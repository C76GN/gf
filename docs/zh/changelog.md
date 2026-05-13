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

## [3.3.0] - 2026-05-13

**版本概述**：把若干开发期与运行时体验优化收敛为 GF 自身的通用抽象入口，重点增强 UI modal、文本自适应、调试观察、编辑器命令工具协议、HTTP 请求构建、日志分批、配置表导入导出、图布局、流程图运行态、反馈轨道、渲染预热和任务层级能力。

### 🚀 新增特性

- 新增 `GFTextAutoFit`，并扩展 `GFTextFitter.fit_control()` / `measure_control_text()`，支持常见文本控件、内容边距、按钮图标和 LineEdit placeholder。
- 新增 `GFModalConfig`、`GFModalAction`、`GFModalResult` 和默认 `GFModalPanel`，`GFUIUtility.open_modal()` 可用统一协议打开 modal 并回收结果。
- 新增 `GFSignalGraphDock` 标准库信号图页面，复用 `GFSceneSignalAudit` 查看当前编辑场景信号连接。
- 新增 `GFSignalRuntimeProbe`，可显式监听节点或节点树的运行时信号发射，并记录最近事件。
- `GFSignalGraphDock` 新增筛选、运行事件页和显式实时追踪开关。
- 新增 `GFEditorCommand`、`GFEditorActionDefinition`、`GFEditorTool` 和 `GFEditorToolContext`，为编辑器工具提供命令、动作和持续交互协议。
- 新增 `GFHttpRequestBuilder`、`GFHttpResponse` 和 `GFAsyncBatch`，提供通用 HTTP 请求构建、响应状态对象和异步结果聚合。
- 新增 `GFBudgetLedger`，用于抽象资源预算、消费、释放和快照。
- 新增 `GFValueIndex` 与 `GFMutationBatch`，提供 Foundation 级值索引和可提交/可回滚变更批次。
- 新增 `GFGraphLayoutUtility`，提供分层与网格图布局建议；`GFFlowGraphEditorModel` 新增 `auto_layout()`。
- `GFFlowGraph` 新增运行态序列化、元数据 Schema 校验和运行副本创建；`GFFlowContext` 新增通用条件查询处理器。
- `GFFlowGraphEditorModel` 新增选择包、粘贴和批量删除入口。
- `GFShakePreset` 新增可组合 `GFShakeTrack` 轨道。
- `GFRenderWarmupUtility` 新增场景资源扫描、时间预算和离屏临时渲染节点触碰模式。
- `GFSupportReportUtility` 新增附件规范化、截图附件和提交结果归一化。
- `GFDebugOverlayUtility` 新增通用 panel 注册表，并可附加最近日志面板。
- `GFConsoleUtility` 新增只读 `scene.tree` 与 `scene.node` 内置命令。
- 新增 `GFBatchedLogSink`，用于把结构化日志清洗、缓冲并分批交给项目自定义传输。
- `GFConfigTableImporter` 新增 `export_csv_table()`，`GFConfigTableSchema` 新增 `infer_from_records()`。
- 新增 `GFConfigTableIndexDefinition`、`GFConfigTableReference` 和 `GFConfigReferenceResolver`，支持导表复合唯一索引、跨表引用校验和引用解析。
- 新增 `GFEditorToolOption`、`GFEditorToolOptionSchema` 和 `GFEditorPickOperation`，为编辑器工具提供声明式选项、值规范化和分阶段拾取协议。
- 新增 `GFEditorWorkspaceDock` 底部统一入口，把 GF Save Viewer、GF Extensions、GF Signal Graph 和扩展贡献的 Dock 收束为一个 `GF` 工作区。
- `GFBehaviorTree` 新增 FRESH / ABORTED 状态文本、黑板作用域、运行器调试快照，以及 `Probability`、`Cooldown`、`TimeLimit` 通用装饰节点。
- `GFSlotInventoryModel` 新增惰性物品槽位索引、索引快照、库存约束校验和注册表约束应用入口；`GFInventoryItemDefinition` 新增运行时兼容性回调。
- 新增 `GFAudioBackendCapability`、`GFAudioEvent`、`GFAudioParameter`、`GFAudioState`、`GFAudioSwitch` 和 `GFAudioCatalogProvider`，并扩展音频后端资源化事件、参数、状态和开关协议。
- 新增 `GFTimedTextEntry`、`GFTimedTextTrack` 和 `GFTimedTextImporter`，提供通用时间段文本轨道与 SRT/WebVTT/LRC 轻量解析。
- 新增 `GFRegionMap2D`，提供二维区域分块数据映射和脏区域追踪。
- `GFQuestUtility` 新增接取条件、失败状态、父子任务关系和树形聚合报告。

