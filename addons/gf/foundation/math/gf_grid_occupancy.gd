## GFGridOccupancy: 网格占用与预约数据结构。
##
## 适合格子移动、战棋、推箱子和解谜类玩法在 System 中跟踪运行时占用。
## 它不负责路径查找、碰撞或胜负规则。
class_name GFGridOccupancy
extends RefCounted


# --- 信号 ---

## 接收者占用格子时发出。
signal cell_occupied(receiver: Variant, cell: Vector2i)

## 接收者释放格子时发出。
signal cell_released(receiver: Variant, cell: Vector2i)

## 接收者预约格子时发出。
signal cell_reserved(receiver: Variant, cell: Vector2i)

## 接收者释放预约时发出。
signal reservation_released(receiver: Variant, cell: Vector2i)


# --- 公共变量 ---

## 网格尺寸。小于等于 0 的维度会让所有格子视为越界。
var grid_size: Vector2i = Vector2i.ZERO

## 单格允许的最大占用数量。
var max_occupants_per_cell: int = 1


# --- 私有变量 ---

var _cell_occupants: Dictionary = {}
var _receiver_records: Dictionary = {}
var _cell_reservations: Dictionary = {}
var _receiver_reservations: Dictionary = {}
var _reservation_records: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(p_grid_size: Vector2i = Vector2i.ZERO, p_max_occupants_per_cell: int = 1) -> void:
	grid_size = p_grid_size
	max_occupants_per_cell = maxi(p_max_occupants_per_cell, 1)


# --- 公共方法 ---

## 设置网格参数并清空占用。
## @param p_grid_size: 网格尺寸。
## @param p_max_occupants_per_cell: 单格最大占用数量。
func configure(p_grid_size: Vector2i, p_max_occupants_per_cell: int = 1) -> void:
	grid_size = p_grid_size
	max_occupants_per_cell = maxi(p_max_occupants_per_cell, 1)
	clear()


## 检查格子是否在边界内。
## @param cell: 格子坐标。
## @return 在边界内返回 true。
func is_in_bounds(cell: Vector2i) -> bool:
	return GFGridMath.is_in_bounds(cell, grid_size)


## 检查接收者是否可以占用格子。
## @param receiver: 接收者。
## @param cell: 格子坐标。
## @return 可占用时返回 true。
func can_occupy(receiver: Variant, cell: Vector2i) -> bool:
	if not is_in_bounds(cell):
		return false

	prune_invalid_receivers()
	var receiver_key := _make_receiver_key(receiver)
	if receiver_key.is_empty():
		return false

	var reserved_by := String(_cell_reservations.get(_cell_key(cell), ""))
	if not reserved_by.is_empty() and reserved_by != receiver_key:
		return false

	var occupants := _get_occupant_keys(cell)
	if occupants.has(receiver_key):
		return true
	return occupants.size() < max_occupants_per_cell


## 占用格子。接收者若已占用其他格子，会先释放旧格子。
## @param receiver: 接收者。
## @param cell: 格子坐标。
## @return 成功时返回 true。
func occupy(receiver: Variant, cell: Vector2i) -> bool:
	if not can_occupy(receiver, cell):
		return false

	var receiver_key := _make_receiver_key(receiver)
	var current_cell := get_receiver_cell(receiver)
	if current_cell == cell:
		return true
	if current_cell != Vector2i(-1, -1):
		release(receiver)

	var cell_key := _cell_key(cell)
	if not _cell_occupants.has(cell_key):
		_cell_occupants[cell_key] = []

	var occupants := _cell_occupants[cell_key] as Array
	if not occupants.has(receiver_key):
		occupants.append(receiver_key)

	_receiver_records[receiver_key] = _make_receiver_record(receiver, cell)
	cell_occupied.emit(receiver, cell)
	return true


