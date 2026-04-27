class_name GFController
extends Node


## GFController: 连接 UI/输入与架构的控制器基类。
##
## 提供访问架构的便捷代理。这里不缓存 Model/System/Utility 引用，
## 以避免架构切换或模块注销后保留过期对象。


# --- 常量 ---

const GFNodeContextBase = preload("res://addons/gf/core/gf_node_context.gd")


# --- 获取方法 ---

## 获取当前 Controller 所属的架构。
##
## 优先沿场景树向上寻找 GFNodeContext；若未找到，则回退到全局 Gf 架构。
## @return 当前可用的架构实例。
func get_architecture() -> GFArchitecture:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		return architecture
	return Gf.get_architecture()


## 获取当前 Controller 所属的架构，找不到时返回 null 且不触发全局错误。
## @return 当前可用的架构实例。
func get_architecture_or_null() -> GFArchitecture:
	return _get_architecture_or_null()


## 等待最近的 GFNodeContext 完成初始化并返回可用架构。
## 若当前节点不在上下文子树下，则直接返回全局架构。
## @return 当前 Controller 可用的架构实例。
func wait_for_context_ready() -> GFArchitecture:
	var context := _find_nearest_context()
	if context != null:
		var architecture := await context.wait_until_ready()
		if architecture != null:
			return architecture

	return get_architecture()


## 通过类型获取 Model 实例。
## @param model_type: 模型的脚本类型。
## @return 模型实例。
func get_model(model_type: Script) -> Object:
	var architecture := get_architecture()
	if architecture == null:
		return null
	return architecture.get_model(model_type)


## 通过类型获取 System 实例。
## @param system_type: 系统的脚本类型。
## @return 系统实例。
func get_system(system_type: Script) -> Object:
	var architecture := get_architecture()
	if architecture == null:
		return null
	return architecture.get_system(system_type)


## 通过类型获取 Utility 实例。
## @param utility_type: 工具的脚本类型。
## @return 工具实例。
func get_utility(utility_type: Script) -> Object:
	var architecture := get_architecture()
	if architecture == null:
		return null
	return architecture.get_utility(utility_type)


# --- 命令与查询 ---

## 向架构发送命令。支持 await：'await send_command(MyCommand.new())'。
## @param command: 要发送的命令实例。
## @return 命令的执行结果（null 或 Signal）。
func send_command(command: Object) -> Variant:
	var architecture := get_architecture()
	if architecture == null:
		return null
	return architecture.send_command(command)


## 执行查询并返回结果。
## @param query: 要执行的查询实例。
## @return 查询结果。
func send_query(query: Object) -> Variant:
	var architecture := get_architecture()
	if architecture == null:
		return null
	return architecture.send_query(query)


# --- 事件系统 ---

## 注册类型事件监听器。
## @param event_type: 要监听的脚本类型。
## @param callback: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
	var architecture := get_architecture()
	if architecture != null:
		architecture.register_event_owned(self, event_type, callback, priority)


## 注销类型事件监听器。
## @param event_type: 要注销的脚本类型。
## @param callback: 要移除的回调函数。
func unregister_event(event_type: Script, callback: Callable) -> void:
	var architecture := get_architecture()
	if architecture != null:
		architecture.unregister_event(event_type, callback)


## 通过事件系统发送类型事件。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	var architecture := get_architecture()
	if architecture != null:
		architecture.send_event(event_instance)


## 注册轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param callback: 回调函数，签名为 func(payload: Variant)。
func register_simple_event(event_id: StringName, callback: Callable) -> void:
	var architecture := get_architecture()
	if architecture != null:
		architecture.register_simple_event_owned(self, event_id, callback)


## 注销轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param callback: 要移除的回调函数。
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
	var architecture := get_architecture()
	if architecture != null:
		architecture.unregister_simple_event(event_id, callback)


## 发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。
## @param event_id: StringName 事件标识符。
## @param payload: 可选的事件附加数据。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	var architecture := get_architecture()
	if architecture != null:
		architecture.send_simple_event(event_id, payload)


# --- 私有/辅助方法 ---

func _get_architecture_or_null() -> GFArchitecture:
	var context := _find_nearest_context()
	if context != null:
		var context_architecture := context.get_architecture()
		if context_architecture != null:
			return context_architecture

	if Gf.has_architecture():
		return Gf.get_architecture()
	return null


func _find_nearest_context() -> GFNodeContextBase:
	var current_node: Node = self
	while current_node != null:
		if current_node is GFNodeContextBase:
			return current_node as GFNodeContextBase
		current_node = current_node.get_parent()

	return null
