@tool

## GFEditorValueField: 编辑器通用 Variant 值输入控件。
##
## 根据 Godot 属性信息创建基础输入控件，适合 Inspector、Dock 或批量资源表格复用。
## [br]
## @api public
## [br]
## @category editor_api
## [br]
## @since 3.17.0
## [br]
## @layer kernel/editor
class_name GFEditorValueField
extends HBoxContainer


# --- 信号 ---

## 控件值变化时发出。
## [br]
## @api public
## [br]
## @param value: 新值。
## [br]
## @schema value: Variant editor value read from the active control.
signal value_changed(value: Variant)

## Array/Dictionary JSON 输入解析失败时发出。
## [br]
## @api public
## [br]
## @param text: 用户输入的原始文本。
## [br]
## @param error_message: JSON 解析错误说明。
signal value_parse_failed(text: String, error_message: String)


# --- 常量 ---

const _GF_VARIANT_ACCESS_SCRIPT = preload("res://addons/gf/kernel/core/gf_variant_access.gd")


# --- 私有变量 ---

var _property_info: Dictionary = {}
var _value: Variant = null
var _editor: Control = null
var _editable: bool = true
var _is_updating: bool = false


# --- 公共方法 ---

## 配置字段输入控件。
## [br]
## @api public
## [br]
## @param property_info: Godot 属性信息字典，常用键为 name、type、hint、hint_string。
## [br]
## @schema property_info: Godot property info dictionary.
## [br]
## @param value: 初始值。
## [br]
## @schema value: Variant initial editor value.
func configure(property_info: Dictionary, value: Variant = null) -> void:
	_property_info = property_info.duplicate(true)
	_value = value
	_rebuild_editor()


## 设置当前值。
## [br]
## @api public
## [br]
## @param value: 新值。
## [br]
## @schema value: Variant value assigned to the editor.
func set_value(value: Variant) -> void:
	_value = value
	_sync_editor_from_value()


## 获取当前值。
## [br]
## @api public
## [br]
## @return 当前值。
## [br]
## @schema return: Variant value read from the active editor control.
func get_value() -> Variant:
	return _read_editor_value()


## 设置控件是否可编辑。
## [br]
## @api public
## [br]
## @param editable: 为 true 时允许编辑。
func set_editable(editable: bool) -> void:
	_editable = editable
	if _editor != null:
		_apply_editable_state(_editor)


## 获取当前属性信息。
## [br]
## @api public
## [br]
## @return 属性信息字典。
## [br]
## @schema return: Godot property info dictionary copy.
func get_property_info() -> Dictionary:
	return _property_info.duplicate(true)


# --- 私有/辅助方法 ---

func _rebuild_editor() -> void:
	if _editor != null:
		remove_child(_editor)
		_editor.queue_free()
		_editor = null

	_editor = _create_editor_for_type(_get_property_type())
	add_child(_editor)
	_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_editable_state(_editor)
	_sync_editor_from_value()


func _create_editor_for_type(value_type: int) -> Control:
	match value_type:
		TYPE_BOOL:
			var checkbox: CheckBox = CheckBox.new()
			var _connect_result_136: Variant = checkbox.toggled.connect(_on_bool_toggled)
			return checkbox
		TYPE_INT:
			var spin: SpinBox = SpinBox.new()
			spin.rounded = true
			var _connect_result_141: Variant = spin.value_changed.connect(_on_number_changed)
			return spin
		TYPE_FLOAT:
			var spin: SpinBox = SpinBox.new()
			spin.step = 0.01
			var _connect_result_146: Variant = spin.value_changed.connect(_on_number_changed)
			return spin
		TYPE_COLOR:
			var color_picker: ColorPickerButton = ColorPickerButton.new()
			var _connect_result_150: Variant = color_picker.color_changed.connect(_on_color_changed)
			return color_picker
		_:
			var line_edit: LineEdit = LineEdit.new()
			var _connect_result_154: Variant = line_edit.text_changed.connect(_on_text_changed)
			return line_edit


func _sync_editor_from_value() -> void:
	if _editor == null:
		return

	_is_updating = true
	var value_type: int = _get_property_type()
	match value_type:
		TYPE_BOOL:
			var checkbox: CheckBox = _get_checkbox_editor()
			if checkbox != null:
				checkbox.button_pressed = _GF_VARIANT_ACCESS_SCRIPT.to_bool(_value)
		TYPE_INT, TYPE_FLOAT:
			var spin: SpinBox = _get_spin_editor()
			if spin != null:
				spin.value = _GF_VARIANT_ACCESS_SCRIPT.to_float(_value)
		TYPE_COLOR:
			var color_picker: ColorPickerButton = _get_color_picker_editor()
			if color_picker != null:
				color_picker.color = _variant_to_color(_value, Color.WHITE)
		_:
			var line_edit: LineEdit = _get_line_edit_editor()
			if line_edit != null:
				line_edit.text = _stringify_value(_value)
	_is_updating = false


