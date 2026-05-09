## GFValidationUtility: 通用校验报告辅助函数。
##
## 提供字典报告的追加、归一化、统计和严重级别提升工具，便于旧的字典式报告
## 逐步接入 `GFValidationIssue` / `GFValidationReport`，同时保持返回结构兼容。
class_name GFValidationUtility
extends RefCounted


# --- 常量 ---

const _GF_VALIDATION_ISSUE_SCRIPT = preload("res://addons/gf/foundation/validation/gf_validation_issue.gd")
const _GF_VALIDATION_REPORT_SCRIPT = preload("res://addons/gf/foundation/validation/gf_validation_report.gd")


# --- 公共方法 ---

## 将任意问题转换为字典。
## @param issue: GFValidationIssue 或问题字典。
## @param include_empty_fields: 为 true 时包含空的可选字段。
## @return 问题字典。
static func issue_to_dict(issue: Variant, include_empty_fields: bool = false) -> Dictionary:
	if issue is _GF_VALIDATION_ISSUE_SCRIPT:
		var issue_dict: Variant = (issue as RefCounted).call("to_dict", include_empty_fields)
		return issue_dict as Dictionary if issue_dict is Dictionary else {}
	if issue is Dictionary:
		return (issue as Dictionary).duplicate(true)
	return {}


## 将报告字典转换为 GFValidationReport。
## @param data: 输入字典。
## @return 新报告。
static func report_from_dict(data: Dictionary) -> RefCounted:
	var report := _GF_VALIDATION_REPORT_SCRIPT.new() as RefCounted
	report.call("apply_dict", data)
	return report


## 向字典报告追加问题。
## @param report: 目标报告字典。
## @param severity: 严重级别，可传入 Severity、int 或字符串。
## @param kind: 问题类别。
## @param message: 问题说明。
## @param fields: 附加字段，例如 key、path、row_key、metadata。
## @return 追加的问题字典。
static func append_issue(
	report: Dictionary,
	severity: Variant,
	kind: StringName,
	message: String,
	fields: Dictionary = {}
) -> Dictionary:
	var issue := {
		"severity": _GF_VALIDATION_ISSUE_SCRIPT.severity_to_string(severity),
		"kind": String(kind),
		"message": message,
	}
	for field_key: Variant in fields.keys():
		var field_name := String(field_key)
		if field_name == "severity" or field_name == "kind" or field_name == "message":
			continue
		issue[field_key] = GFVariantUtility.duplicate_variant(fields[field_key])

	_get_issue_array(report).append(issue)
	return issue


## 重新计算字典报告的统计字段。
## @param report: 目标报告字典。
## @param subject: 摘要主题；为空时使用 report.subject 或 Validation report。
## @param options: 可选控制，支持 next_actions、fallback_action、no_action、include_info_count、include_issue_count、warnings_as_errors、promote_warning_kinds。
## @return 同一个报告字典。
static func finalize_report(
	report: Dictionary,
	subject: String = "",
	options: Dictionary = {}
) -> Dictionary:
	var error_count := 0
	var warning_count := 0
	var info_count := 0
	var issue_counts_by_kind: Dictionary = {}
	var issues := _get_issue_array(report)
	for issue_variant: Variant in issues:
		var issue := issue_to_dict(issue_variant)
		if issue.is_empty():
			continue

		var kind_key := _get_issue_kind(issue)
		issue_counts_by_kind[kind_key] = int(issue_counts_by_kind.get(kind_key, 0)) + 1

		match _get_effective_severity(issue, options):
			"error":
				error_count += 1
			"warning":
				warning_count += 1
			"info":
				info_count += 1

	report["error_count"] = error_count
	report["warning_count"] = warning_count
	if _get_option_bool(options, "include_info_count", report.has("info_count")):
		report["info_count"] = info_count
	if _get_option_bool(options, "include_issue_count", report.has("issue_count")):
		report["issue_count"] = issues.size()
	report["issue_counts_by_kind"] = issue_counts_by_kind
	report["ok"] = error_count == 0
	report["healthy"] = error_count == 0 and warning_count == 0

	var summary_subject := subject
	if summary_subject.is_empty():
		summary_subject = String(report.get("subject", ""))
	report["summary"] = make_summary(summary_subject, error_count, warning_count)

	var next_actions: Dictionary = options.get("next_actions", {}) as Dictionary
	if next_actions == null:
		next_actions = {}
	var fallback_action := String(options.get("fallback_action", "Review the first reported issue."))
	var no_action := String(options.get("no_action", "No action required."))
	report["next_action"] = get_next_action(report, next_actions, fallback_action, no_action, options)
	return report


