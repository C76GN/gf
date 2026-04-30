## GFInputDeviceUtility: 本地玩家输入设备分配工具。
##
## 负责维护玩家索引与键鼠、手柄、触控、AI 或自定义设备的映射。
## 它不消费输入事件，也不规定动作名。
class_name GFInputDeviceUtility
extends GFUtility


# --- 信号 ---

## 设备映射发生变化时发出。
signal assignments_changed(assignments: Array)

## 最近产生输入的玩家变化时发出。
## @param player_index: 玩家索引。
signal active_player_changed(player_index: int)


# --- 公共变量 ---

## 自动扫描时允许的最大本地玩家数。
var max_players: int = 4

## 是否为 0 号玩家自动分配键鼠。
var include_keyboard_mouse: bool = true

## 是否在移动平台自动添加触控设备。
var include_touch: bool = true

## 是否在收到未登记手柄输入时自动分配到空玩家席位。
var auto_assign_joypads_on_input: bool = true

## 未登记手柄轴输入需要达到该幅度才会触发自动分配，避免漂移噪声抢占席位。
var auto_assign_axis_threshold: float = 0.75

## 当前最近活跃玩家索引。
var active_player_index: int = 0


# --- 私有变量 ---

var _assignments: Array[GFInputDeviceAssignment] = []
var _player_deadzones: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	refresh_connected_devices()
	if not Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
		Input.joy_connection_changed.connect(_on_joy_connection_changed)


func dispose() -> void:
	_assignments.clear()
	_player_deadzones.clear()
	if Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
		Input.joy_connection_changed.disconnect(_on_joy_connection_changed)


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


## 移除指定玩家的设备映射。
## @param player_index: 玩家索引。
func remove_assignment(player_index: int) -> void:
	for index: int in range(_assignments.size() - 1, -1, -1):
		if _assignments[index].player_index == player_index:
			_assignments.remove_at(index)
			assignments_changed.emit(get_assignments())
			return


## 获取指定玩家的设备映射。
## @param player_index: 玩家索引。
## @return 设备映射；不存在时返回 null。
func get_assignment(player_index: int) -> GFInputDeviceAssignment:
	for assignment: GFInputDeviceAssignment in _assignments:
		if assignment.player_index == player_index:
			return assignment
	return null


## 根据设备类型和设备 ID 获取玩家索引。
## @param device_type: 设备类型。
## @param device_id: 设备 ID。
## @return 玩家索引；不存在时返回 -1。
func get_player_for_device(
	device_type: GFInputDeviceAssignment.DeviceType,
	device_id: int
) -> int:
	for assignment: GFInputDeviceAssignment in _assignments:
		if assignment.device_type == device_type and assignment.device_id == device_id:
			return assignment.player_index
	return -1


## 根据输入事件获取玩家索引，不产生自动分配。
## @param event: 输入事件。
## @return 玩家索引；无法匹配时返回 -1。
func get_player_for_event(event: InputEvent) -> int:
	var device_type := _get_event_device_type(event)
	if device_type == -1:
		return -1

	var device_id := _get_event_device_id(event, device_type)
	return get_player_for_device(device_type, device_id)


## 处理输入事件并返回玩家索引。未登记手柄可按配置自动占位。
## @param event: 输入事件。
## @return 玩家索引；无法匹配时返回 -1。
func handle_input_event(event: InputEvent) -> int:
	if event == null:
		return -1

	var device_type := _get_event_device_type(event)
	if device_type == -1:
		return -1

	var device_id := _get_event_device_id(event, device_type)
	var player_index := get_player_for_device(device_type, device_id)
	if (
		player_index == -1
		and device_type == GFInputDeviceAssignment.DeviceType.JOYPAD
		and auto_assign_joypads_on_input
		and _is_event_active_enough_for_assignment(event)
	):
		player_index = assign_device_to_next_player(device_type, device_id)

	if player_index != -1 and _is_event_active_enough_for_active_player(event):
		_set_active_player(player_index)

	return player_index


