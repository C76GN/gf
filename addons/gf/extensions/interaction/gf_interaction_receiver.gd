## GFInteractionReceiver: 通用交互接收节点。
##
## 用 GFInteractionContext 接收任意交互请求，并提供启用状态、交互 ID 过滤、
## 自定义校验回调和统一结果报告。节点不解释任何业务语义。
class_name GFInteractionReceiver
extends Node


# --- 信号 ---

## 交互进入自定义校验阶段时发出。
## @param context: 交互上下文。
## @param report: 当前结果报告副本。
signal interaction_validating(context: GFInteractionContext, report: Dictionary)

## 交互被接受时发出。
## @param context: 交互上下文。
## @param report: 结果报告。
signal interaction_received(context: GFInteractionContext, report: Dictionary)

## 交互被拒绝时发出。
## @param context: 交互上下文。
## @param report: 结果报告。
signal interaction_rejected(context: GFInteractionContext, report: Dictionary)


# --- 导出变量 ---

## 是否允许接收交互。
@export var enabled: bool = true

## 非空时，只接受这些交互 ID。
@export var accepted_interaction_ids: Array[StringName] = []

## 始终拒绝的交互 ID。
@export var rejected_interaction_ids: Array[StringName] = []

## 接收器自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共变量 ---

## 自定义校验回调，建议签名为 func(context: GFInteractionContext, report: Dictionary) -> Variant。
## 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。
var validation_callback: Callable = Callable()


# --- 公共方法 ---

## 检查指定交互 ID 是否可被当前接收器接受。
## @param interaction_id: 交互 ID。
## @return 可接受时返回 true。
func can_receive_interaction(interaction_id: StringName = &"") -> bool:
	if not enabled:
		return false
	if rejected_interaction_ids.has(interaction_id):
		return false
	if accepted_interaction_ids.is_empty():
		return true
	return accepted_interaction_ids.has(interaction_id)


## 接收一次交互。
## @param context: 交互上下文。
## @param interaction_id: 交互 ID。
## @return 统一结果报告。
func receive_interaction(context: GFInteractionContext, interaction_id: StringName = &"") -> Dictionary:
	if context == null:
		var invalid_context_report := _make_report(false, interaction_id, "invalid_context", "Interaction context is null.")
		interaction_rejected.emit(context, invalid_context_report)
		return invalid_context_report

	if not enabled:
		var disabled_report := _make_report(false, interaction_id, "disabled", "Interaction receiver is disabled.")
		interaction_rejected.emit(context, disabled_report)
		return disabled_report

	if rejected_interaction_ids.has(interaction_id):
		var rejected_report := _make_report(false, interaction_id, "rejected_id", "Interaction id is rejected.")
		interaction_rejected.emit(context, rejected_report)
		return rejected_report

	if not accepted_interaction_ids.is_empty() and not accepted_interaction_ids.has(interaction_id):
		var blocked_report := _make_report(false, interaction_id, "unaccepted_id", "Interaction id is not accepted.")
		interaction_rejected.emit(context, blocked_report)
		return blocked_report

	if context.target == null:
		context.target = self

	var report := _make_report(true, interaction_id, "accepted", "")
	interaction_validating.emit(context, report.duplicate(true))
	if validation_callback.is_valid():
		report = _apply_validation_result(report, validation_callback.call(context, report.duplicate(true)))

	if bool(report.get("ok", false)):
		interaction_received.emit(context, report)
	else:
		interaction_rejected.emit(context, report)
	return report


# --- 私有/辅助方法 ---

func _make_report(ok: bool, interaction_id: StringName, reason: String, message: String) -> Dictionary:
	return {
		"ok": ok,
		"interaction_id": interaction_id,
		"receiver": self,
		"reason": reason,
		"message": message,
		"metadata": metadata.duplicate(true),
	}


func _apply_validation_result(report: Dictionary, validation_result: Variant) -> Dictionary:
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
