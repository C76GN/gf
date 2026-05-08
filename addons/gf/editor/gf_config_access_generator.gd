@tool

## GFConfigAccessGenerator: 生成静态导表访问器脚本。
##
## 生成结果只封装 `GFConfigProvider.get_record()` / `get_table()` 调用，
## 不规定项目表结构语义，适合需要 IDE 补全和集中表名常量的项目使用。
class_name GFConfigAccessGenerator
extends RefCounted


# --- 常量 ---

const DEFAULT_OUTPUT_PATH: String = "res://gf/generated/gf_config_access.gd"
const DEFAULT_CLASS_NAME: String = "GFConfigAccess"
const DEFAULT_PROVIDER_ACCESSOR: String = "Gf.get_utility(GFConfigProvider) as GFConfigProvider"


# --- 公共方法 ---

## 根据 schema 列表生成访问器并写入文件。
## @param schemas: `GFConfigTableSchema` 列表。
## @param output_path: 生成文件输出路径。
## @param overwrite_existing: 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。
## @param access_class_name: 生成脚本的 class_name。
## @param provider_accessor: 无显式 provider 参数时用于获取 Provider 的表达式。
## @return 写入结果错误码。
func generate(
	schemas: Array,
	output_path: String = DEFAULT_OUTPUT_PATH,
	overwrite_existing: bool = true,
	access_class_name: String = DEFAULT_CLASS_NAME,
	provider_accessor: String = DEFAULT_PROVIDER_ACCESSOR
) -> Error:
	return save_source(output_path, build_source(schemas, access_class_name, provider_accessor), overwrite_existing)


## 根据 schema 列表生成访问器源码。
## @param schemas: `GFConfigTableSchema` 列表。
## @param access_class_name: 生成脚本的 class_name。
## @param provider_accessor: 无显式 provider 参数时用于获取 Provider 的表达式。
## @return GDScript 源码。
func build_source(
	schemas: Array,
	access_class_name: String = DEFAULT_CLASS_NAME,
	provider_accessor: String = DEFAULT_PROVIDER_ACCESSOR
) -> String:
	var records := _collect_schema_records(schemas)
	var output := PackedStringArray()
	output.append("## %s: 自动生成的静态导表访问器。" % access_class_name)
	output.append("##")
	output.append("## 该文件由 GFConfigAccessGenerator 生成，可以提交到版本库；请不要手动编辑。")
	output.append("class_name %s" % access_class_name)
	output.append("extends RefCounted")
	output.append("")
	output.append("")
	output.append("# --- 常量 ---")
	output.append("")
	for record: Dictionary in records:
		output.append("const %s: StringName = &\"%s\"" % [
			String(record.get("constant_name", "")),
			_escape_string(String(record.get("table_name", ""))),
		])

	output.append("")
	output.append("")
	output.append("# --- 公共方法 ---")
	output.append("")
	var used_methods: Dictionary = {}
	for record: Dictionary in records:
		_append_table_accessors(output, record, used_methods)

	output.append("")
	output.append("# --- 私有/辅助方法 ---")
	output.append("")
	output.append("static func _provider_or_null(provider: GFConfigProvider = null) -> GFConfigProvider:")
	output.append("\tif provider != null:")
	output.append("\t\treturn provider")
	output.append("\treturn %s" % provider_accessor)
	return "\n".join(output) + "\n"


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

func _collect_schema_records(schemas: Array) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for schema_variant: Variant in schemas:
		var schema := schema_variant as GFConfigTableSchema
		if schema == null:
			continue

		var table_name := String(schema.get_table_key())
		if table_name.is_empty():
			continue

		var method_prefix := _sanitize_identifier(table_name)
		if method_prefix.is_empty():
			push_warning("[GFConfigAccessGenerator] 表名无法生成有效访问器，已跳过：%s" % table_name)
			continue

		records.append({
			"table_name": table_name,
			"method_prefix": method_prefix,
			"constant_name": _to_constant_name(method_prefix),
		})

	records.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return String(left.get("table_name", "")) < String(right.get("table_name", ""))
	)
	return records


func _append_table_accessors(output: PackedStringArray, record: Dictionary, used_methods: Dictionary) -> void:
	var method_prefix := String(record.get("method_prefix", ""))
	var constant_name := String(record.get("constant_name", ""))
	var record_method := "get_%s_record" % method_prefix
	var table_method := "get_%s_table" % method_prefix
	if used_methods.has(record_method) or used_methods.has(table_method):
		push_warning("[GFConfigAccessGenerator] 函数名重复，已跳过：%s" % method_prefix)
		return

	used_methods[record_method] = true
	used_methods[table_method] = true
	output.append("## 获取 `%s` 表中的单条记录。" % String(record.get("table_name", "")))
	output.append("static func %s(id: Variant, provider: GFConfigProvider = null) -> Variant:" % record_method)
	output.append("\tvar resolved_provider := _provider_or_null(provider)")
	output.append("\tif resolved_provider == null:")
	output.append("\t\treturn null")
	output.append("\treturn resolved_provider.get_record(%s, id)" % constant_name)
	output.append("")
	output.append("")
	output.append("## 获取 `%s` 整张表数据。" % String(record.get("table_name", "")))
	output.append("static func %s(provider: GFConfigProvider = null) -> Variant:" % table_method)
	output.append("\tvar resolved_provider := _provider_or_null(provider)")
	output.append("\tif resolved_provider == null:")
	output.append("\t\treturn null")
	output.append("\treturn resolved_provider.get_table(%s)" % constant_name)
	output.append("")
	output.append("")


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
