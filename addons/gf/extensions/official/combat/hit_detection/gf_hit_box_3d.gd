## GFHitBox3D: 3D 通用命中发送区域。
##
## 节点负责构建 GFCombatHitContext 并发送给具备 receive_hit() 的接收对象，
## 不规定伤害、阵营、冷却、命中特效或生命值规则。
class_name GFHitBox3D
extends Area3D


# --- 信号 ---

## 命中已发送。
## @param context: 命中上下文。
## @param receiver: 接收对象。
## @param report: 结果报告。
signal hit_sent(context: GFCombatHitContext, receiver: Object, report: Dictionary)

## 命中被接收对象接受。
## @param context: 命中上下文。
## @param receiver: 接收对象。
## @param report: 结果报告。
signal hit_accepted(context: GFCombatHitContext, receiver: Object, report: Dictionary)

## 命中被接收对象拒绝或发送失败。
## @param context: 命中上下文。
## @param receiver: 接收对象。
## @param report: 结果报告。
signal hit_rejected(context: GFCombatHitContext, receiver: Object, report: Dictionary)

## 启用状态变化时发出。
## @param enabled: 当前是否允许发送命中。
signal enabled_changed(enabled: bool)


# --- 常量 ---

const _MESSAGE_DISPATCH_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_message_dispatch_support.gd")
const _GENERATED_COLLISION_SHAPE_NODE_NAME: StringName = &"GFGeneratedCollisionShape3D"


# --- 导出变量 ---

## 是否允许发送命中。
@export var enabled: bool = true:
	set(value):
		if enabled == value:
			return
		enabled = value
		enabled_changed.emit(enabled)

## 默认命中 ID。
@export var hit_id: StringName = &""

## 默认 payload；发送时会深拷贝。
@export var payload: Dictionary = {}

## 通用强度值。框架不解释该字段。
@export var magnitude: float = 0.0

## 命中标签。框架不解释该字段。
@export var tags: Array[StringName] = []

## 发送器自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}

## 可选发送者路径；为空时使用当前节点。
@export_node_path("Node") var sender_path: NodePath = NodePath("")

## 可选碰撞形状配置。设置后可自动生成或更新 CollisionShape3D 子节点。
@export var collision_shape_config: GFHitCollisionShapeConfig3D = null:
	get:
		return _collision_shape_config
	set(value):
		_collision_shape_config = value
		if is_inside_tree() and auto_apply_collision_shape_config:
			_apply_collision_shape_config(_collision_shape_config)

## 可选碰撞形状配置列表。非空时可自动生成或更新多个 CollisionShape3D 子节点。
@export var collision_shape_configs: Array[GFHitCollisionShapeConfig3D] = []:
	get:
		return _collision_shape_configs
	set(value):
		_collision_shape_configs = value
		if is_inside_tree() and auto_apply_collision_shape_config:
			_apply_collision_shape_configs(_collision_shape_configs)

## 是否在进入场景树或配置变化时自动应用碰撞形状配置。
@export var auto_apply_collision_shape_config: bool = true


# --- 私有变量 ---

var _collision_shape_config: GFHitCollisionShapeConfig3D = null
var _collision_shape_configs: Array[GFHitCollisionShapeConfig3D] = []


# --- Godot 生命周期方法 ---

func _ready() -> void:
	if auto_apply_collision_shape_config:
		if _collision_shape_configs.is_empty():
			apply_collision_shape_config()
		else:
			apply_collision_shape_configs()


# --- 公共方法 ---

## 应用碰撞形状配置，创建或更新框架管理的 CollisionShape3D 子节点。
## @param config: 可选配置；为空时使用 collision_shape_config。
## @return 创建或更新的 CollisionShape3D；配置无效时返回 null。
func apply_collision_shape_config(config: GFHitCollisionShapeConfig3D = null) -> CollisionShape3D:
	if config != null:
		_collision_shape_config = config
	return _apply_collision_shape_config(_collision_shape_config)


## 应用碰撞形状配置列表，创建或更新框架管理的多个 CollisionShape3D 子节点。
## @param configs: 可选配置列表；为空时使用 collision_shape_configs。
## @return 创建或更新的 CollisionShape3D 列表。
func apply_collision_shape_configs(configs: Array[GFHitCollisionShapeConfig3D] = []) -> Array[CollisionShape3D]:
	if not configs.is_empty():
		_collision_shape_configs = configs
	return _apply_collision_shape_configs(_collision_shape_configs)


## 获取框架管理的 CollisionShape3D 子节点。
## @return 存在则返回 CollisionShape3D，否则返回 null。
func get_generated_collision_shape() -> CollisionShape3D:
	return get_node_or_null(String(_GENERATED_COLLISION_SHAPE_NODE_NAME)) as CollisionShape3D


## 获取框架管理的 CollisionShape3D 子节点列表。
## @return 已生成的 CollisionShape3D 列表。
func get_generated_collision_shapes() -> Array[CollisionShape3D]:
	var result: Array[CollisionShape3D] = []
	for child: Node in get_children():
		var collision_shape := child as CollisionShape3D
		if collision_shape != null and String(collision_shape.name).begins_with(String(_GENERATED_COLLISION_SHAPE_NODE_NAME)):
			result.append(collision_shape)
	return result


## 移除框架管理的 CollisionShape3D 子节点。
func clear_generated_collision_shape() -> void:
	clear_generated_collision_shapes()


