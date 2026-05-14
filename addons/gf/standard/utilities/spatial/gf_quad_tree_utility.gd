## GFQuadTreeUtility: 纯逻辑 2D 四叉树空间划分工具。
##
## 继承自 GFUtility，提供不依赖引擎物理节点的 2D 空间划分和范围查询能力。
## 适用于模拟经营、RTS 等需要对海量实体进行高效范围检索的场景。
##
## 用法：
##   1. 调用 setup(bounds, max_depth, max_entities) 初始化树的参数。
##   2. 调用 insert(entity_id, rect) 将实体插入四叉树。
##   3. 调用 query_rect(rect)、query_radius(center, radius) 或 query_point(point) 查询。
##   4. 调用 update(entity_id, rect) 更新实体位置（内部先移除再插入）。
##   5. 调用 remove(entity_id) 移除实体。
##
## 注意：entity_id 为 int，由调用方自行管理 ID 映射。
class_name GFQuadTreeUtility
extends GFUtility


# --- 常量 ---

## 默认最大树深度。
const DEFAULT_MAX_DEPTH: int = 8

## 默认每节点最大实体数（超过后分裂）。
const DEFAULT_MAX_ENTITIES: int = 8


# --- 公共变量 ---

## 四叉树覆盖的世界边界。
var bounds: Rect2 = Rect2()

## 最大递归深度。
var max_depth: int = DEFAULT_MAX_DEPTH

## 每个节点在分裂前允许的最大实体数。
var max_entities_per_node: int = DEFAULT_MAX_ENTITIES


# --- 私有变量 ---

## 根节点。
var _root: QTNode

## 全局实体索引。Key 为 entity_id (int)，Value 为 Rect2。
var _entity_rects: Dictionary = {}

## 实体点命中测试。Key 为 entity_id (int)，Value 为 Callable。
var _entity_hit_tests: Dictionary = {}


# --- Godot 生命周期方法 ---

## 第一阶段初始化：创建空根节点。
func init() -> void:
	_entity_rects.clear()
	_entity_hit_tests.clear()
	_rebuild_root()


# --- 公共方法 ---

## 配置四叉树参数并重建。应在 init() 之前或之后调用。
## @param world_bounds: 世界边界矩形。
## @param depth: 最大递归深度。
## @param entities_per_node: 每节点最大实体数。
func setup(world_bounds: Rect2, depth: int = DEFAULT_MAX_DEPTH, entities_per_node: int = DEFAULT_MAX_ENTITIES) -> void:
	bounds = _normalize_rect(world_bounds)
	max_depth = maxi(depth, 0)
	max_entities_per_node = maxi(entities_per_node, 1)
	clear()


## 将实体插入四叉树。
## @param entity_id: 实体唯一标识。
## @param rect: 实体的轴对齐包围矩形。
func insert(entity_id: int, rect: Rect2) -> void:
	_ensure_root()
	if _entity_rects.has(entity_id):
		_remove_entity(entity_id, true)

	var normalized_rect := _normalize_rect(rect)
	_entity_rects[entity_id] = normalized_rect
	_root.insert(entity_id, normalized_rect)


## 将带精确点命中测试的实体插入四叉树。
## @param entity_id: 实体唯一标识。
## @param rect: 实体的轴对齐包围矩形。
## @param hit_test: 可选精确命中测试，签名为 `(entity_id, point, rect) -> bool`。
func insert_with_hit_test(entity_id: int, rect: Rect2, hit_test: Callable) -> void:
	insert(entity_id, rect)
	set_entity_hit_test(entity_id, hit_test)


## 从四叉树中移除实体。
## @param entity_id: 要移除的实体标识。
func remove(entity_id: int) -> void:
	_remove_entity(entity_id, true)


