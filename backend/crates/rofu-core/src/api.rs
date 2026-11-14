use crate::{
    auth,
    model::{self, flag, mask, normalized, number, text},
    server::AppState,
};
use axum::{
    extract::{Request, State},
    http::{Method, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use serde_json::{json, Value};
use sqlx::Row;
use std::collections::HashMap;

pub type ApiResult<T> = Result<T, ApiError>;
#[derive(Debug)]
pub struct ApiError {
    pub status: StatusCode,
    pub message: String,
}
impl ApiError {
    pub fn bad(s: impl Into<String>) -> Self {
        Self {
            status: StatusCode::BAD_REQUEST,
            message: s.into(),
        }
    }
    pub fn not_found() -> Self {
        Self {
            status: StatusCode::NOT_FOUND,
            message: "resource not found".into(),
        }
    }
    pub fn unauthorized(s: impl Into<String>) -> Self {
        Self {
            status: StatusCode::UNAUTHORIZED,
            message: s.into(),
        }
    }
    pub fn forbidden(s: impl Into<String>) -> Self {
        Self {
            status: StatusCode::FORBIDDEN,
            message: s.into(),
        }
    }
    pub fn conflict(s: impl Into<String>) -> Self {
        Self {
            status: StatusCode::CONFLICT,
            message: s.into(),
        }
    }
}
impl From<anyhow::Error> for ApiError {
    fn from(e: anyhow::Error) -> Self {
        tracing::error!(error=%e,"request failed");
        Self {
            status: StatusCode::INTERNAL_SERVER_ERROR,
            message: e.to_string(),
        }
    }
}
impl From<sqlx::Error> for ApiError {
    fn from(e: sqlx::Error) -> Self {
        anyhow::Error::from(e).into()
    }
}
impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        (self.status, Json(json!({"error":self.message}))).into_response()
    }
}
fn ok(v: Value) -> Response {
    Json(v).into_response()
}
fn empty() -> Response {
    StatusCode::NO_CONTENT.into_response()
}
pub async fn required(s: &AppState, uid: &str, kind: &str, eid: &str) -> ApiResult<Value> {
    s.db.get(uid, kind, eid)
        .await?
        .ok_or_else(ApiError::not_found)
}
pub async fn conversation(s: &AppState, uid: &str, cid: &str) -> ApiResult<Value> {
    s.db.conversation(uid, cid)
        .await?
        .ok_or_else(ApiError::not_found)
}
pub async fn settings(s: &AppState, uid: &str) -> ApiResult<Value> {
    Ok(s.db
        .list(uid, "settings")
        .await?
        .into_iter()
        .next()
        .unwrap_or_else(|| model::defaults("settings")))
}

