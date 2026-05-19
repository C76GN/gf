## 扩展消息发送节点共享实现。
##
## 该脚本供命中、交互等场景桥接节点复用，不直接作为用户继承入口。
extends RefCounted


# --- 私有/辅助方法 ---

static func _dispatch_to_receiver(
	enabled: bool,
	metadata: Dictionary,
	receiver: Object,
	receiver_method: StringName,
	call_args: Array,
	id_key: String,
	id_value: StringName,
	disabled_message: String,
	missing_receiver_message: String,
	invalid_receiver_message: String,
	invalid_report_message: String
) -> Dictionary:
	if not enabled:
		return _make_report(false, id_key, id_value, "disabled", disabled_message, metadata)
	if receiver == null:
		return _make_report(false, id_key, id_value, "missing_receiver", missing_receiver_message, metadata)
	if not receiver.has_method(receiver_method):
		return _make_report(false, id_key, id_value, "invalid_receiver", invalid_receiver_message, metadata)

	var value: Variant = receiver.callv(receiver_method, call_args)
	return GFVariantData.duplicate_variant(value) if value is Dictionary else _make_report(
		false,
		id_key,
		id_value,
		"invalid_report",
		invalid_report_message,
		metadata
	)


static func _send_to_collision_candidates(
	dispatch_host: Object,
	candidates: Array,
	max_count: int,
	payload_override: Variant,
	id_override: StringName,
	receiver_method: StringName,
	send_result_callback: Callable = Callable()
) -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	var visited_receivers: Dictionary = {}
	for candidate: Object in candidates:
		if max_count > 0 and reports.size() >= max_count:
			break

		var receiver := _resolve_receiver(candidate, receiver_method)
		if receiver == null:
			continue
		var receiver_id := receiver.get_instance_id()
		if visited_receivers.has(receiver_id):
			continue
		visited_receivers[receiver_id] = true

		var report := dispatch_host.call("send_to", receiver, payload_override, id_override) as Dictionary
		if report != null:
			reports.append(report)
			if send_result_callback.is_valid():
				send_result_callback.call(receiver, payload_override, id_override, report)
	return reports


static func _resolve_receiver(candidate: Object, receiver_method: StringName) -> Object:
	if candidate == null:
		return null
	if candidate.has_method(receiver_method):
		return candidate

	var node := candidate as Node
	while node != null:
		if node.has_method(receiver_method):
			return node
		node = node.get_parent()
	return null


static func _make_report(
	ok: bool,
	id_key: String,
	id_value: StringName,
	reason: String,
	message: String,
	metadata: Dictionary
) -> Dictionary:
	return {
		"ok": ok,
		id_key: id_value,
		"receiver": null,
		"reason": reason,
		"message": message,
		"metadata": metadata.duplicate(true),
	}
