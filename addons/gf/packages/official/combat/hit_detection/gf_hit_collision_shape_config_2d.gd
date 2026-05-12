## GFHitCollisionShapeConfig2D: 2D 命中区域碰撞形状配置。
##
## 用于把可复用的 Shape2D、偏移、旋转、缩放和禁用状态应用到 HitBox / HurtBox
## 自动生成的 CollisionShape2D 上。不表达伤害、阵营或其他玩法规则。
class_name GFHitCollisionShapeConfig2D
extends Resource


# --- 导出变量 ---

## 要应用的 Godot 2D 碰撞形状。
@export var shape: Shape2D = null

## 碰撞形状相对 HitBox / HurtBox 节点的位置。
@export var position: Vector2 = Vector2.ZERO

## 碰撞形状相对 HitBox / HurtBox 节点的旋转角度。
@export var rotation_degrees: float = 0.0

## 碰撞形状相对 HitBox / HurtBox 节点的缩放。
@export var scale: Vector2 = Vector2.ONE

## 是否禁用生成的 CollisionShape2D。
@export var disabled: bool = false


# --- 公共方法 ---

## 将配置应用到指定 CollisionShape2D。
## @param collision_shape: 目标 CollisionShape2D。
## @return 应用成功返回 true。
func apply_to(collision_shape: CollisionShape2D) -> bool:
	if collision_shape == null or shape == null:
		return false

	collision_shape.shape = shape
	collision_shape.position = position
	collision_shape.rotation_degrees = rotation_degrees
	collision_shape.scale = scale
	collision_shape.disabled = disabled
	return true


## 创建一个已应用当前配置的 CollisionShape2D。
## @return 创建成功返回 CollisionShape2D；配置缺少 shape 时返回 null。
func instantiate_collision_shape() -> CollisionShape2D:
	if shape == null:
		return null

	var collision_shape := CollisionShape2D.new()
	apply_to(collision_shape)
	return collision_shape
