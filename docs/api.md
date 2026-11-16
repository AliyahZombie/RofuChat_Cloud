# Backend API implementation notes

The current routes, events and required fields are defined by `backend-spec.md` §6 and this document. Only this contract is supported.

Additive response fields:

- Provider, Model, Character, Plugin and Memory entities include server-managed `created_at` and `updated_at` in Unix milliseconds. IDs supplied during creation are ignored.
- Settings responses may include server-managed `id`, `created_at`, and `updated_at`; clients can ignore these fields.
- Assistant `usage` includes `estimated` (boolean), `last_input` and `last_output` (token counts for the last upstream request). `input`, `output`, `cached` and `reasoning` remain accumulated for the entire agent turn.
- The SSE `context` event includes the same `estimated`, `instant`, `summarize`, and `threshold` fields as `GET /api/conversations/{id}/context`, in addition to `tokens` and `max`.

Operational details:

- Mutations of messages, manual compression and memory scanning can return 409 while the conversation is generating. Stop the turn first before retrying.
- `greeting_index` is a zero-based index into `alternate_greetings`; omit it to use `first_mes`.
- PNG export defaults to a generated solid-color image when the character does not have a PNG avatar. HTTP(S) avatars are fetched for PNG export (20-second timeout, 32MB limit). JSON export uses Character Card V2.
- `POST /api/conversations/{id}/memory_scan` returns zero counts when no new messages are available. A failed scan advances the scan cursor as required by the specification.

## Upstream context and token estimates

Normal sends and regenerate requests build exactly one system message at the start of the upstream context. Its blocks, separated by blank lines with character/user macros expanded, are ordered as follows: card `system_prompt` (or the built-in default), description, personality, scenario, user persona, matching worldbook entries, `mes_example`, long-term memory, visible compression summaries in seq order (each prefixed with `[Summary of the earlier conversation]\n`), then `post_history_instructions`. Stored system-role rows are excluded from upstream history; configure instructions in the character card `system_prompt`. The remaining history contains only user/assistant/tool messages; summaries remain available as Message objects through the HTTP API.

Responses providers receive the merged system text in `instructions`, with no system or developer messages in `input`. With unchanged card/settings, worldbook matches, memory and summaries, consecutive turns keep the same system text. Traditional history grows by appending messages; instant mode still selects display/actual according to `display_recent`, counting only user/assistant/tool history. Keyword-triggered worldbook matches can change the system text as the conversation changes; this is expected.

Token estimates, including `GET /api/conversations/{id}/context` and SSE `context`, use the merged structure, including one system message's overhead. When instant compression is enabled or a visible summary exists, current context is estimated (`estimated:true`) so provider usage from before compression cannot override it. Otherwise the last assistant's authoritative `usage.last_input + usage.last_output` retains priority.

## Independent compression switches

Character `context` adds `summarize` (default `true`) and `instant` (default `false`). They work independently: summarize controls automatic threshold compression and manual `POST /api/conversations/{id}/compress`; instant controls per-reply actual generation and display/actual selection. Existing threshold, keep_recent and display_recent fields keep their meanings. Example with both enabled:

```json
{"context":{"summarize":true,"instant":true,"compress_threshold":0,"keep_recent":6,"display_recent":4}}
```

Reads, writes and exports expose `instant` and `summarize`; there is no `mode` field. Creation uses the defaults above. Character Card V2 JSON exports and embedded PNG JSON include a top-level `context` object, preserved on import. External cards without application context use creation defaults.

After a completed reply, actual compression runs first if enabled, then threshold summary compression if enabled. Summary input uses each active assistant's successful actual, otherwise content and available tool results, without inactive swipes/tails. A summary hides old messages with visible=false; hidden messages never reappear through actual selection. With instant disabled, new replies have no automatic actual; the manual actual endpoint and existing actual editing remain available. Summary input can still use existing successful actuals.

With summarize=false, manual compression returns HTTP 400 and an error containing `summary compression is disabled (context.summarize=false)`. Successful compression still returns a summary Message, or 204 when there is nothing to compress. Existing routes and SSE event names are unchanged. `GET /api/conversations/{id}/context` and SSE `context` add the two boolean switches; threshold remains available even with summarization disabled.

Instant compression receives only visible content with think/thinking blocks removed, followed by one `[tool] name(args) → result` line per tool (arguments ≤120 Unicode characters, result ≤200, whitespace collapsed). The user message is `Condense the following roleplay reply.\n<reply>\n...\n</reply>`; the system explicitly treats the tagged reply as source material to summarize, never dialogue to answer or continue. Requests omit `max_tokens` and `max_output_tokens`, including the model's `max_output` default, so models with mandatory thinking can finish reasoning before writing the note. They send no reasoning/thinking parameters or inherited character generation parameters. Length is controlled by the existing cleaned-content checks and one retry, not an upstream output-token cap. It never receives reasoning segments, duplicate text segments or raw segments JSON. The system prompt supplies character/user names and requests a faithful third-person, past-tense note in the reply's language, only plot facts, no invented or unrelated material, no title/commentary/markdown, roughly ≤1/5 length and ≤120 CJK characters or 80 English words, usually 1–3 short sentences. Fast-model resolution is unchanged.

