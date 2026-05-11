## 验证框架 API 文档注释与函数签名保持同步。
extends GutTest


# --- 常量 ---

const SOURCE_ROOT: String = "res://addons/gf"


# --- 测试用例 ---

func test_documented_params_match_function_signatures() -> void:
	var script_paths := _collect_gdscript_files(SOURCE_ROOT)
	var issues: Array[String] = []
	for path: String in script_paths:
		issues.append_array(_collect_param_doc_issues(path))

	assert_eq(issues, [], "API @param 注释应与函数签名双向一致：\n%s" % _join_lines(issues))


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


func _collect_param_doc_issues(path: String) -> Array[String]:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ["%s: cannot open file" % path]

	var lines := file.get_as_text().split("\n")
	file.close()
	var issues: Array[String] = []
	var doc_lines: Array[String] = []
	var line_index := 0
	while line_index < lines.size():
		var line := String(lines[line_index])
		var trimmed := line.strip_edges()
		if trimmed.begins_with("##"):
			doc_lines.append(trimmed)
			line_index += 1
			continue

		if _line_starts_function(trimmed):
			var signature_start_line := line_index + 1
			var signature := trimmed
			var signature_parenthesis_depth := _get_parenthesis_delta(trimmed)
			while signature_parenthesis_depth > 0 and line_index + 1 < lines.size():
				line_index += 1
				var signature_line := String(lines[line_index]).strip_edges()
				signature += " " + signature_line
				signature_parenthesis_depth += _get_parenthesis_delta(signature_line)

			var function_name := _parse_function_name(signature)
			var actual_params := _parse_signature_params(signature)
			var documented_params := _parse_documented_params(doc_lines)
			if _should_validate_param_docs(function_name, actual_params, documented_params):
				issues.append_array(_collect_function_param_doc_issues(
					path,
					signature_start_line,
					function_name,
					actual_params,
					documented_params
				))

		if not trimmed.is_empty():
			doc_lines.clear()
		line_index += 1
	return issues


func _line_starts_function(trimmed: String) -> bool:
	return trimmed.begins_with("func ") or trimmed.begins_with("static func ")


func _get_parenthesis_delta(text: String) -> int:
	var delta := 0
	for i: int in range(text.length()):
		var character := text[i]
		if character == "(":
			delta += 1
		elif character == ")":
			delta -= 1
	return delta


func _parse_signature_params(signature: String) -> PackedStringArray:
	var result := PackedStringArray()
	var open_index := signature.find("(")
	var close_index := signature.rfind(")")
	if open_index == -1 or close_index == -1 or close_index <= open_index:
		return result

	var args_text := signature.substr(open_index + 1, close_index - open_index - 1).strip_edges()
	if args_text.is_empty():
		return result

	for raw_part: String in _split_top_level_arguments(args_text):
		var part := raw_part.strip_edges()
		if part.is_empty():
			continue

		var default_index := _find_top_level_character(part, "=")
		var without_default := part
		if default_index != -1:
			without_default = part.substr(0, default_index).strip_edges()

		var type_index := _find_top_level_character(without_default, ":")
		var param_name := without_default
		if type_index != -1:
			param_name = without_default.substr(0, type_index).strip_edges()
		if not param_name.is_empty():
			result.append(param_name)
	return result


func _parse_documented_params(doc_lines: Array[String]) -> PackedStringArray:
	var result := PackedStringArray()
	var regex := RegEx.new()
	regex.compile("@param\\s+([A-Za-z_]\\w*)\\s*:")
	for line: String in doc_lines:
		for match_result: RegExMatch in regex.search_all(line):
			result.append(match_result.get_string(1))
	return result


func _should_validate_param_docs(
	function_name: String,
	actual_params: PackedStringArray,
	documented_params: PackedStringArray
) -> bool:
	if not documented_params.is_empty():
		return true
	if actual_params.is_empty():
		return false
	return not function_name.begins_with("_")


func _collect_function_param_doc_issues(
	path: String,
	signature_start_line: int,
	function_name: String,
	actual_params: PackedStringArray,
	documented_params: PackedStringArray
) -> Array[String]:
	var issues: Array[String] = []
	var duplicate_params := _collect_duplicate_names(documented_params)
	for duplicate_param: String in duplicate_params:
		issues.append("%s:%d %s documents duplicate param '%s'" % [
			path,
			signature_start_line,
			function_name,
			duplicate_param,
		])

	for actual_param: String in actual_params:
		if not documented_params.has(actual_param):
			issues.append("%s:%d %s missing @param for '%s'" % [
				path,
				signature_start_line,
				function_name,
				actual_param,
			])

	for documented_param: String in documented_params:
		if not actual_params.has(documented_param):
			issues.append("%s:%d %s documents unknown param '%s'" % [
				path,
				signature_start_line,
				function_name,
				documented_param,
			])

	if issues.is_empty() and not _packed_string_arrays_equal(actual_params, documented_params):
		issues.append("%s:%d %s @param order should be [%s] but was [%s]" % [
			path,
			signature_start_line,
			function_name,
			", ".join(actual_params),
			", ".join(documented_params),
		])

	return issues


func _split_top_level_arguments(args_text: String) -> PackedStringArray:
	var result := PackedStringArray()
	var start_index := 0
	for i: int in range(args_text.length()):
		if args_text[i] == "," and _is_top_level_character(args_text, i):
			result.append(args_text.substr(start_index, i - start_index))
			start_index = i + 1
	result.append(args_text.substr(start_index))
	return result


func _find_top_level_character(text: String, target: String) -> int:
	for i: int in range(text.length()):
		if text[i] == target and _is_top_level_character(text, i):
			return i
	return -1


func _is_top_level_character(text: String, target_index: int) -> bool:
	var parenthesis_depth := 0
	var bracket_depth := 0
	var brace_depth := 0
	var in_string := false
	var string_delimiter := ""
	var escaped := false

	for i: int in range(target_index):
		var character := text[i]
		if in_string:
			if escaped:
				escaped = false
			elif character == "\\":
				escaped = true
			elif character == string_delimiter:
				in_string = false
			continue

		if character == "\"" or character == "'":
			in_string = true
			string_delimiter = character
		elif character == "(":
			parenthesis_depth += 1
		elif character == ")":
			parenthesis_depth -= 1
		elif character == "[":
			bracket_depth += 1
		elif character == "]":
			bracket_depth -= 1
		elif character == "{":
			brace_depth += 1
		elif character == "}":
			brace_depth -= 1

	return (
		not in_string
		and parenthesis_depth == 0
		and bracket_depth == 0
		and brace_depth == 0
	)


func _collect_duplicate_names(names: PackedStringArray) -> PackedStringArray:
	var duplicates := PackedStringArray()
	var seen := {}
	for param_name: String in names:
		if seen.has(param_name):
			if not duplicates.has(param_name):
				duplicates.append(param_name)
		else:
			seen[param_name] = true
	return duplicates


func _packed_string_arrays_equal(left: PackedStringArray, right: PackedStringArray) -> bool:
	if left.size() != right.size():
		return false
	for i: int in range(left.size()):
		if left[i] != right[i]:
			return false
	return true


func _parse_function_name(signature: String) -> String:
	var regex := RegEx.new()
	regex.compile("(?:static\\s+)?func\\s+(\\w+)")
	var result := regex.search(signature)
	if result == null:
		return "<unknown>"
	return result.get_string(1)


func _join_lines(lines: Array[String]) -> String:
	var packed := PackedStringArray()
	for line: String in lines:
		packed.append(line)
	return "\n".join(packed)
