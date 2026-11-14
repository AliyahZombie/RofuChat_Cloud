# Backend progress

## 已完成
- 读完 AGENTS.md 与 backend-spec.md；frontend-spec.md 仅作接口参考。
- Workspace/core/server/FFI、SQL Any 迁移、root 初始化、鉴权、用户隔离和基础 CRUD 已实现。
- 阶段 1 fmt、clippy --all-targets -D warnings、cargo test 全部通过；3 个测试通过（含 FFI start/health/stop）。
- 已安装 C 编译器、rustfmt、clippy 与本地 PostgreSQL 17，建好测试库。

## 进行中
- 阶段 1 验证完成，提交基础代码。
- 阶段 2 的 card/detect/SSE/context/LLM/JS/MCP/memory/chat/routes 草稿已写在 `/tmp/rofu-stage2/`，待复制接入 `crates/rofu-core/src/`；尚未编译验证。
- 重启前 cargo 会话已消失，已清理孤立 linker 并重新启动 cargo test。

## 待办
- 集成阶段 2；mock OpenAI/Responses/MCP 两种传输测试；并发/断线/停止、上下文压缩、记忆扫描验证。
- PG 同套测试；README/部署/CI 完成；最终 fmt/clippy/test；按阶段提交；最终报告。

构建环境：PATH=/workspace/tools/cargo/bin:$PATH，RUSTUP_HOME=/workspace/tools/rustup，CARGO_HOME=/workspace/tools/cargo，CARGO_TARGET_DIR=/workspace/work/rofu-sol/target，CARGO_BUILD_JOBS=2。
本地 PostgreSQL 测试实例已创建；连接通过 ROFU_TEST_PG_URL 提供。
仅修改 backend/、.github/workflows/backend.yml、必要时 docs/api.md；不修改/提交 app/（其他开发者正在开发）。
