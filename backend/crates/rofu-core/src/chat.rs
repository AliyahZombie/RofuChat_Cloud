use crate::{
    api::{self, ApiError, ApiResult},
    card, context, jstool, llm, mcp, memory,
    model::{flag, id, instant, normalized, now, number, summarize, text},
    server::AppState,
    swipes,
};
use anyhow::{bail, Result};
use axum::response::{
    sse::{Event as SseEvent, KeepAlive},
    IntoResponse, Response, Sse,
};
use futures_util::StreamExt;
use serde_json::{json, Value};
use std::{
    collections::HashMap,
    convert::Infallible,
    time::{Duration, Instant},
};
use tokio::sync::mpsc::{self, UnboundedSender};
use tokio_util::sync::CancellationToken;

type Events = UnboundedSender<Value>;
fn emit(tx: &Events, v: Value) {
    let mut v = v;
    if v["message"].is_object() && v["message"]["role"].is_string() {
        v["message"] = swipes::public(&v["message"]);
    }
    let _ = tx.send(v);
}
pub fn message(cid: &str, seq: i64, role: &str, content: &str) -> Value {
    json!({"id":id(),"conversation_id":cid,"seq":seq,"role":role,"content":content,"actual":null,"actual_status":"none","actual_error":null,"visible":true,"parts":{"segments":[],"images":[],"error":null},"model":"","model_name":"","model_icon":"","usage":{"input":0,"output":0,"cached":0,"reasoning":0,"duration_ms":0,"ttft_ms":0,"estimated":true,"last_input":0},"created_at":now()})
}
pub async fn resolve(
    s: &AppState,
    uid: &str,
    character: &Value,
    fast: bool,
) -> ApiResult<(Value, Value)> {
    let settings = api::settings(s, uid).await?;
    let candidates = if fast {
        vec![
            text(&settings, "fast_model_id"),
            text(character, "model_id"),
            text(&settings, "default_model_id"),
        ]
    } else {
        vec![
            text(character, "model_id"),
            text(&settings, "default_model_id"),
        ]
    };
    let mid = candidates
        .into_iter()
        .find(|s| !s.is_empty())
        .ok_or_else(|| ApiError::bad("no model configured"))?;
    let model = api::required(s, uid, "model", &mid).await?;
    let provider = api::required(s, uid, "provider", &text(&model, "provider_id")).await?;
    if !flag(&provider, "enabled", true) {
        return Err(ApiError::bad("provider is disabled"));
    }
    Ok((model, provider))
}
pub async fn fast(
    s: &AppState,
    uid: &str,
    character: &Value,
    instruction: &str,
    input: &str,
) -> Result<String> {
    let (model, provider) = resolve(s, uid, character, true)
        .await
        .map_err(|e| anyhow::anyhow!(e.message))?;
    let request = short_request(model, provider, instruction, input, json!({}));
    complete_short_request(s, request).await
}
async fn complete_short_request(s: &AppState, request: llm::Request) -> Result<String> {
    tokio::select! {
        _=s.shutdown.cancelled()=>bail!("server stopped"),
        result=llm::complete(&s.client,request)=>result,
    }
}

fn short_request(
    model: Value,
    provider: Value,
    instruction: &str,
    input: &str,
    params: Value,
) -> llm::Request {
    llm::Request {
        provider,
        model,
        messages: vec![
            json!({"role":"system","content":instruction}),
            json!({"role":"user","content":input}),
        ],
        params,
        tools: vec![],
    }
}

async fn complete_actual_request(
    s: &AppState,
    uid: &str,
    c: &Value,
    cid: &str,
    instruction: &str,
    input: &str,
) -> Result<llm::Completion> {
    let cancel = s
        .generating
        .lock()
        .await
        .get(cid)
        .cloned()
        .unwrap_or_default();
    let complete = async {
        let (model, provider) = resolve(s, uid, c, true)
            .await
            .map_err(|e| anyhow::anyhow!(e.message))?;
        // Leave room for mandatory reasoning; validate the cleaned note after completion.
        // Do not inherit character reasoning settings or enable provider thinking modes.
        let request =
            short_request(model, provider, instruction, input, json!({})).without_output_cap();
        Ok(llm::complete_detailed(&s.client, request).await)
    };
    tokio::select! {
        _=s.shutdown.cancelled()=>bail!("server stopped"),
        _=cancel.cancelled()=>bail!("generation stopped"),
        output=complete=>output,
    }
}

fn truncate_title(input: &str, max: usize) -> String {
    let mut chars = input.chars();
    let mut title: String = chars.by_ref().take(max).collect();
    if chars.next().is_some() {
        title.push('…');
    }
    title
}

fn first_title_line(input: &str) -> String {
    input
        .lines()
        .find(|line| !line.trim().is_empty())
        .unwrap_or("")
        .split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
}

fn fallback_title(input: &str) -> String {
    let line = first_title_line(input);
    if line.is_empty() {
        "New chat".into()
    } else {
        truncate_title(&line, 20)
    }
}

fn strip_think(input: &str) -> String {
    let mut output = input.to_owned();
    for tag in ["think", "thinking"] {
        let open = format!("<{tag}>");
        let close = format!("</{tag}>");
        while let Some(start) = output.find(&open) {
            let end = output[start + open.len()..]
                .find(&close)
                .map_or(output.len(), |end| start + open.len() + end + close.len());
            output.replace_range(start..end, "");
        }
    }
    output
}

