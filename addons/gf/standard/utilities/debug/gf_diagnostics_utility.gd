## GFDiagnosticsUtility: 运行时诊断聚合工具。
##
## 提供架构生命周期、事件系统、性能、日志和外部贡献诊断的统一快照。
## 诊断命令、监控项和快照分区通过 Callable 注册，框架只负责调度和包装结果，不解释项目业务数据。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFDiagnosticsUtility
extends GFUtility


# --- 信号 ---

## 采集快照后发出。
## [br]
## @api public
## [br]
## @param snapshot: 刚采集到的诊断快照。
## [br]
## @schema snapshot: Dictionary，包含 collect_snapshot() 返回的顶层诊断分区。
signal snapshot_collected(snapshot: Dictionary)

## 执行诊断命令后发出。
## [br]
## @api public
## [br]
## @param command_name: 已执行的诊断命令名。
## [br]
## @param result: 命令执行结果。
## [br]
## @schema result: Dictionary，包含 ok、value、error、metadata 等字段。
signal diagnostic_command_executed(command_name: StringName, result: Dictionary)

## 采样诊断监控项后发出。
## [br]
## @api public
## [br]
## @param monitor_id: 监控项标识。
## [br]
## @param sample: 采样结果。
## [br]
## @schema sample: Dictionary，包含 id、label、group、value、valid、error、metadata 和 sampled_at_unix。
signal monitor_sampled(monitor_id: StringName, sample: Dictionary)


# --- 枚举 ---

## 诊断命令风险等级。
## [br]
## @api public
enum CommandTier {
	## 只读取状态。
	OBSERVE,
	## 修改调试输入或临时过滤条件。
	INPUT,
	## 控制运行时行为。
	CONTROL,
	## 可能破坏状态、存档或远端连接。
	DANGER,
}


# --- 公共变量 ---

## 是否采集 Godot Performance 监视器。
## [br]
## @api public
var include_performance_monitors: bool = true

## 快照中默认包含的最近日志数量。
## [br]
## @api public
var default_recent_log_count: int = 20

## 当前允许执行的最高命令等级。
## [br]
## @api public
var max_command_tier: CommandTier = CommandTier.OBSERVE

## 是否要求命令参数提供 auth_token 或 _auth_token。
## [br]
## @api public
var require_auth_token: bool = false

## 诊断命令认证 token。为空时无法通过认证。
## [br]
## @api public
var auth_token: String = ""

## 是否允许执行 DANGER 等级命令。即使 max_command_tier 足够，也需要显式开启。
## [br]
## @api public
var allow_danger_commands: bool = false

## 是否把诊断命令结果转换为 JSON 兼容 Variant。
## [br]
## @api public
var encode_command_results_for_json: bool = false

## 场景树快照默认递归深度。
## [br]
## @api public
var default_scene_tree_max_depth: int = 4

## 场景树快照默认最多采集节点数。
## [br]
## @api public
var default_scene_tree_max_nodes: int = 128


# --- 私有变量 ---

var _commands: Dictionary = {}
var _disabled_commands: Dictionary = {}
var _monitors: Dictionary = {}
var _monitor_presets: Dictionary = {}
var _snapshot_section_providers: Dictionary = {}
var _tool_snapshot_providers: Dictionary = {}
var _monitor_order_counter: int = 0
var _console_utility: GFConsoleUtility = null
var _console_command_registered: bool = false


# --- GF 生命周期方法 ---

## 初始化内置诊断命令和监控项。
## [br]
## @api public
func init() -> void:
	_register_builtin_monitors()
	register_command(&"diagnostics.snapshot", Callable(self, "_command_collect_snapshot"), "采集 GF 诊断快照。", CommandTier.OBSERVE)
	register_command(&"diagnostics.performance", Callable(self, "_command_collect_performance"), "采集性能监视器快照。", CommandTier.OBSERVE)
	register_command(&"diagnostics.logs", Callable(self, "_command_collect_logs"), "读取最近日志缓存。", CommandTier.OBSERVE)
	register_command(&"diagnostics.monitors", Callable(self, "_command_collect_monitors"), "采集已注册诊断监控项。", CommandTier.OBSERVE)
	register_command(&"diagnostics.tools", Callable(self, "_command_collect_tools"), "采集已注册 GF 工具快照。", CommandTier.OBSERVE)
	register_command(&"diagnostics.scene", Callable(self, "_command_collect_scene"), "采集只读场景树快照。", CommandTier.OBSERVE)
	register_command(&"diagnostics.signals", Callable(self, "_command_collect_signals"), "采集只读信号连接图快照。", CommandTier.OBSERVE)


## 绑定控制台诊断命令。
## [br]
## @api public
func ready() -> void:
	_bind_console_command()


## 释放诊断注册表并解绑控制台命令。
## [br]
## @api public
func dispose() -> void:
	if _console_utility != null and _console_command_registered:
		_console_utility.unregister_command("diagnostics")
	_console_utility = null
	_console_command_registered = false
	_commands.clear()
	_disabled_commands.clear()
	_monitors.clear()
	_monitor_presets.clear()
	_snapshot_section_providers.clear()
	_tool_snapshot_providers.clear()
	_monitor_order_counter = 0


# --- 公共方法 ---

## 注册诊断命令。
## [br]
## @api public
## [br]
## @param command_name: 命令名。
## [br]
## @param callback: 回调，签名建议为 func(args: Dictionary) -> Variant。
## [br]
## @param description: 描述文本。
## [br]
## @param tier: 命令风险等级。
## [br]
## @param options: 可选元数据，支持 parameters、metadata、enabled。
## [br]
## @schema options: Dictionary，支持 parameters、metadata 和 enabled。
func register_command(
	command_name: StringName,
	callback: Callable,
	description: String = "",
	tier: CommandTier = CommandTier.OBSERVE,
	options: Dictionary = {}
) -> void:
	if command_name == &"" or not callback.is_valid():
		return
	_commands[command_name] = {
		"callback": callback,
		"description": description,
		"tier": tier,
		"parameters": _normalize_parameter_schema(options.get("parameters", [])),
		"metadata": (options.get("metadata", {}) as Dictionary).duplicate(true) if options.get("metadata", {}) is Dictionary else {},
	}
	if options.has("enabled"):
		set_command_enabled(command_name, bool(options.get("enabled", true)))


## 注销诊断命令。
## [br]
## @api public
## [br]
## @param command_name: 命令名。
func unregister_command(command_name: StringName) -> void:
	_commands.erase(command_name)
	_disabled_commands.erase(command_name)


## 检查诊断命令是否存在。
## [br]
## @api public
## [br]
## @param command_name: 命令名。
## [br]
## @return 存在返回 true。
func has_command(command_name: StringName) -> bool:
	return _commands.has(command_name)


