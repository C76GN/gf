## TypeEventSystem: 基于类型和 StringName 的双轨事件系统内部实现。
##
## 轨道一（类型事件）：使用 Script 类型作为键，以对象实例为载体分发事件。
## 轨道二（简单事件）：使用 StringName 作为键，以 Variant 为 payload 分发事件。
class_name TypeEventSystem


# --- 私有变量 ---

var _event_listeners: Dictionary = {}
var _assignable_event_listeners: Dictionary = {}
var _simple_event_listeners: Dictionary = {}
var _type_dispatch_cache: Dictionary = {}

var _is_iterating_type: bool = false
var _type_dispatch_depth: int = 0
var _clear_requested_type: bool = false
var _pending_removes_type: Array = []
var _pending_adds_type: Array = []
var _pending_removes_assignable_type: Array = []
var _pending_adds_assignable_type: Array = []
var _pending_owner_removes_type: Array[int] = []

var _is_iterating_simple: bool = false
var _simple_dispatch_depth: int = 0
var _clear_requested_simple: bool = false
var _pending_removes_simple: Array = []
var _pending_adds_simple: Array = []
var _pending_owner_removes_simple: Array[int] = []
var _listener_order_counter: int = 0


# --- 公共方法 (类型事件) ---

## 注册特定脚本类型的事件监听器。
## @param event_type: 要监听的脚本类型。
## @param on_event: 事件发送时执行的回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
## @param owner: 可选监听拥有者，用于批量注销。
func register(event_type: Script, on_event: Callable, priority: int = 0, owner: Object = null) -> void:
	if event_type == null:
		push_error("[TypeEventSystem] register 失败：event_type 为空。")
		return
	if not _validate_callable_min_args(on_event, 1, "类型事件回调", "事件实例"):
		return

	if _type_dispatch_depth > 0:
		_pending_adds_type.append({
			"event_type": event_type,
			"callable": on_event,
			"priority": priority,
			"owner_ref": _make_owner_ref(owner),
			"owner_id": _owner_instance_id(owner),
			"order": _next_listener_order(),
		})
		return

	_add_listener_entry(_event_listeners, event_type, on_event, priority, owner, _next_listener_order())


## 注销特定脚本类型的事件监听器。
## @param event_type: 要注销的脚本类型。
## @param on_event: 要移除的回调函数。
func unregister(event_type: Script, on_event: Callable) -> void:
	if _event_listeners.has(event_type):
		if _type_dispatch_depth > 0:
			_remove_pending_type_add(event_type, on_event)
			_pending_removes_type.append({ "event_type": event_type, "callable": on_event })
			return

		var listeners := _event_listeners[event_type] as Array
		_remove_entry_by_callable(listeners, on_event)


## 注册可赋值类型事件监听器。
## 监听 base_event_type 时，也会收到继承自该脚本类型的事件实例。
## @param base_event_type: 要监听的基类脚本类型。
## @param on_event: 事件发送时执行的回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
## @param owner: 可选监听拥有者，用于批量注销。
func register_assignable(base_event_type: Script, on_event: Callable, priority: int = 0, owner: Object = null) -> void:
	if base_event_type == null:
		push_error("[TypeEventSystem] register_assignable 失败：base_event_type 为空。")
		return
	if not _validate_callable_min_args(on_event, 1, "可赋值事件回调", "事件实例"):
		return

	if _type_dispatch_depth > 0:
		_pending_adds_assignable_type.append({
			"event_type": base_event_type,
			"callable": on_event,
			"priority": priority,
			"owner_ref": _make_owner_ref(owner),
			"owner_id": _owner_instance_id(owner),
			"order": _next_listener_order(),
		})
		return

	_add_listener_entry(_assignable_event_listeners, base_event_type, on_event, priority, owner, _next_listener_order())


## 注销可赋值类型事件监听器。
## @param base_event_type: 注册时使用的基类脚本类型。
## @param on_event: 要移除的回调函数。
func unregister_assignable(base_event_type: Script, on_event: Callable) -> void:
	if _assignable_event_listeners.has(base_event_type):
		if _type_dispatch_depth > 0:
			_remove_pending_assignable_type_add(base_event_type, on_event)
			_pending_removes_assignable_type.append({ "event_type": base_event_type, "callable": on_event })
			return

		var listeners := _assignable_event_listeners[base_event_type] as Array
		_remove_entry_by_callable(listeners, on_event)


