## GFInventoryOperationResult: 通用库存操作结果。
##
## 描述一次添加、移除、移动或合并操作的接受数量、剩余数量和失败原因。
class_name GFInventoryOperationResult
extends RefCounted


# --- 公共变量 ---

## 操作是否完全成功。
var ok: bool = false

## 物品标识。
var item_id: StringName = &""

## 请求处理的数量。
var requested_amount: int = 0

## 实际处理的数量。
var accepted_amount: int = 0

## 未处理的剩余数量。
var remaining_amount: int = 0

## 源槽位。没有源槽位时为 -1。
var source_slot: int = -1

## 目标槽位。没有目标槽位时为 -1。
var target_slot: int = -1

## 操作结果原因。
var reason: StringName = &""

## 项目自定义元数据。
var metadata: Dictionary = {}


# --- 公共方法 ---

## 创建成功结果。
## @param result_item_id: 物品标识。
## @param amount: 处理数量。
## @param result_source_slot: 源槽位。
## @param result_target_slot: 目标槽位。
## @return 操作结果。
static func success(
	result_item_id: StringName,
	amount: int,
	result_source_slot: int = -1,
	result_target_slot: int = -1
) -> GFInventoryOperationResult:
	var result := GFInventoryOperationResult.new()
	result.ok = true
	result.item_id = result_item_id
	result.requested_amount = amount
	result.accepted_amount = amount
	result.remaining_amount = 0
	result.source_slot = result_source_slot
	result.target_slot = result_target_slot
	result.reason = &"ok"
	return result


## 创建失败或部分成功结果。
## @param result_item_id: 物品标识。
## @param requested: 请求数量。
## @param accepted: 实际处理数量。
## @param result_reason: 操作结果原因。
## @param result_source_slot: 源槽位。
## @param result_target_slot: 目标槽位。
## @return 操作结果。
static func partial(
	result_item_id: StringName,
	requested: int,
	accepted: int,
	result_reason: StringName,
	result_source_slot: int = -1,
	result_target_slot: int = -1
) -> GFInventoryOperationResult:
	var result := GFInventoryOperationResult.new()
	result.ok = accepted >= requested and requested >= 0
	result.item_id = result_item_id
	result.requested_amount = maxi(requested, 0)
	result.accepted_amount = maxi(accepted, 0)
	result.remaining_amount = maxi(result.requested_amount - result.accepted_amount, 0)
	result.source_slot = result_source_slot
	result.target_slot = result_target_slot
	result.reason = result_reason
	return result


## 检查操作是否处理了部分数量。
## @return 有部分处理返回 true。
func is_partial_success() -> bool:
	return not ok and accepted_amount > 0


## 转换为字典。
## @return 操作结果字典。
func to_dict() -> Dictionary:
	return {
		"ok": ok,
		"item_id": String(item_id),
		"requested_amount": requested_amount,
		"accepted_amount": accepted_amount,
		"remaining_amount": remaining_amount,
		"source_slot": source_slot,
		"target_slot": target_slot,
		"reason": String(reason),
		"metadata": metadata.duplicate(true),
	}
