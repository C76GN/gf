# addons/gf/core/gf_architecture.gd
class_name GFArchitecture


## GFArchitecture: 管理 Model、System 和 Utility 的注册与生命周期的容器。
##
## 生命周期遵循三阶段初始化协议：
##   阶段一 (init)       ：所有模块执行自身内部变量初始化。
##   阶段二 (async_init) ：所有模块并发执行异步初始化（可使用 await）。
##   阶段三 (ready)      ：所有模块均已完成 init，可安全进行跨模块依赖获取。


# --- 私有变量 ---

var _systems: Dictionary = {}
var _models: Dictionary = {}
var _utilities: Dictionary = {}
var _event_system: TypeEventSystem
var _time_utility: GFTimeUtility
var _inited: bool = false


# --- Godot 生命周期方法 ---

func _init() -> void:
	_event_system = TypeEventSystem.new()


# --- 公共方法 ---

## 检查架构是否已初始化。
## @return 已初始化返回 true，否则返回 false。
func is_inited() -> bool:
	return _inited


## 初始化架构及所有注册的组件（三阶段）。
## 阶段一：调用所有模块的 init()，用于初始化自身内部变量。
## 阶段二：逐个 await 所有模块的 async_init()，用于异步资源加载等操作。
## 阶段三：调用所有模块的 ready()，此时跨模块依赖获取是安全的。
func init() -> void:
	if _inited:
		return
	_on_init()

	for model: Variant in _models.values():
		if model.has_method("init"):
			model.init()
	for system: Variant in _systems.values():
		if system.has_method("init"):
			system.init()
	for utility: Variant in _utilities.values():
		if utility.has_method("init"):
			utility.init()

	for model: Variant in _models.values():
		if model.has_method("async_init"):
			await model.async_init()
	for system: Variant in _systems.values():
		if system.has_method("async_init"):
			await system.async_init()
	for utility: Variant in _utilities.values():
		if utility.has_method("async_init"):
			await utility.async_init()

	for model: Variant in _models.values():
		if model.has_method("ready"):
			model.ready()
	for system: Variant in _systems.values():
		if system.has_method("ready"):
			system.ready()
	for utility: Variant in _utilities.values():
		if utility.has_method("ready"):
			utility.ready()

	_time_utility = get_utility(GFTimeUtility) as GFTimeUtility
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


## 驱动所有已注册 System 的每帧更新。在架构初始化完成后方可生效。
## 若已注册 GFTimeUtility，则自动将 delta 经过时间缩放/暂停处理后再传递给 System。
## 设置了 ignore_pause 的 System 将始终接收原始 delta。
## @param delta: 距上一帧的时间（秒）。
func tick(delta: float) -> void:
	if not _inited:
		return
	var scaled_delta: float = _get_scaled_delta(delta)
	for system: Variant in _systems.values():
		if system.ignore_pause and _time_utility != null and _time_utility.is_paused:
			system.tick(delta)
		else:
			system.tick(scaled_delta)


## 驱动所有已注册 System 的每物理帧更新。在架构初始化完成后方可生效。
## 若已注册 GFTimeUtility，则自动将 delta 经过时间缩放/暂停处理后再传递给 System。
## 设置了 ignore_pause 的 System 将始终接收原始 delta。
## @param delta: 距上一物理帧的时间（秒）。
func physics_tick(delta: float) -> void:
	if not _inited:
		return
	var scaled_delta: float = _get_scaled_delta(delta)
	for system: Variant in _systems.values():
		if system.ignore_pause and _time_utility != null and _time_utility.is_paused:
			system.physics_tick(delta)
		else:
			system.physics_tick(scaled_delta)


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
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_event(event_type: Script, on_event: Callable, priority: int = 0) -> void:
	_event_system.register(event_type, on_event, priority)


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


# --- 序列化方法 ---

## 收集所有已注册 Model 的状态快照。
## 遍历所有 Model，调用其 to_dict() 方法，以脚本类的全局类名为键汇聚成一个字典。
## @return 包含所有 Model 状态的字典，可直接用于 JSON 序列化。
func get_all_models_state() -> Dictionary:
	var state: Dictionary = {}
	for script_cls: Script in _models:
		var model: Variant = _models[script_cls]
		if model.has_method("to_dict"):
			var class_name_key: String = _get_model_key(script_cls)
			state[class_name_key] = model.to_dict()
	return state


## 从状态字典恢复所有已注册 Model 的数据。
## @param data: 由 get_all_models_state() 返回的状态字典。
func restore_all_models_state(data: Dictionary) -> void:
	for script_cls: Script in _models:
		var class_name_key: String = _get_model_key(script_cls)
		if data.has(class_name_key):
			var model: Variant = _models[script_cls]
			if model.has_method("from_dict"):
				model.from_dict(data[class_name_key])


# --- 私有/内部方法 ---

## 获取经过时间工具缩放后的 delta。若未注册 GFTimeUtility，则返回原始 delta。
## @param delta: 引擎原始帧间隔时间。
## @return 缩放后的 delta。
func _get_scaled_delta(delta: float) -> float:
	if _time_utility == null:
		return delta
	return _time_utility.get_scaled_delta(delta)


## 从脚本类获取用于序列化的稳定字符串键。
## 优先使用 class_name（全局类名），回退到资源路径，最终回退到对象标识。
## @param script_cls: 脚本类。
## @return 用于序列化字典键的字符串。
func _get_model_key(script_cls: Script) -> String:
	var global_name: StringName = script_cls.get_global_name()
	if global_name != &"":
		return String(global_name)
	if not script_cls.resource_path.is_empty():
		return script_cls.resource_path
	return "Script_%d" % script_cls.get_instance_id()


## 内部初始化回调，子类可重写。
func _on_init() -> void:
	pass


## 内部销毁回调，子类可重写。
func _on_dispose() -> void:
	pass