## 设置诊断命令参数 schema。
## [br]
## @api public
## [br]
## @param command_name: 命令名。
## [br]
## @param parameters: 参数 schema，可为数组或按参数名索引的字典。
## [br]
## @return 设置成功返回 true。
## [br]
## @schema parameters: Variant，支持 Array[Dictionary] 或 Dictionary 形式的参数 schema。
func set_command_parameter_schema(command_name: StringName, parameters: Variant) -> bool:
	if not _commands.has(command_name):
		return false
	var entry := _commands[command_name] as Dictionary
	entry["parameters"] = _normalize_parameter_schema(parameters)
	return true


## 设置诊断命令是否启用。
## [br]
## @api public
## [br]
## @param command_name: 命令名。
## [br]
## @param enabled: 是否启用。
## [br]
## @return 命令存在时返回 true。
func set_command_enabled(command_name: StringName, enabled: bool) -> bool:
	if not _commands.has(command_name):
		return false
	if enabled:
		_disabled_commands.erase(command_name)
	else:
		_disabled_commands[command_name] = true
	return true


## 批量设置命令是否启用。
## [br]
## @api public
## [br]
## @param enabled: 是否启用。
## [br]
## @param command_names: 指定命令；为空时作用于全部已注册命令。
## [br]
## @return 实际处理的命令数量。
func set_all_commands_enabled(
	enabled: bool,
	command_names: PackedStringArray = PackedStringArray()
) -> int:
	var selected_names := command_names.duplicate()
	if selected_names.is_empty():
		for command_name: StringName in _commands.keys():
			selected_names.append(String(command_name))

	var count := 0
	for name_text: String in selected_names:
		if set_command_enabled(StringName(name_text), enabled):
			count += 1
	return count


## 检查命令是否启用。
## [br]
## @api public
## [br]
## @param command_name: 命令名。
## [br]
## @return 命令存在且启用时返回 true。
func is_command_enabled(command_name: StringName) -> bool:
	return _commands.has(command_name) and not _disabled_commands.has(command_name)


## 获取诊断命令描述。
## [br]
## @api public
## [br]
## @return 命令名到描述的字典。
## [br]
## @schema return: Dictionary[StringName, String]，以命令名为键。
func get_command_descriptions() -> Dictionary:
	var result: Dictionary = {}
	for command_name: StringName in _commands.keys():
		var entry := _commands[command_name] as Dictionary
		result[command_name] = String(entry.get("description", ""))
	return result


## 获取诊断命令目录。
## [br]
## @api public
## [br]
## @return 命令名到命令元数据的字典。
## [br]
## @schema return: Dictionary[StringName, Dictionary]，每个值包含 description、tier、tier_name、enabled、parameters 和 metadata。
func get_command_catalog() -> Dictionary:
	var result: Dictionary = {}
	for command_name: StringName in _commands.keys():
		var entry := _commands[command_name] as Dictionary
		var tier := int(entry.get("tier", CommandTier.OBSERVE))
		result[command_name] = {
			"description": String(entry.get("description", "")),
			"tier": tier,
			"tier_name": _get_tier_name(tier),
			"enabled": is_command_enabled(command_name),
			"parameters": (entry.get("parameters", []) as Array).duplicate(true) if entry.get("parameters", []) is Array else [],
			"metadata": (entry.get("metadata", {}) as Dictionary).duplicate(true) if entry.get("metadata", {}) is Dictionary else {},
		}
	return result


## 注册诊断监控项。
## [br]
## @api public
## [br]
## @param monitor_id: 监控项唯一标识。
## [br]
## @param provider: 无参数采样回调。
## [br]
## @param options: 可选元数据，支持 label、group、visible、metadata、min_interval_seconds。
## [br]
## @return 注册成功返回 true。
## [br]
## @schema options: Dictionary，支持 label、group、visible、metadata 和 min_interval_seconds。
func register_monitor(monitor_id: StringName, provider: Callable, options: Dictionary = {}) -> bool:
	if monitor_id == &"" or not provider.is_valid():
		return false

	var entry := {
		"provider": provider,
		"label": String(options.get("label", String(monitor_id))),
		"group": String(options.get("group", "Runtime")),
		"visible": bool(options.get("visible", true)),
		"metadata": (options.get("metadata", {}) as Dictionary).duplicate(true) if options.get("metadata", {}) is Dictionary else {},
		"min_interval_seconds": maxf(float(options.get("min_interval_seconds", 0.0)), 0.0),
		"order": _monitor_order_counter,
		"last_sample_time": -INF,
		"last_sample": {},
	}
	_monitor_order_counter += 1
	_monitors[monitor_id] = entry
	return true


## 注销诊断监控项。
## [br]
## @api public
## [br]
## @param monitor_id: 监控项唯一标识。
func unregister_monitor(monitor_id: StringName) -> void:
	_monitors.erase(monitor_id)
	for preset_id: StringName in _monitor_presets.keys():
		var preset := _monitor_presets[preset_id] as Dictionary
		var ids := preset.get("monitor_ids", PackedStringArray()) as PackedStringArray
		if ids.has(String(monitor_id)):
			ids.remove_at(ids.find(String(monitor_id)))


## 检查诊断监控项是否存在。
## [br]
## @api public
## [br]
## @param monitor_id: 监控项唯一标识。
## [br]
## @return 存在返回 true。
func has_monitor(monitor_id: StringName) -> bool:
	return _monitors.has(monitor_id)


## 获取诊断监控项目录。
## [br]
## @api public
## [br]
## @return 监控项元数据字典。
## [br]
## @schema return: Dictionary[StringName, Dictionary]，每个值包含 label、group、visible、metadata 和 min_interval_seconds。
func get_monitor_catalog() -> Dictionary:
	var result: Dictionary = {}
	for monitor_id: StringName in _monitors.keys():
		var entry := _monitors[monitor_id] as Dictionary
		result[monitor_id] = {
			"label": String(entry.get("label", String(monitor_id))),
			"group": String(entry.get("group", "Runtime")),
			"visible": bool(entry.get("visible", true)),
			"metadata": (entry.get("metadata", {}) as Dictionary).duplicate(true),
			"min_interval_seconds": float(entry.get("min_interval_seconds", 0.0)),
		}
	return result


## 注册诊断监控预设。
## [br]
## @api public
## [br]
## @param preset_id: 预设唯一标识。
## [br]
## @param monitor_ids: 预设包含的监控项标识。
## [br]
## @param options: 可选元数据，支持 label、metadata。
## [br]
## @return 注册成功返回 true。
## [br]
## @schema options: Dictionary，支持 label 和 metadata。
func register_monitor_preset(
	preset_id: StringName,
	monitor_ids: PackedStringArray,
	options: Dictionary = {}
) -> bool:
	if preset_id == &"":
		return false

	_monitor_presets[preset_id] = {
		"monitor_ids": monitor_ids.duplicate(),
		"label": String(options.get("label", String(preset_id))),
		"metadata": (options.get("metadata", {}) as Dictionary).duplicate(true) if options.get("metadata", {}) is Dictionary else {},
	}
	return true


