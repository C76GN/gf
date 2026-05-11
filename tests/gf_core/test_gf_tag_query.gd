## 测试通用标签集合与查询工具。
extends GutTest


# --- 常量 ---

const GFTagQueryBase = preload("res://addons/gf/foundation/tags/gf_tag_query.gd")
const GFTagSetBase = preload("res://addons/gf/foundation/tags/gf_tag_set.gd")
const GFTagUtilityBase = preload("res://addons/gf/foundation/tags/gf_tag_utility.gd")


# --- 测试方法 ---

func test_tag_query_matches_all_any_none_with_hierarchy() -> void:
	var tag_set := GFTagSetBase.new()
	tag_set.add_tag(&"state.burning", 2)
	tag_set.add_tag(&"team.enemy")
	var query := GFTagQueryBase.new()
	query.all_tags = [&"state"]
	query.any_tags = [&"team.enemy", &"team.ally"]
	query.none_tags = [&"state.frozen"]
	query.include_child_tags = true

	var report := query.get_match_report(tag_set)

	assert_true(bool(report["ok"]), "层级标签应能满足父级查询。")
	assert_true((report["missing_all"] as Array).is_empty(), "满足 all 条件时不应报告缺失。")
	assert_true((report["blocked_tags"] as Array).is_empty(), "未命中 none 条件时不应报告阻塞。")


func test_tag_query_reports_blocked_tags() -> void:
	var tag_set := GFTagSetBase.new()
	tag_set.set_tags([&"state.stunned"])
	var query := GFTagQueryBase.new()
	query.none_tags = [&"state.stunned"]

	var report := query.get_match_report(tag_set)

	assert_false(bool(report["ok"]), "命中禁止标签时查询应失败。")
	assert_eq(report["blocked_tags"], [&"state.stunned"], "报告应包含阻塞标签。")


func test_tag_utility_reads_tag_component_and_dictionary_sources() -> void:
	var component := GFTagComponent.new()
	component.add_tag(&"state.burning", 2)
	var dictionary_source := {
		"tags": PackedStringArray(["state.frozen", "team.enemy"]),
	}

	assert_true(GFTagUtilityBase.source_has_tag(component, &"state", 2, true), "工具应读取对象标签组件并支持层级层数。")
	assert_true(GFTagUtilityBase.source_has_tag(dictionary_source, &"state", 1, true), "工具应读取字典标签源。")
	assert_eq(component.get_tags(), PackedStringArray(["state.burning"]), "标签组件应提供可枚举快照。")
