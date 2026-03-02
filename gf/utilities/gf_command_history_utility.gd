# gf/utilities/gf_command_history_utility.gd

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


# --- 常量 ---

## 撤销栈的最大容量，超出后将移除最旧的记录。0 表示无限制。
const MAX_HISTORY_SIZE: int = 64


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

	if MAX_HISTORY_SIZE > 0 and _undo_stack.size() > MAX_HISTORY_SIZE:
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


## 重新执行最近被撤销的命令。
## @return 成功重做返回 true，重做栈为空时返回 false。
func redo() -> bool:
	if _redo_stack.is_empty():
		return false

	var cmd: GFUndoableCommand = _redo_stack.pop_back()
	cmd.execute()
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
