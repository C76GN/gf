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
const MENU_VALIDATE_SAVE_GRAPH: int = 13
const ACCESS_GENERATOR_SCRIPT_PATH: String = "res://addons/gf/editor/gf_access_generator.gd"
const SAVE_GRAPH_UTILITY_SCRIPT_PATH: String = "res://addons/gf/extensions/save/gf_save_graph_utility.gd"
const SAVE_SCOPE_SCRIPT_PATH: String = "res://addons/gf/extensions/save/gf_save_scope.gd"
const DIAGNOSTIC_DIALOG_MIN_SIZE: Vector2 = Vector2(720.0, 460.0)
const GFPluginProjectSettings = preload("res://addons/gf/editor/gf_plugin_project_settings.gd")
const _SCRIPT_TYPE_UTILITY: Script = preload("res://addons/gf/foundation/reflection/gf_script_type_utility.gd")


# --- 私有变量 ---

var _file_dialog: FileDialog
var _current_template_type: String = ""
var _diagnostic_dialog: AcceptDialog
var _diagnostic_output: TextEdit


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


## 清理菜单动作持有的对话框。
func cleanup() -> void:
	_cleanup_diagnostic_dialog()
	if is_instance_valid(_file_dialog):
		_file_dialog.queue_free()
	_file_dialog = null


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
			_show_dialog("Capability")
		MENU_GENERATE_NODE_CAPABILITY:
			_show_dialog("NodeCapability")
		MENU_GENERATE_NODE_2D_CAPABILITY:
			_show_dialog("Node2DCapability")
		MENU_GENERATE_NODE_3D_CAPABILITY:
			_show_dialog("Node3DCapability")
		MENU_GENERATE_CONTROL_CAPABILITY:
			_show_dialog("ControlCapability")
		MENU_GENERATE_NODE_STATE:
			_show_dialog("NodeState")
		MENU_GENERATE_NODE_STATE_MACHINE:
			_show_dialog("NodeStateMachine")
		MENU_GENERATE_ACCESSORS:
			_generate_accessors()
		MENU_GENERATE_PROJECT_ACCESSORS:
			_generate_project_accessors()
		MENU_VALIDATE_SAVE_GRAPH:
			_validate_current_scene_save_graph()


# --- 私有/辅助方法 ---

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


func _validate_current_scene_save_graph() -> void:
	var scene_root := EditorInterface.get_edited_scene_root()
	if scene_root == null:
		_show_diagnostic_dialog("GF SaveGraph Health", "当前没有正在编辑的场景。")
		return

	var scope_script := load(SAVE_SCOPE_SCRIPT_PATH) as Script
	var utility_script := load(SAVE_GRAPH_UTILITY_SCRIPT_PATH) as Script
	if scope_script == null or utility_script == null or not utility_script.can_instantiate():
		_show_diagnostic_dialog("GF SaveGraph Health", "GF SaveGraph 诊断脚本不可用。")
		return

	var scopes: Array[Node] = []
	_collect_save_scopes(scene_root, scope_script, scopes)
	if scopes.is_empty():
		_show_diagnostic_dialog("GF SaveGraph Health", "当前场景未找到 GFSaveScope。")
		return

	var utility: Variant = utility_script.new()
	var lines := PackedStringArray()
	lines.append("Scene: %s" % scene_root.scene_file_path)
	lines.append("Scope count: %d" % scopes.size())
	lines.append("")
	for scope: Node in scopes:
		var report: Dictionary = utility.inspect_scope(scope)
		lines.append("[%s] %s" % [String(scope.get_path()), String(report.get("summary", ""))])
		lines.append("Next: %s" % String(report.get("next_action", "")))
		for issue_variant: Variant in report.get("issues", []):
			var issue := issue_variant as Dictionary
			if issue == null:
				continue
			lines.append("- %s %s %s: %s" % [
				String(issue.get("severity", "")),
				String(issue.get("kind", "")),
				String(issue.get("path", "")),
				String(issue.get("message", "")),
			])
		lines.append("")

	_show_diagnostic_dialog("GF SaveGraph Health", "\n".join(lines))


func _collect_save_scopes(node: Node, scope_script: Script, result: Array[Node]) -> void:
	var node_script := node.get_script() as Script
	if node_script == scope_script or _SCRIPT_TYPE_UTILITY.script_extends_or_equals(node_script, scope_script):
		result.append(node)

	for child: Node in node.get_children():
		_collect_save_scopes(child, scope_script, result)


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
