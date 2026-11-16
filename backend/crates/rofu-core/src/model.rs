use serde_json::{json, Value};
use std::time::{SystemTime, UNIX_EPOCH};

pub fn now() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis() as i64
}
pub fn id() -> String {
    uuid::Uuid::new_v4().simple().to_string()
}
pub fn text(v: &Value, k: &str) -> String {
    v[k].as_str().unwrap_or_default().to_owned()
}
pub fn flag(v: &Value, k: &str, default: bool) -> bool {
    v[k].as_bool().unwrap_or(default)
}
pub fn number(v: &Value, k: &str, default: i64) -> i64 {
    v[k].as_i64().unwrap_or(default)
}
pub fn instant(character: &Value) -> bool {
    flag(&character["context"], "instant", false)
}

pub fn summarize(character: &Value) -> bool {
    flag(&character["context"], "summarize", true)
}
pub fn defaults(kind: &str) -> Value {
    match kind {
        "provider" => {
            json!({"name":"", "kind":"openai", "base_url":"", "api_key":"", "enabled":true, "headers":{}, "extra_body":{}, "icon":""})
        }
        "model" => {
            json!({"extra_body":{}, "provider_id":"", "model_id":"", "name":"", "context_length":32768, "max_output":0, "vision":false, "tool_call":true, "reasoning":false, "icon":""})
        }
        "character" => {
            json!({"name":"", "avatar":"", "model_id":"", "card":{}, "mcp":[], "plugin_ids":[], "context":{"summarize":true,"instant":false,"compress_threshold":0,"keep_recent":6,"display_recent":4}, "memory":{"enabled":true,"auto_scan":true,"share_global":true}, "params":{"temperature":null,"top_p":null,"max_tokens":null,"reasoning_effort":""}, "sort":0})
        }
        "memory" => {
            json!({"character_id":null,"content":"","tags":[],"pinned":false,"source":"user"})
        }
        "settings" => {
            json!({"default_model_id":"","fast_model_id":"","user_name":"User","user_persona":"","memory_idle_minutes":10,"client":{}})
        }
        _ => json!({}),
    }
}
pub fn merge(dst: &mut Value, src: &Value) {
    if let (Some(d), Some(s)) = (dst.as_object_mut(), src.as_object()) {
        for (k, v) in s {
            if let Some(existing) = d.get_mut(k) {
                if existing.is_object() && v.is_object() {
                    merge(existing, v);
                    continue;
                }
            }
            d.insert(k.clone(), v.clone());
        }
    }
}
pub fn normalized(kind: &str, input: &Value) -> Value {
    let mut v = defaults(kind);
    let known = Value::Object(
        v.as_object()
            .unwrap()
            .keys()
            .filter_map(|key| input.get(key).map(|value| (key.clone(), value.clone())))
            .collect(),
    );
    merge(&mut v, &known);
    if kind == "character" {
        let mut context = defaults("character")["context"].clone();
        for (key, value) in context.as_object_mut().unwrap() {
            if let Some(input) = input["context"].get(key) {
                *value = input.clone();
            }
        }
        v["context"] = context;
    }
    v
}
pub fn mask(key: &str) -> String {
    let chars: Vec<_> = key.chars().collect();
    if chars.is_empty() {
        return String::new();
    }
    if chars.len() <= 8 {
        return "…".into();
    }
    format!(
        "{}…{}",
        chars[..4].iter().collect::<String>(),
        chars[chars.len() - 4..].iter().collect::<String>()
    )
}
