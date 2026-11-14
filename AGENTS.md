# AGENTS.md — rules for coding agents

- Specs are the source of truth: `docs/backend-spec.md` (backend + API contract) and `docs/frontend-spec.md`.
- The HTTP/SSE contract (backend-spec §6) is shared with the Flutter app. Do not rename fields, events or routes. Additive changes are allowed but must be documented in `docs/api.md`.
- Backend lives in `backend/`, frontend in `app/`. A task scoped to one side must not modify the other side.
- Backend: no `sqlx::query!` macros; SQL must run on both SQLite and PostgreSQL; bundled C deps; rustls only (no OpenSSL).
- Before committing backend work: `cargo fmt --all`, `cargo clippy --all-targets -- -D warnings`, `cargo test` all pass.
- Commit messages in English, imperative mood, scoped prefix: `backend: …`, `app: …`, `docs: …`, `ci: …`.
- Never commit secrets, databases, or build outputs.
