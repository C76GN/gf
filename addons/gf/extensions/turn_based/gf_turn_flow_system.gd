## GFTurnFlowSystem: 通用回合流程系统。
##
## 提供阶段推进、行动排队和按优先级解析能力。
## 它不关心战斗、卡牌、棋盘等具体业务，只调度抽象行动。
class_name GFTurnFlowSystem
extends GFSystem


# --- 信号 ---

## 流程开始时发出。
signal flow_started(context: GFTurnContext)

## 流程停止时发出。
signal flow_stopped(context: GFTurnContext)

## 阶段切换时发出。
signal phase_changed(phase: GFTurnPhase, index: int)

## 行动入队时发出。
signal action_enqueued(action: GFTurnAction)

## 行动解析完成时发出。
signal action_resolved(action: GFTurnAction)


# --- 公共变量 ---

## 当前回合上下文。
var context: GFTurnContext = GFTurnContext.new()

## 阶段列表。
var phases: Array[GFTurnPhase] = []

## 当前阶段索引。
var current_phase_index: int = -1

## 当前是否正在运行。
var is_running: bool = false

## 解析行动前是否按优先级排序。
var sort_actions_before_resolve: bool = true


# --- 公共方法 ---

## 设置上下文。
## @param p_context: 新上下文。
func set_context(p_context: GFTurnContext) -> void:
	context = p_context if p_context != null else GFTurnContext.new()


## 设置阶段列表。
## @param p_phases: 新阶段列表。
func set_phases(p_phases: Array[GFTurnPhase]) -> void:
	phases = p_phases.duplicate()


## 开始流程。
## @param reset_indices: 是否重置阶段索引和轮次数据。
func start(reset_indices: bool = true) -> void:
	if reset_indices:
		current_phase_index = -1
		context.turn_index = 0
		context.round_index = 0
	is_running = true
	flow_started.emit(context)


## 停止流程。
## @param clear_actions: 是否清空待处理行动。
func stop(clear_actions: bool = true) -> void:
	if clear_actions:
		context.clear_actions()
	is_running = false
	flow_stopped.emit(context)


## 推进到下一个阶段。
func advance_phase() -> void:
	if not is_running:
		start(false)
	if phases.is_empty():
		return

	current_phase_index = (current_phase_index + 1) % phases.size()
	if current_phase_index == 0:
		context.round_index += 1

	var phase := phases[current_phase_index]
	if phase == null:
		return

	phase.reset()
	phase_changed.emit(phase, current_phase_index)
	phase.enter(context)
	var result: Variant = phase.execute(context)
	if result is Signal:
		await (result as Signal)
	if phase.auto_finish:
		phase.finish()
	if not phase.is_finished:
		await phase.finished
	phase.exit(context)


## 加入一个行动。
## @param action: 行动实例。
func enqueue_action(action: GFTurnAction) -> void:
	if action == null:
		return
	context.actions.append(action)
	action_enqueued.emit(action)


## 解析当前上下文中的所有行动。
## @param order_resolver: 可选排序回调，签名为 func(a, b) -> bool。
func resolve_actions(order_resolver: Callable = Callable()) -> void:
	var pending_actions := context.actions.duplicate()
	context.actions.clear()

	if sort_actions_before_resolve:
		if order_resolver.is_valid():
			pending_actions.sort_custom(order_resolver)
		else:
			pending_actions.sort_custom(_sort_action_desc)

	for action: GFTurnAction in pending_actions:
		if action == null or action.is_cancelled:
			continue
		_inject_action(action)
		context.current_actor = action.actor
		var result: Variant = action.resolve(context)
		if result is Signal:
			await (result as Signal)
		action_resolved.emit(action)

	context.current_actor = null


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
