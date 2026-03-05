# addons/gf/core/type_event_system.gd
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


# --- 公共方法 (类型事件) ---

## 注册特定脚本类型的事件监听器。
## 回调按 priority 从高到低排序存储，相同优先级保持注册顺序。
## @param event_type: 要监听的脚本类型。
## @param on_event: 事件发送时执行的回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register(event_type: Script, on_event: Callable, priority: int = 0) -> void:
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
		var listeners := _event_listeners[event_type] as Array
		for i: int in range(listeners.size()):
			var entry := listeners[i] as Dictionary
			if entry.callable == on_event:
				listeners.remove_at(i)
				return


## 将事件实例发送给其脚本类型的所有注册监听器。
## 遍历前先对监听器列表进行浅拷贝，确保回调内的注册/注销操作不影响当前遍历。
## 已失效的 Callable 会在遍历结束后从原始列表中移除。
## 若事件实例具有 is_consumed 属性且被设为 true，则立即中断后续回调的执行。
## @param event_instance: 要分发的事件实例。
func send(event_instance: Object) -> void:
	var event_type: Variant = event_instance.get_script()
	if event_type == null:
		push_error("[GDCore] 发送的事件必须是附加了脚本的类实例。")
		return
	if _event_listeners.has(event_type):
		var listeners := _event_listeners[event_type] as Array
		var snapshot := listeners.duplicate()
		var invalid_entries: Array = []

		for entry: Dictionary in snapshot:
			var callback: Callable = entry.callable

			if not callback.is_valid():
				invalid_entries.append(entry)
				continue

			var still_registered: bool = false
			for original_entry: Dictionary in listeners:
				if original_entry.callable == callback:
					still_registered = true
					break
			if not still_registered:
				continue

			callback.call(event_instance)

			if event_instance.get("is_consumed") == true:
				break

		for entry: Dictionary in invalid_entries:
			listeners.erase(entry)


# --- 公共方法 (简单事件) ---

## 注册轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param on_event: 回调函数，签名为 func(payload: Variant)。
func register_simple(event_id: StringName, on_event: Callable) -> void:
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
		var listeners := _simple_event_listeners[event_id] as Array
		listeners.erase(on_event)


## 将 payload 发送给指定 StringName 事件的所有注册监听器。
## 遍历前先对监听器列表进行浅拷贝，确保回调内的注册/注销操作不影响当前遍历。
## 已失效的 Callable 会在遍历结束后从原始列表中移除。
## @param event_id: StringName 事件标识符。
## @param payload: 传递给监听器的数据，可为任意类型。
func send_simple(event_id: StringName, payload: Variant = null) -> void:
	if not _simple_event_listeners.has(event_id):
		return
	var listeners := _simple_event_listeners[event_id] as Array
	var snapshot := listeners.duplicate()
	for callback: Callable in snapshot:
		if not callback.is_valid():
			listeners.erase(callback)
		elif listeners.has(callback):
			callback.call(payload)


## 清空所有已注册的事件监听器（包括类型事件和简单事件）。
func clear() -> void:
	_event_listeners.clear()
	_simple_event_listeners.clear()
