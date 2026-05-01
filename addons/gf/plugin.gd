@tool
extends EditorPlugin


## GF Framework 编辑器插件。
## 在启用/禁用插件时自动注册/注销 Gf AutoLoad 单例，并提供代码生成工具。

# --- 枚举 ---

enum GFMenuId {
	GENERATE_SYSTEM,
	GENERATE_MODEL,
	GENERATE_UTILITY,
	GENERATE_COMMAND,
	GENERATE_CAPABILITY,
	GENERATE_NODE_CAPABILITY,
	GENERATE_NODE_STATE,
	GENERATE_NODE_STATE_MACHINE,
	GENERATE_ACCESSORS,
	GENERATE_PROJECT_ACCESSORS,
}


# --- 常量 ---

const AUTOLOAD_NAME: String = "Gf"
const AUTOLOAD_PATH: String = "res://addons/gf/core/gf.gd"
const INSTALLERS_SETTING: String = "gf/project/installers"
const INSTALLERS_DEFAULT := []
const ACCESS_OUTPUT_SETTING: String = "gf/codegen/access_output_path"
const ACCESS_OUTPUT_DEFAULT: String = "res://gf/generated/gf_access.gd"
const PROJECT_ACCESS_OUTPUT_SETTING: String = "gf/codegen/project_access_output_path"
const PROJECT_ACCESS_OUTPUT_DEFAULT: String = "res://gf/generated/gf_project_access.gd"
const ACCESS_GENERATOR_SCRIPT_PATH: String = "res://addons/gf/editor/gf_access_generator.gd"
const CAPABILITY_INSPECTOR_PLUGIN_SCRIPT_PATH: String = "res://addons/gf/editor/gf_capability_inspector_plugin.gd"
const NODE_STATE_MACHINE_INSPECTOR_PLUGIN_SCRIPT_PATH: String = "res://addons/gf/editor/gf_node_state_machine_inspector_plugin.gd"
const SAVE_VIEWER_CODEC_SCRIPT_PATH: String = "res://addons/gf/utilities/gf_storage_codec.gd"
const SAVE_VIEWER_FORMAT_JSON: int = 0
const SAVE_VIEWER_FORMAT_BINARY: int = 1
const SAVE_VIEWER_LABEL_WIDTH: float = 72.0
const SAVE_VIEWER_OUTPUT_MIN_HEIGHT: float = 40.0


# --- 私有变量 ---

var _file_dialog: FileDialog
var _current_template_type: String = ""
var _capability_inspector_plugin: EditorInspectorPlugin
var _node_state_machine_inspector_plugin: EditorInspectorPlugin
var _save_viewer_dock: Control
var _save_viewer_bottom_button: Button
var _save_viewer_path_edit: LineEdit
var _save_viewer_format_option: OptionButton
var _save_viewer_obfuscation_key_spin: SpinBox
var _save_viewer_compression_check: CheckBox
var _save_viewer_checksum_check: CheckBox
var _save_viewer_strict_check: CheckBox
var _save_viewer_status_label: Label
var _save_viewer_output: TextEdit
var _save_viewer_file_dialog: FileDialog
var _gf_menu: PopupMenu
var _plugin_active: bool = false


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_plugin_active = true
	_ensure_autoload()
	_ensure_installers_setting()
	_ensure_codegen_settings()
	_setup_inspector_tools()
	call_deferred("_setup_save_viewer_dock")
	_setup_generator_tools()


func _exit_tree() -> void:
	_plugin_active = false
	_remove_autoload()
	_cleanup_save_viewer_dock()
	_cleanup_inspector_tools()
	_cleanup_generator_tools()


# --- 编辑器工具 ---

func _ensure_autoload() -> void:
	if not ProjectSettings.has_setting("autoload/%s" % AUTOLOAD_NAME):
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	elif not _autoload_points_to_gf():
		push_warning("[GFPlugin] 已存在名为 Gf 的 AutoLoad，且目标不是 GF Framework；插件不会覆盖该设置。")


func _remove_autoload() -> void:
	if ProjectSettings.has_setting("autoload/%s" % AUTOLOAD_NAME) and _autoload_points_to_gf():
		remove_autoload_singleton(AUTOLOAD_NAME)


