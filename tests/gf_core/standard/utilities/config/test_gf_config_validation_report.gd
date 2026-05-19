## 测试配置表校验报告构建工具。
extends GutTest


# --- 常量 ---

const _CONFIG_VALIDATION_REPORT = preload("res://addons/gf/standard/utilities/config/gf_config_validation_report.gd")


# --- 测试 ---

func test_report_helper_adds_stable_issue_fields_and_context() -> void:
	var report: Dictionary = _CONFIG_VALIDATION_REPORT.new().make_report(&"items", 2)

	_CONFIG_VALIDATION_REPORT.new().add_issue(report, "warning", "sample_warning", &"items", 1001, &"name", "示例警告。", {
		"source": "res://configs/items.csv",
		"line": 4,
		"column": 2,
		"row_index": 1,
		"rule_id": &"sample_rule",
	})
	_CONFIG_VALIDATION_REPORT.new().finalize_report(report)
	var issue := (report["issues"] as Array)[0] as Dictionary

	assert_true(bool(report["ok"]), "仅包含 warning 时报告仍应通过。")
	assert_eq(int(report["warning_count"]), 1, "warning 数量应累加。")
	assert_eq(issue["table_name"], &"items", "问题应包含表名。")
	assert_eq(issue["row_key"], 1001, "问题应包含行标识。")
	assert_eq(issue["field"], &"name", "问题应包含字段名。")
	assert_eq(issue["source"], "res://configs/items.csv", "问题应保留来源。")
	assert_eq(issue["rule_id"], &"sample_rule", "问题应保留规则标识。")


func test_report_helper_merges_reports_with_optional_row_count() -> void:
	var target: Dictionary = _CONFIG_VALIDATION_REPORT.new().make_report(&"items", 2)
	var source: Dictionary = _CONFIG_VALIDATION_REPORT.new().make_error_report(&"items", "sample_error", "示例错误。")
	source["row_count"] = 3

	_CONFIG_VALIDATION_REPORT.new().merge_report(target, source, true)
	_CONFIG_VALIDATION_REPORT.new().finalize_report(target)

	assert_false(bool(target["ok"]), "合并 error 报告后应失败。")
	assert_eq(int(target["row_count"]), 5, "开启 include_row_count 时应累加行数。")
	assert_eq(int(target["error_count"]), 1, "错误数量应累加。")
	assert_eq((target["issues"] as Array).size(), 1, "问题列表应合并。")
