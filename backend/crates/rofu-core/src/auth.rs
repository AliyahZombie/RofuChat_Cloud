use crate::{
    api::{ApiError, ApiResult},
    db::Db,
    model::{id, now, text},
};
use argon2::{
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use serde_json::{json, Value};
use sqlx::Row;

pub async fn hash(password: String) -> anyhow::Result<String> {
    tokio::task::spawn_blocking(move || {
        Argon2::default()
            .hash_password(password.as_bytes(), &SaltString::generate(&mut OsRng))
            .map(|p| p.to_string())
            .map_err(|e| anyhow::anyhow!(e.to_string()))
    })
    .await?
}
pub async fn verify(password: String, encoded: String) -> bool {
    tokio::task::spawn_blocking(move || {
        PasswordHash::new(&encoded).is_ok_and(|h| {
            Argon2::default()
                .verify_password(password.as_bytes(), &h)
                .is_ok()
        })
    })
    .await
    .unwrap_or(false)
}
pub async fn create(db: &Db, username: &str, password: &str, root: bool) -> ApiResult<Value> {
    if username.trim().is_empty() || password.is_empty() {
        return Err(ApiError::bad("username and password are required"));
    }
    let exists: Option<String> = sqlx::query_scalar("SELECT id FROM users WHERE username=$1")
        .bind(username)
        .fetch_optional(&db.pool)
        .await?;
    if exists.is_some() {
        return Err(ApiError::conflict("username already exists"));
    }
    let user = json!({"id":id(),"username":username,"is_root":root,"created_at":now()});
    sqlx::query(
        "INSERT INTO users(id,username,password_hash,is_root,created_at) VALUES ($1,$2,$3,$4,$5)",
    )
    .bind(text(&user, "id"))
    .bind(username)
    .bind(hash(password.to_owned()).await?)
    .bind(i64::from(root))
    .bind(now())
    .execute(&db.pool)
    .await?;
    Ok(user)
}
pub async fn initialize(db: &Db, password: Option<&str>) -> anyhow::Result<()> {
    let existing: Option<String> = sqlx::query_scalar("SELECT id FROM users WHERE username='root'")
        .fetch_optional(&db.pool)
        .await?;
    match (existing, password) {
        (None, None) | (None, Some("")) => {
            anyhow::bail!("First startup requires --root-password or ROFU_ROOT_PASSWORD")
        }
        (None, Some(p)) => {
            create(db, "root", p, true)
                .await
                .map_err(|e| anyhow::anyhow!(e.message))?;
        }
        (Some(uid), Some(p)) => {
            if p.is_empty() {
                anyhow::bail!("root password must not be empty");
            }
            sqlx::query("UPDATE users SET password_hash=$1 WHERE id=$2")
                .bind(hash(p.to_owned()).await?)
                .bind(uid)
                .execute(&db.pool)
                .await?;
        }
        _ => {}
    }
    Ok(())
}
pub fn public(row: &sqlx::any::AnyRow) -> Value {
    json!({"id":row.get::<String,_>("id"),"username":row.get::<String,_>("username"),"is_root":row.get::<i64,_>("is_root")!=0,"created_at":row.get::<i64,_>("created_at")})
}
pub async fn login(db: &Db, body: &Value) -> ApiResult<Value> {
    let row = sqlx::query("SELECT * FROM users WHERE username=$1")
        .bind(text(body, "username"))
        .fetch_optional(&db.pool)
        .await?
        .ok_or_else(|| ApiError::unauthorized("invalid credentials"))?;
    if !verify(text(body, "password"), row.get("password_hash")).await {
        return Err(ApiError::unauthorized("invalid credentials"));
    }
    let user = public(&row);
    let token = format!("{}{}", id(), id());
    sqlx::query("INSERT INTO sessions(token,user_id,created_at,last_used) VALUES ($1,$2,$3,$4)")
        .bind(&token)
        .bind(text(&user, "id"))
        .bind(now())
        .bind(now())
        .execute(&db.pool)
        .await?;
    Ok(json!({"token":token,"user":user}))
}
pub async fn authenticate(db: &Db, token: &str) -> ApiResult<Value> {
    let row =
        sqlx::query("SELECT u.* FROM users u JOIN sessions s ON s.user_id=u.id WHERE s.token=$1")
            .bind(token)
            .fetch_optional(&db.pool)
            .await?
            .ok_or_else(|| ApiError::unauthorized("invalid or missing bearer token"))?;
    sqlx::query("UPDATE sessions SET last_used=$1 WHERE token=$2")
        .bind(now())
        .bind(token)
        .execute(&db.pool)
        .await?;
    Ok(public(&row))
}
