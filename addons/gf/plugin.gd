@tool
extends EditorPlugin


## GF Framework 编辑器插件。
## 在启用/禁用插件时自动注册/注销 Gf AutoLoad 单例，并提供代码生成工具。

var _file_dialog: FileDialog
var _current_template_type: String = ""


func _enter_tree() -> void:
	add_autoload_singleton("Gf", "res://addons/gf/core/gf.gd")
	
	_setup_generator_tools()


func _exit_tree() -> void:
	remove_autoload_singleton("Gf")
	
	_cleanup_generator_tools()


# --- 编辑器工具 ---

func _setup_generator_tools() -> void:
	add_tool_menu_item("GF/生成 System", _show_dialog.bind("System"))
	add_tool_menu_item("GF/生成 Model", _show_dialog.bind("Model"))
	add_tool_menu_item("GF/生成 Utility", _show_dialog.bind("Utility"))
	add_tool_menu_item("GF/生成 Command", _show_dialog.bind("Command"))
	
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


func _get_template(type: String) -> String:
	var base_template := """# {FileName}
class_name {ClassName}
extends {BaseClass}


## {ClassName}: 

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
