## GFHurtBox2D: 2D 通用命中接收区域。
##
## 节点只过滤和接收 GFCombatHitContext，不直接修改生命、属性或 Buff。
class_name GFHurtBox2D
extends Area2D


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


# --- 导出变量 ---

## 是否允许接收命中。
@export var enabled: bool = true

## 非空时，只接受这些命中 ID。
@export var accepted_hit_ids: Array[StringName] = []

## 始终拒绝的命中 ID。
@export var rejected_hit_ids: Array[StringName] = []

## 接收器自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共变量 ---

## 自定义校验回调，建议签名为 func(context: GFCombatHitContext, report: Dictionary) -> Variant。
## 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。
var validation_callback: Callable = Callable()


# --- 公共方法 ---

## 检查指定命中 ID 是否可被当前接收器接受。
## @param p_hit_id: 命中 ID。
## @return 可接受时返回 true。
func can_receive_hit(p_hit_id: StringName = &"") -> bool:
	if not enabled:
		return false
	if rejected_hit_ids.has(p_hit_id):
		return false
	if accepted_hit_ids.is_empty():
		return true
	return accepted_hit_ids.has(p_hit_id)


## 接收一次命中。
## @param context: 命中上下文。
## @return 统一结果报告。
func receive_hit(context: GFCombatHitContext) -> Dictionary:
	if context == null:
		var invalid_context_report := _make_report(false, &"", "invalid_context", "Hit context is null.")
		hit_rejected.emit(context, invalid_context_report)
		return invalid_context_report

	if not enabled:
		var disabled_report := _make_report(false, context.hit_id, "disabled", "Hurt box is disabled.")
		hit_rejected.emit(context, disabled_report)
		return disabled_report

	if rejected_hit_ids.has(context.hit_id):
		var rejected_report := _make_report(false, context.hit_id, "rejected_id", "Hit id is rejected.")
		hit_rejected.emit(context, rejected_report)
		return rejected_report

	if not accepted_hit_ids.is_empty() and not accepted_hit_ids.has(context.hit_id):
		var blocked_report := _make_report(false, context.hit_id, "unaccepted_id", "Hit id is not accepted.")
		hit_rejected.emit(context, blocked_report)
		return blocked_report

	if context.target == null:
		context.target = self

	var report := _make_report(true, context.hit_id, "accepted", "")
	hit_validating.emit(context, report.duplicate(true))
	if validation_callback.is_valid():
		report = _apply_validation_result(report, validation_callback.call(context, report.duplicate(true)))

	if bool(report.get("ok", false)):
		hit_received.emit(context, report)
	else:
		hit_rejected.emit(context, report)
	return report


# --- 私有/辅助方法 ---

func _make_report(ok: bool, p_hit_id: StringName, reason: String, message: String) -> Dictionary:
	return {
		"ok": ok,
		"hit_id": p_hit_id,
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
