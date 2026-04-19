# addons/gf/utilities/gf_command_history_utility.gd

## GFCommandHistoryUtility: 可撤销命令历史管理器。
##
## 继承自 GFUtility，管理由 GFUndoableCommand 组成的撤销栈与重做栈。
## 适用于解谜（Puzzle）、战棋（TRPG）等需要悔步与回放的游戏类型。
##
## 工作流程：
##   1. 业务层执行命令后，调用 record(cmd) 将命令记录入历史。
##   2. 调用 undo_last() 撤销最后一条命令并将其压入重做栈。
##   3. 调用 redo() 重新执行最近被撤销的命令并将其压回撤销栈。
class_name GFCommandHistoryUtility
extends GFUtility


# --- 公共变量 ---

## 撤销栈的最大容量，超出后将移除最旧的记录。0 表示无限制。
var max_history_size: int = 1024


# --- 公共变量 ---

## 当前撤销栈的深度。
var undo_count: int:
	get:
		return _undo_stack.size()

## 当前重做栈的深度。
var redo_count: int:
	get:
		return _redo_stack.size()


# --- 私有变量 ---

## 记录已执行命令的撤销栈，栈顶为最近执行的命令。
var _undo_stack: Array[GFUndoableCommand] = []

## 记录已撤销命令的重做栈，栈顶为最近被撤销的命令。
var _redo_stack: Array[GFUndoableCommand] = []


# --- Godot 生命周期方法 ---

## 第一阶段初始化：清空历史记录栈。
func init() -> void:
	_undo_stack = []
	_redo_stack = []


# --- 公共方法 ---

## 将一条已执行的命令记录到历史。
## 记录后将清空重做栈（因为新操作会打断重做分支）。
## @param cmd: 已成功执行的 GFUndoableCommand 实例。
func record(cmd: GFUndoableCommand) -> void:
	if not is_instance_valid(cmd):
		return

	_undo_stack.push_back(cmd)
	_redo_stack.clear()

	if max_history_size > 0 and _undo_stack.size() > max_history_size:
		_undo_stack.pop_front()


## 撤销最后一条命令。
## @return 成功撤销返回 true，撤销栈为空时返回 false。
func undo_last() -> bool:
	if _undo_stack.is_empty():
		return false

	var cmd: GFUndoableCommand = _undo_stack.pop_back()
	cmd.undo()
	_redo_stack.push_back(cmd)

	return true


## 异步撤销最后一条命令。若命令 undo() 返回 Signal，则等待其完成后再进入重做栈。
## @return 成功撤销返回 true，撤销栈为空时返回 false。
func undo_last_async() -> bool:
	if _undo_stack.is_empty():
		return false

	var cmd: GFUndoableCommand = _undo_stack.pop_back()
	var result: Variant = cmd.undo()
	if result is Signal:
		await result
	_redo_stack.push_back(cmd)

	return true


## 重新执行最近被撤销的命令。
## @return 成功重做返回 true，重做栈为空时返回 false。
func redo() -> bool:
	if _redo_stack.is_empty():
		return false

	var cmd: GFUndoableCommand = _redo_stack.pop_back()
	cmd.execute()
	_undo_stack.push_back(cmd)

	return true


## 异步重新执行最近被撤销的命令。若命令 execute() 返回 Signal，则等待其完成后再回到撤销栈。
## @return 成功重做返回 true，重做栈为空时返回 false。
func redo_async() -> bool:
	if _redo_stack.is_empty():
		return false

	var cmd: GFUndoableCommand = _redo_stack.pop_back()
	var result: Variant = cmd.execute()
	if result is Signal:
		await result
	_undo_stack.push_back(cmd)

	return true


## 清空所有历史记录。
func clear() -> void:
	_undo_stack.clear()
	_redo_stack.clear()


## 检查撤销栈是否有可撤销的命令。
## @return 有可撤销的命令返回 true。
func can_undo() -> bool:
	return not _undo_stack.is_empty()


## 检查重做栈是否有可重做的命令。
## @return 有可重做的命令返回 true。
func can_redo() -> bool:
	return not _redo_stack.is_empty()


## 获取当前撤销栈的浅拷贝，防止外部（如 UI 控制器）意外修改或清空内部状态。
## @return 包含所有可撤销命令的数组。
func get_undo_history() -> Array[GFUndoableCommand]:
	return _undo_stack.duplicate()


## 获取当前重做栈的浅拷贝，防止外部（如 UI 控制器）意外修改或清空内部状态。
## @return 包含所有可重做命令的数组。
func get_redo_history() -> Array[GFUndoableCommand]:
	return _redo_stack.duplicate()


## 将当前撤销栈序列化为纯数据数组，以便于持久化存档（JSON等）。
## 它会优先调用命令对象的 serialize() 方法。如果未实现，则保底提取其快照数据。
## @return 包含所有历史操作数据的字典数组。
func serialize_history() -> Array[Dictionary]:
	var arr: Array[Dictionary] = []
	for cmd in _undo_stack:
		if cmd.has_method("serialize"):
			arr.append(cmd.serialize())
		else:
			arr.append({"snapshot": cmd.get_snapshot()})
	return arr


## 从纯数据数组反序列化并重建撤销栈。
## 由于框架层不感知具体的 Command 类型，需要外部传入构建器(Callable)来实现控制反转。
## @param data_array: 存储了各步骤数据的数组（通常来自读取存档）。
## @param command_builder: 签名为 func(data: Dictionary) -> GFUndoableCommand 的回调函数。
func deserialize_history(data_array: Array, command_builder: Callable) -> void:
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
