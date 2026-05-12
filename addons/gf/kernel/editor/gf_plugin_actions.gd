@tool

## GF 插件菜单动作与脚本模板生成辅助。
extends RefCounted


# --- 常量 ---

const MENU_GENERATE_SYSTEM: int = 0
const MENU_GENERATE_MODEL: int = 1
const MENU_GENERATE_UTILITY: int = 2
const MENU_GENERATE_COMMAND: int = 3
const MENU_GENERATE_CAPABILITY: int = 4
const MENU_GENERATE_NODE_CAPABILITY: int = 5
const MENU_GENERATE_NODE_2D_CAPABILITY: int = 6
const MENU_GENERATE_NODE_3D_CAPABILITY: int = 7
const MENU_GENERATE_CONTROL_CAPABILITY: int = 8
const MENU_GENERATE_NODE_STATE: int = 9
const MENU_GENERATE_NODE_STATE_MACHINE: int = 10
const MENU_GENERATE_ACCESSORS: int = 11
const MENU_GENERATE_PROJECT_ACCESSORS: int = 12
const PACKAGE_MENU_ID_START: int = 1000
const ACCESS_GENERATOR_SCRIPT_PATH: String = "res://addons/gf/kernel/editor/gf_access_generator.gd"
const CAPABILITY_PACKAGE_ID: String = "gf.official.capability"
const DIAGNOSTIC_DIALOG_MIN_SIZE: Vector2 = Vector2(720.0, 460.0)
const GFPluginProjectSettings = preload("res://addons/gf/kernel/editor/gf_plugin_project_settings.gd")
const GFPackageSettingsBase = preload("res://addons/gf/kernel/package/gf_package_settings.gd")


# --- 私有变量 ---

var _file_dialog: FileDialog
var _current_template_type: String = ""
var _diagnostic_dialog: AcceptDialog
var _diagnostic_output: TextEdit
var _package_action_instances: Array[RefCounted] = []
var _package_action_handlers: Dictionary = {}
var _package_menu_entries: Array[Dictionary] = []
var _next_package_menu_id: int = PACKAGE_MENU_ID_START


# --- 公共方法 ---

## 初始化菜单动作需要的文件对话框。
func setup() -> void:
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.filters = PackedStringArray(["*.gd ; GDScript Files"])
	_file_dialog.file_selected.connect(_on_file_selected)

	var base_control := EditorInterface.get_base_control()
	base_control.add_child(_file_dialog)
	_load_package_editor_actions()


## 清理菜单动作持有的对话框。
func cleanup() -> void:
	_cleanup_package_editor_actions()
	_cleanup_diagnostic_dialog()
	if is_instance_valid(_file_dialog):
		_file_dialog.queue_free()
	_file_dialog = null


## 获取启用包注册的菜单项。
## @return 菜单项字典列表，每项包含 `id`、`label`、`section`。
func get_package_menu_entries() -> Array[Dictionary]:
	return _package_menu_entries.duplicate(true)


## 执行 GF 工具菜单对应动作。
## @param id: 菜单项 ID。
func handle_menu_id(id: int) -> void:
	match id:
		MENU_GENERATE_SYSTEM:
			_show_dialog("System")
		MENU_GENERATE_MODEL:
			_show_dialog("Model")
		MENU_GENERATE_UTILITY:
			_show_dialog("Utility")
		MENU_GENERATE_COMMAND:
			_show_dialog("Command")
		MENU_GENERATE_CAPABILITY:
			if not _require_package_enabled(CAPABILITY_PACKAGE_ID, "GF Capability"):
				return
			_show_dialog("Capability")
		MENU_GENERATE_NODE_CAPABILITY:
			if not _require_package_enabled(CAPABILITY_PACKAGE_ID, "GF Capability"):
				return
			_show_dialog("NodeCapability")
		MENU_GENERATE_NODE_2D_CAPABILITY:
			if not _require_package_enabled(CAPABILITY_PACKAGE_ID, "GF Capability"):
				return
			_show_dialog("Node2DCapability")
		MENU_GENERATE_NODE_3D_CAPABILITY:
			if not _require_package_enabled(CAPABILITY_PACKAGE_ID, "GF Capability"):
				return
			_show_dialog("Node3DCapability")
		MENU_GENERATE_CONTROL_CAPABILITY:
			if not _require_package_enabled(CAPABILITY_PACKAGE_ID, "GF Capability"):
				return
			_show_dialog("ControlCapability")
		MENU_GENERATE_NODE_STATE:
			_show_dialog("NodeState")
		MENU_GENERATE_NODE_STATE_MACHINE:
			_show_dialog("NodeStateMachine")
		MENU_GENERATE_ACCESSORS:
			_generate_accessors()
		MENU_GENERATE_PROJECT_ACCESSORS:
			_generate_project_accessors()
		_:
			_handle_package_menu_id(id)


