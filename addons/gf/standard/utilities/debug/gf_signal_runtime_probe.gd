## GFSignalRuntimeProbe: 运行时信号发射追踪器。
##
## 以显式 watch 的方式连接节点信号，并把实际发射记录为只读事件快照。
## 它不修改被观察节点，不解释业务语义，也不应默认用于生产环境全局采样。
class_name GFSignalRuntimeProbe
extends RefCounted


# --- 信号 ---

## 记录到信号发射事件后发出。
## @param event: 发射事件快照。
signal signal_emitted(event: Dictionary)

## 开始监听一个节点信号后发出。
## @param source_path: 信号来源节点路径。
## @param signal_name: 信号名称。
signal signal_watch_started(source_path: String, signal_name: StringName)

## 停止监听一个节点信号后发出。
## @param source_path: 信号来源节点路径。
## @param signal_name: 信号名称。
signal signal_watch_stopped(source_path: String, signal_name: StringName)


# --- 常量 ---

const DEFAULT_MAX_EVENTS: int = 256
const DEFAULT_MAX_ARGUMENT_COUNT: int = 8


# --- 公共变量 ---

## 最多保留的最近事件数量。小于等于 0 表示不保留历史，只发出 signal_emitted。
var max_events: int = DEFAULT_MAX_EVENTS

## 单个信号最多支持追踪的参数数量。
var max_argument_count: int = DEFAULT_MAX_ARGUMENT_COUNT


# --- 私有变量 ---

var _watched: Dictionary = {}
var _events: Array[Dictionary] = []


# --- 公共方法 ---

## 监听单个节点的信号。
## @param source: 需要观察的节点。
## @param options: 选项，支持 include_signals、exclude_signals、include_internal、max_argument_count 与 connect_flags。
## @return 监听报告。
func watch_node(source: Node, options: Dictionary = {}) -> Dictionary:
	if source == null:
		return _make_report(false, 0, 0, ["source_is_null"])

	var include_names := _to_string_name_filter(options.get("include_signals", []))
	var exclude_names := _to_string_name_filter(options.get("exclude_signals", []))
	var include_internal := bool(options.get("include_internal", false))
	var limit := int(options.get("max_argument_count", max_argument_count))
	var connect_flags := int(options.get("connect_flags", 0))
	var watched_count := 0
	var skipped_count := 0
	var errors: Array[String] = []

	for signal_info: Dictionary in source.get_signal_list():
		var signal_name := StringName(signal_info.get("name", ""))
		if signal_name == &"":
			skipped_count += 1
			continue
		if not include_internal and String(signal_name).begins_with("_"):
			skipped_count += 1
			continue
		if not include_names.is_empty() and not include_names.has(signal_name):
			skipped_count += 1
			continue
		if exclude_names.has(signal_name):
			skipped_count += 1
			continue

		var argument_count := _get_signal_argument_count(signal_info)
		if argument_count > limit:
			skipped_count += 1
			errors.append("too_many_arguments:%s" % String(signal_name))
			continue

		var error := _watch_signal(source, signal_name, argument_count, connect_flags)
		if error == OK:
			watched_count += 1
		elif error == ERR_ALREADY_EXISTS:
			skipped_count += 1
		else:
			skipped_count += 1
			errors.append("%s:%s" % [String(signal_name), error_string(error)])

	return _make_report(errors.is_empty(), watched_count, skipped_count, errors)


## 递归监听节点树。
## @param root: 需要观察的根节点。
## @param options: 选项，支持 watch_node() 选项以及 recursive、include_internal_nodes。
## @return 监听报告。
func watch_tree(root: Node, options: Dictionary = {}) -> Dictionary:
	if root == null:
		return _make_report(false, 0, 0, ["root_is_null"])

	var recursive := bool(options.get("recursive", true))
	var include_internal_nodes := bool(options.get("include_internal_nodes", false))
	var nodes: Array[Node] = []
	_collect_nodes(root, nodes, recursive, include_internal_nodes)

	var total_watched := 0
	var total_skipped := 0
	var errors: Array[String] = []
	for node: Node in nodes:
		var report := watch_node(node, options)
		total_watched += int(report.get("watched_count", 0))
		total_skipped += int(report.get("skipped_count", 0))
		for error_variant: Variant in report.get("errors", []):
			errors.append(String(error_variant))

	return _make_report(errors.is_empty(), total_watched, total_skipped, errors)


## 停止监听某个节点。
## @param source: 需要停止观察的节点。
## @return 断开的信号数量。
func unwatch_node(source: Node) -> int:
	if source == null:
		return 0

	var source_id := source.get_instance_id()
	var removed_count := 0
	for key: String in _watched.keys().duplicate():
		var entry := _watched[key] as Dictionary
		if entry == null or int(entry.get("source_id", 0)) != source_id:
			continue
		if _disconnect_entry(entry):
			removed_count += 1
		_watched.erase(key)
	return removed_count


