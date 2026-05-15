## GFCameraBlend: 通用相机过渡资源。
##
## 描述两个相机姿态之间的时间和缓动方式，不绑定具体相机节点、
## 目标选择规则、反馈效果或场景业务。
class_name GFCameraBlend
extends Resource


# --- 导出变量 ---

## 过渡持续时间，单位秒。小于等于 0 时表示立即切换。
@export_range(0.0, 60.0, 0.001, "or_greater") var duration_seconds: float = 0.35

## Tween 过渡类型。
@export var transition_type: Tween.TransitionType = Tween.TRANS_SINE

## Tween 缓动类型。
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT


# --- 公共方法 ---

## 是否为立即切换。
## @return 持续时间小于等于 0 时返回 true。
func is_instant() -> bool:
	return duration_seconds <= 0.0


## 按已过时间采样 0..1 权重。
## @param elapsed_seconds: 已过时间。
## @return 缓动后的权重。
func sample_weight(elapsed_seconds: float) -> float:
	if is_instant():
		return 1.0
	var clamped_elapsed := clampf(elapsed_seconds, 0.0, duration_seconds)
	return clampf(float(Tween.interpolate_value(
		0.0,
		1.0,
		clamped_elapsed,
		duration_seconds,
		transition_type,
		ease_type
	)), 0.0, 1.0)


## 创建深拷贝。
## @return 新过渡资源。
func duplicate_blend() -> GFCameraBlend:
	var blend := GFCameraBlend.new()
	blend.duration_seconds = duration_seconds
	blend.transition_type = transition_type
	blend.ease_type = ease_type
	return blend

