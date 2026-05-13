## 测试 GFBudgetLedger 的通用预算账本能力。
extends GutTest


# --- 常量 ---

const GFBudgetLedgerBase = preload("res://addons/gf/standard/foundation/budget/gf_budget_ledger.gd")


# --- 测试 ---

func test_budget_ledger_consumes_and_releases_budget() -> void:
	var ledger: GFBudgetLedgerBase = GFBudgetLedgerBase.new()
	ledger.set_capacity(&"energy", 10.0)

	var consumed := ledger.consume(&"energy", 3.0)

	assert_true(bool(consumed["ok"]), "预算充足时应允许消费。")
	assert_eq(ledger.get_available(&"energy"), 7.0, "消费后可用量应减少。")

	ledger.release(&"energy", 2.0)
	assert_eq(ledger.get_available(&"energy"), 9.0, "释放后可用量应增加。")


func test_budget_ledger_rejects_insufficient_budget() -> void:
	var ledger: GFBudgetLedgerBase = GFBudgetLedgerBase.new()
	ledger.set_capacity(&"turn_points", 2.0)

	var result := ledger.consume(&"turn_points", 3.0)

	assert_false(bool(result["ok"]), "预算不足时应拒绝消费。")
	assert_eq(String(result["reason"]), "insufficient_budget", "失败原因应可诊断。")
	assert_eq(ledger.get_available(&"turn_points"), 2.0, "失败消费不应改变可用量。")


func test_budget_ledger_snapshot_is_decoupled() -> void:
	var ledger: GFBudgetLedgerBase = GFBudgetLedgerBase.new()
	ledger.set_capacity(&"quota", 4.0)

	var snapshot := ledger.get_snapshot()
	(snapshot["quota"] as Dictionary)["available"] = 0.0

	assert_eq(ledger.get_available(&"quota"), 4.0, "修改快照不应污染账本。")
