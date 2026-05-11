## GFGraphMath: 面向任意节点类型的纯图搜索算法。
##
## 节点可以是 Vector、StringName、Resource、对象引用或项目自定义值。
## 图结构由回调提供，框架只负责遍历、代价累计和路径重建。
class_name GFGraphMath
extends RefCounted


# --- 公共方法 ---

## 使用 Dijkstra 查找一条最低代价路径。
## @param start: 起点节点。
## @param goal: 终点节点。
## @param get_neighbors: 邻居回调，签名为 `func(node: Variant) -> Array`。
## @param get_step_cost: 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。
## @return 包含起点与终点的路径；无法到达时返回空数组。
static func find_path_dijkstra(
	start: Variant,
	goal: Variant,
	get_neighbors: Callable,
	get_step_cost: Callable = Callable()
) -> Array:
	return _find_path(start, goal, get_neighbors, get_step_cost, Callable())


## 使用 A* 查找一条低代价路径。
## @param start: 起点节点。
## @param goal: 终点节点。
## @param get_neighbors: 邻居回调，签名为 `func(node: Variant) -> Array`。
## @param get_step_cost: 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。
## @param heuristic: 可选启发回调，签名为 `func(node: Variant, goal: Variant) -> float`。
## @return 包含起点与终点的路径；无法到达时返回空数组。
static func find_path_a_star(
	start: Variant,
	goal: Variant,
	get_neighbors: Callable,
	get_step_cost: Callable = Callable(),
	heuristic: Callable = Callable()
) -> Array:
	return _find_path(start, goal, get_neighbors, get_step_cost, heuristic)


## 从起点生成距离图。
## @param start: 起点节点。
## @param get_neighbors: 邻居回调，签名为 `func(node: Variant) -> Array`。
## @param get_step_cost: 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。
## @param max_cost: 最大累计代价，超过后停止扩展。
## @return 字典，键为可达节点，值为从起点到该节点的最低代价。
static func build_distance_map(
	start: Variant,
	get_neighbors: Callable,
	get_step_cost: Callable = Callable(),
	max_cost: float = INF
) -> Dictionary:
	var distances: Dictionary = { start: 0.0 }
	if not get_neighbors.is_valid():
		return distances

	var frontier: Array = [start]
	while not frontier.is_empty():
		var current: Variant = _take_lowest_score_node(frontier, distances)
		var current_cost := float(distances.get(current, INF))
		if current_cost > max_cost:
			continue

		for next_node in _get_neighbors(current, get_neighbors):
			var move_cost := _get_step_cost(current, next_node, get_step_cost)
			if move_cost < 0.0:
				continue

			var next_cost := current_cost + move_cost
			if next_cost > max_cost or next_cost >= float(distances.get(next_node, INF)):
				continue

			distances[next_node] = next_cost
			if not frontier.has(next_node):
				frontier.append(next_node)

	return distances


## 查找指定代价内可达的节点。
## @param start: 起点节点。
## @param max_cost: 最大累计代价。
## @param get_neighbors: 邻居回调，签名为 `func(node: Variant) -> Array`。
## @param get_step_cost: 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。
## @return 字典，键为可达节点，值为从起点到该节点的最低代价。
static func find_reachable(
	start: Variant,
	max_cost: float,
	get_neighbors: Callable,
	get_step_cost: Callable = Callable()
) -> Dictionary:
	return build_distance_map(start, get_neighbors, get_step_cost, max_cost)


# --- 私有/辅助方法 ---

static func _find_path(
	start: Variant,
	goal: Variant,
	get_neighbors: Callable,
	get_step_cost: Callable,
	heuristic: Callable
) -> Array:
	if not get_neighbors.is_valid():
		return []
	if start == goal:
		return [start]

	var open_set: Array = [start]
	var open_lookup: Dictionary = { start: true }
	var closed: Dictionary = {}
	var came_from: Dictionary = {}
	var g_score: Dictionary = { start: 0.0 }
	var f_score: Dictionary = { start: _get_heuristic(start, goal, heuristic) }

	while not open_set.is_empty():
		var current: Variant = _take_lowest_score_node(open_set, f_score)
		open_lookup.erase(current)
		if current == goal:
			return _reconstruct_path(start, goal, came_from)

		closed[current] = true
		for next_node in _get_neighbors(current, get_neighbors):
			if closed.has(next_node):
				continue

			var move_cost := _get_step_cost(current, next_node, get_step_cost)
			if move_cost < 0.0:
				continue

			var tentative_score := float(g_score.get(current, INF)) + move_cost
			if tentative_score >= float(g_score.get(next_node, INF)):
				continue

			came_from[next_node] = current
			g_score[next_node] = tentative_score
			f_score[next_node] = tentative_score + _get_heuristic(next_node, goal, heuristic)
			if not open_lookup.has(next_node):
				open_set.append(next_node)
				open_lookup[next_node] = true

	return []


static func _reconstruct_path(start: Variant, goal: Variant, came_from: Dictionary) -> Array:
	var path: Array = [goal]
	var current: Variant = goal

	while current != start:
		if not came_from.has(current):
			return []

		current = came_from[current]
		path.push_front(current)

	return path


static func _take_lowest_score_node(nodes: Array, scores: Dictionary) -> Variant:
	var best_index := 0
	var best_score := float(scores.get(nodes[0], INF))
	for index: int in range(1, nodes.size()):
		var score := float(scores.get(nodes[index], INF))
		if score < best_score:
			best_index = index
			best_score = score

	var node: Variant = nodes[best_index]
	nodes.remove_at(best_index)
	return node


static func _get_neighbors(node: Variant, get_neighbors: Callable) -> Array:
	var raw_neighbors: Variant = get_neighbors.call(node)
	if typeof(raw_neighbors) != TYPE_ARRAY:
		return []

	return raw_neighbors as Array


static func _get_step_cost(from_node: Variant, to_node: Variant, get_step_cost: Callable) -> float:
	if get_step_cost.is_valid():
		return float(get_step_cost.call(from_node, to_node))

	return 1.0


static func _get_heuristic(node: Variant, goal: Variant, heuristic: Callable) -> float:
	if heuristic.is_valid():
		return maxf(0.0, float(heuristic.call(node, goal)))

	return 0.0