## 更新实体的位置（先移除再插入）。
## @param entity_id: 实体标识。
## @param new_rect: 新的包围矩形。
func update(entity_id: int, new_rect: Rect2) -> void:
	var hit_test := _entity_hit_tests.get(entity_id, Callable()) as Callable
	_remove_entity(entity_id, false)
	insert(entity_id, new_rect)
	if hit_test.is_valid():
		_entity_hit_tests[entity_id] = hit_test


## 设置实体的精确点命中测试。
## @param entity_id: 实体标识。
## @param hit_test: 命中测试 Callable，签名为 `(entity_id, point, rect) -> bool`。
## @return 设置成功返回 true。
func set_entity_hit_test(entity_id: int, hit_test: Callable) -> bool:
	if not _entity_rects.has(entity_id):
		return false
	if not hit_test.is_valid():
		_entity_hit_tests.erase(entity_id)
		return true

	_entity_hit_tests[entity_id] = hit_test
	return true


## 清除实体的精确点命中测试。
## @param entity_id: 实体标识。
## @return 清除成功返回 true。
func clear_entity_hit_test(entity_id: int) -> bool:
	var existed := _entity_hit_tests.has(entity_id)
	_entity_hit_tests.erase(entity_id)
	return existed


## 获取实体矩形。
## @param entity_id: 实体标识。
## @return 实体矩形；不存在时返回空 Rect2。
func get_entity_rect(entity_id: int) -> Rect2:
	return _entity_rects.get(entity_id, Rect2()) as Rect2


## 矩形范围查询：返回与查询区域有交集的所有实体 ID。
## @param area: 查询矩形。
## @return 匹配的实体 ID 数组。
func query_rect(area: Rect2) -> Array[int]:
	_ensure_root()
	var result: Array[int] = []
	var visited: Dictionary = {}
	_root.query_rect(_normalize_rect(area), result, visited)
	return result


## 圆形范围查询：返回包围矩形与圆有交集的所有实体 ID。
## @param center: 圆心坐标。
## @param radius: 查询半径。
## @return 匹配的实体 ID 数组。
func query_radius(center: Vector2, radius: float) -> Array[int]:
	if radius < 0.0:
		return []

	var query_bounds := Rect2(center - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0))
	var candidates: Array[int] = query_rect(query_bounds)
	var result: Array[int] = []
	var radius_sq: float = radius * radius

	for entity_id: int in candidates:
		if _entity_rects.has(entity_id):
			var rect: Rect2 = _entity_rects[entity_id]
			var closest: Vector2 = Vector2(
				clampf(center.x, rect.position.x, rect.position.x + rect.size.x),
				clampf(center.y, rect.position.y, rect.position.y + rect.size.y),
			)
			if center.distance_squared_to(closest) <= radius_sq:
				result.append(entity_id)

	return result


## 点查询：返回包含该点的实体 ID，可选执行精确命中测试。
## @param point: 查询点。
## @param use_exact_hit_tests: 是否执行通过 set_entity_hit_test() 注册的精确命中测试。
## @return 匹配的实体 ID 数组。
func query_point(point: Vector2, use_exact_hit_tests: bool = true) -> Array[int]:
	_ensure_root()
	var candidates: Array[int] = []
	var visited: Dictionary = {}
	_root.query_point(point, candidates, visited)
	if not use_exact_hit_tests:
		return candidates

	var result: Array[int] = []
	for entity_id: int in candidates:
		if _passes_point_hit_test(entity_id, point):
			result.append(entity_id)
	return result


## 点查询：返回第一个包含该点的实体 ID，不存在时返回 -1。
## @param point: 查询点。
## @param use_exact_hit_tests: 是否执行精确命中测试。
## @return 第一个实体 ID；不存在时返回 -1。
func query_first_point(point: Vector2, use_exact_hit_tests: bool = true) -> int:
	var result := query_point(point, use_exact_hit_tests)
	return result[0] if not result.is_empty() else -1


