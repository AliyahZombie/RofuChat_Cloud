use crate::{
    card,
    model::{flag, number, text},
};
use serde_json::{json, Value};

pub fn tokens(text: &str) -> i64 {
    let mut cjk = 0;
    let mut other = 0;
    for c in text.chars() {
        if matches!(c as u32,0x3400..=0x9fff|0xf900..=0xfaff|0x20000..=0x3134f) {
            cjk += 1
        } else {
            other += 1
        }
    }
    cjk + (other + 3) / 4
}
pub fn estimate(messages: &[Value], tools: &[Value]) -> i64 {
    messages
        .iter()
        .map(|m| {
            let mut n = tokens(&text(m, "content")) + 4;
            if let Some(images) = m["images"].as_array() {
                n += images.len() as i64 * 800;
            }
            if m.get("tool_calls").is_some() {
                n += tokens(&m["tool_calls"].to_string());
            }
            n
        })
        .sum::<i64>()
        + if tools.is_empty() {
            0
        } else {
            tokens(&serde_json::to_string(tools).unwrap_or_default())
        }
}
pub fn build(
    character: &Value,
    settings: &Value,
    history: &[Value],
    memories: &[Value],
    vision: bool,
) -> Vec<Value> {
    let c = &character["card"];
    let name = text(character, "name");
    let username = text(settings, "user_name");
    let mut blocks = vec![];
    let system = text(c, "system_prompt");
    blocks.push(if system.is_empty() {
        "You are a roleplay character. Stay in character and continue the conversation naturally."
            .to_owned()
    } else {
        system
    });
    for key in ["description", "personality", "scenario"] {
        let v = text(c, key);
        if !v.is_empty() {
            blocks.push(v);
        }
    }
    let persona = text(settings, "user_persona");
    if !persona.is_empty() {
        blocks.push(format!("User persona: {persona}"));
    }
    blocks.extend(card::worldbook(c, history));
    let example = text(c, "mes_example");
    if !example.is_empty() {
        blocks.push(example);
    }
    if flag(&character["memory"], "enabled", true) {
        let pinned = memories
            .iter()
            .filter(|m| flag(m, "pinned", false))
            .map(|m| format!("[{}] {}", text(m, "id"), text(m, "content")))
            .collect::<Vec<_>>()
            .join("\n");
        blocks.push(format!("Long-term memory (pinned):\n{pinned}\nUse memory_search to recall information; memory_add, memory_update and memory_delete maintain durable memories."));
    }
    let mut out =
        vec![json!({"role":"system","content":card::macros(&blocks.join("\n\n"),&name,&username)})];
    let visible: Vec<&Value> = history
        .iter()
        .filter(|m| flag(m, "visible", true))
        .collect();
    let instant = character["context"]["mode"] == "instant";
    let recent = number(&character["context"], "display_recent", 4).max(0) as usize;
    for (index, m) in visible.iter().enumerate() {
        let role = text(m, "role");
        let content = text(m, "content");
        if role == "summary" {
            out.push(json!({"role":"system","content":format!("[Summary of the earlier conversation]\n{content}")}));
            continue;
        }
        if role == "assistant" {
            if instant
                && index < visible.len().saturating_sub(recent)
                && m["actual_status"] == "ok"
                && m["actual"].is_string()
            {
                out.push(json!({"role":"assistant","content":text(m,"actual")}));
                continue;
            }
            if let Some(segments) = m["parts"]["segments"].as_array() {
                if !segments.is_empty() {
                    let mut buffer = String::new();
                    for seg in segments {
                        match seg["type"].as_str().unwrap_or("") {
                            "text" => {
                                if !buffer.is_empty() {
                                    buffer.push_str("\n\n");
                                }
                                buffer.push_str(&text(seg, "text"));
                            }
                            "tool" => {
                                out.push(json!({"role":"assistant","content":std::mem::take(&mut buffer),"tool_calls":[{"id":seg["id"],"name":seg["name"],"arguments":seg["arguments"]}]}));
                                out.push(json!({"role":"tool","call_id":seg["id"],"name":seg["name"],"content":seg["result"]}));
                            }
                            _ => {}
                        }
                    }
                    if !buffer.is_empty() {
                        out.push(json!({"role":"assistant","content":buffer}));
                    }
                    continue;
                }
            }
            if content.is_empty() {
                continue;
            }
        }
        let mut message = json!({"role":role,"content":content});
        if role == "user" && vision {
            message["images"] = m["parts"]["images"]
                .as_array()
                .cloned()
                .map(Value::Array)
                .unwrap_or_else(|| json!([]));
        }
        out.push(message);
    }
    let post = text(c, "post_history_instructions");
    if !post.is_empty() {
        out.push(json!({"role":"system","content":card::macros(&post,&name,&username)}));
    }
    out
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn token_estimate() {
        assert_eq!(tokens("你好abcd"), 3);
        assert_eq!(
            estimate(&[json!({"content":"abcd","images":["x"]})], &[]),
            805
        );
    }
    #[test]
    fn history_selection() {
        let c = json!({"name":"Rofu","context":{"mode":"instant","display_recent":1},"memory":{"enabled":false}});
        let h = vec![
            json!({"role":"user","content":"hidden","visible":false}),
            json!({"role":"summary","content":"summary"}),
            json!({"role":"assistant","content":"display","actual":"short","actual_status":"ok"}),
            json!({"role":"assistant","content":"fallback","actual_status":"failed","parts":{"segments":[{"type":"text","text":"before"},{"type":"tool","id":"c","name":"dice","arguments":"{}","result":"7"},{"type":"text","text":"after"}]}}),
            json!({"role":"user","content":"latest"}),
        ];
        let out = build(&c, &json!({}), &h, &[], true);
        assert!(out[1]["content"].as_str().unwrap().contains("summary"));
        assert_eq!(out[2]["content"], "short");
        assert_eq!(out[3]["content"], "before");
        assert_eq!(out[4]["role"], "tool");
        assert_eq!(out[5]["content"], "after");
        let mut traditional = c.clone();
        traditional["context"]["mode"] = json!("traditional");
        assert_eq!(
            build(&traditional, &json!({}), &h, &[], true)[2]["content"],
            "display"
        );
    }
}
