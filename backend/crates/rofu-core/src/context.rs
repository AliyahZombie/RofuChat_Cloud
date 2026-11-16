use crate::{
    card,
    model::{flag, instant, number, text},
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
    for m in history
        .iter()
        .filter(|m| flag(m, "visible", true) && m["role"] == "summary")
    {
        blocks.push(format!(
            "[Summary of the earlier conversation]\n{}",
            text(m, "content")
        ));
    }
    let post = text(c, "post_history_instructions");
    if !post.is_empty() {
        blocks.push(post);
    }
    let mut out =
        vec![json!({"role":"system","content":card::macros(&blocks.join("\n\n"),&name,&username)})];
    let visible: Vec<&Value> = history
        .iter()
        .filter(|m| {
            flag(m, "visible", true)
                && matches!(m["role"].as_str(), Some("user" | "assistant" | "tool"))
        })
        .collect();
    let instant = instant(character);
    let recent = number(&character["context"], "display_recent", 4).max(0) as usize;
    for (index, m) in visible.iter().enumerate() {
        let role = text(m, "role");
        let content = text(m, "content");
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
                if m["tool_calls"].as_array().is_some_and(|a| !a.is_empty()) {
                    out.push(
                        json!({"role":"assistant","content":buffer,"tool_calls":m["tool_calls"]}),
                    );
                } else if !buffer.is_empty() {
                    out.push(json!({"role":"assistant","content":buffer}));
                }
            }
            continue;
        }
        let mut message = json!({"role":role,"content":content});
        if role == "tool" {
            for key in ["call_id", "name"] {
                if let Some(v) = m.get(key) {
                    message[key] = v.clone();
                }
            }
        }
        if role == "user" && vision {
            message["images"] = m["parts"]["images"]
                .as_array()
                .cloned()
                .map(Value::Array)
                .unwrap_or_else(|| json!([]));
        }
        out.push(message);
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
    fn single_system_block_order_and_stable_prefix() {
        let c = json!({"name":"Rofu","card":{
            "system_prompt":"System {{char}}",
            "description":"Description <BOT>",
            "personality":"Personality",
            "scenario":"Scenario",
            "character_book":{"entries":[{"constant":true,"content":"World {{user}}"}]},
            "mes_example":"Example <USER>",
            "post_history_instructions":"Post {{CHAR}} {{USER}}"
        }});
        let settings = json!({"user_name":"Alice","user_persona":"Persona"});
        let memories = vec![
            json!({"id":"p","pinned":true,"content":"Remember Alice"}),
            json!({"id":"u","content":"Not pinned"}),
        ];
        let mut history = vec![
            json!({"role":"summary","content":"Hidden summary","visible":false}),
            json!({"role":"summary","content":"First summary"}),
            json!({"role":"user","content":"Hello"}),
            json!({"role":"summary","content":"Second summary"}),
        ];
        let out = build(&c, &settings, &history, &memories, false);
        let expected = "System Rofu\n\nDescription Rofu\n\nPersonality\n\nScenario\n\nUser persona: Persona\n\nWorld Alice\n\nExample Alice\n\nLong-term memory (pinned):\n[p] Remember Alice\nUse memory_search to recall information; memory_add, memory_update and memory_delete maintain durable memories.\n\n[Summary of the earlier conversation]\nFirst summary\n\n[Summary of the earlier conversation]\nSecond summary\n\nPost Rofu Alice";
        assert_eq!(
            out,
            vec![
                json!({"role":"system","content":expected}),
                json!({"role":"user","content":"Hello"})
            ]
        );
        assert_eq!(
            estimate(&out, &[]),
            tokens(expected) + 4 + tokens("Hello") + 4
        );

        history.push(crate::chat::message("c", 1000, "assistant", "Hi Alice"));
        history.push(json!({"role":"user","content":"Continue"}));
        let next = build(&c, &settings, &history, &memories, false);
        assert_eq!(&next[..out.len()], out.as_slice());
        assert_eq!(next.len(), out.len() + 2);
    }
    #[test]
    fn keyword_worldbook_changes_system_when_triggered() {
        let c = json!({"card":{"system_prompt":"System","post_history_instructions":"Post","character_book":{"entries":[{"keys":["forest"],"content":"Forest lore"}]}},"memory":{"enabled":false}});
        let before = build(&c, &json!({}), &[], &[], false);
        let after = build(
            &c,
            &json!({}),
            &[json!({"role":"user","content":"Forest"})],
            &[],
            false,
        );
        assert_eq!(before[0]["content"], "System\n\nPost");
        assert_eq!(after[0]["content"], "System\n\nForest lore\n\nPost");
    }
    #[test]
    fn history_selection() {
        let c = json!({"name":"Rofu","context":{"instant":true,"display_recent":1},"memory":{"enabled":false}});
        let h = vec![
            json!({"role":"user","content":"hidden","visible":false}),
            json!({"role":"summary","content":"summary"}),
            json!({"role":"assistant","content":"display","parts":{"segments":[{"type":"text","text":"display"}]},"actual":"short","actual_status":"ok"}),
            json!({"role":"assistant","content":"fallback","actual_status":"failed","parts":{"segments":[{"type":"text","text":"before"},{"type":"tool","id":"c","name":"dice","arguments":"{}","result":"7"},{"type":"text","text":"after"}]}}),
            json!({"role":"user","content":"latest"}),
        ];
        let out = build(&c, &json!({}), &h, &[], true);
        assert_eq!(out[0]["role"], "system");
        assert!(
            text(&out[0], "content").ends_with("[Summary of the earlier conversation]\nsummary")
        );
        assert!(out[1..]
            .iter()
            .all(|m| matches!(m["role"].as_str(), Some("user" | "assistant" | "tool"))));
        assert_eq!(out[1]["content"], "short");
        assert_eq!(out[2]["content"], "before");
        assert_eq!(out[3]["role"], "tool");
        assert_eq!(out[4]["content"], "after");
        let mut traditional = c.clone();
        traditional["context"]["instant"] = json!(false);
        assert_eq!(
            build(&traditional, &json!({}), &h, &[], true)[1]["content"],
            "display"
        );
    }

    #[test]
    fn independent_switches_and_hidden_actual_never_enters_context() {
        let history = vec![
            json!({"role":"assistant","content":"hidden display","actual":"hidden actual","actual_status":"ok","visible":false}),
            json!({"role":"summary","content":"summary"}),
            json!({"role":"assistant","content":"display","parts":{"segments":[{"type":"text","text":"display"}]},"actual":"note","actual_status":"ok"}),
            json!({"role":"user","content":"recent"}),
        ];
        for summarize in [false, true] {
            for instant in [false, true] {
                let c = json!({"context":{"instant":instant,"summarize":summarize,"display_recent":1},"memory":{"enabled":false}});
                let out = build(&c, &json!({}), &history, &[], false);
                assert_eq!(out.len(), 3);
                assert_eq!(out[1]["content"], if instant { "note" } else { "display" });
                assert!(!out.iter().any(|m| text(m, "content").contains("hidden")));
            }
        }
    }
}
