## GFInputDeviceAssignment: 玩家与输入设备的通用映射。
##
## 仅描述设备归属，不绑定任何具体输入动作。
class_name GFInputDeviceAssignment
extends Resource


# --- 枚举 ---

## 输入设备类型。
enum DeviceType {
	KEYBOARD_MOUSE,
	JOYPAD,
	TOUCH,
	AI,
	CUSTOM,
}


# --- 导出变量 ---

## 玩家或本地席位索引。
@export var player_index: int = 0

## 设备类型。
@export var device_type: DeviceType = DeviceType.KEYBOARD_MOUSE

## Godot 输入设备 ID。键鼠通常为 0，虚拟/AI 可使用 -1。
@export var device_id: int = 0

## 自定义元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 创建一个浅拷贝。
## @return 新的设备映射。
func duplicate_assignment() -> GFInputDeviceAssignment:
	var assignment := GFInputDeviceAssignment.new()
	assignment.player_index = player_index
	assignment.device_type = device_type
	assignment.device_id = device_id
	assignment.metadata = metadata.duplicate(true)
	return assignment

