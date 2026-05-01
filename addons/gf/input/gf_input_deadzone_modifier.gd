## GFInputDeadzoneModifier: 输入死区修饰器。
##
## 可对一维或二维轴值应用径向死区，并可选择把剩余范围重新映射到 0..1。
class_name GFInputDeadzoneModifier
extends GFInputModifier


# --- 导出变量 ---

## 低于该阈值的输入会被视为 0。
@export_range(0.0, 1.0, 0.01) var lower_threshold: float = 0.2:
	set(value):
		lower_threshold = clampf(value, 0.0, upper_threshold)

## 达到该阈值时视为满幅输入。
@export_range(0.0, 1.0, 0.01) var upper_threshold: float = 1.0:
	set(value):
		upper_threshold = clampf(value, lower_threshold, 1.0)

## 是否把死区外的剩余范围重新映射到 0..1。
@export var rescale_after_deadzone: bool = true


# --- 公共方法 ---

func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
	var length := value.length()
	if length <= lower_threshold:
		return Vector2.ZERO
	if not rescale_after_deadzone:
		return value

	var range := maxf(upper_threshold - lower_threshold, 0.0001)
	var scaled_length := clampf((minf(length, upper_threshold) - lower_threshold) / range, 0.0, 1.0)
	return value.normalized() * scaled_length


func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
	var length := value.length()
	if length <= lower_threshold:
		return Vector3.ZERO
	if not rescale_after_deadzone:
		return value

	var range := maxf(upper_threshold - lower_threshold, 0.0001)
	var scaled_length := clampf((minf(length, upper_threshold) - lower_threshold) / range, 0.0, 1.0)
	return value.normalized() * scaled_length
