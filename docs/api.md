# Backend API implementation notes

The routes, event names and required fields are defined by `backend-spec.md` §6 and remain unchanged.

Additive response fields:

- Provider, Model, Character, LocalTool and Memory entities include server-managed `created_at` and `updated_at` in Unix milliseconds. IDs supplied during creation are ignored.
- Settings responses may include server-managed `id`, `created_at`, and `updated_at`; clients can ignore these fields.
- Assistant `usage` includes `estimated` (boolean), `last_input` and `last_output` (token counts for the last upstream request). `input`, `output`, `cached` and `reasoning` remain accumulated for the entire agent turn.
- The SSE `context` event includes the same `estimated`, `mode`, `instant`, `summarize`, and `threshold` fields as `GET /api/conversations/{id}/context`, in addition to `tokens` and `max`.

Operational details:

- Mutations of messages, manual compression and memory scanning can return 409 while the conversation is generating. Stop the turn first before retrying.
- `greeting_index` is a zero-based index into `alternate_greetings`; omit it to use `first_mes`.
- PNG export defaults to a generated solid-color image when the character does not have a PNG avatar. HTTP(S) avatars are fetched for PNG export (20-second timeout, 32MB limit). JSON export uses Character Card V2.
- `POST /api/conversations/{id}/memory_scan` returns zero counts when no new messages are available. A failed scan advances the scan cursor as required by the specification.

## Upstream context and token estimates

Normal sends and regenerate requests build exactly one system message at the start of the upstream context. Its blocks, separated by blank lines with character/user macros expanded, are ordered as follows: card `system_prompt` (or the built-in default), description, personality, scenario, user persona, matching worldbook entries, `mes_example`, long-term memory, visible compression summaries in seq order (each prefixed with `[Summary of the earlier conversation]\n`), then `post_history_instructions`. Legacy visible system rows are merged after memory and before summaries. The remaining history contains only user/assistant/tool messages; summaries remain available as Message objects through the HTTP API.

Responses providers receive the merged system text in `instructions`, with no system or developer messages in `input`. With unchanged card/settings, worldbook matches, memory and summaries, consecutive turns keep the same system text. Traditional history grows by appending messages; instant mode still selects display/actual according to `display_recent`, counting only user/assistant/tool history. Keyword-triggered worldbook matches can change the system text as the conversation changes; this is expected.

Token estimates, including `GET /api/conversations/{id}/context` and SSE `context`, use the merged structure, including one system message's overhead. When instant compression is enabled or a visible summary exists, current context is estimated (`estimated:true`) so provider usage from before compression cannot override it. Otherwise the last assistant's authoritative `usage.last_input + usage.last_output` retains priority.

## Independent compression switches

Character `context` adds `summarize` (default `true`) and `instant` (default `false`). They work independently: summarize controls automatic threshold compression and manual `POST /api/conversations/{id}/compress`; instant controls per-reply actual generation and display/actual selection. Existing threshold, keep_recent and display_recent fields keep their meanings. Example with both enabled:

```json
{"context":{"summarize":true,"instant":true,"mode":"instant","compress_threshold":0,"keep_recent":6,"display_recent":4}}
```

For missing switches, legacy `mode:"instant"` means instant=true and summarize=true; all other modes mean instant=false and summarize=true. Explicit switches take priority. Reads (including lists), writes and exports expose both keys; `mode` mirrors instant for old clients. Character Card V2 JSON exports and embedded PNG JSON add a top-level `context` object, preserved on import. Cards without it use defaults.

After a completed reply, actual compression runs first if enabled, then threshold summary compression if enabled. Summary input uses each active assistant's successful actual, otherwise content and available tool results, without inactive swipes/tails. A summary hides old messages with visible=false; hidden messages never reappear through actual selection. With instant disabled, new replies have no automatic actual; the manual actual endpoint and existing actual editing remain available. Summary input can still use existing successful actuals.

With summarize=false, manual compression returns HTTP 400 and an error containing `summary compression is disabled (context.summarize=false)`. Successful compression still returns a summary Message, or 204 when there is nothing to compress. Existing routes and SSE event names are unchanged. `GET /api/conversations/{id}/context` and SSE `context` add the two boolean switches; mode and threshold remain available even with summarization disabled.

Instant compression receives only visible content with think/thinking blocks removed, followed by one `[tool] name(args) → result` line per tool (arguments ≤120 Unicode characters, result ≤200, whitespace collapsed). The user message is `Condense the following roleplay reply.\n<reply>\n...\n</reply>`; the system explicitly treats the tagged reply as source material to summarize, never dialogue to answer or continue. Requests omit `max_tokens` and `max_output_tokens`, including the model's `max_output` default, so models with mandatory thinking can finish reasoning before writing the note. They send no reasoning/thinking parameters or inherited character generation parameters. Length is controlled by the existing cleaned-content checks and one retry, not an upstream output-token cap. It never receives reasoning segments, duplicate text segments or raw segments JSON. The system prompt supplies character/user names and requests a faithful third-person, past-tense note in the reply's language, only plot facts, no invented or unrelated material, no title/commentary/markdown, roughly ≤1/5 length and ≤120 CJK characters or 80 English words, usually 1–3 short sentences. Fast-model resolution is unchanged.

