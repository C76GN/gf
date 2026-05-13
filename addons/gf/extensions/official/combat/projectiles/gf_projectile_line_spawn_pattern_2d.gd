## GFProjectileLineSpawnPattern2D: 沿 2D 局部线段生成发射点。
##
## 只描述发射点分布，适合多炮口、线性随机点或沿武器边缘生成发射体。
class_name GFProjectileLineSpawnPattern2D
extends GFProjectileSpawnPattern2D


# --- 导出变量 ---

## 默认发射数量。
@export_range(1, 256, 1) var point_count: int = 1

## 线段局部起点。
@export var local_start: Vector2 = Vector2.ZERO

## 线段局部终点。
@export var local_end: Vector2 = Vector2.ZERO

## 生成变换是否朝向线段方向。
@export var rotate_to_line: bool = false


# --- 虚方法（由子类重写） ---

func _get_spawn_transforms(
	emitter: Node2D,
	_projectile_context: Dictionary = {},
	emit_count: int = -1
) -> Array[Transform2D]:
	if emitter == null:
		return []

	var count := _resolve_count(point_count, emit_count)
	var result: Array[Transform2D] = []
	var local_direction := local_end - local_start
	var rotation := emitter.global_rotation
	if rotate_to_line and not local_direction.is_zero_approx():
		rotation += local_direction.angle()
	for index: int in range(count):
		var factor := 0.5
		if count > 1:
			factor = float(index) / float(count - 1)
		var local_position := local_start.lerp(local_end, factor)
		result.append(Transform2D(rotation, emitter.to_global(local_position)))
	return result
