## GFInputModifier: 输入值修饰器基类。
##
## 修饰器只处理输入值转换，不决定动作是否触发。可挂在 GFInputBinding 或
## GFInputMapping 上，用于死区、缩放、归一化、范围映射等通用处理。
class_name GFInputModifier
extends Resource


# --- 公共方法 ---

## 修饰输入贡献值。
## @param value: 当前二维贡献值；布尔与一维轴使用 x 分量。
## @param _event: 产生该贡献的原生输入事件，可能为 null。
## @param _action: 当前输入动作。
## @return 修饰后的贡献值。
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
	return value


## 修饰三维输入贡献值。
## 默认复用二维修饰逻辑处理 X/Y，并保留 Z 分量。
## @param value: 当前三维贡献值。
## @param event: 产生该贡献的原生输入事件，可能为 null。
## @param action: 当前输入动作。
## @return 修饰后的三维贡献值。
func modify_3d(value: Vector3, event: InputEvent = null, action: GFInputAction = null) -> Vector3:
	var xy := modify(Vector2(value.x, value.y), event, action)
	return Vector3(xy.x, xy.y, value.z)


## 创建运行时副本。
## @return 修饰器副本。
func duplicate_modifier() -> GFInputModifier:
	return duplicate(true) as GFInputModifier
