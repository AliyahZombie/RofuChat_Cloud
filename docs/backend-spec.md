# RofuChat 后端详细要求（Backend Spec v1）

> 本文是后端实现的唯一依据。前端（Flutter）严格按第 6 节的 HTTP/SSE 契约对接，**契约字段名、类型、事件名不得擅自改动**；确需改动时同步修改本文并在 PR/提交说明中写明。

## 0. 目标与范围

RofuChat 是 Agent-Native 的角色扮演引擎。后端负责**全部数据与逻辑**：用户、模型供应商、角色、会话、消息、上下文管理、工具调用（本地 JS / MCP / 记忆）、长期记忆、流式生成。前端只做展示与交互。

同一份后端代码有两种运行形态：

| 形态 | 说明 |
|---|---|
| 独立服务器 `rofu-server` | 部署在服务器上，多用户，Web 前端必须连接它 |
| 内嵌库 `rofu-ffi`（cdylib） | 打包进 Android / Linux / Windows（以及后续 macOS/iOS）App，进程内启动 HTTP 服务监听 `127.0.0.1:<随机端口>`，前端用同一套 HTTP API 访问 |

**两种形态共用 100% 的业务代码**（`rofu-core`），差异只在启动参数。

## 1. 技术栈与工程结构

- Rust stable（edition 2021），异步运行时 tokio。
- HTTP：axum 0.8；CORS 全开（`tower-http` CorsLayer，允许任意 Origin、`Authorization`/`Content-Type` 头），供 Web 前端跨域。
- 数据库：sqlx 0.8 的 `Any` 驱动，同时支持 **SQLite**（默认，`sqlite://path?mode=rwc`）和 **PostgreSQL**（`postgres://...`）。只用两库通用的类型与语法（TEXT / BIGINT / `$n` 占位符），**不得使用编译期 `query!` 宏**（避免构建依赖数据库）。启动时自动建表/迁移（用 `schema_version` 记录版本，迁移脚本按版本递增执行）。
- HTTP 客户端：reqwest（rustls，不依赖 OpenSSL，保证 Android/Windows 交叉编译）。
- JS 引擎：rquickjs（QuickJS）。
- 密码：argon2。
- 必须能用 `cargo ndk` 编译到 `aarch64-linux-android`、`armv7-linux-androideabi`、`x86_64-linux-android`，能在 Windows MSVC、Linux x64/arm64 编译。所有 C 依赖（sqlite、quickjs）用 bundled 方式。

```
backend/
  Cargo.toml                 # workspace
  crates/
    rofu-core/               # 全部业务逻辑 + axum Router
    rofu-server/             # 二进制：CLI 参数 → start_server
    rofu-ffi/                # cdylib + staticlib：C ABI → start_server
  tests/ 或 crates/rofu-core/tests/   # 集成测试（含 mock LLM / mock MCP）
```

建议 `rofu-core` 模块划分（可调整）：`db`、`auth`、`api/*`、`llm`（chat completions + responses）、`chat`（agent 循环）、`context`（上下文构建与两种压缩模式）、`memory`、`mcp`、`jstool`、`card`（SillyTavern 卡）、`tokens`、`server`。

## 2. 启动与部署

### 2.1 rofu-server CLI

| 参数 | 环境变量 | 默认 | 说明 |
|---|---|---|---|
| `--database` | `ROFU_DATABASE` | `sqlite://rofuchat.db` | 数据库 URL |
| `--listen` | `ROFU_LISTEN` | `0.0.0.0:7860` | 监听地址 |
| `--root-password` | `ROFU_ROOT_PASSWORD` | 无 | **首次启动（库里没有 root）必须提供，否则拒绝启动并打印说明**；之后再提供则重置 root 密码 |
| `--allow-register` | `ROFU_ALLOW_REGISTER` | 不覆盖 | `true/false`，覆盖库中保存的注册开关。**默认（库中无值）= 关闭注册** |
| `--web-dir` | `ROFU_WEB_DIR` | 无 | 可选，Flutter Web 构建目录，挂在 `/`，SPA fallback 到 index.html；API 在 `/api` |
| `--no-memory-scanner` | | false | 关闭空闲记忆扫描 |

日志用 tracing，`RUST_LOG` 控制。

### 2.2 rofu-ffi C ABI

```c
// 启动后端。config_json 见下，返回 malloc 的 JSON 字符串，调用方用 rofu_free_string 释放。
// 成功: {"ok":true,"port":43567}   失败: {"ok":false,"error":"..."}
char* rofu_start(const char* config_json);
// 停止（优雅关闭），返回 0 成功
int rofu_stop(void);
void rofu_free_string(char* s);
```

`config_json`：
```json
{"data_dir": "/data/user/0/app/files/rofu", "root_password": "<前端生成并保存的随机串>", "listen": "127.0.0.1:0"}
```
- 数据库固定为 `<data_dir>/rofuchat.db`（SQLite）。
- 内嵌模式 root 密码由前端首次启动时随机生成并保存在本地安全存储中；之后每次启动都传入（相当于每次重置为同一值，幂等）。
- 内部自建一个多线程 tokio runtime（全局静态），`rofu_start` 阻塞直到端口绑定成功后返回。重复调用 `rofu_start` 时若已在运行，直接返回当前端口。
- 内嵌模式默认开启记忆扫描。

