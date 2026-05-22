## GFHurtBox2D: 2D 通用命中接收区域。
##
## 节点只过滤和接收 GFCombatHitContext，不直接修改生命、属性或 Buff。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFHurtBox2D
extends Area2D


# --- 信号 ---

## 命中进入自定义校验阶段时发出。
## [br]
## @api public
## [br]
## @param context: 命中上下文。
## [br]
## @param report: 当前结果报告副本。
## [br]
## @schema report: Dictionary，当前命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。
signal hit_validating(context: GFCombatHitContext, report: Dictionary)

## 命中被接受时发出。
## [br]
## @api public
## [br]
## @param context: 命中上下文。
## [br]
## @param report: 结果报告。
## [br]
## @schema report: Dictionary，统一命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。
signal hit_received(context: GFCombatHitContext, report: Dictionary)

## 命中被拒绝时发出。
## [br]
## @api public
## [br]
## @param context: 命中上下文。
## [br]
## @param report: 结果报告。
## [br]
## @schema report: Dictionary，统一命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。
signal hit_rejected(context: GFCombatHitContext, report: Dictionary)

## 启用状态变化时发出。
## [br]
## @api public
## [br]
## @param enabled: 当前是否允许接收命中。
signal enabled_changed(enabled: bool)


# --- 常量 ---

const _MESSAGE_RECEIVER_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_message_receiver_support.gd")
const _GENERATED_COLLISION_SHAPE_NODE_NAME: StringName = &"GFGeneratedCollisionShape2D"


# --- 导出变量 ---

## 是否允许接收命中。
## [br]
## @api public
@export var enabled: bool = true:
	set(value):
		if enabled == value:
			return
		enabled = value
		enabled_changed.emit(enabled)

## 非空时，只接受这些命中 ID。
## [br]
## @api public
@export var accepted_hit_ids: Array[StringName] = []

## 始终拒绝的命中 ID。
## [br]
## @api public
@export var rejected_hit_ids: Array[StringName] = []

## 接收器自定义元数据。框架不解释该字段。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，接收器自定义命中元数据；会进入命中接收报告。
@export var metadata: Dictionary = {}

## 可选业务接收节点路径；为空时由当前 HurtBox 直接接收。
## [br]
## @api public
@export_node_path("Node") var receiver_path: NodePath = NodePath("")

## 可选碰撞形状配置。设置后可自动生成或更新 CollisionShape2D 子节点。
## [br]
## @api public
@export var collision_shape_config: GFHitCollisionShapeConfig2D = null:
	get:
		return _collision_shape_config
	set(value):
		_collision_shape_config = value
		if is_inside_tree() and auto_apply_collision_shape_config:
			_apply_collision_shape_config(_collision_shape_config)

## 可选碰撞形状配置列表。非空时可自动生成或更新多个 CollisionShape2D 子节点。
## [br]
## @api public
@export var collision_shape_configs: Array[GFHitCollisionShapeConfig2D] = []:
	get:
		return _collision_shape_configs
	set(value):
		_collision_shape_configs = value
		if is_inside_tree() and auto_apply_collision_shape_config:
			_apply_collision_shape_configs(_collision_shape_configs)

## 是否在进入场景树或配置变化时自动应用碰撞形状配置。
## [br]
## @api public
@export var auto_apply_collision_shape_config: bool = true


# --- 公共变量 ---

## 自定义校验回调，建议签名为 func(context: GFCombatHitContext, report: Dictionary) -> Variant。
## 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。
## [br]
## @api public
var validation_callback: Callable = Callable()


# --- 私有变量 ---

var _collision_shape_config: GFHitCollisionShapeConfig2D = null
var _collision_shape_configs: Array[GFHitCollisionShapeConfig2D] = []


# --- Godot 生命周期方法 ---

func _ready() -> void:
	if auto_apply_collision_shape_config:
		if _collision_shape_configs.is_empty():
			apply_collision_shape_config()
		else:
			apply_collision_shape_configs()


# --- 公共方法 ---

## 应用碰撞形状配置，创建或更新框架管理的 CollisionShape2D 子节点。
## [br]
## @api public
## [br]
## @param config: 可选配置；为空时使用 collision_shape_config。
## [br]
## @return 创建或更新的 CollisionShape2D；配置无效时返回 null。
func apply_collision_shape_config(config: GFHitCollisionShapeConfig2D = null) -> CollisionShape2D:
	if config != null:
		_collision_shape_config = config
	return _apply_collision_shape_config(_collision_shape_config)


## 应用碰撞形状配置列表，创建或更新框架管理的多个 CollisionShape2D 子节点。
## [br]
## @api public
## [br]
## @param configs: 可选配置列表；为空时使用 collision_shape_configs。
## [br]
## @return 创建或更新的 CollisionShape2D 列表。
func apply_collision_shape_configs(configs: Array[GFHitCollisionShapeConfig2D] = []) -> Array[CollisionShape2D]:
	if not configs.is_empty():
		_collision_shape_configs = configs
	return _apply_collision_shape_configs(_collision_shape_configs)