## 释放接收者当前占用。
## @param receiver: 接收者。
func release(receiver: Variant) -> void:
	var receiver_key := _make_receiver_key(receiver)
	var record := _get_record(_receiver_records, receiver_key)
	if record.is_empty():
		return

	var cell := record["cell"] as Vector2i
	var cell_key := _cell_key(cell)
	if _cell_occupants.has(cell_key):
		(_cell_occupants[cell_key] as Array).erase(receiver_key)
		if (_cell_occupants[cell_key] as Array).is_empty():
			_cell_occupants.erase(cell_key)

	_receiver_records.erase(receiver_key)
	cell_released.emit(receiver, cell)


## 释放指定格子的所有占用。
## @param cell: 格子坐标。
func release_cell(cell: Vector2i) -> void:
	var occupants := _get_occupant_keys(cell).duplicate()
	for receiver_key: String in occupants:
		var record := _get_record(_receiver_records, receiver_key)
		if not record.is_empty():
			release(_record_to_receiver(record))


## 预约格子，防止其他接收者抢占。
## @param receiver: 接收者。
## @param cell: 格子坐标。
## @return 成功时返回 true。
func reserve_cell(receiver: Variant, cell: Vector2i) -> bool:
	if not can_occupy(receiver, cell):
		return false

	var receiver_key := _make_receiver_key(receiver)
	release_reservation(receiver)
	_cell_reservations[_cell_key(cell)] = receiver_key
	_receiver_reservations[receiver_key] = cell
	_reservation_records[receiver_key] = _make_receiver_record(receiver, cell)
	cell_reserved.emit(receiver, cell)
	return true


## 将接收者预约确认成占用。
## @param receiver: 接收者。
## @return 成功时返回 true。
func confirm_reservation(receiver: Variant) -> bool:
	var receiver_key := _make_receiver_key(receiver)
	if not _receiver_reservations.has(receiver_key):
		return false

	var cell := _receiver_reservations[receiver_key] as Vector2i
	release_reservation(receiver)
	return occupy(receiver, cell)


## 释放接收者预约。
## @param receiver: 接收者。
func release_reservation(receiver: Variant) -> void:
	var receiver_key := _make_receiver_key(receiver)
	if not _receiver_reservations.has(receiver_key):
		return

	var cell := _receiver_reservations[receiver_key] as Vector2i
	_receiver_reservations.erase(receiver_key)
	_cell_reservations.erase(_cell_key(cell))
	_reservation_records.erase(receiver_key)
	reservation_released.emit(receiver, cell)


## 检查格子是否有占用。
## @param cell: 格子坐标。
## @return 有占用时返回 true。
func is_cell_occupied(cell: Vector2i) -> bool:
	return not get_cell_occupants(cell).is_empty()


## 检查格子是否被预约。
## @param cell: 格子坐标。
## @return 被预约时返回 true。
func is_cell_reserved(cell: Vector2i) -> bool:
	return _cell_reservations.has(_cell_key(cell))


## 获取格子中的所有接收者。
## @param cell: 格子坐标。
## @return 接收者数组。
func get_cell_occupants(cell: Vector2i) -> Array:
	prune_invalid_receivers()
	var result: Array = []
	for receiver_key: String in _get_occupant_keys(cell):
		var record := _get_record(_receiver_records, receiver_key)
		if not record.is_empty():
			result.append(_record_to_receiver(record))
	return result


## 获取格子中的第一个接收者。
## @param cell: 格子坐标。
## @return 接收者；不存在时返回 null。
func get_cell_occupant(cell: Vector2i) -> Variant:
	var occupants := get_cell_occupants(cell)
	return occupants[0] if not occupants.is_empty() else null


## 获取接收者当前占用格。
## @param receiver: 接收者。
## @return 格子坐标；未占用时返回 Vector2i(-1, -1)。
func get_receiver_cell(receiver: Variant) -> Vector2i:
	var receiver_key := _make_receiver_key(receiver)
	var record := _get_record(_receiver_records, receiver_key)
	if record.is_empty():
		return Vector2i(-1, -1)
	if not _record_is_valid(record):
		release(receiver)
		return Vector2i(-1, -1)
	return record["cell"] as Vector2i


