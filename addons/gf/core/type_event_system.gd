class_name TypeEventSystem


## TypeEventSystem: 基于类型和 StringName 的双轨事件系统内部实现。
##
## 轨道一（类型事件）：使用 Script 类型作为键，以对象实例为载体分发事件。
##   支持回调优先级（数值越大优先级越高）和事件消费拦截机制。
## 轨道二（简单事件）：使用 StringName 作为键，以 Variant 为 payload 分发事件。
##   简单事件专为 _process 等高频场景设计，避免 new() 实例化带来的 GC 压力。


# --- 私有变量 ---

var _event_listeners: Dictionary = {}
var _simple_event_listeners: Dictionary = {}

var _is_iterating_type: bool = false
var _type_dispatch_depth: int = 0
var _pending_removes_type: Array = []
var _pending_adds_type: Array = []

var _is_iterating_simple: bool = false
var _simple_dispatch_depth: int = 0
var _pending_removes_simple: Array = []
var _pending_adds_simple: Array = []


# --- 公共方法 (类型事件) ---

## 注册特定脚本类型的事件监听器。
## 回调按 priority 从高到低排序存储，相同优先级保持注册顺序。
## @param event_type: 要监听的脚本类型。
## @param on_event: 事件发送时执行的回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register(event_type: Script, on_event: Callable, priority: int = 0) -> void:
	assert(on_event.is_valid(), "[TypeEventSystem] 尝试注册无效的事件回调函数。")
	_validate_callable_min_args(on_event, 1, "类型事件回调", "事件实例")

	if _type_dispatch_depth > 0:
		_pending_adds_type.append({"event_type": event_type, "callable": on_event, "priority": priority})
		return

	if not _event_listeners.has(event_type):
		_event_listeners[event_type] = []
	var listeners := _event_listeners[event_type] as Array

	for entry: Dictionary in listeners:
		if entry.callable == on_event:
			return

	var new_entry: Dictionary = {"callable": on_event, "priority": priority}
	var inserted: bool = false
	for i: int in range(listeners.size()):
		var entry := listeners[i] as Dictionary
		if priority > entry.priority:
			listeners.insert(i, new_entry)
			inserted = true
			break
	if not inserted:
		listeners.append(new_entry)


## 注销特定脚本类型的事件监听器。
## @param event_type: 要注销的脚本类型。
## @param on_event: 要移除的回调函数。
func unregister(event_type: Script, on_event: Callable) -> void:
	if _event_listeners.has(event_type):
		if _type_dispatch_depth > 0:
			_remove_pending_type_add(event_type, on_event)
			_pending_removes_type.append({"event_type": event_type, "callable": on_event})
			return

		var listeners := _event_listeners[event_type] as Array
		for i: int in range(listeners.size()):
			var entry := listeners[i] as Dictionary
			if entry.callable == on_event:
				listeners.remove_at(i)
				return


## 将事件实例发送给其脚本类型的所有注册监听器。
## 遍历前标记正在迭代，结束后统一清理已注销和失效的监听器，避免在循环中 duplicate 数组。
## 若事件实例具有 is_consumed 属性且被设为 true，则立即中断后续回调的执行。
## @param event_instance: 要分发的事件实例。
func send(event_instance: Object) -> void:
	var event_type: Variant = event_instance.get_script()
	assert(event_type != null, "[TypeEventSystem] 发送的事件实例必须附加继承了 RefCounted 或 Object 的脚本类！")

	if event_type == null:
		push_error("[GDCore] 发送的事件必须是附加了脚本的类实例。")
		return
	if _event_listeners.has(event_type):
		var listeners := _event_listeners[event_type] as Array

		_type_dispatch_depth += 1
		_is_iterating_type = true

		for entry: Dictionary in listeners:
			var callback: Callable = entry.callable

			if not callback.is_valid() or (callback.get_object() != null and not is_instance_valid(callback.get_object())):
				_pending_removes_type.append({"event_type": event_type, "callable": callback})
				continue

			if _is_pending_type_remove(event_type, callback):
				continue

			callback.call(event_instance)

			if event_instance.get("is_consumed") == true:
				break

		_type_dispatch_depth -= 1
		_is_iterating_type = _type_dispatch_depth > 0
		if _type_dispatch_depth == 0:
			_flush_type_pending()


# --- 公共方法 (简单事件) ---

## 注册轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param on_event: 回调函数，签名为 func(payload: Variant)。
func register_simple(event_id: StringName, on_event: Callable) -> void:
	assert(on_event.is_valid(), "[TypeEventSystem] 尝试注册无效的简单事件回调函数。")
	_validate_callable_min_args(on_event, 1, "简单事件回调", "payload")

	if _simple_dispatch_depth > 0:
		_pending_adds_simple.append({"event_id": event_id, "callable": on_event})
		return

	if not _simple_event_listeners.has(event_id):
		_simple_event_listeners[event_id] = []
	var listeners := _simple_event_listeners[event_id] as Array
	if not listeners.has(on_event):
		listeners.append(on_event)


