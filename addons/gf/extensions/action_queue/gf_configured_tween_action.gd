## GFConfiguredTweenAction: 由 GFTweenActionConfig 驱动的通用 Tween 动作。
##
## 允许项目把表现动画拆成 Resource 配置，再交给 GFActionQueueSystem 编排。
class_name GFConfiguredTweenAction
extends GFVisualAction


# --- 常量 ---

const GFTweenActionConfigBase = preload("res://addons/gf/extensions/action_queue/gf_tween_action_config.gd")
const GFTweenActionStepBase = preload("res://addons/gf/extensions/action_queue/gf_tween_action_step.gd")


# --- 公共变量 ---

## 被缓动的目标对象。
var target: Object

## Tween 配置。
var config: GFTweenActionConfigBase

## 可选 Tween 宿主节点。目标不是 Node 时必须提供。
var host_node: Node


# --- 私有变量 ---

var _active_tween: Tween = null


# --- Godot 生命周期方法 ---

func _init(
	p_target: Object = null,
	p_config: GFTweenActionConfigBase = null,
	p_host_node: Node = null
) -> void:
	target = p_target
	config = p_config
	host_node = p_host_node


# --- 公共方法 ---

func execute() -> Variant:
	if config == null or config.is_empty() or not is_instance_valid(target):
		return null

	_clear_active_tween()
	if not config.has_timed_steps():
		config.apply_instant(target)
		return null

	var tween_host := _get_tween_host()
	if tween_host == null:
		push_warning("[GFConfiguredTweenAction] 缺少有效 Tween 宿主节点。")
		return null

	_active_tween = tween_host.create_tween()
	_active_tween.set_ignore_time_scale(config.ignore_time_scale)
	_active_tween.set_process_mode(config.process_mode)
	_active_tween.set_pause_mode(config.pause_mode)
	if config.loop_count != 1:
		_active_tween.set_loops(config.loop_count)

	var appended_count := 0
	for step: GFTweenActionStepBase in config.steps:
		if step == null:
			continue
		if step.append_to_tween(_active_tween, target, config.duration_scale) != null:
			appended_count += 1

	if appended_count <= 0:
		_clear_active_tween()
		return null
	return _active_tween.finished


func cancel() -> void:
	_clear_active_tween()


func get_wait_guard_node() -> Node:
	var tween_host := _get_tween_host()
	return tween_host if is_instance_valid(tween_host) else null


# --- 私有/辅助方法 ---

func _get_tween_host() -> Node:
	if is_instance_valid(host_node):
		return host_node
	if target is Node and is_instance_valid(target):
		return target as Node
	return null


func _clear_active_tween() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
	_active_tween = null
