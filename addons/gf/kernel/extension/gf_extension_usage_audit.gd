## GFExtensionUsageAudit: 检查禁用扩展是否仍被项目文件直接引用。
class_name GFExtensionUsageAudit
extends RefCounted


# --- 常量 ---

const DEFAULT_SCAN_ROOTS: Array[String] = ["res://"]
const DEFAULT_IGNORED_ROOTS: Array[String] = [
	"res://.godot",
	"res://.git",
	"res://addons/gf",
	"res://addons/gut",
	"res://ai_analysis",
	"res://docs",
	"res://tests",
	"res://tools",
]
const TEXT_FILE_EXTENSIONS: Array[String] = [
	"cfg",
	"csv",
	"gd",
	"gdshader",
	"godot",
	"import",
	"json",
	"shader",
	"tscn",
	"tres",
]


# --- 公共方法 ---

## 检查一组禁用扩展是否仍被项目文件直接引用。
## @param manifests: 要检查的禁用扩展 manifest 列表。
## @param options: 可选参数，支持 scan_roots、ignored_roots、max_references_per_extension。
## @return 引用审计报告。
static func audit_disabled_extensions(
	manifests: Array[GFExtensionManifest],
	options: Dictionary = {}
) -> Dictionary:
	var extension_reports: Dictionary = {}
	var all_references: Array[Dictionary] = []
	for manifest: GFExtensionManifest in manifests:
		if manifest == null or manifest.root_path.is_empty():
			continue

		var references := find_references_to_root(manifest.root_path, options)
		if references.is_empty():
			continue

		extension_reports[manifest.id] = {
			"id": manifest.id,
			"display_name": manifest.display_name,
			"root_path": manifest.root_path,
			"references": references,
			"reference_count": references.size(),
		}
		all_references.append_array(references)

	return {
		"ok": all_references.is_empty(),
		"extension_count": extension_reports.size(),
		"reference_count": all_references.size(),
		"extensions": extension_reports,
		"references": all_references,
	}


## 查找项目文件中对指定扩展根目录的直接路径引用。
## @param root_path: 扩展根目录。
## @param options: 可选参数，支持 scan_roots、ignored_roots、max_references_per_extension。
## @return 引用列表。
static func find_references_to_root(root_path: String, options: Dictionary = {}) -> Array[Dictionary]:
	var normalized_root := root_path.trim_suffix("/")
	if normalized_root.is_empty():
		return []

	var scan_roots := _to_string_array(options.get("scan_roots", DEFAULT_SCAN_ROOTS))
	var ignored_roots := _to_string_array(options.get("ignored_roots", DEFAULT_IGNORED_ROOTS))
	ignored_roots.append(normalized_root)

	var files: Array[String] = []
	for scan_root: String in scan_roots:
		_collect_text_files(scan_root.trim_suffix("/"), ignored_roots, files)

	var extension_class_names := _collect_extension_class_names(normalized_root)
	var max_references := maxi(int(options.get("max_references_per_extension", 50)), 1)
	var references: Array[Dictionary] = []
	for path: String in files:
		references.append_array(_collect_file_references(
			path,
			normalized_root,
			extension_class_names,
			max_references - references.size()
		))
		if references.size() >= max_references:
			break
	return references


# --- 私有/辅助方法 ---

static func _collect_text_files(root_path: String, ignored_roots: Array[String], result: Array[String]) -> void:
	if root_path.is_empty() or _is_path_ignored(root_path, ignored_roots):
		return

	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var path := root_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with(".") or entry == ".godot":
				_collect_text_files(path, ignored_roots, result)
		elif _is_text_resource_file(entry):
			result.append(path)
		entry = dir.get_next()
	dir.list_dir_end()


static func _collect_file_references(
	path: String,
	root_path: String,
	class_names: Array[String],
	remaining: int
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if remaining <= 0:
		return result

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return result

	var lines := file.get_as_text().split("\n")
	file.close()
	for line_index: int in range(lines.size()):
		var line := String(lines[line_index])
		if _line_references_root(line, root_path):
			result.append(_make_reference(path, line_index + 1, root_path, "path", "", line))
			if result.size() >= remaining:
				break
			continue

		for class_name_value: String in class_names:
			if not _line_references_identifier(line, class_name_value):
				continue
			result.append(_make_reference(path, line_index + 1, root_path, "class_name", class_name_value, line))
			break
		if result.size() >= remaining:
			break
	return result


static func _make_reference(
	path: String,
	line: int,
	root_path: String,
	kind: String,
	symbol: String,
	source_line: String
) -> Dictionary:
	return {
		"path": path,
		"line": line,
		"root_path": root_path,
		"kind": kind,
		"symbol": symbol,
		"preview": source_line.strip_edges().left(180),
	}


static func _line_references_root(line: String, root_path: String) -> bool:
	var start := line.find(root_path)
	while start >= 0:
		var next_index := start + root_path.length()
		if next_index >= line.length():
			return true

		var next_character := line.substr(next_index, 1)
		if _is_reference_boundary(next_character):
			return true
		start = line.find(root_path, start + 1)
	return false


static func _line_references_identifier(line: String, identifier: String) -> bool:
	if identifier.is_empty():
		return false

	var start := line.find(identifier)
	while start >= 0:
		var before_ok := start == 0 or not _is_identifier_character(line.substr(start - 1, 1))
		var end := start + identifier.length()
		var after_ok := end >= line.length() or not _is_identifier_character(line.substr(end, 1))
		if before_ok and after_ok:
			return true
		start = line.find(identifier, start + 1)
	return false


static func _is_identifier_character(character: String) -> bool:
	if character.is_empty():
		return false
	var code := character.unicode_at(0)
	return (
		(code >= 65 and code <= 90)
		or (code >= 97 and code <= 122)
		or (code >= 48 and code <= 57)
		or code == 95
	)


static func _is_reference_boundary(character: String) -> bool:
	return ["/", "\"", "'", ")", "]", "}", ",", " ", "\t"].has(character)


static func _is_text_resource_file(path: String) -> bool:
	var extension := path.get_extension().to_lower()
	return TEXT_FILE_EXTENSIONS.has(extension)


static func _is_path_ignored(path: String, ignored_roots: Array[String]) -> bool:
	for ignored_root: String in ignored_roots:
		var normalized_root := ignored_root.trim_suffix("/")
		if normalized_root.is_empty():
			continue
		if path == normalized_root or path.begins_with(normalized_root + "/"):
			return true
	return false


static func _collect_extension_class_names(root_path: String) -> Array[String]:
	var files: Array[String] = []
	_collect_gd_files(root_path, files)

	var names: Array[String] = []
	var regex := RegEx.new()
	regex.compile("(?m)^\\s*class_name\\s+([A-Za-z_]\\w*)")
	for path: String in files:
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		var source := file.get_as_text()
		file.close()
		var match_result := regex.search(source)
		if match_result == null:
			continue
		var class_name_value := match_result.get_string(1)
		if not names.has(class_name_value):
			names.append(class_name_value)
	names.sort()
	return names


static func _collect_gd_files(root_path: String, result: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var path := root_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_collect_gd_files(path, result)
		elif entry.ends_with(".gd"):
			result.append(path)
		entry = dir.get_next()
	dir.list_dir_end()


static func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is PackedStringArray:
		for item: String in value:
			result.append(item)
		return result
	if value is Array:
		for item: Variant in value:
			if typeof(item) == TYPE_STRING or item is StringName:
				result.append(String(item))
	return result
