# addons/gf/core/gf.gd
extends Node


## Gf: 全局入口单例，负责架构生命周期管理。


# --- 私有变量 ---

var _architecture: GFArchitecture = null


# --- 公共方法 ---

## 获取当前注册的架构实例。
## @return GFArchitecture 实例，如果未注册则返回 null。
func get_architecture() -> GFArchitecture:
	if _architecture == null:
		push_error("[GDCore] 架构尚未初始化，请先注册架构。")
	return _architecture


## 设置并初始化架构实例。该方法内部使用 await，调用方应加 await。
## @param architecture: 要注册的 GFArchitecture 实例。
func set_architecture(architecture: GFArchitecture) -> void:
	if _architecture != null and _architecture != architecture:
		_architecture.dispose()
	_architecture = architecture
	if not _architecture.is_inited():
		await _architecture.init()


# --- Godot 生命周期方法 ---

## 每帧驱动架构的 tick 循环，传递给所有已注册的 System。
func _process(delta: float) -> void:
	if _architecture != null:
		_architecture.tick(delta)


## 每物理帧驱动架构的 physics_tick 循环，传递给所有已注册的 System。
func _physics_process(delta: float) -> void:
	if _architecture != null:
		_architecture.physics_tick(delta)


## 节点退出树时清理架构。
func _exit_tree() -> void:
	if _architecture != null:
		_architecture.dispose()
		_architecture = null


## 便捷注册 System 实例。
func register_system(instance: Object) -> void:
	get_architecture().register_system_instance(instance)

## 便捷注册 Model 实例。
func register_model(instance: Object) -> void:
	get_architecture().register_model_instance(instance)

## 便捷注册 Utility 实例。
func register_utility(instance: Object) -> void:
	get_architecture().register_utility_instance(instance)

## 获取 System 实例。
func get_system(script_cls: Script) -> Object:
	return get_architecture().get_system(script_cls)

## 获取 Model 实例。
func get_model(script_cls: Script) -> Object:
	return get_architecture().get_model(script_cls)

## 获取 Utility 实例。
func get_utility(script_cls: Script) -> Object:
	return get_architecture().get_utility(script_cls)

## 便捷发送全局命令。
func send_command(command: Object) -> Variant:
	return get_architecture().send_command(command)

## 便捷发送查询。
func send_query(query: Object) -> Variant:
	return get_architecture().send_query(query)

## 便捷发送带载体的强类型事件。
func send_event(event_instance: Object) -> void:
	get_architecture().send_event(event_instance)

## 便捷发送无参数的轻量级事件。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	get_architecture().send_simple_event(event_id, payload)

## 快捷注册类型事件监听（别名：listen）。
func listen(event_type: Script, on_event: Callable, priority: int = 0) -> void:
	get_architecture().register_event(event_type, on_event, priority)

## 快捷注销类型事件监听（别名：unlisten）。
func unlisten(event_type: Script, on_event: Callable) -> void:
	get_architecture().unregister_event(event_type, on_event)

## 快捷注册轻量事件监听（别名：listen_simple）。
func listen_simple(event_id: StringName, on_event: Callable) -> void:
	get_architecture().register_simple_event(event_id, on_event)

## 快捷注销轻量事件监听（别名：unlisten_simple）。
func unlisten_simple(event_id: StringName, on_event: Callable) -> void:
	get_architecture().unregister_simple_event(event_id, on_event)
