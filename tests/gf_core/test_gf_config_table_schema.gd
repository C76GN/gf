## 测试通用导表 schema、导入器与 Provider 注册能力。
extends GutTest


# --- 测试 ---

func test_schema_validate_table_reports_missing_type_and_extra_fields() -> void:
	var schema := _make_item_schema()
	schema.allow_extra_fields = false

	var report := schema.validate_table([
		{ "id": 1, "name": "Potion", "power": 3.5 },
		{ "id": "bad", "extra": true },
	])
	var issues := report["issues"] as Array

	assert_false(bool(report["ok"]), "包含缺字段、类型错误和额外字段时校验应失败。")
	assert_eq(int(report["row_count"]), 2, "表校验应记录行数。")
	assert_true(_has_issue_code(issues, "invalid_type"), "错误报告应包含类型错误。")
	assert_true(_has_issue_code(issues, "missing_required"), "错误报告应包含缺失必填字段。")
	assert_true(_has_issue_code(issues, "extra_field"), "错误报告应包含额外字段。")


func test_schema_coerce_record_applies_column_types_and_defaults() -> void:
	var schema := _make_item_schema()
	schema.coerce_values = true

	var record := schema.coerce_record({ "id": "7", "name": 42 })

	assert_eq(record["id"], 7, "id 应按列声明转换为 int。")
	assert_eq(record["name"], "42", "name 应按列声明转换为 String。")
	assert_eq(record["power"], 1.0, "缺失字段应补默认值并转换。")


func test_config_provider_registers_schema_and_validates_table() -> void:
	var provider := GFConfigProvider.new()
	var schema := _make_item_schema()

	assert_true(provider.register_schema(schema), "有效 schema 应注册成功。")
	assert_true(provider.has_schema(&"items"), "Provider 应可查询已注册 schema。")

	var report := provider.validate_record(&"items", { "id": 1, "name": "Potion", "power": 2.0 })

	assert_true(bool(report["ok"]), "Provider 应通过已注册 schema 校验记录。")
	assert_eq(provider.get_schema_ids(), PackedStringArray(["items"]), "schema id 应排序返回。")


func test_csv_importer_parses_quotes_and_validates_with_coercion() -> void:
	var schema := _make_item_schema()
	schema.coerce_values = true

	var parsed := GFConfigTableImporter.parse_csv_table("id,name,power\n1,\"A,B\",2.5\n")
	var report := GFConfigTableImporter.validate_csv_table("id,name,power\n1,\"A,B\",2.5\n", schema)
	var rows := parsed["data"] as Array

	assert_true(bool(parsed["success"]), "CSV 应解析成功。")
	assert_eq((rows[0] as Dictionary)["name"], "A,B", "引号内逗号应保留为单元格内容。")
	assert_true(bool(report["ok"]), "启用 coerce_values 后 CSV 字符串值应可通过 schema 校验。")


func test_json_importer_reports_parse_failure_as_validation_report() -> void:
	var report := GFConfigTableImporter.validate_json_table("{bad", _make_item_schema())

	assert_false(bool(report["ok"]), "非法 JSON 应返回失败校验报告。")
	assert_eq(((report["issues"] as Array)[0] as Dictionary)["code"], "parse_failed", "失败报告应标记解析错误。")


# --- 私有/辅助方法 ---

func _make_item_schema() -> GFConfigTableSchema:
	var id_column := GFConfigTableColumn.new()
	id_column.field_name = &"id"
	id_column.value_type = GFConfigTableColumn.ValueType.INT
	id_column.required = true
	id_column.allow_null = false

	var name_column := GFConfigTableColumn.new()
	name_column.field_name = &"name"
	name_column.value_type = GFConfigTableColumn.ValueType.STRING
	name_column.required = true
	name_column.allow_null = false

	var power_column := GFConfigTableColumn.new()
	power_column.field_name = &"power"
	power_column.value_type = GFConfigTableColumn.ValueType.FLOAT
	power_column.default_value = 1.0

	var schema := GFConfigTableSchema.new()
	schema.table_name = &"items"
	schema.columns = [id_column, name_column, power_column]
	return schema


func _has_issue_code(issues: Array, code: String) -> bool:
	for issue: Dictionary in issues:
		if str(issue.get("code", "")) == code:
			return true
	return false