### 🔄 机制更改

- 新增能力保持 additive API，不改变现有任务、UI 栈、日志、配置表和控制台的默认行为。
- `GFSignalGraphDock` 默认查看持久连接并过滤根节点外目标，避免编辑器内部运行时连接污染场景图；运行时追踪默认关闭，只有显式开启后才连接当前场景信号。
- modal、日志分批、Overlay panel、配置表推导、任务树、流程状态、反馈轨道、支持报告附件和渲染预热都只保留通用协议，不内置具体业务、远端服务或项目适配。
- 编辑器命令、HTTP 请求、预算账本、值索引、变更批次和图布局都保持 additive API，不写入具体服务端、玩法或外部工具适配。
- 配置引用、编辑器拾取、行为树调试、库存索引、音频事件、时间段文本和区域分块能力都只保留通用协议，不内置第三方工具、玩法规则、地图渲染或媒体业务。
- 编辑器底部入口默认统一注册为一个 `GF` 工作区，标准库和扩展贡献的编辑器页作为内部页面呈现；工作区页面入口会按宽度自动平铺，根面板只保留顶部入口区的折叠最小高度，页面承载层不设置固定最小高度并裁剪溢出内容，同时提供框架介绍、项目地址、正式文档地址和维护者联系方式弹窗，减少底部栏标签拥挤。
- 本版本所有官方扩展的 `version` 同步为 `3.3.0`；Behavior Tree、Domain、Feedback 和 Flow 扩展因新增公开行为，将 `extension_version` 递增为 `1.1.0`，其余未发生扩展内公开行为变化的官方扩展保持原有 `extension_version`。

### 🔌 API 变动说明

