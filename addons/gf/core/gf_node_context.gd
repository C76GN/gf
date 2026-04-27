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


# --- 公共变量 ---

## 当前上下文使用的架构实例。
var architecture: GFArchitecture:
	get:
		return get_architecture()


# --- 私有变量 ---

var _architecture: GFArchitecture = null
var _owns_architecture: bool = false
var _is_context_ready: bool = false


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_setup_architecture()
	if _owns_architecture:
		await _wait_for_parent_architecture_ready()
		await install(_architecture)
		await install_bindings(_architecture.create_binder())
		if auto_init:
			await _initialize_owned_architecture()
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


# --- 公共方法 ---

## 安装当前上下文的局部模块。仅在 SCOPED 模式下调用。
## @param architecture_instance: 当前上下文创建的局部架构。
func install(_architecture_instance: GFArchitecture) -> void:
	pass


## 使用声明式装配器安装当前上下文的局部模块。仅在 SCOPED 模式下调用。
## @param binder: 当前上下文创建的局部架构装配器。
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


## 等待上下文架构完成初始化并返回该架构。
## @return 当前上下文架构；上下文失效时返回 null。
func wait_until_ready() -> GFArchitecture:
	while _architecture != null and not _architecture.is_inited():
		if not is_inside_tree():
			return null
		var waiting_architecture := _architecture
		await waiting_architecture.initialization_finished
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
			_owns_architecture = true
			_is_context_ready = false


func _initialize_owned_architecture() -> void:
	var initializing_architecture := _architecture
	if initializing_architecture == null:
		return

	await initializing_architecture.init()
	if _architecture == initializing_architecture and initializing_architecture.is_inited():
		_is_context_ready = true
		context_ready.emit(initializing_architecture)


func _wait_for_parent_architecture_ready() -> void:
	if _architecture == null:
		return

	var parent_architecture := _architecture.get_parent_architecture()
	while parent_architecture != null and not parent_architecture.is_inited():
		if not is_inside_tree():
			return
		await parent_architecture.initialization_finished
		if _architecture == null:
			return
		parent_architecture = _architecture.get_parent_architecture()


func _find_parent_architecture() -> GFArchitecture:
	var current_node := get_parent()
	while current_node != null:
		if current_node is GFNodeContext:
			var parent_context := current_node as GFNodeContext
			var context_architecture := parent_context.get_architecture()
			if context_architecture != null:
				return context_architecture
		current_node = current_node.get_parent()

	if Gf.has_architecture():
		return Gf.get_architecture()
	return null


func _should_tick_owned_architecture() -> bool:
	return (
		process_scoped_ticks
		and _owns_architecture
		and _architecture != null
	)
