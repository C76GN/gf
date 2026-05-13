## GFTweenActionStep: 配置化 Tween 属性步骤。
##
## 描述一个目标对象属性如何缓动，不绑定具体节点或业务动作。
class_name GFTweenActionStep
extends Resource


# --- 导出变量 ---

## 要缓动的属性路径。
@export var property_name: NodePath = ^"position"

## 目标值。
@export var target_value: Variant = null

## 步骤持续时间。
@export var duration: float = 0.2

## 步骤延迟。
@export var delay: float = 0.0

## 是否相对当前值偏移。
@export var as_relative: bool = false

## 是否与前一个步骤并行。
@export var parallel: bool = false

## Tween 过渡类型。
@export var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC

## Tween 缓动类型。
@export var ease_type: Tween.EaseType = Tween.EASE_OUT


# --- 公共方法 ---

## 追加到 Tween。
## @param tween: 目标 Tween。
## @param target: 目标对象。
## @param duration_scale: 时长缩放。
## @return 创建的 Tweener。
func append_to_tween(tween: Tween, target: Object, duration_scale: float = 1.0) -> Variant:
	if tween == null:
		return null
	var validation_error := get_validation_error(target)
	if not validation_error.is_empty():
		push_warning("[GFTweenActionStep] 跳过无效 Tween 步骤：%s" % validation_error)
		return null

	if parallel:
		tween.parallel()

	var effective_scale := maxf(duration_scale, 0.0)
	var effective_duration := maxf(duration * effective_scale, 0.0)
	var effective_delay := maxf(delay * effective_scale, 0.0)
	var tweener := tween.tween_property(target, property_name, target_value, effective_duration)
	tweener.set_trans(transition_type).set_ease(ease_type)
	if effective_delay > 0.0:
		tweener.set_delay(effective_delay)
	if as_relative:
		tweener.as_relative()
	return tweener


## 立即应用步骤目标值。
## @param target: 目标对象。
func apply_instant(target: Object) -> void:
	var validation_error := get_validation_error(target)
	if not validation_error.is_empty():
		push_warning("[GFTweenActionStep] 跳过无效即时步骤：%s" % validation_error)
		return
	if as_relative:
		target.set_indexed(property_name, _resolve_relative_value(target))
	else:
		target.set_indexed(property_name, target_value)


## 创建深拷贝。
## @return 新步骤。
func duplicate_step() -> GFTweenActionStep:
	var step := GFTweenActionStep.new()
	step.property_name = property_name
	step.target_value = target_value
	step.duration = duration
	step.delay = delay
	step.as_relative = as_relative
	step.parallel = parallel
	step.transition_type = transition_type
	step.ease_type = ease_type
	return step


## 检查目标对象是否能应用当前步骤。
## @param target: 目标对象。
## @return 可应用时返回 true。
func can_apply_to(target: Object) -> bool:
	return get_validation_error(target).is_empty()


## 获取当前步骤对目标对象的校验错误。
## @param target: 目标对象。
## @return 校验通过时返回空字符串。
func get_validation_error(target: Object) -> String:
	if not is_instance_valid(target):
		return "Target is invalid."
	if property_name.is_empty():
		return "Property name is empty."

	var root_property := _get_root_property_name()
	if root_property.is_empty():
		return "Property name is empty."
	if not _has_property(target, root_property):
		return "Property not found: %s" % root_property
	if as_relative and not _can_resolve_relative_value(target):
		return "Relative value type mismatch for property: %s" % String(property_name)
	return ""


# --- 私有/辅助方法 ---

func _resolve_relative_value(target: Object) -> Variant:
	var current_value: Variant = target.get_indexed(property_name)
	if current_value is float or current_value is int:
		return float(current_value) + float(target_value)
	if current_value is Vector2 and target_value is Vector2:
		return (current_value as Vector2) + (target_value as Vector2)
	if current_value is Vector3 and target_value is Vector3:
		return (current_value as Vector3) + (target_value as Vector3)
	if current_value is Color and target_value is Color:
		return (current_value as Color) + (target_value as Color)
	return target_value


func _can_resolve_relative_value(target: Object) -> bool:
	var current_value: Variant = target.get_indexed(property_name)
	return (
		(current_value is float or current_value is int)
		and (target_value is float or target_value is int)
	) or (
		current_value is Vector2
		and target_value is Vector2
	) or (
		current_value is Vector3
		and target_value is Vector3
	) or (
		current_value is Color
		and target_value is Color
	)


func _get_root_property_name() -> String:
	var path_text := String(property_name)
	var separator_index := path_text.find(":")
	if separator_index >= 0:
		return path_text.substr(0, separator_index)
	return path_text


func _has_property(target: Object, property: String) -> bool:
	for property_info: Dictionary in target.get_property_list():
		if String(property_info.get("name", "")) == property:
			return true
	return false