## 重建四叉树节点结构，保留实体、矩形和命中测试。
func compact() -> void:
	var rects := _entity_rects.duplicate()
	_rebuild_root()
	for entity_id: int in rects.keys():
		var rect := rects[entity_id] as Rect2
		_entity_rects[entity_id] = rect
		_root.insert(entity_id, rect)


## 清空四叉树中的所有实体并重建根节点。
func clear() -> void:
	_entity_rects.clear()
	_entity_hit_tests.clear()
	_rebuild_root()


## 获取当前存储的实体总数。
## @return 实体数量。
func get_entity_count() -> int:
	return _entity_rects.size()


## 检查实体是否存在于四叉树中。
## @param entity_id: 实体标识。
## @return 是否存在。
func has_entity(entity_id: int) -> bool:
	return _entity_rects.has(entity_id)


## 获取调试快照。
## @return 四叉树状态。
func get_debug_snapshot() -> Dictionary:
	_ensure_root()
	return {
		"bounds": bounds,
		"entity_count": _entity_rects.size(),
		"hit_test_count": _entity_hit_tests.size(),
		"max_depth": max_depth,
		"max_entities_per_node": max_entities_per_node,
		"node_count": _root.get_node_count(),
	}


# --- 私有/辅助方法 ---

func _ensure_root() -> void:
	if _root == null:
		_rebuild_root()


func _rebuild_root() -> void:
	max_depth = maxi(max_depth, 0)
	max_entities_per_node = maxi(max_entities_per_node, 1)
	bounds = _normalize_rect(bounds)
	_root = QTNode.new(bounds, 0, max_depth, max_entities_per_node)


func _remove_entity(entity_id: int, erase_hit_test: bool) -> void:
	if not _entity_rects.has(entity_id):
		return
	_ensure_root()
	var rect: Rect2 = _entity_rects[entity_id]
	_root.remove(entity_id, rect)
	_entity_rects.erase(entity_id)
	if erase_hit_test:
		_entity_hit_tests.erase(entity_id)


func _passes_point_hit_test(entity_id: int, point: Vector2) -> bool:
	if not _entity_rects.has(entity_id):
		return false

	var rect: Rect2 = _entity_rects[entity_id]
	var hit_test := _entity_hit_tests.get(entity_id, Callable()) as Callable
	if hit_test.is_valid():
		return bool(hit_test.call(entity_id, point, rect))
	return _rect_contains_point(rect, point)


func _normalize_rect(rect: Rect2) -> Rect2:
	var position := rect.position
	var size := rect.size
	if size.x < 0.0:
		position.x += size.x
		size.x = -size.x
	if size.y < 0.0:
		position.y += size.y
		size.y = -size.y
	return Rect2(position, size)


func _rect_contains_point(rect: Rect2, point: Vector2) -> bool:
	return (
		point.x >= rect.position.x
		and point.y >= rect.position.y
		and point.x <= rect.position.x + rect.size.x
		and point.y <= rect.position.y + rect.size.y
	)


# --- 内部类 ---

## 四叉树节点内部实现。
class QTNode:
	# --- 公共变量 ---
	var node_bounds: Rect2
	var depth: int
	var max_depth_limit: int
	var max_entities_limit: int
	var entities: Array[int] = []
	var entity_rects: Dictionary = {}
	var children: Array = []
	var is_split: bool = false


	# --- Godot 生命周期方法 ---

	func _init(
		p_bounds: Rect2,
		p_depth: int,
		p_max_depth: int,
		p_max_entities: int
	) -> void:
		node_bounds = p_bounds
		depth = p_depth
		max_depth_limit = p_max_depth
		max_entities_limit = p_max_entities


	# --- 公共方法 ---

## 插入空间索引记录。
## @param entity_id: 实体唯一标识。
## @param rect: 矩形区域。
	func insert(entity_id: int, rect: Rect2) -> void:
		if is_split:
			if _insert_into_children(entity_id, rect):
				return

		if not entities.has(entity_id):
			entities.append(entity_id)
		entity_rects[entity_id] = rect

		if entities.size() > max_entities_limit and depth < max_depth_limit:
			_split()