## 清理已释放 Object 接收者。
func prune_invalid_receivers() -> void:
	var keys_to_release: Array[String] = []
	for receiver_key: String in _receiver_records.keys():
		var record := _get_record(_receiver_records, receiver_key)
		if not _record_is_valid(record):
			keys_to_release.append(receiver_key)

	for receiver_key: String in keys_to_release:
		_release_by_key(receiver_key)

	var reservation_keys_to_release: Array[String] = []
	for receiver_key: String in _reservation_records.keys():
		var record := _get_record(_reservation_records, receiver_key)
		if not _record_is_valid(record):
			reservation_keys_to_release.append(receiver_key)

	for receiver_key: String in reservation_keys_to_release:
		_release_reservation_by_key(receiver_key)


## 清空占用和预约。
func clear() -> void:
	_cell_occupants.clear()
	_receiver_records.clear()
	_cell_reservations.clear()
	_receiver_reservations.clear()
	_reservation_records.clear()


# --- 私有/辅助方法 ---

func _get_occupant_keys(cell: Vector2i) -> Array:
	return _cell_occupants.get(_cell_key(cell), []) as Array


func _cell_key(cell: Vector2i) -> String:
	return "%d:%d" % [cell.x, cell.y]


func _make_receiver_key(receiver: Variant) -> String:
	if receiver == null:
		return ""
	if receiver is Object:
		return "object:%d" % (receiver as Object).get_instance_id()
	return "%d:%s" % [typeof(receiver), str(receiver)]


func _make_receiver_record(receiver: Variant, cell: Vector2i) -> Dictionary:
	if receiver is Object:
		return {
			"receiver_ref": weakref(receiver),
			"receiver": null,
			"cell": cell,
		}

	return {
		"receiver_ref": null,
		"receiver": receiver,
		"cell": cell,
	}


func _record_to_receiver(record: Dictionary) -> Variant:
	var receiver_ref_variant: Variant = record.get("receiver_ref")
	if receiver_ref_variant is WeakRef:
		var receiver_ref := receiver_ref_variant as WeakRef
		return receiver_ref.get_ref()
	return record.get("receiver")


func _record_is_valid(record: Dictionary) -> bool:
	if record.is_empty():
		return false

	var receiver_ref_variant: Variant = record.get("receiver_ref")
	if receiver_ref_variant is WeakRef:
		return (receiver_ref_variant as WeakRef).get_ref() != null
	return true


func _release_by_key(receiver_key: String) -> void:
	var record := _get_record(_receiver_records, receiver_key)
	if record.is_empty():
		return

	var cell := record["cell"] as Vector2i
	var cell_key := _cell_key(cell)
	if _cell_occupants.has(cell_key):
		(_cell_occupants[cell_key] as Array).erase(receiver_key)
		if (_cell_occupants[cell_key] as Array).is_empty():
			_cell_occupants.erase(cell_key)

	_receiver_records.erase(receiver_key)
	_release_reservation_by_key(receiver_key)


func _release_reservation_by_key(receiver_key: String) -> void:
	if not _receiver_reservations.has(receiver_key):
		_reservation_records.erase(receiver_key)
		return

	var cell := _receiver_reservations[receiver_key] as Vector2i
	var record := _get_record(_reservation_records, receiver_key)
	var receiver: Variant = null
	if not record.is_empty():
		receiver = _record_to_receiver(record)
	_receiver_reservations.erase(receiver_key)
	_cell_reservations.erase(_cell_key(cell))
	_reservation_records.erase(receiver_key)
	reservation_released.emit(receiver, cell)


func _get_record(records: Dictionary, receiver_key: String) -> Dictionary:
	var record_variant: Variant = records.get(receiver_key, {})
	if record_variant is Dictionary:
		return record_variant as Dictionary
	return {}