## 注销轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param on_event: 要移除的回调函数。
func unregister_simple(event_id: StringName, on_event: Callable) -> void:
	if _simple_event_listeners.has(event_id):
		if _simple_dispatch_depth > 0:
			_remove_pending_simple_add(event_id, on_event)
			_pending_removes_simple.append({"event_id": event_id, "callable": on_event})
			return
		var listeners := _simple_event_listeners[event_id] as Array
		listeners.erase(on_event)


## 将 payload 发送给指定 StringName 事件的所有注册监听器。
## 遍历前标记正在迭代，结束后统一清理已注销和失效的监听器，避免在循环中 duplicate 数组。
## @param event_id: StringName 事件标识符。
## @param payload: 传递给监听器的数据，可为任意类型。
func send_simple(event_id: StringName, payload: Variant = null) -> void:
	if not _simple_event_listeners.has(event_id):
		return
	var listeners := _simple_event_listeners[event_id] as Array

	_simple_dispatch_depth += 1
	_is_iterating_simple = true

	for callback: Callable in listeners:
		if not callback.is_valid() or (callback.get_object() != null and not is_instance_valid(callback.get_object())):
			_pending_removes_simple.append({"event_id": event_id, "callable": callback})
			continue

		if _is_pending_simple_remove(event_id, callback):
			continue

		callback.call(payload)

	_simple_dispatch_depth -= 1
	_is_iterating_simple = _simple_dispatch_depth > 0
	if _simple_dispatch_depth == 0:
		_flush_simple_pending()


## 清空所有已注册的事件监听器（包括类型事件和简单事件）。
func clear() -> void:
	_event_listeners.clear()
	_simple_event_listeners.clear()
	_pending_removes_type.clear()
	_pending_removes_simple.clear()
	_pending_adds_type.clear()
	_pending_adds_simple.clear()
	_type_dispatch_depth = 0
	_simple_dispatch_depth = 0
	_is_iterating_type = false
	_is_iterating_simple = false


# --- 私有/辅助方法 ---

func _is_pending_type_remove(event_type: Script, on_event: Callable) -> bool:
	for pending: Dictionary in _pending_removes_type:
		if pending.event_type == event_type and pending.callable == on_event:
			return true
	return false


func _is_pending_simple_remove(event_id: StringName, on_event: Callable) -> bool:
	for pending: Dictionary in _pending_removes_simple:
		if pending.event_id == event_id and pending.callable == on_event:
			return true
	return false


func _remove_pending_type_add(event_type: Script, on_event: Callable) -> void:
	for i: int in range(_pending_adds_type.size() - 1, -1, -1):
		var pending := _pending_adds_type[i] as Dictionary
		if pending.event_type == event_type and pending.callable == on_event:
			_pending_adds_type.remove_at(i)


func _remove_pending_simple_add(event_id: StringName, on_event: Callable) -> void:
	for i: int in range(_pending_adds_simple.size() - 1, -1, -1):
		var pending := _pending_adds_simple[i] as Dictionary
		if pending.event_id == event_id and pending.callable == on_event:
			_pending_adds_simple.remove_at(i)


func _flush_type_pending() -> void:
	for pending: Dictionary in _pending_removes_type:
		if _event_listeners.has(pending.event_type):
			var listeners := _event_listeners[pending.event_type] as Array
			for i: int in range(listeners.size() - 1, -1, -1):
				var entry := listeners[i] as Dictionary
				if entry.callable == pending.callable:
					listeners.remove_at(i)
					break
	_pending_removes_type.clear()

	for pending: Dictionary in _pending_adds_type:
		register(pending.event_type, pending.callable, pending.priority)
	_pending_adds_type.clear()


func _flush_simple_pending() -> void:
	for pending: Dictionary in _pending_removes_simple:
		if _simple_event_listeners.has(pending.event_id):
			var listeners := _simple_event_listeners[pending.event_id] as Array
			listeners.erase(pending.callable)
	_pending_removes_simple.clear()

	for pending: Dictionary in _pending_adds_simple:
		register_simple(pending.event_id, pending.callable)
	_pending_adds_simple.clear()


func _validate_callable_min_args(on_event: Callable, min_args: int, callback_label: String, arg_label: String) -> void:
	# 运行时只可靠检查对象方法；匿名函数/custom callable 在 Godot 中缺少稳定的参数反射。
	var target_obj: Object = on_event.get_object()
	if target_obj == null or on_event.is_custom():
		return

	var method_name: StringName = on_event.get_method()
	var methods: Array[Dictionary] = target_obj.get_method_list()
	for m: Dictionary in methods:
		if m["name"] == String(method_name):
			assert(
				m["args"].size() >= min_args,
				"[TypeEventSystem] 注册的%s %s 必须至少包含 %d 个参数用于接收%s！" % [
					callback_label,
					method_name,
					min_args,
					arg_label,
				]
			)
			break
