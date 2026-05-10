# 更新日志 (Changelog)

## 📝 日志条目结构标准

每次版本更新应包含以下核心模块（若无相关变动可省略该模块）：

1. **版本号与日期**：格式为 `## [主版本.次版本.修订号] - YYYY-MM-DD`
2. **版本概述**：简短描述该版本的核心目标（如：大型特性更新、紧急修复、性能重构等）。
3. **🚀 新增特性 (Added)**：新加入的类、方法、系统、扩展组件等。
4. **🔄 机制更改 (Changed)**：对现有功能逻辑的修改、内部重构、性能优化等。
5. **🐛 Bug 修复 (Fixed)**：修复的逻辑错误、内存泄漏、崩溃问题等。
6. **⚠️ 废弃与移除 (Deprecated/Removed)**：标记为废弃（将在未来移除）或本次直接移除的接口、文件。
7. **🔌 API 变动说明 (API Changes)**：极其重要。详细列出函数签名改变、属性重命名等直接导致旧代码报错的改动。
8. **📘 升级指南 (Migration Guide)**：为使用旧版本框架的开发者提供 Step-by-Step 的升级建议和兼容性处理方案。
9. **📁 核心受影响文件 (Affected Files)**：列出改动最大的核心源码文件，方便开发者进行二次开发比对。

---

## 维护策略

本页面只保留最近三个版本线的更新记录，当前保留 `2.4.x`、`2.3.x` 与 `2.2.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [2.4.0] - 2026-05-10

**版本概述**：修复资源化输入一次性状态在真实 GF tick 顺序中过早清理的问题，加固 headless 场景切换加载路径，并补齐状态机命令/查询上下文代理。

### 🚀 新增特性 (Added)
- `GFState` / `GFStateMachine` 新增 `send_command()` 与 `send_query()` 代理，状态内部可通过所属状态机上下文发送命令和查询，避免在局部架构下误用全局 `Gf`。

### 🔄 机制更改 (Changed)
- `GFInputMappingUtility` 的 just-started / just-completed 清理改为按 System 观察窗口收敛，避免 `SceneTree.process_frame` 信号早于业务 System tick 时清掉可消费动作；由 Utility tick 内触发器生成的动作会保留到下一次 System tick。
- `GFSceneUtility.load_scene_async()` 在 headless 环境中对活动场景使用同步资源解析降级，但仍复用 loading 状态、缓存写入、完成信号、最短 loading 时长和安全切场队列。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFState.send_command(command: Object) -> Variant`。
- 新增 `GFState.send_query(query: Object) -> Variant`。
- 新增 `GFStateMachine.send_command(command: Object) -> Variant`。
- 新增 `GFStateMachine.send_query(query: Object) -> Variant`。

### 🐛 Bug 修复 (Fixed)
- 修复项目通过 `GFInputMappingUtility.consume_action()` 在 System tick 中轮询输入时，键盘等输入事件可能因为一次性状态过早清理而读不到的问题。
- 修复 headless 启动链路中 threaded scene loader 对活动场景加载失败时无法复用标准 `GFSceneUtility` 路由的问题。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。已有 `GFState` 状态脚本继续可用；如果状态脚本运行在局部 `GFNodeContext` 下，应优先改用状态自身的 `send_command()` / `send_query()`，避免误用全局 `Gf`。
- 如果项目在 `System.tick()` 中轮询 `GFInputMappingUtility.consume_action()`，升级后无需业务层绕过 GF 输入映射；一次性动作会保留到 System 可观察窗口。
- Headless 命令行启动链路可继续使用标准 `GFSceneUtility.load_scene_async()` 路由，不需要在业务 SceneRouter 中单独特判同步加载。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_input_mapping_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/extensions/state_machine/gf_state.gd`
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `tests/gf_core/test_gf_input_mapping_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_state_machine.gd`
- `docs/wiki/06. 命令与查询 (Commands & Queries).md`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`

---

## [2.3.0] - 2026-05-10

**版本概述**：补齐 `GFStorageUtility` 在存储根目录内管理通用文件的公开入口，便于项目在不绕过框架路径安全策略的前提下维护缓存、缩略图、manifest 或自定义资源。

### 🚀 新增特性 (Added)
- `GFStorageUtility` 新增 `ensure_directory()`、`list_files()` 与 `delete_file()`，用于创建存储目录、按扩展名枚举文件和删除存储相对文件；默认继续拒绝绝对路径并阻止 `..` 跨目录。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFStorageUtility.ensure_directory(directory_name := "") -> Error`。
- 新增 `GFStorageUtility.list_files(directory_name := "", extension_filter := "", recursive := false) -> PackedStringArray`。
- 新增 `GFStorageUtility.delete_file(file_name: String) -> Error`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。已有槽位读档 UI 继续使用 `list_slots()`；只有需要管理存储根目录下的普通文件时再使用新增文件管理 API。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_storage_utility.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `README.md`
- `addons/gf/README.md`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`

---

## [2.2.0] - 2026-05-10

**版本概述**：补齐两个通用运行时辅助能力，分别覆盖安全富文本格式化和状态快照级回滚，保持框架抽象边界，不引入项目业务流程。

### 🚀 新增特性 (Added)
- 新增 `GFRichTextFormatter`，提供 BBCode 安全转义、Markdown 常见子集转 BBCode、变量占位符替换和可配置 token 替换，适合把外部文本、本地化参数或项目生成图标片段安全写入 `RichTextLabel`。
- 新增 `GFSnapshotHistoryUtility`，提供通用快照栈、按 ID/索引恢复、前后跳转、历史上限裁剪、调试快照和默认架构全局快照捕获/恢复；也支持通过自定义回调接入任意项目状态。

### 🐛 Bug 修复 (Fixed)
- 修复新增富文本测试中的局部参数名 shadow `Node.name` 警告，避免 Godot 以 `SHADOWED_VARIABLE_BASE_CLASS` 报告测试脚本。

### 🔌 API 变动说明 (API Changes)
- 新增公开类 `GFRichTextFormatter`，包含 `to_bbcode()`、`markdown_to_bbcode()`、`replace_variables()`、`replace_tokens()`、`escape_bbcode()` 与 `strip_bbcode()`。
- 新增公开类 `GFSnapshotHistoryUtility`，包含 `snapshot_recorded`、`snapshot_restored`、`history_changed` 信号，`max_history_size`、`current_index`、`snapshot_count` 属性，以及 `configure()`、`capture()`、`push_snapshot()`、`step_back()`、`step_forward()`、`restore_index()`、`restore_snapshot_id()`、`get_current_snapshot()`、`get_history()`、`clear()` 和 `get_debug_snapshot()`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。需要安全拼接富文本或做状态快照级回滚时按需引入新增类。
- `GFSnapshotHistoryUtility` 是状态快照历史，不替代逐命令撤销的 `GFCommandHistoryUtility`，也不替代持久化写盘的 `GFStorageUtility`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_rich_text_formatter.gd`
- `addons/gf/utilities/gf_snapshot_history_utility.gd`
- `tests/gf_core/test_gf_rich_text_formatter.gd`
- `tests/gf_core/test_gf_snapshot_history_utility.gd`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `README.md`
- `addons/gf/README.md`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`