func _autoload_points_to_gf() -> bool:
	var setting_path := "autoload/%s" % AUTOLOAD_NAME
	var raw_value: Variant = ProjectSettings.get_setting(setting_path, "")
	var autoload_value := String(raw_value).trim_prefix("*")
	if autoload_value == AUTOLOAD_PATH:
		return true

	var uid := ResourceLoader.get_resource_uid(AUTOLOAD_PATH)
	if uid == -1:
		return false
	return autoload_value == ResourceUID.id_to_text(uid)


func _ensure_installers_setting() -> void:
	var should_save: bool = false

	if not ProjectSettings.has_setting(INSTALLERS_SETTING):
		ProjectSettings.set_setting(INSTALLERS_SETTING, INSTALLERS_DEFAULT)
		ProjectSettings.set_initial_value(INSTALLERS_SETTING, INSTALLERS_DEFAULT)
		should_save = true

	ProjectSettings.add_property_info({
		"name": INSTALLERS_SETTING,
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "%d/%d:*.gd" % [TYPE_STRING, PROPERTY_HINT_FILE],
	})
	ProjectSettings.set_as_basic(INSTALLERS_SETTING, true)

	if should_save:
		ProjectSettings.save()


func _ensure_codegen_settings() -> void:
	var should_save: bool = false

	if not ProjectSettings.has_setting(ACCESS_OUTPUT_SETTING):
		ProjectSettings.set_setting(ACCESS_OUTPUT_SETTING, ACCESS_OUTPUT_DEFAULT)
		ProjectSettings.set_initial_value(ACCESS_OUTPUT_SETTING, ACCESS_OUTPUT_DEFAULT)
		should_save = true

	if not ProjectSettings.has_setting(PROJECT_ACCESS_OUTPUT_SETTING):
		ProjectSettings.set_setting(PROJECT_ACCESS_OUTPUT_SETTING, PROJECT_ACCESS_OUTPUT_DEFAULT)
		ProjectSettings.set_initial_value(PROJECT_ACCESS_OUTPUT_SETTING, PROJECT_ACCESS_OUTPUT_DEFAULT)
		should_save = true

	ProjectSettings.add_property_info({
		"name": ACCESS_OUTPUT_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.gd",
	})
	ProjectSettings.set_as_basic(ACCESS_OUTPUT_SETTING, true)

	ProjectSettings.add_property_info({
		"name": PROJECT_ACCESS_OUTPUT_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.gd",
	})
	ProjectSettings.set_as_basic(PROJECT_ACCESS_OUTPUT_SETTING, true)

	if should_save:
		ProjectSettings.save()


func _setup_generator_tools() -> void:
	_gf_menu = PopupMenu.new()
	_gf_menu.id_pressed.connect(_on_gf_menu_id_pressed)
	_populate_gf_menu()
	add_tool_submenu_item("GF", _gf_menu)
	
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.filters = PackedStringArray(["*.gd ; GDScript Files"])
	_file_dialog.file_selected.connect(_on_file_selected)
	
	var base_control := EditorInterface.get_base_control()
	base_control.add_child(_file_dialog)


func _setup_inspector_tools() -> void:
	_capability_inspector_plugin = _load_inspector_plugin(
		CAPABILITY_INSPECTOR_PLUGIN_SCRIPT_PATH,
		"能力 Inspector"
	)
	if _capability_inspector_plugin != null:
		add_inspector_plugin(_capability_inspector_plugin)

	_node_state_machine_inspector_plugin = _load_inspector_plugin(
		NODE_STATE_MACHINE_INSPECTOR_PLUGIN_SCRIPT_PATH,
		"节点状态机 Inspector"
	)
	if _node_state_machine_inspector_plugin != null:
		add_inspector_plugin(_node_state_machine_inspector_plugin)


func _setup_save_viewer_dock() -> void:
	if not _plugin_active or is_instance_valid(_save_viewer_dock):
		return

	_save_viewer_dock = _create_save_viewer_dock()
	_save_viewer_bottom_button = add_control_to_bottom_panel(_save_viewer_dock, "GF Save Viewer")


func _load_inspector_plugin(script_path: String, label: String) -> EditorInspectorPlugin:
	var inspector_script := load(script_path) as Script
	if inspector_script == null or not inspector_script.can_instantiate():
		push_error("[GF Framework] %s 插件脚本加载失败。" % label)
		return null

	var inspector_plugin := inspector_script.new() as EditorInspectorPlugin
	if inspector_plugin == null:
		push_error("[GF Framework] %s 插件实例化失败。" % label)
		return null

	return inspector_plugin


