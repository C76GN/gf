## GFNodeContext: 场景树上的局部架构上下文。
##
## 可选择继承父级架构，或创建带父级回退的 Scoped 架构。
## Scoped 架构会在节点退出树时自动 dispose，适合关卡、战斗房间、调试面板等局部模块。
class_name GFNodeContext
extends Node


# --- 信号 ---

## 当上下文架构完成初始化后发出。
## @param architecture: 当前上下文使用的架构实例。
signal context_ready(architecture: GFArchitecture)

## 当上下文无法继续等待或初始化时发出。
## @param reason: 失败原因。
signal context_failed(reason: String)


# --- 枚举 ---

## 上下文作用域模式。
enum ScopeMode {
	## 直接复用最近的父级上下文架构；若不存在则回退到全局 Gf 架构。
	INHERITED,
	## 创建新的局部架构，并将最近的父级或全局架构作为依赖回退来源。
	SCOPED,
}


# --- 导出变量 ---

## 当前节点上下文的作用域模式。
@export var scope_mode: ScopeMode = ScopeMode.SCOPED

## 是否在进入树后自动初始化 Scoped 架构。
@export var auto_init: bool = true

## 是否由该节点驱动 Scoped 架构的 tick 与 physics_tick。
@export var process_scoped_ticks: bool = true

## Scoped 架构是否启用严格依赖查询。开启后本地未注册的依赖不会回退父级架构。
@export var strict_dependency_lookup: bool = false

## Scoped 架构中单个模块 async_init() 的最长等待时间。小于等于 0 时继承架构默认行为。
@export var module_async_init_timeout_seconds: float = 0.0

## 等待父级架构或当前上下文 ready 的超时时间。小于等于 0 时禁用超时。
@export var context_wait_timeout_seconds: float = 30.0


# --- 公共变量 ---

## 当前上下文使用的架构实例。
var architecture: GFArchitecture:
	get:
		return get_architecture()


# --- 私有变量 ---

var _architecture: GFArchitecture = null
var _owns_architecture: bool = false
var _is_context_ready: bool = false
var _is_context_installing: bool = false


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_setup_architecture()
	if _owns_architecture:
		_is_context_installing = true
		var context_architecture := _architecture
		var parent_ready := await _wait_for_parent_architecture_ready(context_architecture)
		if not parent_ready:
			_is_context_installing = false
			return
		if not _is_owned_architecture_current(context_architecture):
			_is_context_installing = false
			return
		await install(context_architecture)
		if not _is_owned_architecture_current(context_architecture):
			_is_context_installing = false
			return
		await install_bindings(context_architecture.create_binder())
		if not _is_owned_architecture_current(context_architecture):
			_is_context_installing = false
			return
		_is_context_installing = false
		if auto_init:
			await _initialize_owned_architecture(context_architecture)
	elif _architecture == null:
		push_warning("[GFNodeContext] 未找到可继承的架构。")


func _process(delta: float) -> void:
	if _should_tick_owned_architecture():
		_architecture.tick(delta)


func _physics_process(delta: float) -> void:
	if _should_tick_owned_architecture():
		_architecture.physics_tick(delta)


func _exit_tree() -> void:
	if _owns_architecture and _architecture != null:
		_architecture.dispose()
	_architecture = null
	_owns_architecture = false
	_is_context_ready = false
	_is_context_installing = false


# --- 公共方法 ---

## 安装当前上下文的局部模块。仅在 SCOPED 模式下调用。
## @param _architecture_instance: 当前上下文创建的局部架构。
func install(_architecture_instance: GFArchitecture) -> void:
	pass


## 使用声明式装配器安装当前上下文的局部模块。仅在 SCOPED 模式下调用。
## @param _binder: 当前上下文创建的局部架构装配器。
func install_bindings(_binder: Variant) -> void:
	pass


## 获取当前上下文使用的架构。
## @return 架构实例；未找到时返回 null。
func get_architecture() -> GFArchitecture:
	return _architecture


