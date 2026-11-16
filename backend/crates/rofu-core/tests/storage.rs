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
    let web = tempfile::tempdir().unwrap();
    std::fs::write(web.path().join("index.html"), "<html>RofuChat SPA</html>").unwrap();
    let server = start_server(Config {
        database: "sqlite::memory:".into(),
        listen: "127.0.0.1:0".into(),
        root_password: Some("secret".into()),
        memory_scanner: false,
        web_dir: Some(web.path().to_path_buf()),
        ..Config::default()
    })
    .await
    .unwrap();
    let base = format!("http://{}/api", server.address);
    let client = reqwest::Client::builder().no_proxy().build().unwrap();
    let fallback = client
        .get(format!("http://{}/nested/frontend/route", server.address))
        .send()
        .await
        .unwrap();
    assert_eq!(fallback.status(), 200);
    assert_eq!(fallback.text().await.unwrap(), "<html>RofuChat SPA</html>");
    let preflight = client
        .request(reqwest::Method::OPTIONS, format!("{base}/settings"))
        .header("origin", "https://frontend.example")
        .header("access-control-request-method", "PUT")
        .header(
            "access-control-request-headers",
            "authorization, content-type",
        )
        .send()
        .await
        .unwrap();
    assert!(preflight.status().is_success());
    assert_eq!(preflight.headers()["access-control-allow-origin"], "*");
    assert_eq!(
        preflight.headers()["access-control-allow-headers"],
        "authorization, content-type"
    );
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

#[tokio::test]
async fn authentication_lifecycle_and_admin_controls() {
    use rofu_core::{start_server, Config};
    let dir = tempfile::tempdir().unwrap();
    let cfg = Config {
        database: format!("sqlite://{}/auth.db", dir.path().display()),
        listen: "127.0.0.1:0".into(),
        root_password: Some("initial".into()),
        memory_scanner: false,
        ..Config::default()
    };
    let server = start_server(cfg.clone()).await.unwrap();
    let client = reqwest::Client::builder().no_proxy().build().unwrap();
    let base = format!("http://{}/api", server.address);
    let login = |username: &str, password: &str| {
        client
            .post(format!("{base}/auth/login"))
            .json(&json!({"username":username,"password":password}))
    };
    let root: serde_json::Value = login("root", "initial")
        .send()
        .await
        .unwrap()
        .json()
        .await
        .unwrap();
    let rt = root["token"].as_str().unwrap();
    assert_eq!(
        client
            .put(format!("{base}/admin/config"))
            .bearer_auth(rt)
            .json(&json!({"allow_register":true}))
            .send()
            .await
            .unwrap()
            .status(),
        200
    );
    let registered: serde_json::Value = client
        .post(format!("{base}/auth/register"))
        .json(&json!({"username":"alice","password":"first"}))
        .send()
        .await
        .unwrap()
        .json()
        .await
        .unwrap();
    let first = registered["token"].as_str().unwrap();
    let another: serde_json::Value = login("alice", "first")
        .send()
        .await
        .unwrap()
        .json()
        .await
        .unwrap();
    let second = another["token"].as_str().unwrap();
    assert_eq!(
        client
            .get(format!("{base}/admin/users"))
            .bearer_auth(first)
            .send()
            .await
            .unwrap()
            .status(),
        403
    );
    assert_eq!(
        client
            .get(format!("{base}/auth/me?token={first}"))
            .send()
            .await
            .unwrap()
            .status(),
        200
    );
    assert_eq!(
        client
            .post(format!("{base}/auth/password"))
            .bearer_auth(first)
            .json(&json!({"old_password":"wrong","new_password":"second"}))
            .send()
            .await
            .unwrap()
            .status(),
        403
    );
    assert_eq!(
        client
            .post(format!("{base}/auth/password"))
            .bearer_auth(first)
            .json(&json!({"old_password":"first","new_password":"second"}))
            .send()
            .await
            .unwrap()
            .status(),
        204
    );
    assert_eq!(
        client
            .get(format!("{base}/auth/me"))
            .bearer_auth(second)
            .send()
            .await
            .unwrap()
            .status(),
        401
    );
    assert_eq!(
        client
            .get(format!("{base}/auth/me"))
            .bearer_auth(first)
            .send()
            .await
            .unwrap()
            .status(),
        200
    );
    assert_eq!(login("alice", "first").send().await.unwrap().status(), 401);
    assert_eq!(login("alice", "second").send().await.unwrap().status(), 200);
    assert_eq!(
        client
            .delete(format!(
                "{base}/admin/users/{}",
                root["user"]["id"].as_str().unwrap()
            ))
            .bearer_auth(rt)
            .send()
            .await
            .unwrap()
            .status(),
        403
    );
    let uid = registered["user"]["id"].as_str().unwrap();
    assert_eq!(
        client
            .post(format!("{base}/admin/users/{uid}/password"))
            .bearer_auth(rt)
            .json(&json!({"password":"third"}))
            .send()
            .await
            .unwrap()
            .status(),
        204
    );
    assert_eq!(
        client
            .get(format!("{base}/auth/me"))
            .bearer_auth(first)
            .send()
            .await
            .unwrap()
            .status(),
        401
    );
    let latest: serde_json::Value = login("alice", "third")
        .send()
        .await
        .unwrap()
        .json()
        .await
        .unwrap();
    let token = latest["token"].as_str().unwrap();
    assert_eq!(
        client
            .post(format!("{base}/auth/logout"))
            .bearer_auth(token)
            .send()
            .await
            .unwrap()
            .status(),
        204
    );
    assert_eq!(
        client
            .get(format!("{base}/auth/me"))
            .bearer_auth(token)
            .send()
            .await
            .unwrap()
            .status(),
        401
    );
    assert_eq!(
        client
            .delete(format!("{base}/admin/users/{uid}"))
            .bearer_auth(rt)
            .send()
            .await
            .unwrap()
            .status(),
        204
    );
    server.stop().await.unwrap();
    let server = start_server(Config {
        root_password: Some("reset".into()),
        ..cfg
    })
    .await
    .unwrap();
    assert!(server.state.db.registration().await.unwrap());
    assert!(auth::login(
        &server.state.db,
        &json!({"username":"root","password":"initial"})
    )
    .await
    .is_err());
    assert!(auth::login(
        &server.state.db,
        &json!({"username":"root","password":"reset"})
    )
    .await
    .is_ok());
    server.stop().await.unwrap();
}

