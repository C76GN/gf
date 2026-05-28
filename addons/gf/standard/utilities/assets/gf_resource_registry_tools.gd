@tool

## GFResourceRegistryTools: 通用资源注册表扫描和生成工具。
##
## 面向编辑器工具、构建脚本和项目安装器复用；它只从路径生成
## `GFResourceRegistry` / `GFResourceRegistryEntry`，不解释业务字段。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.23.0
class_name GFResourceRegistryTools
extends RefCounted


# --- 枚举 ---

## 从资源路径生成条目 ID 的方式。
## [br]
## @api public
enum EntryIdMode {
	## 使用文件名，不包含扩展名。
	BASENAME,
	## 使用相对 base_path 的路径，不包含扩展名。
	RELATIVE_PATH,
	## 使用完整资源路径，不包含扩展名。
	FULL_PATH,
}


# --- 常量 ---

## 默认资源扩展名白名单，不包含点号。
## [br]
## @api public
const RESOURCE_EXTENSIONS: PackedStringArray = [
	"tres",
	"res",
	"tscn",
	"scn",
	"png",
	"jpg",
	"jpeg",
	"webp",
	"svg",
	"bmp",
	"tga",
	"exr",
	"hdr",
	"ktx",
	"ctex",
	"ogg",
	"wav",
	"mp3",
	"opus",
	"glb",
	"gltf",
	"obj",
	"fbx",
	"dae",
	"blend",
	"material",
	"shader",
	"gdshader",
	"gd",
	"cs",
]

## 默认排除的扫描路径。
## [br]
## @api public
const DEFAULT_EXCLUDED_PATHS: PackedStringArray = ["res://addons"]

## 默认递归扫描深度上限。
## [br]
## @api public
const DEFAULT_MAX_SCAN_DEPTH: int = 32

## 默认单次扫描收集的资源路径数量上限。
## [br]
## @api public
const DEFAULT_MAX_RESOURCE_PATHS: int = 10000

## 默认路径字段：资源扩展名。
## [br]
## @api public
const FIELD_EXTENSION: StringName = &"extension"

## 默认路径字段：相对目录。
## [br]
## @api public
const FIELD_DIRECTORY: StringName = &"directory"

## 默认路径字段：文件基础名。
## [br]
## @api public
const FIELD_BASENAME: StringName = &"basename"

## 默认路径字段：相对路径。
## [br]
## @api public
const FIELD_RELATIVE_PATH: StringName = &"relative_path"

## 默认路径字段：由相对目录段推导的标签集合。
## [br]
## @api public
const FIELD_TAGS: StringName = &"tags"

## 默认路径字段：相对目录的第一段。
## [br]
## @api public
const FIELD_CATEGORY: StringName = &"category"

const _DEFAULT_TYPE_HINTS_BY_EXTENSION: Dictionary = {
	"tscn": "PackedScene",
	"scn": "PackedScene",
	"glb": "PackedScene",
	"gltf": "PackedScene",
	"png": "Texture2D",
	"jpg": "Texture2D",
	"jpeg": "Texture2D",
	"webp": "Texture2D",
	"svg": "Texture2D",
	"bmp": "Texture2D",
	"tga": "Texture2D",
	"exr": "Texture2D",
	"hdr": "Texture2D",
	"ktx": "Texture2D",
	"ctex": "Texture2D",
	"ogg": "AudioStream",
	"wav": "AudioStream",
	"mp3": "AudioStream",
	"opus": "AudioStream",
	"material": "Material",
	"shader": "Shader",
	"gdshader": "Shader",
	"gd": "Script",
	"cs": "Script",
}
const _GF_RESOURCE_REGISTRY_BASE: Script = preload("res://addons/gf/standard/utilities/assets/gf_resource_registry.gd")
const _GF_RESOURCE_REGISTRY_ENTRY_BASE: Script = preload("res://addons/gf/standard/utilities/assets/gf_resource_registry_entry.gd")
const _GF_VALIDATION_REPORT_BASE: Script = preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")


# --- 公共方法 ---

## 判断路径是否指向受支持的资源扩展名。
## [br]
## @api public
## [br]
## @param path: 资源路径或文件名。
## [br]
## @param extensions: 可选扩展名白名单，不包含点号。
## [br]
## @return 是受支持资源路径时返回 true。
static func is_resource_path(path: String, extensions: PackedStringArray = RESOURCE_EXTENSIONS) -> bool:
	var extension := path.get_extension().to_lower()
	return not extension.is_empty() and _normalize_extensions(extensions).has(extension)


