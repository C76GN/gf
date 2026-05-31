## GFGridKey3D: 3D 网格坐标稳定整数键工具。
##
## 将有限范围内的 Vector3i 格坐标与方向编号打包成非负 int，并提供反解与
## Vector3 位置量化。它只处理坐标编码，不绑定 TileMap、GridMap、渲染或存档格式。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.18.0
class_name GFGridKey3D
extends RefCounted


# --- 常量 ---

## 每个坐标轴使用的位数。
## [br]
## @api public
const COORDINATE_BITS: int = 19

## 方向编号使用的位数。
## [br]
## @api public
const ORIENTATION_BITS: int = 6

## 可打包坐标最小值。
## [br]
## @api public
const COORDINATE_MIN: int = -262144

## 可打包坐标最大值。
## [br]
## @api public
const COORDINATE_MAX: int = 262143

## 可打包方向编号最小值。
## [br]
## @api public
const ORIENTATION_MIN: int = 0

## 可打包方向编号最大值。
## [br]
## @api public
const ORIENTATION_MAX: int = 63

## 无效 key 哨兵值。
## [br]
## @api public
const INVALID_KEY: int = -1

const _COORDINATE_SPAN: int = 1 << COORDINATE_BITS
const _COORDINATE_OFFSET: int = _COORDINATE_SPAN >> 1
const _COORDINATE_MASK: int = _COORDINATE_SPAN - 1
const _X_SHIFT: int = 0
const _Y_SHIFT: int = COORDINATE_BITS
const _Z_SHIFT: int = COORDINATE_BITS * 2
const _ORIENTATION_SHIFT: int = COORDINATE_BITS * 3
const _MAX_PACKED_KEY: int = 9223372036854775807
const _MIN_CELL_SIZE: float = 0.000001


# --- 公共方法 ---

## 判断格坐标和方向编号是否能被打包。
## [br]
## @api public
## [br]
## @param cell: 3D 格坐标。
## [br]
## @param orientation: 方向编号，范围为 0..63。
## [br]
## @return 可打包时返回 true。
static func can_pack_cell(cell: Vector3i, orientation: int = 0) -> bool:
	return (
		cell.x >= COORDINATE_MIN
		and cell.x <= COORDINATE_MAX
		and cell.y >= COORDINATE_MIN
		and cell.y <= COORDINATE_MAX
		and cell.z >= COORDINATE_MIN
		and cell.z <= COORDINATE_MAX
		and orientation >= ORIENTATION_MIN
		and orientation <= ORIENTATION_MAX
	)


## 将格坐标和方向编号打包成非负整数 key。
## [br]
## @api public
## [br]
## @param cell: 3D 格坐标。
## [br]
## @param orientation: 方向编号，范围为 0..63。
## [br]
## @return 打包后的 key；输入超出范围时返回 INVALID_KEY。
static func pack_cell(cell: Vector3i, orientation: int = 0) -> int:
	if not can_pack_cell(cell, orientation):
		return INVALID_KEY

	return (
		(_encode_coordinate(cell.x) << _X_SHIFT)
		| (_encode_coordinate(cell.y) << _Y_SHIFT)
		| (_encode_coordinate(cell.z) << _Z_SHIFT)
		| (orientation << _ORIENTATION_SHIFT)
	)


## 判断整数是否可能是 GFGridKey3D 生成的 key。
## [br]
## @api public
## [br]
## @param key: 待检测 key。
## [br]
## @return 在有效整数范围内时返回 true。
static func is_packed_key_valid(key: int) -> bool:
	return key >= 0 and key <= _MAX_PACKED_KEY


## 从 key 反解格坐标。
## [br]
## @api public
## [br]
## @param key: 打包 key。
## [br]
## @return 反解出的格坐标；key 无效时返回 Vector3i.ZERO。
static func unpack_cell(key: int) -> Vector3i:
	if not is_packed_key_valid(key):
		return Vector3i.ZERO

	return Vector3i(
		_decode_coordinate((key >> _X_SHIFT) & _COORDINATE_MASK),
		_decode_coordinate((key >> _Y_SHIFT) & _COORDINATE_MASK),
		_decode_coordinate((key >> _Z_SHIFT) & _COORDINATE_MASK)
	)


## 从 key 反解方向编号。
## [br]
## @api public
## [br]
## @param key: 打包 key。
## [br]
## @return 方向编号；key 无效时返回 -1。
static func unpack_orientation(key: int) -> int:
	if not is_packed_key_valid(key):
		return -1

	return (key >> _ORIENTATION_SHIFT) & ORIENTATION_MAX


## 从 key 反解完整数据字典。
## [br]
## @api public
## [br]
## @param key: 打包 key。
## [br]
## @return Dictionary，包含 valid、cell 和 orientation。
## [br]
## @schema return: Dictionary with valid: bool, cell: Vector3i, and orientation: int.
static func unpack_key(key: int) -> Dictionary:
	var valid: bool = is_packed_key_valid(key)
	return {
		"valid": valid,
		"cell": unpack_cell(key) if valid else Vector3i.ZERO,
		"orientation": unpack_orientation(key) if valid else -1,
	}


## 将世界位置量化为格坐标。
## [br]
## @api public
## [br]
## @param position: 世界或局部位置。
## [br]
## @param cell_size: 单格尺寸，各轴会被限制为正数。
## [br]
## @param origin: 量化原点。
## [br]
## @return 量化后的格坐标。
static func position_to_cell(
	position: Vector3,
	cell_size: Vector3 = Vector3.ONE,
	origin: Vector3 = Vector3.ZERO
) -> Vector3i:
	var safe_size: Vector3 = _get_safe_cell_size(cell_size)
	return Vector3i(
		floori((position.x - origin.x) / safe_size.x),
		floori((position.y - origin.y) / safe_size.y),
		floori((position.z - origin.z) / safe_size.z)
	)


## 将世界位置量化并打包成整数 key。
## [br]
## @api public
## [br]
## @param position: 世界或局部位置。
## [br]
## @param cell_size: 单格尺寸，各轴会被限制为正数。
## [br]
## @param origin: 量化原点。
## [br]
## @param orientation: 方向编号，范围为 0..63。
## [br]
## @return 打包后的 key；量化坐标或方向编号超出范围时返回 INVALID_KEY。
static func pack_position(
	position: Vector3,
	cell_size: Vector3 = Vector3.ONE,
	origin: Vector3 = Vector3.ZERO,
	orientation: int = 0
) -> int:
	return pack_cell(position_to_cell(position, cell_size, origin), orientation)


# --- 私有/辅助方法 ---

static func _encode_coordinate(value: int) -> int:
	return value + _COORDINATE_OFFSET


static func _decode_coordinate(value: int) -> int:
	return value - _COORDINATE_OFFSET


static func _get_safe_cell_size(cell_size: Vector3) -> Vector3:
	return Vector3(
		maxf(absf(cell_size.x), _MIN_CELL_SIZE),
		maxf(absf(cell_size.y), _MIN_CELL_SIZE),
		maxf(absf(cell_size.z), _MIN_CELL_SIZE)
	)
