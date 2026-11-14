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
// Capture upstream requests, including the exact empty-content retry sent by Flutter.
async fn retry_history(h: &Harness, mock: &MockServer) {
    for instant in [false, true] {
        for tools in [false, true] {
            let (model, mut c, _) = h.fixture(mock, "openai", "http").await;
            c["card"] = json!({"system_prompt":"retry history system","post_history_instructions":"Retry as {{char}}"});
            c["context"] = json!({"mode":if instant {"instant"} else {"traditional"},"display_recent":0,"compress_threshold":999999});
            c["memory"] = json!({"enabled":tools,"auto_scan":false});
            if !tools {
                c["tool_ids"] = json!([]);
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
                assert!(assistants
                    .iter()
                    .all(|m| m["content"] == "compressed reply"));
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
                assert_eq!(raw["actual"], "compressed reply");
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
            h.server
                .state
                .db
                .save_message(
                    &owner,
                    &json!({
                        "id":id(),"conversation_id":cid,"seq":seq,
                        "role":role,"content":content,"visible":visible
                    }),
                )
                .await
                .unwrap();
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
    assert_eq!(
        h.post(&format!("/messages/{gid}/swipe"), json!({"index":0}))
            .await["messages"][0]["content"],
        "First Swipy User"
    );
    assert_eq!(
        h.post(&format!("/messages/{gid}/swipe"), json!({"index":2}))
            .await["messages"][0]["content"],
        "Third Swipy"
    );
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
    let events = h
        .events(
            &cid,
            json!({"content":"Original user","images":["old image"]}),
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
    let owner = text(&h.get("/auth/me").await, "id");
    // Old messages remain uninitialized until their first swipe operation.
    let raw = h
        .server
        .state
        .db
        .message(&owner, &uid)
        .await
        .unwrap()
        .unwrap();
    assert!(raw.get("swipes").is_none());
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
            json!({"edit_message_id":uid,"content":"Edited user","images":["new image"]}),
        )
        .await;
    assert_eq!(edit_events[0]["message"]["swipe_count"], 2);
    assert_eq!(edit_events[0]["message"]["swipe_index"], 1);
    let edited = h.server.state.db.messages(&owner, &cid).await.unwrap();
    assert_eq!(edited.len(), 3);
    assert_eq!(edited[1]["swipes"][0]["tail"], json!(original[2..]));
    assert_eq!(edited[1]["swipes"][1]["tail"], json!([]));
    assert_eq!(edited[1]["parts"]["images"], json!(["new image"]));
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
        json!(["old image"])
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

    // Branch copies only active contents; raw persisted copies have no swipe/tail metadata.
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
        for key in ["swipes", "tail", "swipe_index", "swipe_count"] {
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

async fn run_suite(database: Option<String>) {
    let mock = MockServer::start().await;
    let h = Harness::new(database).await;
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
        assert_eq!(
            page,
            json!({"messages":[stored[1],stored[2]],"has_more":true})
        );
        let page = h
            .get(&format!(
                "/conversations/{cid}/messages?limit=2&before_seq={}",
                stored[1]["seq"]
            ))
            .await;
        assert_eq!(page, json!({"messages":[stored[0]],"has_more":false}));
        assert_eq!(
            h.get(&format!(
                "/conversations/{cid}/messages?limit=10&before_seq=0"
            ))
            .await,
            json!({"messages":[],"has_more":false})
        );
        assert_eq!(
            h.get(&format!("/conversations/{cid}/messages?limit=3"))
                .await,
            json!({"messages":stored,"has_more":false})
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
    cc["context"] = json!({"mode":"instant"});
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
