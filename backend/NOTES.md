# Implementation decisions

- PUT entities replaces public fields with spec defaults for omitted values; IDs, ownership and timestamps are server controlled. Provider masked/empty keys preserve the stored secret.
- `greeting_index`: absent selects first_mes; a supplied zero-based index selects alternate_greetings.
- Embedded ABI strings are allocated with Rust CString and must be released only through rofu_free_string (the ABI's matching allocator); no cross-runtime allocator assumptions.
- SQLite uses one connection for in-memory databases. Migration statements use TEXT/BIGINT and numbered placeholders on both database engines.
