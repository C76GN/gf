## GFConfigReferenceResolver: 通用导表引用校验与解析工具。
##
## 在多张表加载后统一检查引用、构建复合索引，并可把记录中的引用解析为目标记录副本。
class_name GFConfigReferenceResolver
extends RefCounted


# --- 公共方法 ---

## 构建表数据索引。
## @param table_data: Array[Dictionary] 或 Dictionary 形式的表数据。
## @param field_names: 参与索引的字段名。
## @return 索引字典，key 为复合键，value 为记录数组。
static func build_index(table_data: Variant, field_names: PackedStringArray) -> Dictionary:
	var result: Dictionary = {}
	for entry: Dictionary in _normalize_rows(table_data):
		var record := entry["record"] as Dictionary
		var key := _make_key(record, field_names, true)
		if key.is_empty():
			continue
		if not result.has(key):
			result[key] = []
		(result[key] as Array).append(record.duplicate(true))
	return result


## 校验多张表的 schema 与引用关系。
## @param tables_by_name: 表名到表数据的字典。
## @param schemas: schema 列表。
## @param options: 可选参数，当前支持 validate_schema。
## @return 聚合校验报告字典。
static func validate_tables(
	tables_by_name: Dictionary,
	schemas: Array[GFConfigTableSchema],
	options: Dictionary = {}
) -> Dictionary:
	var report := _make_report()
	var schema_lookup := _build_schema_lookup(schemas)
	var validate_schema := bool(options.get("validate_schema", true))

	for schema: GFConfigTableSchema in schemas:
		if schema == null:
			continue
		var table_name := schema.get_table_key()
		if not tables_by_name.has(table_name):
			_add_issue(report, "error", "missing_table", table_name, null, &"", "缺少表数据：%s。" % String(table_name))
			continue
		if validate_schema:
			_merge_report(report, schema.validate_table(tables_by_name[table_name]))
		_validate_schema_references(schema, tables_by_name, schema_lookup, report)

	_finalize_report(report)
	return report


## 解析单条记录的引用目标。
## @param record: 来源记录。
## @param schema: 来源 schema。
## @param tables_by_name: 表名到表数据的字典。
## @param schemas_by_name: 可选 schema 字典。
## @return 引用 ID 到目标记录副本的字典。
static func resolve_record_references(
	record: Dictionary,
	schema: GFConfigTableSchema,
	tables_by_name: Dictionary,
	schemas_by_name: Dictionary = {}
) -> Dictionary:
	var result: Dictionary = {}
	if schema == null:
		return result

	for reference: GFConfigTableReference in schema.references:
		if reference == null or not reference.is_valid_definition():
			continue
		var source_key := reference.make_source_key(record)
		if source_key.is_empty():
			continue

		var target_schema := schemas_by_name.get(reference.target_table_name) as GFConfigTableSchema
		var target_fields := reference.get_target_fields(target_schema)
		var target_index := build_index(tables_by_name.get(reference.target_table_name, []), target_fields)
		var matches := target_index.get(source_key, []) as Array
		if matches != null and not matches.is_empty():
			result[reference.get_reference_id()] = (matches[0] as Dictionary).duplicate(true)
	return result


# --- 私有/辅助方法 ---

