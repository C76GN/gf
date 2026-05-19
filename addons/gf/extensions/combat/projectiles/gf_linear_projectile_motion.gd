## GFLinearProjectileMotion: 2D/3D 通用直线发射体移动策略。
##
## 该策略只处理线性位移，不处理碰撞、伤害、生命周期或目标选择。
class_name GFLinearProjectileMotion
extends GFProjectileMotion


# --- 导出变量 ---

## 每秒移动距离。
@export var speed: float = 0.0

## 2D 方向。use_local_direction 为 true 时按发射体当前变换转换。
@export var direction_2d: Vector2 = Vector2.RIGHT

## 3D 方向。use_local_direction 为 true 时按发射体当前变换转换。
@export var direction_3d: Vector3 = Vector3.FORWARD

## 是否把方向视为发射体本地坐标。
@export var use_local_direction: bool = true

## 是否归一化方向。
@export var normalize_direction: bool = true


# --- 虚方法（由子类重写） ---

func _step(projectile: Node, delta: float, projectile_context: Dictionary = {}) -> void:
	if projectile is Node2D:
		_step_2d(projectile as Node2D, delta, projectile_context)
	elif projectile is Node3D:
		_step_3d(projectile as Node3D, delta, projectile_context)


# --- 私有/辅助方法 ---

func _step_2d(projectile: Node2D, delta: float, projectile_context: Dictionary) -> void:
	var direction := direction_2d
	if use_local_direction:
		var transform := projectile.global_transform if projectile.is_inside_tree() else projectile.transform
		direction = transform.x * direction_2d.x + transform.y * direction_2d.y
	if normalize_direction and not direction.is_zero_approx():
		direction = direction.normalized()

	var velocity := direction * speed
	if projectile.is_inside_tree():
		projectile.global_position += velocity * delta
	else:
		projectile.position += velocity * delta
	projectile_context["velocity_2d"] = velocity


func _step_3d(projectile: Node3D, delta: float, projectile_context: Dictionary) -> void:
	var direction := direction_3d
	if use_local_direction:
		var transform := projectile.global_transform if projectile.is_inside_tree() else projectile.transform
		direction = transform.basis * direction_3d
	if normalize_direction and not direction.is_zero_approx():
		direction = direction.normalized()

	var velocity := direction * speed
	if projectile.is_inside_tree():
		projectile.global_position += velocity * delta
	else:
		projectile.position += velocity * delta
	projectile_context["velocity_3d"] = velocity
