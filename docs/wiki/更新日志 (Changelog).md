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

本页面只保留最近三个大版本线的更新记录，当前保留 `1.23.x`、`1.22.x` 与 `1.21.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [1.23.1] - 2026-05-06

**版本概述**：收敛 GF 1.23.0 引入的大型扩展能力中的可靠性边界，重点修复存储写入校验、异步存档调度、存档图重复 key、空间节点能力基类、场景 UID 校验、Signal 去重语义、事件优先级、输入 just-started 生命周期、网络收包预算和运行时状态机 reload 行为。

### 🚀 新增特性 (Added)
- **异步存档并发预算**：`GFStorageUtility` 新增 `max_async_thread_count`，异步保存/读取会进入内部队列，并按同文件串行、不同文件受预算限制的策略启动线程。
- **空间节点能力基类**：新增 `GFNode2DCapability`、`GFNode3DCapability` 与 `GFControlCapability`，分别继承 `Node2D`、`Node3D` 与 `Control`，便于通用能力保留空间变换或 UI 布局语义。
- **响应式补跑上限**：`GFReactiveEffect` 新增 `max_reruns_per_run`，当 effect 回调运行中再次修改来源属性时会补跑，并用上限避免自激循环。
- **节点状态机 reload 状态保持**：`GFNodeStateMachine` 新增 `preserve_current_state_on_reload`，运行时从子节点重新加载状态时会尽量恢复原当前状态。
- **ENet 收包预算**：`GFENetNetworkBackend` 新增 `max_packets_per_poll`，默认每帧最多派发 64 个入站包，避免异常流量占满单帧。
- **架构生命周期扫描上限**：`GFArchitecture` 新增 `module_lifecycle_max_stage_passes`，避免模块在生命周期回调中无限注册新模块导致初始化阶段无法结束。

### 🔄 机制更改 (Changed)
- **存储路径收敛**：`GFStorageUtility` 会规范化相对路径，并拒绝 `../` 形式的跨目录路径；禁用绝对路径时仍回落到存档目录内同名文件。
- **Signal 连接去重更精确**：`GFSignalUtility` 去重现在同时匹配 once 语义、owner、默认参数和连接标记；`connect_once()` 不再把已有常驻连接意外改成一次性连接。
- **类型事件优先级全局排序**：`TypeEventSystem` 会把精确监听和可赋值监听合并后按 priority 排序；同优先级仍保持注册顺序。
- **输入 just-started 生命周期延后**：`GFInputMappingUtility` 不再在 Utility tick 开头清理 just-started，而是保留到当前帧结束，便于 Controller `_process` 稳定消费。
- **节点能力共享实现收敛**：`GFNodeCapability` 与空间节点能力基类共用内部 support 脚本处理架构注入和能力查询，减少不同原生父类基类之间的重复实现。
- **严格依赖模式覆盖工厂回退**：`GFArchitecture.strict_dependency_lookup` 现在也会阻止工厂查找回退到父架构。
- **入站网络通道校验**：`GFNetworkUtility` 在解码入站消息后，会按 `message_type` 或 payload 中的 `channel_id` 匹配注册通道，并应用通道级包体大小限制。
- **场景完成信号时机收敛**：`GFSceneUtility.scene_load_completed` 只在目标场景切换成功后发出；切换失败只发出 `scene_load_failed`。
- **节点能力编辑器识别范围**：Capability Inspector、GF 模板菜单与强类型访问器生成器会识别 `GFNode2DCapability`、`GFNode3DCapability` 与 `GFControlCapability` 子类。

### 🐛 Bug 修复 (Fixed)
- **存储写入静默成功**：修复 `GFStorageUtility` 写入 buffer/string 后未检查 `FileAccess.get_error()`，导致磁盘满或写入失败时仍返回 `OK` 的问题。
- **异步保存旧结果覆盖新结果**：修复同一文件多次异步保存可能并发提交、旧结果覆盖新结果的问题。
- **存档图重复 Source key 无法回放**：`GFSaveGraphUtility.gather_scope()` 遇到同一 Scope 内重复 Source/子 Scope key 时会失败并报错，不再生成 `key#2` 这类无法匹配应用端 source 的载荷。
- **空存档载荷误报成功**：`GFSaveGraphUtility.apply_scope()` 对空 payload 返回失败，避免坏档被当作成功应用。
- **槽位逻辑 ID 索引错误**：`GFSaveSlotWorkflow` 可从默认 `slot_{index}` 形式和尾部数字的逻辑 `slot_id` 中反推索引，不再把 `"slot_1"` 强转为 `0`。
- **UID 场景路径被误拒绝**：`GFSceneUtility` 对普通路径使用 `PackedScene` 识别扩展名校验，对 `uid://` 路径同步加载确认类型，既支持无扩展名场景 UID，也避免 `icon.svg` 这类非场景资源误入加载流程。
- **事件 owner ID 误判为空**：`TypeEventSystem` 只将 `0` 视为无 owner，兼容 Godot 4.6 下可能为负数的 `Object.get_instance_id()`，避免同 Callable 不同 owner 被误去重或派发期 owner 注销失效。
- **能力 Inspector 控件生命周期**：`GFCapabilityInspectorPlugin` 会先构建完整自定义 Inspector UI，再交给 Godot Inspector 管理，避免选中已挂载能力的宿主时偶发 `previously freed instance` 编辑器报错。
- **Asset 缓存 null 条目**：`GFAssetUtility.put_cache()` 会拒绝空路径或 null Resource，并补强脚本 `class_name` / 脚本路径形式的类型提示兼容。
- **Flow 等待 Node 退出树悬挂**：`GFFlowRunner` 等待 Node 信号时会监听 `tree_exited`，避免节点离树后流程长期等待。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFStorageUtility.max_async_thread_count: int`。
- 新增 `GFNode2DCapability`。
- 新增 `GFNode3DCapability`。
- 新增 `GFControlCapability`。
- 新增 `GFReactiveEffect.max_reruns_per_run: int`。
- 新增 `GFNodeStateMachine.preserve_current_state_on_reload: bool`。
- 新增 `GFENetNetworkBackend.max_packets_per_poll: int`。
- 新增 `GFArchitecture.module_lifecycle_max_stage_passes: int`。
- 无破坏性函数签名变更；但 `strict_dependency_lookup` 对工厂父级回退的语义更严格，开启该模式的项目应显式在局部架构注册需要的工厂。

### 📘 升级指南 (Migration Guide)
1. 如果项目使用 `GFStorageUtility.save_data_async()` 高频自动保存，建议按磁盘 IO 压力调整 `max_async_thread_count`；同一文件现在会按调用顺序串行提交。
2. 如果项目依赖 `connect_once()` 复用已有连接并把它改为一次性连接，需要改为显式保存返回的 `GFSignalConnection` 并调用 `once()`。
3. 如果项目开启了 `strict_dependency_lookup` 且仍希望从父架构创建工厂实例，需要在局部架构显式注册对应工厂，或关闭严格模式。
4. 如果项目在类型事件中同时注册 exact 与 assignable listener，请按全局 priority 重新确认事件消费顺序。
5. 如果项目有运行时动态增删 `GFNodeStateMachine` 子状态，默认会尽量保持当前状态；需要旧的重载即重启行为时可关闭 `preserve_current_state_on_reload`。
6. 如果项目已有 2D、3D 或 UI Node 能力，建议把需要空间变换或 UI 布局继承的能力基类切换为 `GFNode2DCapability`、`GFNode3DCapability` 或 `GFControlCapability`；不依赖空间分支的能力继续使用 `GFNodeCapability`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_reactive_effect.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/plugin.gd`
- `addons/gf/base/gf_model.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/editor/gf_access_generator.gd`
- `addons/gf/editor/gf_capability_inspector_plugin.gd`
- `addons/gf/extensions/flow/gf_flow_runner.gd`
- `addons/gf/extensions/network/gf_enet_network_backend.gd`
- `addons/gf/extensions/network/gf_network_utility.gd`
- `addons/gf/extensions/capability/gf_node_capability.gd`
- `addons/gf/extensions/capability/gf_node_capability_support.gd`
- `addons/gf/extensions/capability/gf_node_2d_capability.gd`
- `addons/gf/extensions/capability/gf_node_3d_capability.gd`
- `addons/gf/extensions/capability/gf_control_capability.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/extensions/save/gf_save_slot_workflow.gd`
- `addons/gf/extensions/state_machine/gf_node_state_group.gd`
- `addons/gf/extensions/state_machine/gf_node_state_machine.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_input_mapping_utility.gd`
- `addons/gf/utilities/gf_quad_tree_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_signal_connection.gd`
- `addons/gf/utilities/gf_signal_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_ui_utility.gd`
- `docs/wiki/12. 能力组件 (Capabilities).md`
- `docs/wiki/更新日志 (Changelog).md`
- `tests/gf_core/test_gf_access_generator.gd`
- `tests/gf_core/test_bindable_property.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_input_mapping_utility.gd`
- `tests/gf_core/test_gf_network_extension.gd`
- `tests/gf_core/test_gf_save_graph_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_signal_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `tests/gf_core/test_type_event_system.gd`

## [1.23.0] - 2026-05-06

**版本概述**：围绕 GF 的横向框架能力继续补强，新增响应式组合、瓦片/网格、3D 表面材质、场景预加载与配置化切换、存档槽位工作流、存档流程 trace、输入展示 provider、调试绘制命令缓冲、配置化 Tween 动作、能力诊断和流程失败治理。新增内容保持抽象、可选接入，不把自动铺砖、脚步声、关卡、战斗或 UI 等业务语义写入框架层。

### 🚀 新增特性 (Added)
- **响应式组合辅助**：新增 `GFReactiveEffect`，可监听多个 `BindableProperty` 并在任一来源变化时执行回调，支持绑定 `Node` 生命周期。
- **只读派生属性**：新增 `GFComputedProperty`，可由多个 `BindableProperty` 派生只读值，用于局部 UI/Controller 数据组合。
- **瓦片数据快照**：新增 `GFTileMapCache`，提供通用格子字典数据缓存、`TileMapLayer` 采集、差分比较和 `to_dict()` / `from_dict()`。
- **瓦片邻域规则表**：新增 `GFTileRuleSet`，用邻域值序列解析结果，支持 fallback 邻域值、默认结果、权重结果和确定性选择。
- **3D 表面材质查询**：新增 `GFSurfaceUtility`，可根据 RayCast/碰撞命中的 face index 推导 `MeshInstance3D` surface、基础材质、override 材质和 active material。
- **场景资源预加载缓存**：`GFSceneUtility` 新增场景预加载信号、LRU PackedScene 缓存、取消预加载、缓存状态查询和调试快照。
- **资源化场景切换配置**：新增 `GFSceneTransitionConfig`，并为 `GFSceneUtility` 增加 `load_scene_with_transition()`，可用资源描述目标场景、loading scene、预加载和缓存策略。
- **通用存档槽位工作流**：新增 `GFSaveSlotMetadata`、`GFSaveSlotCard` 与 `GFSaveSlotWorkflow`，用于构建槽位元数据、读档卡片 DTO 和槽位索引/逻辑标识映射。
- **存档流程上下文与事件**：新增 `GFSavePipelineContext` 与 `GFSavePipelineEvent`，`GFSaveGraphUtility` 可按需输出采集/应用流程 trace，也允许调用方传入上下文收集事件。
- **输入展示 provider**：新增 `GFInputTextProvider` 与 `GFInputIconProvider`，允许项目为平台、设备、本地化或图标字体扩展输入展示。
- **调试绘制命令缓冲**：新增 `GFDebugDrawUtility`，提供 2D/3D 线段、矩形、圆、文本和自定义命令的通用缓冲、频道过滤和生命周期管理。
- **配置化 Tween 动作**：新增 `GFTweenActionStep`、`GFTweenActionConfig` 与 `GFConfiguredTweenAction`，可把表现属性动画资源化后交给 `GFActionQueueSystem` 编排。
- **能力诊断报告**：`GFCapabilityUtility` 新增 `inspect_receiver()` 与 `validate_receiver_dependencies()`，便于调试能力、依赖和分组状态。
- **命令序列失败治理**：`GFCommandSequence` 新增失败信号、失败策略、运行报告和可选逆序回滚。
- **架构初始化超时保护**：`GFArchitecture` 新增 `module_async_init_timeout_seconds`、`initialization_failed`、`last_initialization_error` 与 `has_initialization_failed()`，可在开发期或高风险模块初始化中避免 `async_init()` 永久挂起。
- **严格依赖查询模式**：`GFArchitecture` 新增 `strict_dependency_lookup` 与 `get_local_model()` / `get_local_system()` / `get_local_utility()`；`GFNodeContext` 新增同名严格查询开关和本地查询代理，便于分屏、战斗房间等局部上下文暴露漏注册依赖。
- **存档异步纯数据管线**：`GFStorageUtility` 新增 `save_data_async()`、`load_data_async()`、`save_completed` 与 `load_completed`，把字典编码、解码和文件 IO 移到线程执行，完成通知回到主线程。
- **时间缩放保护**：`GFTimeUtility` 新增 `max_scaled_delta`、`physics_substep_max_delta`、`max_physics_substeps`、`get_physics_scaled_delta_steps()` 与 `should_substep_physics()`，可限制高倍速或掉帧后的单步 delta。
- **资源缓存锁定**：`GFAssetUtility` 新增 `pin_cache()`、`unpin_cache()` 与 `is_cache_pinned()`，可让关键预加载资源暂时跳过 LRU 淘汰。
- **对象池时间预算预热**：`GFObjectPoolUtility` 新增 `prewarm_async_budget()`，按单帧毫秒预算分批实例化复杂场景。
- **表现动作条件跳过**：`GFVisualAction` 新增 `is_valid()` 与 `can_execute()`，`GFActionQueueSystem` 和 `GFVisualActionGroup` 会在执行前跳过无效动作。
- **API 注释校验测试**：新增 `test_api_docs_validation.gd`，自动校验公开 API 带参数函数必须提供 `## @param`，并与函数签名在名称、数量和顺序上双向一致。