## 将事件实例发送给其脚本类型的所有注册监听器。
## @param event_instance: 要分发的事件实例。
func send(event_instance: Object) -> void:
	if event_instance == null:
		push_error("[TypeEventSystem] 发送的事件实例为空。")
		return

	var event_type: Variant = event_instance.get_script()
	if event_type == null:
		push_error("[TypeEventSystem] 发送的事件必须是附加了脚本的类实例。")
		return
	var dispatch_entries := _get_type_dispatch_entries(event_type as Script)
	if dispatch_entries.is_empty():
		return

	_type_dispatch_depth += 1
	_is_iterating_type = true

	_dispatch_type_listener_entries(event_instance, dispatch_entries)

	_type_dispatch_depth = maxi(_type_dispatch_depth - 1, 0)
	_is_iterating_type = _type_dispatch_depth > 0
	if _type_dispatch_depth == 0:
		_clear_requested_type = false
		_flush_type_pending()


# --- 公共方法 (简单事件) ---

## 注册轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param on_event: 回调函数，签名为 func(payload: Variant)。
## @param owner: 可选监听拥有者，用于批量注销。
func register_simple(event_id: StringName, on_event: Callable, owner: Object = null) -> void:
	if not _validate_callable_min_args(on_event, 1, "简单事件回调", "payload"):
		return

	if _simple_dispatch_depth > 0:
		_pending_adds_simple.append({
			"event_id": event_id,
			"callable": on_event,
			"owner_ref": _make_owner_ref(owner),
			"owner_id": _owner_instance_id(owner),
			"order": _next_listener_order(),
		})
		return

	if not _simple_event_listeners.has(event_id):
		_simple_event_listeners[event_id] = []
	var listeners := _simple_event_listeners[event_id] as Array
	for entry: Dictionary in listeners:
		if _listener_entry_matches(entry, on_event, owner):
			return

	listeners.append({
		"callable": on_event,
		"owner_ref": _make_owner_ref(owner),
		"owner_id": _owner_instance_id(owner),
		"order": _next_listener_order(),
	})


## 注销轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param on_event: 要移除的回调函数。
func unregister_simple(event_id: StringName, on_event: Callable) -> void:
	if _simple_event_listeners.has(event_id):
		if _simple_dispatch_depth > 0:
			_remove_pending_simple_add(event_id, on_event)
			_pending_removes_simple.append({ "event_id": event_id, "callable": on_event })
			return

		var listeners := _simple_event_listeners[event_id] as Array
		_remove_entry_by_callable(listeners, on_event)


## 将 payload 发送给指定 StringName 事件的所有注册监听器。
## @param event_id: StringName 事件标识符。
## @param payload: 传递给监听器的数据，可为任意类型。
func send_simple(event_id: StringName, payload: Variant = null) -> void:
	if not _simple_event_listeners.has(event_id):
		return
	var listeners := _simple_event_listeners[event_id] as Array

	_simple_dispatch_depth += 1
	_is_iterating_simple = true
	var has_pending_owner_removes := not _pending_owner_removes_simple.is_empty()
	var has_pending_removes := not _pending_removes_simple.is_empty()

	for entry: Dictionary in listeners:
		if _clear_requested_simple:
			break

		var callback: Callable = entry.callable

		if _entry_owner_is_released(entry):
			_pending_removes_simple.append({ "event_id": event_id, "callable": callback })
			has_pending_removes = true
			continue
		if has_pending_owner_removes and _is_pending_owner_remove(entry, _pending_owner_removes_simple):
			continue
		if not callback.is_valid() or (callback.get_object() != null and not is_instance_valid(callback.get_object())):
			_pending_removes_simple.append({ "event_id": event_id, "callable": callback })
			has_pending_removes = true
			continue
		if has_pending_removes and _is_pending_simple_remove(event_id, callback):
			continue

		callback.call(payload)

		if _clear_requested_simple:
			break
		if not has_pending_owner_removes and not _pending_owner_removes_simple.is_empty():
			has_pending_owner_removes = true
		if not has_pending_removes and not _pending_removes_simple.is_empty():
			has_pending_removes = true

	_simple_dispatch_depth = maxi(_simple_dispatch_depth - 1, 0)
	_is_iterating_simple = _simple_dispatch_depth > 0
	if _simple_dispatch_depth == 0:
		_clear_requested_simple = false
		_flush_simple_pending()


