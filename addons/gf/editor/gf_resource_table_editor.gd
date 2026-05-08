@tool

## GFResourceTableEditor: 通用 Resource 表格编辑控件。
##
## 提供资源扫描、属性列提取、表格刷新与单元格提交，不绑定具体资源类型或业务数据。
class_name GFResourceTableEditor
extends VBoxContainer


# --- 信号 ---

## 表格选中资源时发出。
signal resource_selected(resource: Resource)

## 单元格值提交后发出。
signal cell_value_committed(resource: Resource, property: StringName, old_value: Variant, new_value: Variant)


# --- 私有变量 ---

var _resources: Array[Resource] = []
var _columns: Array[Dictionary] = []
var _tree: Tree = null


# --- Godot 生命周期方法 ---

func _ready() -> void:
	_ensure_tree()


# --- 公共方法 ---

## 基于资源属性列表构建可编辑列声明。
## @param resource: 示例资源。
## @param include_read_only: 是否包含只读属性。
## @return 列声明列表。
static func build_export_columns(resource: Resource, include_read_only: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if resource == null:
		return result

	for property_info: Dictionary in resource.get_property_list():
		var usage := int(property_info.get("usage", 0))
		var has_storage := (usage & PROPERTY_USAGE_STORAGE) != 0
		var has_editor := (usage & PROPERTY_USAGE_EDITOR) != 0
		var read_only := (usage & PROPERTY_USAGE_READ_ONLY) != 0
		if not has_storage or not has_editor:
			continue
		if read_only and not include_read_only:
			continue

		result.append({
			"name": StringName(property_info.get("name", "")),
			"type": int(property_info.get("type", TYPE_NIL)),
			"hint": int(property_info.get("hint", PROPERTY_HINT_NONE)),
			"hint_string": str(property_info.get("hint_string", "")),
			"usage": usage,
			"read_only": read_only,
		})
	return result


## 递归扫描资源路径。
## @param root_path: 扫描根路径。
## @param extensions: 文件扩展名白名单，不包含点号。
## @return 资源路径列表。
static func scan_resource_paths(
	root_path: String = "res://",
	extensions: PackedStringArray = PackedStringArray(["tres", "res"])
) -> PackedStringArray:
	var result := PackedStringArray()
	_scan_resource_paths_recursive(root_path, _normalize_extensions(extensions), result)
	result.sort()
	return result


## 从路径列表加载资源。
## @param paths: 资源路径列表。
## @param script_filter: 可选脚本过滤；只返回附加该脚本或其子类脚本的资源。
## @return 资源列表。
static func load_resources_from_paths(paths: PackedStringArray, script_filter: Script = null) -> Array[Resource]:
	var result: Array[Resource] = []
	for path: String in paths:
		var resource := ResourceLoader.load(path) as Resource
		if resource == null:
			continue
		if script_filter != null and not _resource_script_extends_or_equals(resource, script_filter):
			continue
		result.append(resource)
	return result


## 加载资源与列声明。
## @param resources: Resource 列表。
## @param columns: 可选列声明；为空时从第一条资源推导。
func load_resources(resources: Array[Resource], columns: Array[Dictionary] = []) -> void:
	_resources = resources.duplicate()
	_columns = columns.duplicate(true)
	if _columns.is_empty() and not _resources.is_empty():
		_columns = build_export_columns(_resources[0])
	refresh()


## 获取当前资源列表拷贝。
## @return 资源列表。
func get_resources() -> Array[Resource]:
	return _resources.duplicate()


## 获取当前列声明拷贝。
## @return 列声明列表。
func get_columns() -> Array[Dictionary]:
	return _columns.duplicate(true)


## 提交单元格值。
## @param row_index: 资源行索引。
## @param property: 属性名。
## @param new_value: 新值。
## @return 提交成功返回 true。
func commit_cell_value(row_index: int, property: StringName, new_value: Variant) -> bool:
	if row_index < 0 or row_index >= _resources.size() or property == &"":
		return false

	var resource := _resources[row_index]
	if resource == null or not _resource_has_property(resource, property):
		return false

	var old_value: Variant = resource.get(property)
	resource.set(property, new_value)
	cell_value_committed.emit(resource, property, old_value, new_value)
	refresh()
	return true


## 刷新表格显示。
func refresh() -> void:
	_ensure_tree()
	_tree.clear()
	_tree.columns = _columns.size() + 1
	_tree.set_column_title(0, "Resource")
	for column_index: int in range(_columns.size()):
		var column := _columns[column_index] as Dictionary
		_tree.set_column_title(column_index + 1, str(column.get("name", "")))

	var root := _tree.create_item()
	for row_index: int in range(_resources.size()):
		var resource := _resources[row_index]
		if resource == null:
			continue
		var item := _tree.create_item(root)
		item.set_metadata(0, row_index)
		item.set_text(0, _resource_label(resource, row_index))
		for column_index: int in range(_columns.size()):
			var column := _columns[column_index] as Dictionary
			var property := StringName(column.get("name", ""))
			var value: Variant = resource.get(property) if _resource_has_property(resource, property) else null
			item.set_text(column_index + 1, _format_cell_value(value))


# --- 私有/辅助方法 ---

func _ensure_tree() -> void:
	if _tree != null:
		return

	_tree = Tree.new()
	_tree.hide_root = true
	_tree.column_titles_visible = true
	_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.item_selected.connect(_on_tree_item_selected)
	add_child(_tree)


static func _scan_resource_paths_recursive(
	root_path: String,
	extensions: PackedStringArray,
	result: PackedStringArray
) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		var path := "%s/%s" % [root_path.trim_suffix("/"), file_name]
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				_scan_resource_paths_recursive(path, extensions, result)
		else:
			var extension := file_name.get_extension().to_lower()
			if extensions.has(extension):
				result.append(path)
		file_name = dir.get_next()
	dir.list_dir_end()


static func _normalize_extensions(extensions: PackedStringArray) -> PackedStringArray:
	var result := PackedStringArray()
	for extension: String in extensions:
		result.append(extension.trim_prefix(".").to_lower())
	return result


static func _resource_script_extends_or_equals(resource: Resource, script_filter: Script) -> bool:
	var script := resource.get_script() as Script
	while script != null:
		if script == script_filter:
			return true
		script = script.get_base_script()
	return false


func _resource_has_property(resource: Resource, property: StringName) -> bool:
	for property_info: Dictionary in resource.get_property_list():
		if StringName(property_info.get("name", "")) == property:
			return true
	return false


func _resource_label(resource: Resource, row_index: int) -> String:
	if not resource.resource_path.is_empty():
		return resource.resource_path
	return "Resource %d" % row_index


func _format_cell_value(value: Variant) -> String:
	if value is Dictionary or value is Array:
		return JSON.stringify(value)
	return str(value)


# --- 信号处理函数 ---

func _on_tree_item_selected() -> void:
	if _tree == null:
		return

	var item := _tree.get_selected()
	if item == null:
		return

	var row_index := int(item.get_metadata(0))
	if row_index >= 0 and row_index < _resources.size():
		resource_selected.emit(_resources[row_index])
