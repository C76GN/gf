@tool

## GFEditorValueField: 编辑器通用 Variant 值输入控件。
##
## 根据 Godot 属性信息创建基础输入控件，适合 Inspector、Dock 或批量资源表格复用。
class_name GFEditorValueField
extends HBoxContainer


# --- 信号 ---

## 控件值变化时发出。
signal value_changed(value: Variant)


# --- 私有变量 ---

var _property_info: Dictionary = {}
var _value: Variant = null
var _editor: Control = null
var _editable: bool = true
var _is_updating: bool = false


# --- 公共方法 ---

## 配置字段输入控件。
## @param property_info: Godot 属性信息字典，常用键为 name、type、hint、hint_string。
## @param value: 初始值。
func configure(property_info: Dictionary, value: Variant = null) -> void:
	_property_info = property_info.duplicate(true)
	_value = value
	_rebuild_editor()


## 设置当前值。
## @param value: 新值。
func set_value(value: Variant) -> void:
	_value = value
	_sync_editor_from_value()


## 获取当前值。
## @return 当前值。
func get_value() -> Variant:
	return _read_editor_value()


## 设置控件是否可编辑。
## @param editable: 为 true 时允许编辑。
func set_editable(editable: bool) -> void:
	_editable = editable
	if _editor != null:
		_apply_editable_state(_editor)


## 获取当前属性信息。
## @return 属性信息字典。
func get_property_info() -> Dictionary:
	return _property_info.duplicate(true)


# --- 私有/辅助方法 ---

func _rebuild_editor() -> void:
	if _editor != null:
		remove_child(_editor)
		_editor.queue_free()
		_editor = null

	_editor = _create_editor_for_type(int(_property_info.get("type", TYPE_STRING)))
	add_child(_editor)
	_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_editable_state(_editor)
	_sync_editor_from_value()


func _create_editor_for_type(value_type: int) -> Control:
	match value_type:
		TYPE_BOOL:
			var checkbox := CheckBox.new()
			checkbox.toggled.connect(_on_bool_toggled)
			return checkbox
		TYPE_INT:
			var spin := SpinBox.new()
			spin.rounded = true
			spin.value_changed.connect(_on_number_changed)
			return spin
		TYPE_FLOAT:
			var spin := SpinBox.new()
			spin.step = 0.01
			spin.value_changed.connect(_on_number_changed)
			return spin
		TYPE_COLOR:
			var color_picker := ColorPickerButton.new()
			color_picker.color_changed.connect(_on_color_changed)
			return color_picker
		_:
			var line_edit := LineEdit.new()
			line_edit.text_changed.connect(_on_text_changed)
			return line_edit


func _sync_editor_from_value() -> void:
	if _editor == null:
		return

	_is_updating = true
	var value_type := int(_property_info.get("type", TYPE_STRING))
	match value_type:
		TYPE_BOOL:
			(_editor as CheckBox).button_pressed = bool(_value)
		TYPE_INT, TYPE_FLOAT:
			(_editor as SpinBox).value = float(_value)
		TYPE_COLOR:
			var color_value: Color = _value as Color if _value is Color else Color.WHITE
			(_editor as ColorPickerButton).color = color_value
		_:
			(_editor as LineEdit).text = _stringify_value(_value)
	_is_updating = false


func _read_editor_value() -> Variant:
	if _editor == null:
		return _value

	var value_type := int(_property_info.get("type", TYPE_STRING))
	match value_type:
		TYPE_BOOL:
			return (_editor as CheckBox).button_pressed
		TYPE_INT:
			return int((_editor as SpinBox).value)
		TYPE_FLOAT:
			return float((_editor as SpinBox).value)
		TYPE_STRING_NAME:
			return StringName((_editor as LineEdit).text)
		TYPE_COLOR:
			return (_editor as ColorPickerButton).color
		TYPE_ARRAY, TYPE_DICTIONARY:
			return _parse_json_value((_editor as LineEdit).text)
		_:
			return (_editor as LineEdit).text


func _apply_editable_state(control: Control) -> void:
	if control is BaseButton:
		(control as BaseButton).disabled = not _editable
	elif control is LineEdit:
		(control as LineEdit).editable = _editable
	elif control is SpinBox:
		(control as SpinBox).editable = _editable
	elif control is ColorPickerButton:
		(control as ColorPickerButton).disabled = not _editable


func _stringify_value(value: Variant) -> String:
	if value is Dictionary or value is Array:
		return JSON.stringify(value)
	if value == null:
		return ""
	return str(value)


func _parse_json_value(text: String) -> Variant:
	var json := JSON.new()
	if json.parse(text) != OK:
		return [] if int(_property_info.get("type", TYPE_STRING)) == TYPE_ARRAY else {}
	return json.data


func _emit_value_changed(value: Variant) -> void:
	if _is_updating:
		return
	_value = value
	value_changed.emit(value)


# --- 信号处理函数 ---

func _on_bool_toggled(pressed: bool) -> void:
	_emit_value_changed(pressed)


func _on_number_changed(_value_float: float) -> void:
	_emit_value_changed(_read_editor_value())


func _on_color_changed(color: Color) -> void:
	_emit_value_changed(color)


func _on_text_changed(_text: String) -> void:
	_emit_value_changed(_read_editor_value())
