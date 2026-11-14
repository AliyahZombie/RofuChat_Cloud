# Backend progress

## 已完成
- 阶段 1（69a119b）：workspace/core/server/FFI、Any SQL 迁移、root/鉴权/隔离、基础 CRUD、部署文档/CI。
- 阶段 2（b450823）：OpenAI/Responses、SSE/think、Agent、QuickJS、MCP 两种传输、记忆工具与扫描、角色卡 JSON/PNG、上下文双模式、全部 API 路由与 mock 集成测试。
- 阶段 3：关闭时回收后台任务、停止后处理、级联删除并发保护、FFI malloc/free 和重启、SIGTERM、远程 PNG 头像、usage 字段回退、完整错误/鉴权生命周期测试。
- 最终 fmt、clippy --all-targets -D warnings、cargo test 和 cargo build 全部通过。
- 测试 24 项：18 core 单测 + SQLite/PG 两个集成入口（均实际执行）+ 3 鉴权/存储 + 1 FFI；0 失败、0 ignored。两个集成入口都覆盖 OpenAI/Responses 和 MCP HTTP/SSE、JS/记忆工具、压缩/扫描/失败、断线/停止/关闭。
- 已实际验证本地 PostgreSQL 17；测试不连接真实 LLM。
- README、Dockerfile/.dockerignore、systemd 示例、C 头文件、API 补充文档、Linux/Android/Windows CI 已交付。

## 进行中
- 只运行一次最终 release 构建，补验 backend-spec §12.1；开发迭代均使用 debug 构建。

## 待办
- 记录 release 结果，写 /workspace/work/rofu-sol/result_backend.md 并提交最终进度。Android/Windows 交叉编译按用户要求仅配置 CI，本机不验证。

## 环境
PATH=/workspace/tools/cargo/bin:$PATH，RUSTUP_HOME=/workspace/tools/rustup，CARGO_HOME=/workspace/tools/cargo，CARGO_TARGET_DIR=/workspace/work/rofu-sol/target，CARGO_BUILD_JOBS=2。
本机已安装 gcc、lld、rustfmt、clippy、PostgreSQL 17；PG 连接通过 ROFU_TEST_PG_URL 提供。
JuiceFS 曾在 mmap 链接和重用测试二进制时 SIGBUS。已将要求的 target 路径设为指向本机磁盘 /var/tmp/rofu-target 的符号链接，并完整重建验证通过。/workspace/work/rofu-sol/target-fuse-backup 为旧依赖缓存，不属于仓库。可选本机 /tmp/rofu-bin/cc 包装器：exec /usr/bin/cc -fuse-ld=lld -Wl,--no-mmap-output-file "$@"。CI 不依赖这些本机设置。
仅修改 backend/、.github/workflows/backend.yml、docs/api.md；不修改或提交 app/。
