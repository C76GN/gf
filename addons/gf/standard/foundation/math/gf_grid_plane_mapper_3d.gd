## GFGridPlaneMapper3D: 3D 轴对齐平面与 2D 邻域坐标映射工具。
##
## 将 axis-aligned 3D 表面上的格坐标映射为局部 2D 坐标，并可按 2D offset
## 采样邻域值。它只处理坐标和回调取值，不绑定 TileSet、GridMap、碰撞或玩法语义。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.18.0
class_name GFGridPlaneMapper3D
extends RefCounted


# --- 常量 ---

## 默认四邻域 offset 顺序：上、右、下、左。
## [br]
## @api public
const DEFAULT_CARDINAL_OFFSETS: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0),
]


# --- 公共方法 ---

## 判断 normal 是否能表示单轴方向。
## [br]
## @api public
## [br]
## @param normal: 3D 平面法线。
## [br]
## @return normal 只有一个非零轴时返回 true。
static func is_axis_aligned_normal(normal: Vector3i) -> bool:
	return (
		(normal.x != 0 and normal.y == 0 and normal.z == 0)
		or (normal.x == 0 and normal.y != 0 and normal.z == 0)
		or (normal.x == 0 and normal.y == 0 and normal.z != 0)
	)


## 将单轴 normal 归一化为 -1/1 法线。
## [br]
## @api public
## [br]
## @param normal: 3D 平面法线。
## [br]
## @return 归一化法线；无效 normal 返回 Vector3i.ZERO。
static func normalize_axis_normal(normal: Vector3i) -> Vector3i:
	if normal.x != 0 and normal.y == 0 and normal.z == 0:
		return Vector3i(1 if normal.x > 0 else -1, 0, 0)
	if normal.x == 0 and normal.y != 0 and normal.z == 0:
		return Vector3i(0, 1 if normal.y > 0 else -1, 0)
	if normal.x == 0 and normal.y == 0 and normal.z != 0:
		return Vector3i(0, 0, 1 if normal.z > 0 else -1)
	return Vector3i.ZERO


## 获取轴对齐平面的局部基向量。
## [br]
## @api public
## [br]
## @param normal: 3D 平面法线。
## [br]
## @return Dictionary，包含 valid、normal、u、v。
## [br]
## @schema return: Dictionary with valid: bool, normal: Vector3i, u: Vector3i, and v: Vector3i.
static func get_plane_basis(normal: Vector3i) -> Dictionary:
	var normalized := normalize_axis_normal(normal)
	if normalized == Vector3i.ZERO:
		return _make_basis(false, Vector3i.ZERO, Vector3i.ZERO, Vector3i.ZERO)
	if normalized == Vector3i(1, 0, 0):
		return _make_basis(true, normalized, Vector3i(0, 0, 1), Vector3i(0, -1, 0))
	if normalized == Vector3i(-1, 0, 0):
		return _make_basis(true, normalized, Vector3i(0, 0, 1), Vector3i(0, 1, 0))
	if normalized == Vector3i(0, 1, 0):
		return _make_basis(true, normalized, Vector3i(1, 0, 0), Vector3i(0, 0, -1))
	if normalized == Vector3i(0, -1, 0):
		return _make_basis(true, normalized, Vector3i(1, 0, 0), Vector3i(0, 0, 1))
	if normalized == Vector3i(0, 0, 1):
		return _make_basis(true, normalized, Vector3i(1, 0, 0), Vector3i(0, 1, 0))
	return _make_basis(true, normalized, Vector3i(1, 0, 0), Vector3i(0, -1, 0))


## 将 3D 格坐标映射为平面局部 2D 坐标。
## [br]
## @api public
## [br]
## @param cell: 3D 格坐标。
## [br]
## @param origin: 平面局部原点。
## [br]
## @param normal: 3D 平面法线。
## [br]
## @return 局部 2D 坐标；normal 无效时返回 Vector2i.ZERO。
static func map_cell_to_plane(cell: Vector3i, origin: Vector3i, normal: Vector3i) -> Vector2i:
	var basis := get_plane_basis(normal)
	if not bool(basis.get("valid", false)):
		return Vector2i.ZERO

	var delta := cell - origin
	return Vector2i(
		_dot(delta, basis.get("u", Vector3i.ZERO) as Vector3i),
		_dot(delta, basis.get("v", Vector3i.ZERO) as Vector3i)
	)


