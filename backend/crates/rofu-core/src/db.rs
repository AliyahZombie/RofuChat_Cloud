use crate::model::{id, normalize_context, now, text};
use anyhow::{bail, Result};
use futures_util::TryStreamExt;
use serde_json::{json, Value};
use sqlx::{any::AnyPoolOptions, AnyPool, Row};

/// Active content already contains text segments; count only additional segment text.
pub fn message_chars(message: &Value) -> u64 {
    let mut chars = text(message, "content").chars().count() as u64;
    if let Some(segments) = message["parts"]["segments"].as_array() {
        for segment in segments {
            let fields: &[&str] = match segment["type"].as_str() {
                Some("reasoning") => &["text"],
                Some("tool") => &["arguments", "result"],
                _ => &[],
            };
            for field in fields {
                chars += text(segment, field).chars().count() as u64;
            }
        }
    }
    chars
}

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
        // BYTEA accepts binary bindings on both SQLite and PostgreSQL.
        sqlx::query("CREATE TABLE IF NOT EXISTS attachments (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, mime TEXT NOT NULL, data BYTEA NOT NULL, metadata TEXT NOT NULL)").execute(&mut *tx).await?;
        tx.commit().await?;
        let images_migrated: i64 =
            sqlx::query_scalar("SELECT COUNT(*) FROM schema_version WHERE version=2")
                .fetch_one(&self.pool)
                .await?;
        if images_migrated == 0 {
            // Idempotent migration, including inactive swipes and archived branches. Mark
            // complete only after every row is persisted; interruption safely retries.
            for table in ["messages", "entities"] {
                let filter = if table == "entities" {
                    " AND kind='character'"
                } else {
                    ""
                };
                let mut cursor = String::new();
                // Keep one row in memory, even when upgrading large image histories.
                while let Some(row) = sqlx::query(&format!(
                    "SELECT id,user_id,data FROM {table} WHERE id>$1{filter} ORDER BY id LIMIT 1"
                ))
                .bind(&cursor)
                .fetch_optional(&self.pool)
                .await?
                {
                    cursor = row.try_get("id")?;
                    let uid: String = row.try_get("user_id")?;
                    let original: String = row.try_get("data")?;
                    let mut value: Value = serde_json::from_str(&original)?;
                    self.externalize_images(&uid, &mut value).await?;
                    let serialized = value.to_string();
                    if serialized != original {
                        sqlx::query(&format!(
                            "UPDATE {table} SET data=$1 WHERE id=$2 AND user_id=$3"
                        ))
                        .bind(serialized)
                        .bind(row.try_get::<String, _>("id")?)
                        .bind(&uid)
                        .execute(&self.pool)
                        .await?;
                    }
                }
            }
            sqlx::query(
                "INSERT INTO schema_version(version) VALUES (2) ON CONFLICT(version) DO NOTHING",
            )
            .execute(&self.pool)
            .await?;
        }
        if version.unwrap_or(0) < 3 {
            let mut tx = self.pool.begin().await?;
            for q in [
                "CREATE TABLE IF NOT EXISTS plugin_storage (user_id TEXT NOT NULL, plugin_id TEXT NOT NULL, used_bytes BIGINT NOT NULL, entry_count BIGINT NOT NULL, PRIMARY KEY(user_id,plugin_id))",
                "CREATE TABLE IF NOT EXISTS plugin_kv (user_id TEXT NOT NULL, plugin_id TEXT NOT NULL, table_name TEXT NOT NULL, key TEXT NOT NULL, value TEXT NOT NULL, bytes BIGINT NOT NULL, updated_at BIGINT NOT NULL, PRIMARY KEY(user_id,plugin_id,table_name,key))",
            ] { sqlx::query(q).execute(&mut *tx).await?; }
            let rows = sqlx::query("SELECT id,user_id,data FROM entities WHERE kind='tool'")
                .fetch_all(&mut *tx)
                .await?;
            for row in rows {
                let value: Value = serde_json::from_str(row.try_get("data")?)?;
                let plugin = crate::plugins::legacy_plugin(value);
                sqlx::query("UPDATE entities SET kind='plugin',data=$1 WHERE id=$2")
                    .bind(plugin.to_string())
                    .bind(row.try_get::<String, _>("id")?)
                    .execute(&mut *tx)
                    .await?;
                sqlx::query("INSERT INTO plugin_storage(user_id,plugin_id,used_bytes,entry_count) VALUES ($1,$2,0,0) ON CONFLICT(user_id,plugin_id) DO NOTHING").bind(row.try_get::<String,_>("user_id")?).bind(row.try_get::<String,_>("id")?).execute(&mut *tx).await?;
            }
            sqlx::query(
                "INSERT INTO schema_version(version) VALUES (3) ON CONFLICT(version) DO NOTHING",
            )
            .execute(&mut *tx)
            .await?;
            tx.commit().await?;
        }
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
        .bind(if kind == "tool" { "plugin" } else { kind })
        .fetch_all(&self.pool)
        .await?;
        rows.into_iter()
            .map(|r| {
                let mut data = serde_json::from_str(r.try_get::<&str, _>("data")?)?;
                if kind == "character" {
                    normalize_context(&mut data);
                }
                Ok(data)
            })
            .collect::<Result<Vec<Value>>>()
            .map(|values| {
                values
                    .into_iter()
                    .filter(|v| kind != "tool" || v["format"] == "legacy-main")
                    .map(|v| {
                        if kind == "tool" {
                            crate::plugins::legacy_tool(v)
                        } else {
                            v
                        }
                    })
                    .collect()
            })
    }
    pub async fn tool_summaries(&self, uid: &str) -> Result<Vec<Value>> {
        let mut rows = sqlx::query(
            "SELECT data FROM entities WHERE user_id=$1 AND kind='plugin' ORDER BY created_at,id",
        )
        .bind(uid)
        .fetch(&self.pool);
        let mut summaries = Vec::new();
        // The portable TEXT store requires reading JSON, but retain only one row's
        // code at a time and count it without cloning the potentially large string.
        while let Some(row) = rows.try_next().await? {
            let mut data: Value = serde_json::from_str(row.try_get("data")?)?;
            if data["format"] != "legacy-main" {
                continue;
            }
            data = crate::plugins::legacy_tool(data);
            let code = data.as_object_mut().unwrap().remove("code");
            let code_chars = code
                .as_ref()
                .and_then(Value::as_str)
                .unwrap_or_default()
                .chars()
                .count();
            data["code_chars"] = json!(code_chars);
            summaries.push(data);
        }
        Ok(summaries)
    }
    pub async fn get(&self, uid: &str, kind: &str, eid: &str) -> Result<Option<Value>> {
        let row = sqlx::query("SELECT data FROM entities WHERE user_id=$1 AND kind=$2 AND id=$3")
            .bind(uid)
            .bind(if kind == "tool" { "plugin" } else { kind })
            .bind(eid)
            .fetch_optional(&self.pool)
            .await?;
        row.map(|r| {
            let mut data = serde_json::from_str(r.try_get::<&str, _>("data")?)?;
            if kind == "character" {
                normalize_context(&mut data);
            }
            Ok(data)
        })
        .transpose()
        .map(|value: Option<Value>| {
            value
                .filter(|v| kind != "tool" || v["format"] == "legacy-main")
                .map(|v| {
                    if kind == "tool" {
                        crate::plugins::legacy_tool(v)
                    } else {
                        v
                    }
                })
        })
    }
    pub async fn save(&self, uid: &str, kind: &str, mut data: Value) -> Result<Value> {
        if kind == "tool" {
            data = crate::plugins::legacy_plugin(data);
        }
        if kind == "character" {
            normalize_context(&mut data);
            self.externalize_images(uid, &mut data).await?;
        }
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
            .bind(text(&data,"id")).bind(uid).bind(if kind=="tool" {"plugin"} else {kind}).bind(parent).bind(data.to_string()).bind(data["created_at"].as_i64().unwrap_or_else(now)).bind(now()).execute(&self.pool).await?;
        if kind == "tool" || kind == "plugin" {
            sqlx::query("INSERT INTO plugin_storage(user_id,plugin_id,used_bytes,entry_count) VALUES ($1,$2,0,0) ON CONFLICT(user_id,plugin_id) DO NOTHING").bind(uid).bind(text(&data,"id")).execute(&self.pool).await?;
        }
        Ok(if kind == "tool" {
            crate::plugins::legacy_tool(data)
        } else {
            data
        })
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
        if kind == "tool" || kind == "plugin" {
            sqlx::query("UPDATE entities SET updated_at=updated_at WHERE user_id=$1 AND kind='plugin' AND id=$2").bind(uid).bind(eid).execute(&mut *tx).await?;
            for table in ["plugin_kv", "plugin_storage"] {
                sqlx::query(&format!(
                    "DELETE FROM {table} WHERE user_id=$1 AND plugin_id=$2"
                ))
                .bind(uid)
                .bind(eid)
                .execute(&mut *tx)
                .await?;
            }
        }
        sqlx::query("DELETE FROM entities WHERE user_id=$1 AND kind=$2 AND id=$3")
            .bind(uid)
            .bind(if kind == "tool" { "plugin" } else { kind })
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
        limit: Option<i64>,
        before: Option<i64>,
        max_chars: Option<u64>,
    ) -> Result<(Vec<Value>, bool, u64)> {
        // Stream newest first, keeping only this page and one lookahead row.
        let fetch_limit = limit.map_or(i64::MAX, |n| n + 1);
        let query = if let Some(before) = before {
            sqlx::query_scalar("SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq<$3 ORDER BY seq DESC,id DESC LIMIT $4")
                .bind(uid).bind(cid).bind(before).bind(fetch_limit)
        } else {
            sqlx::query_scalar("SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 ORDER BY seq DESC,id DESC LIMIT $3")
                .bind(uid).bind(cid).bind(fetch_limit)
        };
        let mut rows = query.fetch(&self.pool);
        let mut messages = Vec::new();
        let mut chars = 0u64;
        let (mut has_user, mut has_assistant) = (false, false);
        let mut has_more = false;
        while let Some(row) = rows.try_next().await? {
            let row: String = row;
            let message: Value = serde_json::from_str(&row)?;
            let next_chars = message_chars(&message);
            if limit.is_some_and(|n| messages.len() as i64 >= n)
                || (has_user
                    && has_assistant
                    && max_chars.is_some_and(|n| chars.saturating_add(next_chars) > n))
            {
                has_more = true;
                break;
            }
            has_user |= message["role"] == "user";
            has_assistant |= message["role"] == "assistant";
            chars += next_chars;
            messages.push(message);
        }
        messages.reverse();
        Ok((messages, has_more, chars))
    }
    /// Fetch the nearest floor(K/2) rows below the insertion point and the
    /// remaining rows at/above it, using the existing conversation/seq index.
    pub async fn messages_around(
        &self,
        uid: &str,
        cid: &str,
        seq: i64,
        limit: i64,
    ) -> Result<(Vec<Value>, bool, bool)> {
        let (mut messages, _, _) = self
            .messages_page(uid, cid, Some(limit / 2), Some(seq), None)
            .await?;
        let rows: Vec<String> = sqlx::query_scalar(
            "SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq>=$3 ORDER BY seq,id LIMIT $4"
        ).bind(uid).bind(cid).bind(seq).bind(limit - limit / 2).fetch_all(&self.pool).await?;
        for row in rows {
            messages.push(serde_json::from_str(&row)?);
        }
        let (before, after) = self.message_edges(uid, cid, &messages, seq).await?;
        Ok((messages, before, after))
    }
    pub async fn messages_after(
        &self,
        uid: &str,
        cid: &str,
        seq: i64,
        limit: Option<i64>,
        max_chars: Option<u64>,
    ) -> Result<(Vec<Value>, bool, bool)> {
        let mut rows = sqlx::query_scalar::<_, String>(
            "SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq>$3 ORDER BY seq,id LIMIT $4"
        ).bind(uid).bind(cid).bind(seq).bind(limit.map_or(i64::MAX, |n| n + 1)).fetch(&self.pool);
        let mut messages = Vec::new();
        let (mut chars, mut has_user, mut has_assistant) = (0u64, false, false);
        while let Some(row) = rows.try_next().await? {
            let message: Value = serde_json::from_str(&row)?;
            let next_chars = message_chars(&message);
            if limit.is_some_and(|n| messages.len() as i64 >= n)
                || (has_user
                    && has_assistant
                    && max_chars.is_some_and(|n| chars.saturating_add(next_chars) > n))
            {
                break;
            }
            has_user |= message["role"] == "user";
            has_assistant |= message["role"] == "assistant";
            chars += next_chars;
            messages.push(message);
        }
        // Release the streaming connection before the edge query (SQLite in-memory
        // pools have just one connection).
        drop(rows);
        let (before, after) = self.message_edges(uid, cid, &messages, seq).await?;
        Ok((messages, before, after))
    }
    async fn message_edges(
        &self,
        uid: &str,
        cid: &str,
        messages: &[Value],
        pivot: i64,
    ) -> Result<(bool, bool)> {
        let first = messages
            .first()
            .and_then(|m| m["seq"].as_i64())
            .unwrap_or(pivot);
        let last = messages
            .last()
            .and_then(|m| m["seq"].as_i64())
            .unwrap_or(pivot);
        let before_sql = if messages.is_empty() {
            "SELECT COUNT(*) FROM (SELECT 1 FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq<=$3 LIMIT 1) AS edge"
        } else {
            "SELECT COUNT(*) FROM (SELECT 1 FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq<$3 LIMIT 1) AS edge"
        };
        let before: i64 = sqlx::query_scalar(before_sql)
            .bind(uid)
            .bind(cid)
            .bind(first)
            .fetch_one(&self.pool)
            .await?;
        let after: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM (SELECT 1 FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq>$3 LIMIT 1) AS edge"
        ).bind(uid).bind(cid).bind(last).fetch_one(&self.pool).await?;
        Ok((before > 0, after > 0))
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
        self.externalize_images(uid, &mut v).await?;
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