## 停止所有监听。
## @return 断开的信号数量。
func unwatch_all() -> int:
	var removed_count := 0
	for key: String in _watched.keys().duplicate():
		var entry := _watched[key] as Dictionary
		if entry != null and _disconnect_entry(entry):
			removed_count += 1
		_watched.erase(key)
	return removed_count


## 清空最近事件。
func clear_events() -> void:
	_events.clear()


## 获取最近事件副本。
## @return 事件快照数组。
func get_events() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event: Dictionary in _events:
		result.append(event.duplicate(true))
	return result


## 获取被监听的信号数量。
func get_watch_count() -> int:
	_prune_invalid_watches()
	return _watched.size()


## 获取调试快照。
## @return 调试信息字典。
func get_debug_snapshot() -> Dictionary:
	_prune_invalid_watches()
	return {
		"watch_count": _watched.size(),
		"event_count": _events.size(),
		"max_events": max_events,
		"max_argument_count": max_argument_count,
		"watches": _describe_watches(),
	}


# --- 私有/辅助方法 ---

func _watch_signal(source: Node, signal_name: StringName, argument_count: int, connect_flags: int) -> Error:
	var key := _make_watch_key(source.get_instance_id(), signal_name)
	if _watched.has(key):
		return ERR_ALREADY_EXISTS

	var source_path := _get_node_path_text(source)
	var callback := _make_emit_callable(argument_count).bind(source.get_instance_id(), source_path, signal_name)
	if not callback.is_valid():
		return ERR_INVALID_PARAMETER
	if source.is_connected(signal_name, callback):
		return ERR_ALREADY_EXISTS

	var error := source.connect(signal_name, callback, connect_flags)
	if error != OK:
		return error

	_watched[key] = {
		"source_ref": weakref(source),
		"source_id": source.get_instance_id(),
		"source_path": source_path,
		"signal_name": signal_name,
		"argument_count": argument_count,
		"callable": callback,
	}
	signal_watch_started.emit(source_path, signal_name)
	return OK


func _disconnect_entry(entry: Dictionary) -> bool:
	var source_ref := entry.get("source_ref") as WeakRef
	var source := source_ref.get_ref() as Node if source_ref != null else null
	var signal_name := StringName(entry.get("signal_name", ""))
	var callback := entry.get("callable") as Callable
	if source == null or signal_name == &"" or not callback.is_valid():
		return false
	if source.is_connected(signal_name, callback):
		source.disconnect(signal_name, callback)
		signal_watch_stopped.emit(String(entry.get("source_path", "")), signal_name)
		return true
	return false


func _record_signal(source_id: int, source_path: String, signal_name: StringName, arguments: Array) -> void:
	var source := instance_from_id(source_id) as Node
	var event := {
		"timestamp_msec": Time.get_ticks_msec(),
		"process_frame": Engine.get_process_frames(),
		"physics_frame": Engine.get_physics_frames(),
		"source_instance_id": source_id,
		"source_node_path": _get_node_path_text(source) if source != null else source_path,
		"signal_name": String(signal_name),
		"argument_count": arguments.size(),
		"arguments": arguments.duplicate(false),
		"connections": _describe_signal_connections(source, signal_name),
	}
	if max_events > 0:
		_events.append(event)
		while _events.size() > max_events:
			_events.pop_front()
	signal_emitted.emit(event.duplicate(true))