func _cleanup_inspector_tools() -> void:
	if _capability_inspector_plugin != null:
		remove_inspector_plugin(_capability_inspector_plugin)
		_capability_inspector_plugin = null
	if _node_state_machine_inspector_plugin != null:
		remove_inspector_plugin(_node_state_machine_inspector_plugin)
		_node_state_machine_inspector_plugin = null


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


func _cleanup_generator_tools() -> void:
	remove_tool_menu_item("GF")
	if is_instance_valid(_gf_menu):
		_gf_menu.queue_free()
	_gf_menu = null
	
	if is_instance_valid(_file_dialog):
		_file_dialog.queue_free()


func _show_dialog(type: String) -> void:
	_current_template_type = type
	_file_dialog.title = "生成 GF " + type
	_file_dialog.current_file = "new_" + type.to_lower() + ".gd"
	_file_dialog.popup_centered_ratio(0.5)


func _on_file_selected(path: String) -> void:
	var file_name := path.get_file().get_basename()
	var class_name_str := file_name.to_pascal_case()
			
	var template := _get_template(_current_template_type)
	template = template.replace("{ClassName}", class_name_str)
	template = template.replace("{FileName}", file_name + ".gd")
	template = template.replace("{BaseClass}", _get_base_class(_current_template_type))
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(template)
		file.close()
		EditorInterface.get_resource_filesystem().scan()
		print("[GF Framework] 成功生成文件: ", path)
	else:
		push_error("[GF Framework] 文件生成失败: ", path)


func _generate_accessors() -> void:
	var output_path := String(ProjectSettings.get_setting(ACCESS_OUTPUT_SETTING, ACCESS_OUTPUT_DEFAULT))
	var generator_script := load(ACCESS_GENERATOR_SCRIPT_PATH) as Script
	if generator_script == null or not generator_script.can_instantiate():
		push_error("[GF Framework] 强类型访问器生成器加载失败。")
		return

	var generator: Variant = generator_script.new()
	if generator == null or not generator.has_method("generate"):
		push_error("[GF Framework] 强类型访问器生成器实例化失败。")
		return

	var error: Error = generator.generate(output_path)
	if error == OK:
		print("[GF Framework] 成功生成强类型访问器: ", output_path)
	else:
		push_error("[GF Framework] 强类型访问器生成失败: %s" % error_string(error))


func _generate_project_accessors() -> void:
	var output_path := String(ProjectSettings.get_setting(
		PROJECT_ACCESS_OUTPUT_SETTING,
		PROJECT_ACCESS_OUTPUT_DEFAULT
	))
	var generator_script := load(ACCESS_GENERATOR_SCRIPT_PATH) as Script
	if generator_script == null or not generator_script.can_instantiate():
		push_error("[GF Framework] 项目常量访问器生成器加载失败。")
		return

	var generator: Variant = generator_script.new()
	if generator == null or not generator.has_method("generate_project_access"):
		push_error("[GF Framework] 项目常量访问器生成器实例化失败。")
		return

	var error: Error = generator.generate_project_access(output_path)
	if error == OK:
		print("[GF Framework] 成功生成项目常量访问器: ", output_path)
	else:
		push_error("[GF Framework] 项目常量访问器生成失败: %s" % error_string(error))


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


func _populate_gf_menu() -> void:
	_gf_menu.add_separator("核心模块")
	_gf_menu.add_item("生成 System", GFMenuId.GENERATE_SYSTEM)
	_gf_menu.add_item("生成 Model", GFMenuId.GENERATE_MODEL)
	_gf_menu.add_item("生成 Utility", GFMenuId.GENERATE_UTILITY)
	_gf_menu.add_item("生成 Command", GFMenuId.GENERATE_COMMAND)

	_gf_menu.add_separator("扩展模板")
	_gf_menu.add_item("生成 Capability", GFMenuId.GENERATE_CAPABILITY)
	_gf_menu.add_item("生成 NodeCapability", GFMenuId.GENERATE_NODE_CAPABILITY)
	_gf_menu.add_item("生成 NodeState", GFMenuId.GENERATE_NODE_STATE)
	_gf_menu.add_item("生成 NodeStateMachine", GFMenuId.GENERATE_NODE_STATE_MACHINE)

	_gf_menu.add_separator("代码生成")
	_gf_menu.add_item("生成强类型访问器", GFMenuId.GENERATE_ACCESSORS)
	_gf_menu.add_item("生成项目常量访问器", GFMenuId.GENERATE_PROJECT_ACCESSORS)


