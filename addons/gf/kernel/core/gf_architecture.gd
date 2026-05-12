## GFArchitecture: 管理 Model、System 和 Utility 的注册与生命周期的容器。
##
## 生命周期遵循三阶段初始化协议：
##   阶段一 (init)       ：所有模块执行自身内部变量初始化。
##   阶段二 (async_init) ：所有模块串行执行异步初始化（可使用 await）。
##   阶段三 (ready)      ：所有模块均已完成 init，可安全进行跨模块依赖获取。
class_name GFArchitecture


# --- 信号 ---

## 当一次初始化流程完成或被 dispose() 中断后发出。
signal initialization_finished

## 当一次初始化流程因为框架级保护失败后发出。
## @param reason: 初始化失败原因。
signal initialization_failed(reason: String)

## 当项目级 Installer 应用完成或被 dispose() 中断后发出。
signal project_installers_finished


# --- 常量 ---

const GFBindingBase = preload("res://addons/gf/kernel/core/gf_binding.gd")
const GFBinderBase = preload("res://addons/gf/kernel/core/gf_binder.gd")
const GFBindingLifetimesBase = preload("res://addons/gf/kernel/core/gf_binding_lifetimes.gd")
const HOOK_GET_REQUIRED_DEPENDENCIES: StringName = &"get_required_dependencies"
const HOOK_GET_REQUIRED_MODELS: StringName = &"get_required_models"
const HOOK_GET_REQUIRED_SYSTEMS: StringName = &"get_required_systems"
const HOOK_GET_REQUIRED_UTILITIES: StringName = &"get_required_utilities"
const HOOK_GET_REQUIRED_FACTORIES: StringName = &"get_required_factories"
const _GF_VALIDATION_REPORT_SCRIPT = preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")
const _SCRIPT_TYPE_INSPECTOR: Script = preload("res://addons/gf/standard/foundation/reflection/gf_script_type_inspector.gd")


# --- 公共变量 ---

## 单个模块 async_init() 的最长等待时间。小于等于 0 时不启用超时。
## 默认关闭；项目可按自身加载预算显式启用。
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

var _system_registry := ModuleRegistry.new("System")
var _model_registry := ModuleRegistry.new("Model")
var _utility_registry := ModuleRegistry.new("Utility")
var _systems: Dictionary = _system_registry.instances
var _models: Dictionary = _model_registry.instances
var _utilities: Dictionary = _utility_registry.instances
var _factories: Dictionary = {}
var _module_lifecycle_stages: Dictionary = {}
var _event_system: GFTypeEventSystem
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
	_event_system = GFTypeEventSystem.new()


# --- 公共方法 ---

## 检查架构是否已初始化。
## @return 已初始化返回 true，否则返回 false。
func is_inited() -> bool:
	return _inited


## 检查最近一次初始化是否因为框架级保护失败。
## @return 最近一次初始化失败返回 true。
func has_initialization_failed() -> bool:
	return _initialization_failed


## 检查当前架构生命周期是否仍处于可安全继续异步写回的活动状态。
## @return 正在初始化或已完成初始化，且未被 dispose() 或失败保护中断时返回 true。
func is_lifecycle_active() -> bool:
	return (_is_initializing or _inited) and not _initialization_failed


## 检查指定模块实例是否已经完成 ready 阶段。
## @param instance: 由当前架构注册的模块实例。
## @return 模块完成 ready 阶段时返回 true。
func is_module_ready(instance: Object) -> bool:
	return _is_module_ready_for_lookup(instance)


## 将当前架构标记为初始化失败，并唤醒等待初始化或 Installer 的调用方。
## @param reason: 初始化失败原因。
func fail_initialization(reason: String) -> void:
	var failure_reason := reason
	if failure_reason.is_empty():
		failure_reason = "[GFArchitecture] 初始化失败。"
	_fail_initialization(failure_reason, _lifecycle_serial)


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

	if _initialization_failed and not _inited and not _is_initializing:
		_initialization_failed = false
		last_initialization_error = ""

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
	_dispose_module_registry(_system_registry)
	_dispose_module_registry(_model_registry)
	_dispose_module_registry(_utility_registry)
	for binding_variant: Variant in _factories.values():
		var binding := binding_variant as Object
		if binding != null and binding.has_method("clear_cached_instance"):
			binding.call("clear_cached_instance")
	_model_registry._clear()
	_system_registry._clear()
	_utility_registry._clear()
	_factories.clear()
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


## 驱动所有参与 tick 的 System 与 Utility 的每帧更新。
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


## 驱动所有参与 physics_tick 的 System 与 Utility 的每物理帧更新。
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
## command 缺少 execute() 方法时会输出 warning 并返回 null。
## @param command: 要执行的命令实例。
## @return 命令 execute() 的返回值；空对象或缺少 execute() 时返回 null。
func send_command(command: Object) -> Variant:
	if command == null:
		push_error("[GFArchitecture] send_command 失败：command 为空。")
		return null

	_inject_dependencies_if_needed(command)
	if command.has_method("execute"):
		return command.execute()
	push_warning("[GFArchitecture] send_command 失败：command 缺少 execute() 方法，已忽略。")
	return null


