## GFPointerActivityUtility: 通用指针活动状态工具。
##
## 由项目在 _input(event) 中显式转发事件，工具只维护按下、移动、拖拽和空闲状态，
## 不消费输入，也不绑定任何具体交互或业务对象。
class_name GFPointerActivityUtility
extends GFUtility


# --- 信号 ---

## 指针按下时发出。
signal pointer_pressed(pointer_id: int, position: Vector2, event: InputEvent)

## 指针释放时发出。
signal pointer_released(pointer_id: int, position: Vector2, event: InputEvent)

## 指针移动时发出。
signal pointer_moved(pointer_id: int, position: Vector2, previous_position: Vector2, event: InputEvent)

## 指针从按下状态进入拖拽时发出。
signal pointer_drag_started(pointer_id: int, start_position: Vector2, position: Vector2, event: InputEvent)

## 指针拖拽中发出。
signal pointer_dragged(pointer_id: int, position: Vector2, delta: Vector2, event: InputEvent)

## 指针拖拽结束时发出。
signal pointer_drag_ended(pointer_id: int, position: Vector2, event: InputEvent)

## 指针活动超过阈值后进入空闲时发出。
signal pointer_idle_started(pointer_id: int, position: Vector2)

## 指针从空闲恢复活动时发出。
signal pointer_idle_ended(pointer_id: int, position: Vector2)


# --- 公共变量 ---

## 是否追踪鼠标事件。
var track_mouse: bool = true

## 是否追踪触摸事件。
var track_touch: bool = true

## 鼠标模式下作为主指针的按钮。
var mouse_button_index: MouseButton = MOUSE_BUTTON_LEFT

## 从按下位置移动超过该距离后进入拖拽状态。
var drag_threshold_pixels: float = 8.0

## 无活动超过该秒数后进入空闲状态。
var idle_threshold_seconds: float = 0.5

## 当前是否有指针按下。
var is_pointer_pressed: bool = false

## 当前是否处于拖拽状态。
var is_pointer_dragging: bool = false

## 最近一帧是否收到指针活动。
var is_pointer_moving: bool = false

## 当前是否处于空闲状态。
var is_pointer_idle: bool = true

## 当前活动指针 ID；鼠标为 0，触摸为 InputEventScreenTouch.index。
var active_pointer_id: int = -1

## 最近发生活动的指针 ID。
var last_pointer_id: int = -1

## 最近按下位置。
var press_position: Vector2 = Vector2.ZERO

## 最近指针位置。
var last_position: Vector2 = Vector2.ZERO


# --- 私有变量 ---

var _idle_elapsed_seconds: float = 0.0


# --- 公共方法 ---

## 处理一个输入事件。
## @param event: 输入事件。
## @return 识别为受追踪指针事件时返回 true。
func handle_input_event(event: InputEvent) -> bool:
	if event == null:
		return false
	if track_mouse and event is InputEventMouseButton:
		return _handle_mouse_button(event as InputEventMouseButton)
	if track_mouse and event is InputEventMouseMotion:
		return _handle_mouse_motion(event as InputEventMouseMotion)
	if track_touch and event is InputEventScreenTouch:
		return _handle_screen_touch(event as InputEventScreenTouch)
	if track_touch and event is InputEventScreenDrag:
		return _handle_screen_drag(event as InputEventScreenDrag)
	return false


## 推进空闲计时。通常在 tick(delta) 或 _process(delta) 中调用。
## @param delta: 秒。
func tick(delta: float) -> void:
	var safe_delta := maxf(delta, 0.0)
	if is_pointer_moving:
		is_pointer_moving = false
		_idle_elapsed_seconds = 0.0
		return

	_idle_elapsed_seconds += safe_delta
	if not is_pointer_idle and _idle_elapsed_seconds >= maxf(idle_threshold_seconds, 0.0):
		is_pointer_idle = true
		pointer_idle_started.emit(last_pointer_id, last_position)


