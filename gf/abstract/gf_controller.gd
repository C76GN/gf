# addons/gf/abstract/gf_controller.gd
extends Node
class_name GFController


## GFController: 连接 UI/输入与架构的控制器基类。
##
## 内置懒加载缓存机制，高频调用 get_model/get_system/get_utility 时
## 首次从架构获取后自动缓存，后续直接从本地字典取值，避免频繁跨类哈希查找。


# --- 私有变量 ---

## 懒加载缓存字典，存储本 Controller 首次获取过的 Model/System/Utility 实例。
## Key 为 Script 类型，Value 为对应实例。
var _cache: Dictionary = {}


# --- 获取方法 (懒加载缓存) ---

## 通过类型获取 Model 实例。首次调用后结果将缓存于本地。
## @param model_type: 模型的脚本类型。
## @return 模型实例。
func get_model(model_type: Script) -> Object:
	if not _cache.has(model_type):
		_cache[model_type] = Gf.get_architecture().get_model(model_type)
	return _cache[model_type]


## 通过类型获取 System 实例。首次调用后结果将缓存于本地。
## @param system_type: 系统的脚本类型。
## @return 系统实例。
func get_system(system_type: Script) -> Object:
	if not _cache.has(system_type):
		_cache[system_type] = Gf.get_architecture().get_system(system_type)
	return _cache[system_type]


## 通过类型获取 Utility 实例。首次调用后结果将缓存于本地。
## @param utility_type: 工具的脚本类型。
## @return 工具实例。
func get_utility(utility_type: Script) -> Object:
	if not _cache.has(utility_type):
		_cache[utility_type] = Gf.get_architecture().get_utility(utility_type)
	return _cache[utility_type]


# --- 命令与查询 ---

## 向架构发送命令。支持 await：'await send_command(MyCommand.new())'。
## @param command: 要发送的命令实例。
## @return 命令的执行结果（null 或 Signal）。
func send_command(command: Object) -> Variant:
	return Gf.get_architecture().send_command(command)


## 执行查询并返回结果。
## @param query: 要执行的查询实例。
## @return 查询结果。
func send_query(query: Object) -> Variant:
	return Gf.get_architecture().send_query(query)


# --- 事件系统 ---

## 注册类型事件监听器。
## @param event_type: 要监听的脚本类型。
## @param callback: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
	Gf.get_architecture().register_event(event_type, callback, priority)


## 注销类型事件监听器。
## @param event_type: 要注销的脚本类型。
## @param callback: 要移除的回调函数。
func unregister_event(event_type: Script, callback: Callable) -> void:
	Gf.get_architecture().unregister_event(event_type, callback)


## 通过事件系统发送类型事件。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	Gf.get_architecture().send_event(event_instance)


## 注册轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param callback: 回调函数，签名为 func(payload: Variant)。
func register_simple_event(event_id: StringName, callback: Callable) -> void:
	Gf.get_architecture().register_simple_event(event_id, callback)


## 注销轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param callback: 要移除的回调函数。
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
	Gf.get_architecture().unregister_simple_event(event_id, callback)


## 发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。
## @param event_id: StringName 事件标识符。
## @param payload: 可选的事件附加数据。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	Gf.get_architecture().send_simple_event(event_id, payload)