## 执行查询实例并返回结果。
## query 缺少 execute() 方法时会输出 warning 并返回 null。
## @param query: 要执行的查询实例。
## @return 查询 execute() 的返回值；空对象或缺少 execute() 时返回 null。
func send_query(query: Object) -> Variant:
	if query == null:
		push_error("[GFArchitecture] send_query 失败：query 为空。")
		return null

	_inject_dependencies_if_needed(query)
	if query.has_method("execute"):
		return query.execute()
	push_warning("[GFArchitecture] send_query 失败：query 缺少 execute() 方法，已忽略。")
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


## 配置事件系统调试与保护选项。
## @param max_dispatch_depth: 最大嵌套派发深度；小于等于 0 表示不限制。
## @param trace_enabled: 是否记录派发追踪。
## @param max_trace_entries: 最多保留的追踪条目数。
func configure_event_debugging(
	max_dispatch_depth: int = GFTypeEventSystem.DEFAULT_MAX_DISPATCH_DEPTH,
	trace_enabled: bool = false,
	max_trace_entries: int = 64
) -> void:
	_event_system.max_dispatch_depth = max_dispatch_depth
	_event_system.trace_enabled = trace_enabled
	_event_system.max_trace_entries = max_trace_entries


## 获取最近事件派发追踪条目。
## @return 从旧到新的追踪条目副本。
func get_event_dispatch_trace() -> Array[Dictionary]:
	return _event_system.get_dispatch_trace()


## 清空事件派发追踪。
func clear_event_dispatch_trace() -> void:
	_event_system.clear_dispatch_trace()


# --- 注册方法 ---

## 注册 System 实例。
## @param script_cls: 系统的脚本类。
## @param instance: 系统实例。
func register_system(script_cls: Script, instance: Object) -> void:
	if not _register_module(_system_registry, script_cls, instance):
		return

	_refresh_tick_caches()
	if _inited:
		await _initialize_registered_module(instance)


## 注册 Model 实例。
## @param script_cls: 模型的脚本类。
## @param instance: 模型实例。
func register_model(script_cls: Script, instance: Object) -> void:
	if not _register_module(_model_registry, script_cls, instance):
		return

	if _inited:
		await _initialize_registered_module(instance)


## 注册 Utility 实例。
## @param script_cls: 工具的脚本类。
## @param instance: 工具实例。
func register_utility(script_cls: Script, instance: Object) -> void:
	if not _register_module(_utility_registry, script_cls, instance):
		return

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
	if _system_registry._has_direct(script_cls):
		unregister_system(script_cls)
	await register_system(script_cls, instance)


## 替换 Model 实例。若旧实例存在，会先调用 dispose() 并移除相关别名。
## @param script_cls: 模型的脚本类。
## @param instance: 新模型实例。
func replace_model(script_cls: Script, instance: Object) -> void:
	if not _validate_registration(script_cls, instance, "Model"):
		return
	if _model_registry._has_direct(script_cls):
		unregister_model(script_cls)
	await register_model(script_cls, instance)


## 替换 Utility 实例。若旧实例存在，会先调用 dispose() 并移除相关别名。
## @param script_cls: 工具的脚本类。
## @param instance: 新工具实例。
func replace_utility(script_cls: Script, instance: Object) -> void:
	if not _validate_registration(script_cls, instance, "Utility"):
		return
	if _utility_registry._has_direct(script_cls):
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
	if not _can_mutate_registration_state("register_factory"):
		return
	if script_cls == null:
		push_error("[GFArchitecture] register_factory 失败：脚本类型为空。")
		return
	if not factory.is_valid():
		push_error("[GFArchitecture] register_factory 失败：factory 无效。")
		return
	if not _validate_factory_lifetime(lifetime, "register_factory"):
		return
	if _factories.has(script_cls):
		push_warning("[GFArchitecture] register_factory：类型已注册，已忽略重复注册。若需要替换，请使用 replace_factory()。")
		return
	_factories[script_cls] = GFBindingBase.new(script_cls, factory, self, lifetime, true)


## 注册已有实例作为短生命周期工厂入口。该实例以单例方式返回。
## @param script_cls: 要创建的脚本类型。
## @param instance: 要暴露的实例。
func register_factory_instance(script_cls: Script, instance: Object) -> void:
	if not _can_mutate_registration_state("register_factory_instance"):
		return
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
	if not _can_mutate_registration_state("replace_factory"):
		return
	if script_cls == null:
		push_error("[GFArchitecture] replace_factory 失败：脚本类型为空。")
		return
	if not factory.is_valid():
		push_error("[GFArchitecture] replace_factory 失败：factory 无效。")
		return
	if not _validate_factory_lifetime(lifetime, "replace_factory"):
		return
	_factories[script_cls] = GFBindingBase.new(script_cls, factory, self, lifetime, true)


## 替换已有实例工厂入口。
## @param script_cls: 要创建的脚本类型。
## @param instance: 要暴露的实例。
func replace_factory_instance(script_cls: Script, instance: Object) -> void:
	if not _can_mutate_registration_state("replace_factory_instance"):
		return
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
	_register_module_alias(_system_registry, alias_cls, target_cls)


## 为已注册 Model 增加一个额外查询别名。
## @param alias_cls: 调用 get_model() 时使用的别名脚本类。
## @param target_cls: 已注册 Model 的实际脚本类。
func register_model_alias(alias_cls: Script, target_cls: Script) -> void:
	_register_module_alias(_model_registry, alias_cls, target_cls)


