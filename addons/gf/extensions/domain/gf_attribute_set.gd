## GFAttributeSet: 通用数值属性集合。
##
## 用 StringName 管理一组可保存、可恢复、可限制范围的数值属性。它不规定
## 属性含义，生命值、耐久、温度、声望或任意项目数值都由项目层命名和解释。
class_name GFAttributeSet
extends Resource


# --- 信号 ---

## 属性被定义时发出。
signal attribute_defined(attribute_id: StringName)

## 当前值变化时发出。
signal attribute_changed(attribute_id: StringName, current_value: float, previous_value: float)


# --- 常量 ---

const DEFAULT_MIN_VALUE: float = -1.0e20
const DEFAULT_MAX_VALUE: float = 1.0e20


# --- 导出变量 ---

## 属性记录。结构为 attribute_id -> { base, current, min, max, metadata }。
@export var attributes: Dictionary = {}


# --- 公共方法 ---

## 定义或替换属性。
## @param attribute_id: 属性标识。
## @param base_value: 基础值。
## @param current_value: 当前值；为 null 或 NAN 时使用 base_value。
## @param min_value: 最小值。
## @param max_value: 最大值。
## @param metadata: 项目自定义元数据。
func define_attribute(
	attribute_id: StringName,
	base_value: float = 0.0,
	current_value: Variant = null,
	min_value: float = DEFAULT_MIN_VALUE,
	max_value: float = DEFAULT_MAX_VALUE,
	metadata: Dictionary = {}
) -> void:
	if attribute_id == &"":
		return

	var safe_min := minf(min_value, max_value)
	var safe_max := maxf(min_value, max_value)
	var resolved_current := base_value
	if current_value != null:
		var parsed_current := float(current_value)
		resolved_current = base_value if is_nan(parsed_current) else parsed_current
	attributes[attribute_id] = {
		"base": clampf(base_value, safe_min, safe_max),
		"current": clampf(resolved_current, safe_min, safe_max),
		"min": safe_min,
		"max": safe_max,
		"metadata": metadata.duplicate(true),
	}
	attribute_defined.emit(attribute_id)


## 检查属性是否存在。
## @param attribute_id: 属性标识。
## @return 存在返回 true。
func has_attribute(attribute_id: StringName) -> bool:
	return attributes.has(attribute_id)


## 移除属性。
## @param attribute_id: 属性标识。
func remove_attribute(attribute_id: StringName) -> void:
	attributes.erase(attribute_id)


## 清空所有属性。
func clear() -> void:
	attributes.clear()


## 设置当前值。
## @param attribute_id: 属性标识。
## @param value: 新值。
## @return 成功返回 true。
func set_value(attribute_id: StringName, value: float) -> bool:
	if not attributes.has(attribute_id):
		return false

	var record := attributes[attribute_id] as Dictionary
	var previous_value := float(record.get("current", 0.0))
	var next_value := clampf(value, float(record.get("min", DEFAULT_MIN_VALUE)), float(record.get("max", DEFAULT_MAX_VALUE)))
	record["current"] = next_value
	if not is_equal_approx(previous_value, next_value):
		attribute_changed.emit(attribute_id, next_value, previous_value)
	return true


## 增减当前值。
## @param attribute_id: 属性标识。
## @param delta: 增量。
## @return 成功返回 true。
func adjust_value(attribute_id: StringName, delta: float) -> bool:
	return set_value(attribute_id, get_value(attribute_id) + delta)


## 设置基础值。
## @param attribute_id: 属性标识。
## @param value: 新基础值。
## @param sync_current: 是否同步当前值。
## @return 成功返回 true。
func set_base_value(attribute_id: StringName, value: float, sync_current: bool = false) -> bool:
	if not attributes.has(attribute_id):
		return false

	var record := attributes[attribute_id] as Dictionary
	var next_base := clampf(value, float(record.get("min", DEFAULT_MIN_VALUE)), float(record.get("max", DEFAULT_MAX_VALUE)))
	record["base"] = next_base
	if sync_current:
		return set_value(attribute_id, next_base)
	return true


