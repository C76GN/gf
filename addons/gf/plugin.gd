@tool
extends EditorPlugin


## GF Framework 编辑器插件。
## 在启用/禁用插件时自动注册/注销 Gf AutoLoad 单例，并装配 GF 编辑器工具。

# --- 常量 ---

const GFPluginAutoload = preload("res://addons/gf/kernel/editor/gf_plugin_autoload.gd")
const GFPluginProjectSettings = preload("res://addons/gf/kernel/editor/gf_plugin_project_settings.gd")
const GFPluginInspectorTools = preload("res://addons/gf/kernel/editor/gf_plugin_inspector_tools.gd")
const GFPluginActions = preload("res://addons/gf/kernel/editor/gf_plugin_actions.gd")
const GFPluginMenu = preload("res://addons/gf/kernel/editor/gf_plugin_menu.gd")
const PACKAGE_MANAGER_DOCK_SCRIPT_PATH: String = "res://addons/gf/kernel/editor/package/gf_package_manager_dock.gd"
const SAVE_VIEWER_CODEC_SCRIPT_PATH: String = "res://addons/gf/standard/utilities/storage/gf_storage_codec.gd"
const SAVE_VIEWER_FORMAT_JSON: int = 0
const SAVE_VIEWER_FORMAT_BINARY: int = 1
const SAVE_VIEWER_LABEL_WIDTH: float = 72.0
const SAVE_VIEWER_OUTPUT_MIN_HEIGHT: float = 40.0


# --- 私有变量 ---

var _inspector_tools: RefCounted
var _actions: RefCounted
var _menu: RefCounted
var _save_viewer_dock: Control
var _save_viewer_bottom_button: Button
var _package_manager_dock: Control
var _package_manager_bottom_button: Button
var _save_viewer_path_edit: LineEdit
var _save_viewer_format_option: OptionButton
var _save_viewer_obfuscation_key_spin: SpinBox
var _save_viewer_compression_check: CheckBox
var _save_viewer_checksum_check: CheckBox
var _save_viewer_strict_check: CheckBox
var _save_viewer_status_label: Label
var _save_viewer_output: TextEdit
var _save_viewer_file_dialog: FileDialog
var _plugin_active: bool = false


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_plugin_active = true
	GFPluginAutoload.ensure(self)
	GFPluginProjectSettings.ensure_all()

	_inspector_tools = GFPluginInspectorTools.new()
	_inspector_tools.setup(self)

	_actions = GFPluginActions.new()
	_actions.setup()

	_menu = GFPluginMenu.new()
	_menu.setup(self, Callable(_actions, "handle_menu_id"))

	call_deferred("_setup_save_viewer_dock")
	call_deferred("_setup_package_manager_dock")


func _exit_tree() -> void:
	_plugin_active = false
	GFPluginAutoload.remove(self)
	_cleanup_save_viewer_dock()
	_cleanup_package_manager_dock()

	if _menu != null:
		_menu.cleanup(self)
		_menu = null
	if _actions != null:
		_actions.cleanup()
		_actions = null
	if _inspector_tools != null:
		_inspector_tools.cleanup(self)
		_inspector_tools = null


# --- 私有/辅助方法 ---

func _setup_save_viewer_dock() -> void:
	if not _plugin_active or is_instance_valid(_save_viewer_dock):
		return

	_save_viewer_dock = _create_save_viewer_dock()
	_save_viewer_bottom_button = add_control_to_bottom_panel(_save_viewer_dock, "GF Save Viewer")


func _cleanup_save_viewer_dock() -> void:
	if is_instance_valid(_save_viewer_dock):
		remove_control_from_bottom_panel(_save_viewer_dock)
		_save_viewer_dock.queue_free()
	_save_viewer_dock = null
	_save_viewer_bottom_button = null
	_save_viewer_path_edit = null
	_save_viewer_format_option = null
	_save_viewer_obfuscation_key_spin = null
	_save_viewer_compression_check = null
	_save_viewer_checksum_check = null
	_save_viewer_strict_check = null
	_save_viewer_status_label = null
	_save_viewer_output = null
	_save_viewer_file_dialog = null


