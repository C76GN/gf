## 测试 GFGrid3DMath 的邻居、寻路、可达范围和台阶式表面移动。
extends GutTest


# --- 常量 ---

const GF_GRID_3D_MATH := preload("res://addons/gf/foundation/math/gf_grid_3d_math.gd")


# --- 测试 ---

func test_neighbors_respect_bounds_and_diagonal_option() -> void:
	var grid_size := Vector3i(3, 3, 3)

	assert_eq(GF_GRID_3D_MATH.get_neighbors(Vector3i(1, 1, 1), grid_size).size(), 6)
	assert_eq(GF_GRID_3D_MATH.get_neighbors(Vector3i(1, 1, 1), grid_size, true).size(), 26)
	assert_eq(GF_GRID_3D_MATH.get_neighbors(Vector3i.ZERO, grid_size).size(), 3)


func test_find_path_a_star_avoids_blocked_cell() -> void:
	var blocked := {
		Vector3i(1, 0, 0): true,
	}
	var path: Array[Vector3i] = GF_GRID_3D_MATH.find_path_a_star(
		Vector3i(3, 1, 2),
		Vector3i(0, 0, 0),
		Vector3i(2, 0, 0),
		func(cell: Vector3i) -> bool:
			return not blocked.has(cell)
	)

	assert_false(path.is_empty(), "A* 应能绕过阻挡格。")
	assert_eq(path.front(), Vector3i(0, 0, 0))
	assert_eq(path.back(), Vector3i(2, 0, 0))
	assert_false(path.has(Vector3i(1, 0, 0)))


func test_find_reachable_reports_costs_with_limit() -> void:
	var reachable: Dictionary = GF_GRID_3D_MATH.find_reachable(
		Vector3i(3, 3, 3),
		Vector3i(1, 1, 1),
		1.0,
		func(_cell: Vector3i) -> bool:
			return true
	)

	assert_eq(reachable.size(), 7)
	assert_eq(float(reachable.get(Vector3i(1, 1, 1))), 0.0)
	assert_eq(float(reachable.get(Vector3i(2, 1, 1))), 1.0)


func test_surface_neighbors_respect_step_limits() -> void:
	var walkable := {
		Vector3i(0, 1, 0): true,
		Vector3i(1, 2, 0): true,
		Vector3i(2, 3, 0): true,
	}

	var neighbors: Array[Vector3i] = GF_GRID_3D_MATH.get_surface_neighbors(
		Vector3i(0, 1, 0),
		Vector3i(3, 4, 1),
		func(cell: Vector3i) -> bool:
			return walkable.has(cell),
		1,
		1
	)

	assert_true(neighbors.has(Vector3i(1, 2, 0)))
	assert_false(neighbors.has(Vector3i(2, 3, 0)), "只应枚举一步水平移动范围内的表面邻居。")


func test_surface_path_can_climb_with_step_constraints() -> void:
	var walkable := {
		Vector3i(0, 0, 0): true,
		Vector3i(1, 1, 0): true,
		Vector3i(2, 1, 0): true,
	}
	var path: Array[Vector3i] = GF_GRID_3D_MATH.find_surface_path_a_star(
		Vector3i(3, 3, 1),
		Vector3i(0, 0, 0),
		Vector3i(2, 1, 0),
		func(cell: Vector3i) -> bool:
			return walkable.has(cell),
		1,
		1
	)

	assert_eq(path, [Vector3i(0, 0, 0), Vector3i(1, 1, 0), Vector3i(2, 1, 0)])
