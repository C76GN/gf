## 测试可嵌套标签表达式资源。
extends GutTest


# --- 常量 ---

const GFTagExpressionBase = preload("res://addons/gf/standard/foundation/tags/gf_tag_expression.gd")
const GFTagQueryBase = preload("res://addons/gf/standard/foundation/tags/gf_tag_query.gd")
const GFTagSetBase = preload("res://addons/gf/standard/foundation/tags/gf_tag_set.gd")


# --- 测试方法 ---

func test_any_expression_matches_nested_queries() -> void:
	var tags := GFTagSetBase.new()
	tags.set_tags([&"team.enemy", &"state.burning"])
	var burning_enemy := GFTagExpressionBase.from_query(_make_query([&"team.enemy", &"state.burning"]))
	var boss := GFTagExpressionBase.from_query(_make_query([&"rank.boss"]))
	var expression := GFTagExpressionBase.new().configure_any([burning_enemy, boss])

	var report := expression.get_match_report(tags)

	assert_true(bool(report["ok"]), "任意子表达式满足时 ANY 表达式应通过。")
	assert_eq(report["matched_indices"], [0], "报告应记录命中的子表达式索引。")
	assert_eq(report["failed_indices"], [1], "报告应记录未命中的子表达式索引。")


func test_all_expression_reports_failed_child() -> void:
	var tags := GFTagSetBase.new()
	tags.set_tags([&"team.enemy"])
	var enemy := GFTagExpressionBase.from_query(_make_query([&"team.enemy"]))
	var visible := GFTagExpressionBase.from_query(_make_query([&"state.visible"]))
	var expression := GFTagExpressionBase.new().configure_all([enemy, visible])

	var report := expression.get_match_report(tags)

	assert_false(bool(report["ok"]), "ALL 中任意子表达式失败时整体应失败。")
	assert_eq(report["matched_indices"], [0], "报告应保留已满足子表达式。")
	assert_eq(report["failed_indices"], [1], "报告应指出失败子表达式。")
	assert_eq(report["reason"], "child_failed", "失败原因应说明子表达式未满足。")


func test_none_expression_blocks_matching_children() -> void:
	var tags := GFTagSetBase.new()
	tags.set_tags([&"state.stunned"])
	var stunned := GFTagExpressionBase.from_query(_make_query([&"state.stunned"]))
	var expression := GFTagExpressionBase.new().configure_none([stunned])

	var report := expression.get_match_report(tags)

	assert_false(bool(report["ok"]), "NONE 中有子表达式满足时整体应失败。")
	assert_eq(report["matched_indices"], [0], "报告应指出阻塞命中的子表达式。")
	assert_eq(report["reason"], "blocked_child_matched", "失败原因应说明禁止子表达式被命中。")


func test_expression_dictionary_roundtrip_preserves_nested_logic() -> void:
	var enemy := GFTagExpressionBase.from_query(_make_query([&"team.enemy"]))
	var ally := GFTagExpressionBase.from_query(_make_query([&"team.ally"]))
	var expression := GFTagExpressionBase.new().configure_any([enemy, ally])

	var restored := GFTagExpressionBase.from_dictionary(expression.to_dictionary())

	assert_true(restored.matches([&"team.ally"]), "字典往返后应保留嵌套匹配逻辑。")
	assert_false(restored.matches([&"team.neutral"]), "字典往返后未满足条件仍应失败。")


func test_expression_reports_cycles_as_failure() -> void:
	var expression := GFTagExpressionBase.new()
	expression.operator = GFTagExpressionBase.Operator.ALL
	expression.expressions.append(expression)

	var report := expression.get_match_report([&"team.enemy"])
	var child_reports := report["child_reports"] as Array
	var child_report := child_reports[0] as Dictionary

	assert_false(bool(report["ok"]), "循环表达式不应无限递归或通过。")
	assert_eq(child_report["reason"], "cycle_detected", "循环应进入诊断报告。")
	expression.expressions.clear()


# --- 私有/辅助方法 ---

func _make_query(required_all: Array[StringName]) -> GFTagQueryBase:
	var query := GFTagQueryBase.new()
	query.all_tags = required_all
	return query
