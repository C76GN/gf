## GFWaitAction: 动作队列中的通用等待动作。
##
## 通过 SceneTreeTimer 表达一段时间等待，不携带业务含义。
class_name GFWaitAction
extends GFVisualAction


# --- 公共变量 ---

## 等待秒数。
var seconds: float = 0.0

## 可选宿主节点。存在时优先从该节点获取 SceneTree。
var host_node: Node

## 计时器是否在暂停时继续处理。
var process_always: bool = true

## 是否按物理帧处理。
var process_in_physics: bool = false

## 是否忽略 Engine.time_scale。
var ignore_time_scale: bool = false


# --- 私有变量 ---

var _timer: SceneTreeTimer = null


# --- Godot 生命周期方法 ---

func _init(p_seconds: float = 0.0, p_host_node: Node = null) -> void:
	seconds = maxf(p_seconds, 0.0)
	host_node = p_host_node


# --- 公共方法 ---

func execute() -> Variant:
	if seconds <= 0.0:
		return null

	var tree := _get_scene_tree()
	if tree == null:
		return null

	_timer = tree.create_timer(seconds, process_always, process_in_physics, ignore_time_scale)
	return _timer.timeout


func cancel() -> void:
	_timer = null


func finish() -> void:
	if is_instance_valid(_timer):
		_timer.timeout.emit()
	_timer = null


# --- 私有/辅助方法 ---

func _get_scene_tree() -> SceneTree:
	if is_instance_valid(host_node) and host_node.is_inside_tree():
		return host_node.get_tree()
	return Engine.get_main_loop() as SceneTree
