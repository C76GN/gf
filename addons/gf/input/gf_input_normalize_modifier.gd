## GFInputNormalizeModifier: 输入归一化修饰器。
##
## 可避免多个方向叠加后超过单位长度，也可强制非零输入变成单位向量。
class_name GFInputNormalizeModifier
extends GFInputModifier


# --- 导出变量 ---

## 只在长度超过 1 时归一化；关闭后任何非零输入都会归一化。
@export var only_when_over_one: bool = true


# --- 公共方法 ---

func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
	var length := value.length()
	if length <= 0.0001:
		return Vector2.ZERO
	if only_when_over_one and length <= 1.0:
		return value
	return value / length


func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
	var length := value.length()
	if length <= 0.0001:
		return Vector3.ZERO
	if only_when_over_one and length <= 1.0:
		return value
	return value / length