func _on_gf_menu_id_pressed(id: int) -> void:
	match id:
		GFMenuId.GENERATE_SYSTEM:
			_show_dialog("System")
		GFMenuId.GENERATE_MODEL:
			_show_dialog("Model")
		GFMenuId.GENERATE_UTILITY:
			_show_dialog("Utility")
		GFMenuId.GENERATE_COMMAND:
			_show_dialog("Command")
		GFMenuId.GENERATE_CAPABILITY:
			_show_dialog("Capability")
		GFMenuId.GENERATE_NODE_CAPABILITY:
			_show_dialog("NodeCapability")
		GFMenuId.GENERATE_NODE_STATE:
			_show_dialog("NodeState")
		GFMenuId.GENERATE_NODE_STATE_MACHINE:
			_show_dialog("NodeStateMachine")
		GFMenuId.GENERATE_ACCESSORS:
			_generate_accessors()
		GFMenuId.GENERATE_PROJECT_ACCESSORS:
			_generate_project_accessors()


func _get_template(type: String) -> String:
	var base_template := """## {ClassName}: TODO。
class_name {ClassName}
extends {BaseClass}


# --- 信号 ---


# --- 枚举 ---


# --- 常量 ---


# --- 导出变量 ---


"""
	
	var lifecycle_template := """# --- Godot 生命周期方法 ---

func init() -> void:
	pass


func async_init() -> void:
	pass


func ready() -> void:
	pass


func dispose() -> void:
	pass


"""

	var tick_template := """func tick(_delta: float) -> void:
	pass


"""

	var methods_template := """# --- 公共变量 ---


# --- 私有变量 ---


# --- @onready 变量 (节点引用) ---


# --- 公共方法 ---


# --- 私有辅助方法 ---


# --- 信号处理函数 ---

"""

	if type == "Command":
		return base_template + """# --- 公共变量 ---


# --- 私有变量 ---


# --- 公共方法 ---

func execute() -> Variant:
	return null


# --- 私有辅助方法 ---

"""
	elif type == "Capability" or type == "NodeCapability":
		return base_template + """# --- 公共变量 ---


# --- 私有变量 ---


# --- @onready 变量 (节点引用) ---


# --- 公共方法 ---

func get_required_capabilities() -> Array[Script]:
	return [] as Array[Script]


func get_dependency_removal_policy() -> int:
	return super.get_dependency_removal_policy()


func on_gf_capability_added(target: Object) -> void:
	super.on_gf_capability_added(target)


func on_gf_capability_removed(target: Object) -> void:
	super.on_gf_capability_removed(target)


func on_gf_capability_active_changed(_target: Object, _active: bool) -> void:
	pass


# --- 私有辅助方法 ---


# --- 信号处理函数 ---

"""
	elif type == "NodeState":
		return base_template + """# --- 公共变量 ---


# --- 私有变量 ---


# --- @onready 变量 (节点引用) ---


# --- 公共方法 ---

func _initialize() -> void:
	pass


func _enter(_previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


func _exit(_next_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


func _pause(_next_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


func _resume(_previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


# --- 私有辅助方法 ---


# --- 信号处理函数 ---

"""
	elif type == "NodeStateMachine":
		return base_template + """# --- 公共变量 ---


# --- 私有变量 ---


# --- @onready 变量 (节点引用) ---


# --- Godot 生命周期方法 ---

func _ready() -> void:
	super._ready()


# --- 公共方法 ---


# --- 私有辅助方法 ---


# --- 信号处理函数 ---

"""
	elif type == "System":
		return base_template + methods_template + lifecycle_template + tick_template
	else:
		return base_template + methods_template + lifecycle_template


func _get_base_class(type: String) -> String:
	match type:
		"NodeState":
			return "GFNodeState"
		"NodeStateMachine":
			return "GFNodeStateMachine"
		_:
			return "GF" + type
