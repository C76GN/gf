## GFConfigTableSchema: 通用导表结构声明与校验器。
##
## 用于在导入期或运行时校验表数据结构，保持数据工具链可替换且不绑定业务表。
class_name GFConfigTableSchema
extends Resource


# --- 导出变量 ---

## 表名。为空时可由调用方自行决定表标识。
@export var table_name: StringName = &""

## 记录 ID 字段。为空时不检查记录 ID。
@export var id_field: StringName = &"id"

## 字段声明列表。
@export var columns: Array[GFConfigTableColumn] = []

## 是否允许记录包含 schema 未声明的字段。
@export var allow_extra_fields: bool = true

## 是否在校验前按字段声明尝试类型转换。
@export var coerce_values: bool = false

## 可选元数据，供导入器、编辑器或项目层扩展使用。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取稳定表键。
## @return 表名。
func get_table_key() -> StringName:
	return table_name


## 获取字段声明。
## @param field_name: 字段名。
## @return 找到时返回字段声明，否则返回 null。
func get_column(field_name: StringName) -> GFConfigTableColumn:
	for column: GFConfigTableColumn in columns:
		if column != null and column.get_field_key() == field_name:
			return column
	return null


## 检查字段声明是否存在。
## @param field_name: 字段名。
## @return 存在返回 true。
func has_column(field_name: StringName) -> bool:
	return get_column(field_name) != null


## 获取当前 schema 的字段名列表。
## @return 字段名列表。
func get_column_names() -> PackedStringArray:
	var result := PackedStringArray()
	for column: GFConfigTableColumn in columns:
		if column != null and column.get_field_key() != &"":
			result.append(str(column.get_field_key()))
	result.sort()
	return result


## 校验单条记录。
## @param record: 记录字典。
## @param row_key: 可选行标识，用于错误报告。
## @return 校验报告字典。
func validate_record(record: Dictionary, row_key: Variant = null) -> Dictionary:
	var report: Dictionary = _make_report(1)
	var working_record: Dictionary = coerce_record(record) if coerce_values else record
	var declared_fields: Dictionary = {}

	for column: GFConfigTableColumn in columns:
		if column == null:
			_add_issue(report, "error", "null_column", row_key, &"", "字段声明为空。")
			continue

		var field_key := column.get_field_key()
		if field_key == &"":
			_add_issue(report, "error", "empty_field", row_key, &"", "字段名为空。")
			continue

		declared_fields[field_key] = true
		if not working_record.has(field_key):
			if column.required:
				_add_issue(report, "error", "missing_required", row_key, field_key, "缺少必填字段：%s。" % str(field_key))
			continue

		var value: Variant = working_record[field_key]
		if value == null and not column.allow_null:
			_add_issue(report, "error", "null_value", row_key, field_key, "字段不允许为空：%s。" % str(field_key))
		elif not column.is_value_valid(value):
			_add_issue(report, "error", "invalid_type", row_key, field_key, "字段类型不匹配：%s。" % str(field_key))

	if not allow_extra_fields:
		for field_variant: Variant in working_record.keys():
			var field_name := StringName(field_variant)
			if not declared_fields.has(field_name):
				_add_issue(report, "error", "extra_field", row_key, field_name, "存在未声明字段：%s。" % str(field_name))

	_finalize_report(report)
	return report


## 校验整张表。
## @param table_data: Array[Dictionary] 或 Dictionary 形式的表数据。
## @return 校验报告字典。
func validate_table(table_data: Variant) -> Dictionary:
	var report: Dictionary = _make_report(0)
	if table_data is Array:
		_validate_array_table(table_data as Array, report)
	elif table_data is Dictionary:
		_validate_dictionary_table(table_data as Dictionary, report)
	else:
		_add_issue(report, "error", "invalid_table", null, &"", "表数据必须是 Array 或 Dictionary。")

	_finalize_report(report)
	return report


