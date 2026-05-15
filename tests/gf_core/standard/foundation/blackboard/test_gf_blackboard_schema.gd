## 测试通用黑板 Schema 与字段声明。
extends GutTest


# --- 常量 ---

const GFBlackboardEntryBase = preload("res://addons/gf/standard/foundation/blackboard/gf_blackboard_entry.gd")
const GFBlackboardSchemaBase = preload("res://addons/gf/standard/foundation/blackboard/gf_blackboard_schema.gd")


# --- 测试方法 ---

func test_blackboard_schema_coerces_values_and_defaults() -> void:
	var schema := _make_agent_schema()
	schema.coerce_values = true

	var values := schema.apply_defaults({
		"hp": "12",
		"target": "enemy",
		"position": [1, 2],
	})
	var report := schema.validate_values(values)

	assert_true(bool(report["ok"]), "补默认值并转换后应通过 schema 校验。")
	assert_eq(values[&"hp"], 12, "字段应按声明转换为 int。")
	assert_eq(values[&"target"], &"enemy", "字段应按声明转换为 StringName。")
	assert_eq(values[&"position"], Vector2(1.0, 2.0), "数组应可转换为 Vector2。")
	assert_eq(values[&"enabled"], true, "缺失字段应补默认值。")


func test_blackboard_schema_reports_missing_type_and_extra_keys() -> void:
	var schema := _make_agent_schema()
	schema.allow_extra_keys = false

	var report := schema.validate_values({
		"hp": "bad",
		"extra": true,
	})

	assert_false(bool(report["ok"]), "缺字段、类型错误和额外字段应使校验失败。")
	assert_true(_has_issue(report, "missing_required"), "报告应包含缺失必填字段。")
	assert_true(_has_issue(report, "invalid_type"), "报告应包含类型错误。")
	assert_true(_has_issue(report, "extra_key"), "报告应包含额外字段。")


func test_blackboard_schema_duplicate_isolated_entries() -> void:
	var schema := _make_agent_schema()
	var schema_copy := schema.duplicate_schema()
	schema_copy.entries.clear()

	var report := schema.validate_values({
		"hp": 10,
		"target": &"enemy",
	})

	assert_true(bool(report["ok"]), "修改 schema 拷贝不应污染原 schema。")
	assert_eq(schema_copy.entries.size(), 0, "拷贝应可独立修改。")


func test_blackboard_entry_rejects_invalid_color_string() -> void:
	var entry := GFBlackboardEntryBase.new()
	entry.value_type = GFBlackboardEntry.ValueType.COLOR

	var invalid_result := entry.try_coerce_value("not_a_color")
	var valid_result := entry.try_coerce_value("#ff0000")

	assert_false(bool(invalid_result.get("ok", false)), "无效颜色字符串不应静默转换为黑色。")
	assert_true(bool(valid_result.get("ok", false)), "有效 HTML 颜色字符串应可转换。")
	assert_eq(valid_result.get("value"), Color(1.0, 0.0, 0.0, 1.0), "颜色通道应来自输入文本。")


# --- 私有/辅助方法 ---

func _make_agent_schema() -> GFBlackboardSchema:
	var hp_entry := GFBlackboardEntryBase.new()
	hp_entry.key = &"hp"
	hp_entry.value_type = GFBlackboardEntry.ValueType.INT
	hp_entry.required = true
	hp_entry.allow_null = false

	var target_entry := GFBlackboardEntryBase.new()
	target_entry.key = &"target"
	target_entry.value_type = GFBlackboardEntry.ValueType.STRING_NAME
	target_entry.required = true
	target_entry.allow_null = false

	var position_entry := GFBlackboardEntryBase.new()
	position_entry.key = &"position"
	position_entry.value_type = GFBlackboardEntry.ValueType.VECTOR2
	position_entry.default_value = Vector2.ZERO

	var enabled_entry := GFBlackboardEntryBase.new()
	enabled_entry.key = &"enabled"
	enabled_entry.value_type = GFBlackboardEntry.ValueType.BOOL
	enabled_entry.default_value = true

	var schema := GFBlackboardSchemaBase.new()
	schema.schema_id = &"agent"
	schema.entries = [hp_entry, target_entry, position_entry, enabled_entry]
	return schema


func _has_issue(report: Dictionary, kind: String) -> bool:
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue != null and String(issue.get("kind", "")) == kind:
			return true
	return false
