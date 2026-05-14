## GFProjectileConePattern3D: 3D 水平扇形发射点模式。
##
## 围绕发射器局部 Y 轴分布 yaw，可叠加固定 pitch，并按变换前向生成点位。
class_name GFProjectileConePattern3D
extends GFProjectileSpawnPattern3D


# --- 导出变量 ---

## 默认发射数量。
@export_range(1, 256, 1) var projectile_count: int = 1

## 总水平扩散角度（度）。
@export var yaw_spread_degrees: float = 0.0

## 额外俯仰角度（度）。
@export var pitch_degrees: float = 0.0

## 生成点距离发射器的半径。
@export var radius: float = 0.0


# --- 虚方法（由子类重写） ---

func _get_spawn_transforms(
	emitter: Node3D,
	_projectile_context: Dictionary = {},
	emit_count: int = -1
) -> Array[Transform3D]:
	if emitter == null:
		return []

	var count := _resolve_count(projectile_count, emit_count)
	var result: Array[Transform3D] = []
	var yaw_spread := deg_to_rad(yaw_spread_degrees)
	var pitch := deg_to_rad(pitch_degrees)
	for index: int in range(count):
		var factor := 0.5
		if count > 1:
			factor = float(index) / float(count - 1)
		var yaw := (factor - 0.5) * yaw_spread
		var basis := emitter.global_basis * Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pitch)
		var direction := -basis.z.normalized()
		var position := emitter.global_position + direction * maxf(radius, 0.0)
		result.append(Transform3D(basis, position))
	return result