## 清理所有指针活动状态。
func reset_activity() -> void:
	is_pointer_pressed = false
	is_pointer_dragging = false
	is_pointer_moving = false
	is_pointer_idle = true
	active_pointer_id = -1
	last_pointer_id = -1
	press_position = Vector2.ZERO
	last_position = Vector2.ZERO
	_idle_elapsed_seconds = 0.0


## 获取调试快照。
## @return 当前指针状态。
func get_debug_snapshot() -> Dictionary:
	return {
		"active_pointer_id": active_pointer_id,
		"last_pointer_id": last_pointer_id,
		"is_pointer_pressed": is_pointer_pressed,
		"is_pointer_dragging": is_pointer_dragging,
		"is_pointer_moving": is_pointer_moving,
		"is_pointer_idle": is_pointer_idle,
		"press_position": press_position,
		"last_position": last_position,
		"idle_elapsed_seconds": _idle_elapsed_seconds,
		"drag_threshold_pixels": drag_threshold_pixels,
		"idle_threshold_seconds": idle_threshold_seconds,
	}


# --- 私有/辅助方法 ---

func _handle_mouse_button(event: InputEventMouseButton) -> bool:
	if event.button_index != mouse_button_index:
		return false
	if event.pressed:
		_press_pointer(0, event.position, event)
	else:
		_release_pointer(0, event.position, event)
	return true


func _handle_mouse_motion(event: InputEventMouseMotion) -> bool:
	_move_pointer(0, event.position, event)
	return true


func _handle_screen_touch(event: InputEventScreenTouch) -> bool:
	if event.pressed:
		if active_pointer_id != -1 and active_pointer_id != event.index:
			return false
		_press_pointer(event.index, event.position, event)
	else:
		if active_pointer_id != event.index:
			return false
		_release_pointer(event.index, event.position, event)
	return true


func _handle_screen_drag(event: InputEventScreenDrag) -> bool:
	if active_pointer_id != -1 and active_pointer_id != event.index:
		return false
	_move_pointer(event.index, event.position, event)
	return true


func _press_pointer(pointer_id: int, position: Vector2, event: InputEvent) -> void:
	active_pointer_id = pointer_id
	is_pointer_pressed = true
	is_pointer_dragging = false
	press_position = position
	last_position = position
	_mark_pointer_activity(pointer_id, position)
	pointer_pressed.emit(pointer_id, position, event)


func _release_pointer(pointer_id: int, position: Vector2, event: InputEvent) -> void:
	if active_pointer_id != -1 and active_pointer_id != pointer_id:
		return

	_mark_pointer_activity(pointer_id, position)
	last_position = position
	if is_pointer_dragging:
		pointer_drag_ended.emit(pointer_id, position, event)
	is_pointer_pressed = false
	is_pointer_dragging = false
	active_pointer_id = -1
	pointer_released.emit(pointer_id, position, event)


func _move_pointer(pointer_id: int, position: Vector2, event: InputEvent) -> void:
	if active_pointer_id != -1 and active_pointer_id != pointer_id:
		return

	var previous_position := last_position
	last_position = position
	_mark_pointer_activity(pointer_id, position)
	pointer_moved.emit(pointer_id, position, previous_position, event)

	if not is_pointer_pressed:
		return

	var drag_distance := press_position.distance_to(position)
	if not is_pointer_dragging and drag_distance >= maxf(drag_threshold_pixels, 0.0):
		is_pointer_dragging = true
		pointer_drag_started.emit(pointer_id, press_position, position, event)
	if is_pointer_dragging:
		pointer_dragged.emit(pointer_id, position, position - previous_position, event)


func _mark_pointer_activity(pointer_id: int, position: Vector2) -> void:
	var was_idle := is_pointer_idle
	last_pointer_id = pointer_id
	is_pointer_moving = true
	is_pointer_idle = false
	_idle_elapsed_seconds = 0.0
	if was_idle:
		pointer_idle_ended.emit(pointer_id, position)
