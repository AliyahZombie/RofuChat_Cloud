//! Persist full swipe snapshots, but expose only the active version over HTTP/SSE.
use crate::{
    api::{ApiError, ApiResult},
    model::{number, text},
    server::AppState,
};
use serde_json::{json, Value};
use sqlx::{Any, Transaction};

const FIELDS: &[&str] = &[
    "content",
    "parts",
    "actual",
    "actual_status",
    "actual_error",
    "usage",
    "model",
    "model_name",
    "model_icon",
    "created_at",
];

pub fn count(m: &Value) -> usize {
    m["swipes"]
        .as_array()
        .expect("stored message must have swipes")
        .len()
}
pub fn index(m: &Value) -> usize {
    m["swipe_index"]
        .as_u64()
        .expect("stored message must have swipe_index") as usize
}
pub fn snapshot(m: &Value) -> Value {
    let mut swipe = json!({});
    for key in FIELDS {
        swipe[key] = m[key].clone();
    }
    if m["role"] == "user" {
        swipe["tail"] = json!([]);
    }
    swipe
}
/// Initialize new messages only; stored messages always carry snapshots.
pub fn initialize(m: &mut Value) {
    m["swipes"] = json!([snapshot(m)]);
    m["swipe_index"] = json!(0);
}
/// Update the active snapshot while preserving its archived user branch.
pub fn sync(m: &mut Value) {
    let i = index(m);
    let mut swipe = snapshot(m);
    if m["role"] == "user" {
        swipe["tail"] = m["swipes"][i]["tail"]
            .as_array()
            .cloned()
            .map(Value::Array)
            .unwrap_or_else(|| json!([]));
    }
    let mut preserved = m["swipes"][i].clone();
    crate::model::merge(&mut preserved, &swipe);
    m["swipes"][i] = preserved;
    m["swipe_index"] = json!(i);
}

pub fn activate(m: &mut Value, i: usize) {
    let swipe = m["swipes"][i].clone();
    for key in FIELDS {
        m[key] = swipe[key].clone();
    }
    m["swipe_index"] = json!(i);
}
pub fn append(m: &mut Value, fresh: &Value) {
    sync(m);
    let swipes = m["swipes"].as_array_mut().unwrap();
    swipes.push(snapshot(fresh));
    let i = swipes.len() - 1;
    activate(m, i);
}
pub fn active_only(m: &Value) -> Value {
    Value::Object(
        m.as_object()
            .unwrap()
            .iter()
            .filter(|(key, _)| {
                !matches!(
                    key.as_str(),
                    "swipes" | "tail" | "swipe_index" | "swipe_count"
                )
            })
            .map(|(key, value)| (key.clone(), value.clone()))
            .collect(),
    )
}
pub fn public(m: &Value) -> Value {
    let mut v = active_only(m);
    v["swipe_index"] = json!(index(m));
    v["swipe_count"] = json!(count(m));
    v
}
pub async fn store(tx: &mut Transaction<'_, Any>, uid: &str, m: &Value) -> anyhow::Result<()> {
    let mut m = m.clone();
    sync(&mut m);
    sqlx::query("INSERT INTO messages(id,user_id,conversation_id,seq,data) VALUES ($1,$2,$3,$4,$5) ON CONFLICT(id) DO UPDATE SET data=excluded.data,seq=excluded.seq WHERE messages.user_id=excluded.user_id")
        .bind(text(&m,"id")).bind(uid).bind(text(&m,"conversation_id")).bind(number(&m,"seq",0)).bind(m.to_string()).execute(&mut **tx).await?;
    Ok(())
}
/// Move all following rows into the active user swipe, retaining complete nested branches.
pub async fn archive_tail(
    tx: &mut Transaction<'_, Any>,
    uid: &str,
    m: &mut Value,
) -> anyhow::Result<()> {
    sync(m);
    let cid = text(m, "conversation_id");
    let seq = number(m, "seq", 0);
    let rows: Vec<String> = sqlx::query_scalar("SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq>$3 ORDER BY seq,id")
        .bind(uid).bind(&cid).bind(seq).fetch_all(&mut **tx).await?;
    let tail = rows
        .iter()
        .map(|s| serde_json::from_str::<Value>(s))
        .collect::<serde_json::Result<Vec<_>>>()?;
    let i = index(m);
    m["swipes"][i]["tail"] = json!(tail);
    sqlx::query("DELETE FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq>$3")
        .bind(uid)
        .bind(cid)
        .bind(seq)
        .execute(&mut **tx)
        .await?;
    Ok(())
}
async fn restore_tail(
    tx: &mut Transaction<'_, Any>,
    uid: &str,
    m: &mut Value,
) -> anyhow::Result<Vec<Value>> {
    let i = index(m);
    let tail = m["swipes"][i]["tail"]
        .as_array()
        .cloned()
        .unwrap_or_default();
    for row in &tail {
        // INSERT rather than upsert: a collision must roll back the complete switch.
        sqlx::query(
            "INSERT INTO messages(id,user_id,conversation_id,seq,data) VALUES ($1,$2,$3,$4,$5)",
        )
        .bind(text(row, "id"))
        .bind(uid)
        .bind(text(row, "conversation_id"))
        .bind(number(row, "seq", 0))
        .bind(row.to_string())
        .execute(&mut **tx)
        .await?;
    }
    m["swipes"][i]["tail"] = json!([]);
    Ok(tail)
}
/// Serialize against generation and other mutations, then read and mutate in one transaction.
pub async fn change(
    s: &AppState,
    uid: &str,
    mid: &str,
    cid: &str,
    requested: usize,
    delete: bool,
) -> ApiResult<Value> {
    let running = s.generating.lock().await;
    if running.contains_key(cid) {
        return Err(ApiError::conflict("conversation is generating"));
    }
    let mut tx = s.db.pool.begin().await?;
    let raw: String = sqlx::query_scalar("SELECT data FROM messages WHERE user_id=$1 AND id=$2")
        .bind(uid)
        .bind(mid)
        .fetch_optional(&mut *tx)
        .await?
        .ok_or_else(ApiError::not_found)?;
    let mut m: Value = serde_json::from_str(&raw).map_err(anyhow::Error::from)?;
    if !matches!(m["role"].as_str(), Some("user" | "assistant")) {
        return Err(ApiError::bad(
            "only user and assistant messages have swipes",
        ));
    }
    if requested >= count(&m) {
        return Err(ApiError::bad("swipe index out of range"));
    }
    if delete && count(&m) == 1 {
        return Err(ApiError::bad("cannot delete the only swipe"));
    }
    sync(&mut m);
    let current = index(&m);
    let switching = requested != current && !delete || delete && requested == current;
    if switching && m["role"] == "user" {
        archive_tail(&mut tx, uid, &mut m).await?;
    }
    if delete {
        m["swipes"].as_array_mut().unwrap().remove(requested);
        let next = if requested < current {
            current - 1
        } else {
            current.min(count(&m) - 1)
        };
        activate(&mut m, next);
    } else {
        activate(&mut m, requested);
    }
    let tail = if switching && m["role"] == "user" {
        restore_tail(&mut tx, uid, &mut m).await?
    } else if m["role"] == "user" {
        // A no-op selection or inactive deletion still returns the active branch.
        let rows: Vec<String> = sqlx::query_scalar("SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq>$3 ORDER BY seq,id")
            .bind(uid).bind(cid).bind(number(&m,"seq",0)).fetch_all(&mut *tx).await?;
        rows.iter()
            .map(|s| serde_json::from_str(s))
            .collect::<serde_json::Result<Vec<Value>>>()
            .map_err(anyhow::Error::from)?
    } else {
        vec![]
    };
    store(&mut tx, uid, &m).await?;
    tx.commit().await?;
    let mut messages = vec![public(&m)];
    messages.extend(tail.iter().map(public));
    Ok(json!({"messages":messages}))
}

