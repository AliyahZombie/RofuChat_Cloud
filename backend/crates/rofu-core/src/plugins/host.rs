use super::{runtime, storage, MAX_FOLLOW_UPS};
use crate::{
    api, chat, context, memory,
    model::{flag, id, now, number, text},
    server::AppState,
    swipes,
};
use anyhow::{anyhow, bail, ensure, Result};
use serde_json::{json, Value};
use std::{
    collections::{BTreeMap, HashMap, HashSet, VecDeque},
    sync::Arc,
    time::Duration,
};
use tokio::sync::{mpsc::UnboundedSender, oneshot, Mutex, Semaphore};
use tokio_util::sync::CancellationToken;

pub struct PendingDialog {
    pub uid: String,
    pub client_id: String,
    pub invocation_id: String,
    pub actions: Vec<String>,
    pub default_action: String,
    pub max_length: usize,
    pub reply: oneshot::Sender<Value>,
}
#[derive(Clone)]
pub struct PluginState {
    pub dialogs: Arc<Mutex<HashMap<String, PendingDialog>>>,
    locks: Arc<Mutex<HashMap<String, Arc<Mutex<()>>>>>,
    workers: Arc<Semaphore>,
}
impl Default for PluginState {
    fn default() -> Self {
        Self {
            dialogs: Default::default(),
            locks: Default::default(),
            workers: Arc::new(Semaphore::new(2)),
        }
    }
}
#[derive(Default)]
pub struct FollowUps {
    pub accepted: usize,
    pub queue: VecDeque<Value>,
}
#[derive(Clone)]
pub struct Operation {
    pub tx: UnboundedSender<Value>,
    pub cancel: CancellationToken,
    pub protocol: bool,
    pub client_id: String,
    pub capabilities: Vec<String>,
    pub root_turn_id: String,
    pub round: usize,
    pub follow_ups: Arc<Mutex<FollowUps>>,
}
impl Operation {
    pub fn new(tx: UnboundedSender<Value>, cancel: CancellationToken, body: &Value) -> Self {
        Self {
            tx,
            cancel,
            protocol: body["plugin_protocol"] == 1,
            client_id: text(body, "client_id"),
            capabilities: body["ui_capabilities"]
                .as_array()
                .map(|a| {
                    a.iter()
                        .filter_map(|v| v.as_str().map(str::to_owned))
                        .collect()
                })
                .unwrap_or_default(),
            root_turn_id: id(),
            round: 0,
            follow_ups: Default::default(),
        }
    }
    pub fn emit(&self, value: Value) {
        if self.protocol {
            let _ = self.tx.send(value);
        }
    }
}
#[derive(Clone)]
pub struct Session {
    pub state: AppState,
    pub uid: String,
    pub plugin: Value,
    pub conversation: Value,
    pub character: Value,
    pub invocation: Value,
    pub phase: String,
    pub operation: Operation,
    pub messages: Vec<Value>,
    pub original_messages: Vec<Value>,
    pub memories: Vec<Value>,
    pub original_memories: Vec<Value>,
    pub globals: Vec<Value>,
    pub kv: Vec<storage::Change>,
    pub sends: Vec<Value>,
    pub deadline: std::time::Instant,
    pub attachments: Vec<crate::attachments::PreparedAttachment>,
}
impl Session {
    pub async fn new(
        s: &AppState,
        uid: &str,
        cid: &str,
        plugin: Value,
        phase: &str,
        operation: Operation,
    ) -> Result<Self> {
        let conversation =
            s.db.conversation(uid, cid)
                .await?
                .ok_or_else(|| anyhow!("E_NOT_FOUND: conversation"))?;
        let character =
            s.db.get(uid, "character", &text(&conversation, "character_id"))
                .await?
                .ok_or_else(|| anyhow!("E_NOT_FOUND: character"))?;
        let mut messages = s.db.messages(uid, cid).await?;
        for message in &mut messages {
            message["user_id"] = json!(uid);
        }
        let available = memory::available(s, uid, &character)
            .await
            .map_err(|e| anyhow!(e.message))?;
        let memories =
            s.db.list(uid, "memory")
                .await?
                .into_iter()
                .filter(|m| m["character_id"] == character["id"])
                .collect::<Vec<_>>();
        let globals = available
            .into_iter()
            .filter(|m| m["character_id"] != character["id"])
            .collect();
        let invocation = json!({"id":id(),"conversation_id":cid,"character_id":character["id"],"plugin_id":plugin["id"],"source":if phase=="menu" {"menu"} else if operation.round==0 {"user"} else {"plugin"},"phase":phase,"root_turn_id":operation.root_turn_id,"round":operation.round});
        Ok(Self {
            state: s.clone(),
            uid: uid.into(),
            plugin,
            conversation,
            character,
            invocation,
            phase: phase.into(),
            operation,
            original_messages: messages.clone(),
            messages,
            original_memories: memories.clone(),
            memories,
            globals,
            kv: vec![],
            sends: vec![],
            attachments: vec![],
            deadline: std::time::Instant::now()
                + if phase == "tool" || phase == "menu" {
                    super::INVOCATION_TIMEOUT
                } else {
                    super::HOOK_TIMEOUT
                },
        })
    }
    fn permit(&self, group: &str) -> Result<()> {
        ensure!(
            flag(&self.plugin, "enabled", false),
            "E_PERMISSION: plugin disabled"
        );
        ensure!(
            self.plugin["granted_permissions"]
                .as_array()
                .is_some_and(|a| a.iter().any(|p| p == group || p["name"] == group)),
            "E_PERMISSION: {group} permission required"
        );
        Ok(())
    }
    fn message_index(&self, mid: &Value) -> Result<usize> {
        self.messages
            .iter()
            .position(|m| m["id"] == *mid)
            .ok_or_else(|| anyhow!("E_NOT_FOUND: message"))
    }
    async fn kv_entries(&self, table: &str) -> Result<BTreeMap<String, Value>> {
        storage::validate(table, "_", None)?;
        let mut values =
            storage::entries(&self.state.db, &self.uid, &text(&self.plugin, "id"), table)
                .await?
                .into_iter()
                .collect::<BTreeMap<_, _>>();
        for c in self.kv.iter().filter(|c| c.table == table) {
            if let Some(v) = &c.value {
                values.insert(c.key.clone(), v.clone());
            } else {
                values.remove(&c.key);
            }
        }
        Ok(values)
    }
    pub async fn command(&mut self, method: &str, a: &Value) -> Result<Value> {
        ensure!(
            !self.operation.cancel.is_cancelled(),
            "E_CANCELLED: operation cancelled"
        );
        let current = self
            .state
            .db
            .get(&self.uid, "plugin", &text(&self.plugin, "id"))
            .await?;
        ensure!(
            current.as_ref().is_some_and(|p| flag(p, "enabled", false)
                && p["granted_permissions"] == self.plugin["granted_permissions"]),
            "E_PERMISSION: plugin revoked"
        );
        let group = match method {
            "conversation.get" | "character.get" | "context.get" | "memory.list"
            | "messages.list" | "messages.get" | "swipes.list" => "read",
            "memory.add" | "memory.update" | "memory.remove" | "messages.update"
            | "messages.insert" | "swipes.append" | "swipes.select" | "swipes.remove" => "write",
            "kv.get" | "kv.set" | "kv.delete" | "kv.list" => "storage",
            "chat.send" => "send",
            "ui.toast" | "ui.notify" | "ui.dialog" => "ui",
            "http.request" => "network",
            _ => bail!("E_VALIDATION: unknown host method"),
        };
        self.permit(group)?;
        let output = match method {
            "conversation.get" => {
                json!({"id":self.conversation["id"],"character_id":self.character["id"],"title":self.conversation["title"]})
            }
            "character.get" => {
                json!({"id":self.character["id"],"name":self.character["name"],"card":self.character["card"],"context":self.character["context"],"memory":self.character["memory"],"params":self.character["params"]})
            }
            "context.get" => {
                let settings = api::settings(&self.state, &self.uid)
                    .await
                    .map_err(|e| anyhow!(e.message))?;
                let (model, _) = chat::resolve(&self.state, &self.uid, &self.character, false)
                    .await
                    .map_err(|e| anyhow!(e.message))?;
                let mut memories = self.globals.clone();
                memories.extend(self.memories.clone());
                let messages = context::build(
                    &self.character,
                    &settings,
                    &self.messages,
                    &memories,
                    flag(&model, "vision", false),
                );
                let tools =
                    chat::tool_definitions(&self.state, &self.uid, &self.character, &model).await?;
                json!({"tokens":context::estimate(&messages,&tools),"max":number(&model,"context_length",32768),"estimated":true,"messages":messages,"tools":tools})
            }
            "messages.list" => page(&self.messages, &a[0], true)?,
            "messages.get" => self.messages[self.message_index(&a[0])?].clone(),
            "messages.update" => {
                let i = self.message_index(&a[0])?;
                let patch = &a[1];
                ensure!(patch.is_object(), "E_VALIDATION: patch must be object");
                let old = self.messages[i].clone();
                let mut edited = old.clone();
                // Selecting a version supplies defaults; explicit fields in this patch
                // still take precedence, including provenance and actual status.
                if patch.get("swipe_index").is_some() || patch.get("swipes").is_some() {
                    for key in ["swipes", "swipe_index"] {
                        if let Some(v) = patch.get(key) {
                            edited[key] = v.clone();
                        }
                    }
                    validate_swipes(&edited, &self.uid, &text(&self.conversation, "id"))?;
                    if edited.get("swipes").is_some() {
                        let index = swipes::index(&edited);
                        swipes::activate(&mut edited, index);
                    }
                }
                for (k, v) in patch.as_object().unwrap() {
                    if matches!(k.as_str(), "id" | "user_id" | "conversation_id") {
                        ensure!(old.get(k) == Some(v), "E_VALIDATION: {k} is immutable");
                    } else {
                        edited[k] = v.clone();
                    }
                }
                ensure!(
                    edited["parts"].is_object(),
                    "E_VALIDATION: parts must be object"
                );
                if let Some(display) = patch.get("display") {
                    ensure!(display.is_string(), "E_VALIDATION: display must be string");
                    edited["content"] = display.clone();
                    edited.as_object_mut().unwrap().remove("display");
                }
                for field in ["images", "segments"] {
                    if let Some(v) = patch.get(field) {
                        edited["parts"][field] = v.clone();
                        edited.as_object_mut().unwrap().remove(field);
                    }
                }
                validate_content(&edited)?;
                if (patch.get("content").is_some() || patch.get("display").is_some())
                    && patch.get("segments").is_none()
                    && patch.get("parts").and_then(|p| p.get("segments")).is_none()
                {
                    swipes::edit_text(&mut edited);
                }
                if patch.get("actual").is_some() {
                    if patch.get("actual_status").is_none() {
                        edited["actual_status"] = json!(if edited["actual"].is_null() {
                            "none"
                        } else {
                            "ok"
                        });
                    }
                    if patch.get("actual_error").is_none() {
                        edited["actual_error"] = Value::Null;
                    }
                }
                if patch.get("swipes").is_none() {
                    swipes::sync(&mut edited);
                }
                self.messages[i] = edited;
                if let Err(e) =
                    validate_shape(&self.messages, &self.uid, &text(&self.conversation, "id"))
                {
                    self.messages[i] = old;
                    return Err(e);
                }
                self.messages.sort_by_key(|m| number(m, "seq", 0));
                self.messages[self.message_index(&a[0])?].clone()
            }
            "messages.insert" => {
                let input = &a[0];
                ensure!(
                    input.is_object() && input["content"].is_string(),
                    "E_VALIDATION: insert requires role and content"
                );
                let role = text(input, "role");
                ensure!(
                    matches!(role.as_str(), "user" | "assistant" | "system" | "tool"),
                    "E_VALIDATION: invalid insert role"
                );
                let after = if input.get("after_seq").is_some() {
                    input["after_seq"]
                        .as_i64()
                        .ok_or_else(|| anyhow!("E_VALIDATION: after_seq must be integer"))?
                } else {
                    self.messages
                        .iter()
                        .map(|m| number(m, "seq", 0))
                        .max()
                        .unwrap_or(0)
                };
                let seq = after
                    .checked_add(1)
                    .ok_or_else(|| anyhow!("E_VALIDATION: seq overflow"))?;
                let mut rows = self.messages.clone();
                if rows.iter().any(|m| m["seq"] == seq) {
                    for m in rows.iter_mut().filter(|m| number(m, "seq", 0) >= seq) {
                        m["seq"] = json!(number(m, "seq", 0)
                            .checked_add(1)
                            .ok_or_else(|| anyhow!("E_VALIDATION: seq overflow"))?);
                    }
                }
                let mut m = chat::message(
                    &text(&self.conversation, "id"),
                    seq,
                    &role,
                    &text(input, "content"),
                );
                m["user_id"] = json!(self.uid);
                for key in ["call_id", "name"] {
                    if let Some(v) = input.get(key) {
                        m[key] = v.clone();
                    }
                }
                for key in ["actual", "visible"] {
                    if let Some(v) = input.get(key) {
                        m[key] = v.clone();
                    }
                }
                if m["actual"].is_string() {
                    m["actual_status"] = json!("ok");
                }
                if let Some(images) = input.get("images") {
                    m["parts"]["images"] = images.clone();
                }
                rows.push(m.clone());
                rows.sort_by_key(|m| number(m, "seq", 0));
                validate_shape(&rows, &self.uid, &text(&self.conversation, "id"))?;
                self.messages = rows;
                m
            }
            "swipes.list" => {
                let mut m = self.messages[self.message_index(&a[0])?].clone();
                swipes::ensure(&mut m);
                swipes::sync(&mut m);
                json!({"items":m["swipes"],"next_cursor":null})
            }
            "swipes.append" | "swipes.select" | "swipes.remove" => self.change_swipe(method, a)?,
            "memory.list" | "memory.add" | "memory.update" | "memory.remove" => {
                self.memory_command(method, a)?
            }
            "kv.get" | "kv.set" | "kv.delete" | "kv.list" => {
                let table = a[0]
                    .as_str()
                    .ok_or_else(|| anyhow!("E_VALIDATION: table must be string"))?;
                let values = self.kv_entries(table).await?;
                if method == "kv.list" {
                    let opts = &a[1];
                    let prefix = text(opts, "prefix");
                    let cursor = text(opts, "cursor");
                    let limit = limit(opts)?;
                    let mut items = values
                        .into_iter()
                        .filter(|(k, _)| k.starts_with(&prefix) && k > &cursor)
                        .map(|(key, value)| json!({"key":key,"value":value}))
                        .take(limit + 1)
                        .collect::<Vec<_>>();
                    let next = if items.len() > limit {
                        items.pop();
                        items
                            .last()
                            .map(|v| v["key"].clone())
                            .unwrap_or(Value::Null)
                    } else {
                        Value::Null
                    };
                    json!({"items":items,"next_cursor":next})
                } else {
                    let key = a[1]
                        .as_str()
                        .ok_or_else(|| anyhow!("E_VALIDATION: key must be string"))?;
                    storage::validate(
                        table,
                        key,
                        if method == "kv.set" {
                            Some(&a[2])
                        } else {
                            None
                        },
                    )?;
                    match method {
                        "kv.get" => {
                            json!({"found":values.contains_key(key),"value":values.get(key)})
                        }
                        "kv.set" => {
                            self.kv.push(storage::Change {
                                table: table.into(),
                                key: key.into(),
                                value: Some(a[2].clone()),
                            });
                            Value::Null
                        }
                        _ => {
                            let existed = values.contains_key(key);
                            self.kv.push(storage::Change {
                                table: table.into(),
                                key: key.into(),
                                value: None,
                            });
                            json!(existed)
                        }
                    }
                }
            }
            "http.request" => self.http(&a[0]).await?,
            "chat.send" => {
                ensure!(
                    matches!(self.phase.as_str(), "afterReply" | "menu"),
                    "E_PHASE: send is allowed only in afterReply and menus"
                );
                ensure!(a[0].is_string(), "E_VALIDATION: content must be string");
                ensure!(
                    !a[0].as_str().unwrap().trim().is_empty()
                        || a[1]["images"].as_array().is_some_and(|a| !a.is_empty()),
                    "E_VALIDATION: content or images required"
                );
                ensure!(
                    self.sends.is_empty()
                        && self.operation.follow_ups.lock().await.accepted < MAX_FOLLOW_UPS,
                    "E_LIMIT: follow-up send limit reached"
                );
                let queued_id = id();
                let send = json!({"content":a[0],"images":a[1].get("images").cloned().unwrap_or_else(||json!([])),"queued_id":queued_id});
                let mut checked = send.clone();
                self.state
                    .db
                    .stage_images(&self.uid, &mut checked, &mut vec![])
                    .await?;
                self.sends.push(send);
                json!({"queued_id":queued_id})
            }
            "ui.toast" | "ui.notify" | "ui.dialog" => self.ui(method, a).await?,
            _ => unreachable!(),
        };
        ensure!(
            output.to_string().len() <= 1024 * 1024,
            "E_LIMIT: host response exceeds 1 MiB; use pagination"
        );
        Ok(output)
    }
    fn memory_command(&mut self, method: &str, a: &Value) -> Result<Value> {
        ensure!(
            flag(&self.character["memory"], "enabled", true),
            "E_PHASE: character memory disabled"
        );
        if method == "memory.list" {
            let q = text(&a[0], "q");
            let values = if q.is_empty() {
                self.memories.clone()
            } else {
                memory::search(self.memories.clone(), &q, usize::MAX)
            };
            return page(&values, &a[0], false);
        }
        if method == "memory.add" {
            ensure!(
                a[0]["content"].is_string(),
                "E_VALIDATION: memory content must be string"
            );
            let mut m = crate::model::normalized("memory", &a[0]);
            m["id"] = json!(id()[..12]);
            m["character_id"] = self.character["id"].clone();
            m["source"] = json!("plugin");
            m["created_at"] = json!(now());
            m["updated_at"] = json!(now());
            validate_memory(&m)?;
            self.memories.push(m.clone());
            return Ok(m);
        }
        let i = self
            .memories
            .iter()
            .position(|m| m["id"] == a[0])
            .ok_or_else(|| anyhow!("E_NOT_FOUND: memory"))?;
        if method == "memory.remove" {
            self.memories.remove(i);
            return Ok(Value::Null);
        }
        let mut m = self.memories[i].clone();
        ensure!(
            a[1].is_object(),
            "E_VALIDATION: memory patch must be object"
        );
        for key in ["content", "tags", "pinned"] {
            if let Some(v) = a[1].get(key) {
                m[key] = v.clone();
            }
        }
        m["updated_at"] = json!(now());
        validate_memory(&m)?;
        self.memories[i] = m.clone();
        Ok(m)
    }
    fn change_swipe(&mut self, method: &str, a: &Value) -> Result<Value> {
        let i = self.message_index(&a[0])?;
        let mut m = self.messages[i].clone();
        let mut rows = self.messages.clone();
        swipes::ensure(&mut m);
        swipes::sync(&mut m);
        let current = swipes::index(&m);
        let mut next = current;
        let switching = if method == "swipes.append" {
            a[2]["activate"] != false
        } else {
            let requested = a[1]
                .as_u64()
                .ok_or_else(|| anyhow!("E_VALIDATION: swipe index must be unsigned integer"))?
                as usize;
            ensure!(
                requested < swipes::count(&m),
                "E_VALIDATION: swipe index out of range"
            );
            if method == "swipes.remove" {
                ensure!(
                    swipes::count(&m) > 1,
                    "E_VALIDATION: cannot remove only swipe"
                );
                next = if requested < current {
                    current - 1
                } else {
                    current.min(swipes::count(&m) - 2)
                };
                requested == current
            } else {
                next = requested;
                next != current
            }
        };
        if switching && m["role"] == "user" {
            let seq = number(&m, "seq", 0);
            m["swipes"][current]["tail"] = json!(rows
                .iter()
                .filter(|r| number(r, "seq", 0) > seq)
                .cloned()
                .collect::<Vec<_>>());
            rows.retain(|r| number(r, "seq", 0) <= seq);
        }
        if method == "swipes.append" {
            ensure!(
                a[1].is_object() && a[1]["content"].is_string(),
                "E_VALIDATION: swipe input requires content"
            );
            let mut fresh = chat::message(
                &text(&self.conversation, "id"),
                number(&m, "seq", 0),
                &text(&m, "role"),
                &text(&a[1], "content"),
            );
            for (k, v) in a[1].as_object().unwrap() {
                if !matches!(k.as_str(), "id" | "user_id" | "conversation_id") {
                    fresh[k] = v.clone();
                }
            }
            if let Some(v) = a[1].get("images") {
                fresh["parts"]["images"] = v.clone();
                fresh.as_object_mut().unwrap().remove("images");
            }
            m["swipes"]
                .as_array_mut()
                .unwrap()
                .push(swipes::snapshot(&fresh));
            if switching {
                next = swipes::count(&m) - 1;
            }
        } else if method == "swipes.remove" {
            m["swipes"]
                .as_array_mut()
                .unwrap()
                .remove(a[1].as_u64().unwrap() as usize);
        }
        swipes::activate(&mut m, next);
        if switching && m["role"] == "user" {
            let tail = m["swipes"][next]["tail"]
                .as_array()
                .cloned()
                .unwrap_or_default();
            rows.extend(tail);
            m["swipes"][next]["tail"] = json!([]);
        }
        let row = rows
            .iter_mut()
            .find(|r| r["id"] == m["id"])
            .ok_or_else(|| anyhow!("E_VALIDATION: missing active message"))?;
        *row = m.clone();
        rows.sort_by_key(|m| number(m, "seq", 0));
        validate_shape(&rows, &self.uid, &text(&self.conversation, "id"))?;
        self.messages = rows;
        if method == "swipes.append" {
            Ok(m)
        } else {
            Ok(json!({"messages":self.messages}))
        }
    }
    async fn http(&self, opts: &Value) -> Result<Value> {
        let url = url::Url::parse(&text(opts, "url")).map_err(|e| anyhow!("E_VALIDATION: {e}"))?;
        self.check_origin(&url)?;
        let origins = self.plugin["granted_permissions"]
            .as_array()
            .unwrap()
            .iter()
            .find(|p| p["name"] == "network")
            .map(|p| p["origins"].clone())
            .unwrap_or_else(|| json!([]));
        // Validate every redirect against the same optional allowlist.
        let mut client_builder = reqwest::Client::builder();
        if url.host_str().is_some_and(|host| {
            host.eq_ignore_ascii_case("localhost")
                || host
                    .parse::<std::net::IpAddr>()
                    .is_ok_and(|ip| ip.is_loopback())
        }) {
            client_builder = client_builder.no_proxy();
        }
        let client = client_builder
            .redirect(reqwest::redirect::Policy::custom(move |attempt| {
                if attempt.previous().len() >= 10 {
                    return attempt.error("too many redirects");
                }
                if !matches!(attempt.url().scheme(), "http" | "https") {
                    return attempt.error("invalid redirect scheme");
                }
                if origins.as_array().is_some_and(|a| {
                    !a.is_empty()
                        && !a.iter().any(|v| {
                            v.as_str() == Some(&attempt.url().origin().ascii_serialization())
                        })
                }) {
                    return attempt.error("E_PERMISSION: redirect origin not granted");
                }
                attempt.follow()
            }))
            .build()?;
        let method = opts["method"].as_str().unwrap_or("GET");
        ensure!(
            matches!(method, "GET" | "POST" | "PUT" | "PATCH" | "DELETE" | "HEAD"),
            "E_VALIDATION: unsupported HTTP method"
        );
        let timeout = opts["timeout_ms"]
            .as_u64()
            .unwrap_or(10_000)
            .clamp(1, 30_000);
        let mut req = client
            .request(reqwest::Method::from_bytes(method.as_bytes())?, url)
            .timeout(Duration::from_millis(timeout));
        if let Some(headers) = opts["headers"].as_object() {
            for (k, v) in headers {
                req = req.header(
                    k,
                    v.as_str()
                        .ok_or_else(|| anyhow!("E_VALIDATION: header must be string"))?,
                );
            }
        }
        if let Some(body) = opts.get("body") {
            req = req.body(
                body.as_str()
                    .ok_or_else(|| anyhow!("E_VALIDATION: body must be string"))?
                    .to_owned(),
            );
        }
        let mut response = req.send().await?;
        let status = response.status().as_u16();
        let headers = response
            .headers()
            .iter()
            .filter_map(|(k, v)| v.to_str().ok().map(|s| (k.to_string(), json!(s))))
            .collect::<serde_json::Map<_, _>>();
        let mut bytes = vec![];
        while let Some(chunk) = response.chunk().await? {
            ensure!(
                bytes.len() + chunk.len() <= 1024 * 1024,
                "E_LIMIT: HTTP response exceeds 1 MiB"
            );
            bytes.extend(chunk);
        }
        Ok(json!({"status":status,"headers":headers,"body":String::from_utf8_lossy(&bytes)}))
    }
    fn check_origin(&self, url: &url::Url) -> Result<()> {
        ensure!(
            matches!(url.scheme(), "http" | "https"),
            "E_VALIDATION: only HTTP(S) URLs allowed"
        );
        for p in self.plugin["granted_permissions"].as_array().unwrap() {
            if p == "network" {
                return Ok(());
            }
            if p["name"] == "network" {
                let origins = p["origins"]
                    .as_array()
                    .ok_or_else(|| anyhow!("E_PERMISSION: invalid network grant"))?;
                ensure!(
                    origins.is_empty()
                        || origins
                            .iter()
                            .any(|v| v.as_str() == Some(&url.origin().ascii_serialization())),
                    "E_PERMISSION: origin not granted"
                );
                return Ok(());
            }
        }
        bail!("E_PERMISSION: network permission required")
    }
    async fn ui(&self, method: &str, a: &Value) -> Result<Value> {
        let kind = method.strip_prefix("ui.").unwrap();
        let delivered = self.operation.protocol
            && !self.operation.client_id.is_empty()
            && self.operation.capabilities.iter().any(|c| c == kind)
            && !self.operation.tx.is_closed();
        let payload = if kind == "toast" {
            ensure!(
                a[0].is_string(),
                "E_VALIDATION: toast message must be string"
            );
            json!({"message":a[0],"duration_ms":a[1]["duration_ms"].as_u64().unwrap_or(3000)})
        } else {
            ensure!(
                a[0].is_object() && a[0]["title"].is_string(),
                "E_VALIDATION: UI payload requires title"
            );
            a[0].clone()
        };
        let call_id = id();
        let mut receiver = None;
        let mut default = String::new();
        let mut timeout = 5000;
        if kind == "dialog" {
            default = text(&payload, "default_action");
            let actions = payload["actions"]
                .as_array()
                .ok_or_else(|| anyhow!("E_VALIDATION: dialog requires actions"))?;
            let ids = actions.iter().map(|v| text(v, "id")).collect::<Vec<_>>();
            ensure!(
                !ids.is_empty()
                    && ids.contains(&default)
                    && ids.iter().all(|s| !s.is_empty())
                    && ids.iter().collect::<HashSet<_>>().len() == ids.len()
                    && actions.iter().all(|v| v["label"].is_string()),
                "E_VALIDATION: dialog requires unique actions and valid default_action"
            );
            timeout = payload["timeout_ms"].as_u64().unwrap_or(5000);
            ensure!(
                timeout > 0 && timeout <= 30_000,
                "E_VALIDATION: dialog timeout must be 1..30000 ms"
            );
            timeout = timeout.min(
                self.deadline
                    .saturating_duration_since(std::time::Instant::now())
                    .as_millis()
                    .saturating_sub(50)
                    .max(1) as u64,
            );
            if !delivered {
                return Ok(json!({"action":default,"input":null,"reason":"unavailable"}));
            }
            let (tx, rx) = oneshot::channel();
            receiver = Some(rx);
            self.state.plugins.dialogs.lock().await.insert(
                call_id.clone(),
                PendingDialog {
                    uid: self.uid.clone(),
                    client_id: self.operation.client_id.clone(),
                    invocation_id: text(&self.invocation, "id"),
                    actions: ids,
                    default_action: default.clone(),
                    max_length: payload["input"]["max_length"]
                        .as_u64()
                        .unwrap_or(4096)
                        .min(65536) as usize,
                    reply: tx,
                },
            );
        }
        if delivered {
            self.operation.emit(json!({"type":"plugin_ui","plugin_id":self.plugin["id"],"invocation_id":self.invocation["id"],"call_id":call_id,"client_id":self.operation.client_id,"kind":kind,"payload":payload}));
        }
        if let Some(rx) = receiver {
            let response = tokio::select! {
                _=self.operation.cancel.cancelled()=>Err(anyhow!("E_CANCELLED: dialog cancelled")),
                result=tokio::time::timeout(Duration::from_millis(timeout),rx)=>Ok(match result{Ok(Ok(v))=>v,_=>json!({"action":default,"input":null,"reason":"timeout"})}),
                _=self.operation.tx.closed()=>Ok(json!({"action":default,"input":null,"reason":"unavailable"})),
            };
            self.state.plugins.dialogs.lock().await.remove(&call_id);
            response
        } else {
            Ok(json!({"delivered":delivered}))
        }
    }
    pub async fn commit(&mut self) -> Result<()> {
        ensure!(
            !self.operation.cancel.is_cancelled(),
            "E_CANCELLED: operation cancelled"
        );
        let current = self
            .state
            .db
            .get(&self.uid, "plugin", &text(&self.plugin, "id"))
            .await?;
        ensure!(
            current.as_ref().is_some_and(|p| flag(p, "enabled", false)
                && p["granted_permissions"] == self.plugin["granted_permissions"]),
            "E_PERMISSION: plugin revoked"
        );
        self.stage_images()
            .await
            .map_err(|e| anyhow!("E_VALIDATION: {e}"))?;
        validate_messages(&self.messages, &self.uid, &text(&self.conversation, "id"))?;
        let mut tx = self.state.db.pool.begin().await?;
        self.commit_into(&mut tx).await?;
        tx.commit().await?;
        self.finish_commit().await;
        Ok(())
    }
    pub async fn stage_images(&mut self) -> Result<()> {
        for message in &mut self.messages {
            self.state
                .db
                .stage_images(&self.uid, message, &mut self.attachments)
                .await?;
        }
        for send in &mut self.sends {
            self.state
                .db
                .stage_images(&self.uid, send, &mut self.attachments)
                .await?;
        }
        Ok(())
    }
    pub async fn commit_into(&self, tx: &mut sqlx::Transaction<'_, sqlx::Any>) -> Result<()> {
        sqlx::query("UPDATE entities SET updated_at=updated_at WHERE user_id=$1 AND kind='plugin' AND id=$2").bind(&self.uid).bind(text(&self.plugin,"id")).execute(&mut **tx).await?;
        let raw: Option<String> = sqlx::query_scalar(
            "SELECT data FROM entities WHERE user_id=$1 AND kind='plugin' AND id=$2",
        )
        .bind(&self.uid)
        .bind(text(&self.plugin, "id"))
        .fetch_optional(&mut **tx)
        .await?;
        let current: Value = serde_json::from_str(raw.as_deref().unwrap_or("null"))?;
        ensure!(
            flag(&current, "enabled", false)
                && current["granted_permissions"] == self.plugin["granted_permissions"],
            "E_PERMISSION: plugin revoked"
        );
        crate::attachments::store_prepared(tx, &self.uid, &self.attachments).await?;
        if !self.kv.is_empty() {
            storage::apply(tx, &self.uid, &text(&self.plugin, "id"), &self.kv).await?;
        }
        if self.messages != self.original_messages {
            let cid = text(&self.conversation, "id");
            for old in &self.original_messages {
                if !self.messages.iter().any(|m| m["id"] == old["id"]) {
                    sqlx::query(
                        "DELETE FROM messages WHERE user_id=$1 AND conversation_id=$2 AND id=$3",
                    )
                    .bind(&self.uid)
                    .bind(&cid)
                    .bind(text(old, "id"))
                    .execute(&mut **tx)
                    .await?;
                }
            }
            for m in &self.messages {
                if self.original_messages.iter().any(|o| o == m) {
                    continue;
                }
                // Never upsert a plugin-controlled ID: identity is immutable and inserts use server IDs.
                if self.original_messages.iter().any(|o| o["id"] == m["id"]) {
                    sqlx::query("UPDATE messages SET seq=$4,data=$5 WHERE user_id=$1 AND conversation_id=$2 AND id=$3").bind(&self.uid).bind(&cid).bind(text(m,"id")).bind(number(m,"seq",0)).bind(m.to_string()).execute(&mut **tx).await?;
                } else {
                    sqlx::query("INSERT INTO messages(id,user_id,conversation_id,seq,data) VALUES ($1,$2,$3,$4,$5)").bind(text(m,"id")).bind(&self.uid).bind(&cid).bind(number(m,"seq",0)).bind(m.to_string()).execute(&mut **tx).await?;
                }
            }
        }
        if self.messages != self.original_messages || self.memories != self.original_memories {
            let raw: Option<String> =
                sqlx::query_scalar("SELECT data FROM conversations WHERE user_id=$1 AND id=$2")
                    .bind(&self.uid)
                    .bind(text(&self.conversation, "id"))
                    .fetch_optional(&mut **tx)
                    .await?;
            let mut conversation: Value = serde_json::from_str(
                raw.as_deref()
                    .ok_or_else(|| anyhow!("E_NOT_FOUND: conversation"))?,
            )?;
            conversation["plugin_context_edited"] = json!(true);
            sqlx::query("UPDATE conversations SET data=$3 WHERE user_id=$1 AND id=$2")
                .bind(&self.uid)
                .bind(text(&self.conversation, "id"))
                .bind(conversation.to_string())
                .execute(&mut **tx)
                .await?;
        }
        for old in &self.original_memories {
            if !self.memories.iter().any(|m| m["id"] == old["id"]) {
                let changed = sqlx::query(
                    "DELETE FROM entities WHERE user_id=$1 AND kind='memory' AND id=$2 AND data=$3",
                )
                .bind(&self.uid)
                .bind(text(old, "id"))
                .bind(old.to_string())
                .execute(&mut **tx)
                .await?
                .rows_affected();
                ensure!(changed == 1, "E_CONFLICT: memory changed");
            }
        }
        for m in &self.memories {
            if self.original_memories.iter().any(|o| o == m) {
                continue;
            }
            if let Some(old) = self.original_memories.iter().find(|o| o["id"] == m["id"]) {
                let changed=sqlx::query("UPDATE entities SET data=$4,updated_at=$5 WHERE user_id=$1 AND kind='memory' AND id=$2 AND data=$3").bind(&self.uid).bind(text(m,"id")).bind(old.to_string()).bind(m.to_string()).bind(now()).execute(&mut **tx).await?.rows_affected();
                ensure!(changed == 1, "E_CONFLICT: memory changed");
            } else {
                sqlx::query("INSERT INTO entities(id,user_id,kind,parent_id,data,created_at,updated_at) VALUES ($1,$2,'memory',$3,$4,$5,$6)").bind(text(m,"id")).bind(&self.uid).bind(text(&self.character,"id")).bind(m.to_string()).bind(number(m,"created_at",now())).bind(now()).execute(&mut **tx).await?;
            }
        }
        Ok(())
    }
    pub async fn finish_commit(&self) {
        if self.messages != self.original_messages {
            self.operation.emit(json!({"type":"plugin_messages_changed","plugin_id":self.plugin["id"],"conversation_id":self.conversation["id"],"message_ids":self.messages.iter().filter(|m|!self.original_messages.contains(m)).map(|m|m["id"].clone()).collect::<Vec<_>>(),"reload":true}));
        }
        let mut follow = self.operation.follow_ups.lock().await;
        for send in &self.sends {
            if follow.accepted < MAX_FOLLOW_UPS {
                follow.accepted += 1;
                follow.queue.push_back(send.clone());
            }
        }
    }
}
fn validate_memory(m: &Value) -> Result<()> {
    ensure!(
        m["content"].is_string()
            && m["pinned"].is_boolean()
            && m["tags"]
                .as_array()
                .is_some_and(|a| a.iter().all(Value::is_string)),
        "E_VALIDATION: invalid memory shape"
    );
    Ok(())
}
fn limit(opts: &Value) -> Result<usize> {
    let n = opts["limit"].as_u64().unwrap_or(50);
    ensure!(n > 0 && n <= 100, "E_VALIDATION: limit must be 1..100");
    Ok(n as usize)
}
fn page(rows: &[Value], opts: &Value, messages: bool) -> Result<Value> {
    let limit = limit(opts)?;
    let cursor = text(opts, "cursor");
    let mut values = rows
        .iter()
        .filter(|m| !messages || opts["include_hidden"] != false || flag(m, "visible", true));
    if !cursor.is_empty() {
        ensure!(
            rows.iter().any(|m| m["id"] == cursor),
            "E_VALIDATION: invalid cursor"
        );
        for m in values.by_ref() {
            if m["id"] == cursor {
                break;
            }
        }
    }
    let mut items = values.take(limit + 1).cloned().collect::<Vec<_>>();
    let next = if items.len() > limit {
        items.pop();
        items.last().map(|m| m["id"].clone()).unwrap_or(Value::Null)
    } else {
        Value::Null
    };
    Ok(json!({"items":items,"next_cursor":next}))
}
pub fn validate_messages(rows: &[Value], uid: &str, cid: &str) -> Result<()> {
    validate_shape(rows, uid, cid)?;
    let mut pending = HashSet::new();
    let mut seen = HashSet::new();
    for m in rows {
        if let Some(calls) = m["tool_calls"].as_array() {
            ensure!(
                m["role"] == "assistant",
                "E_VALIDATION: tool_calls requires assistant role"
            );
            for c in calls {
                let call = text(c, "id");
                ensure!(
                    !call.is_empty() && seen.insert(call.clone()),
                    "E_VALIDATION: duplicate or empty tool call ID"
                );
                pending.insert(call);
            }
        }
        if m["role"] == "tool" {
            let call = text(m, "call_id");
            ensure!(pending.remove(&call), "E_VALIDATION: unpaired tool result");
        }
        if let Some(segments) = m["parts"]["segments"].as_array() {
            for seg in segments.iter().filter(|s| s["type"] == "tool") {
                ensure!(
                    seen.insert(text(seg, "id")),
                    "E_VALIDATION: duplicate tool call ID"
                );
            }
        }
    }
    ensure!(pending.is_empty(), "E_VALIDATION: unpaired tool call");
    Ok(())
}
fn validate_shape(rows: &[Value], uid: &str, cid: &str) -> Result<()> {
    let mut ids = HashSet::new();
    let mut seqs = HashSet::new();
    for m in rows {
        ensure!(
            m.is_object()
                && !text(m, "id").is_empty()
                && m["conversation_id"] == cid
                && m.get("user_id").is_none_or(|v| v == uid),
            "E_VALIDATION: invalid message identity"
        );
        ensure!(
            ids.insert(text(m, "id")) && m["seq"].as_i64().is_some_and(|s| seqs.insert(s)),
            "E_VALIDATION: duplicate message ID or seq"
        );
        ensure!(
            matches!(
                m["role"].as_str(),
                Some("user" | "assistant" | "system" | "tool" | "summary")
            ),
            "E_VALIDATION: invalid message role"
        );
        validate_content(m)?;
        validate_swipes(m, uid, cid)?;
    }
    Ok(())
}
fn validate_content(m: &Value) -> Result<()> {
    ensure!(
        m["content"].is_string() && m["actual"].is_null()
            || m["content"].is_string() && m["actual"].is_string(),
        "E_VALIDATION: content/actual must be string or actual null"
    );
    if let Some(v) = m.get("visible") {
        ensure!(v.is_boolean(), "E_VALIDATION: visible must be boolean");
    }
    if let Some(v) = m.get("usage") {
        ensure!(v.is_object(), "E_VALIDATION: usage must be object");
    }
    for key in ["model", "model_name", "model_icon", "actual_status"] {
        if let Some(v) = m.get(key) {
            ensure!(v.is_string(), "E_VALIDATION: {key} must be string");
        }
    }
    ensure!(
        m["parts"].is_object()
            && m["parts"]["images"].is_array()
            && m["parts"]["segments"].is_array(),
        "E_VALIDATION: parts requires images and segments arrays"
    );
    let mut ids = HashSet::new();
    for seg in m["parts"]["segments"].as_array().unwrap() {
        match seg["type"].as_str() {
            Some("text" | "reasoning") => ensure!(
                seg["text"].is_string(),
                "E_VALIDATION: text segment requires text"
            ),
            Some("tool") => {
                ensure!(
                    !text(seg, "id").is_empty()
                        && ids.insert(text(seg, "id"))
                        && seg["name"].is_string()
                        && seg["arguments"].is_string()
                        && seg["result"].is_string()
                        && seg["is_error"].is_boolean(),
                    "E_VALIDATION: tool segment requires paired call/result"
                );
                serde_json::from_str::<Value>(&text(seg, "arguments"))
                    .map_err(|_| anyhow!("E_VALIDATION: tool arguments must be valid JSON"))?;
            }
            _ => bail!("E_VALIDATION: invalid segment type"),
        }
    }
    if let Some(calls) = m.get("tool_calls") {
        for call in calls
            .as_array()
            .ok_or_else(|| anyhow!("E_VALIDATION: tool_calls must be array"))?
        {
            ensure!(
                call["id"].is_string() && call["name"].is_string() && call["arguments"].is_string(),
                "E_VALIDATION: invalid tool_call shape"
            );
            serde_json::from_str::<Value>(&text(call, "arguments"))
                .map_err(|_| anyhow!("E_VALIDATION: invalid tool arguments"))?;
        }
    }
    Ok(())
}
fn validate_swipes(m: &Value, uid: &str, cid: &str) -> Result<()> {
    if let Some(swipes) = m.get("swipes") {
        let a = swipes
            .as_array()
            .ok_or_else(|| anyhow!("E_VALIDATION: swipes must be array"))?;
        ensure!(
            !a.is_empty()
                && m["swipe_index"]
                    .as_u64()
                    .is_some_and(|i| (i as usize) < a.len()),
            "E_VALIDATION: invalid swipe index"
        );
        for swipe in a {
            validate_content(swipe)?;
            if let Some(tail) = swipe.get("tail") {
                validate_messages(
                    tail.as_array()
                        .ok_or_else(|| anyhow!("E_VALIDATION: tail must be array"))?,
                    uid,
                    cid,
                )?;
            }
        }
    } else if let Some(i) = m.get("swipe_index") {
        ensure!(i == 0, "E_VALIDATION: swipe_index requires swipes");
    }
    Ok(())
}

