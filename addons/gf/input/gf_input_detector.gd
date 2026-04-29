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


# --- 导出变量 ---

## 是否忽略键盘 echo 事件。
@export var ignore_echo: bool = true

## 轴输入检测阈值。
@export_range(0.0, 1.0, 0.01) var minimum_axis_amplitude: float = 0.25

## 检测超时时间。小于等于 0 表示不超时。
@export var timeout_seconds: float = 0.0

## 取消检测的输入事件列表。
@export var abort_events: Array[InputEvent] = []


# --- 私有变量 ---

var _is_detecting: bool = false
var _elapsed: float = 0.0
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
	if not _matches_device_filter(event):
		return

	_finish_detection(event.duplicate(true) as InputEvent)
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not _is_detecting or timeout_seconds <= 0.0:
		return

	_elapsed += delta
	if _elapsed >= timeout_seconds:
		cancel_detection()


# --- 公共方法 ---

## 开始检测下一次输入。
## @param allowed_device_types: 允许的设备类型。空数组表示不限制。
func begin_detection(allowed_device_types: Array[int] = []) -> void:
	_allowed_device_types = allowed_device_types.duplicate()
	_elapsed = 0.0
	_is_detecting = true
	set_process(timeout_seconds > 0.0)
	detection_started.emit()


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

func _finish_detection(input_event: InputEvent) -> void:
	_is_detecting = false
	_elapsed = 0.0
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