### 🔄 机制更改 (Changed)
- **日志内存缓存改为环形缓冲**：`GFLogUtility` 的内存日志保留最新条目，避免长时间运行时数组无限增长；`get_recent_entries()` 支持在环形缓存上稳定分页读取。
- **场景切换可复用预加载资源**：`GFSceneUtility.load_scene_async()` 会优先使用已预加载的 `PackedScene`，也可按 `cache_loaded_scenes` 将正常加载完成的场景写入缓存。
- **场景切换缓存策略可按次覆盖**：`GFSceneUtility.load_scene_with_transition()` 会把 `GFSceneTransitionConfig.cache_loaded_scene` 捕获到当前加载任务，不污染全局默认缓存策略。
- **存档图流程自动记录通用事件**：`GFSaveGraphUtility.gather_scope()` / `apply_scope()` 会在 context 中维护可选 `GFSavePipelineContext`，记录 Scope、Source 和 PipelineStep 的通用阶段事件。
- **输入格式化改为 provider 优先**：`GFInputFormatter` 保持原有文本 API，同时优先尝试已注册 provider，并新增 RichText 与 Texture2D 图标查询入口。
- **命令序列失败结果协议收敛**：`GFCommandSequence` 会识别 `{"ok": false}`、`{"success": false}`、`{"status": "error"}` / `failed` / `failure` 这类失败字典，并把失败步骤写入 `last_run_report.results`。
- **瓦片规则内部结构更稳健**：`GFTileRuleSet` 的 trie 节点使用 `branches` / `results` 分区，允许邻域值本身为 `"results"` 等普通字符串。
- **物理帧可选子步进驱动**：当注册的 `GFTimeUtility.physics_substep_max_delta > 0` 且缩放后物理 delta 超过阈值时，`GFArchitecture.physics_tick()` 会把该帧拆成多个缩放子步驱动模块；默认关闭，旧项目行为不变。
- **定点数大位移除法减少分配**：`GFFixedDecimal` 的字符串除法、减法和按位乘法改为数组收集后一次 join，降低极端精度路径中的字符串拼接压力。
- **轻量事件派发热路径优化**：`TypeEventSystem.send_simple()` 在 pending 列表为空时跳过每监听器数组扫描，降低高频简单事件的固定开销。
- **API 注释校验收紧**：`test_api_docs_validation.gd` 支持多行签名和带逗号默认值解析；公开函数名不以 `_` 开头且带参数时强制要求 `@param`，私有函数与 Godot 生命周期函数继续豁免。