## 移除空间索引记录。
## @param entity_id: 实体唯一标识。
## @param rect: 矩形区域。
	func remove(entity_id: int, rect: Rect2) -> void:
		entities.erase(entity_id)
		entity_rects.erase(entity_id)

		if is_split:
			for child: QTNode in children:
				if child.node_bounds.intersects(rect):
					child.remove(entity_id, rect)


## 查询矩形范围内的空间索引记录。
## @param query: 查询矩形。
## @param result: 用于接收查询结果的数组。
## @param visited: 查询过程中的去重索引。
	func query_rect(query: Rect2, result: Array[int], visited: Dictionary) -> void:
		if not node_bounds.intersects(query):
			return

		_query_local_rect(query, result, visited)
		if is_split:
			for child: QTNode in children:
				child.query_rect(query, result, visited)


## 查询包含指定点的空间索引记录。
## @param point: 查询点。
## @param result: 用于接收查询结果的数组。
## @param visited: 查询过程中的去重索引。
	func query_point(point: Vector2, result: Array[int], visited: Dictionary) -> void:
		if not _contains_point(node_bounds, point):
			return

		_query_local_point(point, result, visited)
		if is_split:
			for child: QTNode in children:
				child.query_point(point, result, visited)


## 获取当前节点及子节点总数。
## @return 节点数量。
	func get_node_count() -> int:
		var count := 1
		if is_split:
			for child: QTNode in children:
				count += child.get_node_count()
		return count


	# --- 私有/辅助方法 ---

	func _split() -> void:
		var half_size := node_bounds.size * 0.5
		var pos := node_bounds.position
		var next_depth: int = depth + 1

		children = [
			QTNode.new(Rect2(pos, half_size), next_depth, max_depth_limit, max_entities_limit),
			QTNode.new(Rect2(Vector2(pos.x + half_size.x, pos.y), half_size), next_depth, max_depth_limit, max_entities_limit),
			QTNode.new(Rect2(Vector2(pos.x, pos.y + half_size.y), half_size), next_depth, max_depth_limit, max_entities_limit),
			QTNode.new(Rect2(pos + half_size, half_size), next_depth, max_depth_limit, max_entities_limit),
		]
		is_split = true

		var old_entities := entities.duplicate()
		var old_rects := entity_rects.duplicate()
		entities.clear()
		entity_rects.clear()

		for entity_id: int in old_entities:
			if old_rects.has(entity_id):
				insert(entity_id, old_rects[entity_id] as Rect2)


	func _insert_into_children(entity_id: int, rect: Rect2) -> bool:
		var inserted := false
		for child: QTNode in children:
			if child.node_bounds.intersects(rect):
				child.insert(entity_id, rect)
				inserted = true
		return inserted


	func _query_local_rect(query: Rect2, result: Array[int], visited: Dictionary) -> void:
		for entity_id: int in entities:
			if visited.has(entity_id) or not entity_rects.has(entity_id):
				continue

			var rect: Rect2 = entity_rects[entity_id]
			if rect.intersects(query):
				visited[entity_id] = true
				result.append(entity_id)


	func _query_local_point(point: Vector2, result: Array[int], visited: Dictionary) -> void:
		for entity_id: int in entities:
			if visited.has(entity_id) or not entity_rects.has(entity_id):
				continue

			var rect: Rect2 = entity_rects[entity_id]
			if _contains_point(rect, point):
				visited[entity_id] = true
				result.append(entity_id)


	func _contains_point(rect: Rect2, point: Vector2) -> bool:
		return (
			point.x >= rect.position.x
			and point.y >= rect.position.y
			and point.x <= rect.position.x + rect.size.x
			and point.y <= rect.position.y + rect.size.y
		)