## 递归扫描资源路径。
## [br]
## @api public
## [br]
## @param root_path: 扫描起点，通常是 res:// 下的目录。
## [br]
## @param options: 可选项，支持 recursive、include_addons、excluded_paths、extensions、include_hidden、include_import_sidecars、max_scan_depth 与 max_resource_paths。
## [br]
## @return 按字典序排序的资源路径。
## [br]
## @schema options: Dictionary，可包含 recursive、include_addons、excluded_paths、extensions、include_hidden、include_import_sidecars、max_scan_depth 和 max_resource_paths 字段。
static func scan_resource_paths(root_path: String = "res://", options: Dictionary = {}) -> PackedStringArray:
	var result := PackedStringArray()
	var normalized_root := _normalize_dir_path(root_path)
	var extensions := _get_extensions(options)
	var recursive := GFVariantData.get_option_bool(options, "recursive", true)
	var excluded_paths := _get_excluded_paths(options)
	var include_hidden := GFVariantData.get_option_bool(options, "include_hidden", false)
	var include_import_sidecars := GFVariantData.get_option_bool(options, "include_import_sidecars", false)
	var max_scan_depth := maxi(GFVariantData.get_option_int(options, "max_scan_depth", DEFAULT_MAX_SCAN_DEPTH), 0)
	var max_resource_paths := maxi(GFVariantData.get_option_int(options, "max_resource_paths", DEFAULT_MAX_RESOURCE_PATHS), 0)
	var scan_state := _make_scan_state()
	_scan_resource_paths_recursive(
		normalized_root,
		recursive,
		excluded_paths,
		extensions,
		result,
		0,
		max_scan_depth,
		max_resource_paths,
		include_hidden,
		include_import_sidecars,
		scan_state
	)
	result.sort()
	return result


## 从路径列表创建新的资源注册表。
## [br]
## @api public
## [br]
## @param paths: 资源路径列表。
## [br]
## @param options: 可选项，支持 id_mode、base_path、path_separator、strip_extension、type_hint、default_type_hint、type_hints_by_extension、extra_fields、fields_by_path、fields_by_id、include_path_fields、include_tags、include_category、tag_field 和 category_field。
## [br]
## @return 新建的资源注册表。
## [br]
## @schema options: Dictionary，可包含路径导入、ID 生成、类型提示和字段生成选项。
static func create_registry_from_paths(paths: PackedStringArray, options: Dictionary = {}) -> GFResourceRegistry:
	var registry := _GF_RESOURCE_REGISTRY_BASE.new() as GFResourceRegistry
	var import_options := GFVariantData.to_dictionary(options)
	import_options["overwrite"] = true
	add_paths_to_registry(registry, paths, import_options)
	return registry


## 扫描目录并创建新的资源注册表。
## [br]
## @api public
## [br]
## @param root_path: 扫描起点，通常是 res://assets。
## [br]
## @param options: 可选项，同时传给 scan_resource_paths() 与 create_registry_from_paths()。
## [br]
## @return 新建的资源注册表。
## [br]
## @schema options: Dictionary，可同时包含扫描选项和条目导入选项。
static func create_registry_from_scan(root_path: String = "res://", options: Dictionary = {}) -> GFResourceRegistry:
	var paths := scan_resource_paths(root_path, options)
	return create_registry_from_paths(paths, options)