## 将一个监控项追加到已有预设；预设不存在时会创建。
## [br]
## @api public
## [br]
## @param preset_id: 预设唯一标识。
## [br]
## @param monitor_id: 监控项唯一标识。
## [br]
## @return 追加成功返回 true。
func add_monitor_to_preset(preset_id: StringName, monitor_id: StringName) -> bool:
	if preset_id == &"" or monitor_id == &"":
		return false
	if not _monitor_presets.has(preset_id):
		return register_monitor_preset(preset_id, PackedStringArray([String(monitor_id)]))

	var preset := _monitor_presets[preset_id] as Dictionary
	var ids := preset.get("monitor_ids", PackedStringArray()) as PackedStringArray
	if not ids.has(String(monitor_id)):
		ids.append(String(monitor_id))
		preset["monitor_ids"] = ids
	return true


## 注销诊断监控预设。
## [br]
## @api public
## [br]
## @param preset_id: 预设唯一标识。
func unregister_monitor_preset(preset_id: StringName) -> void:
	_monitor_presets.erase(preset_id)


## 检查诊断监控预设是否存在。
## [br]
## @api public
## [br]
## @param preset_id: 预设唯一标识。
## [br]
## @return 存在返回 true。
func has_monitor_preset(preset_id: StringName) -> bool:
	return _monitor_presets.has(preset_id)


## 获取诊断监控预设列表。
## [br]
## @api public
## [br]
## @return 预设标识列表。
func get_monitor_preset_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for preset_id: StringName in _monitor_presets.keys():
		result.append(String(preset_id))
	result.sort()
	return result


## 注册快照分区 provider。用于扩展或项目把自己的诊断数据贡献到 collect_snapshot() 顶层字段。
## [br]
## @api public
## [br]
## @param section_id: 快照顶层字段名。
## [br]
## @param provider: 无参数采样回调，建议返回 Dictionary。
## [br]
## @return 注册成功返回 true。
func register_snapshot_section_provider(section_id: StringName, provider: Callable) -> bool:
	if section_id == &"" or not provider.is_valid():
		return false
	_snapshot_section_providers[section_id] = provider
	return true


## 注销快照分区 provider。
## [br]
## @api public
## [br]
## @param section_id: 快照顶层字段名。
func unregister_snapshot_section_provider(section_id: StringName) -> void:
	_snapshot_section_providers.erase(section_id)


## 检查快照分区 provider 是否存在。
## [br]
## @api public
## [br]
## @param section_id: 快照顶层字段名。
## [br]
## @return 存在返回 true。
func has_snapshot_section_provider(section_id: StringName) -> bool:
	return _snapshot_section_providers.has(section_id)


## 注册工具快照 provider。用于扩展或项目把 get_debug_snapshot() 风格数据贡献到 tools 字段。
## [br]
## @api public
## [br]
## @param tool_id: tools 内部字段名。
## [br]
## @param provider: 无参数采样回调，建议返回 Dictionary。
## [br]
## @return 注册成功返回 true。
func register_tool_snapshot_provider(tool_id: StringName, provider: Callable) -> bool:
	if tool_id == &"" or not provider.is_valid():
		return false
	_tool_snapshot_providers[tool_id] = provider
	return true


## 注销工具快照 provider。
## [br]
## @api public
## [br]
## @param tool_id: tools 内部字段名。
func unregister_tool_snapshot_provider(tool_id: StringName) -> void:
	_tool_snapshot_providers.erase(tool_id)


## 检查工具快照 provider 是否存在。
## [br]
## @api public
## [br]
## @param tool_id: tools 内部字段名。
## [br]
## @return 存在返回 true。
func has_tool_snapshot_provider(tool_id: StringName) -> bool:
	return _tool_snapshot_providers.has(tool_id)


## 采集诊断监控快照。
## [br]
## @api public
## [br]
## @param monitor_ids: 指定监控项；为空时采集全部可见监控项。
## [br]
## @param include_hidden: 为 true 时包含 visible=false 的监控项。
## [br]
## @return 监控快照字典。
## [br]
## @schema return: Dictionary，包含 timestamp_unix、monitor_count 和 monitors。
func collect_monitor_snapshot(
	monitor_ids: PackedStringArray = PackedStringArray(),
	include_hidden: bool = false
) -> Dictionary:
	var selected_ids := monitor_ids.duplicate()
	if selected_ids.is_empty():
		for monitor_id: StringName in _monitors.keys():
			selected_ids.append(String(monitor_id))

	selected_ids.sort()
	var monitors: Dictionary = {}
	for id_text: String in selected_ids:
		var monitor_id := StringName(id_text)
		if not _monitors.has(monitor_id):
			continue

		var entry := _monitors[monitor_id] as Dictionary
		if not include_hidden and not bool(entry.get("visible", true)):
			continue
		monitors[monitor_id] = _sample_monitor(monitor_id, entry)

	return {
		"timestamp_unix": Time.get_unix_time_from_system(),
		"monitor_count": monitors.size(),
		"monitors": monitors,
	}


## 按预设采集诊断监控快照。
## [br]
## @api public
## [br]
## @param preset_id: 预设唯一标识。
## [br]
## @param include_hidden: 为 true 时包含 visible=false 的监控项。
## [br]
## @return 监控快照字典。
## [br]
## @schema return: Dictionary，包含 collect_monitor_snapshot() 字段以及 preset_id、preset_label、preset_metadata。
func collect_monitor_preset(preset_id: StringName, include_hidden: bool = false) -> Dictionary:
	if not _monitor_presets.has(preset_id):
		return collect_monitor_snapshot(PackedStringArray(), include_hidden)

	var preset := _monitor_presets[preset_id] as Dictionary
	var ids := preset.get("monitor_ids", PackedStringArray()) as PackedStringArray
	var snapshot := collect_monitor_snapshot(ids, include_hidden)
	snapshot["preset_id"] = preset_id
	snapshot["preset_label"] = String(preset.get("label", String(preset_id)))
	snapshot["preset_metadata"] = (preset.get("metadata", {}) as Dictionary).duplicate(true)
	return snapshot


