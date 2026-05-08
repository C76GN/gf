## GFInteractionSensor: 通用交互发送节点。
##
## 负责构建 GFInteractionContext，并把交互请求发送给具备 receive_interaction()
## 方法的接收对象。发送者、目标、payload 和分组均保持通用，不绑定具体玩法。
class_name GFInteractionSensor
extends Node


# --- 信号 ---

## 交互已发送。
## @param context: 交互上下文。
## @param receiver: 接收对象。
## @param report: 结果报告。
signal interaction_sent(context: GFInteractionContext, receiver: Object, report: Dictionary)

## 交互被接收对象接受。
## @param context: 交互上下文。
## @param receiver: 接收对象。
## @param report: 结果报告。
signal interaction_accepted(context: GFInteractionContext, receiver: Object, report: Dictionary)

## 交互被接收对象拒绝或发送失败。
## @param context: 交互上下文。
## @param receiver: 接收对象。
## @param report: 结果报告。
signal interaction_rejected(context: GFInteractionContext, receiver: Object, report: Dictionary)


# --- 导出变量 ---

## 是否允许发送交互。
@export var enabled: bool = true

## 默认交互 ID。
@export var interaction_id: StringName = &""

## 默认交互分组。
@export var group_name: StringName = &""

## 默认 payload；发送时会深拷贝。
@export var payload: Dictionary = {}

## 发送器自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}

## 可选发送者路径；为空时使用当前节点。
@export_node_path("Node") var sender_path: NodePath = NodePath("")


# --- 公共方法 ---

## 构建交互上下文。
## @param target: 交互目标。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param group_override: 覆盖分组；为空时使用节点默认分组。
## @return 交互上下文。
func build_context(
	target: Object = null,
	payload_override: Variant = null,
	group_override: StringName = &""
) -> GFInteractionContext:
	var context_payload: Variant = payload.duplicate(true) if payload_override == null else _duplicate_variant(payload_override)
	var context_group := group_override if group_override != &"" else group_name
	var context := GFInteractionContext.new(_resolve_sender(), target, context_payload, context_group)
	return context


## 向指定接收对象发送交互。
## @param receiver: 接收对象。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param interaction_id_override: 覆盖交互 ID；为空时使用节点默认交互 ID。
## @return 统一结果报告。
func send_to(
	receiver: Object,
	payload_override: Variant = null,
	interaction_id_override: StringName = &""
) -> Dictionary:
	var effective_interaction_id := interaction_id_override if interaction_id_override != &"" else interaction_id
	var context := build_context(receiver, payload_override)
	var report := _dispatch_to_receiver(context, receiver, effective_interaction_id)
	_emit_send_result(context, receiver, report)
	return report


## 向指定节点路径发送交互。
## @param receiver_path: 接收节点路径。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param interaction_id_override: 覆盖交互 ID；为空时使用节点默认交互 ID。
## @return 统一结果报告。
func send_to_path(
	receiver_path: NodePath,
	payload_override: Variant = null,
	interaction_id_override: StringName = &""
) -> Dictionary:
	var receiver := get_node_or_null(receiver_path)
	return send_to(receiver, payload_override, interaction_id_override)


## 向场景树分组中的接收对象广播交互。
## @param target_group_name: 目标分组；为空时使用节点默认分组。
## @param max_count: 最多发送数量；小于等于 0 表示不限制。
## @return 结果报告列表。
func broadcast_to_group(target_group_name: StringName = &"", max_count: int = 0) -> Array[Dictionary]:
	var effective_group := target_group_name if target_group_name != &"" else group_name
	var reports: Array[Dictionary] = []
	if effective_group == &"" or get_tree() == null:
		return reports

	var receivers := get_tree().get_nodes_in_group(String(effective_group))
	for receiver: Node in receivers:
		if max_count > 0 and reports.size() >= max_count:
			break
		reports.append(send_to(receiver))
	return reports


## 向 RayCast2D 当前命中的接收对象发送交互。
## @param raycast: RayCast2D 节点。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param interaction_id_override: 覆盖交互 ID；为空时使用节点默认交互 ID。
## @return 统一结果报告。
func send_to_raycast_2d(
	raycast: RayCast2D,
	payload_override: Variant = null,
	interaction_id_override: StringName = &""
) -> Dictionary:
	if raycast == null or not raycast.is_colliding():
		return _make_report(false, interaction_id_override if interaction_id_override != &"" else interaction_id, "missing_receiver", "RayCast2D is not colliding.")
	return send_to(_resolve_interaction_receiver(raycast.get_collider()), payload_override, interaction_id_override)


