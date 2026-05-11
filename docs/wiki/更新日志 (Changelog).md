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

本页面只保留最近三个版本线的更新记录，当前保留 `3.0.x`、`2.6.x` 与 `2.5.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [3.0.0] - 2026-05-11

**版本概述**：修复事件 pending、存档迁移、输入来源聚合和暂停驱动等边界问题，收敛事件监听轨道、架构注册表、存档路径/事务处理、tick 参与判定与权重表复制辅助逻辑，并按最佳实践调整纯代码状态机启动初始状态的默认通知行为。

### 🚀 新增特性 (Added)
- 新增编辑器侧 `GFSourceBuilder`，用于生成脚本时统一处理源码行、缩进、空行、section 与文档注释格式。
- 新增 Foundation 级 `GFResultUtility`，提供通用结果字典 key 常量与 `make()` / `make_success()` / `make_failure()` 轻量工厂。

### 🔄 机制更改 (Changed)
- `Gf` AutoLoad 会将自身 `process_mode` 设置为 `PROCESS_MODE_ALWAYS`，避免项目使用 Godot 原生暂停时框架 tick 完全停摆。
- `GFTypeEventSystem` 将 exact、assignable 与 simple 三组监听器的 pending add/remove/owner-remove 规则收敛为共享内部轨道，减少重复实现并统一派发中变更的边界语义；公开 API 不变。
- `GFArchitecture` 将 Model、System、Utility 三组模块注册表收敛为共享内部结构，统一注册、别名、继承匹配缓存、注销与生命周期阶段推进的实现；公开 API 与默认行为不变。
- `GFArchitecture` 的 tick 缓存现在基于显式 `tick_enabled` / `physics_tick_enabled` 或脚本真实声明的 `tick()` / `physics_tick()` 构建；未重写基类空模板的 `GFSystem` 不再每帧空转，`GFUtility` 仍必须实现对应方法才会被驱动，旧项目重写方法后自动参与 tick 的行为保持兼容。
- `GFAccessGenerator` 与 `GFConfigAccessGenerator` 复用 `GFSourceBuilder` 生成脚本源码，减少直接 `PackedStringArray.append()` 拼接造成的格式维护成本；生成访问器的公开行为保持兼容。
- 编辑器 `plugin.gd` 拆分为 ProjectSettings、AutoLoad、工具菜单、菜单动作、Inspector/导出插件装配等内部辅助脚本，主插件脚本保留生命周期编排与 Save Viewer Dock；插件入口、菜单项和默认行为保持兼容。
- `GFStorageUtility` 将路径策略、文件操作和事务提交/恢复收敛为内部 `StoragePathPolicy`、`StorageFileOps` 与 `StorageTransactionManager`，保持存档文件格式、事务文件格式和公开 API 不变。
- `GFStorageCodec`、`GFStorageBackend` 与 `GFStorageUtility` 的 `ok` / `data` / `metadata` / `integrity_valid` / `error` 返回字典改为复用 `GFResultUtility` 构造；返回字段和默认语义保持兼容。
- `GFStateMachine.start()` 默认会在初始状态进入成功后发出 `state_changed(&"", initial_state_name)`，让启动与后续状态切换共享同一通知路径；少数需要静默启动的场景可传入第三个参数 `false`。
- `GFNetworkReconnectPolicy` 的 jitter 随机源改为实例初始化时播种，不再在每次计算延迟时重新 `randomize()`，便于测试和项目层复现退避序列。
- `GFWeightedEntry` / `GFWeightedTable` 复用 `GFVariantUtility.duplicate_variant(..., duplicate_resources = true)` 复制集合与资源值，减少重复 helper。

### 🐛 Bug 修复 (Fixed)
- 修复 `GFTypeEventSystem` 在派发中跨事件类型/简单事件 ID 注册后立即注销时，pending add 仍会在 flush 后落地的问题。
- 修复事件回调签名只校验最少参数、不拦截额外未绑定必填参数的问题；对象方法回调现在会拒绝派发时无法满足的签名。
- 修复 `GFStorageUtility` 注册了迁移步骤但缺少完整迁移链时，旧存档仍被标记为当前 `save_version` 的问题。
- 修复 `GFStorageUtility.save_data()` / `load_data()` / `load_data_result()` / `save_data_async()` / `load_data_async()` 空 `file_name` 会落入内部兜底文件名的问题。
- 修复 `GFInputMappingUtility` 玩家级动作状态未把真实输入来源纳入 binding key，导致同一玩家多来源输入可能互相覆盖的问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFSourceBuilder` 公开编辑器辅助类；现有访问器生成器入口和生成脚本调用方式不变。
- 新增 `GFResultUtility` 公开基础辅助类，用于统一常见结果字典字段名和构造方式；现有存储 API 返回字典字段不变。
- `GFStateMachine.start(initial_state_name, msg = {}, emit_changed = true)` 新增可选 `emit_changed` 参数；默认初始进入会发出 `state_changed(&"", initial_state_name)`，传 `false` 可静默启动。
- `GFSystem` 与 `GFUtility` 新增可选公开属性 `tick_enabled` / `physics_tick_enabled`，用于显式声明模块参与 `tick()` / `physics_tick()` 缓存；旧项目继续通过重写同名方法自动参与，无需迁移。
- `GFVariantUtility.duplicate_variant(value, deep = true, duplicate_resources = false)` 新增可选参数；默认仍只复制 `Dictionary` / `Array`，显式传入 `duplicate_resources = true` 时才复制 `Resource`。
- `GFVariantUtility.duplicate_collection(value, deep = true)` 新增可选 `deep` 参数，旧的一参调用保持兼容。
- 纯数据存取 API 传入空 `file_name` 时会明确返回失败：同步保存返回 `ERR_INVALID_PARAMETER`，同步读取写入失败的 `last_load_result`，异步接口返回 `ERR_INVALID_PARAMETER` 并发出对应失败完成信号。

### 📘 升级指南 (Migration Guide)
- 如果项目曾误传空字符串给 `save_data()` / `load_data()` 并依赖 `_invalid_storage_file` 兜底文件，需要改为在项目层传入明确文件名。
- 使用 `register_migration()` 时请保证旧版本到当前 `save_version` 的迁移链完整；如果只想用默认值补齐字段，不注册迁移步骤即可继续走默认迁移路径。
- 如果事件回调方法声明了额外必填参数，请改成默认参数或使用 `Callable(...).bind(...)` 绑定额外参数。
- 如果项目有意依赖纯代码状态机启动时不发 `state_changed`，请改为 `start(initial_state_name, msg, false)`；推荐新代码保留默认通知行为。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_type_event_system.gd`
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_input_mapping_utility.gd`
- `addons/gf/extensions/network/gf_network_reconnect_policy.gd`
- `addons/gf/foundation/validation/gf_result_utility.gd`
- `addons/gf/foundation/variant/gf_variant_utility.gd`
- `addons/gf/foundation/math/gf_weighted_entry.gd`
- `addons/gf/foundation/math/gf_weighted_table.gd`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`

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
