## GFHomingProjectileMotion: 2D/3D 通用追踪发射体移动策略。
##
## 目标可通过 launch() 上下文中的 target、target_position、target_position_2d
## 或 target_position_3d 传入，也可以用 target_path 从发射体节点相对查找。
class_name GFHomingProjectileMotion
extends "res://addons/gf/extensions/official/combat/projectiles/gf_projectile_motion.gd"


# --- 常量 ---

const _DIRECTION_2D_KEY: StringName = &"homing_direction_2d"
const _DIRECTION_3D_KEY: StringName = &"homing_direction_3d"


# --- 导出变量 ---

## 每秒移动距离。
@export var speed: float = 0.0

## 可选目标节点路径。为空时只读取 projectile_context。
@export var target_path: NodePath = NodePath("")

## 从 projectile_context 读取目标对象或位置的键。
@export var target_context_key: StringName = &"target"

## 从 projectile_context 读取通用目标位置的键。
@export var target_position_context_key: StringName = &"target_position"

## 到目标的距离小于等于该值时视为到达。小于 0 表示不标记到达。
@export var arrival_distance: float = 0.0

## 是否每帧重新朝向当前目标。关闭后只在首次解析目标时锁定方向。
@export var track_target: bool = true

## 到达目标范围时是否停止并夹住位移，避免越过目标。
@export var stop_when_reached: bool = true


# --- 虚方法（由子类重写） ---

func _setup(projectile: Node, projectile_context: Dictionary = {}) -> void:
	if projectile is Node2D:
		_cache_direction_2d(projectile as Node2D, projectile_context)
	elif projectile is Node3D:
		_cache_direction_3d(projectile as Node3D, projectile_context)


func _step(projectile: Node, delta: float, projectile_context: Dictionary = {}) -> void:
	if delta <= 0.0:
		return
	if projectile is Node2D:
		_step_2d(projectile as Node2D, delta, projectile_context)
	elif projectile is Node3D:
		_step_3d(projectile as Node3D, delta, projectile_context)


# --- 私有/辅助方法 ---

func _step_2d(projectile: Node2D, delta: float, projectile_context: Dictionary) -> void:
	var target_position_variant := _get_target_position_2d(projectile, projectile_context)
	if not (target_position_variant is Vector2):
		projectile_context["target_missing"] = true
		projectile_context["velocity_2d"] = Vector2.ZERO
		return

	var target_position := target_position_variant as Vector2
	var current_position := _get_projectile_position_2d(projectile)
	var offset := target_position - current_position
	var distance := offset.length()
	projectile_context["target_distance_2d"] = distance
	if _is_arrived(distance):
		projectile_context["target_reached"] = true
		projectile_context["velocity_2d"] = Vector2.ZERO
		if stop_when_reached:
			return

	var direction := _get_direction_2d(offset, projectile_context)
	if direction.is_zero_approx():
		projectile_context["velocity_2d"] = Vector2.ZERO
		return

	var travel_distance := speed * delta
	if stop_when_reached and arrival_distance >= 0.0:
		travel_distance = minf(travel_distance, maxf(distance - arrival_distance, 0.0))

	var velocity := direction * (travel_distance / delta)
	_set_projectile_position_2d(projectile, current_position + direction * travel_distance)
	projectile_context["velocity_2d"] = velocity
	if _is_arrived(distance - travel_distance):
		projectile_context["target_reached"] = true


func _step_3d(projectile: Node3D, delta: float, projectile_context: Dictionary) -> void:
	var target_position_variant := _get_target_position_3d(projectile, projectile_context)
	if not (target_position_variant is Vector3):
		projectile_context["target_missing"] = true
		projectile_context["velocity_3d"] = Vector3.ZERO
		return

	var target_position := target_position_variant as Vector3
	var current_position := _get_projectile_position_3d(projectile)
	var offset := target_position - current_position
	var distance := offset.length()
	projectile_context["target_distance_3d"] = distance
	if _is_arrived(distance):
		projectile_context["target_reached"] = true
		projectile_context["velocity_3d"] = Vector3.ZERO
		if stop_when_reached:
			return

	var direction := _get_direction_3d(offset, projectile_context)
	if direction.is_zero_approx():
		projectile_context["velocity_3d"] = Vector3.ZERO
		return

	var travel_distance := speed * delta
	if stop_when_reached and arrival_distance >= 0.0:
		travel_distance = minf(travel_distance, maxf(distance - arrival_distance, 0.0))

	var velocity := direction * (travel_distance / delta)
	_set_projectile_position_3d(projectile, current_position + direction * travel_distance)
	projectile_context["velocity_3d"] = velocity
	if _is_arrived(distance - travel_distance):
		projectile_context["target_reached"] = true


