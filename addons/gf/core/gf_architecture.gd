class_name GFArchitecture


## GFArchitecture: 管理 Model、System 和 Utility 的注册与生命周期的容器。
##
## 生命周期遵循三阶段初始化协议：
##   阶段一 (init)       ：所有模块执行自身内部变量初始化。
##   阶段二 (async_init) ：所有模块串行执行异步初始化（可使用 await）。
##   阶段三 (ready)      ：所有模块均已完成 init，可安全进行跨模块依赖获取。


# --- 信号 ---

## 当一次初始化流程完成或被 dispose() 中断后发出。
signal initialization_finished

## 当一次初始化流程因为框架级保护失败后发出。
## @param reason: 初始化失败原因。
signal initialization_failed(reason: String)

## 当项目级 Installer 应用完成或被 dispose() 中断后发出。
signal project_installers_finished


# --- 常量 ---

const GFBindingBase = preload("res://addons/gf/core/gf_binding.gd")
const GFBinderBase = preload("res://addons/gf/core/gf_binder.gd")
const GFBindingLifetimesBase = preload("res://addons/gf/core/gf_binding_lifetimes.gd")


# --- 公共变量 ---

## 单个模块 async_init() 的最长等待时间。小于等于 0 时不启用超时。
## 默认关闭以保持旧项目的初始化语义。
var module_async_init_timeout_seconds: float = 0.0:
	set(value):
		module_async_init_timeout_seconds = maxf(value, 0.0)

## 单个生命周期阶段最多扫描模块注册表的次数，避免模块在生命周期中无限注册新模块。
var module_lifecycle_max_stage_passes: int = 256:
	set(value):
		module_lifecycle_max_stage_passes = maxi(value, 1)

## 严格依赖查询模式。开启后本架构查询不到本地模块时不会回退父级架构。
var strict_dependency_lookup: bool = false

## 最近一次初始化失败原因；没有失败时为空字符串。
var last_initialization_error: String = ""


# --- 私有变量 ---

var _systems: Dictionary = {}
var _models: Dictionary = {}
var _utilities: Dictionary = {}
var _factories: Dictionary = {}
var _system_aliases: Dictionary = {}
var _model_aliases: Dictionary = {}
var _utility_aliases: Dictionary = {}
var _module_lifecycle_stages: Dictionary = {}
var _event_system: TypeEventSystem
var _time_utility: GFTimeUtility
var _inited: bool = false
var _is_initializing: bool = false
var _lifecycle_serial: int = 0
var _tick_systems: Array[Object] = []
var _physics_systems: Array[Object] = []
var _tick_utilities: Array[Object] = []
var _physics_utilities: Array[Object] = []
var _is_iterating_tick_caches: bool = false
var _tick_caches_dirty: bool = false
var _parent_architecture: GFArchitecture = null
var _project_installers_applied: bool = false
var _project_installers_running: bool = false
var _initialization_failed: bool = false


# --- Godot 生命周期方法 ---

func _init(parent_architecture: GFArchitecture = null) -> void:
	_parent_architecture = parent_architecture
	_event_system = TypeEventSystem.new()


# --- 公共方法 ---

## 检查架构是否已初始化。
## @return 已初始化返回 true，否则返回 false。
func is_inited() -> bool:
	return _inited


## 检查最近一次初始化是否因为框架级保护失败。
## @return 最近一次初始化失败返回 true。
func has_initialization_failed() -> bool:
	return _initialization_failed


## 获取父级架构。Scoped 架构会在本地未找到依赖时回退到父级架构查询。
## @return 父级架构实例；未设置时返回 null。
func get_parent_architecture() -> GFArchitecture:
	return _parent_architecture


## 设置父级架构。不会接管父级生命周期。
## @param parent_architecture: 要作为依赖回退来源的父级架构。
func set_parent_architecture(parent_architecture: GFArchitecture) -> void:
	_parent_architecture = parent_architecture


## 检查项目级 Installer 是否已经应用到当前架构。
## @return 已应用返回 true。
func has_project_installers_applied() -> bool:
	return _project_installers_applied


## 检查项目级 Installer 是否正在应用。
## @return 正在应用返回 true。
func is_project_installers_running() -> bool:
	return _project_installers_running


## 标记项目级 Installer 已开始应用。
## @return 成功开始返回 true；已经完成或正在运行时返回 false。
func begin_project_installers() -> bool:
	if _project_installers_applied or _project_installers_running:
		return false

	_project_installers_running = true
	return true


## 标记项目级 Installer 已应用。由 Gf 启动入口调用。
func mark_project_installers_applied() -> void:
	var was_running := _project_installers_running
	_project_installers_applied = true
	_project_installers_running = false
	if was_running:
		project_installers_finished.emit()


## 标记项目级 Installer 应用完成并唤醒等待方。
func finish_project_installers() -> void:
	mark_project_installers_applied()


## 创建一个声明式装配器，便于 Installer 使用 fluent API 注册模块与工厂。
## @return 绑定到当前架构的装配器。
func create_binder() -> Variant:
	return GFBinderBase.new(self)


## 初始化架构及所有注册的组件（三阶段）。
## 阶段一：调用所有模块的 init()，用于初始化自身内部变量。
## 阶段二：串行 await 所有模块的 async_init()，用于异步资源加载等操作。
## 阶段三：调用所有模块的 ready()，此时跨模块依赖获取是安全的。
func init() -> void:
	if _inited:
		return

	if _is_initializing:
		var waiting_serial := _lifecycle_serial
		while _is_initializing and waiting_serial == _lifecycle_serial:
			await initialization_finished
		return

	_lifecycle_serial += 1
	var current_serial := _lifecycle_serial
	_is_initializing = true
	_initialization_failed = false
	last_initialization_error = ""
	_on_init()
	await _advance_all_modules_to_stage(1, current_serial)
	if not _is_lifecycle_current(current_serial) or _initialization_failed:
		return
	await _advance_all_modules_to_stage(2, current_serial)
	if not _is_lifecycle_current(current_serial) or _initialization_failed:
		return
	await _advance_all_modules_to_stage(3, current_serial)
	if not _is_lifecycle_current(current_serial) or _initialization_failed:
		return

	_time_utility = get_local_utility(GFTimeUtility) as GFTimeUtility
	if _time_utility == null and not strict_dependency_lookup and _parent_architecture != null:
		_time_utility = _parent_architecture.get_utility(GFTimeUtility) as GFTimeUtility
	_inited = true
	_is_initializing = false
	initialization_finished.emit()


