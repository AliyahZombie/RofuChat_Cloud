use crate::{
    context,
    model::{flag, id, number, text},
    sse::{Decoder, Think},
};
use anyhow::{bail, Result};
use futures_util::StreamExt;
use serde_json::{json, Value};
use std::collections::BTreeMap;
use tokio::sync::mpsc::UnboundedSender;

#[derive(Clone, Debug)]
pub enum Event {
    Text(String),
    Reasoning(String),
    ToolCall(Value),
    Usage(Value),
}
#[derive(Clone)]
pub struct Request {
    pub provider: Value,
    pub model: Value,
    pub messages: Vec<Value>,
    pub params: Value,
    pub tools: Vec<Value>,
}
impl Request {
    /// Short visible answers may still require substantial mandatory reasoning.
    /// Suppress both explicit limits and the model's default output limit.
    pub fn without_output_cap(mut self) -> Self {
        if let Some(params) = self.params.as_object_mut() {
            params.remove("max_tokens");
        }
        self.model["max_output"] = json!(0);
        self
    }

    pub fn body(&self) -> Value {
        let responses = self.provider["kind"] == "responses";
        let mut body = json!({"model":self.model["model_id"],"stream":true});
        if responses {
            body["store"] = json!(false);
            let mut input = vec![];
            let mut first_system = true;
            for m in &self.messages {
                let role = text(m, "role");
                let content = text(m, "content");
                match role.as_str(){
                    "system" if first_system=>{body["instructions"]=json!(content);first_system=false;},
                    "system"=>input.push(json!({"role":"developer","content":content})),
                    "user"=>{let mut parts=vec![json!({"type":"input_text","text":content})];if flag(&self.model,"vision",false){if let Some(images)=m["images"].as_array(){for image in images{parts.push(json!({"type":"input_image","image_url":image}));}}}input.push(json!({"role":"user","content":parts}));},
                    "tool"=>input.push(json!({"type":"function_call_output","call_id":m["call_id"],"output":content})),
                    "assistant"=>{if !content.is_empty(){input.push(json!({"role":"assistant","content":[{"type":"output_text","text":content}]}));}
if let Some(calls)=m["tool_calls"].as_array(){for call in calls{input.push(json!({"type":"function_call","call_id":call["id"],"name":call["name"],"arguments":call["arguments"]}));}}},
                    _=>{}
                }
            }
            body["input"] = json!(input);
            if flag(&self.model, "tool_call", true) && !self.tools.is_empty() {
                body["tools"]=json!(self.tools.iter().map(|t|json!({"type":"function","name":t["name"],"description":t["description"],"parameters":t["parameters"]})).collect::<Vec<_>>());
            }
            let effort = text(&self.params, "reasoning_effort");
            if flag(&self.model, "reasoning", false) && !effort.is_empty() {
                body["reasoning"] = json!({"effort":effort,"summary":"auto"});
            }
            if let Some(n) = self.params["max_tokens"]
                .as_i64()
                .filter(|n| *n > 0)
                .or_else(|| self.model["max_output"].as_i64().filter(|n| *n > 0))
            {
                body["max_output_tokens"] = json!(n);
            }
        } else {
            body["stream_options"] = json!({"include_usage":true});
            let messages=self.messages.iter().map(|m|{
                let role=text(m,"role");let mut v=json!({"role":role,"content":m["content"]});
                if role=="user"&&flag(&self.model,"vision",false){if let Some(images)=m["images"].as_array().filter(|a|!a.is_empty()){let mut parts=vec![json!({"type":"text","text":m["content"]})];for image in images{parts.push(json!({"type":"image_url","image_url":{"url":image}}));}v["content"]=json!(parts);}}
                if role=="tool"{v["tool_call_id"]=m["call_id"].clone();v["name"]=m["name"].clone();}
                if let Some(calls)=m["tool_calls"].as_array(){v["tool_calls"]=json!(calls.iter().map(|c|json!({"id":c["id"],"type":"function","function":{"name":c["name"],"arguments":c["arguments"]}})).collect::<Vec<_>>());}
                v
            }).collect::<Vec<_>>();
            body["messages"] = json!(messages);
            if flag(&self.model, "tool_call", true) && !self.tools.is_empty() {
                body["tools"]=json!(self.tools.iter().map(|t|json!({"type":"function","function":{"name":t["name"],"description":t["description"],"parameters":t["parameters"]}})).collect::<Vec<_>>());
            }
            let effort = text(&self.params, "reasoning_effort");
            if flag(&self.model, "reasoning", false) && !effort.is_empty() {
                body["reasoning_effort"] = json!(effort);
            }
            if let Some(n) = self.params["max_tokens"]
                .as_i64()
                .filter(|n| *n > 0)
                .or_else(|| self.model["max_output"].as_i64().filter(|n| *n > 0))
            {
                body["max_tokens"] = json!(n);
            }
        }
        for key in ["temperature", "top_p"] {
            if self.params[key].is_number() {
                body[key] = self.params[key].clone();
            }
        }
        merge_extra_body(&mut body, &self.provider["extra_body"]);
        merge_extra_body(&mut body, &self.model["extra_body"]);
        body
    }
}
/// Literal request overrides: objects recurse, null deletes, other values replace.
fn merge_extra_body(body: &mut Value, extra: &Value) {
    if let Some(extra) = extra.as_object() {
        if !body.is_object() {
            *body = json!({});
        }
        let object = body.as_object_mut().unwrap();
        for (key, value) in extra {
            if value.is_null() {
                object.remove(key);
            } else if value.is_object() {
                merge_extra_body(object.entry(key.clone()).or_insert(Value::Null), value);
            } else {
                object.insert(key.clone(), value.clone());
            }
        }
    }
}
pub fn headers(
    mut request: reqwest::RequestBuilder,
    provider: &Value,
) -> Result<reqwest::RequestBuilder> {
    let key = text(provider, "api_key");
    if !key.is_empty() {
        request = request.bearer_auth(key);
    }
    if let Some(headers) = provider["headers"].as_object() {
        for (k, v) in headers {
            if let Some(v) = v.as_str() {
                request = request.header(k, v);
            }
        }
    }
    Ok(request)
}
struct Parser<'a> {
    responses: bool,
    think: Think,
    calls: BTreeMap<i64, Value>,
    usage: Option<Value>,
    output: String,
    diagnostics: &'a mut Completion,
    tx: UnboundedSender<Event>,
}
impl Parser<'_> {
    fn emit(&mut self, e: Event) {
        if let Event::Text(t) | Event::Reasoning(t) = &e {
            self.output.push_str(t);
        }
        let _ = self.tx.send(e);
    }
    fn finish_usage(&mut self, request: &Request) -> Value {
        let mut usage = self
            .usage
            .take()
            .unwrap_or_else(|| json!({"cached":0,"reasoning":0,"estimated":true}));
        for (key, estimate) in [
            (
                "input",
                context::estimate(&request.messages, &request.tools),
            ),
            ("output", context::tokens(&self.output)),
        ] {
            if !usage[key].is_i64() {
                usage[key] = json!(estimate);
                usage["estimated"] = json!(true);
            }
        }
        usage
    }
    fn text(&mut self, s: &str) {
        for (reasoning, t) in self.think.push(s) {
            self.emit(if reasoning {
                Event::Reasoning(t)
            } else {
                Event::Text(t)
            });
        }
    }
    fn parse(&mut self, data: &str) -> Result<()> {
        if data.trim() == "[DONE]" || data.trim().is_empty() {
            return Ok(());
        }
        let v: Value = serde_json::from_str(data)?;
        if let Some(e) = v.get("error").filter(|e| !e.is_null()) {
            bail!("provider stream error: {e}");
        }
        if self.responses {
            match text(&v, "type").as_str() {
                "response.output_text.delta" => {
                    self.diagnostics.raw.push_str(&text(&v, "delta"));
                    self.text(&text(&v, "delta"));
                }
                "response.reasoning_summary_text.delta" | "response.reasoning_text.delta" => {
                    self.emit(Event::Reasoning(text(&v, "delta")))
                }
                "response.output_item.done" if v["item"]["type"] == "function_call" => {
                    let c = &v["item"];
                    let cid = text(c, "call_id");
                    self.emit(Event::ToolCall(json!({"id":if cid.is_empty(){format!("call_0_{}",id())}else{cid},"name":c["name"],"arguments":c["arguments"]})));
                }
                "response.completed" | "response.incomplete" => {
                    self.diagnostics.truncated |= v["type"] == "response.incomplete"
                        || v["response"]["status"] == "incomplete"
                        || v["response"]["incomplete_details"]["reason"] == "max_output_tokens";
                    let u = &v["response"]["usage"];
                    if u.is_object() {
                        self.usage = Some(
                            json!({"input":u["input_tokens"],"output":u["output_tokens"],"cached":number(&u["input_tokens_details"],"cached_tokens",0),"reasoning":number(&u["output_tokens_details"],"reasoning_tokens",0),"estimated":!u["input_tokens_details"]["cached_tokens"].is_i64()}),
                        );
                    }
                }
                "response.failed" | "error" => bail!("provider response failed: {v}"),
                _ => {}
            }
        } else {
            if let Some(choices) = v["choices"].as_array() {
                for choice in choices.iter().take(1) {
                    self.diagnostics.truncated |= choice["finish_reason"] == "length";
                    let d = &choice["delta"];
                    if let Some(s) = d["content"].as_str() {
                        self.diagnostics.raw.push_str(s);
                        self.text(s);
                    }
                    if let Some(s) = d["reasoning_content"]
                        .as_str()
                        .or_else(|| d["reasoning"].as_str())
                    {
                        self.emit(Event::Reasoning(s.into()));
                    }
                    if let Some(calls) = d["tool_calls"].as_array() {
                        for c in calls {
                            let index = number(c, "index", 0);
                            let entry = self
                                .calls
                                .entry(index)
                                .or_insert_with(|| json!({"id":"","name":"","arguments":""}));
                            for (key, source) in [
                                ("id", &c["id"]),
                                ("name", &c["function"]["name"]),
                                ("arguments", &c["function"]["arguments"]),
                            ] {
                                if let Some(part) = source.as_str() {
                                    let mut t = text(entry, key);
                                    t.push_str(part);
                                    entry[key] = json!(t);
                                }
                            }
                        }
                    }
                }
            }
            let u = &v["usage"];
            if u.is_object() {
                self.usage = Some(
                    json!({"input":u["prompt_tokens"],"output":u["completion_tokens"],"cached":u["prompt_tokens_details"]["cached_tokens"].as_i64().unwrap_or_else(||number(u,"prompt_cache_hit_tokens",0)),"reasoning":number(&u["completion_tokens_details"],"reasoning_tokens",0),"estimated":!(u["prompt_tokens_details"]["cached_tokens"].is_i64()||u["prompt_cache_hit_tokens"].is_i64())}),
                );
            }
        }
        Ok(())
    }
}
pub async fn stream(
    client: &reqwest::Client,
    request: Request,
    tx: UnboundedSender<Event>,
) -> Result<()> {
    stream_with_diagnostics(client, request, tx, &mut Completion::default()).await
}