### 🐛 Bug 修复 (Fixed)
- **命令序列失败步骤统计修正**：当 `stop_on_error = false` 时，失败步骤不再被计入成功步骤和回滚候选，但仍会发出 `step_completed` 以保持旧的继续执行语义。
- **命令序列空错误兜底**：失败字典未提供 `error` / `message` / `reason` 时，运行报告使用稳定默认错误 `"Step failed."`。
- **响应式测试生命周期修正**：`GFReactiveEffect` 测试显式持有 effect 引用，并避免局部变量遮蔽 `Node.owner`。
- **3D 表面工具测试清理**：`GFSurfaceUtility` 测试创建的 `MeshInstance3D` 交由 GUT 自动释放，不再产生 orphan 报告。
- **API 注释参数名修正**：修正 `Gf.set_architecture()` 文档中的 `@param` 名称，避免注释与签名不一致。
- **公开 API @param 注释补齐**：补齐公开 API 参数说明，并修正抽象基类、能力查询、Buff、命令历史和配置 provider 中 `@param` 与函数签名不一致的问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFReactiveEffect`。
- 新增 `GFComputedProperty`。
- 新增 `GFTileMapCache`。
- 新增 `GFTileRuleSet`。
- 新增 `GFSurfaceUtility`。
- 新增 `GFSceneTransitionConfig`。
- 新增 `GFSavePipelineContext`。
- 新增 `GFSavePipelineEvent`。
- 新增 `GFSaveSlotMetadata`。
- 新增 `GFSaveSlotCard`。
- 新增 `GFSaveSlotWorkflow`。
- 新增 `GFInputTextProvider`。
- 新增 `GFInputIconProvider`。
- 新增 `GFDebugDrawUtility`。
- 新增 `GFTweenActionStep`。
- 新增 `GFTweenActionConfig`。
- 新增 `GFConfiguredTweenAction`。
- `GFSceneUtility` 新增 `scene_preload_started`、`scene_preload_progress`、`scene_preload_completed`、`scene_preload_failed` 与 `scene_preload_cancelled` 信号。
- `GFSceneUtility` 新增 `SceneResourceState` 枚举。
- `GFSceneUtility` 新增 `max_preloaded_scene_resources` 与 `cache_loaded_scenes`。
- `GFSceneUtility` 新增 `preload_scene()`、`preload_scenes()`、`cancel_scene_preload()`、`cancel_all_scene_preloads()`、`is_scene_preloading()`、`is_scene_preloaded()`、`get_preloaded_scene()`、`put_preloaded_scene()`、`remove_preloaded_scene()`、`clear_preloaded_scenes()`、`get_preloading_scene_paths()`、`get_scene_cache_debug_snapshot()` 与 `get_scene_resource_state()`。
- `GFSceneUtility` 新增 `load_scene_with_transition(config: GFSceneTransitionConfig) -> Error`。
- `GFSaveGraphUtility` 新增 `create_pipeline_context(operation: StringName, scope: GFSaveScope = null, shared: Dictionary = {}) -> GFSavePipelineContext`。
- `GFSaveGraphUtility.gather_scope()` 支持通过 context 传入 `pipeline_context` 或 `include_pipeline_trace`。
- `GFSaveGraphUtility.apply_scope()` 支持通过 context 传入 `pipeline_context` 或 `include_pipeline_trace`。
- `GFInputFormatter.input_event_as_text()`、`binding_as_text()` 与 `mapping_as_text()` 新增可选 `options: Dictionary = {}` 参数，旧调用保持兼容。
- `GFInputFormatter` 新增 `input_event_as_rich_text()`、`input_event_icon()`、`binding_as_rich_text()`、`mapping_as_rich_text()`、`add_text_provider()`、`remove_text_provider()`、`clear_text_providers()`、`get_text_providers()`、`add_icon_provider()`、`remove_icon_provider()`、`clear_icon_providers()` 与 `get_icon_providers()`。
- `GFCapabilityUtility` 新增 `inspect_receiver()` 与 `validate_receiver_dependencies()`。
- `GFCommandSequence` 新增 `step_failed` 与 `sequence_failed` 信号。
- `GFCommandSequence` 新增 `stop_on_error`、`rollback_on_failure` 与 `last_run_report`。
- `GFCommandSequence` 新增 `with_failure_policy(should_stop_on_error: bool = true, should_rollback_on_failure: bool = false) -> GFCommandSequence`。
- `GFArchitecture` 新增 `initialization_failed(reason: String)` 信号。
- `GFArchitecture` 新增 `module_async_init_timeout_seconds`、`strict_dependency_lookup` 与 `last_initialization_error`。
- `GFArchitecture` 新增 `has_initialization_failed()`、`get_local_model()`、`get_local_system()` 与 `get_local_utility()`。
- `Gf` 新增 `get_local_model()`、`get_local_system()` 与 `get_local_utility()`。
- `GFNodeContext` 新增 `strict_dependency_lookup`、`module_async_init_timeout_seconds`、`get_local_model()`、`get_local_system()` 与 `get_local_utility()`。
- `GFController` 新增 `get_local_model()`、`get_local_system()` 与 `get_local_utility()`。
- `GFStorageUtility` 新增 `save_completed(file_name: String, error: Error)` 与 `load_completed(file_name: String, result: Dictionary)` 信号。
- `GFStorageUtility` 新增 `save_data_async(file_name: String, data: Dictionary) -> Error` 与 `load_data_async(file_name: String) -> Error`。
- `GFTimeUtility` 新增 `max_scaled_delta`、`physics_substep_max_delta`、`max_physics_substeps`、`get_physics_scaled_delta_steps()` 与 `should_substep_physics()`。
- `GFAssetUtility` 新增 `pin_cache()`、`unpin_cache()` 与 `is_cache_pinned()`。
- `GFObjectPoolUtility` 新增 `prewarm_async_budget(scene: PackedScene, parent: Node, count: int, msec_budget_per_frame: float = 8.0) -> void`。
- `GFVisualAction` 新增 `is_valid()` 与 `can_execute()`。
- 无破坏性 API 变更；旧项目不使用新增能力时无需修改现有调用。

### 📘 升级指南 (Migration Guide)
1. 旧项目可直接升级；新增类和 Utility 均为可选接入。
2. 如果项目已有 UI 多属性刷新逻辑，可逐步用 `GFReactiveEffect` 或 `GFComputedProperty` 替代临时事件转发；核心状态仍应放在项目 `Model` 中。
3. 如果项目有 TileMap 编辑器工具、自动铺砖或地图差分刷新，可用 `GFTileMapCache` / `GFTileRuleSet` 作为纯数据底座；邻域采样顺序、规则含义和最终落图策略仍由项目层决定。
4. 如果项目需要按 3D 命中材质分发脚步声、弹孔或特效，可注册 `GFSurfaceUtility` 并读取 surface/material；材质标签和效果映射仍由项目层维护。
5. 如果项目已有场景加载入口，可按需调用 `GFSceneUtility.preload_scene()` 预热场景资源；loading UI、解锁规则和传送流程不进入 GF 内部。
6. 如果项目希望把场景切换参数资源化，可使用 `GFSceneTransitionConfig`，并通过 `GFSceneUtility.load_scene_with_transition()` 发起切换。
7. 如果项目需要读档选单数据，可使用 `GFSaveSlotWorkflow` 生成 `GFSaveSlotMetadata` 与 `GFSaveSlotCard`；真正的数据字段和 UI 布局仍由项目层决定。
8. 如果项目需要存档流程审计，可在 context 中传入 `include_pipeline_trace = true`，或显式创建并复用 `GFSavePipelineContext`。
9. 如果项目已有输入图标或本地化系统，可注册 `GFInputTextProvider` / `GFInputIconProvider`，无需替换现有输入映射资源。
10. 如果项目需要开发期绘制碰撞、路径或范围，可注册 `GFDebugDrawUtility` 收集命令，再用项目自己的 Overlay 渲染。
11. 如果项目有可复用表现 Tween，可用 `GFTweenActionConfig` 资源化步骤，并生成 `GFConfiguredTweenAction` 加入 `GFActionQueueSystem`。
12. 如果项目已有能力调试面板，可接入 `GFCapabilityUtility.inspect_receiver()` 展示能力依赖和分组报告。
13. 如果项目使用 `GFCommandSequence` 编排可失败流程，可通过 `with_failure_policy()` 开启失败停止和可选回滚；已有不关心失败字典的序列保持继续执行行为。
14. 如果项目存在网络、远程配置或大资源预加载等高风险初始化，可为开发期架构设置 `module_async_init_timeout_seconds`，并监听 `initialization_failed` 输出诊断。
15. 如果项目使用 `GFNodeContext.SCOPED` 承载独立战斗、房间或分屏玩家状态，可开启 `strict_dependency_lookup`，让漏注册的局部依赖立刻报错；需要显式读取父级依赖时保持默认关闭或调用父架构。
16. 如果项目存档数据较大，可把纯字典保存/读取入口迁移到 `save_data_async()` / `load_data_async()`，并在注册为 Utility 后由架构 tick 派发完成信号。
17. 如果项目使用高倍速或快进物理逻辑，可设置 `GFTimeUtility.physics_substep_max_delta` 和 `max_physics_substeps`，避免单次 `physics_tick` delta 过大。
18. 如果项目批量预加载表现资源，可在使用期间对关键资源调用 `pin_cache()`，使用结束后调用 `unpin_cache()` 恢复 LRU 淘汰。
19. 如果项目动作队列中的表现依赖运行时目标，可在自定义 `GFVisualAction.is_valid()` 或 `can_execute()` 中检查目标是否仍有效，框架会自动跳过失效动作。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf_reactive_effect.gd`
- `addons/gf/core/gf_computed_property.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/core/gf.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/plugin.gd`
- `addons/gf/base/gf_controller.gd`
- `addons/gf/base/gf_payload.gd`
- `addons/gf/base/gf_rule.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/core/gf_installer.gd`
- `addons/gf/editor/gf_access_generator.gd`
- `addons/gf/editor/gf_editor_type_index.gd`
- `addons/gf/foundation/math/gf_tile_map_cache.gd`
- `addons/gf/foundation/math/gf_tile_rule_set.gd`
- `addons/gf/foundation/numeric/gf_fixed_decimal.gd`
- `addons/gf/utilities/gf_surface_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_scene_transition_config.gd`
- `addons/gf/utilities/gf_debug_draw_utility.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_object_pool_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_time_utility.gd`
- `addons/gf/utilities/gf_log_utility.gd`
- `addons/gf/utilities/gf_config_provider.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/extensions/combat/gf_buff.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `addons/gf/extensions/combat/gf_modifier.gd`
- `addons/gf/extensions/command/gf_undoable_command.gd`
- `addons/gf/extensions/interaction/gf_interaction_context.gd`
- `addons/gf/extensions/interaction/gf_interaction_flow.gd`
- `addons/gf/extensions/interaction/gf_interactions.gd`
- `addons/gf/extensions/network/gf_enet_network_backend.gd`
- `addons/gf/extensions/network/gf_network_utility.gd`
- `addons/gf/extensions/state_machine/gf_state.gd`
- `addons/gf/extensions/sequence/gf_command_sequence.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/extensions/save/gf_save_pipeline_context.gd`
- `addons/gf/extensions/save/gf_save_pipeline_event.gd`
- `addons/gf/extensions/save/gf_save_slot_metadata.gd`
- `addons/gf/extensions/save/gf_save_slot_card.gd`
- `addons/gf/extensions/save/gf_save_slot_workflow.gd`
- `addons/gf/input/gf_input_formatter.gd`
- `addons/gf/input/gf_input_text_provider.gd`
- `addons/gf/input/gf_input_icon_provider.gd`
- `addons/gf/input/gf_input_*_modifier.gd`
- `addons/gf/input/gf_input_*_trigger.gd`
- `addons/gf/extensions/action_queue/gf_tween_action_step.gd`
- `addons/gf/extensions/action_queue/gf_tween_action_config.gd`
- `addons/gf/extensions/action_queue/gf_configured_tween_action.gd`
- `addons/gf/extensions/action_queue/gf_visual_action.gd`
- `addons/gf/extensions/action_queue/gf_visual_action_group.gd`
- `addons/gf/extensions/action_queue/gf_action_queue_system.gd`
- `tests/gf_core/test_api_docs_validation.gd`
- `tests/gf_core/test_bindable_property.gd`
- `tests/gf_core/test_gf_tile_utilities.gd`
- `tests/gf_core/test_gf_surface_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_save_graph_utility.gd`
- `tests/gf_core/test_gf_input_mapping_utility.gd`
- `tests/gf_core/test_gf_visual_actions.gd`
- `tests/gf_core/test_gf_debug_draw_utility.gd`
- `tests/gf_core/test_gf_log_utility.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_command_sequence.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `tests/gf_core/test_gf_time_utility.gd`
- `tests/gf_core/test_gf_asset_utility.gd`
- `tests/gf_core/test_gf_object_pool_utility.gd`

