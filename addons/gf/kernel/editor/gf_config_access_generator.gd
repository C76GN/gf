@tool

## GFConfigAccessGenerator: 生成静态导表访问器脚本。
##
## 生成结果只封装 provider 的 `get_record()` / `get_table()` 调用，
## 不规定项目表结构语义，适合需要 IDE 补全和集中表名常量的项目使用。
## [br]
## @api public
## [br]
## @category editor_api
## [br]
## @since 3.17.0
## [br]
## @layer kernel/editor
class_name GFConfigAccessGenerator
extends RefCounted


# --- 常量 ---

## 默认生成输出路径。
## [br]
## @api public
const DEFAULT_OUTPUT_PATH: String = "res://gf/generated/gf_config_access.gd"

## 默认生成 class_name。
## [br]
## @api public
const DEFAULT_CLASS_NAME: String = "GFConfigAccess"

## 默认 provider 获取表达式。
## [br]
## @api public
const DEFAULT_PROVIDER_ACCESSOR: String = "null"
const _GF_VARIANT_ACCESS_SCRIPT = preload("res://addons/gf/kernel/core/gf_variant_access.gd")


# --- 公共方法 ---

## 根据 schema 列表生成访问器并写入文件。
## [br]
## @api public
## [br]
## @param schemas: 带有 `table_name` 或 `table_key` 属性的 schema 列表。
## [br]
## @schema schemas: Array of Dictionary or Object schemas with table_name/table_key and optional metadata.
## [br]
## @param output_path: 生成文件输出路径。
## [br]
## @param overwrite_existing: 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。
## [br]
## @param access_class_name: 生成脚本的 class_name。
## [br]
## @param provider_accessor: 无显式 provider 参数时用于获取 provider 的表达式。
## [br]
## @param options: 可选生成选项，支持 method_name_style、constant_prefix、record_method_pattern、table_method_pattern、include_schema_comments。
## [br]
## @schema options: Dictionary controlling method_name_style, constant_prefix, record_method_pattern, table_method_pattern, and include_schema_comments.
## [br]
## @return 写入结果错误码。
func generate(
	schemas: Array,
	output_path: String = DEFAULT_OUTPUT_PATH,
	overwrite_existing: bool = true,
	access_class_name: String = DEFAULT_CLASS_NAME,
	provider_accessor: String = DEFAULT_PROVIDER_ACCESSOR,
	options: Dictionary = {}
) -> Error:
	return save_source(output_path, build_source(schemas, access_class_name, provider_accessor, options), overwrite_existing)


## 根据 schema 列表生成访问器源码。
## [br]
## @api public
## [br]
## @param schemas: 带有 `table_name` 或 `table_key` 属性的 schema 列表。
## [br]
## @schema schemas: Array of Dictionary or Object schemas with table_name/table_key and optional metadata.
## [br]
## @param access_class_name: 生成脚本的 class_name。
## [br]
## @param provider_accessor: 无显式 provider 参数时用于获取 provider 的表达式。
## [br]
## @param options: 可选生成选项。
## [br]
## @schema options: Dictionary controlling method_name_style, constant_prefix, record_method_pattern, table_method_pattern, and include_schema_comments.
## [br]
## @return GDScript 源码。
func build_source(
	schemas: Array,
	access_class_name: String = DEFAULT_CLASS_NAME,
	provider_accessor: String = DEFAULT_PROVIDER_ACCESSOR,
	options: Dictionary = {}
) -> String:
	var generation_options: Dictionary = _normalize_generation_options(options)
	var records: Array[Dictionary] = _collect_schema_records(schemas, generation_options)
	var builder: GFSourceBuilder = GFSourceBuilder.new()
	builder.doc("%s: 自动生成的静态导表访问器。" % access_class_name)
	builder.doc()
	builder.doc("该文件由 GFConfigAccessGenerator 生成，可以提交到版本库；请不要手动编辑。")
	builder.line("class_name %s" % access_class_name)
	builder.line("extends RefCounted")
	builder.blank(2)
	builder.section("常量")
	for record: Dictionary in records:
		builder.line("const %s: StringName = &\"%s\"" % [
			_GF_VARIANT_ACCESS_SCRIPT.get_option_string(record, "constant_name"),
			_escape_string(_GF_VARIANT_ACCESS_SCRIPT.get_option_string(record, "table_name")),
		])

	builder.blank(2)
	builder.section("公共方法")
	var used_methods: Dictionary = {}
	for record: Dictionary in records:
		_append_table_accessors(builder, record, used_methods, generation_options)

	builder.blank()
	builder.section("私有/辅助方法")
	builder.line("static func _provider_or_null(provider: Variant = null) -> Variant:")
	builder.indent()
	builder.line("if provider != null:")
	builder.indent()
	builder.line("return provider")
	builder.dedent()
	builder.line("return %s" % provider_accessor)
	builder.dedent()
	builder.blank(2)
	builder.line("static func _get_provider_record(provider: Variant, table_name: StringName, id: Variant) -> Variant:")
	builder.indent()
	builder.line("var resolved_provider: Variant = _provider_or_null(provider)")
	builder.line("if not (resolved_provider is Object):")
	builder.indent()
	builder.line("return null")
	builder.dedent()
	builder.line("var provider_object: Object = resolved_provider")
	builder.line("if not provider_object.has_method(\"get_record\"):")
	builder.indent()
	builder.line("return null")
	builder.dedent()
	builder.line("return provider_object.call(\"get_record\", table_name, id)")
	builder.dedent()
	builder.blank(2)
	builder.line("static func _get_provider_table(provider: Variant, table_name: StringName) -> Variant:")
	builder.indent()
	builder.line("var resolved_provider: Variant = _provider_or_null(provider)")
	builder.line("if not (resolved_provider is Object):")
	builder.indent()
	builder.line("return null")
	builder.dedent()
	builder.line("var provider_object: Object = resolved_provider")
	builder.line("if not provider_object.has_method(\"get_table\"):")
	builder.indent()
	builder.line("return null")
	builder.dedent()
	builder.line("return provider_object.call(\"get_table\", table_name)")
	builder.dedent()
	return builder.build()


