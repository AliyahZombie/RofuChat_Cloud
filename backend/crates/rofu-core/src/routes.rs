use crate::{
    api::{self, ApiError, ApiResult},
    card, chat, detect, jstool, llm, mcp, memory,
    model::{id, now, number, text},
    server::AppState,
    swipes,
};
use axum::{
    body::Body,
    http::{header, Method, StatusCode},
    response::{IntoResponse, Redirect, Response},
    Json,
};
use base64::{engine::general_purpose::STANDARD, Engine};
use futures_util::StreamExt;
use serde_json::{json, Value};
use std::{collections::HashMap, time::Instant};
fn ok(v: Value) -> Response {
    Json(v).into_response()
}
fn empty() -> Response {
    StatusCode::NO_CONTENT.into_response()
}
fn binary(bytes: Vec<u8>, mime: &str) -> ApiResult<Response> {
    Response::builder()
        .header(header::CONTENT_TYPE, mime)
        .body(Body::from(bytes))
        .map_err(|e| ApiError::bad(e.to_string()))
}
async fn export_png(s: &AppState, mut c: Value) -> ApiResult<Vec<u8>> {
    let avatar = text(&c, "avatar");
    if avatar.starts_with("https://") || avatar.starts_with("http://") {
        let response = s
            .client
            .get(&avatar)
            .timeout(std::time::Duration::from_secs(20))
            .send()
            .await
            .map_err(|e| ApiError::bad(e.to_string()))?;
        if !response.status().is_success() {
            return Err(ApiError::bad(format!("avatar HTTP {}", response.status())));
        }
        let mut stream = response.bytes_stream();
        let mut bytes = vec![];
        while let Some(chunk) = stream.next().await {
            let chunk = chunk.map_err(|e| ApiError::bad(e.to_string()))?;
            if bytes.len() + chunk.len() > 32 * 1024 * 1024 {
                return Err(ApiError::bad("avatar exceeds 32MB"));
            }
            bytes.extend_from_slice(&chunk);
        }
        if bytes.starts_with(b"\x89PNG\r\n\x1a\n") {
            c["avatar"] = json!(format!("data:image/png;base64,{}", STANDARD.encode(bytes)));
        }
    }
    card::export_png(&c).map_err(|e| ApiError::bad(e.to_string()))
}
#[allow(clippy::too_many_arguments)]
pub async fn dispatch(
    s: &AppState,
    uid: &str,
    method: &Method,
    path: &str,
    parts: &[&str],
    body: &Value,
    q: &HashMap<String, String>,
) -> ApiResult<Option<Response>> {
    if path == "models/detect" && method == Method::POST {
        return Ok(Some(ok(detect::detect(
            &json!({"id":body["model_id"]}),
            "",
        ))));
    }
    if parts.len() == 3 && parts[0] == "providers" && method == Method::POST {
        let provider = api::required(s, uid, "provider", parts[1]).await?;
        if parts[2] == "remote_models" {
            let url = format!(
                "{}/models",
                text(&provider, "base_url").trim_end_matches('/')
            );
            let response = llm::headers(s.client.get(url), &provider)?
                .timeout(std::time::Duration::from_secs(20))
                .send()
                .await
                .map_err(|e| ApiError::bad(e.to_string()))?;
            if !response.status().is_success() {
                let status = response.status();
                let body = response.text().await.unwrap_or_default();
                return Err(ApiError::bad(format!(
                    "HTTP {status}: {}",
                    body.chars().take(800).collect::<String>()
                )));
            }
            let remote: Value = response
                .json()
                .await
                .map_err(|e| ApiError::bad(e.to_string()))?;
            let models = remote["data"]
                .as_array()
                .or_else(|| remote["models"].as_array())
                .ok_or_else(|| {
                    ApiError::bad("remote models response must contain data or models array")
                })?;
            return Ok(Some(ok(json!(models
                .iter()
                .map(|m| detect::detect(m, parts[1]))
                .collect::<Vec<_>>()))));
        }
        if parts[2] == "test" {
            let model = detect::detect(&json!({"id":body["model_id"]}), parts[1]);
            let start = Instant::now();
            let outcome = llm::complete(
                &s.client,
                llm::Request {
                    provider,
                    model,
                    messages: vec![json!({"role":"user","content":"hi"})],
                    params: json!({}),
                    tools: vec![],
                },
            )
            .await;
            return Ok(Some(ok(match outcome {
                Ok(reply) => {
                    json!({"ok":true,"latency_ms":start.elapsed().as_millis() as i64,"reply":reply})
                }
                Err(e) => {
                    json!({"ok":false,"latency_ms":start.elapsed().as_millis() as i64,"error":e.to_string()})
                }
            })));
        }
    }
    if path == "characters/import" && method == Method::POST {
        let c = card::import(body).map_err(|e| ApiError::bad(e.to_string()))?;
        return Ok(Some(ok(s.db.save(uid, "character", c).await?)));
    }
    if parts.len() == 3 && parts[0] == "characters" && method == Method::GET {
        let c = api::required(s, uid, "character", parts[1]).await?;
        if parts[2] == "export" {
            return Ok(Some(
                if q.get("format").map(String::as_str).unwrap_or("json") == "png" {
                    binary(export_png(s, c.clone()).await?, "image/png")?
                } else {
                    ok(card::export_json(&c))
                },
            ));
        }
        if parts[2] == "avatar" {
            let url = text(&c, "avatar");
            if url.starts_with("https://") || url.starts_with("http://") {
                return Ok(Some(Redirect::temporary(&url).into_response()));
            }
            let (bytes, mime) = card::avatar(&c).map_err(|e| ApiError::bad(e.to_string()))?;
            return Ok(Some(binary(bytes, &mime)?));
        }
    }
    if path == "tools/run" && method == Method::POST {
        return Ok(Some(ok(jstool::run(
            text(body, "code"),
            body.get("args").cloned().unwrap_or_else(|| json!({})),
        )
        .await)));
    }
    if path == "mcp/test" && method == Method::POST {
        let outcome = mcp::Connection::connect(s.client.clone(), body.clone()).await;
        return Ok(Some(ok(match outcome {
            Ok(conn) => {
                json!({"ok":true,"tools":conn.tools.iter().map(|t|json!({"name":t["raw_name"],"description":t["description"],"input_schema":t["parameters"]})).collect::<Vec<_>>(),"error":null})
            }
            Err(e) => json!({"ok":false,"tools":[],"error":e.to_string()}),
        })));
    }
    if parts[0] == "conversations" {
        if parts.len() == 1 {
            if method == Method::GET {
                let all = s.db.conversations(uid).await?;
                return Ok(Some(ok(json!(all
                    .into_iter()
                    .filter(|c| q
                        .get("character_id")
                        .is_none_or(|id| text(c, "character_id") == *id))
                    .collect::<Vec<_>>()))));
            }
            if method == Method::POST {
                return Ok(Some(ok(chat::create_conversation(s, uid, body).await?)));
            }
        }
        if parts.len() >= 2 {
            let cid = parts[1];
            let mut conv = api::conversation(s, uid, cid).await?;
            if parts.len() == 2 {
                if method == Method::GET {
                    conv["generating"] = json!(s.generating.lock().await.contains_key(cid));
                    conv["message_count"] = json!(s.db.message_count(uid, cid).await?);
                    return Ok(Some(ok(conv)));
                }
                if method == Method::PATCH {
                    let _lock = s.generating.lock().await;
                    conv = api::conversation(s, uid, cid).await?;
                    if !body["title"].is_string() {
                        return Err(ApiError::bad("title must be a string"));
                    }
                    conv["title"] = body["title"].clone();
                    s.db.save_conversation(uid, &conv).await?;
                    return Ok(Some(ok(conv)));
                }
                if method == Method::DELETE {
                    let lock = s.generating.lock().await;
                    if lock.contains_key(cid) {
                        return Err(ApiError::conflict("conversation is generating"));
                    }
                    s.db.delete_conversation(uid, cid).await?;
                    return Ok(Some(empty()));
                }
            }
            if parts.len() == 3 {
                match (method.as_str(), parts[2]) {
                    ("GET", "messages") => {
                        if q.contains_key("limit") || q.contains_key("max_chars") {
                            let limit = q.get("limit").map(|value| {
                                value.parse::<i64>().ok().filter(|n| *n > 0 && *n < i64::MAX)
                                    .ok_or_else(|| ApiError::bad("limit must be a positive integer less than 9223372036854775807"))
                            }).transpose()?;
                            let max_chars = q
                                .get("max_chars")
                                .map(|value| {
                                    value.parse::<u64>().map_err(|_| {
                                        ApiError::bad(
                                            "max_chars must be an unsigned 64-bit integer",
                                        )
                                    })
                                })
                                .transpose()?;
                            let before = q
                                .get("before_seq")
                                .map(|v| v.parse::<i64>())
                                .transpose()
                                .map_err(|_| ApiError::bad("before_seq must be an integer"))?;
                            let (messages, has_more, chars) =
                                s.db.messages_page(uid, cid, limit, before, max_chars)
                                    .await?;
                            let messages = messages.iter().map(swipes::public).collect::<Vec<_>>();
                            let bytes = serde_json::to_vec(&messages)
                                .map_err(anyhow::Error::from)?
                                .len();
                            return Ok(Some(ok(
                                json!({"messages":messages,"has_more":has_more,"chars":chars,"bytes":bytes}),
                            )));
                        }
                        return Ok(Some(ok(json!(s
                            .db
                            .messages(uid, cid)
                            .await?
                            .iter()
                            .map(swipes::public)
                            .collect::<Vec<_>>()))));
                    }
                    ("GET", "context") => {
                        return Ok(Some(ok(chat::context_info(s, uid, cid).await?)))
                    }
                    ("POST", "chat") => {
                        return Ok(Some(
                            chat::begin(s.clone(), uid.into(), cid.into(), body.clone()).await?,
                        ))
                    }
                    ("POST", "stop") => {
                        if let Some(token) = s.generating.lock().await.get(cid) {
                            token.cancel();
                        }
                        return Ok(Some(empty()));
                    }
                    ("POST", "compress") | ("POST", "memory_scan") => {
                        {
                            let mut running = s.generating.lock().await;
                            if running.contains_key(cid) {
                                return Err(ApiError::conflict("conversation is generating"));
                            }
                            running.insert(cid.into(), tokio_util::sync::CancellationToken::new());
                        }
                        let result = if parts[2] == "memory_scan" {
                            memory::scan(s, uid, cid).await.map(ok)
                        } else {
                            match api::required(s, uid, "character", &text(&conv, "character_id"))
                                .await
                            {
                                Ok(c) if !crate::model::summarize(&c) => Err(ApiError::bad(
                                    "summary compression is disabled (context.summarize=false)",
                                )),
                                Ok(c) => chat::compress(s, uid, cid, &c)
                                    .await
                                    .map(|v| {
                                        v.map(|(m, _)| ok(swipes::public(&m))).unwrap_or_else(empty)
                                    })
                                    .map_err(Into::into),
                                Err(e) => Err(e),
                            }
                        };
                        s.generating.lock().await.remove(cid);
                        return result.map(Some);
                    }
                    _ => {}
                }
            }
        }
    }
    if parts[0] == "messages" && parts.len() >= 2 {
        let mid = parts[1];
        let mut m =
            s.db.message(uid, mid)
                .await?
                .ok_or_else(ApiError::not_found)?;
        let cid = text(&m, "conversation_id");
        if parts.len() == 2 && method == Method::GET {
            return Ok(Some(ok(swipes::public(&m))));
        }
        if parts.len() == 3 && parts[2] == "swipe" && method == Method::POST {
            let index = body["index"]
                .as_u64()
                .and_then(|i| usize::try_from(i).ok())
                .ok_or_else(|| ApiError::bad("index must be a non-negative integer"))?;
            return Ok(Some(ok(
                swipes::change(s, uid, mid, &cid, index, false).await?
            )));
        }
        if parts.len() == 4 && parts[2] == "swipes" && method == Method::DELETE {
            let index = parts[3]
                .parse::<usize>()
                .map_err(|_| ApiError::bad("index must be a non-negative integer"))?;
            return Ok(Some(ok(
                swipes::change(s, uid, mid, &cid, index, true).await?
            )));
        }
        if parts.len() == 2 && matches!(*method, Method::PATCH | Method::DELETE) {
            let lock = s.generating.lock().await;
            if lock.contains_key(&cid) {
                return Err(ApiError::conflict("conversation is generating"));
            }
            if method == Method::DELETE {
                sqlx::query("DELETE FROM messages WHERE user_id=$1 AND id=$2")
                    .bind(uid)
                    .bind(mid)
                    .execute(&s.db.pool)
                    .await?;
                return Ok(Some(empty()));
            }
            m =
                s.db.message(uid, mid)
                    .await?
                    .ok_or_else(ApiError::not_found)?;
            for key in ["content", "visible", "actual"] {
                if let Some(v) = body.get(key) {
                    if key == "visible" && !v.is_boolean() || key != "visible" && !v.is_string() {
                        return Err(ApiError::bad(format!("invalid {key}")));
                    }
                    m[key] = v.clone();
                }
            }
            if body.get("content").is_some() && m["role"] == "assistant" {
                swipes::edit_text(&mut m);
            }
            if body.get("actual").is_some() {
                m["actual_status"] = json!("ok");
                m["actual_error"] = Value::Null;
            }
            s.db.save_message(uid, &m).await?;
            return Ok(Some(ok(swipes::public(&m))));
        }
        if parts.len() == 3 && method == Method::POST {
            if parts[2] == "actual" {
                if m["role"] != "assistant" {
                    return Err(ApiError::bad("only assistant messages have actual content"));
                }
                {
                    let mut running = s.generating.lock().await;
                    if running.contains_key(&cid) {
                        return Err(ApiError::conflict("conversation is generating"));
                    }
                    running.insert(cid.clone(), tokio_util::sync::CancellationToken::new());
                }
                let result = async {
                    let conv = api::conversation(s, uid, &cid).await?;
                    let c =
                        api::required(s, uid, "character", &text(&conv, "character_id")).await?;
                    m =
                        s.db.message(uid, mid)
                            .await?
                            .ok_or_else(ApiError::not_found)?;
                    chat::actual(s, uid, &mut m, &c).await?;
                    Ok::<_, ApiError>(ok(swipes::public(&m)))
                }
                .await;
                s.generating.lock().await.remove(&cid);
                return result.map(Some);
            }
            if parts[2] == "branch" {
                let _lock = s.generating.lock().await;
                let mut conv = api::conversation(s, uid, &cid).await?;
                conv["id"] = json!(id());
                conv["created_at"] = json!(now());
                conv["updated_at"] = json!(now());
                conv["memory_scanned_seq"] = json!(0);
                let copies = s.db.messages(uid, &cid).await?;
                let mut tx = s.db.pool.begin().await?;
                sqlx::query("INSERT INTO conversations(id,user_id,character_id,data,updated_at) VALUES ($1,$2,$3,$4,$5)").bind(text(&conv,"id")).bind(uid).bind(text(&conv,"character_id")).bind(conv.to_string()).bind(now()).execute(&mut *tx).await?;
                for mut copy in copies
                    .into_iter()
                    .filter(|msg| number(msg, "seq", 0) <= number(&m, "seq", 0))
                {
                    copy = swipes::active_only(&copy);
                    copy["id"] = json!(id());
                    copy["conversation_id"] = conv["id"].clone();
                    sqlx::query("INSERT INTO messages(id,user_id,conversation_id,seq,data) VALUES ($1,$2,$3,$4,$5)").bind(text(&copy,"id")).bind(uid).bind(text(&conv,"id")).bind(number(&copy,"seq",0)).bind(copy.to_string()).execute(&mut *tx).await?;
                }
                tx.commit().await?;
                return Ok(Some(ok(conv)));
            }
        }
    }
    Ok(None)
}