Generated notes strip think/thinking blocks (including an unclosed block while preserving preceding text), leading Summary:/摘要：/压缩： labels, surrounding quotes/markdown and repeated whitespace. A single outer `<note>`/`<reply>` pair or code fence with any language is unwrapped. Validation uses cleaned text, so large raw outputs with short usable notes are accepted. The existing acceptance rule remains a non-empty note shorter than the input; the one-fifth/CJK/English bounds remain instructions to the model.

Invalid cleaned notes retry once. The appended feedback says `Your previous output was empty` or `Your previous output was N characters; the limit is M. Output only the note.` M is the source input's Unicode length / 5, clamped to 1–120, excluding framing. Empty-result feedback also requests this cap. Reasoning text is never used as the note; empty visible content with reasoning is diagnosed as `reasoning-only`. If the provider reports `finish_reason:"length"`, or Responses reports `response.incomplete`, incomplete status or `incomplete_details.reason:"max_output_tokens"`, empty visible content is diagnosed as `truncated while reasoning` (even if the provider exposes no reasoning text).

A second invalid result sets actual=null and actual_status=failed; actual_error lists each attempt's reason (empty, reasoning-only, truncated while reasoning, cleaned character count over the length limit, or provider error), then a quoted, escaped preview bounded to 160 Unicode characters. Non-empty raw provider content is labeled `last content preview`, preserving think tags; otherwise reasoning is labeled `last reasoning preview` for diagnosis only. Reasoning is never presented as the output or used as the note. The same diagnostic is logged at warn level with the message id. Provider/HTTP errors end the request immediately with the same failed status and diagnostics, including partial streamed content if available. Context continues to fall back to the full reply; routes, SSE events and fast-model resolution are unchanged.

## Conversation titles

After the first reply, an empty conversation title uses only an explicitly configured, resolvable `fast_model_id`. It never falls back to a character/default model for titles. The instruction requests only a title in the user's language, at most 16 Chinese characters or 6 English words, without quotes or trailing punctuation. Title requests also omit output-token caps (including the model's `max_output` default) and reasoning/thinking parameters, allowing mandatory thinking to finish. Output removes `<think>…</think>` / `<thinking>…</thinking>` blocks, selects the first non-empty line, strips surrounding quotes/book-title marks/`#`/`*` and `Title:` / `标题：` prefixes, collapses whitespace, then truncates to 24 Unicode scalar values plus `…` if necessary.

Missing/unresolvable/disabled fast models, failed calls, or empty cleaned output use the first user message's first non-empty line with collapsed whitespace, truncated to 20 Unicode scalar values plus `…` when needed. Empty text (including image-only messages) uses `New chat`. Compression and memory scanning retain their existing fast-model fallback rules. Title saving remains asynchronous and preserves a title set by the user.

## Message pagination

`GET /api/conversations/{id}/messages` without either `limit` or `max_chars` continues to return the full array, including hidden messages and summaries; a standalone `before_seq` remains ignored for compatibility. Supplying either bound returns a page object with `messages`, `has_more`, `chars` and `bytes`. `limit` is a positive signed 64-bit integer less than `9223372036854775807`; `max_chars` is an unsigned 64-bit integer (including zero). Optional `before_seq` is an exclusive signed 64-bit seq cursor. Invalid pagination values return 400.

Messages are selected newest first, strictly before `before_seq` when supplied, and returned in ascending seq order. `max_chars` counts Unicode scalar values (Rust `chars()`) in each message's active `content`, plus `parts.segments` entries of type `reasoning` (`text`) or `tool` (`arguments` and `result`, both stored strings). Text segments are already represented in `content` and are not counted again. Images, metadata, `actual`, inactive swipes and archived branch tails do not contribute. Hidden messages and summaries remain eligible and their content counts normally.

Before adding a message that would exceed `max_chars`, selection stops only if the page already contains at least one user and one assistant message. Until then it keeps walking backward, even beyond the budget, or until the conversation starts. Messages/swipes are never split. Both bounds may be supplied: `limit` always remains a hard upper bound, so `limit=1&max_chars=1` may return just one assistant message. With `limit` alone, selection behavior is unchanged.

`chars` reports the selected page's total using the above counting rules, even when only `limit` is supplied. `bytes` is the UTF-8 byte length of the compact JSON serialization of the public `messages` array, including its brackets, punctuation, escaping and message metadata, but excluding the outer response object. It is not the HTTP body's size or compressed transfer size. An empty page has `chars:0`, `bytes:2`, and `has_more:false`.

Request: `GET /api/conversations/c1/messages?limit=2&before_seq=4000`

Response (Message objects abbreviated):
```json
{"messages":[{"id":"u1","seq":2000,"role":"user","content":"Hi"},{"id":"a1","seq":3000,"role":"assistant","content":"Hello"}],"has_more":true,"chars":7,"bytes":113}
```

`bytes:113` above describes exactly the abbreviated array shown; real Message objects contain additional fields and therefore more bytes. `has_more` indicates that older eligible messages exist. Use the first returned message's seq as the next `before_seq` (for example `?max_chars=20000&before_seq=2000`). Pagination streams SQL rows in descending seq order, retains the page plus one lookahead row, then reverses the page. `GET /api/conversations/{id}` additionally returns `message_count` for all currently stored messages, alongside `generating`:

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