## 为已注册 Utility 增加一个额外查询别名。
## @param alias_cls: 调用 get_utility() 时使用的别名脚本类。
## @param target_cls: 已注册 Utility 的实际脚本类。
func register_utility_alias(alias_cls: Script, target_cls: Script) -> void:
	_register_module_alias(_utility_registry, alias_cls, target_cls)


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
	if _system_registry._has_direct(script):
		register_system_alias(alias_cls, script)


## 便捷注册 Model，并同时以 alias_cls 作为额外查询键。
## @param instance: Model 实例。
## @param alias_cls: 额外查询脚本类。
func register_model_instance_as(instance: Object, alias_cls: Script) -> void:
	var script := _get_instance_script_or_null(instance, "register_model_instance_as")
	if script == null:
		return

	await register_model_instance(instance)
	if _model_registry._has_direct(script):
		register_model_alias(alias_cls, script)


## 便捷注册 Utility，并同时以 alias_cls 作为额外查询键。
## @param instance: Utility 实例。
## @param alias_cls: 额外查询脚本类。
func register_utility_instance_as(instance: Object, alias_cls: Script) -> void:
	var script := _get_instance_script_or_null(instance, "register_utility_instance_as")
	if script == null:
		return

	await register_utility_instance(instance)
	if _utility_registry._has_direct(script):
		register_utility_alias(alias_cls, script)


## 注销 System 实例。
## @param script_cls: 系统的脚本类。
func unregister_system(script_cls: Script) -> void:
	if _unregister_module(_system_registry, script_cls):
		_refresh_tick_caches()


## 注销 Model 实例。
## @param script_cls: 模型的脚本类。
func unregister_model(script_cls: Script) -> void:
	_unregister_module(_model_registry, script_cls)


## 注销 Utility 实例。
## @param script_cls: 工具的脚本类。
func unregister_utility(script_cls: Script) -> void:
	if _unregister_module(_utility_registry, script_cls):
		_refresh_cached_utility_refs()
		_refresh_tick_caches()


# --- 获取方法 ---

## 通过脚本类获取 System 实例。
## @param script_cls: 脚本类。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 系统实例，如果未找到则返回 null。
func get_system(script_cls: Script, require_ready: bool = false) -> Object:
	var instance := _get_local_registered_instance(_system_registry, script_cls)
	if instance != null:
		return instance if not require_ready or _is_module_ready_for_lookup(instance) else null
	if _parent_architecture != null and not strict_dependency_lookup and not _has_assignable_instance(_system_registry, script_cls):
		return _parent_architecture.get_system(script_cls, require_ready)
	if strict_dependency_lookup:
		_report_strict_lookup_miss(script_cls, "System")
	return null


## 通过脚本类获取 Model 实例。
## @param script_cls: 脚本类。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 模型实例，如果未找到则返回 null。
func get_model(script_cls: Script, require_ready: bool = false) -> Object:
	var instance := _get_local_registered_instance(_model_registry, script_cls)
	if instance != null:
		return instance if not require_ready or _is_module_ready_for_lookup(instance) else null
	if _parent_architecture != null and not strict_dependency_lookup and not _has_assignable_instance(_model_registry, script_cls):
		return _parent_architecture.get_model(script_cls, require_ready)
	if strict_dependency_lookup:
		_report_strict_lookup_miss(script_cls, "Model")
	return null


## 通过脚本类获取 Utility 实例。
## @param script_cls: 脚本类。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 工具实例，如果未找到则返回 null。
func get_utility(script_cls: Script, require_ready: bool = false) -> Object:
	var instance := _get_local_registered_instance(_utility_registry, script_cls)
	if instance != null:
		return instance if not require_ready or _is_module_ready_for_lookup(instance) else null
	if _parent_architecture != null and not strict_dependency_lookup and not _has_assignable_instance(_utility_registry, script_cls):
		return _parent_architecture.get_utility(script_cls, require_ready)
	if strict_dependency_lookup:
		_report_strict_lookup_miss(script_cls, "Utility")
	return null


## 仅从当前架构获取 System，不回退父级架构。
## @param script_cls: 脚本类。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 当前架构中的系统实例，如果未找到则返回 null。
func get_local_system(script_cls: Script, require_ready: bool = false) -> Object:
	var instance := _get_local_registered_instance(_system_registry, script_cls)
	return instance if not require_ready or _is_module_ready_for_lookup(instance) else null


## 仅从当前架构获取 Model，不回退父级架构。
## @param script_cls: 脚本类。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 当前架构中的模型实例，如果未找到则返回 null。
func get_local_model(script_cls: Script, require_ready: bool = false) -> Object:
	var instance := _get_local_registered_instance(_model_registry, script_cls)
	return instance if not require_ready or _is_module_ready_for_lookup(instance) else null


## 仅从当前架构获取 Utility，不回退父级架构。
## @param script_cls: 脚本类。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 当前架构中的工具实例，如果未找到则返回 null。
func get_local_utility(script_cls: Script, require_ready: bool = false) -> Object:
	var instance := _get_local_registered_instance(_utility_registry, script_cls)
	return instance if not require_ready or _is_module_ready_for_lookup(instance) else null


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
		var models_data: Variant = data["models"]
		if typeof(models_data) == TYPE_DICTIONARY:
			restore_all_models_state(models_data)
		else:
			push_warning("[GFArchitecture] restore_global_snapshot：models 必须是 Dictionary，已跳过 Model 恢复。")
		
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
			"models": _model_registry.aliases.size(),
			"systems": _system_registry.aliases.size(),
			"utilities": _utility_registry.aliases.size(),
		},
		"tick": {
			"systems": _tick_systems.size(),
			"physics_systems": _physics_systems.size(),
			"utilities": _tick_utilities.size(),
			"physics_utilities": _physics_utilities.size(),
		},
	}


