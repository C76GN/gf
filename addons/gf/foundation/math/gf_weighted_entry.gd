## GFWeightedEntry: 权重表中的单个候选项。
##
## 只保存值、权重和可选元数据，不约束 value 的业务类型。
class_name GFWeightedEntry
extends Resource


# --- 导出变量 ---

## 被选择后返回的值。
@export var value: Variant = null

## 权重；小于等于 0 的条目不会被选择。
@export_range(0.0, 1000000000000.0, 0.001, "or_greater") var weight: float = 1.0

## 项目层可选元数据，框架不解释其含义。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 配置条目内容。
## @param p_value: 被选择后返回的值。
## @param p_weight: 权重；小于等于 0 表示不可被选择。
## @param p_metadata: 可选元数据。
## @return 当前条目。
func configure(p_value: Variant, p_weight: float = 1.0, p_metadata: Dictionary = {}) -> GFWeightedEntry:
	value = p_value
	weight = p_weight
	metadata = p_metadata.duplicate(true)
	return self


## 判断该条目当前是否可被选择。
## @return 权重大于 0 时返回 true。
func is_selectable() -> bool:
	return weight > 0.0


## 复制当前条目。
## @param deep: 是否深拷贝元数据。
## @return 新条目实例。
func duplicate_entry(deep: bool = true) -> GFWeightedEntry:
	var entry := GFWeightedEntry.new()
	entry.value = _duplicate_variant(value, deep)
	entry.weight = weight
	entry.metadata = metadata.duplicate(deep)
	return entry


## 导出为通用字典。
## @return 包含 `value`、`weight` 与 `metadata` 的字典。
func to_dict() -> Dictionary:
	return {
		"value": value,
		"weight": weight,
		"metadata": metadata.duplicate(true),
	}


## 从通用字典创建条目。
## @param data: 包含 `value`、`weight` 与 `metadata` 的字典。
## @return 新条目实例。
static func from_dict(data: Dictionary) -> GFWeightedEntry:
	var entry := GFWeightedEntry.new()
	entry.value = data.get("value", null)
	entry.weight = float(data.get("weight", 1.0))
	var raw_metadata: Variant = data.get("metadata", {})
	entry.metadata = raw_metadata.duplicate(true) if typeof(raw_metadata) == TYPE_DICTIONARY else {}
	return entry


# --- 私有/辅助方法 ---

static func _duplicate_variant(target: Variant, deep: bool) -> Variant:
	if typeof(target) == TYPE_ARRAY or typeof(target) == TYPE_DICTIONARY:
		return target.duplicate(deep)
	if target is Resource:
		return target.duplicate(deep)
	return target
