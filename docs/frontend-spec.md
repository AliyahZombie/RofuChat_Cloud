# RofuChat 前端详细要求（Frontend Spec v1）

> 后端契约见 `docs/backend-spec.md` 第 6 节。前端不保存任何业务数据（除连接配置、登录 token、主题等本地偏好），**所有数据都通过 HTTP API 读写**。

## 0. 平台与优先级

Flutter（Dart 3.x，Material 3），一套代码覆盖：

| 平台 | 优先级 | 后端 |
|---|---|---|
| Android 手机/平板 | P0 | 内置（FFI）或远程 |
| **Android 手表（Wear OS，圆/方屏 ~192–480px）** | P0 | 内置或远程 |
| Linux 桌面 | P0 | 内置或远程 |
| Windows 桌面 | P0 | 内置或远程 |
| Web | P1 | **只能远程**（无 FFI，隐藏“本地启动”入口） |
| macOS / iOS | P2 | 预留，不阻塞 |

## 1. 依赖

- Markdown：**必须**使用 `md_single_block_renderer`（git 依赖 `https://github.com/EnderWolf006/md_single_block_renderer`）。用法：`markdownToBlocks(md)`（流式过程中）/ `markdownToBlocksAsync`（历史消息，在 isolate 解析）得到 `List<Block>`，每个 Block 用 `MarkdownSingleBlockRenderer(block)` 作为**聊天 ListView 的独立 item** 渲染（而不是一条消息一个 item），保证超长回复也只构建可视区域。
- 状态管理：Riverpod（或同等），路由 go_router。
- 网络：`http`/`dio`，SSE 自己解析（POST + 流式响应，Web 用 fetch streaming）。
- 本地存储：`shared_preferences`；token 和内嵌 root 密码用 `flutter_secure_storage`（Web 用 localStorage 回退）。
- FFI：`dart:ffi` 调 `rofu_ffi`（条件导入，Web 下为 stub）。
- 其他：`file_picker`（导入角色卡/图片）、`image_picker`（Android 拍照/相册）、`flutter_highlight` 由 md 渲染库带入。

## 2. 启动与连接

首次启动进入 **连接页**：
1. **本地启动（推荐，非 Web）**：调用 `rofu_start({"data_dir": <应用数据目录>/rofu, "root_password": <首次随机生成32位并存入 secure storage>, "listen": "127.0.0.1:0"})`，拿到端口后以 root 自动登录，直接进入主页，用户无感知。之后每次启动 App 自动启动内置后端。
2. **连接服务器**：输入地址（如 `https://rofu.example.com`），先请求 `/api/health` 校验，再显示登录表单（用户名/密码）；`allow_register=true` 时显示注册切换。
3. 可保存多个连接配置（名称、地址、用户名、token），在设置中切换；“本地”是一个固定配置项。
4. token 失效（401）时回到该连接的登录页，不清除其他配置。

Android 需声明网络权限；内置后端绑定 `127.0.0.1`。Linux/Windows 把 `librofu_ffi.so` / `rofu_ffi.dll` 随应用打包（CMake install 规则）。

## 3. 整体布局（参考 RikkaHub 截图）

### 3.1 主页面 = 聊天页
- **顶栏**：左侧抽屉按钮；中间两行——第一行会话标题（单行省略），第二行小字 `角色名 / 模型显示名（Provider名）`，点击第二行弹出模型快速切换（修改当前角色的 model_id）；右侧“新建会话”图标 + 溢出菜单（重命名、导出、压缩上下文、记忆、删除会话、角色设置）。
- **消息列表**：尽量铺满，**边距小、行距紧凑，提高信息密度**：
  - **用户消息**：右对齐**气泡**（primaryContainer 色、圆角 20、最大宽度 85%），气泡上方小字用户名 + 头像（可在设置里关闭头像）；附图以缩略图网格显示在气泡上方。图片按 `{id,mime,width?,height?,bytes}` 引用加载：先显示固定占位（有尺寸时保留比例），接近视口才开始带鉴权请求，成功后以 M3 emphasized-decelerate 淡入；失败可重试。头像复用 ImageProvider；遗留 data URL 在 native isolate 解码并缓存，Web 使用浏览器异步加载。气泡下方一排小图标：复制、编辑重发、更多（删除、切换 visible、分支）。
  - **角色回复：不使用气泡**，占满整行宽度。顶部一行：模型图标（圆形 24px）+ 角色名/模型名。正文按 segment 顺序渲染：
    - `reasoning`：可折叠卡片 “💡 Thought for 0.4 seconds ⌄”（生成中显示 “Thinking…” 并实时展开最后几行），默认折叠。
    - `tool`：工具卡片（圆角卡片，左侧图标，名称、耗时 `4.7s`、右箭头；第二行显示参数摘要（如 URL）；点击展开/弹出完整参数与结果）。连续多个工具/思考片段收进一个分组卡片，折叠时显示 “Show N more steps”。
    - `text`：markdown 块，每个 Block 是 ListView 中独立 item。
  - 回复下方一行 **token indicator**（小号灰字）：`↑1.2k ↓350 ⚡800 cached · 5.3s`（输入/输出/缓存 token，用时；估算值前加 `~`；首 token 时间长按查看），旁边操作图标：复制、重新生成、更多（删除、切换 visible、查看/编辑 actual、分支、朗读预留）。
  - **即时模式**：`actual_status=failed` 时在该消息右上角（或 token 行末尾）显示一个小的红色 `!` 图标；`pending` 时显示极小的进度点；**不弹窗、不 toast**，点击 `!` 才弹出对话框显示 `actual_error`，提供“重试”和“手动编辑 actual”。
  - `visible=false` 的消息：正常显示但整体降低不透明度（0.5）并在角落显示 “不在上下文中” 小标签。
  - **摘要卡**（role=summary）：全宽卡片，标题 “上下文已压缩”，正文默认折叠为 3 行，点击展开；卡片上可编辑摘要内容。
  - 生成失败：在 assistant 消息底部显示错误卡（红色描边）+ 重试按钮。
  - 自动滚动：在底部时跟随流式输出；用户上滑后停止跟随并显示“回到底部”浮动按钮（截图右下角那个按钮的位置）。
