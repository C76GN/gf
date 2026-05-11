@tool

## GFTouchButton: 通用触屏虚拟按钮节点。
##
## 可直接发送按下/释放信号，也可映射到 Godot InputMap 动作或虚拟手柄按钮事件。
class_name GFTouchButton
extends Node2D


# --- 信号 ---

## 按钮按下时发出。
signal button_pressed

## 按钮释放时发出。
signal button_released


# --- 导出变量 ---

@export_group("Shape")
## 按钮半径。
@export var radius: float = 48.0:
	set(value):
		radius = maxf(value, 1.0)
		queue_redraw()

## 按钮常态颜色。
@export var color: Color = Color(1.0, 1.0, 1.0, 0.3):
	set(value):
		color = value
		queue_redraw()

## 按钮按下颜色。
@export var pressed_color: Color = Color(1.0, 1.0, 1.0, 0.65):
	set(value):
		pressed_color = value
		queue_redraw()

@export_group("Input")
## 是否允许鼠标左键模拟触屏。
@export var accept_mouse_input: bool = true

## 映射到 Godot InputMap 的动作名。为空则不映射。
@export var action_name: StringName = &""

@export_group("Joypad Event")
## 是否额外发送虚拟手柄按钮事件。
@export var emit_joypad_button: bool = false

## 虚拟手柄设备 ID。建议使用负数以避开真实手柄。
@export var joypad_device_id: int = -2

## 对应的手柄按钮。
@export var joy_button: JoyButton = JOY_BUTTON_A


# --- 私有变量 ---

var _active_touch_index: int = -1
var _mouse_pressed_inside: bool = false
var _pressed: bool = false


# --- Godot 生命周期方法 ---

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_drag(event as InputEventScreenDrag)
	elif accept_mouse_input and event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif accept_mouse_input and event is InputEventMouseMotion:
		_handle_mouse_motion(event as InputEventMouseMotion)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, pressed_color if _pressed else color, true, -1.0, true)
	draw_circle(Vector2.ZERO, radius, Color(color, minf(color.a + 0.25, 1.0)), false, 2.0, true)


# --- 公共方法 ---

## 检查按钮是否处于按下状态。
## @return 是否按下。
func is_pressed() -> bool:
	return _pressed


## 手动释放按钮。
func release() -> void:
	_active_touch_index = -1
	_mouse_pressed_inside = false
	_set_pressed(false)


# --- 私有/辅助方法 ---

func _handle_touch(event: InputEventScreenTouch) -> void:
	var local_pos := to_local(_screen_to_global_position(event.position))
	if event.pressed:
		if _active_touch_index == -1 and local_pos.length() <= radius:
			_active_touch_index = event.index
			_set_pressed(true)
			get_viewport().set_input_as_handled()
	elif event.index == _active_touch_index:
		release()
		get_viewport().set_input_as_handled()


func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index != _active_touch_index:
		return

	var local_pos := to_local(_screen_to_global_position(event.position))
	if local_pos.length() > radius:
		release()
	get_viewport().set_input_as_handled()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	var local_pos := to_local(_screen_to_global_position(event.position))
	if event.pressed:
		_mouse_pressed_inside = local_pos.length() <= radius
		if _mouse_pressed_inside:
			_set_pressed(true)
			get_viewport().set_input_as_handled()
	else:
		if _mouse_pressed_inside:
			release()
			get_viewport().set_input_as_handled()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not _mouse_pressed_inside:
		return

	var local_pos := to_local(_screen_to_global_position(event.position))
	if local_pos.length() > radius:
		release()
	get_viewport().set_input_as_handled()


func _set_pressed(next_pressed: bool) -> void:
	if _pressed == next_pressed:
		return

	_pressed = next_pressed
	_apply_input_action(next_pressed)
	_emit_joypad_button(next_pressed)
	if next_pressed:
		button_pressed.emit()
	else:
		button_released.emit()
	queue_redraw()


func _apply_input_action(pressed: bool) -> void:
	if action_name == &"":
		return
	if pressed:
		Input.action_press(action_name)
	else:
		Input.action_release(action_name)


func _emit_joypad_button(pressed: bool) -> void:
	if not emit_joypad_button:
		return

	var event := InputEventJoypadButton.new()
	event.device = joypad_device_id
	event.button_index = joy_button
	event.pressed = pressed
	event.pressure = 1.0 if pressed else 0.0
	Input.parse_input_event(event)


func _screen_to_global_position(screen_position: Vector2) -> Vector2:
	var viewport := get_viewport()
	if viewport == null:
		return screen_position
	return viewport.get_canvas_transform().affine_inverse() * screen_position