func _read_editor_value() -> Variant:
	if _editor == null:
		return _value

	var value_type: int = _get_property_type()
	match value_type:
		TYPE_BOOL:
			var checkbox: CheckBox = _get_checkbox_editor()
			return checkbox.button_pressed if checkbox != null else _value
		TYPE_INT:
			var spin: SpinBox = _get_spin_editor()
			return int(spin.value) if spin != null else _value
		TYPE_FLOAT:
			var spin: SpinBox = _get_spin_editor()
			return float(spin.value) if spin != null else _value
		TYPE_STRING_NAME:
			var line_edit: LineEdit = _get_line_edit_editor()
			return StringName(line_edit.text) if line_edit != null else _value
		TYPE_COLOR:
			var color_picker: ColorPickerButton = _get_color_picker_editor()
			return color_picker.color if color_picker != null else _value
		TYPE_ARRAY, TYPE_DICTIONARY:
			var line_edit: LineEdit = _get_line_edit_editor()
			if line_edit == null:
				return _value
			var parse_result: Dictionary = _try_parse_json_value(line_edit.text, value_type)
			if not _GF_VARIANT_ACCESS_SCRIPT.get_option_bool(parse_result, "ok", false):
				return _value
			return _GF_VARIANT_ACCESS_SCRIPT.get_option_value(parse_result, "value")
		_:
			var line_edit: LineEdit = _get_line_edit_editor()
			return line_edit.text if line_edit != null else _value


func _apply_editable_state(control: Control) -> void:
	if control is BaseButton:
		var button: BaseButton = control
		button.disabled = not _editable
	elif control is LineEdit:
		var line_edit: LineEdit = control
		line_edit.editable = _editable
	elif control is SpinBox:
		var spin: SpinBox = control
		spin.editable = _editable
	elif control is ColorPickerButton:
		var color_picker: ColorPickerButton = control
		color_picker.disabled = not _editable


func _get_property_type() -> int:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_int(_property_info, "type", TYPE_STRING)


func _get_checkbox_editor() -> CheckBox:
	if _editor is CheckBox:
		var checkbox: CheckBox = _editor
		return checkbox
	return null


func _get_spin_editor() -> SpinBox:
	if _editor is SpinBox:
		var spin: SpinBox = _editor
		return spin
	return null


func _get_color_picker_editor() -> ColorPickerButton:
	if _editor is ColorPickerButton:
		var color_picker: ColorPickerButton = _editor
		return color_picker
	return null


func _get_line_edit_editor() -> LineEdit:
	if _editor is LineEdit:
		var line_edit: LineEdit = _editor
		return line_edit
	return null


func _variant_to_color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		var color: Color = value
		return color
	return fallback


func _stringify_value(value: Variant) -> String:
	if value is Dictionary or value is Array:
		return JSON.stringify(value)
	if value == null:
		return ""
	return str(value)


func _try_parse_json_value(text: String, expected_type: int = TYPE_NIL) -> Dictionary:
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		return {
			"ok": false,
			"value": _value,
			"error": json.get_error_message(),
		}
	if expected_type == TYPE_ARRAY and not (json.data is Array):
		return {
			"ok": false,
			"value": _value,
			"error": "Expected Array JSON.",
		}
	if expected_type == TYPE_DICTIONARY and not (json.data is Dictionary):
		return {
			"ok": false,
			"value": _value,
			"error": "Expected Dictionary JSON.",
		}
	return {
		"ok": true,
		"value": json.data,
		"error": "",
	}


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
	var value_type: int = _get_property_type()
	if value_type == TYPE_ARRAY or value_type == TYPE_DICTIONARY:
		var line_edit: LineEdit = _get_line_edit_editor()
		if line_edit == null:
			return
		var parse_result: Dictionary = _try_parse_json_value(line_edit.text, value_type)
		if not _GF_VARIANT_ACCESS_SCRIPT.get_option_bool(parse_result, "ok", false):
			value_parse_failed.emit(
				line_edit.text,
				_GF_VARIANT_ACCESS_SCRIPT.get_option_string(parse_result, "error", "")
			)
			return
		_emit_value_changed(_GF_VARIANT_ACCESS_SCRIPT.get_option_value(parse_result, "value"))
		return

	_emit_value_changed(_read_editor_value())
