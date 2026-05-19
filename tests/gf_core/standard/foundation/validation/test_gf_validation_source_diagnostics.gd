## 测试校验报告源码定位与诊断适配辅助。
extends GutTest


# --- 常量 ---

const GF_SOURCE_SPAN_BASE := preload("res://addons/gf/standard/foundation/validation/gf_source_span.gd")
const GF_VALIDATION_DIAGNOSTIC_ADAPTER_BASE := preload("res://addons/gf/standard/foundation/validation/gf_validation_diagnostic_adapter.gd")
const GF_VALIDATION_ISSUE_BASE := preload("res://addons/gf/standard/foundation/validation/gf_validation_issue.gd")
const GF_VALIDATION_REPORT_BASE := preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")
const GF_VALIDATION_REPORT_DICTIONARY_BASE := preload("res://addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd")


# --- 测试方法 ---

func test_source_span_normalizes_source_alias_and_location() -> void:
	var span := GF_SOURCE_SPAN_BASE.from_dict({
		"source": "res://data/items.csv",
		"line": 4,
		"column": 2,
		"length": 5,
	})
	var data: Dictionary = span.to_dict(false, true)

	assert_eq(span.source_path, "res://data/items.csv", "source 应作为 source_path 兼容别名。")
	assert_eq(data["source_path"], "res://data/items.csv", "应输出标准 source_path。")
	assert_eq(data["source"], "res://data/items.csv", "需要时应输出 legacy source 别名。")
	assert_eq(span.get_effective_end_column(), 7, "未显式设置 end_column 时应由 column + length 推导。")
	assert_eq(span.get_location_text(), "res://data/items.csv:4:2", "定位文本应包含路径、行与列。")


func test_validation_issue_preserves_source_span_fields() -> void:
	var issue := GF_VALIDATION_ISSUE_BASE.from_dict({
		"severity": "warning",
		"kind": "invalid_cell",
		"message": "Cell is invalid.",
		"source": "res://data/items.csv",
		"line": 6,
		"column": 3,
		"length": 2,
		"row_key": "potion",
	})
	var data: Dictionary = issue.to_dict()
	var source_span := data["source_span"] as Dictionary

	assert_eq(data["source_path"], "res://data/items.csv", "问题应暴露标准 source_path 字段。")
	assert_eq(data["source"], "res://data/items.csv", "问题应保留 source 兼容字段。")
	assert_eq(data["line"], 6, "问题应暴露行号。")
	assert_eq(data["column"], 3, "问题应暴露列号。")
	assert_eq(source_span["line"], 6, "嵌套 source_span 应保留行号。")
	assert_eq(data["row_key"], "potion", "额外业务定位字段仍应保留。")
	assert_eq(issue.get_location_text(), "res://data/items.csv:6:3", "问题应能生成定位文本。")


func test_issue_metadata_does_not_create_source_span() -> void:
	var issue := GF_VALIDATION_ISSUE_BASE.from_dict({
		"severity": "warning",
		"kind": "metadata_only",
		"message": "Metadata only.",
		"metadata": {
			"owner": "importer",
		},
	})
	var data: Dictionary = issue.to_dict()

	assert_false(data.has("source_span"), "普通问题 metadata 不应被误写成 source_span。")
	assert_eq((data["metadata"] as Dictionary)["owner"], "importer", "普通问题 metadata 应保留在顶层。")


func test_report_source_issue_converts_to_editor_diagnostics() -> void:
	var report := GF_VALIDATION_REPORT_BASE.new("Config table")
	report.add_source_error(&"invalid_value", "Value is invalid.", {
		"source_path": "res://data/items.csv",
		"line": 8,
		"column": 4,
		"length": 3,
	})

	var diagnostics := GF_VALIDATION_DIAGNOSTIC_ADAPTER_BASE.report_to_diagnostics(report, {
		"include_positionless": false,
	})
	var line_records := GF_VALIDATION_DIAGNOSTIC_ADAPTER_BASE.make_line_records(diagnostics)
	var grouped := GF_VALIDATION_DIAGNOSTIC_ADAPTER_BASE.group_by_source(diagnostics)

	assert_eq(diagnostics.size(), 1, "报告应转换为一条诊断。")
	assert_eq(diagnostics[0]["source_path"], "res://data/items.csv", "诊断应包含源路径。")
	assert_eq(diagnostics[0]["line_index"], 7, "诊断应提供 0-based 行索引。")
	assert_eq(diagnostics[0]["column_index"], 3, "诊断应提供 0-based 列索引。")
	assert_true(String(diagnostics[0]["display_text"]).contains("Value is invalid."), "显示文本应包含问题说明。")
	assert_eq(line_records.size(), 1, "可定位诊断应生成行记录。")
	assert_eq((grouped["res://data/items.csv"] as Array).size(), 1, "诊断应按源路径分组。")


func test_diagnostic_adapter_normalizes_legacy_issue_fields() -> void:
	var diagnostic := GF_VALIDATION_DIAGNOSTIC_ADAPTER_BASE.issue_to_diagnostic({
		"severity": "error",
		"code": "legacy_code",
		"type": "legacy_type",
		"message": "Legacy issue.",
		"path": "items[0]",
	})

	assert_eq(diagnostic["kind"], "unknown", "诊断适配器不应再把旧 code/type 当作问题类别。")
	assert_false(diagnostic.has("code"), "诊断不应输出旧 code 字段。")
	assert_false(diagnostic.has("type"), "诊断不应输出旧 type 字段。")
	assert_eq(diagnostic["path"], "items[0]", "标准定位字段应继续保留。")


func test_report_source_issue_accepts_string_severity() -> void:
	var report := GF_VALIDATION_REPORT_BASE.new("Config table")
	report.add_source_issue(
		"warning",
		&"invalid_value",
		"Value is suspicious.",
		{
			"source_path": "res://data/items.csv",
			"line": 8,
			"column": 4,
		}
	)

	assert_eq(report.get_warning_count(), 1, "对象式源码问题入口应接受字符串 severity。")
	assert_eq(report.get_error_count(), 0, "warning 字符串不应被误归一为 error。")


func test_dictionary_report_can_append_source_issue() -> void:
	var report := {
		"issues": [],
	}
	GF_VALIDATION_REPORT_DICTIONARY_BASE.append_source_issue(
		report,
		"warning",
		&"missing_optional",
		"Optional field is missing.",
		GF_SOURCE_SPAN_BASE.make("res://data/items.csv", 10, 1, 4),
		{ "row_key": "shield" }
	)
	GF_VALIDATION_REPORT_DICTIONARY_BASE.finalize_report(report, "Config table")

	var issue := (report["issues"] as Array)[0] as Dictionary
	var source_span := issue["source_span"] as Dictionary

	assert_true(bool(report["ok"]), "只有警告时报告仍应通过。")
	assert_eq(issue["source_path"], "res://data/items.csv", "字典报告应包含标准 source_path。")
	assert_eq(issue["line"], 10, "字典报告应包含行号。")
	assert_eq(source_span["column"], 1, "嵌套 source_span 应包含列号。")
	assert_eq(issue["row_key"], "shield", "附加字段应保留。")
