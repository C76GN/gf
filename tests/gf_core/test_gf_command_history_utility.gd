# tests/gf_core/test_gf_command_history_utility.gd

## 测试 GFCommandHistoryUtility 的 record、undo_last、redo 及边界情况。
extends GutTest


# --- 私有变量 ---

var _history: GFCommandHistoryUtility


# --- 辅助命令类 ---

class CounterCommand:
	extends GFUndoableCommand

	## 指向共享计数器字典的引用，避免闭包捕获问题。
	var _counter: Dictionary

	func _init(counter: Dictionary) -> void:
		_counter = counter

	func execute() -> Variant:
		set_snapshot(_counter.get("value", 0))
		_counter["value"] = _counter.get("value", 0) + 1
		return null

	func undo() -> void:
		_counter["value"] = get_snapshot()


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_history = GFCommandHistoryUtility.new()
	_history.init()


func after_each() -> void:
	_history = null


# --- 测试：record ---

## 验证 record 后 undo_count 自增。
func test_record_increases_undo_count() -> void:
	var counter := {"value": 0}
	var cmd := CounterCommand.new(counter)
	cmd.execute()
	_history.record(cmd)

	assert_eq(_history.undo_count, 1, "record 后撤销栈应有一条记录。")


## 验证 record 后 redo_count 归零（新操作打断重做分支）。
func test_record_clears_redo_stack() -> void:
	var counter := {"value": 0}
	var cmd1 := CounterCommand.new(counter)
	cmd1.execute()
	_history.record(cmd1)

	_history.undo_last()
	assert_eq(_history.redo_count, 1, "撤销后重做栈应有一条。")

	var cmd2 := CounterCommand.new(counter)
	cmd2.execute()
	_history.record(cmd2)

	assert_eq(_history.redo_count, 0, "record 新命令后重做栈应被清空。")


# --- 测试：undo_last ---

## 验证 undo_last 调用命令的 undo() 并恢复状态。
func test_undo_last_restores_state() -> void:
	var counter := {"value": 0}
	var cmd := CounterCommand.new(counter)
	cmd.execute()
	_history.record(cmd)

	assert_eq(counter.value, 1, "execute 后 value 应为 1。")

	_history.undo_last()
	assert_eq(counter.value, 0, "undo_last 后 value 应恢复为 0。")


## 验证 undo_last 将命令压入重做栈。
func test_undo_last_moves_to_redo_stack() -> void:
	var counter := {"value": 0}
	var cmd := CounterCommand.new(counter)
	cmd.execute()
	_history.record(cmd)
	_history.undo_last()

	assert_eq(_history.redo_count, 1, "undo_last 后重做栈应有一条。")
	assert_eq(_history.undo_count, 0, "undo_last 后撤销栈应为空。")


## 验证撤销栈为空时 undo_last 返回 false 且不崩溃。
func test_undo_last_empty_stack_returns_false() -> void:
	var result: bool = _history.undo_last()
	assert_false(result, "空栈时 undo_last 应返回 false。")


# --- 测试：redo ---

## 验证 redo 重新执行被撤销的命令。
func test_redo_reapplies_command() -> void:
	var counter := {"value": 0}
	var cmd := CounterCommand.new(counter)
	cmd.execute()
	_history.record(cmd)
	_history.undo_last()

	assert_eq(counter.value, 0, "undo 后 value 应为 0。")

	_history.redo()
	assert_eq(counter.value, 1, "redo 后 value 应恢复为 1。")


## 验证 redo 后命令重回撤销栈。
func test_redo_moves_back_to_undo_stack() -> void:
	var counter := {"value": 0}
	var cmd := CounterCommand.new(counter)
	cmd.execute()
	_history.record(cmd)
	_history.undo_last()
	_history.redo()

	assert_eq(_history.undo_count, 1, "redo 后撤销栈应有一条。")
	assert_eq(_history.redo_count, 0, "redo 后重做栈应为空。")


## 验证重做栈为空时 redo 返回 false 且不崩溃。
func test_redo_empty_stack_returns_false() -> void:
	var result: bool = _history.redo()
	assert_false(result, "空栈时 redo 应返回 false。")


# --- 测试：clear 与辅助方法 ---

## 验证 clear 清空两个栈。
func test_clear_empties_both_stacks() -> void:
	var counter := {"value": 0}
	var cmd := CounterCommand.new(counter)
	cmd.execute()
	_history.record(cmd)
	_history.undo_last()

	_history.clear()

	assert_eq(_history.undo_count, 0, "clear 后撤销栈应为空。")
	assert_eq(_history.redo_count, 0, "clear 后重做栈应为空。")


## 验证 can_undo 与 can_redo 的返回值。
func test_can_undo_and_can_redo() -> void:
	assert_false(_history.can_undo(), "初始时 can_undo 应为 false。")
	assert_false(_history.can_redo(), "初始时 can_redo 应为 false。")

	var counter := {"value": 0}
	var cmd := CounterCommand.new(counter)
	cmd.execute()
	_history.record(cmd)

	assert_true(_history.can_undo(), "record 后 can_undo 应为 true。")
	assert_false(_history.can_redo(), "record 后 can_redo 应为 false。")

	_history.undo_last()
	assert_false(_history.can_undo(), "undo 后 can_undo 应为 false。")
	assert_true(_history.can_redo(), "undo 后 can_redo 应为 true。")