## 移除框架管理的全部 CollisionShape3D 子节点。
func clear_generated_collision_shapes() -> void:
	for collision_shape: CollisionShape3D in get_generated_collision_shapes():
		remove_child(collision_shape)
		collision_shape.queue_free()


## 构建命中上下文。
## @param target: 命中目标。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param hit_id_override: 覆盖命中 ID；为空时使用节点默认命中 ID。
## @return 命中上下文。
func build_hit_context(
	target: Object = null,
	payload_override: Variant = null,
	hit_id_override: StringName = &""
) -> GFCombatHitContext:
	var context_payload: Variant = payload.duplicate(true) if payload_override == null else GFVariantData.duplicate_variant(payload_override)
	var effective_hit_id := hit_id_override if hit_id_override != &"" else hit_id
	var context := GFCombatHitContext.new(_resolve_sender(), target, context_payload, effective_hit_id)
	context.magnitude = magnitude
	context.tags = tags.duplicate()
	context.position_3d = global_position
	context.metadata = metadata.duplicate(true)
	return context


## 向指定接收对象发送命中。
## @param receiver: 接收对象。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param hit_id_override: 覆盖命中 ID；为空时使用节点默认命中 ID。
## @return 统一结果报告。
func send_to(
	receiver: Object,
	payload_override: Variant = null,
	hit_id_override: StringName = &""
) -> Dictionary:
	var context := build_hit_context(receiver, payload_override, hit_id_override)
	var report: Dictionary = _MESSAGE_DISPATCH_SUPPORT._dispatch_to_receiver(
		enabled,
		metadata,
		receiver,
		&"receive_hit",
		[context],
		"hit_id",
		context.hit_id,
		"Hit box is disabled.",
		"Hit receiver is null.",
		"Receiver does not expose receive_hit().",
		"Receiver returned an invalid hit report."
	) as Dictionary
	_emit_send_result(context, receiver, report)
	return report


## 向指定节点路径发送命中。
## @param receiver_path: 接收节点路径。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param hit_id_override: 覆盖命中 ID；为空时使用节点默认命中 ID。
## @return 统一结果报告。
func send_to_path(
	receiver_path: NodePath,
	payload_override: Variant = null,
	hit_id_override: StringName = &""
) -> Dictionary:
	var receiver := get_node_or_null(receiver_path)
	return send_to(receiver, payload_override, hit_id_override)


## 向当前重叠对象中的命中接收器批量发送命中。
## @param max_count: 最多发送数量；小于等于 0 表示不限制。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param hit_id_override: 覆盖命中 ID；为空时使用节点默认命中 ID。
## @return 结果报告列表。
func broadcast_overlaps(
	max_count: int = 0,
	payload_override: Variant = null,
	hit_id_override: StringName = &""
) -> Array[Dictionary]:
	var candidates: Array = []
	candidates.append_array(get_overlapping_areas())
	candidates.append_array(get_overlapping_bodies())
	var reports: Array[Dictionary] = []
	reports.assign(_MESSAGE_DISPATCH_SUPPORT._send_to_collision_candidates(
		self,
		candidates,
		max_count,
		payload_override,
		hit_id_override,
		&"receive_hit"
	))
	return reports


# --- 私有/辅助方法 ---

func _emit_send_result(context: GFCombatHitContext, receiver: Object, report: Dictionary) -> void:
	hit_sent.emit(context, receiver, report)
	if bool(report.get("ok", false)):
		hit_accepted.emit(context, receiver, report)
	else:
		hit_rejected.emit(context, receiver, report)


func _resolve_sender() -> Object:
	if sender_path != NodePath(""):
		var sender := get_node_or_null(sender_path)
		if sender != null:
			return sender
	return self


func _apply_collision_shape_config(config: GFHitCollisionShapeConfig3D) -> CollisionShape3D:
	var configs: Array[GFHitCollisionShapeConfig3D] = []
	if config != null:
		configs.append(config)
	var generated_shapes := _apply_collision_shape_configs(configs)
	if generated_shapes.is_empty():
		return null
	return generated_shapes[0]


func _apply_collision_shape_configs(configs: Array[GFHitCollisionShapeConfig3D]) -> Array[CollisionShape3D]:
	var generated_shapes: Array[CollisionShape3D] = []
	var generated_index := 0
	for config: GFHitCollisionShapeConfig3D in configs:
		if config == null or config.shape == null:
			continue

		var collision_shape := _get_or_create_collision_shape(generated_index)
		if config.apply_to(collision_shape):
			generated_shapes.append(collision_shape)
			generated_index += 1

	_clear_generated_collision_shapes_from_index(generated_index)
	return generated_shapes


func _get_or_create_collision_shape(index: int = 0) -> CollisionShape3D:
	var collision_shape := get_node_or_null(_get_generated_collision_shape_name(index)) as CollisionShape3D
	if collision_shape != null:
		return collision_shape

	collision_shape = CollisionShape3D.new()
	collision_shape.name = _get_generated_collision_shape_name(index)
	add_child(collision_shape)
	return collision_shape


func _clear_generated_collision_shapes_from_index(start_index: int) -> void:
	var index := start_index
	while true:
		var collision_shape := get_node_or_null(_get_generated_collision_shape_name(index)) as CollisionShape3D
		if collision_shape == null:
			return
		remove_child(collision_shape)
		collision_shape.queue_free()
		index += 1


func _get_generated_collision_shape_name(index: int) -> String:
	if index <= 0:
		return String(_GENERATED_COLLISION_SHAPE_NODE_NAME)
	return "%s%d" % [String(_GENERATED_COLLISION_SHAPE_NODE_NAME), index + 1]
