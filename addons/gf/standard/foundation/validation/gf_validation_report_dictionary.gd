## GFValidationReportDictionary: 通用校验报告字典辅助。
##
## 提供字典报告的追加、归一化、统计和严重级别提升工具，便于字典式报告
## 接入 `GFValidationIssue` / `GFValidationReport` 使用的标准字段。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFValidationReportDictionary
extends RefCounted


# --- 常量 ---

const _GF_VALIDATION_ISSUE_SCRIPT: Script = preload("res://addons/gf/standard/foundation/validation/gf_validation_issue.gd")
const _GF_VALIDATION_REPORT_SCRIPT: Script = preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")
const _GF_SOURCE_SPAN_SCRIPT: Script = preload("res://addons/gf/standard/foundation/validation/gf_source_span.gd")


# --- 公共方法 ---

## 将任意问题转换为字典。
## [br]
## @api public
## [br]
## @param issue: GFValidationIssue 或问题字典。
## [br]
## @schema issue: Variant accepting GFValidationIssue or Dictionary issue payload.
## [br]
## @param include_empty_fields: 为 true 时包含空的可选字段。
## [br]
## @return 问题字典。
## [br]
## @schema return: Dictionary serialized issue payload.
static func issue_to_dict(issue: Variant, include_empty_fields: bool = false) -> Dictionary:
	if issue is _GF_VALIDATION_ISSUE_SCRIPT:
		var issue_dict: Variant = (issue as RefCounted).call("to_dict", include_empty_fields)
		return issue_dict as Dictionary if issue_dict is Dictionary else {}
	if issue is Dictionary:
		var issue_data := issue as Dictionary
		if issue_data.is_empty():
			return {}
		var normalized_issue := _GF_VALIDATION_ISSUE_SCRIPT.new() as RefCounted
		normalized_issue.call("apply_dict", issue_data)
		var normalized_dict: Variant = normalized_issue.call("to_dict", include_empty_fields)
		return normalized_dict as Dictionary if normalized_dict is Dictionary else {}
	return {}


## 将报告字典转换为 GFValidationReport。
## [br]
## @api public
## [br]
## @param data: 输入字典。
## [br]
## @schema data: Dictionary report payload.
## [br]
## @return 新报告。
static func report_from_dict(data: Dictionary) -> RefCounted:
	var report := _GF_VALIDATION_REPORT_SCRIPT.new() as RefCounted
	report.call("apply_dict", data)
	return report


## 向字典报告追加问题。
## [br]
## @api public
## [br]
## @param report: 目标报告字典。
## [br]
## @schema report: Dictionary report payload mutated in place.
## [br]
## @param severity: 严重级别，可传入 Severity、int 或字符串。
## [br]
## @schema severity: Variant accepting GFValidationIssue.Severity, int, String, or StringName.
## [br]
## @param kind: 问题类别。
## [br]
## @param message: 问题说明。
## [br]
## @param fields: 附加字段，例如 key、path、row_key、metadata。
## [br]
## @schema fields: Dictionary additional issue fields.
## [br]
## @return 追加的问题字典。
## [br]
## @schema return: Dictionary appended issue payload.
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
		issue[field_key] = GFVariantData.duplicate_variant(fields[field_key])

	_get_issue_array(report).append(issue)
	return issue


## 向字典报告追加带源码定位的问题。
## [br]
## @api public
## [br]
## @param report: 目标报告字典。
## [br]
## @schema report: Dictionary report payload mutated in place.
## [br]
## @param severity: 严重级别，可传入 Severity、int 或字符串。
## [br]
## @schema severity: Variant accepting GFValidationIssue.Severity, int, String, or StringName.
## [br]
## @param kind: 问题类别。
## [br]
## @param message: 问题说明。
## [br]
## @param source_span: GFSourceSpan 或兼容字典。
## [br]
## @schema source_span: Variant accepting GFSourceSpan or Dictionary span payload.
## [br]
## @param fields: 附加字段，例如 key、path、row_key、metadata。
## [br]
## @schema fields: Dictionary additional issue fields.
## [br]
## @return 追加的问题字典。
## [br]
## @schema return: Dictionary appended issue payload.
static func append_source_issue(
	report: Dictionary,
	severity: Variant,
	kind: StringName,
	message: String,
	source_span: Variant,
	fields: Dictionary = {}
) -> Dictionary:
	var merged_fields := fields.duplicate(true)
	var span_dict := _source_span_to_dict(source_span)
	for field_key: Variant in span_dict.keys():
		merged_fields[field_key] = GFVariantData.duplicate_variant(span_dict[field_key])
	if not span_dict.is_empty():
		merged_fields["source_span"] = span_dict.duplicate(true)
	return append_issue(report, severity, kind, message, merged_fields)


