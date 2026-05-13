## GFDiagnosticsUtility: 运行时诊断聚合工具。
##
## 提供架构生命周期、事件系统、性能、日志和外部贡献诊断的统一快照。
## 诊断命令、监控项和快照分区通过 Callable 注册，框架只负责调度和包装结果，不解释项目业务数据。
class_name GFDiagnosticsUtility
extends GFUtility


# --- 信号 ---

## 采集快照后发出。
signal snapshot_collected(snapshot: Dictionary)

## 执行诊断命令后发出。
signal diagnostic_command_executed(command_name: StringName, result: Dictionary)

## 采样诊断监控项后发出。
signal monitor_sampled(monitor_id: StringName, sample: Dictionary)


# --- 枚举 ---

## 诊断命令风险等级。
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
var include_performance_monitors: bool = true

## 快照中默认包含的最近日志数量。
var default_recent_log_count: int = 20

## 当前允许执行的最高命令等级。
var max_command_tier: CommandTier = CommandTier.OBSERVE

## 是否要求命令参数提供 auth_token 或 _auth_token。
var require_auth_token: bool = false

## 诊断命令认证 token。为空时无法通过认证。
var auth_token: String = ""

## 是否允许执行 DANGER 等级命令。即使 max_command_tier 足够，也需要显式开启。
var allow_danger_commands: bool = false

## 场景树快照默认递归深度。
var default_scene_tree_max_depth: int = 4

## 场景树快照默认最多采集节点数。
var default_scene_tree_max_nodes: int = 128


# --- 私有变量 ---

var _commands: Dictionary = {}
var _monitors: Dictionary = {}
var _monitor_presets: Dictionary = {}
var _snapshot_section_providers: Dictionary = {}
var _tool_snapshot_providers: Dictionary = {}
var _monitor_order_counter: int = 0
var _console_utility: GFConsoleUtility = null
var _console_command_registered: bool = false


# --- Godot 生命周期方法 ---

func init() -> void:
	_register_builtin_monitors()
	register_command(&"diagnostics.snapshot", Callable(self, "_command_collect_snapshot"), "采集 GF 诊断快照。", CommandTier.OBSERVE)
	register_command(&"diagnostics.performance", Callable(self, "_command_collect_performance"), "采集性能监视器快照。", CommandTier.OBSERVE)
	register_command(&"diagnostics.logs", Callable(self, "_command_collect_logs"), "读取最近日志缓存。", CommandTier.OBSERVE)
	register_command(&"diagnostics.monitors", Callable(self, "_command_collect_monitors"), "采集已注册诊断监控项。", CommandTier.OBSERVE)
	register_command(&"diagnostics.tools", Callable(self, "_command_collect_tools"), "采集已注册 GF 工具快照。", CommandTier.OBSERVE)
	register_command(&"diagnostics.scene", Callable(self, "_command_collect_scene"), "采集只读场景树快照。", CommandTier.OBSERVE)


func ready() -> void:
	_bind_console_command()


func dispose() -> void:
	if _console_utility != null and _console_command_registered:
		_console_utility.unregister_command("diagnostics")
	_console_utility = null
	_console_command_registered = false
	_commands.clear()
	_monitors.clear()
	_monitor_presets.clear()
	_snapshot_section_providers.clear()
	_tool_snapshot_providers.clear()
	_monitor_order_counter = 0


# --- 公共方法 ---

## 注册诊断命令。
## @param command_name: 命令名。
## @param callback: 回调，签名建议为 func(args: Dictionary) -> Variant。
## @param description: 描述文本。
## @param tier: 命令风险等级。
func register_command(
	command_name: StringName,
	callback: Callable,
	description: String = "",
	tier: CommandTier = CommandTier.OBSERVE
) -> void:
	if command_name == &"" or not callback.is_valid():
		return
	_commands[command_name] = {
		"callback": callback,
		"description": description,
		"tier": tier,
	}


## 注销诊断命令。
## @param command_name: 命令名。
func unregister_command(command_name: StringName) -> void:
	_commands.erase(command_name)


## 检查诊断命令是否存在。
## @param command_name: 命令名。
## @return 存在返回 true。
func has_command(command_name: StringName) -> bool:
	return _commands.has(command_name)


## 获取诊断命令描述。
## @return 命令名到描述的字典。
func get_command_descriptions() -> Dictionary:
	var result: Dictionary = {}
	for command_name: StringName in _commands.keys():
		var entry := _commands[command_name] as Dictionary
		result[command_name] = String(entry.get("description", ""))
	return result


## 获取诊断命令目录。
## @return 命令名到命令元数据的字典。
func get_command_catalog() -> Dictionary:
	var result: Dictionary = {}
	for command_name: StringName in _commands.keys():
		var entry := _commands[command_name] as Dictionary
		var tier := int(entry.get("tier", CommandTier.OBSERVE))
		result[command_name] = {
			"description": String(entry.get("description", "")),
			"tier": tier,
			"tier_name": _get_tier_name(tier),
		}
	return result


## 注册诊断监控项。
## @param monitor_id: 监控项唯一标识。
## @param provider: 无参数采样回调。
## @param options: 可选元数据，支持 label、group、visible、metadata、min_interval_seconds。
## @return 注册成功返回 true。
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
## @param monitor_id: 监控项唯一标识。
func unregister_monitor(monitor_id: StringName) -> void:
	_monitors.erase(monitor_id)
	for preset_id: StringName in _monitor_presets.keys():
		var preset := _monitor_presets[preset_id] as Dictionary
		var ids := preset.get("monitor_ids", PackedStringArray()) as PackedStringArray
		if ids.has(String(monitor_id)):
			ids.remove_at(ids.find(String(monitor_id)))


