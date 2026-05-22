@tool

## GFEditorCommand: 可撤销编辑器操作的通用基类。
##
## 用于把编辑器 UI、快捷键或交互工具产生的修改收敛成可执行、可撤销的命令。
## 命令只描述操作协议，不绑定具体资源、节点类型或业务含义。
## [br]
## @api public
## [br]
## @category editor_api
## [br]
## @since 3.17.0
## [br]
## @layer kernel/editor
class_name GFEditorCommand
extends RefCounted


# --- 公共变量 ---

## 命令显示名称，会作为 UndoRedo action 名称使用。
## [br]
## @api public
var command_name: String = "GF Editor Command"

## 调用方可附加的上下文数据。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary for caller-defined command metadata.
var metadata: Dictionary = {}


# --- 私有变量 ---

var _executed: bool = false


# --- 公共方法 ---

## 执行命令。
## [br]
## @api public
## [br]
## @return Godot 错误码。
func execute() -> Error:
	if not can_execute():
		return ERR_UNAVAILABLE

	var error := _do_it()
	if error == OK:
		_executed = true
	return error


## 撤销命令。
## [br]
## @api public
## [br]
## @return Godot 错误码。
func revert() -> Error:
	if not _executed and not can_revert_before_execute():
		return ERR_UNAVAILABLE

	var error := _undo_it()
	if error == OK:
		_executed = false
	return error


## 将命令写入 Godot 编辑器 UndoRedo 管理器。
## [br]
## @api public
## [br]
## @param undo_manager: EditorUndoRedoManager 或兼容对象。
## [br]
## @param execute_immediately: 提交 action 时是否立即执行 do 方法。
## [br]
## @return Godot 错误码。
func add_to_undo_manager(undo_manager: Object, execute_immediately: bool = true) -> Error:
	if undo_manager == null:
		return ERR_UNCONFIGURED
	if not undo_manager.has_method("create_action"):
		return ERR_INVALID_PARAMETER
	if not undo_manager.has_method("add_do_method"):
		return ERR_INVALID_PARAMETER
	if not undo_manager.has_method("add_undo_method"):
		return ERR_INVALID_PARAMETER
	if not undo_manager.has_method("commit_action"):
		return ERR_INVALID_PARAMETER

	undo_manager.call("create_action", command_name)
	undo_manager.call("add_do_method", self, "execute")
	undo_manager.call("add_undo_method", self, "revert")
	if undo_manager.has_method("add_do_reference"):
		undo_manager.call("add_do_reference", self)
	if undo_manager.has_method("add_undo_reference"):
		undo_manager.call("add_undo_reference", self)
	undo_manager.call("commit_action", execute_immediately)
	return OK


## 当前命令是否已执行。
## [br]
## @api public
## [br]
## @return 已执行时返回 true。
func is_executed() -> bool:
	return _executed


## 命令当前是否允许执行。
## [br]
## @api public
## [br]
## @return 允许执行时返回 true。
func can_execute() -> bool:
	return true


## 未执行时是否仍允许调用 revert()。
## [br]
## @api public
## [br]
## @return 未执行时允许撤销返回 true。
func can_revert_before_execute() -> bool:
	return false


## 获取调试快照。
## [br]
## @api public
## [br]
## @return 调试信息字典。
## [br]
## @schema return: Dictionary containing command_name, executed, and metadata.
func get_debug_snapshot() -> Dictionary:
	return {
		"command_name": command_name,
		"executed": _executed,
		"metadata": metadata.duplicate(true),
	}


# --- 虚方法（由子类重写） ---

## 执行具体编辑器操作，供子类重写。
## [br]
## @api protected
## [br]
## @return Godot 错误码。
func _do_it() -> Error:
	return OK


## 撤销具体编辑器操作，供子类重写。
## [br]
## @api protected
## [br]
## @return Godot 错误码。
func _undo_it() -> Error:
	return OK
