## GFTweenActionConfig: 配置化 Tween 动作资源。
##
## 可复用地描述一组属性 Tween 步骤，并生成 GFVisualAction。
class_name GFTweenActionConfig
extends Resource


# --- 常量 ---

const GFTweenActionStepBase = preload("res://addons/gf/extensions/action_queue/gf_tween_action_step.gd")


# --- 导出变量 ---

## Tween 步骤列表。
@export var steps: Array[GFTweenActionStepBase] = []

## 全局时长缩放。
@export var duration_scale: float = 1.0

## 播放次数。1 表示播放一次，0 表示无限循环。
@export_range(0, 999, 1) var loop_count: int = 1

## 是否忽略全局 time scale。
@export var ignore_time_scale: bool = false

## Tween 处理模式。
@export var process_mode: Tween.TweenProcessMode = Tween.TWEEN_PROCESS_IDLE

## Tween 暂停模式。
@export var pause_mode: Tween.TweenPauseMode = Tween.TWEEN_PAUSE_BOUND


# --- 公共方法 ---

## 创建配置化 Tween 动作。
## @param target: 目标对象。
## @param host_node: 可选 Tween 宿主节点。
## @return 动作实例。
func create_action(target: Object, host_node: Node = null) -> GFVisualAction:
	return GFConfiguredTweenAction.new(target, self, host_node)


## 添加一个属性步骤并返回该步骤。
## @param property_name: 属性路径。
## @param target_value: 目标值。
## @param duration: 持续时间。
## @return 新步骤。
func add_property_step(
	property_name: NodePath,
	target_value: Variant,
	duration: float = 0.2
) -> GFTweenActionStepBase:
	var step := GFTweenActionStepBase.new()
	step.property_name = property_name
	step.target_value = target_value
	step.duration = duration
	steps.append(step)
	return step


## 是否没有有效步骤。
## @return 无步骤返回 true。
func is_empty() -> bool:
	for step: GFTweenActionStepBase in steps:
		if step != null:
			return false
	return true


## 是否包含需要等待的步骤。
## @return 包含耗时步骤返回 true。
func has_timed_steps() -> bool:
	var effective_scale := maxf(duration_scale, 0.0)
	for step: GFTweenActionStepBase in steps:
		if step != null and (step.duration * effective_scale > 0.0 or step.delay * effective_scale > 0.0):
			return true
	return false


## 立即应用全部步骤。
## @param target: 目标对象。
func apply_instant(target: Object) -> void:
	for step: GFTweenActionStepBase in steps:
		if step != null:
			step.apply_instant(target)


## 创建深拷贝。
## @return 新配置。
func duplicate_config() -> GFTweenActionConfig:
	var config := GFTweenActionConfig.new()
	config.duration_scale = duration_scale
	config.loop_count = loop_count
	config.ignore_time_scale = ignore_time_scale
	config.process_mode = process_mode
	config.pause_mode = pause_mode
	for step: GFTweenActionStepBase in steps:
		config.steps.append(step.duplicate_step() if step != null else null)
	return config