Generated notes strip think/thinking blocks (including an unclosed block while preserving preceding text), leading Summary:/摘要：/压缩： labels, surrounding quotes/markdown and repeated whitespace. A single outer `<note>`/`<reply>` pair or code fence with any language is unwrapped. Validation uses cleaned text, so large raw outputs with short usable notes are accepted. The existing acceptance rule remains a non-empty note shorter than the input; the one-fifth/CJK/English bounds remain instructions to the model.

Invalid cleaned notes retry once. The appended feedback says `Your previous output was empty` or `Your previous output was N characters; the limit is M. Output only the note.` M is the source input's Unicode length / 5, clamped to 1–120, excluding framing. Empty-result feedback also requests this cap. Reasoning text is never used as the note; empty visible content with reasoning is diagnosed as `reasoning-only`. If the provider reports `finish_reason:"length"`, or Responses reports `response.incomplete`, incomplete status or `incomplete_details.reason:"max_output_tokens"`, empty visible content is diagnosed as `truncated while reasoning` (even if the provider exposes no reasoning text).

A second invalid result sets actual=null and actual_status=failed; actual_error lists each attempt's reason (empty, reasoning-only, truncated while reasoning, cleaned character count over the length limit, or provider error), then a quoted, escaped preview bounded to 160 Unicode characters. Non-empty raw provider content is labeled `last content preview`, preserving think tags; otherwise reasoning is labeled `last reasoning preview` for diagnosis only. Reasoning is never presented as the output or used as the note. The same diagnostic is logged at warn level with the message id. Provider/HTTP errors end the request immediately with the same failed status and diagnostics, including partial streamed content if available. Context continues to fall back to the full reply; routes, SSE events and fast-model resolution are unchanged.

## Conversation titles

After the first reply, an empty conversation title uses only an explicitly configured, resolvable `fast_model_id`. It never falls back to a character/default model for titles. The instruction requests only a title in the user's language, at most 16 Chinese characters or 6 English words, without quotes or trailing punctuation. Title requests also omit output-token caps (including the model's `max_output` default) and reasoning/thinking parameters, allowing mandatory thinking to finish. Output removes `<think>…</think>` / `<thinking>…</thinking>` blocks, selects the first non-empty line, strips surrounding quotes/book-title marks/`#`/`*` and `Title:` / `标题：` prefixes, collapses whitespace, then truncates to 24 Unicode scalar values plus `…` if necessary.

Missing/unresolvable/disabled fast models, failed calls, or empty cleaned output use the first user message's first non-empty line with collapsed whitespace, truncated to 20 Unicode scalar values plus `…` when needed. Empty text (including image-only messages) uses `New chat`. Compression and memory scanning retain their existing fast-model fallback rules. Title saving remains asynchronous and preserves a title set by the user.

## Message pagination

`GET /api/conversations/{id}/messages` without `after_seq`/`around_seq` and without either `limit` or `max_chars` continues to return the full array, including hidden messages and summaries; a standalone `before_seq` returns a page before that exclusive cursor. Supplying either bound returns a page object with `messages`, `has_more`, `chars` and `bytes`. `limit` is a positive signed 64-bit integer less than `9223372036854775807`; `max_chars` is an unsigned 64-bit integer (including zero). Optional `before_seq` is an exclusive signed 64-bit seq cursor. Invalid pagination values return 400.

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

## Conversation map and seq navigation

`GET /api/conversations/{id}/map?chars=48&q=<text>&limit=N&before_seq=S` returns compact entries in ascending seq order:

```json
{"items":[{"id":"a1","seq":3000,"role":"assistant","visible":true,"preview":"Hello 中文","chars":10,"has_images":false,"swipe_count":2}],"total":1,"has_more":false}
```

The map includes hidden messages (`visible:false`) and summaries (`role:"summary",kind:"summary"`). Existing stored `kind` values are preserved. Each entry describes only active contents; it omits full content, actual, reasoning, tool payloads, image metadata/bytes, inactive swipes and archived tails. `has_images` flags a nonempty active `parts.images`; `swipe_count` is at least one. Assistant text is the concatenation of `type:"text"` segments in order. Reasoning/tool-only assistants have empty previews. Other roles use active `content`.

`chars` in an item is the full visible source text's Unicode scalar count, before preview cleanup/truncation; it excludes reasoning/tools. The query parameter `chars` controls preview size (default 48, signed integer clamped to 8–200). Previews collapse Unicode whitespace/newlines to one space and trim outer whitespace. Heading `#`, quote `>`, unordered/ordered list prefixes at line starts and code-fence delimiter/language lines are removed; code inside fences remains visible. A normal preview contains the first requested number of cleaned Unicode scalars.