fn clean_title(input: &str) -> Option<String> {
    let line = first_title_line(&strip_think(input));
    let mut title = line.as_str();
    loop {
        let stripped = title.trim_matches(|c: char| {
            c.is_whitespace()
                || matches!(
                    c,
                    '\'' | '"'
                        | '“'
                        | '”'
                        | '‘'
                        | '’'
                        | '《'
                        | '》'
                        | '〈'
                        | '〉'
                        | '「'
                        | '」'
                        | '#'
                        | '*'
                )
        });
        let stripped = if stripped
            .get(..6)
            .is_some_and(|s| s.eq_ignore_ascii_case("Title:"))
        {
            &stripped[6..]
        } else {
            stripped
                .strip_prefix("标题：")
                .or_else(|| stripped.strip_prefix("标题:"))
                .unwrap_or(stripped)
        };
        if stripped == title {
            break;
        }
        title = stripped;
    }
    (!title.is_empty()).then(|| truncate_title(title, 24))
}

async fn conversation_title(s: &AppState, uid: &str, first: &str) -> String {
    let generated = async {
        let settings = api::settings(s, uid).await.ok()?;
        let mid = text(&settings, "fast_model_id");
        if mid.is_empty() {
            return None;
        }
        let model = api::required(s, uid, "model", &mid).await.ok()?;
        let provider = api::required(s, uid, "provider", &text(&model, "provider_id")).await.ok()?;
        if !flag(&provider, "enabled", true) {
            return None;
        }
        let request = short_request(
            model, provider,
            "Generate a short conversation title. Output only the title itself, at most 16 Chinese characters or 6 English words, in the user's language. No quotes or trailing punctuation.",
            first,
            json!({}),
        ).without_output_cap();
        let output = complete_short_request(s, request).await.ok()?;
        clean_title(&output)
    }.await;
    generated.unwrap_or_else(|| fallback_title(first))
}
pub async fn fast_for_conversation(
    s: &AppState,
    uid: &str,
    character: &Value,
    cid: &str,
    instruction: &str,
    input: &str,
) -> Result<String> {
    let cancel = s
        .generating
        .lock()
        .await
        .get(cid)
        .cloned()
        .unwrap_or_default();
    tokio::select! {
        _=cancel.cancelled()=>bail!("generation stopped"),
        result=fast(s,uid,character,instruction,input)=>result,
    }
}
pub async fn create_conversation(s: &AppState, uid: &str, body: &Value) -> ApiResult<Value> {
    let _lock = s.generating.lock().await;
    let c = api::required(s, uid, "character", &text(body, "character_id")).await?;
    let conv = json!({"id":id(),"character_id":c["id"],"title":"","created_at":now(),"updated_at":now(),"memory_scanned_seq":0});
    let greeting = if let Some(index) = body["greeting_index"].as_u64() {
        c["card"]["alternate_greetings"][index as usize]
            .as_str()
            .unwrap_or_default()
            .to_owned()
    } else {
        text(&c["card"], "first_mes")
    };
    // Insert conversation and greeting together so readers never observe a partial creation.
    let settings = api::settings(s, uid).await?;
    let mut tx = s.db.pool.begin().await?;
    sqlx::query("INSERT INTO conversations(id,user_id,character_id,data,updated_at) VALUES ($1,$2,$3,$4,$5)").bind(text(&conv,"id")).bind(uid).bind(text(&c,"id")).bind(conv.to_string()).bind(now()).execute(&mut *tx).await?;
    if !greeting.is_empty() {
        let mut m = message(
            &text(&conv, "id"),
            1000,
            "assistant",
            &card::macros(&greeting, &text(&c, "name"), &text(&settings, "user_name")),
        );
        let mut greetings = vec![text(&c["card"], "first_mes")];
        greetings.extend(
            c["card"]["alternate_greetings"]
                .as_array()
                .into_iter()
                .flatten()
                .map(|g| g.as_str().unwrap_or_default().to_owned()),
        );
        m["swipes"] = json!(greetings
            .iter()
            .map(|g| {
                let mut version = m.clone();
                version["content"] = json!(card::macros(
                    g,
                    &text(&c, "name"),
                    &text(&settings, "user_name")
                ));
                swipes::snapshot(&version)
            })
            .collect::<Vec<_>>());
        let selected = body["greeting_index"]
            .as_u64()
            .map_or(0, |i| i as usize + 1);
        swipes::activate(&mut m, selected);
        sqlx::query(
            "INSERT INTO messages(id,user_id,conversation_id,seq,data) VALUES ($1,$2,$3,$4,$5)",
        )
        .bind(text(&m, "id"))
        .bind(uid)
        .bind(text(&conv, "id"))
        .bind(1000_i64)
        .bind(m.to_string())
        .execute(&mut *tx)
        .await?;
    }
    tx.commit().await?;
    Ok(conv)
}
pub async fn busy(s: &AppState, cid: &str) -> ApiResult<()> {
    if s.generating.lock().await.contains_key(cid) {
        Err(ApiError::conflict("conversation is generating"))
    } else {
        Ok(())
    }
}
pub async fn begin(s: AppState, uid: String, cid: String, body: Value) -> ApiResult<Response> {
    if s.shutdown.is_cancelled() {
        return Err(ApiError::conflict("server is stopping"));
    }
    let mut running = s.generating.lock().await;
    if running.contains_key(&cid) {
        return Err(ApiError::conflict("conversation is generating"));
    }
    let conv = api::conversation(&s, &uid, &cid).await?;
    let character = api::required(&s, &uid, "character", &text(&conv, "character_id")).await?;
    let (model, provider) = resolve(&s, &uid, &character, false).await?;
    let cancel = CancellationToken::new();
    running.insert(cid.clone(), cancel.clone());
    drop(running);
    let prep = prepare(&s, &uid, &cid, &body).await;
    let user = match prep {
        Ok(user) => user,
        Err(e) => {
            s.generating.lock().await.remove(&cid);
            return Err(e);
        }
    };
    let (tx, rx) = mpsc::unbounded_channel();
    s.tasks.clone().spawn(async move {
        let work = run(
            &s, &uid, &cid, &character, &model, &provider, user, &tx, &cancel,
        )
        .await;
        if let Err(e) = work {
            tracing::warn!(error=%e,"generation failed");
            emit(&tx, json!({"type":"error","error":e.to_string()}));
        }
        s.generating.lock().await.remove(&cid);
        emit(&tx, json!({"type":"done"}));
    });
    let stream = tokio_stream::wrappers::UnboundedReceiverStream::new(rx)
        .map(|v| Ok::<_, Infallible>(SseEvent::default().data(v.to_string())));
    Ok(Sse::new(stream)
        .keep_alive(
            KeepAlive::new()
                .interval(Duration::from_secs(15))
                .text("ping"),
        )
        .into_response())
}
struct Prepared {
    user: Value,
    assistant: Option<Value>,
}
async fn prepare(s: &AppState, uid: &str, cid: &str, body: &Value) -> ApiResult<Prepared> {
    let messages = s.db.messages(uid, cid).await?;
    let edit = text(body, "edit_message_id");
    let regenerate = flag(body, "regenerate", false);
    if regenerate || !edit.is_empty() {
        let target = if !edit.is_empty() {
            messages
                .iter()
                .find(|m| text(m, "id") == edit && m["role"] == "user")
        } else {
            messages.iter().rev().find(|m| m["role"] == "user")
        }
        .ok_or_else(|| ApiError::bad("no matching user message"))?;
        let mut target = target.clone();
        let mut tx = s.db.pool.begin().await?;
        let mut assistant = None;
        let cutoff = if !edit.is_empty() {
            swipes::archive_tail(&mut tx, uid, &mut target).await?;
            let mut fresh = message(
                cid,
                number(&target, "seq", 0),
                "user",
                &text(body, "content"),
            );
            fresh["parts"]["images"] = body["images"]
                .as_array()
                .cloned()
                .map(Value::Array)
                .unwrap_or_else(|| json!([]));
            swipes::append(&mut target, &fresh);
            number(&target, "seq", 0)
        } else {
            if let Some(old) = messages
                .iter()
                .find(|m| number(m, "seq", 0) > number(&target, "seq", 0))
                .filter(|m| m["role"] == "assistant")
            {
                let mut versioned = old.clone();
                let fresh = message(cid, number(old, "seq", 0), "assistant", "");
                swipes::append(&mut versioned, &fresh);
                swipes::store(&mut tx, uid, &versioned).await?;
                assistant = Some(versioned);
            }
            assistant
                .as_ref()
                .map_or(number(&target, "seq", 0), |m| number(m, "seq", 0))
        };
        sqlx::query("DELETE FROM messages WHERE user_id=$1 AND conversation_id=$2 AND seq>$3")
            .bind(uid)
            .bind(cid)
            .bind(cutoff)
            .execute(&mut *tx)
            .await?;
        swipes::store(&mut tx, uid, &target).await?;
        tx.commit().await?;
        return Ok(Prepared {
            user: target,
            assistant,
        });
    }
    if text(body, "content").trim().is_empty()
        && body["images"].as_array().is_none_or(|a| a.is_empty())
    {
        return Err(ApiError::bad("content or images is required"));
    }
    let mut user = message(
        cid,
        messages
            .iter()
            .map(|m| number(m, "seq", 0))
            .max()
            .unwrap_or(0)
            + 1000,
        "user",
        &text(body, "content"),
    );
    user["parts"]["images"] = body["images"]
        .as_array()
        .cloned()
        .map(Value::Array)
        .unwrap_or_else(|| json!([]));
    s.db.save_message(uid, &user).await?;
    Ok(Prepared {
        user,
        assistant: None,
    })
}
struct Toolbox {
    definitions: Vec<Value>,
    local: HashMap<String, Value>,
    mcp: Vec<mcp::Connection>,
    remote: HashMap<String, (usize, String)>,
    memory: bool,
}
impl Toolbox {
    async fn load(s: &AppState, uid: &str, c: &Value, model: &Value, tx: &Events) -> Result<Self> {
        let mut this = Self {
            definitions: vec![],
            local: HashMap::new(),
            mcp: vec![],
            remote: HashMap::new(),
            memory: false,
        };
        if !flag(model, "tool_call", true) {
            return Ok(this);
        }
        if flag(&c["memory"], "enabled", true) {
            this.memory = true;
            this.definitions.extend(memory::definitions());
        }
        if let Some(ids) = c["tool_ids"].as_array() {
            for tid in ids {
                if let Some(t) = s.db.get(uid, "tool", tid.as_str().unwrap_or("")).await? {
                    if !flag(&t, "enabled", true) {
                        continue;
                    }
                    if t["models"]
                        .as_array()
                        .is_some_and(|a| !a.is_empty() && !a.contains(&model["id"]))
                    {
                        continue;
                    }
                    let name = jstool::sanitize(&text(&t, "name"));
                    if this.definitions.iter().any(|d| d["name"] == name) {
                        emit(
                            tx,
                            json!({"type":"notice","message":format!("Duplicate tool name: {name}")}),
                        );
                        continue;
                    }
                    this.definitions.push(json!({"name":name,"description":t["description"],"parameters":t["parameters"]}));
                    this.local.insert(name, t);
                }
            }
        }
        if let Some(servers) = c["mcp"].as_array() {
            for config in servers {
                if !flag(config, "enabled", true) {
                    continue;
                }
                match mcp::Connection::connect(s.client.clone(), config.clone()).await {
                    Ok(conn) => {
                        let index = this.mcp.len();
                        for tool in &conn.tools {
                            let name = text(tool, "name");
                            if this.definitions.iter().any(|d| d["name"] == name) {
                                emit(
                                    tx,
                                    json!({"type":"notice","message":format!("Duplicate tool name: {name}")}),
                                );
                                continue;
                            }
                            this.definitions.push(tool.clone());
                            this.remote.insert(name, (index, text(tool, "raw_name")));
                        }
                        this.mcp.push(conn);
                    }
                    Err(e) => emit(
                        tx,
                        json!({"type":"notice","message":format!("MCP {} skipped: {e}",text(config,"name"))}),
                    ),
                }
            }
        }
        Ok(this)
    }
    async fn execute(
        &mut self,
        s: &AppState,
        uid: &str,
        c: &Value,
        call: &Value,
    ) -> (String, bool) {
        let args: Value = match serde_json::from_str(&text(call, "arguments")) {
            Ok(a) => a,
            Err(e) => return (format!("Invalid tool arguments: {e}"), true),
        };
        let name = text(call, "name");
        if let Some(tool) = self.local.get(&name) {
            let v = jstool::run(text(tool, "code"), args).await;
            return (text(&v, "result"), flag(&v, "is_error", false));
        }
        if let Some((index, raw)) = self.remote.get(&name) {
            return match self.mcp[*index].call(raw, args).await {
                Ok(v) => v,
                Err(e) => (e.to_string(), true),
            };
        }
        if self.memory && memory::definitions().iter().any(|d| d["name"] == name) {
            return match memory::tool(s, uid, c, &name, &args).await {
                Ok(v) => (v, false),
                Err(e) => (e.message, true),
            };
        }
        (format!("Unknown tool: {name}"), true)
    }
}
fn append(m: &mut Value, kind: &str, delta: &str) {
    let segments = m["parts"]["segments"].as_array_mut().unwrap();
    if let Some(last) = segments.last_mut().filter(|s| s["type"] == kind) {
        let value = format!("{}{delta}", text(last, "text"));
        last["text"] = json!(value);
    } else {
        segments.push(json!({"type":kind,"text":delta,"duration_ms":0}));
    }
    m["content"] = json!(m["parts"]["segments"]
        .as_array()
        .unwrap()
        .iter()
        .filter(|s| s["type"] == "text")
        .map(|s| text(s, "text"))
        .collect::<Vec<_>>()
        .join("\n\n"));
}
fn reasoning_end(m: &mut Value, tx: &Events, start: &mut Option<Instant>) {
    if let Some(time) = start.take() {
        let ms = time.elapsed().as_millis() as i64;
        if let Some(last) = m["parts"]["segments"]
            .as_array_mut()
            .unwrap()
            .last_mut()
            .filter(|s| s["type"] == "reasoning")
        {
            last["duration_ms"] = json!(ms);
        }
        emit(tx, json!({"type":"reasoning_end","duration_ms":ms}));
    }
}
#[allow(clippy::too_many_arguments)]
async fn run(
    s: &AppState,
    uid: &str,
    cid: &str,
    c: &Value,
    model: &Value,
    provider: &Value,
    prepared: Prepared,
    tx: &Events,
    cancel: &CancellationToken,
) -> Result<()> {
    let start = Instant::now();
    let mut conv = api::conversation(s, uid, cid)
        .await
        .map_err(|e| anyhow::anyhow!(e.message))?;
    conv["updated_at"] = json!(now());
    s.db.save_conversation(uid, &conv).await?;
    let user = prepared.user;
    emit(tx, json!({"type":"user_message","message":user}));
    let mut assistant = prepared
        .assistant
        .unwrap_or_else(|| message(cid, number(&user, "seq", 0) + 1000, "assistant", ""));
    assistant["model"] = model["id"].clone();
    assistant["model_name"] = model["name"].clone();
    assistant["model_icon"] = model["icon"].clone();
    s.db.save_message(uid, &assistant).await?;
    emit(tx, json!({"type":"assistant_start","message":assistant}));
    let mut tool_definitions = vec![];
    let mut reasoning = None;
    let generation=async{
        let mut toolbox=tokio::select!{_ = cancel.cancelled()=>return Ok(()),t=Toolbox::load(s,uid,c,model,tx)=>t?};
        tool_definitions=toolbox.definitions.clone();
        let settings=api::settings(s,uid).await.map_err(|e|anyhow::anyhow!(e.message))?;let mut first_token=true;
        for turn in 0..16 {
            let history=s.db.messages(uid,cid).await?;let memories=memory::available(s,uid,c).await.map_err(|e|anyhow::anyhow!(e.message))?;
            let messages=context::build(c,&settings,&history,&memories,flag(model,"vision",false));
            let request=llm::Request{provider:provider.clone(),model:model.clone(),messages,params:c["params"].clone(),tools:toolbox.definitions.clone()};
            let (events_tx,mut events_rx)=mpsc::unbounded_channel();let client=s.client.clone();
            let mut worker=tokio_util::task::AbortOnDropHandle::new(tokio::spawn(async move{llm::stream(&client,request,events_tx).await}));
            let mut flush=tokio::time::interval(Duration::from_secs(1));let mut calls=vec![];
            loop {
                tokio::select!{
                    _=cancel.cancelled()=>{worker.abort();reasoning_end(&mut assistant,tx,&mut reasoning);return Ok(());},
                    _=s.shutdown.cancelled()=>{worker.abort();return Ok(());},
                    _=flush.tick()=>{s.db.save_message(uid,&assistant).await?;},
                    event=events_rx.recv()=>{
                        let Some(event)=event else{break;};
                        match event {
                            llm::Event::Text(delta)=>{if first_token{assistant["usage"]["ttft_ms"]=json!(start.elapsed().as_millis() as i64);first_token=false;}reasoning_end(&mut assistant,tx,&mut reasoning);append(&mut assistant,"text",&delta);emit(tx,json!({"type":"text","delta":delta}));},
                            llm::Event::Reasoning(delta)=>{if first_token{assistant["usage"]["ttft_ms"]=json!(start.elapsed().as_millis() as i64);first_token=false;}reasoning.get_or_insert_with(Instant::now);append(&mut assistant,"reasoning",&delta);emit(tx,json!({"type":"reasoning","delta":delta}));},
                            llm::Event::ToolCall(call)=>{reasoning_end(&mut assistant,tx,&mut reasoning);calls.push(call);},
                            llm::Event::Usage(usage)=>{for key in ["input","output","cached","reasoning"]{assistant["usage"][key]=json!(number(&assistant["usage"],key,0)+number(&usage,key,0));}assistant["usage"]["last_input"]=usage["input"].clone();assistant["usage"]["last_output"]=usage["output"].clone();assistant["usage"]["estimated"]=json!(flag(&usage,"estimated",true)||if turn==0{false}else{flag(&assistant["usage"],"estimated",true)});},
                        }
                    }
                }
            }
            // Receiver closure means all parsed events have been consumed.
            (&mut worker).await??;reasoning_end(&mut assistant,tx,&mut reasoning);
            if calls.is_empty(){return Ok(());}
            for call in calls {
                emit(tx,json!({"type":"tool_start","id":call["id"],"name":call["name"],"arguments":call["arguments"]}));let t=Instant::now();
                let (result,is_error)=tokio::select!{_ = cancel.cancelled()=>return Ok(()),v=toolbox.execute(s,uid,c,&call)=>v};let result=result.chars().take(20_000).collect::<String>();let duration=t.elapsed().as_millis() as i64;
                assistant["parts"]["segments"].as_array_mut().unwrap().push(json!({"type":"tool","id":call["id"],"name":call["name"],"arguments":call["arguments"],"result":result,"is_error":is_error,"duration_ms":duration}));
                emit(tx,json!({"type":"tool_end","id":call["id"],"result":result,"is_error":is_error,"duration_ms":duration}));s.db.save_message(uid,&assistant).await?;
            }
        }
        bail!("agent reached the 16-turn limit")
    }.await;
    reasoning_end(&mut assistant, tx, &mut reasoning);
    assistant["usage"]["duration_ms"] = json!(start.elapsed().as_millis() as i64);
    if let Err(ref e) = generation {
        assistant["parts"]["error"] = json!(e.to_string());
        emit(tx, json!({"type":"error","error":e.to_string()}));
    }
    s.db.save_message(uid, &assistant).await?;
    {
        let _lock = s.generating.lock().await;
        conv = api::conversation(s, uid, cid)
            .await
            .map_err(|e| anyhow::anyhow!(e.message))?;
        conv["updated_at"] = json!(now());
        s.db.save_conversation(uid, &conv).await?;
    }
    emit(tx, json!({"type":"assistant_done","message":assistant}));
    if !cancel.is_cancelled() && generation.is_ok() {
        if instant(c) {
            emit(tx, json!({"type":"actual_pending","id":assistant["id"]}));
            match actual(s, uid, &mut assistant, c).await {
                Ok(()) => emit(tx, json!({"type":"actual","message":assistant})),
                Err(e) => emit(tx, json!({"type":"notice","message":e.to_string()})),
            }
        }
        if summarize(c) {
            let stat = context_info_with_tools(s, uid, cid, Some(&tool_definitions)).await?;
            if number(&stat, "tokens", 0) >= number(&stat, "threshold", i64::MAX) {
                emit(tx, json!({"type":"compressing"}));
                match compress(s, uid, cid, c).await {
                    Ok(Some((summary, hidden))) => emit(
                        tx,
                        json!({"type":"summary","message":summary,"hidden_ids":hidden}),
                    ),
                    Ok(None) => {}
                    Err(e) => emit(
                        tx,
                        json!({"type":"notice","message":format!("Compression failed: {e}")}),
                    ),
                }
            }
        }
        if text(&conv, "title").is_empty() {
            let s = s.clone();
            let uid = uid.to_owned();
            let cid = cid.to_owned();
            s.tasks.clone().spawn(async move {
                let Ok(history) = s.db.messages(&uid, &cid).await else {
                    return;
                };
                let first = history
                    .iter()
                    .find(|m| m["role"] == "user")
                    .map(|m| text(m, "content"))
                    .unwrap_or_default();
                let title = conversation_title(&s, &uid, &first).await;
                let _lock = s.generating.lock().await;
                if let Ok(Some(mut conv)) = s.db.conversation(&uid, &cid).await {
                    if text(&conv, "title").is_empty() {
                        conv["title"] = json!(title);
                        let _ = s.db.save_conversation(&uid, &conv).await;
                    }
                }
            });
        }
    }
    match context_info_with_tools(s, uid, cid, Some(&tool_definitions)).await {
        Ok(info) => {
            let mut info = info;
            info["type"] = json!("context");
            emit(tx, info);
        }
        Err(e) => emit(tx, json!({"type":"notice","message":e.to_string()})),
    }
    Ok(())
}
fn collapse_whitespace(input: &str) -> String {
    input.split_whitespace().collect::<Vec<_>>().join(" ")
}

