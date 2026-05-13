## GFModalResult: 通用 modal 交互结果。
##
## 只描述用户选择、附加载荷和调用上下文，不解释业务含义。
class_name GFModalResult
extends RefCounted


# --- 常量 ---

## 表示肯定或主要操作。
const STATUS_CONFIRMED: StringName = &"confirmed"

## 表示取消、返回或关闭。
const STATUS_CANCELLED: StringName = &"cancelled"

## 表示中性关闭。
const STATUS_DISMISSED: StringName = &"dismissed"


# --- 公共变量 ---

## 结果状态。
var status: StringName = STATUS_DISMISSED

## 触发该结果的动作 ID。
var action_id: StringName = &""

## 动作携带的通用载荷。
var payload: Variant = null

## 结果元数据。
var metadata: Dictionary = {}

## 打开 modal 时传入的调用上下文。
var context: Dictionary = {}


# --- 公共方法 ---

## 创建结果实例。
## @param result_status: 结果状态。
## @param result_action_id: 触发动作 ID。
## @param result_payload: 动作载荷。
## @param result_metadata: 结果元数据。
## @param result_context: 调用上下文。
## @return 新结果实例。
static func create(
	result_status: StringName,
	result_action_id: StringName = &"",
	result_payload: Variant = null,
	result_metadata: Dictionary = {},
	result_context: Dictionary = {}
) -> GFModalResult:
	var result := GFModalResult.new()
	result.status = result_status
	result.action_id = result_action_id
	result.payload = result_payload
	result.metadata = result_metadata.duplicate(true)
	result.context = result_context.duplicate(true)
	return result


## 导出为字典。
## @return 结果字典。
func to_dict() -> Dictionary:
	return {
		"status": status,
		"action_id": action_id,
		"payload": GFVariantData.duplicate_collection(payload),
		"metadata": metadata.duplicate(true),
		"context": context.duplicate(true),
	}
