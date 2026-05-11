## GFGrid3DMath: 3D 整数网格的纯算法工具。
##
## 提供边界判断、邻居枚举、A* 寻路、可达范围和台阶式表面邻居。
## 它不依赖 GridMap 或场景节点；可通行、代价和高度规则都由回调注入。
class_name GFGrid3DMath
extends RefCounted


# --- 常量 ---

const _ORTHOGONAL_DIRECTIONS: Array[Vector3i] = [
	Vector3i(1, 0, 0),
	Vector3i(-1, 0, 0),
	Vector3i(0, 1, 0),
	Vector3i(0, -1, 0),
	Vector3i(0, 0, 1),
	Vector3i(0, 0, -1),
]

const _SURFACE_DIRECTIONS: Array[Vector3i] = [
	Vector3i(1, 0, 0),
	Vector3i(-1, 0, 0),
	Vector3i(0, 0, 1),
	Vector3i(0, 0, -1),
]


# --- 公共方法 ---

## 判断格子是否在 3D 网格范围内。
## @param cell: 待检测格子。
## @param grid_size: 网格尺寸，三个轴都必须大于 0。
## @return 在范围内时返回 true。
static func is_in_bounds(cell: Vector3i, grid_size: Vector3i) -> bool:
	return (
		grid_size.x > 0
		and grid_size.y > 0
		and grid_size.z > 0
		and cell.x >= 0
		and cell.y >= 0
		and cell.z >= 0
		and cell.x < grid_size.x
		and cell.y < grid_size.y
		and cell.z < grid_size.z
	)


## 获取 3D 网格邻居。
## @param cell: 中心格子。
## @param grid_size: 网格尺寸。
## @param allow_diagonal: 是否包含 26 邻域；否则只包含 6 个正交邻居。
## @return 边界内邻居数组。
static func get_neighbors(
	cell: Vector3i,
	grid_size: Vector3i,
	allow_diagonal: bool = false
) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	for direction: Vector3i in _get_directions(allow_diagonal):
		var next_cell := cell + direction
		if is_in_bounds(next_cell, grid_size):
			result.append(next_cell)

	return result


## 获取台阶式表面移动邻居。
## @param cell: 当前站立格。
## @param grid_size: 网格尺寸。
## @param is_walkable: 可站立回调，签名为 `func(cell: Vector3i) -> bool`。
## @param max_step_up: 单步最多上升高度。
## @param max_step_down: 单步最多下降高度。
## @param horizontal_directions: 可选水平移动方向；为空时使用 X/Z 四方向。
## @return 可站立的相邻表面格。
static func get_surface_neighbors(
	cell: Vector3i,
	grid_size: Vector3i,
	is_walkable: Callable,
	max_step_up: int = 1,
	max_step_down: int = 1,
	horizontal_directions: Array[Vector3i] = []
) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	if not is_walkable.is_valid():
		return result

	var directions: Array[Vector3i] = horizontal_directions if not horizontal_directions.is_empty() else _SURFACE_DIRECTIONS
	for direction: Vector3i in directions:
		var base_cell := Vector3i(cell.x + direction.x, cell.y, cell.z + direction.z)
		for y_offset: int in range(maxi(max_step_up, 0), -maxi(max_step_down, 0) - 1, -1):
			var candidate := Vector3i(base_cell.x, base_cell.y + y_offset, base_cell.z)
			if not is_in_bounds(candidate, grid_size):
				continue
			if bool(is_walkable.call(candidate)):
				result.append(candidate)
				break

	return result


