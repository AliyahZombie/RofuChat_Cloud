//! Portable plugin KV accounting; lock the accounting row before reading or writing entries.
use crate::{db::Db, model::now};
use anyhow::{ensure, Result};
use serde_json::{json, Value};
use sqlx::{Any, Row, Transaction};

pub const MAX_BYTES: i64 = 10 * 1024 * 1024;
pub const MAX_VALUE_BYTES: usize = 64 * 1024;
pub const MAX_ENTRIES: usize = 10_000;
pub const MAX_TABLES: usize = 16;

#[derive(Clone, Debug)]
pub struct Change {
    pub table: String,
    pub key: String,
    pub value: Option<Value>,
}

pub fn validate(table: &str, key: &str, value: Option<&Value>) -> Result<()> {
    ensure!(
        !table.is_empty()
            && table.len() <= 128
            && table
                .bytes()
                .all(|b| b.is_ascii_alphanumeric() || matches!(b, b'_' | b'-' | b'.')),
        "E_VALIDATION: invalid table name"
    );
    ensure!(
        !key.is_empty() && key.len() <= 256,
        "E_VALIDATION: key must be 1..256 UTF-8 bytes"
    );
    ensure!(
        value.is_none_or(|v| v.to_string().len() <= MAX_VALUE_BYTES),
        "E_LIMIT: KV value exceeds 64 KiB"
    );
    Ok(())
}
pub async fn apply(
    tx: &mut Transaction<'_, Any>,
    uid: &str,
    pid: &str,
    changes: &[Change],
) -> Result<()> {
    sqlx::query("INSERT INTO plugin_storage(user_id,plugin_id,used_bytes,entry_count) VALUES ($1,$2,0,0) ON CONFLICT(user_id,plugin_id) DO NOTHING").bind(uid).bind(pid).execute(&mut **tx).await?;
    // This write serializes concurrent writers on PostgreSQL and SQLite.
    sqlx::query(
        "UPDATE plugin_storage SET used_bytes=used_bytes WHERE user_id=$1 AND plugin_id=$2",
    )
    .bind(uid)
    .bind(pid)
    .execute(&mut **tx)
    .await?;
    for c in changes {
        validate(&c.table, &c.key, c.value.as_ref())?;
        if let Some(v) = &c.value {
            let encoded = v.to_string();
            let bytes = (c.table.len() + c.key.len() + encoded.len()) as i64;
            sqlx::query("INSERT INTO plugin_kv(user_id,plugin_id,table_name,key,value,bytes,updated_at) VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT(user_id,plugin_id,table_name,key) DO UPDATE SET value=excluded.value,bytes=excluded.bytes,updated_at=excluded.updated_at")
                .bind(uid).bind(pid).bind(&c.table).bind(&c.key).bind(encoded).bind(bytes).bind(now()).execute(&mut **tx).await?;
        } else {
            sqlx::query("DELETE FROM plugin_kv WHERE user_id=$1 AND plugin_id=$2 AND table_name=$3 AND key=$4").bind(uid).bind(pid).bind(&c.table).bind(&c.key).execute(&mut **tx).await?;
        }
    }
    let row=sqlx::query("SELECT CAST(COALESCE(SUM(bytes),0) AS BIGINT) AS used,COUNT(*) AS entries,COUNT(DISTINCT table_name) AS tables FROM plugin_kv WHERE user_id=$1 AND plugin_id=$2").bind(uid).bind(pid).fetch_one(&mut **tx).await?;
    let used: i64 = row.try_get("used")?;
    let entries: i64 = row.try_get("entries")?;
    let tables: i64 = row.try_get("tables")?;
    ensure!(
        used <= MAX_BYTES && entries <= MAX_ENTRIES as i64 && tables <= MAX_TABLES as i64,
        "E_LIMIT: plugin storage quota exceeded"
    );
    sqlx::query(
        "UPDATE plugin_storage SET used_bytes=$3,entry_count=$4 WHERE user_id=$1 AND plugin_id=$2",
    )
    .bind(uid)
    .bind(pid)
    .bind(used)
    .bind(entries)
    .execute(&mut **tx)
    .await?;
    Ok(())
}
pub async fn entries(db: &Db, uid: &str, pid: &str, table: &str) -> Result<Vec<(String, Value)>> {
    let rows=sqlx::query("SELECT key,value FROM plugin_kv WHERE user_id=$1 AND plugin_id=$2 AND table_name=$3 ORDER BY key").bind(uid).bind(pid).bind(table).fetch_all(&db.pool).await?;
    rows.into_iter()
        .map(|r| {
            Ok((
                r.try_get("key")?,
                serde_json::from_str(r.try_get("value")?)?,
            ))
        })
        .collect()
}
pub async fn usage(db: &Db, uid: &str, pid: &str) -> Result<Value> {
    let rows=sqlx::query("SELECT table_name,CAST(COALESCE(SUM(bytes),0) AS BIGINT) AS used,COUNT(*) AS entries FROM plugin_kv WHERE user_id=$1 AND plugin_id=$2 GROUP BY table_name ORDER BY table_name").bind(uid).bind(pid).fetch_all(&db.pool).await?;
    let mut used = 0i64;
    let mut count = 0i64;
    let mut tables = vec![];
    for row in rows {
        let bytes: i64 = row.try_get("used")?;
        let entries: i64 = row.try_get("entries")?;
        used += bytes;
        count += entries;
        tables.push(json!({"name":row.try_get::<String,_>("table_name")?,"used_bytes":bytes,"entry_count":entries}));
    }
    Ok(
        json!({"plugin_id":pid,"used_bytes":used,"entry_count":count,"quota_bytes":MAX_BYTES,"tables":tables}),
    )
}
pub async fn clear(db: &Db, uid: &str, pid: &str, table: Option<&str>) -> Result<()> {
    let mut tx = db.pool.begin().await?;
    let exists = sqlx::query(
        "UPDATE entities SET updated_at=updated_at WHERE user_id=$1 AND kind='plugin' AND id=$2",
    )
    .bind(uid)
    .bind(pid)
    .execute(&mut *tx)
    .await?
    .rows_affected();
    ensure!(exists == 1, "E_NOT_FOUND: plugin");
    apply(&mut tx, uid, pid, &[]).await?;
    if let Some(table) = table {
        sqlx::query("DELETE FROM plugin_kv WHERE user_id=$1 AND plugin_id=$2 AND table_name=$3")
            .bind(uid)
            .bind(pid)
            .bind(table)
            .execute(&mut *tx)
            .await?;
    } else {
        sqlx::query("DELETE FROM plugin_kv WHERE user_id=$1 AND plugin_id=$2")
            .bind(uid)
            .bind(pid)
            .execute(&mut *tx)
            .await?;
    }
    apply(&mut tx, uid, pid, &[]).await?;
    tx.commit().await?;
    Ok(())
}

