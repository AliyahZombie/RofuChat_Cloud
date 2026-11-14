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
- PNG export defaults to a generated solid-color image when the character does not have a PNG avatar. HTTP(S) avatars are fetched for PNG export (20-second timeout, 32MB limit). JSON export uses Character Card V2.
- `POST /api/conversations/{id}/memory_scan` returns zero counts when no new messages are available. A failed scan advances the scan cursor as required by the specification.

## Message pagination

`GET /api/conversations/{id}/messages` without `limit` continues to return the full array, including hidden messages and summaries. With a positive signed 64-bit `limit` (less than `9223372036854775807`), it returns the last N eligible messages in ascending seq order. Optional `before_seq` is an exclusive signed 64-bit seq cursor and is applied only with `limit`. Invalid pagination values return 400.

Request: `GET /api/conversations/c1/messages?limit=2&before_seq=4000`

Response (Message objects abbreviated):
```json
{"messages":[{"id":"u1","seq":2000,"role":"user","content":"Hi"},{"id":"a1","seq":3000,"role":"assistant","content":"Hello"}],"has_more":true}
```

`has_more` indicates that older eligible messages exist. Use the first returned message's seq as the next `before_seq`; an empty page has `has_more:false`. Pagination is performed in SQL with descending seq and LIMIT, then the page is reversed. `GET /api/conversations/{id}` additionally returns `message_count` for all currently stored messages, alongside `generating`:

```json
{"id":"c1","character_id":"char1","title":"Chat","created_at":0,"updated_at":0,"memory_scanned_seq":0,"generating":false,"message_count":3}
```
