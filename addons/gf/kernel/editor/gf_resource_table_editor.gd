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

## 自动保存资源失败时发出。
signal resource_save_failed(resource: Resource, path: String, error: Error)

## 资源列表顺序变化后发出。
signal resources_reordered(resources: Array)

## 插入资源后发出。
signal resource_inserted(resource: Resource, index: int)

## 移除资源后发出。
signal resource_removed(resource: Resource, index: int)

## 搜索过滤条件变化后发出。
signal resource_filter_changed(query: String, visible_count: int)


# --- 常量 ---

const DEFAULT_MAX_SCAN_DEPTH: int = 32
const DEFAULT_MAX_RESOURCE_PATHS: int = 10000
const _SCRIPT_TYPE_INSPECTOR: Script = preload("res://addons/gf/kernel/core/gf_script_type_inspector.gd")


# --- 公共变量 ---

## 提交单元格后是否自动保存已绑定路径的 Resource。
var auto_save_committed_resources: bool = false

## 当前搜索过滤文本。为空时显示全部资源。
var search_text: String = ""

## 当前排序属性；为空时不记录排序属性。
var sort_property: StringName = &""

## 当前排序方向。
var sort_ascending: bool = true


# --- 私有变量 ---

var _resources: Array[Resource] = []
var _columns: Array[Dictionary] = []
var _visible_row_indices: PackedInt32Array = PackedInt32Array()
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
## @param options: 可选参数，支持 `max_scan_depth` 与 `max_resource_paths`。
## @return 资源路径列表。
static func scan_resource_paths(
	root_path: String = "res://",
	extensions: PackedStringArray = PackedStringArray(["tres", "res"]),
	options: Dictionary = {}
) -> PackedStringArray:
	var result := PackedStringArray()
	var max_scan_depth := maxi(int(options.get("max_scan_depth", DEFAULT_MAX_SCAN_DEPTH)), 0)
	var max_resource_paths := maxi(int(options.get("max_resource_paths", DEFAULT_MAX_RESOURCE_PATHS)), 0)
	var scan_state := _make_scan_state()
	_scan_resource_paths_recursive(
		root_path,
		_normalize_extensions(extensions),
		result,
		0,
		max_scan_depth,
		max_resource_paths,
		scan_state
	)
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
		if script_filter != null and not _resource_matches_script_filter(resource, script_filter):
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


## 设置搜索过滤文本。
## @param query: 搜索文本，会匹配资源标签、路径和当前列值。
func set_search_text(query: String) -> void:
	if search_text == query:
		return
	search_text = query
	refresh()
	resource_filter_changed.emit(search_text, _visible_row_indices.size())


## 获取当前可见资源行的原始索引。
## @return 可见行索引列表。
func get_visible_row_indices() -> PackedInt32Array:
	return PackedInt32Array(_visible_row_indices)


## 获取当前可见资源数量。
## @return 可见资源数量。
func get_visible_resource_count() -> int:
	return _visible_row_indices.size()


## 查找资源在当前列表中的索引。
## @param resource: 目标资源。
## @return 资源索引；不存在时返回 -1。
func find_resource_index(resource: Resource) -> int:
	return _resources.find(resource)


## 按属性或资源标签排序。
## @param property: 属性名；为空时按资源标签排序。
## @param ascending: 是否升序。
func sort_by_property(property: StringName = &"", ascending: bool = true) -> void:
	sort_property = property
	sort_ascending = ascending
	_resources.sort_custom(func(left: Resource, right: Resource) -> bool:
		var compare_result := _compare_resources_for_sort(left, right, property)
		if compare_result == 0:
			return false
		return compare_result < 0 if ascending else compare_result > 0
	)
	refresh()
	resources_reordered.emit(get_resources())


## 移动资源位置。
## @param from_index: 原始索引。
## @param to_index: 目标索引。
## @return 移动成功返回 true。
func move_resource(from_index: int, to_index: int) -> bool:
	if from_index < 0 or from_index >= _resources.size():
		return false
	if _resources.is_empty():
		return false
	var target_index := clampi(to_index, 0, _resources.size() - 1)
	if from_index == target_index:
		return true

	var resource := _resources[from_index]
	_resources.remove_at(from_index)
	_resources.insert(target_index, resource)
	refresh()
	resources_reordered.emit(get_resources())
	return true


