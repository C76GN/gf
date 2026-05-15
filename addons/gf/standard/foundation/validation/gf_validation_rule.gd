## GFValidationRule: 通用校验规则资源。
##
## 通过 Callable 或子类钩子校验任意对象、资源、节点或数据。规则只负责把问题写入
## GFValidationReport，不约定项目脚本方法名，也不内置业务字段语义。
class_name GFValidationRule
extends Resource


# --- 枚举 ---

## 规则适用的目标类型。
enum TargetKind {
	## 接受任意目标。
	ANY,
	## 接受 Node。
	NODE,
	## 接受 Resource。
	RESOURCE,
	## 接受 PackedScene。
	PACKED_SCENE,
	## 接受 Dictionary。
	DICTIONARY,
	## 接受 Array。
	ARRAY,
	## 接受 Object。
	OBJECT,
}


# --- 导出变量 ---

## 规则唯一标识。推荐使用稳定的 snake_case 或点分层级标识。
@export var rule_id: StringName = &""

## 面向工具或报告的规则说明。
@export_multiline var description: String = ""

## 规则适用的目标类型。
@export var target_kind: TargetKind = TargetKind.ANY

## 是否启用该规则。
@export var enabled: bool = true

## 当 Callable 或钩子返回 false / 非空字符串时使用的默认严重级别。
@export var severity: GFValidationIssue.Severity = GFValidationIssue.Severity.ERROR

## 可选元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共变量 ---

## 可选校验回调，签名为 func(target: Variant, report: GFValidationReport, context: Dictionary) -> Variant。
var callback: Callable = Callable()


# --- 公共方法 ---

## 配置规则并返回自身。
## @param p_rule_id: 规则标识。
## @param p_callback: 可选校验回调。
## @param options: 可选字段，支持 description、target_kind、enabled、severity、metadata。
## @return 当前规则。
func configure(
	p_rule_id: StringName,
	p_callback: Callable = Callable(),
	options: Dictionary = {}
) -> GFValidationRule:
	rule_id = p_rule_id
	callback = p_callback
	description = String(options.get("description", description))
	target_kind = int(options.get("target_kind", target_kind)) as TargetKind
	enabled = bool(options.get("enabled", enabled))
	severity = GFValidationIssue.normalize_severity(options.get("severity", severity))
	var metadata_value: Variant = options.get("metadata", metadata)
	metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}
	return self


## 检查规则是否适用于目标。
## @param target: 待校验目标。
## @param context: 调用方上下文。
## @return 适用时返回 true。
func applies_to(target: Variant, context: Dictionary = {}) -> bool:
	if not enabled:
		return false
	if bool(context.get("skip_rule_kind_check", false)):
		return true
	return _target_kind_matches(target, target_kind)


## 执行规则并返回报告。
## @param target: 待校验目标。
## @param context: 调用方上下文。
## @return 校验报告。
func validate(target: Variant, context: Dictionary = {}) -> GFValidationReport:
	var report := GFValidationReport.new(_make_subject(context), {
		"rule_id": String(rule_id),
	})
	if not applies_to(target, context):
		return report

	if not metadata.is_empty():
		report.metadata["rule_metadata"] = metadata.duplicate(true)

	var hook_result: Variant = _validate(target, report, context)
	_apply_result(report, hook_result)
	if callback.is_valid():
		var callback_result: Variant = callback.call(target, report, context.duplicate(true))
		_apply_result(report, callback_result)
	return report


## 创建当前规则的浅配置副本。
## @return 新规则。
func duplicate_rule() -> GFValidationRule:
	var rule := GFValidationRule.new()
	rule.rule_id = rule_id
	rule.description = description
	rule.target_kind = target_kind
	rule.enabled = enabled
	rule.severity = severity
	rule.metadata = metadata.duplicate(true)
	rule.callback = callback
	return rule


# --- 可重写钩子 ---

func _validate(_target: Variant, _report: GFValidationReport, _context: Dictionary) -> Variant:
	return null


# --- 私有/辅助方法 ---

func _apply_result(report: GFValidationReport, value: Variant) -> void:
	if value == null:
		return
	if value is GFValidationReport:
		report.merge(value)
		return
	if value is Dictionary:
		report.merge(value)
		return
	if value is Array:
		for issue: Variant in value as Array:
			report.add_issue(issue)
		return
	if value is bool:
		if not bool(value):
			report.add_issue(_make_issue("Validation rule failed."))
		return
	if value is String or value is StringName:
		var message := String(value)
		if not message.is_empty():
			report.add_issue(_make_issue(message))


func _make_issue(message: String) -> GFValidationIssue:
	var issue := GFValidationIssue.new(severity, _get_issue_kind(), message)
	issue.subject = String(rule_id)
	if not metadata.is_empty():
		issue.metadata = metadata.duplicate(true)
	return issue


func _get_issue_kind() -> StringName:
	return rule_id if rule_id != &"" else &"validation_rule_failed"


func _make_subject(context: Dictionary) -> String:
	var subject := String(context.get("subject", ""))
	if not subject.is_empty():
		return subject
	if rule_id != &"":
		return String(rule_id)
	return "GFValidationRule"


func _target_kind_matches(target: Variant, kind: TargetKind) -> bool:
	match kind:
		TargetKind.NODE:
			return target is Node
		TargetKind.RESOURCE:
			return target is Resource
		TargetKind.PACKED_SCENE:
			return target is PackedScene
		TargetKind.DICTIONARY:
			return target is Dictionary
		TargetKind.ARRAY:
			return target is Array
		TargetKind.OBJECT:
			return target is Object
		_:
			return true