## 检查诊断监控项是否存在。
## @param monitor_id: 监控项唯一标识。
## @return 存在返回 true。
func has_monitor(monitor_id: StringName) -> bool:
	return _monitors.has(monitor_id)


## 获取诊断监控项目录。
## @return 监控项元数据字典。
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
## @param preset_id: 预设唯一标识。
## @param monitor_ids: 预设包含的监控项标识。
## @param options: 可选元数据，支持 label、metadata。
## @return 注册成功返回 true。
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
## @param preset_id: 预设唯一标识。
## @param monitor_id: 监控项唯一标识。
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
## @param preset_id: 预设唯一标识。
func unregister_monitor_preset(preset_id: StringName) -> void:
	_monitor_presets.erase(preset_id)


## 检查诊断监控预设是否存在。
## @param preset_id: 预设唯一标识。
## @return 存在返回 true。
func has_monitor_preset(preset_id: StringName) -> bool:
	return _monitor_presets.has(preset_id)


## 获取诊断监控预设列表。
## @return 预设标识列表。
func get_monitor_preset_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for preset_id: StringName in _monitor_presets.keys():
		result.append(String(preset_id))
	result.sort()
	return result


## 注册快照分区 provider。用于扩展或项目把自己的诊断数据贡献到 collect_snapshot() 顶层字段。
## @param section_id: 快照顶层字段名。
## @param provider: 无参数采样回调，建议返回 Dictionary。
## @return 注册成功返回 true。
func register_snapshot_section_provider(section_id: StringName, provider: Callable) -> bool:
	if section_id == &"" or not provider.is_valid():
		return false
	_snapshot_section_providers[section_id] = provider
	return true


## 注销快照分区 provider。
## @param section_id: 快照顶层字段名。
func unregister_snapshot_section_provider(section_id: StringName) -> void:
	_snapshot_section_providers.erase(section_id)


## 检查快照分区 provider 是否存在。
## @param section_id: 快照顶层字段名。
## @return 存在返回 true。
func has_snapshot_section_provider(section_id: StringName) -> bool:
	return _snapshot_section_providers.has(section_id)


## 注册工具快照 provider。用于扩展或项目把 get_debug_snapshot() 风格数据贡献到 tools 字段。
## @param tool_id: tools 内部字段名。
## @param provider: 无参数采样回调，建议返回 Dictionary。
## @return 注册成功返回 true。
func register_tool_snapshot_provider(tool_id: StringName, provider: Callable) -> bool:
	if tool_id == &"" or not provider.is_valid():
		return false
	_tool_snapshot_providers[tool_id] = provider
	return true


## 注销工具快照 provider。
## @param tool_id: tools 内部字段名。
func unregister_tool_snapshot_provider(tool_id: StringName) -> void:
	_tool_snapshot_providers.erase(tool_id)


## 检查工具快照 provider 是否存在。
## @param tool_id: tools 内部字段名。
## @return 存在返回 true。
func has_tool_snapshot_provider(tool_id: StringName) -> bool:
	return _tool_snapshot_providers.has(tool_id)


## 采集诊断监控快照。
## @param monitor_ids: 指定监控项；为空时采集全部可见监控项。
## @param include_hidden: 为 true 时包含 visible=false 的监控项。
## @return 监控快照字典。
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
## @param preset_id: 预设唯一标识。
## @param include_hidden: 为 true 时包含 visible=false 的监控项。
## @return 监控快照字典。
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
## @param snapshot: collect_monitor_snapshot() 或 collect_monitor_preset() 返回值。
## @param format: 导出格式，支持 json、text、csv。
## @return 导出文本。
func export_monitor_snapshot(snapshot: Dictionary, format: StringName = &"json") -> String:
	match format:
		&"text":
			return _export_monitor_snapshot_as_text(snapshot)
		&"csv":
			return _export_monitor_snapshot_as_csv(snapshot)
		_:
			return JSON.stringify(snapshot, "\t")


## 设置诊断认证 token。
## @param token: token 文本。
## @param required: 是否立即启用 token 校验。
func set_auth_token(token: String, required: bool = true) -> void:
	auth_token = token
	require_auth_token = required


## 执行诊断命令。
## @param command_name: 命令名。
## @param args: 命令参数。
## @return 统一结果字典。
func execute_command(command_name: StringName, args: Dictionary = {}) -> Dictionary:
	if not _commands.has(command_name):
		var missing_result := _make_command_result(false, null, "Missing diagnostic command: %s" % String(command_name))
		diagnostic_command_executed.emit(command_name, missing_result)
		return missing_result

	var entry := _commands[command_name] as Dictionary
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

	var callback: Callable = entry.get("callback")
	if not callback.is_valid():
		var invalid_result := _make_command_result(false, null, "Diagnostic command callback is invalid: %s" % String(command_name))
		diagnostic_command_executed.emit(command_name, invalid_result)
		return invalid_result

	var value: Variant = callback.call(args.duplicate(true))
	var result := _make_command_result(true, value, "", {
		"tier": tier,
		"tier_name": _get_tier_name(tier),
	})
	diagnostic_command_executed.emit(command_name, result)
	return result


## 采集运行时诊断快照。
## @param options: 可选参数，支持 recent_log_count、include_recent_logs、include_scene_tree、scene_tree_options。
## @return 快照字典。
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
## @return 性能数据字典。
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
## @param recent_log_count: 最近日志数量。
## @param include_recent_logs: 是否包含日志条目。
## @return 日志数据字典。
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
## @param root: 可选根节点；为空时优先使用当前场景，再回退到 Viewport root。
## @param options: 可选参数，支持 max_depth、max_nodes、include_groups、include_owner_path、include_script_path、include_internal。
## @return 场景树快照字典。
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
