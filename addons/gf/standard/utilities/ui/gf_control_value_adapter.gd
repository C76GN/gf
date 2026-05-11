## GFControlValueAdapter: 常见 Control 节点的值读写适配器。
##
## 用于表单、设置页和编辑工具中统一读写控件值，不持有状态。
class_name GFControlValueAdapter
extends RefCounted


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
	if control == null or not callback.is_valid():
		return false

	if control is LineEdit:
		(control as LineEdit).text_changed.connect(func(_text: String) -> void:
			callback.call()
		)
		return true
	if control is TextEdit:
		(control as TextEdit).text_changed.connect(func() -> void:
			callback.call()
		)
		return true
	if control is OptionButton:
		(control as OptionButton).item_selected.connect(func(_index: int) -> void:
			callback.call()
		)
		return true
	if control is ColorPickerButton:
		(control as ColorPickerButton).color_changed.connect(func(_color: Color) -> void:
			callback.call()
		)
		return true
	if control is BaseButton:
		(control as BaseButton).toggled.connect(func(_pressed: bool) -> void:
			callback.call()
		)
		return true
	if control is Range:
		(control as Range).value_changed.connect(func(_value: float) -> void:
			callback.call()
		)
		return true
	if control is ItemList:
		(control as ItemList).item_selected.connect(func(_index: int) -> void:
			callback.call()
		)
		(control as ItemList).multi_selected.connect(func(_index: int, _selected: bool) -> void:
			callback.call()
		)
		return true
	if control.has_signal("value_changed"):
		control.connect("value_changed", func(_value: Variant = null) -> void:
			callback.call()
		)
		return true

	return false


# --- 私有/辅助方法 ---

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