## 注销指定拥有者注册过的所有事件监听器。
## @param owner: 监听拥有者。
func unregister_owner(owner: Object) -> void:
	if owner == null:
		return

	var owner_id := owner.get_instance_id()
	if _type_dispatch_depth > 0:
		_remove_pending_type_adds_for_owner_id(owner_id)
		_remove_pending_assignable_type_adds_for_owner_id(owner_id)
		_append_unique_int(_pending_owner_removes_type, owner_id)
	else:
		_remove_owner_from_type_listeners(owner_id)
		_remove_owner_from_assignable_type_listeners(owner_id)

	if _simple_dispatch_depth > 0:
		_remove_pending_simple_adds_for_owner_id(owner_id)
		_append_unique_int(_pending_owner_removes_simple, owner_id)
	else:
		_remove_owner_from_simple_listeners(owner_id)


## 获取事件系统诊断统计。
## @return 包含类型事件、可赋值事件和简单事件监听数量的字典。
func get_debug_stats() -> Dictionary:
	return {
		"type_events": _collect_listener_stats(_event_listeners),
		"assignable_type_events": _collect_listener_stats(_assignable_event_listeners),
		"simple_events": _collect_simple_listener_stats(),
		"pending_type_adds": _pending_adds_type.size() + _pending_adds_assignable_type.size(),
		"pending_type_removes": _pending_removes_type.size() + _pending_removes_assignable_type.size(),
		"pending_simple_adds": _pending_adds_simple.size(),
		"pending_simple_removes": _pending_removes_simple.size(),
	}


## 清空所有已注册的事件监听器（包括类型事件和简单事件）。
func clear() -> void:
	_event_listeners.clear()
	_assignable_event_listeners.clear()
	_simple_event_listeners.clear()
	_invalidate_type_dispatch_cache()
	_pending_removes_type.clear()
	_pending_removes_assignable_type.clear()
	_pending_removes_simple.clear()
	_pending_adds_type.clear()
	_pending_adds_assignable_type.clear()
	_pending_adds_simple.clear()
	_pending_owner_removes_type.clear()
	_pending_owner_removes_simple.clear()
	if _type_dispatch_depth > 0:
		_clear_requested_type = true
	else:
		_type_dispatch_depth = 0
		_is_iterating_type = false
		_clear_requested_type = false
	if _simple_dispatch_depth > 0:
		_clear_requested_simple = true
	else:
		_simple_dispatch_depth = 0
		_is_iterating_simple = false
		_clear_requested_simple = false


# --- 私有/辅助方法 ---

func _is_pending_type_remove(event_type: Script, on_event: Callable) -> bool:
	for pending: Dictionary in _pending_removes_type:
		if pending.event_type == event_type and pending.callable == on_event:
			return true
	return false


func _is_pending_assignable_type_remove(event_type: Script, on_event: Callable) -> bool:
	for pending: Dictionary in _pending_removes_assignable_type:
		if pending.event_type == event_type and pending.callable == on_event:
			return true
	return false


func _is_pending_simple_remove(event_id: StringName, on_event: Callable) -> bool:
	for pending: Dictionary in _pending_removes_simple:
		if pending.event_id == event_id and pending.callable == on_event:
			return true
	return false


func _is_pending_owner_remove(entry: Dictionary, pending_owner_ids: Array[int]) -> bool:
	var owner_id := _entry_owner_id(entry)
	return owner_id != 0 and pending_owner_ids.has(owner_id)


