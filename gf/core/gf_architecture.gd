# addons/gf/core/gf_architecture.gd
class_name GFArchitecture


## GFArchitecture: 管理 Model、System 和 Utility 的注册与生命周期的容器。
##
## 生命周期遵循两阶段初始化协议：
##   阶段一 (init)  ：所有模块执行自身内部变量初始化。
##   阶段二 (ready) ：所有模块均已完成 init，可安全进行跨模块依赖获取。


# --- 私有变量 ---

var _systems: Dictionary = {}
var _models: Dictionary = {}
var _utilities: Dictionary = {}
var _event_system: TypeEventSystem
var _inited: bool = false


# --- Godot 生命周期方法 ---

func _init() -> void:
	_event_system = TypeEventSystem.new()


# --- 公共方法 ---

## 检查架构是否已初始化。
## @return 已初始化返回 true，否则返回 false。
func is_inited() -> bool:
	return _inited


## 初始化架构及所有注册的组件（两阶段）。
## 阶段一：调用所有模块的 init()，用于初始化自身内部变量。
## 阶段二：调用所有模块的 ready()，此时跨模块依赖获取是安全的。
func init() -> void:
	if _inited:
		return
	_on_init()

	for model in _models.values():
		if model.has_method("init"):
			model.init()
	for system in _systems.values():
		if system.has_method("init"):
			system.init()
	for utility in _utilities.values():
		if utility.has_method("init"):
			utility.init()

	for model in _models.values():
		if model.has_method("ready"):
			model.ready()
	for system in _systems.values():
		if system.has_method("ready"):
			system.ready()
	for utility in _utilities.values():
		if utility.has_method("ready"):
			utility.ready()

	_inited = true


## 销毁架构及所有注册的组件。
func dispose() -> void:
	_on_dispose()
	for system in _systems.values():
		if system.has_method("dispose"):
			system.dispose()
	for model in _models.values():
		if model.has_method("dispose"):
			model.dispose()
	for utility in _utilities.values():
		if utility.has_method("dispose"):
			utility.dispose()
	_models.clear()
	_systems.clear()
	_utilities.clear()
	_event_system.clear()
	_inited = false


## 执行命令实例。支持 await：'await send_command(MyCommand.new())'。
## @param command: 要执行的命令实例。
## @return 命令的执行结果（null 或 Signal）。
func send_command(command: Object) -> Variant:
	if command.has_method("execute"):
		return command.execute()
	return null


## 执行查询实例并返回结果。
## @param query: 要执行的查询实例。
## @return 查询执行的结果。
func send_query(query: Object) -> Variant:
	if query.has_method("execute"):
		return query.execute()
	return null


## 通过事件系统发送类型事件实例。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	_event_system.send(event_instance)


## 为脚本类型注册事件监听器。
## @param event_type: 要监听的脚本类型。
## @param on_event: 回调函数。
func register_event(event_type: Script, on_event: Callable) -> void:
	_event_system.register(event_type, on_event)


## 为脚本类型注销事件监听器。
## @param event_type: 要注销的脚本类型。
## @param on_event: 要移除的回调函数。
func unregister_event(event_type: Script, on_event: Callable) -> void:
	_event_system.unregister(event_type, on_event)


## 注册轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param on_event: 回调函数，签名为 func(payload: Variant)。
func register_simple_event(event_id: StringName, on_event: Callable) -> void:
	_event_system.register_simple(event_id, on_event)


## 注销轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param on_event: 要移除的回调函数。
func unregister_simple_event(event_id: StringName, on_event: Callable) -> void:
	_event_system.unregister_simple(event_id, on_event)


## 发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。
## @param event_id: StringName 事件标识符。
## @param payload: 可选的事件附加数据。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	_event_system.send_simple(event_id, payload)


# --- 注册方法 ---

## 注册 System 实例。
## @param script_cls: 系统的脚本类。
## @param instance: 系统实例。
func register_system(script_cls: Script, instance: Object) -> void:
	if not _systems.has(script_cls):
		_systems[script_cls] = instance


## 注册 Model 实例。
## @param script_cls: 模型的脚本类。
## @param instance: 模型实例。
func register_model(script_cls: Script, instance: Object) -> void:
	if not _models.has(script_cls):
		_models[script_cls] = instance


## 注册 Utility 实例。
## @param script_cls: 工具的脚本类。
## @param instance: 工具实例。
func register_utility(script_cls: Script, instance: Object) -> void:
	if not _utilities.has(script_cls):
		_utilities[script_cls] = instance


## 便捷注册 System 实例，自动从实例获取脚本类作为注册键。
## @param instance: 系统实例，必须附加有 GDScript 脚本。
func register_system_instance(instance: Object) -> void:
	var script := instance.get_script() as Script
	if script == null:
		push_error("[GDCore] register_system_instance 失败：实例未附加脚本。")
		return
	register_system(script, instance)


## 便捷注册 Model 实例，自动从实例获取脚本类作为注册键。
## @param instance: 模型实例，必须附加有 GDScript 脚本。
func register_model_instance(instance: Object) -> void:
	var script := instance.get_script() as Script
	if script == null:
		push_error("[GDCore] register_model_instance 失败：实例未附加脚本。")
		return
	register_model(script, instance)


## 便捷注册 Utility 实例，自动从实例获取脚本类作为注册键。
## @param instance: 工具实例，必须附加有 GDScript 脚本。
func register_utility_instance(instance: Object) -> void:
	var script := instance.get_script() as Script
	if script == null:
		push_error("[GDCore] register_utility_instance 失败：实例未附加脚本。")
		return
	register_utility(script, instance)


# --- 获取方法 ---

## 通过脚本类获取 System 实例。
## @param script_cls: 脚本类。
## @return 系统实例，如果未找到则返回 null。
func get_system(script_cls: Script) -> Object:
	return _systems.get(script_cls)


## 通过脚本类获取 Model 实例。
## @param script_cls: 脚本类。
## @return 模型实例，如果未找到则返回 null。
func get_model(script_cls: Script) -> Object:
	return _models.get(script_cls)


## 通过脚本类获取 Utility 实例。
## @param script_cls: 脚本类。
## @return 工具实例，如果未找到则返回 null。
func get_utility(script_cls: Script) -> Object:
	return _utilities.get(script_cls)


# --- 私有/内部方法 ---

## 内部初始化回调，子类可重写。
func _on_init() -> void:
	pass


## 内部销毁回调，子类可重写。
func _on_dispose() -> void:
	pass