## 将平面局部 2D 坐标映射为 3D 格坐标。
## [br]
## @api public
## [br]
## @param plane_cell: 局部 2D 坐标。
## [br]
## @param origin: 平面局部原点。
## [br]
## @param normal: 3D 平面法线。
## [br]
## @param depth: 沿 normal 的偏移层数。
## [br]
## @return 3D 格坐标；normal 无效时返回 origin。
static func map_plane_to_cell(
	plane_cell: Vector2i,
	origin: Vector3i,
	normal: Vector3i,
	depth: int = 0
) -> Vector3i:
	var basis := get_plane_basis(normal)
	if not bool(basis.get("valid", false)):
		return origin

	return (
		origin
		+ _scale(basis.get("u", Vector3i.ZERO) as Vector3i, plane_cell.x)
		+ _scale(basis.get("v", Vector3i.ZERO) as Vector3i, plane_cell.y)
		+ _scale(basis.get("normal", Vector3i.ZERO) as Vector3i, depth)
	)


## 获取格坐标相对平面的深度。
## [br]
## @api public
## [br]
## @param cell: 3D 格坐标。
## [br]
## @param origin: 平面局部原点。
## [br]
## @param normal: 3D 平面法线。
## [br]
## @return 沿 normal 的偏移层数；normal 无效时返回 0。
static func get_cell_depth(cell: Vector3i, origin: Vector3i, normal: Vector3i) -> int:
	var basis := get_plane_basis(normal)
	if not bool(basis.get("valid", false)):
		return 0

	return _dot(cell - origin, basis.get("normal", Vector3i.ZERO) as Vector3i)


## 按 2D offset 获取同一平面上的 3D 邻居格。
## [br]
## @api public
## [br]
## @param center: 中心 3D 格坐标。
## [br]
## @param normal: 3D 平面法线。
## [br]
## @param offsets: 局部 2D offset；为空时使用 DEFAULT_CARDINAL_OFFSETS。
## [br]
## @return 3D 邻居格列表。
static func get_neighbor_cells(center: Vector3i, normal: Vector3i, offsets: Array[Vector2i] = []) -> Array[Vector3i]:
	var basis := get_plane_basis(normal)
	var result: Array[Vector3i] = []
	if not bool(basis.get("valid", false)):
		return result

	var effective_offsets := DEFAULT_CARDINAL_OFFSETS if offsets.is_empty() else offsets
	var u := basis.get("u", Vector3i.ZERO) as Vector3i
	var v := basis.get("v", Vector3i.ZERO) as Vector3i
	for offset: Vector2i in effective_offsets:
		result.append(center + _scale(u, offset.x) + _scale(v, offset.y))

	return result


## 按 2D offset 采样同一平面上的 3D 邻域值。
## [br]
## @api public
## [br]
## @param center: 中心 3D 格坐标。
## [br]
## @param normal: 3D 平面法线。
## [br]
## @param value_getter: 取值回调，签名为 func(cell: Vector3i) -> Variant。
## [br]
## @param offsets: 局部 2D offset；为空时使用 DEFAULT_CARDINAL_OFFSETS。
## [br]
## @param fallback_value: 回调无效时填充的值。
## [br]
## @schema fallback_value: Variant used for each neighbor when value_getter is invalid.
## [br]
## @return 邻域值列表。
## [br]
## @schema return: Array ordered neighbor values sampled from mapped 3D cells.
static func sample_neighbor_values(
	center: Vector3i,
	normal: Vector3i,
	value_getter: Callable,
	offsets: Array[Vector2i] = [],
	fallback_value: Variant = null
) -> Array:
	var values: Array = []
	for cell: Vector3i in get_neighbor_cells(center, normal, offsets):
		if value_getter.is_valid():
			values.append(value_getter.call(cell))
		else:
			values.append(fallback_value)

	return values


# --- 私有/辅助方法 ---

static func _make_basis(valid: bool, normal: Vector3i, u: Vector3i, v: Vector3i) -> Dictionary:
	return {
		"valid": valid,
		"normal": normal,
		"u": u,
		"v": v,
	}


static func _dot(a: Vector3i, b: Vector3i) -> int:
	return a.x * b.x + a.y * b.y + a.z * b.z


static func _scale(value: Vector3i, amount: int) -> Vector3i:
	return Vector3i(value.x * amount, value.y * amount, value.z * amount)
