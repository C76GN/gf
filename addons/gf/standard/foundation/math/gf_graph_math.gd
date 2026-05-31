## GFGraphMath: 面向任意节点类型的纯图搜索算法。
##
## 节点可以是 Vector、StringName、Resource、对象引用或项目自定义值。
## 图结构由回调提供，框架只负责遍历、代价累计和路径重建。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFGraphMath
extends RefCounted


# --- 公共方法 ---

## 使用 Dijkstra 查找一条最低代价路径。
## [br]
## @api public
## [br]
## @param start: 起点节点。
## [br]
## @schema start: Variant graph node identity.
## [br]
## @param goal: 终点节点。
## [br]
## @schema goal: Variant graph node identity.
## [br]
## @param get_neighbors: 邻居回调，签名为 `func(node: Variant) -> Array`。
## [br]
## @param get_step_cost: 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。
## [br]
## @return 包含起点与终点的路径；无法到达时返回空数组。
## [br]
## @schema return: Array graph node path from start to goal.
static func find_path_dijkstra(
	start: Variant,
	goal: Variant,
	get_neighbors: Callable,
	get_step_cost: Callable = Callable()
) -> Array[Variant]:
	return _find_path(start, goal, get_neighbors, get_step_cost, Callable())


## 使用 A* 查找一条低代价路径。
## [br]
## @api public
## [br]
## @param start: 起点节点。
## [br]
## @schema start: Variant graph node identity.
## [br]
## @param goal: 终点节点。
## [br]
## @schema goal: Variant graph node identity.
## [br]
## @param get_neighbors: 邻居回调，签名为 `func(node: Variant) -> Array`。
## [br]
## @param get_step_cost: 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。
## [br]
## @param heuristic: 可选启发回调，签名为 `func(node: Variant, goal: Variant) -> float`。
## [br]
## @return 包含起点与终点的路径；无法到达时返回空数组。
## [br]
## @schema return: Array graph node path from start to goal.
static func find_path_a_star(
	start: Variant,
	goal: Variant,
	get_neighbors: Callable,
	get_step_cost: Callable = Callable(),
	heuristic: Callable = Callable()
) -> Array[Variant]:
	return _find_path(start, goal, get_neighbors, get_step_cost, heuristic)


## 从起点生成距离图。
## [br]
## @api public
## [br]
## @param start: 起点节点。
## [br]
## @schema start: Variant graph node identity.
## [br]
## @param get_neighbors: 邻居回调，签名为 `func(node: Variant) -> Array`。
## [br]
## @param get_step_cost: 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。
## [br]
## @param max_cost: 最大累计代价，超过后停止扩展。
## [br]
## @return 字典，键为可达节点，值为从起点到该节点的最低代价。
## [br]
## @schema return: Dictionary mapping reachable graph nodes to lowest float costs.
static func build_distance_map(
	start: Variant,
	get_neighbors: Callable,
	get_step_cost: Callable = Callable(),
	max_cost: float = INF
) -> Dictionary:
	var distances: Dictionary = { start: 0.0 }
	if not get_neighbors.is_valid():
		return distances

	var frontier: Array[Dictionary] = []
	_heap_push_node(frontier, start, 0.0)
	while not frontier.is_empty():
		var current_entry: Dictionary = _heap_pop_node(frontier)
		var current: Variant = GFVariantData.get_option_value(current_entry, "node")
		var current_cost: float = GFVariantData.get_option_float(distances, current, INF)
		if _get_entry_priority(current_entry) > current_cost:
			continue
		if current_cost > max_cost:
			continue

		for next_node: Variant in _get_neighbors(current, get_neighbors):
			var move_cost: float = _get_step_cost(current, next_node, get_step_cost)
			if move_cost < 0.0:
				continue

			var next_cost: float = current_cost + move_cost
			if next_cost > max_cost or next_cost >= GFVariantData.get_option_float(distances, next_node, INF):
				continue

			distances[next_node] = next_cost
			_heap_push_node(frontier, next_node, next_cost)

	return distances


