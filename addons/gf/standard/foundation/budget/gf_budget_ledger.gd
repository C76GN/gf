## GFBudgetLedger: 通用资源预算账本。
##
## 用于记录一组抽象资源的容量、可用量和消耗结果。
## 资源含义由项目决定，框架只提供预算检查、消费、释放和快照。
class_name GFBudgetLedger
extends RefCounted


# --- 信号 ---

## 资源预算变化后发出。
## @param budget_id: 预算标识。
## @param available: 当前可用量。
## @param capacity: 当前容量。
signal budget_changed(budget_id: StringName, available: float, capacity: float)

## 资源消费成功后发出。
## @param budget_id: 预算标识。
## @param amount: 消费数量。
signal budget_consumed(budget_id: StringName, amount: float)

## 资源消费被拒绝后发出。
## @param budget_id: 预算标识。
## @param amount: 请求数量。
## @param reason: 拒绝原因。
signal budget_rejected(budget_id: StringName, amount: float, reason: String)


# --- 私有变量 ---

var _budgets: Dictionary = {}


# --- 公共方法 ---

## 设置预算容量，并可选重置可用量。
## @param budget_id: 预算标识。
## @param capacity: 容量。
## @param reset_available: 是否把可用量重置为容量。
func set_capacity(budget_id: StringName, capacity: float, reset_available: bool = true) -> void:
	if budget_id == &"":
		return

	var normalized_capacity := maxf(0.0, capacity)
	var entry := _get_or_make_entry(budget_id)
	entry["capacity"] = normalized_capacity
	if reset_available:
		entry["available"] = normalized_capacity
	else:
		entry["available"] = clampf(float(entry.get("available", 0.0)), 0.0, normalized_capacity)
	_budgets[budget_id] = entry
	budget_changed.emit(budget_id, float(entry["available"]), normalized_capacity)


## 设置当前可用量。
## @param budget_id: 预算标识。
## @param available: 可用量。
func set_available(budget_id: StringName, available: float) -> void:
	if budget_id == &"":
		return

	var entry := _get_or_make_entry(budget_id)
	var capacity := float(entry.get("capacity", 0.0))
	entry["available"] = clampf(available, 0.0, capacity)
	_budgets[budget_id] = entry
	budget_changed.emit(budget_id, float(entry["available"]), capacity)


## 获取容量。
## @param budget_id: 预算标识。
func get_capacity(budget_id: StringName) -> float:
	var entry := _budgets.get(budget_id) as Dictionary
	return float(entry.get("capacity", 0.0)) if entry != null else 0.0


## 获取可用量。
## @param budget_id: 预算标识。
func get_available(budget_id: StringName) -> float:
	var entry := _budgets.get(budget_id) as Dictionary
	return float(entry.get("available", 0.0)) if entry != null else 0.0


## 是否有足够预算。
## @param budget_id: 预算标识。
## @param amount: 请求数量。
func can_consume(budget_id: StringName, amount: float) -> bool:
	if amount < 0.0:
		return false
	return get_available(budget_id) >= amount


## 尝试消费预算。
## @param budget_id: 预算标识。
## @param amount: 消费数量。
## @param metadata: 调用方附加信息。
## @return 消费结果字典。
func consume(budget_id: StringName, amount: float, metadata: Dictionary = {}) -> Dictionary:
	if budget_id == &"":
		return _make_result(false, budget_id, amount, "empty_budget_id", metadata)
	if amount < 0.0:
		budget_rejected.emit(budget_id, amount, "negative_amount")
		return _make_result(false, budget_id, amount, "negative_amount", metadata)
	if not _budgets.has(budget_id):
		budget_rejected.emit(budget_id, amount, "missing_budget")
		return _make_result(false, budget_id, amount, "missing_budget", metadata)
	if not can_consume(budget_id, amount):
		budget_rejected.emit(budget_id, amount, "insufficient_budget")
		return _make_result(false, budget_id, amount, "insufficient_budget", metadata)

	var entry := _budgets[budget_id] as Dictionary
	entry["available"] = float(entry.get("available", 0.0)) - amount
	_budgets[budget_id] = entry
	budget_consumed.emit(budget_id, amount)
	budget_changed.emit(budget_id, float(entry["available"]), float(entry.get("capacity", 0.0)))
	return _make_result(true, budget_id, amount, "", metadata)


## 释放预算，可用量不会超过容量。
## @param budget_id: 预算标识。
## @param amount: 释放数量。
func release(budget_id: StringName, amount: float) -> void:
	if budget_id == &"" or amount <= 0.0:
		return

	var entry := _get_or_make_entry(budget_id)
	var capacity := float(entry.get("capacity", 0.0))
	entry["available"] = clampf(float(entry.get("available", 0.0)) + amount, 0.0, capacity)
	_budgets[budget_id] = entry
	budget_changed.emit(budget_id, float(entry["available"]), capacity)


## 将一个或全部预算重置为容量。
## @param budget_id: 预算标识；为空时重置全部。
func reset(budget_id: StringName = &"") -> void:
	if budget_id != &"":
		var entry := _budgets.get(budget_id) as Dictionary
		if entry == null:
			return
		entry["available"] = float(entry.get("capacity", 0.0))
		_budgets[budget_id] = entry
		budget_changed.emit(budget_id, float(entry["available"]), float(entry.get("capacity", 0.0)))
		return

	for key: StringName in _budgets.keys():
		reset(key)


## 清空所有预算。
func clear() -> void:
	_budgets.clear()


## 获取预算快照。
## @return 预算字典副本。
func get_snapshot() -> Dictionary:
	var result: Dictionary = {}
	for key: StringName in _budgets.keys():
		var entry := _budgets[key] as Dictionary
		result[String(key)] = entry.duplicate(true) if entry != null else {}
	return result


# --- 私有/辅助方法 ---

func _get_or_make_entry(budget_id: StringName) -> Dictionary:
	if _budgets.has(budget_id):
		return (_budgets[budget_id] as Dictionary).duplicate(true)
	return {
		"capacity": 0.0,
		"available": 0.0,
	}


func _make_result(
	ok: bool,
	budget_id: StringName,
	amount: float,
	reason: String,
	metadata: Dictionary
) -> Dictionary:
	return {
		"ok": ok,
		"budget_id": budget_id,
		"amount": amount,
		"reason": reason,
		"available": get_available(budget_id),
		"capacity": get_capacity(budget_id),
		"metadata": metadata.duplicate(true),
	}
