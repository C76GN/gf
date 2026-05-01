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


# --- 常量 ---

const GFInputActionBase = preload("res://addons/gf/input/gf_input_action.gd")
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


# --- 私有变量 ---

var _is_detecting: bool = false
var _elapsed: float = 0.0
var _countdown_remaining: float = 0.0
var _value_type: int = _ANY_VALUE_TYPE
var _allowed_device_types: Array[int] = []


# --- Godot 生命周期方法 ---

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)


func _input(event: InputEvent) -> void:
	if not _is_detecting:
		return
	if _should_ignore_event(event):
		return
	if _matches_abort_event(event):
		cancel_detection()
		get_viewport().set_input_as_handled()
		return
	if _countdown_remaining > 0.0:
		return
	if not _matches_device_filter(event):
		return
	if not _matches_value_type_filter(event):
		return

	_finish_detection(event.duplicate(true) as InputEvent)
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not _is_detecting:
		return

	var safe_delta := maxf(delta, 0.0)
	if _countdown_remaining > 0.0:
		_countdown_remaining = maxf(_countdown_remaining - safe_delta, 0.0)
		if _countdown_remaining <= 0.0 and timeout_seconds <= 0.0:
			set_process(false)
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


## 是否已经结束倒计时并正在接收候选输入。
## @return 是否可接收输入。
func is_accepting_input() -> bool:
	return _is_detecting and _countdown_remaining <= 0.0


## 取消检测。
func cancel_detection() -> void:
	if not _is_detecting:
		return
	_finish_detection(null)


## 检查当前是否正在检测。
## @return 是否正在检测。
func is_detecting() -> bool:
	return _is_detecting


# --- 私有/辅助方法 ---

func _begin_detection_internal(value_type: int, allowed_device_types: Array[int]) -> void:
	_allowed_device_types = allowed_device_types.duplicate()
	_elapsed = 0.0
	_countdown_remaining = maxf(countdown_seconds, 0.0)
	_value_type = value_type
	_is_detecting = true
	set_process(timeout_seconds > 0.0 or _countdown_remaining > 0.0)
	detection_started.emit()


func _finish_detection(input_event: InputEvent) -> void:
	_is_detecting = false
	_elapsed = 0.0
	_countdown_remaining = 0.0
	_value_type = _ANY_VALUE_TYPE
	set_process(false)
	input_detected.emit(input_event)


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
