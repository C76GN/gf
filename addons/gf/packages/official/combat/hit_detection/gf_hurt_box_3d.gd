## GFHurtBox3D: 3D 通用命中接收区域。
##
## 节点只过滤和接收 GFCombatHitContext，不直接修改生命、属性或 Buff。
class_name GFHurtBox3D
extends Area3D


# --- 信号 ---

## 命中进入自定义校验阶段时发出。
## @param context: 命中上下文。
## @param report: 当前结果报告副本。
signal hit_validating(context: GFCombatHitContext, report: Dictionary)

## 命中被接受时发出。
## @param context: 命中上下文。
## @param report: 结果报告。
signal hit_received(context: GFCombatHitContext, report: Dictionary)

## 命中被拒绝时发出。
## @param context: 命中上下文。
## @param report: 结果报告。
signal hit_rejected(context: GFCombatHitContext, report: Dictionary)

## 启用状态变化时发出。
## @param enabled: 当前是否允许接收命中。
signal enabled_changed(enabled: bool)


# --- 常量 ---

const _MESSAGE_RECEIVER_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_message_receiver_support.gd")
const _GENERATED_COLLISION_SHAPE_NODE_NAME: StringName = &"GFGeneratedCollisionShape3D"


# --- 导出变量 ---

## 是否允许接收命中。
@export var enabled: bool = true:
	set(value):
		if enabled == value:
			return
		enabled = value
		enabled_changed.emit(enabled)

## 非空时，只接受这些命中 ID。
@export var accepted_hit_ids: Array[StringName] = []

## 始终拒绝的命中 ID。
@export var rejected_hit_ids: Array[StringName] = []

## 接收器自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}

## 可选碰撞形状配置。设置后可自动生成或更新 CollisionShape3D 子节点。
@export var collision_shape_config: GFHitCollisionShapeConfig3D = null:
	get:
		return _collision_shape_config
	set(value):
		_collision_shape_config = value
		if is_inside_tree() and auto_apply_collision_shape_config:
			_apply_collision_shape_config(_collision_shape_config)

## 是否在进入场景树或配置变化时自动应用碰撞形状配置。
@export var auto_apply_collision_shape_config: bool = true


# --- 公共变量 ---

## 自定义校验回调，建议签名为 func(context: GFCombatHitContext, report: Dictionary) -> Variant。
## 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。
var validation_callback: Callable = Callable()


# --- 私有变量 ---

var _collision_shape_config: GFHitCollisionShapeConfig3D = null


# --- Godot 生命周期方法 ---

func _ready() -> void:
	if auto_apply_collision_shape_config:
		apply_collision_shape_config()


# --- 公共方法 ---

## 应用碰撞形状配置，创建或更新框架管理的 CollisionShape3D 子节点。
## @param config: 可选配置；为空时使用 collision_shape_config。
## @return 创建或更新的 CollisionShape3D；配置无效时返回 null。
func apply_collision_shape_config(config: GFHitCollisionShapeConfig3D = null) -> CollisionShape3D:
	if config != null:
		_collision_shape_config = config
	return _apply_collision_shape_config(_collision_shape_config)


## 获取框架管理的 CollisionShape3D 子节点。
## @return 存在则返回 CollisionShape3D，否则返回 null。
func get_generated_collision_shape() -> CollisionShape3D:
	return get_node_or_null(String(_GENERATED_COLLISION_SHAPE_NODE_NAME)) as CollisionShape3D


## 移除框架管理的 CollisionShape3D 子节点。
func clear_generated_collision_shape() -> void:
	var collision_shape := get_generated_collision_shape()
	if collision_shape == null:
		return
	remove_child(collision_shape)
	collision_shape.queue_free()


## 检查指定命中 ID 是否可被当前接收器接受。
## @param p_hit_id: 命中 ID。
## @return 可接受时返回 true。
func can_receive_hit(p_hit_id: StringName = &"") -> bool:
	return bool(_MESSAGE_RECEIVER_SUPPORT._can_receive(enabled, accepted_hit_ids, rejected_hit_ids, p_hit_id))


## 接收一次命中。
## @param context: 命中上下文。
## @return 统一结果报告。
func receive_hit(context: GFCombatHitContext) -> Dictionary:
	var hit_id_value := context.hit_id if context != null else &""
	var report: Dictionary = _MESSAGE_RECEIVER_SUPPORT._receive(
		self,
		context,
		"hit_id",
		hit_id_value,
		enabled,
		accepted_hit_ids,
		rejected_hit_ids,
		metadata,
		validation_callback,
		&"hit_validating",
		&"hit_received",
		&"hit_rejected",
		"Hit context is null.",
		"Hurt box is disabled.",
		"Hit id is rejected.",
		"Hit id is not accepted."
	) as Dictionary
	return report


# --- 私有/辅助方法 ---

func _apply_collision_shape_config(config: GFHitCollisionShapeConfig3D) -> CollisionShape3D:
	if config == null or config.shape == null:
		clear_generated_collision_shape()
		return null

	var collision_shape := _get_or_create_collision_shape()
	if not config.apply_to(collision_shape):
		clear_generated_collision_shape()
		return null
	return collision_shape


func _get_or_create_collision_shape() -> CollisionShape3D:
	var collision_shape := get_generated_collision_shape()
	if collision_shape != null:
		return collision_shape

	collision_shape = CollisionShape3D.new()
	collision_shape.name = String(_GENERATED_COLLISION_SHAPE_NODE_NAME)
	add_child(collision_shape)
	return collision_shape