func _describe_signal_connections(source: Node, signal_name: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if source == null or signal_name == &"":
		return result

	for connection_info: Dictionary in source.get_signal_connection_list(signal_name):
		var callable := connection_info.get("callable") as Callable
		var target := callable.get_object() if callable.is_valid() else null
		result.append({
			"target": str(target),
			"method_name": callable.get_method() if callable.is_valid() else "",
			"flags": int(connection_info.get("flags", 0)),
		})
	return result


func _describe_watches() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry_variant: Variant in _watched.values():
		var entry := entry_variant as Dictionary
		if entry == null:
			continue
		result.append({
			"source_path": String(entry.get("source_path", "")),
			"signal_name": String(entry.get("signal_name", "")),
			"argument_count": int(entry.get("argument_count", 0)),
		})
	return result


func _make_emit_callable(argument_count: int) -> Callable:
	match argument_count:
		0:
			return Callable(self, "_on_signal_emitted_0")
		1:
			return Callable(self, "_on_signal_emitted_1")
		2:
			return Callable(self, "_on_signal_emitted_2")
		3:
			return Callable(self, "_on_signal_emitted_3")
		4:
			return Callable(self, "_on_signal_emitted_4")
		5:
			return Callable(self, "_on_signal_emitted_5")
		6:
			return Callable(self, "_on_signal_emitted_6")
		7:
			return Callable(self, "_on_signal_emitted_7")
		8:
			return Callable(self, "_on_signal_emitted_8")
		_:
			return Callable()


func _get_signal_argument_count(signal_info: Dictionary) -> int:
	var arguments := signal_info.get("args", [])
	return arguments.size() if arguments is Array else 0


func _to_string_name_filter(value: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if value is PackedStringArray:
		for item: String in value:
			result.append(StringName(item))
	elif value is Array:
		for item_variant: Variant in value:
			result.append(StringName(str(item_variant)))
	elif value is String or value is StringName:
		result.append(StringName(value))
	return result


func _collect_nodes(root: Node, result: Array[Node], recursive: bool, include_internal_nodes: bool) -> void:
	result.append(root)
	if not recursive:
		return

	for child: Node in root.get_children(include_internal_nodes):
		_collect_nodes(child, result, recursive, include_internal_nodes)


func _prune_invalid_watches() -> void:
	for key: String in _watched.keys().duplicate():
		var entry := _watched[key] as Dictionary
		var source_ref := entry.get("source_ref") as WeakRef if entry != null else null
		if source_ref == null or source_ref.get_ref() == null:
			_watched.erase(key)


func _get_node_path_text(node: Node) -> String:
	if node == null:
		return ""
	if node.is_inside_tree():
		return str(node.get_path())
	return node.name


func _make_watch_key(source_id: int, signal_name: StringName) -> String:
	return "%d:%s" % [source_id, String(signal_name)]


func _make_report(ok: bool, watched_count: int, skipped_count: int, errors: Array[String]) -> Dictionary:
	return {
		"ok": ok,
		"watched_count": watched_count,
		"skipped_count": skipped_count,
		"errors": errors.duplicate(),
	}


# --- 信号处理函数 ---

func _on_signal_emitted_0(source_id: int, source_path: String, signal_name: StringName) -> void:
	_record_signal(source_id, source_path, signal_name, [])


func _on_signal_emitted_1(arg0: Variant, source_id: int, source_path: String, signal_name: StringName) -> void:
	_record_signal(source_id, source_path, signal_name, [arg0])


func _on_signal_emitted_2(
	arg0: Variant,
	arg1: Variant,
	source_id: int,
	source_path: String,
	signal_name: StringName
) -> void:
	_record_signal(source_id, source_path, signal_name, [arg0, arg1])


func _on_signal_emitted_3(
	arg0: Variant,
	arg1: Variant,
	arg2: Variant,
	source_id: int,
	source_path: String,
	signal_name: StringName
) -> void:
	_record_signal(source_id, source_path, signal_name, [arg0, arg1, arg2])


func _on_signal_emitted_4(
	arg0: Variant,
	arg1: Variant,
	arg2: Variant,
	arg3: Variant,
	source_id: int,
	source_path: String,
	signal_name: StringName
) -> void:
	_record_signal(source_id, source_path, signal_name, [arg0, arg1, arg2, arg3])


func _on_signal_emitted_5(
	arg0: Variant,
	arg1: Variant,
	arg2: Variant,
	arg3: Variant,
	arg4: Variant,
	source_id: int,
	source_path: String,
	signal_name: StringName
) -> void:
	_record_signal(source_id, source_path, signal_name, [arg0, arg1, arg2, arg3, arg4])


func _on_signal_emitted_6(
	arg0: Variant,
	arg1: Variant,
	arg2: Variant,
	arg3: Variant,
	arg4: Variant,
	arg5: Variant,
	source_id: int,
	source_path: String,
	signal_name: StringName
) -> void:
	_record_signal(source_id, source_path, signal_name, [arg0, arg1, arg2, arg3, arg4, arg5])


func _on_signal_emitted_7(
	arg0: Variant,
	arg1: Variant,
	arg2: Variant,
	arg3: Variant,
	arg4: Variant,
	arg5: Variant,
	arg6: Variant,
	source_id: int,
	source_path: String,
	signal_name: StringName
) -> void:
	_record_signal(source_id, source_path, signal_name, [arg0, arg1, arg2, arg3, arg4, arg5, arg6])


func _on_signal_emitted_8(
	arg0: Variant,
	arg1: Variant,
	arg2: Variant,
	arg3: Variant,
	arg4: Variant,
	arg5: Variant,
	arg6: Variant,
	arg7: Variant,
	source_id: int,
	source_path: String,
	signal_name: StringName
) -> void:
	_record_signal(source_id, source_path, signal_name, [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7])