func _add_listener_entry(
	registry: Dictionary,
	event_type: Script,
	on_event: Callable,
	priority: int,
	owner: Object,
	order: int
) -> void:
	if not registry.has(event_type):
		registry[event_type] = []
	var listeners := registry[event_type] as Array

	for entry: Dictionary in listeners:
		if _listener_entry_matches(entry, on_event, owner):
			return

	var new_entry := {
		"callable": on_event,
		"priority": priority,
		"owner_ref": _make_owner_ref(owner),
		"owner_id": _owner_instance_id(owner),
		"order": order,
	}
	var inserted: bool = false
	for i: int in range(listeners.size()):
		var entry := listeners[i] as Dictionary
		if (
			priority > int(entry.priority)
			or (priority == int(entry.priority) and order < int(entry.get("order", 0)))
		):
			listeners.insert(i, new_entry)
			inserted = true
			break
	if not inserted:
		listeners.append(new_entry)
	_invalidate_type_dispatch_cache()


func _get_type_dispatch_entries(event_type: Script) -> Array[Dictionary]:
	if _type_dispatch_cache.has(event_type):
		return _duplicate_dispatch_entries(_type_dispatch_cache[event_type] as Array)

	var result: Array[Dictionary] = []
	if _event_listeners.has(event_type):
		var exact_listeners := _event_listeners[event_type] as Array
		for entry: Dictionary in exact_listeners:
			var dispatch_entry := entry.duplicate()
			dispatch_entry["event_type"] = event_type
			dispatch_entry["assignable"] = false
			result.append(dispatch_entry)

	for base_event_type: Script in _assignable_event_listeners.keys():
		if not _script_extends_or_equals(event_type, base_event_type):
			continue
		var assignable_listeners := _assignable_event_listeners[base_event_type] as Array
		for entry: Dictionary in assignable_listeners:
			var dispatch_entry := entry.duplicate()
			dispatch_entry["event_type"] = base_event_type
			dispatch_entry["assignable"] = true
			result.append(dispatch_entry)

	result.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_priority := int(left.get("priority", 0))
		var right_priority := int(right.get("priority", 0))
		if left_priority != right_priority:
			return left_priority > right_priority
		return int(left.get("order", 0)) < int(right.get("order", 0))
	)
	_type_dispatch_cache[event_type] = result
	return _duplicate_dispatch_entries(result)


func _dispatch_type_listener_entries(event_instance: Object, listeners: Array[Dictionary]) -> void:
	for entry: Dictionary in listeners:
		if _clear_requested_type:
			break

		var callback: Callable = entry.callable
		var event_type := entry.get("event_type") as Script
		var assignable := bool(entry.get("assignable", false))
		if _entry_owner_is_released(entry):
			_append_pending_type_remove(event_type, callback, assignable)
			continue
		if _is_pending_owner_remove(entry, _pending_owner_removes_type):
			continue
		if not callback.is_valid() or (callback.get_object() != null and not is_instance_valid(callback.get_object())):
			_append_pending_type_remove(event_type, callback, assignable)
			continue
		if assignable:
			if _is_pending_assignable_type_remove(event_type, callback):
				continue
		elif _is_pending_type_remove(event_type, callback):
			continue

		callback.call(event_instance)

		if _clear_requested_type or event_instance.get("is_consumed") == true:
			break


func _append_pending_type_remove(event_type: Script, callback: Callable, assignable: bool) -> void:
	if assignable:
		_pending_removes_assignable_type.append({ "event_type": event_type, "callable": callback })
	else:
		_pending_removes_type.append({ "event_type": event_type, "callable": callback })


func _script_extends_or_equals(script_cls: Script, base_script: Script) -> bool:
	var current := script_cls
	while current != null:
		if current == base_script:
			return true
		current = current.get_base_script()
	return false


