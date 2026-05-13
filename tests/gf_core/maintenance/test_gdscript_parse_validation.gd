## 验证 GF 源码脚本可被 Godot 解析加载。
extends GutTest


# --- 常量 ---

const SOURCE_ROOT: String = "res://addons/gf"
const REMOVED_PUBLIC_CLASS_NAMES: Array[String] = [
	"GFShakeAction",
	"GFInputUtility",
	"GFValidationUtility",
	"GFDecimalStringUtility",
	"GFScriptTypeUtility",
	"GFTagUtility",
	"GFTextFitUtility",
	"GFNodeTreeUtility",
	"GFVariantUtility",
	"GFAttribute",
]


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


func test_removed_public_class_names_do_not_remain_in_runtime_source() -> void:
	var script_paths := _collect_gdscript_files(SOURCE_ROOT)
	var issues: Array[String] = []
	for path: String in script_paths:
		var source := _read_text(path)
		for removed_class_name: String in REMOVED_PUBLIC_CLASS_NAMES:
			if _contains_identifier(source, removed_class_name):
				issues.append("%s contains removed class name %s" % [path, removed_class_name])

	assert_eq(
		issues,
		[],
		"`addons/gf` 运行时代码不应保留已移除公开类名的副本。"
	)


func test_public_class_names_are_unique() -> void:
	var script_paths := _collect_gdscript_files(SOURCE_ROOT)
	var paths_by_class_name: Dictionary = {}
	var regex := RegEx.new()
	regex.compile("(?m)^\\s*class_name\\s+([A-Za-z_]\\w*)")
	for path: String in script_paths:
		var source := _read_text(path)
		for match_result: RegExMatch in regex.search_all(source):
			var discovered_class_name := match_result.get_string(1)
			if not paths_by_class_name.has(discovered_class_name):
				paths_by_class_name[discovered_class_name] = []
			var paths: Array = paths_by_class_name[discovered_class_name]
			paths.append(path)

	var issues: Array[String] = []
	for discovered_class_name: String in paths_by_class_name.keys():
		var paths: Array = paths_by_class_name[discovered_class_name]
		if paths.size() > 1:
			issues.append("%s declared in %s" % [discovered_class_name, _join_string_values(paths)])

	assert_eq(issues, [], "公开 class_name 必须唯一，避免重复脚本污染 Godot 全局类型表：\n%s" % _join_lines(issues))


func test_gdscript_uid_files_are_unique_and_match_scripts() -> void:
	var uid_paths := _collect_files_with_suffix(SOURCE_ROOT, ".gd.uid")
	var path_by_uid: Dictionary = {}
	var issues: Array[String] = []
	for uid_path: String in uid_paths:
		var script_path := uid_path.substr(0, uid_path.length() - ".uid".length())
		if not FileAccess.file_exists(script_path):
			issues.append("%s has no matching script %s" % [uid_path, script_path])

		var uid := _read_text(uid_path).strip_edges()
		if uid.is_empty():
			issues.append("%s has empty uid" % uid_path)
			continue
		if not uid.begins_with("uid://"):
			issues.append("%s has invalid uid %s" % [uid_path, uid])
			continue
		if path_by_uid.has(uid):
			issues.append("%s duplicates uid from %s" % [uid_path, String(path_by_uid[uid])])
		else:
			path_by_uid[uid] = uid_path

	assert_eq(issues, [], "GDScript UID 文件必须和脚本一一对应，且 UID 不应重复：\n%s" % _join_lines(issues))


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


func _collect_files_with_suffix(root_path: String, suffix: String) -> Array[String]:
	var result: Array[String] = []
	_collect_files_with_suffix_recursive(root_path, suffix, result)
	result.sort()
	return result


func _collect_files_with_suffix_recursive(root_path: String, suffix: String, result: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var child_path := root_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_collect_files_with_suffix_recursive(child_path, suffix, result)
		elif entry.ends_with(suffix):
			result.append(child_path)
		entry = dir.get_next()
	dir.list_dir_end()


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


func _join_lines(values: Array[String]) -> String:
	if values.is_empty():
		return ""

	var packed := PackedStringArray()
	for value: String in values:
		packed.append(value)
	return "\n".join(packed)


func _join_string_values(values: Array) -> String:
	if values.is_empty():
		return ""

	var packed := PackedStringArray()
	for value: Variant in values:
		packed.append(String(value))
	return ", ".join(packed)


func _contains_identifier(source: String, identifier: String) -> bool:
	var regex := RegEx.new()
	regex.compile("(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])" % identifier)
	return regex.search(source) != null