## 插入资源。
## @param resource: 要插入的资源。
## @param index: 插入索引；越界或负数时追加到末尾。
## @return 插入成功返回 true。
func insert_resource(resource: Resource, index: int = -1) -> bool:
	if resource == null:
		return false
	var target_index := index
	if target_index < 0 or target_index > _resources.size():
		target_index = _resources.size()
	_resources.insert(target_index, resource)
	if _columns.is_empty():
		_columns = build_export_columns(resource)
	refresh()
	resource_inserted.emit(resource, target_index)
	return true


## 移除资源。
## @param row_index: 资源行索引。
## @return 被移除的资源；无效索引返回 null。
func remove_resource(row_index: int) -> Resource:
	if row_index < 0 or row_index >= _resources.size():
		return null
	var resource := _resources[row_index]
	_resources.remove_at(row_index)
	refresh()
	resource_removed.emit(resource, row_index)
	return resource


## 复制资源并插入到列表。
## @param row_index: 资源行索引。
## @param deep: 是否深拷贝子资源。
## @param insert_after: 为 true 时插入到当前资源之后，否则插入到当前位置。
## @return 复制出的资源；无效索引返回 null。
func duplicate_resource(row_index: int, deep: bool = false, insert_after: bool = true) -> Resource:
	if row_index < 0 or row_index >= _resources.size():
		return null
	var source := _resources[row_index]
	if source == null:
		return null
	var duplicate := source.duplicate(deep) as Resource
	if duplicate == null:
		return null
	var target_index := row_index + 1 if insert_after else row_index
	_resources.insert(target_index, duplicate)
	refresh()
	resource_inserted.emit(duplicate, target_index)
	return duplicate


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
	_save_resource_if_requested(resource)
	refresh()
	return true


## 提交当前可见行的单元格值。
## @param visible_row_index: 过滤后的可见行索引。
## @param property: 属性名。
## @param new_value: 新值。
## @return 提交成功返回 true。
func commit_visible_cell_value(visible_row_index: int, property: StringName, new_value: Variant) -> bool:
	if visible_row_index < 0 or visible_row_index >= _visible_row_indices.size():
		return false
	return commit_cell_value(_visible_row_indices[visible_row_index], property, new_value)


## 刷新表格显示。
func refresh() -> void:
	_ensure_tree()
	_rebuild_visible_row_indices()
	_tree.clear()
	_tree.columns = _columns.size() + 1
	_tree.set_column_title(0, "Resource")
	for column_index: int in range(_columns.size()):
		var column := _columns[column_index] as Dictionary
		_tree.set_column_title(column_index + 1, str(column.get("name", "")))

	var root := _tree.create_item()
	for row_index: int in _visible_row_indices:
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


func _rebuild_visible_row_indices() -> void:
	_visible_row_indices = PackedInt32Array()
	for row_index: int in range(_resources.size()):
		var resource := _resources[row_index]
		if resource == null:
			continue
		if _resource_matches_search(resource, row_index, search_text):
			_visible_row_indices.append(row_index)


static func _scan_resource_paths_recursive(
	root_path: String,
	extensions: PackedStringArray,
	result: PackedStringArray,
	depth: int,
	max_scan_depth: int,
	max_resource_paths: int,
	scan_state: Dictionary
) -> void:
	if not _can_collect_more_resource_paths(result, max_resource_paths):
		_warn_resource_path_limit(max_resource_paths, scan_state)
		return

	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not _can_collect_more_resource_paths(result, max_resource_paths):
			_warn_resource_path_limit(max_resource_paths, scan_state)
			break

		var path := "%s/%s" % [root_path.trim_suffix("/"), file_name]
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				if _can_scan_deeper(path, depth, max_scan_depth, scan_state):
					_scan_resource_paths_recursive(
						path,
						extensions,
						result,
						depth + 1,
						max_scan_depth,
						max_resource_paths,
						scan_state
					)
		else:
			var extension := file_name.get_extension().to_lower()
			if extensions.has(extension):
				result.append(path)
		file_name = dir.get_next()
	dir.list_dir_end()


static func _can_scan_deeper(path: String, current_depth: int, max_scan_depth: int, scan_state: Dictionary) -> bool:
	if max_scan_depth <= 0 or current_depth < max_scan_depth:
		return true
	_warn_scan_depth_limit(path, max_scan_depth, scan_state)
	return false


