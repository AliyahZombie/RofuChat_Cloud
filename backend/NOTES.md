# Implementation decisions

- PUT entities replaces public fields with spec defaults for omitted values; IDs, ownership and timestamps are server controlled. Provider masked/empty keys preserve the stored secret.
- `greeting_index`: absent selects first_mes; a supplied zero-based index selects alternate_greetings.
- Embedded ABI strings use C malloc/free; callers must use rofu_free_string so the allocator stays paired across platform CRT boundaries.
- SQLite uses one connection for in-memory databases. Migration statements use TEXT/BIGINT and numbered placeholders on both database engines.
- Conversation mutation endpoints return 409 during generation to avoid truncating messages while the independent generation task is saving them.
- `usage.last_output` supplements the specified `last_input` so context usage can represent the final request rather than accumulated output across tool rounds.
- Tests inject a direct HTTP client so environment proxies cannot route loopback mock traffic outside the machine. Production clients retain normal proxy-environment support.
- Integration PostgreSQL tests create and drop an isolated database with a random UUID name; ROFU_TEST_PG_URL must permit CREATE DATABASE. They never migrate or clear the supplied database itself.

- keep_recent is clamped to at least 1 so the summary always has a retained message before which its seq can be placed.
- JS http calls bypass environment proxies for loopback addresses; other destinations use the normal proxy environment. The 15s HTTP timeout is additionally capped to the remaining 10s tool budget.
- Remote PNG avatars are fetched on export with a 20s timeout and 32MB limit; non-PNG avatars use the generated solid-color PNG.

- Message swipes are JSON snapshots, synchronized from the active top-level fields on each message save. User branch tails retain complete nested message histories; switch/delete runs under the existing generation mutex and a database transaction. No schema migration is needed.
- Wire messages expose swipe_index/swipe_count only. Compression and memory scanning explicitly project active contents before serializing to the fast model, so inactive versions and archived tails never enter those prompts.
- Retrying three rounds with Flutter's empty-content regenerate body preserved the upstream history on both databases, before and after swipe support, in traditional/instant modes and with tools enabled/disabled. The reported loss of all context was not reproduced in the backend.
- System prompt compatibility fix: context now has exactly one system message, always first. Visible summaries (in seq order) and post_history_instructions are merged after long-term memory, with post_history_instructions last; visible legacy system rows are preserved before summaries. Blocks use blank-line separators and macro expansion. Only user/assistant/tool rows remain in history and count toward instant-mode display_recent. Responses maps the merged system to instructions, so normal requests generate no developer messages; token estimates and the context API use the same merged structure.
- With unchanged card/settings, worldbook matches, memory and summaries, the system prefix remains stable across turns. Keyword-triggered worldbook entries can change the system text as recent history changes; this is expected behavior. Instant mode can still replace older display messages with actual text. Regression tests capture both provider formats, consecutive-turn prefixes, and exact normal-send/regenerate request equality on SQLite and PostgreSQL.
