# Backend progress

## 已完成
- 阶段 1 已提交 69a119b：workspace/core/server/FFI、Any SQL 迁移、root/鉴权/隔离、基础 CRUD、部署文档/CI 初稿；fmt、clippy、3 个测试通过。
- 阶段 2：两种 LLM、SSE/think 解析、Agent/工具、QuickJS、MCP 两种传输、记忆工具/扫描、角色卡 JSON/PNG、宏/世界书、上下文双模式、全部 API 路由已接入。
- 阶段 2 fmt、clippy --all-targets -D warnings、cargo test 通过：13 个单元测试 + 2 个集成入口 + 2 个存储测试 + 1 个 FFI 测试。无 PG 环境时 PG 入口明确跳过。
- 已用本机 PostgreSQL 17 设置 ROFU_TEST_PG_URL 实跑同一套集成流程：SQLite 与 PostgreSQL 均通过。
- 所有实现与测试均已在 backend/；不依赖 /tmp 草稿。

## 进行中
- 阶段 3 审核边界：优雅关闭/任务回收、停止后处理、并发修改、FFI 分配器、增补错误路径和验收覆盖。

## 待办
- 最终 API 文档/NOTES/README/CI 审查；最终 fmt/clippy/test（含本地 PG）；cargo build；提交。
- /workspace/work/rofu-sol/result_backend.md：逐节清单、测试数字、偏离与未完成项。交叉编译只写 CI，不在本机验证。

环境：PATH=/workspace/tools/cargo/bin:$PATH，RUSTUP_HOME=/workspace/tools/rustup，CARGO_HOME=/workspace/tools/cargo，CARGO_TARGET_DIR=/workspace/work/rofu-sol/target，CARGO_BUILD_JOBS=2。
本机安装了 gcc、lld、rustfmt、clippy、PostgreSQL 17。GNU ld 在 JuiceFS 下很慢；可重建 /tmp/rofu-bin/cc（脚本 exec /usr/bin/cc -fuse-ld=lld "$@"）并加入 PATH。PG 连接通过 ROFU_TEST_PG_URL 提供。
仅修改 backend/、.github/workflows/backend.yml、docs/api.md；app/ 属于并行前端工作，勿 add/commit。