## 销毁架构及所有注册的组件。
func dispose() -> void:
	var was_initializing := _is_initializing
	_lifecycle_serial += 1
	_is_initializing = false

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
	for binding_variant: Variant in _factories.values():
		var binding := binding_variant as Object
		if binding != null and binding.has_method("clear_cached_instance"):
			binding.call("clear_cached_instance")
	_models.clear()
	_systems.clear()
	_utilities.clear()
	_factories.clear()
	_model_aliases.clear()
	_system_aliases.clear()
	_utility_aliases.clear()
	_module_lifecycle_stages.clear()
	_event_system.clear()
	_time_utility = null
	_inited = false
	_initialization_failed = false
	last_initialization_error = ""
	_reset_project_installers()
	_refresh_tick_caches()
	if was_initializing:
		initialization_finished.emit()


## 驱动所有已注册 System 与带 tick() 方法的 Utility 的每帧更新。
## 在架构初始化完成后方可生效。
## 若已注册 GFTimeUtility，则自动将 delta 经过时间缩放/暂停处理后再传递给参与 tick 的模块。
## 设置了 ignore_pause 的模块在暂停时将接收原始 delta。
## 设置了 ignore_time_scale 的模块在未暂停时将跳过 time_scale。
## @param delta: 距上一帧的时间（秒）。
func tick(delta: float) -> void:
	if not _inited:
		return
	var scaled_delta: float = _get_scaled_delta(delta)
	_is_iterating_tick_caches = true
	for system: Object in _tick_systems:
		if is_instance_valid(system) and _is_module_ready_for_tick(system):
			system.tick(_get_module_delta(system, delta, scaled_delta))
	for utility: Object in _tick_utilities:
		if is_instance_valid(utility) and _is_module_ready_for_tick(utility):
			utility.tick(_get_module_delta(utility, delta, scaled_delta))
	_is_iterating_tick_caches = false
	_flush_tick_cache_refresh()


## 驱动所有已注册 System 与带 physics_tick() 方法的 Utility 的每物理帧更新。
## 在架构初始化完成后方可生效。
## 若已注册 GFTimeUtility，则自动将 delta 经过时间缩放/暂停处理后再传递给参与 physics_tick 的模块。
## 设置了 ignore_pause 的模块在暂停时将接收原始 delta。
## 设置了 ignore_time_scale 的模块在未暂停时将跳过 time_scale。
## @param delta: 距上一物理帧的时间（秒）。
func physics_tick(delta: float) -> void:
	if not _inited:
		return
	if _time_utility != null and _time_utility.should_substep_physics(delta):
		var scaled_steps := _time_utility.get_physics_scaled_delta_steps(delta)
		var raw_step := delta / float(scaled_steps.size())
		for scaled_step: float in scaled_steps:
			_drive_physics_tick_step(raw_step, scaled_step)
		return

	var scaled_delta: float = _get_scaled_delta(delta)
	_drive_physics_tick_step(delta, scaled_delta)


## 执行命令实例。支持 await：'await send_command(MyCommand.new())'。
## @param command: 要执行的命令实例。
## @return 命令的执行结果（null 或 Signal）。
func send_command(command: Object) -> Variant:
	if command == null:
		push_error("[GFArchitecture] send_command 失败：command 为空。")
		return null

	_inject_dependencies_if_needed(command)
	if command.has_method("execute"):
		return command.execute()
	return null


## 执行查询实例并返回结果。
## @param query: 要执行的查询实例。
## @return 查询执行的结果。
func send_query(query: Object) -> Variant:
	if query == null:
		push_error("[GFArchitecture] send_query 失败：query 为空。")
		return null

	_inject_dependencies_if_needed(query)
	if query.has_method("execute"):
		return query.execute()
	return null


## 通过事件系统发送类型事件实例。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	if event_instance == null:
		push_error("[GFArchitecture] send_event 失败：event_instance 为空。")
		return

	_event_system.send(event_instance)


## 为脚本类型注册事件监听器。
## @param event_type: 要监听的脚本类型。
## @param on_event: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_event(event_type: Script, on_event: Callable, priority: int = 0) -> void:
	_event_system.register(event_type, on_event, priority)


## 为脚本类型注册带拥有者的事件监听器。
## 拥有者注销或释放后，可通过 unregister_owner_events() 一次性清理相关监听。
## @param owner: 监听器拥有者。
## @param event_type: 要监听的脚本类型。
## @param on_event: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_event_owned(owner: Object, event_type: Script, on_event: Callable, priority: int = 0) -> void:
	_event_system.register(event_type, on_event, priority, owner)


## 为脚本类型注册可赋值事件监听器。
## 监听基类事件时，也会收到继承自该脚本类型的事件实例。
## @param base_event_type: 要监听的基类脚本类型。
## @param on_event: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_assignable_event(base_event_type: Script, on_event: Callable, priority: int = 0) -> void:
	_event_system.register_assignable(base_event_type, on_event, priority)


## 为脚本类型注册带拥有者的可赋值事件监听器。
## @param owner: 监听器拥有者。
## @param base_event_type: 要监听的基类脚本类型。
## @param on_event: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_assignable_event_owned(
	owner: Object,
	base_event_type: Script,
	on_event: Callable,
	priority: int = 0
) -> void:
	_event_system.register_assignable(base_event_type, on_event, priority, owner)


## 为脚本类型注销事件监听器。
## @param event_type: 要注销的脚本类型。
## @param on_event: 要移除的回调函数。
func unregister_event(event_type: Script, on_event: Callable) -> void:
	_event_system.unregister(event_type, on_event)


## 注销可赋值类型事件监听器。
## @param base_event_type: 注册时使用的基类脚本类型。
## @param on_event: 要移除的回调函数。
func unregister_assignable_event(base_event_type: Script, on_event: Callable) -> void:
	_event_system.unregister_assignable(base_event_type, on_event)


## 注册轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param on_event: 回调函数，签名为 func(payload: Variant)。
func register_simple_event(event_id: StringName, on_event: Callable) -> void:
	_event_system.register_simple(event_id, on_event)


