## GFGridMath: 网格类小游戏的纯算法工具。
##
## 提供一维索引与二维格坐标转换、邻居枚举、泛洪搜索、BFS 路径查找
## 以及连连看类“两折连线”判断。它不依赖 GFArchitecture，可直接在
## Model、System、Controller 或测试中静态调用。
class_name GFGridMath
extends RefCounted


# --- 常量 ---

const _ORTHOGONAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i.LEFT,
	Vector2i.DOWN,
	Vector2i.UP,
]

const _DIAGONAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(-1, -1),
]


# --- 公共方法 ---

## 将二维格坐标转换为一维索引。
## @param cell: 二维格坐标。
## @param width: 网格宽度。
## @return 成功时返回一维索引；宽度无效时返回 -1。
static func cell_to_index(cell: Vector2i, width: int) -> int:
	if width <= 0:
		return -1

	return cell.y * width + cell.x


## 将一维索引转换为二维格坐标。
## @param index: 一维索引。
## @param width: 网格宽度。
## @return 成功时返回二维格坐标；参数无效时返回 Vector2i(-1, -1)。
static func index_to_cell(index: int, width: int) -> Vector2i:
	if index < 0 or width <= 0:
		return Vector2i(-1, -1)

	return Vector2i(index % width, int(index / width))


## 判断格坐标是否位于网格范围内。
## @param cell: 二维格坐标。
## @param grid_size: 网格尺寸。
## @return 在范围内返回 true。
static func is_in_bounds(cell: Vector2i, grid_size: Vector2i) -> bool:
	return (
		grid_size.x > 0
		and grid_size.y > 0
		and cell.x >= 0
		and cell.y >= 0
		and cell.x < grid_size.x
		and cell.y < grid_size.y
	)