static func _validate_schema_references(
	schema: GFConfigTableSchema,
	tables_by_name: Dictionary,
	schema_lookup: Dictionary,
	report: Dictionary
) -> void:
	for reference: GFConfigTableReference in schema.references:
		if reference == null or not reference.is_valid_definition():
			_add_issue(report, "error", "invalid_reference", schema.get_table_key(), null, &"", "引用声明无效。")
			continue

		var target_schema := schema_lookup.get(reference.target_table_name) as GFConfigTableSchema
		var target_fields := reference.get_target_fields(target_schema)
		if target_fields.is_empty():
			_add_issue(
				report,
				"error",
				"missing_reference_target_fields",
				schema.get_table_key(),
				null,
				&"",
				"引用缺少目标字段：%s。" % String(reference.get_reference_id())
			)
			continue

		var target_table: Variant = tables_by_name.get(reference.target_table_name, null)
		if target_table == null:
			_add_issue(
				report,
				"error",
				"missing_reference_target_table",
				schema.get_table_key(),
				null,
				&"",
				"引用目标表不存在：%s。" % String(reference.target_table_name)
			)
			continue

		var target_index := build_index(target_table, target_fields)
		for entry: Dictionary in _normalize_rows(tables_by_name.get(schema.get_table_key(), [])):
			var record := entry["record"] as Dictionary
			var source_key := reference.make_source_key(record)
			if source_key.is_empty():
				if reference.required:
					_add_issue(
						report,
						"error",
						"missing_reference_value",
						schema.get_table_key(),
						entry.get("row_key"),
						_first_field(reference.source_fields),
						"引用来源字段缺失：%s。" % String(reference.get_reference_id())
					)
				continue
			if reference.required and not target_index.has(source_key):
				_add_issue(
					report,
					"error",
					"missing_reference",
					schema.get_table_key(),
					entry.get("row_key"),
					_first_field(reference.source_fields),
					"引用目标不存在：%s。" % String(reference.get_reference_id())
				)


static func _build_schema_lookup(schemas: Array[GFConfigTableSchema]) -> Dictionary:
	var result: Dictionary = {}
	for schema: GFConfigTableSchema in schemas:
		if schema != null and schema.get_table_key() != &"":
			result[schema.get_table_key()] = schema
	return result


static func _normalize_rows(table_data: Variant) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if table_data is Array:
		var array_table := table_data as Array
		for index: int in range(array_table.size()):
			var row_variant: Variant = array_table[index]
			if row_variant is Dictionary:
				rows.append({
					"row_key": (row_variant as Dictionary).get(&"id", index),
					"record": (row_variant as Dictionary).duplicate(true),
				})
	elif table_data is Dictionary:
		var table := table_data as Dictionary
		for key: Variant in table.keys():
			var row_variant: Variant = table[key]
			if row_variant is Dictionary:
				rows.append({
					"row_key": key,
					"record": (row_variant as Dictionary).duplicate(true),
				})
	return rows


static func _make_key(record: Dictionary, field_names: PackedStringArray, allow_null_values: bool) -> String:
	var parts := PackedStringArray()
	for field_name: String in field_names:
		var key := StringName(field_name)
		if not record.has(key):
			return ""
		var value: Variant = record[key]
		if value == null and not allow_null_values:
			return ""
		parts.append("%d:%s" % [typeof(value), var_to_str(value)])
	return "|".join(parts)


static func _make_report() -> Dictionary:
	return {
		"ok": true,
		"table_name": &"",
		"row_count": 0,
		"error_count": 0,
		"warning_count": 0,
		"issues": [],
	}


static func _add_issue(
	report: Dictionary,
	severity: String,
	table_code: String,
	table_name: StringName,
	row_key: Variant,
	field_name: StringName,
	message: String
) -> void:
	var issues := report["issues"] as Array
	issues.append({
		"severity": severity,
		"code": table_code,
		"table_name": table_name,
		"row_key": row_key,
		"field": field_name,
		"message": message,
	})
	if severity == "warning":
		report["warning_count"] = int(report["warning_count"]) + 1
	else:
		report["error_count"] = int(report["error_count"]) + 1
		report["ok"] = false


static func _merge_report(target: Dictionary, source: Dictionary) -> void:
	target["row_count"] = int(target.get("row_count", 0)) + int(source.get("row_count", 0))
	target["error_count"] = int(target.get("error_count", 0)) + int(source.get("error_count", 0))
	target["warning_count"] = int(target.get("warning_count", 0)) + int(source.get("warning_count", 0))
	if not bool(source.get("ok", true)):
		target["ok"] = false

	var target_issues := target["issues"] as Array
	for issue: Dictionary in source.get("issues", []) as Array:
		target_issues.append(issue.duplicate(true))


static func _finalize_report(report: Dictionary) -> void:
	report["ok"] = int(report.get("error_count", 0)) == 0


static func _first_field(fields: PackedStringArray) -> StringName:
	if fields.is_empty():
		return &""
	return StringName(fields[0])