## 注册带拥有者的轻量级 StringName 事件监听器。
## @param owner: 监听器拥有者。
## @param event_id: StringName 事件标识符。
## @param on_event: 回调函数，签名为 func(payload: Variant)。
func register_simple_event_owned(owner: Object, event_id: StringName, on_event: Callable) -> void:
	_event_system.register_simple(event_id, on_event, owner)


## 注销轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param on_event: 要移除的回调函数。
func unregister_simple_event(event_id: StringName, on_event: Callable) -> void:
	_event_system.unregister_simple(event_id, on_event)


## 注销某个拥有者注册过的所有事件监听器。
## @param owner: 要清理监听器的拥有者。
func unregister_owner_events(owner: Object) -> void:
	_event_system.unregister_owner(owner)


## 发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。
## @param event_id: StringName 事件标识符。
## @param payload: 可选的事件附加数据。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	_event_system.send_simple(event_id, payload)


## 获取事件系统诊断统计。
## @return 包含各事件轨道监听数量与 pending 操作数量的字典。
func get_event_debug_stats() -> Dictionary:
	return _event_system.get_debug_stats()


# --- 注册方法 ---

## 注册 System 实例。
## @param script_cls: 系统的脚本类。
## @param instance: 系统实例。
func register_system(script_cls: Script, instance: Object) -> void:
	if not _validate_registration(script_cls, instance, "System"):
		return
	if _systems.has(script_cls):
		push_warning("[GFArchitecture] register_system：类型已注册，已忽略重复注册。若需要替换，请使用 replace_system()。")
		return

	_inject_dependencies_if_needed(instance)
	_systems[script_cls] = instance
	_track_registered_module(instance)
	_refresh_tick_caches()
	if _inited:
		await _initialize_registered_module(instance)


## 注册 Model 实例。
## @param script_cls: 模型的脚本类。
## @param instance: 模型实例。
func register_model(script_cls: Script, instance: Object) -> void:
	if not _validate_registration(script_cls, instance, "Model"):
		return
	if _models.has(script_cls):
		push_warning("[GFArchitecture] register_model：类型已注册，已忽略重复注册。若需要替换，请使用 replace_model()。")
		return

	_inject_dependencies_if_needed(instance)
	_models[script_cls] = instance
	_track_registered_module(instance)
	if _inited:
		await _initialize_registered_module(instance)


## 注册 Utility 实例。
## @param script_cls: 工具的脚本类。
## @param instance: 工具实例。
func register_utility(script_cls: Script, instance: Object) -> void:
	if not _validate_registration(script_cls, instance, "Utility"):
		return
	if _utilities.has(script_cls):
		push_warning("[GFArchitecture] register_utility：类型已注册，已忽略重复注册。若需要替换，请使用 replace_utility()。")
		return

	_inject_dependencies_if_needed(instance)
	_utilities[script_cls] = instance
	_track_registered_module(instance)
	_refresh_cached_utility_refs()
	_refresh_tick_caches()
	if _inited:
		await _initialize_registered_module(instance)
		_refresh_cached_utility_refs()


## 替换 System 实例。若旧实例存在，会先调用 dispose() 并移除相关别名。
## @param script_cls: 系统的脚本类。
## @param instance: 新系统实例。
func replace_system(script_cls: Script, instance: Object) -> void:
	if not _validate_registration(script_cls, instance, "System"):
		return
	if _systems.has(script_cls):
		unregister_system(script_cls)
	await register_system(script_cls, instance)


## 替换 Model 实例。若旧实例存在，会先调用 dispose() 并移除相关别名。
## @param script_cls: 模型的脚本类。
## @param instance: 新模型实例。
func replace_model(script_cls: Script, instance: Object) -> void:
	if not _validate_registration(script_cls, instance, "Model"):
		return
	if _models.has(script_cls):
		unregister_model(script_cls)
	await register_model(script_cls, instance)


## 替换 Utility 实例。若旧实例存在，会先调用 dispose() 并移除相关别名。
## @param script_cls: 工具的脚本类。
## @param instance: 新工具实例。
func replace_utility(script_cls: Script, instance: Object) -> void:
	if not _validate_registration(script_cls, instance, "Utility"):
		return
	if _utilities.has(script_cls):
		unregister_utility(script_cls)
	await register_utility(script_cls, instance)


## 注册短生命周期对象工厂。
## @param script_cls: 要创建的脚本类型。
## @param factory: 返回对象实例的工厂回调。
## @param lifetime: 工厂生命周期，默认每次 create_instance() 都创建新对象。
func register_factory(
	script_cls: Script,
	factory: Callable,
	lifetime: int = GFBindingLifetimesBase.Lifetime.TRANSIENT
) -> void:
	if script_cls == null:
		push_error("[GFArchitecture] register_factory 失败：脚本类型为空。")
		return
	if not factory.is_valid():
		push_error("[GFArchitecture] register_factory 失败：factory 无效。")
		return
	if _factories.has(script_cls):
		push_warning("[GFArchitecture] register_factory：类型已注册，已忽略重复注册。若需要替换，请使用 replace_factory()。")
		return
	_factories[script_cls] = GFBindingBase.new(script_cls, factory, self, lifetime, true)


## 注册已有实例作为短生命周期工厂入口。该实例以单例方式返回。
## @param script_cls: 要创建的脚本类型。
## @param instance: 要暴露的实例。
func register_factory_instance(script_cls: Script, instance: Object) -> void:
	if script_cls == null:
		push_error("[GFArchitecture] register_factory_instance 失败：脚本类型为空。")
		return
	if instance == null:
		push_error("[GFArchitecture] register_factory_instance 失败：实例为空。")
		return
	if _factories.has(script_cls):
		push_warning("[GFArchitecture] register_factory_instance：类型已注册，已忽略重复注册。若需要替换，请使用 replace_factory_instance()。")
		return
	_factories[script_cls] = GFBindingBase.new(script_cls, instance, self, GFBindingLifetimesBase.Lifetime.SINGLETON, true)


