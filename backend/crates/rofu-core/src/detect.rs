use crate::model::{defaults, text};
use serde_json::{json, Value};

pub const ICONS: &[(&[&str], &str)] = &[
    (&["openrouter"], "openrouter"),
    (&["siliconflow"], "siliconflow"),
    (&["ollama"], "ollama"),
    (&["claude", "anthropic"], "claude"),
    (
        &["gemini", "gemma", "generativelanguage", "google"],
        "gemini",
    ),
    (
        &[
            "gpt", "o1", "o3", "o4", "chatgpt", "dall-e", "whisper", "codex", "openai",
        ],
        "openai",
    ),
    (&["deepseek"], "deepseek"),
    (&["qwen", "qwq"], "qwen"),
    (&["glm", "zhipu", "bigmodel"], "zhipu"),
    (&["moonshot", "kimi"], "moonshot"),
    (&["grok", "x.ai"], "grok"),
    (&["llama", "meta"], "meta"),
    (
        &[
            "mistral",
            "mixtral",
            "codestral",
            "pixtral",
            "magistral",
            "devstral",
        ],
        "mistral",
    ),
    (&["doubao", "volcengine"], "doubao"),
    (&["minimax"], "minimax"),
    (&["ernie", "wenxin", "baidu"], "wenxin"),
    (&["hunyuan"], "hunyuan"),
    (&["yi-", "01.ai"], "yi"),
    (&["cohere", "command"], "cohere"),
    (&["phi", "microsoft"], "microsoft"),
    (&["nova", "bedrock", "amazon"], "aws"),
    (&["step-", "stepfun"], "stepfun"),
    (&["baichuan"], "baichuan"),
    (&["spark", "xfyun"], "spark"),
    (&["sonar", "perplexity"], "perplexity"),
    (&["nemotron", "nvidia"], "nvidia"),
];
pub const VISION: &[&str] = &[
    "gpt-4o",
    "gpt-4.1",
    "gpt-5",
    "claude-3",
    "claude-sonnet-4",
    "claude-opus-4",
    "claude-haiku-4",
    "gemini",
    "-vl",
    "qwen-vl",
    "llava",
    "pixtral",
    "grok-4",
    "glm-4v",
];
pub const NO_TOOLS: &[&str] = &[
    "embedding",
    "tts",
    "whisper",
    "dall-e",
    "image",
    "moderation",
    "rerank",
];
pub const REASONING: &[&str] = &[
    "o1",
    "o3",
    "o4",
    "gpt-5",
    "r1",
    "reasoner",
    "thinking",
    "qwq",
    "claude-sonnet-4",
    "claude-opus-4",
    "gemini-2.5",
    "gemini-3",
    "qwen3",
    "glm-4.5",
    "glm-4.6",
    "glm-4.7",
    "glm-5",
];
fn has(name: &str, keys: &[&str]) -> bool {
    keys.iter().any(|k| name.contains(k))
}
pub fn icon(name: &str) -> String {
    let lower = name.to_lowercase();
    ICONS
        .iter()
        .find(|(keys, _)| has(&lower, keys))
        .map(|(_, i)| i.to_string())
        .unwrap_or_default()
}
pub fn detect(raw: &Value, provider: &str) -> Value {
    let model = text(raw, "id");
    let model = if model.is_empty() {
        let model_id = text(raw, "model_id");
        if model_id.is_empty() {
            text(raw, "name")
        } else {
            model_id
        }
    } else {
        model
    };
    let model = model.trim_start_matches("models/");
    let low = model.to_lowercase();
    let mut v = defaults("model");
    v["id"] = json!("");
    v["provider_id"] = json!(provider);
    v["model_id"] = json!(model);
    let name = text(raw, "name");
    v["name"] = json!(if name.is_empty() { model } else { &name });
    v["icon"] = json!(icon(&low));
    let default = if low.contains("gemini") {
        1_000_000
    } else if low.contains("gpt-5") {
        400_000
    } else if has(&low, &["claude", "o1", "o3", "o4"]) {
        200_000
    } else if has(
        &low,
        &["gpt-4o", "gpt-4.1", "deepseek", "qwen", "glm", "kimi"],
    ) {
        128_000
    } else {
        32768
    };
    v["context_length"] = json!([
        "context_length",
        "context_window",
        "inputTokenLimit",
        "max_context_length"
    ]
    .iter()
    .find_map(|k| raw[*k].as_i64())
    .unwrap_or(default));
    v["max_output"] = json!(raw["top_provider"]["max_completion_tokens"]
        .as_i64()
        .or_else(|| raw["outputTokenLimit"].as_i64())
        .or_else(|| raw["max_output_tokens"].as_i64())
        .unwrap_or(0));
    let modalities = raw["architecture"]["input_modalities"].as_array();
    let params = raw["supported_parameters"].as_array();
    v["vision"] = json!(raw["capabilities"]["vision"]
        .as_bool()
        .unwrap_or_else(|| modalities
            .map(|m| m.iter().any(|x| x == "image"))
            .unwrap_or_else(|| has(&low, VISION))));
    v["tool_call"] = json!(raw["capabilities"]["function_calling"]
        .as_bool()
        .unwrap_or_else(|| params
            .map(|p| p.iter().any(|x| x == "tools"))
            .unwrap_or_else(|| !has(&low, NO_TOOLS))));
    v["reasoning"] = json!(params
        .map(|p| p
            .iter()
            .any(|x| x == "reasoning" || x == "include_reasoning"))
        .unwrap_or_else(|| has(&low, REASONING)));
    v
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn metadata_and_heuristics() {
        let v = detect(&json!({"id":"models/gemini-2.5-pro"}), "p");
        assert_eq!(v["model_id"], "gemini-2.5-pro");
        assert_eq!(v["vision"], true);
        assert_eq!(v["reasoning"], true);
        assert_eq!(v["context_length"], 1_000_000);
        let v = detect(
            &json!({"id":"unknown","context_window":42,"architecture":{"input_modalities":["image"]},"supported_parameters":["tools","reasoning"],"top_provider":{"max_completion_tokens":9}}),
            "",
        );
        assert_eq!(v["max_output"], 9);
        assert_eq!(v["context_length"], 42);
        assert_eq!(v["vision"], true);
        assert_eq!(
            detect(&json!({"id":"text-embedding-3"}), "")["tool_call"],
            false
        );
    }
    #[test]
    fn icons() {
        for (keys, key) in ICONS {
            assert_eq!(icon(keys[0]), *key);
        }
        assert_eq!(icon("unknown"), "");
    }
}
