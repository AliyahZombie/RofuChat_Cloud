use super::host::{self, Operation, Session};
use crate::{
    model::{flag, text},
    server::AppState,
};
use anyhow::{ensure, Result};
use serde_json::{json, Value};

pub async fn enabled(s: &AppState, uid: &str, character: &Value) -> Result<Vec<Value>> {
    let mut out = vec![];
    if let Some(ids) = character["tool_ids"].as_array() {
        for id in ids {
            if let Some(plugin) = s.db.get(uid, "plugin", id.as_str().unwrap_or("")).await? {
                if flag(&plugin, "enabled", false) {
                    out.push(plugin);
                }
            }
        }
    }
    Ok(out)
}
pub fn error(op: &Operation, plugin: &Value, phase: &str, e: &anyhow::Error) {
    let message = e.to_string();
    let code = message
        .split(':')
        .next()
        .filter(|s| s.starts_with("E_"))
        .unwrap_or("E_JS");
    op.emit(json!({"type":"plugin_error","plugin_id":plugin["id"],"phase":phase,"code":code,"error":message}));
}
pub struct HookResult {
    pub payload: Value,
    pub staged: Vec<Session>,
    pub cancelled: bool,
}
#[allow(clippy::too_many_arguments)]
pub async fn run(
    s: &AppState,
    uid: &str,
    cid: &str,
    plugins: &[Value],
    phase: &str,
    mut payload: Value,
    op: &Operation,
    defer: bool,
) -> HookResult {
    let mut staged: Vec<Session> = vec![];
    for plugin in plugins {
        if op.cancel.is_cancelled() {
            break;
        }
        let handler = text(&plugin["manifest"]["hooks"], phase);
        if handler.is_empty() {
            continue;
        }
        let result = async {
            let mut outcome = host::invoke(
                s,
                uid,
                cid,
                plugin,
                &handler,
                payload.clone(),
                phase,
                op,
                if defer { staged.last() } else { None },
            )
            .await?;
            let patched = apply(phase, &payload, &outcome.result)?;
            if defer && patched["cancel"].is_null() {
                host::validate_messages(&outcome.session.messages, uid, cid)?;
                super::storage::check(&s.db, uid, &text(plugin, "id"), &outcome.session.kv).await?;
                let mut images = json!({"images":patched["images"]});
                s.db.stage_images(uid, &mut images, &mut vec![])
                    .await
                    .map_err(|e| anyhow::anyhow!("E_VALIDATION: {e}"))?;
                let mut rows = json!(outcome.session.messages);
                s.db.stage_images(uid, &mut rows, &mut vec![])
                    .await
                    .map_err(|e| anyhow::anyhow!("E_VALIDATION: {e}"))?;
            }
            if !defer {
                outcome.session.commit().await?;
            }
            Ok::<_, anyhow::Error>((patched, outcome.session))
        }
        .await;
        match result {
            Ok((patched, session)) => {
                payload = patched;
                if defer {
                    staged.push(session);
                }
                if phase == "beforeSend" && !payload["cancel"].is_null() {
                    op.emit(json!({"type":"plugin_cancelled","plugin_id":plugin["id"],"reason":payload["cancel"]["reason"]}));
                    return HookResult {
                        payload,
                        staged: vec![],
                        cancelled: true,
                    };
                }
            }
            Err(e) => error(op, plugin, phase, &e),
        }
    }
    HookResult {
        payload,
        staged,
        cancelled: false,
    }
}
fn apply(phase: &str, payload: &Value, result: &Value) -> Result<Value> {
    if result.is_null() {
        return Ok(payload.clone());
    }
    let object = result
        .as_object()
        .ok_or_else(|| anyhow::anyhow!("E_VALIDATION: hook result must be object or undefined"))?;
    let allowed: &[&str] = match phase {
        "beforeSend" => &["patch", "cancel"],
        "beforeToolCall" => &["args", "skip"],
        "afterToolCall" => &["result", "is_error"],
        _ => &[],
    };
    ensure!(
        object.keys().all(|k| allowed.contains(&k.as_str())) && phase != "afterReply",
        "E_VALIDATION: unsupported hook return field"
    );
    let mut value = payload.clone();
    match phase {
        "beforeSend" => {
            if let Some(patch) = result.get("patch") {
                ensure!(patch.is_object(), "E_VALIDATION: patch must be object");
                for (key, v) in patch.as_object().unwrap() {
                    match key.as_str() {
                        "content" => ensure!(
                            v.is_string() && payload["mode"] != "regenerate",
                            "E_VALIDATION: invalid content patch"
                        ),
                        "images" => ensure!(
                            v.is_array() && payload["mode"] != "regenerate",
                            "E_VALIDATION: invalid images patch"
                        ),
                        "params" => {
                            ensure!(v.is_object(), "E_VALIDATION: params must be object");
                            for (k, p) in v.as_object().unwrap() {
                                ensure!(
                                    match k.as_str() {
                                        "temperature" | "top_p" => p.is_null() || p.is_number(),
                                        "max_tokens" =>
                                            p.is_null() || p.as_u64().is_some_and(|n| n > 0),
                                        "reasoning_effort" => p.is_string(),
                                        _ => false,
                                    },
                                    "E_VALIDATION: invalid parameter {k}"
                                );
                            }
                        }
                        _ => anyhow::bail!("E_VALIDATION: unknown patch field {key}"),
                    }
                    if key == "params" {
                        crate::model::merge(&mut value["params"], v);
                    } else {
                        value[key] = v.clone();
                    }
                }
            }
            if let Some(cancel) = result.get("cancel") {
                ensure!(
                    cancel.is_object() && cancel["reason"].is_string(),
                    "E_VALIDATION: cancel requires reason"
                );
                value["cancel"] = cancel.clone();
            }
        }
        "beforeToolCall" => {
            ensure!(
                result.get("args").is_none() || result.get("skip").is_none(),
                "E_VALIDATION: return args or skip"
            );
            if let Some(args) = result.get("args") {
                super::validate_args(&payload["parameters"], args)?;
                value["args"] = args.clone();
            }
            if let Some(skip) = result.get("skip") {
                ensure!(
                    skip["result"].is_string() && skip["is_error"].is_boolean(),
                    "E_VALIDATION: skip requires result and is_error"
                );
                value["skip"] = skip.clone();
            }
        }
        "afterToolCall" => {
            for key in ["result", "is_error"] {
                if let Some(v) = result.get(key) {
                    ensure!(
                        if key == "result" {
                            v.is_string()
                        } else {
                            v.is_boolean()
                        },
                        "E_VALIDATION: invalid {key}"
                    );
                    value[key] = v.clone();
                }
            }
        }
        _ => {}
    }
    Ok(value)
}
