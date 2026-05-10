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

本页面只保留最近三个版本线的更新记录，当前保留 `2.5.x`、`2.4.x` 与 `2.3.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [2.5.0] - 2026-05-10

**版本概述**：补齐纯代码状态机的状态级事件监听便捷代理，并明确状态切换后的控制流写法。

### 🚀 新增特性 (Added)
- `GFState` 新增 owner 绑定事件代理：`register_event()`、`register_assignable_event()`、`register_simple_event()`、对应注销方法以及 `unregister_owner_events()`，状态内部可直接使用所属状态机上下文注册事件监听。
- `GFStateMachine` 新增 owner 绑定事件代理，用于支撑状态级监听并跟踪实际注册过的架构，便于局部架构和架构切换场景下正确清理。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFState.register_event(event_type: Script, callback: Callable, priority: int = 0) -> void`。
- 新增 `GFState.unregister_event(event_type: Script, callback: Callable) -> void`。
- 新增 `GFState.register_assignable_event(base_event_type: Script, callback: Callable, priority: int = 0) -> void`。
- 新增 `GFState.unregister_assignable_event(base_event_type: Script, callback: Callable) -> void`。
- 新增 `GFState.register_simple_event(event_id: StringName, callback: Callable) -> void`。
- 新增 `GFState.unregister_simple_event(event_id: StringName, callback: Callable) -> void`。
- 新增 `GFState.unregister_owner_events() -> void`。
- 新增 `GFStateMachine.register_event_owned(owner: Object, event_type: Script, callback: Callable, priority: int = 0) -> void`。
- 新增 `GFStateMachine.unregister_event(event_type: Script, callback: Callable) -> void`。
- 新增 `GFStateMachine.register_assignable_event_owned(owner: Object, base_event_type: Script, callback: Callable, priority: int = 0) -> void`。
- 新增 `GFStateMachine.unregister_assignable_event(base_event_type: Script, callback: Callable) -> void`。
- 新增 `GFStateMachine.register_simple_event_owned(owner: Object, event_id: StringName, callback: Callable) -> void`。
- 新增 `GFStateMachine.unregister_simple_event(event_id: StringName, callback: Callable) -> void`。
- 新增 `GFStateMachine.unregister_owner_events(owner: Object) -> void`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。已有 `Gf.listen_owned(self, ...)` / `Gf.unlisten_owner(self)` 仍可继续使用；新的 `GFState.register_event()` 写法只是在状态类内部更简洁。
- `change_state()` 不会也不能替调用方自动 `return`。状态 `update()` 中存在多个切换条件时，应继续按优先级使用 `return` 或 `elif`，避免同一帧连续切换。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/extensions/state_machine/gf_state.gd`
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `tests/gf_core/test_gf_state_machine.gd`
- `docs/wiki/04. 事件系统 (Event System).md`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`

---

## [2.4.1] - 2026-05-10

**版本概述**：修复构建信息导出插件在 Godot 4.6 导出流程中的名称虚方法兼容问题，并收敛编辑器脚本模板 section 命名。

### 🔄 机制更改 (Changed)
- GF 编辑器脚本模板改用 `GF 生命周期方法` 和 `私有/辅助方法` section，并新增布局测试覆盖模板 section 命名，避免生成代码与规范脱节。

### 🐛 Bug 修复 (Fixed)
- `GFBuildInfoExportPlugin` 现在实现 `EditorExportPlugin._get_name()` 并返回稳定插件名，避免启用 GF 编辑器插件后导出项目时报 `Required virtual method EditorExportPlugin::_get_name must be overridden before calling.`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。Godot 4.6 导出流程可直接使用 GF 内置构建信息导出插件，不再需要项目侧保留临时补丁。
- 如需让新建 GF 模板脚本使用更新后的 section 名称，可重新通过 GF 编辑器菜单生成；已有业务脚本不需要强制迁移。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/plugin.gd`
- `addons/gf/editor/gf_build_info_export_plugin.gd`
- `tests/gf_core/test_gf_build_info.gd`
- `tests/gf_core/test_gdscript_layout_validation.gd`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`

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
