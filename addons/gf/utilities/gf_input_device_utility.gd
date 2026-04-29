## GFInputDeviceUtility: 本地玩家输入设备分配工具。
##
## 负责维护玩家索引与键鼠、手柄、触控、AI 或自定义设备的映射。
## 它不消费输入事件，也不规定动作名。
class_name GFInputDeviceUtility
extends GFUtility


# --- 信号 ---

## 设备映射发生变化时发出。
signal assignments_changed(assignments: Array)


# --- 公共变量 ---

## 自动扫描时允许的最大本地玩家数。
var max_players: int = 4

## 是否为 0 号玩家自动分配键鼠。
var include_keyboard_mouse: bool = true

## 是否在移动平台自动添加触控设备。
var include_touch: bool = true


# --- 私有变量 ---

var _assignments: Array[GFInputDeviceAssignment] = []


# --- Godot 生命周期方法 ---

func init() -> void:
	refresh_connected_devices()


func dispose() -> void:
	_assignments.clear()


# --- 公共方法 ---

## 按当前硬件重新生成设备映射。
func refresh_connected_devices() -> void:
	_assignments.clear()

	if include_keyboard_mouse and _assignments.size() < max_players:
		_assignments.append(create_assignment(
			_assignments.size(),
			GFInputDeviceAssignment.DeviceType.KEYBOARD_MOUSE,
			0
		))

	if include_touch and _is_touch_platform() and _assignments.size() < max_players:
		_assignments.append(create_assignment(
			_assignments.size(),
			GFInputDeviceAssignment.DeviceType.TOUCH,
			-1
		))

	for joypad_id: int in Input.get_connected_joypads():
		if _assignments.size() >= max_players:
			break
		_assignments.append(create_assignment(
			_assignments.size(),
			GFInputDeviceAssignment.DeviceType.JOYPAD,
			joypad_id
		))

	assignments_changed.emit(get_assignments())


## 创建一个设备映射。
## @param player_index: 玩家索引。
## @param device_type: 设备类型。
## @param device_id: 设备 ID。
## @return 新映射。
func create_assignment(
	player_index: int,
	device_type: GFInputDeviceAssignment.DeviceType,
	device_id: int
) -> GFInputDeviceAssignment:
	var assignment := GFInputDeviceAssignment.new()
	assignment.player_index = player_index
	assignment.device_type = device_type
	assignment.device_id = device_id
	return assignment


## 手动设置一个玩家的设备映射。
## @param assignment: 设备映射。
func set_assignment(assignment: GFInputDeviceAssignment) -> void:
	if assignment == null:
		return

	for index: int in range(_assignments.size()):
		if _assignments[index].player_index == assignment.player_index:
			_assignments[index] = assignment
			assignments_changed.emit(get_assignments())
			return

	_assignments.append(assignment)
	_assignments.sort_custom(func(a: GFInputDeviceAssignment, b: GFInputDeviceAssignment) -> bool:
		return a.player_index < b.player_index
	)
	assignments_changed.emit(get_assignments())


## 获取指定玩家的设备映射。
## @param player_index: 玩家索引。
## @return 设备映射；不存在时返回 null。
func get_assignment(player_index: int) -> GFInputDeviceAssignment:
	for assignment: GFInputDeviceAssignment in _assignments:
		if assignment.player_index == player_index:
			return assignment
	return null


## 获取所有设备映射的拷贝。
## @return 映射数组。
func get_assignments() -> Array[GFInputDeviceAssignment]:
	var result: Array[GFInputDeviceAssignment] = []
	for assignment: GFInputDeviceAssignment in _assignments:
		result.append(assignment.duplicate_assignment())
	return result


## 清空所有映射。
func clear_assignments() -> void:
	_assignments.clear()
	assignments_changed.emit(get_assignments())


# --- 私有/辅助方法 ---

func _is_touch_platform() -> bool:
	var os_name := OS.get_name()
	return os_name == "Android" or os_name == "iOS"
