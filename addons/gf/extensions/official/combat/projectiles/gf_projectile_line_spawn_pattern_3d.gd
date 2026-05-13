## GFProjectileLineSpawnPattern3D: 沿 3D 局部线段生成发射点。
##
## 只描述发射点分布，适合多炮口、轨道点或沿空间线段生成发射体。
class_name GFProjectileLineSpawnPattern3D
extends GFProjectileSpawnPattern3D


# --- 导出变量 ---

## 默认发射数量。
@export_range(1, 256, 1) var point_count: int = 1

## 线段局部起点。
@export var local_start: Vector3 = Vector3.ZERO

## 线段局部终点。
@export var local_end: Vector3 = Vector3.ZERO

## 生成变换是否朝向线段方向。
@export var rotate_to_line: bool = false


# --- 虚方法（由子类重写） ---

func _get_spawn_transforms(
	emitter: Node3D,
	_projectile_context: Dictionary = {},
	emit_count: int = -1
) -> Array[Transform3D]:
	if emitter == null:
		return []

	var count := _resolve_count(point_count, emit_count)
	var result: Array[Transform3D] = []
	var basis := emitter.global_basis
	var local_direction := local_end - local_start
	if rotate_to_line and not local_direction.is_zero_approx():
		var global_direction := emitter.global_basis * local_direction.normalized()
		basis = Basis.looking_at(global_direction, Vector3.UP)
	for index: int in range(count):
		var factor := 0.5
		if count > 1:
			factor = float(index) / float(count - 1)
		var local_position := local_start.lerp(local_end, factor)
		result.append(Transform3D(basis, emitter.to_global(local_position)))
	return result
