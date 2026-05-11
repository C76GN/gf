## 测试通用校验问题、报告与字典兼容辅助。
extends GutTest


# --- 常量 ---

const GF_VALIDATION_ISSUE_BASE := preload("res://addons/gf/standard/foundation/validation/gf_validation_issue.gd")
const GF_VALIDATION_REPORT_BASE := preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")
const GF_VALIDATION_REPORT_DICTIONARY_BASE := preload("res://addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd")


# --- 测试方法 ---

func test_issue_from_dict_preserves_extra_fields() -> void:
	var issue := GF_VALIDATION_ISSUE_BASE.from_dict({
		"severity": "warn",
		"code": "missing_field",
		"type": "legacy_type",
		"row_key": 3,
		"field": &"name",
		"message": "Missing field.",
	})

	var data: Dictionary = issue.to_dict()

	assert_eq(data["severity"], "warning", "严重级别应归一为稳定字符串。")
	assert_eq(data["kind"], "missing_field", "code 应可作为统计用 kind。")
	assert_eq(data["code"], "missing_field", "原始 code 字段应保留。")
	assert_eq(data["type"], "legacy_type", "已有 type 风格字段应作为附加字段保留。")
	assert_eq(data["row_key"], 3, "自定义定位字段应保留。")
	assert_eq(data["field"], &"name", "StringName 字段应保留。")


func test_report_counts_summary_and_next_action() -> void:
	var report := GF_VALIDATION_REPORT_BASE.new("Sample data")
	report.add_warning(&"optional_missing", "Optional value is missing.", "row_1")
	report.add_error(&"invalid_value", "Value is invalid.", "row_2")

	var data: Dictionary = report.to_dict({}, {
		"next_actions": {
			"invalid_value": "Fix the invalid value.",
		},
	})

	assert_false(bool(data["ok"]), "存在错误时报告不应通过。")
	assert_false(bool(data["healthy"]), "存在警告或错误时报告不应健康。")
	assert_eq(int(data["error_count"]), 1, "应统计错误数量。")
	assert_eq(int(data["warning_count"]), 1, "应统计警告数量。")
	assert_eq((data["issue_counts_by_kind"] as Dictionary)["invalid_value"], 1, "应按 kind 统计问题。")
	assert_eq(data["summary"], "Sample data has 1 error(s) and 1 warning(s).", "摘要应使用主题和统计数量。")
	assert_eq(data["next_action"], "Fix the invalid value.", "下一步建议应优先使用首个错误的映射。")


func test_report_promotes_selected_warnings_to_errors() -> void:
	var report := GF_VALIDATION_REPORT_BASE.new("Sample data")
	report.add_warning(&"optional_missing", "Optional value is missing.")
	report.add_warning(&"deprecated_value", "Deprecated value.")

	report.promote_warnings_to_errors(PackedStringArray(["deprecated_value"]))

	assert_eq(report.get_error_count(), 1, "匹配类别的警告应提升为错误。")
	assert_eq(report.get_warning_count(), 1, "未匹配类别的警告应保持警告。")


func test_dictionary_report_finalize_preserves_existing_fields() -> void:
	var report := {
		"row_count": 2,
		"issues": [],
	}
	GF_VALIDATION_REPORT_DICTIONARY_BASE.append_issue(report, "warning", &"missing_optional", "Optional field is missing.", {
		"row_key": 1,
	})

	GF_VALIDATION_REPORT_DICTIONARY_BASE.finalize_report(report, "Config table")

	assert_true(bool(report["ok"]), "只有警告时报告仍可通过。")
	assert_false(bool(report["healthy"]), "包含警告时报告不应视为完全健康。")
	assert_eq(int(report["row_count"]), 2, "调用方已有统计字段应保留。")
	assert_eq(int(report["warning_count"]), 1, "字典报告应计算警告数量。")
	assert_eq(((report["issues"] as Array)[0] as Dictionary)["row_key"], 1, "问题附加字段应保留。")


func test_dictionary_report_can_treat_warnings_as_errors() -> void:
	var report := {
		"issues": [
			{
				"severity": "warning",
				"kind": "missing_optional",
				"message": "Optional field is missing.",
			},
		],
	}

	GF_VALIDATION_REPORT_DICTIONARY_BASE.finalize_report(report, "Config table", {
		"warnings_as_errors": true,
	})

	assert_false(bool(report["ok"]), "启用 warnings_as_errors 后警告应使报告失败。")
	assert_eq(int(report["error_count"]), 1, "提升后的警告应计入错误数量。")
	assert_eq(int(report["warning_count"]), 0, "提升后的警告不应再计入警告数量。")