- 新增公开类：`GFTextAutoFit`、`GFModalConfig`、`GFModalAction`、`GFModalResult`、`GFModalPanel`、`GFSignalGraphDock`、`GFSignalRuntimeProbe`、`GFBatchedLogSink`。
- 新增公开类：`GFEditorCommand`、`GFEditorActionDefinition`、`GFEditorTool`、`GFEditorToolContext`、`GFHttpRequestBuilder`、`GFHttpResponse`、`GFAsyncBatch`、`GFBudgetLedger`、`GFValueIndex`、`GFMutationBatch`、`GFGraphLayoutUtility`。
- 新增公开类：`GFShakeTrack`。
- `GFSceneSignalAudit.build_signal_graph()` 新增 `include_external_targets` 选项。
- `GFFlowContext` 新增 `register_condition_handler()`、`unregister_condition_handler()`、`has_condition_handler()`、`clear_condition_handlers()` 和 `query_condition()`。
- `GFFlowNode` 新增 `runtime_state`、`set_runtime_value()`、`get_runtime_value()`、`clear_runtime_state()`、`serialize_runtime_state()` 和 `deserialize_runtime_state()`。
- `GFFlowGraph` 新增 `metadata_schema`、`instantiate_graph()`、`serialize_runtime_state()`、`deserialize_runtime_state()`、`clear_runtime_state()`、`validate_metadata()` 和 `validate_graph_metadata()`。
- `GFFlowGraphEditorModel` 新增 `auto_layout()`、`build_selection_package()`、`paste_selection_package()` 和 `remove_nodes()`。
- `GFShakePreset` 新增 `tracks`、`add_track()`、`clear_tracks()` 和 `has_tracks()`。
- `GFRenderWarmupUtility` 新增 `TouchMode`、`default_max_seconds`、`default_touch_mode`、`build_manifest_from_scene()`、`build_manifest_from_scene_path()` 和 `release_temporary_render_nodes()`。
- `GFSupportReportUtility` 新增 `default_max_attachment_bytes`、`include_screenshot_by_default`、`collect_attachments()` 和 `add_attachment_to_report()`。
- `GFUIUtility` 新增 `open_modal()`。
- `GFDebugOverlayUtility` 新增 `register_panel()`、`push_panel_text()`、`remove_panel()`、`clear_panels()`、`has_panel()` 和 `get_panel_snapshot()`。
- `GFConfigTableImporter` 新增 `export_csv_table()`；`GFConfigTableSchema` 新增 `infer_from_records()`。
- 新增公开类：`GFConfigTableIndexDefinition`、`GFConfigTableReference`、`GFConfigReferenceResolver`、`GFEditorToolOption`、`GFEditorToolOptionSchema`、`GFEditorPickOperation`。
- 新增公开类：`GFAudioBackendCapability`、`GFAudioEvent`、`GFAudioParameter`、`GFAudioState`、`GFAudioSwitch`、`GFAudioCatalogProvider`、`GFTimedTextEntry`、`GFTimedTextTrack`、`GFTimedTextImporter`、`GFRegionMap2D`。
- `GFConfigTableSchema` 新增 `indexes`、`references`、`get_index()`、`has_index()`、`get_reference()` 和 `has_reference()`。
- `GFEditorTool` 新增 `option_schema`、`set_option_schema()`、`set_tool_option()`、`get_tool_option()`、`get_tool_options()`、`clear_tool_options()`、`begin_pick_operation()`、`pick()`、`apply_pick_operation()`、`cancel_pick_operation()` 和 `get_pick_operation()`。
- `GFBehaviorTree` 新增 `Status.FRESH`、`Status.ABORTED`、`status_to_string()`、`build_debug_snapshot()`、`BlackboardScope`、`Probability`、`Cooldown`、`TimeLimit` 和 `Runner.get_debug_snapshot()`。
- `GFSlotInventoryModel` 新增 `get_slots_for_item()`、`rebuild_index()`、`get_index_debug_snapshot()`、`validate_inventory()` 和 `apply_registry_constraints()`；`GFInventoryItemDefinition` 新增 `compatibility_checker`。
- `GFAudioBackend` 新增 `capabilities`、`get_capabilities()`、`has_capability()`、`can_handle_event()`、`post_event()`、`set_parameter()`、`set_state()` 和 `set_switch()`；`GFAudioUtility` 新增 `post_audio_event()`、`set_audio_parameter()`、`set_audio_state()` 和 `set_audio_switch()`；`GFAudioBank` 新增加载状态字段和状态快照。
- `GFQuestUtility` 新增 `STATUS_FAILED`、`quest_acceptance_blocked`、`quest_failed`、`fail_quest()`、`add_acceptance_condition()`、`clear_acceptance_conditions()`、`set_quest_parent()`、`clear_quest_parent()`、`get_child_quests()` 和 `get_quest_tree_report()`。

### 📁 核心受影响文件

- `addons/gf/standard/utilities/ui/**`
- `addons/gf/standard/utilities/debug/**`
- `addons/gf/kernel/editor/**`
- `addons/gf/standard/foundation/**`
- `addons/gf/standard/utilities/io/**`
- `addons/gf/standard/utilities/display/gf_render_warmup_utility.gd`
- `addons/gf/extensions/official/flow/**`
- `addons/gf/extensions/official/feedback/resources/**`
- `addons/gf/standard/utilities/logging/**`
- `addons/gf/standard/utilities/config/**`
- `addons/gf/standard/utilities/audio/**`
- `addons/gf/standard/foundation/timeline/**`
- `addons/gf/standard/foundation/math/gf_region_map_2d.gd`
- `addons/gf/extensions/official/behavior_tree/runtime/gf_behavior_tree.gd`
- `addons/gf/extensions/official/domain/inventory/**`
- `addons/gf/extensions/official/domain/quest/gf_quest_utility.gd`
- `tests/gf_core/standard/utilities/**`
- `tests/gf_core/extensions/official/domain/test_gf_quest_utility.gd`
