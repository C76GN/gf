## GFWeightedTable: 通用权重选择表。
##
## 适合需要“按权重从候选集合中选择值”的纯算法场景。
## 该类只处理权重和随机源，不绑定掉落、奖励、AI 等业务语义。
class_name GFWeightedTable
extends Resource


# --- 常量 ---

const GFWeightedEntryBase: Script = preload("res://addons/gf/standard/foundation/math/gf_weighted_entry.gd")


# --- 导出变量 ---

## 候选条目列表。
@export var entries: Array[GFWeightedEntryBase] = []

## 没有可选条目时返回的默认值。
@export var default_value: Variant = null

## 可选确定性种子；为 0 时使用随机化种子。
@export var deterministic_seed: int = 0


# --- 公共方法 ---

## 追加一个候选条目。
## @param value: 被选择后返回的值。
## @param weight: 权重；小于等于 0 的条目会保留但不会被选择。
## @param metadata: 可选元数据。
## @return 新增的条目实例。
func add_entry(value: Variant, weight: float = 1.0, metadata: Dictionary = {}) -> GFWeightedEntry:
	var entry := GFWeightedEntry.new().configure(value, weight, metadata)
	entries.append(entry)
	return entry


## 追加已有候选条目。
## @param entry: 要追加的条目。
## @return 添加成功时返回 true。
func add_weighted_entry(entry: GFWeightedEntry) -> bool:
	if entry == null:
		return false

	entries.append(entry)
	return true


## 移除候选条目。
## @param entry: 要移除的条目。
## @return 找到并移除时返回 true。
func remove_entry(entry: GFWeightedEntry) -> bool:
	var index := entries.find(entry)
	if index < 0:
		return false

	entries.remove_at(index)
	return true


## 清空候选条目。
func clear() -> void:
	entries.clear()


## 获取当前可被选择的条目。
## @return 权重大于 0 的条目数组。
func get_selectable_entries() -> Array[GFWeightedEntry]:
	var result: Array[GFWeightedEntry] = []
	for entry: GFWeightedEntry in entries:
		if entry != null and entry.is_selectable():
			result.append(entry)

	return result


## 计算当前总权重。
## @return 所有可选条目的权重总和。
func get_total_weight() -> float:
	var total := 0.0
	for entry: GFWeightedEntry in entries:
		if entry != null and entry.is_selectable():
			total += entry.weight

	return total


## 判断当前是否没有可选条目。
## @return 没有可选条目时返回 true。
func is_empty() -> bool:
	return get_total_weight() <= 0.0


## 按权重选择一个条目。
## @param rng: 可选随机源；传入同一种子可获得可复现结果。
## @return 选中的条目；没有可选条目时返回 null。
func pick_entry(rng: RandomNumberGenerator = null) -> GFWeightedEntry:
	return _pick_entry_from(get_selectable_entries(), _resolve_rng(rng))


## 按权重选择一个值。
## @param rng: 可选随机源；传入同一种子可获得可复现结果。
## @return 选中条目的 value；没有可选条目时返回 default_value。
func pick_value(rng: RandomNumberGenerator = null) -> Variant:
	var entry := pick_entry(rng)
	return entry.value if entry != null else default_value


## 按权重选择多个值。
## @param count: 选择次数。
## @param rng: 可选随机源；传入同一种子可获得可复现结果。
## @param allow_repeats: 是否允许同一条目被重复选择。
## @return 选中的 value 数组。
func pick_many(
	count: int,
	rng: RandomNumberGenerator = null,
	allow_repeats: bool = true
) -> Array:
	var result: Array = []
	if count <= 0:
		return result

	var active_rng := _resolve_rng(rng)
	var available := get_selectable_entries()
	if allow_repeats:
		for _index: int in range(count):
			var repeated_entry := _pick_entry_from(available, active_rng)
			if repeated_entry == null:
				break

			result.append(repeated_entry.value)
		return result

	for _index: int in range(count):
		var entry := _pick_entry_from(available, active_rng)
		if entry == null:
			break

		result.append(entry.value)
		available.erase(entry)

	return result


## 复制当前权重表。
## @param deep: 是否深拷贝条目和元数据。
## @return 新权重表实例。
func duplicate_table(deep: bool = true) -> GFWeightedTable:
	var table := GFWeightedTable.new()
	table.default_value = GFVariantData.duplicate_variant(default_value, deep, true)
	table.deterministic_seed = deterministic_seed
	for entry: GFWeightedEntry in entries:
		table.entries.append(entry.duplicate_entry(deep) if entry != null and deep else entry)

	return table


## 导出为通用字典。
## @return 包含条目、默认值和确定性种子的字典。
func to_dict() -> Dictionary:
	var serialized_entries: Array[Dictionary] = []
	for entry: GFWeightedEntry in entries:
		if entry != null:
			serialized_entries.append(entry.to_dict())

	return {
		"entries": serialized_entries,
		"default_value": default_value,
		"deterministic_seed": deterministic_seed,
	}


## 使用通用字典覆盖当前权重表。
## @param data: 包含 `entries`、`default_value` 与 `deterministic_seed` 的字典。
func apply_dict(data: Dictionary) -> void:
	entries.clear()
	default_value = data.get("default_value", null)
	deterministic_seed = int(data.get("deterministic_seed", 0))

	var raw_entries: Variant = data.get("entries", [])
	if typeof(raw_entries) != TYPE_ARRAY:
		return

	for raw_entry in raw_entries:
		if typeof(raw_entry) == TYPE_DICTIONARY:
			entries.append(GFWeightedEntry.from_dict(raw_entry))


## 从通用字典创建权重表。
## @param data: 包含 `entries`、`default_value` 与 `deterministic_seed` 的字典。
## @return 新权重表实例。
static func from_dict(data: Dictionary) -> GFWeightedTable:
	var table := GFWeightedTable.new()
	table.apply_dict(data)
	return table


# --- 私有/辅助方法 ---

func _pick_entry_from(source_entries: Array[GFWeightedEntry], rng: RandomNumberGenerator) -> GFWeightedEntry:
	var total := 0.0
	for entry: GFWeightedEntry in source_entries:
		if entry != null and entry.is_selectable():
			total += entry.weight

	if total <= 0.0:
		return null

	var threshold := rng.randf_range(0.0, total)
	var accumulated := 0.0
	var fallback: GFWeightedEntry = null
	for entry: GFWeightedEntry in source_entries:
		if entry == null or not entry.is_selectable():
			continue

		fallback = entry
		accumulated += entry.weight
		if threshold <= accumulated:
			return entry

	return fallback


func _resolve_rng(rng: RandomNumberGenerator) -> RandomNumberGenerator:
	if rng != null:
		return rng

	var fallback := RandomNumberGenerator.new()
	if deterministic_seed != 0:
		fallback.seed = deterministic_seed
	else:
		fallback.randomize()
	return fallback
