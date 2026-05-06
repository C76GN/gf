## GFTileRuleSet: 通用瓦片邻域规则表。
##
## 使用邻域值序列匹配结果，可用于自动铺砖、地形变体、网格装饰或任意
## 基于相邻格子状态的选择逻辑。规则只处理 Variant 值，不绑定 TileSet 语义。
class_name GFTileRuleSet
extends Resource


# --- 导出变量 ---

## 规则匹配失败时尝试使用的邻域回退值。
@export var fallback_neighbor_value: Variant = 0

## 没有匹配规则时返回的值。
@export var default_result: Variant = null

## 参与确定性加权选择的默认种子。
@export var deterministic_seed: int = 0


# --- 私有变量 ---

var _rules: Dictionary = {
	"branches": {},
	"results": [],
}
var _rule_count: int = 0


# --- 公共方法 ---

## 注册一条邻域规则。
## @param neighbor_values: 邻域值序列。
## @param result: 匹配结果。
## @param weight: 同一邻域下多个结果的权重。
func register_rule(neighbor_values: Array, result: Variant, weight: float = 1.0) -> void:
	if neighbor_values.is_empty():
		return

	var node := _rules
	for value: Variant in neighbor_values:
		var branches := _get_branches(node)
		if not branches.has(value):
			branches[value] = _make_node()
		node = branches[value] as Dictionary

	var results := _get_results(node)
	results.append({
		"value": result,
		"weight": maxf(weight, 0.0),
	})
	_rule_count += 1


## 清空全部规则。
func clear() -> void:
	_rules = _make_node()
	_rule_count = 0


## 获取已注册规则数量。
## @return 规则数量。
func get_rule_count() -> int:
	return _rule_count


## 根据邻域值解析结果。
## @param neighbor_values: 邻域值序列。
## @param cell: 可选格坐标，用于确定性加权选择。
## @param seed: 可选种子；为 0 时使用 deterministic_seed。
## @return 匹配结果；没有匹配时返回 default_result。
func resolve(neighbor_values: Array, cell: Vector2i = Vector2i.ZERO, seed: int = 0) -> Variant:
	if neighbor_values.is_empty():
		return default_result

	var node := _rules
	for value: Variant in neighbor_values:
		var branches := _get_branches(node)
		if not branches.has(value):
			value = fallback_neighbor_value
		if not branches.has(value):
			return default_result
		node = branches[value] as Dictionary

	var results := _get_results(node)
	if results.is_empty():
		return default_result
	return _pick_result(results, cell, seed)


## 检查邻域值是否存在明确规则。
## @param neighbor_values: 邻域值序列。
## @return 存在规则时返回 true。
func has_rule(neighbor_values: Array) -> bool:
	var node := _rules
	for value: Variant in neighbor_values:
		var branches := _get_branches(node)
		if not branches.has(value):
			return false
		node = branches[value] as Dictionary
	return not _get_results(node).is_empty()


# --- 私有/辅助方法 ---

func _make_node() -> Dictionary:
	return {
		"branches": {},
		"results": [],
	}


func _get_branches(node: Dictionary) -> Dictionary:
	return node.get("branches", {}) as Dictionary


func _get_results(node: Dictionary) -> Array:
	return node.get("results", []) as Array


func _pick_result(results: Array, cell: Vector2i, seed: int) -> Variant:
	if results.size() == 1:
		return (results[0] as Dictionary).get("value")

	var total_weight := 0.0
	for result_entry: Dictionary in results:
		total_weight += float(result_entry.get("weight", 0.0))
	if total_weight <= 0.0:
		return (results[0] as Dictionary).get("value")

	var rng := RandomNumberGenerator.new()
	var effective_seed := deterministic_seed if seed == 0 else seed
	rng.seed = hash("%s:%s:%s" % [cell, effective_seed, results.size()])
	var target := rng.randf_range(0.0, total_weight)
	var cursor := 0.0
	for result_entry: Dictionary in results:
		cursor += float(result_entry.get("weight", 0.0))
		if target <= cursor:
			return result_entry.get("value")
	return (results[results.size() - 1] as Dictionary).get("value")
