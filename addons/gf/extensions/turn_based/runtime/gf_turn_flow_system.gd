## GFTurnFlowSystem: 通用回合流程系统。
##
## 提供阶段推进、行动排队和按优先级解析能力。
## 它不关心战斗、卡牌、棋盘等具体业务，只调度抽象行动。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFTurnFlowSystem
extends GFSystem


# --- 信号 ---

## 流程开始时发出。
## [br]
## @api public
## [br]
## @param context: 当前回合上下文。
signal flow_started(context: GFTurnContext)

## 流程停止时发出。
## [br]
## @api public
## [br]
## @param context: 当前回合上下文。
signal flow_stopped(context: GFTurnContext)

## 阶段切换时发出。
## [br]
## @api public
## [br]
## @param phase: 当前阶段。
## [br]
## @param index: 当前阶段索引。
signal phase_changed(phase: GFTurnPhase, index: int)

## 行动入队时发出。
## [br]
## @api public
## [br]
## @param action: 入队行动。
signal action_enqueued(action: GFTurnAction)

## 行动解析完成时发出。
## [br]
## @api public
## [br]
## @param action: 已解析行动。
signal action_resolved(action: GFTurnAction)


# --- 常量 ---

const _GF_ASYNC_WAIT_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_async_wait_support.gd")


# --- 公共变量 ---

## 当前回合上下文。
## [br]
## @api public
var context: GFTurnContext = GFTurnContext.new()

## 阶段列表。
## [br]
## @api public
var phases: Array[GFTurnPhase] = []

## 当前阶段索引。
## [br]
## @api public
var current_phase_index: int = -1

## 当前是否正在运行。
## [br]
## @api public
var is_running: bool = false

## 解析行动前是否按优先级排序。
## [br]
## @api public
var sort_actions_before_resolve: bool = true

## Signal 等待超时时间。小于等于 0 表示不启用超时。
## [br]
## @api public
var signal_timeout_seconds: float = 30.0

## Signal 超时计时是否跟随 GFTimeUtility 的暂停与 time_scale。
## [br]
## @api public
var signal_timeout_respects_time_scale: bool = true


# --- 私有变量 ---

var _flow_serial: int = 0
var _is_resolving_actions: bool = false


# --- 公共方法 ---

## 设置上下文。
## [br]
## @api public
## [br]
## @param p_context: 新上下文。
func set_context(p_context: GFTurnContext) -> void:
	context = p_context if p_context != null else GFTurnContext.new()


## 设置阶段列表。
## [br]
## @api public
## [br]
## @param p_phases: 新阶段列表。
func set_phases(p_phases: Array[GFTurnPhase]) -> void:
	phases = p_phases.duplicate()


## 开始流程。
## [br]
## @api public
## [br]
## @param reset_indices: 是否重置阶段索引和轮次数据。
func start(reset_indices: bool = true) -> void:
	if reset_indices:
		current_phase_index = -1
		context.turn_index = 0
		context.round_index = 0
	_flow_serial += 1
	is_running = true
	flow_started.emit(context)


## 停止流程。
## [br]
## @api public
## [br]
## @param clear_actions: 是否清空待处理行动。
func stop(clear_actions: bool = true) -> void:
	_flow_serial += 1
	if clear_actions:
		context.clear_actions()
	is_running = false
	flow_stopped.emit(context)


## 推进到下一个阶段。
## [br]
## @api public
func advance_phase() -> void:
	if not is_running:
		start(false)
	if phases.is_empty():
		return
	var flow_serial := _flow_serial

	current_phase_index = (current_phase_index + 1) % phases.size()
	if current_phase_index == 0:
		context.round_index += 1

	var phase := phases[current_phase_index]
	if phase == null:
		return

	phase.reset()
	phase_changed.emit(phase, current_phase_index)
	phase._enter(context)
	if not _is_active_flow_serial(flow_serial):
		return

	var result: Variant = phase._execute(context)
	if result is Signal:
		var completed := await _await_signal_safely(
			result as Signal,
			Callable(self, "_is_active_flow_serial").bind(flow_serial),
			"[GFTurnFlowSystem] 等待阶段 Signal 超时，阶段推进已中止。"
		)
		if not completed or not _is_active_flow_serial(flow_serial):
			return
	if phase.auto_finish:
		phase.finish()
	if not _is_active_flow_serial(flow_serial):
		return
	if not phase.is_finished:
		var completed := await _await_signal_safely(
			phase.finished,
			Callable(self, "_is_active_flow_serial").bind(flow_serial),
			"[GFTurnFlowSystem] 等待阶段完成超时，阶段推进已中止。"
		)
		if not completed or not _is_active_flow_serial(flow_serial):
			return
	phase._exit(context)


## 加入一个行动。
## [br]
## @api public
## [br]
## @param action: 行动实例。
func enqueue_action(action: GFTurnAction) -> void:
	if action == null:
		return
	context.actions.append(action)
	action_enqueued.emit(action)


## 解析当前上下文中的所有行动。
## [br]
## @api public
## [br]
## @param order_resolver: 可选排序回调，签名为 func(a, b) -> bool。
func resolve_actions(order_resolver: Callable = Callable()) -> void:
	if _is_resolving_actions:
		push_warning("[GFTurnFlowSystem] resolve_actions 失败：行动正在解析中。")
		return

	var flow_serial := _flow_serial
	var pending_actions := context.actions.duplicate()
	context.actions.clear()
	_is_resolving_actions = true

	if sort_actions_before_resolve:
		if order_resolver.is_valid():
			pending_actions.sort_custom(order_resolver)
		else:
			pending_actions.sort_custom(_sort_action_desc)

	for action: GFTurnAction in pending_actions:
		if not _is_flow_serial_current(flow_serial):
			break
		if action == null or action.is_cancelled:
			continue
		_inject_action(action)
		context.current_actor = action.actor
		var result: Variant = action._resolve(context)
		if result is Signal:
			var completed := await _await_signal_safely(
				result as Signal,
				Callable(self, "_is_flow_serial_current").bind(flow_serial),
				"[GFTurnFlowSystem] 等待行动 Signal 超时，当前行动已跳过。"
			)
			if not _is_flow_serial_current(flow_serial):
				break
			if not completed:
				continue
		action_resolved.emit(action)

	context.current_actor = null
	_is_resolving_actions = false


# --- 私有/辅助方法 ---

func _sort_action_desc(a: GFTurnAction, b: GFTurnAction) -> bool:
	if a.priority != b.priority:
		return a.priority > b.priority
	return a.sort_value > b.sort_value


func _inject_action(action: GFTurnAction) -> void:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return
	if action.has_method("inject_dependencies"):
		action.call("inject_dependencies", architecture)
	if action.has_method("inject"):
		action.call("inject", architecture)


func _await_signal_safely(result_signal: Signal, should_continue: Callable, timeout_warning: String) -> bool:
	return await _GF_ASYNC_WAIT_SUPPORT.await_signal_safely(
		result_signal,
		should_continue,
		_get_time_utility(),
		signal_timeout_seconds,
		signal_timeout_respects_time_scale,
		timeout_warning
	)


func _get_time_utility() -> GFTimeUtility:
	return get_utility(GFTimeUtility) as GFTimeUtility


func _is_flow_serial_current(serial: int) -> bool:
	return serial == _flow_serial


func _is_active_flow_serial(serial: int) -> bool:
	return is_running and serial == _flow_serial
