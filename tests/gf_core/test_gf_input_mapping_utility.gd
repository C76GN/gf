## 测试 GFInputMappingUtility 的资源化输入上下文、重映射和动作状态行为。
extends GutTest


# --- 常量 ---

const GFInputActionBase = preload("res://addons/gf/input/gf_input_action.gd")
const GFInputBindingBase = preload("res://addons/gf/input/gf_input_binding.gd")
const GFInputContextBase = preload("res://addons/gf/input/gf_input_context.gd")
const GFInputFormatterBase = preload("res://addons/gf/input/gf_input_formatter.gd")
const GFInputMappingBase = preload("res://addons/gf/input/gf_input_mapping.gd")
const GFInputMappingUtilityBase = preload("res://addons/gf/utilities/gf_input_mapping_utility.gd")


# --- 私有变量 ---

var _utility: GFInputMappingUtilityBase


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_utility = GFInputMappingUtilityBase.new()
	_utility.init()


func after_each() -> void:
	if _utility != null:
		_utility.dispose()
		_utility = null
	await get_tree().process_frame


# --- 测试方法 ---

## 验证布尔动作可由按键事件激活、消费并释放。
func test_bool_action_press_consume_and_release() -> void:
	var context := _make_context(&"gameplay", [
		_make_mapping(_make_action(&"jump"), [
			_make_key_binding(KEY_SPACE),
		]),
	])

	_utility.enable_context(context)
	_utility.handle_input_event(_make_key_event(KEY_SPACE, true))

	assert_true(_utility.is_action_active(&"jump"), "按下绑定按键后动作应活跃。")
	assert_true(_utility.was_action_just_started(&"jump"), "首次按下应记录 just started。")
	assert_true(_utility.consume_action(&"jump"), "刚触发动作应可被消费。")
	assert_false(_utility.consume_action(&"jump"), "同一次触发不应被重复消费。")

	_utility.handle_input_event(_make_key_event(KEY_SPACE, false))

	assert_false(_utility.is_action_active(&"jump"), "释放按键后动作应结束。")


## 验证上下文优先级可以阻断较低优先级的同输入动作。
func test_higher_priority_context_blocks_lower_priority_same_input() -> void:
	var high_context := _make_context(&"menu", [
		_make_mapping(_make_action(&"confirm"), [
			_make_key_binding(KEY_E),
		]),
	])
	var low_context := _make_context(&"gameplay", [
		_make_mapping(_make_action(&"interact"), [
			_make_key_binding(KEY_E),
		]),
	])

	_utility.enable_context(low_context, 0)
	_utility.enable_context(high_context, 10)
	_utility.handle_input_event(_make_key_event(KEY_E, true))

	assert_true(_utility.is_action_active(&"confirm"), "高优先级动作应触发。")
	assert_false(_utility.is_action_active(&"interact"), "低优先级同输入动作应被阻断。")


## 验证运行时重绑定覆盖默认输入。
func test_remap_override_replaces_default_binding() -> void:
	var context := _make_context(&"gameplay", [
		_make_mapping(_make_action(&"jump"), [
			_make_key_binding(KEY_SPACE),
		]),
	])

	_utility.enable_context(context)
	_utility.set_binding_override(&"gameplay", &"jump", 0, _make_key_event(KEY_ENTER, true))

	_utility.handle_input_event(_make_key_event(KEY_SPACE, true))
	assert_false(_utility.is_action_active(&"jump"), "默认绑定被覆盖后不应再触发。")

	_utility.handle_input_event(_make_key_event(KEY_ENTER, true))
	assert_true(_utility.is_action_active(&"jump"), "覆盖后的绑定应触发动作。")


## 验证二维轴动作会合并多个数字输入方向。
func test_axis_2d_action_combines_directional_bindings() -> void:
	var action := _make_action(&"move", GFInputActionBase.ValueType.AXIS_2D)
	action.activation_threshold = 0.1
	var context := _make_context(&"gameplay", [
		_make_mapping(action, [
			_make_key_binding(KEY_A, GFInputBindingBase.ValueTarget.AXIS_2D_X_NEGATIVE),
			_make_key_binding(KEY_D, GFInputBindingBase.ValueTarget.AXIS_2D_X_POSITIVE),
			_make_key_binding(KEY_W, GFInputBindingBase.ValueTarget.AXIS_2D_Y_NEGATIVE),
			_make_key_binding(KEY_S, GFInputBindingBase.ValueTarget.AXIS_2D_Y_POSITIVE),
		]),
	])

	_utility.enable_context(context)
	_utility.handle_input_event(_make_key_event(KEY_D, true))
	_utility.handle_input_event(_make_key_event(KEY_S, true))

	var value := _utility.get_action_value(&"move") as Vector2
	assert_gt(value.x, 0.0, "D 键应贡献 X 正向。")
	assert_gt(value.y, 0.0, "S 键应贡献 Y 正向。")
	assert_true(_utility.is_action_active(&"move"), "轴值超过阈值时动作应活跃。")