## 向 RayCast3D 当前命中的接收对象发送交互。
## @param raycast: RayCast3D 节点。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param interaction_id_override: 覆盖交互 ID；为空时使用节点默认交互 ID。
## @return 统一结果报告。
func send_to_raycast_3d(
	raycast: RayCast3D,
	payload_override: Variant = null,
	interaction_id_override: StringName = &""
) -> Dictionary:
	if raycast == null or not raycast.is_colliding():
		return _make_report(false, interaction_id_override if interaction_id_override != &"" else interaction_id, "missing_receiver", "RayCast3D is not colliding.")
	return send_to(_resolve_interaction_receiver(raycast.get_collider()), payload_override, interaction_id_override)


## 向 Area2D 当前重叠的接收对象批量发送交互。
## @param area: Area2D 节点。
## @param max_count: 最多发送数量；小于等于 0 表示不限制。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param interaction_id_override: 覆盖交互 ID；为空时使用节点默认交互 ID。
## @return 结果报告列表。
func broadcast_to_area_2d(
	area: Area2D,
	max_count: int = 0,
	payload_override: Variant = null,
	interaction_id_override: StringName = &""
) -> Array[Dictionary]:
	if area == null:
		return []
	var candidates: Array = []
	candidates.append_array(area.get_overlapping_areas())
	candidates.append_array(area.get_overlapping_bodies())
	return _send_to_collision_candidates(candidates, max_count, payload_override, interaction_id_override)


## 向 Area3D 当前重叠的接收对象批量发送交互。
## @param area: Area3D 节点。
## @param max_count: 最多发送数量；小于等于 0 表示不限制。
## @param payload_override: 覆盖 payload；为 null 时使用节点默认 payload。
## @param interaction_id_override: 覆盖交互 ID；为空时使用节点默认交互 ID。
## @return 结果报告列表。
func broadcast_to_area_3d(
	area: Area3D,
	max_count: int = 0,
	payload_override: Variant = null,
	interaction_id_override: StringName = &""
) -> Array[Dictionary]:
	if area == null:
		return []
	var candidates: Array = []
	candidates.append_array(area.get_overlapping_areas())
	candidates.append_array(area.get_overlapping_bodies())
	return _send_to_collision_candidates(candidates, max_count, payload_override, interaction_id_override)


# --- 私有/辅助方法 ---

func _dispatch_to_receiver(context: GFInteractionContext, receiver: Object, effective_interaction_id: StringName) -> Dictionary:
	if not enabled:
		return _make_report(false, effective_interaction_id, "disabled", "Interaction sensor is disabled.")
	if receiver == null:
		return _make_report(false, effective_interaction_id, "missing_receiver", "Interaction receiver is null.")
	if not receiver.has_method("receive_interaction"):
		return _make_report(false, effective_interaction_id, "invalid_receiver", "Receiver does not expose receive_interaction().")

	var value: Variant = receiver.call("receive_interaction", context, effective_interaction_id)
	return (value as Dictionary).duplicate(true) if value is Dictionary else _make_report(
		false,
		effective_interaction_id,
		"invalid_report",
		"Receiver returned an invalid interaction report."
	)


func _emit_send_result(context: GFInteractionContext, receiver: Object, report: Dictionary) -> void:
	interaction_sent.emit(context, receiver, report)
	if bool(report.get("ok", false)):
		interaction_accepted.emit(context, receiver, report)
	else:
		interaction_rejected.emit(context, receiver, report)


func _send_to_collision_candidates(
	candidates: Array,
	max_count: int,
	payload_override: Variant,
	interaction_id_override: StringName
) -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	var visited_receivers: Dictionary = {}
	for candidate: Object in candidates:
		if max_count > 0 and reports.size() >= max_count:
			break

		var receiver := _resolve_interaction_receiver(candidate)
		if receiver == null:
			continue
		var receiver_id := receiver.get_instance_id()
		if visited_receivers.has(receiver_id):
			continue
		visited_receivers[receiver_id] = true
		reports.append(send_to(receiver, payload_override, interaction_id_override))
	return reports


func _resolve_interaction_receiver(candidate: Object) -> Object:
	if candidate == null:
		return null
	if candidate.has_method("receive_interaction"):
		return candidate

	var node := candidate as Node
	while node != null:
		if node.has_method("receive_interaction"):
			return node
		node = node.get_parent()
	return null


func _make_report(ok: bool, effective_interaction_id: StringName, reason: String, message: String) -> Dictionary:
	return {
		"ok": ok,
		"interaction_id": effective_interaction_id,
		"receiver": null,
		"reason": reason,
		"message": message,
		"metadata": metadata.duplicate(true),
	}


func _resolve_sender() -> Object:
	if sender_path != NodePath(""):
		var sender := get_node_or_null(sender_path)
		if sender != null:
			return sender
	return self


func _duplicate_variant(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
