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

## [3.9.0] - 2026-05-15

**版本概述**：本轮聚焦 kernel 层级的时间回退、父级架构关系、扩展 manifest 路径校验、声明式绑定语义、依赖作用域保护和编辑器 JSON 字段提交边界，以及 standard 层级的小型边界修复、通用拖拽抽象、声明式信号桥、输入检测与修饰器增强、UI 异步生命周期加固、Camera/Dialogue 扩展、Interaction/Combat 场景桥接可维护性和冗余代码清理，保持现有公开 API 兼容。

### 🚀 新增特性

- 标准库输入层新增 `GFDragDropUtility`、`GFDragSession` 与 `GFDropZone`，用于通用拖拽会话、落点注册、命中排序和结构化 drop 结果包装。
- 标准库信号工具新增 `GFSignalBridge`、`GFSignalSourceRef`、`GFCallableTargetRef` 与 `GFSignalBridgeBinding`，用于资源化描述原生 Signal 到 Callable 的通用桥接。
- 标准库输入修饰器新增 `GFInputCurveModifier`、`GFInputSwizzleModifier`、`GFInputMagnitudeModifier`、`GFInputSignClampModifier` 与 `GFInputVirtualCursorModifier`，覆盖曲线采样、分量重排、幅值投影、符号方向限制和抽象虚拟光标积分。
- 新增 `gf.camera` 内置扩展，提供 `GFCameraBlend`、`GFCameraRig2D`、`GFCameraRig3D`、`GFCameraDirector2D` 与 `GFCameraDirector3D`，用于通用相机 Rig 优先级选择和 2D/3D 过渡应用。
- 新增 `gf.dialogue` 内置扩展，提供 `GFDialogueResource`、`GFDialogueLine`、`GFDialogueResponse`、`GFDialogueContext` 与 `GFDialogueRunner`，用于通用对话行、响应、条件、mutation 和运行推进。
- 标准库校验基础新增 `GFValidationRule`、`GFValidationSuite`、`GFValidationRunner` 与 `GFValidationJUnitExporter`，用于通用资源/场景/对象校验流水线和 CI 报告导出。
- `GFDiagnosticsUtility` 新增诊断命令参数 schema、命令启停、JSON-safe 命令结果和只读信号图快照命令。
- Steering 基础新增 `GFSteeringBehaviorResource` 与 `GFSteeringBehaviorStack`，用于资源化组合现有纯 steering 算法。
- ActionQueue Tween 配置新增步骤 marker、配置级校验报告和初始值恢复选项。

### 🔄 机制更改

- `GFDecimalStringFormatter.contains_only_digits()` 空字符串现在返回 `false`，符合"仅包含数字"的语义。
- `GFCommandSequence` 失败步骤在 `stop_on_error=false` 时不再发射 `step_completed` 信号，只发射 `step_failed`。
- `GFBlackboardEntry._try_coerce_color()` 使用 `Color.html_is_valid()` 校验颜色字符串，无效格式现在返回转换失败而非静默接受为黑色。
- `GFBlackboardEntry`、`GFBlackboardSchema`、`GFTileMetadataLayer` 中重复的 `_duplicate_variant()` 统一替换为 `GFVariantData.duplicate_variant()`。
- `GFNumberFormatter` 移除只返回常量的内部脚本获取 helper，直接使用已缓存的脚本引用。
- `GFExtensionSettings.resolve_extension_dependencies()`、`get_enabled_manifests()` 和启用扩展路径收集现在保持依赖优先顺序，不再受 manifest 扫描顺序影响。
- `GFBindBuilder.from_instance().as_transient()` 现在直接报错；已有实例只能以单例工厂语义暴露，短生命周期对象应使用 `from_factory()`。
- `GFUIUtility.push_panel_async()` 对同一层级、同一路径的待完成请求做合并，避免连点重复异步压入相同面板。
- `GFReadOnlyBindableProperty` 与 `GFComputedProperty` 现在会拒绝继承自 `GFBindableProperty` 的原地修改 helper，保持只读语义一致。
- `GFInteractionReceiver`、`GFHurtBox2D` 与 `GFHurtBox3D` 新增 `receiver_path` 委托入口，可把碰撞/过滤桥接节点与业务接收节点拆开。
- `GFRequestOutboxUtility.replay()` 同一实例同一时间只允许一轮重放；并发调用会返回 `replay_in_progress` 报告，避免异步 transport 等待期间重复发送同一请求。
- `GFInputDetector` 新增检测阶段状态，并可在正式检测前等待取消输入释放、在检测后等待候选输入释放，减少改键界面中的误触发。
- `GFDiagnosticsUtility.register_command()` 可通过可选 `options` 声明参数 schema 和元数据；命令执行前会做通用参数校验，但不解释业务权限。

### 🐛 Bug 修复