## 获取框架管理的 CollisionShape2D 子节点。
## [br]
## @api public
## [br]
## @return 存在则返回 CollisionShape2D，否则返回 null。
func get_generated_collision_shape() -> CollisionShape2D:
	return get_node_or_null(String(_GENERATED_COLLISION_SHAPE_NODE_NAME)) as CollisionShape2D


## 获取框架管理的 CollisionShape2D 子节点列表。
## [br]
## @api public
## [br]
## @return 已生成的 CollisionShape2D 列表。
func get_generated_collision_shapes() -> Array[CollisionShape2D]:
	var result: Array[CollisionShape2D] = []
	for child: Node in get_children():
		var collision_shape := child as CollisionShape2D
		if collision_shape != null and String(collision_shape.name).begins_with(String(_GENERATED_COLLISION_SHAPE_NODE_NAME)):
			result.append(collision_shape)
	return result


## 移除框架管理的 CollisionShape2D 子节点。
## [br]
## @api public
func clear_generated_collision_shape() -> void:
	clear_generated_collision_shapes()


## 移除框架管理的全部 CollisionShape2D 子节点。
## [br]
## @api public
func clear_generated_collision_shapes() -> void:
	for collision_shape: CollisionShape2D in get_generated_collision_shapes():
		remove_child(collision_shape)
		collision_shape.queue_free()


## 检查指定命中 ID 是否可被当前接收器接受。
## [br]
## @api public
## [br]
## @param p_hit_id: 命中 ID。
## [br]
## @return 可接受时返回 true。
func can_receive_hit(p_hit_id: StringName = &"") -> bool:
	if not bool(_MESSAGE_RECEIVER_SUPPORT._can_receive(enabled, accepted_hit_ids, rejected_hit_ids, p_hit_id)):
		return false
	if receiver_path == NodePath(""):
		return true
	var receiver := _resolve_receiver()
	return receiver != null


## 接收一次命中。
## [br]
## @api public
## [br]
## @param context: 命中上下文。
## [br]
## @return 统一结果报告。
## [br]
## @schema return: Dictionary，统一命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。
func receive_hit(context: GFCombatHitContext) -> Dictionary:
	var hit_id_value := context.hit_id if context != null else &""
	var receiver := _resolve_receiver()
	var has_receiver_path := receiver_path != NodePath("")
	var report: Dictionary = _MESSAGE_RECEIVER_SUPPORT._receive_with_delegate(
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
		"Hit id is not accepted.",
		has_receiver_path,
		receiver,
		&"receive_hit",
		[context],
		"Hit delegate receiver is missing.",
		"Hit delegate receiver returned an invalid hit report."
	) as Dictionary
	return report


# --- 私有/辅助方法 ---

func _resolve_receiver() -> Object:
	if receiver_path == NodePath(""):
		return null
	var receiver := get_node_or_null(receiver_path)
	if receiver == self:
		return null
	return receiver


func _apply_collision_shape_config(config: GFHitCollisionShapeConfig2D) -> CollisionShape2D:
	var configs: Array[GFHitCollisionShapeConfig2D] = []
	if config != null:
		configs.append(config)
	var generated_shapes := _apply_collision_shape_configs(configs)
	if generated_shapes.is_empty():
		return null
	return generated_shapes[0]


func _apply_collision_shape_configs(configs: Array[GFHitCollisionShapeConfig2D]) -> Array[CollisionShape2D]:
	var generated_shapes: Array[CollisionShape2D] = []
	var generated_index := 0
	for config: GFHitCollisionShapeConfig2D in configs:
		if config == null or config.shape == null:
			continue

		var collision_shape := _get_or_create_collision_shape(generated_index)
		if config.apply_to(collision_shape):
			generated_shapes.append(collision_shape)
			generated_index += 1

	_clear_generated_collision_shapes_from_index(generated_index)
	return generated_shapes


func _get_or_create_collision_shape(index: int = 0) -> CollisionShape2D:
	var collision_shape := get_node_or_null(_get_generated_collision_shape_name(index)) as CollisionShape2D
	if collision_shape != null:
		return collision_shape

	collision_shape = CollisionShape2D.new()
	collision_shape.name = _get_generated_collision_shape_name(index)
	add_child(collision_shape)
	return collision_shape


func _clear_generated_collision_shapes_from_index(start_index: int) -> void:
	var index := start_index
	while true:
		var collision_shape := get_node_or_null(_get_generated_collision_shape_name(index)) as CollisionShape2D
		if collision_shape == null:
			return
		remove_child(collision_shape)
		collision_shape.queue_free()
		index += 1


func _get_generated_collision_shape_name(index: int) -> String:
	if index <= 0:
		return String(_GENERATED_COLLISION_SHAPE_NODE_NAME)
	return "%s%d" % [String(_GENERATED_COLLISION_SHAPE_NODE_NAME), index + 1]