## 查找指定代价内可达的节点。
## [br]
## @api public
## [br]
## @param start: 起点节点。
## [br]
## @schema start: Variant graph node identity.
## [br]
## @param max_cost: 最大累计代价。
## [br]
## @param get_neighbors: 邻居回调，签名为 `func(node: Variant) -> Array`。
## [br]
## @param get_step_cost: 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。
## [br]
## @return 字典，键为可达节点，值为从起点到该节点的最低代价。
## [br]
## @schema return: Dictionary mapping reachable graph nodes to lowest float costs.
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

	var open_heap: Array[Dictionary] = []
	var closed: Dictionary = {}
	var came_from: Dictionary = {}
	var g_score: Dictionary = { start: 0.0 }
	var f_score: Dictionary = { start: _get_heuristic(start, goal, heuristic) }
	_heap_push_node(open_heap, start, GFVariantData.to_float(f_score[start], INF))

	while not open_heap.is_empty():
		var current_entry: Dictionary = _heap_pop_node(open_heap)
		var current: Variant = GFVariantData.get_option_value(current_entry, "node")
		if closed.has(current):
			continue
		if _get_entry_priority(current_entry) > GFVariantData.get_option_float(f_score, current, INF):
			continue
		if current == goal:
			return _reconstruct_path(start, goal, came_from)

		closed[current] = true
		for next_node: Variant in _get_neighbors(current, get_neighbors):
			if closed.has(next_node):
				continue

			var move_cost: float = _get_step_cost(current, next_node, get_step_cost)
			if move_cost < 0.0:
				continue

			var tentative_score: float = GFVariantData.get_option_float(g_score, current, INF) + move_cost
			if tentative_score >= GFVariantData.get_option_float(g_score, next_node, INF):
				continue

			came_from[next_node] = current
			g_score[next_node] = tentative_score
			f_score[next_node] = tentative_score + _get_heuristic(next_node, goal, heuristic)
			_heap_push_node(open_heap, next_node, GFVariantData.to_float(f_score[next_node], INF))

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
	var best_index: int = 0
	var best_score: float = GFVariantData.get_option_float(scores, nodes[0], INF)
	for index: int in range(1, nodes.size()):
		var score: float = GFVariantData.get_option_float(scores, nodes[index], INF)
		if score < best_score:
			best_index = index
			best_score = score

	var node: Variant = nodes[best_index]
	nodes.remove_at(best_index)
	return node


static func _heap_push_node(heap: Array[Dictionary], node: Variant, priority: float) -> void:
	heap.append({
		"node": node,
		"priority": priority,
	})
	var index: int = heap.size() - 1
	while index > 0:
		var parent_index: int = (index - 1) >> 1
		if _get_entry_priority(heap[parent_index]) <= priority:
			break
		var parent_entry: Dictionary = heap[parent_index]
		heap[parent_index] = heap[index]
		heap[index] = parent_entry
		index = parent_index


static func _heap_pop_node(heap: Array[Dictionary]) -> Dictionary:
	if heap.is_empty():
		return {}

	var result: Dictionary = heap[0]
	var last_entry: Dictionary = GFVariantData.as_dictionary(heap.pop_back())
	if heap.is_empty():
		return result

	heap[0] = last_entry
	var index: int = 0
	while true:
		var left_index: int = index * 2 + 1
		var right_index: int = left_index + 1
		var best_index: int = index
		if (
			left_index < heap.size()
			and _get_entry_priority(heap[left_index]) < _get_entry_priority(heap[best_index])
		):
			best_index = left_index
		if (
			right_index < heap.size()
			and _get_entry_priority(heap[right_index]) < _get_entry_priority(heap[best_index])
		):
			best_index = right_index
		if best_index == index:
			break

		var best_entry: Dictionary = heap[best_index]
		heap[best_index] = heap[index]
		heap[index] = best_entry
		index = best_index
	return result


static func _get_neighbors(node: Variant, get_neighbors: Callable) -> Array:
	var raw_neighbors: Variant = get_neighbors.call(node)
	if typeof(raw_neighbors) != TYPE_ARRAY:
		return []

	return GFVariantData.as_array(raw_neighbors)


static func _get_step_cost(from_node: Variant, to_node: Variant, get_step_cost: Callable) -> float:
	if get_step_cost.is_valid():
		return GFVariantData.to_float(get_step_cost.call(from_node, to_node), -1.0)

	return 1.0


static func _get_heuristic(node: Variant, goal: Variant, heuristic: Callable) -> float:
	if heuristic.is_valid():
		return maxf(0.0, GFVariantData.to_float(heuristic.call(node, goal), 0.0))

	return 0.0


static func _get_entry_priority(entry: Dictionary, fallback: float = INF) -> float:
	return GFVariantData.get_option_float(entry, "priority", fallback)