## 替换短生命周期对象工厂。
## @param script_cls: 要创建的脚本类型。
## @param factory: 新工厂回调。
## @param lifetime: 工厂生命周期。
func replace_factory(
	script_cls: Script,
	factory: Callable,
	lifetime: int = GFBindingLifetimesBase.Lifetime.TRANSIENT
) -> void:
	if script_cls == null:
		push_error("[GFArchitecture] replace_factory 失败：脚本类型为空。")
		return
	if not factory.is_valid():
		push_error("[GFArchitecture] replace_factory 失败：factory 无效。")
		return
	_factories[script_cls] = GFBindingBase.new(script_cls, factory, self, lifetime, true)


## 替换已有实例工厂入口。
## @param script_cls: 要创建的脚本类型。
## @param instance: 要暴露的实例。
func replace_factory_instance(script_cls: Script, instance: Object) -> void:
	if script_cls == null:
		push_error("[GFArchitecture] replace_factory_instance 失败：脚本类型为空。")
		return
	if instance == null:
		push_error("[GFArchitecture] replace_factory_instance 失败：实例为空。")
		return
	_factories[script_cls] = GFBindingBase.new(script_cls, instance, self, GFBindingLifetimesBase.Lifetime.SINGLETON, true)


## 注销短生命周期对象工厂。
## @param script_cls: 要移除的脚本类型。
func unregister_factory(script_cls: Script) -> void:
	_factories.erase(script_cls)


## 检查当前架构或父级架构是否注册了指定工厂。
## @param script_cls: 要查询的脚本类型。
func has_factory(script_cls: Script) -> bool:
	if script_cls == null:
		return false
	if _factories.has(script_cls):
		return true
	if _parent_architecture != null and not strict_dependency_lookup:
		return _parent_architecture.has_factory(script_cls)
	return false


## 为已注册 System 增加一个额外查询别名。
## 适合把具体实现以抽象基类或接口式脚本暴露给调用方。
## @param alias_cls: 调用 get_system() 时使用的别名脚本类。
## @param target_cls: 已注册 System 的实际脚本类。
func register_system_alias(alias_cls: Script, target_cls: Script) -> void:
	_register_alias(_system_aliases, _systems, alias_cls, target_cls, "System")


## 为已注册 Model 增加一个额外查询别名。
## @param alias_cls: 调用 get_model() 时使用的别名脚本类。
## @param target_cls: 已注册 Model 的实际脚本类。
func register_model_alias(alias_cls: Script, target_cls: Script) -> void:
	_register_alias(_model_aliases, _models, alias_cls, target_cls, "Model")


## 为已注册 Utility 增加一个额外查询别名。
## @param alias_cls: 调用 get_utility() 时使用的别名脚本类。
## @param target_cls: 已注册 Utility 的实际脚本类。
func register_utility_alias(alias_cls: Script, target_cls: Script) -> void:
	_register_alias(_utility_aliases, _utilities, alias_cls, target_cls, "Utility")


## 便捷注册 System 实例，自动从实例获取脚本类作为注册键。
## @param instance: 系统实例，必须附加有 GDScript 脚本。
func register_system_instance(instance: Object) -> void:
	if instance == null:
		push_error("[GFArchitecture] register_system_instance 失败：实例为空。")
		return
	var script := instance.get_script() as Script
	if script == null:
		push_error("[GFArchitecture] register_system_instance 失败：实例未附加脚本。")
		return
	await register_system(script, instance)


## 便捷注册 Model 实例，自动从实例获取脚本类作为注册键。
## @param instance: 模型实例，必须附加有 GDScript 脚本。
func register_model_instance(instance: Object) -> void:
	if instance == null:
		push_error("[GFArchitecture] register_model_instance 失败：实例为空。")
		return
	var script := instance.get_script() as Script
	if script == null:
		push_error("[GFArchitecture] register_model_instance 失败：实例未附加脚本。")
		return
	await register_model(script, instance)


## 便捷注册 Utility 实例，自动从实例获取脚本类作为注册键。
## @param instance: 工具实例，必须附加有 GDScript 脚本。
func register_utility_instance(instance: Object) -> void:
	if instance == null:
		push_error("[GFArchitecture] register_utility_instance 失败：实例为空。")
		return
	var script := instance.get_script() as Script
	if script == null:
		push_error("[GFArchitecture] register_utility_instance 失败：实例未附加脚本。")
		return
	await register_utility(script, instance)


## 便捷注册 System，并同时以 alias_cls 作为额外查询键。
## @param instance: System 实例。
## @param alias_cls: 额外查询脚本类。
func register_system_instance_as(instance: Object, alias_cls: Script) -> void:
	var script := _get_instance_script_or_null(instance, "register_system_instance_as")
	if script == null:
		return

	await register_system_instance(instance)
	if _systems.has(script):
		register_system_alias(alias_cls, script)


## 便捷注册 Model，并同时以 alias_cls 作为额外查询键。
## @param instance: Model 实例。
## @param alias_cls: 额外查询脚本类。
func register_model_instance_as(instance: Object, alias_cls: Script) -> void:
	var script := _get_instance_script_or_null(instance, "register_model_instance_as")
	if script == null:
		return

	await register_model_instance(instance)
	if _models.has(script):
		register_model_alias(alias_cls, script)


## 便捷注册 Utility，并同时以 alias_cls 作为额外查询键。
## @param instance: Utility 实例。
## @param alias_cls: 额外查询脚本类。
func register_utility_instance_as(instance: Object, alias_cls: Script) -> void:
	var script := _get_instance_script_or_null(instance, "register_utility_instance_as")
	if script == null:
		return

	await register_utility_instance(instance)
	if _utilities.has(script):
		register_utility_alias(alias_cls, script)


## 注销 System 实例。
## @param script_cls: 系统的脚本类。
func unregister_system(script_cls: Script) -> void:
	var registered_key := _resolve_registered_key(_systems, _system_aliases, script_cls)
	if registered_key != null and _systems.has(registered_key):
		var system: Variant = _systems[registered_key]
		if system.has_method("dispose"):
			system.dispose()
		if system is Object:
			_event_system.unregister_owner(system)
		_module_lifecycle_stages.erase(system)
		_systems.erase(registered_key)
		_remove_aliases_for(_system_aliases, registered_key)
		_refresh_tick_caches()
	else:
		_system_aliases.erase(script_cls)


