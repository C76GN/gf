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
	if not _can_tween_target_property():
		return null

	if duration <= 0.0:
		target.set_indexed(property_name, target_position)
		return null

	_active_tween = target.create_tween()
	_active_tween.tween_property(target, property_name, target_position, duration).set_trans(transition_type).set_ease(ease_type)
	return _active_tween.finished


func cancel() -> void:
	_emit_active_tween_finished()
	_clear_active_tween()


func pause() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.pause()


func resume() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.play()


func finish() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.custom_step(INF)
	_clear_active_tween()


func get_wait_guard_node() -> Node:
	return target if is_instance_valid(target) else null


# --- 私有/辅助方法 ---

func _clear_active_tween() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
	_active_tween = null


func _emit_active_tween_finished() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.finished.emit()


func _can_tween_target_property() -> bool:
	if not _has_target_property_path():
		push_warning("[GFMoveTweenAction] 目标属性不存在：%s。" % String(property_name))
		return false

	var current_value: Variant = target.get_indexed(property_name)
	if current_value == null:
		push_warning("[GFMoveTweenAction] 目标属性不存在：%s。" % String(property_name))
		return false
	if _values_are_tween_compatible(current_value, target_position):
		return true

	push_warning("[GFMoveTweenAction] 目标属性与目标值类型不兼容：%s。" % String(property_name))
	return false


func _values_are_tween_compatible(current_value: Variant, next_value: Variant) -> bool:
	if _is_numeric_value(current_value) and _is_numeric_value(next_value):
		return true
	if current_value is Vector2 and next_value is Vector2:
		return true
	if current_value is Vector3 and next_value is Vector3:
		return true
	if current_value is Vector4 and next_value is Vector4:
		return true
	if current_value is Color and next_value is Color:
		return true
	return false


func _is_numeric_value(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


func _has_target_property_path() -> bool:
	var base_name := _get_property_base_name(property_name)
	if base_name.is_empty():
		return false

	for property: Dictionary in target.get_property_list():
		if String(property.get("name", "")) == base_name:
			return true
	return false


func _get_property_base_name(path: NodePath) -> String:
	if path.get_name_count() > 0:
		return String(path.get_name(0))

	var text := String(path)
	var separator_index := text.find(":")
	if separator_index >= 0:
		text = text.substr(0, separator_index)
	return text
