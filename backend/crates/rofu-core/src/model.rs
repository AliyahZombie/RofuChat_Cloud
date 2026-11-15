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
    flag(
        &character["context"],
        "instant",
        character["context"]["mode"] == "instant",
    )
}
pub fn summarize(character: &Value) -> bool {
    flag(&character["context"], "summarize", true)
}
pub fn normalize_context(character: &mut Value) {
    let instant = instant(character);
    let summarize = summarize(character);
    if !character["context"].is_object() {
        character["context"] = json!({});
    }
    character["context"]["instant"] = json!(instant);
    character["context"]["summarize"] = json!(summarize);
    character["context"]["mode"] = json!(if instant { "instant" } else { "traditional" });
}
pub fn defaults(kind: &str) -> Value {
    match kind {
        "provider" => {
            json!({"name":"", "kind":"openai", "base_url":"", "api_key":"", "enabled":true, "headers":{}, "icon":""})
        }
        "model" => {
            json!({"provider_id":"", "model_id":"", "name":"", "context_length":32768, "max_output":0, "vision":false, "tool_call":true, "reasoning":false, "icon":""})
        }
        "character" => {
            json!({"name":"", "avatar":"", "model_id":"", "card":{}, "mcp":[], "tool_ids":[], "context":{"mode":"traditional","summarize":true,"instant":false,"compress_threshold":0,"keep_recent":6,"display_recent":4}, "memory":{"enabled":true,"auto_scan":true,"share_global":true}, "params":{"temperature":null,"top_p":null,"max_tokens":null,"reasoning_effort":""}, "sort":0})
        }
        "tool" => {
            json!({"name":"", "description":"", "parameters":{"type":"object","properties":{}}, "code":"", "models":[], "enabled":true})
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
    merge(&mut v, input);
    if kind == "character" {
        // Derive missing switches from the original input before defaults mask absence.
        if !v["context"].is_object() {
            v["context"] = defaults("character")["context"].clone();
        }
        v["context"]["instant"] = json!(instant(input));
        v["context"]["summarize"] = json!(summarize(input));
        normalize_context(&mut v);
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn independent_context_switches_and_legacy_defaults() {
        for (input, expected_instant, expected_summarize) in [
            (json!({}), false, true),
            (json!({"mode":"instant"}), true, true),
            (json!({"mode":"traditional"}), false, true),
            (json!({"mode":"unknown"}), false, true),
            (json!({"mode":"instant","instant":false}), false, true),
            (
                json!({"mode":"traditional","instant":true,"summarize":false}),
                true,
                false,
            ),
            (json!({"summarize":false}), false, false),
            (Value::Null, false, true),
        ] {
            let c = normalized("character", &json!({"context":input}));
            assert_eq!(c["context"]["instant"], expected_instant);
            assert_eq!(c["context"]["summarize"], expected_summarize);
            assert_eq!(
                c["context"]["mode"],
                if expected_instant {
                    "instant"
                } else {
                    "traditional"
                }
            );
        }
        assert_eq!(defaults("character")["context"]["instant"], false);
        assert_eq!(defaults("character")["context"]["summarize"], true);
    }
}
