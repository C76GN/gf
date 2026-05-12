## 验证 GF 源码脚本可被 Godot 解析加载。
extends GutTest


# --- 常量 ---

const SOURCE_ROOT: String = "res://addons/gf"


# --- 测试用例 ---

func test_gf_source_scripts_load_without_parse_errors() -> void:
	var script_paths := _collect_gdscript_files(SOURCE_ROOT)
	var issues: Array[String] = []
	for path: String in script_paths:
		var resource := load(path)
		if resource == null:
			issues.append("%s: load returned null" % path)
			continue
		if not (resource is Script):
			issues.append("%s: loaded resource is not a Script" % path)

	assert_eq(issues, [], "GF 源码脚本应能被 Godot 解析加载：\n%s" % _join_lines(issues))


# --- 私有/辅助方法 ---

func _collect_gdscript_files(root_path: String) -> Array[String]:
	var result: Array[String] = []
	_collect_gdscript_files_recursive(root_path, result)
	result.sort()
	return result


func _collect_gdscript_files_recursive(root_path: String, result: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var child_path := root_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_collect_gdscript_files_recursive(child_path, result)
		elif entry.ends_with(".gd"):
			result.append(child_path)
		entry = dir.get_next()
	dir.list_dir_end()


func _join_lines(values: Array[String]) -> String:
	if values.is_empty():
		return ""

	var packed := PackedStringArray()
	for value: String in values:
		packed.append(value)
	return "\n".join(packed)
