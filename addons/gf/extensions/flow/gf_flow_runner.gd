## GFFlowRunner: 通用流程图执行器。
##
## 按节点后继关系执行 GFFlowGraph，支持 Signal 等待、取消和简单循环保护。
class_name GFFlowRunner
extends RefCounted


# --- 信号 ---

## 流程开始时发出。
signal flow_started(graph: GFFlowGraph)

## 节点开始执行时发出。
signal node_started(node_id: StringName, node: GFFlowNode)

## 节点完成执行时发出。
signal node_completed(node_id: StringName, node: GFFlowNode)

## 流程完成时发出。
signal flow_completed

## 流程取消时发出。
signal flow_cancelled


# --- 公共变量 ---

## 当前是否正在执行。
var is_running: bool = false

## 最多执行节点数量，避免循环图无限运行。小于等于 0 表示不限制。
var max_executed_nodes: int = 1024

## Signal 等待超时时间。小于等于 0 表示不启用超时。
var signal_timeout_seconds: float = 30.0


# --- 私有变量 ---

var _cancel_requested: bool = false
var _architecture_ref: WeakRef = null


# --- 公共方法 ---

## 注入架构。通常由 GFArchitecture 创建或注册时自动调用。
## @param architecture: 架构实例。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null


## 运行流程图。
## @param graph: 流程图资源。
## @param context: 可选上下文。
func run(graph: GFFlowGraph, context: GFFlowContext = null) -> void:
	if graph == null:
		push_error("[GFFlowRunner] run 失败：graph 为空。")
		return
	if is_running:
		push_warning("[GFFlowRunner] 流程正在执行，忽略重复 run()。")
		return

	var flow_context := context if context != null else GFFlowContext.new(_get_architecture_or_null())
	if flow_context.get_architecture() == null:
		flow_context.set_architecture(_get_architecture_or_null())

	is_running = true
	_cancel_requested = false
	flow_started.emit(graph)
	await _run_graph(graph, flow_context)
	is_running = false
	if _cancel_requested:
		flow_cancelled.emit()
	else:
		flow_completed.emit()


## 请求取消流程。
func cancel() -> void:
	_cancel_requested = true


## 设置 Signal 等待超时时间。
## @param seconds: 秒数。
## @return 当前执行器。
func with_signal_timeout(seconds: float) -> GFFlowRunner:
	signal_timeout_seconds = maxf(seconds, 0.0)
	return self


# --- 私有/辅助方法 ---

func _run_graph(graph: GFFlowGraph, context: GFFlowContext) -> void:
	var pending := PackedStringArray([String(graph.start_node_id)])
	var executed_count := 0
	while not pending.is_empty() and not _cancel_requested:
		if max_executed_nodes > 0 and executed_count >= max_executed_nodes:
			push_warning("[GFFlowRunner] 达到最大节点执行数量，流程停止。")
			break

		var node_id := StringName(pending[0])
		pending.remove_at(0)
		if node_id == &"":
			continue

		var node := graph.get_node(node_id)
		if node == null:
			push_warning("[GFFlowRunner] 缺少流程节点：%s" % String(node_id))
			continue

		executed_count += 1
		context.clear_next_nodes()
		node_started.emit(node_id, node)
		var result: Variant = node.execute(context)
		if node.wait_for_result and result is Signal:
			await _await_signal_safely(result as Signal)
		node_completed.emit(node_id, node)

		var next_ids := node.get_next_nodes(context)
		for next_id: String in next_ids:
			pending.append(next_id)


func _await_signal_safely(result_signal: Signal) -> void:
	if result_signal.is_null():
		return

	var target_obj: Object = result_signal.get_object()
	if not is_instance_valid(target_obj):
		return

	var completed := [false]
	var on_resume := func(_arg1 = null, _arg2 = null, _arg3 = null, _arg4 = null) -> void:
		completed[0] = true

	result_signal.connect(on_resume, CONNECT_ONE_SHOT)
	var timeout_msec := signal_timeout_seconds * 1000.0
	var elapsed_timeout_msec := 0.0
	var last_timeout_msec := Time.get_ticks_msec()

	while not completed[0] and not _cancel_requested:
		var current_timeout_msec := Time.get_ticks_msec()
		if timeout_msec > 0.0:
			elapsed_timeout_msec += float(current_timeout_msec - last_timeout_msec)
			if elapsed_timeout_msec >= timeout_msec:
				push_warning("[GFFlowRunner] 等待 Signal 超时，流程将继续执行后续节点。")
				break
		last_timeout_msec = current_timeout_msec
		if not is_instance_valid(target_obj):
			break
		await Engine.get_main_loop().process_frame

	_disconnect_signal_if_connected(result_signal, on_resume)


func _disconnect_signal_if_connected(target_signal: Signal, callback: Callable) -> void:
	if target_signal.is_null():
		return
	if not is_instance_valid(target_signal.get_object()):
		return
	if target_signal.is_connected(callback):
		target_signal.disconnect(callback)


func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	return GFAutoload.get_architecture_or_null()
