## 测试触屏控件默认不桥接项目级输入。
extends GutTest


func test_touch_button_mouse_and_action_bridges_are_opt_in_by_default() -> void:
	var button := GFTouchButton.new()
	add_child_autofree(button)

	assert_false(button.accept_mouse_input, "触屏按钮默认不应接管鼠标左键。")
	assert_eq(button.action_name, &"", "触屏按钮默认不应映射 InputMap 动作。")
	assert_false(button.emit_joypad_button, "触屏按钮默认不应发送虚拟手柄事件。")


func test_touch_joystick_action_bridges_are_opt_in_by_default() -> void:
	var joystick := GFTouchJoystick.new()
	add_child_autofree(joystick)

	assert_eq(joystick.action_left, &"", "触屏摇杆默认不应映射左方向动作。")
	assert_eq(joystick.action_right, &"", "触屏摇杆默认不应映射右方向动作。")
	assert_eq(joystick.action_up, &"", "触屏摇杆默认不应映射上方向动作。")
	assert_eq(joystick.action_down, &"", "触屏摇杆默认不应映射下方向动作。")
	assert_false(joystick.emit_joypad_motion, "触屏摇杆默认不应发送虚拟手柄轴事件。")
