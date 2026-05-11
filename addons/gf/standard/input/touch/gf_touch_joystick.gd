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


# --- 枚举 ---

## 摇杆定位模式。
enum PositionMode {
	## 摇杆中心保持在场景中摆放的位置。
	FIXED,
	## 初次触摸时摇杆中心移动到触点，释放后回到原位置。
	RELATIVE,
}


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

## 是否绘制相对摇杆交互范围。
@export var draw_interaction_zone: bool = false:
	set(value):
		draw_interaction_zone = value
		queue_redraw()

@export_group("Input")
## 输入死区，范围 0 到 1。
@export_range(0.0, 0.95, 0.01) var deadzone: float = 0.1

## 摇杆定位模式。
@export var position_mode: PositionMode = PositionMode.FIXED:
	set(value):
		position_mode = value
		queue_redraw()

## 相对模式下允许开始触控的交互半径。
@export var interaction_radius: float = 160.0:
	set(value):
		interaction_radius = maxf(value, radius)
		queue_redraw()

## 左方向动作名。为空则不映射。
@export var action_left: StringName = &""

## 右方向动作名。为空则不映射。
@export var action_right: StringName = &""

## 上方向动作名。为空则不映射。
@export var action_up: StringName = &""

## 下方向动作名。为空则不映射。
@export var action_down: StringName = &""

@export_group("Joypad Event")
## 是否额外发送虚拟手柄轴事件。
@export var emit_joypad_motion: bool = false

## 虚拟手柄设备 ID。建议使用负数以避开真实手柄。
@export var joypad_device_id: int = -2

## X 轴对应的手柄轴。
@export var joy_axis_x: JoyAxis = JOY_AXIS_LEFT_X

## Y 轴对应的手柄轴。
@export var joy_axis_y: JoyAxis = JOY_AXIS_LEFT_Y


# --- 私有变量 ---

var _active_touch_index: int = -1
var _knob_position: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO
var _rest_global_position: Vector2 = Vector2.ZERO


# --- Godot 生命周期方法 ---

func _ready() -> void:
	_rest_global_position = global_position


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_drag(event as InputEventScreenDrag)


func _draw() -> void:
	if draw_interaction_zone and position_mode == PositionMode.RELATIVE:
		draw_circle(Vector2.ZERO, interaction_radius, Color(color, color.a * 0.35), false, 1.0, true)
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
	if position_mode == PositionMode.RELATIVE:
		global_position = _rest_global_position
	joystick_released.emit()


# --- 私有/辅助方法 ---

func _handle_touch(event: InputEventScreenTouch) -> void:
	var global_pos := _screen_to_global_position(event.position)
	var local_pos := to_local(global_pos)
	if event.pressed:
		if _active_touch_index == -1 and _can_begin_at(local_pos):
			_begin_touch(event.index, global_pos, local_pos)
	elif event.index == _active_touch_index:
		release()


func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index != _active_touch_index:
		return
	_update_from_local_position(to_local(_screen_to_global_position(event.position)))


func _begin_touch(touch_index: int, global_pos: Vector2, local_pos: Vector2) -> void:
	_active_touch_index = touch_index
	if position_mode == PositionMode.RELATIVE:
		global_position = global_pos
		local_pos = Vector2.ZERO
	_knob_position = Vector2.ZERO
	joystick_pressed.emit()
	_update_from_local_position(local_pos)


func _can_begin_at(local_pos: Vector2) -> bool:
	if position_mode == PositionMode.RELATIVE:
		return local_pos.length() <= interaction_radius
	return local_pos.length() <= radius


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
	_emit_joypad_motion(direction)


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


func _emit_joypad_motion(direction: Vector2) -> void:
	if not emit_joypad_motion:
		return

	_emit_joypad_axis(joy_axis_x, direction.x)
	_emit_joypad_axis(joy_axis_y, direction.y)


func _emit_joypad_axis(axis: JoyAxis, value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = joypad_device_id
	event.axis = axis
	event.axis_value = clampf(value, -1.0, 1.0)
	Input.parse_input_event(event)


func _screen_to_global_position(screen_position: Vector2) -> Vector2:
	var viewport := get_viewport()
	if viewport == null:
		return screen_position
	return viewport.get_canvas_transform().affine_inverse() * screen_position
