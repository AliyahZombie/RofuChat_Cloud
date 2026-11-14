# Implementation decisions

- PUT entities replaces public fields with spec defaults for omitted values; IDs, ownership and timestamps are server controlled. Provider masked/empty keys preserve the stored secret.
- `greeting_index`: absent selects first_mes; a supplied zero-based index selects alternate_greetings.
- Embedded ABI strings are allocated with Rust CString and must be released only through rofu_free_string (the ABI's matching allocator); no cross-runtime allocator assumptions.
- SQLite uses one connection for in-memory databases. Migration statements use TEXT/BIGINT and numbered placeholders on both database engines.
- Conversation mutation endpoints return 409 during generation to avoid truncating messages while the independent generation task is saving them.
- `usage.last_output` supplements the specified `last_input` so context usage can represent the final request rather than accumulated output across tool rounds.
- Tests inject a direct HTTP client so environment proxies cannot route loopback mock traffic outside the machine. Production clients retain normal proxy-environment support.
- Integration PostgreSQL tests create and drop an isolated database with a random UUID name; ROFU_TEST_PG_URL must permit CREATE DATABASE. They never migrate or clear the supplied database itself.
