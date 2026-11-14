use crate::{api, auth, db::Db};
use anyhow::Result;
use axum::{routing::any, Router};
use std::{collections::HashMap, net::SocketAddr, path::PathBuf, sync::Arc};
use tokio::{sync::Mutex, task::JoinHandle};
use tokio_util::sync::CancellationToken;
use tower_http::{
    cors::{Any, CorsLayer},
    services::{ServeDir, ServeFile},
};

#[derive(Clone, Debug)]
pub struct Config {
    pub database: String,
    pub listen: String,
    pub root_password: Option<String>,
    pub allow_register: Option<bool>,
    pub web_dir: Option<PathBuf>,
    pub embedded: bool,
    pub memory_scanner: bool,
}
impl Default for Config {
    fn default() -> Self {
        Self {
            database: "sqlite://rofuchat.db".into(),
            listen: "0.0.0.0:7860".into(),
            root_password: None,
            allow_register: None,
            web_dir: None,
            embedded: false,
            memory_scanner: true,
        }
    }
}
#[derive(Clone)]
pub struct AppState {
    pub db: Db,
    pub client: reqwest::Client,
    pub embedded: bool,
    pub generating: Arc<Mutex<HashMap<String, CancellationToken>>>,
    pub shutdown: CancellationToken,
}
impl AppState {
    pub async fn new(config: &Config) -> Result<Self> {
        let db = Db::connect(&config.database).await?;
        auth::initialize(&db, config.root_password.as_deref()).await?;
        if let Some(v) = config.allow_register {
            db.set_registration(v).await?;
        }
        Ok(Self {
            db,
            client: reqwest::Client::builder()
                .connect_timeout(std::time::Duration::from_secs(20))
                .build()?,
            embedded: config.embedded,
            generating: Default::default(),
            shutdown: CancellationToken::new(),
        })
    }
}
pub fn router(state: AppState, web: Option<PathBuf>) -> Router {
    let mut router = Router::new()
        .route("/api/{*path}", any(api::dispatch))
        .with_state(state);
    if let Some(dir) = web {
        router = router.fallback_service(
            ServeDir::new(&dir).not_found_service(ServeFile::new(dir.join("index.html"))),
        );
    }
    router.layer(
        CorsLayer::new()
            .allow_origin(Any)
            .allow_methods(Any)
            .allow_headers(Any),
    )
}
pub struct RunningServer {
    pub address: SocketAddr,
    pub state: AppState,
    task: JoinHandle<Result<()>>,
}
impl RunningServer {
    pub async fn stop(self) -> Result<()> {
        self.state.shutdown.cancel();
        for token in self.state.generating.lock().await.values() {
            token.cancel();
        }
        self.task.await??;
        Ok(())
    }
}
pub async fn start_server(config: Config) -> Result<RunningServer> {
    let state = AppState::new(&config).await?;
    let listener = tokio::net::TcpListener::bind(&config.listen).await?;
    let address = listener.local_addr()?;
    let shutdown = state.shutdown.clone();
    let app = router(state.clone(), config.web_dir);
    let task = tokio::spawn(async move {
        axum::serve(listener, app)
            .with_graceful_shutdown(shutdown.cancelled_owned())
            .await?;
        Ok(())
    });
    tracing::info!(%address,"RofuChat listening");
    Ok(RunningServer {
        address,
        state,
        task,
    })
}