## 注销 Model 实例。
## @param script_cls: 模型的脚本类。
func unregister_model(script_cls: Script) -> void:
	var registered_key := _resolve_registered_key(_models, _model_aliases, script_cls)
	if registered_key != null and _models.has(registered_key):
		var model: Variant = _models[registered_key]
		if model.has_method("dispose"):
			model.dispose()
		if model is Object:
			_event_system.unregister_owner(model)
		_module_lifecycle_stages.erase(model)
		_models.erase(registered_key)
		_remove_aliases_for(_model_aliases, registered_key)
	else:
		_model_aliases.erase(script_cls)


## 注销 Utility 实例。
## @param script_cls: 工具的脚本类。
func unregister_utility(script_cls: Script) -> void:
	var registered_key := _resolve_registered_key(_utilities, _utility_aliases, script_cls)
	if registered_key != null and _utilities.has(registered_key):
		var utility: Variant = _utilities[registered_key]
		if utility.has_method("dispose"):
			utility.dispose()
		if utility is Object:
			_event_system.unregister_owner(utility)
		_module_lifecycle_stages.erase(utility)
		_utilities.erase(registered_key)
		_remove_aliases_for(_utility_aliases, registered_key)
		_refresh_cached_utility_refs()
		_refresh_tick_caches()
	else:
		_utility_aliases.erase(script_cls)


# --- 获取方法 ---

## 通过脚本类获取 System 实例。
## @param script_cls: 脚本类。
## @return 系统实例，如果未找到则返回 null。
func get_system(script_cls: Script) -> Object:
	var instance := _get_local_registered_instance(_systems, _system_aliases, script_cls, "System")
	if instance != null:
		return instance
	if _parent_architecture != null and not strict_dependency_lookup and not _has_assignable_instance(_systems, script_cls):
		return _parent_architecture.get_system(script_cls)
	if strict_dependency_lookup:
		_report_strict_lookup_miss(script_cls, "System")
	return null


## 通过脚本类获取 Model 实例。
## @param script_cls: 脚本类。
## @return 模型实例，如果未找到则返回 null。
func get_model(script_cls: Script) -> Object:
	var instance := _get_local_registered_instance(_models, _model_aliases, script_cls, "Model")
	if instance != null:
		return instance
	if _parent_architecture != null and not strict_dependency_lookup and not _has_assignable_instance(_models, script_cls):
		return _parent_architecture.get_model(script_cls)
	if strict_dependency_lookup:
		_report_strict_lookup_miss(script_cls, "Model")
	return null


## 通过脚本类获取 Utility 实例。
## @param script_cls: 脚本类。
## @return 工具实例，如果未找到则返回 null。
func get_utility(script_cls: Script) -> Object:
	var instance := _get_local_registered_instance(_utilities, _utility_aliases, script_cls, "Utility")
	if instance != null:
		return instance
	if _parent_architecture != null and not strict_dependency_lookup and not _has_assignable_instance(_utilities, script_cls):
		return _parent_architecture.get_utility(script_cls)
	if strict_dependency_lookup:
		_report_strict_lookup_miss(script_cls, "Utility")
	return null


## 仅从当前架构获取 System，不回退父级架构。
## @param script_cls: 脚本类。
## @return 当前架构中的系统实例，如果未找到则返回 null。
func get_local_system(script_cls: Script) -> Object:
	return _get_local_registered_instance(_systems, _system_aliases, script_cls, "System")


## 仅从当前架构获取 Model，不回退父级架构。
## @param script_cls: 脚本类。
## @return 当前架构中的模型实例，如果未找到则返回 null。
func get_local_model(script_cls: Script) -> Object:
	return _get_local_registered_instance(_models, _model_aliases, script_cls, "Model")


## 仅从当前架构获取 Utility，不回退父级架构。
## @param script_cls: 脚本类。
## @return 当前架构中的工具实例，如果未找到则返回 null。
func get_local_utility(script_cls: Script) -> Object:
	return _get_local_registered_instance(_utilities, _utility_aliases, script_cls, "Utility")


## 通过已注册工厂创建短生命周期对象。
## @param script_cls: 要创建的脚本类型。
## @return 新对象实例；没有工厂或工厂返回非对象时返回 null。
func create_instance(script_cls: Script) -> Object:
	if script_cls == null:
		push_error("[GFArchitecture] create_instance 失败：脚本类型为空。")
		return null

	return _create_instance_for_requester(script_cls, self)


## 向任意对象注入当前架构依赖。
## @param instance: 需要注入的对象。
func inject_object(instance: Object) -> void:
	_inject_dependencies_if_needed(instance)


## 递归向节点树中实现注入 Hook 的节点注入当前架构。
## @param node: 节点树根节点。
func inject_node_tree(node: Node) -> void:
	if node == null:
		return

	_inject_node_tree(node)


# --- 序列化方法 ---

## 收集所有已注册 Model 的状态快照。
## 遍历所有 Model，调用其 to_dict() 方法，以脚本类的全局类名为键汇聚成一个字典。
## @return 包含所有 Model 状态的字典，可直接用于 JSON 序列化。
func get_all_models_state() -> Dictionary:
	var state: Dictionary = {}
	for script_cls: Script in _models:
		var model: Variant = _models[script_cls]
		if model.has_method("to_dict"):
			var class_name_key: String = _get_model_key(script_cls, model as Object)
			if class_name_key.is_empty():
				continue
			state[class_name_key] = model.to_dict()
	return state


## 从状态字典恢复所有已注册 Model 的数据。
## @param data: 由 get_all_models_state() 返回的状态字典。
func restore_all_models_state(data: Dictionary) -> void:
	for script_cls: Script in _models:
		var model := _models[script_cls] as Object
		var class_name_key: String = _get_model_key(script_cls, model)
		if class_name_key.is_empty():
			continue
		if data.has(class_name_key):
			if model.has_method("from_dict"):
				model.from_dict(data[class_name_key])


## 获取整个框架的全局快照，包含所有 Model 状态以及（如果已注册）命令历史记录。
## @return 包含全局快照数据的字典。可直接用于 JSON 序列化。
func get_global_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	
	# 打包所有的 Model 状态
	snapshot["models"] = get_all_models_state()
	
	# 打包命令操作历史（如果有）
	var history_util := get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility
	if history_util != null:
		snapshot["command_history"] = history_util.serialize_full_history()
		
	return snapshot


