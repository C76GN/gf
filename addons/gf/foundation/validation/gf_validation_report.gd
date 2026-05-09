## GFValidationReport: 通用校验报告数据结构。
##
## 用于聚合 `GFValidationIssue`，提供错误/警告统计、健康状态、摘要、下一步建议
## 和字典序列化。报告不绑定具体配置、存档、节点或编辑器业务语义。
class_name GFValidationReport
extends RefCounted


# --- 常量 ---

const _GF_VALIDATION_ISSUE_SCRIPT = preload("res://addons/gf/foundation/validation/gf_validation_issue.gd")


# --- 公共变量 ---

## 报告主题，例如资源名、模块名或调用方自定义域。
var subject: String = ""

## 问题列表。
var issues: Array[RefCounted] = []

## 可选元数据。框架不解释该字段。
var metadata: Dictionary = {}

## 额外报告字段。用于保留或附加调用方自己的统计数据。
var extra_fields: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(p_subject: String = "", p_metadata: Dictionary = {}) -> void:
	subject = p_subject
	metadata = p_metadata.duplicate(true)


# --- 公共方法 ---

## 配置报告主题和元数据。
## @param p_subject: 报告主题。
## @param p_metadata: 可选元数据。
## @return 当前报告。
func configure(p_subject: String = "", p_metadata: Dictionary = {}) -> RefCounted:
	subject = p_subject
	metadata = p_metadata.duplicate(true)
	return self


## 清空问题与额外字段。
func clear() -> void:
	issues.clear()
	metadata.clear()
	extra_fields.clear()


## 添加一个问题。
## @param issue: GFValidationIssue 或问题字典。
## @return 添加后的问题；输入无效时返回 null。
func add_issue(issue: Variant) -> RefCounted:
	var normalized_issue := _normalize_issue(issue)
	if normalized_issue == null:
		return null
	issues.append(normalized_issue)
	return normalized_issue


## 添加信息问题。
## @param kind: 问题类别。
## @param message: 问题说明。
## @param key: 可选定位键。
## @param path: 可选路径。
## @param issue_metadata: 可选元数据。
## @return 新问题。
func add_info(
	kind: StringName,
	message: String,
	key: Variant = null,
	path: String = "",
	issue_metadata: Dictionary = {}
) -> RefCounted:
	return _add_issue(_GF_VALIDATION_ISSUE_SCRIPT.Severity.INFO, kind, message, key, path, issue_metadata)


## 添加警告问题。
## @param kind: 问题类别。
## @param message: 问题说明。
## @param key: 可选定位键。
## @param path: 可选路径。
## @param issue_metadata: 可选元数据。
## @return 新问题。
func add_warning(
	kind: StringName,
	message: String,
	key: Variant = null,
	path: String = "",
	issue_metadata: Dictionary = {}
) -> RefCounted:
	return _add_issue(_GF_VALIDATION_ISSUE_SCRIPT.Severity.WARNING, kind, message, key, path, issue_metadata)


## 添加错误问题。
## @param kind: 问题类别。
## @param message: 问题说明。
## @param key: 可选定位键。
## @param path: 可选路径。
## @param issue_metadata: 可选元数据。
## @return 新问题。
func add_error(
	kind: StringName,
	message: String,
	key: Variant = null,
	path: String = "",
	issue_metadata: Dictionary = {}
) -> RefCounted:
	return _add_issue(_GF_VALIDATION_ISSUE_SCRIPT.Severity.ERROR, kind, message, key, path, issue_metadata)


## 合并另一个报告或报告字典。
## @param source: GFValidationReport 或包含 issues 的字典。
## @param include_metadata: 为 true 时合并源报告 metadata。
## @return 当前报告。
func merge(source: Variant, include_metadata: bool = true) -> RefCounted:
	if source is RefCounted and (source as RefCounted).get_script() == get_script():
		var source_object := source as RefCounted
		var source_issues := source_object.get("issues") as Array
		if source_issues != null:
			for issue_variant: Variant in source_issues:
				add_issue(issue_variant)
		if include_metadata:
			var source_metadata := source_object.get("metadata") as Dictionary
			if source_metadata != null:
				for key: Variant in source_metadata.keys():
					metadata[key] = _duplicate_variant(source_metadata[key])
			var source_extra_fields := source_object.get("extra_fields") as Dictionary
			if source_extra_fields != null:
				for key: Variant in source_extra_fields.keys():
					extra_fields[key] = _duplicate_variant(source_extra_fields[key])
	elif source is Dictionary:
		var source_dict := source as Dictionary
		var source_issues := source_dict.get("issues", []) as Array
		if source_issues != null:
			for issue_variant: Variant in source_issues:
				add_issue(issue_variant)
		if include_metadata and source_dict.get("metadata") is Dictionary:
			var source_metadata := source_dict.get("metadata") as Dictionary
			for key: Variant in source_metadata.keys():
				metadata[key] = _duplicate_variant(source_metadata[key])
	return self


