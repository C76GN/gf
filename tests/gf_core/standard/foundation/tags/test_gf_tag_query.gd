## 测试通用标签集合与查询工具。
extends GutTest


func test_tag_query_matches_all_any_none_with_hierarchy() -> void:
	var tag_set: GFTagSet = GFTagSet.new()
	var _burning_added: GFTagSet = tag_set.add_tag(&"state.burning", 2)
	var _enemy_added: GFTagSet = tag_set.add_tag(&"team.enemy")
	var query: GFTagQuery = GFTagQuery.new()
	query.all_tags = [&"state"]
	query.any_tags = [&"team.enemy", &"team.ally"]
	query.none_tags = [&"state.frozen"]
	query.include_child_tags = true

	var report: Dictionary = query.get_match_report(tag_set)
	var missing_all: Array = GFVariantData.as_array(GFVariantData.get_option_value(report, "missing_all"))
	var blocked_tags: Array = GFVariantData.as_array(GFVariantData.get_option_value(report, "blocked_tags"))

	assert_true(GFVariantData.get_option_bool(report, "ok"), "层级标签应能满足父级查询。")
	assert_true(missing_all.is_empty(), "满足 all 条件时不应报告缺失。")
	assert_true(blocked_tags.is_empty(), "未命中 none 条件时不应报告阻塞。")


func test_tag_query_reports_blocked_tags() -> void:
	var tag_set: GFTagSet = GFTagSet.new()
	var _tags_set: GFTagSet = tag_set.set_tags([&"state.stunned"])
	var query: GFTagQuery = GFTagQuery.new()
	query.none_tags = [&"state.stunned"]

	var report: Dictionary = query.get_match_report(tag_set)

	assert_false(GFVariantData.get_option_bool(report, "ok"), "命中禁止标签时查询应失败。")
	assert_eq(GFVariantData.get_option_array(report, "blocked_tags"), [&"state.stunned"], "报告应包含阻塞标签。")


func test_tag_utility_reads_object_protocol_and_dictionary_sources() -> void:
	var component: SampleTagSource = SampleTagSource.new()
	component.add_tag(&"state.burning", 2)
	var dictionary_source: Dictionary = {
		"tags": PackedStringArray(["state.frozen", "team.enemy"]),
	}

	assert_true(GFTagSourceAdapter.source_has_tag(component, &"state", 2, true), "工具应读取对象标签协议并支持层级层数。")
	assert_true(GFTagSourceAdapter.source_has_tag(dictionary_source, &"state", 1, true), "工具应读取字典标签源。")
	assert_eq(component.get_tags(), PackedStringArray(["state.burning"]), "对象标签协议应提供可枚举快照。")


func test_tag_source_adapter_normalizes_sources_to_counts_and_sets() -> void:
	var dictionary_source: Dictionary = {
		"tag_counts": {
			&"state.burning": 2,
			"team.enemy": 1,
		},
	}
	var array_source: PackedStringArray = PackedStringArray(["state.burning", "state.burning", "rank.elite"])

	var counts: Dictionary = GFTagSourceAdapter.get_tag_counts(dictionary_source)
	var tag_set: GFTagSet = GFTagSourceAdapter.to_tag_set(array_source)

	assert_eq(GFVariantData.get_option_int(counts, &"state.burning"), 2, "字典来源应规范化为标签层数字典。")
	assert_eq(GFVariantData.get_option_int(counts, &"team.enemy"), 1, "String key 应规范化为 StringName。")
	assert_eq(tag_set.get_tag_count(&"state.burning"), 2, "数组来源应规范化为 GFTagSet。")
	assert_eq(tag_set.get_tag_count(&"rank.elite"), 1, "数组来源应保留普通标签。")


func test_tag_source_adapter_merges_multiple_sources() -> void:
	var component: SampleTagSource = SampleTagSource.new()
	component.add_tag(&"state.burning", 2)
	var merged: GFTagSet = GFTagSourceAdapter.merge_sources([
		component,
		[&"state.burning", &"team.enemy"],
		{ "tag_counts": { &"team.enemy": 2 } },
	])

	assert_eq(merged.get_tag_count(&"state.burning"), 3, "合并时应累加不同来源的标签层数。")
	assert_eq(merged.get_tag_count(&"team.enemy"), 3, "合并时应累加字典和数组来源。")


# --- 内部类 ---

class SampleTagSource:
	extends RefCounted

	var _tags: GFTagSet = GFTagSet.new()

	func add_tag(tag: StringName, count: int = 1) -> void:
		var _added: GFTagSet = _tags.add_tag(tag, count)

	func has_tag(tag: StringName, minimum_count: int = 1) -> bool:
		return get_tag_count(tag) >= minimum_count

	func get_tag_count(tag: StringName) -> int:
		return _tags.get_tag_count(tag)

	func get_tags() -> PackedStringArray:
		return _tags.get_tags()
