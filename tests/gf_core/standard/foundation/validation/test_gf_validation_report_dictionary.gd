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
		"kind": "missing_field",
		"row_key": 3,
		"field": &"name",
		"message": "Missing field.",
	})

	var data: Dictionary = issue.to_dict()

	assert_eq(data["severity"], "warning", "严重级别应归一为稳定字符串。")
	assert_eq(data["kind"], "missing_field", "kind 应作为统计用问题类别。")
	assert_false(data.has("code"), "问题字典不应再输出旧 code 字段。")
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
	assert_eq(int(report["issue_count"]), 1, "字典报告应始终输出问题总数。")
	assert_eq(((report["issues"] as Array)[0] as Dictionary)["row_key"], 1, "问题附加字段应保留。")


func test_dictionary_report_finalize_normalizes_legacy_issue_fields() -> void:
	var report := {
		"issues": [
			{
				"severity": "warning",
				"code": "legacy_code",
				"type": "legacy_type",
				"message": "Legacy issue.",
				"row_key": 7,
			},
		],
	}

	GF_VALIDATION_REPORT_DICTIONARY_BASE.finalize_report(report, "Legacy report")

	var issue := (report["issues"] as Array)[0] as Dictionary
	assert_eq(issue["kind"], "unknown", "缺少 kind 的旧问题应归入 unknown，而不是读取旧 code/type。")
	assert_false(issue.has("code"), "字典报告归一化后不应继续输出旧 code 字段。")
	assert_false(issue.has("type"), "字典报告归一化后不应继续输出旧 type 字段。")
	assert_eq(issue["row_key"], 7, "自定义定位字段应继续保留。")
	assert_eq((report["issue_counts_by_kind"] as Dictionary)["unknown"], 1, "统计应使用标准 kind。")


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


func test_dictionary_report_filter_issues_uses_ignores_and_preserves_source() -> void:
	var report := {
		"subject": "Project scan",
		"issues": [
			{
				"severity": "error",
				"kind": "missing_script",
				"message": "Script is missing.",
				"path": "res://levels/broken.tscn",
			},
			{
				"severity": "warning",
				"kind": "large_texture",
				"message": "Texture is large.",
				"path": "res://textures/big.png",
			},
		],
	}

	var filtered: Dictionary = GF_VALIDATION_REPORT_DICTIONARY_BASE.filter_issues(report, {
		"ignored_kinds": PackedStringArray(["missing_script"]),
	})
	var source_issues := report["issues"] as Array
	var filtered_issues := filtered["issues"] as Array

	assert_eq(source_issues.size(), 2, "过滤应返回副本，不应修改源报告。")
	assert_eq(filtered_issues.size(), 1, "匹配忽略类别的问题应被移除。")
	assert_eq(String((filtered_issues[0] as Dictionary)["kind"]), "large_texture", "未匹配的问题应保留。")
	assert_true(bool(filtered["ok"]), "只剩警告时过滤后的报告应可通过。")
	assert_eq(int(filtered["original_issue_count"]), 2, "过滤摘要应记录原始问题数。")
	assert_eq(int(filtered["filtered_issue_count"]), 1, "过滤摘要应记录移除数量。")


func test_dictionary_report_filter_issues_supports_baseline_fingerprints_and_globs() -> void:
	var report := {
		"issues": [
			{
				"severity": "error",
				"kind": "broken_reference",
				"message": "Missing resource.",
				"path": "res://content/legacy_scene.tscn",
				"key": "icon",
			},
			{
				"severity": "warning",
				"kind": "unused_file",
				"message": "File appears unused.",
				"path": "res://generated/cache/old.png",
			},
			{
				"severity": "error",
				"kind": "missing_export_preset",
				"message": "No export preset.",
				"path": "res://export_presets.cfg",
			},
		],
	}
	var baseline_issue := {
		"severity": "error",
		"kind": "broken_reference",
		"message": "Missing resource.",
		"path": "res://content/legacy_scene.tscn",
		"key": "icon",
	}
	var fingerprint := GF_VALIDATION_REPORT_DICTIONARY_BASE.make_issue_fingerprint(baseline_issue)

	var filtered: Dictionary = GF_VALIDATION_REPORT_DICTIONARY_BASE.filter_issues(report, {
		"baseline_fingerprints": PackedStringArray([fingerprint]),
		"ignored_path_patterns": PackedStringArray(["res://generated/**"]),
	})
	var issues := filtered["issues"] as Array

	assert_eq(issues.size(), 1, "基线指纹和路径通配忽略应同时生效。")
	assert_eq(String((issues[0] as Dictionary)["kind"]), "missing_export_preset", "未进入基线或忽略路径的问题应保留。")
	assert_false(bool(filtered["ok"]), "剩余错误应继续让报告失败。")