## 重新计算字典报告的统计字段。
## [br]
## @api public
## [br]
## @param report: 目标报告字典。
## [br]
## @schema report: Dictionary report payload mutated in place.
## [br]
## @param subject: 摘要主题；为空时使用 report.subject 或 Validation report。
## [br]
## @param options: 可选控制，支持 next_actions、fallback_action、no_action、include_info_count、include_issue_count、warnings_as_errors、promote_warning_kinds。
## [br]
## @schema options: Dictionary controlling report finalization.
## [br]
## @return 同一个报告字典。
## [br]
## @schema return: Dictionary finalized report payload.
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
	for issue_index in range(issues.size()):
		var issue := issue_to_dict(issues[issue_index])
		if issue.is_empty():
			continue
		issues[issue_index] = issue

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
## [br]
## @api public
## [br]
## @param subject: 摘要主题。
## [br]
## @param error_count: 错误数量。
## [br]
## @param warning_count: 警告数量。
## [br]
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
## [br]
## @api public
## [br]
## @param report: 报告字典。
## [br]
## @schema report: Dictionary report payload.
## [br]
## @param action_map: 按问题类别映射的建议文本。
## [br]
## @schema action_map: Dictionary keyed by issue kind with action text values.
## [br]
## @param fallback_action: 存在问题但未命中映射时返回的建议。
## [br]
## @param no_action: 没有问题时返回的建议。
## [br]
## @param options: 严重级别计算选项。
## [br]
## @schema options: Dictionary severity evaluation options.
## [br]
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
## [br]
## @api public
## [br]
## @param report: 报告字典。
## [br]
## @schema report: Dictionary report payload.
## [br]
## @param options: 严重级别计算选项。
## [br]
## @schema options: Dictionary severity evaluation options.
## [br]
## @return 存在错误时返回 true。
static func has_error_issues(report: Dictionary, options: Dictionary = {}) -> bool:
	for issue_variant: Variant in _get_issue_array(report):
		var issue := issue_to_dict(issue_variant)
		if not issue.is_empty() and _get_effective_severity(issue, options) == "error":
			return true
	return false


## 将报告中的警告提升为错误。
## [br]
## @api public
## [br]
## @param report: 报告字典。
## [br]
## @schema report: Dictionary report payload mutated in place.
## [br]
## @param kinds: 为空时提升全部警告；否则只提升匹配类别。
## [br]
## @return 同一个报告字典。
## [br]
## @schema return: Dictionary report payload mutated in place.
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


static func _source_span_to_dict(source_span: Variant) -> Dictionary:
	if source_span is _GF_SOURCE_SPAN_SCRIPT:
		var span_dict: Variant = (source_span as RefCounted).call("to_dict", false, true)
		return span_dict as Dictionary if span_dict is Dictionary else {}
	if source_span is Dictionary:
		var span := _GF_SOURCE_SPAN_SCRIPT.new() as RefCounted
		span.call("apply_dict", source_span as Dictionary)
		var span_dict: Variant = span.call("to_dict", false, true)
		return span_dict as Dictionary if span_dict is Dictionary else {}
	return {}


static func _get_effective_severity(issue: Dictionary, options: Dictionary) -> String:
	var severity_name: String = _GF_VALIDATION_ISSUE_SCRIPT.severity_to_string(issue.get("severity", "error"))
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
	var kind_value: Variant = issue.get("kind", "unknown")
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