## 检查上下文是否已经完成初始化。
## @return 已完成初始化返回 true。
func is_context_ready() -> bool:
	return _is_context_ready


## 手动初始化当前 Scoped 上下文。适合 auto_init 为 false 时，在 install()/install_bindings() 完成后统一触发初始化与 context_ready/context_failed 信号。
## @return 初始化完成的架构；上下文失效或初始化失败时返回 null。
func initialize_context() -> GFArchitecture:
	if _architecture == null:
		return null
	if not _owns_architecture:
		return await wait_until_ready()
	if _is_context_ready:
		return _architecture

	var context_architecture := _architecture
	while _is_context_installing:
		if not is_inside_tree():
			return null
		await get_tree().process_frame
		if _architecture != context_architecture:
			return null

	if not _is_owned_architecture_current(context_architecture):
		return null
	var parent_ready := await _wait_for_parent_architecture_ready(context_architecture)
	if not parent_ready:
		return null
	if not _is_owned_architecture_current(context_architecture):
		return null

	await _initialize_owned_architecture(context_architecture)
	if _is_owned_architecture_current(context_architecture) and context_architecture.is_inited():
		return context_architecture
	return null


## 等待上下文架构完成初始化并返回该架构。
## @return 当前上下文架构；上下文失效时返回 null。
func wait_until_ready() -> GFArchitecture:
	var start_msec := Time.get_ticks_msec()
	while _architecture != null and not _architecture.is_inited():
		if not is_inside_tree():
			return null
		var waiting_architecture := _architecture
		if waiting_architecture.has_initialization_failed():
			_fail_context(_get_architecture_failure_reason(waiting_architecture, "上下文架构初始化失败。"))
			return null
		var timeout_reason := _get_wait_timeout_reason(start_msec, "等待上下文初始化超时。")
		if not timeout_reason.is_empty():
			_fail_context(timeout_reason)
			return null
		await get_tree().process_frame
		if _architecture != waiting_architecture:
			return null

	if _architecture != null:
		_is_context_ready = true
	return _architecture


## 通过当前上下文架构获取 Model。
## @param model_type: 模型脚本类型。
## @return 模型实例。
func get_model(model_type: Script) -> Object:
	if _architecture == null:
		return null
	return _architecture.get_model(model_type)


## 通过当前上下文架构获取 System。
## @param system_type: 系统脚本类型。
## @return 系统实例。
func get_system(system_type: Script) -> Object:
	if _architecture == null:
		return null
	return _architecture.get_system(system_type)


## 通过当前上下文架构获取 Utility。
## @param utility_type: 工具脚本类型。
## @return 工具实例。
func get_utility(utility_type: Script) -> Object:
	if _architecture == null:
		return null
	return _architecture.get_utility(utility_type)


## 仅从当前上下文架构获取 Model，不回退父级架构。
## @param model_type: 模型脚本类型。
## @return 当前上下文架构中的模型实例。
func get_local_model(model_type: Script) -> Object:
	if _architecture == null:
		return null
	return _architecture.get_local_model(model_type)


## 仅从当前上下文架构获取 System，不回退父级架构。
## @param system_type: 系统脚本类型。
## @return 当前上下文架构中的系统实例。
func get_local_system(system_type: Script) -> Object:
	if _architecture == null:
		return null
	return _architecture.get_local_system(system_type)


## 仅从当前上下文架构获取 Utility，不回退父级架构。
## @param utility_type: 工具脚本类型。
## @return 当前上下文架构中的工具实例。
func get_local_utility(utility_type: Script) -> Object:
	if _architecture == null:
		return null
	return _architecture.get_local_utility(utility_type)


## 向任意对象注入当前上下文架构依赖。
## @param instance: 要注册、替换或注入的实例。
func inject_object(instance: Object) -> void:
	if _architecture != null:
		_architecture.inject_object(instance)


