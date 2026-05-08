## 测试 GFHexGridMath 的坐标转换、邻居、范围、视线、寻路与 Flow Field。
extends GutTest


# --- 常量 ---

const GF_HEX_GRID_MATH := preload("res://addons/gf/foundation/math/gf_hex_grid_math.gd")


# --- 测试 ---

func test_offset_cube_roundtrip_for_supported_layouts() -> void:
	var cell := Vector2i(3, 4)
	for layout: int in [
		GF_HEX_GRID_MATH.OffsetLayout.ODD_R,
		GF_HEX_GRID_MATH.OffsetLayout.EVEN_R,
		GF_HEX_GRID_MATH.OffsetLayout.ODD_Q,
		GF_HEX_GRID_MATH.OffsetLayout.EVEN_Q,
	]:
		var cube: Vector3i = GF_HEX_GRID_MATH.offset_to_cube(cell, layout)
		var roundtrip: Vector2i = GF_HEX_GRID_MATH.cube_to_offset(cube, layout)

		assert_eq(cube.x + cube.y + cube.z, 0, "cube 坐标三轴和应为 0。")
		assert_eq(roundtrip, cell, "offset/cube 转换应可往返。")


func test_pixel_roundtrip_pointy_and_flat() -> void:
	var cell := Vector2i(2, 3)
	var pointy_pixel: Vector2 = GF_HEX_GRID_MATH.offset_to_pixel(
		cell,
		24.0,
		GF_HEX_GRID_MATH.OffsetLayout.ODD_R,
		GF_HEX_GRID_MATH.HexOrientation.POINTY_TOP
	)
	var flat_pixel: Vector2 = GF_HEX_GRID_MATH.offset_to_pixel(
		cell,
		24.0,
		GF_HEX_GRID_MATH.OffsetLayout.ODD_Q,
		GF_HEX_GRID_MATH.HexOrientation.FLAT_TOP
	)

	assert_eq(
		GF_HEX_GRID_MATH.pixel_to_offset(
			pointy_pixel,
			24.0,
			GF_HEX_GRID_MATH.OffsetLayout.ODD_R,
			GF_HEX_GRID_MATH.HexOrientation.POINTY_TOP
		),
		cell,
		"pointy-top 像素转换应可往返。"
	)
	assert_eq(
		GF_HEX_GRID_MATH.pixel_to_offset(
			flat_pixel,
			24.0,
			GF_HEX_GRID_MATH.OffsetLayout.ODD_Q,
			GF_HEX_GRID_MATH.HexOrientation.FLAT_TOP
		),
		cell,
		"flat-top 像素转换应可往返。"
	)


func test_neighbors_and_distance_use_hex_topology() -> void:
	var neighbors: Array[Vector2i] = GF_HEX_GRID_MATH.get_neighbors(
		Vector2i(1, 1),
		Vector2i(4, 4),
		GF_HEX_GRID_MATH.OffsetLayout.ODD_R
	)

	assert_eq(neighbors.size(), 6, "内部六边形格子应有 6 个邻居。")
	assert_eq(
		GF_HEX_GRID_MATH.distance(
			Vector2i(0, 0),
			Vector2i(2, 1),
			GF_HEX_GRID_MATH.OffsetLayout.ODD_R
		),
		3,
		"六边形距离应按 cube 拓扑计算。"
	)


func test_range_and_ring_filter_bounds() -> void:
	var range_cells: Array[Vector2i] = GF_HEX_GRID_MATH.get_range(
		Vector2i(2, 2),
		1,
		Vector2i(5, 5),
		GF_HEX_GRID_MATH.OffsetLayout.ODD_R
	)
	var ring_cells: Array[Vector2i] = GF_HEX_GRID_MATH.get_ring(
		Vector2i.ZERO,
		1,
		Vector2i(2, 2),
		GF_HEX_GRID_MATH.OffsetLayout.ODD_R
	)

	assert_eq(range_cells.size(), 7, "半径 1 范围应包含中心和 6 个邻居。")
	assert_true(range_cells.has(Vector2i(2, 2)), "范围应包含中心。")
	assert_true(ring_cells.size() < 6, "边界附近的外环应被 grid_size 过滤。")
	assert_false(ring_cells.has(Vector2i(-1, 0)), "越界外环坐标不应进入结果。")


func test_line_of_sight_respects_blocking_cells() -> void:
	var line: Array[Vector2i] = GF_HEX_GRID_MATH.get_line(
		Vector2i(0, 0),
		Vector2i(3, 0),
		GF_HEX_GRID_MATH.OffsetLayout.ODD_R
	)
	var blocked := {
		line[1]: true,
	}

	assert_eq(line.front(), Vector2i.ZERO, "直线应从起点开始。")
	assert_eq(line.back(), Vector2i(3, 0), "直线应抵达终点。")
	assert_false(
		GF_HEX_GRID_MATH.has_line_of_sight(
			Vector2i(0, 0),
			Vector2i(3, 0),
			func(cell: Vector2i) -> bool:
				return blocked.has(cell),
			GF_HEX_GRID_MATH.OffsetLayout.ODD_R
		),
		"中间格阻挡时视线应失败。"
	)


func test_find_path_a_star_avoids_blocked_hex() -> void:
	var blocked := {
		Vector2i(1, 0): true,
	}
	var path: Array[Vector2i] = GF_HEX_GRID_MATH.find_path_a_star(
		Vector2i(4, 4),
		Vector2i.ZERO,
		Vector2i(2, 0),
		func(cell: Vector2i) -> bool:
			return not blocked.has(cell),
		GF_HEX_GRID_MATH.OffsetLayout.ODD_R
	)

	assert_false(path.is_empty(), "A* 应能绕过阻挡格。")
	assert_eq(path.front(), Vector2i.ZERO, "路径应从起点开始。")
	assert_eq(path.back(), Vector2i(2, 0), "路径应抵达终点。")
	assert_false(path.has(Vector2i(1, 0)), "路径不应穿过阻挡格。")


func test_flow_field_and_reachable_report_costs() -> void:
	var field: Dictionary = GF_HEX_GRID_MATH.build_flow_field(
		Vector2i(4, 4),
		[Vector2i(2, 0)],
		func(_cell: Vector2i) -> bool:
			return true,
		GF_HEX_GRID_MATH.OffsetLayout.ODD_R
	)
	var costs := field.get("costs", {}) as Dictionary
	var directions := field.get("directions", {}) as Dictionary
	var reachable: Dictionary = GF_HEX_GRID_MATH.find_reachable(
		Vector2i(4, 4),
		Vector2i.ZERO,
		1.0,
		func(_cell: Vector2i) -> bool:
			return true,
		GF_HEX_GRID_MATH.OffsetLayout.ODD_R
	)

	assert_eq(float(costs.get(Vector2i(2, 0))), 0.0, "目标格代价应为 0。")
	assert_ne(directions.get(Vector2i.ZERO), null, "Flow Field 应为可达格提供方向。")
	assert_true(reachable.has(Vector2i.ZERO), "可达结果应包含起点。")
	assert_true(reachable.size() <= 7, "移动代价 1 最多包含中心和一圈邻居。")
