mod support;
use futures_util::StreamExt;
use reqwest::{Client, Method};
use rofu_core::{
    model::{id, text},
    plugins::{self, storage},
    sse::Decoder,
    start_server, Config, RunningServer,
};
use serde_json::{json, Value};
use std::time::Duration;
use support::mock::MockServer;

struct Harness {
    server: RunningServer,
    client: Client,
    base: String,
    token: String,
    uid: String,
    _dir: tempfile::TempDir,
}
impl Harness {
    async fn new(database: String) -> Self {
        let dir = tempfile::tempdir().unwrap();
        let server = start_server(Config {
            database,
            listen: "127.0.0.1:0".into(),
            root_password: Some("plugin-tests".into()),
            memory_scanner: false,
            http_client: Some(Client::builder().no_proxy().build().unwrap()),
            ..Config::default()
        })
        .await
        .unwrap();
        let client = Client::builder().no_proxy().build().unwrap();
        let base = format!("http://{}/api", server.address);
        let login: Value = client
            .post(format!("{base}/auth/login"))
            .json(&json!({"username":"root","password":"plugin-tests"}))
            .send()
            .await
            .unwrap()
            .json()
            .await
            .unwrap();
        Self {
            server,
            client,
            base,
            token: text(&login, "token"),
            uid: text(&login["user"], "id"),
            _dir: dir,
        }
    }
    async fn request(&self, method: Method, path: &str, body: Value) -> reqwest::Response {
        self.client
            .request(method, format!("{}{path}", self.base))
            .bearer_auth(&self.token)
            .json(&body)
            .send()
            .await
            .unwrap()
    }
    async fn json(&self, method: Method, path: &str, body: Value) -> Value {
        let response = self.request(method, path, body).await;
        let status = response.status();
        let raw = response.text().await.unwrap();
        assert!(status.is_success(), "{path}: {status}: {raw}");
        if raw.is_empty() {
            Value::Null
        } else {
            serde_json::from_str(&raw).unwrap()
        }
    }
    async fn get(&self, path: &str) -> Value {
        self.json(Method::GET, path, json!({})).await
    }
    async fn post(&self, path: &str, body: Value) -> Value {
        self.json(Method::POST, path, body).await
    }
    async fn events(&self, path: &str, body: Value) -> Vec<Value> {
        let response = self.request(Method::POST, path, body).await;
        assert_eq!(response.status(), 200);
        decode(&response.text().await.unwrap())
    }
    async fn fixture(&self, mock: &MockServer) -> (Value, Value) {
        let p = self
            .post("/providers", json!({"name":"mock","base_url":mock.url}))
            .await;
        let model = self
            .post(
                "/models",
                json!({"provider_id":p["id"],"model_id":"mock","name":"Mock","tool_call":false}),
            )
            .await;
        let c=self.post("/characters",json!({"name":"Plugin character","model_id":model["id"],"memory":{"enabled":true,"auto_scan":false},"context":{"instant":false,"summarize":false}})).await;
        let conv = self
            .post("/conversations", json!({"character_id":c["id"]}))
            .await;
        (c, conv)
    }
    async fn plugin(&self, code: &str, manifest: Value) -> Value {
        self.post(
            "/plugins",
            json!({"name":"Test plugin","code":code,"enabled":true,"manifest":manifest}),
        )
        .await
    }
    async fn attach(&self, c: &Value, plugins: &[Value]) {
        self.json(
            Method::PUT,
            &format!("/characters/{}/plugins", text(c, "id")),
            json!({"plugin_ids":plugins.iter().map(|p| p["id"].clone()).collect::<Vec<_>>()}),
        )
        .await;
    }
    async fn menu(&self, p: &Value, cid: &str, input: Value) -> Vec<Value> {
        self.events(
            &format!("/plugins/{}/menus/run/invoke", text(p, "id")),
            json!({"conversation_id":cid,"input":input}),
        )
        .await
    }
}
fn decode(raw: &str) -> Vec<Value> {
    let mut decoder = Decoder::default();
    decoder
        .push(raw.as_bytes())
        .into_iter()
        .filter_map(|event| serde_json::from_str(&event.data).ok())
        .collect()
}
fn manifest(permissions: Value, hooks: Value, menus: bool) -> Value {
    json!({"api_version":1,"permissions":permissions,"tools":[],"hooks":hooks,"menus":if menus{json!([{"id":"run","label":"Run","handler":"run"}])}else{json!([])}})
}
fn result(events: &[Value]) -> Value {
    events
        .iter()
        .find(|e| e["type"] == "plugin_result")
        .unwrap_or_else(|| panic!("no result: {events:?}"))["result"]
        .clone()
}
fn no_errors(events: &[Value]) {
    assert!(
        !events
            .iter()
            .any(|e| e["type"] == "plugin_error" || e["type"] == "error"),
        "{events:?}"
    );
}