## [1.22.0] - 2026-05-01

**版本概述**：围绕开发期诊断、流程图协议、网络后端、输入重绑定检查和通用领域数据继续补强框架横向能力。新增能力均以独立工具、可选后端、资源描述或纯数据结构提供，不把任何项目业务、玩法节点或同步规则写入 GF。

### 🚀 新增特性 (Added)
- **存档图诊断**：`GFSaveGraphUtility` 新增 `inspect_scope()` 与 `validate_payload_for_scope()`，可提前检查重复 Source/Scope key、缺失目标、无匹配序列化器和载荷缺失项。
- **输入冲突分析**：新增 `GFInputConflictAnalyzer`，支持读取 `GFInputContext` 与可选 `GFInputRemapConfig`，用于改键界面或编辑器检查有效绑定冲突。
- **输入重绑定报告**：`GFInputConflictAnalyzer` 新增 `build_rebind_report()`，可一次返回上下文数量、有效绑定条目和冲突列表，便于设置界面与编辑器工具消费。
- **流程图端口与连接协议**：新增 `GFFlowPort`；`GFFlowNode` 新增输入/输出端口与元数据描述；`GFFlowGraph` 新增连接表、图描述和结构校验。
- **流程图连接执行**：`GFFlowRunner` 可在节点未指定 `next_node_ids` 且上下文未显式覆盖后继时，使用 `GFFlowGraph.connections` 推进后续节点。
- **默认节点序列化器扩展**：默认注册表新增 `GFNodeTimerSerializer`、`GFNodeAnimationPlayerSerializer` 与 `GFNodeAudioStreamPlayerSerializer`，覆盖更多 Godot 通用节点状态。
- **ENet 网络后端**：新增 `GFENetNetworkBackend`，作为 `GFNetworkBackend` 的可选实现，提供 host/connect/send/poll 的 bytes 传输边界。
- **网络会话与通道描述**：新增 `GFNetworkSession`、`GFNetworkChannel` 与 `GFNetworkMessageValidator`；`GFNetworkUtility` 支持频道发送、消息校验、会话状态与更完整调试快照。
- **运行时诊断工具**：新增 `GFDiagnosticsUtility`，聚合架构生命周期、事件系统、性能监视器、日志缓存和可选网络状态，并支持注册诊断命令。
- **诊断命令治理**：`GFDiagnosticsUtility` 新增命令等级、认证 token、危险命令开关与命令目录，便于开发期诊断桥接保持可控。
- **通用通知队列**：新增 `GFNotificationUtility`，提供通知入队、去重、时长推进和生命周期信号，不规定任何 UI 样式。
- **资源化控制台命令定义**：新增 `GFConsoleCommandDefinition`，`GFConsoleUtility` 支持从资源定义注册主命令与别名。
- **节点状态守卫与黑板**：`GFNodeState` 新增进入/退出守卫；`GFNodeStateGroup` 新增共享 `blackboard` 与 `transition_blocked` 信号。
- **通用属性集合**：新增 `GFAttributeSet`，提供可序列化数值属性、上下限、当前值调整、元数据和可选 `GFTraitSet` 计算入口。