## 导出诊断监控快照。
## [br]
## @api public
## [br]
## @param snapshot: collect_monitor_snapshot() 或 collect_monitor_preset() 返回值。
## [br]
## @param format: 导出格式，支持 json、text、csv。
## [br]
## @return 导出文本。
## [br]
## @schema snapshot: Dictionary，collect_monitor_snapshot() 或 collect_monitor_preset() 返回结构。
func export_monitor_snapshot(snapshot: Dictionary, format: StringName = &"json") -> String:
	match format:
		&"text":
			return _export_monitor_snapshot_as_text(snapshot)
		&"csv":
			return _export_monitor_snapshot_as_csv(snapshot)
		_:
			return JSON.stringify(snapshot, "\t")


## 设置诊断认证 token。
## [br]
## @api public
## [br]
## @param token: token 文本。
## [br]
## @param required: 是否立即启用 token 校验。
func set_auth_token(token: String, required: bool = true) -> void:
	auth_token = token
	require_auth_token = required


## 执行诊断命令。
## [br]
## @api public
## [br]
## @param command_name: 命令名。
## [br]
## @param args: 命令参数。
## [br]
## @return 统一结果字典。
## [br]
## @schema args: Dictionary，命令参数；可包含 auth_token 以及该命令 parameter_schema 定义的字段。
## [br]
## @schema return: Dictionary，包含 ok、value、error、metadata。
func execute_command(command_name: StringName, args: Dictionary = {}) -> Dictionary:
	if not _commands.has(command_name):
		var missing_result := _make_command_result(false, null, "Missing diagnostic command: %s" % String(command_name))
		diagnostic_command_executed.emit(command_name, missing_result)
		return missing_result

	var entry := _commands[command_name] as Dictionary
	if _disabled_commands.has(command_name):
		var disabled_result := _make_command_result(false, null, "Diagnostic command is disabled: %s" % String(command_name))
		diagnostic_command_executed.emit(command_name, disabled_result)
		return disabled_result

	var tier := int(entry.get("tier", CommandTier.OBSERVE))
	if not _is_tier_allowed(tier):
		var tier_result := _make_command_result(false, null, "Diagnostic command tier is not allowed: %s" % _get_tier_name(tier), {
			"tier": tier,
			"tier_name": _get_tier_name(tier),
		})
		diagnostic_command_executed.emit(command_name, tier_result)
		return tier_result
	if not _is_auth_allowed(args):
		var auth_result := _make_command_result(false, null, "Diagnostic command authentication failed.", {
			"tier": tier,
			"tier_name": _get_tier_name(tier),
		})
		diagnostic_command_executed.emit(command_name, auth_result)
		return auth_result

	var prepared_args := _prepare_command_args(args, entry)
	var validation_report := _validate_command_args(entry, prepared_args, args)
	if not validation_report.is_ok():
		var validation_result := _make_command_result(false, null, validation_report.make_summary(String(command_name)), {
			"tier": tier,
			"tier_name": _get_tier_name(tier),
			"validation": validation_report.to_dict(),
		})
		diagnostic_command_executed.emit(command_name, validation_result)
		return validation_result

	var callback: Callable = entry.get("callback")
	if not callback.is_valid():
		var invalid_result := _make_command_result(false, null, "Diagnostic command callback is invalid: %s" % String(command_name))
		diagnostic_command_executed.emit(command_name, invalid_result)
		return invalid_result

	var value: Variant = callback.call(prepared_args)
	var result := _make_command_result(true, value, "", {
		"tier": tier,
		"tier_name": _get_tier_name(tier),
	})
	if encode_command_results_for_json:
		result = command_result_to_json_compatible(result)
	diagnostic_command_executed.emit(command_name, result)
	return result


## 执行诊断命令并返回 JSON 兼容结果。
## [br]
## @api public
## [br]
## @param command_name: 命令名。
## [br]
## @param args: 命令参数。
## [br]
## @return JSON 兼容结果字典。
## [br]
## @schema args: Dictionary，命令参数；可包含 auth_token 以及该命令 parameter_schema 定义的字段。
## [br]
## @schema return: Dictionary，包含 JSON 兼容的 ok、value、error、metadata。
func execute_command_json_safe(command_name: StringName, args: Dictionary = {}) -> Dictionary:
	return command_result_to_json_compatible(execute_command(command_name, args))


## 将命令结果转换为 JSON 兼容字典。
## [br]
## @api public
## [br]
## @param result: execute_command() 返回的结果。
## [br]
## @param options: 传给 GFVariantJsonCodec.variant_to_json_compatible() 的选项。
## [br]
## @return JSON 兼容结果字典。
## [br]
## @schema result: Dictionary，execute_command() 返回结构。
## [br]
## @schema options: Dictionary，传给 GFVariantJsonCodec.variant_to_json_compatible() 的编码选项。
## [br]
## @schema return: Dictionary，JSON 兼容命令结果。
func command_result_to_json_compatible(result: Dictionary, options: Dictionary = {}) -> Dictionary:
	return GFVariantJsonCodec.variant_to_json_compatible(result, options) as Dictionary


## 采集运行时诊断快照。
## [br]
## @api public
## [br]
## @param options: 可选参数，支持 recent_log_count、include_recent_logs、include_scene_tree、scene_tree_options、include_signal_graph、signal_graph_options。
## [br]
## @return 快照字典。
## [br]
## @schema options: Dictionary，支持 recent_log_count、include_recent_logs、include_scene_tree、scene_tree_options、include_signal_graph、signal_graph_options、include_monitors、monitor_preset、monitor_ids、include_hidden_monitors。
## [br]
## @schema return: Dictionary，包含 timestamp_unix、engine、build、architecture、event_system、performance、logs、network、tools，可选 scene_tree、signal_graph、monitors 和注册分区。
func collect_snapshot(options: Dictionary = {}) -> Dictionary:
	var snapshot := {
		"timestamp_unix": Time.get_unix_time_from_system(),
		"engine": Engine.get_version_info(),
		"build": GFBuildInfo.collect().to_dict(),
		"architecture": {},
		"event_system": {},
		"performance": {},
		"logs": {},
		"network": {},
		"tools": {},
	}

	var architecture := _get_architecture_or_null()
	if architecture != null:
		snapshot["architecture"] = architecture.get_debug_lifecycle_state()
		snapshot["event_system"] = architecture.get_event_debug_stats()

	if include_performance_monitors:
		snapshot["performance"] = collect_performance_snapshot()

	var build_info_utility := get_utility(GFBuildInfoUtility) as GFBuildInfoUtility
	if build_info_utility != null:
		snapshot["build"] = build_info_utility.get_build_info_dict()

	snapshot["logs"] = collect_log_snapshot(
		int(options.get("recent_log_count", default_recent_log_count)),
		bool(options.get("include_recent_logs", true))
	)

	if bool(options.get("include_scene_tree", false)):
		var scene_options := options.get("scene_tree_options", {}) as Dictionary
		snapshot["scene_tree"] = collect_scene_tree_snapshot(null, scene_options if scene_options != null else {})

	if bool(options.get("include_signal_graph", false)):
		var signal_options := options.get("signal_graph_options", {}) as Dictionary
		snapshot["signal_graph"] = collect_signal_graph_snapshot(null, signal_options if signal_options != null else {})

	snapshot["tools"] = _collect_tool_debug_snapshots()
	_collect_registered_snapshot_sections(snapshot)

	if bool(options.get("include_monitors", true)):
		var preset_id := StringName(options.get("monitor_preset", &""))
		if preset_id != &"":
			snapshot["monitors"] = collect_monitor_preset(
				preset_id,
				bool(options.get("include_hidden_monitors", false))
			)
		else:
			var monitor_ids := options.get("monitor_ids", PackedStringArray()) as PackedStringArray
			snapshot["monitors"] = collect_monitor_snapshot(
				monitor_ids if monitor_ids != null else PackedStringArray(),
				bool(options.get("include_hidden_monitors", false))
			)

	snapshot_collected.emit(snapshot)
	return snapshot