## 3. 用户与鉴权

- 表 `users(id, username UNIQUE, password_hash, is_root, created_at)`。root 用户名固定 `root`。
- 登录得到不透明 bearer token（≥48 字符随机），表 `sessions(token, user_id, created_at, last_used)`。所有 `/api/*`（除 `health`、`auth/login`、`auth/register`）需 `Authorization: Bearer <token>`；为方便图片/文件下载，同时接受查询参数 `?token=`。
- **用户数据严格隔离**：任何读写都必须带 `user_id` 条件；访问别人的资源一律返回 404（不泄露存在性）。
- 注册：仅当注册开关打开时 `POST /api/auth/register` 可用，否则 403。root 可在管理接口里开关注册、创建/删除用户、重置任意用户密码。
- 修改自己的密码后，使该用户其他 session 失效。

## 4. 数据模型

所有 id 为字符串（UUID v4 simple 格式即可）。时间戳为 **毫秒 Unix 时间（i64）**。JSON 字段一律 `snake_case`。反序列化对缺失字段使用默认值（向前兼容），未知字段忽略。

### 4.1 Provider（模型供应商）
```json
{
  "id": "…", "name": "OpenRouter",
  "kind": "openai",            // "openai" = Chat Completions 兼容；"responses" = OpenAI Responses API
  "base_url": "https://openrouter.ai/api/v1",
  "api_key": "sk-…",           // GET 时返回掩码 "sk-…abcd"（前4后4），PUT 时若传入掩码值或空串则保持原值
  "enabled": true,
  "headers": {"HTTP-Referer": "…"}   // 额外请求头
}
```

### 4.2 Model（按 provider 管理）
```json
{
  "id": "…", "provider_id": "…",
  "model_id": "anthropic/claude-sonnet-4.5",  // 发给 API 的名字
  "name": "Claude Sonnet 4.5",                // 显示名
  "context_length": 200000,
  "max_output": 64000,                         // 0 = 未知
  "vision": true,          // 多模态图片输入
  "tool_call": true,       // 支持函数调用
  "reasoning": true,       // 支持推理/思考参数
  "icon": "claude"         // 图标键，见 4.2.1
}
```
**自动识别**（`POST /api/providers/{id}/remote_models`）：
1. 请求 `GET {base_url}/models`，兼容 `{"data":[…]}` 与 `{"models":[…]}`；Gemini 风格 id 去掉 `models/` 前缀。
2. 优先使用供应商返回的元数据：`context_length` / `context_window` / `inputTokenLimit` / `max_context_length`；`top_provider.max_completion_tokens` / `outputTokenLimit` / `max_output_tokens`；`architecture.input_modalities` 含 `image` → vision；`supported_parameters` 含 `tools` → tool_call，含 `reasoning`/`include_reasoning` → reasoning；`capabilities.{vision,function_calling}`。
3. 没有元数据时按模型名启发式（关键字表写在代码常量里，便于维护）：例如 gpt-4o/gpt-4.1/gpt-5/claude-3+/gemini/`-vl`/qwen-vl/llava/pixtral/grok-4/glm-4v → vision；embedding/tts/whisper/dall-e/image/moderation/rerank → 非 tool_call；o1/o3/o4/gpt-5/r1/reasoner/thinking/qwq/claude-sonnet-4+/gemini-2.5+/qwen3/glm-4.5+ → reasoning；上下文长度按家族给默认值（gemini 1M、gpt-5 400k、claude/o 系列 200k、gpt-4o/deepseek/qwen/glm/kimi 128k，未知 32768）。
4. 返回识别结果供前端勾选，**不自动保存**；前端选中后调用 `POST /api/models`（可批量）。用户可手动编辑所有字段。

#### 4.2.1 图标键
后端按模型名/ID 识别 `icon`（小写关键字 → 键）：claude, gemini(含 gemma), openai(gpt/o1/o3/o4/chatgpt/dall-e/whisper/codex), deepseek, qwen(含 qwq), zhipu(glm), moonshot(kimi), grok, meta(llama), mistral(mixtral/codestral/pixtral/magistral/devstral), doubao, minimax, wenxin(ernie), hunyuan, yi, cohere(command), microsoft(phi), aws(nova), stepfun(step-), baichuan, spark, perplexity(sonar), nvidia(nemotron)；未命中为空串。Provider 也要有 `icon` 字段（按 base_url 域名/名称识别，同一套键 + openrouter、siliconflow、ollama 等）。

### 4.3 Character（角色）
每个角色独立配置：
```json
{
  "id": "…", "name": "露芙", "avatar": "data:image/png;base64,…" ,   // 或 http(s) URL，可空
  "model_id": "…",           // Model.id；空 = 用用户默认模型
  "card": { /* SillyTavern V2 data 段，见 4.3.1 */ },
  "mcp": [ {"name": "search", "url": "https://…/mcp", "transport": "http", "headers": {"Authorization": "Bearer …"}, "enabled": true} ],
                              // transport: "http" = Streamable HTTP；"sse" = 旧版 HTTP+SSE
  "tool_ids": ["…"],         // 启用的本地工具 LocalTool.id
  "context": {"mode": "traditional", "compress_threshold": 0, "keep_recent": 6, "display_recent": 4},
  "memory": {"enabled": true, "auto_scan": true, "share_global": true},
  "params": {"temperature": null, "top_p": null, "max_tokens": null, "reasoning_effort": ""},  // "", "low", "medium", "high"
  "sort": 0
}
```
- 头像较大时（>1MB）允许存为 data URL，但列表接口 `GET /api/characters` 返回的 `avatar` 若为 data URL 则替换为 `/api/characters/{id}/avatar`（返回图片二进制，支持 `?token=`）。单个 GET 返回完整值。

