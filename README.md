# RofuChat — Agent-Native Roleplay Engine

- **Backend**: Rust (axum + sqlx, SQLite/PostgreSQL). Runs as a server, or embedded inside the desktop/mobile app via FFI.
- **Frontend**: Flutter (Android incl. Wear OS, Linux, Windows, Web; macOS/iOS later).

Specs:
- [docs/backend-spec.md](docs/backend-spec.md) — backend requirements and the HTTP/SSE contract
- [docs/frontend-spec.md](docs/frontend-spec.md) — frontend requirements
- UI reference: [docs/ref/rikkahub-chat.webp](docs/ref/rikkahub-chat.webp)

Layout:
```
backend/   Rust workspace (rofu-core, rofu-server, rofu-ffi)
app/       Flutter app
docs/      specs
```