## 将路径列表加入资源注册表。
## [br]
## @api public
## [br]
## @param registry: 要写入的资源注册表。
## [br]
## @param paths: 资源路径列表。
## [br]
## @param options: 可选项，支持 id_mode、base_path、path_separator、strip_extension、overwrite、type_hint、default_type_hint、type_hints_by_extension、extra_fields、fields_by_path、fields_by_id、include_path_fields、include_tags、include_category、tag_field 和 category_field。
## [br]
## @return 导入报告。
## [br]
## @schema options: Dictionary，可包含路径导入、ID 生成、类型提示和字段生成选项。
static func add_paths_to_registry(
	registry: GFResourceRegistry,
	paths: PackedStringArray,
	options: Dictionary = {}
) -> GFValidationReport:
	var report := _GF_VALIDATION_REPORT_BASE.new("GFResourceRegistryTools.add_paths_to_registry") as GFValidationReport
	if registry == null:
		report.add_error(&"missing_resource_registry", "Resource registry is null.")
		return report

	var overwrite := GFVariantData.get_option_bool(options, "overwrite", false)
	var extensions := _get_extensions(options)
	var added_count := 0
	var skipped_count := 0
	for path: String in paths:
		if not is_resource_path(path, extensions):
			report.add_warning(&"invalid_resource_path", "Path is not a supported resource file.", path, path)
			skipped_count += 1
			continue

		var entry_id := make_entry_id(path, options)
		if entry_id == &"":
			report.add_warning(&"empty_resource_entry_id", "Generated registry entry id is empty.", path, path)
			skipped_count += 1
			continue

		if registry.has_entry(entry_id) and not overwrite:
			report.add_warning(
				&"resource_entry_id_exists",
				"Registry entry id already exists and overwrite is disabled.",
				entry_id,
				path
			)
			skipped_count += 1
			continue

		var entry := _GF_RESOURCE_REGISTRY_ENTRY_BASE.new() as GFResourceRegistryEntry
		entry.configure(entry_id, path, make_type_hint(path, options), make_entry_fields(path, options))
		registry.set_entry(entry)
		added_count += 1

	report.metadata["added_count"] = added_count
	report.metadata["skipped_count"] = skipped_count
	return report


## 扫描目录并同步到已有资源注册表。
## [br]
## @api public
## [br]
## @param registry: 要写入的资源注册表。
## [br]
## @param root_path: 扫描起点，通常是 res://assets。
## [br]
## @param options: 可选项，同时传给 scan_resource_paths() 与 add_paths_to_registry()。
## [br]
## @return 导入报告。
## [br]
## @schema options: Dictionary，可同时包含扫描选项和条目导入选项。
static func sync_registry_from_scan(
	registry: GFResourceRegistry,
	root_path: String = "res://",
	options: Dictionary = {}
) -> GFValidationReport:
	var paths := scan_resource_paths(root_path, options)
	var report := add_paths_to_registry(registry, paths, options)
	report.metadata["root_path"] = root_path
	report.metadata["scanned_count"] = paths.size()
	return report


## 按选项从路径生成稳定条目 ID。
## [br]
## @api public
## [br]
## @param path: 资源路径。
## [br]
## @param options: 可选项，支持 id_mode、base_path、path_separator、strip_extension。
## [br]
## @return 条目 ID。
## [br]
## @schema options: Dictionary，可包含 id_mode、base_path、path_separator 和 strip_extension 字段。
static func make_entry_id(path: String, options: Dictionary = {}) -> StringName:
	var mode := _resolve_id_mode(GFVariantData.get_option_value(options, "id_mode", EntryIdMode.BASENAME))
	var id_text := path.replace("\\", "/")
	match mode:
		EntryIdMode.BASENAME:
			id_text = id_text.get_file()
		EntryIdMode.RELATIVE_PATH:
			id_text = _make_relative_path(id_text, GFVariantData.get_option_string(options, "base_path", "res://"))
		EntryIdMode.FULL_PATH:
			pass

	if GFVariantData.get_option_bool(options, "strip_extension", true):
		id_text = id_text.get_basename()
	id_text = id_text.replace("/", GFVariantData.get_option_string(options, "path_separator", "/")).strip_edges()
	return StringName(id_text)


## 按选项从路径推导资源类型提示。
## [br]
## @api public
## [br]
## @param path: 资源路径。
## [br]
## @param options: 可选项，支持 type_hint、default_type_hint 与 type_hints_by_extension。
## [br]
## @return ResourceLoader 类型提示。
## [br]
## @schema options: Dictionary，可包含 type_hint、default_type_hint 和 type_hints_by_extension 字段。
static func make_type_hint(path: String, options: Dictionary = {}) -> String:
	var explicit_type_hint := GFVariantData.get_option_string(options, "type_hint", "")
	if not explicit_type_hint.is_empty():
		return explicit_type_hint

	var type_hints := GFVariantData.get_option_dictionary(
		options,
		"type_hints_by_extension",
		_DEFAULT_TYPE_HINTS_BY_EXTENSION
	)
	var extension := path.get_extension().to_lower()
	var type_hint: Variant = type_hints.get(extension, "")
	if type_hint is String or type_hint is StringName:
		var text := String(type_hint)
		if not text.is_empty():
			return text
	return GFVariantData.get_option_string(options, "default_type_hint", "")


