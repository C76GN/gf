## 测试 TileMap 相关的通用规则与缓存基础件。
extends GutTest


const GFTileRuleSetBase = preload("res://addons/gf/foundation/math/gf_tile_rule_set.gd")
const GFTileMapCacheBase = preload("res://addons/gf/foundation/math/gf_tile_map_cache.gd")


func test_tile_rule_set_resolves_registered_rule() -> void:
	var rules := GFTileRuleSetBase.new()
	rules.default_result = "empty"

	rules.register_rule([1, 2, 3], "tile_a")

	assert_true(rules.has_rule([1, 2, 3]), "注册后的邻域规则应可查询。")
	assert_eq(rules.resolve([1, 2, 3]), "tile_a", "邻域值完全匹配时应返回注册结果。")
	assert_eq(rules.resolve([1, 2, 4]), "empty", "没有匹配规则时应返回默认结果。")


func test_tile_rule_set_falls_back_per_neighbor() -> void:
	var rules := GFTileRuleSetBase.new()
	rules.fallback_neighbor_value = 0
	rules.default_result = "empty"
	rules.register_rule([1, 0, 1], "edge")

	assert_eq(rules.resolve([1, 9, 1]), "edge", "单个邻域值缺失时应尝试使用 fallback 值匹配。")


func test_tile_rule_set_allows_results_as_neighbor_value() -> void:
	var rules := GFTileRuleSetBase.new()
	rules.default_result = "empty"

	rules.register_rule([1, "results", 2], "safe")

	assert_true(rules.has_rule([1, "results", 2]), "邻域值不应和内部结果字段冲突。")
	assert_eq(rules.resolve([1, "results", 2]), "safe", "使用 results 作为普通邻域值也应可解析。")


func test_tile_map_cache_diff_can_compare_full_record_or_single_key() -> void:
	var previous := GFTileMapCacheBase.new()
	var current := GFTileMapCacheBase.new()
	previous.set_cell_data(Vector2i(0, 0), { "terrain": 1, "variant": "a" })
	current.set_cell_data(Vector2i(0, 0), { "terrain": 1, "variant": "b" })
	current.set_cell_data(Vector2i(1, 0), { "terrain": 2, "variant": "c" })

	var full_diff := current.diff_cells(previous)
	var terrain_diff := current.diff_cells(previous, &"terrain")

	assert_true(full_diff.has(Vector2i(0, 0)), "完整字典比较应识别字段变化。")
	assert_true(full_diff.has(Vector2i(1, 0)), "完整字典比较应识别新增格子。")
	assert_false(terrain_diff.has(Vector2i(0, 0)), "按指定字段比较时无关字段变化不应算差异。")
	assert_true(terrain_diff.has(Vector2i(1, 0)), "按指定字段比较仍应识别新增格子。")


func test_tile_map_cache_roundtrips_serialized_cell_keys() -> void:
	var cache := GFTileMapCacheBase.new()
	cache.set_cell_data(Vector2i(-2, 5), { "terrain": 3 })

	var restored := GFTileMapCacheBase.new()
	restored.from_dict(cache.to_dict())

	assert_true(restored.has_cell(Vector2i(-2, 5)), "序列化恢复后应保留格坐标。")
	assert_eq(restored.get_value(Vector2i(-2, 5), &"terrain"), 3, "序列化恢复后应保留格子字段。")
