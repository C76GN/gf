## GFConfigValidationRule: 导表校验规则基类。
##
## 用于把字段、记录或整表校验拆成可组合 Resource，便于项目按需声明范围、
## 正则、资源路径或本地化 key 等规则，而不把业务表结构写进框架。
class_name GFConfigValidationRule
extends Resource


# --- 枚举 ---

## 校验问题严重级别。
enum IssueSeverity {
	## 警告，不阻止报告通过。
	WARNING,
	## 错误，会让报告失败。
	ERROR,
}


# --- 导出变量 ---

## 规则稳定标识。为空时使用规则类型默认标识。
@export var rule_id: StringName = &""

## 是否启用当前规则。
@export var enabled: bool = true

## 规则触发时写入报告的严重级别。
@export var severity: IssueSeverity = IssueSeverity.ERROR

## 值为 null 时是否直接跳过值校验。
@export var allow_null: bool = true

## 可选元数据，供编辑器或项目工具扩展使用。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取稳定规则标识。
## @return 规则标识。
func get_rule_id() -> StringName:
	if rule_id != &"":
		return rule_id
	return _get_default_rule_id()


## 校验单个字段值。
## @param value: 待校验值。
## @param context: 可选上下文，支持 table_name、row_key、field、source、line、column。
## @return 校验报告字典。
func validate_value(value: Variant, context: Dictionary = {}) -> Dictionary:
	var report := _make_report(context)
	if not enabled:
		return report
	if value == null and allow_null:
		return report
	if value == null:
		_add_issue(report, context, "null_value", "值不允许为空。")
		_finalize_report(report)
		return report

	_validate_value(value, context, report)
	_finalize_report(report)
	return report


## 校验单条记录。
## @param record: 待校验记录。
## @param context: 可选上下文，支持 table_name、row_key、source、line。
## @return 校验报告字典。
func validate_record(record: Dictionary, context: Dictionary = {}) -> Dictionary:
	var report := _make_report(context)
	if not enabled:
		return report
	_validate_record(record, context, report)
	_finalize_report(report)
	return report


## 校验整张表。
## @param rows: 规范化行列表，每项通常包含 row_key、record 和 row_index。
## @param context: 可选上下文，支持 table_name、source。
## @return 校验报告字典。
func validate_table(rows: Array[Dictionary], context: Dictionary = {}) -> Dictionary:
	var report := _make_report(context)
	if not enabled:
		return report
	_validate_table(rows, context, report)
	_finalize_report(report)
	return report


## 创建同内容拷贝。
## @return 新规则。
func duplicate_rule() -> GFConfigValidationRule:
	return duplicate(true) as GFConfigValidationRule


## 导出规则摘要。
## @return 规则摘要字典。
func describe() -> Dictionary:
	return {
		"rule_id": get_rule_id(),
		"enabled": enabled,
		"severity": _severity_to_string(),
		"allow_null": allow_null,
		"metadata": metadata.duplicate(true),
		"script_path": get_script().resource_path if get_script() != null else "",
	}


# --- 可重写钩子 ---

func _get_default_rule_id() -> StringName:
	return &"validation_rule"


func _validate_value(_value: Variant, _context: Dictionary, _report: Dictionary) -> void:
	pass


func _validate_record(_record: Dictionary, _context: Dictionary, _report: Dictionary) -> void:
	pass


func _validate_table(_rows: Array[Dictionary], _context: Dictionary, _report: Dictionary) -> void:
	pass


# --- 私有/辅助方法 ---

func _make_report(context: Dictionary) -> Dictionary:
	return {
		"ok": true,
		"table_name": StringName(context.get("table_name", &"")),
		"row_count": 0,
		"error_count": 0,
		"warning_count": 0,
		"issues": [],
	}


func _add_issue(report: Dictionary, context: Dictionary, code: String, message: String) -> void:
	var issue := {
		"severity": _severity_to_string(),
		"code": code,
		"table_name": StringName(context.get("table_name", &"")),
		"row_key": context.get("row_key", null),
		"field": StringName(context.get("field", &"")),
		"message": message,
		"rule_id": get_rule_id(),
	}
	_copy_context_field(issue, context, "source")
	_copy_context_field(issue, context, "line")
	_copy_context_field(issue, context, "column")
	_copy_context_field(issue, context, "row_index")
	_copy_context_field(issue, context, "column_index")

	var issues := report["issues"] as Array
	issues.append(issue)
	if issue["severity"] == "warning":
		report["warning_count"] = int(report["warning_count"]) + 1
	else:
		report["error_count"] = int(report["error_count"]) + 1
		report["ok"] = false


func _copy_context_field(target: Dictionary, context: Dictionary, field_name: String) -> void:
	if context.has(field_name):
		target[field_name] = GFVariantData.duplicate_variant(context[field_name])


func _finalize_report(report: Dictionary) -> void:
	report["ok"] = int(report.get("error_count", 0)) == 0


func _severity_to_string() -> String:
	return "warning" if severity == IssueSeverity.WARNING else "error"


func _make_variant_key(value: Variant) -> String:
	return "%d:%s" % [typeof(value), var_to_str(value)]