## 从全局快照中恢复整个框架的状态，包含 Model 状态以及（如果已注册）命令历史记录。
## 注意：恢复命令历史需要外部传入 CommandBuilder 进行控制反转，因为它涉及到具体的业务命令类实例化。
## @param data: 由 get_global_snapshot() 导出的全局快照字典数据。
## @param command_builder: 【可选】如果需要恢复历史记录，必须传入用于反序列化具体 Command 实例的 Callable。
func restore_global_snapshot(data: Dictionary, command_builder: Callable = Callable()) -> void:
	if data.has("models"):
		restore_all_models_state(data["models"])
		
	if data.has("command_history"):
		var history_util := get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility
		if history_util != null:
			if command_builder.is_valid():
				var history_data: Variant = data["command_history"]
				if typeof(history_data) == TYPE_DICTIONARY:
					history_util.deserialize_full_history(history_data, command_builder)
				elif typeof(history_data) == TYPE_ARRAY:
					history_util.deserialize_history(history_data, command_builder)
			else:
				push_warning("[GFArchitecture] restore_global_snapshot：快照包含命令历史数据，但未提供有效的 command_builder，跳过历史恢复。")


## 获取架构模块生命周期诊断快照。
## @return 包含 Model、System、Utility、Factory、Alias 与 Tick 缓存状态的字典。
func get_debug_lifecycle_state() -> Dictionary:
	return {
		"inited": _inited,
		"is_initializing": _is_initializing,
		"models": _collect_module_debug_state(_models),
		"systems": _collect_module_debug_state(_systems),
		"utilities": _collect_module_debug_state(_utilities),
		"factories": _collect_factory_debug_state(),
		"aliases": {
			"models": _model_aliases.size(),
			"systems": _system_aliases.size(),
			"utilities": _utility_aliases.size(),
		},
		"tick": {
			"systems": _tick_systems.size(),
			"physics_systems": _physics_systems.size(),
			"utilities": _tick_utilities.size(),
			"physics_utilities": _physics_utilities.size(),
		},
	}


# --- 私有/内部方法 ---

func _reset_project_installers() -> void:
	var was_running := _project_installers_running
	_project_installers_applied = false
	_project_installers_running = false
	if was_running:
		project_installers_finished.emit()


## 获取经过时间工具缩放后的 delta。若未注册 GFTimeUtility，则返回原始 delta。
## @param delta: 引擎原始帧间隔时间。
## @return 缩放后的 delta。
func _get_scaled_delta(delta: float) -> float:
	if _time_utility == null:
		return delta
	return _time_utility.get_scaled_delta(delta)


func _drive_physics_tick_step(raw_delta: float, scaled_delta: float) -> void:
	_is_iterating_tick_caches = true
	for system: Object in _physics_systems:
		if is_instance_valid(system) and _is_module_ready_for_tick(system):
			system.physics_tick(_get_module_delta(system, raw_delta, scaled_delta))
	for utility: Object in _physics_utilities:
		if is_instance_valid(utility) and _is_module_ready_for_tick(utility):
			utility.physics_tick(_get_module_delta(utility, raw_delta, scaled_delta))
	_is_iterating_tick_caches = false
	_flush_tick_cache_refresh()


## 根据模块的 ignore_pause 设置获取本次 tick 应使用的 delta。
## @param instance: 被驱动的模块实例。
## @param raw_delta: 引擎原始 delta。
## @param scaled_delta: 已经由 GFTimeUtility 处理后的 delta。
## @return 模块本次应接收的 delta。
func _get_module_delta(instance: Object, raw_delta: float, scaled_delta: float) -> float:
	if _time_utility == null:
		return raw_delta

	var ignores_pause: bool = "ignore_pause" in instance and instance.get("ignore_pause") == true
	var ignores_time_scale: bool = "ignore_time_scale" in instance and instance.get("ignore_time_scale") == true
	if _time_utility.is_paused:
		return raw_delta if ignores_pause else 0.0

	if ignores_time_scale:
		return raw_delta
	return scaled_delta


