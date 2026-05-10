## GFRepeatAction: 按工厂重复创建并执行队列动作。
##
## 每轮通过 action_factory 创建一个新的 GFVisualAction，避免复用同一个动作实例时
## 残留 Tween、Timer 或节点引用状态。
class_name GFRepeatAction
extends GFVisualAction


# --- 信号 ---

## 重复流程结束时发出。
signal repeat_completed


# --- 公共变量 ---

## 动作工厂。每次调用应返回一个 GFVisualAction；返回 null 会结束重复。
var action_factory: Callable

## 重复次数。0 表示无限重复，直到 cancel()、finish() 或工厂返回 null。
var repeat_count: int = 1


# --- 私有变量 ---

var _execution_serial: int = 0
var _paused: bool = false
var _active_action: GFVisualAction = null


# --- Godot 生命周期方法 ---

func _init(p_action_factory: Callable = Callable(), p_repeat_count: int = 1) -> void:
	action_factory = p_action_factory
	repeat_count = maxi(p_repeat_count, 0)


# --- 公共方法 ---

func execute() -> Variant:
	if not action_factory.is_valid():
		return null

	_execution_serial += 1
	call_deferred("_run_repeat_async", _execution_serial)
	return repeat_completed


func cancel() -> void:
	_execution_serial += 1
	_paused = false
	if is_instance_valid(_active_action):
		_active_action.cancel()
	_active_action = null


func pause() -> void:
	_paused = true
	if is_instance_valid(_active_action):
		_active_action.pause()


func resume() -> void:
	_paused = false
	if is_instance_valid(_active_action):
		_active_action.resume()


func finish() -> void:
	_execution_serial += 1
	_paused = false
	if is_instance_valid(_active_action):
		_active_action.finish()
	_active_action = null
	repeat_completed.emit()


# --- 私有/辅助方法 ---

func _run_repeat_async(current_serial: int) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return

	var completed_count := 0
	while current_serial == _execution_serial:
		if repeat_count > 0 and completed_count >= repeat_count:
			break

		while _paused and current_serial == _execution_serial:
			await tree.process_frame

		if current_serial != _execution_serial:
			return

		var action := action_factory.call() as GFVisualAction
		if not is_instance_valid(action) or not action.can_execute():
			break

		_active_action = action
		action.inject_dependencies(_get_architecture_or_null())
		var result: Variant = action.execute()
		if action.should_wait_for_result(result):
			await action.await_result_safely(result, _is_execution_serial_current.bind(current_serial))

		if current_serial != _execution_serial:
			return

		_active_action = null
		completed_count += 1

	if current_serial == _execution_serial:
		repeat_completed.emit()


func _is_execution_serial_current(serial: int) -> bool:
	return serial == _execution_serial