## 使用 A* 查找 3D 网格路径。
## @param grid_size: 网格尺寸。
## @param start: 起点格子。
## @param goal: 终点格子。
## @param is_walkable: 可通行回调，签名为 `func(cell: Vector3i) -> bool`。
## @param allow_diagonal: 是否允许 26 邻域移动。
## @param step_cost: 可选代价回调，签名为 `func(from: Vector3i, to: Vector3i) -> float`；返回负数表示不可通行。
## @param heuristic: 启发函数名称，支持 `manhattan`、`chebyshev`、`euclidean`。
## @return 包含起点与终点的路径；无法到达时返回空数组。
static func find_path_a_star(
	grid_size: Vector3i,
	start: Vector3i,
	goal: Vector3i,
	is_walkable: Callable,
	allow_diagonal: bool = false,
	step_cost: Callable = Callable(),
	heuristic: StringName = &"manhattan"
) -> Array[Vector3i]:
	if (
		not is_in_bounds(start, grid_size)
		or not is_in_bounds(goal, grid_size)
		or not is_walkable.is_valid()
	):
		return []
	if start == goal:
		return [start]
	if not bool(is_walkable.call(goal)):
		return []

	var open_set: Array[Vector3i] = [start]
	var open_lookup: Dictionary = { start: true }
	var closed: Dictionary = {}
	var came_from: Dictionary = {}
	var g_score: Dictionary = { start: 0.0 }
	var f_score: Dictionary = { start: _heuristic_distance(start, goal, heuristic, allow_diagonal) }

	while not open_set.is_empty():
		var current := _take_lowest_score_cell(open_set, f_score)
		open_lookup.erase(current)
		if current == goal:
			return _reconstruct_path(start, goal, came_from)

		closed[current] = true
		for next_cell: Vector3i in get_neighbors(current, grid_size, allow_diagonal):
			if closed.has(next_cell) or not bool(is_walkable.call(next_cell)):
				continue

			var move_cost := _get_step_cost(current, next_cell, step_cost)
			if move_cost < 0.0:
				continue

			var tentative_score := float(g_score.get(current, INF)) + move_cost
			if tentative_score >= float(g_score.get(next_cell, INF)):
				continue

			came_from[next_cell] = current
			g_score[next_cell] = tentative_score
			f_score[next_cell] = tentative_score + _heuristic_distance(next_cell, goal, heuristic, allow_diagonal)
			if not open_lookup.has(next_cell):
				open_set.append(next_cell)
				open_lookup[next_cell] = true

	return []


## 查找指定代价内可达的 3D 网格格子。
## @param grid_size: 网格尺寸。
## @param start: 起点格子。
## @param max_cost: 最大累计代价。
## @param is_walkable: 可通行回调，签名为 `func(cell: Vector3i) -> bool`。
## @param allow_diagonal: 是否允许 26 邻域移动。
## @param step_cost: 可选代价回调，签名为 `func(from: Vector3i, to: Vector3i) -> float`；返回负数表示不可通行。
## @return 字典，键为可达格子，值为从起点到该格子的最低代价。
static func find_reachable(
	grid_size: Vector3i,
	start: Vector3i,
	max_cost: float,
	is_walkable: Callable,
	allow_diagonal: bool = false,
	step_cost: Callable = Callable()
) -> Dictionary:
	var costs: Dictionary = {}
	if not is_in_bounds(start, grid_size) or not is_walkable.is_valid() or not bool(is_walkable.call(start)):
		return costs

	costs[start] = 0.0
	var frontier: Array[Vector3i] = [start]
	while not frontier.is_empty():
		var current := _take_lowest_score_cell(frontier, costs)
		for next_cell: Vector3i in get_neighbors(current, grid_size, allow_diagonal):
			if not bool(is_walkable.call(next_cell)):
				continue

			var move_cost := _get_step_cost(current, next_cell, step_cost)
			if move_cost < 0.0:
				continue

			var next_cost := float(costs[current]) + move_cost
			if next_cost > max_cost or next_cost >= float(costs.get(next_cell, INF)):
				continue

			costs[next_cell] = next_cost
			if not frontier.has(next_cell):
				frontier.append(next_cell)

	return costs


