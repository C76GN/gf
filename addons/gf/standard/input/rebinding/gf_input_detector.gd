## GFInputDetector: 检测下一次输入事件的辅助节点。
##
## 可用于项目自己的改键界面。检测结果只返回 Godot InputEvent，冲突处理由项目层决定。
class_name GFInputDetector
extends Node


# --- 信号 ---

## 开始检测时发出。
signal detection_started

## 检测结束时发出。input_event 为 null 表示取消或超时。
signal input_detected(input_event: InputEvent)


# --- 枚举 ---

## 设备过滤类型。
enum DeviceType {
	KEYBOARD,
	MOUSE,
	JOYPAD,
	TOUCH,
}

## 检测阶段。
enum DetectionState {
	## 未检测。
	IDLE,
	## 倒计时中。
	COUNTDOWN,
	## 等待取消输入释放。
	PRE_CLEAR,
	## 正在接收候选输入。
	DETECTING,
	## 等待检测到的输入释放。
	POST_CLEAR,
}


# --- 常量 ---

const GFInputActionBase = preload("res://addons/gf/standard/input/mapping/gf_input_action.gd")
const _ANY_VALUE_TYPE: int = -1


# --- 导出变量 ---

## 是否忽略键盘 echo 事件。
@export var ignore_echo: bool = true

## 轴输入检测阈值。
@export_range(0.0, 1.0, 0.01) var minimum_axis_amplitude: float = 0.25

## 正式接收输入前的倒计时。可用于改键界面避开确认按钮本身。
@export var countdown_seconds: float = 0.0

## 检测超时时间。小于等于 0 表示不超时。
@export var timeout_seconds: float = 0.0

## 取消检测的输入事件列表。
@export var abort_events: Array[InputEvent] = []

## 开始正式检测前，是否等待 abort_events 中仍按住的输入释放。
@export var wait_for_clear_before_detection: bool = true

## 检测到输入后，是否等待该输入释放再发出 input_detected。
@export var wait_for_clear_after_detection: bool = false


# --- 私有变量 ---

var _state: DetectionState = DetectionState.IDLE
var _elapsed: float = 0.0
var _countdown_remaining: float = 0.0
var _value_type: int = _ANY_VALUE_TYPE
var _allowed_device_types: Array[int] = []
var _pending_detected_event: InputEvent = null


# --- Godot 生命周期方法 ---

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)


func _input(event: InputEvent) -> void:
	if _state == DetectionState.IDLE:
		return
	if _should_ignore_event(event):
		return
	if _state == DetectionState.PRE_CLEAR:
		if _are_abort_events_released():
			_start_accepting_input()
		return
	if _state == DetectionState.POST_CLEAR:
		if _pending_detected_event == null or not _is_event_still_pressed(_pending_detected_event):
			_emit_detected_input()
		return
	if _state != DetectionState.DETECTING:
		return
	if _matches_abort_event(event):
		cancel_detection()
		get_viewport().set_input_as_handled()
		return
	if not _matches_device_filter(event):
		return
	if not _matches_value_type_filter(event):
		return

	_finish_detection(event.duplicate(true) as InputEvent, wait_for_clear_after_detection)
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _state == DetectionState.IDLE:
		return

	var safe_delta := maxf(delta, 0.0)
	if _state == DetectionState.COUNTDOWN:
		_countdown_remaining = maxf(_countdown_remaining - safe_delta, 0.0)
		if _countdown_remaining <= 0.0:
			_enter_pre_clear_or_detecting()
		return

	if _state == DetectionState.PRE_CLEAR:
		if _are_abort_events_released():
			_start_accepting_input()
		return

	if _state == DetectionState.POST_CLEAR:
		if _pending_detected_event == null or not _is_event_still_pressed(_pending_detected_event):
			_emit_detected_input()
		return

	if timeout_seconds <= 0.0:
		return

	_elapsed += safe_delta
	if _elapsed >= timeout_seconds:
		cancel_detection()


# --- 公共方法 ---

## 开始检测下一次输入。
## @param allowed_device_types: 允许的设备类型。空数组表示不限制。
func begin_detection(allowed_device_types: Array[int] = []) -> void:
	_begin_detection_internal(_ANY_VALUE_TYPE, allowed_device_types)


## 按动作值类型开始检测下一次输入。
## @param value_type: 期望的动作值类型。
## @param allowed_device_types: 允许的设备类型。空数组表示不限制。
func begin_detection_for_value_type(
	value_type: GFInputActionBase.ValueType,
	allowed_device_types: Array[int] = []
) -> void:
	_begin_detection_internal(value_type, allowed_device_types)


## 按动作资源开始检测下一次输入。
## @param action: 输入动作资源。
## @param allowed_device_types: 允许的设备类型。空数组表示不限制。
func begin_detection_for_action(
	action: GFInputActionBase,
	allowed_device_types: Array[int] = []
) -> void:
	if action == null:
		begin_detection(allowed_device_types)
		return

	begin_detection_for_value_type(action.value_type, allowed_device_types)


## 开始检测布尔输入。
## @param allowed_device_types: 允许的设备类型。空数组表示不限制。
func detect_bool(allowed_device_types: Array[int] = []) -> void:
	begin_detection_for_value_type(GFInputActionBase.ValueType.BOOL, allowed_device_types)


## 开始检测一维轴输入。
## @param allowed_device_types: 允许的设备类型。空数组表示不限制。
func detect_axis_1d(allowed_device_types: Array[int] = []) -> void:
	begin_detection_for_value_type(GFInputActionBase.ValueType.AXIS_1D, allowed_device_types)


