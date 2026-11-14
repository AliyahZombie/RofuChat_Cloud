mod support;
use reqwest::{Client, Method};
use rofu_core::{
    model::{id, text},
    sse::Decoder,
    start_server, Config, RunningServer,
};
use serde_json::{json, Value};
use std::time::Duration;
use support::mock::MockServer;
struct Harness {
    server: RunningServer,
    base: String,
    token: String,
    client: Client,
    _dir: tempfile::TempDir,
}
impl Harness {
    async fn new(database: Option<String>) -> Self {
        let dir = tempfile::tempdir().unwrap();
        let database =
            database.unwrap_or_else(|| format!("sqlite://{}/test.db", dir.path().display()));
        let server = start_server(Config {
            database,
            listen: "127.0.0.1:0".into(),
            root_password: Some("root-test-secret".into()),
            memory_scanner: false,
            http_client: Some(Client::builder().no_proxy().build().unwrap()),
            ..Config::default()
        })
        .await
        .unwrap();
        let base = format!("http://{}/api", server.address);
        let client = Client::builder().no_proxy().build().unwrap();
        let login: Value = client
            .post(format!("{base}/auth/login"))
            .json(&json!({"username":"root","password":"root-test-secret"}))
            .send()
            .await
            .unwrap()
            .json()
            .await
            .unwrap();
        Self {
            server,
            base,
            token: text(&login, "token"),
            client,
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
        assert!(status.is_success(), "{path}: {status} {raw}");
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
    async fn fixture(
        &self,
        mock: &MockServer,
        kind: &str,
        transport: &str,
    ) -> (Value, Value, Value) {
        let p = self
            .post(
                "/providers",
                json!({"name":"Mock","kind":kind,"base_url":mock.url,"api_key":"secret-test-key"}),
            )
            .await;
        let remote = self
            .post(
                &format!("/providers/{}/remote_models", text(&p, "id")),
                json!({}),
            )
            .await;
        assert_eq!(remote.as_array().unwrap().len(), 1);
        assert_eq!(remote[0]["context_length"], 10000);
        assert_eq!(
            self.get(&format!("/models?provider_id={}", text(&p, "id")))
                .await,
            json!([])
        );
        let m = self.post("/models", remote[0].clone()).await;
        let tool=self.post("/tools",json!({"name":"dice","code":"function main(args){console.log('rolled');return {total:args.n+1}}"})).await;
        let c=self.post("/characters",json!({"name":"Rofu","model_id":m["id"],"card":{"first_mes":"Hello {{user}}, I am {{char}}"},"tool_ids":[tool["id"]],"mcp":[{"name":"search","url":format!("{}/{}",mock.url,if transport=="sse"{"legacy"}else{"mcp"}),"transport":transport,"enabled":true}]})).await;
        let conv = self
            .post("/conversations", json!({"character_id":c["id"]}))
            .await;
        (m, c, conv)
    }
    async fn events(&self, cid: &str, body: Value) -> Vec<Value> {
        let response = self
            .request(Method::POST, &format!("/conversations/{cid}/chat"), body)
            .await;
        assert_eq!(response.status(), 200);
        let wire = response.bytes().await.unwrap();
        let mut parser = Decoder::default();
        let events = parser.push(&wire);
        events
            .into_iter()
            .map(|e| serde_json::from_str(&e.data).unwrap())
            .collect()
    }
    async fn idle(&self, cid: &str) {
        for _ in 0..500 {
            if self.get(&format!("/conversations/{cid}")).await["generating"] == false {
                return;
            }
            tokio::time::sleep(Duration::from_millis(20)).await;
        }
        panic!("generation did not finish");
    }
}
async fn run_suite(database: Option<String>) {
    let mock = MockServer::start().await;
    let h = Harness::new(database).await;
    assert_eq!(h.get("/health").await["allow_register"], false);
    let user = h
        .post(
            "/admin/users",
            json!({"username":"alice","password":"alice-secret"}),
        )
        .await;
    let login: Value = h
        .client
        .post(format!("{}/auth/login", h.base))
        .json(&json!({"username":"alice","password":"alice-secret"}))
        .send()
        .await
        .unwrap()
        .json()
        .await
        .unwrap();
    assert_eq!(login["user"]["id"], user["id"]);
    for (kind, transport) in [("openai", "http"), ("responses", "sse")] {
        let (model, c, conv) = h.fixture(&mock, kind, transport).await;
        let cid = text(&conv, "id");
        let messages = h.get(&format!("/conversations/{cid}/messages")).await;
        assert_eq!(messages[0]["content"], "Hello User, I am Rofu");
        assert_eq!(
            h.client
                .get(format!("{}/conversations/{cid}", h.base))
                .bearer_auth(text(&login, "token"))
                .send()
                .await
                .unwrap()
                .status(),
            404
        );
        assert_eq!(
            h.client
                .delete(format!("{}/characters/{}", h.base, text(&c, "id")))
                .bearer_auth(text(&login, "token"))
                .send()
                .await
                .unwrap()
                .status(),
            404
        );
        let events = h
            .events(&cid, json!({"content":"Remember I like tea"}))
            .await;
        let types: Vec<_> = events.iter().map(|e| text(e, "type")).collect();
        assert_eq!(types[0], "user_message");
        assert_eq!(types[1], "assistant_start");
        assert_eq!(types.last().unwrap(), "done");
        assert_eq!(
            types.iter().filter(|t| *t == "tool_start").count(),
            3,
            "{events:?}"
        );
        assert_eq!(types.iter().filter(|t| *t == "tool_end").count(), 3);
        assert!(!types.iter().any(|t| t == "error"), "{events:?}");
        let done = events
            .iter()
            .find(|e| e["type"] == "assistant_done")
            .unwrap();
        assert!(text(&done["message"], "content").contains("Answer complete"));
        assert_eq!(done["message"]["usage"]["input"], 200);
        assert_eq!(done["message"]["usage"]["output"], 40);
        assert_eq!(done["message"]["usage"]["cached"], 80);
        assert_eq!(done["message"]["usage"]["last_input"], 100);
        assert_eq!(done["message"]["usage"]["estimated"], false);
        let stored = h.get(&format!("/conversations/{cid}/messages")).await;
        assert_eq!(stored.as_array().unwrap().len(), 3);
        assert_eq!(stored[2], done["message"]);
        let tools: Vec<_> = stored[2]["parts"]["segments"]
            .as_array()
            .unwrap()
            .iter()
            .filter(|s| s["type"] == "tool")
            .collect();
        assert!(text(tools[0], "result").contains("7"));
        assert!(text(tools[1], "result").contains("[image]"));
        assert!(text(tools[1], "result").contains("resource text"));
        let memories = h
            .get(&format!("/memories?character_id={}", text(&c, "id")))
            .await;
        assert_eq!(memories.as_array().unwrap().len(), 1);
        assert_eq!(memories[0]["source"], "agent");
        // Manual compression places the summary immediately before the retained tail.
        let mut cc = c.clone();
        cc["context"] = json!({"mode":"traditional","keep_recent":1,"compress_threshold":1});
        h.json(Method::PUT, &format!("/characters/{}", text(&c, "id")), cc)
            .await;
        let summary = h
            .post(&format!("/conversations/{cid}/compress"), json!({}))
            .await;
        assert_eq!(summary["role"], "summary");
        assert_eq!(summary["seq"], 2999);
        let stored = h.get(&format!("/conversations/{cid}/messages")).await;
        assert_eq!(stored[0]["visible"], false);
        assert_eq!(stored[1]["visible"], false);
        assert_eq!(stored[2]["role"], "summary");
        let events = h.events(&cid, json!({"content":"next"})).await;
        assert!(events.iter().any(|e| e["type"] == "summary"), "{events:?}");
        assert!(
            events
                .iter()
                .position(|e| e["type"] == "compressing")
                .unwrap()
                < events.iter().position(|e| e["type"] == "summary").unwrap()
        );
        // Instant compression and retry failure keep the display text and fallback history intact.
        let mut cc = h.get(&format!("/characters/{}", text(&c, "id"))).await;
        cc["context"] = json!({"mode":"instant","display_recent":0});
        h.json(Method::PUT, &format!("/characters/{}", text(&c, "id")), cc)
            .await;
        let ev = h.events(&cid, json!({"content":"instant"})).await;
        let actual = &ev.iter().find(|e| e["type"] == "actual").unwrap()["message"];
        assert_eq!(actual["actual_status"], "ok");
        assert_eq!(actual["actual"], "compressed reply");
        assert!(text(actual, "content").contains("Answer complete"));
        let fail = h
            .post(
                "/models",
                json!({"provider_id":model["provider_id"],"model_id":"fail"}),
            )
            .await;
        h.json(
            Method::PUT,
            "/settings",
            json!({"fast_model_id":fail["id"]}),
        )
        .await;
        let ev = h.events(&cid, json!({"content":"instant failure"})).await;
        let actual = &ev.iter().find(|e| e["type"] == "actual").unwrap()["message"];
        assert_eq!(actual["actual_status"], "failed");
        assert!(text(actual, "actual_error").contains("500"));
        assert!(actual["actual"].is_null());
        h.json(Method::PUT, "/settings", json!({})).await;
        let retried = h
            .post(
                &format!("/messages/{}/actual", text(actual, "id")),
                json!({}),
            )
            .await;
        assert_eq!(retried["actual_status"], "ok");
        // Scan applies add/update/delete, preserves pinned, and advances the cursor even on failure.
        let pin = h
            .post(
                "/memories",
                json!({"character_id":c["id"],"content":"pinned","pinned":true}),
            )
            .await;
        let delete = h
            .post(
                "/memories",
                json!({"character_id":c["id"],"content":"obsolete"}),
            )
            .await;
        *mock.state.scan.lock().await = json!({"add":[{"content":"scan new","tags":["test"],"global":false}],"update":[{"id":memories[0]["id"],"content":"updated memory"}],"delete":[delete["id"],pin["id"]]});
        let result = h
            .post(&format!("/conversations/{cid}/memory_scan"), json!({}))
            .await;
        assert_eq!(result, json!({"added":1,"updated":1,"deleted":1}));
        let all = h
            .get(&format!("/memories?character_id={}", text(&c, "id")))
            .await;
        assert!(all.as_array().unwrap().iter().any(|m| m["id"] == pin["id"]));
        assert!(!all
            .as_array()
            .unwrap()
            .iter()
            .any(|m| m["id"] == delete["id"]));
        assert!(all
            .as_array()
            .unwrap()
            .iter()
            .any(|m| m["source"] == "scan"));
        let branch = h
            .post(
                &format!("/messages/{}/branch", text(&retried, "id")),
                json!({}),
            )
            .await;
        assert_ne!(branch["id"], conv["id"]);
        assert!(!h
            .get(&format!("/conversations/{}/messages", text(&branch, "id")))
            .await
            .as_array()
            .unwrap()
            .is_empty());
        h.json(
            Method::DELETE,
            &format!("/characters/{}", text(&c, "id")),
            json!({}),
        )
        .await;
        assert_eq!(
            h.request(Method::GET, &format!("/conversations/{cid}"), json!({}))
                .await
                .status(),
            404
        );
    }
    // Independent slow stream: duplicate exclusion, one-second snapshots, disconnect persistence and stop.
    let p = h.post("/providers", json!({"base_url":mock.url})).await;
    let m = h
        .post("/models", json!({"provider_id":p["id"],"model_id":"slow"}))
        .await;
    let c = h
        .post(
            "/characters",
            json!({"model_id":m["id"],"memory":{"enabled":false}}),
        )
        .await;
    let conv = h
        .post("/conversations", json!({"character_id":c["id"]}))
        .await;
    let cid = text(&conv, "id");
    let stream = h
        .request(
            Method::POST,
            &format!("/conversations/{cid}/chat"),
            json!({"content":"slow"}),
        )
        .await;
    assert_eq!(stream.status(), 200);
    assert_eq!(
        h.request(
            Method::POST,
            &format!("/conversations/{cid}/chat"),
            json!({"content":"duplicate"})
        )
        .await
        .status(),
        409
    );
    tokio::time::sleep(Duration::from_millis(1250)).await;
    let partial = h.get(&format!("/conversations/{cid}/messages")).await;
    assert!(!text(&partial[1], "content").is_empty());
    drop(stream);
    h.post(&format!("/conversations/{cid}/stop"), json!({}))
        .await;
    h.idle(&cid).await;
    let stopped = h.get(&format!("/conversations/{cid}/messages")).await;
    let count = text(&stopped[1], "content").len();
    assert!(count > 0 && count < 150, "{count}");
    // A disconnected fast stream still completes without a subscriber.
    let mut mm = m.clone();
    mm["model_id"] = json!("plain");
    h.json(Method::PUT, &format!("/models/{}", text(&m, "id")), mm)
        .await;
    let stream = h
        .request(
            Method::POST,
            &format!("/conversations/{cid}/chat"),
            json!({"content":"disconnect"}),
        )
        .await;
    drop(stream);
    h.idle(&cid).await;
    let stored = h.get(&format!("/conversations/{cid}/messages")).await;
    assert_eq!(
        stored.as_array().unwrap().last().unwrap()["content"],
        "Answer complete"
    );
    // Regenerate and edit truncate the old tail and preserve sequence ordering.
    let before = stored.as_array().unwrap().len();
    h.events(&cid, json!({"regenerate":true,"content":"ignored"}))
        .await;
    assert_eq!(
        h.get(&format!("/conversations/{cid}/messages"))
            .await
            .as_array()
            .unwrap()
            .len(),
        before
    );
    let first = &stored[0];
    h.events(
        &cid,
        json!({"edit_message_id":first["id"],"content":"edited"}),
    )
    .await;
    let edited = h.get(&format!("/conversations/{cid}/messages")).await;
    assert_eq!(edited.as_array().unwrap().len(), 2);
    assert_eq!(edited[0]["content"], "edited");
    h.server.stop().await.unwrap();
}
#[tokio::test]
async fn sqlite_contract_and_agent_suite() {
    run_suite(None).await;
}
#[tokio::test]
async fn postgres_contract_and_agent_suite() {
    let Ok(url) = std::env::var("ROFU_TEST_PG_URL") else {
        eprintln!("ROFU_TEST_PG_URL unset: PostgreSQL suite skipped");
        return;
    };
    sqlx::any::install_default_drivers();
    let admin = sqlx::AnyPool::connect(&url).await.unwrap();
    let name = format!("rofu_{}", id());
    sqlx::query(&format!("CREATE DATABASE {name}"))
        .execute(&admin)
        .await
        .unwrap();
    let mut database = url::Url::parse(&url).unwrap();
    database.set_path(&name);
    run_suite(Some(database.to_string())).await;
    sqlx::query(&format!("DROP DATABASE {name} WITH (FORCE)"))
        .execute(&admin)
        .await
        .unwrap();
    admin.close().await;
}
