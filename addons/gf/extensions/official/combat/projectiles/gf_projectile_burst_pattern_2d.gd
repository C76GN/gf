## GFProjectileBurstPattern2D: 2D 扇形/环形发射点模式。
##
## 通过数量、角度和半径生成一组通用发射变换，适合散射、圆环、扇形或单点发射。
class_name GFProjectileBurstPattern2D
extends GFProjectileSpawnPattern2D


# --- 导出变量 ---

## 默认发射数量。
@export_range(1, 256, 1) var projectile_count: int = 1

## 总扩散角度（度）。数量大于 1 时在该范围内均匀分布。
@export var spread_degrees: float = 0.0

## 相对发射器朝向的中心角度（度）。
@export var center_angle_degrees: float = 0.0

## 生成点距离发射器的半径。
@export var radius: float = 0.0

## 生成变换是否朝向对应发射方向。
@export var rotate_to_direction: bool = true

## 是否把发射器自身旋转计入方向。
@export var include_emitter_rotation: bool = true


# --- 虚方法（由子类重写） ---

func _get_spawn_transforms(
	emitter: Node2D,
	_projectile_context: Dictionary = {},
	emit_count: int = -1
) -> Array[Transform2D]:
	if emitter == null:
		return []

	var count := _resolve_count(projectile_count, emit_count)
	var result: Array[Transform2D] = []
	var base_angle := emitter.global_rotation if include_emitter_rotation else 0.0
	var center_angle := base_angle + deg_to_rad(center_angle_degrees)
	var spread := deg_to_rad(spread_degrees)
	for index: int in range(count):
		var factor := 0.5
		if count > 1:
			factor = float(index) / float(count - 1)
		var angle := center_angle + ((factor - 0.5) * spread)
		var direction := Vector2.RIGHT.rotated(angle)
		var position := emitter.global_position + direction * maxf(radius, 0.0)
		var rotation := angle if rotate_to_direction else emitter.global_rotation
		result.append(Transform2D(rotation, position))
	return result
