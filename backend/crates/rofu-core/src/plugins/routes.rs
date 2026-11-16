use super::{runtime, storage};
use crate::{
    api::{self, ApiError, ApiResult},
    model::{flag, text},
    server::AppState,
};
use axum::{
    http::{Method, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use serde_json::{json, Value};

fn ok(v: Value) -> Response {
    Json(v).into_response()
}
fn validation(e: anyhow::Error) -> ApiError {
    ApiError::bad(e.to_string())
}

pub async fn dispatch(
    s: &AppState,
    uid: &str,
    method: &Method,
    parts: &[&str],
    body: &Value,
) -> ApiResult<Option<Response>> {
    if parts.len() == 3 && parts[0] == "plugins" && parts[1] == "calls" && method == Method::POST {
        let mut calls = s.plugins.dialogs.lock().await;
        let call = calls
            .get(parts[2])
            .filter(|c| c.uid == uid)
            .ok_or_else(ApiError::not_found)?;
        if text(body, "client_id") != call.client_id {
            return Err(ApiError::not_found());
        }
        let dismissed = body["action"].is_null();
        if !dismissed && !call.actions.contains(&text(body, "action")) {
            return Err(ApiError::bad("E_VALIDATION: invalid dialog action"));
        }
        if !body["input"].is_null() && !body["input"].is_string() {
            return Err(ApiError::bad("E_VALIDATION: input must be string or null"));
        }
        if text(body, "input").chars().count() > call.max_length {
            return Err(ApiError::bad("E_VALIDATION: dialog input too long"));
        }
        let call = calls.remove(parts[2]).unwrap();
        let _=call.reply.send(json!({"action":if dismissed {json!(call.default_action)}else{body["action"].clone()},"input":body["input"],"reason":if dismissed {"dismissed"}else{"answered"}}));
        return Ok(Some(StatusCode::NO_CONTENT.into_response()));
    }
    if parts.len() == 3
        && parts[0] == "conversations"
        && parts[2] == "plugin_menus"
        && method == Method::GET
    {
        let conv = api::conversation(s, uid, parts[1]).await?;
        let character = api::required(s, uid, "character", &text(&conv, "character_id")).await?;
        let mut menus = vec![];
        for plugin in super::hooks::enabled(s, uid, &character).await? {
            if let Some(items) = plugin["manifest"]["menus"].as_array() {
                for item in items {
                    menus.push(json!({"plugin_id":plugin["id"],"plugin_name":plugin["name"],"id":item["id"],"label":item["label"],"icon":item.get("icon").cloned().unwrap_or(Value::Null)}));
                }
            }
        }
        return Ok(Some(ok(json!(menus))));
    }
    if parts.len() == 3
        && parts[0] == "characters"
        && parts[2] == "plugins"
        && method == Method::PUT
    {
        let running = s.generating.lock().await;
        let mut character = api::required(s, uid, "character", parts[1]).await?;
        api::ensure_character_idle(s, uid, parts[1], &running).await?;
        let ids = body
            .as_array()
            .or_else(|| body["plugin_ids"].as_array())
            .ok_or_else(|| ApiError::bad("E_VALIDATION: expected plugin ID array"))?;
        let mut unique = std::collections::HashSet::new();
        for id in ids {
            let id = id
                .as_str()
                .ok_or_else(|| ApiError::bad("E_VALIDATION: expected plugin ID string"))?;
            if !unique.insert(id) {
                return Err(ApiError::bad("E_VALIDATION: duplicate plugin ID"));
            }
            api::required(s, uid, "plugin", id).await?;
        }
        character["tool_ids"] = json!(ids);
        let character = s.db.save(uid, "character", character).await?;
        return Ok(Some(ok(json!({"plugin_ids":character["tool_ids"]}))));
    }
    if parts[0] != "plugins" {
        return Ok(None);
    }
    if parts.len() == 1 {
        if method == Method::GET {
            let mut values = s.db.list(uid, "plugin").await?;
            for value in &mut values {
                let code = value.as_object_mut().unwrap().remove("code");
                value["code_chars"] = json!(code
                    .and_then(|v| v.as_str().map(|s| s.chars().count()))
                    .unwrap_or(0));
            }
            return Ok(Some(ok(json!(values))));
        }
        if method == Method::POST {
            return Ok(Some(ok(save(s, uid, body, None).await?)));
        }
        return Ok(None);
    }
    let plugin = api::required(s, uid, "plugin", parts[1]).await?;
    if parts.len() == 5 && parts[2] == "menus" && parts[4] == "invoke" && method == Method::POST {
        return Ok(Some(menu(s, uid, &plugin, parts[3], body).await?));
    }
    if parts.len() == 2 {
        if method == Method::GET {
            return Ok(Some(ok(plugin)));
        }
        if method == Method::PUT {
            return Ok(Some(ok(save(s, uid, body, Some(plugin)).await?)));
        }
        if method == Method::DELETE {
            s.db.delete(uid, "plugin", parts[1]).await?;
            return Ok(Some(StatusCode::NO_CONTENT.into_response()));
        }
    }
    if parts.len() == 3 && parts[2] == "enable" && matches!(*method, Method::POST | Method::PUT) {
        let mut plugin = plugin;
        plugin["enabled"] = json!(flag(body, "enabled", true));
        plugin["granted_permissions"] = if flag(&plugin, "enabled", false) {
            plugin["manifest"]["permissions"].clone()
        } else {
            json!([])
        };
        return Ok(Some(ok(s.db.save(uid, "plugin", plugin).await?)));
    }
    if (parts.len() == 3 || parts.len() == 4) && parts[2] == "storage" {
        if method == Method::GET && parts.len() == 3 {
            return Ok(Some(ok(storage::usage(&s.db, uid, parts[1]).await?)));
        }
        if method == Method::DELETE {
            storage::clear(&s.db, uid, parts[1], parts.get(3).copied()).await?;
            return Ok(Some(StatusCode::NO_CONTENT.into_response()));
        }
    }
    Ok(None)
}
async fn save(s: &AppState, uid: &str, input: &Value, old: Option<Value>) -> ApiResult<Value> {
    if !input.is_object() {
        return Err(ApiError::bad("E_VALIDATION: expected plugin object"));
    }
    let mut value = super::defaults();
    crate::model::merge(&mut value, input);
    for k in [
        "id",
        "created_at",
        "updated_at",
        "code_chars",
        "granted_permissions",
    ] {
        value.as_object_mut().unwrap().remove(k);
    }
    if let Some(old) = old {
        value["id"] = old["id"].clone();
        value["created_at"] = old["created_at"].clone();
        if input.get("code").is_none() {
            value["code"] = old["code"].clone();
        }
        if input.get("format").is_none() {
            value["format"] = old["format"].clone();
        }
        if old["manifest"]["permissions"] != value["manifest"]["permissions"] {
            value["enabled"] = json!(false);
        }
    }
    if value["format"] == "legacy-main" {
        value = super::legacy_plugin(value);
    }
    super::validate(&value).map_err(validation)?;
    if value["format"] == "module-v1" {
        runtime::compile(text(&value, "code"))
            .await
            .map_err(validation)?;
    }
    value["granted_permissions"] = if flag(&value, "enabled", false) {
        value["manifest"]["permissions"].clone()
    } else {
        json!([])
    };
    Ok(s.db.save(uid, "plugin", value).await?)
}

async fn menu(
    s: &AppState,
    uid: &str,
    plugin: &Value,
    menu_id: &str,
    body: &Value,
) -> ApiResult<Response> {
    if s.shutdown.is_cancelled() {
        return Err(ApiError::conflict("server is stopping"));
    }
    if body.get("plugin_protocol").is_some_and(|v| v != 1)
        || body.get("client_id").is_some_and(|v| !v.is_string())
        || body
            .get("ui_capabilities")
            .is_some_and(|v| !v.as_array().is_some_and(|a| a.iter().all(Value::is_string)))
    {
        return Err(ApiError::bad("E_VALIDATION: invalid plugin negotiation"));
    }
    let cid = text(body, "conversation_id");
    let conv = api::conversation(s, uid, &cid).await?;
    let character = api::required(s, uid, "character", &text(&conv, "character_id")).await?;
    if !flag(plugin, "enabled", false)
        || !character["tool_ids"]
            .as_array()
            .is_some_and(|ids| ids.contains(&plugin["id"]))
    {
        return Err(ApiError::not_found());
    }
    let item = plugin["manifest"]["menus"]
        .as_array()
        .and_then(|a| a.iter().find(|v| v["id"] == menu_id))
        .ok_or_else(ApiError::not_found)?;
    let handler = text(item, "handler");
    let plugin = plugin.clone();
    let s = s.clone();
    let uid = uid.to_owned();
    let cancel = tokio_util::sync::CancellationToken::new();
    {
        let mut running = s.generating.lock().await;
        if running.contains_key(&cid) {
            return Err(ApiError::conflict("conversation is generating"));
        }
        running.insert(cid.clone(), cancel.clone());
    }
    let (tx, rx) = tokio::sync::mpsc::unbounded_channel();
    let mut negotiation = body.clone();
    if negotiation.get("plugin_protocol").is_none() {
        negotiation["plugin_protocol"] = json!(1);
    }
    let operation = super::host::Operation::new(tx.clone(), cancel, &negotiation);
    let input = body.get("input").cloned().unwrap_or(Value::Null);
    let menu_id = menu_id.to_owned();
    s.tasks.clone().spawn(async move {
        let result=async {
            let mut outcome=super::host::invoke(&s,&uid,&cid,&plugin,&handler,input,"menu",&operation,None).await?;
            outcome.session.commit().await?;
            operation.emit(json!({"type":"plugin_result","plugin_id":plugin["id"],"menu_id":menu_id,"result":outcome.result}));
            crate::chat::drain_follow_ups(&s,&uid,&cid,&operation).await?;
            Ok::<_,anyhow::Error>(())
        }.await;
        if let Err(e)=result{super::hooks::error(&operation,&plugin,"menu",&e);}
        s.generating.lock().await.remove(&cid);let _=tx.send(json!({"type":"done"}));
    });
    Ok(crate::chat::event_stream(rx))
}
