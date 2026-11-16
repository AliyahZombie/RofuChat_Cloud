# Backend progress

## 已完成
- 阶段 1（69a119b）：workspace/core/server/FFI、Any SQL 迁移、root/鉴权/隔离、基础 CRUD、部署文档/CI。
- 阶段 2（b450823）：OpenAI/Responses、SSE/think、Agent、QuickJS、MCP 两种传输、记忆工具与扫描、角色卡 JSON/PNG、上下文双模式、全部 API 路由与 mock 集成测试。
- 阶段 3：关闭时回收后台任务、停止后处理、级联删除并发保护、FFI malloc/free 和重启、SIGTERM、远程 PNG 头像、usage 字段回退、完整错误/鉴权生命周期测试。
- 最终 fmt、clippy --all-targets -D warnings、cargo test 和 cargo build 全部通过。
- 测试 24 项：18 core 单测 + SQLite/PG 两个集成入口（均实际执行）+ 3 鉴权/存储 + 1 FFI；0 失败、0 ignored。两个集成入口都覆盖 OpenAI/Responses 和 MCP HTTP/SSE、JS/记忆工具、压缩/扫描/失败、断线/停止/关闭。
- 已实际验证本地 PostgreSQL 17；测试不连接真实 LLM。
- README、Dockerfile/.dockerignore、systemd 示例、C 头文件、API 补充文档、Linux/Android/Windows CI 已交付。
- 阶段 4（f7381eb）：浏览器 CORS 预检显式回显 Authorization/Content-Type；回归断言通过。恢复后重新执行 fmt、clippy --all-targets -D warnings、24 项全套测试（含实际 PG）均通过。
- 阶段 5：SPA 深层路由 fallback 返回 index.html 与 HTTP 200；回归断言通过。最终代码再次通过 fmt、clippy --all-targets -D warnings、24 项测试（实际 SQLite/PG）和 release 构建。
- release 产物冒烟 3 项通过：启动/health/注册参数、SPA 深层路由、SIGTERM 正常退出；FFI 三个 C ABI 符号已导出，产物未链接 OpenSSL。
- /workspace/work/rofu-sol/result_backend.md 已写入完整章节清单、测试数字、歧义处理与 CI 验证范围，状态为 done。

## 进行中
- 无。

## 待办
- 无实现待办。Android/Windows 交叉编译按用户要求仅配置 CI，本机不验证，未 push 或触发远程 CI。

## 环境
PATH=/workspace/tools/cargo/bin:$PATH，RUSTUP_HOME=/workspace/tools/rustup，CARGO_HOME=/workspace/tools/cargo，CARGO_TARGET_DIR=/workspace/work/rofu-sol/target，CARGO_BUILD_JOBS=2。
本机已安装 gcc、lld、rustfmt、clippy、PostgreSQL 17；PG 连接通过 ROFU_TEST_PG_URL 提供。
JuiceFS 曾在 mmap 链接和重用测试二进制时 SIGBUS。已将要求的 target 路径设为指向本机磁盘 /var/tmp/rofu-target 的符号链接，并完整重建验证通过。/workspace/work/rofu-sol/target-fuse-backup 为旧依赖缓存，不属于仓库。可选本机 /tmp/rofu-bin/cc 包装器：exec /usr/bin/cc -fuse-ld=lld -Wl,--no-mmap-output-file "$@"。CI 不依赖这些本机设置。
仅修改 backend/、.github/workflows/backend.yml、docs/api.md；不修改或提交 app/。

## Swipe / 分页 / 重试任务（2026-11-14）
- 范围：只修改 backend/ 和 docs/api.md（必要时 backend-spec §6）；不触碰同时修改的 app/。
- 阶段 1 已完成：SQL 倒序 LIMIT 分页与 message_count、参数/边界回归、API 示例；在旧 regenerate 实现上验证传统/即时 × 工具开关四种三轮重试上下文，SQLite 与实际 PostgreSQL 17 全通过（每库四种场景）。C 项未复现后端丢上下文，历史用户/助手保留，空占位和被重试旧回复排除。
- 阶段 1 检查：cargo fmt --all、cargo clippy --all-targets -- -D warnings、cargo test（24 项，SQLite/PG 均实际执行）全部通过。
- 阶段 2 已完成（阶段 1 提交 29041d7）：JSON swipe 快照/懒初始化/存储同步；regenerate 原 id 追加空版本；greeting 全宏替换版本；编辑 user 归档完整嵌套 tail；事务切换与删除；PATCH 保留推理/工具；branch 只复制激活内容；HTTP/SSE 输出 index/count；压缩/记忆扫描过滤未激活版本；完整 API 示例及 backend-spec §6 同步。
- 阶段 2 验证：cargo fmt --all、cargo clippy --all-targets -- -D warnings、cargo test 全部通过；26 项 = 20 core 单测 + 2 集成入口 + 3 storage/auth + 1 FFI，0 failed / 0 ignored。两个集成入口均实际执行（SQLite、PostgreSQL 17）。
- 每库集成场景扩展：4 种三轮重试上下文；分页边界/参数；旧消息懒初始化；开场白选择/宏/400；同 id 重试与后缀删除；user 双向恢复/嵌套 user 分支及尾部原始数据；active/inactive 删除；PATCH 后续不变；branch 原始存储无版本历史；失败/停止保留新旧版本；生成中 409；冲突注入验证事务整体回滚；压缩和记忆扫描 prompt 无 swipes/tail/未激活内容。
- C 项结论：后端无问题（所述重试请求和覆盖配置下未复现）。旧实现与新实现均保留 system、前三条 user、前两轮 assistant；即时模式按规则使用历史 actual，工具段按协议恢复；空 assistant、被重试旧 display/actual 均不进入首个生成请求。
- 收尾已完成：实现提交 29041d7、9cde049；提交路径检查通过，前端四个暂存文件保留且未进入后端提交；结果已写 /workspace/work/rofu-sol/result_swipes.md（STATUS: done）。无未完成项，未 push。
- 每阶段 fmt/clippy/test 全过后提交，不 push。最终报告 /workspace/work/rofu-sol/result_swipes.md。

