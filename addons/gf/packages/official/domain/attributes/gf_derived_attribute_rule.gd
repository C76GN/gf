## GFDerivedAttributeRule: 通用派生属性规则。
##
## 通过权重或自定义回调从 GFAttributeSet 的其他属性计算目标属性，不规定属性业务含义。
class_name GFDerivedAttributeRule
extends Resource


# --- 常量 ---

const DEFAULT_MIN_VALUE: float = -1.0e20
const DEFAULT_MAX_VALUE: float = 1.0e20


# --- 导出变量 ---

## 被写入的目标属性 ID。
@export var attribute_id: StringName = &""

## 参与计算的来源属性 ID。为空时使用 source_weights 的键。
@export var source_attribute_ids: Array[StringName] = []

## 来源属性权重，键为属性 ID，值为数字权重。
@export var source_weights: Dictionary = {}

## 固定加值。
@export var flat_bonus: float = 0.0

## 规则级最小值。
@export var min_value: float = DEFAULT_MIN_VALUE

## 规则级最大值。
@export var max_value: float = DEFAULT_MAX_VALUE

## 是否同步写入目标属性的 base 值。
@export var sync_base_value: bool = false


# --- 公共变量 ---

## 自定义计算回调，建议签名为 func(attribute_set: GFAttributeSet, rule: GFDerivedAttributeRule) -> Variant。
var compute_callback: Callable = Callable()


# --- 公共方法 ---

## 计算派生属性值。
## @param attribute_set: 属性集合。
## @return 计算后的数值。
func calculate(attribute_set: Object) -> float:
	if attribute_set == null:
		return _clamp_result(flat_bonus)

	if compute_callback.is_valid():
		var custom_value: Variant = compute_callback.call(attribute_set, self)
		if custom_value is float or custom_value is int:
			return _clamp_result(float(custom_value))

	var result := flat_bonus
	for source_id: StringName in get_source_attribute_ids():
		if source_id == &"" or not attribute_set.has_method("get_value"):
			continue
		result += float(attribute_set.call("get_value", source_id, 0.0)) * get_source_weight(source_id)
	return _clamp_result(result)


## 获取来源属性 ID 列表。
## @return 来源属性 ID 副本。
func get_source_attribute_ids() -> Array[StringName]:
	if not source_attribute_ids.is_empty():
		return source_attribute_ids.duplicate()

	var result: Array[StringName] = []
	for key: Variant in source_weights.keys():
		result.append(StringName(key))
	return result


## 获取来源属性权重。
## @param source_attribute_id: 来源属性 ID。
## @return 权重；未配置时返回 1。
func get_source_weight(source_attribute_id: StringName) -> float:
	return float(source_weights.get(source_attribute_id, source_weights.get(String(source_attribute_id), 1.0)))


## 判断是否依赖指定属性。
## @param source_attribute_id: 来源属性 ID。
## @return 依赖返回 true。
func depends_on(source_attribute_id: StringName) -> bool:
	return get_source_attribute_ids().has(source_attribute_id)


## 创建当前规则的深拷贝。
## @return 规则副本。
func duplicate_rule() -> Resource:
	return duplicate(true) as Resource


# --- 私有/辅助方法 ---

func _clamp_result(value: float) -> float:
	var safe_min := minf(min_value, max_value)
	var safe_max := maxf(min_value, max_value)
	return clampf(value, safe_min, safe_max)