## 把设备分配给第一个空玩家席位。
## @param device_type: 设备类型。
## @param device_id: 设备 ID。
## @return 分配到的玩家索引；无空位时返回 -1。
func assign_device_to_next_player(
	device_type: GFInputDeviceAssignment.DeviceType,
	device_id: int
) -> int:
	var existing_player := get_player_for_device(device_type, device_id)
	if existing_player != -1:
		return existing_player

	var player_index := _find_first_empty_player_index()
	if player_index == -1:
		return -1

	set_assignment(create_assignment(player_index, device_type, device_id))
	return player_index


## 设置最近活跃玩家。
## @param player_index: 玩家索引。
func set_active_player(player_index: int) -> void:
	if player_index < 0:
		return
	_set_active_player(player_index)


## 设置玩家级输入死区。小于 0 表示清除覆盖。
## @param player_index: 玩家索引。
## @param deadzone: 死区值。
func set_player_deadzone(player_index: int, deadzone: float) -> void:
	if player_index < 0:
		return
	if deadzone < 0.0:
		_player_deadzones.erase(player_index)
	else:
		_player_deadzones[player_index] = clampf(deadzone, 0.0, 1.0)


## 获取玩家级输入死区覆盖。
## @param player_index: 玩家索引。
## @param fallback: 没有覆盖时返回的值。
## @return 死区值。
func get_player_deadzone(player_index: int, fallback: float = -1.0) -> float:
	return float(_player_deadzones.get(player_index, fallback))


## 获取玩家设备显示名。
## @param player_index: 玩家索引。
## @return 显示名。
func get_device_name(player_index: int) -> String:
	var assignment := get_assignment(player_index)
	if assignment == null:
		return ""

	match assignment.device_type:
		GFInputDeviceAssignment.DeviceType.KEYBOARD_MOUSE:
			return "Keyboard / Mouse"
		GFInputDeviceAssignment.DeviceType.TOUCH:
			return "Touch"
		GFInputDeviceAssignment.DeviceType.JOYPAD:
			return Input.get_joy_name(assignment.device_id)
		GFInputDeviceAssignment.DeviceType.AI:
			return "AI"
		GFInputDeviceAssignment.DeviceType.CUSTOM:
			return "Custom %d" % assignment.device_id
		_:
			return ""


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


func _get_event_device_type(event: InputEvent) -> int:
	if event is InputEventKey or event is InputEventMouse:
		return GFInputDeviceAssignment.DeviceType.KEYBOARD_MOUSE
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return GFInputDeviceAssignment.DeviceType.TOUCH
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return GFInputDeviceAssignment.DeviceType.JOYPAD
	return -1


func _get_event_device_id(
	event: InputEvent,
	device_type: GFInputDeviceAssignment.DeviceType
) -> int:
	match device_type:
		GFInputDeviceAssignment.DeviceType.KEYBOARD_MOUSE:
			return 0
		GFInputDeviceAssignment.DeviceType.TOUCH:
			return -1
		GFInputDeviceAssignment.DeviceType.JOYPAD:
			return event.device
		_:
			return event.device


func _find_first_empty_player_index() -> int:
	for player_index: int in range(max_players):
		if get_assignment(player_index) == null:
			return player_index
	return -1


func _is_event_active_enough_for_assignment(event: InputEvent) -> bool:
	if event is InputEventJoypadMotion:
		return absf((event as InputEventJoypadMotion).axis_value) >= auto_assign_axis_threshold
	return _is_event_active_enough_for_active_player(event)


func _is_event_active_enough_for_active_player(event: InputEvent) -> bool:
	if event is InputEventKey:
		return (event as InputEventKey).pressed
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).pressed
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	if event is InputEventJoypadButton:
		return (event as InputEventJoypadButton).pressed
	if event is InputEventJoypadMotion:
		return absf((event as InputEventJoypadMotion).axis_value) > 0.0
	return true


func _set_active_player(player_index: int) -> void:
	if active_player_index == player_index:
		return
	active_player_index = player_index
	active_player_changed.emit(active_player_index)


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		return

	for index: int in range(_assignments.size() - 1, -1, -1):
		var assignment := _assignments[index]
		if (
			assignment.device_type == GFInputDeviceAssignment.DeviceType.JOYPAD
			and assignment.device_id == device
		):
			_assignments.remove_at(index)
			assignments_changed.emit(get_assignments())
			return
