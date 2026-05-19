## GFConfigValidationReport: 配置表校验报告构建工具。
##
## 统一创建、合并和补全配置表校验报告，保证 schema、导入器、引用解析和补丁合并使用相同问题结构。
class_name GFConfigValidationReport
extends RefCounted


# --- 常量 ---

const CONTEXT_FIELDS: Array[String] = [
	"source",
	"line",
	"column",
	"row_index",
	"column_index",
	"rule_id",
]


# --- 公共方法 ---

## 创建空校验报告。
## @param table_name: 表名。
## @param row_count: 记录数量。
## @return 校验报告字典。
func make_report(table_name: StringName = &"", row_count: int = 0) -> Dictionary:
	return {
		"ok": true,
		"table_name": table_name,
		"row_count": row_count,
		"error_count": 0,
		"warning_count": 0,
		"issues": [],
	}


## 创建单错误校验报告。
## @param table_name: 表名。
## @param kind: 稳定问题类型。
## @param message: 问题描述。
## @param context: 可选上下文。
## @return 校验报告字典。
func make_error_report(
	table_name: StringName,
	kind: String,
	message: String,
	context: Dictionary = {}
) -> Dictionary:
	var report := make_report(table_name)
	add_issue(report, "error", kind, table_name, context.get("row_key", null), StringName(context.get("field", &"")), message, context)
	finalize_report(report)
	return report


## 向报告写入一条问题。
## @param report: 目标校验报告。
## @param severity: severity 字符串，支持 error 或 warning。
## @param kind: 稳定问题类型。
## @param table_name: 表名。
## @param row_key: 行标识。
## @param field_name: 字段名。
## @param message: 问题描述。
## @param context: 可选上下文。
func add_issue(
	report: Dictionary,
	severity: String,
	kind: String,
	table_name: StringName,
	row_key: Variant,
	field_name: StringName,
	message: String,
	context: Dictionary = {}
) -> void:
	var issue := {
		"severity": severity,
		"kind": kind,
		"table_name": table_name,
		"row_key": row_key,
		"field": field_name,
		"message": message,
	}
	_apply_issue_context(issue, context)
	var issues := report.get("issues", []) as Array
	issues.append(issue)
	report["issues"] = issues

	if severity == "warning":
		report["warning_count"] = int(report.get("warning_count", 0)) + 1
	else:
		report["error_count"] = int(report.get("error_count", 0)) + 1
		report["ok"] = false


## 合并一份校验报告。
## @param target: 目标报告。
## @param source: 来源报告。
## @param include_row_count: 为 true 时累加 row_count。
func merge_report(target: Dictionary, source: Dictionary, include_row_count: bool = false) -> void:
	if include_row_count:
		target["row_count"] = int(target.get("row_count", 0)) + int(source.get("row_count", 0))
	target["error_count"] = int(target.get("error_count", 0)) + int(source.get("error_count", 0))
	target["warning_count"] = int(target.get("warning_count", 0)) + int(source.get("warning_count", 0))
	if not bool(source.get("ok", true)):
		target["ok"] = false

	var target_issues := target.get("issues", []) as Array
	for issue: Dictionary in source.get("issues", []) as Array:
		target_issues.append(issue.duplicate(true))
	target["issues"] = target_issues


## 根据 error_count 补全 ok 字段。
## @param report: 校验报告。
func finalize_report(report: Dictionary) -> void:
	report["ok"] = int(report.get("error_count", 0)) == 0


# --- 私有/辅助方法 ---

func _apply_issue_context(issue: Dictionary, context: Dictionary) -> void:
	for field_name: String in CONTEXT_FIELDS:
		if context.has(field_name):
			issue[field_name] = GFVariantData.duplicate_variant(context[field_name])
