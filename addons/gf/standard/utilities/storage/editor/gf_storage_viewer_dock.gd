@tool

## GFStorageViewerDock: 开发期本地存档查看面板。
##
## 用 GFStorageCodec 解码本地存档字节，便于编辑器内排查存档内容与完整性状态。
class_name GFStorageViewerDock
extends VBoxContainer


# --- 常量 ---

const SAVE_VIEWER_CODEC_SCRIPT_PATH: String = "res://addons/gf/standard/utilities/storage/gf_storage_codec.gd"
const SAVE_VIEWER_FORMAT_JSON: int = 0
const SAVE_VIEWER_FORMAT_BINARY: int = 1
const SAVE_VIEWER_LABEL_WIDTH: float = 72.0
const SAVE_VIEWER_OUTPUT_MIN_HEIGHT: float = 40.0


# --- 私有变量 ---

var _path_edit: LineEdit
var _format_option: OptionButton
var _obfuscation_key_spin: SpinBox
var _compression_check: CheckBox
var _checksum_check: CheckBox
var _strict_check: CheckBox
var _status_label: Label
var _output: TextEdit
var _file_dialog: FileDialog


# --- Godot 生命周期方法 ---

func _init() -> void:
	name = "GF Save Viewer"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2.ZERO
	_build_ui()


# --- 私有/辅助方法 ---

func _build_ui() -> void:
	var path_row := HBoxContainer.new()
	path_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(path_row)

	_path_edit = LineEdit.new()
	_path_edit.placeholder_text = "user://saves/slot_1_data.sav or absolute path"
	_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	path_row.add_child(_path_edit)

	var browse_button := Button.new()
	browse_button.text = "..."
	browse_button.tooltip_text = "Browse save file"
	browse_button.pressed.connect(_on_browse_pressed)
	path_row.add_child(browse_button)

	_format_option = OptionButton.new()
	_format_option.add_item("JSON", SAVE_VIEWER_FORMAT_JSON)
	_format_option.add_item("Binary", SAVE_VIEWER_FORMAT_BINARY)
	_format_option.selected = 0
	add_child(_make_labeled_row("Format", _format_option))

	_obfuscation_key_spin = SpinBox.new()
	_obfuscation_key_spin.min_value = 0.0
	_obfuscation_key_spin.max_value = 255.0
	_obfuscation_key_spin.step = 1.0
	_obfuscation_key_spin.value = 42.0
	add_child(_make_labeled_row("XOR key", _obfuscation_key_spin))

	_compression_check = CheckBox.new()
	_compression_check.text = "Compressed"
	add_child(_compression_check)

	_checksum_check = CheckBox.new()
	_checksum_check.text = "Verify checksum"
	add_child(_checksum_check)

	_strict_check = CheckBox.new()
	_strict_check.text = "Strict integrity"
	_strict_check.button_pressed = true
	add_child(_strict_check)

	var button_row := HBoxContainer.new()
	add_child(button_row)

	var load_button := Button.new()
	load_button.text = "Load"
	load_button.tooltip_text = "Load save file"
	load_button.pressed.connect(_on_load_pressed)
	button_row.add_child(load_button)

	var copy_button := Button.new()
	copy_button.text = "Copy"
	copy_button.tooltip_text = "Copy decoded JSON"
	copy_button.pressed.connect(_on_copy_pressed)
	button_row.add_child(copy_button)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.text = "Choose a save file and matching codec options."
	add_child(_status_label)

	_output = TextEdit.new()
	_output.editable = false
	_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_output.custom_minimum_size = Vector2(0.0, SAVE_VIEWER_OUTPUT_MIN_HEIGHT)
	add_child(_output)

	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.file_selected.connect(_on_file_selected)
	add_child(_file_dialog)


func _make_labeled_row(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(SAVE_VIEWER_LABEL_WIDTH, 0.0)
	row.add_child(label)

	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


func _create_codec() -> Variant:
	var codec_script := load(SAVE_VIEWER_CODEC_SCRIPT_PATH) as Script
	if codec_script == null or not codec_script.can_instantiate():
		return null
	return codec_script.new()


func _get_selected_format() -> int:
	return _format_option.get_selected_id()


func _set_status(message: String, is_error: bool) -> void:
	if is_instance_valid(_status_label):
		_status_label.text = message
	if is_error:
		push_warning("[GF Save Viewer] " + message)


# --- 信号处理函数 ---

func _on_browse_pressed() -> void:
	if is_instance_valid(_file_dialog):
		_file_dialog.popup_centered_ratio(0.6)


func _on_file_selected(path: String) -> void:
	if is_instance_valid(_path_edit):
		_path_edit.text = path


func _on_load_pressed() -> void:
	var path := _path_edit.text.strip_edges()
	if path.is_empty():
		_set_status("Path is empty.", true)
		return
	if not FileAccess.file_exists(path):
		_set_status("File does not exist: %s" % path, true)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_set_status("Cannot open file: %s" % error_string(FileAccess.get_open_error()), true)
		return

	var bytes := file.get_buffer(file.get_length())
	file.close()

	var codec := _create_codec()
	if codec == null:
		_output.text = ""
		_set_status("Storage codec is unavailable.", true)
		return

	var result: Dictionary = codec.decode(bytes, {
		"format": _get_selected_format(),
		"obfuscation_key": int(_obfuscation_key_spin.value),
		"use_compression": _compression_check.button_pressed,
		"use_integrity_checksum": _checksum_check.button_pressed,
		"strict_integrity": _strict_check.button_pressed,
	})

	if not bool(result.get("ok", false)):
		_output.text = ""
		_set_status(String(result.get("error", "Decode failed")), true)
		return

	var data_value: Variant = result.get("data", {})
	if not (data_value is Dictionary):
		_output.text = ""
		_set_status("Decoded storage payload is not a Dictionary.", true)
		return

	var data := data_value as Dictionary
	_output.text = JSON.stringify(data, "\t")
	_set_status(
		"OK: %d bytes, %d top-level keys, integrity=%s" % [
			bytes.size(),
			data.size(),
			str(result.get("integrity_valid", true)),
		],
		false
	)


func _on_copy_pressed() -> void:
	if _output == null or _output.text.is_empty():
		return
	DisplayServer.clipboard_set(_output.text)
	_set_status("Copied JSON to clipboard.", false)