## 获取指定格子的邻居。
## @param cell: 中心格子。
## @param grid_size: 网格尺寸。
## @param include_diagonal: 是否包含四个斜向邻居。
## @return 位于网格范围内的邻居列表。
static func get_neighbors(
	cell: Vector2i,
	grid_size: Vector2i,
	include_diagonal: bool = false
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var directions: Array[Vector2i] = []
	directions.append_array(_ORTHOGONAL_DIRECTIONS)
	if include_diagonal:
		directions.append_array(_DIAGONAL_DIRECTIONS)

	for direction: Vector2i in directions:
		var next_cell := cell + direction
		if is_in_bounds(next_cell, grid_size):
			result.append(next_cell)

	return result


## 从起点执行泛洪搜索，返回所有满足匹配条件且连通的格子。
## @param grid_size: 网格尺寸。
## @param start: 起点格子。
## @param is_match: 匹配回调，签名为 `func(cell: Vector2i) -> bool`。
## @param include_diagonal: 是否允许斜向连通。
## @return 连通格子列表。
static func flood_fill(
	grid_size: Vector2i,
	start: Vector2i,
	is_match: Callable,
	include_diagonal: bool = false
) -> Array[Vector2i]:
	if not is_in_bounds(start, grid_size) or not is_match.is_valid():
		return []
	if not bool(is_match.call(start)):
		return []

	var result: Array[Vector2i] = []
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = { start: true }

	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		result.append(cell)

		for next_cell: Vector2i in get_neighbors(cell, grid_size, include_diagonal):
			if visited.has(next_cell):
				continue
			visited[next_cell] = true

			if bool(is_match.call(next_cell)):
				queue.append(next_cell)

	return result


## 使用 BFS 查找一条最短路径。
## @param grid_size: 网格尺寸。
## @param start: 起点格子。
## @param goal: 终点格子。
## @param is_walkable: 可通行回调，签名为 `func(cell: Vector2i) -> bool`。
## @param allow_diagonal: 是否允许斜向移动。
## @return 包含起点与终点的路径；无法到达时返回空数组。
static func find_path_bfs(
	grid_size: Vector2i,
	start: Vector2i,
	goal: Vector2i,
	is_walkable: Callable,
	allow_diagonal: bool = false
) -> Array[Vector2i]:
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

	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = { start: true }
	var came_from: Dictionary = {}

	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for next_cell: Vector2i in get_neighbors(cell, grid_size, allow_diagonal):
			if visited.has(next_cell) or not bool(is_walkable.call(next_cell)):
				continue

			visited[next_cell] = true
			came_from[next_cell] = cell

			if next_cell == goal:
				return _reconstruct_path(start, goal, came_from)

			queue.append(next_cell)

	return []


## 判断两个格子是否能在指定转折次数内连通。
## @param grid_size: 网格尺寸。
## @param start: 起点格子。
## @param goal: 终点格子。
## @param is_walkable: 可通行回调，签名为 `func(cell: Vector2i) -> bool`；起点与终点可不通行。
## @param max_turns: 最大转折次数，连连看常用值为 2。
## @param allow_outer_border: 是否允许路径经过网格外一圈虚拟空格。
## @return 可连通时返回 true。
static func can_connect_with_max_turns(
	grid_size: Vector2i,
	start: Vector2i,
	goal: Vector2i,
	is_walkable: Callable,
	max_turns: int = 2,
	allow_outer_border: bool = true
) -> bool:
	if (
		start == goal
		or max_turns < 0
		or not is_walkable.is_valid()
		or not is_in_bounds(start, grid_size)
		or not is_in_bounds(goal, grid_size)
	):
		return false

	var queue: Array[Dictionary] = []
	var visited: Dictionary = {}
	for direction_index: int in range(_ORTHOGONAL_DIRECTIONS.size()):
		var direction: Vector2i = _ORTHOGONAL_DIRECTIONS[direction_index]
		var next_cell := start + direction
		if not _can_step_connector(next_cell, goal, grid_size, is_walkable, allow_outer_border):
			continue

		queue.append({
			"cell": next_cell,
			"direction_index": direction_index,
			"turns": 0,
		})
		visited[_make_connector_key(next_cell, direction_index)] = 0

	while not queue.is_empty():
		var state: Dictionary = queue.pop_front()
		var cell: Vector2i = state["cell"]
		var direction_index: int = state["direction_index"]
		var turns: int = state["turns"]

		if cell == goal and turns <= max_turns:
			return true

		for next_direction_index: int in range(_ORTHOGONAL_DIRECTIONS.size()):
			var next_turns: int = turns
			if next_direction_index != direction_index:
				next_turns += 1
			if next_turns > max_turns:
				continue

			var next_cell := cell + _ORTHOGONAL_DIRECTIONS[next_direction_index]
			if not _can_step_connector(next_cell, goal, grid_size, is_walkable, allow_outer_border):
				continue

			var key := _make_connector_key(next_cell, next_direction_index)
			if visited.has(key) and int(visited[key]) <= next_turns:
				continue

			visited[key] = next_turns
			queue.append({
				"cell": next_cell,
				"direction_index": next_direction_index,
				"turns": next_turns,
			})

	return false


# --- 私有/辅助方法 ---

static func _reconstruct_path(start: Vector2i, goal: Vector2i, came_from: Dictionary) -> Array[Vector2i]:
	var path: Array[Vector2i] = [goal]
	var current := goal

	while current != start:
		if not came_from.has(current):
			return []

		current = came_from[current]
		path.push_front(current)

	return path


static func _can_step_connector(
	cell: Vector2i,
	goal: Vector2i,
	grid_size: Vector2i,
	is_walkable: Callable,
	allow_outer_border: bool
) -> bool:
	if cell == goal:
		return true

	if is_in_bounds(cell, grid_size):
		return bool(is_walkable.call(cell))

	if not allow_outer_border:
		return false

	return (
		cell.x >= -1
		and cell.y >= -1
		and cell.x <= grid_size.x
		and cell.y <= grid_size.y
	)


static func _make_connector_key(cell: Vector2i, direction_index: int) -> String:
	return "%d:%d:%d" % [cell.x, cell.y, direction_index]