## 采集性能监视器快照。
## [br]
## @return 性能数据字典。
## [br]
## @api public
## [br]
## @schema return: Dictionary，包含 fps、process_time、physics_process_time、static_memory、object_count、node_count、resource_count。
func collect_performance_snapshot() -> Dictionary:
	return {
		"fps": Performance.get_monitor(Performance.TIME_FPS),
		"process_time": Performance.get_monitor(Performance.TIME_PROCESS),
		"physics_process_time": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
		"static_memory": Performance.get_monitor(Performance.MEMORY_STATIC),
		"object_count": Performance.get_monitor(Performance.OBJECT_COUNT),
		"node_count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"resource_count": Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
	}


## 采集日志缓存快照。
## [br]
## @api public
## [br]
## @param recent_log_count: 最近日志数量。
## [br]
## @param include_recent_logs: 是否包含日志条目。
## [br]
## @return 日志数据字典。
## [br]
## @schema return: Dictionary，包含 available、memory_count、dropped_count、recent。
func collect_log_snapshot(recent_log_count: int = 20, include_recent_logs: bool = true) -> Dictionary:
	var log_utility := get_utility(GFLogUtility) as GFLogUtility
	if log_utility == null:
		return {
			"available": false,
			"memory_count": 0,
			"dropped_count": 0,
			"recent": [],
		}

	return {
		"available": true,
		"memory_count": log_utility.get_memory_entry_count(),
		"dropped_count": log_utility.get_dropped_memory_entry_count(),
		"recent": log_utility.get_recent_entries(recent_log_count) if include_recent_logs else [],
	}


## 采集只读场景树快照。
## [br]
## @api public
## [br]
## @param root: 可选根节点；为空时优先使用当前场景，再回退到 Viewport root。
## [br]
## @param options: 可选参数，支持 max_depth、max_nodes、include_groups、include_owner_path、include_script_path、include_internal。
## [br]
## @return 场景树快照字典。
## [br]
## @schema options: Dictionary，支持 max_depth、max_nodes、include_groups、include_owner_path、include_script_path、include_internal、root_path、prefer_current_scene。
## [br]
## @schema return: Dictionary，包含 available、node_count、truncated、root_path、root。
func collect_scene_tree_snapshot(root: Node = null, options: Dictionary = {}) -> Dictionary:
	var target_root := root if root != null else _resolve_scene_tree_root(options)
	var max_depth := maxi(int(options.get("max_depth", default_scene_tree_max_depth)), 0)
	var max_nodes := maxi(int(options.get("max_nodes", default_scene_tree_max_nodes)), 1)
	var normalized_options := {
		"max_depth": max_depth,
		"max_nodes": max_nodes,
		"include_groups": bool(options.get("include_groups", false)),
		"include_owner_path": bool(options.get("include_owner_path", true)),
		"include_script_path": bool(options.get("include_script_path", true)),
		"include_internal": bool(options.get("include_internal", false)),
	}

	if target_root == null:
		return {
			"available": false,
			"node_count": 0,
			"truncated": false,
			"root_path": "",
			"root": {},
		}

	var counters := {
		"count": 0,
		"truncated": false,
	}
	var root_snapshot := _collect_scene_tree_node(target_root, 0, normalized_options, counters)
	return {
		"available": true,
		"node_count": int(counters.get("count", 0)),
		"truncated": bool(counters.get("truncated", false)),
		"root_path": _get_node_path_or_empty(target_root),
		"root": root_snapshot,
	}


## 采集只读信号连接图快照。
## [br]
## @api public
## [br]
## @param root: 可选根节点；为空时优先使用当前场景，再回退到 Viewport root。
## [br]
## @param options: 可选参数，支持 include_internal、persistent_only、include_empty_signals、include_external_targets、include_index。
## [br]
## @return 信号图快照字典。
## [br]
## @schema options: Dictionary，支持 include_internal、persistent_only、include_empty_signals、include_external_targets、include_index、root_path、prefer_current_scene。
## [br]
## @schema return: Dictionary，包含 ok、root_path、node_count、signal_count、connection_count、nodes、signals、connections，可选 index。
func collect_signal_graph_snapshot(root: Node = null, options: Dictionary = {}) -> Dictionary:
	var target_root := root if root != null else _resolve_scene_tree_root(options)
	if target_root == null:
		return {
			"ok": false,
			"root_path": "",
			"node_count": 0,
			"signal_count": 0,
			"connection_count": 0,
			"nodes": [],
			"signals": [],
			"connections": [],
			"message": "Signal graph root is unavailable.",
		}

	var graph := GFSceneSignalAudit.build_signal_graph(target_root, options)
	if bool(options.get("include_index", false)):
		graph["index"] = GFSceneSignalAudit.index_signal_graph(graph)
	return graph


# --- 私有/辅助方法 ---

func _bind_console_command() -> void:
	_console_utility = get_utility(GFConsoleUtility) as GFConsoleUtility
	if _console_utility == null:
		return
	if _console_utility.get_command_names().has("diagnostics"):
		return

	_console_utility.register_command("diagnostics", Callable(self, "_on_console_diagnostics_command"), "输出 GF 诊断摘要。")
	_console_command_registered = true


func _make_command_result(ok: bool, value: Variant, error: String, metadata: Dictionary = {}) -> Dictionary:
	var result := {
		"ok": ok,
		"value": value,
		"error": error,
		"metadata": metadata.duplicate(true),
	}
	return result


func _command_collect_snapshot(args: Dictionary) -> Dictionary:
	return collect_snapshot(args)


func _command_collect_performance(_args: Dictionary) -> Dictionary:
	return collect_performance_snapshot()


func _command_collect_logs(args: Dictionary) -> Dictionary:
	return collect_log_snapshot(
		int(args.get("recent_log_count", default_recent_log_count)),
		bool(args.get("include_recent_logs", true))
	)


