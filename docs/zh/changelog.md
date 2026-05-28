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

## [3.23.0] - 2026-05-28

**版本概述**：增强资源索引、目录变化检测、SaveGraph 属性持久化、屏幕转场、调试趋势和 3D 环绕相机入口，并收紧若干默认行为，确保框架只提供通用协议与能力，不替项目决定 UI 文案、按钮动作或输入策略。

### 🚀 新增特性 (Added)

- 新增 `GFResourceRegistryTools`，支持扫描目录、生成 `GFResourceRegistry`、推导资源 ID、路径字段、目录标签和常见 `ResourceLoader` 类型提示。
- 新增 `GFDirectoryWatchUtility` 与 `GFDirectoryChangeSet`，提供调用方驱动的目录快照差异检测，用于编辑器工具、资产索引器和构建脚本。
- 新增 `GFPersistPropertiesSource`，作为 `GFSaveSource` 的属性白名单薄封装，内部复用 `GFNodePropertySerializer` 并保持 SaveGraph 载荷格式。
- 新增 `GFScreenTransitionUtility` 与 `GFScreenTransitionEffect`，提供通用屏幕覆盖式淡入淡出和可选 shader progress，不侵入具体场景切换流程。
- 新增 `GFMetricSeries`，并让 `GFDebugOverlayUtility` 可显示短期指标趋势面板。
- 新增 `GFCameraOrbitRig3D` 与 `GFCameraOrbitInput3D`，提供通用 3D 环绕相机姿态和可配置输入桥接。

### 🔄 机制更改 (Changed)

- `GFSaveSlotWorkflow` 不再为空槽自动生成 `Slot {index}` 展示名；`empty_display_name_template` 默认为空，项目可按 UI 与本地化需要显式配置。
- `GFSaveSlotWorkflow.active_slot_index` 默认值改为 0，避免框架默认采用读档 UI 常见的一基槽位习惯。
- `GFSaveSlotCard` 改为暴露非本地化 `status_id`，项目 UI 负责映射状态文案、样式和图标。
- `GFTouchButton.accept_mouse_input` 默认关闭，避免触屏控件在桌面端隐式接管鼠标左键。
- `GFModalConfig` 不再隐式生成 OK 动作；`GFModalAction` 默认保持空动作，项目必须显式声明可渲染动作。
- `GFNotificationUtility` 不再为通知 action 自动派生 `label`，项目 UI 负责动作展示文案。
- `GFUndoableCommand.action_name` 默认改为空字符串，项目历史面板或调试工具需要文案时显式设置。

### ⚠️ 废弃与移除 (Deprecated/Removed)

- 移除 `GFSaveSlotCard.get_status_text()`。
- 移除 `GFModalConfig.get_actions_or_default()`。

### 🔌 API 变动说明 (API Changes)

- 新增 `GFSaveSlotCard.get_status_id()`，返回 `empty`、`incompatible`、`active` 或 `ready`。
- 新增 `GFModalConfig.get_actions()`，只返回已显式设置 `action_id` 的动作副本。
- `GFSaveSlotWorkflow.empty_display_name_template` 默认值由 `"Slot {index}"` 改为 `""`。
- `GFSaveSlotWorkflow.active_slot_index` 默认值由 `1` 改为 `0`。
- `GFTouchButton.accept_mouse_input` 默认值由 `true` 改为 `false`。
- `GFModalAction.action_id` 默认值由 `ok` 改为 empty，`label` 默认值由 `OK` 改为空字符串，`result_status` 默认值由 `confirmed` 改为 `dismissed`。
- `GFNotificationUtility` 的 action 归一化不再把 `label` 缺省为 `id`。
- `GFUndoableCommand.action_name` 默认值由 `"未命名动作"` 改为 `""`。

### 📘 升级指南 (Migration Guide)