pub struct Outcome {
    pub result: Value,
    pub session: Session,
}
#[allow(clippy::too_many_arguments)]
pub async fn invoke(
    s: &AppState,
    uid: &str,
    cid: &str,
    plugin: &Value,
    handler: &str,
    payload: Value,
    phase: &str,
    operation: &Operation,
    previous: Option<&Session>,
) -> Result<Outcome> {
    let key = format!("{uid}:{}", text(plugin, "id"));
    let lock = s.plugins.locks.lock().await.entry(key).or_default().clone();
    let _guard = tokio::select! {_=operation.cancel.cancelled()=>bail!("E_CANCELLED: operation cancelled"),g=lock.lock_owned()=>g};
    let _worker = tokio::select! {_=operation.cancel.cancelled()=>bail!("E_CANCELLED: operation cancelled"),p=s.plugins.workers.clone().acquire_owned()=>p?};
    let mut session = Session::new(s, uid, cid, plugin.clone(), phase, operation.clone()).await?;
    if phase != "menu" && phase != "tool" {
        session.permit("hooks")?;
    }
    if let Some(previous) = previous {
        session.messages = previous.messages.clone();
        session.original_messages = previous.messages.clone();
        session.memories = previous.memories.clone();
        session.original_memories = previous.memories.clone();
    }
    let invocation = session.invocation.clone();
    let invocation_id = text(&invocation, "id");
    let session = Arc::new(Mutex::new(session));
    let host_session = session.clone();
    let host: runtime::Host = Arc::new(move |method, args| {
        let session = host_session.clone();
        Box::pin(async move { session.lock().await.command(&method, &args).await })
    });
    let mut payload = payload;
    if payload.is_object() && phase != "tool" && phase != "menu" {
        payload["invocation"] = invocation.clone();
    }
    let result = runtime::run(
        text(plugin, "code"),
        handler.into(),
        payload,
        invocation,
        host,
        phase != "menu" && phase != "tool",
        operation.cancel.clone(),
    )
    .await;
    s.plugins
        .dialogs
        .lock()
        .await
        .retain(|_, call| call.invocation_id != invocation_id);
    let result = result?;
    let session = session.lock().await.clone();
    Ok(Outcome { result, session })
}
