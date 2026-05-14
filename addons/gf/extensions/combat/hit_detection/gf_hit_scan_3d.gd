## GFHitScan3D: 3D 通用射线命中发送器。
##
## 基于 RayCast3D 构建 GFCombatHitContext 并发送给具备 receive_hit() 的接收对象。
## 它不规定伤害、穿透、命中特效或任何业务规则。
class_name GFHitScan3D
extends RayCast3D


# --- 信号 ---

## 扫描命中对象后发出。
## @param context: 命中上下文。
## @param receiver: 接收对象。
## @param report: 结果报告。
signal scan_hit(context: GFCombatHitContext, receiver: Object, report: Dictionary)

## 扫描没有命中可发送对象时发出。
## @param report: 结果报告。
signal scan_missed(report: Dictionary)

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

const _MESSAGE_DISPATCH_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_message_dispatch_support.gd")


# --- 导出变量 ---

## 是否允许发送命中。
@export var hit_enabled: bool = true

## 扫描前是否强制刷新射线。
@export var force_update_before_scan: bool = true

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
	var context_payload: Variant = payload.duplicate(true) if payload_override == null else GFVariantData.duplicate_variant(payload_override)
	var effective_hit_id := hit_id_override if hit_id_override != &"" else hit_id
	var context := GFCombatHitContext.new(_resolve_sender(), target, context_payload, effective_hit_id)
	context.magnitude = magnitude
	context.tags = tags.duplicate()
	context.position_3d = get_collision_point() if is_colliding() else global_position
	context.normal_3d = get_collision_normal() if is_colliding() else Vector3.ZERO
	context.metadata = metadata.duplicate(true)
	return context


## 执行一次射线扫描并尝试发送命中。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param hit_id_override: 覆盖命中 ID；为空时使用节点默认命中 ID。
## @return 统一结果报告。
func scan(payload_override: Variant = null, hit_id_override: StringName = &"") -> Dictionary:
	if force_update_before_scan:
		force_raycast_update()
	if not hit_enabled:
		return _emit_missed(&"disabled")
	if not is_colliding():
		return _emit_missed(&"no_collision")

	var receiver := get_collider()
	var context := build_hit_context(receiver, payload_override, hit_id_override)
	var report: Dictionary = _MESSAGE_DISPATCH_SUPPORT._dispatch_to_receiver(
		hit_enabled,
		metadata,
		receiver,
		&"receive_hit",
		[context],
		"hit_id",
		context.hit_id,
		"Hit scan is disabled.",
		"Hit scan receiver is null.",
		"Receiver does not expose receive_hit().",
		"Receiver returned an invalid hit report."
	) as Dictionary
	_emit_scan_result(context, receiver, report)
	return report


# --- 私有/辅助方法 ---

func _emit_missed(reason: StringName) -> Dictionary:
	var report := {
		"ok": false,
		"reason": reason,
		"metadata": metadata.duplicate(true),
	}
	scan_missed.emit(report)
	return report


func _emit_scan_result(context: GFCombatHitContext, receiver: Object, report: Dictionary) -> void:
	scan_hit.emit(context, receiver, report)
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