## 获取架构中已注册模块的声明式依赖诊断报告。
## 模块可选择实现 get_required_dependencies() 或 get_required_models/systems/utilities/factories()。
## @param options: 可选参数，支持 include_parent_lookup 与 include_factories。
## @return 统一诊断报告字典。
func get_dependency_diagnostics(options: Dictionary = {}) -> Dictionary:
	var include_parent_lookup := bool(options.get("include_parent_lookup", not strict_dependency_lookup))
	var include_factories := bool(options.get("include_factories", true))
	var report := _GF_VALIDATION_REPORT_SCRIPT.new("Architecture dependencies")
	var modules: Array[Dictionary] = []
	var resolved_dependencies: Array[Dictionary] = []
	var missing_dependencies: Array[Dictionary] = []

	_collect_registry_dependency_diagnostics(
		"model",
		_model_registry,
		report,
		include_parent_lookup,
		include_factories,
		modules,
		resolved_dependencies,
		missing_dependencies
	)
	_collect_registry_dependency_diagnostics(
		"utility",
		_utility_registry,
		report,
		include_parent_lookup,
		include_factories,
		modules,
		resolved_dependencies,
		missing_dependencies
	)
	_collect_registry_dependency_diagnostics(
		"system",
		_system_registry,
		report,
		include_parent_lookup,
		include_factories,
		modules,
		resolved_dependencies,
		missing_dependencies
	)

	return report.to_dict(
		{
			"module_count": modules.size(),
			"modules": modules,
			"resolved_dependencies": resolved_dependencies,
			"missing_dependencies": missing_dependencies,
			"include_parent_lookup": include_parent_lookup,
			"include_factories": include_factories,
		},
		{
			"include_subject": false,
			"include_metadata": false,
			"include_info_count": false,
			"include_issue_count": false,
			"next_actions": _get_dependency_diagnostics_next_actions(),
			"fallback_action": "Review the first reported architecture dependency issue.",
		}
	)


# --- 私有/内部方法 ---

func _collect_registry_dependency_diagnostics(
	module_kind: String,
	module_registry: ModuleRegistry,
	report: Variant,
	include_parent_lookup: bool,
	include_factories: bool,
	modules: Array[Dictionary],
	resolved_dependencies: Array[Dictionary],
	missing_dependencies: Array[Dictionary]
) -> void:
	for script_cls: Script in module_registry.instances.keys():
		var instance := module_registry.instances[script_cls] as Object
		var module_key := _get_script_debug_key(script_cls, instance)
		var declared_dependencies := _collect_declared_dependencies(
			instance,
			report,
			module_key,
			include_factories
		)
		var module_record := {
			"kind": module_kind,
			"script": module_key,
			"instance": _get_instance_debug_key(instance),
			"dependencies": _dependency_map_to_keys(declared_dependencies),
			"resolved_dependencies": [],
			"missing_dependencies": [],
		}
		_collect_dependency_resolution_records(
			module_kind,
			module_key,
			declared_dependencies,
			report,
			include_parent_lookup,
			include_factories,
			module_record,
			resolved_dependencies,
			missing_dependencies
		)
		modules.append(module_record)


func _collect_declared_dependencies(
	instance: Object,
	report: Variant,
	module_key: String,
	include_factories: bool
) -> Dictionary:
	var dependencies := _make_dependency_map()
	if instance == null:
		return dependencies

	if instance.has_method(HOOK_GET_REQUIRED_DEPENDENCIES):
		var raw_dependencies: Variant = instance.call(HOOK_GET_REQUIRED_DEPENDENCIES)
		_merge_dependency_dictionary(
			dependencies,
			raw_dependencies,
			report,
			module_key,
			String(HOOK_GET_REQUIRED_DEPENDENCIES),
			include_factories
		)

	_append_dependency_hook_array(
		dependencies["models"] as Array[Script],
		instance,
		HOOK_GET_REQUIRED_MODELS,
		report,
		module_key
	)
	_append_dependency_hook_array(
		dependencies["systems"] as Array[Script],
		instance,
		HOOK_GET_REQUIRED_SYSTEMS,
		report,
		module_key
	)
	_append_dependency_hook_array(
		dependencies["utilities"] as Array[Script],
		instance,
		HOOK_GET_REQUIRED_UTILITIES,
		report,
		module_key
	)
	if include_factories:
		_append_dependency_hook_array(
			dependencies["factories"] as Array[Script],
			instance,
			HOOK_GET_REQUIRED_FACTORIES,
			report,
			module_key
		)
	return dependencies