## 验证手柄轴正负向绑定会按轴值符号过滤。
func test_joy_axis_directional_binding_respects_axis_sign() -> void:
	var action := _make_action(&"look_x", GFInputActionBase.ValueType.AXIS_1D)
	action.activation_threshold = 0.1
	var context := _make_context(&"gameplay", [
		_make_mapping(action, [
			_make_joy_axis_binding(JOY_AXIS_LEFT_X, GFInputBindingBase.ValueTarget.AXIS_1D_POSITIVE),
		]),
	])

	_utility.enable_context(context)
	_utility.handle_input_event(_make_joy_motion_event(JOY_AXIS_LEFT_X, -0.8))

	assert_eq(_utility.get_action_value(&"look_x"), 0.0, "负向轴值不应触发正向绑定。")
	assert_false(_utility.is_action_active(&"look_x"), "符号不匹配时动作应保持非活跃。")

	_utility.handle_input_event(_make_joy_motion_event(JOY_AXIS_LEFT_X, 0.8))

	assert_gt(float(_utility.get_action_value(&"look_x")), 0.0, "正向轴值应触发正向绑定。")
	assert_true(_utility.is_action_active(&"look_x"), "符号匹配且超过阈值时动作应活跃。")


## 验证可重绑条目会返回上下文、动作和有效事件。
func test_get_remappable_items_returns_effective_event() -> void:
	var context := _make_context(&"gameplay", [
		_make_mapping(_make_action(&"jump"), [
			_make_key_binding(KEY_SPACE),
		]),
	])

	_utility.enable_context(context)
	_utility.set_binding_override(&"gameplay", &"jump", 0, _make_key_event(KEY_ENTER, true))
	var items := _utility.get_remappable_items()

	assert_eq(items.size(), 1, "应返回一个可重绑条目。")
	assert_eq(items[0]["context_id"], &"gameplay", "条目应包含上下文标识。")
	assert_eq(items[0]["action_id"], &"jump", "条目应包含动作标识。")
	assert_eq(GFInputFormatterBase.input_event_as_text(items[0]["event"] as InputEvent), "Enter", "条目应使用重映射后的事件。")


## 验证格式化工具可以输出组合键文本。
func test_input_formatter_formats_key_modifiers() -> void:
	var event := _make_key_event(KEY_K, true)
	event.ctrl_pressed = true
	event.shift_pressed = true

	assert_eq(GFInputFormatterBase.input_event_as_text(event), "Ctrl + Shift + K", "组合键文本应稳定。")


## 验证延迟挂载在 Utility 销毁后不会留下输入路由节点。
func test_deferred_router_attach_is_canceled_after_dispose() -> void:
	_utility.dispose()
	await get_tree().process_frame

	assert_null(_find_router_node(), "Utility 已销毁时，延迟挂载不应留下输入 Router。")


## 验证同一动作可以按输入设备映射维护玩家级状态。
func test_player_action_state_is_scoped_by_device_assignment() -> void:
	var arch := GFArchitecture.new()
	var devices := GFInputDeviceUtility.new()
	devices.include_keyboard_mouse = false
	devices.include_touch = false
	devices.max_players = 2
	await arch.register_utility_instance(devices)
	await arch.register_utility_instance(_utility)

	var context := _make_context(&"gameplay", [
		_make_mapping(_make_action(&"jump"), [
			_make_joy_button_binding(JOY_BUTTON_A),
		]),
	])

	_utility.enable_context(context)
	_utility.handle_input_event(_make_joy_button_event(0, JOY_BUTTON_A, true))
	_utility.handle_input_event(_make_joy_button_event(1, JOY_BUTTON_A, true))
	_utility.handle_input_event(_make_joy_button_event(0, JOY_BUTTON_A, false))

	assert_false(_utility.is_action_active_for_player(0, &"jump"), "0 号玩家释放后自己的动作应结束。")
	assert_true(_utility.is_action_active_for_player(1, &"jump"), "1 号玩家仍按住时自己的动作应保持活跃。")
	assert_true(_utility.is_action_active(&"jump"), "全局动作状态应聚合仍活跃的设备来源。")

	arch.dispose()
	_utility = null
	await get_tree().process_frame


# --- 私有/辅助方法 ---

func _make_action(action_id: StringName, value_type: GFInputActionBase.ValueType = GFInputActionBase.ValueType.BOOL) -> GFInputActionBase:
	var action := GFInputActionBase.new()
	action.action_id = action_id
	action.value_type = value_type
	return action


func _make_context(context_id: StringName, mappings: Array[GFInputMappingBase]) -> GFInputContextBase:
	var context := GFInputContextBase.new()
	context.context_id = context_id
	context.mappings = mappings
	return context


func _make_mapping(action: GFInputActionBase, bindings: Array[GFInputBindingBase]) -> GFInputMappingBase:
	var mapping := GFInputMappingBase.new()
	mapping.action = action
	mapping.bindings = bindings
	return mapping


func _make_key_binding(
	key: Key,
	target: GFInputBindingBase.ValueTarget = GFInputBindingBase.ValueTarget.AUTO
) -> GFInputBindingBase:
	var binding := GFInputBindingBase.new()
	binding.input_event = _make_key_event(key, true)
	binding.value_target = target
	return binding


func _make_joy_axis_binding(axis: JoyAxis, target: GFInputBindingBase.ValueTarget) -> GFInputBindingBase:
	var binding := GFInputBindingBase.new()
	binding.input_event = _make_joy_motion_event(axis, 1.0)
	binding.value_target = target
	return binding


func _make_joy_button_binding(button: JoyButton) -> GFInputBindingBase:
	var binding := GFInputBindingBase.new()
	binding.input_event = _make_joy_button_event(0, button, true)
	return binding


func _make_key_event(key: Key, pressed: bool) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	return event


func _make_joy_motion_event(axis: JoyAxis, axis_value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	return event


func _make_joy_button_event(device: int, button: JoyButton, pressed: bool) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = pressed
	event.pressure = 1.0 if pressed else 0.0
	return event


func _find_router_node() -> Node:
	for child: Node in get_tree().root.get_children():
		if child.name == "GFInputMappingRouter":
			return child
	return null
