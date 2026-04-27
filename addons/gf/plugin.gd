@tool
extends EditorPlugin


## GF Framework 编辑器插件。
## 在启用/禁用插件时自动注册/注销 Gf AutoLoad 单例，并提供代码生成工具。

# --- 常量 ---

const AUTOLOAD_NAME: String = "Gf"
const AUTOLOAD_PATH: String = "res://addons/gf/core/gf.gd"
const INSTALLERS_SETTING: String = "gf/project/installers"
const INSTALLERS_DEFAULT := []
const ACCESS_OUTPUT_SETTING: String = "gf/codegen/access_output_path"
const ACCESS_OUTPUT_DEFAULT: String = "res://gf/generated/gf_access.gd"
const GF_ACCESS_GENERATOR_BASE = preload("res://addons/gf/editor/gf_access_generator.gd")


# --- 私有变量 ---

var _file_dialog: FileDialog
var _current_template_type: String = ""


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_ensure_autoload()
	_ensure_installers_setting()
	_ensure_codegen_settings()
	_setup_generator_tools()


func _exit_tree() -> void:
	_remove_autoload()
	_cleanup_generator_tools()


# --- 编辑器工具 ---

func _ensure_autoload() -> void:
	if not ProjectSettings.has_setting("autoload/%s" % AUTOLOAD_NAME):
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)


func _remove_autoload() -> void:
	if ProjectSettings.has_setting("autoload/%s" % AUTOLOAD_NAME):
		remove_autoload_singleton(AUTOLOAD_NAME)


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

	ProjectSettings.add_property_info({
		"name": ACCESS_OUTPUT_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.gd",
	})
	ProjectSettings.set_as_basic(ACCESS_OUTPUT_SETTING, true)

	if should_save:
		ProjectSettings.save()


func _setup_generator_tools() -> void:
	add_tool_menu_item("GF/生成 System", _show_dialog.bind("System"))
	add_tool_menu_item("GF/生成 Model", _show_dialog.bind("Model"))
	add_tool_menu_item("GF/生成 Utility", _show_dialog.bind("Utility"))
	add_tool_menu_item("GF/生成 Command", _show_dialog.bind("Command"))
	add_tool_menu_item("GF/生成强类型访问器", _generate_accessors)
	
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.filters = PackedStringArray(["*.gd ; GDScript Files"])
	_file_dialog.file_selected.connect(_on_file_selected)
	
	var base_control := EditorInterface.get_base_control()
	base_control.add_child(_file_dialog)


func _cleanup_generator_tools() -> void:
	remove_tool_menu_item("GF/生成 System")
	remove_tool_menu_item("GF/生成 Model")
	remove_tool_menu_item("GF/生成 Utility")
	remove_tool_menu_item("GF/生成 Command")
	remove_tool_menu_item("GF/生成强类型访问器")
	
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
	template = template.replace("{BaseClass}", "GF" + _current_template_type)
	
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
	var generator: Variant = GF_ACCESS_GENERATOR_BASE.new()
	var error: Error = generator.generate(output_path)
	if error == OK:
		print("[GF Framework] 成功生成强类型访问器: ", output_path)
	else:
		push_error("[GF Framework] 强类型访问器生成失败: %s" % error_string(error))


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
	elif type == "System":
		return base_template + methods_template + lifecycle_template + tick_template
	else:
		return base_template + methods_template + lifecycle_template