func _collect_dependency_resolution_records(
	module_kind: String,
	module_key: String,
	declared_dependencies: Dictionary,
	report: Variant,
	include_parent_lookup: bool,
	include_factories: bool,
	module_record: Dictionary,
	resolved_dependencies: Array[Dictionary],
	missing_dependencies: Array[Dictionary]
) -> void:
	for dependency_kind: String in ["models", "systems", "utilities", "factories"]:
		if dependency_kind == "factories" and not include_factories:
			continue

		var dependency_scripts := declared_dependencies[dependency_kind] as Array[Script]
		for dependency_script: Script in dependency_scripts:
			var dependency_record := _make_dependency_diagnostic_record(
				module_kind,
				module_key,
				dependency_kind,
				dependency_script,
				include_parent_lookup,
				include_factories
			)
			if bool(dependency_record.get("resolved", false)):
				(module_record["resolved_dependencies"] as Array).append(dependency_record)
				resolved_dependencies.append(dependency_record)
				continue

			(module_record["missing_dependencies"] as Array).append(dependency_record)
			missing_dependencies.append(dependency_record)
			report.add_error(
				StringName("missing_%s_dependency" % _dependency_kind_to_singular(dependency_kind)),
				"Architecture module declares a missing %s dependency." % _dependency_kind_to_singular(dependency_kind),
				module_key,
				_get_script_debug_key(dependency_script),
				{
					"module_kind": module_kind,
					"dependency_kind": dependency_kind,
				}
			)


func _make_dependency_diagnostic_record(
	module_kind: String,
	module_key: String,
	dependency_kind: String,
	dependency_script: Script,
	include_parent_lookup: bool,
	include_factories: bool
) -> Dictionary:
	var status := _resolve_dependency_diagnostic_status(
		dependency_kind,
		dependency_script,
		include_parent_lookup,
		include_factories
	)
	return {
		"module_kind": module_kind,
		"module": module_key,
		"kind": dependency_kind,
		"script": _get_script_debug_key(dependency_script),
		"resolved": bool(status.get("resolved", false)),
		"scope": String(status.get("scope", "missing")),
		"architecture_depth": int(status.get("architecture_depth", -1)),
	}


func _resolve_dependency_diagnostic_status(
	dependency_kind: String,
	dependency_script: Script,
	include_parent_lookup: bool,
	include_factories: bool,
	architecture_depth: int = 0
) -> Dictionary:
	if dependency_script == null:
		return {
			"resolved": false,
			"scope": "invalid",
			"architecture_depth": architecture_depth,
		}

	var local_resolved := false
	match dependency_kind:
		"models":
			local_resolved = _get_local_registered_instance(_model_registry, dependency_script) != null
		"systems":
			local_resolved = _get_local_registered_instance(_system_registry, dependency_script) != null
		"utilities":
			local_resolved = _get_local_registered_instance(_utility_registry, dependency_script) != null
		"factories":
			local_resolved = include_factories and _factories.has(dependency_script)

	if local_resolved:
		return {
			"resolved": true,
			"scope": _get_dependency_scope_name(architecture_depth),
			"architecture_depth": architecture_depth,
		}

	if include_parent_lookup and not strict_dependency_lookup and _parent_architecture != null:
		return _parent_architecture._resolve_dependency_diagnostic_status(
			dependency_kind,
			dependency_script,
			include_parent_lookup,
			include_factories,
			architecture_depth + 1
		)

	return {
		"resolved": false,
		"scope": "missing",
		"architecture_depth": architecture_depth,
	}


func _merge_dependency_dictionary(
	dependencies: Dictionary,
	raw_dependencies: Variant,
	report: Variant,
	module_key: String,
	hook_name: String,
	include_factories: bool
) -> void:
	if raw_dependencies == null:
		return
	if not raw_dependencies is Dictionary:
		report.add_warning(
			&"invalid_dependency_hook_return",
			"%s() must return a Dictionary." % hook_name,
			module_key,
			"",
			{ "hook": hook_name }
		)
		return

	var source := raw_dependencies as Dictionary
	for raw_key: Variant in source.keys():
		var dependency_kind := _normalize_dependency_kind_key(String(raw_key))
		if dependency_kind.is_empty():
			report.add_warning(
				&"invalid_dependency_kind",
				"Dependency declaration contains an unknown dependency kind.",
				module_key,
				"",
				{
					"hook": hook_name,
					"dependency_kind": String(raw_key),
				}
			)
			continue
		if dependency_kind == "factories" and not include_factories:
			continue
		_append_dependency_items(
			dependencies[dependency_kind] as Array[Script],
			source[raw_key],
			report,
			module_key,
			hook_name
		)


func _append_dependency_hook_array(
	target: Array[Script],
	instance: Object,
	hook_name: StringName,
	report: Variant,
	module_key: String
) -> void:
	if instance == null or not instance.has_method(hook_name):
		return

	var raw_value: Variant = instance.call(hook_name)
	_append_dependency_items(target, raw_value, report, module_key, String(hook_name))


func _append_dependency_items(
	target: Array[Script],
	raw_value: Variant,
	report: Variant,
	module_key: String,
	hook_name: String
) -> void:
	if raw_value == null:
		return
	if not raw_value is Array:
		report.add_warning(
			&"invalid_dependency_hook_return",
			"%s() must return an Array of Script values." % hook_name,
			module_key,
			"",
			{ "hook": hook_name }
		)
		return

	for dependency_variant: Variant in raw_value:
		if dependency_variant is Script:
			_append_unique_script(target, dependency_variant as Script)
		elif dependency_variant != null:
			report.add_warning(
				&"invalid_dependency_type",
				"Dependency declaration contains a non-Script value.",
				module_key,
				"",
				{
					"hook": hook_name,
					"value": str(dependency_variant),
				}
			)


func _make_dependency_map() -> Dictionary:
	return {
		"models": [] as Array[Script],
		"systems": [] as Array[Script],
		"utilities": [] as Array[Script],
		"factories": [] as Array[Script],
	}