## 按字段声明转换单条记录。
## @param record: 输入记录。
## @return 转换后的新记录。
func coerce_record(record: Dictionary) -> Dictionary:
	var result: Dictionary = record.duplicate(true)
	for column: GFConfigTableColumn in columns:
		if column == null or column.get_field_key() == &"":
			continue

		var field_key := column.get_field_key()
		if result.has(field_key):
			result[field_key] = column.coerce_value(result[field_key])
		elif column.default_value != null:
			result[field_key] = column.coerce_value(column.default_value)
	return result


## 创建空记录模板。
## @param include_optional: 为 true 时包含非必填字段。
## @return 新记录字典。
func build_empty_record(include_optional: bool = true) -> Dictionary:
	var result: Dictionary = {}
	for column: GFConfigTableColumn in columns:
		if column == null or column.get_field_key() == &"":
			continue
		if column.required or include_optional:
			result[column.get_field_key()] = column.coerce_value(column.default_value)
	return result


## 创建同内容拷贝，避免运行时修改污染共享 Resource。
## @return 新 schema。
func duplicate_schema() -> GFConfigTableSchema:
	var schema: GFConfigTableSchema = GFConfigTableSchema.new()
	schema.table_name = table_name
	schema.id_field = id_field
	schema.allow_extra_fields = allow_extra_fields
	schema.coerce_values = coerce_values
	schema.metadata = metadata.duplicate(true)
	for column: GFConfigTableColumn in columns:
		schema.columns.append(column.duplicate_column() if column != null else null)
	return schema


## 导出 schema 摘要。
## @return schema 字典。
func describe() -> Dictionary:
	var column_descriptions: Array[Dictionary] = []
	for column: GFConfigTableColumn in columns:
		if column != null:
			column_descriptions.append(column.describe())
	return {
		"table_name": table_name,
		"id_field": id_field,
		"columns": column_descriptions,
		"allow_extra_fields": allow_extra_fields,
		"coerce_values": coerce_values,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _validate_array_table(rows: Array, report: Dictionary) -> void:
	report["row_count"] = rows.size()
	for index: int in range(rows.size()):
		var row: Variant = rows[index]
		if not (row is Dictionary):
			_add_issue(report, "error", "invalid_row", index, &"", "行数据必须是 Dictionary。")
			continue

		var record := row as Dictionary
		var row_key: Variant = record.get(id_field, index) if id_field != &"" else index
		_merge_report(report, validate_record(record, row_key))


func _validate_dictionary_table(table: Dictionary, report: Dictionary) -> void:
	report["row_count"] = table.size()
	for key: Variant in table.keys():
		var row: Variant = table[key]
		if not (row is Dictionary):
			_add_issue(report, "error", "invalid_row", key, &"", "行数据必须是 Dictionary。")
			continue

		var record := row as Dictionary
		var row_key: Variant = record.get(id_field, key) if id_field != &"" else key
		_merge_report(report, validate_record(record, row_key))


func _make_report(row_count: int) -> Dictionary:
	return {
		"ok": true,
		"table_name": table_name,
		"row_count": row_count,
		"error_count": 0,
		"warning_count": 0,
		"issues": [],
	}


func _add_issue(
	report: Dictionary,
	severity: String,
	code: String,
	row_key: Variant,
	field_name: StringName,
	message: String
) -> void:
	var issues := report["issues"] as Array
	issues.append({
		"severity": severity,
		"code": code,
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


func _merge_report(target: Dictionary, source: Dictionary) -> void:
	target["error_count"] = int(target["error_count"]) + int(source.get("error_count", 0))
	target["warning_count"] = int(target["warning_count"]) + int(source.get("warning_count", 0))
	if not bool(source.get("ok", true)):
		target["ok"] = false

	var target_issues := target["issues"] as Array
	var source_issues := source.get("issues", []) as Array
	for issue: Dictionary in source_issues:
		target_issues.append(issue.duplicate(true))


func _finalize_report(report: Dictionary) -> void:
	report["ok"] = int(report.get("error_count", 0)) == 0
