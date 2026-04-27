## GFVisualActionGroup: 动作组复合节点 (Composite Pattern)
## 
## 继承自 GFVisualAction。允许将一组子动作打包，按并行（全部一起发出并等待全部完成）
## 或顺序（逐个执行并等待各自完成）两种模式执行。
class_name GFVisualActionGroup
extends GFVisualAction


# --- 信号 ---

## 内部使用：并行执行全部完成时发出。
signal _parallel_completed

## 内部使用：顺序执行全部完成时发出。
signal _sequence_completed


# --- 公共变量 ---

## 包含的子动作列表。
var actions: Array[GFVisualAction] = []

## 是否并行执行。为 true 时，并行触发所有子动作并等待全部完成；
## 为 false 时，按数组顺序依次执行并等待各自完成。
var is_parallel: bool = true


# --- 私有变量 ---

var _execution_serial: int = 0


# --- Godot 生命周期方法 ---

func _init(actions_list: Array[GFVisualAction] = [], parallel: bool = true) -> void:
	actions = actions_list
	is_parallel = parallel


# --- 公共方法 ---

## 添加一个子动作。
## @param action: GFVisualAction 实例。
func add(action: GFVisualAction) -> void:
	if is_instance_valid(action):
		actions.append(action)


## 执行动作组逻辑。根据 is_parallel 决定并发还是串行。
## @return 需要等待则返回内部完成信号，否则返回 null。
func execute() -> Variant:
	if actions.is_empty():
		return null

	_execution_serial += 1
	var current_serial: int = _execution_serial

	if is_parallel:
		return _run_parallel(current_serial)
	return _run_sequence(current_serial)


# --- 私有方法 ---

func _run_parallel(current_serial: int) -> Variant:
	call_deferred("_do_parallel_async", current_serial)
	return _parallel_completed


func _run_sequence(current_serial: int) -> Variant:
	call_deferred("_do_sequence_async", current_serial)
	return _sequence_completed


func _do_parallel_async(current_serial: int) -> void:
	if current_serial != _execution_serial:
		return

	var pending_state := { "count": 0 }
	for action: GFVisualAction in actions:
		if not is_instance_valid(action):
			continue

		_inject_action_dependencies(action)
		var result: Variant = action.execute()
		if action.should_wait_for_result(result):
			pending_state["count"] = int(pending_state["count"]) + 1
			_wait_parallel_action(action, result, pending_state, current_serial)

	if int(pending_state["count"]) <= 0 and current_serial == _execution_serial:
		_parallel_completed.emit()


func _do_sequence_async(current_serial: int) -> void:
	if current_serial != _execution_serial:
		return

	for action: GFVisualAction in actions:
		if not is_instance_valid(action):
			continue

		_inject_action_dependencies(action)
		var result: Variant = action.execute()
		if action.should_wait_for_result(result):
			await action.await_result_safely(result)

		if current_serial != _execution_serial:
			return

	_sequence_completed.emit()


func _wait_parallel_action(
	action: GFVisualAction,
	result: Variant,
	pending_state: Dictionary,
	current_serial: int,
) -> void:
	if current_serial != _execution_serial or not is_instance_valid(action):
		return

	await action.await_result_safely(result)

	if current_serial != _execution_serial:
		return

	pending_state["count"] = int(pending_state["count"]) - 1
	if int(pending_state["count"]) <= 0:
		_parallel_completed.emit()


func _inject_action_dependencies(action: GFVisualAction) -> void:
	if action.has_method("inject_dependencies"):
		action.inject_dependencies(_get_architecture_or_null())
