## 测试通用标签集合与查询工具。
extends GutTest


# --- 常量 ---

const GFTagQueryBase = preload("res://addons/gf/standard/foundation/tags/gf_tag_query.gd")
const GFTagSetBase = preload("res://addons/gf/standard/foundation/tags/gf_tag_set.gd")
const GFTagSourceAdapterBase = preload("res://addons/gf/standard/foundation/tags/gf_tag_source_adapter.gd")


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

	assert_true(GFTagSourceAdapterBase.source_has_tag(component, &"state", 2, true), "工具应读取对象标签组件并支持层级层数。")
	assert_true(GFTagSourceAdapterBase.source_has_tag(dictionary_source, &"state", 1, true), "工具应读取字典标签源。")
	assert_eq(component.get_tags(), PackedStringArray(["state.burning"]), "标签组件应提供可枚举快照。")


func test_tag_source_adapter_normalizes_sources_to_counts_and_sets() -> void:
	var dictionary_source := {
		"tag_counts": {
			&"state.burning": 2,
			"team.enemy": 1,
		},
	}
	var array_source := PackedStringArray(["state.burning", "state.burning", "rank.elite"])

	var counts := GFTagSourceAdapterBase.get_tag_counts(dictionary_source)
	var tag_set := GFTagSourceAdapterBase.to_tag_set(array_source)

	assert_eq(int(counts.get(&"state.burning", 0)), 2, "字典来源应规范化为标签层数字典。")
	assert_eq(int(counts.get(&"team.enemy", 0)), 1, "String key 应规范化为 StringName。")
	assert_eq(tag_set.get_tag_count(&"state.burning"), 2, "数组来源应规范化为 GFTagSet。")
	assert_eq(tag_set.get_tag_count(&"rank.elite"), 1, "数组来源应保留普通标签。")


func test_tag_source_adapter_merges_multiple_sources() -> void:
	var component := GFTagComponent.new()
	component.add_tag(&"state.burning", 2)
	var merged := GFTagSourceAdapterBase.merge_sources([
		component,
		[&"state.burning", &"team.enemy"],
		{ "tag_counts": { &"team.enemy": 2 } },
	])

	assert_eq(merged.get_tag_count(&"state.burning"), 3, "合并时应累加不同来源的标签层数。")
	assert_eq(merged.get_tag_count(&"team.enemy"), 3, "合并时应累加字典和数组来源。")
