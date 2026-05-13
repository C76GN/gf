## GFCombatActionModifier: 通用战斗动作修正器。
##
## 按动作类别和标签过滤后，调整动作数值或操作。它不解释动作业务语义，
## 只负责把一个 GFCombatAction 转换为另一个 GFCombatAction。
class_name GFCombatActionModifier
extends Resource


# --- 导出变量 ---

## 修正器标识。
@export var modifier_id: StringName = &""

## 非空时，只匹配这些动作类别。
@export var accepted_action_kinds: Array[StringName] = []

## 始终拒绝匹配的动作类别。
@export var rejected_action_kinds: Array[StringName] = []

## 非空时，动作必须包含这些标签。
@export var required_tags: Array[StringName] = []

## 数值加成。
@export var amount_add: float = 0.0

## 数值乘区。
@export var amount_multiplier: float = 1.0

## 是否覆盖动作操作。
@export var override_operation: bool = false

## 覆盖后的动作操作。
@export var operation: GFCombatAction.Operation = GFCombatAction.Operation.SUBTRACT

## 是否覆盖动作类别。
@export var override_action_kind: bool = false

## 覆盖后的动作类别。
@export var action_kind: StringName = &""

## 修正器元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查修正器是否匹配动作。
## @param action: 原始动作。
## @return 匹配时返回 true。
func matches(action: GFCombatAction) -> bool:
	if action == null:
		return false
	if rejected_action_kinds.has(action.action_kind):
		return false
	if not accepted_action_kinds.is_empty() and not accepted_action_kinds.has(action.action_kind):
		return false
	for required_tag: StringName in required_tags:
		if not action.tags.has(required_tag):
			return false
	return true


## 应用修正器。
## @param action: 原始动作。
## @return 修正后的动作副本。
func apply(action: GFCombatAction) -> GFCombatAction:
	if action == null:
		return null

	var result := action.duplicate_action()
	if not matches(action):
		return result

	result.amount = (result.amount + amount_add) * amount_multiplier
	if override_operation:
		result.operation = operation
	if override_action_kind:
		result.action_kind = action_kind

	var modifier_metadata: Array = []
	var modifier_metadata_value: Variant = result.metadata.get("modifiers", [])
	if modifier_metadata_value is Array:
		modifier_metadata = (modifier_metadata_value as Array).duplicate(true)
	modifier_metadata.append({
		"modifier_id": modifier_id,
		"metadata": metadata.duplicate(true),
	})
	result.metadata["modifiers"] = modifier_metadata
	return result


## 复制修正器。
## @return 新修正器。
func duplicate_modifier() -> GFCombatActionModifier:
	var modifier := GFCombatActionModifier.new()
	modifier.modifier_id = modifier_id
	modifier.accepted_action_kinds = accepted_action_kinds.duplicate()
	modifier.rejected_action_kinds = rejected_action_kinds.duplicate()
	modifier.required_tags = required_tags.duplicate()
	modifier.amount_add = amount_add
	modifier.amount_multiplier = amount_multiplier
	modifier.override_operation = override_operation
	modifier.operation = operation
	modifier.override_action_kind = override_action_kind
	modifier.action_kind = action_kind
	modifier.metadata = metadata.duplicate(true)
	return modifier
