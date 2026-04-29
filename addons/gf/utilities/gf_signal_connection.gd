## GFSignalConnection: 可管理的 Godot Signal 链式连接。
##
## 连接支持默认参数、过滤、映射、延迟、防抖、一次性触发和 owner 归属清理。
class_name GFSignalConnection
extends RefCounted


# --- 枚举 ---

enum OperationType {
	FILTER,
	MAP,
	DELAY,
	DEBOUNCE,
}


# --- 私有变量 ---

var _source_signal: Signal
var _callback: Callable
var _owner_ref: WeakRef = null
var _utility_ref: WeakRef = null
var _default_args: Array = []
var _connect_flags: int = 0
var _operations: Array[Dictionary] = []
var _is_once: bool = false
var _is_connected: bool = false
var _serial: int = 0


# --- Godot 生命周期方法 ---

func _init(
	source_signal: Signal,
	callback: Callable,
	owner: Object = null,
	default_args: Array = [],
	connect_flags: int = 0,
	utility: Object = null
) -> void:
	_source_signal = source_signal
	_callback = callback
	_owner_ref = weakref(owner) if owner != null else null
	_default_args = default_args.duplicate()
	_connect_flags = connect_flags
	_utility_ref = weakref(utility) if utility != null else null


# --- 公共方法 ---

## 增加过滤步骤。predicate 返回 false 时停止本次回调。
func filter(predicate: Callable) -> GFSignalConnection:
	if predicate.is_valid():
		_operations.append({
			"type": OperationType.FILTER,
			"callable": predicate,
		})
	return self


## 增加映射步骤。mapper 的返回值会替换后续回调参数。
func map(mapper: Callable) -> GFSignalConnection:
	if mapper.is_valid():
		_operations.append({
			"type": OperationType.MAP,
			"callable": mapper,
		})
	return self


## 延迟指定秒数后再继续处理。
func delay(seconds: float) -> GFSignalConnection:
	_operations.append({
		"type": OperationType.DELAY,
		"seconds": maxf(seconds, 0.0),
	})
	return self


## 防抖处理。连续触发时只保留静默期后的最后一次。
func debounce(seconds: float) -> GFSignalConnection:
	_operations.append({
		"type": OperationType.DEBOUNCE,
		"seconds": maxf(seconds, 0.0),
	})
	return self


## 设置为一次性连接，首次成功触发后自动断开。
func once() -> GFSignalConnection:
	_is_once = true
	return self


## 启动连接。
func start() -> GFSignalConnection:
	if _is_connected:
		return self
	if _source_signal.is_null():
		push_error("[GFSignalConnection] start 失败：Signal 为空。")
		return self
	if not _callback.is_valid():
		push_error("[GFSignalConnection] start 失败：callback 无效。")
		return self

	_source_signal.connect(_on_signal_emitted, _connect_flags)
	_is_connected = true
	return self


## 主动断开连接。
func disconnect_signal() -> void:
	_serial += 1
	if not _is_connected:
		return
	if not _source_signal.is_null() and is_instance_valid(_source_signal.get_object()):
		if _source_signal.is_connected(_on_signal_emitted):
			_source_signal.disconnect(_on_signal_emitted)
	_is_connected = false


## 当前连接是否仍有效。
func is_active() -> bool:
	return _is_connected


## 当前连接是否属于指定 owner。
func is_owned_by(owner: Object) -> bool:
	if owner == null or _owner_ref == null:
		return false
	return _owner_ref.get_ref() == owner


## 检查连接是否匹配指定 Signal、回调和可选 owner。
func matches(source_signal: Signal, callback: Callable, owner: Object = null) -> bool:
	if _source_signal != source_signal:
		return false
	if _callback != callback:
		return false
	if owner != null and not is_owned_by(owner):
		return false
	return true


## owner 或 signal 发射源失效时清理连接。
func prune_if_invalid() -> bool:
	if _source_signal.is_null():
		disconnect_signal()
		return true
	var source_obj := _source_signal.get_object()
	if not is_instance_valid(source_obj):
		disconnect_signal()
		return true
	if _owner_ref != null and _owner_ref.get_ref() == null:
		disconnect_signal()
		return true
	return false


# --- 私有/辅助方法 ---

func _on_signal_emitted(
	arg1: Variant = null,
	arg2: Variant = null,
	arg3: Variant = null,
	arg4: Variant = null,
	arg5: Variant = null,
	arg6: Variant = null,
	arg7: Variant = null,
	arg8: Variant = null
) -> void:
	var args := _collect_args([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8])
	_serial += 1
	_process_async(args, _serial)


func _process_async(args: Array, serial: int) -> void:
	var current_args := args.duplicate()
	for operation: Dictionary in _operations:
		if serial != _serial or prune_if_invalid():
			return

		match int(operation["type"]):
			OperationType.FILTER:
				var predicate := operation["callable"] as Callable
				if not bool(predicate.callv(current_args)):
					return

			OperationType.MAP:
				var mapper := operation["callable"] as Callable
				var mapped: Variant = mapper.callv(current_args)
				current_args = mapped if mapped is Array else [mapped]

			OperationType.DELAY:
				await _wait_seconds(float(operation["seconds"]), serial)

			OperationType.DEBOUNCE:
				await _wait_seconds(float(operation["seconds"]), serial)
				await _wait_process_frame(serial)
				if serial != _serial:
					return

	if serial != _serial or prune_if_invalid():
		return

	var final_args := _default_args.duplicate()
	final_args.append_array(current_args)
	_callback.callv(final_args)

	if _is_once:
		disconnect_signal()
		_unregister_from_utility()


func _wait_seconds(seconds: float, serial: int) -> void:
	if seconds <= 0.0:
		return

	var start_msec := Time.get_ticks_msec()
	var wait_msec := int(seconds * 1000.0)
	while serial == _serial and Time.get_ticks_msec() - start_msec < wait_msec:
		await Engine.get_main_loop().process_frame


func _wait_process_frame(serial: int) -> void:
	if serial != _serial:
		return

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return

	await tree.process_frame


func _collect_args(raw_args: Array) -> Array:
	var declared_count := _get_source_signal_argument_count()
	if declared_count >= 0:
		return raw_args.slice(0, mini(declared_count, raw_args.size()))

	var args: Array = raw_args.duplicate()
	while not args.is_empty() and args.back() == null:
		args.pop_back()
	return args


func _get_source_signal_argument_count() -> int:
	if _source_signal.is_null():
		return -1

	var source_obj := _source_signal.get_object()
	if not is_instance_valid(source_obj):
		return -1

	var signal_name := String(_source_signal.get_name())
	for signal_info: Dictionary in source_obj.get_signal_list():
		if String(signal_info.get("name", "")) != signal_name:
			continue

		var args: Array = signal_info.get("args", [])
		return args.size()

	return -1


func _unregister_from_utility() -> void:
	if _utility_ref == null:
		return
	var utility := _utility_ref.get_ref()
	if utility != null and utility.has_method("_untrack_connection"):
		utility.call("_untrack_connection", self)