## 从字典应用报告字段。
## @param data: 输入字典。
func apply_dict(data: Dictionary) -> void:
	issues.clear()
	subject = String(data.get("subject", subject))
	var metadata_value: Variant = data.get("metadata", metadata)
	metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}
	extra_fields.clear()

	var source_issues := data.get("issues", []) as Array
	if source_issues != null:
		for issue_variant: Variant in source_issues:
			add_issue(issue_variant)

	for field_key: Variant in data.keys():
		if _is_reserved_report_field(String(field_key)):
			continue
		extra_fields[field_key] = _duplicate_variant(data[field_key])


## 转换为报告字典。
## @param additional_fields: 附加到输出中的调用方字段。
## @param options: 可选输出控制，支持 include_subject、include_metadata、include_info_count、include_issue_count、include_empty_issue_fields、summary_subject、next_actions、fallback_action、no_action。
## @return 报告字典。
func to_dict(additional_fields: Dictionary = {}, options: Dictionary = {}) -> Dictionary:
	var result := extra_fields.duplicate(true)
	for field_key: Variant in additional_fields.keys():
		result[field_key] = _duplicate_variant(additional_fields[field_key])

	var include_subject := _get_option_bool(options, "include_subject", not subject.is_empty())
	var include_metadata := _get_option_bool(options, "include_metadata", not metadata.is_empty())
	var include_info_count := _get_option_bool(options, "include_info_count", true)
	var include_issue_count := _get_option_bool(options, "include_issue_count", true)
	var include_empty_issue_fields := _get_option_bool(options, "include_empty_issue_fields", false)
	var summary_subject := String(options.get("summary_subject", subject))
	var next_actions: Dictionary = options.get("next_actions", {}) as Dictionary
	if next_actions == null:
		next_actions = {}
	var fallback_action := String(options.get("fallback_action", "Review the first reported issue."))
	var no_action := String(options.get("no_action", "No action required."))

	if include_subject:
		result["subject"] = subject
	if include_metadata:
		result["metadata"] = metadata.duplicate(true)

	result["ok"] = is_ok()
	result["healthy"] = is_healthy()
	result["error_count"] = get_error_count()
	result["warning_count"] = get_warning_count()
	if include_info_count:
		result["info_count"] = get_info_count()
	if include_issue_count:
		result["issue_count"] = issues.size()
	result["issue_counts_by_kind"] = get_issue_counts_by_kind()
	result["summary"] = make_summary(summary_subject)
	result["next_action"] = get_next_action(next_actions, fallback_action, no_action)

	var issue_dicts: Array[Dictionary] = []
	for issue: RefCounted in issues:
		var issue_dict: Variant = issue.call("to_dict", include_empty_issue_fields)
		if issue_dict is Dictionary:
			issue_dicts.append(issue_dict as Dictionary)
	result["issues"] = issue_dicts
	return result


## 创建当前报告深拷贝。
## @return 新报告。
func duplicate_report() -> RefCounted:
	var report := get_script().new() as RefCounted
	report.call("apply_dict", to_dict({}, { "include_empty_issue_fields": true }))
	return report


## 获取错误数量。
## @return 错误数量。
func get_error_count() -> int:
	var count := 0
	for issue: RefCounted in issues:
		if issue != null and bool(issue.call("is_error")):
			count += 1
	return count


## 获取警告数量。
## @return 警告数量。
func get_warning_count() -> int:
	var count := 0
	for issue: RefCounted in issues:
		if issue != null and bool(issue.call("is_warning")):
			count += 1
	return count


## 获取信息数量。
## @return 信息数量。
func get_info_count() -> int:
	var count := 0
	for issue: RefCounted in issues:
		if issue != null and bool(issue.call("is_info")):
			count += 1
	return count


## 检查报告是否没有错误。
## @return 没有错误时返回 true。
func is_ok() -> bool:
	return get_error_count() == 0


## 检查报告是否完全健康。
## @return 没有错误和警告时返回 true。
func is_healthy() -> bool:
	return get_error_count() == 0 and get_warning_count() == 0


