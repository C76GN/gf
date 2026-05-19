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

## [3.14.0] - 2026-05-19

**版本概述**：收口大型项目中的递归扫描边界，修复自动分发信号所有权与动作队列生命周期释放问题，并降低框架内部对脚本路径的脆弱耦合。

### 🚀 新增特性

- `GFValidationSuite` 新增 `max_scan_depth` 与 `max_collected_paths`，用于限制递归路径扫描的目录深度和单次收集数量；设为 `0` 可关闭对应限制。
- `GFEditorTypeIndex`、`GFExtensionUsageAudit`、`GFSceneSignalAudit`、`GFResourceTableEditor`、`GFAudioBankTools`、`GFStorageUtility`、`GFSignalRuntimeProbe` 与 `GFSupportReportUtility` 新增递归扫描或节点收集上限选项；设为 `0` 可关闭对应限制。

### 🔄 机制更改

- `GFValidationSuite.collect_paths()` 默认限制递归扫描深度与收集数量，避免误把项目根目录、生成目录或极深目录作为 include path 时长时间阻塞编辑器或 CI。
- 编辑器类型扫描、项目引用审计、场景信号审计、资源表扫描、音频 bank 扫描、存储文件递归枚举、运行时信号探针和支持报告场景统计默认限制递归深度与收集数量，避免开发期工具在大型目录或大型节点树上无界遍历。
- `GFExtensionUsageAudit` 的默认忽略目录收窄为 Godot / VCS 隐藏缓存目录，不再把 `addons/gf`、`addons/gut`、`docs`、`tests`、`tools` 或 `ai_analysis` 当作所有项目的默认目录结构；项目需要跳过自有目录时应显式传入 `ignored_roots`。
- `GFTimeUtility` 与发射体移动策略改为直接继承稳定 `class_name` 契约，减少跨层和扩展内部对脚本文件路径的脆弱耦合。

### 🐛 Bug 修复

- 修复 HitBox、Projectile 与 InteractionSensor 在 `sender_path` 业务发送者接管自动发送时，把桥接节点信号也隐式迁移到业务发送者的问题；自动分发现在仍由业务 sender 执行 `send_to()`，但 `hit_sent` / `hit_accepted` / `hit_rejected` 与 `interaction_sent` / `interaction_accepted` / `interaction_rejected` 继续由桥接节点发出。
- 修复 `GFActionQueueSystem` 销毁时只清空命名子队列而不释放子队列依赖作用域的问题；父队列或架构销毁现在会递归取消命名子队列并释放其架构引用。

### 🔌 API 变动说明

- `GFValidationSuite` 新增导出属性 `max_scan_depth`（默认 `32`）和 `max_collected_paths`（默认 `10000`）。
- `GFEditorTypeIndex.collect_scene_roots_extending()` 新增可选 `options` 参数，支持 `max_scan_depth` 与 `max_scanned_scenes`。
- `GFExtensionUsageAudit.find_references_to_root()` / `audit_disabled_extensions()` 的 `options` 新增 `max_scan_depth` 与 `max_scanned_files`。
- `GFSceneSignalAudit.collect_scene_paths()` / `audit_directory()` 的 `options` 新增 `max_scan_depth` 与 `max_scene_paths`；`build_signal_graph()` 的 `options` 新增 `max_node_depth` 与 `max_nodes`，返回报告新增 `truncated`。
- `GFResourceTableEditor.scan_resource_paths()` 新增可选 `options` 参数，支持 `max_scan_depth` 与 `max_resource_paths`。
- `GFAudioBankTools.scan_audio_paths()` 的 `options` 新增 `max_scan_depth` 与 `max_audio_paths`。
- `GFStorageUtility.list_files()` 新增可选 `options` 参数，支持 `max_scan_depth` 与 `max_file_count`。
- `GFSignalRuntimeProbe.watch_tree()` 的 `options` 新增 `max_node_depth` 与 `max_nodes`；触达上限时监听报告会返回 `max_node_depth_reached:*` 或 `max_nodes_reached:*` 错误。
- `GFSupportReportUtility` 新增 `default_scene_count_max_depth` 与 `default_scene_count_max_nodes`；`build_report()` 的 `options.scene_options` 支持 `max_depth` 与 `max_nodes`，场景快照新增 `node_count_truncated`。

