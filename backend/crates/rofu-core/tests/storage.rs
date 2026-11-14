use rofu_core::{auth, db::Db};
use serde_json::json;

#[tokio::test]
async fn initialization_and_storage_isolation() {
    let db = Db::connect("sqlite::memory:").await.unwrap();
    assert!(auth::initialize(&db, None).await.is_err());
    auth::initialize(&db, Some("root-secret")).await.unwrap();
    assert!(!db.registration().await.unwrap());
    let root = auth::login(&db, &json!({"username":"root","password":"root-secret"}))
        .await
        .unwrap();
    assert!(root["token"].as_str().unwrap().len() >= 48);
    let a = auth::create(&db, "alice", "secret", false).await.unwrap();
    let b = auth::create(&db, "bob", "secret", false).await.unwrap();
    let uid = a["id"].as_str().unwrap();
    let v = db
        .save(uid, "character", json!({"name":"Rofu"}))
        .await
        .unwrap();
    assert!(db
        .get(
            b["id"].as_str().unwrap(),
            "character",
            v["id"].as_str().unwrap()
        )
        .await
        .unwrap()
        .is_none());
    db.set_registration(true).await.unwrap();
    assert!(db.registration().await.unwrap());
}

#[tokio::test]
async fn http_auth_and_secret_masking() {
    use rofu_core::{start_server, Config};
    let server = start_server(Config {
        database: "sqlite::memory:".into(),
        listen: "127.0.0.1:0".into(),
        root_password: Some("secret".into()),
        memory_scanner: false,
        ..Config::default()
    })
    .await
    .unwrap();
    let base = format!("http://{}/api", server.address);
    let client = reqwest::Client::builder().no_proxy().build().unwrap();
    let health: serde_json::Value = client
        .get(format!("{base}/health"))
        .send()
        .await
        .unwrap()
        .json()
        .await
        .unwrap();
    assert_eq!(health["allow_register"], false);
    assert_eq!(
        client
            .post(format!("{base}/auth/register"))
            .json(&json!({"username":"a","password":"b"}))
            .send()
            .await
            .unwrap()
            .status(),
        403
    );
    assert_eq!(
        client
            .get(format!("{base}/settings"))
            .send()
            .await
            .unwrap()
            .status(),
        401
    );
    let login: serde_json::Value = client
        .post(format!("{base}/auth/login"))
        .json(&json!({"username":"root","password":"secret"}))
        .send()
        .await
        .unwrap()
        .json()
        .await
        .unwrap();
    let token = login["token"].as_str().unwrap();
    let p: serde_json::Value = client
        .post(format!("{base}/providers"))
        .bearer_auth(token)
        .json(&json!({"name":"test","api_key":"sk-test-123456789"}))
        .send()
        .await
        .unwrap()
        .json()
        .await
        .unwrap();
    assert_eq!(p["api_key"], "sk-t…6789");
    let p2: serde_json::Value = client
        .put(format!("{base}/providers/{}", p["id"].as_str().unwrap()))
        .bearer_auth(token)
        .json(&p)
        .send()
        .await
        .unwrap()
        .json()
        .await
        .unwrap();
    assert_eq!(p["api_key"], p2["api_key"]);
    server.stop().await.unwrap();
}
