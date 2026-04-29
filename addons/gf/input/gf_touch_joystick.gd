@tool

## GFTouchJoystick: 通用触屏虚拟摇杆节点。
##
## 可直接发出方向信号，也可选择映射到 Godot InputMap 动作。
class_name GFTouchJoystick
extends Node2D


# --- 信号 ---

## 摇杆方向变化时发出。方向已归一化并应用死区。
signal direction_changed(direction: Vector2)

## 摇杆按下时发出。
signal joystick_pressed

## 摇杆释放时发出。
signal joystick_released


# --- 导出变量 ---

@export_group("Shape")
## 摇杆半径。
@export var radius: float = 64.0:
	set(value):
		radius = maxf(value, 1.0)
		queue_redraw()

## 摇杆手柄半径比例。
@export_range(2.0, 8.0, 0.1) var knob_radius_ratio: float = 3.0:
	set(value):
		knob_radius_ratio = maxf(value, 1.0)
		queue_redraw()

## 摇杆颜色。
@export var color: Color = Color(1.0, 1.0, 1.0, 0.35):
	set(value):
		color = value
		queue_redraw()

@export_group("Input")
## 输入死区，范围 0 到 1。
@export_range(0.0, 0.95, 0.01) var deadzone: float = 0.1

## 左方向动作名。为空则不映射。
@export var action_left: StringName = &""

## 右方向动作名。为空则不映射。
@export var action_right: StringName = &""

## 上方向动作名。为空则不映射。
@export var action_up: StringName = &""

## 下方向动作名。为空则不映射。
@export var action_down: StringName = &""


# --- 私有变量 ---

var _active_touch_index: int = -1
var _knob_position: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO


# --- Godot 生命周期方法 ---

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_drag(event as InputEventScreenDrag)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color, false, 2.0, true)
	draw_circle(Vector2.ZERO, radius, Color(color, color.a * 0.35), true, -1.0, true)
	draw_circle(_knob_position, radius / knob_radius_ratio, color, true, -1.0, true)


# --- 公共方法 ---

## 获取当前方向。
## @return 当前摇杆方向。
func get_direction() -> Vector2:
	return _direction


## 手动释放摇杆并清理动作状态。
func release() -> void:
	_active_touch_index = -1
	_set_direction(Vector2.ZERO, Vector2.ZERO)
	joystick_released.emit()


# --- 私有/辅助方法 ---

func _handle_touch(event: InputEventScreenTouch) -> void:
	var local_pos := to_local(event.position)
	if event.pressed:
		if _active_touch_index == -1 and local_pos.length() <= radius:
			_active_touch_index = event.index
			joystick_pressed.emit()
			_update_from_local_position(local_pos)
	elif event.index == _active_touch_index:
		release()


func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index != _active_touch_index:
		return
	_update_from_local_position(to_local(event.position))


func _update_from_local_position(local_pos: Vector2) -> void:
	var knob_pos := local_pos.limit_length(radius)
	var raw_direction := knob_pos / radius
	var next_direction := raw_direction
	if next_direction.length() < deadzone:
		next_direction = Vector2.ZERO
	else:
		next_direction = next_direction.normalized()
	_set_direction(next_direction, knob_pos)


func _set_direction(next_direction: Vector2, knob_position: Vector2) -> void:
	if _direction == next_direction and _knob_position == knob_position:
		return
	_direction = next_direction
	_knob_position = knob_position
	_apply_input_actions(next_direction)
	direction_changed.emit(next_direction)
	queue_redraw()


func _apply_input_actions(direction: Vector2) -> void:
	_apply_axis_actions(direction.x, action_left, action_right)
	_apply_axis_actions(direction.y, action_up, action_down)


func _apply_axis_actions(value: float, negative_action: StringName, positive_action: StringName) -> void:
	if value < 0.0:
		_press_action(negative_action, absf(value))
		_release_action(positive_action)
	elif value > 0.0:
		_press_action(positive_action, absf(value))
		_release_action(negative_action)
	else:
		_release_action(negative_action)
		_release_action(positive_action)


func _press_action(action: StringName, strength: float) -> void:
	if action == &"":
		return
	Input.action_press(action, strength)


func _release_action(action: StringName) -> void:
	if action == &"":
		return
	Input.action_release(action)