### 📘 升级指南

- 如果校验套件确实需要扫描超过 32 层目录或单次收集超过 10000 个资源路径，请在套件资源中显式调高 `max_scan_depth` / `max_collected_paths`，或设为 `0` 关闭对应限制。
- 如果项目工具确实需要全量扫描超大目录或节点树，请在对应入口显式调高上限，或设为 `0` 关闭限制；推荐优先收窄扫描根目录，而不是默认扫描整个项目。
- 如果项目的禁用扩展引用审计不希望检查测试、文档、构建脚本或第三方插件目录，请在自定义调用 `GFExtensionUsageAudit` 时显式设置 `ignored_roots`；框架默认不会再假定这些目录一定是可跳过的维护目录。

### 📁 核心受影响文件

- 动作队列生命周期：`addons/gf/extensions/action_queue/core/gf_action_queue_system.gd`。
- 自动分发信号所有权：`addons/gf/standard/common/gf_message_dispatch_support.gd`、`addons/gf/extensions/combat/hit_detection/gf_hit_box_2d.gd`、`addons/gf/extensions/combat/hit_detection/gf_hit_box_3d.gd`、`addons/gf/extensions/combat/projectiles/gf_projectile_2d.gd`、`addons/gf/extensions/combat/projectiles/gf_projectile_3d.gd`、`addons/gf/extensions/interaction/nodes/gf_interaction_sensor.gd`。
- Foundation 校验套件：`addons/gf/standard/foundation/validation/gf_validation_suite.gd`。
- 递归扫描与诊断工具：`addons/gf/kernel/editor/gf_editor_type_index.gd`、`addons/gf/kernel/extension/gf_extension_usage_audit.gd`、`addons/gf/kernel/editor/gf_scene_signal_audit.gd`、`addons/gf/kernel/editor/gf_resource_table_editor.gd`、`addons/gf/extensions/capability/editor/gf_capability_inspector_plugin.gd`、`addons/gf/standard/utilities/audio/gf_audio_bank_tools.gd`、`addons/gf/standard/utilities/storage/gf_storage_utility.gd`、`addons/gf/standard/utilities/debug/gf_signal_runtime_probe.gd`、`addons/gf/standard/utilities/debug/gf_support_report_utility.gd`。
- 时间协议实现：`addons/gf/standard/utilities/time/gf_time_utility.gd`。
- 测试与文档：`tests/gf_core/extensions/action_queue/test_gf_action_queue.gd`、`tests/gf_core/extensions/combat/test_gf_combat_extension.gd`、`tests/gf_core/extensions/combat/test_gf_projectiles.gd`、`tests/gf_core/extensions/interaction/test_gf_interaction_nodes.gd`、`tests/gf_core/standard/foundation/validation/test_gf_validation_runner_suite.gd`、`tests/gf_core/kernel/editor/test_gf_scene_signal_audit.gd`、`tests/gf_core/kernel/editor/test_gf_resource_table_editor.gd`、`tests/gf_core/kernel/extension/test_gf_extension_manifest.gd`、`tests/gf_core/standard/utilities/audio/test_gf_audio_bank_tools.gd`、`tests/gf_core/standard/utilities/storage/test_gf_storage_utility.gd`、`tests/gf_core/standard/utilities/debug/test_gf_signal_runtime_probe.gd`、`docs/zh/extensions/action-queue/index.md`、`docs/zh/extensions/combat/index.md`、`docs/zh/extensions/interaction-feedback/index.md`、`docs/zh/standard/foundation/data-validation.md`。
