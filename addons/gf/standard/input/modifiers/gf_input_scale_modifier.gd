## GFInputScaleModifier: 输入缩放修饰器。
##
## 适合统一调节轴灵敏度、反转某个方向或压低虚拟摇杆输出。
class_name GFInputScaleModifier
extends GFInputModifier


# --- 导出变量 ---

## X 分量缩放。
@export var scale_x: float = 1.0

## Y 分量缩放。
@export var scale_y: float = 1.0

## Z 分量缩放，仅用于三维轴动作。
@export var scale_z: float = 1.0


# --- 公共方法 ---

## 修改二维输入值。
## @param value: 要写入或修改的值。
## @param _event: 原始输入事件，默认实现不直接使用。
## @param _action: 当前输入动作配置，默认实现不直接使用。
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
	return Vector2(value.x * scale_x, value.y * scale_y)


## 修改三维输入值。
## @param value: 要写入或修改的值。
## @param _event: 原始输入事件，默认实现不直接使用。
## @param _action: 当前输入动作配置，默认实现不直接使用。
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
	return Vector3(value.x * scale_x, value.y * scale_y, value.z * scale_z)
