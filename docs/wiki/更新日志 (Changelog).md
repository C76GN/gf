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

本页面只保留最近三个大版本线的更新记录，当前保留 `1.29.x`、`1.28.x` 与 `1.27.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [1.29.0] - 2026-05-08

**版本概述**：增强纯代码状态机与节点状态机的通用性，补齐分层状态路径、事件分发、守卫和运行时快照能力。

### 🚀 新增特性 (Added)
- `GFStateMachine` 支持通过 `parent_state_name` 注册父子状态路径，并按最近公共祖先执行分层状态切换。
- `GFStateMachine` 新增进入/退出守卫、状态事件上抛、共享黑板、激活路径查询和调试快照。
- `GFNodeStateMachine` / `GFNodeStateGroup` / `GFNodeState` 新增状态事件分发、处理信号和运行时状态快照。

### 🔄 机制更改 (Changed)
- `GFStateMachine.update(delta)` 默认仍只更新当前叶子状态；传入 `include_ancestors = true` 时可按 root -> leaf 顺序更新整条激活路径。
- `GFNodeStateGroup` 的状态事件会先交给当前状态，再交给暂停栈中的状态，便于覆盖式状态把未处理事件交回下层状态。

### 🐛 Bug 修复 (Fixed)
- `GFCapabilityUtility.get_capability()` 会在查询时同步扫描 receiver 直属 GF 能力容器，修复旧场景或 Inspector 创建的 `GFCapabilityContainer2D` / `3D` / `Control` 仅保留容器标记或命名时，子能力在 receiver `_ready()` 中无法查询的问题。

### 🔌 API 变动说明 (API Changes)
- `GFStateMachine.add_state(state_name, state, parent_state_name = &"")` 新增可选父状态参数，旧二参调用保持兼容。
- 新增 `GFStateMachine.transition_blocked`、`state_event_handled`、`blackboard`、`set_state_parent()`、`dispatch_state_event()`、`get_state()`、`get_current_state()`、`has_state()`、`get_state_names()`、`get_parent_state_name()`、`get_active_state_path()`、`is_in_state()`、`get_blackboard()` 与 `get_state_snapshot()`。
- `GFStateMachine.update(delta, include_ancestors = false)` 新增可选参数，旧一参调用保持兼容。
- `GFState.setup(machine, state_name = &"")` 新增可选注册名参数；新增 `get_state_name()`、`can_enter()`、`can_exit()`、`handle_state_event()`、`dispatch_state_event()`、`get_parent_state_name()`、`is_in_state()` 与 `get_blackboard()`。
- 新增 `GFNodeState.handle_state_event()` 与 `_handle_state_event()`。
- 新增 `GFNodeStateGroup.state_event_handled`、`dispatch_state_event()` 与 `get_state_snapshot()`。
- 新增 `GFNodeStateMachine.state_event_handled`、`dispatch_state_event()` 与 `get_state_snapshot()`。

### 📘 升级指南 (Migration Guide)
- 旧状态机代码无需迁移；平铺状态注册和 `update(delta)` 的默认行为保持不变。
- 需要真正分层语义时，为子状态注册 `parent_state_name`，并把跨多个子状态共享的逻辑放入父状态的 `enter()` / `exit()` / `handle_state_event()`。
- 节点状态事件只负责分发和处理结果，不规定输入、动画、权限或业务效果；这些仍应由项目层状态脚本决定。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/extensions/state_machine/gf_state.gd`
- `addons/gf/extensions/state_machine/gf_node_state_machine.gd`
- `addons/gf/extensions/state_machine/gf_node_state_group.gd`
- `addons/gf/extensions/state_machine/gf_node_state.gd`
- `tests/gf_core/test_gf_state_machine.gd`
- `tests/gf_core/test_gf_node_state_machine.gd`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`

---

## [1.28.0] - 2026-05-08

**版本概述**：新增构建信息、交互收发、FlowGraph 视图模型与 3D 力场抽象，并增强场景切换参数、历史与过渡时长控制。

### 🚀 新增特性 (Added)
- 新增 `GFBuildInfo` 与 `GFBuildInfoUtility`，用于统一采集项目版本、GF 版本、构建号、提交号、分支、构建时间、Godot 版本、平台和自定义构建元数据。
- 新增 `GFInteractionSensor` 与 `GFInteractionReceiver`，提供通用交互上下文发送、接收、交互 ID 过滤、自定义校验和统一结果报告。
- 新增 `GFFlowGraphEditorModel`，把流程图节点、端口索引、连接端口索引、分组和校验结果整理为项目 GraphEdit 或调试面板可消费的视图模型。
- 新增 `GFGravityField3D` 与 `GFGravityProbe3D`，提供通用 3D 加速度场、衰减采样和上下方向计算。

### 🔄 机制更改 (Changed)
- `GFSceneUtility` 支持切换参数、场景历史、返回上一场景和 loading scene 最短显示时长；`GFSceneTransitionConfig` 可资源化携带 `params` 与 `minimum_duration_seconds`。
- `GFDiagnosticsUtility.collect_snapshot()` 新增 `build` 字段，并会把已注册 `GFBuildInfoUtility` 的调试快照聚合到 `tools.build_info`。

### 🐛 Bug 修复 (Fixed)
- 修复已摆放在 `GFCapabilityContainer2D` / `GFCapabilityContainer3D` / `GFCapabilityContainerControl` 下的子能力，在容器进树同步注册时可能被误判为需要迁移到新容器，导致能力无法立即查询或触发 Godot children setup 阶段 `add_child()` 报错的问题。
- 修复能力容器随 receiver 退出树时，注销子能力可能在 busy parent 上 `remove_child()` 的边界问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFSceneTransitionConfig.params: Dictionary`。
- 新增 `GFSceneTransitionConfig.minimum_duration_seconds: float`。
- `GFSceneUtility.load_scene_async(path, loading_scene_path = "", params = {}, minimum_duration_seconds = -1.0)` 新增可选参数，旧的二参调用保持兼容。
- 新增 `GFSceneUtility.default_transition_minimum_seconds: float`、`max_scene_history: int`、`get_current_scene_params()`、`get_scene_history()`、`clear_scene_history()`、`pop_scene_history()` 与 `load_previous_scene()`。
- `GFDiagnosticsUtility.collect_snapshot()` 返回值新增 `build` 字段。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移；新增 API 均为向后兼容。需要传递入口参数时优先使用 `params`，不要把项目业务字段写进框架子类。
- `GFBuildInfoUtility` 需要项目主动注册才会保存稳定副本；未注册时诊断快照会即时采集当前环境信息。
- `GFInteractionSensor` / `GFInteractionReceiver` 只处理上下文和报告，碰撞范围、输入触发、冷却、权限和效果结算仍由项目层实现。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_build_info.gd`
- `addons/gf/utilities/gf_build_info_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_scene_transition_config.gd`
- `addons/gf/utilities/gf_diagnostics_utility.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/extensions/interaction/gf_interaction_sensor.gd`
- `addons/gf/extensions/interaction/gf_interaction_receiver.gd`
- `addons/gf/extensions/flow/gf_flow_graph_editor_model.gd`
- `addons/gf/extensions/physics/gf_gravity_field_3d.gd`
- `addons/gf/extensions/physics/gf_gravity_probe_3d.gd`
- `tests/gf_core/**`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/12. 能力组件 (Capabilities).md`

---

## [1.27.1] - 2026-05-08

**版本概述**：修复能力容器运行时注册时机与 GF 编辑器 Inspector 的可见性、属性显示和状态机下拉框占位实例报错。

### 🔄 机制更改 (Changed)
- `GFCapabilityContainer` 进入场景树时会先同步扫描子节点能力，再保留一次延迟扫描兜底，使随场景摆放的 `GFNodeCapability` 可在宿主 `_ready()` 或状态 `_enter()` 中被立即查询。
- GF Capabilities Inspector 通过“添加”创建的能力容器与能力节点现在作为可见场景节点加入场景树；内联属性区域只展示能力脚本自身导出变量，并补充属性标签。

### 🐛 Bug 修复 (Fixed)
- 修复 `GFNodeStateMachine` Inspector 枚举直接子状态时对非 `@tool` 状态脚本占位实例调用 `get_state_name()`，导致编辑器输出报错的问题。

### 🔌 API 变动说明 (API Changes)
- 无公开 API 签名变化。

### 📘 升级指南 (Migration Guide)
- 已用旧版 Inspector 添加出的 internal 能力节点仍会被识别；新添加的能力会在场景树中可见，便于手动检查、重命名与保存。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/extensions/capability/gf_capability_container.gd`
- `addons/gf/editor/gf_capability_inspector_plugin.gd`
- `addons/gf/editor/gf_node_state_machine_inspector_plugin.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_node_state_machine.gd`
- `docs/wiki/12. 能力组件 (Capabilities).md`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`

## [1.27.0] - 2026-05-08

**版本概述**：修复输入上下文优先级、存档图错误传播、槽位索引、分析队列回灌、本地多人设备映射、网络通道、远程缓存、能力组件、任务与关卡流程中的边界问题，并补充若干兼容型诊断和玩法辅助 API。

### 🚀 新增特性 (Added)
- **结构化槽位读取结果**：`GFStorageUtility` 新增 `load_slot_result()` 与 `load_slot_meta_result()`，用于区分合法空字典、缺失文件、非法槽位和解码失败。
- **异步存档收敛入口**：`GFStorageUtility.wait_for_async_tasks()` 可等待已入队和正在执行的异步纯数据任务完成，便于同一路径混合同步/异步读写前主动收敛顺序。
- **JSON 数字归一化开关**：`GFStorageUtility` 与 `GFStorageCodec` 新增 `normalize_json_numbers`，默认保持旧的 JSON float 到 int 归一化语义，需要类型保真时可关闭。
- **触屏 index 精确匹配**：`GFInputBinding.match_touch_index` 可让 `InputEventScreenTouch.index` 参与匹配，默认关闭以保留任意触摸兼容语义。
- **Flow 超时时间缩放**：`GFFlowRunner` 新增 `signal_timeout_respects_time_scale`，`with_signal_timeout()` 新增可选 `respect_time_scale` 参数，与 Action / Sequence 的 Signal 等待语义对齐。
- **Tween 步骤校验**：`GFTweenActionStep` 新增 `can_apply_to()` 与 `get_validation_error()`，可在执行前检查目标属性和相对值类型。
- **网络消息通道元信息**：`GFNetworkMessage` 新增 `channel_id`，`GFNetworkUtility.send_message_on_channel()` 会在发送副本中写入逻辑通道，入站校验可按通道应用包体上限。
- **远程缓存队列控制**：`GFRemoteCacheUtility` 新增 `max_pending_requests`、`cache_key_builder`、`cancel()` 与 `cancel_all()`，并支持同缓存 key 请求合并。
- **战斗运行时移除 API**：`GFCombatSystem` 新增 `remove_buff()`、`clear_buffs()` 与 `remove_skill()`，便于项目层驱散 Buff 或取消技能驱动。
- **任务与关卡严格边界**：`GFQuestUtility` 新增 `allow_negative_progress`；`GFLevelUtility` 新增 `fail_on_missing_level_data`。
- **导表严格转换报告**：`GFConfigTableColumn` 新增 `try_coerce_value()`，`GFConfigTableSchema` 新增 `fail_on_coerce_error` 与 `require_unique_id`，用于把坏数据转换失败和重复 ID 纳入校验报告。
- **控制台命令安全边界**：`GFConsoleUtility` 新增命令风险等级、`max_command_tier`、`require_danger_confirmation` 与 `max_history_size`。
- **编辑器工具安全选项**：`GFEditorValueField` 新增 `value_parse_failed`，`GFResourceTableEditor` 新增 `auto_save_committed_resources` 与 `resource_save_failed`，`GFAccessGenerator` 新增禁止覆盖参数，`GFThumbnailRenderer` 新增批量预览取消开关。

### 🔄 机制更改 (Changed)
- 同一 `action_id` 出现在多个启用的输入上下文时，动作定义、Mapping 级修饰器和触发器现在按上下文处理顺序采用第一个定义，避免低优先级上下文反向覆盖高优先级上下文。
- `GFInputDeviceUtility.set_assignment()` 现在受 `max_players` 约束，并会把同一物理设备从旧玩家席位移动到新玩家席位；已登记手柄的活跃玩家切换使用新的 `active_player_axis_threshold` 过滤摇杆漂移。
- `GFAnalyticsConfig.build_headers()` 会忽略空 Header 名和包含 CR/LF 的 Header 键值。
- `GFTweenActionStep.append_to_tween()` / `apply_instant()` 遇到无效目标属性或不兼容相对值时会跳过步骤并发出警告。
- `GFNetworkUtility.host()` / `connect_to_endpoint()` 会先准备会话状态再调用后端，避免后端立即发出 connected 时会话 peer 信息仍为默认值。
- `GFRemoteCacheUtility` 的缓存 key 现在包含 URL、请求格式与 headers；JSON 响应会先解析成功再写入缓存，解析失败时不会污染 TTL 缓存。
- `GFCapabilityUtility` 会拒绝同一能力实例挂载到多个 receiver，反向查询会过滤失效能力实例；自动生成的空能力容器会在最后一个 Node 能力移除后释放。
- `GFCapabilityContainer` 离开场景树时会注销此前注册的子能力。
- `GFCapabilityUtility.set_capability_active()` 重新启用 Node 能力时，会保留停用期间项目层手动改过的 `process_mode`。
- `GFQuestUtility` 默认忽略负数进度 payload，并拒绝空 `quest_id` 或空 `target_event`。
- `GFLevelUtility` 的开始/重开信号现在发出关卡数据副本，避免监听者污染内部 `current_level_data`。
- `GFSkill.execute(manual_target)` 在手动目标未通过 targeting rule 校验时不再以空目标执行，即使 `max_count <= 0` 表示不截断目标。
- `GFBuff` 使用旧 `source_id` / `source_tag` 作为目标属性兼容回退时会输出迁移 warning。
- `GFConsoleUtility.debug_only` 默认改为 `true`，发布构建需要显式关闭该选项才会创建开发者控制台；命令参数解析现在支持引号和反斜杠转义。
- `GFNotificationUtility` 显式 key 去重时只按 key 匹配，无 key 时才按消息文本匹配；`max_queue_size = 0` 现在表示不保留等待队列。
- `GFConfigProvider.get_schema()` 现在返回 schema 副本，避免调用方修改 Provider 内部校验规则；CSV 导入会去掉 UTF-8 BOM 并默认拒绝重复表头。
- `GFEditorTypeIndex.collect_scene_roots_extending()` 可传入 root path 过滤场景扫描；`GFThumbnailRenderer` 会把渲染尺寸钳制到至少 1 像素。

### 🐛 Bug 修复 (Fixed)
- 修复 `GFInputMappingUtility` 中低优先级重复 `action_id` 会覆盖高优先级动作修饰器、触发器和动作定义的问题。
- 修复 `GFSaveGraphUtility.gather_scope()` 在子 Scope 采集失败时静默跳过子树、生成部分存档的问题；错误现在会传播到父 Scope 并写入 `GFSavePipelineContext`。
- 修复 `GFStorageUtility.save_slot(-1)` 会写出不可被 `list_slots()` 枚举的负数槽位文件的问题。
- 修复 `GFSaveSlotCard.configure_from_slot_summary()` 把 `"slot_3"` 这类字符串 `slot_id` 解析成错误整数索引的问题。
- 修复 `GFAnalyticsUtility` flush 失败回灌批次后可能超过 `max_queue_size` 的问题。
- 修复 `GFInputDeviceUtility` 已分配手柄的微弱轴漂移会切换 `active_player_index` 的问题。
- 修复手柄断连时若存在重复映射只移除第一条的问题。
- 修复按 `send_message_on_channel()` 发送的消息在入站侧无法可靠匹配原通道，导致通道级包体上限可能失效的问题。
- 修复 `GFRemoteCacheUtility.fetch_json()` 在 HTTP 成功但 JSON 无效时仍写入坏缓存的问题。
- 修复同一 `GFCapability` / `GFNodeCapability` 实例可被挂载到多个 receiver 造成 receiver 状态串线的问题。
- 修复 `GFCapabilityContainer` 被移除但 receiver 仍存活时能力索引可能残留的问题。
- 修复 `GFQuestUtility` 默认允许负数进度 payload 导致任务进度倒退的问题。
- 修复 `GFLevelUtility.level_started` / `level_restarted` 信号暴露内部 Dictionary 引用的问题。
- 修复手动目标技能在目标校验失败且 `max_count <= 0` 时仍可能执行空目标的问题。
- 修复 `GFFormula.calculate_float()` 遇到非法数字字符串时静默返回 `0.0` 而不是 fallback 的问题。
- 修复 `GFGridOccupancy.prune_invalid_receivers()` 清理失效对象占用时不会发出 `cell_released` 的问题。
- 修复 `GFSeedUtility` 直接 `new()` 后未手动 `init()` 调用公共方法会空引用的问题。
- 修复 `GFEditorValueField` Array/Dictionary 输入 JSON 解析失败时会静默提交空容器的问题。
- 修复 `GFConsoleUtility` 日志 BBCode 未转义和负数日志等级索引异常语义的问题。
- 修复 GF 编辑器脚本模板生成会直接覆盖已有文件的问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFStorageUtility.load_slot_result(slot_id: int) -> Dictionary`。
- 新增 `GFStorageUtility.load_slot_meta_result(slot_id: int) -> Dictionary`。
- 新增 `GFStorageUtility.wait_for_async_tasks() -> void`。
- 新增 `GFStorageUtility.normalize_json_numbers: bool`。
- 新增 `GFStorageCodec.normalize_json_numbers: bool`。
- 新增 `GFInputBinding.match_touch_index: bool`。
- 新增 `GFInputDeviceUtility.active_player_axis_threshold: float`。
- 新增 `GFFlowRunner.signal_timeout_respects_time_scale: bool`。
- `GFFlowRunner.with_signal_timeout(seconds: float, respect_time_scale: bool = true) -> GFFlowRunner` 新增可选参数，旧的一参调用保持兼容。
- 新增 `GFTweenActionStep.can_apply_to(target: Object) -> bool`。
- 新增 `GFTweenActionStep.get_validation_error(target: Object) -> String`。
- 新增 `GFNetworkMessage.channel_id: StringName`。
- 新增 `GFRemoteCacheUtility.max_pending_requests: int`。
- 新增 `GFRemoteCacheUtility.cache_key_builder: Callable`。
- `GFRemoteCacheUtility.has_valid_cache(url, ttl_seconds, headers, format)` 新增可选参数，旧的一参/两参调用保持兼容。
- `GFRemoteCacheUtility.get_cached_text(url, ttl_seconds, headers)` 新增可选参数，旧调用保持兼容。
- `GFRemoteCacheUtility.remove_cache(url, headers, format)` 新增可选参数，旧调用保持兼容。
- 新增 `GFRemoteCacheUtility.cancel(url, headers, format) -> int`。
- 新增 `GFRemoteCacheUtility.cancel_all() -> int`。
- 新增 `GFCombatSystem.remove_buff(p_entity: Object, p_buff_id: StringName) -> bool`。
- 新增 `GFCombatSystem.clear_buffs(p_entity: Object, predicate: Callable = Callable()) -> int`。
- 新增 `GFCombatSystem.remove_skill(p_entity: Object, p_skill: GFSkill) -> bool`。
- 新增 `GFQuestUtility.allow_negative_progress: bool`。
- 新增 `GFLevelUtility.fail_on_missing_level_data: bool`。
- 新增 `GFConfigTableColumn.try_coerce_value(value: Variant) -> Dictionary`。
- 新增 `GFConfigTableSchema.fail_on_coerce_error: bool`。
- 新增 `GFConfigTableSchema.require_unique_id: bool`。
- 新增 `GFConsoleUtility.CommandTier`、`GFConsoleUtility.max_command_tier`、`GFConsoleUtility.require_danger_confirmation` 与 `GFConsoleUtility.max_history_size`。
- `GFConsoleUtility.debug_only` 默认值从 `false` 改为 `true`。
- 新增 `GFEditorValueField.value_parse_failed(text: String, error_message: String)`。
- 新增 `GFResourceTableEditor.auto_save_committed_resources: bool` 与 `resource_save_failed(resource: Resource, path: String, error: Error)`。
- `GFAccessGenerator.generate()`、`generate_project_access()` 与 `save_source()` 新增可选 `overwrite_existing` 参数，旧调用保持兼容。
- `GFEditorTypeIndex.collect_scene_roots_extending()` 新增可选 `root_paths` 参数，旧调用保持兼容。
- 新增 `GFThumbnailRenderer.cancel_preview_generation: bool`。

### 📘 升级指南 (Migration Guide)
- 旧项目通常不需要迁移；新增 API 均保持默认兼容语义。
- 如果项目曾依赖负数 `slot_id` 写入隐藏槽位，应改用项目自己的文件名或逻辑 `slot_id` 映射，不再通过 `GFStorageUtility.save_slot()` 写负数整数槽。
- 如果项目手动把同一键鼠、触控、手柄或自定义设备分配给多个玩家，升级后应改为不同 `device_id` 或使用 `DeviceType.AI` 与负数设备 ID 表示虚拟席位。
- 如果项目希望 Flow Signal 超时不受暂停和 time_scale 影响，调用 `runner.with_signal_timeout(seconds, false)` 或设置 `signal_timeout_respects_time_scale = false`。
- 如果项目依赖 `GFRemoteCacheUtility` 同 URL 在 text/json 或不同 headers 间共享缓存，应改用 `cache_key_builder` 显式定义兼容 key；默认行为会按格式和 headers 隔离缓存。
- 如果项目确实需要任务进度扣减，设置 `GFQuestUtility.allow_negative_progress = true`；默认负数 amount 会被忽略。
- 如果项目希望缺失关卡 ID 仍按空数据启动，保持 `GFLevelUtility.fail_on_missing_level_data = false`；正式环境建议开启严格模式。
- 新代码应显式填写 `GFModifier.attribute_id`；旧的 `source_id` / `source_tag` 目标属性回退仍可用，但会输出 warning。
- 如果项目在发布构建中确实需要 `GFConsoleUtility`，现在必须显式设置 `debug_only = false`，并建议用命令 `tier`、`max_command_tier` 和 `--confirm` 限制高风险指令。
- 如果项目曾依赖 `GFConfigTableSchema.coerce_values` 把非法数据静默转为 `0`、`ZERO` 或 `WHITE` 后通过校验，应清理导表数据，或临时设置 `fail_on_coerce_error = false` 保留旧式宽松导入。
- 如果项目工具需要反复覆盖访问器生成文件，可以继续使用默认 `overwrite_existing = true`；模板生成现在会拒绝覆盖已有脚本，请改选新路径或先手动删除旧文件。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/input/gf_input_binding.gd`
- `addons/gf/utilities/gf_input_mapping_utility.gd`
- `addons/gf/utilities/gf_input_device_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_storage_codec.gd`
- `addons/gf/utilities/gf_analytics_utility.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/extensions/save/gf_save_slot_card.gd`
- `addons/gf/extensions/flow/gf_flow_runner.gd`
- `addons/gf/extensions/action_queue/gf_tween_action_step.gd`
- `addons/gf/extensions/network/**`
- `addons/gf/extensions/capability/**`
- `addons/gf/extensions/combat/**`
- `addons/gf/utilities/gf_remote_cache_utility.gd`
- `addons/gf/utilities/gf_quest_utility.gd`
- `addons/gf/utilities/gf_level_utility.gd`
- `addons/gf/foundation/formula/gf_formula.gd`
- `addons/gf/foundation/math/gf_grid_occupancy.gd`
- `addons/gf/utilities/gf_config_table_column.gd`
- `addons/gf/utilities/gf_config_table_schema.gd`
- `addons/gf/utilities/gf_config_table_importer.gd`
- `addons/gf/utilities/gf_config_provider.gd`
- `addons/gf/utilities/gf_seed_utility.gd`
- `addons/gf/utilities/gf_notification_utility.gd`
- `addons/gf/utilities/gf_console_utility.gd`
- `addons/gf/editor/gf_editor_value_field.gd`
- `addons/gf/editor/gf_resource_table_editor.gd`
- `addons/gf/editor/gf_access_generator.gd`
- `addons/gf/editor/gf_editor_type_index.gd`
- `addons/gf/editor/gf_thumbnail_renderer.gd`
- `addons/gf/plugin.gd`
- `tests/gf_core/**`
- `docs/wiki/01. 架构概览 (Architecture).md`
- `docs/wiki/11. 基础层 (Foundation Layer).md`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/10. 战斗扩展 (Combat Extension).md`
- `docs/wiki/12. 能力组件 (Capabilities).md`

---