fn actual_input(message: &Value) -> String {
    let mut lines = vec![strip_think(&text(message, "content")).trim().to_owned()];
    if let Some(segments) = message["parts"]["segments"].as_array() {
        for tool in segments.iter().filter(|seg| seg["type"] == "tool") {
            let name = collapse_whitespace(&strip_think(&text(tool, "name")));
            let args: String = collapse_whitespace(&strip_think(&text(tool, "arguments")))
                .chars()
                .take(120)
                .collect();
            let result: String = collapse_whitespace(&strip_think(&text(tool, "result")))
                .chars()
                .take(200)
                .collect();
            lines.push(format!("[tool] {name}({args}) → {result}"));
        }
    }
    lines
        .into_iter()
        .filter(|line| !line.is_empty())
        .collect::<Vec<_>>()
        .join("\n")
}

fn clean_actual(input: &str) -> String {
    let output = strip_think(input);
    let mut note = output.trim();
    loop {
        let unwrapped = if let Some(fenced) = note.trim().strip_prefix("```") {
            let body = fenced.split_once('\n').map_or(fenced, |(_, body)| body);
            body.trim().strip_suffix("```").unwrap_or(body).trim()
        } else if let Some(body) = note
            .trim()
            .strip_prefix("<note>")
            .and_then(|s| s.strip_suffix("</note>"))
        {
            body
        } else if let Some(body) = note
            .trim()
            .strip_prefix("<reply>")
            .and_then(|s| s.strip_suffix("</reply>"))
        {
            body
        } else {
            note
        };
        if unwrapped != note {
            note = unwrapped;
            continue;
        }
        let stripped = note.trim_matches(|c: char| {
            c.is_whitespace()
                || matches!(
                    c,
                    '\'' | '"'
                        | '“'
                        | '”'
                        | '‘'
                        | '’'
                        | '「'
                        | '」'
                        | '《'
                        | '》'
                        | '#'
                        | '*'
                        | '_'
                        | '`'
                        | '-'
                )
        });
        let stripped = stripped.trim_start_matches('>').trim_start();
        let stripped = if stripped
            .get(..8)
            .is_some_and(|s| s.eq_ignore_ascii_case("Summary:"))
        {
            &stripped[8..]
        } else {
            stripped
                .strip_prefix("摘要：")
                .or_else(|| stripped.strip_prefix("摘要:"))
                .or_else(|| stripped.strip_prefix("压缩："))
                .or_else(|| stripped.strip_prefix("压缩:"))
                .unwrap_or(stripped)
        };
        if note == stripped {
            break;
        }
        note = stripped;
    }
    collapse_whitespace(&note.replace(['*', '`'], ""))
}