- **输入区**（底部圆角大卡片，类似截图）：
  - 第一行：多行输入框（`Chat with {角色名}`），桌面端 Enter 发送 / Shift+Enter 换行（可设置），移动端回车换行。
  - 第二行：左侧模型图标按钮（切换模型）、推理强度按钮（灯泡：关/低/中/高，仅 reasoning 模型可见）；右侧依次为 **加号键**（附加图片/文件，非 vision 模型时图片按钮置灰并提示）、**上下文指示器**、**发送键**（生成中变为停止键）。
  - **上下文指示器**：位于加号键和发送键之间，环形进度条（直径约 22px），进度 = `tokens / max`；颜色 <60% 主色、60–85% 橙色、>85% 红色；传统模式下在环上用一个小刻度标出压缩阈值。点击弹出小卡片：`12.3k / 200k (6%)`、模式、阈值、“立即压缩”按钮（传统模式）。数据来自 `GET /context`，以及每轮结束时 SSE 的 `context` 事件。
  - 粘贴/拖拽图片（桌面、Web）直接加入附件。

### 3.2 侧边栏（抽屉；宽屏 ≥ 1000px 时常驻左侧）
- **顶部：角色切换器**：横向滚动的头像列表（当前角色高亮）+ “+” 新建/导入角色；或者在窄屏使用下拉卡片（头像 + 名称 + 模型名），展开为角色列表，长按/右键编辑、排序、复制、导出、删除。
- 当前角色的**会话列表**（按更新时间分组：今天/昨天/7天内/更早），支持搜索、重命名、删除，生成中的会话显示小动画。
- 底部：设置、记忆、本地工具、连接切换（显示当前服务器/本地、用户名）。

### 3.3 宽屏布局
≥ 1000px：侧边栏常驻（可收起），消息列表最大宽度 900px 居中但用户可在设置中选择“铺满”；≥ 1400px 可选在右侧显示角色/上下文信息面板（P1）。

## 4. 手表适配（Wear OS，P0）

判定：`shortestSide < 300`（或 Wear 平台）。手表模式下：
- 圆屏：内容留出安全区（`MediaQuery.padding` + 圆屏额外水平内边距 ≈ 宽度 × 0.146 的 inset），列表使用居中 + 首尾留白，支持表冠/旋钮滚动（`RotaryScrollController` 或监听 `PointerScrollEvent`）。
- 隐藏头像、隐藏 token indicator（长按消息查看）、reasoning/工具卡片只显示一行摘要。
- 字号整体缩放（基础 13sp），用户气泡最大宽度 95%。
- 顶栏简化为只显示角色名（小字），左滑/上滑边缘返回。
- 输入：底部只有一个圆形“说话/输入”按钮，点击打开系统输入（语音/键盘，`TextInputType.multiline` 全屏输入页），发送后回到列表；上下文环形指示器以细环绕在该按钮外圈显示。
- 侧边栏改为独立页面：角色网格（大头像）→ 会话列表。
- 设置页在手表上只读核心项（连接、主题、Fast model），复杂编辑（角色卡、工具代码）提示“请在手机/电脑上编辑”。
- 必须在 192×192 圆屏、384×384、454×454 尺寸下无溢出（widget 测试覆盖）。

## 5. 设置