## 保存生成源码到指定路径。
## [br]
## @api public
## [br]
## @param output_path: 生成文件输出路径。
## [br]
## @param source: GDScript 源码。
## [br]
## @param overwrite_existing: 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。
## [br]
## @return 写入结果错误码。
func save_source(output_path: String, source: String, overwrite_existing: bool = true) -> Error:
	if output_path.is_empty():
		push_error("[GFConfigAccessGenerator] 输出路径为空。")
		return ERR_INVALID_PARAMETER

	if FileAccess.file_exists(output_path) and not overwrite_existing:
		push_warning("[GFConfigAccessGenerator] 目标文件已存在，已跳过：%s" % output_path)
		return ERR_ALREADY_EXISTS

	var dir_error: Error = DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	if dir_error != OK:
		push_error("[GFConfigAccessGenerator] 无法创建导表访问器输出目录：%s (%s)" % [output_path.get_base_dir(), error_string(dir_error)])
		return dir_error

	var file: FileAccess = FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		var open_error: Error = FileAccess.get_open_error()
		push_error("[GFConfigAccessGenerator] 无法写入导表访问器脚本：%s (%s)" % [output_path, error_string(open_error)])
		return open_error

	_store_file_string(file, source)
	file.close()

	if Engine.is_editor_hint():
		var filesystem: EditorFileSystem = EditorInterface.get_resource_filesystem()
		if filesystem != null:
			filesystem.scan()

	return OK


# --- 私有/辅助方法 ---

func _collect_schema_records(schemas: Array, options: Dictionary) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for schema_variant: Variant in schemas:
		var table_name: String = _get_schema_table_name(schema_variant)
		if table_name.is_empty():
			continue

		var method_prefix: String = _sanitize_identifier(table_name)
		if method_prefix.is_empty():
			push_warning("[GFConfigAccessGenerator] 表名无法生成有效访问器，已跳过：%s" % table_name)
			continue

		var metadata: Dictionary = _get_schema_metadata(schema_variant)
		records.append({
			"table_name": table_name,
			"method_prefix": _format_identifier(method_prefix, _GF_VARIANT_ACCESS_SCRIPT.get_option_string(options, "method_name_style", "snake")),
			"constant_name": "%s%s" % [_GF_VARIANT_ACCESS_SCRIPT.get_option_string(options, "constant_prefix"), _to_constant_name(method_prefix)],
			"comment": _get_schema_comment(metadata),
		})

	records.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return _GF_VARIANT_ACCESS_SCRIPT.get_option_string(left, "table_name") < _GF_VARIANT_ACCESS_SCRIPT.get_option_string(right, "table_name")
	)
	return records


