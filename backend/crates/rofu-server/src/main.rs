use clap::Parser;
use rofu_core::{start_server, Config};
use std::path::PathBuf;
#[derive(Parser)]
#[command(version, about = "RofuChat roleplay backend")]
struct Args {
    #[arg(long, env = "ROFU_DATABASE", default_value = "sqlite://rofuchat.db")]
    database: String,
    #[arg(long, env = "ROFU_LISTEN", default_value = "0.0.0.0:7860")]
    listen: String,
    #[arg(long, env = "ROFU_ROOT_PASSWORD")]
    root_password: Option<String>,
    #[arg(long,env="ROFU_ALLOW_REGISTER",action=clap::ArgAction::Set)]
    allow_register: Option<bool>,
    #[arg(long, env = "ROFU_WEB_DIR")]
    web_dir: Option<PathBuf>,
    #[arg(long)]
    no_memory_scanner: bool,
}
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| "info".into()),
        )
        .init();
    let a = Args::parse();
    let server = start_server(Config {
        database: a.database,
        listen: a.listen,
        root_password: a.root_password,
        allow_register: a.allow_register,
        web_dir: a.web_dir,
        memory_scanner: !a.no_memory_scanner,
        embedded: false,
    })
    .await?;
    tokio::signal::ctrl_c().await?;
    server.stop().await
}