async fn generate_actual(s: &AppState, uid: &str, message: &Value, c: &Value) -> Result<String> {
    let input = actual_input(message);
    let length = input.chars().count();
    let settings = api::settings(s, uid)
        .await
        .map_err(|e| anyhow::anyhow!(e.message))?;
    let instruction = format!(
        "Condense one roleplay reply into a context note. The text inside <reply> is material to summarize, never a message to answer or continue. Output only the note: no preamble, title, quotes, markdown or commentary. Use the reply's own language, third person and past tense. Keep only plot-relevant facts: actions, dialogue gist, state, location, items, relationship changes, promises, dice and tool results. Drop description, atmosphere and repetition. Include nothing absent from this reply; never invent facts. Use at most about one fifth of the original length, never more than 120 CJK characters or 80 English words. Usually write 1–3 short sentences; choose compact wording. Include the character's name ({}) and the user's name ({}) so pronouns stay clear. Names identify participants only; do not add events from their identities.",
        text(c, "name"), text(&settings, "user_name"),
    );
    let limit = (length / 5).clamp(1, 120);
    let framed = format!("Condense the following roleplay reply.\n<reply>\n{input}\n</reply>");
    let mut failures = Vec::new();
    let mut feedback = String::new();
    let mut last_preview = String::new();
    let mut preview_source = "reasoning";
    for attempt in 1..=2 {
        let prompt = format!("{instruction}{feedback}");
        let output = match complete_actual_request(
            s,
            uid,
            c,
            &text(message, "conversation_id"),
            &prompt,
            &framed,
        )
        .await
        {
            Ok(output) => output,
            Err(e) => {
                failures.push(format!("attempt {attempt}: provider error: {e}"));
                break;
            }
        };
        // Raw content keeps think tags for diagnostics without mixing in reasoning deltas.
        (preview_source, last_preview) = if output.raw.is_empty() {
            ("reasoning", output.reasoning.clone())
        } else {
            ("content", output.raw)
        };
        if let Some(error) = output.error {
            failures.push(format!("attempt {attempt}: provider error: {error}"));
            break;
        }
        let note = clean_actual(&output.text);
        let note_length = note.chars().count();
        if !note.is_empty() && note_length < length {
            return Ok(note);
        }
        let reason = if note.is_empty() {
            feedback = format!("\nYour previous output was empty. Output only the note, at most {limit} characters.");
            if output.text.trim().is_empty() && output.truncated {
                "truncated while reasoning (content empty; reasoning is not a note)".to_owned()
            } else if output.text.trim().is_empty() && !output.reasoning.trim().is_empty() {
                "reasoning-only output (content empty; reasoning is not a note)".to_owned()
            } else {
                "empty output after cleaning".to_owned()
            }
        } else {
            feedback = format!("\nYour previous output was {note_length} characters; the limit is {limit}. Output only the note.");
            format!("{note_length} characters over the limit (must be shorter than input: {length} characters; retry limit: {limit})")
        };
        failures.push(format!("attempt {attempt}: {reason}"));
    }
    let attempts = if failures.len() == 2 {
        "two attempts"
    } else {
        "one attempt"
    };
    let preview: String = last_preview.chars().take(160).collect();
    bail!("instant compression failed after {attempts}: {}; last {preview_source} preview (first 160 characters): {preview:?}", failures.join("; "))
}

