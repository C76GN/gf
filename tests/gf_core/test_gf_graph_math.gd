## 测试 GFGraphMath 的 Dijkstra、A* 与距离图。
extends GutTest


# --- 常量 ---

const GF_GRAPH_MATH := preload("res://addons/gf/foundation/math/gf_graph_math.gd")


# --- 测试 ---

func test_dijkstra_prefers_lowest_cost_path() -> void:
	var graph := {
		"A": ["B", "C"],
		"B": ["D"],
		"C": ["D"],
		"D": [],
	}
	var costs := {
		"A:B": 1.0,
		"B:D": 1.0,
		"A:C": 1.0,
		"C:D": 10.0,
	}

	var path := GF_GRAPH_MATH.find_path_dijkstra(
		"A",
		"D",
		func(node: Variant) -> Array:
			return graph.get(node, []),
		func(from_node: Variant, to_node: Variant) -> float:
			return float(costs.get("%s:%s" % [from_node, to_node], 1.0))
	)

	assert_eq(path, ["A", "B", "D"])


func test_astar_uses_custom_variant_nodes_and_heuristic() -> void:
	var graph := {
		Vector2i(0, 0): [Vector2i(1, 0), Vector2i(0, 1)],
		Vector2i(1, 0): [Vector2i(2, 0)],
		Vector2i(0, 1): [Vector2i(1, 1)],
		Vector2i(1, 1): [Vector2i(2, 0)],
		Vector2i(2, 0): [],
	}

	var path := GF_GRAPH_MATH.find_path_a_star(
		Vector2i.ZERO,
		Vector2i(2, 0),
		func(node: Variant) -> Array:
			return graph.get(node, []),
		Callable(),
		func(node: Variant, goal: Variant) -> float:
			var from_cell: Vector2i = node
			var goal_cell: Vector2i = goal
			return float(absi(goal_cell.x - from_cell.x) + absi(goal_cell.y - from_cell.y))
	)

	assert_eq(path.front(), Vector2i.ZERO)
	assert_eq(path.back(), Vector2i(2, 0))
	assert_true(path.size() <= 3, "A* 应优先选择启发函数指向的短路径。")


func test_negative_step_cost_blocks_edges() -> void:
	var graph := {
		"A": ["B"],
		"B": ["C"],
		"C": [],
	}

	var path := GF_GRAPH_MATH.find_path_dijkstra(
		"A",
		"C",
		func(node: Variant) -> Array:
			return graph.get(node, []),
		func(_from_node: Variant, to_node: Variant) -> float:
			return -1.0 if to_node == "C" else 1.0
	)

	assert_true(path.is_empty(), "负数代价应视为不可通行。")


func test_distance_map_respects_max_cost() -> void:
	var graph := {
		"A": ["B", "C"],
		"B": ["D"],
		"C": ["D"],
		"D": [],
	}
	var distances: Dictionary = GF_GRAPH_MATH.build_distance_map(
		"A",
		func(node: Variant) -> Array:
			return graph.get(node, []),
		Callable(),
		1.0
	)

	assert_true(distances.has("A"))
	assert_true(distances.has("B"))
	assert_true(distances.has("C"))
	assert_false(distances.has("D"), "超过 max_cost 的节点不应进入距离图。")
