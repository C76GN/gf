## GFGravityProbe3D: 通用 3D 重力采样器。
##
## 从场景树分组中采样 GFGravityField3D 或任何暴露 get_acceleration_at()
## 方法的对象，并汇总为当前节点位置处的加速度、上下方向。
class_name GFGravityProbe3D
extends Node3D


# --- 导出变量 ---

## 要采样的力场分组。
@export var field_group: StringName = &"gf_gravity_field_3d"

## 找不到力场时是否返回 fallback_acceleration。
@export var use_fallback_when_empty: bool = true

## 找不到力场时使用的默认加速度。
@export var fallback_acceleration: Vector3 = Vector3.DOWN * 9.8


# --- 公共变量 ---

## 最近一次 sample() 得到的加速度。
var last_acceleration: Vector3 = Vector3.ZERO


# --- 公共方法 ---

## 采样场景树分组中的所有力场。
## @return 汇总后的加速度。
func sample() -> Vector3:
	if get_tree() == null or field_group == &"":
		last_acceleration = fallback_acceleration if use_fallback_when_empty else Vector3.ZERO
		return last_acceleration

	var fields := get_tree().get_nodes_in_group(String(field_group))
	last_acceleration = sample_fields(fields)
	return last_acceleration


## 采样指定力场列表。
## @param fields: 力场对象列表。
## @return 汇总后的加速度。
func sample_fields(fields: Array) -> Vector3:
	var acceleration_sum := Vector3.ZERO
	var sampled_count := 0
	for field: Object in fields:
		if field == null or not field.has_method("get_acceleration_at"):
			continue
		var value: Variant = field.call("get_acceleration_at", global_position)
		if value is Vector3:
			acceleration_sum += value
			sampled_count += 1

	if sampled_count == 0 and use_fallback_when_empty:
		return fallback_acceleration
	return acceleration_sum


## 获取当前位置的向下方向。
## @return 向下方向。
func get_down_direction() -> Vector3:
	var acceleration := last_acceleration
	if acceleration.is_zero_approx():
		acceleration = sample()
	if acceleration.is_zero_approx():
		return Vector3.DOWN
	return acceleration.normalized()


## 获取当前位置的向上方向。
## @return 向上方向。
func get_up_direction() -> Vector3:
	return -get_down_direction()