async fn contract_suite(database: String) {
    let h = Harness::new(database).await;
    let mock = MockServer::start().await;
    let (c, conv) = h.fixture(&mock).await;
    let cid = text(&conv, "id");
    let uid = rofu_core::auth::authenticate(&h.server.state.db, &h.token)
        .await
        .unwrap();
    let uid = text(&uid, "id");
    assert_eq!(h.uid, uid);
    let p=h.plugin(r#"export async function run(input) {
      if (input.action === 'foreign') {try {await rofu.messages.get(input.id);return false;}catch(e){return e.code==='E_NOT_FOUND';}}
      if (input.action === 'read') return {v:await rofu.kv.get('global'), named:await rofu.kv.table(rofu.invocation.character_id).list('pre')};
      await rofu.kv.set('global', {n:7});
      await rofu.kv.table(rofu.invocation.character_id).set('prefix-key', [1,2]);
      await rofu.messages.insert({role:'user',content:'before system'});
      const m=await rofu.messages.insert({role:'system',content:'system from plugin'});
      const a=await rofu.messages.insert({role:'assistant',content:'old'});
      const updated=await rofu.messages.update(a.id,{role:'user',seq:42,content:'edited',visible:false,actual:'note',usage:{input:99},model:'custom',images:[],segments:[{type:'text',text:'edited'}],created_at:123,custom:{ok:true}});
      let immutable=false;
      try { await rofu.messages.update(a.id,{conversation_id:'foreign'}); } catch(e) { immutable=e.code==='E_VALIDATION'; }
      let seq=false;
      try { await rofu.messages.update(a.id,{seq:m.seq}); } catch(e) { seq=e.code==='E_VALIDATION'; }
      const mem=await rofu.memory.add({content:'remember',tags:['x'],pinned:true});
      await rofu.memory.update(mem.id,{content:'changed'});
      const memories=await rofu.memory.list();await rofu.memory.remove(mem.id);
      const swiped=await rofu.messages.swipes.append(a.id,{content:'version 2'});
      await rofu.messages.swipes.select(a.id,0);
      const swipes=await rofu.messages.swipes.list(a.id);
      await rofu.messages.swipes.remove(a.id,1);
      const context=await rofu.context.get();
      return {updated,immutable,seq,memories,swipes,context,conversation:await rofu.conversation.get(),character:await rofu.character.get(),page:await rofu.messages.list(),missing:typeof await rofu.kv.get('missing')};
    }"#,manifest(json!(["read","write","storage"]),json!({}),true)).await;
    h.attach(&c, std::slice::from_ref(&p)).await;
    assert!(h
        .get("/plugins")
        .await
        .as_array()
        .unwrap()
        .iter()
        .all(|p| p.get("code").is_none()));
    let projected = h.get(&format!("/characters/{}", text(&c, "id"))).await;
    assert_eq!(projected["plugin_ids"], json!([p["id"]]));
    h.json(
        Method::PUT,
        &format!("/characters/{}", text(&c, "id")),
        projected,
    )
    .await;
    assert_eq!(
        h.get(&format!("/characters/{}", text(&c, "id"))).await["plugin_ids"],
        json!([p["id"]])
    );
    assert_eq!(
        h.get(&format!("/conversations/{cid}/plugin_menus")).await[0]["id"],
        "run"
    );
    let events = h.menu(&p, &cid, json!({})).await;
    no_errors(&events);
    let value = result(&events);
    assert_eq!(value["updated"]["user_id"], uid);
    assert_eq!(value["updated"]["role"], "user");
    assert_eq!(value["updated"]["seq"], 42);
    assert_eq!(value["updated"]["usage"]["input"], 99);
    assert_eq!(value["updated"]["custom"]["ok"], true);
    assert_eq!(value["immutable"], true);
    assert_eq!(value["seq"], true);
    assert_eq!(value["missing"], "undefined");
    assert_eq!(value["context"]["messages"][0]["role"], "system");
    assert!(!text(&value["context"]["messages"][0], "content").contains("system from plugin"));
    assert_eq!(
        value["context"]["messages"]
            .as_array()
            .unwrap()
            .iter()
            .filter(|m| m["role"] == "system")
            .count(),
        1
    );
    assert!(
        mock.state.requests.lock().await.is_empty(),
        "insert must never generate"
    );
    assert_eq!(value["swipes"]["items"].as_array().unwrap().len(), 2);
    assert_eq!(value["memories"]["items"][0]["content"], "changed");
    let other = h
        .post(
            "/characters",
            json!({"name":"Other","model_id":c["model_id"]}),
        )
        .await;
    let other_conv = h
        .post("/conversations", json!({"character_id":other["id"]}))
        .await;
    h.attach(&other, std::slice::from_ref(&p)).await;
    let read = result(
        &h.menu(&p, &text(&other_conv, "id"), json!({"action":"read"}))
            .await,
    );
    assert_eq!(read["v"], json!({"n":7}));
    assert_eq!(read["named"]["items"], json!([]));
    let usage = h.get(&format!("/plugins/{}/storage", text(&p, "id"))).await;
    assert_eq!(usage["entry_count"], 2);
    assert_eq!(usage["tables"].as_array().unwrap().len(), 2);
    h.json(
        Method::DELETE,
        &format!("/plugins/{}/storage/{}", text(&p, "id"), text(&c, "id")),
        json!({}),
    )
    .await;
    assert_eq!(
        h.get(&format!("/plugins/{}/storage", text(&p, "id"))).await["entry_count"],
        1
    );
    h.json(
        Method::DELETE,
        &format!("/plugins/{}/storage", text(&p, "id")),
        json!({}),
    )
    .await;
    assert_eq!(
        h.get(&format!("/plugins/{}/storage", text(&p, "id"))).await["used_bytes"],
        0
    );
    // Quota failure rolls back entries and accounting in the same transaction.
    let mut tx = h.server.state.db.pool.begin().await.unwrap();
    let changes = (0..161)
        .map(|i| storage::Change {
            table: "default".into(),
            key: format!("key-{i}"),
            value: Some(json!("x".repeat(65530))),
        })
        .collect::<Vec<_>>();
    assert!(storage::apply(&mut tx, &uid, &text(&p, "id"), &changes)
        .await
        .unwrap_err()
        .to_string()
        .contains("E_LIMIT"));
    tx.rollback().await.unwrap();
    assert_eq!(
        storage::usage(&h.server.state.db, &uid, &text(&p, "id"))
            .await
            .unwrap()["entry_count"],
        0
    );
    // Invocation failure discards all three kinds of staged mutation.
    let bad=h.plugin("export async function run(){await rofu.kv.set('bad',1);await rofu.messages.insert({role:'user',content:'rollback'});await rofu.memory.add({content:'rollback'});throw Error('rollback');}",manifest(json!(["write","storage"]),json!({}),true)).await;
    h.attach(&c, std::slice::from_ref(&bad)).await;
    let before = h.get(&format!("/conversations/{cid}/messages")).await;
    assert!(h
        .menu(&bad, &cid, json!({}))
        .await
        .iter()
        .any(|e| e["type"] == "plugin_error"));
    assert_eq!(
        h.get(&format!("/conversations/{cid}/messages")).await,
        before
    );
    assert_eq!(
        h.get(&format!("/plugins/{}/storage", text(&bad, "id")))
            .await["used_bytes"],
        0
    );
    let unpaired=h.plugin("export async function run(){await rofu.messages.insert({role:'tool',content:'unpaired'});}",manifest(json!(["write"]),json!({}),true)).await;
    h.attach(&c, std::slice::from_ref(&unpaired)).await;
    assert!(h
        .menu(&unpaired, &cid, json!({}))
        .await
        .iter()
        .any(|e| e["code"] == "E_VALIDATION"));
    assert_eq!(
        h.get(&format!("/conversations/{cid}/messages")).await,
        before
    );
    // Another user cannot read plugins, storage, menus, or reply to calls.
    let b = rofu_core::auth::create(
        &h.server.state.db,
        &format!("user-{}", id()),
        "other",
        false,
    )
    .await
    .unwrap();
    let login = rofu_core::auth::login(
        &h.server.state.db,
        &json!({"username":b["username"],"password":"other"}),
    )
    .await
    .unwrap();
    for path in [
        format!("/plugins/{}", text(&p, "id")),
        format!("/plugins/{}/storage", text(&p, "id")),
        format!("/conversations/{cid}/plugin_menus"),
    ] {
        assert_eq!(
            h.client
                .get(format!("{}{path}", h.base))
                .bearer_auth(text(&login, "token"))
                .send()
                .await
                .unwrap()
                .status(),
            404
        );
    }
    h.server.stop().await.unwrap();
}