func _dependency_map_to_keys(dependencies: Dictionary) -> Dictionary:
	return {
		"models": _script_array_to_debug_keys(dependencies["models"] as Array[Script]),
		"systems": _script_array_to_debug_keys(dependencies["systems"] as Array[Script]),
		"utilities": _script_array_to_debug_keys(dependencies["utilities"] as Array[Script]),
		"factories": _script_array_to_debug_keys(dependencies["factories"] as Array[Script]),
	}


func _script_array_to_debug_keys(scripts: Array[Script]) -> PackedStringArray:
	var result := PackedStringArray()
	for script: Script in scripts:
		result.append(_get_script_debug_key(script))
	result.sort()
	return result


func _append_unique_script(target: Array[Script], script: Script) -> void:
	if script != null and not target.has(script):
		target.append(script)


func _normalize_dependency_kind_key(key: String) -> String:
	match key.to_lower():
		"model", "models":
			return "models"
		"system", "systems":
			return "systems"
		"utility", "utilities":
			return "utilities"
		"factory", "factories":
			return "factories"
		_:
			return ""


func _dependency_kind_to_singular(dependency_kind: String) -> String:
	match dependency_kind:
		"models":
			return "model"
		"systems":
			return "system"
		"utilities":
			return "utility"
		"factories":
			return "factory"
		_:
			return "dependency"


func _get_dependency_scope_name(architecture_depth: int) -> String:
	if architecture_depth <= 0:
		return "local"
	if architecture_depth == 1:
		return "parent"
	return "ancestor"


func _get_dependency_diagnostics_next_actions() -> Dictionary:
	return {
		"missing_model_dependency": "Register the required Model locally or in an allowed parent architecture.",
		"missing_system_dependency": "Register the required System locally or in an allowed parent architecture.",
		"missing_utility_dependency": "Register the required Utility locally or in an allowed parent architecture.",
		"missing_factory_dependency": "Register the required factory before the dependent module requests it.",
		"invalid_dependency_hook_return": "Return a Dictionary or Array shape that matches the dependency hook contract.",
		"invalid_dependency_type": "Only Script values should be listed as declared dependencies.",
		"invalid_dependency_kind": "Use models, systems, utilities, or factories as dependency declaration keys.",
	}


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


func _get_modules_by_lifecycle_priority(registry: Dictionary, reverse: bool = false) -> Array[Object]:
	var entries: Array[Dictionary] = []
	var order := 0
	for instance: Object in registry.values():
		entries.append({
			"instance": instance,
			"priority": _get_module_priority(instance, &"lifecycle_priority"),
			"order": order,
		})
		order += 1

	entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_priority := int(left.get("priority", 0))
		var right_priority := int(right.get("priority", 0))
		if left_priority == right_priority:
			var left_order := int(left.get("order", 0))
			var right_order := int(right.get("order", 0))
			return left_order > right_order if reverse else left_order < right_order
		return left_priority < right_priority if reverse else left_priority > right_priority
	)

	var result: Array[Object] = []
	for entry: Dictionary in entries:
		var instance := entry.get("instance") as Object
		if instance != null:
			result.append(instance)
	return result


func _sort_modules_for_tick(modules: Array[Object], priority_property: StringName) -> void:
	var entries: Array[Dictionary] = []
	for index: int in range(modules.size()):
		var instance := modules[index]
		entries.append({
			"instance": instance,
			"priority": _get_module_priority(instance, priority_property),
			"order": index,
		})

	entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_priority := int(left.get("priority", 0))
		var right_priority := int(right.get("priority", 0))
		if left_priority == right_priority:
			return int(left.get("order", 0)) < int(right.get("order", 0))
		return left_priority > right_priority
	)

	modules.clear()
	for entry: Dictionary in entries:
		var instance := entry.get("instance") as Object
		if instance != null:
			modules.append(instance)


func _get_module_priority(instance: Object, property_name: StringName) -> int:
	if instance == null:
		return 0
	if String(property_name) in instance:
		return int(instance.get(property_name))
	return 0


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
			"has_tick": _module_participates_in_tick(instance, &"tick", &"tick_enabled"),
			"has_physics_tick": _module_participates_in_tick(instance, &"physics_tick", &"physics_tick_enabled"),
			"ignore_pause": ignores_pause,
			"ignore_time_scale": ignores_time_scale,
			"tick_enabled": _get_module_bool(instance, &"tick_enabled"),
			"physics_tick_enabled": _get_module_bool(instance, &"physics_tick_enabled"),
			"lifecycle_priority": _get_module_priority(instance, &"lifecycle_priority"),
			"tick_priority": _get_module_priority(instance, &"tick_priority"),
			"physics_tick_priority": _get_module_priority(instance, &"physics_tick_priority"),
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


func _validate_factory_lifetime(lifetime: int, context: String) -> bool:
	if (
		lifetime == GFBindingLifetimesBase.Lifetime.TRANSIENT
		or lifetime == GFBindingLifetimesBase.Lifetime.SINGLETON
	):
		return true

	push_error("[GFArchitecture] %s 失败：未知工厂生命周期：%s。" % [context, str(lifetime)])
	return false


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
		if await _advance_module_registry_to_stage(_model_registry, target_stage, lifecycle_serial):
			progressed = true
		if await _advance_module_registry_to_stage(_utility_registry, target_stage, lifecycle_serial):
			progressed = true
		if await _advance_module_registry_to_stage(_system_registry, target_stage, lifecycle_serial):
			progressed = true
		if not progressed:
			return
		pass_count += 1