func _append_table_accessors(
	builder: GFSourceBuilder,
	record: Dictionary,
	used_methods: Dictionary,
	options: Dictionary
) -> void:
	var method_prefix: String = _GF_VARIANT_ACCESS_SCRIPT.get_option_string(record, "method_prefix")
	var constant_name: String = _GF_VARIANT_ACCESS_SCRIPT.get_option_string(record, "constant_name")
	var record_method: String = _format_method_pattern(_GF_VARIANT_ACCESS_SCRIPT.get_option_string(options, "record_method_pattern", "get_{table}_record"), method_prefix)
	var table_method: String = _format_method_pattern(_GF_VARIANT_ACCESS_SCRIPT.get_option_string(options, "table_method_pattern", "get_{table}_table"), method_prefix)
	if used_methods.has(record_method) or used_methods.has(table_method):
		push_warning("[GFConfigAccessGenerator] 函数名重复，已跳过：%s" % method_prefix)
		return

	used_methods[record_method] = true
	used_methods[table_method] = true
	var comment: String = _GF_VARIANT_ACCESS_SCRIPT.get_option_string(record, "comment")
	if _GF_VARIANT_ACCESS_SCRIPT.get_option_bool(options, "include_schema_comments", true) and not comment.is_empty():
		builder.doc(comment)
	builder.doc("获取 `%s` 表中的单条记录。" % _GF_VARIANT_ACCESS_SCRIPT.get_option_string(record, "table_name"))
	builder.line("static func %s(id: Variant, provider: Variant = null) -> Variant:" % record_method)
	builder.indent()
	builder.line("return _get_provider_record(provider, %s, id)" % constant_name)
	builder.dedent()
	builder.blank(2)
	builder.doc("获取 `%s` 整张表数据。" % _GF_VARIANT_ACCESS_SCRIPT.get_option_string(record, "table_name"))
	builder.line("static func %s(provider: Variant = null) -> Variant:" % table_method)
	builder.indent()
	builder.line("return _get_provider_table(provider, %s)" % constant_name)
	builder.dedent()
	builder.blank(2)


func _sanitize_identifier(value: String) -> String:
	var parts: PackedStringArray = PackedStringArray()
	var current: String = ""
	for index: int in range(value.length()):
		var character: String = value.substr(index, 1).to_lower()
		if _is_identifier_part(character):
			current += character
		elif not current.is_empty():
			_append_packed_string(parts, current)
			current = ""
	if not current.is_empty():
		_append_packed_string(parts, current)
	if parts.is_empty():
		return ""

	var result: String = "_".join(parts)
	if result.substr(0, 1).is_valid_int():
		result = "table_" + result
	return result


func _normalize_generation_options(options: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"method_name_style": _GF_VARIANT_ACCESS_SCRIPT.get_option_string(options, "method_name_style", "snake").to_lower(),
		"constant_prefix": _sanitize_constant_prefix(_GF_VARIANT_ACCESS_SCRIPT.get_option_string(options, "constant_prefix")),
		"record_method_pattern": _GF_VARIANT_ACCESS_SCRIPT.get_option_string(options, "record_method_pattern", "get_{table}_record"),
		"table_method_pattern": _GF_VARIANT_ACCESS_SCRIPT.get_option_string(options, "table_method_pattern", "get_{table}_table"),
		"include_schema_comments": _GF_VARIANT_ACCESS_SCRIPT.get_option_bool(options, "include_schema_comments", true),
	}
	if not (_GF_VARIANT_ACCESS_SCRIPT.get_option_string(result, "method_name_style") in ["snake", "camel", "pascal"]):
		result["method_name_style"] = "snake"
	if _GF_VARIANT_ACCESS_SCRIPT.get_option_string(result, "record_method_pattern").is_empty():
		result["record_method_pattern"] = "get_{table}_record"
	if _GF_VARIANT_ACCESS_SCRIPT.get_option_string(result, "table_method_pattern").is_empty():
		result["table_method_pattern"] = "get_{table}_table"
	return result


func _sanitize_constant_prefix(value: String) -> String:
	if value.is_empty():
		return ""
	var sanitized: String = _sanitize_identifier(value).to_upper()
	return "%s_" % sanitized if not sanitized.is_empty() and not sanitized.ends_with("_") else sanitized


func _format_identifier(identifier: String, style: String) -> String:
	match style:
		"camel":
			return _to_camel_case(identifier)
		"pascal":
			return _to_pascal_case(identifier)
		_:
			return identifier


