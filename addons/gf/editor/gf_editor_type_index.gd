@tool

## GFEditorTypeIndex: 编辑器侧 GF 类型查询工具。
##
## 集中扫描 class_name 脚本与能力场景，供代码生成器和 Inspector 工具复用。
class_name GFEditorTypeIndex
extends RefCounted


# --- 私有变量 ---

var _script_cache: Dictionary = {}
var _scene_root_script_cache: Dictionary = {}


# --- 公共方法 ---

## 收集继承指定脚本基类的全局脚本类。
func collect_scripts_extending(base_script: Script, excluded_scripts: Array[Script] = []) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if base_script == null:
		return records

	var used_paths: Dictionary = {}
	for global_class: Dictionary in ProjectSettings.get_global_class_list():
		var class_name_value := String(global_class.get("class", ""))
		var path := String(global_class.get("path", ""))
		if class_name_value.is_empty() or path.is_empty() or used_paths.has(path):
			continue

		var script := _load_script(path)
		if script == null or excluded_scripts.has(script):
			continue
		if not _script_extends_or_equals(script, base_script):
			continue

		used_paths[path] = true
		records.append({
			"class_name": class_name_value,
			"path": path,
			"script": script,
		})

	records.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return String(left["class_name"]) < String(right["class_name"])
	)
	return records


## 收集根脚本继承指定基类的场景。
func collect_scene_roots_extending(base_script: Script, used_paths: Dictionary = {}) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if base_script == null or not Engine.is_editor_hint():
		return records

	var filesystem := EditorInterface.get_resource_filesystem()
	if filesystem == null:
		return records

	var root_dir := filesystem.get_filesystem()
	if root_dir == null:
		return records

	var dir_stack: Array[EditorFileSystemDirectory] = [root_dir]
	while not dir_stack.is_empty():
		var current_dir := dir_stack.pop_back()
		for i: int in range(current_dir.get_subdir_count()):
			dir_stack.append(current_dir.get_subdir(i))

		for i: int in range(current_dir.get_file_count()):
			if current_dir.get_file_type(i) != "PackedScene":
				continue

			var path := _join_resource_path(current_dir.get_path(), current_dir.get_file(i))
			if used_paths.has(path):
				continue

			var script := get_scene_root_script(path)
			if script == null or not _script_extends_or_equals(script, base_script):
				continue

			used_paths[path] = true
			records.append({
				"path": path,
				"script": script,
				"display_name": path.get_file().get_basename().to_pascal_case(),
			})

	records.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return String(left["display_name"]) < String(right["display_name"])
	)
	return records


## 获取 PackedScene 根节点脚本。
func get_scene_root_script(path: String) -> Script:
	if _scene_root_script_cache.has(path):
		return _scene_root_script_cache[path] as Script

	var packed_scene := load(path) as PackedScene
	if packed_scene == null:
		_scene_root_script_cache[path] = null
		return null

	var state := packed_scene.get_state()
	if state == null:
		_scene_root_script_cache[path] = null
		return null

	for node_index: int in range(state.get_node_count()):
		if not state.get_node_path(node_index, true).is_empty():
			continue

		for property_index: int in range(state.get_node_property_count(node_index)):
			if state.get_node_property_name(node_index, property_index) == &"script":
				var script := state.get_node_property_value(node_index, property_index) as Script
				_scene_root_script_cache[path] = script
				return script

	_scene_root_script_cache[path] = null
	return null


## 清空脚本和场景根脚本缓存。
func clear_cache() -> void:
	_script_cache.clear()
	_scene_root_script_cache.clear()


# --- 私有/辅助方法 ---

func _load_script(path: String) -> Script:
	if _script_cache.has(path):
		return _script_cache[path] as Script

	var script := load(path) as Script
	_script_cache[path] = script
	return script


func _join_resource_path(dir_path: String, file_name: String) -> String:
	if dir_path.ends_with("/"):
		return dir_path + file_name
	return "%s/%s" % [dir_path, file_name]


func _script_extends_or_equals(candidate: Script, expected: Script) -> bool:
	var current: Script = candidate
	while current != null:
		if current == expected:
			return true
		current = current.get_base_script()
	return false
