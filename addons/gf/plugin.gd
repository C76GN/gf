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
}


# --- 常量 ---

const AUTOLOAD_NAME: String = "Gf"
const AUTOLOAD_PATH: String = "res://addons/gf/core/gf.gd"
const INSTALLERS_SETTING: String = "gf/project/installers"
const INSTALLERS_DEFAULT := []
const ACCESS_OUTPUT_SETTING: String = "gf/codegen/access_output_path"
const ACCESS_OUTPUT_DEFAULT: String = "res://gf/generated/gf_access.gd"
const ACCESS_GENERATOR_SCRIPT_PATH: String = "res://addons/gf/editor/gf_access_generator.gd"
const CAPABILITY_INSPECTOR_PLUGIN_SCRIPT_PATH: String = "res://addons/gf/editor/gf_capability_inspector_plugin.gd"


# --- 私有变量 ---

var _file_dialog: FileDialog
var _current_template_type: String = ""
var _capability_inspector_plugin: EditorInspectorPlugin
var _gf_menu: PopupMenu


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_ensure_autoload()
	_ensure_installers_setting()
	_ensure_codegen_settings()
	_setup_inspector_tools()
	_setup_generator_tools()


func _exit_tree() -> void:
	_remove_autoload()
	_cleanup_inspector_tools()
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
	var inspector_script := load(CAPABILITY_INSPECTOR_PLUGIN_SCRIPT_PATH) as Script
	if inspector_script == null or not inspector_script.can_instantiate():
		push_error("[GF Framework] 能力 Inspector 插件脚本加载失败。")
		return

	_capability_inspector_plugin = inspector_script.new() as EditorInspectorPlugin
	if _capability_inspector_plugin == null:
		push_error("[GF Framework] 能力 Inspector 插件实例化失败。")
		return

	add_inspector_plugin(_capability_inspector_plugin)


func _cleanup_inspector_tools() -> void:
	if _capability_inspector_plugin != null:
		remove_inspector_plugin(_capability_inspector_plugin)
		_capability_inspector_plugin = null


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