### 🔄 机制更改 (Changed)
- **流程图数据描述增强**：`GFFlowNode` 仍保持执行职责不变，但可携带端口与元数据；`GFFlowGraph` 负责连接校验，项目层仍决定端口数据和节点语义。
- **上下文空后继语义收敛**：`GFFlowContext.set_next_nodes(PackedStringArray())` 现在会被视为显式停止推进，不再与“没有覆盖”混淆。
- **网络后端边界增强**：现有项目自定义后端不受影响；网络会话、频道和校验只描述传输元信息，不改变项目消息协议或同步规则。
- **诊断能力集中化与治理**：日志、架构生命周期、事件系统和网络状态可通过 `GFDiagnosticsUtility` 聚合读取；可执行命令默认只允许观察类操作。
- **存档默认覆盖面扩展**：默认序列化器覆盖更多 Godot 通用节点，但项目业务状态仍需项目层显式序列化。

### 🔌 API 变动说明 (API Changes)
- `GFSaveGraphUtility` 新增 `inspect_scope(scope: GFSaveScope, context: Dictionary = {}) -> Dictionary`。
- `GFSaveGraphUtility` 新增 `validate_payload_for_scope(scope: GFSaveScope, payload: Dictionary, strict: bool = false) -> Dictionary`。
- 新增 `GFInputConflictAnalyzer`，包含 `analyze_context()`、`analyze_contexts()`、`build_rebind_report()`、`collect_binding_items()`、`get_event_signature()` 与 `are_events_equivalent()`。
- 新增 `GFFlowPort`。
- `GFFlowNode` 新增 `input_ports`、`output_ports`、`metadata`、`get_input_ports()`、`get_output_ports()`、`get_input_port()`、`get_output_port()`、`describe_ports()` 与 `describe_node()`。
- `GFFlowContext` 新增 `has_next_node_override` 与 `has_next_nodes_override()`。
- `GFFlowGraph` 新增 `connections`、`add_connection()`、`remove_connection()`、`remove_connections_for_node()`、`has_connection()`、`get_connections_from()`、`get_connections_to()`、`get_connected_node_ids_from()`、`describe_graph()` 与 `validate_graph()`。
- 新增 `GFNodeTimerSerializer`、`GFNodeAnimationPlayerSerializer` 与 `GFNodeAudioStreamPlayerSerializer`。
- 新增 `GFENetNetworkBackend`。
- 新增 `GFNetworkSession`、`GFNetworkChannel` 与 `GFNetworkMessageValidator`。
- `GFNetworkUtility` 新增 `validator`、`session`、`register_channel()`、`unregister_channel()`、`get_channel()`、`get_channel_ids()`、`clear_channels()`、`send_message_on_channel()` 与 `message_rejected` 信号。
- `GFNetworkBackend` 与 `GFNetworkUtility` 新增 `get_debug_snapshot()`。
- 新增 `GFDiagnosticsUtility`。
- `GFDiagnosticsUtility.register_command()` 新增可选 `tier` 参数；新增 `CommandTier`、`max_command_tier`、`require_auth_token`、`auth_token`、`allow_danger_commands`、`get_command_catalog()` 与 `set_auth_token()`。
- 新增 `GFNotificationUtility`。
- 新增 `GFConsoleCommandDefinition`；`GFConsoleUtility.register_command()` 新增可选 `metadata` 参数，新增 `register_command_definition()`。
- `GFNodeState` 新增 `can_enter()`、`can_exit()`、`get_blackboard()`、`_can_enter()` 与 `_can_exit()`。
- `GFNodeStateGroup` 新增 `blackboard`、`transition_blocked` 与 `get_blackboard()`。
- 新增 `GFAttributeSet`。
- 无破坏性 API 变更；旧项目不使用新增能力时无需修改现有调用。

