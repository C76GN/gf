## 测试 GFInputDeviceUtility 与 GFInputDeviceAssignment 的设备映射行为。
extends GutTest


# --- 测试方法 ---

## 验证自动刷新可为首位玩家分配键鼠。
func test_refresh_assigns_keyboard_mouse() -> void:
	var utility := GFInputDeviceUtility.new()
	utility.max_players = 1
	utility.include_keyboard_mouse = true
	utility.include_touch = false

	utility.refresh_connected_devices()
	var assignment := utility.get_assignment(0)

	assert_not_null(assignment, "0 号玩家应获得默认键鼠映射。")
	assert_eq(assignment.device_type, GFInputDeviceAssignment.DeviceType.KEYBOARD_MOUSE, "默认映射应为键鼠。")
	assert_eq(utility.get_assignments().size(), 1, "max_players 为 1 时只应返回一个映射。")


## 验证手动映射会替换同一玩家并保持排序。
func test_set_assignment_replaces_same_player() -> void:
	var utility := GFInputDeviceUtility.new()
	utility.include_keyboard_mouse = false
	utility.include_touch = false

	utility.set_assignment(utility.create_assignment(2, GFInputDeviceAssignment.DeviceType.AI, -1))
	utility.set_assignment(utility.create_assignment(0, GFInputDeviceAssignment.DeviceType.CUSTOM, 77))
	utility.set_assignment(utility.create_assignment(2, GFInputDeviceAssignment.DeviceType.JOYPAD, 3))

	var assignments := utility.get_assignments()

	assert_eq(assignments[0].player_index, 0, "映射应按玩家索引排序。")
	assert_eq(assignments[1].player_index, 2, "替换后仍应保留玩家索引。")
	assert_eq(assignments[1].device_type, GFInputDeviceAssignment.DeviceType.JOYPAD, "同玩家映射应被替换。")
	assert_eq(assignments[1].device_id, 3, "替换后的设备 ID 应生效。")


## 验证返回的映射是拷贝，避免外部直接污染内部表。
func test_get_assignments_returns_copies() -> void:
	var utility := GFInputDeviceUtility.new()
	utility.include_keyboard_mouse = false
	utility.include_touch = false
	utility.set_assignment(utility.create_assignment(0, GFInputDeviceAssignment.DeviceType.CUSTOM, 9))

	var assignments := utility.get_assignments()
	assignments[0].device_id = 999

	assert_eq(utility.get_assignment(0).device_id, 9, "外部修改副本不应影响内部映射。")