func _command_collect_monitors(args: Dictionary) -> Dictionary:
	var preset_id := StringName(args.get("preset_id", &""))
	if preset_id != &"":
		return collect_monitor_preset(preset_id, bool(args.get("include_hidden", false)))

	var monitor_ids := args.get("monitor_ids", PackedStringArray()) as PackedStringArray
	return collect_monitor_snapshot(
		monitor_ids if monitor_ids != null else PackedStringArray(),
		bool(args.get("include_hidden", false))
	)


func _command_collect_tools(_args: Dictionary) -> Dictionary:
	return _collect_tool_debug_snapshots()


func _command_collect_scene(args: Dictionary) -> Dictionary:
	return collect_scene_tree_snapshot(null, args)


func _command_collect_signals(args: Dictionary) -> Dictionary:
	return collect_signal_graph_snapshot(null, args)


func _collect_scene_tree_node(node: Node, depth: int, options: Dictionary, counters: Dictionary) -> Dictionary:
	counters["count"] = int(counters.get("count", 0)) + 1
	var include_internal := bool(options.get("include_internal", false))
	var child_count := node.get_child_count(include_internal)
	var info := {
		"name": node.name,
		"type": node.get_class(),
		"path": _get_node_path_or_empty(node),
		"depth": depth,
		"child_count": child_count,
		"children": [],
	}

	if bool(options.get("include_owner_path", true)):
		info["owner_path"] = _get_node_path_or_empty(node.owner)
	if bool(options.get("include_script_path", true)):
		info["script_path"] = _get_node_script_path(node)
	if bool(options.get("include_groups", false)):
		info["groups"] = _get_node_group_names(node)

	if depth >= int(options.get("max_depth", default_scene_tree_max_depth)):
		if child_count > 0:
			info["depth_limit_reached"] = true
			counters["truncated"] = true
		return info

	var children: Array[Dictionary] = []
	for child_index: int in range(child_count):
		if int(counters.get("count", 0)) >= int(options.get("max_nodes", default_scene_tree_max_nodes)):
			info["children_truncated"] = true
			counters["truncated"] = true
			break

		var child := node.get_child(child_index, include_internal)
		children.append(_collect_scene_tree_node(child, depth + 1, options, counters))
	info["children"] = children
	return info


func _resolve_scene_tree_root(options: Dictionary) -> Node:
	var root_path := NodePath(String(options.get("root_path", "")))
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null

	if not root_path.is_empty():
		var explicit_root := tree.root.get_node_or_null(root_path)
		if explicit_root != null:
			return explicit_root
		if tree.current_scene != null:
			explicit_root = tree.current_scene.get_node_or_null(root_path)
			if explicit_root != null:
				return explicit_root

	return tree.current_scene if tree.current_scene != null else tree.root


func _get_node_path_or_empty(node: Node) -> String:
	if node == null:
		return ""
	if node.is_inside_tree():
		return str(node.get_path())
	return String(node.name)


func _get_node_script_path(node: Node) -> String:
	var script := node.get_script() as Script
	if script == null:
		return ""
	return script.resource_path


func _get_node_group_names(node: Node) -> PackedStringArray:
	var groups := PackedStringArray()
	for group: StringName in node.get_groups():
		groups.append(String(group))
	groups.sort()
	return groups


func _register_builtin_monitors() -> void:
	register_monitor(&"performance.fps", Callable(self, "_monitor_performance_fps"), {
		"label": "FPS",
		"group": "Performance",
	})
	register_monitor(&"performance.process_time", Callable(self, "_monitor_performance_process_time"), {
		"label": "Process Time",
		"group": "Performance",
	})
	register_monitor(&"performance.physics_process_time", Callable(self, "_monitor_performance_physics_time"), {
		"label": "Physics Time",
		"group": "Performance",
	})
	register_monitor(&"performance.static_memory", Callable(self, "_monitor_performance_static_memory"), {
		"label": "Static Memory",
		"group": "Performance",
		"min_interval_seconds": 0.25,
	})
	register_monitor(&"performance.node_count", Callable(self, "_monitor_performance_node_count"), {
		"label": "Nodes",
		"group": "Performance",
		"min_interval_seconds": 0.25,
	})
	register_monitor(&"architecture.models", Callable(self, "_monitor_architecture_model_count"), {
		"label": "Models",
		"group": "Architecture",
		"min_interval_seconds": 0.25,
	})
	register_monitor(&"architecture.systems", Callable(self, "_monitor_architecture_system_count"), {
		"label": "Systems",
		"group": "Architecture",
		"min_interval_seconds": 0.25,
	})
	register_monitor(&"architecture.utilities", Callable(self, "_monitor_architecture_utility_count"), {
		"label": "Utilities",
		"group": "Architecture",
		"min_interval_seconds": 0.25,
	})
	register_monitor(&"event_system.stats", Callable(self, "_monitor_event_system_stats"), {
		"label": "Event Stats",
		"group": "Architecture",
		"min_interval_seconds": 0.25,
	})
	register_monitor(&"tools.asset", Callable(self, "_monitor_tool_asset_snapshot"), {
		"label": "Asset Utility",
		"group": "Tools",
		"min_interval_seconds": 0.25,
	})
	register_monitor(&"tools.timer", Callable(self, "_monitor_tool_timer_snapshot"), {
		"label": "Timer Utility",
		"group": "Tools",
		"min_interval_seconds": 0.25,
	})
	register_monitor(&"tools.download", Callable(self, "_monitor_tool_download_snapshot"), {
		"label": "Download Utility",
		"group": "Tools",
		"min_interval_seconds": 0.25,
	})

	register_monitor_preset(&"minimal", PackedStringArray([
		"performance.fps",
		"performance.process_time",
		"performance.physics_process_time",
	]), { "label": "Minimal" })
	register_monitor_preset(&"performance", PackedStringArray([
		"performance.fps",
		"performance.process_time",
		"performance.physics_process_time",
		"performance.static_memory",
		"performance.node_count",
	]), { "label": "Performance" })
	register_monitor_preset(&"architecture", PackedStringArray([
		"architecture.models",
		"architecture.systems",
		"architecture.utilities",
		"event_system.stats",
	]), { "label": "Architecture" })
	register_monitor_preset(&"tools", PackedStringArray([
		"tools.asset",
		"tools.timer",
		"tools.download",
	]), { "label": "Tools" })
	register_monitor_preset(&"overlay", PackedStringArray([
		"performance.fps",
		"architecture.models",
		"architecture.systems",
		"architecture.utilities",
	]), { "label": "Overlay" })


