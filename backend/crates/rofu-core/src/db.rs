use crate::model::{id, now, text};
use anyhow::{bail, Result};
use serde_json::{json, Value};
use sqlx::{any::AnyPoolOptions, AnyPool, Row};

#[derive(Clone)]
pub struct Db {
    pub pool: AnyPool,
}
impl Db {
    pub async fn connect(url: &str) -> Result<Self> {
        sqlx::any::install_default_drivers();
        let url =
            if url.starts_with("sqlite:") && !url.contains("mode=") && !url.contains(":memory:") {
                format!("{url}{}mode=rwc", if url.contains('?') { "&" } else { "?" })
            } else {
                url.to_owned()
            };
        let pool = AnyPoolOptions::new()
            .max_connections(if url.contains(":memory:") { 1 } else { 5 })
            .connect(&url)
            .await?;
        let db = Self { pool };
        db.migrate().await?;
        Ok(db)
    }
    async fn migrate(&self) -> Result<()> {
        sqlx::query("CREATE TABLE IF NOT EXISTS schema_version (version BIGINT PRIMARY KEY)")
            .execute(&self.pool)
            .await?;
        let mut tx = self.pool.begin().await?;
        let version: Option<i64> = sqlx::query_scalar("SELECT MAX(version) FROM schema_version")
            .fetch_one(&mut *tx)
            .await?;
        if version.unwrap_or(0) < 1 {
            for q in [
                "CREATE TABLE users (id TEXT PRIMARY KEY, username TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, is_root BIGINT NOT NULL, created_at BIGINT NOT NULL)",
                "CREATE TABLE sessions (token TEXT PRIMARY KEY, user_id TEXT NOT NULL, created_at BIGINT NOT NULL, last_used BIGINT NOT NULL)",
                "CREATE INDEX sessions_user ON sessions(user_id)",
                "CREATE TABLE kv (key TEXT PRIMARY KEY, value TEXT NOT NULL)",
                "CREATE TABLE entities (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, kind TEXT NOT NULL, parent_id TEXT NOT NULL, data TEXT NOT NULL, created_at BIGINT NOT NULL, updated_at BIGINT NOT NULL)",
                "CREATE INDEX entities_owner ON entities(user_id,kind)",
                "CREATE TABLE conversations (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, character_id TEXT NOT NULL, data TEXT NOT NULL, updated_at BIGINT NOT NULL)",
                "CREATE INDEX conversations_owner ON conversations(user_id,character_id)",
                "CREATE TABLE messages (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, conversation_id TEXT NOT NULL, seq BIGINT NOT NULL, data TEXT NOT NULL)",
                "CREATE INDEX messages_order ON messages(conversation_id,seq)",
                "INSERT INTO schema_version(version) VALUES (1)",
            ] { sqlx::query(q).execute(&mut *tx).await?; }
        }
        tx.commit().await?;
        Ok(())
    }
    pub async fn registration(&self) -> Result<bool> {
        Ok(
            sqlx::query_scalar::<_, String>("SELECT value FROM kv WHERE key='allow_register'")
                .fetch_optional(&self.pool)
                .await?
                .as_deref()
                == Some("true"),
        )
    }
    pub async fn set_registration(&self, v: bool) -> Result<()> {
        sqlx::query("INSERT INTO kv(key,value) VALUES ('allow_register',$1) ON CONFLICT(key) DO UPDATE SET value=excluded.value").bind(v.to_string()).execute(&self.pool).await?;
        Ok(())
    }
    pub async fn list(&self, uid: &str, kind: &str) -> Result<Vec<Value>> {
        let rows = sqlx::query(
            "SELECT data FROM entities WHERE user_id=$1 AND kind=$2 ORDER BY created_at,id",
        )
        .bind(uid)
        .bind(kind)
        .fetch_all(&self.pool)
        .await?;
        rows.into_iter()
            .map(|r| Ok(serde_json::from_str(r.try_get::<&str, _>("data")?)?))
            .collect()
    }
    pub async fn get(&self, uid: &str, kind: &str, eid: &str) -> Result<Option<Value>> {
        let row = sqlx::query("SELECT data FROM entities WHERE user_id=$1 AND kind=$2 AND id=$3")
            .bind(uid)
            .bind(kind)
            .bind(eid)
            .fetch_optional(&self.pool)
            .await?;
        row.map(|r| Ok(serde_json::from_str(r.try_get::<&str, _>("data")?)?))
            .transpose()
    }
    pub async fn save(&self, uid: &str, kind: &str, mut data: Value) -> Result<Value> {
        if text(&data, "id").is_empty() {
            data["id"] = json!(if kind == "memory" {
                id()[..12].to_owned()
            } else {
                id()
            });
            data["created_at"] = json!(now());
        }
        data["updated_at"] = json!(now());
        let parent = if kind == "model" {
            text(&data, "provider_id")
        } else {
            text(&data, "character_id")
        };
        // Never allow an upsert to transfer ownership.
        let existing: Option<String> =
            sqlx::query_scalar("SELECT user_id FROM entities WHERE id=$1")
                .bind(text(&data, "id"))
                .fetch_optional(&self.pool)
                .await?;
        if existing.as_deref().is_some_and(|s| s != uid) {
            bail!("resource not found");
        }
        sqlx::query("INSERT INTO entities(id,user_id,kind,parent_id,data,created_at,updated_at) VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT(id) DO UPDATE SET data=excluded.data,parent_id=excluded.parent_id,updated_at=excluded.updated_at")
            .bind(text(&data,"id")).bind(uid).bind(kind).bind(parent).bind(data.to_string()).bind(data["created_at"].as_i64().unwrap_or_else(now)).bind(now()).execute(&self.pool).await?;
        Ok(data)
    }
    pub async fn delete(&self, uid: &str, kind: &str, eid: &str) -> Result<()> {
        let mut tx = self.pool.begin().await?;
        if kind == "provider" {
            sqlx::query("DELETE FROM entities WHERE user_id=$1 AND kind='model' AND parent_id=$2")
                .bind(uid)
                .bind(eid)
                .execute(&mut *tx)
                .await?;
        }
        if kind == "character" {
            sqlx::query("DELETE FROM messages WHERE user_id=$1 AND conversation_id IN (SELECT id FROM conversations WHERE user_id=$1 AND character_id=$2)").bind(uid).bind(eid).execute(&mut *tx).await?;
            sqlx::query("DELETE FROM conversations WHERE user_id=$1 AND character_id=$2")
                .bind(uid)
                .bind(eid)
                .execute(&mut *tx)
                .await?;
            sqlx::query("DELETE FROM entities WHERE user_id=$1 AND kind='memory' AND parent_id=$2")
                .bind(uid)
                .bind(eid)
                .execute(&mut *tx)
                .await?;
        }
        sqlx::query("DELETE FROM entities WHERE user_id=$1 AND kind=$2 AND id=$3")
            .bind(uid)
            .bind(kind)
            .bind(eid)
            .execute(&mut *tx)
            .await?;
        tx.commit().await?;
        Ok(())
    }
    pub async fn conversation(&self, uid: &str, cid: &str) -> Result<Option<Value>> {
        let row: Option<String> =
            sqlx::query_scalar("SELECT data FROM conversations WHERE user_id=$1 AND id=$2")
                .bind(uid)
                .bind(cid)
                .fetch_optional(&self.pool)
                .await?;
        row.map(|s| Ok(serde_json::from_str(&s)?)).transpose()
    }
    pub async fn conversations(&self, uid: &str) -> Result<Vec<Value>> {
        let rows: Vec<String> = sqlx::query_scalar(
            "SELECT data FROM conversations WHERE user_id=$1 ORDER BY updated_at DESC,id",
        )
        .bind(uid)
        .fetch_all(&self.pool)
        .await?;
        rows.into_iter()
            .map(|s| Ok(serde_json::from_str(&s)?))
            .collect()
    }
    pub async fn save_conversation(&self, uid: &str, v: &Value) -> Result<()> {
        sqlx::query("INSERT INTO conversations(id,user_id,character_id,data,updated_at) VALUES ($1,$2,$3,$4,$5) ON CONFLICT(id) DO UPDATE SET data=excluded.data,updated_at=excluded.updated_at WHERE conversations.user_id=excluded.user_id")
            .bind(text(v,"id")).bind(uid).bind(text(v,"character_id")).bind(v.to_string()).bind(v["updated_at"].as_i64().unwrap_or_else(now)).execute(&self.pool).await?;
        Ok(())
    }
    pub async fn messages(&self, uid: &str, cid: &str) -> Result<Vec<Value>> {
        let rows: Vec<String> = sqlx::query_scalar(
            "SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 ORDER BY seq,id",
        )
        .bind(uid)
        .bind(cid)
        .fetch_all(&self.pool)
        .await?;
        rows.into_iter()
            .map(|s| Ok(serde_json::from_str(&s)?))
            .collect()
    }
    pub async fn message_count(&self, uid: &str, cid: &str) -> Result<i64> {
        Ok(sqlx::query_scalar(
            "SELECT COUNT(*) FROM messages WHERE user_id=$1 AND conversation_id=$2",
        )
        .bind(uid)
        .bind(cid)
        .fetch_one(&self.pool)
        .await?)
    }
    pub async fn messages_page(
        &self,
        uid: &str,
        cid: &str,
        limit: i64,
        before: Option<i64>,
    ) -> Result<(Vec<Value>, bool)> {
        // Fetch one extra row to determine has_more without loading the full history.
        let rows: Vec<String> = if let Some(before) = before {
            sqlx::query_scalar("SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq<$3 ORDER BY seq DESC,id DESC LIMIT $4")
                .bind(uid).bind(cid).bind(before).bind(limit + 1).fetch_all(&self.pool).await?
        } else {
            sqlx::query_scalar("SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 ORDER BY seq DESC,id DESC LIMIT $3")
                .bind(uid).bind(cid).bind(limit + 1).fetch_all(&self.pool).await?
        };
        let has_more = rows.len() as i64 > limit;
        let mut messages = rows
            .into_iter()
            .take(limit as usize)
            .map(|s| serde_json::from_str(&s))
            .collect::<serde_json::Result<Vec<Value>>>()?;
        messages.reverse();
        Ok((messages, has_more))
    }
    pub async fn message(&self, uid: &str, mid: &str) -> Result<Option<Value>> {
        let s: Option<String> =
            sqlx::query_scalar("SELECT data FROM messages WHERE user_id=$1 AND id=$2")
                .bind(uid)
                .bind(mid)
                .fetch_optional(&self.pool)
                .await?;
        s.map(|s| Ok(serde_json::from_str(&s)?)).transpose()
    }
    pub async fn save_message(&self, uid: &str, v: &Value) -> Result<()> {
        let mut v = v.clone();
        crate::swipes::sync(&mut v);
        let v = &v;
        sqlx::query("INSERT INTO messages(id,user_id,conversation_id,seq,data) VALUES ($1,$2,$3,$4,$5) ON CONFLICT(id) DO UPDATE SET data=excluded.data,seq=excluded.seq WHERE messages.user_id=excluded.user_id")
            .bind(text(v,"id")).bind(uid).bind(text(v,"conversation_id")).bind(v["seq"].as_i64().unwrap_or(0)).bind(v.to_string()).execute(&self.pool).await?;
        Ok(())
    }
    pub async fn delete_conversation(&self, uid: &str, cid: &str) -> Result<()> {
        let mut tx = self.pool.begin().await?;
        sqlx::query("DELETE FROM messages WHERE user_id=$1 AND conversation_id=$2")
            .bind(uid)
            .bind(cid)
            .execute(&mut *tx)
            .await?;
        sqlx::query("DELETE FROM conversations WHERE user_id=$1 AND id=$2")
            .bind(uid)
            .bind(cid)
            .execute(&mut *tx)
            .await?;
        tx.commit().await?;
        Ok(())
    }
}