A nonempty `q` searches the entire active visible source text using Unicode lowercase substring matching in Rust, identically on SQLite and PostgreSQL. It uses no SQL LIKE expression: `%`, `_`, backslash, quotes and SQL-looking strings are literal text. URL-encode the query. Empty `q` behaves like omission. Only matching items are returned; previews show a window around the first match and use `…` at truncated edges. Window body size is approximately `chars`, expanding when needed to retain a longer match. Search items add `match_start` and `match_len`, measured in Unicode scalars within the **returned preview**, including any leading ellipsis. Highlighting follows the cleaned representation (e.g. matched whitespace collapses); a match entirely in removed markdown has length zero. Search covers the original source, so a newline query can match before preview whitespace is collapsed. Lowercase expansions are mapped back to original scalar offsets. No locale-specific collation, accent normalization or transliteration is performed.

Omitting `limit` returns the entire map. An explicit positive `limit` is capped at 5000 and selects the newest eligible matches, returned ascending. `before_seq` is an exclusive signed 64-bit cursor and also works without `limit`. `total` counts all matching messages in the conversation, independently of cursor/limit. `has_more` means older matching messages exist before the returned page; pass the first item's seq as the next `before_seq`. Invalid integer parameters return 400. Reads stream one stored row at a time, skip unused JSON fields, and retain only compact results (at most `limit` when supplied); search/count scans the conversation without retaining full history.

`GET /api/conversations/{id}/messages?around_seq=N&limit=K` returns the existing page object plus two direction flags:

```json
{"messages":[],"has_more":false,"chars":0,"bytes":2,"has_more_before":false,"has_more_after":false}
```

It selects the nearest `floor(K/2)` messages strictly below `N`, then up to `K-floor(K/2)` messages at or above `N`, returning ascending seq order. This uses message counts, not arithmetic seq spacing, and includes the target if it exists. Missing `N` uses its insertion point. At either end the unavailable half is not refilled from the other side. `limit=1` selects the target or the first later message. `has_more_before` / `has_more_after` indicate stored messages outside the returned range, including hidden rows and summaries; `has_more` is their logical OR.

`GET /api/conversations/{id}/messages?after_seq=N&limit=K` selects the oldest messages strictly above `N`, returned ascending. `has_more` equals `has_more_after`; both direction flags describe messages outside the returned range. Continue downward using the last item's seq. If the page is empty, flags describe rows at/below and strictly above the requested cursor, respectively. `after_seq` also accepts `max_chars` with the existing Unicode budget and minimum user/assistant rules, applied in ascending order; a supplied `limit` remains a hard cap.

Each new cursor opts into a page object. Without `limit`, new cursor requests default to 50 messages (except `after_seq` with `max_chars`, which uses the budget alone). `before_seq`, `after_seq` and `around_seq` are mutually exclusive. `around_seq` cannot be combined with `max_chars`; these combinations return 400. New cursors accept signed 64-bit seqs and the same `limit` validation as existing message pagination. Existing requests without the new cursors retain their previous array/page shape and selection behavior. All map/navigation routes require authentication and return 404 for unknown or other users' conversations.

## Message swipes (versions)

All Message objects returned over HTTP (including full/paged lists, `GET /api/messages/{id}`, PATCH, actual and compression responses) or embedded in SSE events expose only the active contents, plus:

```json
{"id":"a1","conversation_id":"c1","seq":3000,"role":"assistant","content":"Current reply","swipe_index":1,"swipe_count":2}
```

Examples abbreviate the other existing Message fields; those fields keep their original names and types. Full `swipes` arrays and archived `tail` messages are never included in these responses. Every stored message has an initialized, nonempty `swipes` array and a valid `swipe_index`, created with the message.

Stored swipes live inside message JSON. Each snapshot contains `content`, `parts` (including images, segments and errors), `actual`, `actual_status`, `actual_error`, `usage`, `model`, `model_name`, `model_icon`, and `created_at`. User snapshots also contain `tail`, an archive of complete following messages, including their own swipe history. Identity, conversation, seq, role and visibility belong to the message. The top-level mutable fields always match the active snapshot. Context building, compression and memory scanning use only the active contents and never consume inactive swipes or tails.

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

## Image attachments

Chat `images` accepts data-URL uploads (used by the current app) or owner-scoped attachment references. Stored message `parts.images` contains only metadata references, including in SSE `user_message`, full history, paging, single-message and swipe responses:

```json
{"parts":{"images":[{"id":"<opaque-id>","mime":"image/png","width":640,"height":480,"bytes":18234}]}}
```

`width`/`height` are optional (currently extracted from PNG headers); `bytes` is the decoded blob size. Remote URL image strings are not accepted. Reference ids belong to the authenticated user and supplied reference metadata is replaced by the stored metadata. A reference owned by another user is rejected.