## 按选项从路径生成可索引字段。
## [br]
## @api public
## [br]
## @param path: 资源路径。
## [br]
## @param options: 可选项，支持 base_path、extra_fields、fields_by_path、fields_by_id、include_path_fields、include_tags、include_category、tag_field 和 category_field。
## [br]
## @return 字段字典。
## [br]
## @schema options: Dictionary，可包含路径字段、目录标签和调用方附加字段选项。
## [br]
## @schema return: Dictionary keyed by field id with scalar, Array, or PackedStringArray values.
static func make_entry_fields(path: String, options: Dictionary = {}) -> Dictionary:
	var fields := GFVariantData.get_option_dictionary(options, "extra_fields", {})
	var normalized_path := path.replace("\\", "/")
	var relative_path := _make_relative_path(
		normalized_path,
		GFVariantData.get_option_string(options, "base_path", "res://")
	)
	var entry_id := make_entry_id(path, options)

	if GFVariantData.get_option_bool(options, "include_path_fields", true):
		fields[FIELD_EXTENSION] = normalized_path.get_extension().to_lower()
		fields[FIELD_BASENAME] = normalized_path.get_file().get_basename()
		fields[FIELD_DIRECTORY] = _get_relative_directory(relative_path)
		fields[FIELD_RELATIVE_PATH] = relative_path

	if GFVariantData.get_option_bool(options, "include_tags", true):
		var tags := _make_path_tags(relative_path)
		if not tags.is_empty():
			fields[GFVariantData.get_option_string_name(options, "tag_field", FIELD_TAGS)] = tags

	if GFVariantData.get_option_bool(options, "include_category", true):
		var category := _make_path_category(relative_path)
		if not category.is_empty():
			fields[GFVariantData.get_option_string_name(options, "category_field", FIELD_CATEGORY)] = category

	GFVariantData.merge_dictionary(fields, _get_path_override_fields(path, options), true, true)
	GFVariantData.merge_dictionary(fields, _get_id_override_fields(entry_id, options), true, true)
	return fields


# --- 私有/辅助方法 ---

static func _scan_resource_paths_recursive(
	dir_path: String,
	recursive: bool,
	excluded_paths: PackedStringArray,
	extensions: PackedStringArray,
	result: PackedStringArray,
	depth: int,
	max_scan_depth: int,
	max_resource_paths: int,
	include_hidden: bool,
	include_import_sidecars: bool,
	scan_state: Dictionary
) -> void:
	if not _can_collect_more_resource_paths(result, max_resource_paths):
		_warn_resource_path_limit(max_resource_paths, scan_state)
		return
	if _is_excluded_path(dir_path, excluded_paths):
		return

	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		if not _can_collect_more_resource_paths(result, max_resource_paths):
			_warn_resource_path_limit(max_resource_paths, scan_state)
			break

		if not include_hidden and entry.begins_with("."):
			entry = dir.get_next()
			continue

		var child_path := dir_path.path_join(entry)
		if dir.current_is_dir():
			if recursive and _can_scan_deeper(child_path, depth, max_scan_depth, scan_state):
				_scan_resource_paths_recursive(
					child_path,
					recursive,
					excluded_paths,
					extensions,
					result,
					depth + 1,
					max_scan_depth,
					max_resource_paths,
					include_hidden,
					include_import_sidecars,
					scan_state
				)
		elif _can_include_file_entry(entry, extensions, include_import_sidecars):
			result.append(child_path)
		entry = dir.get_next()
	dir.list_dir_end()


static func _can_include_file_entry(
	entry: String,
	extensions: PackedStringArray,
	include_import_sidecars: bool
) -> bool:
	if not include_import_sidecars and entry.ends_with(".import"):
		return false
	return is_resource_path(entry, extensions)


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
	push_warning("[GFResourceRegistryTools] scan_resource_paths 已达到 max_resource_paths=%d，后续资源已跳过。" % max_resource_paths)