func _cache_direction_2d(projectile: Node2D, projectile_context: Dictionary) -> void:
	var target_position_variant := _get_target_position_2d(projectile, projectile_context)
	if not (target_position_variant is Vector2):
		return
	var offset := (target_position_variant as Vector2) - _get_projectile_position_2d(projectile)
	if not offset.is_zero_approx():
		projectile_context[_DIRECTION_2D_KEY] = offset.normalized()


func _cache_direction_3d(projectile: Node3D, projectile_context: Dictionary) -> void:
	var target_position_variant := _get_target_position_3d(projectile, projectile_context)
	if not (target_position_variant is Vector3):
		return
	var offset := (target_position_variant as Vector3) - _get_projectile_position_3d(projectile)
	if not offset.is_zero_approx():
		projectile_context[_DIRECTION_3D_KEY] = offset.normalized()


func _get_direction_2d(offset: Vector2, projectile_context: Dictionary) -> Vector2:
	if track_target or not projectile_context.has(_DIRECTION_2D_KEY):
		if offset.is_zero_approx():
			return Vector2.ZERO
		var direction := offset.normalized()
		projectile_context[_DIRECTION_2D_KEY] = direction
		return direction

	var cached_direction: Variant = projectile_context.get(_DIRECTION_2D_KEY, Vector2.ZERO)
	if cached_direction is Vector2 and not (cached_direction as Vector2).is_zero_approx():
		return (cached_direction as Vector2).normalized()
	return Vector2.ZERO


func _get_direction_3d(offset: Vector3, projectile_context: Dictionary) -> Vector3:
	if track_target or not projectile_context.has(_DIRECTION_3D_KEY):
		if offset.is_zero_approx():
			return Vector3.ZERO
		var direction := offset.normalized()
		projectile_context[_DIRECTION_3D_KEY] = direction
		return direction

	var cached_direction: Variant = projectile_context.get(_DIRECTION_3D_KEY, Vector3.ZERO)
	if cached_direction is Vector3 and not (cached_direction as Vector3).is_zero_approx():
		return (cached_direction as Vector3).normalized()
	return Vector3.ZERO


func _get_target_position_2d(projectile: Node2D, projectile_context: Dictionary) -> Variant:
	if projectile_context.has(&"target_position_2d"):
		var typed_position: Variant = projectile_context.get(&"target_position_2d")
		if typed_position is Vector2:
			return typed_position

	var common_position: Variant = projectile_context.get(target_position_context_key)
	if common_position is Vector2:
		return common_position

	var target: Variant = projectile_context.get(target_context_key)
	if target is Vector2:
		return target
	if target is Node2D:
		var target_2d := target as Node2D
		return target_2d.global_position if target_2d.is_inside_tree() else target_2d.position

	var path_target := _get_path_target(projectile)
	if path_target is Node2D:
		var path_target_2d := path_target as Node2D
		return path_target_2d.global_position if path_target_2d.is_inside_tree() else path_target_2d.position
	return null


func _get_target_position_3d(projectile: Node3D, projectile_context: Dictionary) -> Variant:
	if projectile_context.has(&"target_position_3d"):
		var typed_position: Variant = projectile_context.get(&"target_position_3d")
		if typed_position is Vector3:
			return typed_position

	var common_position: Variant = projectile_context.get(target_position_context_key)
	if common_position is Vector3:
		return common_position

	var target: Variant = projectile_context.get(target_context_key)
	if target is Vector3:
		return target
	if target is Node3D:
		var target_3d := target as Node3D
		return target_3d.global_position if target_3d.is_inside_tree() else target_3d.position

	var path_target := _get_path_target(projectile)
	if path_target is Node3D:
		var path_target_3d := path_target as Node3D
		return path_target_3d.global_position if path_target_3d.is_inside_tree() else path_target_3d.position
	return null


func _get_path_target(projectile: Node) -> Node:
	if target_path == NodePath(""):
		return null
	return projectile.get_node_or_null(target_path)


func _get_projectile_position_2d(projectile: Node2D) -> Vector2:
	return projectile.global_position if projectile.is_inside_tree() else projectile.position


func _set_projectile_position_2d(projectile: Node2D, position: Vector2) -> void:
	if projectile.is_inside_tree():
		projectile.global_position = position
	else:
		projectile.position = position


func _get_projectile_position_3d(projectile: Node3D) -> Vector3:
	return projectile.global_position if projectile.is_inside_tree() else projectile.position


func _set_projectile_position_3d(projectile: Node3D, position: Vector3) -> void:
	if projectile.is_inside_tree():
		projectile.global_position = position
	else:
		projectile.position = position


func _is_arrived(distance: float) -> bool:
	return arrival_distance >= 0.0 and distance <= arrival_distance