# --- 私有/辅助方法 ---

func _require_package_enabled(package_id: String, display_name: String) -> bool:
	if GFPackageSettingsBase.is_package_enabled(package_id):
		return true

	_show_diagnostic_dialog(
		"GF Package Disabled",
		"%s 包当前未启用。请先在 GF Packages 面板启用该包，再使用对应编辑器工具。" % display_name
	)
	return false


func _show_dialog(type: String) -> void:
	_current_template_type = type
	_file_dialog.title = "生成 GF " + type
	_file_dialog.current_file = "new_" + type.to_lower() + ".gd"
	_file_dialog.popup_centered_ratio(0.5)


func _on_file_selected(path: String) -> void:
	if FileAccess.file_exists(path):
		push_error("[GF Framework] 文件已存在，已取消生成: %s" % path)
		return

	var file_name := path.get_file().get_basename()
	var class_name_str := file_name.to_pascal_case()
	var template := _get_template(_current_template_type)
	template = template.replace("{ClassName}", class_name_str)
	template = template.replace("{FileName}", file_name + ".gd")
	template = template.replace("{BaseClass}", _get_base_class(_current_template_type))

	var dir_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	if dir_error != OK:
		push_error("[GF Framework] 文件目录创建失败: %s" % error_string(dir_error))
		return

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(template)
		file.close()
		EditorInterface.get_resource_filesystem().scan()
		print("[GF Framework] 成功生成文件: ", path)
	else:
		push_error("[GF Framework] 文件生成失败: ", path)


func _generate_accessors() -> void:
	var output_path := GFPluginProjectSettings.get_access_output_path()
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
	var output_path := GFPluginProjectSettings.get_project_access_output_path()
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


func _show_diagnostic_dialog(title: String, text: String) -> void:
	if not is_instance_valid(_diagnostic_dialog):
		_diagnostic_dialog = AcceptDialog.new()
		var dialog_min_size := Vector2i(
			int(DIAGNOSTIC_DIALOG_MIN_SIZE.x),
			int(DIAGNOSTIC_DIALOG_MIN_SIZE.y)
		)
		_diagnostic_dialog.min_size = dialog_min_size
		_diagnostic_output = TextEdit.new()
		_diagnostic_output.editable = false
		_diagnostic_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_diagnostic_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_diagnostic_dialog.add_child(_diagnostic_output)
		EditorInterface.get_base_control().add_child(_diagnostic_dialog)

	_diagnostic_dialog.title = title
	if is_instance_valid(_diagnostic_output):
		_diagnostic_output.text = text
	_diagnostic_dialog.popup_centered(Vector2i(
		int(DIAGNOSTIC_DIALOG_MIN_SIZE.x),
		int(DIAGNOSTIC_DIALOG_MIN_SIZE.y)
	))


func _load_package_editor_actions() -> void:
	_cleanup_package_editor_actions()
	for script_path: String in GFPackageSettingsBase.get_enabled_editor_action_paths(true):
		var action := _create_package_editor_action(script_path)
		if action == null:
			continue
		_package_action_instances.append(action)
		if action.has_method("setup"):
			action.setup()
		_register_package_action_entries(action, script_path)


func _create_package_editor_action(script_path: String) -> RefCounted:
	var script := load(script_path) as Script
	if script == null or not script.can_instantiate():
		push_error("[GF Framework] 包编辑器动作加载失败: %s" % script_path)
		return null

	var instance := script.new() as RefCounted
	if instance == null:
		push_error("[GF Framework] 包编辑器动作实例化失败: %s" % script_path)
		return null
	return instance