- 需要存档槽位占位名的项目，显式设置 `GFSaveSlotWorkflow.empty_display_name_template`，或在 UI 层按 `slot_index` 自行生成本地化文案。
- 依赖默认当前槽位为 1 的项目，显式设置 `GFSaveSlotWorkflow.active_slot_index = 1`。
- 需要状态文字的读档 UI，改用 `GFSaveSlotCard.get_status_id()` 或 `to_dict()["status_id"]` 映射项目自己的文本。
- 需要桌面鼠标模拟触屏按钮的项目，显式开启 `GFTouchButton.accept_mouse_input`。
- 需要 modal 确认按钮的项目，显式创建 `GFModalAction` 并加入 `GFModalConfig.actions`。
- 需要通知按钮或撤销历史显示文案的项目，显式设置通知 action 的 `label` 或命令的 `action_name`。

### 📁 核心受影响文件 (Affected Files)

- `addons/gf/standard/utilities/assets/gf_resource_registry_tools.gd`
- `addons/gf/standard/utilities/io/gf_directory_watch_utility.gd`
- `addons/gf/standard/utilities/io/gf_directory_change_set.gd`
- `addons/gf/standard/utilities/scene/gf_screen_transition_utility.gd`
- `addons/gf/standard/utilities/scene/gf_screen_transition_effect.gd`
- `addons/gf/standard/utilities/debug/gf_debug_overlay_utility.gd`
- `addons/gf/standard/utilities/debug/gf_metric_series.gd`
- `addons/gf/standard/input/touch/gf_touch_button.gd`
- `addons/gf/standard/command/gf_undoable_command.gd`
- `addons/gf/standard/utilities/ui/gf_notification_utility.gd`
- `addons/gf/standard/utilities/ui/gf_modal_action.gd`
- `addons/gf/standard/utilities/ui/gf_modal_config.gd`
- `addons/gf/extensions/save/core/gf_persist_properties_source.gd`
- `addons/gf/extensions/save/slots/gf_save_slot_card.gd`
- `addons/gf/extensions/save/slots/gf_save_slot_workflow.gd`
- `addons/gf/extensions/camera/nodes/gf_camera_orbit_rig_3d.gd`
- `addons/gf/extensions/camera/nodes/gf_camera_orbit_input_3d.gd`
- `tests/gf_core/standard/utilities/assets/test_gf_resource_registry_tools.gd`
- `tests/gf_core/standard/utilities/io/test_gf_directory_watch_utility.gd`
- `tests/gf_core/standard/utilities/scene/test_gf_screen_transition_utility.gd`
- `tests/gf_core/standard/utilities/debug/test_gf_metric_series.gd`
- `tests/gf_core/standard/input/touch/test_gf_touch_controls.gd`
- `tests/gf_core/standard/utilities/ui/test_gf_ui_utility.gd`
- `tests/gf_core/standard/utilities/ui/test_gf_notification_utility.gd`
- `tests/gf_core/standard/utilities/history/test_gf_command_history_utility.gd`
- `tests/gf_core/extensions/save/test_gf_persist_properties_source.gd`
- `tests/gf_core/extensions/save/test_gf_save_slot_card.gd`
- `tests/gf_core/extensions/save/test_gf_save_slot_workflow.gd`
- `tests/gf_core/extensions/camera/test_gf_camera_orbit_3d.gd`
- `docs/zh/standard/utilities/io/assets-jobs-warmup/asset-utility/resource-registry.md`
- `docs/zh/standard/utilities/io/assets-jobs-warmup/index.md`
- `docs/zh/standard/utilities/runtime/settings-ui-scene/scene-flow/switching-transition.md`
- `docs/zh/standard/utilities/runtime/settings-ui-scene/ui-stack-routing/ui-stack-modal/modal-protocol.md`
- `docs/zh/standard/utilities/runtime/debug-observability/debug-visual-inspection/debug-overlay.md`
- `docs/zh/standard/utilities/runtime/debug-observability/support-notifications/notifications.md`
- `docs/zh/standard/input-flow/command-sequence/undo-history.md`
- `docs/zh/standard/input-flow/input-assist/input-devices-touch/index.md`
- `docs/zh/extensions/save-graph/serializers-slots.md`
- `docs/zh/extensions/camera/camera-3d.md`