#### 4.3.1 SillyTavern 角色卡兼容
- `card` 字段 = Character Card V2 的 `data`：`name, description, personality, scenario, first_mes, mes_example, creator_notes, system_prompt, post_history_instructions, alternate_greetings[], character_book, tags[], creator, character_version, extensions{}`。
- 导入 `POST /api/characters/import`：body 为 `{"json": <卡片 JSON>}` 或 `{"png_base64": "…"}`。支持 V1（顶层字段，含 `char_name/char_persona/world_scenario/char_greeting/example_dialogue` 旧名）、V2（`spec=chara_card_v2`）、V3（`spec=chara_card_v3`，读 `data` 中兼容字段，其余放 extensions）。PNG 读取 `tEXt`/`iTXt` 中 keyword `ccv3`（优先）或 `chara` 的 base64 JSON；PNG 本身作为头像（转 data URL）。
- 导出 `GET /api/characters/{id}/export?format=json|png`：json 为 V2；png 把 V2 写入 `chara` tEXt chunk（有 PNG 头像时嵌入该头像，否则生成 1 张纯色 PNG）。
- 宏：`{{char}}` `{{user}}` `<BOT>` `<USER>`（大小写变体）在 system prompt、first_mes、示例对话、post_history_instructions 中替换。
- `character_book`（世界书）：条目 `enabled != false` 且（`constant` 或 任一 `keys` 出现在最近 N=6 条可见消息中，忽略大小写）时注入，按 `insertion_order` 升序。

### 4.4 LocalTool（本地 JS 工具）
```json
{
  "id": "…", "name": "dice", "description": "Roll dice like 2d6",
  "parameters": {"type": "object", "properties": {"expr": {"type": "string"}}, "required": ["expr"]},
  "code": "function main(args) { … return {total: 7}; }",
  "models": [],        // Model.id 列表；空 = 所有模型可用；非空则仅这些模型启用
  "enabled": true
}
```
见第 9 节执行规则。

### 4.5 Conversation
`{id, character_id, title, created_at, updated_at, memory_scanned_seq}`。创建时若角色有 `first_mes`（或指定 `greeting_index` 选 alternate_greetings），插入一条 assistant 消息作为开场白（宏替换后）。`title` 初始为空串，第一轮回复后仅在用户明确配置且能解析 Fast model 时自动生成；否则使用用户首条消息的回退标题，清洗及截断规则见 §5.4。

### 4.6 Message
```json
{
  "id": "…", "conversation_id": "…",
  "seq": 3000,                    // 排序键，新消息 = max+1000，留缝给摘要卡插入
  "role": "user",                 // "user" | "assistant" | "summary" | "system"
  "content": "显示内容（display）",
  "actual": null,                 // 即时模式：发送给模型的压缩内容
  "actual_status": "none",        // "none" | "pending" | "ok" | "failed"
  "actual_error": null,           // failed 时的错误说明（前端点击感叹号时展示）
  "visible": true,                // false = 不进入上下文，但用户仍可见
  "parts": {
    "segments": [                 // assistant 回合按时间顺序的片段
      {"type": "reasoning", "text": "…", "duration_ms": 400},
      {"type": "text", "text": "我将使用…"},
      {"type": "tool", "id": "call_1", "name": "search__scrape", "arguments": "{…}", "result": "…", "is_error": false, "duration_ms": 4700},
      {"type": "text", "text": "以下为…"}
    ],
    "images": [],                 // user 消息附带图片（data URL）
    "error": null                 // 生成失败的错误信息
  },
  "model": "…",                   // 生成它的 Model.id
  "model_name": "gemini-3.8-flash", "model_icon": "gemini",   // 冗余，便于前端显示（模型被删后仍可显示）
  "usage": {"input": 1200, "output": 350, "cached": 800, "reasoning": 120, "duration_ms": 5300, "ttft_ms": 420},
  "created_at": 0
}
```
- assistant 的 `content` = 所有 text 片段拼接（片段之间空行分隔）。
- `usage` 是整轮（含多次工具往返）的累计；`input/cached` 用供应商返回值，供应商未返回时用估算值并设 `"estimated": true`。

### 4.7 Memory（长期记忆）
`{id(12位短id), character_id|null(=全局), content, tags[], pinned, source("agent"|"scan"|"user"), created_at, updated_at}`

### 4.8 UserSettings
```json
{
  "default_model_id": "", "fast_model_id": "",
  "user_name": "User", "user_persona": "",
  "memory_idle_minutes": 10,
  "client": {}            // 前端自由存放（主题、配色、字体大小等），后端只透传
}
```

