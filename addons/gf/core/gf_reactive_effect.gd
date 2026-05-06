## GFReactiveEffect: BindableProperty 的轻量响应式副作用。
##
## 监听一组 BindableProperty，在任意来源变化时执行回调。可绑定 Node 生命周期，
## 适合 Controller 层组合多个 Model 属性，不要求项目引入新的状态模型。
class_name GFReactiveEffect
extends RefCounted


# --- 信号 ---

## effect 执行后发出。
## @param value: 回调返回值。
signal effect_ran(value: Variant)


# --- 公共变量 ---

## 单次 run 中最多补跑的次数，避免回调持续写入来源属性造成死循环。
var max_reruns_per_run: int = 8


# --- 私有变量 ---

var _sources: Array[BindableProperty] = []
var _callback: Callable = Callable()
var _owner_ref: WeakRef = null
var _connections: Array[Dictionary] = []
var _active: bool = false
var _running: bool = false
var _rerun_requested: bool = false


# --- Godot 生命周期方法 ---

## 构造函数。
## @param sources: 要监听的 BindableProperty 列表。
## @param callback: 变化后执行的回调。
## @param owner: 可选 Node 生命周期宿主。
## @param run_immediately: 是否立即执行一次。
func _init(
	sources: Array[BindableProperty] = [],
	callback: Callable = Callable(),
	owner: Node = null,
	run_immediately: bool = true
) -> void:
	if not sources.is_empty() or callback.is_valid():
		configure(sources, callback, owner, run_immediately)


# --- 公共方法 ---

## 配置并启动 effect。重复调用会先停止旧绑定。
## @param sources: 要监听的 BindableProperty 列表。
## @param callback: 变化后执行的回调。
## @param owner: 可选 Node 生命周期宿主。
## @param run_immediately: 是否立即执行一次。
func configure(
	sources: Array[BindableProperty],
	callback: Callable,
	owner: Node = null,
	run_immediately: bool = true
) -> void:
	stop()
	_sources = _filter_sources(sources)
	_callback = callback
	_owner_ref = weakref(owner) if owner != null else null
	_active = _callback.is_valid()
	if not _active:
		return

	for source: BindableProperty in _sources:
		_bind_source(source, owner)

	var stop_callback := Callable(self, "stop")
	if owner != null and not owner.tree_exited.is_connected(stop_callback):
		owner.tree_exited.connect(stop_callback, CONNECT_ONE_SHOT)

	if run_immediately:
		run()


## 手动执行 effect。
## @return 回调返回值；回调无效时返回 null。
func run() -> Variant:
	if not _active or not _callback.is_valid():
		return null
	if _running:
		_rerun_requested = true
		return null

	var value: Variant = null
	var rerun_count := 0
	while _active and _callback.is_valid():
		_running = true
		_rerun_requested = false
		value = _callback.call()
		_running = false
		effect_ran.emit(value)

		if not _rerun_requested:
			break
		rerun_count += 1
		if rerun_count >= maxi(max_reruns_per_run, 1):
			push_warning("[GFReactiveEffect] run 停止补跑：达到 max_reruns_per_run。")
			break
	return value


## 停止 effect 并断开全部监听。
func stop() -> void:
	for connection: Dictionary in _connections:
		var source := connection.get("source") as BindableProperty
		var callback := connection.get("callable", Callable()) as Callable
		var owner := _get_owner()
		if source == null or not callback.is_valid():
			continue
		if owner != null:
			source.unbind(owner, callback)
		elif source.value_changed.is_connected(callback):
			source.value_changed.disconnect(callback)

	var owner := _get_owner()
	var stop_callback := Callable(self, "stop")
	if owner != null and owner.tree_exited.is_connected(stop_callback):
		owner.tree_exited.disconnect(stop_callback)

	_connections.clear()
	_sources.clear()
	_callback = Callable()
	_owner_ref = null
	_active = false
	_running = false
	_rerun_requested = false


## 检查 effect 是否处于激活状态。
## @return 激活时返回 true。
func is_active() -> bool:
	return _active


## 获取当前监听的属性列表。
## @return BindableProperty 数组。
func get_sources() -> Array[BindableProperty]:
	return _sources.duplicate()


# --- 私有/辅助方法 ---

func _bind_source(source: BindableProperty, owner: Node) -> void:
	var callback := Callable(self, "_on_source_changed")
	_connections.append({
		"source": source,
		"callable": callback,
	})
	if owner != null:
		source.bind_to(owner, callback)
	elif not source.value_changed.is_connected(callback):
		source.value_changed.connect(callback)


func _filter_sources(sources: Array[BindableProperty]) -> Array[BindableProperty]:
	var result: Array[BindableProperty] = []
	for source: BindableProperty in sources:
		if source != null and not result.has(source):
			result.append(source)
	return result


func _get_owner() -> Node:
	if _owner_ref == null:
		return null
	return _owner_ref.get_ref() as Node


func _on_source_changed(_old_value: Variant, _new_value: Variant) -> void:
	run()
