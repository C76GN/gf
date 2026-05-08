## 测试 GFInputBinding 的深拷贝、事件匹配与贡献值计算。
extends GutTest


const GFInputActionBase = preload("res://addons/gf/input/gf_input_action.gd")
const GFInputBindingBase = preload("res://addons/gf/input/gf_input_binding.gd")


func test_duplicate_binding_copies_fields_without_aliasing() -> void:
	var orig := GFInputBindingBase.new()
	var key := InputEventKey.new()
	key.keycode = KEY_F
	key.physical_keycode = KEY_NONE
	orig.input_event = key
	orig.scale = 2.0
	orig.remappable = false
	orig.match_touch_index = true
	var dup := orig.duplicate_binding() as GFInputBindingBase
	assert_ne(dup, orig, "duplicate_binding 应返回新实例。")
	dup.scale = 0.5
	assert_eq(orig.scale, 2.0, "修改拷贝不应影响原绑定的 scale。")
	var dup_key := dup.input_event as InputEventKey
	dup_key.keycode = KEY_G
	var orig_key := orig.input_event as InputEventKey
	assert_eq(orig_key.keycode, KEY_F, "input_event 应深拷贝。")


func test_matches_event_returns_false_when_template_or_event_null() -> void:
	var binding := GFInputBindingBase.new()
	var ev := InputEventKey.new()
	ev.keycode = KEY_A
	ev.pressed = true
	assert_false(binding.matches_event(ev), "未设置模板事件时不应匹配。")

	var template := InputEventKey.new()
	template.keycode = KEY_B
	binding.input_event = template
	assert_false(binding.matches_event(null), "运行时事件为 null 时不应匹配。")


func test_match_device_requires_same_device_id() -> void:
	var template := InputEventJoypadButton.new()
	template.device = 0
	template.button_index = JOY_BUTTON_A
	var binding := GFInputBindingBase.new()
	binding.input_event = template
	binding.match_device = true
	var other_device := InputEventJoypadButton.new()
	other_device.device = 1
	other_device.button_index = JOY_BUTTON_A
	assert_false(binding.matches_event(other_device), "设备 ID 不同时不应匹配。")
	other_device.device = 0
	assert_true(binding.matches_event(other_device), "设备与按键一致时应匹配。")


func test_match_touch_index_controls_screen_touch_index() -> void:
	var template := InputEventScreenTouch.new()
	template.index = 1
	var binding := GFInputBindingBase.new()
	binding.input_event = template
	binding.match_touch_index = false
	var ev := InputEventScreenTouch.new()
	ev.index = 2
	assert_true(binding.matches_event(ev), "关闭 index 精确匹配时应接受任意 index。")
	binding.match_touch_index = true
	assert_false(binding.matches_event(ev), "index 不同时不应匹配。")
	ev.index = 1
	assert_true(binding.matches_event(ev), "index 一致时应匹配。")


func test_get_display_name_respects_override() -> void:
	var binding := GFInputBindingBase.new()
	binding.display_name = "自定义跳跃"
	binding.input_event = InputEventKey.new()
	assert_eq(binding.get_display_name(), "自定义跳跃", "非空 display_name 应优先返回。")


func test_get_contribution_bool_respects_scale() -> void:
	var binding := GFInputBindingBase.new()
	var key := InputEventKey.new()
	key.keycode = KEY_X
	key.pressed = true
	binding.input_event = key
	binding.value_target = GFInputBindingBase.ValueTarget.BOOL
	binding.scale = 0.5
	var v := binding.get_contribution(key, GFInputActionBase.ValueType.BOOL)
	assert_almost_eq(v.x, 0.5, 0.0001, "BOOL 目标应将 scale 应用到 x 分量。")


func test_get_contribution_joy_axis_negative_target_uses_positive_magnitude() -> void:
	var binding := GFInputBindingBase.new()
	var template := InputEventJoypadMotion.new()
	template.axis = JOY_AXIS_LEFT_X
	binding.input_event = template
	binding.deadzone = 0.1
	binding.value_target = GFInputBindingBase.ValueTarget.AXIS_1D_NEGATIVE
	binding.scale = 1.0
	var motion := InputEventJoypadMotion.new()
	motion.axis = JOY_AXIS_LEFT_X
	motion.axis_value = -0.9
	var v := binding.get_contribution(motion, GFInputActionBase.ValueType.AXIS_1D)
	assert_almost_eq(v.x, -0.9, 0.0001, "负向轴绑定应将负轴量级写入负 x 分量。")
