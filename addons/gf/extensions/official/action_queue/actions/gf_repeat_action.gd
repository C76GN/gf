## GFRepeatAction: 按工厂重复创建并执行队列动作。
##
## 每轮通过 action_factory 创建一个新的动作对象，避免复用同一个动作实例时
## 残留 Tween、Timer 或节点引用状态。
class_name GFRepeatAction
extends GFVisualAction


# --- 信号 ---

## 重复流程结束时发出。
signal repeat_completed


# --- 常量 ---

const _ACTION_PROTOCOL: Script = preload("res://addons/gf/extensions/official/action_queue/core/gf_action_protocol.gd")

## 单帧最多连续执行的瞬时重复次数，避免无限重复的瞬时动作锁住主线程。
const DEFAULT_MAX_IMMEDIATE_ITERATIONS_PER_FRAME: int = 256


# --- 公共变量 ---

## 动作工厂。每次调用应返回一个动作对象；返回 null 会结束重复。
var action_factory: Callable

## 重复次数。0 表示无限重复，直到 cancel()、finish() 或工厂返回 null。
var repeat_count: int = 1

## 单帧最多连续执行的瞬时重复次数。小于 1 时按 1 处理。
var max_immediate_iterations_per_frame: int = DEFAULT_MAX_IMMEDIATE_ITERATIONS_PER_FRAME


# --- 私有变量 ---

var _execution_serial: int = 0
var _paused: bool = false
var _active_action: Object = null


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
		_ACTION_PROTOCOL.cancel(_active_action)
	_active_action = null


func pause() -> void:
	_paused = true
	if is_instance_valid(_active_action):
		_ACTION_PROTOCOL.pause(_active_action)


func resume() -> void:
	_paused = false
	if is_instance_valid(_active_action):
		_ACTION_PROTOCOL.resume(_active_action)


func finish() -> void:
	_execution_serial += 1
	_paused = false
	if is_instance_valid(_active_action):
		_ACTION_PROTOCOL.finish(_active_action)
	_active_action = null
	repeat_completed.emit()


# --- 私有/辅助方法 ---

func _run_repeat_async(current_serial: int) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return

	var completed_count := 0
	var immediate_count := 0
	while current_serial == _execution_serial:
		if repeat_count > 0 and completed_count >= repeat_count:
			break

		while _paused and current_serial == _execution_serial:
			await tree.process_frame

		if current_serial != _execution_serial:
			return

		var action := action_factory.call() as Object
		if not _ACTION_PROTOCOL.is_action_valid(action) or not _ACTION_PROTOCOL.can_execute(action):
			break

		_active_action = action
		_ACTION_PROTOCOL.inject_dependencies(action, _get_architecture_or_null())
		var result: Variant = _ACTION_PROTOCOL.execute(action)
		var waited := false
		if _ACTION_PROTOCOL.should_wait_for_result(action, result):
			waited = true
			immediate_count = 0
			await _ACTION_PROTOCOL.await_result_safely(
				action,
				result,
				_is_execution_serial_current.bind(current_serial),
				_get_architecture_or_null()
			)

		if current_serial != _execution_serial:
			return

		_active_action = null
		completed_count += 1
		if waited:
			continue

		immediate_count += 1
		if immediate_count >= maxi(max_immediate_iterations_per_frame, 1):
			immediate_count = 0
			await tree.process_frame

	if current_serial == _execution_serial:
		repeat_completed.emit()


func _is_execution_serial_current(serial: int) -> bool:
	return serial == _execution_serial