## 设置属性范围。
## @param attribute_id: 属性标识。
## @param min_value: 最小值。
## @param max_value: 最大值。
## @return 成功返回 true。
func set_limits(attribute_id: StringName, min_value: float, max_value: float) -> bool:
	if not attributes.has(attribute_id):
		return false

	var record := attributes[attribute_id] as Dictionary
	record["min"] = minf(min_value, max_value)
	record["max"] = maxf(min_value, max_value)
	record["base"] = clampf(float(record.get("base", 0.0)), float(record["min"]), float(record["max"]))
	return set_value(attribute_id, float(record.get("current", 0.0)))


## 获取当前值。
## @param attribute_id: 属性标识。
## @param default_value: 默认值。
## @return 当前值。
func get_value(attribute_id: StringName, default_value: float = 0.0) -> float:
	var record := attributes.get(attribute_id) as Dictionary
	if record == null:
		return default_value
	return float(record.get("current", default_value))


## 获取基础值。
## @param attribute_id: 属性标识。
## @param default_value: 默认值。
## @return 基础值。
func get_base_value(attribute_id: StringName, default_value: float = 0.0) -> float:
	var record := attributes.get(attribute_id) as Dictionary
	if record == null:
		return default_value
	return float(record.get("base", default_value))


## 通过 TraitSet 计算属性值。
## @param attribute_id: 属性标识。
## @param trait_set: 特征集合。
## @return Trait 修饰后的值。
func get_value_with_traits(attribute_id: StringName, trait_set: GFTraitSet) -> float:
	var value := get_value(attribute_id)
	if trait_set == null:
		return value
	return trait_set.calculate_number(attribute_id, value)


## 获取属性元数据。
## @param attribute_id: 属性标识。
## @return 元数据副本。
func get_metadata(attribute_id: StringName) -> Dictionary:
	var record := attributes.get(attribute_id) as Dictionary
	if record == null:
		return {}
	var metadata := record.get("metadata", {}) as Dictionary
	if metadata == null:
		return {}
	return metadata.duplicate(true)


## 设置属性元数据。
## @param attribute_id: 属性标识。
## @param metadata: 元数据。
## @return 成功返回 true。
func set_metadata(attribute_id: StringName, metadata: Dictionary) -> bool:
	var record := attributes.get(attribute_id) as Dictionary
	if record == null:
		return false
	record["metadata"] = metadata.duplicate(true)
	return true


## 导出快照。
## @return 可序列化字典。
func get_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	for attribute_id_variant: Variant in attributes.keys():
		var record := attributes[attribute_id_variant] as Dictionary
		if record == null:
			continue
		snapshot[String(attribute_id_variant)] = record.duplicate(true)
	return snapshot


## 从快照恢复。
## @param snapshot: 由 get_snapshot() 或 to_dict() 返回的数据。
func restore_snapshot(snapshot: Dictionary) -> void:
	attributes.clear()
	for attribute_id_variant: Variant in snapshot.keys():
		var record := snapshot[attribute_id_variant] as Dictionary
		if record == null:
			continue
		var metadata := record.get("metadata", {}) as Dictionary
		define_attribute(
			StringName(attribute_id_variant),
			float(record.get("base", 0.0)),
			float(record.get("current", record.get("base", 0.0))),
			float(record.get("min", DEFAULT_MIN_VALUE)),
			float(record.get("max", DEFAULT_MAX_VALUE)),
			metadata if metadata != null else {}
		)


## 序列化为字典。
## @return 可序列化字典。
func to_dict() -> Dictionary:
	return get_snapshot()


## 从字典恢复。
## @param data: 属性数据。
func from_dict(data: Dictionary) -> void:
	restore_snapshot(data)