#[tokio::test]
async fn sqlite_plugin_contract() {
    contract_suite("sqlite::memory:".into()).await;
}
#[tokio::test]
async fn postgres_plugin_contract() {
    let Ok(url) = std::env::var("ROFU_TEST_PG_URL") else {
        return;
    };
    let (url, pool, schema) = pg_schema(&url).await;
    contract_suite(url).await;
    cleanup(pool, schema).await;
}
async fn pg_schema(url: &str) -> (String, sqlx::AnyPool, String) {
    sqlx::any::install_default_drivers();
    let pool = sqlx::AnyPool::connect(url).await.unwrap();
    let schema = format!("plugins_{}", id());
    sqlx::query(&format!("CREATE SCHEMA {schema}"))
        .execute(&pool)
        .await
        .unwrap();
    let mut parsed = url::Url::parse(url).unwrap();
    parsed
        .query_pairs_mut()
        .append_pair("options", &format!("-c search_path={schema}"));
    (parsed.to_string(), pool, schema)
}
async fn cleanup(pool: sqlx::AnyPool, schema: String) {
    sqlx::query(&format!("DROP SCHEMA {schema} CASCADE"))
        .execute(&pool)
        .await
        .unwrap();
    pool.close().await;
}

async fn hook_suite(database: String) {
    let h = Harness::new(database).await;
    let mock = MockServer::start().await;
    let (c, conv) = h.fixture(&mock).await;
    let cid = text(&conv, "id");
    let first=h.plugin(r#"export async function before(p){await rofu.kv.set('order','first');return {patch:{content:p.content+' A',params:{temperature:0.25}}};}
      export async function beforeTool(p){if(p.tool.name.endsWith('_roll_dice'))return {args:{expression:'9'}};if(p.tool.name==='search__lookup')return {skip:{result:'skipped by plugin',is_error:false}};}
      export async function afterTool(p){return {result:p.result+' [after]',is_error:false};}
      export async function after(p){const m=await rofu.messages.get(p.assistant.id);await rofu.messages.update(m.id,{content:m.content+' patched',actual:'explicit note',model:'plugin model'});}
    "#,manifest(json!(["hooks","read","write","storage"]),json!({"beforeSend":"before","beforeToolCall":"beforeTool","afterToolCall":"afterTool","afterReply":"after"}),false)).await;
    let second = h
        .plugin(
            "export function before(p){return {patch:{content:p.content+' B'}}}",
            manifest(json!(["hooks"]), json!({"beforeSend":"before"}), false),
        )
        .await;
    let throwing=h.plugin("export async function before(){await rofu.kv.set('rollback',1);await rofu.messages.insert({role:'system',content:'should roll back'});throw Error('bad plugin');}",manifest(json!(["hooks","write","storage"]),json!({"beforeSend":"before"}),false)).await;
    let tool = h.get("/plugins").await[0].clone();
    let model = h.get(&format!("/models/{}", text(&c, "model_id"))).await;
    let mut tool_model = model.clone();
    tool_model["model_id"] = json!("mock-tool");
    tool_model["tool_call"] = json!(true);
    h.json(
        Method::PUT,
        &format!("/models/{}", text(&model, "id")),
        tool_model,
    )
    .await;
    h.attach(
        &c,
        &[
            first.clone(),
            throwing.clone(),
            second.clone(),
            tool.clone(),
        ],
    )
    .await;
    let events = h
        .events(
            &format!("/conversations/{cid}/chat"),
            json!({"content":"root"}),
        )
        .await;
    assert_eq!(
        events
            .iter()
            .filter(|e| e["type"] == "plugin_error")
            .count(),
        1,
        "{events:?}"
    );
    assert_eq!(
        events.iter().find(|e| e["type"] == "user_message").unwrap()["message"]["content"],
        "root A B"
    );
    let calls = events
        .iter()
        .filter(|e| e["type"] == "tool_start")
        .collect::<Vec<_>>();
    assert_eq!(calls[0]["arguments"], "{\"expression\":\"9\"}");
    let ends = events
        .iter()
        .filter(|e| e["type"] == "tool_end")
        .collect::<Vec<_>>();
    assert!(text(ends[0], "result").contains("**9** [after]"));
    assert_eq!(ends[1]["result"], "skipped by plugin [after]");
    let done = events
        .iter()
        .position(|e| e["type"] == "assistant_done")
        .unwrap();
    let changed = events
        .iter()
        .rposition(|e| e["type"] == "plugin_messages_changed")
        .unwrap();
    assert!(changed < done);
    assert!(text(&events[done]["message"], "content").ends_with("patched"));
    assert_eq!(events[done]["message"]["actual"], "explicit note");
    assert_eq!(events[done]["message"]["model"], "plugin model");
    assert_eq!(
        h.get(&format!("/plugins/{}/storage", text(&throwing, "id")))
            .await["used_bytes"],
        0
    );
    let requests = mock.state.requests.lock().await;
    assert_eq!(requests[0]["temperature"], 0.25);
    assert_eq!(requests[0]["messages"][1]["content"], "root A B");
    drop(requests);
    // Hooks run even if the model exports no tools. Cancelling beforeSend has no writes,
    // including image uploads and another plugin's already-staged writes.
    let cancel=h.plugin("export async function before(){await rofu.kv.set('cancelled',1);await rofu.messages.insert({role:'system',content:'cancelled'});return {cancel:{reason:'stop here'}}}",manifest(json!(["hooks","storage","write"]),json!({"beforeSend":"before"}),false)).await;
    h.attach(&c, &[first.clone(), cancel.clone()]).await;
    let before = h.get(&format!("/conversations/{cid}/messages")).await;
    let uid = text(&h.get("/auth/me").await, "id");
    let attachments: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM attachments WHERE user_id=$1")
        .bind(&uid)
        .fetch_one(&h.server.state.db.pool)
        .await
        .unwrap();
    let events = h
        .events(
            &format!("/conversations/{cid}/chat"),
            json!({"content":"cancel me","images":["data:image/png;base64,eA=="]}),
        )
        .await;
    assert!(events.iter().any(|e| e["type"] == "plugin_cancelled"));
    assert!(!events.iter().any(|e| e["type"] == "user_message"));
    assert_eq!(
        h.get(&format!("/conversations/{cid}/messages")).await,
        before
    );
    assert_eq!(
        sqlx::query_scalar::<_, i64>("SELECT COUNT(*) FROM attachments WHERE user_id=$1")
            .bind(&uid)
            .fetch_one(&h.server.state.db.pool)
            .await
            .unwrap(),
        attachments
    );
    assert_eq!(
        h.get(&format!("/plugins/{}/storage", text(&cancel, "id")))
            .await["used_bytes"],
        0
    );
    // A fresh conversation exercises all queued rounds through the same SSE owner.
    let follow = h
        .plugin(
            "export async function after(){await rofu.chat.send('follow-up');}",
            manifest(
                json!(["hooks", "send"]),
                json!({"afterReply":"after"}),
                false,
            ),
        )
        .await;
    h.attach(&c, std::slice::from_ref(&follow)).await;
    let mut model = model;
    model["tool_call"] = json!(false);
    h.json(
        Method::PUT,
        &format!("/models/{}", text(&model, "id")),
        model,
    )
    .await;
    let fresh = h
        .post("/conversations", json!({"character_id":c["id"]}))
        .await;
    let fc = text(&fresh, "id");
    let events = h
        .events(
            &format!("/conversations/{fc}/chat"),
            json!({"content":"root"}),
        )
        .await;
    assert_eq!(
        events
            .iter()
            .filter(|e| e["type"] == "user_message")
            .count(),
        plugins::MAX_FOLLOW_UPS + 1,
        "{events:?}"
    );
    assert_eq!(
        events
            .iter()
            .filter(|e| e["type"] == "assistant_done")
            .count(),
        3
    );
    assert_eq!(events.iter().filter(|e| e["type"] == "done").count(), 1);
    assert!(events
        .iter()
        .any(|e| e["type"] == "plugin_error" && e["code"] == "E_LIMIT"));
    assert_eq!(
        h.get(&format!("/conversations/{fc}")).await["generating"],
        false
    );
    h.server.stop().await.unwrap();
}
#[tokio::test]
async fn sqlite_plugin_hooks() {
    hook_suite("sqlite::memory:".into()).await;
}
#[tokio::test]
async fn postgres_plugin_hooks() {
    let Ok(url) = std::env::var("ROFU_TEST_PG_URL") else {
        return;
    };
    let (url, pool, schema) = pg_schema(&url).await;
    hook_suite(url).await;
    cleanup(pool, schema).await;
}

async fn ui_suite(database: String) {
    let h = Harness::new(database).await;
    let mock = MockServer::start().await;
    let (c, conv) = h.fixture(&mock).await;
    let cid = text(&conv, "id");
    let plugin=h.plugin(r#"export async function run(input){
        const toast=await rofu.ui.toast('hello');const notify=await rofu.ui.notify({title:'title',body:'body'});
        const reply=await rofu.ui.dialog({title:'Choose',actions:[{id:'yes',label:'Yes'},{id:'no',label:'No'}],default_action:'no',timeout_ms:input.timeout||2000,input:{label:'Text',max_length:4}});
        return {reply,toast,notify};
    }"#,manifest(json!(["ui"]),json!({}),true)).await;
    h.attach(&c, std::slice::from_ref(&plugin)).await;
    let path = format!("/plugins/{}/menus/run/invoke", text(&plugin, "id"));
    let events = h.menu(&plugin, &cid, json!({})).await;
    no_errors(&events);
    assert_eq!(
        result(&events)["reply"],
        json!({"action":"no","input":null,"reason":"unavailable"})
    );
    let events=h.events(&path,json!({"conversation_id":cid,"client_id":"test-client","ui_capabilities":["dialog"],"input":{"timeout":20}})).await;
    no_errors(&events);
    assert_eq!(result(&events)["reply"]["reason"], "timeout");
    assert_eq!(result(&events)["reply"]["action"], "no");
    let response=h.request(Method::POST,&path,json!({"conversation_id":cid,"client_id":"test-client","ui_capabilities":["toast","notify","dialog"],"input":{}})).await;
    let mut stream = response.bytes_stream();
    let mut decoder = Decoder::default();
    let mut events = vec![];
    let mut replied = false;
    while let Some(chunk) = tokio::time::timeout(Duration::from_secs(4), stream.next())
        .await
        .unwrap()
    {
        for event in decoder.push(&chunk.unwrap()) {
            let value: Value = serde_json::from_str(&event.data).unwrap();
            if value["type"] == "plugin_ui" && value["kind"] == "dialog" {
                assert!(!replied);
                replied = true;
                let call_id = text(&value, "call_id");
                // UI waits release the global coordinator mutex, but retain ownership.
                assert_eq!(
                    h.request(Method::POST, &path, json!({"conversation_id":cid}))
                        .await
                        .status(),
                    409
                );
                assert_eq!(
                    h.request(
                        Method::POST,
                        &format!("/conversations/{cid}/chat"),
                        json!({"content":"busy"})
                    )
                    .await
                    .status(),
                    409
                );
                assert_eq!(
                    h.request(
                        Method::POST,
                        &format!("/plugins/calls/{call_id}"),
                        json!({"client_id":"wrong","action":"yes"})
                    )
                    .await
                    .status(),
                    404
                );
                assert_eq!(
                    h.request(
                        Method::POST,
                        &format!("/plugins/calls/{call_id}"),
                        json!({"client_id":"test-client","action":"invalid"})
                    )
                    .await
                    .status(),
                    400
                );
                assert_eq!(
                    h.request(
                        Method::POST,
                        &format!("/plugins/calls/{call_id}"),
                        json!({"client_id":"test-client","action":"yes","input":"long input"})
                    )
                    .await
                    .status(),
                    400
                );
                h.post(
                    &format!("/plugins/calls/{call_id}"),
                    json!({"client_id":"test-client","action":"yes","input":"ok"}),
                )
                .await;
                assert_eq!(
                    h.request(
                        Method::POST,
                        &format!("/plugins/calls/{call_id}"),
                        json!({"client_id":"test-client","action":"yes"})
                    )
                    .await
                    .status(),
                    404
                );
            }
            events.push(value);
        }
    }
    assert!(replied, "{events:?}");
    no_errors(&events);
    assert_eq!(
        result(&events)["reply"],
        json!({"action":"yes","input":"ok","reason":"answered"})
    );
    assert_eq!(result(&events)["toast"]["delivered"], true);
    assert_eq!(result(&events)["notify"]["delivered"], true);
    assert!(h.server.state.plugins.dialogs.lock().await.is_empty());
    h.server.stop().await.unwrap();
}
#[tokio::test]
async fn sqlite_plugin_dialogs() {
    ui_suite("sqlite::memory:".into()).await;
}
#[tokio::test]
async fn postgres_plugin_dialogs() {
    let Ok(url) = std::env::var("ROFU_TEST_PG_URL") else {
        return;
    };
    let (url, pool, schema) = pg_schema(&url).await;
    ui_suite(url).await;
    cleanup(pool, schema).await;
}

#[tokio::test]
async fn async_runtime_limits_isolation_and_syntax_only_compile() {
    use rofu_core::plugins::runtime;
    use std::sync::Arc;
    use tokio_util::sync::CancellationToken;
    let host: runtime::Host = Arc::new(|_, _| {
        Box::pin(async {
            tokio::time::sleep(Duration::from_millis(10)).await;
            Ok(json!({"ok":"async I/O"}))
        })
    });
    runtime::compile("throw Error('must not execute at save');export function run(){}".into())
        .await
        .unwrap();
    assert!(runtime::compile("export function broken( {".into())
        .await
        .is_err());
    let value = runtime::run(
        "export async function run(){globalThis.leak=42;return await rofu.kv.get('x')}".into(),
        "run".into(),
        json!({}),
        json!({}),
        host.clone(),
        false,
        CancellationToken::new(),
    )
    .await
    .unwrap();
    assert_eq!(value, Value::Null); // bridge get maps absence to undefined
    let value = runtime::run(
        "export function run(){return typeof leak}".into(),
        "run".into(),
        json!({}),
        json!({}),
        host.clone(),
        false,
        CancellationToken::new(),
    )
    .await
    .unwrap();
    assert_eq!(value, "undefined");
    for code in [
        "export function run(){while(true){}}",
        "export function run(){return new Promise(()=>{})}",
    ] {
        let started = std::time::Instant::now();
        let error = runtime::run(
            code.into(),
            "run".into(),
            json!({}),
            json!({}),
            host.clone(),
            true,
            CancellationToken::new(),
        )
        .await
        .unwrap_err();
        assert!(error.to_string().contains("E_TIMEOUT"), "{error}");
        assert!(started.elapsed() < Duration::from_secs(4));
    }
    let cancel = CancellationToken::new();
    cancel.cancel();
    assert!(runtime::run(
        "export function run(){return 1}".into(),
        "run".into(),
        json!({}),
        json!({}),
        host,
        true,
        cancel
    )
    .await
    .unwrap_err()
    .to_string()
    .contains("E_CANCELLED"));
}

async fn module_suite(database: String) {
    use axum::{routing::post, Json, Router};
    use std::sync::Arc;
    let requests = Arc::new(tokio::sync::Mutex::new(vec![]));
    let captured = requests.clone();
    let listener = tokio::net::TcpListener::bind("127.0.0.1:0").await.unwrap();
    let address = listener.local_addr().unwrap();
    let app=Router::new().route("/chat/completions",post(move|Json(body):Json<Value>|{let captured=captured.clone();async move {
        captured.lock().await.push(body.clone());
        let has_result=body["messages"].as_array().unwrap().iter().any(|m|m["role"]=="tool");
        let delta=if !has_result && body["tools"].as_array().is_some_and(|a|!a.is_empty()) {json!({"tool_calls":[{"index":0,"id":"module-call","function":{"name":body["tools"][0]["function"]["name"],"arguments":"{\"n\":4}"}}]})}else{json!({"content":"module complete"})};
        ([ ("content-type","text/event-stream") ],format!("data: {}\n\ndata: [DONE]\n\n",json!({"choices":[{"delta":delta}]})))
    }}));
    let llm = tokio::spawn(async move { axum::serve(listener, app).await.unwrap() });
    let h = Harness::new(database).await;
    let mock = MockServer::start().await;
    let (c, conv) = h.fixture(&mock).await;
    let cid = text(&conv, "id");
    let mut model = h.get(&format!("/models/{}", text(&c, "model_id"))).await;
    model["tool_call"] = json!(true);
    let provider_id = text(&model, "provider_id");
    h.json(
        Method::PUT,
        &format!("/providers/{provider_id}"),
        json!({"name":"module mock","base_url":format!("http://{address}")}),
    )
    .await;
    h.json(
        Method::PUT,
        &format!("/models/{}", text(&model, "id")),
        model,
    )
    .await;
    let mut character = c.clone();
    character["memory"]["enabled"] = json!(false);
    h.json(
        Method::PUT,
        &format!("/characters/{}", text(&c, "id")),
        character,
    )
    .await;
    let mut m = manifest(json!(["storage", "network", "send"]), json!({}), true);
    m["tools"] = json!([{"id":"calculate","name":"Calculate","description":"add one","parameters":{"type":"object","properties":{"n":{"type":"integer"}},"required":["n"],"additionalProperties":false},"handler":"calculate"}]);
    let plugin=h.plugin(r#"export async function calculate(args){await rofu.kv.set('tool-value',args.n);return {n:args.n+1};}
        export async function run(input){const response=await rofu.http.request({url:input.url});const saved=await rofu.kv.get('tool-value');const send=await rofu.chat.send('from menu');return {status:response.status,body:response.body,saved,send};}
    "#,m).await;
    h.attach(&c, std::slice::from_ref(&plugin)).await;
    let events = h
        .events(
            &format!("/conversations/{cid}/chat"),
            json!({"content":"run module"}),
        )
        .await;
    no_errors(&events);
    assert_eq!(
        events.iter().find(|e| e["type"] == "tool_start").unwrap()["name"],
        format!("p_{}_calculate", text(&plugin, "id"))
    );
    assert_eq!(
        events.iter().find(|e| e["type"] == "tool_end").unwrap()["result"],
        "{\"n\":5}"
    );
    let events = h
        .menu(&plugin, &cid, json!({"url":format!("{}/models",mock.url)}))
        .await;
    no_errors(&events);
    assert_eq!(result(&events)["status"], 200, "{events:?}");
    assert_eq!(result(&events)["saved"], 4);
    assert!(result(&events)["send"]["queued_id"].is_string());
    assert_eq!(
        events
            .iter()
            .filter(|e| e["type"] == "user_message")
            .count(),
        1
    );
    assert_eq!(events.last().unwrap()["type"], "done");
    let denied = h
        .plugin(
            "export async function run(input){return await rofu.http.request({url:input.url})}",
            manifest(
                json!([{"name":"network","origins":["https://example.org"]}]),
                json!({}),
                true,
            ),
        )
        .await;
    h.attach(&c, std::slice::from_ref(&denied)).await;
    assert!(h
        .menu(&denied, &cid, json!({"url":format!("{}/models",mock.url)}))
        .await
        .iter()
        .any(|e| e["code"] == "E_PERMISSION"));
    let denied = h
        .plugin(
            "export async function run(){return await rofu.messages.list()}",
            manifest(json!([]), json!({}), true),
        )
        .await;
    h.attach(&c, std::slice::from_ref(&denied)).await;
    assert!(h
        .menu(&denied, &cid, json!({}))
        .await
        .iter()
        .any(|e| e["code"] == "E_PERMISSION"));
    h.post(
        &format!("/plugins/{}/enable", text(&denied, "id")),
        json!({"enabled":false}),
    )
    .await;
    assert_eq!(
        h.get(&format!("/conversations/{cid}/plugin_menus")).await,
        json!([])
    );
    assert_eq!(
        h.request(
            Method::POST,
            &format!("/plugins/{}/menus/run/invoke", text(&denied, "id")),
            json!({"conversation_id":cid})
        )
        .await
        .status(),
        404
    );
    h.server.stop().await.unwrap();
    llm.abort();
}
#[tokio::test]
async fn sqlite_module_tools_network_and_menu_send() {
    module_suite("sqlite::memory:".into()).await;
}
#[tokio::test]
async fn postgres_module_tools_network_and_menu_send() {
    let Ok(url) = std::env::var("ROFU_TEST_PG_URL") else {
        return;
    };
    let (url, pool, schema) = pg_schema(&url).await;
    module_suite(url).await;
    cleanup(pool, schema).await;
}

async fn cancellation_suite(database: String) {
    let h = Harness::new(database).await;
    let mock = MockServer::start().await;
    let (c, conv) = h.fixture(&mock).await;
    let cid = text(&conv, "id");
    let plugin=h.plugin("export async function run(){await rofu.kv.set('rolled-back',1);await rofu.messages.insert({role:'user',content:'rolled-back'});return await rofu.ui.dialog({title:'Waiting',actions:[{id:'no',label:'No'}],default_action:'no',timeout_ms:5000})}",manifest(json!(["ui","storage","write"]),json!({}),true)).await;
    h.attach(&c, std::slice::from_ref(&plugin)).await;
    for revoke in [false, true] {
        let response=h.request(Method::POST,&format!("/plugins/{}/menus/run/invoke",text(&plugin,"id")),json!({"conversation_id":cid,"client_id":"cancelling-client","ui_capabilities":["dialog"]})).await;
        let mut stream = response.bytes_stream();
        let mut decoder = Decoder::default();
        let mut events = vec![];
        let mut call = None;
        while let Some(chunk) = tokio::time::timeout(Duration::from_secs(6), stream.next())
            .await
            .unwrap()
        {
            for event in decoder.push(&chunk.unwrap()) {
                let value: Value = serde_json::from_str(&event.data).unwrap();
                if value["type"] == "plugin_ui" && value["kind"] == "dialog" {
                    call = Some(text(&value, "call_id"));
                    if revoke {
                        h.post(
                            &format!("/plugins/{}/enable", text(&plugin, "id")),
                            json!({"enabled":false}),
                        )
                        .await;
                        h.post(
                            &format!("/plugins/calls/{}", call.as_ref().unwrap()),
                            json!({"client_id":"cancelling-client","action":"no"}),
                        )
                        .await;
                    } else {
                        h.post(&format!("/conversations/{cid}/stop"), json!({}))
                            .await;
                    }
                }
                events.push(value);
            }
        }
        assert!(call.is_some());
        assert!(
            events.iter().any(|e| e["type"] == "plugin_error"
                && e["code"]
                    == if revoke {
                        "E_PERMISSION"
                    } else {
                        "E_CANCELLED"
                    }),
            "{events:?}"
        );
        assert_eq!(
            h.get(&format!("/conversations/{cid}/messages")).await,
            json!([])
        );
        assert_eq!(
            h.get(&format!("/plugins/{}/storage", text(&plugin, "id")))
                .await["used_bytes"],
            0
        );
        assert!(h.server.state.plugins.dialogs.lock().await.is_empty());
        assert_eq!(
            h.request(
                Method::POST,
                &format!("/plugins/calls/{}", call.unwrap()),
                json!({"client_id":"cancelling-client","action":"no"})
            )
            .await
            .status(),
            404
        );
    }
    h.server.stop().await.unwrap();
}
#[tokio::test]
async fn sqlite_plugin_stop_and_revoke() {
    cancellation_suite("sqlite::memory:".into()).await;
}
#[tokio::test]
async fn postgres_plugin_stop_and_revoke() {
    let Ok(url) = std::env::var("ROFU_TEST_PG_URL") else {
        return;
    };
    let (url, pool, schema) = pg_schema(&url).await;
    cancellation_suite(url).await;
    cleanup(pool, schema).await;
}
