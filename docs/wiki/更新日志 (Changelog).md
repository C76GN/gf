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

本页面只保留最近三个大版本线的更新记录，当前保留 `1.27.x`、`1.26.x` 与 `1.25.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

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

## [1.26.0] - 2026-05-08

**版本概述**：补齐通用导表校验、文件下载、运行时工具快照与开发期资源表格能力，保持框架抽象边界，不引入具体业务规则。

### 🚀 新增特性 (Added)
- **导表结构声明与导入校验**：新增 `GFConfigTableColumn`、`GFConfigTableSchema` 与 `GFConfigTableImporter`，支持 JSON/CSV 解析、字段类型校验、必填/空值检查、默认值转换和统一 issue 报告。
- **ConfigProvider Schema 注册**：`GFConfigProvider` 新增 schema 注册、查询、校验和记录转换入口，子类仍可保持原有 `get_record()` / `get_table()` 适配方式。
- **通用文件下载队列**：新增 `GFDownloadTask` 与 `GFDownloadUtility`，支持顺序下载、临时文件提交、可选续传、SHA-256 校验、暂停、取消、结果缓存和诊断快照。
- **定时器调度增强**：`GFTimerUtility` 新增重复任务、owner 绑定任务、owner 批量取消和 debug snapshot。
- **运行时工具快照**：`GFAssetUtility`、`GFRemoteCacheUtility`、`GFActionQueueSystem` 新增 `get_debug_snapshot()`，`GFDiagnosticsUtility` 新增工具快照聚合、`diagnostics.tools` 命令和 `tools` 监控预设。
- **事件系统派发统计**：`TypeEventSystem.get_debug_stats()` 新增派发次数、当前派发深度和历史最大嵌套深度。
- **开发期资源表格控件**：新增 `GFEditorValueField` 与 `GFResourceTableEditor`，用于通用 Resource 属性输入、扫描、列推导和单元格提交。

### 🔄 机制更改 (Changed)
- `GFTimerUtility.cancel()` 现在可在重复任务回调执行期间取消当前句柄，避免回调结束后再次排入队列。
- `GFDiagnosticsUtility.collect_snapshot()` 的结果新增 `tools` 字段；未注册对应工具时自动跳过，不影响旧调用。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFConfigTableColumn`、`GFConfigTableSchema`、`GFConfigTableImporter`。
- 新增 `GFDownloadTask`、`GFDownloadUtility`。
- 新增 `GFEditorValueField`、`GFResourceTableEditor`。
- `GFConfigProvider` 新增 `register_schema()`、`unregister_schema()`、`has_schema()`、`get_schema()`、`get_schema_ids()`、`validate_record()`、`validate_table()` 与 `coerce_record()`。
- `GFTimerUtility` 新增 `execute_after_owned()`、`execute_repeating()`、`execute_repeating_owned()`、`cancel_owner()` 与 `get_debug_snapshot()`。
- `GFDiagnosticsUtility` 新增内置命令 `diagnostics.tools`，`collect_snapshot()` 返回值新增 `tools` 字段，内置监控预设新增 `tools`。
- `GFAssetUtility`、`GFRemoteCacheUtility`、`GFActionQueueSystem` 新增 `get_debug_snapshot()`。
- `TypeEventSystem.get_debug_stats()` 返回值新增派发统计字段。