- `POST /api/attachments` with `{"data_url":"data:image/png;base64,..."}` optionally uploads an image ahead of sending and returns its reference. Sending a data URL directly continues to upload automatically. Supported MIME types: PNG, JPEG, GIF, WebP, AVIF and BMP. Decoded images are limited to 24 MiB; the existing 32 MiB JSON body limit still applies.
- `GET /api/attachments/{id}` returns the original image bytes and MIME type. Authenticate with the existing bearer header or `?token=` mechanism (including browser images and the embedded loopback server). Unknown/other-owner ids return 404; missing authentication returns 401. Responses use `ETag: "<id>"`, `Cache-Control: private, max-age=31536000, immutable`, and `X-Content-Type-Options: nosniff`. A matching `If-None-Match` returns 304 after authentication/ownership checks. Ids include the owner, MIME type and content in a SHA-256 digest; repeated uploads by that owner deduplicate.

Character `avatar` retains its string type. Inline avatar uploads/imports are stored as blobs and returned as `/api/attachments/{id}`, with additive `avatar_attachment` reference metadata. The existing character avatar and PNG export routes resolve stored blobs, preserving export behavior. HTTP(S) avatars keep their existing behavior.

Database schema version is **4**, created as one fresh baseline on SQLite and PostgreSQL. Startup rejects any other version with an error telling the operator to delete/recreate the database. No upgrades, conversion passes or completion markers exist. Blob bytes are stored separately from message JSON. Blobs remain available for shared references and swipe history; deleting a user removes that user's blobs.

Only the selected vision-provider context resolves image references back to data URLs, server-side, for both Chat Completions and Responses. API history never does this. Pagination `max_chars` continues to ignore images; page `bytes` still measures the compact public JSON array, which now includes only reference metadata, never the referenced blob bytes.

The Flutter client reserves image geometry before loading, loads near the viewport (including the eager newest-turn sliver), caches providers/decoded images, requests display-sized decoding, fades with the emphasized-decelerate curve, and offers retry after failure. Avatars share memoized image providers across rebuilds.

## Plugins (JavaScript API 1)

Plugins are owned by the authenticated user. Character attachments are ordered; tools, hooks and menus come from a static manifest. Saving or listing a module never evaluates its code. Each handler executes in a fresh QuickJS async runtime (64 MiB heap, 1 MiB stack); hooks have a 2-second invocation deadline and tools/menus have 10 seconds. The deadlines include host I/O. Two runtime workers are available per server. Imports, OS/file/environment access and timers are not provided. Await host calls. Persistent state belongs in KV.

### Packages and grants

```json
{
  "id":"<server-generated-id>",
  "name":"Example","version":"1","description":"Example plugin",
  "code":"export async function run(input) { return input; }",
  "format":"module-v1","enabled":false,"models":[],
  "manifest":{
    "api_version":1,
    "permissions":["read","write","storage","hooks","send","ui",{"name":"network","origins":["https://example.org"]}],
    "tools":[{"id":"lookup","name":"Lookup","description":"Look up a value","parameters":{"type":"object","properties":{"key":{"type":"string"}},"required":["key"]},"handler":"lookup"}],
    "hooks":{"beforeSend":"beforeSend","beforeToolCall":"beforeToolCall","afterToolCall":"afterToolCall","afterReply":"afterReply"},
    "menus":[{"id":"run","label":"Run example","icon":"extension","handler":"run"}]
  },
  "granted_permissions":[],"created_at":0,"updated_at":0
}
```

`handler` names an ES module export. Tools receive `(args, invocation)`, menus `(input, invocation)`; hooks receive `(payload, invocation)` and also have `payload.invocation`. Any handler may be async. Results must be JSON-serializable; `undefined` becomes `null`. Module tool string results are returned verbatim to the model; other results are serialized as JSON. Tool provider names are `p_<plugin-id>_<tool-id>`. `models` filters exported tools by saved Model.id; it does not filter hooks or menus. Hooks and menus work when the model has `tool_call:false`.

Permissions are coarse groups: `read` (conversation, character, assembled context, messages/swipes, current-character memory), `write` (message/insert/swipe and memory mutations), `storage`, `hooks`, `send`, `ui`, `network`. `network` may be a string (any origin) or `{name:"network",origins:string[]}`; an empty origins array permits any HTTP(S) origin. Allowlisted origins include scheme and port, with no path or trailing slash; redirects are checked too. Enabling records the declared list as `granted_permissions`; clients must present the list before enabling. Changing the declared permissions on PUT disables the plugin until explicitly enabled again. Grant metadata is server-managed; there are no hash-bound grants or UI receipts. Network permission permits transmitting data the plugin can read.

Limits: code 1 MiB UTF-8, 32 tools and 16 menus per plugin. Tool/menu ids are 1–20 ASCII letters/digits/underscores, unique within their category. Parameters use the supported JSON Schema subset: `type`, `properties`, `required`, `items`, `enum`, `additionalProperties` (boolean), `minimum`, `maximum`, `minLength`, `maxLength`, `minItems`, `maxItems`, `description`, `title`. Unsupported keywords are rejected at save time; tool arguments and hook-transformed arguments are checked against the schema.