func _advance_module_registry_to_stage(module_registry: ModuleRegistry, target_stage: int, lifecycle_serial: int) -> bool:
	var progressed: bool = false
	for instance: Object in _get_modules_by_lifecycle_priority(module_registry.instances):
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


func _dispose_module_registry(module_registry: ModuleRegistry) -> void:
	for instance in _get_modules_by_lifecycle_priority(module_registry.instances, true):
		if instance.has_method("dispose"):
			instance.dispose()
		_clear_injected_scope(instance)


func _fail_initialization(reason: String, lifecycle_serial: int) -> void:
	if _initialization_failed or not _is_lifecycle_current(lifecycle_serial):
		return

	_initialization_failed = true
	last_initialization_error = reason
	_lifecycle_serial += 1
	_is_initializing = false
	_inited = false
	_stop_project_installers_after_failure()
	push_error(reason)
	initialization_failed.emit(reason)
	initialization_finished.emit()


func _track_registered_module(instance: Object) -> void:
	if instance == null:
		return
	if not _module_lifecycle_stages.has(instance):
		_module_lifecycle_stages[instance] = 0


func _register_module(module_registry: ModuleRegistry, script_cls: Script, instance: Object) -> bool:
	if not _can_mutate_registration_state("register_%s" % module_registry._label_key()):
		return false
	if not _validate_registration(script_cls, instance, module_registry.label):
		return false
	if module_registry._has_direct(script_cls):
		var method_name := "register_%s" % module_registry._label_key()
		var replacement_name := "replace_%s" % module_registry._label_key()
		push_warning("[GFArchitecture] %s：类型已注册，已忽略重复注册。若需要替换，请使用 %s()。" % [
			method_name,
			replacement_name,
		])
		return false

	_inject_dependencies_if_needed(instance)
	module_registry.instances[script_cls] = instance
	module_registry._clear_assignable_cache()
	_track_registered_module(instance)
	return true


func _can_mutate_registration_state(context: String) -> bool:
	if _initialization_failed:
		push_error("[GFArchitecture] %s 失败：架构初始化已失败，已拒绝迟到写入。" % context)
		return false
	return true


func _unregister_module(module_registry: ModuleRegistry, script_cls: Script) -> bool:
	var registered_key := _resolve_registered_key(module_registry, script_cls)
	if registered_key != null and module_registry._has_direct(registered_key):
		var instance := module_registry.instances[registered_key] as Object
		if instance != null and instance.has_method("dispose"):
			instance.dispose()
		if instance != null:
			_event_system.unregister_owner(instance)
			_clear_injected_scope(instance)
		_module_lifecycle_stages.erase(instance)
		module_registry.instances.erase(registered_key)
		_remove_aliases_for(module_registry, registered_key)
		module_registry._clear_assignable_cache()
		return true

	module_registry.aliases.erase(script_cls)
	module_registry._clear_assignable_cache()
	return false


func _inject_dependencies_if_needed(instance: Object) -> void:
	if instance != null and instance.has_method("_gf_set_dependency_scope"):
		instance.call("_gf_set_dependency_scope", self)
	if instance != null and instance.has_method("inject_dependencies"):
		instance.inject_dependencies(self)
	if instance != null and instance.has_method("inject"):
		instance.inject(self)


func _clear_injected_scope(instance: Object) -> void:
	if instance != null and instance.has_method("_gf_set_dependency_scope"):
		instance.call("_gf_set_dependency_scope", null)
	elif instance != null and instance.has_method("_release_dependency_scope"):
		instance.call("_release_dependency_scope")


func _stop_project_installers_after_failure() -> void:
	var was_running := _project_installers_running
	_project_installers_running = false
	if was_running:
		project_installers_finished.emit()


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
	if not _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(instance_script, script_cls):
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
		if _module_participates_in_tick(system, &"tick", &"tick_enabled"):
			_tick_systems.append(system)
		if _module_participates_in_tick(system, &"physics_tick", &"physics_tick_enabled"):
			_physics_systems.append(system)

	for utility: Object in _utilities.values():
		if _module_participates_in_tick(utility, &"tick", &"tick_enabled"):
			_tick_utilities.append(utility)
		if _module_participates_in_tick(utility, &"physics_tick", &"physics_tick_enabled"):
			_physics_utilities.append(utility)

	_sort_modules_for_tick(_tick_systems, &"tick_priority")
	_sort_modules_for_tick(_physics_systems, &"physics_tick_priority")
	_sort_modules_for_tick(_tick_utilities, &"tick_priority")
	_sort_modules_for_tick(_physics_utilities, &"physics_tick_priority")


func _flush_tick_cache_refresh() -> void:
	if _tick_caches_dirty:
		_rebuild_tick_caches()


func _is_lifecycle_current(lifecycle_serial: int) -> bool:
	return _lifecycle_serial == lifecycle_serial


func _is_module_ready_for_tick(instance: Object) -> bool:
	return int(_module_lifecycle_stages.get(instance, 0)) >= 3


func _is_module_ready_for_lookup(instance: Object) -> bool:
	return (
		instance != null
		and _inited
		and not _initialization_failed
		and int(_module_lifecycle_stages.get(instance, 0)) >= 3
	)


func _module_participates_in_tick(instance: Object, method_name: StringName, explicit_property: StringName) -> bool:
	if instance == null:
		return false
	if not instance.has_method(method_name):
		return false
	if _get_module_bool(instance, explicit_property):
		return true
	if _script_chain_declares_method_before_framework_base(instance, method_name):
		return true
	return not (instance is GFSystem or instance is GFUtility)


