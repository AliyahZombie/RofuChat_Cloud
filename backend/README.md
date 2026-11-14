# RofuChat backend

Rust 2021 workspace: `rofu-core` owns all application logic, `rofu-server` is the CLI, and `rofu-ffi` exposes the same server through a C ABI.

## Build and run

```sh
cargo build --workspace
cargo run -p rofu-server -- --root-password 'choose-a-password' --listen 0.0.0.0:7860
```

The first startup requires a root password. Passing it on subsequent starts resets the root password. Prefer `ROFU_ROOT_PASSWORD` over shell arguments in production. Registration starts disabled. SQLite files are created automatically; PostgreSQL accepts `postgres://user:password@host/database`.

```sh
cargo fmt --all
cargo clippy --all-targets -- -D warnings
cargo test
# Optional second database:
ROFU_TEST_PG_URL=postgres://user:password@localhost/rofu_test cargo test
```

Never point integration tests at a production database.

## Configuration

| CLI | Environment | Default |
| --- | --- | --- |
| `--database` | `ROFU_DATABASE` | `sqlite://rofuchat.db` |
| `--listen` | `ROFU_LISTEN` | `0.0.0.0:7860` |
| `--root-password` | `ROFU_ROOT_PASSWORD` | required at first startup |
| `--allow-register true/false` | `ROFU_ALLOW_REGISTER` | persisted setting, initially false |
| `--web-dir` | `ROFU_WEB_DIR` | no static website |
| `--no-memory-scanner` | — | scanner enabled |

`RUST_LOG` controls tracing. `--web-dir` serves a Flutter Web build with SPA fallback, while `/api/*` stays reserved for the API.

## Embedded ABI

`rofu_start`, `rofu_stop`, and `rofu_free_string` are exported by `rofu-ffi`. Start with a UTF-8 JSON config `{ "data_dir": "/path", "root_password": "persisted-random-secret", "listen": "127.0.0.1:0" }`. The result is `{ "ok": true, "port": 12345 }` or `{ "ok": false, "error": "..." }`. Free each returned string exactly once with `rofu_free_string`. Repeated starts return the running port. The runtime is process-global and supports stop/restart.

## systemd

Create a dedicated `rofuchat` system user and `/var/lib/rofuchat`. Store environment variables in `/etc/rofuchat.env` readable only by the service user/root.

```ini
[Unit]
Description=RofuChat
After=network.target

[Service]
User=rofuchat
WorkingDirectory=/var/lib/rofuchat
EnvironmentFile=/etc/rofuchat.env
ExecStart=/usr/local/bin/rofu-server --listen 127.0.0.1:7860
Restart=on-failure
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

Use a reverse proxy for public HTTPS and disable response buffering for SSE. Allow long-lived streaming requests. Back up the SQLite database with the SQLite backup API or stop the service during file copies; PostgreSQL deployments can use `pg_dump`.

## Docker

From `backend/`:

```sh
docker build -t rofuchat .
docker run --rm -p 7860:7860 -v rofu-data:/data --env-file /secure/rofuchat.env rofuchat
```

Set `ROFU_DATABASE=sqlite:///data/rofuchat.db` in the environment file. No external database is needed for SQLite.