/// Retain reasoning/tools and replace only the first text segment in place.
pub fn edit_text(m: &mut Value) {
    let replacement = json!({"type":"text","text":m["content"]});
    let segments = m["parts"]["segments"]
        .as_array()
        .cloned()
        .unwrap_or_default();
    let mut found = false;
    let mut edited = vec![];
    for segment in segments {
        if segment["type"] == "text" {
            if !found {
                edited.push(replacement.clone());
                found = true;
            }
        } else {
            edited.push(segment);
        }
    }
    if !found {
        edited.push(replacement);
    }
    m["parts"]["segments"] = json!(edited);
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn edit_without_text_retains_other_segments_and_appends_text() {
        let reasoning = json!({"type":"reasoning","text":"thought","duration_ms":12});
        let tool = json!({"type":"tool","id":"call","result":"result"});
        let mut m = json!({"content":"new text","parts":{"segments":[reasoning,tool],"images":[],"error":null}});
        edit_text(&mut m);
        assert_eq!(
            m["parts"]["segments"],
            json!([reasoning,tool,{"type":"text","text":"new text"}])
        );
        assert_eq!(m["parts"]["images"], json!([]));
        assert!(m["parts"]["error"].is_null());
    }
    #[test]
    fn snapshots_restore_all_mutable_fields_and_keep_identity_and_visibility() {
        let mut m = crate::chat::message("conversation", 2000, "user", "original");
        let original = snapshot(&m);
        let message_id = m["id"].clone();
        let mut fresh = crate::chat::message("other", 9999, "user", "edited");
        fresh["parts"]["images"] = json!(["image"]);
        fresh["actual"] = json!("actual");
        fresh["actual_status"] = json!("ok");
        fresh["actual_error"] = json!("error");
        fresh["usage"]["input"] = json!(123);
        fresh["model"] = json!("new model");
        fresh["model_name"] = json!("New name");
        fresh["model_icon"] = json!("new icon");
        fresh["created_at"] = json!(42);
        append(&mut m, &fresh);
        for key in FIELDS {
            assert_eq!(m[key], fresh[key]);
        }
        assert_eq!(m["id"], message_id);
        assert_eq!(m["conversation_id"], "conversation");
        assert_eq!(m["seq"], 2000);
        m["visible"] = json!(false);
        m["swipes"][1]["tail"] = json!([{"id":"archived"}]);
        m["content"] = json!("saved only");
        sync(&mut m);
        assert_eq!(m["swipes"][1]["content"], "saved only");
        assert_eq!(m["swipes"][1]["tail"], json!([{"id":"archived"}]));
        activate(&mut m, 0);
        for key in FIELDS {
            assert_eq!(m[key], original[key]);
        }
        assert_eq!(m["visible"], false);
        let wire = public(&m);
        assert_eq!(wire["swipe_index"], 0);
        assert_eq!(wire["swipe_count"], 2);
        assert!(wire.get("swipes").is_none());
        let copy = active_only(&m);
        for key in ["swipes", "tail", "swipe_index", "swipe_count"] {
            assert!(copy.get(key).is_none());
        }
    }
}