- 当前环境已安装/启动 PostgreSQL 17，测试 URL：postgresql:///postgres?host=/var/run/postgresql（本机 peer 身份验证，无口令）；target 原符号链接目标丢失，已重建 /var/tmp/rofu-target 并完成 debug 编译。
- 共享索引中有前端暂存，提交使用 git commit --only -- backend docs/api.md 保留前端索引、不带入前端文件。

## Lazy image attachments / phone menus（2026-11-15）
- Backend 已完成：schema v2 独立用户图片 blob、SHA-256 去重、鉴权 GET /api/attachments/{id}（ETag / Cache-Control）和可选 POST 上传；消息/分页/SSE 返回引用，头像返回 blob 路径；保留 data URL 上传兼容。
- 升级按主键逐行迁移旧消息（含 inactive swipes / archived tails）与角色头像，完成后标记版本，可中断重试；不改写角色卡扩展字段。
- OpenAI Chat Completions / Responses 的 vision 上下文在服务端恢复 data URL；非 vision 和历史 API 不加载 blob。regenerate 保持忽略提交 content/images 的既有规则。
- SQLite / PostgreSQL 17 实际集成覆盖：512KiB 上传→引用→精确二进制取回、token URL、ETag 304/跨用户 404、去重、PNG 尺寸、分页无图片字节、SSE 无内联数据、两种 provider 还原、旧数据迁移与二次启动；FFI 测试覆盖启动后鉴权上传并获取图片。
- 最终 backend 检查：cargo fmt --all、cargo clippy --all-targets -- -D warnings、cargo test 均通过；35 项（29 core + 2 SQLite/PG 集成入口 + 3 storage/auth + 1 FFI），0 failed / ignored。
- 本任务同时获授权修改 app/；前端菜单/图片实现与 docs/api.md 等文档分开本地提交。结果记录在 /workspace/work/rofu-sol/result_lazyimg.md，不 push。

## Plugin system (2026-11-16, completed)
- Scope remained backend/**, docs/api.md and docs/backend-spec.md; app/ untouched; no push. Read design review and plugin_plan_v2.md; implemented user overrides.
- Implementation commit 75d3ff6: transactional schema 2→3 legacy conversion and old tools adapter; package CRUD/grants/order/storage; async rquickjs with limits; full staged rofu APIs; menus/UI/dialog replies; beforeSend/beforeToolCall/afterToolCall/afterReply; coordinated generation and queued follow-ups (max 2); arbitrary message fields except identities; plugin-global KV/named tables; one leading system context; staged image writes and rollback.
- Test commit 267520d: 13 new plugin test entries. Actual SQLite and PostgreSQL cover transactional migration failure/retry, legacy APIs, KV quota/usage/clear, arbitrary message edits/immutable identities, insertion without LLM and non-leading system merge, swipes/memory, isolation, module tools/async HTTP, all hooks, serial patches/rollback, follow-up cap/menu sends, dialog replies/timeout/unavailable, 409 while waiting, stop/revoke, runtime timeouts/isolation and compile without evaluation.
- Final validation passed: cargo fmt --all; cargo clippy --all-targets -- -D warnings; cargo test (53 passed = 32 core unit + 4 existing integration + 13 plugin integration/runtime + 3 storage/auth + 1 FFI, no failures or ignored tests). ROFU_TEST_PG_URL was set; PostgreSQL tests actually executed. Mock LLM only; no provider credentials used.
- docs/api.md documents every new route, exact SSE shapes, full rofu signatures, hooks/grants/limits and an example; backend-spec §9 synchronized. Result: /workspace/work/rofu-sol/result_plugins.md. No remaining backend implementation task. Frontend plugin UI integration is outside this task; existing clients retain their contract.
- Runtime deployment remains one backend process per database; pending calls/queues are intentionally transient. Invocation deadlines include dialogs; dialog timeout is shortened to remaining invocation budget. Android/Windows cross-compilation was not run locally.
- Rust env: PATH=/workspace/tools/cargo/bin:$PATH RUSTUP_HOME=/workspace/tools/rustup CARGO_HOME=/workspace/tools/cargo CARGO_TARGET_DIR=/var/tmp/rofu-target; builds -j2. Local disposable PG cluster /var/tmp/rofu-plugin-pg listens on 55439, database rofu_plugins, local trust (test-only). Servers on 7860/7862 were not touched. Logs /var/tmp/rofu-{tests,plugin-tests,clippy}.log may disappear after restart.