func _sample_monitor(monitor_id: StringName, entry: Dictionary) -> Dictionary:
	var now_seconds := Time.get_ticks_msec() / 1000.0
	var min_interval_seconds := float(entry.get("min_interval_seconds", 0.0))
	var last_sample := entry.get("last_sample", {}) as Dictionary
	if (
		min_interval_seconds > 0.0
		and not last_sample.is_empty()
		and now_seconds - float(entry.get("last_sample_time", -INF)) < min_interval_seconds
	):
		return last_sample.duplicate(true)

	var provider: Callable = entry.get("provider", Callable())
	var sample := {
		"id": monitor_id,
		"label": String(entry.get("label", String(monitor_id))),
		"group": String(entry.get("group", "Runtime")),
		"value": null,
		"valid": false,
		"error": "",
		"metadata": (entry.get("metadata", {}) as Dictionary).duplicate(true),
		"sampled_at_unix": Time.get_unix_time_from_system(),
	}
	if not provider.is_valid():
		sample["error"] = "Monitor provider is invalid."
	else:
		sample["value"] = provider.call()
		sample["valid"] = true

	entry["last_sample_time"] = now_seconds
	entry["last_sample"] = sample.duplicate(true)
	monitor_sampled.emit(monitor_id, sample)
	return sample


func _monitor_performance_fps() -> float:
	return Performance.get_monitor(Performance.TIME_FPS)


func _monitor_performance_process_time() -> float:
	return Performance.get_monitor(Performance.TIME_PROCESS)


func _monitor_performance_physics_time() -> float:
	return Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)


func _monitor_performance_static_memory() -> float:
	return Performance.get_monitor(Performance.MEMORY_STATIC)


func _monitor_performance_node_count() -> float:
	return Performance.get_monitor(Performance.OBJECT_NODE_COUNT)


func _monitor_architecture_model_count() -> int:
	return _get_architecture_debug_section_count("models")


func _monitor_architecture_system_count() -> int:
	return _get_architecture_debug_section_count("systems")


func _monitor_architecture_utility_count() -> int:
	return _get_architecture_debug_section_count("utilities")


func _monitor_event_system_stats() -> Dictionary:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return {}
	return architecture.get_event_debug_stats()


func _monitor_tool_asset_snapshot() -> Dictionary:
	return _get_instance_debug_snapshot(get_utility(GFAssetUtility))


func _monitor_tool_timer_snapshot() -> Dictionary:
	return _get_instance_debug_snapshot(get_utility(GFTimerUtility))


func _monitor_tool_download_snapshot() -> Dictionary:
	return _get_instance_debug_snapshot(get_utility(GFDownloadUtility))


func _collect_tool_debug_snapshots() -> Dictionary:
	var result: Dictionary = {}
	_add_tool_debug_snapshot(result, &"build_info", get_utility(GFBuildInfoUtility))
	_add_tool_debug_snapshot(result, &"asset", get_utility(GFAssetUtility))
	_add_tool_debug_snapshot(result, &"timer", get_utility(GFTimerUtility))
	_add_tool_debug_snapshot(result, &"remote_cache", get_utility(GFRemoteCacheUtility))
	_add_tool_debug_snapshot(result, &"download", get_utility(GFDownloadUtility))
	_add_tool_debug_snapshot(result, &"object_pool", get_utility(GFObjectPoolUtility))
	_add_registered_tool_debug_snapshots(result)
	return result


func _add_tool_debug_snapshot(result: Dictionary, key: StringName, instance: Object) -> void:
	var snapshot := _get_instance_debug_snapshot(instance)
	if not snapshot.is_empty():
		result[key] = snapshot


func _add_registered_tool_debug_snapshots(result: Dictionary) -> void:
	for tool_id: StringName in _tool_snapshot_providers.keys():
		var provider := _tool_snapshot_providers[tool_id] as Callable
		var snapshot := _call_dictionary_provider(provider)
		if not snapshot.is_empty():
			result[tool_id] = snapshot


func _collect_registered_snapshot_sections(snapshot: Dictionary) -> void:
	for section_id: StringName in _snapshot_section_providers.keys():
		var provider := _snapshot_section_providers[section_id] as Callable
		var section := _call_dictionary_provider(provider)
		if not section.is_empty():
			snapshot[section_id] = section


func _get_instance_debug_snapshot(instance: Object) -> Dictionary:
	if instance == null or not instance.has_method("get_debug_snapshot"):
		return {}
	var value: Variant = instance.call("get_debug_snapshot")
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


func _call_dictionary_provider(provider: Callable) -> Dictionary:
	if not provider.is_valid():
		return {}
	var value: Variant = provider.call()
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


func _get_architecture_debug_section_count(section_name: String) -> int:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return 0

	var state := architecture.get_debug_lifecycle_state()
	var section := state.get(section_name, {}) as Dictionary
	return section.size() if section != null else 0


func _export_monitor_snapshot_as_text(snapshot: Dictionary) -> String:
	var lines := PackedStringArray()
	var monitors := snapshot.get("monitors", {}) as Dictionary
	if monitors == null:
		return ""

	var ids := PackedStringArray()
	for monitor_id: Variant in monitors.keys():
		ids.append(String(monitor_id))
	ids.sort()
	for id_text: String in ids:
		var sample := monitors[StringName(id_text)] as Dictionary
		if sample == null:
			continue
		lines.append("%s [%s]: %s" % [
			String(sample.get("label", id_text)),
			String(sample.get("group", "Runtime")),
			str(sample.get("value", null)),
		])
	return "\n".join(lines)


func _export_monitor_snapshot_as_csv(snapshot: Dictionary) -> String:
	var lines := PackedStringArray(["id,label,group,value,valid,error"])
	var monitors := snapshot.get("monitors", {}) as Dictionary
	if monitors == null:
		return "\n".join(lines)

	var ids := PackedStringArray()
	for monitor_id: Variant in monitors.keys():
		ids.append(String(monitor_id))
	ids.sort()
	for id_text: String in ids:
		var sample := monitors[StringName(id_text)] as Dictionary
		if sample == null:
			continue
		lines.append(",".join(PackedStringArray([
			_escape_csv(id_text),
			_escape_csv(String(sample.get("label", id_text))),
			_escape_csv(String(sample.get("group", "Runtime"))),
			_escape_csv(str(sample.get("value", null))),
			_escape_csv(str(sample.get("valid", false))),
			_escape_csv(String(sample.get("error", ""))),
		])))
	return "\n".join(lines)


func _escape_csv(value: String) -> String:
	var escaped := value.replace("\"", "\"\"")
	if escaped.contains(",") or escaped.contains("\n") or escaped.contains("\""):
		return "\"%s\"" % escaped
	return escaped


func _on_console_diagnostics_command(_args: PackedStringArray) -> void:
	var snapshot := collect_snapshot({
		"include_recent_logs": false,
	})
	var summary := _make_console_summary(snapshot)
	var log_utility := get_utility(GFLogUtility) as GFLogUtility
	if log_utility != null:
		log_utility.info("Diagnostics", summary)
	else:
		print(summary)


