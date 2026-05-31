## 测试 GFInputDetector 的值类型过滤和倒计时检测。
extends GutTest


# --- 私有变量 ---

var _detector: GFInputDetector
var _received_event: InputEvent


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_received_event = null
	_detector = GFInputDetector.new()
	get_tree().root.add_child(_detector)
	var _connect_result_17: Variant = _detector.input_detected.connect(func(input_event: InputEvent) -> void:
		_received_event = input_event
	)


func after_each() -> void:
	if is_instance_valid(_detector):
		_detector.queue_free()
	_detector = null
	await get_tree().process_frame


# --- 测试方法 ---

## 验证轴检测会过滤非轴输入。
func test_axis_detection_ignores_bool_events() -> void:
	_detector.detect_axis_1d()

	_detector._input(_make_key_event(KEY_SPACE, true))
	assert_null(_received_event, "轴检测不应接受按键事件。")

	_detector._input(_make_joy_motion_event(JOY_AXIS_LEFT_X, 0.5))
	assert_not_null(_received_event, "轴检测应接受超过阈值的手柄轴事件。")
	assert_true(_received_event is InputEventJoypadMotion, "检测结果应保留原生轴事件类型。")


## 验证三维轴检测也接受手柄轴事件。
func test_axis_3d_detection_accepts_joy_motion() -> void:
	_detector.detect_axis_3d()

	_detector._input(_make_joy_motion_event(JOY_AXIS_RIGHT_Y, 0.6))

	assert_not_null(_received_event, "三维轴检测应接受超过阈值的手柄轴事件。")
	assert_true(_received_event is InputEventJoypadMotion, "检测结果应保留原生轴事件类型。")


## 验证倒计时结束前不会接收候选输入。
func test_countdown_delays_input_acceptance() -> void:
	_detector.countdown_seconds = 0.1
	_detector.begin_detection()

	_detector._input(_make_key_event(KEY_SPACE, true))
	assert_null(_received_event, "倒计时内输入不应被接收。")
	assert_true(_detector.is_detecting(), "倒计时内检测仍应进行。")
	assert_false(_detector.is_accepting_input(), "倒计时内不应处于接收状态。")

	_detector._process(0.11)
	_detector._input(_make_key_event(KEY_SPACE, true))

	assert_not_null(_received_event, "倒计时结束后应接收输入。")


## 验证无倒计时且无需清理时会立即进入接收状态。
func test_detection_state_reports_accepting_phase() -> void:
	_detector.countdown_seconds = 0.0
	_detector.wait_for_clear_before_detection = false

	_detector.begin_detection()

	assert_eq(_detector.get_detection_state(), GFInputDetector.DetectionState.DETECTING, "检测器应立即进入接收阶段。")
	assert_true(_detector.is_accepting_input(), "接收阶段应允许候选输入。")


# --- 私有/辅助方法 ---

func _make_key_event(key: Key, pressed: bool) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	return event


func _make_joy_motion_event(axis: JoyAxis, axis_value: float) -> InputEventJoypadMotion:
	var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	return event