- **连接与账户**：当前连接、切换/新增连接、修改密码、登出；root 额外显示“用户管理”（列表、新建、删除、重置密码、注册开关）。
- **模型供应商**：Provider 列表（图标 + 名称 + 类型）。编辑页：名称、类型（OpenAI Compatible / OpenAI Responses）、Base URL、API Key（掩码，眼睛按钮仅在本次输入时可见）、额外请求头、启用开关、测试连接。
  - 模型管理（按 Provider 分组）：“获取模型列表” → 调用 `remote_models` → 可搜索的多选列表（显示图标、识别出的上下文长度、vision/tool/reasoning 标签）→ 保存选中项；“手动添加”（输入 model_id 后调用 `/api/models/detect` 预填）；每个模型可编辑：显示名、上下文长度、最大输出、vision/tool_call/reasoning 开关、图标（从图标列表选择）。
- **默认模型** 与 **Fast model**（用于标题、压缩、记忆扫描）选择器。
- **个人**：用户名（{{user}}）、persona。
- **记忆**：空闲扫描分钟数。
- **外观**：主题模式（跟随系统/浅色/深色/纯黑 AMOLED）、配色（动态取色 Android 12+、若干预设种子色：靛蓝、樱粉、薄荷、琥珀、石板灰、自定义色）、字体大小、消息密度（紧凑/标准）、聊天宽度（铺满/居中）、显示头像、显示 token indicator、Enter 发送。外观设置存本地并同步到 `UserSettings.client`。
- **关于**：版本、后端版本、开源许可。

- **表单约定（M3）**：需点“保存”才生效的编辑页（角色、供应商、模型、工具、记忆编辑）用复选框；立即生效的设置用开关。字段错误在字段下方以 errorText 常驻显示，不只用 snackbar。多字段编辑在紧凑宽度用全屏对话框，较宽窗口用可滚动的基本对话框（两个文字按钮、确认按钮写明动作）。表单与设置在大窗口限制为易读宽度（≤ 720dp）；分段按钮放不下时（手表、窄屏）改为下拉菜单。

### 5.1 模型图标
内置一套 SVG/PNG 图标资源（键与后端 4.2.1 一致：openai、claude、gemini、deepseek、qwen、zhipu、moonshot、grok、meta、mistral、doubao、minimax、wenxin、hunyuan、yi、cohere、microsoft、aws、stepfun、baichuan、spark、perplexity、nvidia、openrouter、siliconflow、ollama …），可从 lobehub icons（MIT）获取并打包进 assets（不在运行时联网加载）；无匹配时显示模型名首字母的彩色圆形头像（颜色由名称 hash 决定）。

## 6. 角色编辑

分页或分段：
1. **基本**：头像（选择图片/裁剪）、名称、对话模型（下拉，按 Provider 分组带图标；“使用默认模型”选项）、生成参数（temperature、top_p、max_tokens，可留空=供应商默认；推理强度）。
2. **角色卡**（兼容 SillyTavern）：description、personality、scenario、first_mes、alternate_greetings（列表）、mes_example、system_prompt、post_history_instructions、creator_notes、tags；世界书条目编辑（keys、content、constant、enabled、insertion_order）。支持导入（JSON/PNG，文件选择或拖拽）与导出（JSON/PNG）。
3. **工具**：本地工具多选（显示每个工具允许的模型；当前模型不在其允许列表时灰显说明）；MCP 服务器列表（名称、URL、传输方式 Streamable HTTP / SSE、请求头、启用），每项“测试”按钮显示获取到的工具列表。
4. **上下文**：模式切换（传统 / 即时），传统：压缩阈值（token，0=自动75%）、保留最近 n 条；即时：最近 n 条发送原文。每项旁边一句话解释。
5. **记忆**：启用记忆、空闲自动扫描、共享全局记忆；“查看此角色的记忆”入口。

新建会话时若角色有多个开场白，弹出选择（默认 first_mes）。

## 7. 本地工具编辑器

- 列表 + 编辑页：名称、描述、参数 JSON Schema（带格式校验）、代码编辑器（等宽字体、语法高亮 `flutter_highlight`/`re_editor`，行号）、启用的模型（多选，空=全部）、启用开关。
- “试运行”：输入参数 JSON → 调用 `/api/tools/run` → 显示结果、console 日志、耗时、错误。
- 新建时提供模板：
```js
// args 为模型传入的参数对象；可使用 console.log 与同步 http(method, url, body, headers)
function main(args) {
  return { echo: args };
}
```

## 8. 记忆管理页

- 过滤：全部 / 全局 / 某角色；搜索框（调用 `?q=`）。
- 每条：内容、标签、来源图标（agent/scan/user）、置顶开关、更新时间；可编辑/删除；新增。
- 会话溢出菜单中“立即整理记忆”调用 `memory_scan`。

## 9. 聊天流处理

