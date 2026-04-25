## GFCommandHistoryUtility: 可撤销命令历史管理器。
##
## 负责维护 `GFUndoableCommand` 的撤销栈与重做栈，
## 并提供同步/异步重放与历史序列化能力。
class_name GFCommandHistoryUtility
extends GFUtility


# --- 公共变量 ---

## 撤销栈的最大容量；为 0 时表示不限制。
var max_history_size: int = 1024

## 当前撤销栈深度。
var undo_count: int:
	get:
		return _undo_stack.size()

## 当前重做栈深度。
var redo_count: int:
	get:
		return _redo_stack.size()


# --- 私有变量 ---

## 已执行命令的撤销栈。
var _undo_stack: Array[GFUndoableCommand] = []

## 已撤销命令的重做栈。
var _redo_stack: Array[GFUndoableCommand] = []

## 当前是否正在等待一条异步命令完成。
var _is_processing_async: bool = false


# --- Godot 生命周期方法 ---

func init() -> void:
	_undo_stack = []
	_redo_stack = []
	_is_processing_async = false


# --- 公共方法 ---

## 记录一条已经执行完成的命令。
## @param cmd: 已执行的命令实例。
func record(cmd: GFUndoableCommand) -> void:
	if not is_instance_valid(cmd):
		return
	if _is_processing_async:
		push_warning("[GFCommandHistoryUtility] 当前正在处理异步命令，忽略新的历史记录。")
		return

	_record_internal(cmd)


## 执行命令并自动记录到撤销栈。
## @param cmd: 要执行的命令实例。
## @return `execute()` 的原始返回值；异步命令可由调用方自行 `await`。
func execute_command(cmd: GFUndoableCommand) -> Variant:
	if not is_instance_valid(cmd):
		return null
	if _is_processing_async:
		push_warning("[GFCommandHistoryUtility] 当前正在处理异步命令，忽略新的执行请求。")
		return null

	var result: Variant = cmd.execute()
	if result is Signal:
		_is_processing_async = true
		await result
		_is_processing_async = false
	_record_internal(cmd)
	return result


## 撤销最后一条命令。
## @return 成功撤销时返回 `true`。
func undo_last() -> bool:
	if _is_processing_async or _undo_stack.is_empty():
		return false

	var cmd: GFUndoableCommand = _undo_stack.pop_back()
	cmd.undo()
	_redo_stack.push_back(cmd)
	return true


## 异步撤销最后一条命令。
## @return 成功撤销时返回 `true`。
func undo_last_async() -> bool:
	if _is_processing_async or _undo_stack.is_empty():
		return false

	var cmd: GFUndoableCommand = _undo_stack.pop_back()
	var result: Variant = cmd.undo()
	if result is Signal:
		_is_processing_async = true
		await result
		_is_processing_async = false

	_redo_stack.push_back(cmd)
	return true


## 重做最近被撤销的命令。
## @return 成功重做时返回 `true`。
func redo() -> bool:
	if _is_processing_async or _redo_stack.is_empty():
		return false

	var cmd: GFUndoableCommand = _redo_stack.pop_back()
	cmd.execute()
	_undo_stack.push_back(cmd)
	return true


## 异步重做最近被撤销的命令。
## @return 成功重做时返回 `true`。
func redo_async() -> bool:
	if _is_processing_async or _redo_stack.is_empty():
		return false

	var cmd: GFUndoableCommand = _redo_stack.pop_back()
	var result: Variant = cmd.execute()
	if result is Signal:
		_is_processing_async = true
		await result
		_is_processing_async = false

	_undo_stack.push_back(cmd)
	return true


## 清空所有历史记录。
func clear() -> void:
	if _is_processing_async:
		push_warning("[GFCommandHistoryUtility] 当前正在处理异步命令，忽略清空请求。")
		return

	_undo_stack.clear()
	_redo_stack.clear()