| Method | Route | Request / response |
|---|---|---|
| GET | `/api/plugins` | Summary array: all package metadata, `code` omitted, `code_chars` added (Unicode scalar count). Never executes code. |
| POST | `/api/plugins` | Package fields above; returns full saved plugin. Defaults: `enabled:false`, `format:"module-v1"`, version `"1"`, empty tools/hooks/menus/permissions/models. Supplied id/timestamps/grants are ignored. `enabled:true` grants the declared list. |
| GET | `/api/plugins/{id}` | Full package including code. |
| PUT | `/api/plugins/{id}` | Save package (missing ordinary fields use defaults); omitted code preserves stored code. Id/created_at are retained. |
| DELETE | `/api/plugins/{id}` | 204; removes package, KV and accounting. Stale character attachments are ignored. |
| POST or PUT | `/api/plugins/{id}/enable` | `{enabled?:boolean}` (default true); returns full package with declared permissions granted, or grants cleared when disabled. |
| PUT | `/api/characters/{id}/plugins` | `{plugin_ids:[...]}`; rejects foreign/unknown/duplicate ids. Returns `{plugin_ids:[...]}`. |
| GET | `/api/plugins/{id}/storage` | `{plugin_id,used_bytes,entry_count,quota_bytes,tables:[{name,used_bytes,entry_count}]}`. |
| DELETE | `/api/plugins/{id}/storage` | 204; clears all plugin KV tables. |
| DELETE | `/api/plugins/{id}/storage/{table}` | 204; clears that table. |
| GET | `/api/conversations/{id}/plugin_menus` | Array of `{plugin_id,plugin_name,id,label,icon}` in character/plugin manifest order; missing icon is null. Only enabled attached plugins are listed. |
| POST | `/api/plugins/{id}/menus/{menu_id}/invoke` | SSE. `{conversation_id,input?:Json,client_id?:string,ui_capabilities?:string[]}`. Omitted input is null. |
| POST | `/api/plugins/calls/{call_id}` | `{client_id,action:string|null,input?:string|null}`; dialog reply, 204. `action:null` dismisses and returns the dialog default. Wrong user/client, expired or already answered call: 404. Invalid action/input: 400. |

Every plugin/conversation/character/call lookup is scoped to the authenticated user. HTTP validation errors use the existing `{error:string}` envelope, with `E_VALIDATION:` for plugin shape errors. Independent conversation/message/swipe/branch/title/memory/menu mutations return 409 during an operation; reads remain available. Character memory/order changes are also blocked while an affected conversation is active. Hooks from the owning generation use the internal staged APIs and can mutate their conversation. Plugin enable/revoke remains available. Stop cancels the operation, its dialogs and queued sends. The coordinator is in-process: run one backend process per database.

Characters use one ordered list, `plugin_ids`, in storage and in every HTTP response. Character POST/PUT accepts `{"plugin_ids":["<plugin-id>"]}` alongside its other fields; PUT replaces the list. `PUT /api/characters/{id}/plugins` accepts exactly `{"plugin_ids":["<plugin-id>"]}` and returns the same shape. IDs must be unique and belong to the user.

Every new user, including root on a fresh database, receives one enabled normal plugin named **骰子 / Dice**. Its code is included in the backend binary, format is `module-v1`, manifest API is 1, permissions and grants are `[]`, and models is `[]`. It exposes `roll_dice` (upstream name `p_<plugin-id>_roll_dice`) with arguments `{"expression":"4d6kh3","reason":"Ability score"}`; `expression` is required and `reason` optional. It returns the dice roller's formatted string and supports kh/kl/dl/dh, adv/dis, !/!!, r/ro, success counting, N#expr, labels, dF and d%. Attach its ID to a character to use it. Users can edit, disable or delete it; startup/login never reinstalls it.

### Invocation, reads and messages

All `rofu` I/O methods return Promises. Returned values are copies; mutate using the methods below. `Json` denotes a JSON value, `Image` a data URL upload or owner-scoped attachment reference, and `Message` the complete stored message, including swipes/tails (unlike the public HTTP message projection). Host results and handler results are limited to 1 MiB UTF-8; use pagination. Default page size is 50, maximum 100; `next_cursor:null` ends a list. Cursors are opaque strings, with no optimistic revision requirement.

