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

本页面只保留最近三个版本线的更新记录，当前保留 `2.6.x`、`2.5.x` 与 `2.4.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [2.6.0] - 2026-05-11

**版本概述**：补齐通用节点树操作、场景预加载图谱、架构依赖诊断、能力 Inspector 的 Recipe/校验辅助、转向避碰、动作拦截器、UI 路由、虚拟输入源与录制回放、权重选择、标签查询、黑板 Schema、类型化 JSON Variant codec、请求 Outbox、3D 指针交互桥、WebSocket 后端、通用图搜索和 3D 网格算法，保持功能抽象、可选且不改变旧项目默认行为。

### 🚀 新增特性 (Added)
- 新增 `GFNodeTreeUtility`，提供节点添加、重挂、替换、类型查找、树遍历、owner 传播和子节点释放等通用节点树操作。
- 新增 `GFScenePreloadEntry` 与 `GFScenePreloadMap`，用于资源化描述场景相邻关系、固定预加载路径和图谱校验报告。
- `GFSceneUtility` 支持配置场景预加载图谱，可获取预加载计划、按图谱预加载指定或当前场景，并可在切换成功后自动预加载相邻场景。
- `GFArchitecture` 新增声明式依赖诊断报告，可读取模块可选的 `get_required_dependencies()` / `get_required_models()` / `get_required_systems()` / `get_required_utilities()` / `get_required_factories()` hook。
- GF Capability Inspector 新增 Recipe 应用入口和节点能力依赖校验按钮，便于编辑器中批量添加节点能力并检查缺失依赖。
- `GFSteeringMath` 新增动态碰撞避让计算，基于代理位置、速度、半径和预测窗口返回通用 steering 加速度。
- 新增 `GFActionInterceptor` 与 `GFActionInterceptionResult`，`GFActionQueueSystem` 可在动作执行前后按优先级执行拦截器，用于跳过、替换或停止表现队列。
- 新增 `GFUIRoute` 与 `GFUIRouterUtility`，在 `GFUIUtility` 分层 UI 栈之上提供 route id 到面板场景的可选映射、路由参数和轻量历史。
- 新增 `GFVirtualInputSource`，`GFInputMappingUtility` 支持通过虚拟源写入抽象动作值，便于测试、回放、AI 控制或自定义输入桥接。
- 新增 `GFInputRecording` 与 `GFInputPlayback`，支持把抽象动作值按时间录制并通过 `GFVirtualInputSource` 回放。
- 新增 `GFWeightedEntry` 与 `GFWeightedTable`，提供资源化候选项、权重选择、批量选择、可复现随机源和字典序列化。
- 新增 `GFTagSet`、`GFTagQuery` 与 `GFTagUtility`，提供 Foundation 级标签集合、all/any/none 查询、层级标签匹配和多种标签源适配。
- 新增 `GFBlackboardEntry` 与 `GFBlackboardSchema`，提供通用黑板字段契约、默认值补齐、类型转换和字典校验。
- `GFVariantUtility` 新增类型化 JSON 兼容 codec，可保留常见 Godot 值类型、PackedArray 和可选非字符串字典键。
- 新增 `GFRequestEnvelope` 与 `GFRequestOutboxUtility`，提供通用离线请求描述、持久化队列、重试策略、失败列表和 transport callback 边界。
- 新增 `GFPointerInteraction3D`，将 `CollisionObject3D` 的 3D 指针 hover/click/wheel 事件桥接为 `GFInteractionContext`。
- 新增 `GFWebSocketNetworkBackend`，基于 `WebSocketPeer` 实现可插拔 bytes 传输边界，便于浏览器、工具链或 WebSocket 网关复用 `GFNetworkUtility`。
- 新增 `GFGraphMath`，提供面向任意 Variant 节点的 Dijkstra、A*、距离图和可达范围算法。
- 新增 `GFGrid3DMath`，提供 3D 整数网格邻居、A*、可达范围和台阶式表面路径算法。

### 🔄 机制更改 (Changed)
- `GFBehaviorTree.RandomSelector` 与 `RandomSequence` 支持注入 `RandomNumberGenerator`，也可从 `blackboard["rng"]` 读取随机源；未提供随机源时保持原随机行为。
- `GFFlowGraph.validate_graph()` 新增可选拓扑诊断 warning：不可达节点、循环结构和显式开启的终端节点提示。
- `GFBuff` 支持可配置重复添加策略、持续时间刷新策略、周期 Tick 间隔和过期保留；默认仍保持旧的刷新持续时间并叠层行为。
- `GFTagComponent` 新增标签枚举和层数字典快照，便于通用标签查询或调试工具读取。
- `GFNetworkSerializer` 的 JSON 格式新增可选类型化 Variant codec 开关；默认关闭，旧 JSON 载荷格式保持不变。
- `GFPattern2D` Inspector 的格子编辑器支持拖拽涂抹和 Ctrl 擦除。

### 🐛 Bug 修复 (Fixed)
- 修复 `GFRequestEnvelope.mark_failure()` 在 0ms 重试延迟下仍写入当前时间戳，导致同帧连续 `GFRequestOutboxUtility.replay()` 可能跳过立即重试的问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFNodeTreeUtility.add_child_with_owner(parent: Node, child: Node, owner: Node = null, force_readable_name: bool = false) -> bool`。
- 新增 `GFNodeTreeUtility.reparent_node(node: Node, new_parent: Node, keep_global_transform: bool = true, owner: Node = null) -> bool`。
- 新增 `GFNodeTreeUtility.replace_child(parent: Node, old_child: Node, new_child: Node, keep_global_transform: bool = true, free_old_child: bool = false, owner: Node = null) -> bool`。
- 新增 `GFNodeTreeUtility.find_first_parent_of_type(node: Node, parent_type: Variant, include_self: bool = false) -> Node`。
- 新增 `GFNodeTreeUtility.find_first_child_of_type(parent: Node, child_type: Variant, recursive: bool = false, include_internal: bool = false, include_parent: bool = false) -> Node`。
- 新增 `GFNodeTreeUtility.collect_node_tree(root: Node, type_filter: Variant = null, include_root: bool = true, include_internal: bool = false) -> Array[Node]`。
- 新增 `GFNodeTreeUtility.set_owner_recursive(node: Node, owner: Node) -> void`。
- 新增 `GFNodeTreeUtility.free_children(parent: Node, include_internal: bool = false) -> int`。
- 新增 `GFScenePreloadEntry.scene_path`、`adjacent_scene_paths`、`fixed`、`metadata` 以及 `get_scene_path()`、`get_adjacent_scene_paths()`、`describe_entry()`。
- 新增 `GFScenePreloadMap.default_radius`、`max_scheduled_scenes`、`fixed_scene_paths`、`entries`、`metadata` 以及 `get_entry()`、`get_fixed_scene_paths()`、`get_neighbor_scene_paths()`、`get_preload_plan()`、`validate_map()`。
- `GFSceneUtility` 新增 `scene_preload_map`、`auto_preload_map_neighbors_on_switch`、`scene_preload_map_radius`、`configure_scene_preload_map()`、`get_scene_preload_map_plan()`、`preload_scene_map_for()` 与 `preload_current_scene_map()`。
- `GFArchitecture` 新增 `get_dependency_diagnostics(options: Dictionary = {}) -> Dictionary`，并暴露依赖声明 hook 名称常量。
- 新增 `GFSteeringMath.avoid_collisions(agent: GFSteeringAgent, targets: Array[GFSteeringAgent], max_prediction_seconds: float = 1.0, collision_radius: float = -1.0, minimum_separation: float = -1.0) -> GFSteeringAcceleration`。
- 新增 `GFActionQueueSystem.add_interceptor()`、`remove_interceptor()`、`set_interceptors()`、`clear_interceptors()` 与 `get_interceptors()`。
- 新增 `GFActionInterceptor.before_execute()`、`after_execute()`，以及 `GFActionInterceptionResult.continue_action()`、`skip_action()`、`replace_with()`、`stop_queue()`。
- 新增 `GFUIRoute.get_route_id()`、`is_valid_route()`、`build_options()`。
- 新增 `GFUIRouterUtility` 的路由注册、同步/异步打开、替换、返回、历史和诊断快照 API。
- 新增 `GFInputMappingUtility.create_virtual_source()`、`set_virtual_action_value()`、`clear_virtual_action()`、`clear_virtual_source()` 与 `get_virtual_source_snapshot()`。
- 新增 `GFVirtualInputSource.configure()`、`set_action_value_for_player()`、`press()`、`release()`、`set_axis_1d()`、`set_axis_2d()`、`set_axis_3d()`、`clear_action()`、`clear_action_for_player()`、`clear_all()` 与 `get_snapshot()`。
- 新增 `GFInputRecording.add_event()`、`clear()`、`is_empty()`、`get_event_count()`、`sort_events()`、`get_events()`、`duplicate_recording()`、`to_dict()`、`apply_dict()` 与 `from_dict()`。
- 新增 `GFInputPlayback.start()`、`stop()`、`reset()`、`tick()`、`seek()`、`is_finished()` 与 `get_debug_snapshot()`。
- 新增 `GFWeightedEntry.configure()`、`is_selectable()`、`duplicate_entry()`、`to_dict()` 与 `from_dict()`。
- 新增 `GFWeightedTable.add_entry()`、`add_weighted_entry()`、`remove_entry()`、`clear()`、`get_selectable_entries()`、`get_total_weight()`、`is_empty()`、`pick_entry()`、`pick_value()`、`pick_many()`、`duplicate_table()`、`to_dict()`、`apply_dict()` 与 `from_dict()`。
- 新增 `GFTagSet.add_tag()`、`remove_tag()`、`has_tag()`、`get_tag_count()`、`get_tags()`、`get_tag_counts()`、`duplicate_set()`、`to_dictionary()` 与 `from_dictionary()`。
- 新增 `GFTagQuery.matches()`、`get_match_report()`、`configure()`、`duplicate_query()`、`to_dictionary()` 与 `from_dictionary()`。
- 新增 `GFTagUtility.source_has_tag()`、`get_tag_count()`、`get_tags()`、`matches_all()`、`matches_any()` 与 `matches_none()`。
- 新增 `GFBlackboardEntry.is_value_valid()`、`try_coerce_value()`、`coerce_value()`、`duplicate_entry()`、`describe()` 与 `value_type_to_name()`。
- 新增 `GFBlackboardSchema.get_entry()`、`has_entry()`、`get_entry_keys()`、`build_defaults()`、`apply_defaults()`、`coerce_dictionary()`、`validate_values()`、`duplicate_schema()` 与 `describe()`。
- 新增 `GFVariantUtility.variant_to_json_compatible()` 与 `json_compatible_to_variant()`。
- 新增 `GFRequestEnvelope.configure()`、`is_valid()`、`can_attempt()`、`is_exhausted()`、`mark_attempt()`、`mark_failure()`、`mark_success()`、`duplicate_request()`、`to_dict()`、`apply_dict()`、`get_method_name()` 与 `from_dict()`。
- 新增 `GFRequestOutboxUtility.enqueue_request()`、`enqueue()`、`replay()`、`remove_request()`、`clear_queue()`、`clear_failed_requests()`、`get_queue_size()`、`get_failed_request_count()`、`get_pending_requests()`、`get_failed_requests()`、`save_queue()`、`load_queue()` 与 `get_debug_snapshot()`。
- 新增 `GFPointerInteraction3D.bind_collision_object()`、`get_collision_object()`、`build_context()` 与 `send_pointer_interaction()`。
- 新增 `GFWebSocketNetworkBackend.host()`、`connect_to_endpoint()`、`disconnect_backend()`、`send_bytes()`、`poll()` 与 `get_debug_snapshot()` 实现。
- 新增 `GFGraphMath.find_path_dijkstra()`、`find_path_a_star()`、`build_distance_map()` 与 `find_reachable()`。
- 新增 `GFGrid3DMath.is_in_bounds()`、`get_neighbors()`、`get_surface_neighbors()`、`find_path_a_star()`、`find_reachable()` 与 `find_surface_path_a_star()`。
- `GFBehaviorTree.RandomSelector.new(children_nodes, random_source = null)` 与 `GFBehaviorTree.RandomSequence.new(children_nodes, random_source = null)` 新增可选随机源参数。
- `GFFlowGraph` 新增 `warn_unreachable_nodes`、`warn_cycles` 与 `warn_terminal_nodes` 导出配置。
- `GFBuff` 新增 `StackMode`、`DurationRefreshPolicy`、`stack_mode`、`duration_refresh_policy`、`tick_interval_seconds` 与 `remove_on_expire`。
- `GFTagComponent` 新增 `get_tags()` 与 `get_tag_snapshot()`。
- `GFNetworkSerializer` 新增 `use_typed_json_codec` 与 `json_codec_options`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。新增能力默认关闭或只在显式配置后生效；`GFSceneUtility` 只有设置 `scene_preload_map` 后才会按图谱预加载。
- 依赖诊断 hook 是可选约定，不会影响模块注册、初始化顺序或依赖查询结果；项目可逐步为关键模块补充声明。
- Capability Inspector 的 Recipe 应用只处理节点能力条目；普通对象能力仍应通过运行时 `GFCapabilityUtility.apply_recipe()` 应用。
- 动作队列拦截器默认为空，旧队列执行顺序不变；需要横切处理时再显式注册拦截器。
- UI 路由工具只封装 `GFUIUtility`，不会替代项目已有导航 Model/System；旧项目可继续直接使用 UI 栈 API。
- 虚拟输入源只影响已启用上下文中存在的动作，不参与重绑定配置和冲突分析。
- 输入录制回放只处理抽象动作值，不模拟真实设备事件；需要文件格式、压缩、权限或公开回放时由项目层定义。
- 请求 Outbox 只负责队列、持久化和重试；幂等策略、签名、脱敏、冲突处理和真正传输由项目自己的 callback 决定。
- 类型化 JSON codec 只有在显式调用 `GFVariantUtility` 或打开 `GFNetworkSerializer.use_typed_json_codec` 后才生效。
- 3D 指针桥默认只在 click 发送交互，距离、焦点、碰撞层、权限和效果仍由项目层处理。
- 权重表、标签查询、黑板 Schema、通用图算法和 3D 网格算法都是新增 Foundation 原语，不需要注册到 `GFArchitecture`；旧项目无需迁移。
- WebSocket 后端为可选新后端，不改变现有 ENet 或自定义后端行为；需要浏览器/工具链连接时再显式 `set_backend(GFWebSocketNetworkBackend.new())`。
- FlowGraph 新增诊断默认只产生 warning，不改变 `ok` 判定；若项目把 `healthy` 用作硬性校验，需要注意不可达节点或循环会让 `healthy` 为 false。
- Buff 新策略默认保持旧行为；只有显式设置 `stack_mode`、`duration_refresh_policy`、`tick_interval_seconds` 或 `remove_on_expire` 时才改变运行表现。
- 行为树随机节点的新随机源参数为可选参数；旧构造调用保持兼容。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/editor/gf_capability_inspector_plugin.gd`
- `addons/gf/extensions/action_queue/gf_action_interception_result.gd`
- `addons/gf/extensions/action_queue/gf_action_interceptor.gd`
- `addons/gf/extensions/action_queue/gf_action_queue_system.gd`
- `addons/gf/extensions/combat/gf_buff.gd`
- `addons/gf/extensions/combat/gf_tag_component.gd`
- `addons/gf/extensions/flow/gf_flow_graph.gd`
- `addons/gf/extensions/interaction/gf_pointer_interaction_3d.gd`
- `addons/gf/extensions/network/gf_network_serializer.gd`
- `addons/gf/extensions/network/gf_websocket_network_backend.gd`
- `addons/gf/foundation/blackboard/gf_blackboard_entry.gd`
- `addons/gf/foundation/blackboard/gf_blackboard_schema.gd`
- `addons/gf/foundation/math/gf_steering_math.gd`
- `addons/gf/foundation/math/gf_graph_math.gd`
- `addons/gf/foundation/math/gf_grid_3d_math.gd`
- `addons/gf/foundation/math/gf_weighted_entry.gd`
- `addons/gf/foundation/math/gf_weighted_table.gd`
- `addons/gf/foundation/tags/gf_tag_query.gd`
- `addons/gf/foundation/tags/gf_tag_set.gd`
- `addons/gf/foundation/tags/gf_tag_utility.gd`
- `addons/gf/foundation/variant/gf_variant_utility.gd`
- `addons/gf/input/gf_input_recording.gd`
- `addons/gf/input/gf_input_playback.gd`
- `addons/gf/input/gf_virtual_input_source.gd`
- `addons/gf/utilities/gf_behavior_tree.gd`
- `addons/gf/utilities/gf_input_mapping_utility.gd`
- `addons/gf/utilities/gf_node_tree_utility.gd`
- `addons/gf/utilities/gf_request_envelope.gd`
- `addons/gf/utilities/gf_request_outbox_utility.gd`
- `addons/gf/utilities/gf_scene_preload_entry.gd`
- `addons/gf/utilities/gf_scene_preload_map.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_ui_route.gd`
- `addons/gf/utilities/gf_ui_router_utility.gd`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_architecture_dependency_diagnostics.gd`
- `tests/gf_core/test_gf_behavior_tree.gd`
- `tests/gf_core/test_gf_blackboard_schema.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_flow_graph.gd`
- `tests/gf_core/test_gf_input_mapping_utility.gd`
- `tests/gf_core/test_gf_interaction_nodes.gd`
- `tests/gf_core/test_gf_network_extension.gd`
- `tests/gf_core/test_gf_request_outbox_utility.gd`
- `tests/gf_core/test_gf_variant_utility.gd`
- `tests/gf_core/test_gf_node_tree_utility.gd`
- `tests/gf_core/test_gf_scene_preload_map.gd`
- `tests/gf_core/test_gf_steering_math.gd`
- `tests/gf_core/test_gf_tag_query.gd`
- `tests/gf_core/test_gf_graph_math.gd`
- `tests/gf_core/test_gf_grid_3d_math.gd`
- `tests/gf_core/test_gf_weighted_table.gd`
- `tests/gf_core/test_gf_ui_router_utility.gd`
- `docs/wiki/01. 架构概览 (Architecture).md`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/10. 战斗扩展 (Combat Extension).md`
- `docs/wiki/11. 基础层 (Foundation Layer).md`
- `docs/wiki/12. 能力组件 (Capabilities).md`
- `README.md`
- `addons/gf/README.md`

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