## 递归向节点树中实现注入 Hook 的节点注入当前上下文架构。
## @param node: 目标节点。
func inject_node_tree(node: Node) -> void:
	if _architecture != null:
		_architecture.inject_node_tree(node)


# --- 私有/辅助方法 ---

func _setup_architecture() -> void:
	var parent_architecture := _find_parent_architecture()

	match scope_mode:
		ScopeMode.INHERITED:
			_architecture = parent_architecture
			_owns_architecture = false
			_is_context_ready = _architecture != null and _architecture.is_inited()

		ScopeMode.SCOPED:
			_architecture = GFArchitecture.new(parent_architecture)
			_architecture.strict_dependency_lookup = strict_dependency_lookup
			if module_async_init_timeout_seconds > 0.0:
				_architecture.module_async_init_timeout_seconds = module_async_init_timeout_seconds
			_owns_architecture = true
			_is_context_ready = false


func _initialize_owned_architecture(architecture_instance: GFArchitecture = null) -> void:
	var initializing_architecture := architecture_instance
	if initializing_architecture == null:
		initializing_architecture = _architecture
	if initializing_architecture == null:
		return

	await initializing_architecture.init()
	if _is_owned_architecture_current(initializing_architecture) and initializing_architecture.is_inited():
		_is_context_ready = true
		context_ready.emit(initializing_architecture)
	elif _is_owned_architecture_current(initializing_architecture) and initializing_architecture.has_initialization_failed():
		_fail_context(_get_architecture_failure_reason(initializing_architecture, "上下文架构初始化失败。"))


func _wait_for_parent_architecture_ready(architecture_instance: GFArchitecture = null) -> bool:
	var scoped_architecture := architecture_instance
	if scoped_architecture == null:
		scoped_architecture = _architecture
	if scoped_architecture == null:
		return true

	var parent_architecture := scoped_architecture.get_parent_architecture()
	var start_msec := Time.get_ticks_msec()
	while parent_architecture != null and not parent_architecture.is_inited():
		if not _is_owned_architecture_current(scoped_architecture):
			return false
		if parent_architecture.has_initialization_failed():
			_fail_context(_get_architecture_failure_reason(parent_architecture, "父级架构初始化失败。"))
			return false
		var timeout_reason := _get_wait_timeout_reason(start_msec, "等待父级架构初始化超时。")
		if not timeout_reason.is_empty():
			_fail_context(timeout_reason)
			return false
		await get_tree().process_frame
		if not _is_owned_architecture_current(scoped_architecture):
			return false
		parent_architecture = scoped_architecture.get_parent_architecture()
	return true


func _find_parent_architecture() -> GFArchitecture:
	var current_node := get_parent()
	while current_node != null:
		if current_node is GFNodeContext:
			var parent_context := current_node as GFNodeContext
			var context_architecture := parent_context.get_architecture()
			if context_architecture != null:
				return context_architecture
		current_node = current_node.get_parent()

	return GFAutoload.get_architecture_or_null()


func _should_tick_owned_architecture() -> bool:
	return (
		process_scoped_ticks
		and _owns_architecture
		and _architecture != null
	)


func _get_wait_timeout_reason(start_msec: int, reason: String) -> String:
	if context_wait_timeout_seconds <= 0.0:
		return ""
	var elapsed_msec := Time.get_ticks_msec() - start_msec
	if elapsed_msec >= int(context_wait_timeout_seconds * 1000.0):
		return reason
	return ""


func _fail_context(reason: String) -> void:
	if reason.is_empty():
		return
	push_warning("[GFNodeContext] %s" % reason)
	context_failed.emit(reason)


func _get_architecture_failure_reason(architecture_instance: GFArchitecture, fallback_reason: String) -> String:
	if architecture_instance != null and not architecture_instance.last_initialization_error.is_empty():
		return architecture_instance.last_initialization_error
	return fallback_reason


func _is_owned_architecture_current(architecture_instance: GFArchitecture) -> bool:
	return (
		is_inside_tree()
		and _owns_architecture
		and _architecture == architecture_instance
	)