func _setup_package_manager_dock() -> void:
	if not _plugin_active or is_instance_valid(_package_manager_dock):
		return

	var dock_script := load(PACKAGE_MANAGER_DOCK_SCRIPT_PATH) as Script
	if dock_script == null or not dock_script.can_instantiate():
		push_error("[GF Framework] 包管理器面板加载失败。")
		return

	_package_manager_dock = dock_script.new() as Control
	if _package_manager_dock == null:
		push_error("[GF Framework] 包管理器面板实例化失败。")
		return

	_package_manager_bottom_button = add_control_to_bottom_panel(_package_manager_dock, "GF Packages")


func _cleanup_package_manager_dock() -> void:
	if is_instance_valid(_package_manager_dock):
		remove_control_from_bottom_panel(_package_manager_dock)
		_package_manager_dock.queue_free()
	_package_manager_dock = null
	_package_manager_bottom_button = null


func _create_save_viewer_dock() -> Control:
	var dock := VBoxContainer.new()
	dock.name = "GF Save Viewer"
	dock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dock.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dock.custom_minimum_size = Vector2.ZERO

	var path_row := HBoxContainer.new()
	path_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dock.add_child(path_row)

	_save_viewer_path_edit = LineEdit.new()
	_save_viewer_path_edit.placeholder_text = "user://saves/slot_1_data.sav or absolute path"
	_save_viewer_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	path_row.add_child(_save_viewer_path_edit)

	var browse_button := Button.new()
	browse_button.text = "..."
	browse_button.tooltip_text = "Browse save file"
	browse_button.pressed.connect(_on_save_viewer_browse_pressed)
	path_row.add_child(browse_button)

	_save_viewer_format_option = OptionButton.new()
	_save_viewer_format_option.add_item("JSON", SAVE_VIEWER_FORMAT_JSON)
	_save_viewer_format_option.add_item("Binary", SAVE_VIEWER_FORMAT_BINARY)
	_save_viewer_format_option.selected = 0
	dock.add_child(_make_save_viewer_labeled_row("Format", _save_viewer_format_option))

	_save_viewer_obfuscation_key_spin = SpinBox.new()
	_save_viewer_obfuscation_key_spin.min_value = 0.0
	_save_viewer_obfuscation_key_spin.max_value = 255.0
	_save_viewer_obfuscation_key_spin.step = 1.0
	_save_viewer_obfuscation_key_spin.value = 42.0
	dock.add_child(_make_save_viewer_labeled_row("XOR key", _save_viewer_obfuscation_key_spin))

	_save_viewer_compression_check = CheckBox.new()
	_save_viewer_compression_check.text = "Compressed"
	dock.add_child(_save_viewer_compression_check)

	_save_viewer_checksum_check = CheckBox.new()
	_save_viewer_checksum_check.text = "Verify checksum"
	dock.add_child(_save_viewer_checksum_check)

	_save_viewer_strict_check = CheckBox.new()
	_save_viewer_strict_check.text = "Strict integrity"
	_save_viewer_strict_check.button_pressed = true
	dock.add_child(_save_viewer_strict_check)

	var button_row := HBoxContainer.new()
	dock.add_child(button_row)

	var load_button := Button.new()
	load_button.text = "Load"
	load_button.tooltip_text = "Load save file"
	load_button.pressed.connect(_on_save_viewer_load_pressed)
	button_row.add_child(load_button)

	var copy_button := Button.new()
	copy_button.text = "Copy"
	copy_button.tooltip_text = "Copy decoded JSON"
	copy_button.pressed.connect(_on_save_viewer_copy_pressed)
	button_row.add_child(copy_button)

	_save_viewer_status_label = Label.new()
	_save_viewer_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_save_viewer_status_label.text = "Choose a save file and matching codec options."
	dock.add_child(_save_viewer_status_label)

	_save_viewer_output = TextEdit.new()
	_save_viewer_output.editable = false
	_save_viewer_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_save_viewer_output.custom_minimum_size = Vector2(0.0, SAVE_VIEWER_OUTPUT_MIN_HEIGHT)
	dock.add_child(_save_viewer_output)

	_save_viewer_file_dialog = FileDialog.new()
	_save_viewer_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_save_viewer_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_save_viewer_file_dialog.file_selected.connect(_on_save_viewer_file_selected)
	dock.add_child(_save_viewer_file_dialog)
	return dock