### 📘 升级指南 (Migration Guide)
- 旧项目不需要迁移；所有新增能力均为向后兼容 API。需要导表校验时，先用 `GFConfigTableSchema` 描述结构，再在现有 `GFConfigProvider` 子类初始化阶段注册 schema。
- 需要下载文件时优先使用 `GFDownloadUtility`；只拉取远程文本或 JSON 并复用 TTL 缓存时继续使用 `GFRemoteCacheUtility`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_config_provider.gd`
- `addons/gf/utilities/gf_timer_utility.gd`
- `addons/gf/utilities/gf_diagnostics_utility.gd`
- `addons/gf/utilities/gf_download_utility.gd`
- `addons/gf/editor/gf_resource_table_editor.gd`
- `tests/gf_core/**`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`

---

## [1.25.0] - 2026-05-08

**版本概述**：增强运行时调试、日志、本地多人输入、场景切换、存档图健康检查、流程图编辑器辅助、能力组合与开发期维护基础设施，在保持旧调用兼容的前提下，为常用框架能力补充更通用的验证、监控和组合入口。

### 🚀 新增特性 (Added)
- **结构化日志上下文**：`GFLogUtility` 各等级日志方法和 `log()` 可附加 `Dictionary` 上下文，日志条目会保留 `context`、`level_name`、`text`、时间戳等结构化字段。
- **日志 Sink 扩展点**：新增 `GFLogSink` 基类，项目可通过 `add_sink()` 接入 JSONL、编辑器面板、本地诊断或其他自定义采集目标。
- **JSONL 日志 Sink**：新增 `GFJsonLineLogSink`，可把结构化日志条目写入一行一个 JSON 对象的本地文件，便于测试、诊断工具和离线分析读取。
- **结构化日志信号**：`GFLogUtility` 新增 `log_entry_emitted(entry)`，在保留 `log_emitted(level, tag, message)` 的同时广播完整条目。
- **控制台窗口模式**：`GFConsoleUtility` 新增可配置窗口模式，支持拖拽、缩放、背景透明度、初始尺寸比例、最小尺寸、层级和 debug-only 创建策略。
- **调试覆盖层 Watch**：`GFDebugOverlayUtility` 新增通用运行时 watch API，可显示项目主动推送或由 provider 拉取的小型调试值，不要求这些值进入 `GFModel`。
- **诊断监控注册表**：`GFDiagnosticsUtility` 新增 monitor / preset 机制，可采集内置性能、架构和项目自定义监控项，并导出 JSON、文本或 CSV。
- **存档图健康报告**：`GFSaveGraphUtility.inspect_scope()` 与 `validate_payload_for_scope()` 报告新增健康摘要、错误/警告计数、issue 统计和 `next_action`，并提供 `build_scope_health_report()` / `build_payload_health_report()` 语义入口。
- **场景缓存分层与 Loading 协议**：`GFSceneUtility` 支持固定预加载缓存、场景资源信息快照、加载进度查询、切换流程信号和 loading scene 可选 `fade_in` / `fade_out` / `set_progress` / `update_progress` 协议。
- **流程图编辑器辅助**：`GFFlowNode` 新增显示名、分类和编辑器布局元数据，`GFFlowGraph` 新增编辑器目录、编辑器报告和 Inspector 校验辅助。
- **能力组合 Recipe**：新增 `GFCapabilityRecipe` 与 `GFCapabilityRecipeEntry`，`GFCapabilityUtility` 可按 Recipe 批量应用或移除能力和分组。
- **输入配置 Profile Bank**：新增 `GFInputProfileBank`，用于保存、切换和复制多个命名 `GFInputRemapConfig`，不绑定账号、UI、存档槽或玩家业务语义。
- **本地加入输入与手柄反馈**：`GFInputDeviceUtility` 新增 join 输入模板、玩家加入请求信号，以及按玩家席位转发手柄震动的薄封装。
- **场景信号连接审计**：新增 `GFSceneSignalAudit`，可在开发期扫描 `.tscn` 中保存的编辑器信号连接，报告缺失节点、缺失信号、缺失方法和参数数量不匹配。

### 🔄 机制更改 (Changed)
- **日志输出链路统一**：低于 `min_level` 或被 tag 静音的日志不会写文件、进入内存缓存、写入 sink 或发出日志信号；`*_lazy()` 现在也会延迟构造可选上下文。
- **控制台默认兼容**：`GFConsoleUtility.windowed` 默认仍为 `false`，保持原全屏覆盖行为；只有显式启用时才使用窗口面板。
- **输入扩展保持 opt-in**：join 输入默认不启用，只有项目填充 `join_events` 或调用 `configure_default_join_events()` 后才会响应加入请求。
- **Debug Overlay 可消费诊断预设**：注册 `GFDiagnosticsUtility` 时，Debug Overlay 默认合并显示 `overlay` 监控预设；项目可切换预设或关闭该行为。
- **表面材质查询轻量化**：`GFSurfaceUtility` 优先从 Mesh surface arrays 统计面数，减少材质查询前的几何分析开销，并保留兼容回退路径。

### 🐛 Bug 修复 (Fixed)
- **Debug Overlay 兼容性**：改用内部 BBCode 转义逻辑，避免 Godot 4.6 中缺失 `String.escape_bbcode()` 导致脚本解析失败，并在释放时先停用 overlay 回调，避免销毁期间访问已释放架构。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFLogSink`。
- 新增 `GFJsonLineLogSink`。
- 新增 `GFInputProfileBank`。
- 新增 `GFSceneSignalAudit`。
- 新增 `GFCapabilityRecipe`。
- 新增 `GFCapabilityRecipeEntry`。
- `GFJsonLineLogSink` 提供 `file_path`、`omit_formatted_text`、`flush_interval_msec`、`flush_immediately`、`max_jsonl_files` 与 `get_file_path()`。
- `GFInputProfileBank` 提供 `set_profile()`、`ensure_profile()`、`get_profile()`、`has_profile()`、`remove_profile()`、`get_profile_ids()`、`clear_profiles()`、`set_active_profile()`、`get_active_profile()` 与 `duplicate_bank()`。
- `GFSceneSignalAudit` 提供 `audit_directory()`、`audit_scene_paths()`、`audit_scene()` 与 `collect_scene_paths()`。
- 新增 `GFLogUtility.log_entry_emitted(entry: Dictionary)`。
- 新增 `GFLogUtility.add_sink(sink)`、`remove_sink(sink, shutdown := true)`、`clear_sinks(shutdown := true)`、`get_sinks()`、`flush_sinks()`、`get_log_file_path()`。
- `GFLogUtility.debug/info/warn/error/fatal/log()` 新增可选 `context: Dictionary = {}` 参数；旧调用保持可用。
- `GFLogUtility.*_lazy()` 新增可选 `context_builder: Callable = Callable()` 参数；旧调用保持可用。
- 新增 `GFConsoleUtility.background_alpha`、`windowed`、`initial_window_size_ratio`、`minimum_window_size`、`keep_topmost`、`debug_only`。
- 新增 `GFDebugOverlayUtility.watch_value()`、`push_watch_value()`、`remove_watch()`、`clear_watches()`、`has_watch()` 与 `get_watch_snapshot()`。
- 新增 `GFDebugOverlayUtility.include_diagnostics_monitors`、`diagnostics_monitor_preset` 与 `set_diagnostics_monitor_preset()`。
- 新增 `GFDiagnosticsUtility.monitor_sampled`、`register_monitor()`、`unregister_monitor()`、`has_monitor()`、`get_monitor_catalog()`、`register_monitor_preset()`、`unregister_monitor_preset()`、`has_monitor_preset()`、`get_monitor_preset_ids()`、`collect_monitor_snapshot()`、`collect_monitor_preset()` 与 `export_monitor_snapshot()`。
- 新增 `GFSaveGraphUtility.build_scope_health_report()` 与 `build_payload_health_report()`；`inspect_scope()` / `validate_payload_for_scope()` 返回值新增 `healthy`、`error_count`、`warning_count`、`issue_counts_by_kind`、`summary`、`next_action`。
- 新增 `GFSceneUtility.scene_switch_started`、`scene_switch_completed`、`scene_switch_failed`、`loading_scene_shown`、`loading_scene_hidden`、`scene_cache_added`、`scene_cache_removed`。
- `GFSceneUtility.preload_scene()`、`preload_scenes()`、`put_preloaded_scene()`、`clear_preloaded_scenes()` 新增兼容可选参数；新增 `move_preloaded_scene_to_fixed()`、`move_preloaded_scene_to_temporary()`、`is_preloaded_scene_fixed()`、`get_loading_progress()` 与 `get_scene_resource_info()`。
- 新增 `GFSceneTransitionConfig.preload_as_fixed_cache`。
- 新增 `GFFlowNode.display_name`、`category`、`editor_position`、`editor_size`、`editor_collapsed`、`get_display_name()` 与 `describe_editor()`。
- 新增 `GFFlowGraph.editor_groups`、`editor_metadata`、`set_node_editor_position()`、`set_node_editor_layout()`、`get_editor_catalog()` 与 `build_editor_report()`。
- 新增 `GFCapabilityUtility.apply_recipe()` 与 `remove_recipe()`。
- 新增 `GFInputDeviceUtility.player_join_requested(player_index, assignment, event)`。
- 新增 `GFInputDeviceUtility.join_events` 与 `auto_assign_devices_on_join`。
- 新增 `GFInputDeviceUtility.handle_join_input_event()`、`is_join_input_event()`、`configure_default_join_events()`、`clear_join_events()`、`start_vibration_for_player()` 与 `stop_vibration_for_player()`。
- 无破坏性函数签名变更。

### 📘 升级指南 (Migration Guide)
1. 旧日志调用无需修改；需要结构化字段时，把上下文作为最后一个参数传入即可。
2. 自定义日志 sink 应继承 `GFLogSink`，并把 sink 视为输出目标，不要在 sink 内反向持有业务生命周期。
3. 控制台仍默认全屏；需要边运行边观察时设置 `windowed = true`，发布构建可按项目策略设置 `debug_only = true` 或不注册该工具。
4. Debug Overlay 仍会反射已注册 `GFModel`；项目只在需要观察非 Model 临时值时额外注册 watch，避免把业务字段或敏感信息默认暴露到覆盖层。
5. 需要更稳定的运行时调试面板时，优先把通用指标注册为 `GFDiagnosticsUtility` monitor，再让 Overlay、控制台或编辑器工具按预设消费；不要把一次性业务字段硬塞进框架内置 monitor。
6. 需要多套输入重映射配置时，可把现有 `GFInputRemapConfig` 放入 `GFInputProfileBank`；旧的单配置调用方式保持可用。
7. 本地多人加入流程应显式配置 join 输入模板，并在收到 `player_join_requested` 后由项目层决定 UI、角色、队伍或出生点。
8. `GFSceneSignalAudit` 和 SaveGraph 当前场景校验都是可选开发期工具，不需要注册到 `GFArchitecture`；项目可在 CI、编辑器按钮或维护脚本中按需调用。
9. 需要实体能力预设时，用 `GFCapabilityRecipe` 描述组合结构，把具体数值、目标规则和表现逻辑继续放在项目能力资源或项目系统中。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_log_sink.gd`
- `addons/gf/utilities/gf_json_line_log_sink.gd`
- `addons/gf/utilities/gf_log_utility.gd`
- `addons/gf/utilities/gf_console_utility.gd`
- `addons/gf/utilities/gf_debug_overlay_utility.gd`
- `addons/gf/utilities/gf_diagnostics_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_scene_transition_config.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/extensions/flow/gf_flow_node.gd`
- `addons/gf/extensions/flow/gf_flow_graph.gd`
- `addons/gf/extensions/capability/gf_capability_recipe.gd`
- `addons/gf/extensions/capability/gf_capability_recipe_entry.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/editor/gf_flow_graph_inspector_plugin.gd`
- `addons/gf/utilities/gf_input_device_utility.gd`
- `addons/gf/utilities/gf_surface_utility.gd`
- `addons/gf/input/gf_input_profile_bank.gd`
- `addons/gf/editor/gf_scene_signal_audit.gd`
- `tests/gf_core/test_gf_log_utility.gd`
- `tests/gf_core/test_gf_console_utility.gd`
- `tests/gf_core/test_gf_debug_overlay_utility.gd`
- `tests/gf_core/test_gf_diagnostics_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_save_graph_utility.gd`
- `tests/gf_core/test_gf_flow_graph.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_input_device_utility.gd`
- `tests/gf_core/test_gf_surface_utility.gd`
- `tests/gf_core/test_gf_input_profile_bank.gd`
- `tests/gf_core/test_gf_scene_signal_audit.gd`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/12. 能力组件 (Capabilities).md`
- `docs/wiki/01. 架构概览 (Architecture).md`
- `docs/wiki/更新日志 (Changelog).md`

---
