## GFValidationDiagnosticAdapter: 校验报告到编辑器诊断数据的适配器。
##
## 只把 `GFValidationIssue`、`GFValidationReport` 或兼容字典转换成纯 Dictionary
## 诊断记录，不创建 UI，也不假设具体编辑器控件，便于 Inspector、Dock、CI 和项目工具复用。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFValidationDiagnosticAdapter
extends RefCounted


# --- 常量 ---

## 校验问题脚本基类。
## [br]
## @api framework_internal
const GF_VALIDATION_ISSUE_BASE: Script = preload("res://addons/gf/standard/foundation/validation/gf_validation_issue.gd")

## 校验报告脚本基类。
## [br]
## @api framework_internal
const GF_VALIDATION_REPORT_BASE: Script = preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")

## 源码范围脚本基类。
## [br]
## @api framework_internal
const GF_SOURCE_SPAN_BASE: Script = preload("res://addons/gf/standard/foundation/validation/gf_source_span.gd")


# --- 公共方法 ---

## 将单个问题转换成诊断字典。
## [br]
## @api public
## [br]
## @param issue: GFValidationIssue 或兼容问题字典。
## [br]
## @schema issue: Variant accepting GFValidationIssue or Dictionary issue payload.
## [br]
## @param options: 可选参数，支持 use_path_as_source、include_empty_source_span。
## [br]
## @schema options: Dictionary diagnostic conversion options.
## [br]
## @return 诊断字典；输入无效时返回空字典。
## [br]
## @schema return: Dictionary editor diagnostic record.
static func issue_to_diagnostic(issue: Variant, options: Dictionary = {}) -> Dictionary:
	var issue_data := _issue_to_dict(issue, bool(options.get("include_empty_source_span", false)))
	if issue_data.is_empty():
		return {}

	var source_span := _source_span_from_dict(_make_span_data(issue_data, options))
	var severity: String = GF_VALIDATION_ISSUE_BASE.severity_to_string(issue_data.get("severity", "error"))
	var kind_key := _get_issue_kind(issue_data)
	var source_path := String(source_span.get("source_path"))
	var line := int(source_span.get("line"))
	var column := int(source_span.get("column"))
	var length := int(source_span.get("length"))
	var end_line := int(source_span.get("end_line"))
	var end_column := int(source_span.get("end_column"))
	var preview := String(source_span.get("preview"))
	var location := String(source_span.call("get_location_text"))
	var source_span_dict: Variant = source_span.call("to_dict", false, true)
	var diagnostic := {
		"severity": severity,
		"kind": kind_key,
		"message": String(issue_data.get("message", "")),
		"key": GFVariantData.duplicate_variant(issue_data.get("key", null)),
		"path": String(issue_data.get("path", "")),
		"source_path": source_path,
		"line": line,
		"column": column,
		"length": length,
		"end_line": end_line,
		"end_column": end_column,
		"preview": preview,
		"line_index": line - 1 if line > 0 else -1,
		"column_index": column - 1 if column > 0 else -1,
		"location": location,
		"source_span": source_span_dict as Dictionary if source_span_dict is Dictionary else {},
		"metadata": _read_dictionary(issue_data, "metadata"),
	}
	diagnostic["display_text"] = make_display_text(diagnostic)
	diagnostic["tooltip"] = make_tooltip(diagnostic)
	return diagnostic


## 将报告、报告字典或问题数组转换成诊断数组。
## [br]
## @api public
## [br]
## @param source: GFValidationReport、报告字典或问题数组。
## [br]
## @schema source: Variant accepting GFValidationReport, Dictionary report payload, or Array issues.
## [br]
## @param options: 可选参数，支持 source_path、include_positionless、use_path_as_source。
## [br]
## @schema options: Dictionary diagnostic conversion options.
## [br]
## @return 诊断数组。
## [br]
## @schema return: Array of Dictionary editor diagnostic records.
static func report_to_diagnostics(source: Variant, options: Dictionary = {}) -> Array[Dictionary]:
	var diagnostics: Array[Dictionary] = []
	var source_filter := String(options.get("source_path", ""))
	var include_positionless := bool(options.get("include_positionless", true))
	for issue: Variant in _get_source_issues(source):
		var diagnostic := issue_to_diagnostic(issue, options)
		if diagnostic.is_empty():
			continue
		if not source_filter.is_empty() and String(diagnostic.get("source_path", "")) != source_filter:
			continue
		if not include_positionless and int(diagnostic.get("line", 0)) <= 0:
			continue
		diagnostics.append(diagnostic)
	return diagnostics