### 4.9 存储
推荐：`users`、`sessions`、`kv`、`conversations`、`messages` 为独立表；Provider/Model/Character/LocalTool/Memory/Settings 可以用通用表 `entities(id, user_id, kind, parent_id, data TEXT(JSON), created_at, updated_at)` + 索引 `(user_id, kind)`，也可以分表，由实现者决定，但必须两种数据库都能跑。`messages` 需索引 `(conversation_id, seq)`。删除 Provider 级联删除其 Model；删除 Character 级联删除其会话、消息、角色专属记忆；删除会话级联删除消息。

## 5. LLM 接入

### 5.1 统一抽象
内部消息：`System(text)`、`User{text, images}`、`Assistant{text, tool_calls[]}`、`Tool{call_id, name, content}`；流事件：`Text(delta)`、`Reasoning(delta)`、`ToolCall{id,name,arguments}`（完整）、`Usage{…}`。

### 5.2 Chat Completions（kind=openai）
- `POST {base_url}/chat/completions`，`stream: true`，`stream_options: {include_usage: true}`。
- 图片：`content` 数组 `[{type:text},{type:image_url,image_url:{url}}]`；模型 `vision=false` 时不发图片。
- 工具：`tools:[{type:function,function:{name,description,parameters}}]`；模型 `tool_call=false` 时不发工具。
- `reasoning_effort` 仅在模型 `reasoning=true` 且角色设置非空时发送。
- 解析：`delta.content`、`delta.reasoning_content` / `delta.reasoning`（DeepSeek/OpenRouter）、`delta.tool_calls` 按 `index` 累积；content 中以 `<think>…</think>` 开头的段落拆为 reasoning（需处理标签被切在两个 chunk 之间）；usage 读 `prompt_tokens / completion_tokens / prompt_tokens_details.cached_tokens（或 prompt_cache_hit_tokens）/ completion_tokens_details.reasoning_tokens`。
- 有些供应商工具调用缺 id：补 `call_<序号>_<随机>`。
- 错误：非 2xx 返回 `HTTP {status}: {body 前 800 字}`；流中 `{"error":…}` 视为错误。

### 5.3 Responses API（kind=responses）
- `POST {base_url}/responses`，`stream: true`，`store: false`。
- 上下文中唯一且位于首条的 system 转为 `instructions`；正常上下文不产生 developer 消息。user → `input_text` / `input_image`；assistant 文本 → `output_text`；工具调用 → `{type:function_call, call_id, name, arguments}`；结果 → `{type:function_call_output, call_id, output}`。
- 工具：`{type:function, name, description, parameters}`；推理：`reasoning:{effort, summary:"auto"}`；`max_output_tokens`。
- 事件：`response.output_text.delta`、`response.reasoning_summary_text.delta`、`response.reasoning_text.delta`、`response.output_item.done`（function_call）、`response.completed`/`response.incomplete`（usage：`input_tokens / output_tokens / input_tokens_details.cached_tokens / output_tokens_details.reasoning_tokens`）、`response.failed` / `error`。

### 5.4 Fast model
用户设置 `fast_model_id`，用于：标题生成、传统模式压缩、即时模式压缩、记忆扫描。标题只使用明确配置且可解析的 fast 模型，绝不回退到角色或默认模型；未配置、解析失败、调用失败或清洗后为空时，使用用户第一条消息的第一条非空行，折叠空白后取前 20 个 Unicode 字符，截断时加 `…`，纯图片等空文本使用 `New chat`。fast 标题指令要求只输出标题本身、≤ 16 个汉字 / 6 个英文词、无引号和结尾标点、使用用户的语言；输出去掉 `<think>…</think>` / `<thinking>…</thinking>` 块，取第一条非空行，去掉首尾引号、书名号、`#`、`*` 及 `Title:` / `标题：` 前缀并折叠空白，超过 24 个 Unicode 字符则取前 24 个并加 `…`。

传统模式压缩、即时模式压缩、记忆扫描的规则不变：未配置 fast 模型时回退到当前角色模型，再回退默认模型；都没有则对应功能报错（即时模式标记 failed）。

### 5.5 Token 计数
- 优先使用供应商 usage。
- 估算函数：CJK 字符每个约 1 token，其余约 4 字符 1 token，每条消息 +4，图片每张 +800。
- `GET /api/conversations/{id}/context` 返回当前上下文：`{"tokens": 12345, "max": 200000, "estimated": true, "mode": "traditional", "threshold": 150000}`。`tokens` = 按当前规则构建上下文（系统提示 + 历史 + 工具定义）的估算值；如果最后一条 assistant 的 usage 来自供应商且其后没有新消息，则用 `该轮最后一次请求的 input + output`（需在 usage 里额外记录 `last_input`）。

## 6. HTTP API 契约

统一约定：JSON 请求/响应；错误返回 `{"error": "可读信息"}` + 合适状态码（400/401/403/404/409/500）；列表直接返回数组。

