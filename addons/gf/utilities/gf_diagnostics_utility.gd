## GFDiagnosticsUtility: 运行时诊断聚合工具。
##
## 提供架构生命周期、事件系统、性能、日志和可选网络状态的统一快照。
## 诊断命令通过 Callable 注册，框架只负责调度和包装结果，不解释项目业务数据。
class_name GFDiagnosticsUtility
extends GFUtility


# --- 信号 ---

## 采集快照后发出。
signal snapshot_collected(snapshot: Dictionary)

## 执行诊断命令后发出。
signal diagnostic_command_executed(command_name: StringName, result: Dictionary)


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


# --- 私有变量 ---

var _commands: Dictionary = {}
var _console_utility: GFConsoleUtility = null
var _console_command_registered: bool = false


# --- Godot 生命周期方法 ---

func init() -> void:
	register_command(&"diagnostics.snapshot", Callable(self, "_command_collect_snapshot"), "采集 GF 诊断快照。", CommandTier.OBSERVE)
	register_command(&"diagnostics.performance", Callable(self, "_command_collect_performance"), "采集性能监视器快照。", CommandTier.OBSERVE)
	register_command(&"diagnostics.logs", Callable(self, "_command_collect_logs"), "读取最近日志缓存。", CommandTier.OBSERVE)


func ready() -> void:
	_bind_console_command()


func dispose() -> void:
	if _console_utility != null and _console_command_registered:
		_console_utility.unregister_command("diagnostics")
	_console_utility = null
	_console_command_registered = false
	_commands.clear()


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
## @param options: 可选参数，支持 recent_log_count、include_recent_logs。
## @return 快照字典。
func collect_snapshot(options: Dictionary = {}) -> Dictionary:
	var snapshot := {
		"timestamp_unix": Time.get_unix_time_from_system(),
		"engine": Engine.get_version_info(),
		"architecture": {},
		"event_system": {},
		"performance": {},
		"logs": {},
		"network": {},
	}

	var architecture := _get_architecture_or_null()
	if architecture != null:
		snapshot["architecture"] = architecture.get_debug_lifecycle_state()
		snapshot["event_system"] = architecture.get_event_debug_stats()

	if include_performance_monitors:
		snapshot["performance"] = collect_performance_snapshot()

	snapshot["logs"] = collect_log_snapshot(
		int(options.get("recent_log_count", default_recent_log_count)),
		bool(options.get("include_recent_logs", true))
	)

	var network_utility := get_utility(GFNetworkUtility) as GFNetworkUtility
	if network_utility != null:
		snapshot["network"] = network_utility.get_debug_snapshot()

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