- 发送：乐观插入用户消息（本地临时 id），收到 `user_message` 后替换为服务端消息。
- `assistant_start` 创建流式消息；`text`/`reasoning`/`tool_*` 增量更新对应 segment；markdown 在流式中每 ~50ms 节流重建**最后一个 text segment 的 blocks**（之前的 segment blocks 缓存不重建）。
- `assistant_done` 用服务端完整消息替换；`summary` 事件插入摘要卡并把 `hidden_ids` 标记为不可见；`actual*` 更新状态；`context` 更新环形指示器；`notice` 在消息下方显示一行灰色提示（不弹 toast）；`error` 显示错误卡。
- 停止：调用 `/stop`。
- 断线：流异常结束时轮询 `GET /api/conversations/{id}`（`generating`）与 messages，直到生成结束。
- 进入会话时若 `generating=true`，同样以轮询方式显示进度（P1：后端提供 `GET /stream` 重连）。

## 10. 主题

- Material 3 `ColorScheme.fromSeed`，深浅色两套；纯黑模式把 surface 设为 #000。
- 用户气泡用 `primaryContainer`，工具/思考卡用 `surfaceContainerHigh`，与截图一致的深色观感。
- 所有颜色从 ColorScheme 取，不写死。按角色取色：`outline` 只用于边界，文字一律 `onSurface` / `onSurfaceVariant`。
- 配色来源（`appearance.color_source`）：`seed`（预设或自定义种子色，存于 `seed`）或 `dynamic`（Android 12+ 壁纸取色 / 桌面强调色，经 `dynamic_color`）；平台无动态色时回退到种子色。纯黑模式同样作用于动态色的深色方案。
- 产品专用颜色角色放在 `AppColors` ThemeExtension：警告（橙色）`warning/onWarning/warningContainer/onWarningContainer`，按明暗分别取色。不加 surface tint 叠色、不加任意阴影；滚动到内容下方的顶栏改用 `surfaceContainer` 色调区分。
- 设计令牌在 `lib/core/tokens.dart`：间距 4dp 栅格（`Insets`）、圆角 0/4/8/12/16/20/28/full（`Corners`，用户气泡 20 为 large-increased）、M3 动效时长 short1…extraLong4 与 standard / emphasized 缓动（`Motion`）；组件主题在 `lib/core/theme.dart`。
- 文字只用 M3 TextTheme 角色；保留系统 TextScaler（不做截断/线性化）。手表通过主题缩小字号（基础 13sp），用户“字体大小”通过 `AppTypography.chatScale` 作用于所有聊天文字（回复、用户气泡、思考/工具、摘要、输入框）；代码字体由 `bodyMedium` 派生为等宽。
- “紧凑布局”只压缩内容与文字间距，所有可交互目标保持 ≥ 48dp。
- 动效：所有动画使用非线性 M3 缓动与时长令牌（手指拖动时直接跟手，松手后缓动落位）；系统开启“减少动态效果”时动画立即完成、加载形状静止。路由转场：Android 保留预测性返回，Linux/Windows 用 M3 fade-forwards，Apple 平台用 Cupertino。自定义加载形状（LoadingBlob）是产品插画，不是 M3 Expressive 组件，带“正在生成”无障碍标签。
- 图标：系统操作图标统一用 Material Icons Rounded 家族，切换类图标未选中用 outlined、选中用 filled；模型/品牌图标保留原图。
- 上下文菜单按输入方式分发：右键在光标处弹出菜单，长按弹出底部动作面板，“更多”按钮弹出锚定菜单，从不按窗口宽度判断。返回键顺序：先收起键盘，再关闭抽屉，最后两次返回退出。

## 11. 国际化

中文（默认跟随系统）与英文，使用 `flutter_localizations` + ARB。

## 12. 测试与验收

1. `flutter analyze` 无错误，`flutter test` 通过。
2. Widget 测试：聊天页在 360×800（手机）、1280×800（桌面）、192×192 / 454×454（手表圆屏）下渲染一段含用户气泡、思考卡、工具卡、长 markdown、摘要卡、失败感叹号的会话，无 overflow 异常。
3. 用 mock HTTP（或启动真实 `rofu-server` 测试实例）跑通：连接 → 登录 → 建 provider → 拉模型 → 建角色 → 发送消息流式显示。
4. GitHub Actions：构建 Android APK（含 3 个 ABI 的 `librofu_ffi.so`）、Linux bundle（含 `.so`）、Windows（含 `.dll`）、Web，上传产物。

## 13. 目录结构建议

```
app/
  lib/
    main.dart
    core/        # api client、sse、ffi、存储、主题、路由、尺寸断点(watch/phone/desktop)
    models/      # 与后端 JSON 一一对应的数据类（fromJson/toJson）
    features/
      connect/  chat/  sidebar/  characters/  providers/  tools/  memory/  settings/  admin/
    widgets/     # token indicator、context ring、model icon、tool card、reasoning card …
  assets/model_icons/
  test/
```