### 6.1 公共
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/health` | `{"name":"RofuChat","version":"0.1.0","allow_register":false,"embedded":false}` |
| POST | `/api/auth/login` | `{username,password}` → `{token, user:{id,username,is_root,created_at}}` |
| POST | `/api/auth/register` | 同上；注册关闭时 403 |
| POST | `/api/auth/logout` | 删除当前 token |
| GET | `/api/auth/me` | 当前用户 |
| POST | `/api/auth/password` | `{old_password,new_password}` |

### 6.2 管理（仅 root，否则 403）
| GET | `/api/admin/users` | 用户列表 |
|---|---|---|
| POST | `/api/admin/users` | `{username,password}` 创建 |
| DELETE | `/api/admin/users/{id}` | 删除（不能删 root）及其全部数据 |
| POST | `/api/admin/users/{id}/password` | `{password}` 重置 |
| GET/PUT | `/api/admin/config` | `{"allow_register": false}` |

### 6.3 设置
`GET /api/settings` → UserSettings；`PUT /api/settings` 整体替换（缺失字段用默认值）。

### 6.4 Provider / Model
| GET | `/api/providers` | 列表（api_key 掩码） |
|---|---|---|
| POST | `/api/providers` | 创建（服务端生成 id、识别 icon） |
| GET/PUT/DELETE | `/api/providers/{id}` | |
| POST | `/api/providers/{id}/remote_models` | 拉取并识别远端模型（不保存），返回 Model 数组（id 为空） |
| POST | `/api/providers/{id}/test` | `{model_id}` 发一句 "hi"，返回 `{ok, latency_ms, reply|error}` |
| GET | `/api/models?provider_id=` | 列表（可按 provider 过滤） |
| POST | `/api/models` | 单个对象或数组，批量创建；同 provider 下 `model_id` 重复则更新而非重复插入 |
| POST | `/api/models/detect` | `{model_id}` → 只做启发式识别，返回 Model（便于手动添加时预填） |
| GET/PUT/DELETE | `/api/models/{id}` | |

### 6.5 Character
| GET | `/api/characters` | 列表（按 sort、created_at） |
|---|---|---|
| POST | `/api/characters` | 创建；缺省 context/memory/params 用默认值 |
| GET/PUT/DELETE | `/api/characters/{id}` | |
| GET | `/api/characters/{id}/avatar` | 头像二进制 |
| POST | `/api/characters/import` | 见 4.3.1，返回创建的 Character |
| GET | `/api/characters/{id}/export?format=json\|png` | |
| PUT | `/api/characters/order` | `["id1","id2",…]` 重排 sort |
| POST | `/api/mcp/test` | body 为一个 McpServer，返回 `{ok, tools:[{name,description,input_schema}], error}` |

### 6.6 LocalTool
| GET/POST | `/api/tools` | |
|---|---|---|
| GET/PUT/DELETE | `/api/tools/{id}` | |
| POST | `/api/tools/run` | `{code, args}` → `{result, logs[], is_error, duration_ms}`（编辑器里“试运行”） |

### 6.7 Memory
| GET | `/api/memories?character_id=&q=` | `character_id=global` 只列全局；不传列全部；`q` 关键词搜索 |
|---|---|---|
| POST | `/api/memories` | 创建（source=user） |
| PUT/DELETE | `/api/memories/{id}` | |
| POST | `/api/conversations/{id}/memory_scan` | 立即对该会话做一次记忆扫描，返回 `{added, updated, deleted}` |

### 6.8 Conversation / Message
| GET | `/api/conversations?character_id=` | 按 updated_at 倒序 |
|---|---|---|
| POST | `/api/conversations` | `{character_id, greeting_index?}` → Conversation（含开场白） |
| GET/PATCH/DELETE | `/api/conversations/{id}` | PATCH `{title}` |
| GET | `/api/conversations/{id}/messages` | 无 limit/max_chars 返回全部消息数组；`?limit=N&max_chars=C&before_seq=S`（各项可选）返回 `{messages,has_more,chars,bytes}`，从 seq<S（不传则最新）向前取，按 seq 升序返回。max_chars 累计激活 content 及 reasoning text、tool arguments/result 的 Unicode 字符；至少取到 user/assistant 各一条或会话开头，但 limit 始终是硬上限。bytes 为公开 messages 数组的 JSON UTF-8 字节数。`generating` 与 `message_count` 放在 GET Conversation 中。消息只输出激活内容与 swipe_index/swipe_count，详见 docs/api.md |
| GET | `/api/conversations/{id}/context` | 见 5.5 |
| POST | `/api/conversations/{id}/chat` | **SSE 流**，见 6.9 |
| POST | `/api/conversations/{id}/stop` | 停止当前生成（已生成部分保存） |
| POST | `/api/conversations/{id}/compress` | 立即执行一次传统压缩，返回生成的 summary Message（无可压缩时 204） |
| GET/PATCH | `/api/messages/{id}` | PATCH `{content?, visible?, actual?}`；只改激活版本，保留非 text 段；改 actual 时 status 设为 ok |
| POST | `/api/messages/{id}/swipe` | `{index}` 切换版本，user 事务归档/恢复后续消息；返回 `{messages:[...]}` |
| DELETE | `/api/messages/{id}/swipes/{index}` | 删除版本（至少保留一个），删除激活项时切到相邻项；返回 `{messages:[...]}` |
| DELETE | `/api/messages/{id}` | |
| POST | `/api/messages/{id}/actual` | 重新生成该消息 actual（即时模式失败重试），返回 Message |
| POST | `/api/messages/{id}/branch` | 从该消息（含）复制激活内容到新会话，去掉 swipes/tail，返回 Conversation |

### 6.9 聊天流 `POST /api/conversations/{id}/chat`

请求：
```json
{"content": "你好", "images": ["data:image/png;base64,…"], "regenerate": false, "edit_message_id": null}
```
- `regenerate=true`：忽略 content/images，重试最后一条 user；紧随其后的 assistant 保留 id/seq、追加并激活空 swipe，删除其后的其他消息；无紧随 assistant 则按原逻辑新建。无 user 返回 400。
- `edit_message_id`：将该 user 后续消息原样归档到当前 swipe.tail，删除对应行；追加新 content/images 的 user swipe（tail 为空）并激活，再生成。PATCH 只保存不新增版本。
- 同一会话已有生成在跑：返回 409。切换/删除 swipe 同样返回 409；详细快照、开场白版本与返回示例见 `docs/api.md`。

响应：`Content-Type: text/event-stream`，每个事件 `data: <JSON>\n\n`，JSON 都带 `type`：

| type | 字段 | 说明 |
|---|---|---|
| `user_message` | `message` | 已保存的用户消息 |
| `assistant_start` | `message` | 新建或重试版本的空 assistant（带 id、model_name、model_icon、swipe_index、swipe_count；不含完整 swipes） |
| `reasoning` | `delta` | 推理增量 |
| `reasoning_end` | `duration_ms` | 一段推理结束 |
| `text` | `delta` | 正文增量 |
| `tool_start` | `id, name, arguments` | 开始执行工具 |
| `tool_end` | `id, result, is_error, duration_ms` | 工具结束 |
| `notice` | `message` | 非致命提示（如某 MCP 连接失败） |
| `assistant_done` | `message` | 完整 assistant 消息（含 usage） |
| `actual_pending` | `id` | 即时模式开始压缩 |
| `actual` | `message` | 即时模式压缩结束（status ok 或 failed） |
| `compressing` | | 传统模式开始压缩 |
| `summary` | `message, hidden_ids[]` | 新摘要卡 + 被隐藏的消息 id |
| `context` | `tokens, max` | 本轮结束后的上下文统计 |
| `error` | `error` | 致命错误（assistant 消息 `parts.error` 同时写入） |
| `done` | | 流结束，最后一个事件 |

- **客户端断开不终止生成**：生成在独立 task 中运行并持续落库；断开只是不再推送。只有 `/stop` 会终止。
- 每 ~1s 把进行中的 assistant 消息落库一次，前端断线重连后可通过 messages 接口拿到最新内容。
- 发送 15s 一次的 SSE 注释心跳 `: ping`，防止代理断开。

## 7. Agent 循环

1. 读取角色、设置、模型；准备工具箱（第 9、10、11 节），模型 `tool_call=false` 时不提供任何工具。
2. 写入 user 消息 → 创建 assistant 消息。
3. 循环（最多 16 轮）：构建上下文（第 8 节，包括本轮已产生的 segments）→ 流式调用 → 把增量追加为 segments → 若有工具调用，逐个执行（结果截断到 20000 字符），追加 tool segment，继续下一轮；否则结束。
4. 汇总 usage（累计 input/output/cached/reasoning，duration_ms = 总耗时，ttft_ms = 首个 token 时间，last_input = 最后一轮请求的 input）。
5. 落库，发 `assistant_done`；之后执行：自动标题（异步）、上下文后处理（第 8 节）、发 `context`、`done`。
6. 出错：写入 `parts.error`，保留已生成内容，发 `error`。

## 8. 上下文管理（独立开关，按角色配置）

`character.context` 使用两个独立布尔开关：`summarize` 默认 `true`，控制阈值/手动摘要压缩；`instant` 默认 `false`，控制每条回复的 actual 压缩与历史选择。两者可以同时开启或关闭。新字段缺失时按旧数据兼容：`mode="instant"` → `instant=true, summarize=true`，其他 mode → `instant=false, summarize=true`；显式的新字段优先。保存、GET/列表和导出均包含新字段，`mode` 始终镜像 instant（true 为 `"instant"`，false 为 `"traditional"`）。JSON/PNG 角色卡导出在顶层附加 `context`，导入时恢复它；无此字段的外部角色卡使用默认值。

### 8.1 上下文组装（所有开关组合共用）
1. 只生成一条 System，且必须是 messages 的第一条。内容顺序：角色卡 `system_prompt`（为空则用内置默认 RP 提示）→ description → personality → scenario → 用户 persona → 世界书命中条目 → mes_example → 长期记忆块（pinned 记忆 + 记忆工具使用说明）→ 可见压缩摘要（每条以 `[Summary of the earlier conversation]\n` 开头，多条按 seq 顺序）→ `post_history_instructions`。各块以空行分隔，全部做宏替换。兼容历史中已有的可见 system 行时，将其内容按 seq 合入长期记忆块之后、摘要之前。
2. 历史：按 seq 遍历 `visible=true` 的 user/assistant/tool 消息（跳过内容为空且无 segments 的失败 assistant）；summary/system 不再作为独立历史消息发送。assistant 带工具片段时还原为 “assistant(tool_calls) → tool 结果 → assistant 文本” 的正确序列；user 图片仅在模型 vision 时附带。
3. 角色卡、用户设置不变且世界书命中、记忆和摘要未变时，连续两轮的 System 内容保持一致，关闭 instant 时历史仅在末尾追加（摘要压缩仍可隐藏旧消息）；开启时按 display_recent 选择 display/actual。关键词触发的世界书条目改变时，System 内容随之变化，这是预期行为。token 估算（含 context 接口）使用上述合并后的结构。开启 instant 或存在可见 summary 时，使用当前实际组装上下文的估算值（estimated=true），避免供应商压缩前的 usage 覆盖压缩后的结果；其他情况沿用最近 assistant 的供应商 usage 优先规则。GET context 与 SSE context 均附加 `instant`、`summarize` 布尔字段，并保留 mode/threshold/tokens/max/estimated。

### 8.2 摘要压缩（`context.summarize = true`）
- 每轮结束后（开启 instant 时先生成 actual）计算上下文 tokens；≥ 阈值（`compress_threshold`，0 表示模型 `context_length` 的 75%）时触发压缩；也可手动 `POST /compress`。
- 关闭 summarize 时不自动压缩，手动 `POST /api/conversations/{id}/compress` 返回 400，错误说明 `summary compression is disabled (context.summarize=false)`。开启时不受 instant 开关限制。
- 压缩：取所有 `visible=true` 的消息，保留最后 `keep_recent` 条（至少 1 条），其余（含旧摘要卡）交给 Fast model 生成摘要（提示：完整记录事件、决定、承诺、关系变化、当前处境、未完线索，合并旧摘要，与对话同语言）。
- 摘要输入只投影当前活动版本的 role/content：assistant 的 `actual_status=ok` 且 actual 为字符串时使用 actual，否则使用 content（并保留工具名、参数与结果）；使用 actual 时不附带完整 display 或 segments，避免重新膨胀。
- 成功后：被压缩消息 `visible=false`（原文保留、用户可见）；插入 `role=summary` 消息，`seq = 第一条保留消息的 seq - 1`（保证在它们之前）；发 `summary` 事件。
- 失败：不改动任何消息，发 `notice`。
- 用户可在前端手动切换任一消息的 visible（PATCH）。

### 8.3 即时压缩（`context.instant = true`）
- 每条 assistant 回复完成后，调用 Fast model 把该回复压缩后写入 `actual`（`actual_status: pending → ok/failed`，失败写 `actual_error`），`content`（display）不变。
- Fast model 解析规则不变（用户 fast_model_id → 角色 model_id → 用户 default_model_id；选中配置后解析失败仍按原规则报错）。输入只使用 content 可见正文，删除 `<think>` / `<thinking>` 块；不输入 reasoning/text segments 或整个 segments JSON。每个 tool segment 仅追加一行 `[tool] name(args) → result`，参数最多 120 个 Unicode 字符，结果最多 200 个，行内空白折叠。
- 系统提示要求：只输出一条角色扮演上下文笔记，无前言、标题、引号、Markdown 或评论；使用回复本身语言、第三人称、过去时，只保留情节相关的行为、对话大意、状态、地点、物品、关系变化、承诺及骰子/工具结果；删除描写、气氛、重复及回复以外的信息，禁止编造。目标不超过原文约 1/5，且不超过 120 个 CJK 字符或 80 个英文词，通常 1–3 个短句；提示中提供角色名和 persona 设置中的 user_name，要求用姓名消除代词歧义，不输入 persona 背景事实。
- 输出清洗：删除 think/thinking 块、前缀 `摘要：` / `Summary:` / `压缩：`、外围引号和 Markdown 标记，折叠空白。清洗后为空或 Unicode 字符数不小于输入时，只重试一次，在原系统提示追加 `Too long. Output at most N characters.`（N = 输入字符数 / 5，限制在 1–120）。仍无效则 actual=null、actual_status=failed，actual_error 明确说明两次尝试未得到更短非空笔记；模型调用失败保留原错误。
- 构建上下文时：可见 user/assistant/tool 历史中**最后 `display_recent` 条**用 display（content/完整 segments），已合入 System 的摘要/system 行不占此名额；更早的 assistant 消息若 `actual_status=ok` 用 actual（作为纯文本 assistant 消息，不含工具片段），否则**回退完整内容**。user 消息始终用原文。
- 失败不弹任何东西，前端在消息上显示感叹号（据 `actual_status=failed`），点击后展示 `actual_error`，并可调用 `POST /api/messages/{id}/actual` 重试。
- 允许用户 PATCH 手动编辑 actual。
- 切换开关不改历史数据；关闭 instant 时已有 actual 不参与普通历史上下文选择，但摘要输入仍优先使用成功的 actual。关闭 instant 后新回复不自动生成 actual，手动 actual 重试端点保持可用。无论 instant 是否开启，visible=false 的消息均不进入上下文。

## 9. 本地工具（QuickJS）

- 用户代码必须定义 `function main(args)`（可以是 `async function`），返回值：字符串原样返回，其他 `JSON.stringify`，`undefined` 返回 `"undefined"`。
- 提供 `console.log/info/warn/error`，输出收集后以 `\n\n[console]\n…` 附加到结果。
- 限制：执行超时 10s（interrupt handler），内存 64MB，栈 1MB；每次调用新建 Runtime/Context，彼此隔离；在 `spawn_blocking` 中执行。
- 提供同步 `http(method, url, body?, headers?) -> {status, body}` 宿主函数（用阻塞 reqwest，超时 15s，最大响应 1MB），让工具能访问网络；Promise 在 job queue 中驱动到完成，无法完成时报错。
- 工具名对模型暴露为 `sanitize(name)`（仅 `[A-Za-z0-9_-]`，≤64）。
- 启用条件：工具 `enabled` 且在角色 `tool_ids` 中，且 `models` 为空或包含当前 Model.id。
- 异常、语法错误、超时：返回错误文本并 `is_error=true`，不让整个回合失败。

## 10. MCP

- 每个角色可配置多个 MCP Server（`transport: "http" | "sse"`，自定义 headers）。
- **Streamable HTTP**：JSON-RPC 2.0 POST 到 url，头 `Accept: application/json, text/event-stream`、`MCP-Protocol-Version: 2025-06-18`；响应可能是 JSON 或 SSE（读取到对应 id 的响应）；保存并回传 `Mcp-Session-Id`。
- **SSE（旧版）**：GET url 建立 SSE，等待 `endpoint` 事件（相对 URL 用 url 解析），JSON-RPC POST 到该 endpoint，响应从 SSE 的 `message` 事件按 id 匹配。
- 流程：`initialize` → `notifications/initialized` → `tools/list`（支持 nextCursor 分页）→ `tools/call`。
- 工具名对模型暴露为 `sanitize("{server_name}__{tool_name}")`。结果 content 中 text 拼接，image 写 `[image]`，resource 取 text；`isError` 映射 `is_error`。
- 同一轮对话（一次 /chat 请求）内复用连接；连接或列表失败 20s 超时，发 `notice` 后跳过该服务器。
- 建议对 tools/list 结果按 (url, headers) 缓存 5 分钟。

## 11. 长期记忆（类 Hermes）

- 范围：角色专属（character_id）+ 全局（null，角色 `share_global=true` 时可见可写）。
- **按需加载**：系统提示只注入 pinned 记忆（`[id] content` 列表）+ 工具说明；其余通过工具检索。
- 角色可用工具（`memory.enabled` 时提供）：
  - `memory_search {query, limit?=10}`：关键词打分（英文按词，中文按 2-gram），返回 `[id] (pinned) content` 行；query 空返回最近条目。
  - `memory_add {content, tags?, pinned?, global?}`
  - `memory_update {id, content?, pinned?}`
  - `memory_delete {id}`
- **空闲扫描**：后台任务每 2 分钟检查：会话 `updated_at` 早于 `memory_idle_minutes`、且有 `seq > memory_scanned_seq` 的 user/assistant 消息、且当前不在生成中、且角色 `memory.enabled && auto_scan`。取新消息（最多最近 60 条，每条截断 3000 字）+ 现有记忆（最多 100 条），用 Fast model 输出 JSON `{"add":[{content,tags,global}],"update":[{id,content}],"delete":[id]}`（容忍 ```json 包裹），应用后更新 `memory_scanned_seq`。不得删除 pinned。**失败也推进 `memory_scanned_seq`**（避免反复计费），记录 warn 日志。
- 前端可在记忆管理页增删改查、置顶。

