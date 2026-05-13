@tool

## GF 插件菜单动作与脚本模板生成辅助。
extends RefCounted


# --- 常量 ---

const MENU_GENERATE_SYSTEM: int = 0
const MENU_GENERATE_MODEL: int = 1
const MENU_GENERATE_UTILITY: int = 2
const MENU_GENERATE_COMMAND: int = 3
const MENU_GENERATE_ACCESSORS: int = 11
const MENU_GENERATE_PROJECT_ACCESSORS: int = 12
const TEMPLATE_MENU_ID_START: int = 100
const EXTENSION_MENU_ID_START: int = 1000
const ACCESS_GENERATOR_SCRIPT_PATH: String = "res://addons/gf/kernel/editor/gf_access_generator.gd"
const DIAGNOSTIC_DIALOG_MIN_SIZE: Vector2 = Vector2(720.0, 460.0)
const SECTION_CORE_TEMPLATES: String = "核心模块"
const SECTION_EXTENSION_TEMPLATES: String = "扩展模板"
const SECTION_CODE_GENERATION: String = "代码生成"
const SECTION_EXTENSION_TOOLS: String = "扩展工具"
const GFPluginProjectSettings = preload("res://addons/gf/kernel/editor/gf_plugin_project_settings.gd")
const GFExtensionSettingsBase = preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")


# --- 私有变量 ---

var _file_dialog: FileDialog
var _current_template_type: String = ""
var _diagnostic_dialog: AcceptDialog
var _diagnostic_output: TextEdit
var _extension_action_records: Array[Dictionary] = []
var _menu_action_handlers: Dictionary = {}
var _menu_entries: Array[Dictionary] = []
var _template_records: Dictionary = {}
var _next_template_menu_id: int = TEMPLATE_MENU_ID_START
var _next_extension_menu_id: int = EXTENSION_MENU_ID_START


# --- 公共方法 ---

## 初始化菜单动作需要的文件对话框。
## @param template_records: 根插件或上层组合入口注入的模板记录。
func setup(template_records: Array = []) -> void:
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.filters = PackedStringArray(["*.gd ; GDScript Files"])
	_file_dialog.file_selected.connect(_on_file_selected)

	var base_control := EditorInterface.get_base_control()
	base_control.add_child(_file_dialog)
	_setup_menu_actions(template_records)


## 清理菜单动作持有的对话框。
func cleanup() -> void:
	_cleanup_extension_editor_actions()
	_cleanup_diagnostic_dialog()
	_reset_menu_actions()
	if is_instance_valid(_file_dialog):
		_file_dialog.queue_free()
	_file_dialog = null


## 获取 GF 工具菜单项。
## @return 菜单项字典列表，每项包含 `id`、`label`、`section`。
func get_menu_entries() -> Array[Dictionary]:
	return _menu_entries.duplicate(true)


## 执行 GF 工具菜单对应动作。
## @param id: 菜单项 ID。
func handle_menu_id(id: int) -> void:
	var handler := _menu_action_handlers.get(id, {}) as Dictionary
	if handler.is_empty():
		return

	match StringName(handler.get("kind", &"")):
		&"template":
			_show_dialog(String(handler.get("template_type", "")))
		&"generate_accessors":
			_generate_accessors()
		&"generate_project_accessors":
			_generate_project_accessors()
		&"extension_action":
			_handle_extension_action(handler)


# --- 私有/辅助方法 ---

func _setup_menu_actions(template_records: Array = []) -> void:
	_cleanup_extension_editor_actions()
	_reset_menu_actions()
	_register_template_records(_get_core_template_records())
	_register_template_records(template_records)
	_load_extension_editor_actions()
	_register_fixed_menu_action(
		MENU_GENERATE_ACCESSORS,
		"生成强类型访问器",
		SECTION_CODE_GENERATION,
		&"generate_accessors"
	)
	_register_fixed_menu_action(
		MENU_GENERATE_PROJECT_ACCESSORS,
		"生成项目常量访问器",
		SECTION_CODE_GENERATION,
		&"generate_project_accessors"
	)
	_register_loaded_extension_action_entries()


func _reset_menu_actions() -> void:
	_menu_action_handlers.clear()
	_menu_entries.clear()
	_template_records.clear()
	_next_template_menu_id = TEMPLATE_MENU_ID_START
	_next_extension_menu_id = EXTENSION_MENU_ID_START


func _get_core_template_records() -> Array[Dictionary]:
	return [
		{
			"menu_id": MENU_GENERATE_SYSTEM,
			"type": "System",
			"label": "生成 System",
			"section": SECTION_CORE_TEMPLATES,
			"base_class": "GFSystem",
		},
		{
			"menu_id": MENU_GENERATE_MODEL,
			"type": "Model",
			"label": "生成 Model",
			"section": SECTION_CORE_TEMPLATES,
			"base_class": "GFModel",
		},
		{
			"menu_id": MENU_GENERATE_UTILITY,
			"type": "Utility",
			"label": "生成 Utility",
			"section": SECTION_CORE_TEMPLATES,
			"base_class": "GFUtility",
		},
		{
			"menu_id": MENU_GENERATE_COMMAND,
			"type": "Command",
			"label": "生成 Command",
			"section": SECTION_CORE_TEMPLATES,
			"base_class": "GFCommand",
		},
	]


func _register_template_records(records: Array) -> void:
	for record_variant: Variant in records:
		if record_variant is Dictionary:
			_register_template_record(record_variant as Dictionary)