## 开始检测二维轴输入。
## @param allowed_device_types: 允许的设备类型。空数组表示不限制。
func detect_axis_2d(allowed_device_types: Array[int] = []) -> void:
	begin_detection_for_value_type(GFInputActionBase.ValueType.AXIS_2D, allowed_device_types)


## 开始检测三维轴输入。
## @param allowed_device_types: 允许的设备类型。空数组表示不限制。
func detect_axis_3d(allowed_device_types: Array[int] = []) -> void:
	begin_detection_for_value_type(GFInputActionBase.ValueType.AXIS_3D, allowed_device_types)


## 获取正式接收输入前剩余的倒计时秒数。
## @return 剩余秒数。
func get_countdown_remaining() -> float:
	return _countdown_remaining


## 获取当前检测阶段。
## @return 检测阶段。
func get_detection_state() -> DetectionState:
	return _state


## 是否已经结束倒计时并正在接收候选输入。
## @return 是否可接收输入。
func is_accepting_input() -> bool:
	return _state == DetectionState.DETECTING


## 取消检测。
func cancel_detection() -> void:
	if _state == DetectionState.IDLE:
		return
	_finish_detection(null, false)


## 检查当前是否正在检测。
## @return 是否正在检测。
func is_detecting() -> bool:
	return _state != DetectionState.IDLE


# --- 私有/辅助方法 ---

func _begin_detection_internal(value_type: int, allowed_device_types: Array[int]) -> void:
	_allowed_device_types = allowed_device_types.duplicate()
	_elapsed = 0.0
	_countdown_remaining = maxf(countdown_seconds, 0.0)
	_value_type = value_type
	_pending_detected_event = null
	_state = DetectionState.COUNTDOWN if _countdown_remaining > 0.0 else DetectionState.PRE_CLEAR
	if _state == DetectionState.PRE_CLEAR:
		_enter_pre_clear_or_detecting()
	set_process(_state != DetectionState.DETECTING or timeout_seconds > 0.0)
	detection_started.emit()


func _finish_detection(input_event: InputEvent, wait_for_release: bool) -> void:
	if input_event != null and wait_for_release and _is_event_still_pressed(input_event):
		_pending_detected_event = input_event
		_state = DetectionState.POST_CLEAR
		set_process(true)
		return

	_pending_detected_event = input_event
	_emit_detected_input()


func _emit_detected_input() -> void:
	var input_event := _pending_detected_event
	_state = DetectionState.IDLE
	_elapsed = 0.0
	_countdown_remaining = 0.0
	_value_type = _ANY_VALUE_TYPE
	_pending_detected_event = null
	set_process(false)
	input_detected.emit(input_event)


func _enter_pre_clear_or_detecting() -> void:
	if wait_for_clear_before_detection and not _are_abort_events_released():
		_state = DetectionState.PRE_CLEAR
		set_process(true)
		return
	_start_accepting_input()


func _start_accepting_input() -> void:
	_state = DetectionState.DETECTING
	set_process(timeout_seconds > 0.0)


func _should_ignore_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return ignore_echo and key_event.echo
	if event is InputEventJoypadMotion:
		return absf((event as InputEventJoypadMotion).axis_value) < minimum_axis_amplitude
	return false


func _matches_abort_event(event: InputEvent) -> bool:
	for abort_event: InputEvent in abort_events:
		if abort_event != null and abort_event.is_match(event, true):
			return true
	return false


func _are_abort_events_released() -> bool:
	for abort_event: InputEvent in abort_events:
		if abort_event != null and _is_event_still_pressed(abort_event):
			return false
	return true


func _is_event_still_pressed(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.physical_keycode != KEY_NONE:
			return Input.is_physical_key_pressed(key_event.physical_keycode)
		return key_event.keycode != KEY_NONE and Input.is_key_pressed(key_event.keycode)
	if event is InputEventMouseButton:
		return Input.is_mouse_button_pressed((event as InputEventMouseButton).button_index)
	if event is InputEventJoypadButton:
		var joy_button := event as InputEventJoypadButton
		return Input.is_joy_button_pressed(joy_button.device, joy_button.button_index)
	if event is InputEventJoypadMotion:
		var joy_motion := event as InputEventJoypadMotion
		return absf(Input.get_joy_axis(joy_motion.device, joy_motion.axis)) >= minimum_axis_amplitude
	if event is InputEventAction:
		return Input.is_action_pressed((event as InputEventAction).action)
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	return false


func _matches_device_filter(event: InputEvent) -> bool:
	if _allowed_device_types.is_empty():
		return true

	var device_type := _get_event_device_type(event)
	return device_type != -1 and _allowed_device_types.has(device_type)


func _matches_value_type_filter(event: InputEvent) -> bool:
	if _value_type == _ANY_VALUE_TYPE:
		return true

	match _value_type:
		GFInputActionBase.ValueType.BOOL:
			return _is_bool_event(event)
		GFInputActionBase.ValueType.AXIS_1D, GFInputActionBase.ValueType.AXIS_2D, GFInputActionBase.ValueType.AXIS_3D:
			return event is InputEventJoypadMotion
		_:
			return true


func _is_bool_event(event: InputEvent) -> bool:
	if event is InputEventAction:
		return (event as InputEventAction).pressed
	if event is InputEventKey:
		return (event as InputEventKey).pressed
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).pressed
	if event is InputEventJoypadButton:
		return (event as InputEventJoypadButton).pressed
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	return false


func _get_event_device_type(event: InputEvent) -> int:
	if event is InputEventKey:
		return DeviceType.KEYBOARD
	if event is InputEventMouse:
		return DeviceType.MOUSE
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return DeviceType.JOYPAD
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return DeviceType.TOUCH
	return -1
