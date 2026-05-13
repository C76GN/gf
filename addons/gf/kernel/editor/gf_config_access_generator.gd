@tool

## GFConfigAccessGenerator: 生成静态导表访问器脚本。
##
## 生成结果只封装 provider 的 `get_record()` / `get_table()` 调用，
## 不规定项目表结构语义，适合需要 IDE 补全和集中表名常量的项目使用。
class_name GFConfigAccessGenerator
extends RefCounted


# --- 常量 ---

const DEFAULT_OUTPUT_PATH: String = "res://gf/generated/gf_config_access.gd"
const DEFAULT_CLASS_NAME: String = "GFConfigAccess"
const DEFAULT_PROVIDER_ACCESSOR: String = "null"


# --- 公共方法 ---

## 根据 schema 列表生成访问器并写入文件。
## @param schemas: 带有 `get_table_key()` 方法或 `table_name` 属性的 schema 列表。
## @param output_path: 生成文件输出路径。
## @param overwrite_existing: 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。
## @param access_class_name: 生成脚本的 class_name。
## @param provider_accessor: 无显式 provider 参数时用于获取 provider 的表达式。
## @param options: 可选生成选项，支持 method_name_style、constant_prefix、record_method_pattern、table_method_pattern、include_schema_comments。
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
## @param schemas: 带有 `get_table_key()` 方法或 `table_name` 属性的 schema 列表。
## @param access_class_name: 生成脚本的 class_name。
## @param provider_accessor: 无显式 provider 参数时用于获取 provider 的表达式。
## @param options: 可选生成选项。
## @return GDScript 源码。
func build_source(
	schemas: Array,
	access_class_name: String = DEFAULT_CLASS_NAME,
	provider_accessor: String = DEFAULT_PROVIDER_ACCESSOR,
	options: Dictionary = {}
) -> String:
	var generation_options := _normalize_generation_options(options)
	var records := _collect_schema_records(schemas, generation_options)
	var builder := GFSourceBuilder.new()
	builder.doc("%s: 自动生成的静态导表访问器。" % access_class_name)
	builder.doc()
	builder.doc("该文件由 GFConfigAccessGenerator 生成，可以提交到版本库；请不要手动编辑。")
	builder.line("class_name %s" % access_class_name)
	builder.line("extends RefCounted")
	builder.blank(2)
	builder.section("常量")
	for record: Dictionary in records:
		builder.line("const %s: StringName = &\"%s\"" % [
			String(record.get("constant_name", "")),
			_escape_string(String(record.get("table_name", ""))),
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
	return builder.build()


## 保存生成源码到指定路径。
## @param output_path: 生成文件输出路径。
## @param source: GDScript 源码。
## @param overwrite_existing: 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。
## @return 写入结果错误码。
func save_source(output_path: String, source: String, overwrite_existing: bool = true) -> Error:
	if output_path.is_empty():
		push_error("[GFConfigAccessGenerator] 输出路径为空。")
		return ERR_INVALID_PARAMETER

	if FileAccess.file_exists(output_path) and not overwrite_existing:
		push_warning("[GFConfigAccessGenerator] 目标文件已存在，已跳过：%s" % output_path)
		return ERR_ALREADY_EXISTS

	DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		var open_error := FileAccess.get_open_error()
		push_error("[GFConfigAccessGenerator] 无法写入导表访问器脚本：%s (%s)" % [output_path, error_string(open_error)])
		return open_error

	file.store_string(source)
	file.close()

	if Engine.is_editor_hint():
		var filesystem := EditorInterface.get_resource_filesystem()
		if filesystem != null:
			filesystem.scan()

	return OK


# --- 私有/辅助方法 ---

func _collect_schema_records(schemas: Array, options: Dictionary) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for schema_variant: Variant in schemas:
		var table_name := _get_schema_table_name(schema_variant)
		if table_name.is_empty():
			continue

		var method_prefix := _sanitize_identifier(table_name)
		if method_prefix.is_empty():
			push_warning("[GFConfigAccessGenerator] 表名无法生成有效访问器，已跳过：%s" % table_name)
			continue

		var metadata := _get_schema_metadata(schema_variant)
		records.append({
			"table_name": table_name,
			"method_prefix": _format_identifier(method_prefix, String(options.get("method_name_style", "snake"))),
			"constant_name": "%s%s" % [String(options.get("constant_prefix", "")), _to_constant_name(method_prefix)],
			"comment": _get_schema_comment(metadata),
		})

	records.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return String(left.get("table_name", "")) < String(right.get("table_name", ""))
	)
	return records


func _append_table_accessors(
	builder: GFSourceBuilder,
	record: Dictionary,
	used_methods: Dictionary,
	options: Dictionary
) -> void:
	var method_prefix := String(record.get("method_prefix", ""))
	var constant_name := String(record.get("constant_name", ""))
	var record_method := _format_method_pattern(String(options.get("record_method_pattern", "get_{table}_record")), method_prefix)
	var table_method := _format_method_pattern(String(options.get("table_method_pattern", "get_{table}_table")), method_prefix)
	if used_methods.has(record_method) or used_methods.has(table_method):
		push_warning("[GFConfigAccessGenerator] 函数名重复，已跳过：%s" % method_prefix)
		return

	used_methods[record_method] = true
	used_methods[table_method] = true
	var comment := String(record.get("comment", ""))
	if bool(options.get("include_schema_comments", true)) and not comment.is_empty():
		builder.doc(comment)
	builder.doc("获取 `%s` 表中的单条记录。" % String(record.get("table_name", "")))
	builder.line("static func %s(id: Variant, provider: Variant = null) -> Variant:" % record_method)
	builder.indent()
	builder.line("var resolved_provider := _provider_or_null(provider)")
	builder.line("if resolved_provider == null:")
	builder.indent()
	builder.line("return null")
	builder.dedent()
	builder.line("return resolved_provider.get_record(%s, id)" % constant_name)
	builder.dedent()
	builder.blank(2)
	builder.doc("获取 `%s` 整张表数据。" % String(record.get("table_name", "")))
	builder.line("static func %s(provider: Variant = null) -> Variant:" % table_method)
	builder.indent()
	builder.line("var resolved_provider := _provider_or_null(provider)")
	builder.line("if resolved_provider == null:")
	builder.indent()
	builder.line("return null")
	builder.dedent()
	builder.line("return resolved_provider.get_table(%s)" % constant_name)
	builder.dedent()
	builder.blank(2)


func _sanitize_identifier(value: String) -> String:
	var parts := PackedStringArray()
	var current := ""
	for index: int in range(value.length()):
		var character := value.substr(index, 1).to_lower()
		if _is_identifier_part(character):
			current += character
		elif not current.is_empty():
			parts.append(current)
			current = ""
	if not current.is_empty():
		parts.append(current)
	if parts.is_empty():
		return ""

	var result := "_".join(parts)
	if result.substr(0, 1).is_valid_int():
		result = "table_" + result
	return result


func _normalize_generation_options(options: Dictionary) -> Dictionary:
	var result := {
		"method_name_style": String(options.get("method_name_style", "snake")).to_lower(),
		"constant_prefix": _sanitize_constant_prefix(String(options.get("constant_prefix", ""))),
		"record_method_pattern": String(options.get("record_method_pattern", "get_{table}_record")),
		"table_method_pattern": String(options.get("table_method_pattern", "get_{table}_table")),
		"include_schema_comments": bool(options.get("include_schema_comments", true)),
	}
	if not (String(result["method_name_style"]) in ["snake", "camel", "pascal"]):
		result["method_name_style"] = "snake"
	if String(result["record_method_pattern"]).is_empty():
		result["record_method_pattern"] = "get_{table}_record"
	if String(result["table_method_pattern"]).is_empty():
		result["table_method_pattern"] = "get_{table}_table"
	return result


func _sanitize_constant_prefix(value: String) -> String:
	if value.is_empty():
		return ""
	var sanitized := _sanitize_identifier(value).to_upper()
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
	var method_name := pattern.replace("{table}", table_token)
	method_name = _sanitize_generated_method_name(method_name)
	if method_name.is_empty():
		return "get_%s" % table_token
	return method_name


func _sanitize_generated_method_name(value: String) -> String:
	var result := ""
	var previous_was_separator := false
	for index: int in range(value.length()):
		var character := value.substr(index, 1)
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
	var parts := identifier.split("_", false)
	var result := ""
	for part: String in parts:
		if part.is_empty():
			continue
		result += part.substr(0, 1).to_upper() + part.substr(1)
	return result


func _to_camel_case(identifier: String) -> String:
	var pascal := _to_pascal_case(identifier)
	if pascal.is_empty():
		return identifier
	return pascal.substr(0, 1).to_lower() + pascal.substr(1)


func _get_schema_table_name(schema: Variant) -> String:
	if schema == null:
		return ""
	if schema is Dictionary:
		var dictionary := schema as Dictionary
		if dictionary.has("table_name"):
			return String(dictionary.get("table_name"))
		if dictionary.has("table_key"):
			return String(dictionary.get("table_key"))
		return ""
	if schema is Object:
		var object := schema as Object
		if object.has_method("get_table_key"):
			return String(object.call("get_table_key"))
		return String(_get_object_property_or_default(object, &"table_name", ""))
	return ""


func _get_schema_metadata(schema: Variant) -> Dictionary:
	if schema == null:
		return {}
	if schema is Dictionary:
		var dictionary := schema as Dictionary
		var metadata: Variant = dictionary.get("metadata", {})
		return (metadata as Dictionary).duplicate(true) if metadata is Dictionary else {}
	if schema is Object:
		var object := schema as Object
		var metadata_variant: Variant = _get_object_property_or_default(object, &"metadata", {})
		return (metadata_variant as Dictionary).duplicate(true) if metadata_variant is Dictionary else {}
	return {}


func _get_schema_comment(metadata: Dictionary) -> String:
	if metadata.has("comment"):
		return String(metadata.get("comment", ""))
	if metadata.has("description"):
		return String(metadata.get("description", ""))
	return ""


func _get_object_property_or_default(object: Object, property_name: StringName, default_value: Variant) -> Variant:
	for property: Dictionary in object.get_property_list():
		if StringName(property.get("name", "")) == property_name:
			return object.get(property_name)
	return default_value


func _to_constant_name(identifier: String) -> String:
	return identifier.to_upper()


func _is_identifier_part(character: String) -> bool:
	if character.length() != 1:
		return false

	var code := character.unicode_at(0)
	return (
		(code >= 97 and code <= 122)
		or (code >= 48 and code <= 57)
	)


func _escape_string(value: String) -> String:
	return value.replace("\\", "\\\\").replace("\"", "\\\"")