## 检查当前是否允许撤销。
## @return 有可撤销命令时返回 `true`。
func can_undo() -> bool:
	return not _undo_stack.is_empty()


## 检查当前是否允许重做。
## @return 有可重做命令时返回 `true`。
func can_redo() -> bool:
	return not _redo_stack.is_empty()


## 获取撤销栈副本。
## @return 撤销历史的浅拷贝。
func get_undo_history() -> Array[GFUndoableCommand]:
	return _undo_stack.duplicate()


## 获取重做栈副本。
## @return 重做历史的浅拷贝。
func get_redo_history() -> Array[GFUndoableCommand]:
	return _redo_stack.duplicate()


## 将撤销栈序列化为纯数据数组。
## @return 适合持久化的历史数据。
func serialize_history() -> Array[Dictionary]:
	return _serialize_stack(_undo_stack)


## 将完整命令历史序列化为纯数据字典。##
## 包含 `undo` 与 `redo` 两个栈，可用于全量运行时快照恢复。##
## @return 适合持久化的完整历史数据。##
func serialize_full_history() -> Dictionary:
	return {
		"undo": _serialize_stack(_undo_stack),
		"redo": _serialize_stack(_redo_stack),
	}


## 通过构造器从纯数据恢复撤销栈。
## @param data_array: 历史数据数组。
## @param command_builder: 负责反序列化命令实例的构造器。
func deserialize_history(data_array: Array, command_builder: Callable) -> void:
	if _is_processing_async:
		push_warning("[GFCommandHistoryUtility] 当前正在处理异步命令，忽略历史恢复请求。")
		return

	_undo_stack.clear()
	_redo_stack.clear()

	if not command_builder.is_valid():
		push_error("[GFCommandHistoryUtility] deserialize_history 失败：传入的 builder Callable 无效。")
		return

	for data in data_array:
		if typeof(data) == TYPE_DICTIONARY:
			var restored_cmd: GFUndoableCommand = command_builder.call(data)
			if is_instance_valid(restored_cmd):
				_undo_stack.append(restored_cmd)


## 通过构造器从完整历史数据恢复撤销栈与重做栈。##
## @param data: 由 `serialize_full_history()` 生成的字典数据。##
## @param command_builder: 负责反序列化命令实例的构造器。##
func deserialize_full_history(data: Dictionary, command_builder: Callable) -> void:
	if _is_processing_async:
		push_warning("[GFCommandHistoryUtility] 当前正在处理异步命令，忽略完整历史恢复请求。")
		return

	_undo_stack.clear()
	_redo_stack.clear()

	if not command_builder.is_valid():
		push_error("[GFCommandHistoryUtility] deserialize_full_history 失败：传入的 builder Callable 无效。")
		return

	_undo_stack = _deserialize_stack(data.get("undo", []), command_builder)
	_redo_stack = _deserialize_stack(data.get("redo", []), command_builder)


# --- 私有/辅助方法 ---

func _record_internal(cmd: GFUndoableCommand) -> void:
	_undo_stack.push_back(cmd)
	_redo_stack.clear()

	if max_history_size > 0 and _undo_stack.size() > max_history_size:
		_undo_stack.pop_front()


func _serialize_stack(stack: Array[GFUndoableCommand]) -> Array[Dictionary]:
	var arr: Array[Dictionary] = []
	for cmd in stack:
		if cmd.has_method("serialize"):
			arr.append(cmd.serialize())
		else:
			arr.append({ "snapshot": cmd.get_snapshot() })

	return arr


func _deserialize_stack(data_array: Array, command_builder: Callable) -> Array[GFUndoableCommand]:
	var restored_stack: Array[GFUndoableCommand] = []

	for data in data_array:
		if typeof(data) != TYPE_DICTIONARY:
			continue

		var restored_cmd: GFUndoableCommand = command_builder.call(data)
		if is_instance_valid(restored_cmd):
			restored_stack.append(restored_cmd)

	return restored_stack
