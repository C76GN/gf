## GFFlashAction: 通用 CanvasItem 闪色动作。
##
## 将目标节点的颜色属性短暂切到指定颜色，再恢复为原始值。
## 默认等待 Tween 完成后队列才会继续。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFFlashAction
extends GFVisualAction


# --- 公共变量 ---

## 需要闪色的目标节点。
## [br]
## @api public
var target: CanvasItem

## 闪色时写入的颜色。
## [br]
## @api public
var flash_color: Color = Color.WHITE

## 闪色总时长。
## [br]
## @api public
var duration: float = 0.12

## 要缓动的颜色属性名。
## [br]
## @api public
var property_name: NodePath = ^"modulate"


# --- 私有变量 ---

var _active_tween: Tween = null


# --- Godot 生命周期方法 ---

func _init(
	p_target: CanvasItem = null,
	p_flash_color: Color = Color.WHITE,
	p_duration: float = 0.12,
	p_property_name: NodePath = ^"modulate"
) -> void:
	target = p_target
	flash_color = p_flash_color
	duration = maxf(p_duration, 0.0)
	property_name = p_property_name


# --- 公共方法 ---

## 执行闪色 Tween。
## [br]
## @api public
## [br]
## @return 需要等待时返回内部完成 Signal；目标无效、属性无效或瞬时写入时返回 null。
## [br]
## @schema return: Variant，返回内部完成 Signal 或 null。
func execute() -> Variant:
	if not is_instance_valid(target):
		return null

	_clear_active_tween()
	_reset_completion_state()
	var original_color_value := _get_color_property_value()
	if not (original_color_value is Color):
		return null

	var original_color := original_color_value as Color
	if duration <= 0.0:
		target.set_indexed(property_name, original_color)
		return null

	_active_tween = target.create_tween()
	var half_duration := duration * 0.5
	_active_tween.tween_property(target, property_name, flash_color, half_duration)
	_active_tween.tween_property(target, property_name, original_color, half_duration)
	_active_tween.finished.connect(_on_active_tween_finished, CONNECT_ONE_SHOT)
	return _action_completed


## 取消当前 Tween 并释放等待者。
## [br]
## @api public
func cancel() -> void:
	_clear_active_tween()
	_emit_completed_once()


## 获取用于保护等待生命周期的目标节点。
## [br]
## @api public
## [br]
## @return 有效目标节点；无效时返回 null。
func get_wait_guard_node() -> Node:
	return target if is_instance_valid(target) else null


# --- 私有/辅助方法 ---

func _clear_active_tween() -> void:
	if is_instance_valid(_active_tween):
		if _active_tween.finished.is_connected(_on_active_tween_finished):
			_active_tween.finished.disconnect(_on_active_tween_finished)
		_active_tween.kill()
	_active_tween = null


func _get_color_property_value() -> Variant:
	if not _has_target_property_path():
		push_warning("[GFFlashAction] 目标属性不存在：%s。" % String(property_name))
		return null

	var value: Variant = target.get_indexed(property_name)
	if value is Color:
		return value

	push_warning("[GFFlashAction] 目标属性不是 Color：%s。" % String(property_name))
	return null


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


# --- 信号处理函数 ---

func _on_active_tween_finished() -> void:
	_active_tween = null
	_emit_completed_once()
