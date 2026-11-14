# Backend API implementation notes

The routes, event names and required fields are defined by `backend-spec.md` §6 and remain unchanged.

Additive response fields:

- Provider, Model, Character, LocalTool and Memory entities include server-managed `created_at` and `updated_at` in Unix milliseconds. IDs supplied during creation are ignored.
- Settings responses may include server-managed `id`, `created_at`, and `updated_at`; clients can ignore these fields.
- Assistant `usage` includes `estimated` (boolean), `last_input` and `last_output` (token counts for the last upstream request). `input`, `output`, `cached` and `reasoning` remain accumulated for the entire agent turn.
- The SSE `context` event includes the same `estimated`, `mode`, and `threshold` fields as `GET /api/conversations/{id}/context`, in addition to `tokens` and `max`.

Operational details:

- Mutations of messages, manual compression and memory scanning can return 409 while the conversation is generating. Stop the turn first before retrying.
- `greeting_index` is a zero-based index into `alternate_greetings`; omit it to use `first_mes`.
- PNG export defaults to a generated solid-color image when the character does not have a PNG data URL avatar. JSON export uses Character Card V2.
- `POST /api/conversations/{id}/memory_scan` returns zero counts when no new messages are available. A failed scan advances the scan cursor as required by the specification.
