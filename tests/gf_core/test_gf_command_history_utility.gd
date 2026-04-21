## 测试 GFCommandHistoryUtility 的记录、撤销、重做与序列化行为。
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

	func undo() -> Variant:
		_counter["value"] = get_snapshot()
		return null


class AsyncCounterCommand:
	extends GFUndoableCommand

	signal completed

	var _counter: Dictionary
	var _execute_value: int
	var _undo_value: int

	func _init(counter: Dictionary, execute_value: int, undo_value: int) -> void:
		_counter = counter
		_execute_value = execute_value
		_undo_value = undo_value

	func execute() -> Variant:
		call_deferred("_finish_execute")
		return completed

	func undo() -> Variant:
		call_deferred("_finish_undo")
		return completed

	func _finish_execute() -> void:
		_counter["value"] = _execute_value
		completed.emit()

	func _finish_undo() -> void:
		_counter["value"] = _undo_value
		completed.emit()


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


## 验证 execute_command 会执行命令并自动记录到撤销栈。
func test_execute_command_executes_and_records() -> void:
	var counter := {"value": 0}
	var cmd := CounterCommand.new(counter)

	_history.execute_command(cmd)

	assert_eq(counter.value, 1, "execute_command 应先执行命令。")
	assert_eq(_history.undo_count, 1, "execute_command 后应自动记录到撤销栈。")


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


## 验证 undo_last_async 会等待异步撤销命令完成后再移动到重做栈。
func test_undo_last_async_awaits_async_command() -> void:
	var counter := {"value": 10}
	var cmd := AsyncCounterCommand.new(counter, 20, 0)
	_history.record(cmd)

	var result: bool = await _history.undo_last_async()

	assert_true(result, "异步撤销完成后应返回 true。")
	assert_eq(counter.value, 0, "异步 undo 完成后应恢复指定值。")
	assert_eq(_history.redo_count, 1, "异步 undo 完成后应推入重做栈。")


## 验证 redo_async 会等待异步执行命令完成后再移动回撤销栈。
func test_redo_async_awaits_async_command() -> void:
	var counter := {"value": 0}
	var cmd := AsyncCounterCommand.new(counter, 20, 0)
	_history.record(cmd)
	await _history.undo_last_async()

	var result: bool = await _history.redo_async()

	assert_true(result, "异步重做完成后应返回 true。")
	assert_eq(counter.value, 20, "异步 redo 完成后应应用指定值。")
	assert_eq(_history.undo_count, 1, "异步 redo 完成后应推回撤销栈。")


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


## 验证 get_undo_history 和 get_redo_history 返回的数组及元素正确，且原栈不受外部修改影响。
func test_get_history_methods() -> void:
	var counter := {"value": 0}
	var cmd1 := CounterCommand.new(counter)
	var cmd2 := CounterCommand.new(counter)
	cmd1.action_name = "动作1"
	cmd2.action_name = "动作2"

	cmd1.execute()
	_history.record(cmd1)
	cmd2.execute()
	_history.record(cmd2)

	_history.undo_last()

	var undo_history: Array[GFUndoableCommand] = _history.get_undo_history()
	var redo_history: Array[GFUndoableCommand] = _history.get_redo_history()

	assert_eq(undo_history.size(), 1, "撤销历史应有 1 个元素。")
	assert_eq(undo_history[0].action_name, "动作1", "撤销历史的命令描述应正确。")

	assert_eq(redo_history.size(), 1, "重做历史应有 1 个元素。")
	assert_eq(redo_history[0].action_name, "动作2", "重做历史的命令描述应正确。")

	undo_history.clear()
	redo_history.clear()

	assert_eq(_history.undo_count, 1, "返回的原撤销栈的拷贝被清空，不应影响内部撤销栈。")
	assert_eq(_history.redo_count, 1, "返回的原重做栈的拷贝被清空，不应影响内部重做栈。")


# --- 测试：持久化与上限 ---

## 验证 serialize_history 能够提取正确的快照信息。
func test_serialize_history() -> void:
	var counter := {"value": 0}
	var cmd1 := CounterCommand.new(counter)
	var cmd2 := CounterCommand.new(counter)

	cmd1.execute()
	_history.record(cmd1)
	cmd2.execute()
	_history.record(cmd2)

	var data_array := _history.serialize_history()
	assert_eq(data_array.size(), 2, "序列化后的数据长度应为2。")
	assert_eq(data_array[0].get("snapshot"), 0, "第一个快照值应正确。")
	assert_eq(data_array[1].get("snapshot"), 1, "第二个快照值应正确。")


## 验证 deserialize_history 能够正确通过构造器恢复栈。
func test_deserialize_history() -> void:
	var counter := {"value": 0}
	var builder: Callable = func(data: Dictionary) -> GFUndoableCommand:
		var c := CounterCommand.new(counter)
		c.set_snapshot(data.get("snapshot", 0))
		return c

	var src_data := [ {"snapshot": 5}, {"snapshot": 6}]
	_history.deserialize_history(src_data, builder)

	assert_eq(_history.undo_count, 2, "撤销栈应恢复2条。")
	_history.undo_last()
	assert_eq(counter.value, 6, "反序列化后的命令能正常提取之前快照执行 undo。")
	assert_eq(_history.redo_count, 1, "撤销后正常推入重做栈。")


## 验证 max_history_size 超限清理 (FIFO抛弃)。
func test_history_size_limit() -> void:
	_history.max_history_size = 2
	var counter := {"value": 0}

	var cmds: Array[CounterCommand] = []
	for i in range(3):
		var cmd := CounterCommand.new(counter)
		cmd.execute()
		_history.record(cmd)
		cmds.append(cmd)

	assert_eq(_history.undo_count, 2, "超出最大限制时撤销栈大小应保持为 max_history_size (2)。")

	_history.undo_last()
	assert_eq(counter.value, 2, "最新撤销的应是第三个命令，执行撤销后恢复为 2。")

	_history.undo_last()
	assert_eq(counter.value, 1, "再次撤销的是第二个命令，执行撤销后恢复为 1。")

	assert_false(_history.undo_last(), "第一条命令应已被超限丢弃，无法再撤销。")


# --- 测试：深拷贝快照 (Task 7) ---

## 验证 set_snapshot 对于引用类型（字典/数组）执行深拷贝，防止外部修改破坏快照。
func test_snapshot_deep_copy() -> void:
	var data := {"a": 1, "b": [1, 2]}
	var cmd := CounterCommand.new({})

	cmd.set_snapshot(data)

	# 修改原数据
	data["a"] = 99
	data["b"].append(3)

	var snapshot: Dictionary = cmd.get_snapshot()
	assert_eq(snapshot["a"], 1, "字典快照不应受原字典修改影响。")
	assert_eq(snapshot["b"].size(), 2, "嵌套数组快照不应受原数组修改影响。")