func _get_module_bool(instance: Object, property_name: StringName) -> bool:
	if instance == null:
		return false
	if String(property_name) in instance:
		return bool(instance.get(property_name))
	return false


func _script_chain_declares_method_before_framework_base(instance: Object, method_name: StringName) -> bool:
	var script := instance.get_script() as Script
	var framework_method_count := _get_framework_module_method_count(instance, method_name)
	while script != null:
		if _is_framework_module_base_script(script):
			return false
		if _count_script_methods(script, method_name) > framework_method_count:
			return true
		script = script.get_base_script()
	return false


func _is_framework_module_base_script(script: Script) -> bool:
	return script == GFSystem or script == GFUtility


func _get_framework_module_method_count(instance: Object, method_name: StringName) -> int:
	if instance is GFSystem:
		return _count_script_methods(GFSystem, method_name)
	if instance is GFUtility:
		return _count_script_methods(GFUtility, method_name)
	return 0


func _count_script_methods(script: Script, method_name: StringName) -> int:
	var count := 0
	for method: Dictionary in script.get_script_method_list():
		if String(method.get("name", "")) == String(method_name):
			count += 1
	return count


func _register_module_alias(module_registry: ModuleRegistry, alias_cls: Script, target_cls: Script) -> void:
	if not _can_mutate_registration_state("register_%s_alias" % module_registry._label_key()):
		return
	if alias_cls == null or target_cls == null:
		push_error("[GFArchitecture] register_%s_alias 失败：alias 或 target 为空。" % module_registry._label_key())
		return
	if not module_registry._has_direct(target_cls):
		push_warning("[GFArchitecture] register_%s_alias：目标类型尚未注册，仍会记录别名。" % module_registry._label_key())
	module_registry.aliases[alias_cls] = target_cls
	module_registry._clear_assignable_cache()


func _resolve_registered_key(module_registry: ModuleRegistry, script_cls: Script) -> Script:
	if script_cls == null:
		return null
	if module_registry._has_direct(script_cls):
		return script_cls
	if module_registry.aliases.has(script_cls):
		var target_cls := module_registry.aliases[script_cls] as Script
		if target_cls != null and module_registry._has_direct(target_cls):
			return target_cls
	return null


func _get_local_registered_instance(module_registry: ModuleRegistry, script_cls: Script) -> Object:
	var registered_key := _resolve_registered_key(module_registry, script_cls)
	if registered_key != null:
		return module_registry.instances.get(registered_key)
	registered_key = _resolve_assignable_cached_key(module_registry, script_cls)
	if registered_key != null:
		return module_registry.instances.get(registered_key)
	registered_key = _find_assignable_registered_key(module_registry, script_cls)
	if registered_key != null:
		module_registry.assignable_cache[script_cls] = registered_key
		return module_registry.instances.get(registered_key)
	return null


func _report_strict_lookup_miss(script_cls: Script, label: String) -> void:
	push_error("[GFArchitecture] strict_dependency_lookup：当前架构未注册 %s：%s" % [
		label,
		_get_script_debug_key(script_cls),
	])


func _remove_aliases_for(module_registry: ModuleRegistry, registered_key: Script) -> void:
	var keys_to_remove: Array = []
	for alias_cls: Script in module_registry.aliases:
		if module_registry.aliases[alias_cls] == registered_key:
			keys_to_remove.append(alias_cls)
	for alias_cls: Script in keys_to_remove:
		module_registry.aliases.erase(alias_cls)


func _resolve_assignable_cached_key(module_registry: ModuleRegistry, script_cls: Script) -> Script:
	if script_cls == null or not module_registry.assignable_cache.has(script_cls):
		return null
	var cached_key := module_registry.assignable_cache[script_cls] as Script
	if cached_key != null and module_registry._has_direct(cached_key):
		return cached_key
	module_registry.assignable_cache.erase(script_cls)
	return null


func _find_assignable_registered_key(module_registry: ModuleRegistry, script_cls: Script) -> Script:
	if script_cls == null:
		return null
	var matches: Array[Script] = []
	for registered_script: Script in module_registry.instances:
		if _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(registered_script, script_cls):
			matches.append(registered_script)
	if matches.size() == 1:
		return matches[0]
	if matches.size() > 1:
		push_warning("[GFArchitecture] get_%s(%s) 匹配到多个本地实例，本次查询不会回退父架构；请使用显式 alias 注册以消除歧义。" % [
			module_registry._label_key(),
			script_cls.resource_path,
		])
	return null


func _has_assignable_instance(module_registry: ModuleRegistry, script_cls: Script) -> bool:
	if script_cls == null:
		return false
	for registered_script: Script in module_registry.instances:
		if _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(registered_script, script_cls):
			return true
	return false


# --- 内部类 ---

class ModuleRegistry:
	var label: String = ""
	var instances: Dictionary = {}
	var aliases: Dictionary = {}
	var assignable_cache: Dictionary = {}

	func _init(p_label: String) -> void:
		label = p_label

	func _label_key() -> String:
		return label.to_lower()

	func _has_direct(script_cls: Script) -> bool:
		return script_cls != null and instances.has(script_cls)

	func _clear_assignable_cache() -> void:
		assignable_cache.clear()

	func _clear() -> void:
		instances.clear()
		aliases.clear()
		assignable_cache.clear()