func _register_template_record(source_record: Dictionary) -> void:
	var template_type := String(source_record.get("type", "")).strip_edges()
	if template_type.is_empty():
		return

	var record := source_record.duplicate(true)
	record["type"] = template_type
	if not record.has("base_class"):
		record["base_class"] = "GF" + template_type

	var menu_id := int(record.get("menu_id", -1))
	if menu_id < 0:
		menu_id = _allocate_template_menu_id()
	if _menu_action_handlers.has(menu_id):
		push_error("[GF Framework] 模板菜单 ID 重复，已跳过: %s" % menu_id)
		return

	var label := String(record.get("label", "生成 " + template_type)).strip_edges()
	if label.is_empty():
		label = "生成 " + template_type
	var section := String(record.get("section", SECTION_EXTENSION_TEMPLATES)).strip_edges()
	if section.is_empty():
		section = SECTION_EXTENSION_TEMPLATES

	_template_records[template_type] = record
	_menu_action_handlers[menu_id] = {
		"kind": &"template",
		"template_type": template_type,
	}
	_append_menu_entry(menu_id, label, section)


func _allocate_template_menu_id() -> int:
	var menu_id := _next_template_menu_id
	while _menu_action_handlers.has(menu_id):
		menu_id += 1
	_next_template_menu_id = menu_id + 1
	return menu_id


func _register_fixed_menu_action(
	menu_id: int,
	label: String,
	section: String,
	handler_kind: StringName
) -> void:
	if _menu_action_handlers.has(menu_id):
		push_error("[GF Framework] 固定菜单 ID 重复，已跳过: %s" % menu_id)
		return

	_menu_action_handlers[menu_id] = {
		"kind": handler_kind,
	}
	_append_menu_entry(menu_id, label, section)


func _append_menu_entry(menu_id: int, label: String, section: String) -> void:
	_menu_entries.append({
		"id": menu_id,
		"label": label,
		"section": section,
	})


func _show_dialog(type: String) -> void:
	if type.is_empty():
		return
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


func _load_extension_editor_actions() -> void:
	_cleanup_extension_editor_actions()
	for script_path: String in GFExtensionSettingsBase.get_enabled_editor_action_paths(true):
		var action := _create_extension_editor_action(script_path)
		if action == null:
			continue
		_extension_action_records.append({
			"instance": action,
			"script_path": script_path,
		})
		if action.has_method("setup"):
			action.setup()
		_register_extension_template_records(action, script_path)


func _create_extension_editor_action(script_path: String) -> RefCounted:
	var script := load(script_path) as Script
	if script == null or not script.can_instantiate():
		push_error("[GF Framework] 扩展编辑器动作加载失败: %s" % script_path)
		return null

	var instance := script.new() as RefCounted
	if instance == null:
		push_error("[GF Framework] 扩展编辑器动作实例化失败: %s" % script_path)
		return null
	return instance


func _register_extension_template_records(action: RefCounted, script_path: String) -> void:
	if not action.has_method("get_template_records"):
		return

	var records_variant: Variant = action.get_template_records()
	if not (records_variant is Array):
		push_error("[GF Framework] 扩展脚本模板声明无效: %s" % script_path)
		return

	var records: Array[Dictionary] = []
	for record_variant: Variant in records_variant:
		if record_variant is Dictionary:
			records.append(record_variant as Dictionary)
	_register_template_records(records)


func _register_loaded_extension_action_entries() -> void:
	for action_record: Dictionary in _extension_action_records:
		var action := action_record.get("instance") as RefCounted
		var script_path := String(action_record.get("script_path", ""))
		if action == null:
			continue
		_register_extension_action_entries(action, script_path)


func _register_extension_action_entries(action: RefCounted, script_path: String) -> void:
	if not action.has_method("get_menu_entries"):
		return

	var entries_variant: Variant = action.get_menu_entries()
	if not (entries_variant is Array):
		push_error("[GF Framework] 扩展编辑器动作菜单声明无效: %s" % script_path)
		return

	for entry_variant: Variant in entries_variant:
		if not (entry_variant is Dictionary):
			continue
		var entry := entry_variant as Dictionary
		var action_id := StringName(entry.get("id", &""))
		var label := String(entry.get("label", "")).strip_edges()
		if action_id == &"" or label.is_empty():
			continue

		var menu_id := _next_extension_menu_id
		_next_extension_menu_id += 1
		var section := String(entry.get("section", SECTION_EXTENSION_TOOLS)).strip_edges()
		if section.is_empty():
			section = SECTION_EXTENSION_TOOLS

		_menu_action_handlers[menu_id] = {
			"kind": &"extension_action",
			"instance": action,
			"action_id": action_id,
		}
		_append_menu_entry(menu_id, label, section)


func _handle_extension_action(handler: Dictionary) -> void:
	var action := handler.get("instance") as RefCounted
	if action == null or not action.has_method("handle_menu_action"):
		return

	action.handle_menu_action(StringName(handler.get("action_id", &"")))


func _cleanup_extension_editor_actions() -> void:
	for action_record: Dictionary in _extension_action_records:
		var action := action_record.get("instance") as RefCounted
		if action != null and action.has_method("cleanup"):
			action.cleanup()
	_extension_action_records.clear()


func _cleanup_diagnostic_dialog() -> void:
	if is_instance_valid(_diagnostic_dialog):
		_diagnostic_dialog.queue_free()
	_diagnostic_dialog = null
	_diagnostic_output = null


func _get_template(type: String) -> String:
	var record := _template_records.get(type, {}) as Dictionary
	if not record.is_empty() and record.has("template"):
		return String(record.get("template", ""))

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
	elif type == "System":
		return base_template + methods_template + lifecycle_template + tick_template
	else:
		return base_template + methods_template + lifecycle_template


func _get_base_class(type: String) -> String:
	var record := _template_records.get(type, {}) as Dictionary
	if not record.is_empty():
		var base_class := String(record.get("base_class", "")).strip_edges()
		if not base_class.is_empty():
			return base_class
	return "GF" + type