async fn fresh_schema_and_dice(database: &str) {
    let db = Db::connect(database).await.unwrap();
    rofu_core::auth::initialize(&db, Some("secret"))
        .await
        .unwrap();
    let login = rofu_core::auth::login(&db, &json!({"username":"root","password":"secret"}))
        .await
        .unwrap();
    let root = login["user"]["id"].as_str().unwrap();
    let dice = db.list(root, "plugin").await.unwrap();
    assert_eq!(dice.len(), 1);
    assert_eq!(dice[0]["name"], "骰子 / Dice");
    assert_eq!(dice[0]["enabled"], true);
    assert_eq!(dice[0]["format"], "module-v1");
    assert_eq!(dice[0]["manifest"]["permissions"], json!([]));
    assert_eq!(dice[0]["granted_permissions"], json!([]));
    let user = rofu_core::auth::create(&db, "new-user", "secret", false)
        .await
        .unwrap();
    assert_eq!(
        db.list(user["id"].as_str().unwrap(), "plugin")
            .await
            .unwrap()
            .len(),
        1
    );
    db.delete(root, "plugin", dice[0]["id"].as_str().unwrap())
        .await
        .unwrap();
    rofu_core::auth::initialize(&db, None).await.unwrap();
    assert!(db.list(root, "plugin").await.unwrap().is_empty());
    db.pool.close().await;
    let db = Db::connect(database).await.unwrap();
    rofu_core::auth::initialize(&db, None).await.unwrap();
    assert!(db.list(root, "plugin").await.unwrap().is_empty());
    for version in [1, 2, 3, 5] {
        sqlx::query("UPDATE schema_version SET version=$1")
            .bind(version as i64)
            .execute(&db.pool)
            .await
            .unwrap();
        let error = match Db::connect(database).await {
            Ok(_) => panic!("accepted schema {version}"),
            Err(e) => e.to_string(),
        };
        assert!(error.contains("Delete/recreate the database"), "{error}");
    }
    db.pool.close().await;
}
#[tokio::test]
async fn sqlite_fresh_schema_and_dice() {
    let dir = tempfile::tempdir().unwrap();
    fresh_schema_and_dice(&format!("sqlite://{}/fresh.db", dir.path().display())).await;
}
#[tokio::test]
async fn postgres_fresh_schema_and_dice() {
    let Ok(url) = std::env::var("ROFU_TEST_PG_URL") else {
        return;
    };
    sqlx::any::install_default_drivers();
    let pool = sqlx::AnyPool::connect(&url).await.unwrap();
    let schema = format!("fresh_{}", rofu_core::model::id());
    sqlx::query(&format!("CREATE SCHEMA {schema}"))
        .execute(&pool)
        .await
        .unwrap();
    let mut url = url::Url::parse(&url).unwrap();
    url.query_pairs_mut()
        .append_pair("options", &format!("-c search_path={schema}"));
    fresh_schema_and_dice(url.as_str()).await;
    sqlx::query(&format!("DROP SCHEMA {schema} CASCADE"))
        .execute(&pool)
        .await
        .unwrap();
    pool.close().await;
}
