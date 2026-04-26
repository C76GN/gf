## 测试 GFGridMath 的索引转换、邻居、泛洪、BFS 与两折连线判断。
extends GutTest


const GF_GRID_MATH := preload("res://addons/gf/foundation/math/gf_grid_math.gd")


# --- 测试 ---

func test_cell_index_roundtrip() -> void:
	var cell := Vector2i(2, 3)
	var index: int = GF_GRID_MATH.cell_to_index(cell, 5)

	assert_eq(index, 17, "二维坐标应正确转换为一维索引。")
	assert_eq(GF_GRID_MATH.index_to_cell(index, 5), cell, "一维索引应正确还原为二维坐标。")


func test_get_neighbors_filters_bounds() -> void:
	var neighbors: Array[Vector2i] = GF_GRID_MATH.get_neighbors(Vector2i.ZERO, Vector2i(3, 3))

	assert_eq(neighbors.size(), 2, "左上角正交邻居应只有 2 个。")
	assert_true(neighbors.has(Vector2i.RIGHT), "左上角应包含右侧邻居。")
	assert_true(neighbors.has(Vector2i.DOWN), "左上角应包含下方邻居。")


func test_flood_fill_returns_connected_matching_cells() -> void:
	var filled: Array[Vector2i] = GF_GRID_MATH.flood_fill(
		Vector2i(4, 3),
		Vector2i.ZERO,
		func(cell: Vector2i) -> bool:
			return cell.x < 2
	)

	assert_eq(filled.size(), 6, "x < 2 的两列格子应全部连通。")
	assert_true(filled.has(Vector2i(1, 2)), "泛洪结果应包含匹配区域内的底部格子。")
	assert_false(filled.has(Vector2i(2, 0)), "泛洪结果不应包含不匹配格子。")


func test_find_path_bfs_avoids_blocked_cells() -> void:
	var blocked := {
		Vector2i(1, 0): true,
		Vector2i(1, 1): true,
	}
	var path: Array[Vector2i] = GF_GRID_MATH.find_path_bfs(
		Vector2i(3, 3),
		Vector2i.ZERO,
		Vector2i(2, 0),
		func(cell: Vector2i) -> bool:
			return not blocked.has(cell)
	)

	assert_false(path.is_empty(), "BFS 应能绕过障碍找到路径。")
	assert_eq(path.front(), Vector2i.ZERO, "路径应从起点开始。")
	assert_eq(path.back(), Vector2i(2, 0), "路径应抵达终点。")
	assert_false(path.has(Vector2i(1, 0)), "路径不应穿过障碍。")


func test_can_connect_with_max_turns_uses_outer_border() -> void:
	var blocked := {
		Vector2i(1, 0): true,
	}
	var can_connect: bool = GF_GRID_MATH.can_connect_with_max_turns(
		Vector2i(3, 1),
		Vector2i(0, 0),
		Vector2i(2, 0),
		func(cell: Vector2i) -> bool:
			return not blocked.has(cell),
		2,
		true
	)

	assert_true(can_connect, "允许外圈虚拟空格时，应能绕过中间障碍完成两折连线。")


func test_can_connect_with_max_turns_rejects_excess_turns() -> void:
	var blocked := {
		Vector2i(1, 0): true,
	}
	var can_connect: bool = GF_GRID_MATH.can_connect_with_max_turns(
		Vector2i(3, 1),
		Vector2i(0, 0),
		Vector2i(2, 0),
		func(cell: Vector2i) -> bool:
			return not blocked.has(cell),
		1,
		true
	)

	assert_false(can_connect, "只允许一次转折时，绕过中间障碍的外圈路径应失败。")
