mod support;
use futures_util::StreamExt;
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
        let tool = self.get("/plugins").await[0].clone();
        let c=self.post("/characters",json!({"name":"Rofu","model_id":m["id"],"card":{"first_mes":"Hello {{user}}, I am {{char}}"},"plugin_ids":[tool["id"]],"mcp":[{"name":"search","url":format!("{}/{}",mock.url,if transport=="sse"{"legacy"}else{"mcp"}),"transport":transport,"enabled":true}]})).await;
        let conv = self
            .post("/conversations", json!({"character_id":c["id"]}))
            .await;
        (m, c, conv)
    }
    async fn events(&self, cid: &str, body: Value) -> Vec<Value> {
        let response = self
            .request(
                Method::POST,
                &format!("/conversations/{cid}/chat"),
                body.clone(),
            )
            .await;
        let status = response.status();
        if status != 200 {
            panic!(
                "chat {cid}: {body}: {status}: {}",
                response.text().await.unwrap()
            );
        }
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
// Capture upstream requests, including the exact empty-content retry sent by Flutter.
async fn retry_history(h: &Harness, mock: &MockServer) {
    for instant in [false, true] {
        for tools in [false, true] {
            let (model, mut c, _) = h.fixture(mock, "openai", "http").await;
            c["card"] = json!({"system_prompt":"retry history system","post_history_instructions":"Retry as {{char}}"});
            c["context"] =
                json!({"instant":instant,"display_recent":0,"compress_threshold":999999});
            c["memory"] = json!({"enabled":tools,"auto_scan":false});
            if !tools {
                c["plugin_ids"] = json!([]);
                c["mcp"] = json!([]);
            }
            h.json(
                Method::PUT,
                &format!("/characters/{}", text(&c, "id")),
                c.clone(),
            )
            .await;
            let conv = h
                .post("/conversations", json!({"character_id":c["id"]}))
                .await;
            let cid = text(&conv, "id");
            // Avoid unrelated asynchronous title requests in the capture window.
            h.json(
                Method::PATCH,
                &format!("/conversations/{cid}"),
                json!({"title":"Retry regression"}),
            )
            .await;
            let mut last_send = Value::Null;
            for round in 1..=3 {
                let start = mock.state.requests.lock().await.len();
                h.events(&cid, json!({"content":format!("history user {round}")}))
                    .await;
                last_send = mock.state.requests.lock().await[start].clone();
            }
            let stored = h.get(&format!("/conversations/{cid}/messages")).await;
            assert_eq!(stored.as_array().unwrap().len(), 6);
            let last = &stored[5];
            h.json(
                Method::PATCH,
                &format!("/messages/{}", text(last, "id")),
                json!({"content":"OLD SWIPE MUST NOT LEAK","actual":"OLD ACTUAL MUST NOT LEAK"}),
            )
            .await;
            let start = mock.state.requests.lock().await.len();
            h.events(&cid, json!({"regenerate":true,"content":"","images":[]}))
                .await;
            let captured = mock.state.requests.lock().await[start..].to_vec();
            let upstream = &captured[0];
            assert_eq!(upstream, &last_send);
            let history = upstream["messages"].as_array().unwrap();
            assert_eq!(history[0]["role"], "system");
            assert_eq!(history.iter().filter(|m| m["role"] == "system").count(), 1);
            assert!(text(&history[0], "content").contains("retry history system"));
            assert!(text(&history[0], "content").ends_with("\n\nRetry as Rofu"));
            let users: Vec<_> = history
                .iter()
                .filter(|m| m["role"] == "user")
                .map(|m| text(m, "content"))
                .collect();
            assert_eq!(
                users,
                vec!["history user 1", "history user 2", "history user 3"]
            );
            assert_eq!(history.last().unwrap()["content"], "history user 3");
            let assistants: Vec<_> = history
                .iter()
                .filter(|m| m["role"] == "assistant")
                .collect();
            if instant {
                assert_eq!(assistants.len(), 2);
                assert!(assistants.iter().all(|m| m["content"] == "Rofu replied."));
            } else if tools {
                assert_eq!(assistants.len(), 5); // three tool calls + final text, then second reply
                assert_eq!(history.iter().filter(|m| m["role"] == "tool").count(), 3);
                assert_eq!(assistants.last().unwrap()["content"], "Answer complete");
            } else {
                assert_eq!(assistants.len(), 2);
                assert!(assistants.iter().all(|m| m["content"] == "Answer complete"));
            }
            assert!(assistants
                .iter()
                .all(|m| !text(m, "content").is_empty() || m["tool_calls"].is_array()));
            assert!(!upstream.to_string().contains("OLD SWIPE"));
            assert!(!upstream.to_string().contains("OLD ACTUAL"));
            assert_eq!(
                upstream["tools"].as_array().is_some_and(|t| !t.is_empty()),
                tools
            );
            assert_eq!(upstream["model"], model["model_id"]);
            let owner = text(&h.get("/auth/me").await, "id");
            let raw = h
                .server
                .state
                .db
                .message(&owner, &text(last, "id"))
                .await
                .unwrap()
                .unwrap();
            assert_eq!(raw["swipe_index"], 1);
            assert_eq!(raw["swipes"].as_array().unwrap().len(), 2);
            assert_eq!(raw["swipes"][0]["content"], "OLD SWIPE MUST NOT LEAK");
            assert_eq!(raw["swipes"][0]["actual"], "OLD ACTUAL MUST NOT LEAK");
            for key in [
                "content",
                "parts",
                "actual",
                "actual_status",
                "actual_error",
                "usage",
                "model",
                "model_name",
                "model_icon",
                "created_at",
            ] {
                assert_eq!(raw[key], raw["swipes"][1][key], "{key}");
            }
            if instant {
                assert_eq!(raw["actual_status"], "ok");
                assert_eq!(raw["actual"], "Rofu replied.");
            }
        }
    }
}

async fn merged_system_context(h: &Harness, mock: &MockServer) {
    let owner = text(&h.get("/auth/me").await, "id");
    for kind in ["openai", "responses"] {
        let provider = h
            .post("/providers", json!({"kind":kind,"base_url":mock.url}))
            .await;
        let model = h
            .post(
                "/models",
                json!({"provider_id":provider["id"],"model_id":"plain","tool_call":false}),
            )
            .await;
        let character = h
            .post(
                "/characters",
                json!({
                    "name":"Rofu","model_id":model["id"],
                    "memory":{"enabled":false},
                    "context":{"compress_threshold":999999},
                    "card":{
                        "system_prompt":"System {{char}}",
                        "description":"Description",
                        "character_book":{"entries":[{"constant":true,"content":"World lore"}]},
                        "post_history_instructions":"Post <BOT> {{user}}"
                    }
                }),
            )
            .await;
        let conv = h
            .post("/conversations", json!({"character_id":character["id"]}))
            .await;
        let cid = text(&conv, "id");
        h.json(
            Method::PATCH,
            &format!("/conversations/{cid}"),
            json!({"title":"Merged system regression"}),
        )
        .await;
        // Include summaries separated by a retained reply, as well as a hidden summary.
        for (seq, role, content, visible) in [
            (1000, "summary", "早先摘要", true),
            (2000, "assistant", "Retained reply", true),
            (3000, "summary", "Later summary", true),
            (4000, "summary", "Hidden summary", false),
        ] {
            let mut m = rofu_core::chat::message(&cid, seq, role, content);
            m["visible"] = json!(visible);
            h.server.state.db.save_message(&owner, &m).await.unwrap();
        }
        let expected_system = "System Rofu\n\nDescription\n\nWorld lore\n\n[Summary of the earlier conversation]\n早先摘要\n\n[Summary of the earlier conversation]\nLater summary\n\nPost Rofu User";
        let stats = h.get(&format!("/conversations/{cid}/context")).await;
        assert_eq!(stats["estimated"], true);
        assert_eq!(
            stats["tokens"],
            rofu_core::context::tokens(expected_system)
                + 4
                + rofu_core::context::tokens("Retained reply")
                + 4
        );

        let mut previous_history: Vec<Value> = vec![];
        let mut last_send = Value::Null;
        for round in 1..=2 {
            let start = mock.state.requests.lock().await.len();
            let events = h
                .events(&cid, json!({"content":format!("Continue {round}")}))
                .await;
            assert!(!events.iter().any(|e| e["type"] == "error"), "{events:?}");
            let captured = mock.state.requests.lock().await[start..].to_vec();
            assert_eq!(captured.len(), 1);
            let upstream = &captured[0];
            let history = if kind == "responses" {
                assert_eq!(upstream["instructions"], expected_system);
                let input = upstream["input"].as_array().unwrap();
                assert!(input
                    .iter()
                    .all(|m| matches!(m["role"].as_str(), Some("user" | "assistant"))));
                input.clone()
            } else {
                let messages = upstream["messages"].as_array().unwrap();
                assert_eq!(
                    messages[0],
                    json!({"role":"system","content":expected_system})
                );
                assert!(messages[1..]
                    .iter()
                    .all(|m| matches!(m["role"].as_str(), Some("user" | "assistant"))));
                messages[1..].to_vec()
            };
            assert!(!upstream.to_string().contains("Hidden summary"));
            assert_eq!(history.len(), 2 * round);
            assert_eq!(
                &history[..previous_history.len()],
                previous_history.as_slice()
            );
            previous_history = history;
            last_send = upstream.clone();
        }
        let start = mock.state.requests.lock().await.len();
        h.events(&cid, json!({"regenerate":true,"content":"","images":[]}))
            .await;
        let captured = mock.state.requests.lock().await[start..].to_vec();
        assert_eq!(captured, vec![last_send]);
    }
}

async fn swipe_contract(h: &Harness, mock: &MockServer) {
    let p = h.post("/providers", json!({"base_url":mock.url})).await;
    let model = h
        .post("/models", json!({"provider_id":p["id"],"model_id":"plain"}))
        .await;
    let c = h.post("/characters", json!({"name":"Swipy","model_id":model["id"],"memory":{"enabled":false},"card":{"first_mes":"First {{char}} {{user}}","alternate_greetings":["Alternate {{char}} {{user}}","Third {{char}}"]}})).await;
    let conv = h
        .post(
            "/conversations",
            json!({"character_id":c["id"],"greeting_index":0}),
        )
        .await;
    let cid = text(&conv, "id");
    let greeting = h.get(&format!("/conversations/{cid}/messages")).await[0].clone();
    assert_eq!(greeting["content"], "Alternate Swipy User");
    assert_eq!(greeting["swipe_index"], 1);
    assert_eq!(greeting["swipe_count"], 3);
    assert!(greeting.get("swipes").is_none());
    let gid = text(&greeting, "id");
    for (index, expected) in [(0, "First Swipy User"), (2, "Third Swipy")] {
        let selected = h
            .post(&format!("/messages/{gid}/swipe"), json!({"index":index}))
            .await;
        assert_eq!(selected["messages"][0]["content"], expected);
        let upstream = rofu_core::context::build(
            &c,
            &json!({}),
            selected["messages"].as_array().unwrap(),
            &[],
            false,
        );
        assert_eq!(upstream.last().unwrap()["content"], expected);
    }
    assert_eq!(
        h.request(
            Method::POST,
            &format!("/conversations/{cid}/chat"),
            json!({"regenerate":true,"content":"","images":[]})
        )
        .await
        .status(),
        400
    );
    for body in [
        json!({"index":-1}),
        json!({"index":3}),
        json!({"index":1.5}),
        json!({}),
    ] {
        assert_eq!(
            h.request(Method::POST, &format!("/messages/{gid}/swipe"), body)
                .await
                .status(),
            400
        );
    }
    let removed = h
        .json(
            Method::DELETE,
            &format!("/messages/{gid}/swipes/2"),
            json!({}),
        )
        .await;
    assert_eq!(removed["messages"][0]["content"], "Alternate Swipy User");
    assert_eq!(removed["messages"][0]["swipe_index"], 1);
    h.json(
        Method::DELETE,
        &format!("/messages/{gid}/swipes/0"),
        json!({}),
    )
    .await;
    assert_eq!(
        h.request(
            Method::DELETE,
            &format!("/messages/{gid}/swipes/0"),
            json!({})
        )
        .await
        .status(),
        400
    );

    h.json(
        Method::PATCH,
        &format!("/conversations/{cid}"),
        json!({"title":"Swipe contract"}),
    )
    .await;
    let owner = text(&h.get("/auth/me").await, "id");
    let old_image = h
        .server
        .state
        .db
        .put_attachment(&owner, "data:image/png;base64,b2xk")
        .await
        .unwrap();
    let new_image = h
        .server
        .state
        .db
        .put_attachment(&owner, "data:image/png;base64,bmV3")
        .await
        .unwrap();
    let events = h
        .events(
            &cid,
            json!({"content":"Original user","images":[old_image.clone()]}),
        )
        .await;
    let user = events.iter().find(|e| e["type"] == "user_message").unwrap()["message"].clone();
    let assistant = events
        .iter()
        .find(|e| e["type"] == "assistant_done")
        .unwrap()["message"]
        .clone();
    let uid = text(&user, "id");
    let aid = text(&assistant, "id");
    // Every newly persisted message already has its first snapshot.
    let raw = h
        .server
        .state
        .db
        .message(&owner, &uid)
        .await
        .unwrap()
        .unwrap();
    assert_eq!(raw["swipes"].as_array().unwrap().len(), 1);
    assert_eq!(raw["swipe_index"], 0);
    assert_eq!(user["swipe_index"], 0);
    assert_eq!(user["swipe_count"], 1);
    assert_eq!(
        h.post(&format!("/messages/{uid}/swipe"), json!({"index":0}))
            .await["messages"][1]["id"],
        assistant["id"]
    );

    // PATCH only changes active text and preserves reasoning/tools at their original positions.
    let mut raw = h
        .server
        .state
        .db
        .message(&owner, &aid)
        .await
        .unwrap()
        .unwrap();
    let reasoning = json!({"type":"reasoning","text":"retained reasoning","duration_ms":17});
    let tool = json!({"type":"tool","id":"retained-call","name":"dice","arguments":"{}","result":"7","duration_ms":9});
    raw["parts"]["segments"] =
        json!([reasoning,{"type":"text","text":"before"},tool,{"type":"text","text":"after"}]);
    h.server.state.db.save_message(&owner, &raw).await.unwrap();
    let patched = h
        .json(
            Method::PATCH,
            &format!("/messages/{aid}"),
            json!({"content":"Original assistant","actual":"old actual"}),
        )
        .await;
    assert_eq!(
        patched["parts"]["segments"],
        json!([reasoning,{"type":"text","text":"Original assistant"},tool])
    );
    assert_eq!(patched["swipe_count"], 1);
    // Add an extra following message: regenerate keeps the immediate assistant only.
    let suffix = rofu_core::chat::message(&cid, 4000, "system", "discarded suffix");
    // greeting=1000, user=2000, assistant=3000
    h.server
        .state
        .db
        .save_message(&owner, &suffix)
        .await
        .unwrap();
    let events = h
        .events(&cid, json!({"regenerate":true,"content":"","images":[]}))
        .await;
    let started = &events
        .iter()
        .find(|e| e["type"] == "assistant_start")
        .unwrap()["message"];
    assert_eq!(started["id"], assistant["id"]);
    assert_eq!(started["swipe_index"], 1);
    assert_eq!(started["swipe_count"], 2);
    assert_eq!(started["content"], "");
    assert_eq!(started["actual_status"], "none");
    assert!(started["actual"].is_null() && started["actual_error"].is_null());
    for event in &events {
        if event["message"].is_object() {
            assert!(event["message"].get("swipes").is_none(), "{event}");
            assert!(event["message"]["swipe_count"].is_number());
        }
    }
    assert_eq!(
        h.get(&format!("/conversations/{cid}")).await["message_count"],
        3
    );
    let switched = h
        .post(&format!("/messages/{aid}/swipe"), json!({"index":0}))
        .await;
    assert_eq!(switched["messages"][0]["content"], "Original assistant");
    assert_eq!(switched["messages"][0]["actual"], "old actual");
    assert_eq!(
        switched["messages"][0]["parts"]["segments"],
        patched["parts"]["segments"]
    );
    h.json(
        Method::PATCH,
        &format!("/messages/{aid}"),
        json!({"content":"Saved active assistant"}),
    )
    .await;
    assert_eq!(
        h.post(&format!("/messages/{aid}/swipe"), json!({"index":1}))
            .await["messages"][0]["content"],
        "Answer complete"
    );
    assert_eq!(
        h.post(&format!("/messages/{aid}/swipe"), json!({"index":0}))
            .await["messages"][0]["content"],
        "Saved active assistant"
    );
    let deleted = h
        .json(
            Method::DELETE,
            &format!("/messages/{aid}/swipes/0"),
            json!({}),
        )
        .await;
    assert_eq!(deleted["messages"][0]["content"], "Answer complete");
    assert_eq!(deleted["messages"][0]["swipe_count"], 1);

    // A user edit archives the entire original branch, including nested assistant swipes.
    h.events(&cid, json!({"content":"Original second user"}))
        .await;
    let nested = h.get(&format!("/conversations/{cid}/messages")).await[3].clone();
    h.events(
        &cid,
        json!({"edit_message_id":nested["id"],"content":"Nested edited user"}),
    )
    .await;
    let original = h.server.state.db.messages(&owner, &cid).await.unwrap();
    let edit_events = h
        .events(
            &cid,
            json!({"edit_message_id":uid,"content":"Edited user","images":[new_image.clone()]}),
        )
        .await;
    assert_eq!(edit_events[0]["message"]["swipe_count"], 2);
    assert_eq!(edit_events[0]["message"]["swipe_index"], 1);
    let edited = h.server.state.db.messages(&owner, &cid).await.unwrap();
    assert_eq!(edited.len(), 3);
    assert_eq!(edited[1]["swipes"][0]["tail"], json!(original[2..]));
    assert_eq!(edited[1]["swipes"][1]["tail"], json!([]));
    assert_eq!(edited[1]["parts"]["images"], json!([new_image.clone()]));
    assert_eq!(
        h.get(&format!("/conversations/{cid}/messages?limit=2"))
            .await["messages"][0]["swipe_count"],
        2
    );
    let restored = h
        .post(&format!("/messages/{uid}/swipe"), json!({"index":0}))
        .await;
    assert_eq!(restored["messages"].as_array().unwrap().len(), 4);
    assert_eq!(restored["messages"][0]["content"], "Original user");
    assert_eq!(
        restored["messages"][0]["parts"]["images"],
        json!([old_image.clone()])
    );
    let restored_raw = h.server.state.db.messages(&owner, &cid).await.unwrap();
    assert_eq!(restored_raw[2..], original[2..]);
    assert_eq!(restored_raw[1]["swipes"][0]["tail"], json!([]));
    assert_eq!(restored_raw[1]["swipes"][1]["tail"], json!(edited[2..]));
    assert!(h
        .server
        .state
        .db
        .message(&owner, &text(&edited[2], "id"))
        .await
        .unwrap()
        .is_none());
    let current_tail = restored_raw[2..].to_vec();
    h.json(
        Method::PATCH,
        &format!("/messages/{uid}"),
        json!({"content":"Saved user only"}),
    )
    .await;
    assert_eq!(
        h.server.state.db.messages(&owner, &cid).await.unwrap()[2..],
        current_tail
    );
    assert_eq!(
        h.post(&format!("/messages/{uid}/swipe"), json!({"index":1}))
            .await["messages"][1]["id"],
        edited[2]["id"]
    );
    assert_eq!(
        h.post(&format!("/messages/{uid}/swipe"), json!({"index":0}))
            .await["messages"][0]["content"],
        "Saved user only"
    );
    // Deleting the active user version restores the adjacent branch and removes its archive.
    let deleted = h
        .json(
            Method::DELETE,
            &format!("/messages/{uid}/swipes/0"),
            json!({}),
        )
        .await;
    assert_eq!(deleted["messages"][0]["content"], "Edited user");
    assert_eq!(deleted["messages"][0]["swipe_index"], 0);
    assert_eq!(deleted["messages"][0]["swipe_count"], 1);
    assert_eq!(deleted["messages"][1]["id"], edited[2]["id"]);
    assert_eq!(
        h.request(
            Method::DELETE,
            &format!("/messages/{uid}/swipes/0"),
            json!({})
        )
        .await
        .status(),
        400
    );
    // Delete an inactive user version without changing the active branch.
    h.events(
        &cid,
        json!({"edit_message_id":uid,"content":"Third version"}),
    )
    .await;
    let before = h.server.state.db.messages(&owner, &cid).await.unwrap();
    let deleted = h
        .json(
            Method::DELETE,
            &format!("/messages/{uid}/swipes/0"),
            json!({}),
        )
        .await;
    assert_eq!(deleted["messages"][0]["content"], "Third version");
    assert_eq!(
        h.server.state.db.messages(&owner, &cid).await.unwrap()[2..],
        before[2..]
    );

    // Branch copies only active contents and starts a fresh one-swipe history.
    let branch = h
        .post(
            &format!("/messages/{}/branch", text(&before[2], "id")),
            json!({}),
        )
        .await;
    let copies = h
        .server
        .state
        .db
        .messages(&owner, &text(&branch, "id"))
        .await
        .unwrap();
    assert_eq!(copies.len(), 3);
    for (copy, source) in copies.iter().zip(before.iter()) {
        assert_ne!(copy["id"], source["id"]);
        assert_eq!(copy["content"], source["content"]);
        assert_eq!(copy["swipes"].as_array().unwrap().len(), 1);
        assert_eq!(copy["swipe_index"], 0);
        for key in ["tail", "swipe_count"] {
            assert!(copy.get(key).is_none());
        }
    }
    // If there is no following assistant, regenerate creates one as before.
    h.json(
        Method::DELETE,
        &format!("/messages/{}", text(&before[2], "id")),
        json!({}),
    )
    .await;
    let events = h.events(&cid, json!({"regenerate":true})).await;
    let new_assistant = events
        .iter()
        .find(|e| e["type"] == "assistant_done")
        .unwrap()["message"]
        .clone();
    assert_ne!(new_assistant["id"], before[2]["id"]);
    assert_eq!(new_assistant["swipe_count"], 1);

    // Failed and stopped regenerations preserve both the old swipe and the partial new one.
    for model_id in ["stream-error", "slow"] {
        let mut configured = model.clone();
        configured["model_id"] = json!(model_id);
        h.json(
            Method::PUT,
            &format!("/models/{}", text(&model, "id")),
            configured,
        )
        .await;
        if model_id == "stream-error" {
            let events = h.events(&cid, json!({"regenerate":true})).await;
            let done = &events
                .iter()
                .find(|e| e["type"] == "assistant_done")
                .unwrap()["message"];
            assert_eq!(done["content"], "partial");
            assert!(!text(&done["parts"], "error").is_empty());
            assert_eq!(done["swipe_count"], 2);
        } else {
            let stream = h
                .request(
                    Method::POST,
                    &format!("/conversations/{cid}/chat"),
                    json!({"regenerate":true}),
                )
                .await;
            tokio::time::sleep(Duration::from_millis(1250)).await;
            let aid = text(&new_assistant, "id");
            for (method, path, body) in [
                (
                    Method::POST,
                    format!("/messages/{aid}/swipe"),
                    json!({"index":0}),
                ),
                (
                    Method::DELETE,
                    format!("/messages/{aid}/swipes/0"),
                    json!({}),
                ),
                (
                    Method::POST,
                    format!("/messages/{uid}/swipe"),
                    json!({"index":0}),
                ),
            ] {
                assert_eq!(h.request(method, &path, body).await.status(), 409);
            }
            h.post(&format!("/conversations/{cid}/stop"), json!({}))
                .await;
            h.idle(&cid).await;
            drop(stream);
            let m = h.get(&format!("/messages/{aid}")).await;
            assert_eq!(m["swipe_count"], 3);
            assert!(!text(&m, "content").is_empty());
            assert!(text(&m, "content").len() < 150);
            assert_eq!(
                h.post(&format!("/messages/{aid}/swipe"), json!({"index":0}))
                    .await["messages"][0]["content"],
                "Answer complete"
            );
        }
    }
    // Inject a restoration collision: SQL failure must roll back archiving and selection.
    let mut user_raw = h
        .server
        .state
        .db
        .message(&owner, &uid)
        .await
        .unwrap()
        .unwrap();
    let mut conflicting = rofu_core::chat::message(&cid, 9999, "assistant", "collision");
    conflicting["id"] = json!(gid); // existing greeting id, before the user
    let mut inactive = user_raw["swipes"][0].clone();
    inactive["tail"] = json!([conflicting]);
    user_raw["swipes"].as_array_mut().unwrap().push(inactive);
    h.server
        .state
        .db
        .save_message(&owner, &user_raw)
        .await
        .unwrap();
    let snapshot = h.server.state.db.messages(&owner, &cid).await.unwrap();
    assert_eq!(
        h.request(
            Method::POST,
            &format!("/messages/{uid}/swipe"),
            json!({"index":1})
        )
        .await
        .status(),
        500
    );
    assert_eq!(
        h.server.state.db.messages(&owner, &cid).await.unwrap(),
        snapshot
    );
}

async fn active_prompt_history(h: &Harness, mock: &MockServer) {
    let provider = h.post("/providers", json!({"base_url":mock.url})).await;
    let model = h
        .post(
            "/models",
            json!({"provider_id":provider["id"],"model_id":"plain"}),
        )
        .await;
    let character = h.post("/characters",json!({"model_id":model["id"],"card":{"first_mes":"Active greeting","alternate_greetings":["SECRET_INACTIVE_GREETING"]},"context":{"keep_recent":1,"compress_threshold":999999}})).await;
    let conv = h
        .post("/conversations", json!({"character_id":character["id"]}))
        .await;
    let cid = text(&conv, "id");
    h.json(
        Method::PATCH,
        &format!("/conversations/{cid}"),
        json!({"title":"Active prompt history"}),
    )
    .await;
    let events = h
        .events(&cid, json!({"content":"SECRET_ARCHIVED_USER"}))
        .await;
    let user = &events[0]["message"];
    h.events(
        &cid,
        json!({"edit_message_id":user["id"],"content":"Active user"}),
    )
    .await;
    h.events(&cid, json!({"regenerate":true})).await;
    let start = mock.state.requests.lock().await.len();
    h.post(&format!("/conversations/{cid}/memory_scan"), json!({}))
        .await;
    h.post(&format!("/conversations/{cid}/compress"), json!({}))
        .await;
    let captured = mock.state.requests.lock().await[start..].to_vec();
    assert_eq!(captured.len(), 2);
    for request in &captured {
        let input = text(&request["messages"][1], "content");
        assert!(input.contains("Active greeting"));
        assert!(input.contains("Active user"));
        for forbidden in [
            "SECRET_INACTIVE_GREETING",
            "SECRET_ARCHIVED_USER",
            "swipes",
            "tail",
        ] {
            assert!(!input.contains(forbidden), "{input}");
        }
    }
}

fn expected_page(messages: Value, has_more: bool) -> Value {
    let chars: u64 = messages
        .as_array()
        .unwrap()
        .iter()
        .map(rofu_core::db::message_chars)
        .sum();
    let bytes = serde_json::to_vec(&messages).unwrap().len();
    json!({"messages":messages,"has_more":has_more,"chars":chars,"bytes":bytes})
}

async fn wait_title(h: &Harness, cid: &str) -> String {
    tokio::time::timeout(Duration::from_secs(10), async {
        loop {
            let title = text(&h.get(&format!("/conversations/{cid}")).await, "title");
            if !title.is_empty() {
                return title;
            }
            tokio::time::sleep(Duration::from_millis(10)).await;
        }
    })
    .await
    .expect("title task did not finish")
}

async fn title_generation(h: &Harness, mock: &MockServer) {
    for kind in ["openai", "responses"] {
        title_generation_for_provider(h, mock, kind).await;
    }
}

async fn title_generation_for_provider(h: &Harness, mock: &MockServer, kind: &str) {
    let provider = h
        .post("/providers", json!({"kind":kind,"base_url":mock.url}))
        .await;
    let role = h
        .post(
            "/models",
            json!({"provider_id":provider["id"],"model_id":"role-title-regression"}),
        )
        .await;
    let fast_model = json!({
        "provider_id":provider["id"], "model_id":"fast-title-regression",
        "max_output":73, "reasoning":true,
    });
    let fast = h.post("/models", fast_model).await;
    let fail = h
        .post(
            "/models",
            json!({"provider_id":provider["id"],"model_id":"fail"}),
        )
        .await;
    let character = h
        .post(
            "/characters",
            json!({"name":"Title regression","model_id":role["id"]}),
        )
        .await;
    let input = "\n \t\n  一二三四五六七八九十 甲乙丙丁戊己庚辛壬癸 子丑寅卯\nignored second line";
    let fallback = "一二三四五六七八九十 甲乙丙丁戊己庚辛壬…";
    let mut cases: Vec<(String, Option<String>, String, bool)> = vec![
        ("".into(), None, fallback.into(), false),
        ("missing-model".into(), None, fallback.into(), false),
        (
            text(&fast, "id"),
            Some(String::new()),
            fallback.into(),
            true,
        ),
    ];
    cases.extend([
        (text(&fast, "id"), Some("<thinking>hidden\nreasoning</thinking>\n<think>more hidden</think>\n\n### **Title: 《“一二三四五六七八九十甲乙丙丁戊己庚辛壬癸子丑寅卯辰巳”》**\nNever use this line".into()), "一二三四五六七八九十甲乙丙丁戊己庚辛壬癸子丑寅卯…".into(), true),
        (text(&fast, "id"), Some("\n **标题：《  hello   world  》**\nextra line".into()), "hello world".into(), true),
        (text(&fast, "id"), Some("<thinking>only reasoning</thinking>\n**Title: 《》**".into()), fallback.into(), true),
        (text(&fail, "id"), None, fallback.into(), true),
    ]);
    for (mid, output, expected, called) in cases {
        h.json(
            Method::PUT,
            "/settings",
            json!({"fast_model_id":mid,"default_model_id":role["id"]}),
        )
        .await;
        *mock.state.title.lock().await = output;
        let conv = h
            .post("/conversations", json!({"character_id":character["id"]}))
            .await;
        let cid = text(&conv, "id");
        let start = mock.state.requests.lock().await.len();
        let events = h.events(&cid, json!({"content":input})).await;
        assert!(!events.iter().any(|e| e["type"] == "error"), "{events:?}");
        assert_eq!(wait_title(h, &cid).await, expected);
        let requests = mock.state.requests.lock().await[start..].to_vec();
        assert_eq!(requests.len(), if called { 2 } else { 1 }, "{requests:?}");
        assert_eq!(requests[0]["model"], "role-title-regression");
        if called {
            assert_ne!(requests[1]["model"], "role-title-regression");
            assert_uncapped_short_request(&requests[1]);
            if mid == text(&fast, "id") {
                assert_eq!(requests[1]["model"], "fast-title-regression");
                let instruction = upstream_system(&requests[1]);
                for required in [
                    "16 Chinese characters",
                    "6 English words",
                    "user's language",
                    "No quotes or trailing punctuation",
                ] {
                    assert!(instruction.contains(required), "{instruction}");
                }
            }
        }
    }
    h.json(Method::PUT, "/settings", json!({})).await;
    *mock.state.title.lock().await = None;
    let conv = h
        .post("/conversations", json!({"character_id":character["id"]}))
        .await;
    let cid = text(&conv, "id");
    h.events(
        &cid,
        json!({"content":"","images":["data:image/png;base64,eA=="]}),
    )
    .await;
    assert_eq!(wait_title(h, &cid).await, "New chat");
    // An empty title on a later turn still derives from the first user message.
    h.json(
        Method::PATCH,
        &format!("/conversations/{cid}"),
        json!({"title":""}),
    )
    .await;
    h.events(&cid, json!({"content":"This is the second user message"}))
        .await;
    assert_eq!(wait_title(h, &cid).await, "New chat");
}

async fn conversation_map(h: &Harness) {
    let character = h
        .post("/characters", json!({"name":"Conversation map"}))
        .await;
    let conv = h
        .post("/conversations", json!({"character_id":character["id"]}))
        .await;
    let cid = text(&conv, "id");
    let uid = text(&h.get("/auth/me").await, "id");
    assert_eq!(
        h.get(&format!("/conversations/{cid}/map")).await,
        json!({"items":[],"total":0,"has_more":false})
    );
    for query in ["around_seq=0&limit=3", "after_seq=0&limit=3"] {
        let empty = h
            .get(&format!("/conversations/{cid}/messages?{query}"))
            .await;
        assert_eq!(empty["messages"], json!([]));
        assert_eq!(empty["has_more_before"], false);
        assert_eq!(empty["has_more_after"], false);
        assert_eq!(empty["bytes"], 2);
    }
    let contents = [
        (
            "user",
            "  ## > - 你好🙂\t 世界\n1. 第二行\n```rust\n代码\n```",
        ),
        ("assistant", "ignored stale content"),
        ("summary", "# Earlier summary"),
        (
            "user",
            "abcdefghijklmnopqrstuvwxyz HELLO_%\\中文 后面还有文字文字",
        ),
        ("assistant", "Plain HELLO"),
        ("user", "other text"),
        ("assistant", ""),
    ];
    for (i, (role, content)) in contents.iter().enumerate() {
        let mut m = rofu_core::chat::message(&cid, (i as i64 + 1) * 1000, role, content);
        if i == 0 {
            m["visible"] = json!(false);
        }
        if i == 1 {
            m["parts"] = json!({"images":[h.server.state.db.put_attachment(&uid,"data:image/png;base64,eA==").await.unwrap()], "segments":[
                {"type":"reasoning","text":"PRIVATE REASONING"},
                {"type":"text","text":"# Hello "},
                {"type":"tool","arguments":"PRIVATE ARGUMENTS","result":"PRIVATE RESULT"},
                {"type":"text","text":"中文"}
            ]});
            m["swipes"] = json!([{"content":"PRIVATE INACTIVE"},{}]);
            m["swipe_index"] = json!(1);
        }
        if i == 6 {
            m["parts"]["segments"] = json!([{"type":"reasoning","text":"PRIVATE REASONING ONLY"}]);
        }
        h.server.state.db.save_message(&uid, &m).await.unwrap();
    }
    let map = h.get(&format!("/conversations/{cid}/map")).await;
    let items = map["items"].as_array().unwrap();
    assert_eq!(items.len(), 7);
    assert_eq!(map["total"], 7);
    assert_eq!(map["has_more"], false);
    assert_eq!(items[0]["preview"], "你好🙂 世界 第二行 代码");
    assert_eq!(items[0]["chars"], contents[0].1.chars().count());
    assert_eq!(items[0]["visible"], false);
    assert_eq!(items[1]["preview"], "Hello 中文");
    assert_eq!(items[1]["swipe_count"], 2);
    assert_eq!(items[1]["has_images"], true);
    assert_eq!(items[2]["role"], "summary");
    assert_eq!(items[2]["kind"], "summary");
    assert_eq!(items[6]["chars"], 0);
    assert!(!map.to_string().contains("PRIVATE"));
    for item in items {
        assert!(item.get("content").is_none());
        assert!(item.get("parts").is_none());
        assert!(item.get("match_start").is_none());
    }
    for (query, expected, total) in [
        ("", "", 7),
        ("hello", "Hello", 3),
        ("HELLO", "Hello", 3),
        ("中文", "中文", 2),
        ("_%\\", "_%\\", 1),
        ("PRIVATE", "", 0),
        ("%", "%", 1),
        ("_", "_", 1),
        ("' OR 1=1 --", "", 0),
        ("你好🙂", "你好🙂", 1),
    ] {
        let encoded: String = url::form_urlencoded::Serializer::new(String::new())
            .append_pair("q", query)
            .finish();
        let page = h
            .get(&format!("/conversations/{cid}/map?chars=8&{encoded}"))
            .await;
        assert_eq!(page["total"], total, "{query}: {page}");
        if !query.is_empty() && total > 0 {
            let item = &page["items"][0];
            let hit: String = text(item, "preview")
                .chars()
                .skip(item["match_start"].as_u64().unwrap() as usize)
                .take(item["match_len"].as_u64().unwrap() as usize)
                .collect();
            assert_eq!(hit, expected);
        }
    }
    let window = h
        .get(&format!("/conversations/{cid}/map?chars=8&q=hello_%25"))
        .await;
    assert!(text(&window["items"][0], "preview").starts_with('…'));
    assert!(text(&window["items"][0], "preview").ends_with('…'));
    let page = h
        .get(&format!("/conversations/{cid}/map?limit=2&before_seq=5000"))
        .await;
    assert_eq!(page["items"], json!([items[2], items[3]]));
    assert_eq!(page["total"], 7);
    assert_eq!(page["has_more"], true);
    let page = h
        .get(&format!("/conversations/{cid}/map?limit=2&before_seq=3000"))
        .await;
    assert_eq!(page["items"], json!([items[0], items[1]]));
    assert_eq!(page["has_more"], false);
    let page = h
        .get(&format!(
            "/conversations/{cid}/map?q=hello&limit=1&before_seq=5000"
        ))
        .await;
    assert_eq!(page["total"], 3);
    assert_eq!(page["items"][0]["seq"], 4000);
    assert_eq!(page["has_more"], true);
    let all = h.get(&format!("/conversations/{cid}/messages")).await;
    for (query, start, end, before, after) in [
        ("around_seq=4000&limit=4", 1, 5, true, true),
        ("around_seq=4000&limit=3", 2, 5, true, true),
        ("around_seq=4000&limit=1", 3, 4, true, true),
        ("around_seq=3500&limit=4", 1, 5, true, true),
        ("around_seq=1000&limit=4", 0, 2, false, true),
        ("around_seq=7000&limit=4", 4, 7, true, false),
        ("around_seq=9223372036854775807&limit=4", 5, 7, true, false),
        ("around_seq=-9223372036854775808&limit=4", 0, 2, false, true),
        ("around_seq=4000", 0, 7, false, false),
        ("after_seq=2000&limit=3", 2, 5, true, true),
        ("after_seq=0&limit=3", 0, 3, false, true),
        ("after_seq=7000&limit=3", 7, 7, true, false),
        ("after_seq=9223372036854775807&limit=3", 7, 7, true, false),
        ("after_seq=0", 0, 7, false, false),
        ("after_seq=2000&max_chars=0", 2, 5, true, true),
        ("after_seq=2000&max_chars=0&limit=1", 2, 3, true, true),
    ] {
        let page = h
            .get(&format!("/conversations/{cid}/messages?{query}"))
            .await;
        let selected = json!(&all.as_array().unwrap()[start..end]);
        let expected = expected_page(selected, false);
        for key in ["messages", "chars", "bytes"] {
            assert_eq!(page[key], expected[key], "{query}: {key}");
        }
        assert_eq!(page["has_more_before"], before, "{query}");
        assert_eq!(page["has_more_after"], after, "{query}");
        assert_eq!(
            page["has_more"],
            if query.starts_with("around") {
                before || after
            } else {
                after
            },
            "{query}"
        );
    }
    for (route, query) in [
        ("map", "limit=0"),
        ("map", "limit=-1"),
        ("map", "chars=no"),
        ("map", "before_seq=no"),
        ("messages", "around_seq=no"),
        ("messages", "after_seq=no"),
        ("messages", "around_seq=2&after_seq=3"),
        ("messages", "after_seq=2&before_seq=3"),
        ("messages", "around_seq=2&before_seq=3"),
        ("messages", "around_seq=2&max_chars=100"),
        ("messages", "after_seq=2&limit=0"),
        ("messages", "after_seq=2&max_chars=-1"),
    ] {
        assert_eq!(
            h.request(
                Method::GET,
                &format!("/conversations/{cid}/{route}?{query}"),
                json!({})
            )
            .await
            .status(),
            400,
            "{query}"
        );
    }
    let foreign = rofu_core::auth::create(
        &h.server.state.db,
        &format!("map_{}", id()),
        "secret",
        false,
    )
    .await
    .unwrap();
    let login = rofu_core::auth::login(
        &h.server.state.db,
        &json!({"username":foreign["username"],"password":"secret"}),
    )
    .await
    .unwrap();
    for route in [
        "map",
        "map?q=hello",
        "messages?around_seq=4000&limit=3",
        "messages?after_seq=2000&limit=3",
    ] {
        assert_eq!(
            h.client
                .get(format!("{}/conversations/{cid}/{route}", h.base))
                .bearer_auth(text(&login, "token"))
                .send()
                .await
                .unwrap()
                .status(),
            404
        );
    }

    // Bulk insert outside the measured HTTP request, with representative active
    // text, reasoning/tool segments, images and inactive versions.
    let conv = h
        .post("/conversations", json!({"character_id":character["id"]}))
        .await;
    let cid = text(&conv, "id");
    let reference = h
        .server
        .state
        .db
        .put_attachment(&uid, "data:image/png;base64,eA==")
        .await
        .unwrap();
    let mut tx = h.server.state.db.pool.begin().await.unwrap();
    for i in 1..=10_000 {
        let mut m = rofu_core::chat::message(
            &cid,
            i * 1000,
            if i % 2 == 0 { "assistant" } else { "user" },
            &"你好🙂 conversation map text ".repeat(4),
        );
        if i % 2 == 0 {
            m["parts"]["segments"] = json!([
                {"type":"reasoning","text":"private ".repeat(20)},
                {"type":"text","text":m["content"]},
                {"type":"tool","arguments":"{}","result":"ignored result"}
            ]);
            m["swipes"] = json!([{"content":"old inactive","parts":{"images":[reference]}},{}]);
        }
        sqlx::query(
            "INSERT INTO messages(id,user_id,conversation_id,seq,data) VALUES ($1,$2,$3,$4,$5)",
        )
        .bind(text(&m, "id"))
        .bind(&uid)
        .bind(&cid)
        .bind(i * 1000)
        .bind(m.to_string())
        .execute(&mut *tx)
        .await
        .unwrap();
    }
    tx.commit().await.unwrap();
    let start = std::time::Instant::now();
    let large = h.get(&format!("/conversations/{cid}/map")).await;
    let elapsed = start.elapsed();
    eprintln!("10k conversation map HTTP smoke: {elapsed:?}");
    assert!(
        elapsed < Duration::from_secs(1),
        "10k conversation map took {elapsed:?}"
    );
    assert_eq!(large["items"].as_array().unwrap().len(), 10_000);
    assert_eq!(large["total"], 10_000);
    assert_eq!(large["has_more"], false);
    for (width, expected) in [
        ("0", 8),
        ("-1", 8),
        (
            "999",
            "你好🙂 conversation map text "
                .repeat(4)
                .trim()
                .chars()
                .count(),
        ),
    ] {
        let page = h
            .get(&format!("/conversations/{cid}/map?chars={width}&limit=1"))
            .await;
        assert_eq!(text(&page["items"][0], "preview").chars().count(), expected);
    }
    let page = h
        .get(&format!("/conversations/{cid}/map?limit=9999&q=你好"))
        .await;
    assert_eq!(page["items"].as_array().unwrap().len(), 5000);
    assert_eq!(page["total"], 10_000);
    assert_eq!(page["has_more"], true);
}

async fn character_pagination(h: &Harness) {
    let character = h
        .post("/characters", json!({"name":"Pagination regression"}))
        .await;
    let conv = h
        .post("/conversations", json!({"character_id":character["id"]}))
        .await;
    let cid = text(&conv, "id");
    let uid = text(&h.get("/auth/me").await, "id");
    for (i, (role, content)) in [
        ("assistant", "开场"),
        ("user", "一"),
        ("assistant", "答"),
        ("user", "二"),
        ("assistant", "答"),
        ("user", "你🙂"),
        ("assistant", "答复"),
    ]
    .into_iter()
    .enumerate()
    {
        let mut m = rofu_core::chat::message(&cid, (i as i64 + 1) * 1000, role, content);
        if i == 6 {
            m["parts"]["segments"] = json!([
                {"type":"text","text":"答复"},
                {"type":"reasoning","text":"想🙂"},
                {"type":"tool","name":"ignored tool name","arguments":"{\"问\":\"🙂\"}","result":"结果🙂"}
            ]);
            m["actual"] = json!("ignored actual ".repeat(100));
            m["parts"]["images"] = json!([h
                .server
                .state
                .db
                .put_attachment(&uid, "data:image/png;base64,eA==")
                .await
                .unwrap()]);
            let active = m.clone();
            let mut inactive = active.clone();
            inactive["content"] = json!("ignored inactive swipe".repeat(100));
            m["swipes"] = json!([inactive, active]);
            m["swipe_index"] = json!(1);
        }
        if i == 2 {
            m["visible"] = json!(false);
        }
        h.server.state.db.save_message(&uid, &m).await.unwrap();
    }
    let all = h.get(&format!("/conversations/{cid}/messages")).await;
    assert!(all.is_array());
    assert_eq!(
        h.get(&format!("/conversations/{cid}/messages?before_seq=0"))
            .await["messages"],
        json!([])
    );
    for (query, start, chars, more) in [
        ("max_chars=0", 5, 18, true),
        ("max_chars=1", 5, 18, true),
        ("max_chars=17", 5, 18, true),
        ("max_chars=18", 5, 18, true),
        ("max_chars=20", 3, 20, true),
        ("max_chars=100", 0, 24, false),
        ("max_chars=1&limit=1", 6, 16, true),
        ("max_chars=1&limit=3", 5, 18, true),
        ("max_chars=100&limit=3", 4, 19, true),
        ("limit=1", 6, 16, true),
    ] {
        let page = h
            .get(&format!("/conversations/{cid}/messages?{query}"))
            .await;
        assert_eq!(
            page["messages"],
            json!(&all.as_array().unwrap()[start..]),
            "{query}"
        );
        assert_eq!(page["chars"], chars, "{query}");
        assert_eq!(
            page["bytes"],
            serde_json::to_vec(&page["messages"]).unwrap().len()
        );
        assert_eq!(page["has_more"], more);
        assert!(page["messages"]
            .as_array()
            .unwrap()
            .iter()
            .all(|m| m.get("swipes").is_none()));
    }
    let mut before = None;
    let mut combined = Vec::new();
    loop {
        let cursor = before.map_or(String::new(), |seq: i64| format!("&before_seq={seq}"));
        let page = h
            .get(&format!(
                "/conversations/{cid}/messages?max_chars=1{cursor}"
            ))
            .await;
        let messages = page["messages"].as_array().unwrap();
        assert!(!messages.is_empty());
        before = messages[0]["seq"].as_i64();
        combined.splice(0..0, messages.iter().cloned());
        if page["has_more"] == false {
            break;
        }
    }
    assert_eq!(json!(combined), all);
    assert_eq!(
        h.get(&format!(
            "/conversations/{cid}/messages?max_chars=1&before_seq=0"
        ))
        .await,
        json!({"messages":[],"has_more":false,"chars":0,"bytes":2})
    );
    for query in [
        "max_chars=-1",
        "max_chars=no",
        "max_chars=1.5",
        "max_chars=18446744073709551616",
        "max_chars=1&before_seq=no",
        "max_chars=1&limit=0",
    ] {
        assert_eq!(
            h.request(
                Method::GET,
                &format!("/conversations/{cid}/messages?{query}"),
                json!({})
            )
            .await
            .status(),
            400,
            "{query}"
        );
    }
}

// Run these contracts against both databases and both provider wire formats.
async fn instant_summary_contract(h: &Harness, mock: &MockServer) {
    h.json(
        Method::PUT,
        "/settings",
        json!({"user_name":"Alice","user_persona":"A traveler named Alice"}),
    )
    .await;
    let settings = h.get("/settings").await;
    for kind in ["openai", "responses"] {
        let (mut model, mut c, _) = h.fixture(mock, kind, "http").await;
        model["max_output"] = json!(73);
        h.json(
            Method::PUT,
            &format!("/models/{}", text(&model, "id")),
            model.clone(),
        )
        .await;
        c["card"] = json!({"system_prompt":"Switch contract"});
        c["plugin_ids"] = json!([]);
        c["mcp"] = json!([]);
        c["memory"] = json!({"enabled":false});
        let character_path = format!("/characters/{}", text(&c, "id"));
        for (instant, summarize) in [(false, false), (false, true), (true, false), (true, true)] {
            c["context"] = json!({"instant":instant,"summarize":summarize,"keep_recent":1,"display_recent":0,"compress_threshold":1});
            let saved = h.json(Method::PUT, &character_path, c.clone()).await;
            let conv = h
                .post("/conversations", json!({"character_id":c["id"]}))
                .await;
            let cid = text(&conv, "id");
            let ev = h.events(&cid, json!({"content":"Alice arrived."})).await;
            assert_eq!(ev.iter().any(|e| e["type"] == "actual"), instant);
            assert_eq!(ev.iter().any(|e| e["type"] == "summary"), summarize);
            let history = h.get(&format!("/conversations/{cid}/messages")).await;
            let assistant = history
                .as_array()
                .unwrap()
                .iter()
                .find(|m| m["role"] == "assistant")
                .unwrap();
            assert_eq!(
                assistant["actual_status"],
                if instant { "ok" } else { "none" }
            );
            let stats = h.get(&format!("/conversations/{cid}/context")).await;
            assert_eq!(stats["instant"], instant);
            assert_eq!(stats["summarize"], summarize);
            let built = rofu_core::context::build(
                &saved,
                &settings,
                history.as_array().unwrap(),
                &[],
                false,
            );
            if instant || summarize {
                assert_eq!(stats["estimated"], true);
                assert_eq!(stats["tokens"], rofu_core::context::estimate(&built, &[]));
            }
            if summarize {
                // Next round hides the previous actual; the summary input must use it.
                mock.state.requests.lock().await.clear();
                let ev = h.events(&cid, json!({"content":"Alice continued."})).await;
                assert!(ev.iter().any(|e| e["type"] == "summary"));
                let requests = mock.state.requests.lock().await.clone();
                let summary = requests
                    .iter()
                    .find(|r| upstream_system(r).starts_with("Summarize"))
                    .unwrap();
                let input: Vec<Value> = serde_json::from_str(&upstream_user(summary)).unwrap();
                let old_assistant = input.iter().find(|m| m["role"] == "assistant").unwrap();
                assert_eq!(
                    old_assistant["content"],
                    if instant {
                        "Rofu replied."
                    } else {
                        "Answer complete"
                    }
                );
                let history = h.get(&format!("/conversations/{cid}/messages")).await;
                assert_eq!(
                    history
                        .as_array()
                        .unwrap()
                        .iter()
                        .find(|m| m["id"] == assistant["id"])
                        .unwrap()["visible"],
                    false
                );
                let context = rofu_core::context::build(
                    &saved,
                    &settings,
                    history.as_array().unwrap(),
                    &[],
                    false,
                );
                assert_eq!(context.len(), 2); // merged system + retained assistant
                assert!(!text(&context[0], "content").contains("Alice arrived"));
                h.post(&format!("/conversations/{cid}/compress"), json!({}))
                    .await;
            } else {
                let before = h.get(&format!("/conversations/{cid}/messages")).await;
                let response = h
                    .request(
                        Method::POST,
                        &format!("/conversations/{cid}/compress"),
                        json!({}),
                    )
                    .await;
                assert_eq!(response.status(), 400);
                assert!(response
                    .text()
                    .await
                    .unwrap()
                    .contains("context.summarize=false"));
                assert_eq!(
                    h.get(&format!("/conversations/{cid}/messages")).await,
                    before
                );
            }
        }

        // Feed a stored reply with private reasoning, duplicated segments, and oversized tools.
        c["context"] = json!({"instant":true,"summarize":false,"display_recent":0});
        c["params"] = json!({"max_tokens":9999,"reasoning_effort":"high"});
        h.json(Method::PUT, &character_path, c.clone()).await;
        let conv = h
            .post("/conversations", json!({"character_id":c["id"]}))
            .await;
        let cid = text(&conv, "id");
        let ev = h.events(&cid, json!({"content":"Start."})).await;
        let mut reply = ev.iter().find(|e| e["type"] == "actual").unwrap()["message"].clone();
        let visible = "Rofu met Alice at the gate, returned her silver key, and promised to wait for her until dawn.";
        reply["content"] = json!(format!("<think>PRIVATE THINK</think>{visible}"));
        reply["parts"]["segments"] = json!([
            {"type":"reasoning","text":"PRIVATE REASONING"},
            {"type":"text","text":"DUPLICATE SEGMENT"},
            {"type":"tool","id":"RAW TOOL ID","name":"dice","arguments":"骰".repeat(121),"result":"点".repeat(201)}
        ]);
        reply["swipes"] = json!([reply.clone()]);
        reply["swipe_index"] = json!(0);
        sqlx::query("UPDATE messages SET data=$1 WHERE id=$2")
            .bind(reply.to_string())
            .bind(text(&reply, "id"))
            .execute(&h.server.state.db.pool)
            .await
            .unwrap();
        let actual_path = format!("/messages/{}/actual", text(&reply, "id"));
        mock.state.requests.lock().await.clear();
        *mock.state.actual.lock().await =
            ["<think>private output</think>摘要： **“Rofu\treturned Alice's key.”**".into()].into();
        let cleaned = h.post(&actual_path, json!({})).await;
        assert_eq!(cleaned["actual"], "Rofu returned Alice's key.");
        assert_eq!(cleaned["actual_status"], "ok");
        let requests = mock.state.requests.lock().await.clone();
        assert_eq!(requests.len(), 1);
        assert_eq!(
            upstream_user(&requests[0]),
            format!(
                "Condense the following roleplay reply.\n<reply>\n{visible}\n[tool] dice({}) → {}\n</reply>",
                "骰".repeat(120),
                "点".repeat(200)
            )
        );
        let system = upstream_system(&requests[0]);
        for required in [
            "Rofu",
            "Alice",
            "one fifth",
            "120 CJK",
            "80 English",
            "never invent",
            "third person",
            "past tense",
        ] {
            assert!(system.contains(required), "missing {required}: {system}");
        }
        assert_eq!(requests[0]["model"], model["model_id"]); // unchanged character-model fallback
        assert!(system.contains("never a message to answer or continue"));
        assert_uncapped_short_request(&requests[0]);
        // The mock streams reasoning before the visible note; only content is accepted.
        assert!(!text(&cleaned, "actual").contains("reasoning"));

        // An overlong or empty cleaned response retries once, using exactly the same input.
        for first in [
            "长".repeat(2000),
            "<think>empty</think>摘要： **\"\"**".into(),
            "<think>reasoning only</think>".into(),
        ] {
            mock.state.requests.lock().await.clear();
            let first_length = first.chars().count();
            *mock.state.actual.lock().await =
                [first, "Summary: 'Rofu waited for Alice.'".into()].into();
            let retried = h.post(&actual_path, json!({})).await;
            assert_eq!(retried["actual_status"], "ok");
            assert_eq!(retried["actual"], "Rofu waited for Alice.");
            let requests = mock.state.requests.lock().await.clone();
            assert_eq!(requests.len(), 2);
            for request in &requests {
                assert_uncapped_short_request(request);
            }
            assert_eq!(upstream_user(&requests[0]), upstream_user(&requests[1]));
            let input_length =
                visible.chars().count() + "\n[tool] dice() → ".chars().count() + 120 + 200;
            let limit = (input_length / 5).clamp(1, 120);
            let expected = if first_length == 2000 {
                format!("Your previous output was 2000 characters; the limit is {limit}. Output only the note.")
            } else {
                "Your previous output was empty".into()
            };
            assert!(upstream_system(&requests[1]).contains(&expected));
        }
        mock.state.requests.lock().await.clear();
        *mock.state.actual.lock().await = ["长".repeat(2000), "<think>empty</think>".into()].into();
        let failed = h.post(&actual_path, json!({})).await;
        assert_eq!(failed["actual_status"], "failed");
        assert!(failed["actual"].is_null());
        assert!(text(&failed, "actual_error").contains("two attempts"));
        assert_eq!(mock.state.requests.lock().await.len(), 2);
        let error = text(&failed, "actual_error");
        assert!(
            error.contains("attempt 1: 2000 characters over the limit"),
            "{error}"
        );
        assert!(error.contains("attempt 2: reasoning-only"), "{error}");
        assert!(
            error.contains("last content preview (first 160 characters): \"<think>empty</think>\""),
            "{error}"
        );

        // A valid note survives long thought tails and arbitrary presentation wrappers.
        for output in [
            format!(
                "Rofu helped Alice.<think>{}",
                "unfinished thought ".repeat(100)
            ),
            format!(
                "Rofu helped Alice.<thinking>{}",
                "unfinished thought ".repeat(100)
            ),
            "<note>Rofu helped Alice.</note>".into(),
            "<reply>Rofu helped Alice.</reply>".into(),
            "```unexpected-language\nRofu helped Alice.\n```".into(),
        ] {
            mock.state.requests.lock().await.clear();
            *mock.state.actual.lock().await = [output].into();
            let cleaned = h.post(&actual_path, json!({})).await;
            assert_eq!(cleaned["actual_status"], "ok");
            assert_eq!(cleaned["actual"], "Rofu helped Alice.");
            assert_eq!(mock.state.requests.lock().await.len(), 1);
        }

        // Provider cutoffs with empty content are identified even without reasoning deltas.
        for reasoning in [
            String::new(),
            format!("PRIVATE MODEL REASONING {} END", "思".repeat(200)),
        ] {
            mock.state.requests.lock().await.clear();
            *mock.state.actual_reasoning.lock().await = Some(reasoning.clone());
            let failed = h.post(&actual_path, json!({})).await;
            *mock.state.actual_reasoning.lock().await = None;
            assert_eq!(failed["actual_status"], "failed");
            assert!(failed["actual"].is_null());
            let error = text(&failed, "actual_error");
            let expected = "truncated while reasoning";
            assert!(error.contains(&format!("attempt 1: {expected}")), "{error}");
            assert!(error.contains(&format!("attempt 2: {expected}")), "{error}");
            assert!(
                error.contains("last reasoning preview (first 160 characters)"),
                "{error}"
            );
            assert!(!error.contains("last output"), "{error}");
            assert!(error.contains(&reasoning.chars().take(160).collect::<String>()));
            assert!(!error.contains(" END"));
            let requests = mock.state.requests.lock().await.clone();
            assert_eq!(requests.len(), 2);
            for request in &requests {
                assert_uncapped_short_request(request);
            }
            assert!(upstream_system(&requests[1]).contains("Your previous output was empty"));
            mock.state.actual.lock().await.clear();
        }

        // Preserve partial raw content when a provider fails mid-stream.
        let mut broken_model = model.clone();
        broken_model["model_id"] = json!("stream-error");
        let model_path = format!("/models/{}", text(&model, "id"));
        h.json(Method::PUT, &model_path, broken_model).await;
        let failed = h.post(&actual_path, json!({})).await;
        assert_eq!(failed["actual_status"], "failed");
        let error = text(&failed, "actual_error");
        assert!(error.contains("attempt 1: provider error"), "{error}");
        assert!(error.contains("mock stream failure"), "{error}");
        assert!(
            error.contains("last content preview (first 160 characters): \"partial\""),
            "{error}"
        );
        h.json(Method::PUT, &model_path, model.clone()).await;
        let history = h.get(&format!("/conversations/{cid}/messages")).await;
        let built =
            rofu_core::context::build(&c, &settings, history.as_array().unwrap(), &[], false);
        assert!(!built
            .iter()
            .any(|m| text(m, "content") == "Rofu waited for Alice."));
    }
    h.json(Method::PUT, "/settings", json!({})).await;
}

fn assert_uncapped_short_request(request: &Value) {
    for key in [
        "max_tokens",
        "max_output_tokens",
        "max_completion_tokens",
        "reasoning",
        "reasoning_effort",
        "thinking",
        "enable_thinking",
    ] {
        assert!(request.get(key).is_none(), "unexpected {key}: {request}");
    }
}

fn upstream_system(request: &Value) -> String {
    if request.get("input").is_some() {
        text(request, "instructions")
    } else {
        text(&request["messages"][0], "content")
    }
}
fn upstream_user(request: &Value) -> String {
    if request.get("input").is_some() {
        request["input"]
            .as_array()
            .unwrap()
            .iter()
            .find(|m| m["role"] == "user")
            .unwrap()["content"][0]["text"]
            .as_str()
            .unwrap()
            .to_owned()
    } else {
        text(&request["messages"][1], "content")
    }
}

async fn attachment_contract(h: &Harness, mock: &MockServer) {
    use base64::{engine::general_purpose::STANDARD, Engine};
    // A large image proves the JSON page transfers references, not encoded bytes.
    let bytes = vec![7u8; 512 * 1024];
    let data_url = format!("data:image/png;base64,{}", STANDARD.encode(&bytes));
    let reference = h.post("/attachments", json!({"data_url":data_url})).await;
    assert_eq!(reference["bytes"], bytes.len());
    let path = format!("/attachments/{}", text(&reference, "id"));
    let response = h.request(Method::GET, &path, json!({})).await;
    assert_eq!(response.status(), 200);
    assert_eq!(
        response.headers()["cache-control"],
        "private, max-age=31536000, immutable"
    );
    let etag = response.headers()["etag"].clone();
    assert_eq!(response.bytes().await.unwrap().as_ref(), bytes);
    let cached = h
        .client
        .get(format!("{}{path}", h.base))
        .bearer_auth(&h.token)
        .header("if-none-match", etag)
        .send()
        .await
        .unwrap();
    assert_eq!(cached.status(), 304);
    assert_eq!(
        h.client
            .get(format!("{}{path}", h.base))
            .send()
            .await
            .unwrap()
            .status(),
        401
    );
    let other = rofu_core::auth::create(
        &h.server.state.db,
        &format!("blob-{}", id()),
        "secret",
        false,
    )
    .await
    .unwrap();
    assert!(h
        .server
        .state
        .db
        .attachment(&text(&other, "id"), &text(&reference, "id"))
        .await
        .unwrap()
        .is_none());
    let other_login = rofu_core::auth::login(
        &h.server.state.db,
        &json!({"username":other["username"],"password":"secret"}),
    )
    .await
    .unwrap();
    let denied = h
        .client
        .get(format!("{}{path}", h.base))
        .bearer_auth(text(&other_login, "token"))
        .header("if-none-match", "*")
        .send()
        .await
        .unwrap();
    assert_eq!(
        denied.status(),
        404,
        "conditional requests must still check ownership"
    );
    assert_eq!(
        h.client
            .get(format!("{}{path}?token={}", h.base, h.token))
            .send()
            .await
            .unwrap()
            .bytes()
            .await
            .unwrap()
            .as_ref(),
        bytes
    );
    let duplicate = h.post("/attachments", json!({"data_url":data_url})).await;
    assert_eq!(duplicate, reference);
    let mut png_bytes = Vec::new();
    {
        let encoder = png::Encoder::new(&mut png_bytes, 2, 1);
        let mut writer = encoder.write_header().unwrap();
        writer.write_image_data(&[0, 0]).unwrap();
    }
    let png_url = format!("data:image/png;base64,{}", STANDARD.encode(&png_bytes));
    let png_ref = h.post("/attachments", json!({"data_url":png_url})).await;
    assert_eq!(png_ref["width"], 2);
    assert_eq!(png_ref["height"], 1);
    let (mut model, mut character, _) = h.fixture(mock, "openai", "http").await;
    model["vision"] = json!(true);
    h.json(
        Method::PUT,
        &format!("/models/{}", text(&model, "id")),
        model,
    )
    .await;
    character["plugin_ids"] = json!([]);
    character["mcp"] = json!([]);
    character["memory"] = json!({"enabled":false});
    character["context"] = json!({"summarize":false,"instant":false});
    character["avatar"] = json!(data_url);
    let character = h
        .json(
            Method::PUT,
            &format!("/characters/{}", text(&character, "id")),
            character,
        )
        .await;
    assert!(text(&character, "avatar").starts_with("/api/attachments/"));
    assert!(!h
        .get("/characters")
        .await
        .to_string()
        .contains("data:image"));
    for kind in ["openai", "responses"] {
        let model = h
            .get(&format!("/models/{}", text(&character, "model_id")))
            .await;
        let mut provider = h
            .get(&format!("/providers/{}", text(&model, "provider_id")))
            .await;
        provider["kind"] = json!(kind);
        h.json(
            Method::PUT,
            &format!("/providers/{}", text(&provider, "id")),
            provider,
        )
        .await;
        let conv = h
            .post("/conversations", json!({"character_id":character["id"]}))
            .await;
        let cid = text(&conv, "id");
        h.json(
            Method::PATCH,
            &format!("/conversations/{cid}"),
            json!({"title":"Images"}),
        )
        .await;
        let start = mock.state.requests.lock().await.len();
        let events = h
            .events(
                &cid,
                json!({"content":"Look","images":[reference.clone(),data_url]}),
            )
            .await;
        h.idle(&cid).await;
        assert!(!json!(events).to_string().contains("data:image"));
        assert!(mock.state.requests.lock().await[start..]
            .iter()
            .any(|r| r.to_string().contains(&data_url)));
        let full = h.get(&format!("/conversations/{cid}/messages")).await;
        let page = h
            .get(&format!("/conversations/{cid}/messages?max_chars=1"))
            .await;
        assert!(!full.to_string().contains("data:image"));
        assert!(!page.to_string().contains("data:image"));
        assert!(page["bytes"].as_u64().unwrap() < 20000);
        assert_eq!(
            page["bytes"].as_u64().unwrap() as usize,
            serde_json::to_vec(&page["messages"]).unwrap().len()
        );
        assert!(page["chars"].as_u64().unwrap() < 10000);
        assert_eq!(full[1]["parts"]["images"][0], reference);
        let unknown = h
            .request(
                Method::POST,
                &format!("/conversations/{cid}/chat"),
                json!({"content":"Invalid reference","images":[{"id":"missing"}]}),
            )
            .await;
        assert_eq!(unknown.status(), 400);
        let retry = h
            .events(
                &cid,
                json!({"regenerate":true,"images":[{"id":"ignored-missing"},"data:invalid"]}),
            )
            .await;
        assert!(!retry.iter().any(|e| e["type"] == "error"));
        assert!(retry.iter().any(|e| e["type"] == "assistant_done"));
    }
}

async fn extra_body_contract(h: &Harness, mock: &MockServer) {
    for kind in ["openai", "responses"] {
        let provider=h.post("/providers",json!({"name":"Overrides","kind":kind,"base_url":mock.url,"extra_body":{"provider":{"order":["anthropic"],"allow_fallbacks":false},"remove":"value"}})).await;
        let model=h.post("/models",json!({"provider_id":provider["id"],"model_id":"override-model","tool_call":false,"extra_body":{"provider":{"order":["google"]},"remove":null}})).await;
        assert_eq!(
            h.get(&format!("/providers/{}", text(&provider, "id")))
                .await["extra_body"],
            provider["extra_body"]
        );
        assert_eq!(
            h.get(&format!("/models/{}", text(&model, "id"))).await["extra_body"],
            model["extra_body"]
        );
        for value in [Value::Null, json!([]), json!("bad"), json!(false), json!(1)] {
            for path in [
                "/providers".to_string(),
                format!("/providers/{}", text(&provider, "id")),
                "/models".to_string(),
                format!("/models/{}", text(&model, "id")),
            ] {
                let method = if path.matches('/').count() == 1 {
                    Method::POST
                } else {
                    Method::PUT
                };
                let response = h
                    .request(
                        method,
                        &path,
                        json!({"provider_id":provider["id"],"extra_body":value}),
                    )
                    .await;
                assert_eq!(response.status(), 400, "{path}: {value}");
            }
        }
        h.json(
            Method::PUT,
            "/settings",
            json!({"fast_model_id":model["id"]}),
        )
        .await;
        let character=h.post("/characters",json!({"name":"Override test","model_id":model["id"],"context":{"instant":true,"summarize":true,"keep_recent":1,"compress_threshold":1},"memory":{"enabled":true,"auto_scan":false}})).await;
        let conv = h
            .post("/conversations", json!({"character_id":character["id"]}))
            .await;
        let cid = text(&conv, "id");
        let start = mock.state.requests.lock().await.len();
        h.events(
            &cid,
            json!({"content":"A long story about arriving at the village and choosing a room."}),
        )
        .await;
        wait_title(h, &cid).await;
        h.post(&format!("/conversations/{cid}/memory_scan"), json!({}))
            .await;
        let requests = mock.state.requests.lock().await[start..].to_vec();
        assert!(requests
            .iter()
            .any(|r| upstream_system(r).starts_with("Generate a short")));
        assert!(requests
            .iter()
            .any(|r| upstream_system(r).starts_with("Condense one")));
        assert!(requests
            .iter()
            .any(|r| upstream_system(r).starts_with("Summarize")));
        for body in requests {
            assert_eq!(
                body["provider"],
                json!({"order":["google"],"allow_fallbacks":false})
            );
            assert!(body.get("remove").is_none());
        }
    }
    h.json(Method::PUT, "/settings", json!({})).await;
}

async fn run_suite(database: Option<String>) {
    let is_postgres = database.is_some();
    let mock = MockServer::start().await;
    let h = Harness::new(database).await;
    attachment_contract(&h, &mock).await;
    extra_body_contract(&h, &mock).await;
    instant_summary_contract(&h, &mock).await;
    title_generation(&h, &mock).await;
    character_pagination(&h).await;
    if is_postgres {
        conversation_map(&h).await;
    }
    retry_history(&h, &mock).await;
    merged_system_context(&h, &mock).await;
    swipe_contract(&h, &mock).await;
    active_prompt_history(&h, &mock).await;
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
        let dice_call = events
            .iter()
            .find(|e| e["type"] == "tool_start" && text(e, "name").ends_with("_roll_dice"))
            .unwrap();
        let dice = events
            .iter()
            .find(|e| e["type"] == "tool_end" && e["id"] == dice_call["id"])
            .unwrap();
        assert_eq!(dice["is_error"], false, "{dice}");
        assert!(text(dice, "result").contains("= **7**"), "{dice}");
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
        assert_eq!(
            h.get(&format!("/conversations/{cid}")).await["message_count"],
            3
        );
        let page = h
            .get(&format!("/conversations/{cid}/messages?limit=2"))
            .await;
        assert_eq!(page, expected_page(json!([stored[1], stored[2]]), true));
        let page = h
            .get(&format!(
                "/conversations/{cid}/messages?limit=2&before_seq={}",
                stored[1]["seq"]
            ))
            .await;
        assert_eq!(page, expected_page(json!([stored[0]]), false));
        assert_eq!(
            h.get(&format!(
                "/conversations/{cid}/messages?limit=10&before_seq=0"
            ))
            .await,
            expected_page(json!([]), false)
        );
        assert_eq!(
            h.get(&format!("/conversations/{cid}/messages?limit=3"))
                .await,
            expected_page(stored.clone(), false)
        );
        for query in [
            "limit=0",
            "limit=-1",
            "limit=no",
            "limit=9223372036854775807",
            "limit=1&before_seq=no",
        ] {
            assert_eq!(
                h.request(
                    Method::GET,
                    &format!("/conversations/{cid}/messages?{query}"),
                    json!({})
                )
                .await
                .status(),
                400
            );
        }

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
        let stats = h.get(&format!("/conversations/{cid}/context")).await;
        assert_eq!(stats["tokens"], 120);
        assert_eq!(stats["estimated"], false);
        let imported = h
            .post(
                "/characters/import",
                json!({"json":{"spec":"chara_card_v3","data":{"name":"Imported","assets":["x"]}}}),
            )
            .await;
        let mut remote_avatar = imported.clone();
        remote_avatar["avatar"] = json!(format!("{}/avatar", mock.url));
        h.json(
            Method::PUT,
            &format!("/characters/{}", text(&imported, "id")),
            remote_avatar,
        )
        .await;
        let response = h
            .request(
                Method::GET,
                &format!("/characters/{}/export?format=png", text(&imported, "id")),
                json!({}),
            )
            .await;
        assert_eq!(response.status(), 200);
        assert_eq!(response.headers()["content-type"], "image/png");
        let exported = rofu_core::card::png_card(&response.bytes().await.unwrap()).unwrap();
        assert_eq!(exported["data"]["name"], "Imported");
        assert_eq!(exported["data"]["extensions"]["assets"], json!(["x"]));
        // Manual compression places the summary immediately before the retained tail.
        let mut cc = c.clone();
        cc["context"] = json!({"keep_recent":1,"compress_threshold":1});
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
        cc["context"] = json!({"instant":true,"display_recent":0});
        h.json(Method::PUT, &format!("/characters/{}", text(&c, "id")), cc)
            .await;
        let ev = h.events(&cid, json!({"content":"instant"})).await;
        let actual = &ev.iter().find(|e| e["type"] == "actual").unwrap()["message"];
        assert_eq!(actual["actual_status"], "ok");
        assert_eq!(actual["actual"], "Rofu replied.");
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
        let mut current = h.get(&format!("/characters/{}", text(&c, "id"))).await;
        current["context"]["keep_recent"] = json!(1);
        h.json(
            Method::PUT,
            &format!("/characters/{}", text(&c, "id")),
            current,
        )
        .await;
        let snapshot = h.get(&format!("/conversations/{cid}/messages")).await;
        assert_eq!(
            h.request(
                Method::POST,
                &format!("/conversations/{cid}/compress"),
                json!({})
            )
            .await
            .status(),
            500
        );
        assert_eq!(
            h.get(&format!("/conversations/{cid}/messages")).await,
            snapshot
        );
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
        h.events(&cid, json!({"content":"new messages for failing scan"}))
            .await;
        h.json(
            Method::PUT,
            "/settings",
            json!({"fast_model_id":fail["id"]}),
        )
        .await;
        assert_eq!(
            h.request(
                Method::POST,
                &format!("/conversations/{cid}/memory_scan"),
                json!({})
            )
            .await
            .status(),
            500
        );
        let scanned = h.get(&format!("/conversations/{cid}")).await;
        let messages = h.get(&format!("/conversations/{cid}/messages")).await;
        assert_eq!(
            scanned["memory_scanned_seq"],
            messages.as_array().unwrap().last().unwrap()["seq"]
        );
        assert_eq!(
            h.post(&format!("/conversations/{cid}/memory_scan"), json!({}))
                .await,
            json!({"added":0,"updated":0,"deleted":0})
        );
        h.json(Method::PUT, "/settings", json!({})).await;
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
    assert_eq!(
        h.request(Method::DELETE, &format!("/conversations/{cid}"), json!({}))
            .await
            .status(),
        409
    );
    assert_eq!(
        h.request(
            Method::DELETE,
            &format!("/characters/{}", text(&c, "id")),
            json!({})
        )
        .await
        .status(),
        409
    );
    assert_eq!(
        h.request(
            Method::PATCH,
            &format!("/messages/{}", text(&partial[0], "id")),
            json!({"visible":false})
        )
        .await
        .status(),
        409
    );
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
    // Provider failures keep partial assistant content and surface an error event.
    for model_id in ["stream-error", "fail", "no-usage"] {
        let mut model = m.clone();
        model["model_id"] = json!(model_id);
        h.json(Method::PUT, &format!("/models/{}", text(&m, "id")), model)
            .await;
        let ev = h.events(&cid, json!({"content":"check errors"})).await;
        let done = &ev.iter().find(|e| e["type"] == "assistant_done").unwrap()["message"];
        if model_id == "no-usage" {
            assert_eq!(done["usage"]["estimated"], true);
            assert!(done["usage"]["input"].as_i64().unwrap() > 0);
            assert!(done["usage"]["output"].as_i64().unwrap() > 0);
        } else {
            assert!(ev.iter().any(|e| e["type"] == "error"));
            assert!(!text(&done["parts"], "error").is_empty());
            if model_id == "stream-error" {
                assert_eq!(done["content"], "partial");
            }
        }
        assert_eq!(ev.last().unwrap()["type"], "done");
    }
    // Stop while the fast model is compressing, rather than while the visible reply streams.
    let fast = h
        .post("/models", json!({"provider_id":p["id"],"model_id":"slow"}))
        .await;
    h.json(
        Method::PUT,
        "/settings",
        json!({"fast_model_id":fast["id"]}),
    )
    .await;
    let mut cc = c.clone();
    cc["context"] = json!({"instant":true});
    h.json(Method::PUT, &format!("/characters/{}", text(&c, "id")), cc)
        .await;
    let response = h
        .request(
            Method::POST,
            &format!("/conversations/{cid}/chat"),
            json!({"content":"stop compression"}),
        )
        .await;
    let mut bytes = response.bytes_stream();
    let mut decoder = Decoder::default();
    tokio::time::timeout(Duration::from_secs(3), async {
        loop {
            let chunk = bytes.next().await.unwrap().unwrap();
            let events = decoder.push(&chunk);
            if events.iter().any(|e| {
                serde_json::from_str::<Value>(&e.data).unwrap()["type"] == "actual_pending"
            }) {
                break;
            }
        }
    })
    .await
    .unwrap();
    h.post(&format!("/conversations/{cid}/stop"), json!({}))
        .await;
    h.idle(&cid).await;
    drop(bytes);
    let messages = h.get(&format!("/conversations/{cid}/messages")).await;
    let last = messages.as_array().unwrap().last().unwrap();
    assert_eq!(last["actual_status"], "failed");
    assert!(text(last, "actual_error").contains("stopped"));
    // Graceful shutdown cancels a live stream and drains tracked title/scanner/agent tasks.
    let mut model = m.clone();
    model["model_id"] = json!("slow");
    h.json(Method::PUT, &format!("/models/{}", text(&m, "id")), model)
        .await;
    let response = h
        .request(
            Method::POST,
            &format!("/conversations/{cid}/chat"),
            json!({"content":"shutdown"}),
        )
        .await;
    drop(response);
    tokio::time::timeout(Duration::from_secs(3), h.server.stop())
        .await
        .unwrap()
        .unwrap();
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

#[tokio::test]
async fn sqlite_conversation_map() {
    let h = Harness::new(None).await;
    conversation_map(&h).await;
    h.server.stop().await.unwrap();
}
