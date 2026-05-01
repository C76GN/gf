## 测试 GFSpatialHash3D 的插入、更新、移除和范围查询。
extends GutTest


# --- 常量 ---

const GFSpatialHash3DBase = preload("res://addons/gf/foundation/math/gf_spatial_hash_3d.gd")


# --- 测试方法 ---

## 验证 AABB 查询只返回相交实体。
func test_query_aabb_returns_intersecting_entities() -> void:
	var spatial_hash := GFSpatialHash3DBase.new(2.0)
	spatial_hash.insert("near", AABB(Vector3.ZERO, Vector3.ONE))
	spatial_hash.insert("far", AABB(Vector3(8.0, 0.0, 0.0), Vector3.ONE))

	var result := spatial_hash.query_aabb(AABB(Vector3(-1.0, -1.0, -1.0), Vector3(3.0, 3.0, 3.0)))

	assert_true(result.has("near"), "查询范围应包含相交实体。")
	assert_false(result.has("far"), "查询范围不应包含未相交实体。")


## 验证更新实体会刷新桶索引。
func test_update_moves_entity_between_buckets() -> void:
	var spatial_hash := GFSpatialHash3DBase.new(2.0)
	spatial_hash.insert("unit", AABB(Vector3.ZERO, Vector3.ONE))

	spatial_hash.update("unit", AABB(Vector3(6.0, 0.0, 0.0), Vector3.ONE))

	assert_false(spatial_hash.query_aabb(AABB(Vector3.ZERO, Vector3.ONE)).has("unit"), "旧范围不应再查询到实体。")
	assert_true(spatial_hash.query_aabb(AABB(Vector3(5.5, -1.0, -1.0), Vector3(3.0, 3.0, 3.0))).has("unit"), "新范围应查询到实体。")


## 验证半径查询会按 AABB 与球体相交做二次过滤。
func test_query_radius_filters_candidates() -> void:
	var spatial_hash := GFSpatialHash3DBase.new(4.0)
	spatial_hash.insert("inside", AABB(Vector3(1.0, 0.0, 0.0), Vector3.ONE))
	spatial_hash.insert("outside", AABB(Vector3(5.0, 0.0, 0.0), Vector3.ONE))

	var result := spatial_hash.query_radius(Vector3.ZERO, 2.5)

	assert_true(result.has("inside"), "半径内实体应被返回。")
	assert_false(result.has("outside"), "半径外实体应被过滤。")


## 验证移除实体会同步更新数量和查询结果。
func test_remove_erases_entity() -> void:
	var spatial_hash := GFSpatialHash3DBase.new(2.0)
	spatial_hash.insert("unit", AABB(Vector3.ZERO, Vector3.ONE))
	spatial_hash.remove("unit")

	assert_eq(spatial_hash.get_entity_count(), 0, "移除后实体数量应为 0。")
	assert_false(spatial_hash.has_entity("unit"), "移除后实体不应存在。")