func _make_console_summary(snapshot: Dictionary) -> String:
	var architecture := snapshot.get("architecture", {}) as Dictionary
	var models := architecture.get("models", {}) as Dictionary
	var systems := architecture.get("systems", {}) as Dictionary
	var utilities := architecture.get("utilities", {}) as Dictionary
	var performance := snapshot.get("performance", {}) as Dictionary
	var fps := float(performance.get("fps", 0.0))
	return "GF diagnostics: models=%d systems=%d utilities=%d fps=%.1f" % [
		models.size(),
		systems.size(),
		utilities.size(),
		fps,
	]


func _is_tier_allowed(tier: int) -> bool:
	if tier > int(max_command_tier):
		return false
	if tier == CommandTier.DANGER and not allow_danger_commands:
		return false
	return true


func _is_auth_allowed(args: Dictionary) -> bool:
	if not require_auth_token:
		return true
	if auth_token.is_empty():
		return false

	var provided := String(args.get("auth_token", args.get("_auth_token", "")))
	return provided == auth_token


func _normalize_parameter_schema(parameters: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if parameters is Dictionary:
		for key: Variant in (parameters as Dictionary).keys():
			var definition := (parameters as Dictionary)[key] as Dictionary
			if definition == null:
				definition = {}
			definition = definition.duplicate(true)
			definition["name"] = String(key)
			result.append(_normalize_parameter_definition(definition))
	elif parameters is Array:
		for item: Variant in parameters as Array:
			if item is Dictionary:
				result.append(_normalize_parameter_definition((item as Dictionary).duplicate(true)))
	return result


func _normalize_parameter_definition(definition: Dictionary) -> Dictionary:
	var parameter_name := String(definition.get("name", ""))
	if parameter_name.is_empty():
		return {}
	return {
		"name": parameter_name,
		"type": String(definition.get("type", "any")).to_lower(),
		"required": bool(definition.get("required", false)),
		"allow_null": bool(definition.get("allow_null", false)),
		"default": GFVariantData.duplicate_variant(definition.get("default", null)),
		"has_default": definition.has("default"),
		"allowed_values": GFVariantData.duplicate_variant(definition.get("allowed_values", [])),
		"min": definition.get("min", null),
		"max": definition.get("max", null),
		"metadata": (definition.get("metadata", {}) as Dictionary).duplicate(true) if definition.get("metadata", {}) is Dictionary else {},
	}


func _prepare_command_args(args: Dictionary, entry: Dictionary) -> Dictionary:
	var prepared := args.duplicate(true)
	var parameters := entry.get("parameters", []) as Array
	if parameters == null:
		return prepared
	for parameter_variant: Variant in parameters:
		var parameter := parameter_variant as Dictionary
		if parameter == null:
			continue
		var parameter_name := String(parameter.get("name", ""))
		if not prepared.has(parameter_name) and bool(parameter.get("has_default", false)):
			prepared[parameter_name] = GFVariantData.duplicate_variant(parameter.get("default", null))
	return prepared


func _validate_command_args(entry: Dictionary, prepared_args: Dictionary, original_args: Dictionary) -> GFValidationReport:
	var report := GFValidationReport.new("Diagnostic command arguments")
	var parameters := entry.get("parameters", []) as Array
	if parameters == null:
		return report

	for parameter_variant: Variant in parameters:
		var parameter := parameter_variant as Dictionary
		if parameter == null or parameter.is_empty():
			continue
		_validate_command_parameter(report, parameter, prepared_args, original_args)
	return report


func _validate_command_parameter(
	report: GFValidationReport,
	parameter: Dictionary,
	prepared_args: Dictionary,
	original_args: Dictionary
) -> void:
	var parameter_name := String(parameter.get("name", ""))
	if parameter_name.is_empty():
		return
	if bool(parameter.get("required", false)) and not original_args.has(parameter_name) and not bool(parameter.get("has_default", false)):
		report.add_error(&"missing_parameter", "Missing required diagnostic command parameter.", parameter_name)
		return
	if not prepared_args.has(parameter_name):
		return

	var value: Variant = prepared_args[parameter_name]
	if value == null:
		if not bool(parameter.get("allow_null", false)):
			report.add_error(&"null_parameter", "Diagnostic command parameter does not allow null.", parameter_name)
		return

	var type_name := String(parameter.get("type", "any")).to_lower()
	if not _does_value_match_parameter_type(value, type_name):
		report.add_error(&"parameter_type_mismatch", "Diagnostic command parameter has the wrong type.", parameter_name, "", {
			"expected_type": type_name,
			"actual_type": type_string(typeof(value)),
		})
		return

	_validate_allowed_values(report, parameter, parameter_name, value)
	_validate_numeric_range(report, parameter, parameter_name, value)


func _validate_allowed_values(
	report: GFValidationReport,
	parameter: Dictionary,
	name: String,
	value: Variant
) -> void:
	var allowed_values := parameter.get("allowed_values", [])
	if not (allowed_values is Array) or (allowed_values as Array).is_empty():
		return
	for allowed: Variant in allowed_values as Array:
		if value == allowed:
			return
	report.add_error(&"parameter_value_not_allowed", "Diagnostic command parameter value is not allowed.", name)


func _validate_numeric_range(
	report: GFValidationReport,
	parameter: Dictionary,
	name: String,
	value: Variant
) -> void:
	if not (value is int or value is float):
		return
	if parameter.get("min", null) != null and float(value) < float(parameter.get("min")):
		report.add_error(&"parameter_below_minimum", "Diagnostic command parameter is below minimum.", name)
	if parameter.get("max", null) != null and float(value) > float(parameter.get("max")):
		report.add_error(&"parameter_above_maximum", "Diagnostic command parameter is above maximum.", name)


func _does_value_match_parameter_type(value: Variant, type_name: String) -> bool:
	match type_name:
		"", "any", "variant":
			return true
		"bool", "boolean":
			return value is bool
		"int", "integer":
			return value is int
		"float", "number":
			return value is float or value is int
		"string":
			return value is String
		"string_name", "stringname":
			return value is StringName
		"node_path", "nodepath":
			return value is NodePath
		"dictionary", "dict":
			return value is Dictionary
		"array":
			return value is Array
		"packed_string_array":
			return value is PackedStringArray
		"vector2":
			return value is Vector2
		"vector3":
			return value is Vector3
		"color":
			return value is Color
		"object":
			return value is Object
		_:
			return true


func _get_tier_name(tier: int) -> String:
	match tier:
		CommandTier.INPUT:
			return "input"
		CommandTier.CONTROL:
			return "control"
		CommandTier.DANGER:
			return "danger"
		_:
			return "observe"
