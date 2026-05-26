## 测试 GFGridPlaneMapper3D 的 3D 平面映射和邻域采样。
extends GutTest


# --- 常量 ---

const GF_GRID_PLANE_MAPPER_3D := preload("res://addons/gf/standard/foundation/math/gf_grid_plane_mapper_3d.gd")
const GF_TILE_RULE_SET := preload("res://addons/gf/standard/foundation/math/gf_tile_rule_set.gd")


# --- 测试 ---

func test_map_cell_roundtrips_for_axis_normals() -> void:
	var origin := Vector3i(10, 5, -3)
	var normals: Array[Vector3i] = [
		Vector3i(1, 0, 0),
		Vector3i(-1, 0, 0),
		Vector3i(0, 1, 0),
		Vector3i(0, -1, 0),
		Vector3i(0, 0, 1),
		Vector3i(0, 0, -1),
	]

	for normal: Vector3i in normals:
		var cell := GF_GRID_PLANE_MAPPER_3D.map_plane_to_cell(Vector2i(2, -3), origin, normal, 4)
		assert_eq(GF_GRID_PLANE_MAPPER_3D.map_cell_to_plane(cell, origin, normal), Vector2i(2, -3))
		assert_eq(GF_GRID_PLANE_MAPPER_3D.get_cell_depth(cell, origin, normal), 4)


func test_get_neighbor_cells_uses_plane_offsets() -> void:
	var neighbors := GF_GRID_PLANE_MAPPER_3D.get_neighbor_cells(Vector3i.ZERO, Vector3i(0, 1, 0))

	assert_eq(neighbors.size(), 4)
	assert_true(neighbors.has(Vector3i(0, 0, 1)))
	assert_true(neighbors.has(Vector3i(1, 0, 0)))
	assert_true(neighbors.has(Vector3i(0, 0, -1)))
	assert_true(neighbors.has(Vector3i(-1, 0, 0)))


func test_sample_neighbor_values_can_feed_tile_rule_set() -> void:
	var values := {
		Vector3i(0, 0, 1): 1,
		Vector3i(1, 0, 0): 0,
		Vector3i(0, 0, -1): 1,
		Vector3i(-1, 0, 0): 0,
	}
	var rules := GF_TILE_RULE_SET.new()
	rules.default_result = &"none"
	rules.register_rule([1, 0, 1, 0], &"corridor")

	var sampled := GF_GRID_PLANE_MAPPER_3D.sample_neighbor_values(
		Vector3i.ZERO,
		Vector3i(0, 1, 0),
		func(cell: Vector3i) -> Variant:
			return values.get(cell, -1)
	)

	assert_eq(sampled, [1, 0, 1, 0])
	assert_eq(rules.resolve(sampled), &"corridor")


func test_invalid_normal_returns_safe_defaults() -> void:
	assert_false(GF_GRID_PLANE_MAPPER_3D.is_axis_aligned_normal(Vector3i(1, 1, 0)))
	assert_eq(GF_GRID_PLANE_MAPPER_3D.normalize_axis_normal(Vector3i(1, 1, 0)), Vector3i.ZERO)
	assert_eq(
		GF_GRID_PLANE_MAPPER_3D.get_neighbor_cells(Vector3i.ZERO, Vector3i(1, 1, 0)),
		[]
	)