func _collect_module_debug_state(registry: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for script_cls: Script in registry.keys():
		var instance := registry[script_cls] as Object
		var stage: int = _module_lifecycle_stages.get(instance, 0)
		var ignores_pause: bool = (
			instance != null
			and "ignore_pause" in instance
			and instance.get("ignore_pause") == true
		)
		var ignores_time_scale: bool = (
			instance != null
			and "ignore_time_scale" in instance
			and instance.get("ignore_time_scale") == true
		)
		result[_get_script_debug_key(script_cls, instance)] = {
			"stage": stage,
			"stage_name": _get_lifecycle_stage_name(stage),
			"ready": stage >= 3,
			"has_tick": instance != null and instance.has_method("tick"),
			"has_physics_tick": instance != null and instance.has_method("physics_tick"),
			"ignore_pause": ignores_pause,
			"ignore_time_scale": ignores_time_scale,
		}
	return result


func _collect_factory_debug_state() -> Dictionary:
	var result: Dictionary = {}
	for script_cls: Script in _factories.keys():
		var binding := _factories[script_cls] as Object
		var lifetime := -1
		if binding != null and "lifetime" in binding:
			lifetime = int(binding.get("lifetime"))
		result[_get_script_debug_key(script_cls)] = {
			"lifetime": lifetime,
			"lifetime_name": _get_binding_lifetime_name(lifetime),
			"valid": binding != null,
		}
	return result


func _get_lifecycle_stage_name(stage: int) -> String:
	match stage:
		0:
			return "registered"
		1:
			return "init"
		2:
			return "async_init"
		3:
			return "ready"
		_:
			return "unknown"


func _get_binding_lifetime_name(lifetime: int) -> String:
	match lifetime:
		GFBindingLifetimesBase.Lifetime.TRANSIENT:
			return "transient"
		GFBindingLifetimesBase.Lifetime.SINGLETON:
			return "singleton"
		_:
			return "unknown"


func _get_script_debug_key(script_cls: Script, instance: Object = null) -> String:
	if script_cls != null:
		var global_name: StringName = script_cls.get_global_name()
		if global_name != &"":
			return String(global_name)
		if not script_cls.resource_path.is_empty():
			return script_cls.resource_path
	if instance != null:
		var instance_script := instance.get_script() as Script
		if instance_script != null and not instance_script.resource_path.is_empty():
			return instance_script.resource_path
		return "Instance:%d" % instance.get_instance_id()
	return ""


func _get_instance_debug_key(instance: Object) -> String:
	if instance == null:
		return "null"
	var script := instance.get_script() as Script
	if script != null:
		return _get_script_debug_key(script, instance)
	return "Instance:%d" % instance.get_instance_id()


## 从脚本类获取用于序列化的稳定字符串键。
## 优先使用 Model.get_save_key()，其次使用 class_name（全局类名），最后回退到资源路径。
## @param script_cls: 脚本类。
## @param model: 可选 Model 实例。
## @return 用于序列化字典键的字符串。
func _get_model_key(script_cls: Script, model: Object = null) -> String:
	if model != null and model.has_method("get_save_key"):
		var raw_save_key: Variant = model.call("get_save_key")
		if typeof(raw_save_key) == TYPE_STRING or typeof(raw_save_key) == TYPE_STRING_NAME:
			var save_key := String(raw_save_key)
			if not save_key.is_empty():
				return save_key

	var global_name: StringName = script_cls.get_global_name()
	if global_name != &"":
		return String(global_name)
	if not script_cls.resource_path.is_empty():
		return script_cls.resource_path
	push_error("[GFArchitecture] 可序列化 Model 缺少稳定标识：请为脚本声明 class_name 或提供可用的资源路径。")
	return ""


## 内部初始化回调，子类可重写。
func _on_init() -> void:
	pass


## 内部销毁回调，子类可重写。
func _on_dispose() -> void:
	pass


func _initialize_registered_module(instance: Object) -> void:
	if instance == null:
		return
	var current_serial := _lifecycle_serial
	await _advance_module_to_stage(instance, 3, current_serial)


func _create_instance_for_requester(script_cls: Script, requesting_architecture: GFArchitecture) -> Object:
	if _factories.has(script_cls):
		var binding: RefCounted = _factories[script_cls] as RefCounted
		if binding == null or not binding.has_method("get_instance"):
			push_error("[GFArchitecture] create_instance 失败：工厂绑定无效。")
			return null
		return binding.get_instance(requesting_architecture)

	if _parent_architecture != null and not strict_dependency_lookup:
		return _parent_architecture._create_instance_for_requester(script_cls, requesting_architecture)

	if strict_dependency_lookup:
		push_error("[GFArchitecture] strict_dependency_lookup：当前架构未注册工厂：%s" % script_cls.resource_path)
	else:
		push_error("[GFArchitecture] create_instance 失败：未注册工厂。")
	return null


func _advance_all_modules_to_stage(target_stage: int, lifecycle_serial: int) -> void:
	var pass_count := 0
	while true:
		if not _is_lifecycle_current(lifecycle_serial) or _initialization_failed:
			return
		if pass_count >= module_lifecycle_max_stage_passes:
			_fail_initialization(
				"[GFArchitecture] 生命周期阶段推进超过上限：stage=%d, max_passes=%d。" % [
					target_stage,
					module_lifecycle_max_stage_passes,
				],
				lifecycle_serial
			)
			return

		var progressed: bool = false
		if await _advance_registry_to_stage(_models, target_stage, lifecycle_serial):
			progressed = true
		if await _advance_registry_to_stage(_utilities, target_stage, lifecycle_serial):
			progressed = true
		if await _advance_registry_to_stage(_systems, target_stage, lifecycle_serial):
			progressed = true
		if not progressed:
			return
		pass_count += 1


func _advance_registry_to_stage(registry: Dictionary, target_stage: int, lifecycle_serial: int) -> bool:
	var progressed: bool = false
	for instance: Variant in registry.values():
		if not _is_lifecycle_current(lifecycle_serial) or _initialization_failed:
			return progressed

		var current_stage: int = _module_lifecycle_stages.get(instance, 0)
		if current_stage < target_stage:
			await _advance_module_to_stage(instance, target_stage, lifecycle_serial)
			progressed = true
	return progressed


func _advance_module_to_stage(instance: Object, target_stage: int, lifecycle_serial: int) -> void:
	if instance == null:
		return

	var current_stage: int = _module_lifecycle_stages.get(instance, 0)
	while current_stage < target_stage:
		if not _is_lifecycle_current(lifecycle_serial) or _initialization_failed:
			return

		current_stage += 1
		match current_stage:
			1:
				if instance.has_method("init"):
					instance.init()
			2:
				if instance.has_method("async_init"):
					var async_completed := await _await_module_async_init(instance, lifecycle_serial)
					if not async_completed:
						return
			3:
				if instance.has_method("ready"):
					instance.ready()

		if not _is_lifecycle_current(lifecycle_serial) or _initialization_failed:
			return

		_module_lifecycle_stages[instance] = current_stage


func _await_module_async_init(instance: Object, lifecycle_serial: int) -> bool:
	if module_async_init_timeout_seconds <= 0.0:
		await instance.async_init()
		return _is_lifecycle_current(lifecycle_serial) and not _initialization_failed

	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		await instance.async_init()
		return _is_lifecycle_current(lifecycle_serial) and not _initialization_failed

	var completion_state := { "done": false }
	_complete_module_async_init(instance, completion_state)
	var start_msec := Time.get_ticks_msec()
	var timeout_msec := int(module_async_init_timeout_seconds * 1000.0)
	while not bool(completion_state.get("done", false)):
		if not _is_lifecycle_current(lifecycle_serial) or _initialization_failed:
			return false
		var elapsed_msec := Time.get_ticks_msec() - start_msec
		if elapsed_msec >= timeout_msec:
			_fail_initialization(
				"[GFArchitecture] async_init 超时：%s 超过 %.2f 秒。" % [
					_get_instance_debug_key(instance),
					module_async_init_timeout_seconds,
				],
				lifecycle_serial
			)
			return false
		await scene_tree.process_frame
	return _is_lifecycle_current(lifecycle_serial) and not _initialization_failed


func _complete_module_async_init(instance: Object, completion_state: Dictionary) -> void:
	await instance.async_init()
	completion_state["done"] = true


func _fail_initialization(reason: String, lifecycle_serial: int) -> void:
	if _initialization_failed or not _is_lifecycle_current(lifecycle_serial):
		return

	_initialization_failed = true
	last_initialization_error = reason
	_lifecycle_serial += 1
	_is_initializing = false
	_inited = false
	push_error(reason)
	initialization_failed.emit(reason)
	initialization_finished.emit()


func _track_registered_module(instance: Object) -> void:
	if instance == null:
		return
	if not _module_lifecycle_stages.has(instance):
		_module_lifecycle_stages[instance] = 0


func _inject_dependencies_if_needed(instance: Object) -> void:
	if instance != null and instance.has_method("inject_dependencies"):
		instance.inject_dependencies(self)
	if instance != null and instance.has_method("inject"):
		instance.inject(self)


func _inject_node_tree(node: Node) -> void:
	_inject_dependencies_if_needed(node)
	for child: Node in node.get_children(true):
		_inject_node_tree(child)


func _validate_registration(script_cls: Script, instance: Object, label: String) -> bool:
	if script_cls == null:
		push_error("[GFArchitecture] register_%s 失败：脚本类型为空。" % label.to_lower())
		return false
	if instance == null:
		push_error("[GFArchitecture] register_%s 失败：实例为空。" % label.to_lower())
		return false
	if not _instance_matches_registration_label(instance, label):
		push_error("[GFArchitecture] register_%s 失败：实例类型必须继承 GF%s。" % [label.to_lower(), label])
		return false

	var instance_script := instance.get_script() as Script
	if instance_script == null:
		push_error("[GFArchitecture] register_%s 失败：实例未附加脚本。" % label.to_lower())
		return false
	if not _script_extends_or_equals(instance_script, script_cls):
		push_error("[GFArchitecture] register_%s 失败：实例脚本必须继承或等于注册脚本类型。" % label.to_lower())
		return false

	return true


func _get_instance_script_or_null(instance: Object, context: String) -> Script:
	if instance == null:
		push_error("[GFArchitecture] %s 失败：实例为空。" % context)
		return null

	var script := instance.get_script() as Script
	if script == null:
		push_error("[GFArchitecture] %s 失败：实例未附加脚本。" % context)
		return null

	return script


func _instance_matches_registration_label(instance: Object, label: String) -> bool:
	match label:
		"Model":
			return instance is GFModel

		"System":
			return instance is GFSystem

		"Utility":
			return instance is GFUtility

		_:
			return true


func _refresh_cached_utility_refs() -> void:
	_time_utility = get_local_utility(GFTimeUtility) as GFTimeUtility
	if _time_utility == null and not strict_dependency_lookup and _parent_architecture != null:
		_time_utility = _parent_architecture.get_utility(GFTimeUtility) as GFTimeUtility


func _refresh_tick_caches() -> void:
	if _is_iterating_tick_caches:
		_tick_caches_dirty = true
		return

	_rebuild_tick_caches()


func _rebuild_tick_caches() -> void:
	_tick_systems.clear()
	_physics_systems.clear()
	_tick_utilities.clear()
	_physics_utilities.clear()
	_tick_caches_dirty = false

	for system: Object in _systems.values():
		if system.has_method("tick"):
			_tick_systems.append(system)
		if system.has_method("physics_tick"):
			_physics_systems.append(system)

	for utility: Object in _utilities.values():
		if utility.has_method("tick"):
			_tick_utilities.append(utility)
		if utility.has_method("physics_tick"):
			_physics_utilities.append(utility)


func _flush_tick_cache_refresh() -> void:
	if _tick_caches_dirty:
		_rebuild_tick_caches()


func _is_lifecycle_current(lifecycle_serial: int) -> bool:
	return _lifecycle_serial == lifecycle_serial


func _is_module_ready_for_tick(instance: Object) -> bool:
	return int(_module_lifecycle_stages.get(instance, 0)) >= 3


func _register_alias(aliases: Dictionary, registry: Dictionary, alias_cls: Script, target_cls: Script, label: String) -> void:
	if alias_cls == null or target_cls == null:
		push_error("[GFArchitecture] register_%s_alias 失败：alias 或 target 为空。" % label.to_lower())
		return
	if not registry.has(target_cls):
		push_warning("[GFArchitecture] register_%s_alias：目标类型尚未注册，仍会记录别名。" % label.to_lower())
	aliases[alias_cls] = target_cls


func _resolve_registered_key(registry: Dictionary, aliases: Dictionary, script_cls: Script) -> Script:
	if script_cls == null:
		return null
	if registry.has(script_cls):
		return script_cls
	if aliases.has(script_cls):
		var target_cls := aliases[script_cls] as Script
		if target_cls != null and registry.has(target_cls):
			return target_cls
	return null


func _get_local_registered_instance(registry: Dictionary, aliases: Dictionary, script_cls: Script, label: String) -> Object:
	var registered_key := _resolve_registered_key(registry, aliases, script_cls)
	if registered_key != null:
		return registry.get(registered_key)
	return _find_assignable_instance(registry, script_cls, label)


func _report_strict_lookup_miss(script_cls: Script, label: String) -> void:
	push_error("[GFArchitecture] strict_dependency_lookup：当前架构未注册 %s：%s" % [
		label,
		_get_script_debug_key(script_cls),
	])


func _remove_aliases_for(aliases: Dictionary, registered_key: Script) -> void:
	var keys_to_remove: Array = []
	for alias_cls: Script in aliases:
		if aliases[alias_cls] == registered_key:
			keys_to_remove.append(alias_cls)
	for alias_cls: Script in keys_to_remove:
		aliases.erase(alias_cls)


func _find_assignable_instance(registry: Dictionary, script_cls: Script, label: String) -> Object:
	if script_cls == null:
		return null
	var matches: Array[Object] = []
	for registered_script: Script in registry:
		if _script_extends_or_equals(registered_script, script_cls):
			matches.append(registry[registered_script])
	if matches.size() == 1:
		return matches[0]
	if matches.size() > 1:
		push_warning("[GFArchitecture] get_%s(%s) 匹配到多个实例，请使用显式 alias 注册以消除歧义。" % [label.to_lower(), script_cls.resource_path])
	return null


func _has_assignable_instance(registry: Dictionary, script_cls: Script) -> bool:
	if script_cls == null:
		return false
	for registered_script: Script in registry:
		if _script_extends_or_equals(registered_script, script_cls):
			return true
	return false


func _script_extends_or_equals(candidate: Script, expected: Script) -> bool:
	var current: Script = candidate
	while current != null:
		if current == expected:
			return true
		current = current.get_base_script()
	return false