pub async fn actual(s: &AppState, uid: &str, m: &mut Value, c: &Value) -> Result<()> {
    m["actual_status"] = json!("pending");
    m["actual_error"] = Value::Null;
    m["actual"] = Value::Null;
    s.db.save_message(uid, m).await?;
    let result = generate_actual(s, uid, m, c).await;
    match result {
        Ok(note) => {
            m["actual"] = json!(note);
            m["actual_status"] = json!("ok");
        }
        Err(e) => {
            tracing::warn!(message_id = %text(m, "id"), "{e}");
            m["actual_status"] = json!("failed");
            m["actual_error"] = json!(e.to_string());
        }
    }
    s.db.save_message(uid, m).await?;
    Ok(())
}
pub async fn compress(
    s: &AppState,
    uid: &str,
    cid: &str,
    c: &Value,
) -> Result<Option<(Value, Vec<String>)>> {
    if !summarize(c) {
        bail!("summary compression is disabled (context.summarize=false)");
    }
    let visible: Vec<Value> =
        s.db.messages(uid, cid)
            .await?
            .into_iter()
            .filter(|m| flag(m, "visible", true))
            .collect();
    let keep = number(&c["context"], "keep_recent", 6).max(1) as usize;
    if visible.len() <= keep {
        return Ok(None);
    }
    let count = visible.len() - keep;
    let old = &visible[..count];
    let input = old
        .iter()
        .map(|m| {
            let has_actual = m["role"] == "assistant"
                && m["actual_status"] == "ok"
                && m["actual"].is_string();
            let content = if has_actual {
                text(m, "actual")
            } else {
                text(m, "content")
            };
            let mut projected = json!({"role":m["role"],"content":content});
            if !has_actual {
                if let Some(segments) = m["parts"]["segments"].as_array() {
                    let tools: Vec<_> = segments.iter().filter(|seg| seg["type"] == "tool")
                        .map(|seg| json!({"name":seg["name"],"arguments":seg["arguments"],"result":seg["result"]})).collect();
                    if !tools.is_empty() {
                        projected["tools"] = json!(tools);
                    }
                }
            }
            projected
        })
        .collect::<Vec<_>>();
    let summary=fast_for_conversation(s,uid,c,cid,"Summarize the earlier conversation in its language. Fully preserve events, decisions, commitments, relationship changes, current situation and unresolved threads. Merge previous summaries.",&serde_json::to_string(&input)?).await?;
    let m = message(
        cid,
        number(&visible[count], "seq", 0) - 1,
        "summary",
        &summary,
    );
    let hidden = old.iter().map(|m| text(m, "id")).collect::<Vec<_>>();
    let mut tx = s.db.pool.begin().await?;
    for old in old {
        let mut old = old.clone();
        old["visible"] = json!(false);
        sqlx::query("UPDATE messages SET data=$1 WHERE user_id=$2 AND id=$3")
            .bind(old.to_string())
            .bind(uid)
            .bind(text(&old, "id"))
            .execute(&mut *tx)
            .await?;
    }
    sqlx::query(
        "INSERT INTO messages(id,user_id,conversation_id,seq,data) VALUES ($1,$2,$3,$4,$5)",
    )
    .bind(text(&m, "id"))
    .bind(uid)
    .bind(cid)
    .bind(number(&m, "seq", 0))
    .bind(m.to_string())
    .execute(&mut *tx)
    .await?;
    tx.commit().await?;
    Ok(Some((m, hidden)))
}
pub async fn context_info(s: &AppState, uid: &str, cid: &str) -> Result<Value> {
    context_info_with_tools(s, uid, cid, None).await
}
async fn context_info_with_tools(
    s: &AppState,
    uid: &str,
    cid: &str,
    definitions: Option<&[Value]>,
) -> Result<Value> {
    let conv =
        s.db.conversation(uid, cid)
            .await?
            .ok_or_else(|| anyhow::anyhow!("conversation not found"))?;
    let c =
        s.db.get(uid, "character", &text(&conv, "character_id"))
            .await?
            .ok_or_else(|| anyhow::anyhow!("character not found"))?;
    let settings = api::settings(s, uid)
        .await
        .map_err(|e| anyhow::anyhow!(e.message))?;
    let history = s.db.messages(uid, cid).await?;
    let model = resolve(s, uid, &c, false)
        .await
        .map(|(m, _)| m)
        .unwrap_or_else(|_| normalized("model", &json!({})));
    let memories = memory::available(s, uid, &c)
        .await
        .map_err(|e| anyhow::anyhow!(e.message))?;
    let (tx, _rx) = mpsc::unbounded_channel();
    let tools = if let Some(definitions) = definitions {
        definitions.to_vec()
    } else {
        Toolbox::load(s, uid, &c, &model, &tx).await?.definitions
    };
    let mut count = context::estimate(
        &context::build(
            &c,
            &settings,
            &history,
            &memories,
            flag(&model, "vision", false),
        ),
        &tools,
    );
    let mut estimated = true;
    if let Some(last) = history
        .last()
        .filter(|m| m["role"] == "assistant" && m["usage"]["estimated"] == false)
        // Provider usage describes the request before actual/summary postprocessing.
        .filter(|_| {
            !instant(&c)
                && !history
                    .iter()
                    .any(|m| m["role"] == "summary" && flag(m, "visible", true))
        })
    {
        count = number(&last["usage"], "last_input", 0)
            + number(
                &last["usage"],
                "last_output",
                number(&last["usage"], "output", 0),
            );
        estimated = false;
    }
    let max = number(&model, "context_length", 32768).max(1);
    let threshold = number(&c["context"], "compress_threshold", 0);
    Ok(
        json!({"tokens":count,"max":max,"estimated":estimated,"mode":if instant(&c){"instant"}else{"traditional"},"instant":instant(&c),"summarize":summarize(&c),"threshold":if threshold>0{threshold}else{max/4*3+(max%4)*3/4}}),
    )
}

