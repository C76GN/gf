## GFInputMapRangeModifier: 输入范围映射修饰器。
##
## 将输入分量从一个数值范围线性映射到另一个范围，适合灵敏度曲线前后的
## 简单归一化处理。
class_name GFInputMapRangeModifier
extends GFInputModifier


# --- 导出变量 ---

## 输入最小值。
@export var input_min: float = 0.0

## 输入最大值。
@export var input_max: float = 1.0

## 输出最小值。
@export var output_min: float = 0.0

## 输出最大值。
@export var output_max: float = 1.0

## 是否限制输出到目标范围内。
@export var clamp_output: bool = true


# --- 公共方法 ---

## 修改二维输入值。
## @param value: 要写入或修改的值。
## @param _event: 原始输入事件，默认实现不直接使用。
## @param _action: 当前输入动作配置，默认实现不直接使用。
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
	return Vector2(_map_value(value.x), _map_value(value.y))


## 修改三维输入值。
## @param value: 要写入或修改的值。
## @param _event: 原始输入事件，默认实现不直接使用。
## @param _action: 当前输入动作配置，默认实现不直接使用。
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
	return Vector3(_map_value(value.x), _map_value(value.y), _map_value(value.z))


# --- 私有/辅助方法 ---

func _map_value(value: float) -> float:
	var input_range := input_max - input_min
	if is_zero_approx(input_range):
		return output_min

	var t := (value - input_min) / input_range
	var mapped := lerpf(output_min, output_max, t)
	if not clamp_output:
		return mapped

	var min_value := minf(output_min, output_max)
	var max_value := maxf(output_min, output_max)
	return clampf(mapped, min_value, max_value)
