## GFCombatAction: 通用战斗动作数据。
##
## 表达一次对目标系统可解释的数值动作。框架只保存动作类别、操作、数值、
## 标签和元数据，不规定伤害、治疗、阵营或生命值语义。
class_name GFCombatAction
extends Resource


# --- 枚举 ---

## 数值操作类型。
enum Operation {
	## 增加目标值。
	ADD,
	## 减少目标值。
	SUBTRACT,
	## 直接设置目标值。
	SET,
}


# --- 导出变量 ---

## 动作标识。
@export var action_id: StringName = &""

## 动作类别，由项目定义。
@export var action_kind: StringName = &""

## 数值操作。
@export var operation: Operation = Operation.SUBTRACT

## 动作数值。
@export var amount: float = 0.0

## 动作标签，由项目定义。
@export var tags: Array[StringName] = []

## 项目自定义 payload。
@export var payload: Variant = null

## 项目自定义元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 复制动作。
## @return 新动作。
func duplicate_action() -> GFCombatAction:
	var action := GFCombatAction.new()
	action.action_id = action_id
	action.action_kind = action_kind
	action.operation = operation
	action.amount = amount
	action.tags = tags.duplicate()
	action.payload = GFVariantData.duplicate_variant(payload)
	action.metadata = metadata.duplicate(true)
	return action


## 设置动作标识并返回自身。
## @param value: 动作标识。
## @return 当前动作。
func with_action_id(value: StringName) -> GFCombatAction:
	action_id = value
	return self


## 设置动作类别并返回自身。
## @param value: 动作类别。
## @return 当前动作。
func with_kind(value: StringName) -> GFCombatAction:
	action_kind = value
	return self


## 设置数值操作并返回自身。
## @param value: 数值操作。
## @return 当前动作。
func with_operation(value: Operation) -> GFCombatAction:
	operation = value
	return self


## 设置动作数值并返回自身。
## @param value: 动作数值。
## @return 当前动作。
func with_amount(value: float) -> GFCombatAction:
	amount = value
	return self


## 设置动作标签并返回自身。
## @param value: 动作标签。
## @return 当前动作。
func with_tags(value: Array[StringName]) -> GFCombatAction:
	tags = value.duplicate()
	return self


## 设置 payload 并返回自身。
## @param value: payload。
## @return 当前动作。
func with_payload(value: Variant) -> GFCombatAction:
	payload = GFVariantData.duplicate_variant(value)
	return self


## 设置元数据并返回自身。
## @param value: 元数据。
## @return 当前动作。
func with_metadata(value: Dictionary) -> GFCombatAction:
	metadata = value.duplicate(true)
	return self


## 转为字典。
## @return 字典快照。
func to_dict() -> Dictionary:
	return {
		"action_id": action_id,
		"action_kind": action_kind,
		"operation": operation,
		"amount": amount,
		"tags": tags.duplicate(),
		"payload": GFVariantData.duplicate_variant(payload),
		"metadata": metadata.duplicate(true),
	}
