## GFFlashAction: 通用 CanvasItem 闪色动作。
##
## 将目标节点的颜色属性短暂切到指定颜色，再恢复为原始值。
## 默认等待 Tween 完成后队列才会继续。
class_name GFFlashAction
extends GFVisualAction


# --- 公共变量 ---

## 需要闪色的目标节点。
var target: CanvasItem

## 闪色时写入的颜色。
var flash_color: Color = Color.WHITE

## 闪色总时长。
var duration: float = 0.12

## 要缓动的颜色属性名。
var property_name: NodePath = ^"modulate"


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

func execute() -> Variant:
	if not is_instance_valid(target):
		return null

	var original_color := target.get_indexed(property_name) as Color
	if duration <= 0.0:
		target.set_indexed(property_name, original_color)
		return null

	var tween := target.create_tween()
	var half_duration := duration * 0.5
	tween.tween_property(target, property_name, flash_color, half_duration)
	tween.tween_property(target, property_name, original_color, half_duration)
	return tween.finished
