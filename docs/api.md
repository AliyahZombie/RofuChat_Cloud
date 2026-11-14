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

## Message swipes (versions)

All Message objects returned over HTTP (including full/paged lists, `GET /api/messages/{id}`, PATCH, actual and compression responses) or embedded in SSE events expose only the active contents, plus:

```json
{"id":"a1","conversation_id":"c1","seq":3000,"role":"assistant","content":"Current reply","swipe_index":1,"swipe_count":2}
```

Examples abbreviate the other existing Message fields; those fields keep their original names and types. Full `swipes` arrays and archived `tail` messages are never included in these responses. Legacy messages without stored swipes report index 0 and count 1; their arrays are initialized lazily when needed.

Stored swipes live inside the existing message JSON; no table migration is required. Each snapshot contains `content`, `parts` (including images, segments and errors), `actual`, `actual_status`, `actual_error`, `usage`, `model`, `model_name`, `model_icon`, and `created_at`. User snapshots also contain `tail`, an archive of complete following messages, including their own swipe history. Identity, conversation, seq, role and visibility belong to the message. The top-level mutable fields always match the active snapshot. Context building, compression and memory scanning use only the active contents and never consume inactive swipes or tails.

### Regenerate and edit

`POST /api/conversations/{id}/chat` keeps its existing body and SSE event names:

```json
{"regenerate":true,"content":"","images":[]}
```

Regenerate ignores the supplied content/images and finds the last user message. If the immediately following message is an assistant, it appends an empty swipe to that assistant, activates it, and streams into it while preserving its id and seq. Messages after that assistant are removed. If no assistant immediately follows, messages after the user are removed and an assistant is created as before. A conversation without any user message returns 400, including greeting-only conversations. The new version starts with empty content/segments, reset usage and errors, `actual:null`, `actual_status:"none"`, and `actual_error:null`. Instant mode generates a fresh actual for the new version. A failed or stopped generation keeps the new version's partial output; earlier swipes remain available.

Example first assistant event (other Message fields omitted):

```text
data: {"type":"assistant_start","message":{"id":"a1","conversation_id":"c1","seq":3000,"role":"assistant","content":"","actual":null,"actual_status":"none","actual_error":null,"model_name":"Example","model_icon":"openai","swipe_index":1,"swipe_count":2}}
```

Editing and resending a user message archives its complete current following rows into the active user swipe, appends a new user swipe with the new content/images and an empty tail, activates it and generates a new reply. The user id and seq are preserved. Omitted images become an empty array for the new version.

```json
{"edit_message_id":"u1","content":"Revised question","images":["data:image/png;base64,..."]}
```

`PATCH /api/messages/{id}` with `{"content":"Saved text"}` only edits the active swipe and top-level content; it neither adds a swipe nor changes following messages. For assistant segments, non-text segments (reasoning/tools) retain their original order and data; the first text segment is replaced in place, further text segments are removed, and if none exists a text segment is appended. PATCH of `actual` also updates only the active version, sets status to `ok`, and clears its error. Responses use the compact Message shape above.

### Switch a swipe

`POST /api/messages/{id}/swipe` accepts a zero-based non-negative integer index:

```json
{"index":0}
```

For assistant messages (including greetings), switching activates the requested snapshot without touching subsequent messages:

```json
{"messages":[{"id":"a1","seq":3000,"role":"assistant","content":"Original reply","swipe_index":0,"swipe_count":2}]}
```

For user messages, switching archives all currently following rows (`seq` greater than that user's) into the outgoing swipe, removes those rows, activates the target swipe, restores the target's tail with original ids/seq and complete data, then clears its stored tail. All these operations, including reading the target version, occur in one transaction. The response gives the active user followed by its restored messages in ascending seq order:

```json
{"messages":[{"id":"u1","seq":2000,"role":"user","content":"Original question","swipe_index":0,"swipe_count":2},{"id":"a1","seq":3000,"role":"assistant","content":"Original reply","swipe_index":1,"swipe_count":2},{"id":"u2","seq":4000,"role":"user","content":"Follow-up","swipe_index":0,"swipe_count":1}]}
```

Selecting the already active user index leaves the branch intact and returns that user and its current following messages. Clients can replace their local tail starting at this user with `messages`. Invalid/missing/non-integer or out-of-range indices return 400; unknown or other users' messages return 404. Switching while the conversation is generating returns 409. Non-user/non-assistant messages cannot be switched (400).

### Delete a swipe

`DELETE /api/messages/{id}/swipes/{index}` deletes that zero-based version. Deleting the only remaining swipe or an invalid/out-of-range index returns 400; generation in progress returns 409. If the active version is deleted, activate the following neighbor, or the preceding neighbor when deleting the last version. For user messages this uses the same transactional tail replacement as switching. Deleting an inactive version preserves the active branch and adjusts its numeric index if necessary.

The response has the same `{"messages":[...]}` format: assistant deletion returns that message; user deletion returns the active user followed by its active tail (restored when the active version was deleted). Example:

```text
DELETE /api/messages/u1/swipes/1
```
```json
{"messages":[{"id":"u1","seq":2000,"role":"user","content":"Original question","swipe_index":0,"swipe_count":1},{"id":"a1","seq":3000,"role":"assistant","content":"Original reply","swipe_index":1,"swipe_count":2}]}
```

### Greetings and branching

Creating a conversation initializes its greeting versions as `[first_mes, ...alternate_greetings]`, expanding character/user macros in every version. Omitting `greeting_index` activates swipe 0 (`first_mes`); supplying `greeting_index:k` retains the existing zero-based alternate rule and activates swipe `k+1`. The existing rule for an empty or invalid selected greeting is unchanged: no greeting row is inserted. Greetings can be switched/deleted through the message APIs; regenerate requires a user message.

`POST /api/messages/{id}/branch` still copies the conversation through that message (inclusive) with new conversation/message ids, but copies only active contents. Copies contain no swipes or archived tails and appear to clients as index 0/count 1 until new versions are added.
