use axum::{
    body::{Body, Bytes},
    extract::{Query, State},
    http::{HeaderMap, StatusCode},
    response::{sse::Event, IntoResponse, Response, Sse},
    routing::{get, post},
    Json, Router,
};
use futures_util::{stream, StreamExt};
use serde_json::{json, Value};
use std::{
    collections::{HashMap, VecDeque},
    convert::Infallible,
    sync::Arc,
    time::Duration,
};
use tokio::{
    sync::{mpsc, Mutex},
    task::JoinHandle,
};
#[derive(Clone, Default)]
pub struct Mock {
    pub requests: Arc<Mutex<Vec<Value>>>,
    pub scan: Arc<Mutex<Value>>,
    pub title: Arc<Mutex<Option<String>>>,
    pub actual: Arc<Mutex<VecDeque<String>>>,
    legacy: Arc<Mutex<HashMap<String, mpsc::UnboundedSender<Event>>>>,
}
pub struct MockServer {
    pub url: String,
    pub state: Mock,
    task: JoinHandle<()>,
}
impl Drop for MockServer {
    fn drop(&mut self) {
        self.task.abort();
    }
}
impl MockServer {
    pub async fn start() -> Self {
        let state = Mock::default();
        let app=Router::new().route("/models",get(||async{Json(json!({"data":[{"id":"mock-tool","context_length":10000,"supported_parameters":["tools","reasoning"]}]}))})).route("/chat/completions",post(llm)).route("/responses",post(llm)).route("/avatar",get(||async{ ([("Content-Type","image/png")], rofu_core::card::export_png(&json!({"card":{"name":"Avatar"}})).unwrap()) })).route("/mcp",post(mcp_http)).route("/legacy",get(legacy)).route("/mcp/message",post(legacy_post)).with_state(state.clone());
        let listener = tokio::net::TcpListener::bind("127.0.0.1:0").await.unwrap();
        let url = format!("http://{}", listener.local_addr().unwrap());
        let task = tokio::spawn(async move {
            axum::serve(listener, app).await.unwrap();
        });
        Self { url, state, task }
    }
}
async fn llm(State(state): State<Mock>, Json(body): Json<Value>) -> Response {
    state.requests.lock().await.push(body.clone());
    if body["model"] == "fail" {
        return (StatusCode::INTERNAL_SERVER_ERROR, "mock failure").into_response();
    }
    let responses = body.get("input").is_some();
    let instructions = if responses {
        body["instructions"].as_str().unwrap_or("")
    } else {
        body["messages"][0]["content"].as_str().unwrap_or("")
    };
    let answer = if instructions.contains("Extract durable") {
        let v = state.scan.lock().await.clone();
        if v.is_object() {
            format!("```json\n{v}\n```")
        } else {
            "{\"add\":[],\"update\":[],\"delete\":[]}".into()
        }
    } else if instructions.starts_with("Generate a short") {
        state
            .title
            .lock()
            .await
            .clone()
            .unwrap_or_else(|| "Mock title".into())
    } else if instructions.starts_with("Condense one") {
        state
            .actual
            .lock()
            .await
            .pop_front()
            .unwrap_or_else(|| "Rofu replied.".into())
    } else if instructions.starts_with("Summarize") {
        "Earlier summary".into()
    } else {
        "Answer complete".into()
    };
    let has_tool_result = if responses {
        body["input"]
            .as_array()
            .unwrap()
            .iter()
            .any(|m| m["type"] == "function_call_output")
    } else {
        body["messages"]
            .as_array()
            .unwrap()
            .iter()
            .any(|m| m["role"] == "tool")
    };
    let tools = body["tools"].as_array().is_some_and(|t| !t.is_empty())
        && !has_tool_result
        && body["model"] == "mock-tool";
    let mut chunks = vec![];
    if responses {
        chunks.push(json!({"type":"response.reasoning_summary_text.delta","delta":"reasoning"}));
        if tools {
            for (i, name, args) in [
                (0, "dice", json!({"n":6})),
                (1, "search__lookup", json!({"q":"forest"})),
                (2, "memory_add", json!({"content":"Alice likes forest tea"})),
            ] {
                chunks.push(json!({"type":"response.output_item.done","item":{"type":"function_call","call_id":format!("r{i}"),"name":name,"arguments":args.to_string()}}));
            }
        } else {
            chunks.push(json!({"type":"response.output_text.delta","delta":answer}));
        }
        chunks.push(json!({"type":"response.completed","response":{"usage":{"input_tokens":100,"output_tokens":20,"input_tokens_details":{"cached_tokens":40},"output_tokens_details":{"reasoning_tokens":5}}}}));
    } else {
        if body["model"] == "slow" {
            for _ in 0..150 {
                chunks.push(json!({"choices":[{"delta":{"content":"x"}}]}));
            }
        } else if tools {
            chunks.push(json!({"choices":[{"delta":{"content":"<thi"}}]}));
            chunks.push(json!({"choices":[{"delta":{"content":"nk>thought</thi"}}]}));
            chunks.push(json!({"choices":[{"delta":{"content":"nk>I will use tools"}}]}));
            for (i, name, args) in [
                (0, "dice", json!({"n":6})),
                (1, "search__lookup", json!({"q":"forest"})),
                (2, "memory_add", json!({"content":"Alice likes forest tea"})),
            ] {
                let args = args.to_string();
                let mid = args.len() / 2;
                let cid = if i == 0 {
                    Value::Null
                } else {
                    json!(format!("c{i}"))
                };
                chunks.push(json!({"choices":[{"delta":{"tool_calls":[{"index":i,"id":cid,"function":{"name":name,"arguments":&args[..mid]}}]}}]}));
                chunks.push(json!({"choices":[{"delta":{"tool_calls":[{"index":i,"function":{"arguments":&args[mid..]}}]}}]}));
            }
        } else {
            chunks.push(json!({"choices":[{"delta":{"reasoning_content":"reasoning"}}]}));
            chunks.push(json!({"choices":[{"delta":{"content":answer}}]}));
        }
        chunks.push(json!({"choices":[],"usage":{"prompt_tokens":100,"completion_tokens":20,"prompt_tokens_details":{"cached_tokens":40},"completion_tokens_details":{"reasoning_tokens":5}}}));
    }
    if body["model"] == "stream-error" {
        chunks = vec![
            json!({"choices":[{"delta":{"content":"partial"}}]}),
            json!({"error":{"message":"mock stream failure"}}),
        ];
    }
    if body["model"] == "no-usage" {
        chunks.retain(|c| c.get("usage").is_none());
    }
    let delay = if body["model"] == "slow" { 30 } else { 1 };
    // Split SSE fields into small body chunks to exercise incremental parsing.
    let wire = chunks
        .iter()
        .map(|v| format!("data: {v}\r\n\r\n"))
        .collect::<String>()
        + "data: [DONE]\n\n";
    let chunks: Vec<_> = if delay == 30 {
        wire.as_bytes()
            .chunks(55)
            .map(Bytes::copy_from_slice)
            .collect()
    } else {
        wire.as_bytes()
            .chunks(7)
            .map(Bytes::copy_from_slice)
            .collect()
    };
    let stream = stream::iter(chunks).then(move |bytes| async move {
        tokio::time::sleep(Duration::from_millis(delay)).await;
        Ok::<_, Infallible>(bytes)
    });
    Response::builder()
        .header("Content-Type", "text/event-stream")
        .body(Body::from_stream(stream))
        .unwrap()
}
fn rpc(body: &Value) -> Value {
    let result = match body["method"].as_str().unwrap_or("") {
        "initialize" => {
            json!({"protocolVersion":"2025-06-18","capabilities":{"tools":{}},"serverInfo":{"name":"mock","version":"1"}})
        }
        "tools/list" => {
            if body["params"]["cursor"].is_string() {
                json!({"tools":[]})
            } else {
                json!({"tools":[{"name":"lookup","description":"Search forest","inputSchema":{"type":"object","properties":{"q":{"type":"string"}}}}],"nextCursor":"page2"})
            }
        }
        "tools/call" => {
            json!({"content":[{"type":"text","text":"forest result"},{"type":"image","data":"x"},{"type":"resource","resource":{"text":"resource text"}}],"isError":false})
        }
        _ => json!({}),
    };
    json!({"jsonrpc":"2.0","id":body["id"],"result":result})
}
async fn mcp_http(headers: HeaderMap, Json(body): Json<Value>) -> Response {
    assert_eq!(headers["mcp-protocol-version"], "2025-06-18");
    if body["method"] != "initialize" {
        assert_eq!(headers["mcp-session-id"], "mock-session");
    }
    if body.get("id").is_none() {
        return StatusCode::ACCEPTED.into_response();
    }
    let value = rpc(&body);
    if body["method"] == "tools/list" {
        let stream = stream::iter([
            Ok::<_, Infallible>(
                Event::default().data(json!({"jsonrpc":"2.0","method":"notice"}).to_string()),
            ),
            Ok(Event::default().data(value.to_string())),
        ]);
        return Sse::new(stream).into_response();
    }
    ([("Mcp-Session-Id", "mock-session")], Json(value)).into_response()
}
async fn legacy(State(state): State<Mock>) -> Response {
    let id = uuid::Uuid::new_v4().simple().to_string();
    let (tx, rx) = mpsc::unbounded_channel();
    tx.send(
        Event::default()
            .event("endpoint")
            .data(format!("/mcp/message?session={id}")),
    )
    .unwrap();
    state.legacy.lock().await.insert(id, tx);
    Sse::new(tokio_stream::wrappers::UnboundedReceiverStream::new(rx).map(Ok::<_, Infallible>))
        .into_response()
}
async fn legacy_post(
    State(state): State<Mock>,
    Query(q): Query<HashMap<String, String>>,
    Json(body): Json<Value>,
) -> Response {
    if body.get("id").is_some() {
        if let Some(tx) = state.legacy.lock().await.get(q.get("session").unwrap()) {
            let _ = tx.send(
                Event::default()
                    .event("message")
                    .data(rpc(&body).to_string()),
            );
        }
    }
    StatusCode::ACCEPTED.into_response()
}
