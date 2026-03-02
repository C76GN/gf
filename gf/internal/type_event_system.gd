# addons/gf/internal/type_event_system.gd
class_name TypeEventSystem


## TypeEventSystem: 基于类型和 StringName 的双轨事件系统内部实现。
##
## 轨道一（类型事件）：使用 Script 类型作为键，以对象实例为载体分发事件。
## 轨道二（简单事件）：使用 StringName 作为键，以 Variant 为 payload 分发事件。
##   简单事件专为 _process 等高频场景设计，避免 new() 实例化带来的 GC 压力。


# --- 私有变量 ---

var _event_listeners: Dictionary = {}
var _simple_event_listeners: Dictionary = {}


# --- 公共方法 (类型事件) ---

## 注册特定脚本类型的事件监听器。
## @param event_type: 要监听的脚本类型。
## @param on_event: 事件发送时执行的回调函数。
func register(event_type: Script, on_event: Callable) -> void:
	if not _event_listeners.has(event_type):
		_event_listeners[event_type] = []
	var listeners := _event_listeners[event_type] as Array
	if not listeners.has(on_event):
		listeners.append(on_event)


## 注销特定脚本类型的事件监听器。
## @param event_type: 要注销的脚本类型。
## @param on_event: 要移除的回调函数。
func unregister(event_type: Script, on_event: Callable) -> void:
	if _event_listeners.has(event_type):
		var listeners := _event_listeners[event_type] as Array
		listeners.erase(on_event)


## 将事件实例发送给其脚本类型的所有注册监听器。
## 采用倒序遍历以安全移除已失效的回调。
## @param event_instance: 要分发的事件实例。
func send(event_instance: Object) -> void:
	var event_type: Variant = event_instance.get_script()
	if event_type == null:
		push_error("[GDCore] 发送的事件必须是附加了脚本的类实例。")
		return
	if _event_listeners.has(event_type):
		var listeners := _event_listeners[event_type] as Array
		for i in range(listeners.size() - 1, -1, -1):
			var callback := listeners[i] as Callable
			if callback.is_valid():
				callback.call(event_instance)
			else:
				listeners.remove_at(i)


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
## 采用倒序遍历以安全移除已失效的回调。
## @param event_id: StringName 事件标识符。
## @param payload: 传递给监听器的数据，可为任意类型。
func send_simple(event_id: StringName, payload: Variant = null) -> void:
	if not _simple_event_listeners.has(event_id):
		return
	var listeners := _simple_event_listeners[event_id] as Array
	for i in range(listeners.size() - 1, -1, -1):
		var callback := listeners[i] as Callable
		if callback.is_valid():
			callback.call(payload)
		else:
			listeners.remove_at(i)


## 清空所有已注册的事件监听器（包括类型事件和简单事件）。
func clear() -> void:
	_event_listeners.clear()
	_simple_event_listeners.clear()
