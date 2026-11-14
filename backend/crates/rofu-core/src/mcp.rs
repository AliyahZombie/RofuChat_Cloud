use crate::{
    jstool::sanitize,
    model::text,
    sse::{Decoder, Event},
};
use anyhow::{bail, Context, Result};
use futures_util::StreamExt;
use serde_json::{json, Value};
use std::{collections::HashSet, time::Duration};
use tokio::{sync::mpsc, task::JoinHandle};

pub struct Connection {
    client: reqwest::Client,
    config: Value,
    url: String,
    session: Option<String>,
    next_id: i64,
    events: Option<mpsc::UnboundedReceiver<Event>>,
    reader: Option<JoinHandle<()>>,
    pub tools: Vec<Value>,
}
impl Drop for Connection {
    fn drop(&mut self) {
        if let Some(task) = self.reader.take() {
            task.abort();
        }
    }
}
impl Connection {
    pub async fn connect(client: reqwest::Client, config: Value) -> Result<Self> {
        tokio::time::timeout(Duration::from_secs(20), Self::initialize(client, config)).await?
    }
    async fn initialize(client: reqwest::Client, config: Value) -> Result<Self> {
        let mut conn = Self {
            url: text(&config, "url"),
            client,
            config,
            session: None,
            next_id: 1,
            events: None,
            reader: None,
            tools: vec![],
        };
        if conn.config["transport"] == "sse" {
            let response = conn
                .headers(conn.client.get(&conn.url))
                .header("Accept", "text/event-stream")
                .send()
                .await?
                .error_for_status()?;
            let (tx, mut rx) = mpsc::unbounded_channel();
            conn.reader = Some(tokio::spawn(async move {
                let mut stream = response.bytes_stream();
                let mut decoder = Decoder::default();
                while let Some(Ok(chunk)) = stream.next().await {
                    for event in decoder.push(&chunk) {
                        if tx.send(event).is_err() {
                            return;
                        }
                    }
                }
            }));
            let endpoint = loop {
                let e = rx.recv().await.context("MCP SSE closed before endpoint")?;
                if e.event == "endpoint" {
                    break e.data;
                }
            };
            conn.url = url::Url::parse(&conn.url)?.join(&endpoint)?.to_string();
            conn.events = Some(rx);
        }
        conn.rpc("initialize",json!({"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"RofuChat","version":"0.1.0"}})).await?;
        conn.notify("notifications/initialized", json!({})).await?;
        let mut cursor = None;
        let mut seen = HashSet::new();
        loop {
            let params = cursor
                .as_ref()
                .map(|c| json!({"cursor":c}))
                .unwrap_or_else(|| json!({}));
            let list = conn.rpc("tools/list", params).await?;
            if let Some(tools) = list["tools"].as_array() {
                for tool in tools {
                    let raw = text(tool, "name");
                    conn.tools.push(json!({"name":sanitize(&format!("{}__{}",text(&conn.config,"name"),raw)),"raw_name":raw,"description":text(tool,"description"),"parameters":tool.get("inputSchema").cloned().unwrap_or_else(||json!({"type":"object","properties":{}}))}));
                }
            }
            cursor = list["nextCursor"].as_str().map(str::to_owned);
            if cursor.as_ref().is_none_or(|c| c.is_empty()) {
                break;
            }
            if !seen.insert(cursor.clone()) {
                bail!("MCP tools/list cursor loop");
            }
        }
        Ok(conn)
    }
    fn headers(&self, mut req: reqwest::RequestBuilder) -> reqwest::RequestBuilder {
        if let Some(headers) = self.config["headers"].as_object() {
            for (k, v) in headers {
                if let Some(v) = v.as_str() {
                    req = req.header(k, v);
                }
            }
        }
        req = req
            .header("Accept", "application/json, text/event-stream")
            .header("MCP-Protocol-Version", "2025-06-18");
        if let Some(session) = &self.session {
            req = req.header("Mcp-Session-Id", session);
        }
        req
    }
    async fn notify(&mut self, method: &str, params: Value) -> Result<()> {
        self.headers(self.client.post(&self.url))
            .json(&json!({"jsonrpc":"2.0","method":method,"params":params}))
            .send()
            .await?
            .error_for_status()?;
        Ok(())
    }
    async fn rpc(&mut self, method: &str, params: Value) -> Result<Value> {
        tokio::time::timeout(Duration::from_secs(60), self.rpc_inner(method, params)).await?
    }
    async fn rpc_inner(&mut self, method: &str, params: Value) -> Result<Value> {
        let id = self.next_id;
        self.next_id += 1;
        let response = self
            .headers(self.client.post(&self.url))
            .json(&json!({"jsonrpc":"2.0","id":id,"method":method,"params":params}))
            .send()
            .await?
            .error_for_status()?;
        if let Some(session) = response
            .headers()
            .get("Mcp-Session-Id")
            .and_then(|v| v.to_str().ok())
        {
            self.session = Some(session.into());
        }
        let value = if let Some(rx) = self.events.as_mut() {
            loop {
                let e = rx.recv().await.context("MCP SSE closed")?;
                let v: Value = match serde_json::from_str(&e.data) {
                    Ok(v) => v,
                    Err(_) => continue,
                };
                if v["id"] == id {
                    break v;
                }
            }
        } else if response
            .headers()
            .get("Content-Type")
            .and_then(|v| v.to_str().ok())
            .is_some_and(|s| s.contains("text/event-stream"))
        {
            let mut stream = response.bytes_stream();
            let mut decoder = Decoder::default();
            'read: loop {
                let chunk = stream
                    .next()
                    .await
                    .context("MCP stream ended before matching response")??;
                for e in decoder.push(&chunk) {
                    let v: Value = serde_json::from_str(&e.data)?;
                    if v["id"] == id {
                        break 'read v;
                    }
                }
            }
        } else {
            let v: Value = response.json().await?;
            if v["id"] != id {
                bail!("MCP response id mismatch");
            }
            v
        };
        if value.get("error").is_some() {
            bail!("MCP error: {}", value["error"]);
        }
        Ok(value["result"].clone())
    }
    pub async fn call(&mut self, name: &str, args: Value) -> Result<(String, bool)> {
        let result = self
            .rpc("tools/call", json!({"name":name,"arguments":args}))
            .await?;
        let content = result["content"]
            .as_array()
            .map(|items| {
                items
                    .iter()
                    .filter_map(|item| match item["type"].as_str().unwrap_or("") {
                        "text" => Some(text(item, "text")),
                        "image" => Some("[image]".into()),
                        "resource" => Some(text(&item["resource"], "text")),
                        _ => None,
                    })
                    .collect::<Vec<_>>()
                    .join("\n")
            })
            .unwrap_or_default();
        Ok((content, result["isError"] == true))
    }
}
