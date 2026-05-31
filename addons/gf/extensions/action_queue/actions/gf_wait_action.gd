## GFWaitAction: 动作队列中的通用等待动作。
##
## 通过 SceneTreeTimer 表达一段时间等待，不携带业务含义。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFWaitAction
extends GFVisualAction


# --- 信号 ---

## 等待完成时发出。取消后的旧计时器不会触发该信号。
## [br]
## @api public
signal wait_completed


# --- 常量 ---

const _GF_ASYNC_CALL_SCRIPT = preload("res://addons/gf/kernel/core/gf_async_call.gd")


# --- 公共变量 ---

## 等待秒数。
## [br]
## @api public
var seconds: float = 0.0

## 可选宿主节点。存在时优先从该节点获取 SceneTree。
## [br]
## @api public
var host_node: Node

## 计时器是否在暂停时继续处理。
## [br]
## @api public
var process_always: bool = true

## 是否按物理帧处理。
## [br]
## @api public
var process_in_physics: bool = false

## 是否忽略 Engine.time_scale。
## [br]
## @api public
var ignore_time_scale: bool = false


# --- 私有变量 ---

var _timer: SceneTreeTimer = null
var _execution_serial: int = 0


# --- Godot 生命周期方法 ---

func _init(p_seconds: float = 0.0, p_host_node: Node = null) -> void:
	seconds = maxf(p_seconds, 0.0)
	host_node = p_host_node


# --- 公共方法 ---

## 启动等待计时器。
## [br]
## @api public
## [br]
## @return 需要等待时返回 wait_completed Signal；无需等待或无法获取 SceneTree 时返回 null。
## [br]
## @schema return: Variant，返回 wait_completed Signal 或 null。
func execute() -> Variant:
	if seconds <= 0.0:
		return null

	var tree: SceneTree = _get_scene_tree()
	if tree == null:
		return null

	_execution_serial += 1
	_timer = tree.create_timer(seconds, process_always, process_in_physics, ignore_time_scale)
	_GF_ASYNC_CALL_SCRIPT.run_detached(Callable(self, &"_complete_after_timer_async"), [_timer, _execution_serial])
	return wait_completed


## 取消当前等待。
## [br]
## @api public
func cancel() -> void:
	_execution_serial += 1
	_timer = null


## 立即完成当前等待并发出 wait_completed。
## [br]
## @api public
func finish() -> void:
	_execution_serial += 1
	wait_completed.emit()
	_timer = null


# --- 私有/辅助方法 ---

func _complete_after_timer_async(timer: SceneTreeTimer, serial: int) -> void:
	if not is_instance_valid(timer):
		return

	await timer.timeout
	if serial != _execution_serial:
		return

	_timer = null
	wait_completed.emit()


func _get_scene_tree() -> SceneTree:
	if is_instance_valid(host_node) and host_node.is_inside_tree():
		return host_node.get_tree()
	return _get_scene_tree_value(Engine.get_main_loop())


func _get_scene_tree_value(value: Variant) -> SceneTree:
	if value is SceneTree:
		var tree: SceneTree = value
		return tree
	return null