#[cfg(test)]
mod title_tests {
    use super::{clean_title, fallback_title};

    #[test]
    fn fallback_uses_one_line_and_unicode_boundaries() {
        for (input, expected) in [
            ("\n\t  ", "New chat"),
            ("\n  hello\t world  \nignore this", "hello world"),
            (
                "一二三四五六七八九十一二三四五六七八九🙂",
                "一二三四五六七八九十一二三四五六七八九🙂",
            ),
            (
                "一二三四五六七八九十一二三四五六七八九🙂多",
                "一二三四五六七八九十一二三四五六七八九🙂…",
            ),
        ] {
            assert_eq!(fallback_title(input), expected);
        }
    }

    #[test]
    fn cleanup_removes_blocks_and_repeated_decoration() {
        for (input, expected) in [
            ("<think>secret\nsecret</think>\n<thinking>more</thinking>\n # Title: **《hello\t world》**\nextra", Some("hello world")),
            ("‘标题：〈你好🙂〉’", Some("你好🙂")),
            ("**title: \"Short title\"**", Some("Short title")),
            ("<think>secret</think>\nTitle: 《》", None),
            ("<thinking>unfinished", None),
        ] {
            assert_eq!(clean_title(input).as_deref(), expected);
        }
    }
}

#[cfg(test)]
mod actual_tests {
    use super::*;