func _make_save_viewer_labeled_row(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(SAVE_VIEWER_LABEL_WIDTH, 0.0)
	row.add_child(label)

	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


func _create_save_viewer_codec() -> Variant:
	var codec_script := load(SAVE_VIEWER_CODEC_SCRIPT_PATH) as Script
	if codec_script == null or not codec_script.can_instantiate():
		return null
	return codec_script.new()


func _get_save_viewer_selected_format() -> int:
	return _save_viewer_format_option.get_selected_id()


func _set_save_viewer_status(message: String, is_error: bool) -> void:
	if is_instance_valid(_save_viewer_status_label):
		_save_viewer_status_label.text = message
	if is_error:
		push_warning("[GF Save Viewer] " + message)


# --- 信号处理函数 ---

func _on_save_viewer_browse_pressed() -> void:
	if is_instance_valid(_save_viewer_file_dialog):
		_save_viewer_file_dialog.popup_centered_ratio(0.6)


func _on_save_viewer_file_selected(path: String) -> void:
	if is_instance_valid(_save_viewer_path_edit):
		_save_viewer_path_edit.text = path


func _on_save_viewer_load_pressed() -> void:
	var path := _save_viewer_path_edit.text.strip_edges()
	if path.is_empty():
		_set_save_viewer_status("Path is empty.", true)
		return
	if not FileAccess.file_exists(path):
		_set_save_viewer_status("File does not exist: %s" % path, true)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_set_save_viewer_status("Cannot open file: %s" % error_string(FileAccess.get_open_error()), true)
		return

	var bytes := file.get_buffer(file.get_length())
	file.close()

	var codec := _create_save_viewer_codec()
	if codec == null:
		_save_viewer_output.text = ""
		_set_save_viewer_status("Storage codec is unavailable.", true)
		return

	var result: Dictionary = codec.decode(bytes, {
		"format": _get_save_viewer_selected_format(),
		"obfuscation_key": int(_save_viewer_obfuscation_key_spin.value),
		"use_compression": _save_viewer_compression_check.button_pressed,
		"use_integrity_checksum": _save_viewer_checksum_check.button_pressed,
		"strict_integrity": _save_viewer_strict_check.button_pressed,
	})

	if not bool(result.get("ok", false)):
		_save_viewer_output.text = ""
		_set_save_viewer_status(String(result.get("error", "Decode failed")), true)
		return

	var data_value: Variant = result.get("data", {})
	if not (data_value is Dictionary):
		_save_viewer_output.text = ""
		_set_save_viewer_status("Decoded storage payload is not a Dictionary.", true)
		return

	var data := data_value as Dictionary
	_save_viewer_output.text = JSON.stringify(data, "\t")
	_set_save_viewer_status(
		"OK: %d bytes, %d top-level keys, integrity=%s" % [
			bytes.size(),
			data.size(),
			str(result.get("integrity_valid", true)),
		],
		false
	)


func _on_save_viewer_copy_pressed() -> void:
	if _save_viewer_output == null or _save_viewer_output.text.is_empty():
		return
	DisplayServer.clipboard_set(_save_viewer_output.text)
	_set_save_viewer_status("Copied JSON to clipboard.", false)
