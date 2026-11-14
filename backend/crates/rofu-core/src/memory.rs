use crate::{
    api::{ApiError, ApiResult},
    model::{flag, id, normalized, now, text},
    server::AppState,
};
use serde_json::{json, Value};
use std::collections::HashSet;

pub fn scope(memories: Vec<Value>, cid: &str, global: bool) -> Vec<Value> {
    memories
        .into_iter()
        .filter(|m| text(m, "character_id") == cid || (global && m["character_id"].is_null()))
        .collect()
}
fn terms(input: &str) -> HashSet<String> {
    let lower = input.to_lowercase();
    let mut terms = HashSet::new();
    let mut word = String::new();
    let mut cjk = String::new();
    let flush = |word: &mut String, cjk: &mut String, terms: &mut HashSet<String>| {
        if !word.is_empty() {
            terms.insert(std::mem::take(word));
        }
        let chars: Vec<char> = cjk.chars().collect();
        if chars.len() == 1 {
            terms.insert(cjk.clone());
        }
        for pair in chars.windows(2) {
            terms.insert(pair.iter().collect());
        }
        cjk.clear();
    };
    for c in lower.chars() {
        if matches!(c as u32, 0x3400..=0x9fff) {
            if !word.is_empty() {
                terms.insert(std::mem::take(&mut word));
            }
            cjk.push(c);
        } else if c.is_alphanumeric() {
            if !cjk.is_empty() {
                flush(&mut word, &mut cjk, &mut terms);
            }
            word.push(c);
        } else {
            flush(&mut word, &mut cjk, &mut terms);
        }
    }
    flush(&mut word, &mut cjk, &mut terms);
    terms
}
pub fn search(mut memories: Vec<Value>, query: &str, limit: usize) -> Vec<Value> {
    let query = terms(query);
    let score = |m: &Value| {
        let all = terms(&format!("{} {}", text(m, "content"), m["tags"]));
        query.intersection(&all).count()
    };
    if !query.is_empty() {
        memories.retain(|m| score(m) > 0);
    }
    memories.sort_by_key(|m| {
        std::cmp::Reverse((
            if query.is_empty() { 0 } else { score(m) },
            m["updated_at"].as_i64().unwrap_or(0),
        ))
    });
    memories.truncate(limit);
    memories
}
pub async fn available(s: &AppState, uid: &str, character: &Value) -> ApiResult<Vec<Value>> {
    Ok(scope(
        s.db.list(uid, "memory").await?,
        &text(character, "id"),
        flag(&character["memory"], "share_global", true),
    ))
}
pub async fn tool(
    s: &AppState,
    uid: &str,
    character: &Value,
    name: &str,
    args: &Value,
) -> ApiResult<String> {
    let memories = available(s, uid, character).await?;
    match name {
        "memory_search" => {
            let found = search(
                memories,
                &text(args, "query"),
                args["limit"].as_u64().unwrap_or(10).min(100) as usize,
            );
            Ok(found
                .iter()
                .map(|m| {
                    format!(
                        "[{}] {}{}",
                        text(m, "id"),
                        if flag(m, "pinned", false) {
                            "(pinned) "
                        } else {
                            ""
                        },
                        text(m, "content")
                    )
                })
                .collect::<Vec<_>>()
                .join("\n"))
        }
        "memory_add" => {
            if text(args, "content").trim().is_empty() {
                return Err(ApiError::bad("memory content is required"));
            }
            let mut v = normalized("memory", args);
            v["id"] = json!(&id()[..12]);
            v["created_at"] = json!(now());
            v["character_id"] = if flag(args, "global", false) {
                if !flag(&character["memory"], "share_global", true) {
                    return Err(ApiError::forbidden("global memory disabled"));
                }
                Value::Null
            } else {
                character["id"].clone()
            };
            v["source"] = json!("agent");
            Ok(s.db.save(uid, "memory", v).await?.to_string())
        }
        "memory_update" | "memory_delete" => {
            let mut m = memories
                .into_iter()
                .find(|m| m["id"] == args["id"])
                .ok_or_else(ApiError::not_found)?;
            if name == "memory_delete" {
                s.db.delete(uid, "memory", &text(&m, "id")).await?;
                return Ok("deleted".into());
            }
            for key in ["content", "pinned"] {
                if let Some(v) = args.get(key) {
                    m[key] = v.clone();
                }
            }
            Ok(s.db.save(uid, "memory", m).await?.to_string())
        }
        _ => Err(ApiError::bad("unknown memory tool")),
    }
}
pub fn definitions() -> Vec<Value> {
    vec![
        json!({"name":"memory_search","description":"Search long-term memories. Empty query returns recent memories.","parameters":{"type":"object","properties":{"query":{"type":"string"},"limit":{"type":"integer"}}}}),
        json!({"name":"memory_add","description":"Store durable information.","parameters":{"type":"object","properties":{"content":{"type":"string"},"tags":{"type":"array","items":{"type":"string"}},"pinned":{"type":"boolean"},"global":{"type":"boolean"}},"required":["content"]}}),
        json!({"name":"memory_update","description":"Update an existing memory.","parameters":{"type":"object","properties":{"id":{"type":"string"},"content":{"type":"string"},"pinned":{"type":"boolean"}},"required":["id"]}}),
        json!({"name":"memory_delete","description":"Delete an obsolete memory.","parameters":{"type":"object","properties":{"id":{"type":"string"}},"required":["id"]}}),
    ]
}
pub async fn scan(s: &AppState, uid: &str, cid: &str) -> ApiResult<Value> {
    let mut conv = crate::api::conversation(s, uid, cid).await?;
    let c = crate::api::required(s, uid, "character", &text(&conv, "character_id")).await?;
    if !flag(&c["memory"], "enabled", true) {
        return Err(ApiError::bad("memory disabled"));
    }
    let all = s.db.messages(uid, cid).await?;
    let scanned = conv["memory_scanned_seq"].as_i64().unwrap_or(0);
    let mut messages: Vec<Value> = all
        .into_iter()
        .filter(|m| {
            matches!(m["role"].as_str(), Some("user" | "assistant"))
                && m["seq"].as_i64().unwrap_or(0) > scanned
        })
        .collect();
    if messages.is_empty() {
        return Ok(json!({"added":0,"updated":0,"deleted":0}));
    }
    let max = messages
        .iter()
        .filter_map(|m| m["seq"].as_i64())
        .max()
        .unwrap_or(scanned);
    if messages.len() > 60 {
        messages.drain(..messages.len() - 60);
    }
    for m in &mut messages {
        *m = crate::swipes::active_only(m);
        m["content"] = json!(text(m, "content").chars().take(3000).collect::<String>());
        m.as_object_mut().unwrap().remove("parts");
    }
    let mut memories = available(s, uid, &c).await?;
    memories.sort_by_key(|m| std::cmp::Reverse(m["updated_at"].as_i64().unwrap_or(0)));
    memories.truncate(100);
    let result=async {
        let output=crate::chat::fast_for_conversation(s,uid,&c,cid,"Extract durable memories from the new conversation. Return only JSON: {\"add\":[{\"content\":\"...\",\"tags\":[],\"global\":false}],\"update\":[{\"id\":\"...\",\"content\":\"...\"}],\"delete\":[\"id\"]}. Do not delete pinned memories.",&json!({"messages":messages,"memories":memories}).to_string()).await?;
        let trimmed=output.trim();let trimmed=if trimmed.starts_with("```"){let start=trimmed.find('\n').map(|p|p+1).unwrap_or(3);trimmed[start..].trim_end().strip_suffix("```").unwrap_or(&trimmed[start..]).trim()}else{trimmed};
        let delta:Value=serde_json::from_str(trimmed)?;if !delta.is_object(){anyhow::bail!("memory scan must return a JSON object");}
        let mut added=0;let mut updated=0;let mut deleted=0;
        // Validate the complete delta before opening a transaction.
        let mut changes=vec![];
        if let Some(add)=delta["add"].as_array(){for a in add{if text(a,"content").trim().is_empty(){continue;}
if flag(a,"global",false)&&!flag(&c["memory"],"share_global",true){continue;}let mut m=normalized("memory",a);m["id"]=json!(&id()[..12]);m["created_at"]=json!(now());m["updated_at"]=json!(now());m["source"]=json!("scan");m["character_id"]=if flag(a,"global",false){Value::Null}else{c["id"].clone()};m["pinned"]=json!(false);changes.push(m);added+=1;}}
        if let Some(update)=delta["update"].as_array(){for u in update{if let Some(old)=memories.iter().find(|m|m["id"]==u["id"]){let mut m=old.clone();if u["content"].is_string(){m["content"]=u["content"].clone();m["updated_at"]=json!(now());changes.push(m);updated+=1;}}}}
        let deletes:Vec<String>=delta["delete"].as_array().map(|a|a.iter().filter_map(|v|memories.iter().find(|m|m["id"]==*v&&!flag(m,"pinned",false)).map(|m|text(m,"id"))).collect()).unwrap_or_default();
        let mut tx=s.db.pool.begin().await?;
        for m in changes{sqlx::query("INSERT INTO entities(id,user_id,kind,parent_id,data,created_at,updated_at) VALUES ($1,$2,'memory',$3,$4,$5,$6) ON CONFLICT(id) DO UPDATE SET data=excluded.data,updated_at=excluded.updated_at WHERE entities.user_id=excluded.user_id")
            .bind(text(&m,"id")).bind(uid).bind(text(&m,"character_id")).bind(m.to_string()).bind(m["created_at"].as_i64().unwrap_or_else(now)).bind(now()).execute(&mut *tx).await?;}
        for mid in deletes{sqlx::query("DELETE FROM entities WHERE user_id=$1 AND kind='memory' AND id=$2").bind(uid).bind(mid).execute(&mut *tx).await?;deleted+=1;}
        conv["memory_scanned_seq"]=json!(max);sqlx::query("UPDATE conversations SET data=$1 WHERE user_id=$2 AND id=$3").bind(conv.to_string()).bind(uid).bind(cid).execute(&mut *tx).await?;tx.commit().await?;
        Ok::<_,anyhow::Error>(json!({"added":added,"updated":updated,"deleted":deleted}))
    }.await;
    match result {
        Ok(v) => Ok(v),
        Err(e) => {
            tracing::warn!(conversation=cid,error=%e,"memory scan failed; advance cursor to avoid repeated charges");
            conv["memory_scanned_seq"] = json!(max);
            s.db.save_conversation(uid, &conv).await?;
            Err(e.into())
        }
    }
}
pub fn spawn_scanner(s: AppState) {
    s.tasks.clone().spawn(async move {
        let mut timer = tokio::time::interval(std::time::Duration::from_secs(120));
        timer.tick().await;
        loop {
            tokio::select! {_ = s.shutdown.cancelled()=>break,_ = timer.tick()=>{}}
            let users = sqlx::query_scalar::<_, String>("SELECT id FROM users")
                .fetch_all(&s.db.pool)
                .await
                .unwrap_or_default();
            for uid in users {
                let settings = match crate::api::settings(&s, &uid).await {
                    Ok(v) => v,
                    Err(_) => continue,
                };
                let idle = settings["memory_idle_minutes"]
                    .as_i64()
                    .unwrap_or(10)
                    .max(0)
                    * 60_000;
                for conv in s.db.conversations(&uid).await.unwrap_or_default() {
                    if s.shutdown.is_cancelled() {
                        return;
                    }
                    if conv["updated_at"].as_i64().unwrap_or(0) > now().saturating_sub(idle) {
                        continue;
                    }
                    let cid = text(&conv, "id");
                    let c = match s
                        .db
                        .get(&uid, "character", &text(&conv, "character_id"))
                        .await
                    {
                        Ok(Some(c)) => c,
                        _ => continue,
                    };
                    if !flag(&c["memory"], "enabled", true)
                        || !flag(&c["memory"], "auto_scan", true)
                    {
                        continue;
                    }
                    {
                        let mut lock = s.generating.lock().await;
                        if lock.contains_key(&cid) {
                            continue;
                        }
                        lock.insert(cid.clone(), tokio_util::sync::CancellationToken::new());
                    }
                    let _ = scan(&s, &uid, &cid).await;
                    s.generating.lock().await.remove(&cid);
                }
            }
        }
    });
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn english_chinese_search() {
        let all = vec![
            json!({"content":"Alice loves tea","tags":[],"updated_at":1}),
            json!({"content":"露芙喜欢森林与红茶","tags":[],"updated_at":2}),
        ];
        assert_eq!(search(all.clone(), "tea", 10).len(), 1);
        assert_eq!(search(all.clone(), "森林", 10)[0]["updated_at"], 2);
        assert_eq!(search(all, "", 1)[0]["updated_at"], 2);
    }
}
