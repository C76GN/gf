## GFTagExpression: 可嵌套标签查询表达式资源。
##
## 在 GFTagQuery 的 all/any/none 单层查询之上提供组合表达式，适合描述
## “任意一组条件成立”“全部子条件成立”或“没有子条件成立”等通用标签规则。
## 它只组合查询结果，不维护全局标签表，也不规定标签业务语义。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.18.0
class_name GFTagExpression
extends Resource


# --- 枚举 ---

## 表达式运算类型。
## [br]
## @api public
enum Operator {
	## 使用 query 作为叶子查询。
	QUERY,
	## 全部子表达式都满足。
	ALL,
	## 任意子表达式满足。
	ANY,
	## 没有子表达式满足。
	NONE,
}


# --- 常量 ---

const _SCRIPT_PATH: String = "res://addons/gf/standard/foundation/tags/gf_tag_expression.gd"


# --- 导出变量 ---

## 当前表达式运算类型。
## [br]
## @api public
@export var operator: Operator = Operator.QUERY

## 叶子标签查询。operator 为 QUERY 时使用；为空时视为无条件通过。
## [br]
## @api public
@export var query: GFTagQuery = null

## 子表达式列表。operator 为 ALL、ANY 或 NONE 时使用。
## [br]
## @api public
## [br]
## @schema expressions: Array[GFTagExpression]，按数组顺序参与组合判断。
@export var expressions: Array[GFTagExpression] = []


# --- 公共方法 ---

## 检查表达式是否为空。
## [br]
## @api public
## [br]
## @return 无叶子查询且无子表达式时返回 true。
func is_empty() -> bool:
	if operator == Operator.QUERY:
		return query == null or query.is_empty()
	return expressions.is_empty()


## 匹配标签源。
## [br]
## @api public
## [br]
## @param source: 标签源。
## [br]
## @schema source: Variant accepted by GFTagSourceAdapter through GFTagQuery.
## [br]
## @return 表达式满足时返回 true。
func matches(source: Variant) -> bool:
	var report := get_match_report(source)
	return bool(report.get("ok", false))


## 获取匹配报告。
## [br]
## @api public
## [br]
## @param source: 标签源。
## [br]
## @schema source: Variant accepted by GFTagSourceAdapter through GFTagQuery.
## [br]
## @return 匹配报告。
## [br]
## @schema return: Dictionary，包含 ok、operator、query_report、child_reports、matched_indices、failed_indices、reason 等字段。
func get_match_report(source: Variant) -> Dictionary:
	return _get_match_report(source, [])


## 配置为叶子查询表达式。
## [br]
## @api public
## [br]
## @param tag_query: 标签查询资源。
## [br]
## @return 当前表达式。
func configure_query(tag_query: GFTagQuery) -> GFTagExpression:
	operator = Operator.QUERY
	query = tag_query
	expressions.clear()
	return self


## 配置为全部子表达式都满足。
## [br]
## @api public
## [br]
## @param child_expressions: 子表达式列表。
## [br]
## @return 当前表达式。
## [br]
## @schema child_expressions: Array[GFTagExpression]，null 项会在匹配时按失败处理。
func configure_all(child_expressions: Array[GFTagExpression]) -> GFTagExpression:
	operator = Operator.ALL
	query = null
	expressions = child_expressions.duplicate()
	return self


## 配置为任意子表达式满足。
## [br]
## @api public
## [br]
## @param child_expressions: 子表达式列表。
## [br]
## @return 当前表达式。
## [br]
## @schema child_expressions: Array[GFTagExpression]，null 项会在匹配时按失败处理。
func configure_any(child_expressions: Array[GFTagExpression]) -> GFTagExpression:
	operator = Operator.ANY
	query = null
	expressions = child_expressions.duplicate()
	return self


## 配置为没有子表达式满足。
## [br]
## @api public
## [br]
## @param child_expressions: 子表达式列表。
## [br]
## @return 当前表达式。
## [br]
## @schema child_expressions: Array[GFTagExpression]，null 项会在匹配时按失败处理。
func configure_none(child_expressions: Array[GFTagExpression]) -> GFTagExpression:
	operator = Operator.NONE
	query = null
	expressions = child_expressions.duplicate()
	return self


## 创建同内容拷贝。
## [br]
## @api public
## [br]
## @return 新表达式。
func duplicate_expression() -> GFTagExpression:
	var copy := get_script().new() as GFTagExpression
	copy.operator = operator
	copy.query = query.duplicate_query() if query != null else null
	for expression: GFTagExpression in expressions:
		copy.expressions.append(expression.duplicate_expression() if expression != null else null)
	return copy


## 导出为字典。
## [br]
## @api public
## [br]
## @return 表达式字典。
## [br]
## @schema return: Dictionary serialized tag expression.
func to_dictionary() -> Dictionary:
	var child_dictionaries: Array[Dictionary] = []
	for expression: GFTagExpression in expressions:
		if expression != null:
			child_dictionaries.append(expression.to_dictionary())

	return {
		"operator": _operator_to_string(operator),
		"query": query.to_dictionary() if query != null else {},
		"expressions": child_dictionaries,
	}


