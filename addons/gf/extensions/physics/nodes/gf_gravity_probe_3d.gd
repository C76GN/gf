## GFGravityProbe3D: 通用 3D 重力采样器。
##
## 从场景树分组中采样 GFGravityField3D 或任何暴露 get_acceleration_at()
## 方法的对象，并汇总为当前节点位置处的加速度、上下方向。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFGravityProbe3D
extends Node3D


# --- 导出变量 ---

## 要采样的力场分组。
## [br]
## @api public
@export var field_group: StringName = &"gf_gravity_field_3d"

## 找不到力场时是否返回 fallback_acceleration。
## [br]
## @api public
@export var use_fallback_when_empty: bool = true

## 找不到力场时使用的默认加速度。
## [br]
## @api public
@export var fallback_acceleration: Vector3 = Vector3.DOWN * 9.8

## 同一帧、同一位置重复 sample() 时是否复用上次结果。
## [br]
## @api public
@export var cache_samples_per_frame: bool = true


# --- 公共变量 ---

## 最近一次 sample() 得到的加速度。
## [br]
## @api public
var last_acceleration: Vector3 = Vector3.ZERO


# --- 私有变量 ---

var _cached_process_frame: int = -1
var _cached_physics_frame: int = -1
var _cached_position: Vector3 = Vector3.ZERO
var _cached_field_group: StringName = &""


# --- 公共方法 ---

## 采样场景树分组中的所有力场。
## [br]
## @api public
## [br]
## @return 汇总后的加速度。
func sample() -> Vector3:
	if _can_use_cached_sample():
		return last_acceleration

	if get_tree() == null or field_group == &"":
		last_acceleration = fallback_acceleration if use_fallback_when_empty else Vector3.ZERO
		_store_sample_cache()
		return last_acceleration

	var fields := get_tree().get_nodes_in_group(String(field_group))
	last_acceleration = sample_fields(fields)
	_store_sample_cache()
	return last_acceleration


## 采样指定力场列表。
## [br]
## @api public
## [br]
## @param fields: 力场对象列表。
## [br]
## @schema fields: Array，包含 GFGravityField3D 或任何暴露 get_acceleration_at(Vector3) 的 Object。
## [br]
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
## [br]
## @api public
## [br]
## @return 向下方向。
func get_down_direction() -> Vector3:
	var acceleration := last_acceleration
	if acceleration.is_zero_approx():
		acceleration = sample()
	if acceleration.is_zero_approx():
		return Vector3.DOWN
	return acceleration.normalized()


## 获取当前位置的向上方向。
## [br]
## @api public
## [br]
## @return 向上方向。
func get_up_direction() -> Vector3:
	return -get_down_direction()


# --- 私有/辅助方法 ---

func _can_use_cached_sample() -> bool:
	return (
		cache_samples_per_frame
		and _cached_process_frame == Engine.get_process_frames()
		and _cached_physics_frame == Engine.get_physics_frames()
		and _cached_field_group == field_group
		and _cached_position == global_position
	)


func _store_sample_cache() -> void:
	_cached_process_frame = Engine.get_process_frames()
	_cached_physics_frame = Engine.get_physics_frames()
	_cached_field_group = field_group
	_cached_position = global_position