## 生成摘要文本。
## @param subject: 摘要主题。
## @param error_count: 错误数量。
## @param warning_count: 警告数量。
## @return 摘要文本。
static func make_summary(subject: String, error_count: int, warning_count: int) -> String:
	var label := subject
	if label.is_empty():
		label = "Validation report"
	if error_count > 0:
		return "%s has %d error(s) and %d warning(s)." % [label, error_count, warning_count]
	if warning_count > 0:
		return "%s has %d warning(s)." % [label, warning_count]
	return "%s is healthy." % label


## 获取报告下一步建议。
## @param report: 报告字典。
## @param action_map: 按问题类别映射的建议文本。
## @param fallback_action: 存在问题但未命中映射时返回的建议。
## @param no_action: 没有问题时返回的建议。
## @param options: 严重级别计算选项。
## @return 建议文本。
static func get_next_action(
	report: Dictionary,
	action_map: Dictionary = {},
	fallback_action: String = "Review the first reported issue.",
	no_action: String = "No action required.",
	options: Dictionary = {}
) -> String:
	var issue := _get_first_issue_by_priority(report, options)
	if issue.is_empty():
		return no_action

	var kind_key := _get_issue_kind(issue)
	if action_map.has(kind_key):
		return String(action_map[kind_key])
	var kind_name := StringName(kind_key)
	if action_map.has(kind_name):
		return String(action_map[kind_name])
	return fallback_action


## 检查报告是否包含错误。
## @param report: 报告字典。
## @param options: 严重级别计算选项。
## @return 存在错误时返回 true。
static func has_error_issues(report: Dictionary, options: Dictionary = {}) -> bool:
	for issue_variant: Variant in _get_issue_array(report):
		var issue := issue_to_dict(issue_variant)
		if not issue.is_empty() and _get_effective_severity(issue, options) == "error":
			return true
	return false


## 将报告中的警告提升为错误。
## @param report: 报告字典。
## @param kinds: 为空时提升全部警告；否则只提升匹配类别。
## @return 同一个报告字典。
static func promote_warnings(report: Dictionary, kinds: PackedStringArray = PackedStringArray()) -> Dictionary:
	for issue_variant: Variant in _get_issue_array(report):
		if issue_variant is _GF_VALIDATION_ISSUE_SCRIPT:
			var validation_issue := issue_variant as RefCounted
			var kind_key := String(validation_issue.call("get_kind_key"))
			if bool(validation_issue.call("is_warning")) and (kinds.is_empty() or kinds.has(kind_key)):
				validation_issue.set("severity", _GF_VALIDATION_ISSUE_SCRIPT.Severity.ERROR)
		elif issue_variant is Dictionary:
			var issue := issue_variant as Dictionary
			if _GF_VALIDATION_ISSUE_SCRIPT.severity_to_string(issue.get("severity", "")) != "warning":
				continue
			if kinds.is_empty() or kinds.has(_get_issue_kind(issue)):
				issue["severity"] = "error"
	return report


# --- 私有/辅助方法 ---

static func _get_issue_array(report: Dictionary) -> Array:
	var issues_variant: Variant = report.get("issues", [])
	if not (issues_variant is Array):
		report["issues"] = []
	return report["issues"] as Array


static func _get_effective_severity(issue: Dictionary, options: Dictionary) -> String:
	var severity_name := _GF_VALIDATION_ISSUE_SCRIPT.severity_to_string(issue.get("severity", "error"))
	if severity_name == "warning":
		if _get_option_bool(options, "warnings_as_errors", false):
			return "error"
		if _kind_is_promoted(_get_issue_kind(issue), options.get("promote_warning_kinds", PackedStringArray())):
			return "error"
	return severity_name


static func _kind_is_promoted(kind_key: String, promoted_kinds: Variant) -> bool:
	if promoted_kinds is PackedStringArray:
		return (promoted_kinds as PackedStringArray).has(kind_key)
	if promoted_kinds is Array:
		return (promoted_kinds as Array).has(kind_key) or (promoted_kinds as Array).has(StringName(kind_key))
	return false


static func _get_issue_kind(issue: Dictionary) -> String:
	var kind_value: Variant = issue.get("kind", issue.get("code", issue.get("type", "unknown")))
	var kind_text := String(kind_value)
	return kind_text if not kind_text.is_empty() else "unknown"


static func _get_first_issue_by_priority(report: Dictionary, options: Dictionary) -> Dictionary:
	for issue_variant: Variant in _get_issue_array(report):
		var issue := issue_to_dict(issue_variant)
		if not issue.is_empty() and _get_effective_severity(issue, options) == "error":
			return issue
	for issue_variant: Variant in _get_issue_array(report):
		var issue := issue_to_dict(issue_variant)
		if not issue.is_empty() and _get_effective_severity(issue, options) == "warning":
			return issue
	for issue_variant: Variant in _get_issue_array(report):
		var issue := issue_to_dict(issue_variant)
		if not issue.is_empty():
			return issue
	return {}


static func _get_option_bool(options: Dictionary, field_name: String, default_value: bool) -> bool:
	if not options.has(field_name):
		return default_value
	return bool(options[field_name])