```ts
rofu.invocation: Readonly<{
  id: string; plugin_id: string; conversation_id: string; character_id: string;
  source: "user" | "plugin" | "menu";
  phase: "tool" | "menu" | "beforeSend" | "beforeToolCall" | "afterToolCall" | "afterReply";
  root_turn_id: string; round: number;
}>;
// source=menu for menus; otherwise user for the root round, plugin for queued rounds.

rofu.conversation.get(): Promise<{id:string, character_id:string, title:string}>;
rofu.character.get(): Promise<{id:string, name:string, card:Json, context:Json, memory:Json, params:Json}>;
// Excludes provider credentials, MCP headers and plugin code.
rofu.context.get(): Promise<{
  messages: Json[]; tools: Json[]; tokens:number; max:number; estimated:true
}>;
// Uses actual context assembly, including applicable global/pinned memories and
// tools. Image references are not expanded to bytes. Requires a configured model.

rofu.messages.list(opts?: {cursor?:string,limit?:number,include_hidden?:boolean})
  : Promise<{items:Message[],next_cursor:string|null}>;
// Hidden rows included by default; current branch, ascending seq order.
rofu.messages.get(id:string): Promise<Message>;
rofu.messages.update(id:string, patch:Record<string,Json>): Promise<Message>;
rofu.messages.insert(input:{
  role:"user"|"assistant"|"system"|"tool", content:string,
  actual?:string|null, visible?:boolean, images?:Image[], after_seq?:number,
  call_id?:string, name?:string
}): Promise<Message>;

rofu.messages.swipes.list(id:string): Promise<{items:Json[],next_cursor:null}>;
rofu.messages.swipes.append(id:string,input:{content:string,images?:Image[],[field:string]:Json},opts?:{activate?:boolean})
  : Promise<Message>;
rofu.messages.swipes.select(id:string,index:number): Promise<{messages:Message[]}>;
rofu.messages.swipes.remove(id:string,index:number): Promise<{messages:Message[]}>;
```

Every message field is readable/writable, including role, seq, content, actual/status/error, visibility, images, segments, usage, model/provenance, timestamps, custom JSON and swipes. Only `id`, `user_id`, `conversation_id` are immutable; foreign ids never resolve. Top-level `images` and `segments` alias `parts.images` and `parts.segments`. A content-only edit updates text segments while retaining reasoning/tools. An actual-only edit sets status `ok` (or `none` for null) and clears its error; explicit actual_status/actual_error override these defaults. Explicit fields override defaults from a selected swipe.

Validation checks shapes rather than restricting categories: role/field types, JSON arguments, seq uniqueness in the conversation, valid swipe index/nonempty versions, and tool call/result pairing. Invalid shapes return `E_VALIDATION`. Native combined tool segments contain `{type:"tool",id,name,arguments:<JSON string>,result:<string>,is_error:<boolean>,duration_ms?}`. Explicit cross-message calls may use assistant `tool_calls:[{id,name,arguments:<JSON string>}]` paired with a tool message's `call_id`; `name` is optional on a tool result. Pairing is checked at handler commit so a handler can stage both sides. Swipe operations retain at least one version; selecting user versions archives/restores subsequent rows transactionally. Inactive snapshots/tails are readable and editable through the full swipes field.

Insert allocates a server id and places the message immediately after `after_seq`, shifting later seq values if needed; omission appends. It never calls the LLM. A tool-role insert needs a paired call (`call_id`/`name` are additive inputs for that purpose). System-role rows are stored but excluded from provider context; configure instructions in the character card `system_prompt`. Automatic summaries also avoid seq collisions after plugin insertion/resequencing.

### Memory and storage

```ts
rofu.memory.list(opts?:{q?:string,cursor?:string,limit?:number})
  : Promise<{items:Memory[],next_cursor:string|null}>;
rofu.memory.add(input:{content:string,tags?:string[],pinned?:boolean}): Promise<Memory>;
rofu.memory.update(id:string,patch:{content?:string,tags?:string[],pinned?:boolean}): Promise<Memory>;
rofu.memory.remove(id:string): Promise<null>;
// Current character only, source="plugin"; disabled character memory rejects access.
// Context reads can include applicable global memory, but memory CRUD never inherits share_global.

rofu.kv.get(key:string): Promise<Json|undefined>;
rofu.kv.set(key:string,value:Json): Promise<null>;
rofu.kv.delete(key:string): Promise<boolean>;
rofu.kv.list(prefix?:string): Promise<{items:{key:string,value:Json}[],next_cursor:string|null}>;
rofu.kv.list(opts?:{prefix?:string,cursor?:string,limit?:number}): Promise<{items:{key:string,value:Json}[],next_cursor:string|null}>;
rofu.kv.table(name:string): Store; // same get/set/delete/list methods
```

KV scope is **user + plugin + table**, global across characters. Ordinary methods use table `default`; named tables are optional. A plugin may explicitly choose its character id as a table name. Names are 1–128 ASCII letters/digits/underscore/hyphen/dot. Keys are 1–256 UTF-8 bytes. Compact JSON values are at most 64 KiB. Aggregate limits are 10 MiB and 10,000 entries per user/plugin, with 16 tables including default. Charged bytes are UTF-8 table name + key + compact value bytes for each entry. Usage reports each table and the plugin total. Accounting/quota checks and entry writes share a short transaction with serialized accounting-row writes on both databases; a quota failure rolls back the entire invocation. Clearing a table/plugin preserves no hidden per-character namespace. KV list is ordered by key and filters by prefix.

### Network, follow-ups and UI

