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
const SAVE_RUNTIME_BASE_SCRIPT_PATHS: Array[String] = [
	"res://addons/gf/extensions/save/core/gf_save_scope.gd",
	"res://addons/gf/extensions/save/core/gf_save_source.gd",
	"res://addons/gf/extensions/save/core/gf_save_identity.gd",
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


func test_explicit_object_get_calls_do_not_use_dictionary_defaults() -> void:
	var script_paths := _collect_gdscript_files(SOURCE_ROOT)
	var issues: Array[String] = []
	for path: String in script_paths:
		_collect_object_get_default_issues(path, _read_text(path), issues)

	assert_eq(
		issues,
		[],
		"显式对象类型只能调用单参数 Object.get()；需要默认值时应先转成 Dictionary 或显式判空：\n%s" % _join_lines(issues)
	)


func test_save_runtime_base_scripts_do_not_force_tool_annotation() -> void:
	var issues: Array[String] = []
	for path: String in SAVE_RUNTIME_BASE_SCRIPT_PATHS:
		var source := _read_text(path).strip_edges()
		if source.begins_with("@tool"):
			issues.append(path)

	assert_eq(
		issues,
		[],
		"项目常继承的 Save 运行时基类不应声明 @tool，避免要求用户业务脚本也声明 @tool：\n%s" % _join_lines(issues)
	)


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


func _collect_object_get_default_issues(path: String, source: String, issues: Array[String]) -> void:
	var lines := source.split("\n")
	var global_types: Dictionary = {}
	var scope_types: Dictionary = {}
	var receiver_regex := RegEx.new()
	receiver_regex.compile("\\b([A-Za-z_]\\w*)\\.get\\(")
	var declaration_regex := RegEx.new()
	declaration_regex.compile("\\bvar\\s+([A-Za-z_]\\w*)\\s*:\\s*([A-Za-z_]\\w*)")
	var cast_declaration_regex := RegEx.new()
	cast_declaration_regex.compile("\\bvar\\s+([A-Za-z_]\\w*)\\s*:=.*\\bas\\s+([A-Za-z_]\\w*)")
	var for_regex := RegEx.new()
	for_regex.compile("\\bfor\\s+([A-Za-z_]\\w*)\\s*:\\s*([A-Za-z_]\\w*)\\s+in\\b")

	var in_function := false
	for i: int in range(lines.size()):
		var line := String(lines[i])
		var stripped := line.strip_edges()
		if stripped.is_empty() or stripped.begins_with("#"):
			continue

		if stripped.begins_with("func ") or stripped.begins_with("static func "):
			in_function = true
			scope_types = global_types.duplicate()
			var signature := line
			var signature_index := i + 1
			while not signature.contains(")") and signature_index < lines.size():
				signature += "\n" + String(lines[signature_index])
				signature_index += 1
			_add_typed_parameters(signature, scope_types)
		elif not in_function:
			_add_typed_declaration(line, declaration_regex, global_types)

		if in_function:
			_add_typed_declaration(line, declaration_regex, scope_types)
			_add_typed_declaration(line, cast_declaration_regex, scope_types)
			_add_typed_declaration(line, for_regex, scope_types)

		for match_result: RegExMatch in receiver_regex.search_all(line):
			var receiver := match_result.get_string(1)
			if not scope_types.has(receiver):
				continue
			var type_name := String(scope_types[receiver])
			if not _is_object_get_default_risk_type(type_name):
				continue
			if _get_call_has_default_argument(lines, i, match_result.get_start()):
				issues.append("%s:%d uses %s.get() with a Dictionary-style default on %s" % [
					path,
					i + 1,
					receiver,
					type_name,
				])


func _add_typed_parameters(signature: String, types: Dictionary) -> void:
	var param_regex := RegEx.new()
	param_regex.compile("\\b([A-Za-z_]\\w*)\\s*:\\s*([A-Za-z_]\\w*)")
	for match_result: RegExMatch in param_regex.search_all(signature):
		types[match_result.get_string(1)] = match_result.get_string(2)


func _add_typed_declaration(line: String, regex: RegEx, types: Dictionary) -> void:
	var match_result := regex.search(line)
	if match_result == null:
		return
	types[match_result.get_string(1)] = match_result.get_string(2)


func _get_call_has_default_argument(lines: PackedStringArray, start_line: int, start_column: int) -> bool:
	var line := String(lines[start_line])
	var open_index := line.find("(", start_column)
	if open_index < 0:
		return false

	var depth := 1
	var in_string := false
	var escaped := false
	for line_index: int in range(start_line, mini(start_line + 8, lines.size())):
		var text := String(lines[line_index])
		var column := open_index + 1 if line_index == start_line else 0
		while column < text.length():
			var character := text[column]
			if in_string:
				if escaped:
					escaped = false
				elif character == "\\":
					escaped = true
				elif character == "\"":
					in_string = false
			elif character == "\"":
				in_string = true
			elif character == "(":
				depth += 1
			elif character == ")":
				depth -= 1
				if depth == 0:
					return false
			elif character == "," and depth == 1:
				return true
			column += 1
	return false


func _is_object_get_default_risk_type(type_name: String) -> bool:
	if type_name in [
		"Variant",
		"Dictionary",
		"Array",
		"bool",
		"int",
		"float",
		"String",
		"StringName",
	]:
		return false
	if type_name.begins_with("Packed"):
		return false
	return (
		type_name in [
			"Object",
			"Node",
			"Resource",
			"RefCounted",
			"Script",
			"Control",
			"CanvasItem",
			"WeakRef",
		]
		or type_name.begins_with("Editor")
		or type_name.begins_with("GF")
	)


func _contains_identifier(source: String, identifier: String) -> bool:
	var regex := RegEx.new()
	regex.compile("(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])" % identifier)
	return regex.search(source) != null
