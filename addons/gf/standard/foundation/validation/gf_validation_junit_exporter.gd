## GFValidationJUnitExporter: 将 GFValidationReport 导出为 JUnit XML。
##
## 该导出器只负责把通用校验报告转成 CI 友好的文本，不决定测试命名、
## 构建失败策略或项目修复流程。
class_name GFValidationJUnitExporter
extends RefCounted


# --- 公共方法 ---

## 导出单个报告。
## @param report: 校验报告。
## @param options: 可选参数，支持 suite_name、warnings_as_failures、include_passing_case。
## @return JUnit XML 文本。
static func export_report(report: GFValidationReport, options: Dictionary = {}) -> String:
	return export_reports([report], options)


## 导出多个报告。
## @param reports: 校验报告数组。
## @param options: 可选参数，支持 suite_name、warnings_as_failures、include_passing_case。
## @return JUnit XML 文本。
static func export_reports(reports: Array, options: Dictionary = {}) -> String:
	var suite_name := String(options.get("suite_name", "GF Validation"))
	var warnings_as_failures := bool(options.get("warnings_as_failures", true))
	var include_passing_case := bool(options.get("include_passing_case", true))
	var case_lines := PackedStringArray()
	var test_count := 0
	var failure_count := 0

	for report_variant: Variant in reports:
		var report := report_variant as GFValidationReport
		if report == null:
			continue
		var issues := report.issues
		if issues.is_empty() and include_passing_case:
			test_count += 1
			case_lines.append(_make_passing_case(report))
			continue
		for issue: RefCounted in issues:
			if issue == null:
				continue
			test_count += 1
			var is_failure := bool(issue.call("is_error")) or (warnings_as_failures and bool(issue.call("is_warning")))
			if is_failure:
				failure_count += 1
			case_lines.append(_make_issue_case(report, issue, is_failure))

	var lines := PackedStringArray()
	lines.append('<?xml version="1.0" encoding="UTF-8"?>')
	lines.append('<testsuite name="%s" tests="%d" failures="%d" errors="0" skipped="0">' % [
		_escape_attribute(suite_name),
		test_count,
		failure_count,
	])
	for line: String in case_lines:
		lines.append(line)
	lines.append("</testsuite>")
	return "\n".join(lines)


# --- 私有/辅助方法 ---

static func _make_passing_case(report: GFValidationReport) -> String:
	return '\t<testcase classname="%s" name="healthy" />' % _escape_attribute(_get_report_subject(report))


static func _make_issue_case(report: GFValidationReport, issue: RefCounted, is_failure: bool) -> String:
	var class_label := _escape_attribute(_get_report_subject(report))
	var kind := _escape_attribute(String(issue.call("get_kind_key")))
	var message := _escape_attribute(String(issue.get("message")))
	var severity := _escape_attribute(GFValidationIssue.severity_to_string(issue.get("severity")))
	var location := _escape_text(String(issue.call("get_location_text")))
	var text := _escape_text(String(issue.get("message")))
	if not location.is_empty():
		text = "%s\n%s" % [location, text]
	if not is_failure:
		return '\t<testcase classname="%s" name="%s" />' % [class_label, kind]
	return '\t<testcase classname="%s" name="%s"><failure message="%s" type="%s">%s</failure></testcase>' % [
		class_label,
		kind,
		message,
		severity,
		text,
	]


static func _get_report_subject(report: GFValidationReport) -> String:
	if report == null or report.subject.is_empty():
		return "GFValidationReport"
	return report.subject


static func _escape_attribute(value: String) -> String:
	return _escape_text(value).replace("\"", "&quot;").replace("'", "&apos;")


static func _escape_text(value: String) -> String:
	return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