## 从字典创建表达式。
## [br]
## @api public
## [br]
## @param data: 表达式字典。
## [br]
## @schema data: Dictionary serialized tag expression.
## [br]
## @return 新表达式。
static func from_dictionary(data: Dictionary) -> GFTagExpression:
	var expression := (load(_SCRIPT_PATH) as Script).new() as GFTagExpression
	expression.operator = _operator_from_variant(data.get("operator", Operator.QUERY))
	var query_data := data.get("query", {})
	if query_data is Dictionary and not (query_data as Dictionary).is_empty():
		expression.query = GFTagQuery.from_dictionary(query_data as Dictionary)
	var child_data := data.get("expressions", [])
	if child_data is Array:
		for child_variant: Variant in child_data as Array:
			if child_variant is Dictionary:
				expression.expressions.append(GFTagExpression.from_dictionary(child_variant as Dictionary))
	return expression


## 以查询资源创建叶子表达式。
## [br]
## @api public
## [br]
## @param tag_query: 标签查询资源。
## [br]
## @return 新表达式。
static func from_query(tag_query: GFTagQuery) -> GFTagExpression:
	return ((load(_SCRIPT_PATH) as Script).new() as GFTagExpression).configure_query(tag_query)


# --- 私有/辅助方法 ---

func _get_match_report(source: Variant, visited: Array[int]) -> Dictionary:
	var instance_id := get_instance_id()
	if visited.has(instance_id):
		return {
			"ok": false,
			"operator": _operator_to_string(operator),
			"reason": "cycle_detected",
			"query_report": {},
			"child_reports": [],
			"matched_indices": [],
			"failed_indices": [],
		}

	visited.append(instance_id)
	var report: Dictionary
	match operator:
		Operator.QUERY:
			report = _get_query_match_report(source)
		Operator.ALL:
			report = _get_children_match_report(source, visited, true, false)
		Operator.ANY:
			report = _get_children_match_report(source, visited, false, true)
		Operator.NONE:
			report = _get_none_match_report(source, visited)
		_:
			report = {
				"ok": false,
				"operator": "unknown",
				"reason": "unknown_operator",
				"query_report": {},
				"child_reports": [],
				"matched_indices": [],
				"failed_indices": [],
			}
	visited.pop_back()
	return report


func _get_query_match_report(source: Variant) -> Dictionary:
	var query_report := query.get_match_report(source) if query != null else { "ok": true }
	return {
		"ok": bool(query_report.get("ok", false)),
		"operator": _operator_to_string(operator),
		"reason": "" if bool(query_report.get("ok", false)) else "query_failed",
		"query_report": query_report,
		"child_reports": [],
		"matched_indices": [],
		"failed_indices": [],
	}


func _get_children_match_report(
	source: Variant,
	visited: Array[int],
	require_all: bool,
	empty_value: bool
) -> Dictionary:
	var child_reports: Array[Dictionary] = []
	var matched_indices: Array[int] = []
	var failed_indices: Array[int] = []
	for index: int in range(expressions.size()):
		var child := expressions[index]
		var child_report := _get_null_child_report() if child == null else child._get_match_report(source, visited)
		child_reports.append(child_report)
		if bool(child_report.get("ok", false)):
			matched_indices.append(index)
		else:
			failed_indices.append(index)

	var ok := empty_value if expressions.is_empty() else (
		failed_indices.is_empty() if require_all else not matched_indices.is_empty()
	)
	return {
		"ok": ok,
		"operator": _operator_to_string(operator),
		"reason": "" if ok else ("child_failed" if require_all else "no_child_matched"),
		"query_report": {},
		"child_reports": child_reports,
		"matched_indices": matched_indices,
		"failed_indices": failed_indices,
	}


func _get_none_match_report(source: Variant, visited: Array[int]) -> Dictionary:
	var child_reports: Array[Dictionary] = []
	var matched_indices: Array[int] = []
	var failed_indices: Array[int] = []
	for index: int in range(expressions.size()):
		var child := expressions[index]
		var child_report := _get_null_child_report() if child == null else child._get_match_report(source, visited)
		child_reports.append(child_report)
		if bool(child_report.get("ok", false)):
			matched_indices.append(index)
		else:
			failed_indices.append(index)

	var ok := matched_indices.is_empty()
	return {
		"ok": ok,
		"operator": _operator_to_string(operator),
		"reason": "" if ok else "blocked_child_matched",
		"query_report": {},
		"child_reports": child_reports,
		"matched_indices": matched_indices,
		"failed_indices": failed_indices,
	}


func _get_null_child_report() -> Dictionary:
	return {
		"ok": false,
		"operator": "null",
		"reason": "null_expression",
		"query_report": {},
		"child_reports": [],
		"matched_indices": [],
		"failed_indices": [],
	}


static func _operator_to_string(value: int) -> String:
	match value:
		Operator.QUERY:
			return "query"
		Operator.ALL:
			return "all"
		Operator.ANY:
			return "any"
		Operator.NONE:
			return "none"
		_:
			return "unknown"


static func _operator_from_variant(value: Variant) -> Operator:
	if value is int:
		var numeric := int(value)
		if numeric >= Operator.QUERY and numeric <= Operator.NONE:
			return numeric

	var text := String(value).to_lower()
	match text:
		"query":
			return Operator.QUERY
		"all":
			return Operator.ALL
		"any":
			return Operator.ANY
		"none":
			return Operator.NONE
		_:
			return Operator.QUERY
