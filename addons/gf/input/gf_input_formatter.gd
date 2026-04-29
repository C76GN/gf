## GFInputFormatter: 输入事件与绑定的轻量文本格式化工具。
class_name GFInputFormatter
extends RefCounted


# --- 常量 ---

const GFInputBindingBase = preload("res://addons/gf/input/gf_input_binding.gd")
const GFInputMappingBase = preload("res://addons/gf/input/gf_input_mapping.gd")
const GFInputRemapConfigBase = preload("res://addons/gf/input/gf_input_remap_config.gd")


# --- 公共方法 ---

## 将 Godot 输入事件格式化为通用文本。
## @param input_event: 输入事件。
## @return 可显示文本。
static func input_event_as_text(input_event: InputEvent) -> String:
	if input_event == null:
		return "Unbound"

	if input_event is InputEventAction:
		return String((input_event as InputEventAction).action)

	if input_event is InputEventKey:
		return _key_event_as_text(input_event as InputEventKey)

	if input_event is InputEventMouseButton:
		return _mouse_button_as_text((input_event as InputEventMouseButton).button_index)

	if input_event is InputEventJoypadButton:
		return "Joy Button %d" % int((input_event as InputEventJoypadButton).button_index)

	if input_event is InputEventJoypadMotion:
		var axis_event := input_event as InputEventJoypadMotion
		return "Joy Axis %d" % int(axis_event.axis)

	if input_event is InputEventScreenTouch:
		return "Touch"

	return input_event.as_text()


## 将绑定格式化为通用文本。
## @param binding: 输入绑定。
## @return 可显示文本。
static func binding_as_text(binding: GFInputBindingBase) -> String:
	if binding == null:
		return "Unbound"
	return binding.get_display_name()


## 将映射的当前有效绑定格式化为通用文本。
## @param mapping: 输入映射。
## @param context_id: 上下文标识。
## @param remap_config: 可选重映射配置。
## @return 可显示文本。
static func mapping_as_text(
	mapping: GFInputMappingBase,
	context_id: StringName = &"",
	remap_config: GFInputRemapConfigBase = null
) -> String:
	if mapping == null:
		return ""

	var action_id := mapping.get_action_id()
	var parts: Array[String] = []
	for index: int in range(mapping.bindings.size()):
		var binding := mapping.bindings[index]
		if binding == null:
			continue

		var event := binding.input_event
		if remap_config != null and remap_config.has_binding(context_id, action_id, index):
			event = remap_config.get_bound_event_or_null(context_id, action_id, index)
		parts.append(input_event_as_text(event))

	return " / ".join(parts)


# --- 私有/辅助方法 ---

static func _key_event_as_text(event: InputEventKey) -> String:
	var parts: Array[String] = []
	if event.ctrl_pressed:
		parts.append("Ctrl")
	if event.alt_pressed:
		parts.append("Alt")
	if event.shift_pressed:
		parts.append("Shift")
	if event.meta_pressed:
		parts.append("Meta")

	var keycode := event.physical_keycode
	if keycode == KEY_NONE:
		keycode = event.keycode

	var key_text := OS.get_keycode_string(keycode)
	parts.append(key_text if not key_text.is_empty() else "Key %d" % int(keycode))
	return " + ".join(parts)


static func _mouse_button_as_text(button: MouseButton) -> String:
	match button:
		MOUSE_BUTTON_LEFT:
			return "Mouse Left"
		MOUSE_BUTTON_RIGHT:
			return "Mouse Right"
		MOUSE_BUTTON_MIDDLE:
			return "Mouse Middle"
		MOUSE_BUTTON_WHEEL_UP:
			return "Mouse Wheel Up"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "Mouse Wheel Down"
		_:
			return "Mouse Button %d" % int(button)