```ts
rofu.http.request(opts:{
  url:string, method?:"GET"|"POST"|"PUT"|"PATCH"|"DELETE"|"HEAD",
  headers?:Record<string,string>, body?:string, timeout_ms?:number
}): Promise<{status:number,headers:Record<string,string>,body:string}>;
// Async HTTP(S), GET default, timeout default 10000ms (clamped 1..30000),
// response body <=1 MiB; invocation deadline also applies. Non-2xx is returned.

rofu.chat.send(content:string,opts?:{images?:Image[]}): Promise<{queued_id:string}>;
// afterReply and menus only; one enqueue per handler. Queues a normal user message
// and generation after this handler and round postprocessing. Does not recurse
// into /chat. At most 2 extra rounds per root operation, across all plugins.

rofu.ui.toast(message:string,opts?:{duration_ms?:number}): Promise<{delivered:boolean}>;
rofu.ui.notify(opts:{title:string,body:string}): Promise<{delivered:boolean}>;
rofu.ui.dialog(opts:{
  title:string,body?:string,actions:{id:string,label:string}[],
  input?:{label:string,initial?:string,max_length?:number},
  default_action:string,timeout_ms?:number
}): Promise<{action:string,input:string|null,reason:"answered"|"dismissed"|"timeout"|"unavailable"}>;
```

Dialogs require unique nonempty action ids and a matching default_action. Default timeout is 5000ms; accepted range 1–30000ms, shortened to fit the remaining invocation deadline. Input defaults to a maximum of 4096 Unicode characters (maximum supported limit 65536). Dismissal/timeout/unavailable choose the default action with null input. Without an attached, negotiated capable client, dialogs immediately resolve `unavailable`; toast/notify return `delivered:false`. A disconnect during a dialog also resolves `unavailable`; other generation work continues. Stop cancels instead. `delivered:true` means an event was queued to that stream, not a client acknowledgement.

Chat requests add optional fields `{client_id:"<client-instance>",ui_capabilities:["toast","notify","dialog"]}`. Plugin events are always emitted; clients must handle the current plugin SSE events. Unknown UI capabilities grant no additional access. The frontend renders UI and posts dialog answers using the same authenticated user and client_id. No durable calls, request idempotency or acknowledgement receipts exist.

Each event retains the existing SSE framing (`data: <JSON>\n\n`) and `type` discriminator:

```json
{"type":"plugin_ui","plugin_id":"p","invocation_id":"i","call_id":"c","client_id":"client","kind":"dialog","payload":{"title":"Continue?","actions":[{"id":"ok","label":"OK"}],"default_action":"ok"}}
{"type":"plugin_error","plugin_id":"p","phase":"afterReply","code":"E_LIMIT","error":"E_LIMIT: ..."}
{"type":"plugin_cancelled","plugin_id":"p","reason":"Cancelled by plugin"}
{"type":"plugin_messages_changed","plugin_id":"p","conversation_id":"conv","message_ids":["changed-or-inserted-id"],"reload":true}
{"type":"plugin_result","plugin_id":"p","menu_id":"run","result":{"ok":true}}
```

For toast the UI payload is `{message,duration_ms}`; notify/dialog carry their options. `plugin_messages_changed` signals a branch/history reload (including deletions); message_ids lists changed/inserted active rows, so it can be empty after removal. `plugin_result` is the successful menu result, emitted after its commit and before queued generation; menu failures emit plugin_error. Codes include E_VALIDATION, E_PERMISSION, E_PHASE, E_NOT_FOUND, E_LIMIT, E_CONFLICT, E_JS, E_TIMEOUT, E_CANCELLED. The normal stream ends with exactly one `done`, after every queued round. Each round retains user_message/assistant_start/assistant_done. If a plugin selects a user branch that removes the live assistant, generation stops that round and emits no stale assistant_done/actual for the removed row; the history reload is authoritative. Before rendering a final assistant, apply plugin_messages_changed reloads as needed; afterReply edits are also present in assistant_done.

### Hooks and rollback

Hooks run serially in character plugin order. Later hooks see earlier accepted patches and staged writes. Throw, timeout, invalid return, validation failure or revoked permission discards that invocation's staged message/memory/KV writes and queued send; it emits plugin_error and continues to the next plugin. UI/network effects already sent cannot be rolled back. Do not hold a SQL transaction across JavaScript, HTTP or dialog waits. No revision fields or request replay are required. Memory writes use a cheap stored-value conflict check to avoid overwriting concurrent memory edits. Message/memory mutations invalidate provider token-count preference for that conversation; context statistics then use `estimated:true`.