func _collect_listener_stats(registry: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for event_type: Script in registry.keys():
		result[_script_debug_key(event_type)] = (registry[event_type] as Array).size()
	return result


func _collect_simple_listener_stats() -> Dictionary:
	var result: Dictionary = {}
	for event_id: StringName in _simple_event_listeners.keys():
		result[String(event_id)] = (_simple_event_listeners[event_id] as Array).size()
	return result


func _script_debug_key(script_cls: Script) -> String:
	if script_cls == null:
		return ""
	var global_name := script_cls.get_global_name()
	if global_name != &"":
		return String(global_name)
	if not script_cls.resource_path.is_empty():
		return script_cls.resource_path
	return "Script:%d" % script_cls.get_instance_id()


func _remove_pending_type_add(event_type: Script, on_event: Callable) -> void:
	for i: int in range(_pending_adds_type.size() - 1, -1, -1):
		var pending := _pending_adds_type[i] as Dictionary
		if pending.event_type == event_type and pending.callable == on_event:
			_pending_adds_type.remove_at(i)


func _remove_pending_assignable_type_add(event_type: Script, on_event: Callable) -> void:
	for i: int in range(_pending_adds_assignable_type.size() - 1, -1, -1):
		var pending := _pending_adds_assignable_type[i] as Dictionary
		if pending.event_type == event_type and pending.callable == on_event:
			_pending_adds_assignable_type.remove_at(i)


func _remove_pending_simple_add(event_id: StringName, on_event: Callable) -> void:
	for i: int in range(_pending_adds_simple.size() - 1, -1, -1):
		var pending := _pending_adds_simple[i] as Dictionary
		if pending.event_id == event_id and pending.callable == on_event:
			_pending_adds_simple.remove_at(i)


func _remove_pending_type_adds_for_owner_id(owner_id: int) -> void:
	for i: int in range(_pending_adds_type.size() - 1, -1, -1):
		var pending := _pending_adds_type[i] as Dictionary
		if _entry_owner_id(pending) == owner_id:
			_pending_adds_type.remove_at(i)


func _remove_pending_assignable_type_adds_for_owner_id(owner_id: int) -> void:
	for i: int in range(_pending_adds_assignable_type.size() - 1, -1, -1):
		var pending := _pending_adds_assignable_type[i] as Dictionary
		if _entry_owner_id(pending) == owner_id:
			_pending_adds_assignable_type.remove_at(i)


func _remove_pending_simple_adds_for_owner_id(owner_id: int) -> void:
	for i: int in range(_pending_adds_simple.size() - 1, -1, -1):
		var pending := _pending_adds_simple[i] as Dictionary
		if _entry_owner_id(pending) == owner_id:
			_pending_adds_simple.remove_at(i)


func _flush_type_pending() -> void:
	for pending: Dictionary in _pending_removes_type:
		if _event_listeners.has(pending.event_type):
			var listeners := _event_listeners[pending.event_type] as Array
			_remove_entry_by_callable(listeners, pending.callable)
	_pending_removes_type.clear()

	for pending: Dictionary in _pending_removes_assignable_type:
		if _assignable_event_listeners.has(pending.event_type):
			var listeners := _assignable_event_listeners[pending.event_type] as Array
			_remove_entry_by_callable(listeners, pending.callable)
	_pending_removes_assignable_type.clear()

	for owner_id: int in _pending_owner_removes_type:
		_remove_owner_from_type_listeners(owner_id)
		_remove_owner_from_assignable_type_listeners(owner_id)
	_pending_owner_removes_type.clear()

	for pending: Dictionary in _pending_adds_type:
		var binding_owner := _owner_from_ref(pending.get("owner_ref"))
		if pending.get("owner_ref") != null and binding_owner == null:
			continue
		_add_listener_entry(
			_event_listeners,
			pending.event_type,
			pending.callable,
			pending.priority,
			binding_owner,
			_pending_listener_order(pending)
		)
	_pending_adds_type.clear()

	for pending: Dictionary in _pending_adds_assignable_type:
		var binding_owner := _owner_from_ref(pending.get("owner_ref"))
		if pending.get("owner_ref") != null and binding_owner == null:
			continue
		_add_listener_entry(
			_assignable_event_listeners,
			pending.event_type,
			pending.callable,
			pending.priority,
			binding_owner,
			_pending_listener_order(pending)
		)
	_pending_adds_assignable_type.clear()


func _flush_simple_pending() -> void:
	for pending: Dictionary in _pending_removes_simple:
		if _simple_event_listeners.has(pending.event_id):
			var listeners := _simple_event_listeners[pending.event_id] as Array
			_remove_entry_by_callable(listeners, pending.callable)
	_pending_removes_simple.clear()

	for owner_id: int in _pending_owner_removes_simple:
		_remove_owner_from_simple_listeners(owner_id)
	_pending_owner_removes_simple.clear()

	for pending: Dictionary in _pending_adds_simple:
		var binding_owner := _owner_from_ref(pending.get("owner_ref"))
		if pending.get("owner_ref") != null and binding_owner == null:
			continue
		register_simple(pending.event_id, pending.callable, binding_owner)
	_pending_adds_simple.clear()


func _remove_owner_from_type_listeners(owner_id: int) -> void:
	for event_type: Script in _event_listeners:
		var listeners := _event_listeners[event_type] as Array
		_remove_entries_by_owner_id(listeners, owner_id)


func _remove_owner_from_assignable_type_listeners(owner_id: int) -> void:
	for event_type: Script in _assignable_event_listeners:
		var listeners := _assignable_event_listeners[event_type] as Array
		_remove_entries_by_owner_id(listeners, owner_id)


func _remove_owner_from_simple_listeners(owner_id: int) -> void:
	for event_id: StringName in _simple_event_listeners:
		var listeners := _simple_event_listeners[event_id] as Array
		_remove_entries_by_owner_id(listeners, owner_id)


func _remove_entry_by_callable(listeners: Array, on_event: Callable) -> void:
	var removed := false
	for i: int in range(listeners.size() - 1, -1, -1):
		var entry := listeners[i] as Dictionary
		if entry.callable == on_event:
			listeners.remove_at(i)
			removed = true
	if removed:
		_invalidate_type_dispatch_cache()


func _remove_entries_by_owner_id(listeners: Array, owner_id: int) -> void:
	var removed := false
	for i: int in range(listeners.size() - 1, -1, -1):
		var entry := listeners[i] as Dictionary
		if _entry_owner_id(entry) == owner_id:
			listeners.remove_at(i)
			removed = true
	if removed:
		_invalidate_type_dispatch_cache()


func _entry_owner_is_released(entry: Dictionary) -> bool:
	return entry.get("owner_ref") != null and _owner_from_ref(entry.get("owner_ref")) == null


func _entry_owner_id(entry: Dictionary) -> int:
	var stored_owner_id: int = entry.get("owner_id", 0)
	if stored_owner_id != 0:
		return stored_owner_id
	return _owner_id_from_ref(entry.get("owner_ref"))


func _make_owner_ref(owner: Object) -> WeakRef:
	if owner == null:
		return null
	return weakref(owner)


func _owner_instance_id(owner: Object) -> int:
	if owner == null:
		return 0
	return owner.get_instance_id()


func _owner_from_ref(owner_ref_variant: Variant) -> Object:
	var owner_ref := owner_ref_variant as WeakRef
	if owner_ref == null:
		return null
	return owner_ref.get_ref() as Object


func _owner_id_from_ref(owner_ref_variant: Variant) -> int:
	var owner := _owner_from_ref(owner_ref_variant)
	if owner == null:
		return 0
	return owner.get_instance_id()


func _append_unique_int(list: Array[int], value: int) -> void:
	if not list.has(value):
		list.append(value)


func _listener_entry_matches(entry: Dictionary, on_event: Callable, owner: Object) -> bool:
	if entry.callable != on_event:
		return false
	var owner_id := _owner_instance_id(owner)
	if owner_id == 0:
		return _entry_owner_id(entry) == 0
	return _entry_owner_id(entry) == owner_id


func _next_listener_order() -> int:
	_listener_order_counter += 1
	return _listener_order_counter


func _pending_listener_order(pending: Dictionary) -> int:
	if pending.has("order"):
		return int(pending.get("order", 0))
	return _next_listener_order()


func _validate_callable_min_args(on_event: Callable, min_args: int, callback_label: String, arg_label: String) -> bool:
	if not on_event.is_valid():
		push_error("[TypeEventSystem] 注册的%s无效。" % callback_label)
		return false

	var target_obj: Object = on_event.get_object()
	if target_obj == null or on_event.is_custom():
		return true

	var method_name: StringName = on_event.get_method()
	var methods: Array[Dictionary] = target_obj.get_method_list()
	for m: Dictionary in methods:
		if m["name"] == String(method_name):
			if m["args"].size() < min_args:
				push_error("[TypeEventSystem] 注册的%s %s 必须至少包含 %d 个参数用于接收%s！" % [
					callback_label,
					method_name,
					min_args,
					arg_label,
				])
				return false
			break
	return true


func _duplicate_dispatch_entries(entries: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in entries:
		result.append(entry.duplicate())
	return result


func _invalidate_type_dispatch_cache() -> void:
	_type_dispatch_cache.clear()
