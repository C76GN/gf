## GFMoveTweenAction: 通用节点移动 Tween 动作。
##
## 将目标节点的指定位置属性缓动到目标值，适合卡牌、棋子、UI 面板等
## 常见表现动作。默认等待 Tween 完成后队列才会继续。
class_name GFMoveTweenAction
extends GFVisualAction


# --- 公共变量 ---

## 被移动的目标节点。
var target: Node

## 要写入的位置值，通常为 Vector2 或 Vector3。
var target_position: Variant

## Tween 持续时间。
var duration: float = 0.2

## 要缓动的属性名。
var property_name: NodePath = ^"position"

## Tween 过渡类型。
var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC

## Tween 缓动类型。
var ease_type: Tween.EaseType = Tween.EASE_OUT


# --- 私有变量 ---

var _active_tween: Tween = null


# --- Godot 生命周期方法 ---

func _init(
	p_target: Node = null,
	p_target_position: Variant = null,
	p_duration: float = 0.2,
	p_property_name: NodePath = ^"position"
) -> void:
	target = p_target
	target_position = p_target_position
	duration = maxf(p_duration, 0.0)
	property_name = p_property_name


# --- 公共方法 ---

func execute() -> Variant:
	if not is_instance_valid(target):
		return null

	_clear_active_tween()
	if duration <= 0.0:
		target.set_indexed(property_name, target_position)
		return null

	_active_tween = target.create_tween()
	_active_tween.tween_property(target, property_name, target_position, duration).set_trans(transition_type).set_ease(ease_type)
	return _active_tween.finished


func cancel() -> void:
	_clear_active_tween()


# --- 私有/辅助方法 ---

func _clear_active_tween() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
	_active_tween = null