## 按源路径分组诊断。
## [br]
## @api public
## [br]
## @param diagnostics: 诊断数组。
## [br]
## @schema diagnostics: Array of Dictionary editor diagnostic records.
## [br]
## @return source_path -> Array[Dictionary]。
## [br]
## @schema return: Dictionary keyed by source_path with diagnostic arrays.
static func group_by_source(diagnostics: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {}
	for diagnostic: Dictionary in diagnostics:
		var source_path := String(diagnostic.get("source_path", ""))
		if not result.has(source_path):
			result[source_path] = []
		(result[source_path] as Array).append(diagnostic.duplicate(true))
	return result


## 生成适合行号栏、问题列表或资源面板消费的行记录。
## [br]
## @api public
## [br]
## @param diagnostics: 诊断数组。
## [br]
## @schema diagnostics: Array of Dictionary editor diagnostic records.
## [br]
## @param options: 可选参数，支持 include_positionless。
## [br]
## @schema options: Dictionary line record conversion options.
## [br]
## @return 行记录数组。
## [br]
## @schema return: Array of Dictionary line records.
static func make_line_records(diagnostics: Array[Dictionary], options: Dictionary = {}) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var include_positionless := bool(options.get("include_positionless", false))
	for diagnostic: Dictionary in diagnostics:
		var line_number := int(diagnostic.get("line", 0))
		if line_number <= 0 and not include_positionless:
			continue
		records.append({
			"source_path": String(diagnostic.get("source_path", "")),
			"line": line_number,
			"line_index": line_number - 1 if line_number > 0 else -1,
			"column": int(diagnostic.get("column", 0)),
			"column_index": int(diagnostic.get("column", 0)) - 1 if int(diagnostic.get("column", 0)) > 0 else -1,
			"severity": String(diagnostic.get("severity", "error")),
			"kind": String(diagnostic.get("kind", "")),
			"message": String(diagnostic.get("message", "")),
			"tooltip": make_tooltip(diagnostic),
			"diagnostic": diagnostic.duplicate(true),
		})
	return records


## 生成单条诊断的简短显示文本。
## [br]
## @api public
## [br]
## @param diagnostic: 诊断字典。
## [br]
## @schema diagnostic: Dictionary editor diagnostic record.
## [br]
## @return 显示文本。
static func make_display_text(diagnostic: Dictionary) -> String:
	var message := String(diagnostic.get("message", ""))
	var kind := String(diagnostic.get("kind", ""))
	if message.is_empty():
		message = kind
	if message.is_empty():
		message = "Validation issue"

	var location := String(diagnostic.get("location", ""))
	if location.is_empty() or location == "source":
		return message
	return "%s: %s" % [location, message]


## 生成单条诊断的工具提示文本。
## [br]
## @api public
## [br]
## @param diagnostic: 诊断字典。
## [br]
## @schema diagnostic: Dictionary editor diagnostic record.
## [br]
## @return 工具提示文本。
static func make_tooltip(diagnostic: Dictionary) -> String:
	var lines := PackedStringArray()
	var severity := String(diagnostic.get("severity", "error"))
	var kind := String(diagnostic.get("kind", ""))
	var message := String(diagnostic.get("message", ""))
	var location := String(diagnostic.get("location", ""))
	lines.append("[%s] %s" % [severity, kind if not kind.is_empty() else "validation"])
	if not message.is_empty():
		lines.append(message)
	if not location.is_empty() and location != "source":
		lines.append(location)
	var preview := String(diagnostic.get("preview", ""))
	if not preview.is_empty():
		lines.append(preview)
	return "\n".join(lines)


# --- 私有/辅助方法 ---

static func _issue_to_dict(issue: Variant, include_empty_fields: bool = false) -> Dictionary:
	if issue is GF_VALIDATION_ISSUE_BASE:
		var issue_dict: Variant = (issue as RefCounted).call("to_dict", include_empty_fields)
		return issue_dict as Dictionary if issue_dict is Dictionary else {}
	if issue is Dictionary:
		var issue_data := issue as Dictionary
		if issue_data.is_empty():
			return {}
		var normalized_issue := GF_VALIDATION_ISSUE_BASE.new() as RefCounted
		normalized_issue.call("apply_dict", issue_data)
		var normalized_dict: Variant = normalized_issue.call("to_dict", include_empty_fields)
		return normalized_dict as Dictionary if normalized_dict is Dictionary else {}
	return {}


static func _get_source_issues(source: Variant) -> Array:
	if source is GF_VALIDATION_REPORT_BASE:
		var issues := (source as RefCounted).get("issues") as Array
		return issues.duplicate() if issues != null else []
	if source is Dictionary:
		var source_issues := (source as Dictionary).get("issues", []) as Array
		return source_issues.duplicate() if source_issues != null else []
	if source is Array:
		return (source as Array).duplicate()
	return []


static func _make_span_data(issue_data: Dictionary, options: Dictionary) -> Dictionary:
	var span_data: Dictionary = {}
	if issue_data.get("source_span") is Dictionary:
		span_data = (issue_data.get("source_span") as Dictionary).duplicate(true)

	for field_name: String in ["source_path", "source", "line", "column", "length", "end_line", "end_column", "preview"]:
		if issue_data.has(field_name):
			span_data[field_name] = GFVariantData.duplicate_variant(issue_data[field_name])

	if String(span_data.get("source_path", "")).is_empty() and bool(options.get("use_path_as_source", false)):
		span_data["source_path"] = String(issue_data.get("path", ""))
	return span_data


static func _source_span_from_dict(data: Dictionary) -> RefCounted:
	var span := GF_SOURCE_SPAN_BASE.new() as RefCounted
	span.call("apply_dict", data)
	return span


static func _get_issue_kind(issue_data: Dictionary) -> String:
	var kind_value: Variant = issue_data.get("kind", "unknown")
	var kind_text := String(kind_value)
	return kind_text if not kind_text.is_empty() else "unknown"


static func _read_dictionary(data: Dictionary, field_name: String) -> Dictionary:
	var value: Variant = data.get(field_name, {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}