/// Read-only preflight for beforeSend: even accounting writes wait until hooks finish.
pub async fn check(db: &Db, uid: &str, pid: &str, changes: &[Change]) -> Result<()> {
    let rows =
        sqlx::query("SELECT table_name,key,value FROM plugin_kv WHERE user_id=$1 AND plugin_id=$2")
            .bind(uid)
            .bind(pid)
            .fetch_all(&db.pool)
            .await?;
    let mut values = std::collections::BTreeMap::new();
    for row in rows {
        values.insert(
            (
                row.try_get::<String, _>("table_name")?,
                row.try_get::<String, _>("key")?,
            ),
            row.try_get::<String, _>("value")?,
        );
    }
    for change in changes {
        validate(&change.table, &change.key, change.value.as_ref())?;
        let key = (change.table.clone(), change.key.clone());
        if let Some(value) = &change.value {
            values.insert(key, value.to_string());
        } else {
            values.remove(&key);
        }
    }
    let used = values
        .iter()
        .map(|((table, key), value)| table.len() + key.len() + value.len())
        .sum::<usize>();
    let tables = values
        .keys()
        .map(|(table, _)| table)
        .collect::<std::collections::HashSet<_>>()
        .len();
    ensure!(
        used <= MAX_BYTES as usize && values.len() <= MAX_ENTRIES && tables <= MAX_TABLES,
        "E_LIMIT: plugin storage quota exceeded"
    );
    Ok(())
}