static func _can_collect_more_resource_paths(result: PackedStringArray, max_resource_paths: int) -> bool:
	return max_resource_paths <= 0 or result.size() < max_resource_paths


static func _make_scan_state() -> Dictionary:
	return {
		"count_warning_emitted": false,
		"depth_warning_emitted": false,
	}


static func _warn_resource_path_limit(max_resource_paths: int, scan_state: Dictionary) -> void:
	if max_resource_paths <= 0 or bool(scan_state.get("count_warning_emitted", false)):
		return
	scan_state["count_warning_emitted"] = true
	push_warning("[GFResourceTableEditor] scan_resource_paths 已达到 max_resource_paths=%d，后续资源已跳过。" % max_resource_paths)


static func _warn_scan_depth_limit(path: String, max_scan_depth: int, scan_state: Dictionary) -> void:
	if max_scan_depth <= 0 or bool(scan_state.get("depth_warning_emitted", false)):
		return
	scan_state["depth_warning_emitted"] = true
	push_warning("[GFResourceTableEditor] scan_resource_paths 已达到 max_scan_depth=%d，已跳过更深目录：%s。" % [max_scan_depth, path])


static func _normalize_extensions(extensions: PackedStringArray) -> PackedStringArray:
	var result := PackedStringArray()
	for extension: String in extensions:
		result.append(extension.trim_prefix(".").to_lower())
	return result


static func _resource_matches_script_filter(resource: Resource, script_filter: Script) -> bool:
	return _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(resource.get_script() as Script, script_filter)


func _resource_has_property(resource: Resource, property: StringName) -> bool:
	for property_info: Dictionary in resource.get_property_list():
		if StringName(property_info.get("name", "")) == property:
			return true
	return false


func _resource_matches_search(resource: Resource, row_index: int, query: String) -> bool:
	var normalized_query := query.strip_edges().to_lower()
	if normalized_query.is_empty():
		return true

	var label := _resource_label(resource, row_index).to_lower()
	if label.contains(normalized_query):
		return true
	if resource.get_class().to_lower().contains(normalized_query):
		return true

	var script := resource.get_script() as Script
	if script != null and script.resource_path.to_lower().contains(normalized_query):
		return true

	for column: Dictionary in _columns:
		var property := StringName(column.get("name", ""))
		if property == &"" or not _resource_has_property(resource, property):
			continue
		if _format_cell_value(resource.get(property)).to_lower().contains(normalized_query):
			return true
	return false


func _compare_resources_for_sort(left: Resource, right: Resource, property: StringName) -> int:
	if left == right:
		return 0
	if left == null:
		return 1
	if right == null:
		return -1

	if property == &"":
		return _compare_variant_values(_resource_label(left, _resources.find(left)), _resource_label(right, _resources.find(right)))

	var left_value: Variant = left.get(property) if _resource_has_property(left, property) else null
	var right_value: Variant = right.get(property) if _resource_has_property(right, property) else null
	return _compare_variant_values(left_value, right_value)


func _compare_variant_values(left: Variant, right: Variant) -> int:
	if left == right:
		return 0
	if left == null:
		return 1
	if right == null:
		return -1

	var left_type := typeof(left)
	var right_type := typeof(right)
	if _is_numeric_type(left_type) and _is_numeric_type(right_type):
		return _compare_float_values(float(left), float(right))
	if left_type == TYPE_BOOL and right_type == TYPE_BOOL:
		return _compare_float_values(1.0 if bool(left) else 0.0, 1.0 if bool(right) else 0.0)

	var left_text := str(left)
	var right_text := str(right)
	return left_text.naturalnocasecmp_to(right_text)


func _compare_float_values(left: float, right: float) -> int:
	if left < right:
		return -1
	if left > right:
		return 1
	return 0


func _is_numeric_type(type_id: int) -> bool:
	return type_id == TYPE_INT or type_id == TYPE_FLOAT


func _save_resource_if_requested(resource: Resource) -> void:
	if not auto_save_committed_resources:
		return

	var path := resource.resource_path
	if path.is_empty():
		return

	var error := ResourceSaver.save(resource, path)
	if error != OK:
		resource_save_failed.emit(resource, path, error)


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