### 📘 升级指南 (Migration Guide)
1. 旧项目可直接升级；新增类均为可选接入。
2. 如果项目已有改键界面，可在保存覆盖前调用 `GFInputConflictAnalyzer.analyze_context()` 或 `analyze_contexts()`，冲突处理策略仍由项目层决定。
3. 如果项目已有改键界面，可改用 `build_rebind_report()` 一次性获取有效绑定条目与冲突列表。
4. 如果项目使用 `GFFlowGraph` 做可视化编辑，可逐步为自定义节点资源补充 `GFFlowPort` 与 `connections`；运行器仍兼容旧 `next_node_ids`。
5. 如果项目需要直接使用 Godot ENet，可创建 `GFENetNetworkBackend` 并传给 `GFNetworkUtility.set_backend()`；房间、鉴权、同步对象和重连仍留在项目层。
6. 如果项目需要区分可靠/不可靠或频道发送，可注册 `GFNetworkChannel` 后使用 `send_message_on_channel()`；后端仍可自行解释具体 options。
7. 如果项目已有调试面板，可注册 `GFDiagnosticsUtility` 并读取 `collect_snapshot()`；需要执行控制类命令时显式提高 `max_command_tier`，生产构建建议保持默认观察等级。
8. 如果项目需要通用通知入口，可注册 `GFNotificationUtility` 并监听 `notification_started` / `notification_finished` 渲染自己的 UI。
9. 如果项目需要通用数值容器，可用 `GFAttributeSet` 管理属性当前值与范围，再按需要叠加 `GFTraitSet`；具体属性语义仍由项目层命名。