func _format_method_pattern(pattern: String, table_token: String) -> String:
	var method_name: String = pattern.replace("{table}", table_token)
	method_name = _sanitize_generated_method_name(method_name)
	if method_name.is_empty():
		return "get_%s" % table_token
	return method_name


func _sanitize_generated_method_name(value: String) -> String:
	var result: String = ""
	var previous_was_separator: bool = false
	for index: int in range(value.length()):
		var character: String = value.substr(index, 1)
		if _is_identifier_part(character.to_lower()) or character == "_":
			result += character
			previous_was_separator = false
		elif not previous_was_separator:
			result += "_"
			previous_was_separator = true
	while result.contains("__"):
		result = result.replace("__", "_")
	result = result.strip_edges().trim_prefix("_").trim_suffix("_")
	if result.is_empty():
		return ""
	if result.substr(0, 1).is_valid_int():
		result = "method_" + result
	return result


func _to_pascal_case(identifier: String) -> String:
	var parts: PackedStringArray = identifier.split("_", false)
	var result: String = ""
	for part: String in parts:
		if part.is_empty():
			continue
		result += part.substr(0, 1).to_upper() + part.substr(1)
	return result


func _to_camel_case(identifier: String) -> String:
	var pascal: String = _to_pascal_case(identifier)
	if pascal.is_empty():
		return identifier
	return pascal.substr(0, 1).to_lower() + pascal.substr(1)


func _get_schema_table_name(schema: Variant) -> String:
	if schema == null:
		return ""
	if schema is Dictionary:
		var dictionary: Dictionary = schema
		if dictionary.has("table_name"):
			return _GF_VARIANT_ACCESS_SCRIPT.get_option_string(dictionary, "table_name")
		if dictionary.has("table_key"):
			return _GF_VARIANT_ACCESS_SCRIPT.get_option_string(dictionary, "table_key")
		return ""
	if schema is Object:
		var object: Object = schema
		var table_name: String = _GF_VARIANT_ACCESS_SCRIPT.to_text(_get_object_property_or_default(object, &"table_name", ""))
		if not table_name.is_empty():
			return table_name
		return _GF_VARIANT_ACCESS_SCRIPT.to_text(_get_object_property_or_default(object, &"table_key", ""))
	return ""


func _get_schema_metadata(schema: Variant) -> Dictionary:
	if schema == null:
		return {}
	if schema is Dictionary:
		var dictionary: Dictionary = schema
		var metadata: Variant = _GF_VARIANT_ACCESS_SCRIPT.get_option_value(dictionary, "metadata", {})
		if metadata is Dictionary:
			var metadata_dictionary: Dictionary = metadata
			return metadata_dictionary.duplicate(true)
		return {}
	if schema is Object:
		var object: Object = schema
		var metadata_variant: Variant = _get_object_property_or_default(object, &"metadata", {})
		if metadata_variant is Dictionary:
			var metadata_dictionary: Dictionary = metadata_variant
			return metadata_dictionary.duplicate(true)
		return {}
	return {}


func _get_schema_comment(metadata: Dictionary) -> String:
	if metadata.has("comment"):
		return _GF_VARIANT_ACCESS_SCRIPT.get_option_string(metadata, "comment")
	if metadata.has("description"):
		return _GF_VARIANT_ACCESS_SCRIPT.get_option_string(metadata, "description")
	return ""


func _get_object_property_or_default(object: Object, property_name: StringName, default_value: Variant) -> Variant:
	for property: Dictionary in object.get_property_list():
		if _GF_VARIANT_ACCESS_SCRIPT.get_option_string_name(property, "name") == property_name:
			return object.get_indexed(NodePath(String(property_name)))
	return default_value


func _to_constant_name(identifier: String) -> String:
	return identifier.to_upper()


func _is_identifier_part(character: String) -> bool:
	if character.length() != 1:
		return false

	var code: int = character.unicode_at(0)
	return (
		(code >= 97 and code <= 122)
		or (code >= 48 and code <= 57)
	)


func _escape_string(value: String) -> String:
	return value.replace("\\", "\\\\").replace("\"", "\\\"")


func _store_file_string(file: FileAccess, value: String) -> void:
	var _stored: bool = file.store_string(value)


func _append_packed_string(target: PackedStringArray, value: String) -> void:
	var _appended: bool = target.append(value)