| Hook | Payload (plus invocation) | Return / timing |
|---|---|---|
| beforeSend | `{mode:"send"\|"edit"\|"regenerate",target_message_id:string\|null,content,images,params}` | `undefined` or `{patch?:{content?:string,images?:Image[],params?:{temperature?,top_p?,max_tokens?,reasoning_effort?}},cancel?:{reason:string}}`. Runs before any writes, tail archival or swipe allocation. Params apply only to this round. Regenerate cannot patch stored content/images. Cancellation discards the entire beforeSend chain, including staged attachments, and emits plugin_cancelled without a user message or LLM request. |
| beforeToolCall | `{assistant_id,tool:{kind:"plugin"\|"mcp"\|"memory",plugin_id:string\|null,id,name},call_id,args,parameters}` | `undefined`, `{args:Json}`, or `{skip:{result:string,is_error:boolean}}`. Runs before execution for every tool kind. Invalid raw argument JSON bypasses this hook. Tool identity is unchanged. tool_start and persisted arguments use the accepted JSON string. |
| afterToolCall | Same fields plus `{result:string,is_error:boolean,duration_ms:number,skipped:boolean}`; invalid raw args use null | `undefined` or `{result?:string,is_error?:boolean}`. Runs on success/failure/skip, before tool_end and persistence; result is then capped at 20,000 Unicode characters. |
| afterReply | `{user_message_id,assistant:Message,status:"completed"}` | `undefined` only; mutate through rofu and optionally queue send. Runs after the tool loop and before assistant_done/actual/summary. Generation reloads committed edits; an explicitly successful actual is retained. Failed/stopped/greeting/utility generations do not invoke it. |

### Small example plugin

Create a package with this code and manifest (then attach its id using the character plugins route). The menu stores global config, optionally asks the client, and inserts a system note without generating:

```js
export async function remember(input) {
  const reply = await rofu.ui.dialog({
    title: "Remember this instruction?",
    body: input.text,
    actions: [{id:"save",label:"Save"},{id:"cancel",label:"Cancel"}],
    default_action: "cancel", timeout_ms: 3000
  });
  if (reply.action !== "save") return {saved:false, reason:reply.reason};
  await rofu.kv.set("last_instruction", input.text); // shared across characters
  const message = await rofu.messages.insert({role:"system",content:input.text});
  return {saved:true, message_id:message.id};
}
export async function beforeSend(payload) {
  const instruction = await rofu.kv.get("last_instruction");
  if (instruction) return {patch:{params:{temperature:0.7}}};
}
```

```json
{"api_version":1,"permissions":["write","storage","ui","hooks"],"tools":[],"hooks":{"beforeSend":"beforeSend"},"menus":[{"id":"remember","label":"Remember instruction","handler":"remember"}]}
```

## Provider and model request overrides

Provider and Model each expose `extra_body`, an optional JSON object on POST/PUT, default `{}`. Explicit null, arrays, strings, numbers and booleans return HTTP 400 `{"error":"extra_body must be an object"}`. GET/list/save responses include the object. PUT uses replacement semantics; omitting it resets it to `{}`. Model batch creation follows the same validation.

Example provider save input (alongside the provider's other fields):

```json
{"name":"OpenRouter","kind":"openai","base_url":"https://openrouter.ai/api/v1","api_key":"<key>","extra_body":{"provider":{"order":["anthropic"],"allow_fallbacks":false}}}
```

Model example (alongside the model's other fields):

```json
{"provider_id":"<provider-id>","model_id":"anthropic/claude-sonnet-4.5","extra_body":{"provider":{"order":["google"]},"temperature":null}}
```

After building the complete upstream body, the backend deep-merges provider overrides, then model overrides. Objects merge recursively, other values replace (including arrays), and `null` deletes a key, including nested keys. In the examples the final body has `"provider":{"order":["google"],"allow_fallbacks":false}` and no `temperature`. The merge is literal: it can override/delete any generated key, including `model`, messages/input, tools, token limits, `stream` or stream options. Setting `stream:false` is allowed; response parsing still expects SSE, so the operator must supply parameters compatible with the upstream response protocol.

There is no standalone `rofu.llm` API in the current plugin runtime; `rofu.chat.send` queues normal generation through this shared request path. Both Chat Completions and Responses use this path. Title generation, actual compression, summary compression, memory scanning, provider testing and plugin-triggered chat calls apply the resolved provider/model's overrides through the same `llm::Request::body()`.

## Current-contract cleanup

`/api/tools`, `/api/tools/{id}`, `/api/tools/run`, their summary option, LocalTool, `legacy-main`, synchronous `http(...)`, and global `main(args)` are removed. Use `/api/plugins` and named ES-module exports. Plugin message updates use `content`; the `display` alias is removed. Character `tool_ids` and context `mode` are removed; use `plugin_ids`, `context.instant`, and `context.summarize`. Context HTTP/SSE shape is `{"tokens":123,"max":32768,"estimated":true,"instant":false,"summarize":true,"threshold":24576}`. No response event names changed.

Upload with `POST /api/attachments` body `{"data_url":"data:image/png;base64,..."}` to receive `{"id":"<id>","mime":"image/png","bytes":123,"width":10,"height":10}` (dimensions optional), then chat with `{"content":"Describe this","images":[{"id":"<id>"}]}`. Direct chat `{"content":"Describe this","images":["data:image/png;base64,..."]}` remains an upload path; SSE/history/swipes always return canonical attachment metadata. Remote URL strings and stored inline images are not supported. Avatar data-URL saves/imports remain uploads and return `/api/attachments/{id}` plus `avatar_attachment` metadata.

Renamed character-card keys `char_name`, `char_persona`, `world_scenario`, `char_greeting`, `example_dialogue` are removed. Standard card fields, V2/V3 containers and PNG metadata import remain available.