pub async fn dispatch(State(s): State<AppState>, req: Request) -> Result<Response, ApiError> {
    let method = req.method().clone();
    let path = req.uri().path().trim_start_matches("/api/").to_owned();
    let query: HashMap<String, String> =
        url::form_urlencoded::parse(req.uri().query().unwrap_or("").as_bytes())
            .into_owned()
            .collect();
    let token = req
        .headers()
        .get("authorization")
        .and_then(|v| v.to_str().ok())
        .and_then(|s| s.strip_prefix("Bearer "))
        .map(str::to_owned)
        .or_else(|| query.get("token").cloned())
        .unwrap_or_default();
    let raw = axum::body::to_bytes(req.into_body(), 32 * 1024 * 1024)
        .await
        .map_err(|e| ApiError::bad(e.to_string()))?;
    let body: Value = if raw.is_empty() {
        json!({})
    } else {
        serde_json::from_slice(&raw).map_err(|e| ApiError::bad(e.to_string()))?
    };
    if path == "health" && method == Method::GET {
        return Ok(ok(
            json!({"name":"RofuChat","version":"0.1.0","allow_register":s.db.registration().await?,"embedded":s.embedded}),
        ));
    }
    if path == "auth/login" && method == Method::POST {
        return Ok(ok(auth::login(&s.db, &body).await?));
    }
    if path == "auth/register" && method == Method::POST {
        if !s.db.registration().await? {
            return Err(ApiError::forbidden("registration is disabled"));
        }
        auth::create(
            &s.db,
            &text(&body, "username"),
            &text(&body, "password"),
            false,
        )
        .await?;
        return Ok(ok(auth::login(&s.db, &body).await?));
    }
    let user = auth::authenticate(&s.db, &token).await?;
    let uid = text(&user, "id");
    let parts: Vec<&str> = path.split('/').collect();
    if path == "auth/me" && method == Method::GET {
        return Ok(ok(user));
    }
    if path == "auth/logout" && method == Method::POST {
        sqlx::query("DELETE FROM sessions WHERE token=$1 AND user_id=$2")
            .bind(token)
            .bind(&uid)
            .execute(&s.db.pool)
            .await?;
        return Ok(empty());
    }
    if path == "auth/password" && method == Method::POST {
        let hash: String = sqlx::query_scalar("SELECT password_hash FROM users WHERE id=$1")
            .bind(&uid)
            .fetch_one(&s.db.pool)
            .await?;
        if !auth::verify(text(&body, "old_password"), hash).await {
            return Err(ApiError::forbidden("incorrect old password"));
        }
        if text(&body, "new_password").is_empty() {
            return Err(ApiError::bad("new_password is required"));
        }
        sqlx::query("UPDATE users SET password_hash=$1 WHERE id=$2")
            .bind(auth::hash(text(&body, "new_password")).await?)
            .bind(&uid)
            .execute(&s.db.pool)
            .await?;
        sqlx::query("DELETE FROM sessions WHERE user_id=$1 AND token<>$2")
            .bind(&uid)
            .bind(token)
            .execute(&s.db.pool)
            .await?;
        return Ok(empty());
    }
    if parts[0] == "admin" {
        if !flag(&user, "is_root", false) {
            return Err(ApiError::forbidden("root required"));
        }
        if path == "admin/config" {
            if method == Method::PUT {
                s.db.set_registration(flag(&body, "allow_register", false))
                    .await?;
            }
            if method == Method::GET || method == Method::PUT {
                return Ok(ok(json!({"allow_register":s.db.registration().await?})));
            }
        }
        if path == "admin/users" {
            if method == Method::POST {
                return Ok(ok(auth::create(
                    &s.db,
                    &text(&body, "username"),
                    &text(&body, "password"),
                    false,
                )
                .await?));
            }
            if method == Method::GET {
                let rows = sqlx::query("SELECT * FROM users ORDER BY created_at,id")
                    .fetch_all(&s.db.pool)
                    .await?;
                return Ok(ok(Value::Array(rows.iter().map(auth::public).collect())));
            }
        }
        if parts.len() >= 3 && parts[1] == "users" {
            let target = parts[2];
            let row = sqlx::query("SELECT * FROM users WHERE id=$1")
                .bind(target)
                .fetch_optional(&s.db.pool)
                .await?
                .ok_or_else(ApiError::not_found)?;
            if parts.len() == 4 && parts[3] == "password" && method == Method::POST {
                if text(&body, "password").is_empty() {
                    return Err(ApiError::bad("password is required"));
                }
                sqlx::query("UPDATE users SET password_hash=$1 WHERE id=$2")
                    .bind(auth::hash(text(&body, "password")).await?)
                    .bind(target)
                    .execute(&s.db.pool)
                    .await?;
                sqlx::query("DELETE FROM sessions WHERE user_id=$1")
                    .bind(target)
                    .execute(&s.db.pool)
                    .await?;
                return Ok(empty());
            }
            if parts.len() == 3 && method == Method::DELETE {
                if row.get::<i64, _>("is_root") != 0 {
                    return Err(ApiError::forbidden("cannot delete root"));
                }
                let mut tx = s.db.pool.begin().await?;
                for table in ["sessions", "entities", "conversations", "messages"] {
                    sqlx::query(&format!("DELETE FROM {table} WHERE user_id=$1"))
                        .bind(target)
                        .execute(&mut *tx)
                        .await?;
                }
                sqlx::query("DELETE FROM users WHERE id=$1")
                    .bind(target)
                    .execute(&mut *tx)
                    .await?;
                tx.commit().await?;
                return Ok(empty());
            }
        }
        return Err(ApiError::not_found());
    }
    if path == "settings" {
        let old = settings(&s, &uid).await?;
        if method == Method::GET {
            return Ok(ok(old));
        }
        if method == Method::PUT {
            let mut v = normalized("settings", &body);
            v["id"] = json!(text(&old, "id"));
            return Ok(ok(s.db.save(&uid, "settings", v).await?));
        }
    }
    if let Some(response) =
        crate::routes::dispatch(&s, &uid, &method, &path, &parts, &body, &query).await?
    {
        return Ok(response);
    }
    let kind = match parts[0] {
        "providers" => "provider",
        "models" => "model",
        "characters" => "character",
        "tools" => "tool",
        "memories" => "memory",
        _ => "",
    };
    if !kind.is_empty() {
        if path == "models/detect" && method == Method::POST {
            let mut v = model::defaults("model");
            v["model_id"] = body["model_id"].clone();
            return Ok(ok(v));
        }
        if path == "characters/order" && method == Method::PUT {
            let ids = body
                .as_array()
                .ok_or_else(|| ApiError::bad("expected array"))?;
            for val in ids {
                required(&s, &uid, "character", val.as_str().unwrap_or("")).await?;
            }
            for (n, val) in ids.iter().enumerate() {
                let mut v = required(&s, &uid, "character", val.as_str().unwrap_or("")).await?;
                v["sort"] = json!(n);
                s.db.save(&uid, "character", v).await?;
            }
            return Ok(empty());
        }
        if parts.len() == 1 {
            if method == Method::GET {
                let mut values = s.db.list(&uid, kind).await?;
                values.retain(|v| match kind {
                    "model" => query
                        .get("provider_id")
                        .is_none_or(|p| text(v, "provider_id") == *p),
                    "memory" => query.get("character_id").is_none_or(|p| {
                        if p == "global" {
                            v["character_id"].is_null()
                        } else {
                            text(v, "character_id") == *p
                        }
                    }),
                    _ => true,
                });
                if kind == "character" {
                    values.sort_by_key(|v| (number(v, "sort", 0), number(v, "created_at", 0)));
                }
                if kind == "memory" {
                    if let Some(q) = query.get("q") {
                        values = crate::memory::search(values, q, usize::MAX);
                    }
                }
                for v in &mut values {
                    redact(kind, v, true);
                }
                return Ok(ok(json!(values)));
            }
            if method == Method::POST {
                if kind == "model" && body.is_array() {
                    let mut out = vec![];
                    for v in body.as_array().unwrap() {
                        out.push(save_entity(&s, &uid, kind, v, None).await?);
                    }
                    return Ok(ok(json!(out)));
                }
                return Ok(ok(save_entity(&s, &uid, kind, &body, None).await?));
            }
        }
        if parts.len() == 2 {
            let eid = parts[1];
            let mut v = required(&s, &uid, kind, eid).await?;
            if method == Method::GET {
                redact(kind, &mut v, false);
                return Ok(ok(v));
            }
            if method == Method::PUT {
                return Ok(ok(save_entity(&s, &uid, kind, &body, Some(v)).await?));
            }
            if method == Method::DELETE {
                s.db.delete(&uid, kind, eid).await?;
                return Ok(empty());
            }
        }
    }
    Err(ApiError::not_found())
}
fn redact(kind: &str, v: &mut Value, list: bool) {
    if kind == "provider" {
        v["api_key"] = json!(mask(&text(v, "api_key")));
    }
    if kind == "character" && list && text(v, "avatar").starts_with("data:") {
        v["avatar"] = json!(format!("/api/characters/{}/avatar", text(v, "id")));
    }
}
async fn save_entity(
    s: &AppState,
    uid: &str,
    kind: &str,
    input: &Value,
    old: Option<Value>,
) -> ApiResult<Value> {
    if !input.is_object() {
        return Err(ApiError::bad("expected object"));
    }
    let mut v = normalized(kind, input);
    v.as_object_mut().unwrap().remove("id");
    v.as_object_mut().unwrap().remove("created_at");
    if let Some(ref old) = old {
        v["id"] = old["id"].clone();
        v["created_at"] = old["created_at"].clone();
        if kind == "provider"
            && (text(&v, "api_key").is_empty()
                || text(&v, "api_key") == mask(&text(old, "api_key")))
        {
            v["api_key"] = old["api_key"].clone();
        }
    }
    if kind == "model" {
        required(s, uid, "provider", &text(&v, "provider_id")).await?;
        if old.is_none() {
            if let Some(existing) =
                s.db.list(uid, kind).await?.into_iter().find(|e| {
                    e["provider_id"] == v["provider_id"] && e["model_id"] == v["model_id"]
                })
            {
                v["id"] = existing["id"].clone();
                v["created_at"] = existing["created_at"].clone();
            }
        }
    }
    if kind == "provider" && text(&v, "icon").is_empty() {
        v["icon"] = json!(crate::detect::icon(&format!(
            "{} {}",
            text(&v, "name"),
            text(&v, "base_url")
        )));
    }
    if kind == "character" {
        if !text(&v, "model_id").is_empty() {
            required(s, uid, "model", &text(&v, "model_id")).await?;
        }
        if let Some(ids) = v["tool_ids"].as_array() {
            for tid in ids {
                required(s, uid, "tool", tid.as_str().unwrap_or("")).await?;
            }
        }
    }
    if kind == "memory" {
        v["source"] = json!("user");
        if !v["character_id"].is_null() {
            required(s, uid, "character", &text(&v, "character_id")).await?;
        }
    }
    let mut out = s.db.save(uid, kind, v).await?;
    redact(kind, &mut out, false);
    Ok(out)
}
