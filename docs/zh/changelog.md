# 更新日志 (Changelog)

## 📝 日志条目结构标准

每次版本更新应包含以下核心模块（若无相关变动可省略该模块）：

1. **版本号与日期**：格式为 `## [主版本.次版本.修订号] - YYYY-MM-DD`
2. **版本概述**：简短描述该版本的核心目标（如：大型特性更新、紧急修复、性能重构等）。
3. **🚀 新增特性 (Added)**：新加入的类、方法、系统、扩展组件等。
4. **🔄 机制更改 (Changed)**：对现有功能逻辑的修改、内部重构、性能优化等。
5. **🐛 Bug 修复 (Fixed)**：修复的逻辑错误、内存泄漏、崩溃问题等。
6. **⚠️ 废弃与移除 (Deprecated/Removed)**：标记为废弃（将在未来移除）或本次直接移除的接口、文件。
7. **🔌 API 变动说明 (API Changes)**：详细列出函数签名改变、属性重命名等直接导致旧代码报错的改动。
8. **📘 升级指南 (Migration Guide)**：为使用旧版本框架的开发者提供 Step-by-Step 的升级建议和兼容性处理方案。
9. **📁 核心受影响文件 (Affected Files)**：列出改动最大的核心源码文件，方便开发者进行二次开发比对。

---

## 维护策略

正式文档中的更新日志只保留当前最新发布版本。发布新版本时，应将 `[未发布]` 合并为具体版本条目，并删除上一个正式版本条目；旧版本历史以 Git 历史和 GitHub Releases 为准，避免正式文档长期膨胀。

---

## [3.15.0] - 2026-05-19

**版本概述**：以框架抽象边界和 Godot 4.6 稳定性为优先，移除内置默认 modal 视觉面板，补齐 UI 异步加载状态观测，并收口信号参数、节点状态组、对象生命周期、编辑器动作、保存图和网络会话的边界问题。

### 🔄 机制更改 (Changed)

- `GFUIUtility` 不再创建框架默认 modal 视觉面板；modal 只保留配置、动作、结果和面板栈策略，项目应使用自己的 `.tscn` 面板实现视觉、动画、输入和结果发射。
- `GFUIUtility` 的异步面板入口新增请求开始/结束信号和 pending 查询；框架仍不创建 Loading 视觉，但项目不需要自行维护底层资源请求计数。
- `GFDebugOverlayUtility` 与开发者控制台保持一致，默认只在 debug 构建中创建调试 GUI，发布构建需要显式关闭 `debug_only` 才会显示覆盖层。
- 新增内部 `GFInstanceGuard` helper，统一从 `Variant`、`WeakRef` 和 `instance_id` 安全解析仍有效的 `Object` / `Node` / `Control`，供 kernel、standard 与扩展侧复用失效实例防护逻辑。
- `GFNodeStateGroup` 新增 `stop()`，用于退出当前状态与暂停栈但保留已注册状态；`GFNodeStateMachine.clear_state_groups()` 会在解绑状态组前停止外部状态组，避免旧状态组脱离状态机后仍保持 active state。
- `GFSignalConnection`、`GFAsyncWaitSupport.await_signal_payload_safely()`、`GFSignalBridgeBinding` 与 `GFSignalRuntimeProbe` 的通用信号参数捕获上限从 8 个提高到 16 个。

### 🐛 Bug 修复

- 修复 `GFPluginActions.setup()` 重复调用时旧 `FileDialog` 没有立即脱离父节点的问题，避免编辑器插件重复初始化留下旧对话框。
- 修复 9 个参数以上的 Signal 通过异步等待、信号工具、信号桥接或运行时信号探针时 payload 被截断或丢失的问题。
- 修复 `GFNetworkSession` 收到非 `Dictionary` metadata 时静默丢弃的问题，现在会输出 warning 并保留空 metadata。
- 修复 `GFSaveEntityFactory.after_entity_created()` 若删除刚创建的实体，SaveGraph 仍可能把失效 Source 交给后续恢复流程的问题。
- 修复 UI 栈、对象池、能力元数据、命令序列回滚和输入触发器在缓存对象已释放后仍先执行类型转换的问题，避免 Godot 4.6 报告 freed object cast 错误。

### ⚠️ 废弃与移除 (Removed)

- 移除代码构建 UI 的 `GFModalPanel` 默认面板，框架不再提供内置弹窗视觉实现。

### 🔌 API 变动说明 (API Changes)

- 移除 `GFModalPanel`。
- 移除 `GFUIUtility.open_modal()`；项目应通过 `push_panel_with_options()`、`push_panel_async_with_options()` 或 `push_panel_instance_with_options()` 打开自己的 modal scene / instance，并自行连接面板的 `resolved(result: GFModalResult)` 信号。
- `GFUIUtility` 新增 `AsyncPanelLoadStatus`、`panel_async_load_started`、`panel_async_load_finished`、`has_pending_async_panel()` 和 `get_pending_async_panel_requests()`。
- `GFDebugOverlayUtility` 新增 `debug_only` 公共变量，默认 `true`。
- 新增 `GFNodeStateGroup.stop()`。

### 📘 升级指南 (Migration Guide)

- 将 `GFUIUtility.open_modal(config, layer, context, callback)` 改为打开项目自己的 modal scene：使用 `push_panel_with_options("res://ui/your_modal.tscn", layer, modal_options, config_callback)`，在 `config_callback` 中调用项目面板的 `configure(config, context)` 并连接 `resolved(result)`。
- 自定义 modal 面板建议实现 `configure(config: GFModalConfig, context: Dictionary)`、`resolve_cancel()` 和 `resolved(result: GFModalResult)`；`request_dismiss_top()` 会在允许取消时调用 `resolve_cancel()`，关闭时机由项目面板或项目回调决定。
- 异步 UI 的 Loading 视觉仍由项目面板实现；项目可改为监听 `panel_async_load_started` / `panel_async_load_finished`，并用 `has_pending_async_panel(layer)` 判断是否还有同层请求未完成。

### 📁 核心受影响文件 (Affected Files)

- 信号与状态机：`addons/gf/standard/utilities/signals/gf_signal_connection.gd`、`addons/gf/standard/common/gf_async_wait_support.gd`、`addons/gf/standard/utilities/signals/bridge/gf_signal_bridge_binding.gd`、`addons/gf/standard/utilities/debug/gf_signal_runtime_probe.gd`、`addons/gf/standard/state_machine/node/gf_node_state_group.gd`、`addons/gf/standard/state_machine/node/gf_node_state_machine.gd`。
- UI、调试、编辑器、网络、保存与生命周期：`addons/gf/standard/utilities/ui/gf_ui_utility.gd`、`addons/gf/standard/utilities/ui/gf_modal_panel.gd`、`addons/gf/standard/utilities/debug/gf_debug_overlay_utility.gd`、`addons/gf/kernel/core/gf_instance_guard.gd`、`addons/gf/kernel/editor/gf_plugin_actions.gd`、`addons/gf/extensions/network/session/gf_network_session.gd`、`addons/gf/extensions/save/graph/gf_save_graph_utility.gd`、`addons/gf/standard/utilities/nodes/gf_object_pool_utility.gd`、`addons/gf/extensions/capability/core/gf_capability_utility.gd`、`addons/gf/standard/sequence/gf_command_sequence.gd`。
