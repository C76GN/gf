## 测试 GFSupportReportUtility 的报告构建、分区和提交回调。
extends GutTest


# --- 常量 ---

const GFSupportReportUtilityBase = preload("res://addons/gf/utilities/gf_support_report_utility.gd")


# --- 测试方法 ---

## 验证支持报告可聚合用户描述、元数据和自定义分区。
func test_support_report_collects_custom_sections() -> void:
	var utility := GFSupportReportUtilityBase.new()
	assert_true(utility.register_section(&"save", func(options: Dictionary) -> Dictionary:
		return { "slot": options.get("slot", "A") }
	), "有效分区应注册成功。")

	var report := utility.build_report("Need help", {
		"include_diagnostics": false,
		"include_scene": false,
		"section_options": { "slot": "B" },
		"metadata": { "screen": "settings" },
		"tags": ["qa", "runtime"],
	})
	var sections := report["sections"] as Dictionary
	var save_section := sections[&"save"] as Dictionary

	assert_eq(report["description"], "Need help", "报告应保留用户描述。")
	assert_eq((report["metadata"] as Dictionary).get("screen"), "settings", "报告应保留元数据。")
	assert_eq((save_section["value"] as Dictionary).get("slot"), "B", "分区 provider 应收到调用选项。")


## 验证支持报告文本选项可安全接收非字符串值。
func test_support_report_string_options_are_safe_for_variants() -> void:
	var utility := GFSupportReportUtilityBase.new()
	var provider := func(_options: Dictionary) -> String:
		return "ok"
	assert_true(utility.register_section(&"runtime", provider, { "label": 123 }), "数字 label 应被安全转换。")

	var report := utility.build_report("Variants", {
		"include_diagnostics": false,
		"include_scene": false,
		"report_id": 456,
		"tags": [1, &"two"],
	})
	var catalog := utility.get_section_catalog()

	assert_eq(report["report_id"], "456", "数字 report_id 应转换为文本。")
	assert_true((report["tags"] as PackedStringArray).has("1"), "数字 tag 应转换为文本。")
	assert_eq((catalog[&"runtime"] as Dictionary)["label"], "123", "数字分区 label 应转换为文本。")


## 验证支持报告可导出 JSON 并通过回调提交。
func test_support_report_exports_and_submits_with_transport_callback() -> void:
	var utility := GFSupportReportUtilityBase.new()
	var report := utility.build_report("Export", {
		"include_diagnostics": false,
		"include_scene": false,
	})
	var submitted_ids: Array[String] = []
	var result := utility.submit_report(report, func(next_report: Dictionary, _options: Dictionary) -> String:
		submitted_ids.append(String(next_report.get("report_id", "")))
		return "accepted"
	)

	assert_true(utility.export_report_json(report).contains("report_id"), "JSON 导出应包含报告 ID。")
	assert_true(bool(result["ok"]), "有效 transport 应提交成功。")
	assert_eq(result["value"], "accepted", "提交结果应保留回调返回值。")
	assert_eq(submitted_ids.size(), 1, "transport 应收到报告副本。")