    #[test]
    fn input_contains_only_visible_text_and_bounded_tool_lines() {
        let message = json!({"content":"Rofu spoke.<think>private thought</think>","parts":{"segments":[
            {"type":"reasoning","text":"secret reasoning"},
            {"type":"text","text":"duplicated text"},
            {"type":"tool","id":"raw-id","name":"dice","arguments":"骰".repeat(121),"result":"点".repeat(201)}
        ]}});
        assert_eq!(
            actual_input(&message),
            format!(
                "Rofu spoke.\n[tool] dice({}) → {}",
                "骰".repeat(120),
                "点".repeat(200)
            )
        );
    }

    #[test]
    fn sanitizer_removes_thought_labels_quotes_and_markdown() {
        for input in [
            "<think>secret</think>\n摘要： **“Rofu\t helped Alice.”**",
            "<thinking>secret</thinking> # Summary: 'Rofu helped Alice.'",
            "```text\n压缩： Rofu helped\nAlice.\n```",
            "**summary: `Rofu helped Alice.`**",
            "Rofu helped Alice.<think>unfinished",
            "Rofu helped Alice.<thinking>unfinished",
            "<note>Rofu helped Alice.</note>",
            "<reply>Rofu helped Alice.</reply>",
            "```custom-language\n<note>Rofu helped Alice.</note>\n```",
            "<note>```xml\nRofu helped Alice.\n```</note>",
        ] {
            assert_eq!(clean_actual(input), "Rofu helped Alice.");
        }
        for input in [
            "<think>unfinished",
            "摘要： **\"\"**",
            "<thinking>secret</thinking>",
        ] {
            assert!(clean_actual(input).is_empty());
        }
    }
}
