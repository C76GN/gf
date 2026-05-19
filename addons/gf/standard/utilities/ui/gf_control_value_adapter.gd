## GFControlValueAdapter: 常见 Control 节点的值读写适配器。
##
## 用于表单、设置页和编辑工具中统一读写控件值，不持有状态。
class_name GFControlValueAdapter
extends RefCounted


# --- 常量 ---

const _INSTANCE_GUARD: Script = preload("res://addons/gf/kernel/core/gf_instance_guard.gd")


# --- 公共方法 ---

## 从控件读取值。
## @param control: 控件节点。
## @param fallback: 不支持读取时返回的值。
## @return 控件值。
static func get_value(control: Control, fallback: Variant = null) -> Variant:
	if control == null:
		return fallback

	if control is LineEdit:
		return (control as LineEdit).text
	if control is TextEdit:
		return (control as TextEdit).text
	if control is OptionButton:
		return (control as OptionButton).selected
	if control is ColorPickerButton:
		return (control as ColorPickerButton).color
	if control is BaseButton:
		return (control as BaseButton).button_pressed
	if control is Range:
		return (control as Range).value
	if control is ItemList:
		return (control as ItemList).get_selected_items()
	if control.has_method("get_value"):
		return control.call("get_value")
	if "value" in control:
		return control.get("value")

	return fallback


## 向控件写入值。
## @param control: 控件节点。
## @param value: 值。
## @return 成功写入时返回 true。
static func set_value(control: Control, value: Variant) -> bool:
	if control == null:
		return false

	if control is LineEdit:
		(control as LineEdit).text = String(value)
		return true
	if control is TextEdit:
		(control as TextEdit).text = String(value)
		return true
	if control is OptionButton:
		(control as OptionButton).selected = int(value)
		return true
	if control is ColorPickerButton:
		if value is Color:
			(control as ColorPickerButton).color = value as Color
			return true
		return false
	if control is BaseButton:
		(control as BaseButton).button_pressed = bool(value)
		return true
	if control is Range:
		(control as Range).value = float(value)
		return true
	if control is ItemList:
		_set_item_list_selection(control as ItemList, value)
		return true
	if control.has_method("set_value"):
		control.call("set_value", value)
		return true
	if "value" in control:
		control.set("value", value)
		return true

	return false


## 连接控件值变化信号。
## @param control: 控件节点。
## @param callback: 值变化后调用的回调，不接收参数。
## @return 成功连接时返回 true。
static func connect_value_changed(control: Control, callback: Callable) -> bool:
	return not connect_value_changed_with_handles(control, callback).is_empty()


## 连接控件值变化信号并返回可断开的连接句柄。
## @param control: 控件节点。
## @param callback: 值变化后调用的回调，不接收参数。
## @return 连接句柄数组，可传给 disconnect_value_changed_handles()。
static func connect_value_changed_with_handles(control: Control, callback: Callable) -> Array[Dictionary]:
	var connections: Array[Dictionary] = []
	if control == null or not callback.is_valid():
		return connections

	if control is LineEdit:
		var line_edit_callback := func(_text: String) -> void:
			callback.call()
		_connect_control_signal(control, &"text_changed", line_edit_callback, connections)
		return connections
	if control is TextEdit:
		var text_edit_callback := func() -> void:
			callback.call()
		_connect_control_signal(control, &"text_changed", text_edit_callback, connections)
		return connections
	if control is OptionButton:
		var option_callback := func(_index: int) -> void:
			callback.call()
		_connect_control_signal(control, &"item_selected", option_callback, connections)
		return connections
	if control is ColorPickerButton:
		var color_callback := func(_color: Color) -> void:
			callback.call()
		_connect_control_signal(control, &"color_changed", color_callback, connections)
		return connections
	if control is BaseButton:
		var button_callback := func(_pressed: bool) -> void:
			callback.call()
		_connect_control_signal(control, &"toggled", button_callback, connections)
		return connections
	if control is Range:
		var range_callback := func(_value: float) -> void:
			callback.call()
		_connect_control_signal(control, &"value_changed", range_callback, connections)
		return connections
	if control is ItemList:
		var item_selected_callback := func(_index: int) -> void:
			callback.call()
		_connect_control_signal(control, &"item_selected", item_selected_callback, connections)
		var multi_selected_callback := func(_index: int, _selected: bool) -> void:
			callback.call()
		_connect_control_signal(control, &"multi_selected", multi_selected_callback, connections)
		return connections
	if control.has_signal("value_changed"):
		var value_callback := func(_value: Variant = null) -> void:
			callback.call()
		_connect_control_signal(control, &"value_changed", value_callback, connections)
		return connections

	return connections


## 断开 connect_value_changed_with_handles() 返回的连接句柄。
## @param connections: 连接句柄数组。
static func disconnect_value_changed_handles(connections: Array) -> void:
	for connection_variant: Variant in connections:
		var connection := connection_variant as Dictionary
		if connection == null:
			continue
		var control_ref_variant: Variant = connection.get("control_ref")
		var control_ref := control_ref_variant as WeakRef if control_ref_variant is WeakRef else null
		var control: Control = _INSTANCE_GUARD._get_live_control_from_ref(control_ref)
		if not is_instance_valid(control):
			continue
		var signal_name := StringName(connection.get("signal_name", &""))
		var callable := connection.get("callable") as Callable
		if signal_name != &"" and callable.is_valid() and control.is_connected(signal_name, callable):
			control.disconnect(signal_name, callable)


# --- 私有/辅助方法 ---

static func _connect_control_signal(
	control: Control,
	signal_name: StringName,
	callable: Callable,
	connections: Array[Dictionary]
) -> void:
	if control == null or signal_name == &"" or not callable.is_valid():
		return
	if not control.has_signal(signal_name):
		return
	control.connect(signal_name, callable)
	connections.append({
		"control_ref": weakref(control),
		"signal_name": signal_name,
		"callable": callable,
	})


static func _set_item_list_selection(item_list: ItemList, value: Variant) -> void:
	item_list.deselect_all()
	if value is PackedInt32Array:
		for index: int in value:
			item_list.select(index, false)
		return
	if value is Array:
		for index_variant: Variant in value:
			item_list.select(int(index_variant), false)
		return
	item_list.select(int(value), false)