async fn stream_with_diagnostics(
    client: &reqwest::Client,
    request: Request,
    tx: UnboundedSender<Event>,
    diagnostics: &mut Completion,
) -> Result<()> {
    let responses = request.provider["kind"] == "responses";
    let url = format!(
        "{}/{}",
        text(&request.provider, "base_url").trim_end_matches('/'),
        if responses {
            "responses"
        } else {
            "chat/completions"
        }
    );
    let response = headers(client.post(url), &request.provider)?
        .json(&request.body())
        .send()
        .await?;
    if !response.status().is_success() {
        let status = response.status();
        let body = response.text().await?;
        bail!(
            "HTTP {status}: {}",
            body.chars().take(800).collect::<String>()
        );
    }
    let mut parser = Parser {
        responses,
        think: Think::default(),
        calls: Default::default(),
        usage: None,
        output: String::new(),
        diagnostics,
        tx,
    };
    let mut decoder = Decoder::default();
    let mut chunks = response.bytes_stream();
    while let Some(chunk) = chunks.next().await {
        for event in decoder.push(&chunk?) {
            parser.parse(&event.data)?;
        }
    }
    for event in decoder.finish() {
        parser.parse(&event.data)?;
    }
    for (reasoning, s) in parser.think.finish() {
        parser.emit(if reasoning {
            Event::Reasoning(s)
        } else {
            Event::Text(s)
        });
    }
    let calls = std::mem::take(&mut parser.calls);
    for (index, mut c) in calls {
        if text(&c, "id").is_empty() {
            c["id"] = json!(format!("call_{index}_{}", id()));
        }
        parser.emit(Event::ToolCall(c));
    }
    let usage = parser.finish_usage(&request);
    parser.emit(Event::Usage(usage));
    Ok(())
}
#[derive(Debug)]
pub struct EmptyCompletion;
impl std::fmt::Display for EmptyCompletion {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("model returned no text")
    }
}
impl std::error::Error for EmptyCompletion {}

