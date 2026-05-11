## 测试 GFWeightedTable 的权重选择、去重选择、复制与字典序列化。
extends GutTest


# --- 常量 ---

const GF_WEIGHTED_TABLE := preload("res://addons/gf/foundation/math/gf_weighted_table.gd")


# --- 测试 ---

func test_pick_value_ignores_non_positive_weights() -> void:
	var table := GF_WEIGHTED_TABLE.new()
	table.default_value = "EMPTY"
	table.add_entry("SKIP", 0.0)
	table.add_entry("ONLY", 1.0)

	assert_eq(table.pick_value(_make_rng(1)), "ONLY")
	assert_eq(table.get_total_weight(), 1.0)


func test_pick_many_is_reproducible_with_seeded_rng() -> void:
	var first: Array = _make_sample_table().pick_many(8, _make_rng(42))
	var second: Array = _make_sample_table().pick_many(8, _make_rng(42))

	assert_eq(first, second, "相同随机种子应产生可复现的权重选择序列。")


func test_pick_many_without_repeats_returns_unique_entries() -> void:
	var values: Array = _make_sample_table().pick_many(8, _make_rng(7), false)

	assert_eq(values.size(), 3)
	assert_eq(_count_unique(values), 3, "不允许重复时同一条目不应被选择两次。")


func test_serialized_table_roundtrips_entries_and_seed() -> void:
	var table: GFWeightedTable = _make_sample_table()
	table.default_value = "NONE"
	table.deterministic_seed = 99

	var restored := GF_WEIGHTED_TABLE.from_dict(table.to_dict())

	assert_eq(restored.default_value, "NONE")
	assert_eq(restored.deterministic_seed, 99)
	assert_eq(restored.entries.size(), 3)
	assert_eq(restored.entries[1].value, "B")
	assert_eq(restored.entries[1].weight, 2.0)


func test_duplicate_table_can_deep_copy_entries() -> void:
	var table := GF_WEIGHTED_TABLE.new()
	var entry := table.add_entry({"id": "A"}, 1.0, {"tag": "sample"})
	var copied := table.duplicate_table(true)

	entry.value.id = "B"
	entry.metadata.tag = "changed"

	assert_eq(copied.entries[0].value.id, "A")
	assert_eq(copied.entries[0].metadata.tag, "sample")


# --- 私有/辅助方法 ---

func _make_sample_table() -> GFWeightedTable:
	var table := GF_WEIGHTED_TABLE.new()
	table.add_entry("A", 1.0)
	table.add_entry("B", 2.0)
	table.add_entry("C", 3.0)
	return table


func _make_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _count_unique(values: Array) -> int:
	var lookup := {}
	for value in values:
		lookup[value] = true
	return lookup.size()