- 修复子级 `GFArchitecture` 在初始化后无法感知父级后续注册或注销 `GFTimeProvider` 的问题，局部上下文现在会按当前父级状态动态解析时间缩放。
- 修复 `GFArchitecture.set_parent_architecture()` 可把父级设为自身或形成循环引用的问题，避免依赖回退和时间提供者查询出现无限递归。
- 修复扩展 manifest 路径校验在包含 `..` 时可能按未规范化文本前缀误判为仍在扩展根目录内的问题。
- 修复启用扩展的依赖 manifest 扫描顺序靠后时，扩展 Installer 可能先于自己的依赖执行的问题。
- 修复 `GFBindBuilder.from_instance().as_transient()` 静默注册为单例工厂的问题，避免调用方误以为每次会创建新实例。
- 修复 `GFModel`、`GFSystem`、`GFUtility`、`GFCommand` 与 `GFQuery` 的内部 `_get_architecture()` 在依赖作用域释放后仍可能回退到全局架构的问题。
- 修复 `GFBindableProperty.unbind()` 在绑定节点已失效时无法清理 `bind_to()` 持有的托管回调，导致失效节点的监听可能继续触发的问题。
- 修复 `GFNodeContext` 在 `INHERITED` 模式下找不到父级或全局架构时只输出 warning、不发出 `context_failed` 的问题。
- 修复 `GFSignalUtility` 在未传 owner 且回调目标已释放时仍保留连接包装器的问题。
- 修复 `GFEditorValueField` 的 Array/Dictionary JSON 输入只检查语法、不检查容器类型的问题，避免表格编辑器把合法 JSON 但错误容器类型的值提交给资源字段。
- 修复 `GFDecimalStringFormatter.contains_only_digits("")` 对空字符串返回 `true` 的语义错误。
- 修复 `GFCommandSequence` 失败步骤在 `stop_on_error=false` 时同时发射 `step_failed` 和 `step_completed` 的语义冲突。
- 修复 `GFBlackboardEntry._try_coerce_color()` 对无效颜色字符串（如 `"not_a_color"`）静默构造黑色 `Color(0,0,0,1)` 的问题。
- 修复 `GFUIUtility.push_panel_async()` 发起后调用 `pop_panel()` 取消/后退时，迟到的异步资源回调仍可能把旧面板重新压入栈的问题。
- 修复 `GFUIRouterUtility.push_route_async()` 连续打开同一路由时，底层异步面板加载可能叠出多个相同路由实例的问题。
- 修复 `GFUIRouterUtility.back()` 在同层路由面板上方存在普通 UI 面板时误弹普通面板并删除路由历史的问题。
- 修复 `GFRequestOutboxUtility.replay()` 在异步 transport 等待期间当前请求被外部移除后，仍按旧索引删除队列而可能误删后续请求的问题。
- 修复 `GFDialogueRunner.advance()` 到达文本行后再次推进时未进入默认后继，导致后继条件失败 fallback 无法触发的问题。
- 修复 `GFNodeStateGroup.remove_state()` 移除当前叠加状态时只清空当前状态、不恢复暂停父状态的问题。
- 修复 `GFNodeStateGroup.pop_state()` 在当前叠加状态和暂停栈状态退出时连续请求重定向，可能重复退出当前状态并进入较早目标状态的问题。
- 修复 `GFCapabilityUtility` 在 receiver 或能力容器 setup 阶段延迟挂载/移除 Node 能力时，父节点同帧释放可能触发延迟 `add_child()` / `remove_child()` 引擎错误的问题。

### 🔌 API 变动说明