## 12. 测试与验收（必须全部通过）

1. `cargo build --release` 与 `cargo test` 通过，`cargo clippy -- -D warnings` 无警告。
2. 单元测试至少覆盖：SSE 解析（跨 chunk 切分）、`<think>` 拆分、模型能力识别与图标识别、ST 卡 V1/V2/V3 JSON 与 PNG 导入导出往返、宏替换、世界书触发、上下文组装（工具片段还原顺序、visible、summary、即时模式 display/actual 选择与回退）、QuickJS（同步/async/超时/缺 main/console）、记忆搜索（中英文）。
3. 集成测试：在测试里启动 **mock OpenAI 服务器**（axum，支持 chat/completions 与 responses 两种流式，含 tool call、usage）和 **mock MCP 服务器**（Streamable HTTP 与 SSE 两种），在 SQLite 内存/临时文件库上跑通：
   - root 初始化、无密码首启失败、注册默认关闭、用户隔离（A 用户访问 B 的会话 404）；
   - 创建 provider → remote_models → 保存模型 → 角色 → 会话（含开场白）→ /chat 流（事件顺序正确）→ 工具调用（本地 JS + MCP + memory_add）→ 落库内容正确；
   - 断开 SSE 后生成继续完成并落库；/stop 生效；重复请求 409；
   - 传统模式阈值触发压缩（summary 卡 seq 正确、旧消息 visible=false）；
   - 即时模式 actual 成功与失败（fast model 返回 500）两种路径，上下文回退正确；
   - 记忆扫描应用 add/update/delete。
4. PostgreSQL：提供 `ROFU_TEST_PG_URL` 环境变量时同一套集成测试跑在 PG 上（CI 用 postgres service 跑一次）。
5. `rofu-ffi` 提供一个 Rust 测试：调用 `rofu_start` → HTTP `GET /api/health` → `rofu_stop`。
6. 交叉编译：GitHub Actions 中 `cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 build -p rofu-ffi --release` 与 Windows `cargo build -p rofu-ffi -p rofu-server --release` 成功。

## 13. 交付物

- `backend/` 全部代码 + 测试。
- `backend/README.md`：构建、运行、部署（含 systemd 示例、Docker 示例 `Dockerfile`）、配置项说明。
- `docs/api.md` 若与本文第 6 节有任何补充（例如新增字段），在此记录。
- `.github/workflows/backend.yml`：test（sqlite + postgres service）、clippy、android ndk 构建、windows 构建，上传 `rofu-server` 与各平台 `rofu_ffi` 产物。
