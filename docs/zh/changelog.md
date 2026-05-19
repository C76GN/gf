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

## [3.14.1] - 2026-05-19

**版本概述**：修复 UI 栈、调试界面、对象池、节点状态机和编辑器列表在关闭、清空或重建时的同帧脱树时序问题，避免旧节点在父节点下残留到帧尾。

### 🐛 Bug 修复

- 修复 `GFUIUtility.pop_panel()`、`clear_layer()`、替换层入口、`dispose()` 和非栈顶 modal 解析关闭旧面板时只等待 `queue_free()` 而没有先从 `GFUILayer_*` 脱离的问题；面板关闭后会立即从 UI 层级移除，避免同一帧远程节点树或画面里残留旧面板。
- 同步收口 `GFModalPanel` 动作按钮重渲染、`GFViewportUtility.clear_split_screen()`、`GFNodeTreeOps.free_children()`、`GFObjectPoolUtility` 容量淘汰与销毁、节点状态机清空释放、Debug Overlay / Console 销毁和扩展管理器列表刷新中的同类延迟脱树问题，避免清空或重建同一帧父节点下残留旧子节点。
- 修复 modal 自动聚焦和 UI 栈焦点查找在同一帧关闭面板后仍可能对已脱离场景树的控件调用 `grab_focus()` 的问题。

### 📁 核心受影响文件

- UI 与调试界面：`addons/gf/standard/utilities/ui/gf_ui_utility.gd`、`addons/gf/standard/utilities/ui/gf_modal_panel.gd`、`addons/gf/standard/utilities/display/gf_viewport_utility.gd`、`addons/gf/standard/utilities/debug/gf_debug_overlay_utility.gd`、`addons/gf/standard/utilities/debug/gf_console_utility.gd`。
- 节点生命周期工具：`addons/gf/standard/utilities/nodes/gf_node_tree_ops.gd`、`addons/gf/standard/utilities/nodes/gf_object_pool_utility.gd`、`addons/gf/standard/state_machine/node/gf_node_state_machine.gd`、`addons/gf/standard/state_machine/node/gf_node_state_group.gd`。
- 编辑器扩展管理：`addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd`。
- 测试与文档：`tests/gf_core/standard/utilities/ui/test_gf_ui_utility.gd`、`tests/gf_core/standard/utilities/display/test_gf_viewport_utility.gd`、`tests/gf_core/standard/utilities/nodes/test_gf_node_tree_ops.gd`、`tests/gf_core/standard/utilities/nodes/test_gf_object_pool_utility.gd`、`tests/gf_core/standard/state_machine/node/test_gf_node_state_machine.gd`、`tests/gf_core/standard/utilities/debug/test_gf_debug_overlay_utility.gd`、`tests/gf_core/standard/utilities/debug/test_gf_console_utility.gd`、`tests/gf_core/kernel/editor/test_gf_plugin_helpers.gd`、`docs/zh/standard/utilities/runtime/settings-ui-scene.md`、`docs/zh/standard/utilities/runtime/debug-observability.md`。

---