func _register_package_action_entries(action: RefCounted, script_path: String) -> void:
	if not action.has_method("get_menu_entries"):
		return

	var entries_variant: Variant = action.get_menu_entries()
	if not (entries_variant is Array):
		push_error("[GF Framework] 包编辑器动作菜单声明无效: %s" % script_path)
		return

	for entry_variant: Variant in entries_variant:
		var entry := entry_variant as Dictionary
		if entry == null:
			continue

		var action_id := StringName(entry.get("id", &""))
		var label := String(entry.get("label", "")).strip_edges()
		if action_id == &"" or label.is_empty():
			continue

		var menu_id := _next_package_menu_id
		_next_package_menu_id += 1
		var section := String(entry.get("section", "扩展诊断")).strip_edges()
		if section.is_empty():
			section = "扩展诊断"

		_package_action_handlers[menu_id] = {
			"instance": action,
			"action_id": action_id,
		}
		_package_menu_entries.append({
			"id": menu_id,
			"label": label,
			"section": section,
		})


func _handle_package_menu_id(id: int) -> void:
	if not _package_action_handlers.has(id):
		return

	var handler := _package_action_handlers[id] as Dictionary
	if handler == null:
		return

	var action := handler.get("instance") as RefCounted
	if action == null or not action.has_method("handle_menu_action"):
		return

	action.handle_menu_action(StringName(handler.get("action_id", &"")))


func _cleanup_package_editor_actions() -> void:
	for action: RefCounted in _package_action_instances:
		if action != null and action.has_method("cleanup"):
			action.cleanup()
	_package_action_instances.clear()
	_package_action_handlers.clear()
	_package_menu_entries.clear()
	_next_package_menu_id = PACKAGE_MENU_ID_START


func _cleanup_diagnostic_dialog() -> void:
	if is_instance_valid(_diagnostic_dialog):
		_diagnostic_dialog.queue_free()
	_diagnostic_dialog = null
	_diagnostic_output = null


func _get_template(type: String) -> String:
	var base_template := """## {ClassName}: TODO。
class_name {ClassName}
extends {BaseClass}


# --- 信号 ---


# --- 枚举 ---


# --- 常量 ---


# --- 导出变量 ---


"""

	var lifecycle_template := """# --- GF 生命周期方法 ---

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


# --- 私有/辅助方法 ---


# --- 信号处理函数 ---

"""

	if type == "Command":
		return base_template + """# --- 公共变量 ---


# --- 私有变量 ---


# --- 公共方法 ---

func execute() -> Variant:
	return null


# --- 私有/辅助方法 ---

"""
	elif (
		type == "Capability"
		or type == "NodeCapability"
		or type == "Node2DCapability"
		or type == "Node3DCapability"
		or type == "ControlCapability"
	):
		return base_template + """# --- 公共变量 ---


# --- 私有变量 ---


# --- @onready 变量 (节点引用) ---


# --- 公共方法 ---

func get_required_capabilities() -> Array[Script]:
	return [] as Array[Script]


func get_dependency_removal_policy() -> int:
	return super.get_dependency_removal_policy()


## 处理能力添加通知。
## @param target: 交互目标对象。
func on_gf_capability_added(target: Object) -> void:
	super.on_gf_capability_added(target)


## 处理能力移除通知。
## @param target: 交互目标对象。
func on_gf_capability_removed(target: Object) -> void:
	super.on_gf_capability_removed(target)


## 处理能力激活状态变化通知。
## @param _target: 能力目标对象，默认回调不直接使用。
## @param _active: 能力激活状态，默认回调不直接使用。
func on_gf_capability_active_changed(_target: Object, _active: bool) -> void:
	pass


# --- 私有/辅助方法 ---


# --- 信号处理函数 ---

"""
	elif type == "NodeState":
		return base_template + """# --- 公共变量 ---


# --- 私有变量 ---


# --- @onready 变量 (节点引用) ---


# --- 公共方法 ---


# --- 虚方法（由子类重写） ---

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


# --- 私有/辅助方法 ---


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


# --- 私有/辅助方法 ---


# --- 信号处理函数 ---

"""
	elif type == "System":
		return base_template + methods_template + lifecycle_template + tick_template
	else:
		return base_template + methods_template + lifecycle_template


func _get_base_class(type: String) -> String:
	match type:
		"Node2DCapability":
			return "GFNode2DCapability"
		"Node3DCapability":
			return "GFNode3DCapability"
		"ControlCapability":
			return "GFControlCapability"
		"NodeState":
			return "GFNodeState"
		"NodeStateMachine":
			return "GFNodeStateMachine"
		_:
			return "GF" + type
