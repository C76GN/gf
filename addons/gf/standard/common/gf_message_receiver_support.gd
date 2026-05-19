## 扩展消息接收节点共享实现。
##
## 该脚本供命中、交互等通用接收节点复用，不直接作为用户继承入口。
extends RefCounted


# --- 私有/辅助方法 ---

static func _can_receive(
	enabled: bool,
	accepted_ids: Array[StringName],
	rejected_ids: Array[StringName],
	id_value: StringName = &""
) -> bool:
	if not enabled:
		return false
	if rejected_ids.has(id_value):
		return false
	if accepted_ids.is_empty():
		return true
	return accepted_ids.has(id_value)


static func _receive(
	signal_owner: Object,
	context: Object,
	id_key: String,
	id_value: StringName,
	enabled: bool,
	accepted_ids: Array[StringName],
	rejected_ids: Array[StringName],
	metadata: Dictionary,
	validation_callback: Callable,
	validating_signal: StringName,
	received_signal: StringName,
	rejected_signal: StringName,
	invalid_context_message: String,
	disabled_message: String,
	rejected_id_message: String,
	unaccepted_id_message: String
) -> Dictionary:
	return _receive_with_delegate(
		signal_owner,
		context,
		id_key,
		id_value,
		enabled,
		accepted_ids,
		rejected_ids,
		metadata,
		validation_callback,
		validating_signal,
		received_signal,
		rejected_signal,
		invalid_context_message,
		disabled_message,
		rejected_id_message,
		unaccepted_id_message,
		false,
		null,
		&"",
		[],
		"",
		""
	)


static func _receive_with_delegate(
	signal_owner: Object,
	context: Object,
	id_key: String,
	id_value: StringName,
	enabled: bool,
	accepted_ids: Array[StringName],
	rejected_ids: Array[StringName],
	metadata: Dictionary,
	validation_callback: Callable,
	validating_signal: StringName,
	received_signal: StringName,
	rejected_signal: StringName,
	invalid_context_message: String,
	disabled_message: String,
	rejected_id_message: String,
	unaccepted_id_message: String,
	delegate_enabled: bool,
	delegate_receiver: Object,
	delegate_method: StringName,
	delegate_args: Array,
	missing_delegate_message: String,
	invalid_delegate_report_message: String,
	target_property: StringName = &"target"
) -> Dictionary:
	if context == null:
		var invalid_context_report := _make_report(
			signal_owner,
			false,
			id_key,
			id_value,
			"invalid_context",
			invalid_context_message,
			metadata
		)
		signal_owner.emit_signal(rejected_signal, context, invalid_context_report)
		return invalid_context_report

	if not enabled:
		var disabled_report := _make_report(
			signal_owner,
			false,
			id_key,
			id_value,
			"disabled",
			disabled_message,
			metadata
		)
		signal_owner.emit_signal(rejected_signal, context, disabled_report)
		return disabled_report

	if rejected_ids.has(id_value):
		var rejected_report := _make_report(
			signal_owner,
			false,
			id_key,
			id_value,
			"rejected_id",
			rejected_id_message,
			metadata
		)
		signal_owner.emit_signal(rejected_signal, context, rejected_report)
		return rejected_report

	if not accepted_ids.is_empty() and not accepted_ids.has(id_value):
		var blocked_report := _make_report(
			signal_owner,
			false,
			id_key,
			id_value,
			"unaccepted_id",
			unaccepted_id_message,
			metadata
		)
		signal_owner.emit_signal(rejected_signal, context, blocked_report)
		return blocked_report

	if delegate_enabled and delegate_receiver == null:
		var missing_delegate_report := _make_report(null, false, id_key, id_value, "missing_receiver", missing_delegate_message, metadata)
		signal_owner.emit_signal(rejected_signal, context, missing_delegate_report)
		return missing_delegate_report

	var effective_receiver := delegate_receiver if delegate_enabled else signal_owner
	var target_key := String(target_property)
	if context.get(target_key) == null or context.get(target_key) == signal_owner:
		context.set(target_key, effective_receiver)

	var report := _make_report(effective_receiver, true, id_key, id_value, "accepted", "", metadata)
	signal_owner.emit_signal(validating_signal, context, report.duplicate(true))
	if validation_callback.is_valid():
		report = _apply_validation_result(report, validation_callback.call(context, report.duplicate(true)))

	if bool(report.get("ok", false)) and delegate_enabled and delegate_receiver.has_method(delegate_method):
		var delegated_value: Variant = delegate_receiver.callv(delegate_method, delegate_args)
		if delegated_value is Dictionary:
			report = GFVariantData.duplicate_variant(delegated_value)
		elif delegated_value is bool:
			report = _apply_validation_result(report, delegated_value)
		elif delegated_value == null:
			pass
		else:
			report = _make_report(
				delegate_receiver,
				false,
				id_key,
				id_value,
				"invalid_report",
				invalid_delegate_report_message,
				metadata
			)

	if bool(report.get("ok", false)):
		signal_owner.emit_signal(received_signal, context, report)
	else:
		signal_owner.emit_signal(rejected_signal, context, report)
	return report


static func _make_report(
	receiver: Object,
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
		"receiver": receiver,
		"reason": reason,
		"message": message,
		"metadata": metadata.duplicate(true),
	}


static func _apply_validation_result(report: Dictionary, validation_result: Variant) -> Dictionary:
	if validation_result is bool:
		report["ok"] = bool(validation_result)
		if not bool(validation_result) and String(report.get("reason", "")).is_empty():
			report["reason"] = "validation_failed"
		return report

	if not validation_result is Dictionary:
		return report

	var result := validation_result as Dictionary
	for key: Variant in result.keys():
		if key == "metadata" and result[key] is Dictionary:
			var merged_metadata := (report.get("metadata", {}) as Dictionary).duplicate(true)
			for metadata_key: Variant in (result[key] as Dictionary).keys():
				merged_metadata[metadata_key] = result[key][metadata_key]
			report["metadata"] = merged_metadata
		else:
			report[key] = result[key]
	return report