### 📁 核心受影响文件 (Affected Files)
- `ASSET_LIBRARY.md`
- `README.md`
- `addons/gf/README.md`
- `addons/gf/plugin.cfg`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/更新日志 (Changelog).md`
- `addons/gf/extensions/domain/gf_attribute_set.gd`
- `addons/gf/extensions/flow/gf_flow_graph.gd`
- `addons/gf/extensions/flow/gf_flow_context.gd`
- `addons/gf/extensions/flow/gf_flow_node.gd`
- `addons/gf/extensions/flow/gf_flow_port.gd`
- `addons/gf/extensions/flow/gf_flow_runner.gd`
- `addons/gf/extensions/network/gf_network_channel.gd`
- `addons/gf/extensions/network/gf_network_message_validator.gd`
- `addons/gf/extensions/network/gf_network_session.gd`
- `addons/gf/extensions/network/gf_enet_network_backend.gd`
- `addons/gf/extensions/network/gf_network_backend.gd`
- `addons/gf/extensions/network/gf_network_utility.gd`
- `addons/gf/extensions/save/gf_node_animation_player_serializer.gd`
- `addons/gf/extensions/save/gf_node_audio_stream_player_serializer.gd`
- `addons/gf/extensions/save/gf_node_serializer_registry.gd`
- `addons/gf/extensions/save/gf_node_timer_serializer.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/extensions/state_machine/gf_node_state.gd`
- `addons/gf/extensions/state_machine/gf_node_state_group.gd`
- `addons/gf/utilities/gf_console_command_definition.gd`
- `addons/gf/utilities/gf_console_utility.gd`
- `addons/gf/input/gf_input_conflict_analyzer.gd`
- `addons/gf/utilities/gf_diagnostics_utility.gd`
- `addons/gf/utilities/gf_notification_utility.gd`
- `tests/gf_core/test_gf_console_utility.gd`
- `tests/gf_core/test_gf_diagnostics_utility.gd`
- `tests/gf_core/test_gf_domain_extensions.gd`
- `tests/gf_core/test_gf_flow_graph.gd`
- `tests/gf_core/test_gf_input_mapping_utility.gd`
- `tests/gf_core/test_gf_network_extension.gd`
- `tests/gf_core/test_gf_node_state_machine.gd`
- `tests/gf_core/test_gf_notification_utility.gd`
- `tests/gf_core/test_gf_save_graph_utility.gd`

## [1.21.0] - 2026-05-01

**版本概述**：围绕通用输入、节点存档图、流程编排、网络抽象、运行时诊断、音频编排和 3D 空间查询补强框架横向能力。新增内容均以可组合 Resource、Node Hook、后端接口或纯逻辑数据结构提供，不绑定具体业务字段、实体类型、协议平台或玩法规则。

### 🚀 新增特性 (Added)
- **输入修饰器与触发器**：新增 `GFInputModifier`、死区/缩放/归一化/范围映射修饰器，以及 `GFInputTrigger`、`GFInputHoldTrigger`，可在 Binding/Mapping 层组合处理轴值和长按触发。
- **输入检测增强**：`GFInputDetector` 新增按动作值类型检测、倒计时接收窗口和便捷 `detect_bool()` / `detect_axis_1d()` / `detect_axis_2d()`。
- **通用节点存档图**：新增 `GFSaveScope`、`GFSaveSource`、`GFSaveIdentity`、`GFSaveGraphUtility`、节点序列化器注册表和实体工厂基类，支持项目层按 Scope/Source 组合保存和恢复节点状态。
- **存档 Pipeline**：新增 `GFSavePipelineStep` 与 `GFSaveGraphUtility.pipeline_steps`，可在 Scope 采集/应用前后插入版本适配、校验、调试标记或通用载荷处理。
- **默认节点序列化器**：新增 Node2D/Node3D Transform、CanvasItem、Control、Range 序列化器与显式属性白名单序列化器，作为可替换的通用节点状态片段。
- **输入三维动作值**：`GFInputAction.ValueType` 新增 `AXIS_3D`，`GFInputBinding.ValueTarget` 新增三维 X/Y/Z 正负向目标，`GFInputMappingUtility` 新增三维动作值查询。
- **输入触发器扩展**：新增按下、释放、短按、周期脉冲、组合动作和动作序列触发器，覆盖常见输入语义但不绑定具体按键或业务行为。
- **资源化流程图基础**：新增 `GFFlowContext`、`GFFlowNode`、`GFFlowGraph` 与 `GFFlowRunner`，提供节点执行、动态分支、Signal 等待、取消和循环保护。
- **网络抽象基础**：新增 `GFNetworkMessage`、`GFNetworkSerializer`、`GFNetworkBackend`、`GFNetworkUtility` 与 `GFNetworkRateLimiter`，为项目层接入任意传输后端提供统一边界。
- **项目常量访问器生成**：`GFAccessGenerator` 新增项目常量访问器生成能力，可生成命名层、InputMap 动作和 GF ProjectSettings 键名常量。
- **日志内存环形缓存**：`GFLogUtility` 新增最近日志条目缓存、分页读取、容量上限和丢弃计数，便于控制台和调试面板直接读取历史日志。
- **控制台相似命令建议**：`GFConsoleUtility` 新增相似命令候选查询，未知命令可提示最接近的已注册命令。
- **音频编排增强**：`GFAudioUtility` 新增 BGM 淡入淡出、BGM 播放历史、当前 BGM key、环境音 channel 播放/停止，以及资源化环境音入口。
- **3D 空间哈希**：新增 `GFSpatialHash3D`，提供纯逻辑 AABB 插入、更新、移除、范围查询和半径查询。

### 🔄 机制更改 (Changed)
- **输入动作活跃判定解耦**：`GFInputMappingUtility` 在聚合绑定值后先应用 Mapping 修饰器，再由可选 Trigger 决定动作是否活跃；未配置 Trigger 时保持原始活跃语义。
- **输入内部值模型扩展**：输入聚合内部使用三维向量表示贡献，旧二维查询 API 保持兼容并返回 X/Y 分量。
- **玩家级输入状态一致性**：玩家级动作向量现在也应用 Mapping 修饰器，并在清理玩家状态时同步清理 raw active 与 trigger runtime state。
- **BGM 播放请求兼容增强**：原 `play_bgm()` / `play_bgm_clip()` / `play_bgm_from_bank()` 保持可用，并通过可选参数接入单次淡入淡出。
- **Save Viewer 默认位置调整**：`GF Save Viewer` 现在默认加入编辑器底部面板区域，与测试面板等工具使用同类停靠位置，减少右侧 Inspector 空间占用。

### 🐛 Bug 修复 (Fixed)
- **输入 Mapping 重建残留**：重建有效输入条目时同步清理 Mapping 修饰器和触发器缓存，避免上下文切换后旧配置残留。
- **AUTO 绑定事件透传**：`GFInputBinding` 的 AUTO 贡献路径现在会把原生 `InputEvent` 传给绑定级修饰器。
- **输入触发器脚本解析冲突**：`GFInputTrigger` 的状态重置方法避开 Godot `Resource.reset_state()` 内置方法名，修复 LSP 解析 `GFInputTrigger` / `GFInputHoldTrigger` 失败的问题。

### 🔌 API 变动说明 (API Changes)
- `GFInputBinding` 新增 `modifiers: Array[GFInputModifier]`。
- `GFInputBinding.ValueTarget` 新增三维轴正负向枚举项。
- `GFInputMapping` 新增 `modifiers: Array[GFInputModifier]` 与 `triggers: Array[GFInputTrigger]`。
- `GFInputAction.ValueType` 新增 `AXIS_3D`。
- `GFInputMappingUtility` 新增 `get_action_vector3()` 与 `get_action_vector3_for_player()`。
- `GFInputModifier` 新增 `modify_3d(value: Vector3, event: InputEvent = null, action: GFInputAction = null) -> Vector3`。
- `GFInputTrigger` 新增 `prepare_runtime(action_id: StringName, input_utility: Object, player_index: int, state: Dictionary) -> void`。
- `GFInputDetector` 新增 `countdown_seconds`、`begin_detection_for_value_type()`、`begin_detection_for_action()`、`detect_bool()`、`detect_axis_1d()`、`detect_axis_2d()`、`detect_axis_3d()`、`get_countdown_remaining()` 与 `is_accepting_input()`。
- `GFConsoleUtility` 新增 `suggest_similar_commands(cmd_name: String, limit: int = 3, threshold: float = 0.5) -> PackedStringArray`。
- `GFLogUtility` 新增 `max_memory_entries`、`get_recent_entries()`、`get_entries()`、`get_memory_entry_count()`、`get_dropped_memory_entry_count()` 与 `clear_memory_entries()`。
- `GFAudioUtility` 新增 `bgm_crossfade_seconds`、`max_bgm_history`、`get_bgm_history()`、`get_current_bgm_key()`、`clear_bgm_history()`、`play_ambient()`、`play_ambient_clip()`、`play_ambient_from_bank()`、`stop_ambient()`、`stop_all_ambient()` 与 `is_ambient_playing()`；BGM 播放方法增加可选 `crossfade_seconds` 参数。
- 新增 `GFSaveGraphUtility`、`GFSaveScope`、`GFSaveSource`、`GFSaveIdentity`、`GFSaveEntityFactory`、`GFSavePipelineStep`、`GFNodeSerializer`、`GFNodeSerializerRegistry`、`GFNodePropertySerializer`、`GFNodeTransform2DSerializer`、`GFNodeTransform3DSerializer`、`GFNodeCanvasItemSerializer`、`GFNodeControlSerializer`、`GFNodeRangeSerializer`。
- 新增 `GFFlowContext`、`GFFlowNode`、`GFFlowGraph`、`GFFlowRunner`。
- 新增 `GFNetworkMessage`、`GFNetworkSerializer`、`GFNetworkBackend`、`GFNetworkUtility`、`GFNetworkRateLimiter`。
- `GFAccessGenerator` 新增 `generate_project_access()`、`collect_project_records()` 与 `build_project_source()`。
- 新增 `GFSpatialHash3D`。
- 无破坏性 API 变更；未使用新增配置的旧输入、日志、音频和存档调用保持原行为。

### 📘 升级指南 (Migration Guide)
1. 旧项目可直接升级；输入 Mapping 未配置 `modifiers` / `triggers` 时行为保持原样。
2. 如需长按、死区重映射、摇杆归一化或轴值缩放，优先把通用转换放进 `GFInputModifier` / `GFInputTrigger`，具体移动、攻击、菜单规则仍放在项目层。
3. 如需三维输入，使用 `GFInputAction.ValueType.AXIS_3D` 和三维 `ValueTarget`，读取时使用 `get_action_vector3()`；旧二维接口无需迁移。
4. 如需保存场景树局部状态，可在根节点下放置 `GFSaveScope` 与若干 `GFSaveSource`，再由项目层决定 Source 数据 schema、自定义序列化器或 Pipeline 步骤。
5. 如需资源化流程编排，优先继承 `GFFlowNode` 写项目自己的节点资源，再用 `GFFlowRunner` 执行；不要把剧情、任务或教程规则写进框架节点。
6. 如需网络能力，继承 `GFNetworkBackend` 接入项目选择的传输层，并通过 `GFNetworkUtility` 发送/接收 `GFNetworkMessage`。
7. 如需运行时调试面板读取历史日志，使用 `GFLogUtility.get_recent_entries()`，不必额外监听并复制 `log_emitted`。
8. 如需环境音或 BGM 淡入淡出，可使用新增音频参数和 channel API；原 SFX 池化与音量总线接口无需迁移。
9. 3D 项目需要大量实体粗筛时可在 System 内持有 `GFSpatialHash3D`，再在查询结果上执行项目自己的精确规则。

### 📁 核心受影响文件 (Affected Files)
- `ASSET_LIBRARY.md`
- `README.md`
- `addons/gf/README.md`
- `addons/gf/plugin.cfg`
- `addons/gf/plugin.gd`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/11. 基础层 (Foundation Layer).md`
- `docs/wiki/更新日志 (Changelog).md`
- `addons/gf/input/gf_input_binding.gd`
- `addons/gf/input/gf_input_detector.gd`
- `addons/gf/input/gf_input_mapping.gd`
- `addons/gf/input/gf_input_modifier.gd`
- `addons/gf/input/gf_input_trigger.gd`
- `addons/gf/input/gf_input_pressed_trigger.gd`
- `addons/gf/input/gf_input_released_trigger.gd`
- `addons/gf/input/gf_input_tap_trigger.gd`
- `addons/gf/input/gf_input_pulse_trigger.gd`
- `addons/gf/input/gf_input_chord_trigger.gd`
- `addons/gf/input/gf_input_sequence_trigger.gd`
- `addons/gf/utilities/gf_input_mapping_utility.gd`
- `addons/gf/utilities/gf_console_utility.gd`
- `addons/gf/utilities/gf_log_utility.gd`
- `addons/gf/utilities/gf_audio_utility.gd`
- `addons/gf/extensions/save/`
- `addons/gf/extensions/flow/`
- `addons/gf/extensions/network/`
- `addons/gf/editor/gf_access_generator.gd`
- `addons/gf/foundation/math/gf_spatial_hash_3d.gd`
- `tests/gf_core/test_gf_input_mapping_utility.gd`
- `tests/gf_core/test_gf_input_detector.gd`
- `tests/gf_core/test_gf_console_utility.gd`
- `tests/gf_core/test_gf_save_graph_utility.gd`
- `tests/gf_core/test_gf_flow_graph.gd`
- `tests/gf_core/test_gf_network_extension.gd`
- `tests/gf_core/test_gf_access_generator.gd`
- `tests/gf_core/test_gf_spatial_hash_3d.gd`
- `tests/gf_core/test_gf_log_utility.gd`
- `tests/gf_core/test_gf_audio_utility.gd`