/// Visible text and diagnostic data are kept separate: reasoning is never an answer.
#[derive(Default, Debug)]
pub struct Completion {
    pub text: String,
    pub reasoning: String,
    /// Raw content deltas, including think tags; never a fallback to reasoning.
    pub raw: String,
    pub error: Option<anyhow::Error>,
    pub truncated: bool,
}

pub async fn complete_detailed(client: &reqwest::Client, request: Request) -> Completion {
    let (tx, mut rx) = tokio::sync::mpsc::unbounded_channel();
    let mut completion = Completion::default();
    let result = tokio::time::timeout(
        std::time::Duration::from_secs(120),
        stream_with_diagnostics(client, request, tx, &mut completion),
    )
    .await;
    completion.error = match result {
        Ok(result) => result.err(),
        Err(error) => Some(error.into()),
    };
    while let Some(e) = rx.recv().await {
        match e {
            Event::Text(t) => completion.text.push_str(&t),
            Event::Reasoning(t) => completion.reasoning.push_str(&t),
            _ => {}
        }
    }
    completion
}

pub async fn complete(client: &reqwest::Client, request: Request) -> Result<String> {
    let completion = complete_detailed(client, request).await;
    if let Some(error) = completion.error {
        return Err(error);
    }
    if completion.text.is_empty() {
        if !completion.reasoning.is_empty() {
            bail!("model returned reasoning-only output (no content)");
        }
        return Err(EmptyCompletion.into());
    }
    Ok(completion.text)
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn extra_body_merges_last_for_both_apis() {
        for kind in ["openai", "responses"] {
            let request = Request {
                provider: json!({"kind":kind,"extra_body":{"provider":{"order":["anthropic"],"allow_fallbacks":false},"stream_options":{"include_usage":null,"custom":1},"replace":{"before":1},"nested":{"a":1,"b":2},"stream":false,"temperature":0.9}}),
                model: json!({"model_id":"model","extra_body":{"provider":{"order":["google"]},"replace":[1,2],"nested":{"a":null,"c":3},"stream_options":{"custom":2},"store":null,"temperature":null,"new":{"absent":null,"present":true}}}),
                messages: vec![],
                params: json!({"temperature":0.2}),
                tools: vec![],
            };
            let body = request.body();
            assert_eq!(
                body["provider"],
                json!({"order":["google"],"allow_fallbacks":false})
            );
            assert_eq!(body["stream"], false);
            assert_eq!(body["stream_options"], json!({"custom":2}));
            assert_eq!(body["replace"], json!([1, 2]));
            assert_eq!(body["nested"], json!({"b":2,"c":3}));
            assert_eq!(body["new"], json!({"present":true}));
            assert!(body.get("store").is_none());
            assert!(body.get("temperature").is_none());
        }
    }
    #[test]
    fn request_shapes() {
        let mut req = Request {
            provider: json!({"kind":"responses"}),
            model: json!({"model_id":"x","vision":false,"tool_call":false,"reasoning":false}),
            messages: context::build(
                &json!({"card":{"system_prompt":"first","post_history_instructions":"last"},"memory":{"enabled":false}}),
                &json!({}),
                &[
                    json!({"role":"summary","content":"earlier"}),
                    json!({"role":"user","content":"hello","parts":{"images":["img"]}}),
                ],
                &[],
                true,
            ),
            params: json!({"reasoning_effort":"high"}),
            tools: vec![json!({"name":"dice"})],
        };
        let b = req.body();
        assert_eq!(
            b["instructions"],
            "first\n\n[Summary of the earlier conversation]\nearlier\n\nlast"
        );
        assert_eq!(b["input"].as_array().unwrap().len(), 1);
        assert_eq!(b["input"][0]["role"], "user");
        assert!(b.get("tools").is_none());
        assert!(b.get("reasoning").is_none());
        assert_eq!(b["input"][0]["content"].as_array().unwrap().len(), 1);
        req.provider["kind"] = json!("openai");
        assert_eq!(req.body()["stream_options"]["include_usage"], true);
    }
    #[test]
    fn responses_incomplete_and_failed_and_cache_alias() {
        let (tx, _rx) = tokio::sync::mpsc::unbounded_channel();
        let mut p = Parser {
            responses: true,
            think: Think::default(),
            calls: Default::default(),
            usage: None,
            output: String::new(),
            diagnostics: &mut Completion::default(),
            tx,
        };
        p.parse(&json!({"type":"response.incomplete","response":{"usage":{"input_tokens":12,"output_tokens":3,"input_tokens_details":{"cached_tokens":4},"output_tokens_details":{"reasoning_tokens":2}}}}).to_string()).unwrap();
        assert_eq!(p.usage.as_ref().unwrap()["cached"], 4);
        assert!(p.diagnostics.truncated);
        for response in [
            json!({"status":"incomplete"}),
            json!({"incomplete_details":{"reason":"max_output_tokens"}}),
        ] {
            p.diagnostics.truncated = false;
            p.parse(&json!({"type":"response.completed","response":response}).to_string())
                .unwrap();
            assert!(p.diagnostics.truncated);
        }
        assert!(p
            .parse(&json!({"type":"response.failed","response":{"error":"failed"}}).to_string())
            .is_err());
        p.responses = false;
        p.diagnostics.truncated = false;
        p.parse(&json!({"choices":[{"delta":{},"finish_reason":"length"}]}).to_string())
            .unwrap();
        assert!(p.diagnostics.truncated);
        p.parse(&json!({"usage":{"prompt_tokens":30,"completion_tokens":8,"prompt_cache_hit_tokens":9}}).to_string()).unwrap();
        assert_eq!(p.usage.as_ref().unwrap()["cached"], 9);
        assert!(p
            .parse(&json!({"error":{"message":"bad"}}).to_string())
            .is_err());
    }
    #[test]
    fn partial_usage_falls_back_per_field() {
        let (tx, _rx) = tokio::sync::mpsc::unbounded_channel();
        let mut p = Parser {
            responses: false,
            think: Think::default(),
            calls: Default::default(),
            usage: None,
            output: String::new(),
            diagnostics: &mut Completion::default(),
            tx,
        };
        p.parse(&json!({"usage":{"completion_tokens":7}}).to_string())
            .unwrap();
        let req = Request {
            provider: json!({}),
            model: json!({}),
            messages: vec![json!({"role":"user","content":"hello"})],
            params: json!({}),
            tools: vec![],
        };
        let usage = p.finish_usage(&req);
        assert_eq!(usage["input"], 6);
        assert_eq!(usage["output"], 7);
        assert_eq!(usage["estimated"], true);
    }
}