static func _warn_scan_depth_limit(path: String, max_scan_depth: int, scan_state: Dictionary) -> void:
	if max_scan_depth <= 0 or bool(scan_state.get("depth_warning_emitted", false)):
		return
	scan_state["depth_warning_emitted"] = true
	push_warning("[GFResourceRegistryTools] scan_resource_paths 已达到 max_scan_depth=%d，已跳过更深目录：%s。" % [max_scan_depth, path])


static func _get_extensions(options: Dictionary) -> PackedStringArray:
	return _normalize_extensions(
		GFVariantData.get_option_packed_string_array(options, "extensions", RESOURCE_EXTENSIONS)
	)


static func _get_excluded_paths(options: Dictionary) -> PackedStringArray:
	if GFVariantData.get_option_bool(options, "include_addons", false):
		return PackedStringArray()
	var paths := GFVariantData.get_option_packed_string_array(options, "excluded_paths", DEFAULT_EXCLUDED_PATHS)
	var result := PackedStringArray()
	for path: String in paths:
		result.append(_normalize_dir_path(path))
	return result


static func _normalize_extensions(extensions: PackedStringArray) -> PackedStringArray:
	var result := PackedStringArray()
	for extension: String in extensions:
		var normalized := extension.strip_edges().to_lower()
		if normalized.begins_with("."):
			normalized = normalized.substr(1)
		if not normalized.is_empty() and not result.has(normalized):
			result.append(normalized)
	return result


static func _resolve_id_mode(value: Variant) -> EntryIdMode:
	if typeof(value) == TYPE_INT:
		return clampi(int(value), EntryIdMode.BASENAME, EntryIdMode.FULL_PATH) as EntryIdMode

	match String(value).strip_edges().to_lower():
		"relative", "relative_path":
			return EntryIdMode.RELATIVE_PATH
		"full", "full_path", "path":
			return EntryIdMode.FULL_PATH
		_:
			return EntryIdMode.BASENAME


static func _make_relative_path(path: String, base_path: String) -> String:
	var normalized_path := path.replace("\\", "/")
	var normalized_base := _normalize_dir_path(base_path)
	if normalized_base.is_empty():
		return normalized_path
	if normalized_path.begins_with(normalized_base):
		var relative_path := normalized_path.substr(normalized_base.length())
		if relative_path.begins_with("/"):
			relative_path = relative_path.substr(1)
		if not relative_path.is_empty():
			return relative_path
	return normalized_path


static func _get_relative_directory(relative_path: String) -> String:
	var directory := relative_path.get_base_dir()
	if directory == ".":
		return ""
	return directory


static func _make_path_tags(relative_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	var directory := _get_relative_directory(relative_path)
	if directory.is_empty():
		return result

	for segment: String in directory.split("/", false):
		var tag := segment.strip_edges()
		if not tag.is_empty() and not result.has(tag):
			result.append(tag)
	return result


static func _make_path_category(relative_path: String) -> String:
	var tags := _make_path_tags(relative_path)
	if tags.is_empty():
		return ""
	return tags[0]


static func _get_path_override_fields(path: String, options: Dictionary) -> Dictionary:
	var fields_by_path := GFVariantData.get_option_dictionary(options, "fields_by_path", {})
	var normalized_path := path.replace("\\", "/")
	var value: Variant = fields_by_path.get(normalized_path, fields_by_path.get(path, {}))
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}


static func _get_id_override_fields(entry_id: StringName, options: Dictionary) -> Dictionary:
	var fields_by_id := GFVariantData.get_option_dictionary(options, "fields_by_id", {})
	var value: Variant = fields_by_id.get(entry_id, fields_by_id.get(String(entry_id), {}))
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}


static func _normalize_dir_path(path: String) -> String:
	var normalized := path.replace("\\", "/").strip_edges()
	while normalized.ends_with("/") and not normalized.ends_with("://"):
		normalized = normalized.substr(0, normalized.length() - 1)
	return normalized


static func _is_excluded_path(path: String, excluded_paths: PackedStringArray) -> bool:
	var normalized_path := _normalize_dir_path(path)
	for excluded_path: String in excluded_paths:
		var normalized_excluded := _normalize_dir_path(excluded_path)
		if normalized_path == normalized_excluded or normalized_path.begins_with(normalized_excluded + "/"):
			return true
	return false
