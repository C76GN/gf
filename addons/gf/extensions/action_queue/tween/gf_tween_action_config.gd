## GFTweenActionConfig: 配置化 Tween 动作资源。
##
## 可复用地描述一组属性 Tween 步骤，并生成 GFVisualAction。
class_name GFTweenActionConfig
extends Resource


# --- 常量 ---

const GFTweenActionStepBase = preload("res://addons/gf/extensions/action_queue/tween/gf_tween_action_step.gd")
const GFValidationReportBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")


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

## 取消动作时是否恢复播放前捕获的属性值。
@export var restore_initial_values_on_cancel: bool = false

## 动作正常完成或 finish() 时是否恢复播放前捕获的属性值。
@export var restore_initial_values_on_finish: bool = false


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


## 捕获所有有效步骤的初始属性值。
## @param target: 目标对象。
## @return 属性路径字符串到初始值的字典。
func capture_initial_values(target: Object) -> Dictionary:
	var snapshot: Dictionary = {}
	for step: GFTweenActionStepBase in steps:
		if step == null:
			continue
		var key := String(step.property_name)
		if key.is_empty() or snapshot.has(key):
			continue
		if not step.get_validation_error(target).is_empty():
			continue
		snapshot[key] = step.capture_initial_value(target)
	return snapshot


## 恢复 capture_initial_values() 捕获的属性值。
## @param target: 目标对象。
## @param snapshot: 初始值快照。
func restore_initial_values(target: Object, snapshot: Dictionary) -> void:
	if not is_instance_valid(target):
		return
	for key: Variant in snapshot.keys():
		var property_path := NodePath(String(key))
		if property_path.is_empty():
			continue
		target.set_indexed(property_path, GFVariantData.duplicate_variant(snapshot[key]))


## 获取配置对目标对象的校验报告。
## @param target: 目标对象。
## @return 校验报告。
func get_validation_report(target: Object) -> GFValidationReport:
	var report := GFValidationReportBase.new("GFTweenActionConfig") as GFValidationReport
	for index: int in range(steps.size()):
		var step := steps[index]
		if step == null:
			report.add_warning(&"null_step", "Tween step is null.", index)
			continue
		var validation_error := step.get_validation_error(target)
		if not validation_error.is_empty():
			report.add_error(&"invalid_step", validation_error, index, String(step.property_name))
	return report


## 创建深拷贝。
## @return 新配置。
func duplicate_config() -> GFTweenActionConfig:
	var config := GFTweenActionConfig.new()
	config.duration_scale = duration_scale
	config.loop_count = loop_count
	config.ignore_time_scale = ignore_time_scale
	config.process_mode = process_mode
	config.pause_mode = pause_mode
	config.restore_initial_values_on_cancel = restore_initial_values_on_cancel
	config.restore_initial_values_on_finish = restore_initial_values_on_finish
	for step: GFTweenActionStepBase in steps:
		config.steps.append(step.duplicate_step() if step != null else null)
	return config
