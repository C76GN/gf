## GFQuadTreeUtility: 纯逻辑 2D 四叉树空间划分工具。
##
## 继承自 GFUtility，提供不依赖引擎物理节点的 2D 空间划分和范围查询能力。
## 适用于模拟经营、RTS 等需要对海量实体进行高效范围检索的场景。
##
## 用法：
##   1. 调用 setup(bounds, max_depth, max_entities) 初始化树的参数。
##   2. 调用 insert(entity_id, rect) 将实体插入四叉树。
##   3. 调用 query_rect(rect) 或 query_radius(center, radius) 进行范围查询。
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


# --- Godot 生命周期方法 ---

## 第一阶段初始化：创建空根节点。
func init() -> void:
	_entity_rects.clear()
	_root = QTNode.new(bounds, 0, max_depth, max_entities_per_node)


# --- 公共方法 ---

## 配置四叉树参数并重建。应在 init() 之前或之后调用。
## @param world_bounds: 世界边界矩形。
## @param depth: 最大递归深度。
## @param entities_per_node: 每节点最大实体数。
func setup(world_bounds: Rect2, depth: int = DEFAULT_MAX_DEPTH, entities_per_node: int = DEFAULT_MAX_ENTITIES) -> void:
	bounds = world_bounds
	max_depth = depth
	max_entities_per_node = entities_per_node
	clear()


## 将实体插入四叉树。
## @param entity_id: 实体唯一标识。
## @param rect: 实体的轴对齐包围矩形。
func insert(entity_id: int, rect: Rect2) -> void:
	_entity_rects[entity_id] = rect
	_root.insert(entity_id, rect)


## 从四叉树中移除实体。
## @param entity_id: 要移除的实体标识。
func remove(entity_id: int) -> void:
	if not _entity_rects.has(entity_id):
		return
	var rect: Rect2 = _entity_rects[entity_id]
	_root.remove(entity_id, rect)
	_entity_rects.erase(entity_id)


## 更新实体的位置（先移除再插入）。
## @param entity_id: 实体标识。
## @param new_rect: 新的包围矩形。
func update(entity_id: int, new_rect: Rect2) -> void:
	remove(entity_id)
	insert(entity_id, new_rect)


## 矩形范围查询：返回与查询区域有交集的所有实体 ID。
## @param area: 查询矩形。
## @return 匹配的实体 ID 数组。
func query_rect(area: Rect2) -> Array[int]:
	var result: Array[int] = []
	_root.query_rect(area, result)
	return result


## 圆形范围查询：返回包围矩形与圆有交集的所有实体 ID。
## @param center: 圆心坐标。
## @param radius: 查询半径。
## @return 匹配的实体 ID 数组。
func query_radius(center: Vector2, radius: float) -> Array[int]:
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


## 清空四叉树中的所有实体并重建根节点。
func clear() -> void:
	_entity_rects.clear()
	_root = QTNode.new(bounds, 0, max_depth, max_entities_per_node)


## 获取当前存储的实体总数。
## @return 实体数量。
func get_entity_count() -> int:
	return _entity_rects.size()


## 检查实体是否存在于四叉树中。
## @param entity_id: 实体标识。
## @return 是否存在。
func has_entity(entity_id: int) -> bool:
	return _entity_rects.has(entity_id)


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
		p_max_entities: int,
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
			for child: QTNode in children:
				if child.node_bounds.intersects(rect):
					child.insert(entity_id, rect)
			return

		entities.append(entity_id)
		entity_rects[entity_id] = rect

		if entities.size() > max_entities_limit and depth < max_depth_limit:
			_split()


## 移除空间索引记录。
## @param entity_id: 实体唯一标识。
## @param rect: 矩形区域。
	func remove(entity_id: int, rect: Rect2) -> void:
		if is_split:
			for child: QTNode in children:
				if child.node_bounds.intersects(rect):
					child.remove(entity_id, rect)
			return

		entities.erase(entity_id)
		entity_rects.erase(entity_id)


## 查询矩形范围内的空间索引记录。
## @param query: 查询矩形。
## @param result: 用于接收查询结果的数组。
	func query_rect(query: Rect2, result: Array[int]) -> void:
		if not node_bounds.intersects(query):
			return

		if is_split:
			for child: QTNode in children:
				child.query_rect(query, result)
			return

		for entity_id: int in entities:
			if entity_rects.has(entity_id):
				var rect: Rect2 = entity_rects[entity_id]
				if rect.intersects(query) and not result.has(entity_id):
					result.append(entity_id)


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
				var rect: Rect2 = old_rects[entity_id]
				for child: QTNode in children:
					if child.node_bounds.intersects(rect):
						child.insert(entity_id, rect)