## 使用台阶式表面邻居查找路径。
## @param grid_size: 网格尺寸。
## @param start: 起点站立格。
## @param goal: 终点站立格。
## @param is_walkable: 可站立回调，签名为 `func(cell: Vector3i) -> bool`。
## @param max_step_up: 单步最多上升高度。
## @param max_step_down: 单步最多下降高度。
## @param step_cost: 可选代价回调，签名为 `func(from: Vector3i, to: Vector3i) -> float`；返回负数表示不可通行。
## @param heuristic: 启发函数名称，支持 `manhattan`、`chebyshev`、`euclidean`。
## @return 包含起点与终点的路径；无法到达时返回空数组。
static func find_surface_path_a_star(
	grid_size: Vector3i,
	start: Vector3i,
	goal: Vector3i,
	is_walkable: Callable,
	max_step_up: int = 1,
	max_step_down: int = 1,
	step_cost: Callable = Callable(),
	heuristic: StringName = &"manhattan"
) -> Array[Vector3i]:
	if (
		not is_in_bounds(start, grid_size)
		or not is_in_bounds(goal, grid_size)
		or not is_walkable.is_valid()
		or not bool(is_walkable.call(start))
		or not bool(is_walkable.call(goal))
	):
		return []
	if start == goal:
		return [start]

	var open_set: Array[Vector3i] = [start]
	var open_lookup: Dictionary = { start: true }
	var closed: Dictionary = {}
	var came_from: Dictionary = {}
	var g_score: Dictionary = { start: 0.0 }
	var f_score: Dictionary = { start: _heuristic_distance(start, goal, heuristic, false) }

	while not open_set.is_empty():
		var current := _take_lowest_score_cell(open_set, f_score)
		open_lookup.erase(current)
		if current == goal:
			return _reconstruct_path(start, goal, came_from)

		closed[current] = true
		for next_cell: Vector3i in get_surface_neighbors(
			current,
			grid_size,
			is_walkable,
			max_step_up,
			max_step_down
		):
			if closed.has(next_cell):
				continue

			var move_cost := _get_step_cost(current, next_cell, step_cost)
			if move_cost < 0.0:
				continue

			var tentative_score := float(g_score.get(current, INF)) + move_cost
			if tentative_score >= float(g_score.get(next_cell, INF)):
				continue

			came_from[next_cell] = current
			g_score[next_cell] = tentative_score
			f_score[next_cell] = tentative_score + _heuristic_distance(next_cell, goal, heuristic, false)
			if not open_lookup.has(next_cell):
				open_set.append(next_cell)
				open_lookup[next_cell] = true

	return []


# --- 私有/辅助方法 ---

static func _get_directions(allow_diagonal: bool) -> Array[Vector3i]:
	if not allow_diagonal:
		return _ORTHOGONAL_DIRECTIONS

	var directions: Array[Vector3i] = []
	for x: int in range(-1, 2):
		for y: int in range(-1, 2):
			for z: int in range(-1, 2):
				if x == 0 and y == 0 and z == 0:
					continue

				directions.append(Vector3i(x, y, z))

	return directions


static func _reconstruct_path(start: Vector3i, goal: Vector3i, came_from: Dictionary) -> Array[Vector3i]:
	var path: Array[Vector3i] = [goal]
	var current := goal

	while current != start:
		if not came_from.has(current):
			return []

		current = came_from[current]
		path.push_front(current)

	return path


static func _take_lowest_score_cell(cells: Array[Vector3i], scores: Dictionary) -> Vector3i:
	var best_index := 0
	var best_score := float(scores.get(cells[0], INF))
	for index: int in range(1, cells.size()):
		var score := float(scores.get(cells[index], INF))
		if score < best_score:
			best_index = index
			best_score = score

	var cell := cells[best_index]
	cells.remove_at(best_index)
	return cell


static func _heuristic_distance(
	from_cell: Vector3i,
	to_cell: Vector3i,
	heuristic: StringName,
	allow_diagonal: bool
) -> float:
	var dx := absi(to_cell.x - from_cell.x)
	var dy := absi(to_cell.y - from_cell.y)
	var dz := absi(to_cell.z - from_cell.z)
	match heuristic:
		&"chebyshev":
			return float(maxi(dx, maxi(dy, dz)))
		&"euclidean":
			return sqrt(float(dx * dx + dy * dy + dz * dz))
		_:
			return float(maxi(dx, maxi(dy, dz))) if allow_diagonal and heuristic == &"auto" else float(dx + dy + dz)


static func _get_step_cost(from_cell: Vector3i, to_cell: Vector3i, step_cost: Callable) -> float:
	if step_cost.is_valid():
		return float(step_cost.call(from_cell, to_cell))

	var delta := to_cell - from_cell
	return sqrt(float(delta.x * delta.x + delta.y * delta.y + delta.z * delta.z))
