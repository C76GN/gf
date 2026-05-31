## 测试 GFGraphMath 的 Dijkstra、A* 与距离图。
extends GutTest


# --- 常量 ---

const GF_GRAPH_MATH = preload("res://addons/gf/standard/foundation/math/gf_graph_math.gd")


# --- 测试 ---

func test_dijkstra_prefers_lowest_cost_path() -> void:
	var graph: Dictionary = {
		"A": ["B", "C"],
		"B": ["D"],
		"C": ["D"],
		"D": [],
	}
	var costs: Dictionary = {
		"A:B": 1.0,
		"B:D": 1.0,
		"A:C": 1.0,
		"C:D": 10.0,
	}

	var path: Array = GF_GRAPH_MATH.find_path_dijkstra(
		"A",
		"D",
		func(node: Variant) -> Array:
			return GFVariantData.get_option_array(graph, node, []),
		func(from_node: Variant, to_node: Variant) -> float:
			return GFVariantData.get_option_float(costs, "%s:%s" % [from_node, to_node], 1.0)
	)

	assert_eq(path, ["A", "B", "D"])


func test_astar_uses_custom_variant_nodes_and_heuristic() -> void:
	var graph: Dictionary = {
		Vector2i(0, 0): [Vector2i(1, 0), Vector2i(0, 1)],
		Vector2i(1, 0): [Vector2i(2, 0)],
		Vector2i(0, 1): [Vector2i(1, 1)],
		Vector2i(1, 1): [Vector2i(2, 0)],
		Vector2i(2, 0): [],
	}

	var path: Array = GF_GRAPH_MATH.find_path_a_star(
		Vector2i.ZERO,
		Vector2i(2, 0),
		func(node: Variant) -> Array:
			return GFVariantData.get_option_array(graph, node, []),
		Callable(),
		func(node: Variant, goal: Variant) -> float:
			var from_cell: Vector2i = _as_vector2i(node)
			var goal_cell: Vector2i = _as_vector2i(goal)
			return float(absi(goal_cell.x - from_cell.x) + absi(goal_cell.y - from_cell.y))
	)

	assert_eq(_array_vector2i(path, 0), Vector2i.ZERO)
	assert_eq(_array_vector2i(path, path.size() - 1), Vector2i(2, 0))
	assert_true(path.size() <= 3, "A* 应优先选择启发函数指向的短路径。")


func test_negative_step_cost_blocks_edges() -> void:
	var graph: Dictionary = {
		"A": ["B"],
		"B": ["C"],
		"C": [],
	}

	var path: Array = GF_GRAPH_MATH.find_path_dijkstra(
		"A",
		"C",
		func(node: Variant) -> Array:
			return GFVariantData.get_option_array(graph, node, []),
		func(_from_node: Variant, to_node: Variant) -> float:
			return -1.0 if to_node == "C" else 1.0
	)

	assert_true(path.is_empty(), "负数代价应视为不可通行。")


func test_distance_map_respects_max_cost() -> void:
	var graph: Dictionary = {
		"A": ["B", "C"],
		"B": ["D"],
		"C": ["D"],
		"D": [],
	}
	var distances: Dictionary = GF_GRAPH_MATH.build_distance_map(
		"A",
		func(node: Variant) -> Array:
			return GFVariantData.get_option_array(graph, node, []),
		Callable(),
		1.0
	)

	assert_true(distances.has("A"))
	assert_true(distances.has("B"))
	assert_true(distances.has("C"))
	assert_false(distances.has("D"), "超过 max_cost 的节点不应进入距离图。")


func _as_vector2i(value: Variant) -> Vector2i:
	if value is Vector2i:
		var cell: Vector2i = value
		return cell
	return Vector2i.ZERO


func _array_vector2i(values: Array, index: int) -> Vector2i:
	if index < 0 or index >= values.size():
		return Vector2i.ZERO
	return _as_vector2i(values[index])