## 按问题类别统计数量。
## @return 类别计数字典。
func get_issue_counts_by_kind() -> Dictionary:
	var result: Dictionary = {}
	for issue: RefCounted in issues:
		if issue == null:
			continue
		var kind_key := String(issue.call("get_kind_key"))
		result[kind_key] = int(result.get(kind_key, 0)) + 1
	return result


## 生成摘要文本。
## @param subject_override: 临时覆盖报告主题。
## @return 摘要文本。
func make_summary(subject_override: String = "") -> String:
	var label := subject_override if not subject_override.is_empty() else subject
	if label.is_empty():
		label = "Validation report"

	var error_count := get_error_count()
	var warning_count := get_warning_count()
	if error_count > 0:
		return "%s has %d error(s) and %d warning(s)." % [label, error_count, warning_count]
	if warning_count > 0:
		return "%s has %d warning(s)." % [label, warning_count]
	return "%s is healthy." % label


## 获取下一步建议。
## @param action_map: 按问题类别映射的建议文本。
## @param fallback_action: 存在问题但没有命中映射时返回的建议。
## @param no_action: 没有问题时返回的建议。
## @return 建议文本。
func get_next_action(
	action_map: Dictionary = {},
	fallback_action: String = "Review the first reported issue.",
	no_action: String = "No action required."
) -> String:
	var issue := _get_first_issue_by_priority()
	if issue == null:
		return no_action

	var kind_key := String(issue.call("get_kind_key"))
	if action_map.has(kind_key):
		return String(action_map[kind_key])
	var kind_name := StringName(kind_key)
	if action_map.has(kind_name):
		return String(action_map[kind_name])
	return fallback_action


## 将警告提升为错误。
## @param kinds: 为空时提升全部警告；否则只提升匹配类别。
## @return 当前报告。
func promote_warnings_to_errors(kinds: PackedStringArray = PackedStringArray()) -> RefCounted:
	for issue: RefCounted in issues:
		if issue == null or not bool(issue.call("is_warning")):
			continue
		if kinds.is_empty() or kinds.has(String(issue.call("get_kind_key"))):
			issue.set("severity", _GF_VALIDATION_ISSUE_SCRIPT.Severity.ERROR)
	return self


## 从字典创建报告。
## @param data: 输入字典。
## @return 新报告。
static func from_dict(data: Dictionary) -> RefCounted:
	var report := (load("res://addons/gf/foundation/validation/gf_validation_report.gd") as Script).new() as RefCounted
	report.call("apply_dict", data)
	return report


# --- 私有/辅助方法 ---

func _add_issue(
	p_severity: int,
	p_kind: StringName,
	p_message: String,
	p_key: Variant,
	p_path: String,
	p_metadata: Dictionary
) -> RefCounted:
	var issue := _GF_VALIDATION_ISSUE_SCRIPT.new(p_severity, p_kind, p_message, p_key, p_path, p_metadata) as RefCounted
	issues.append(issue)
	return issue


func _normalize_issue(issue: Variant) -> RefCounted:
	if issue is _GF_VALIDATION_ISSUE_SCRIPT:
		return (issue as RefCounted).call("duplicate_issue") as RefCounted
	if issue is Dictionary:
		var normalized_issue := _GF_VALIDATION_ISSUE_SCRIPT.new() as RefCounted
		normalized_issue.call("apply_dict", issue as Dictionary)
		return normalized_issue
	return null


func _get_first_issue_by_priority() -> RefCounted:
	for issue: RefCounted in issues:
		if issue != null and bool(issue.call("is_error")):
			return issue
	for issue: RefCounted in issues:
		if issue != null and bool(issue.call("is_warning")):
			return issue
	for issue: RefCounted in issues:
		if issue != null:
			return issue
	return null


static func _get_option_bool(options: Dictionary, field_name: String, default_value: bool) -> bool:
	if not options.has(field_name):
		return default_value
	return bool(options[field_name])


static func _is_reserved_report_field(field_name: String) -> bool:
	return (
		field_name == "subject"
		or field_name == "metadata"
		or field_name == "issues"
		or field_name == "ok"
		or field_name == "healthy"
		or field_name == "error_count"
		or field_name == "warning_count"
		or field_name == "info_count"
		or field_name == "issue_count"
		or field_name == "issue_counts_by_kind"
		or field_name == "summary"
		or field_name == "next_action"
	)


static func _duplicate_variant(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