- 新增 `GFDragDropUtility`，提供 `register_zone()`、`register_rect_zone()`、`register_control_zone()`、`start_drag()`、`update_drag()`、`drop()`、`cancel_drag()` 和候选落点查询接口。
- 新增 `GFDragSession` 与 `GFDropZone`，分别描述拖拽会话上下文和通用落点规则。
- 新增 `GFSignalBridge.connect_bridge()`、`invoke()`、`build_callable_args()`、`get_validation_report()` 与 `to_dictionary()`；新增 `GFSignalSourceRef`、`GFCallableTargetRef` 和 `GFSignalBridgeBinding` 作为桥接引用与运行句柄。
- 新增 `GFInputDetector.DetectionState`、`wait_for_clear_before_detection`、`wait_for_clear_after_detection` 与 `get_detection_state()`。
- 新增输入修饰器公开类：`GFInputCurveModifier`、`GFInputSwizzleModifier`、`GFInputMagnitudeModifier`、`GFInputSignClampModifier` 与 `GFInputVirtualCursorModifier`。
- 新增 Camera 扩展公开类：`GFCameraBlend`、`GFCameraRig2D`、`GFCameraRig3D`、`GFCameraDirector2D` 与 `GFCameraDirector3D`。
- 新增 Dialogue 扩展公开类：`GFDialogueResource`、`GFDialogueLine`、`GFDialogueResponse`、`GFDialogueContext` 与 `GFDialogueRunner`。
- 新增校验流水线公开类：`GFValidationRule`、`GFValidationSuite`、`GFValidationRunner` 与 `GFValidationJUnitExporter`。
- 新增 Steering 资源化公开类：`GFSteeringBehaviorResource` 与 `GFSteeringBehaviorStack`。
- `GFDiagnosticsUtility.register_command()` 新增可选 `options` 参数；新增 `set_command_parameter_schema()`、`set_command_enabled()`、`set_all_commands_enabled()`、`is_command_enabled()`、`execute_command_json_safe()`、`command_result_to_json_compatible()` 与 `collect_signal_graph_snapshot()`。
- `GFTweenActionStep` 新增 `marker_id` 与 `capture_initial_value()`；`GFTweenActionConfig` 新增 `restore_initial_values_on_cancel`、`restore_initial_values_on_finish`、`capture_initial_values()`、`restore_initial_values()` 与 `get_validation_report()`；`GFConfiguredTweenAction` 新增 `marker_reached` 信号。
- 新增 `GFInteractionReceiver.receiver_path`，接收通过本地过滤后可转发给目标节点的 `receive_interaction(context, interaction_id)`。
- 新增 `GFHurtBox2D.receiver_path` 与 `GFHurtBox3D.receiver_path`，命中通过本地过滤后可转发给目标节点的 `receive_hit(context)`。
- `GFBindableProperty.unbind(node, callable)` 的 `node` 参数类型从 `Node` 放宽为 `Variant`，以便传入已失效的节点引用时仍能触发失效绑定清理；有效节点的调用方式保持不变。

### 📁 核心受影响文件

- 内核容器与绑定：`addons/gf/kernel/core/gf_architecture.gd`、`addons/gf/kernel/core/gf_bind_builder.gd`、`addons/gf/kernel/core/gf_bindable_property.gd`、`addons/gf/kernel/core/gf_computed_property.gd`、`addons/gf/kernel/core/gf_read_only_bindable_property.gd`、`addons/gf/kernel/core/gf_node_context.gd`。
- 内核依赖作用域：`addons/gf/kernel/base/gf_dependency_scope_support.gd`、`addons/gf/kernel/base/gf_model.gd`、`addons/gf/kernel/base/gf_system.gd`、`addons/gf/kernel/base/gf_utility.gd`、`addons/gf/kernel/base/gf_command.gd`、`addons/gf/kernel/base/gf_query.gd`。
- 内核编辑器控件：`addons/gf/kernel/editor/gf_editor_value_field.gd`。
- 扩展 manifest 与启用设置：`addons/gf/kernel/extension/gf_extension_manifest.gd`、`addons/gf/kernel/extension/gf_extension_settings.gd`。
- 标准库基础：`addons/gf/standard/foundation/blackboard/gf_blackboard_entry.gd`、`addons/gf/standard/foundation/blackboard/gf_blackboard_schema.gd`、`addons/gf/standard/foundation/math/gf_tile_metadata_layer.gd`。
- 标准库格式化：`addons/gf/standard/foundation/formatting/gf_number_formatter.gd`、`addons/gf/standard/foundation/formatting/gf_decimal_string_formatter.gd`。
- 标准库序列：`addons/gf/standard/sequence/gf_command_sequence.gd`。
- 标准库输入：`addons/gf/standard/input/drag_drop/**`、`addons/gf/standard/input/modifiers/**`、`addons/gf/standard/input/rebinding/gf_input_detector.gd`。
- 标准库信号与 UI：`addons/gf/standard/utilities/signals/gf_signal_connection.gd`、`addons/gf/standard/utilities/signals/bridge/**`、`addons/gf/standard/utilities/ui/gf_ui_utility.gd`、`addons/gf/standard/utilities/ui/gf_ui_router_utility.gd`。
- 标准库校验、诊断和 Steering：`addons/gf/standard/foundation/validation/**`、`addons/gf/standard/utilities/debug/gf_diagnostics_utility.gd`、`addons/gf/standard/foundation/math/gf_steering_behavior_resource.gd`、`addons/gf/standard/foundation/math/gf_steering_behavior_stack.gd`。
- 标准库请求 Outbox 与节点状态机：`addons/gf/standard/utilities/io/gf_request_outbox_utility.gd`、`addons/gf/standard/state_machine/node/gf_node_state_group.gd`。
- 相机扩展：`addons/gf/extensions/camera/**`。
- 对话扩展：`addons/gf/extensions/dialogue/**`。
- ActionQueue Tween：`addons/gf/extensions/action_queue/tween/**`、`addons/gf/extensions/action_queue/actions/gf_configured_tween_action.gd`。
- 扩展桥接：`addons/gf/extensions/interaction/nodes/gf_interaction_receiver.gd`、`addons/gf/extensions/combat/hit_detection/gf_hurt_box_2d.gd`、`addons/gf/extensions/combat/hit_detection/gf_hurt_box_3d.gd`、`addons/gf/standard/common/gf_message_receiver_support.gd`。
