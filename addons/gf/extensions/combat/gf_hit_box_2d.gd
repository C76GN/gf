## GFHitBox2D: 2D 通用命中发送区域。
##
## 节点负责构建 GFCombatHitContext 并发送给具备 receive_hit() 的接收对象，
## 不规定伤害、阵营、冷却、命中特效或生命值规则。
class_name GFHitBox2D
extends Area2D


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


# --- 常量 ---

const _MESSAGE_DISPATCH_SUPPORT: Script = preload("res://addons/gf/extensions/common/gf_message_dispatch_support.gd")


# --- 导出变量 ---

## 是否允许发送命中。
@export var enabled: bool = true

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


# --- 公共方法 ---

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
	var context_payload: Variant = payload.duplicate(true) if payload_override == null else GFVariantUtility.duplicate_variant(payload_override)
	var effective_hit_id := hit_id_override if hit_id_override != &"" else hit_id
	var context := GFCombatHitContext.new(_resolve_sender(), target, context_payload, effective_hit_id)
	context.magnitude = magnitude
	context.tags = tags.duplicate()
	context.position_2d = global_position
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
