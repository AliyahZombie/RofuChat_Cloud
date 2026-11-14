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

The PostgreSQL test URL must permit CREATE DATABASE. The suite creates a fresh randomly named database and drops it after completion; it does not migrate or clear the supplied database. Never use production credentials for tests.

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


## API and tools

The stable HTTP/SSE contract is in `../docs/backend-spec.md` §6. Additive response details are recorded in `../docs/api.md`. Login at `POST /api/auth/login`, then send `Authorization: Bearer <token>` to protected routes; image/download URLs also accept `?token=`. Provider keys are masked in responses. Each user owns separate providers, models, characters, tools, conversations and memories.

Both provider kinds stream through the same agent loop. A chat continues after its SSE subscriber disconnects; only `/stop` or shutdown cancels it. The service saves partial replies every second. Reverse proxies should pass SSE without buffering and preserve the 15-second heartbeat.

Local JS tools run in isolated QuickJS runtimes (64MB heap, 1MB stack, 10-second budget). `main(args)` may return a Promise. `console.log/info/warn/error` are collected; synchronous `http(method,url,body,headers)` returns `{status,body}`, caps responses at 1MB, and uses rustls. Loopback HTTP bypasses environment proxies. Tool errors become tool results rather than failing the entire agent turn.

MCP supports Streamable HTTP and legacy HTTP+SSE, custom headers, initialization, pagination and session IDs. Connections are reused within an agent turn. Failed MCP connections produce notices and are skipped after a 20-second timeout.

Traditional context compression preserves raw messages and adds a summary card; instant compression preserves display content and stores a separate `actual` value, falling back to full content on failure. Long-term memory loads only pinned entries into the prompt; tools retrieve other memories. The idle scanner checks every two minutes and advances its cursor even after a failed model request to avoid repeated charges. Disable it with `--no-memory-scanner`.

## Platform builds

CI runs Linux x64/arm64 tests against SQLite and PostgreSQL, fmt/clippy, and release builds. It also builds Android `arm64-v8a`, `armeabi-v7a`, `x86_64` using cargo-ndk and Windows MSVC server/FFI artifacts. SQLite and QuickJS C sources are bundled; HTTP and SQL clients use rustls. Local Android/Windows cross-compilation is not required for ordinary development.

See `NOTES.md` for implementation choices and `PROGRESS.md` for validation status.
