# addons/gf/extensions/command/gf_undoable_command.gd

## GFUndoableCommand: 可撤销命令的抽象基类。
##
## 继承自 GFCommand，在标准命令的基础上新增撤销能力。
## 子类须在 execute() 执行前通过 set_snapshot() 保存当前状态快照，
## 并在 undo() 中借助 get_snapshot() 取回快照以还原数据，
## 从而支持解谜、战棋等游戏的回放与悔步功能。
class_name GFUndoableCommand
extends GFCommand

# --- 公共变量 ---

## 在 UI 历史记录面板中显示当前命令的名称描述。
var action_name: String = "未命名动作"


# --- 私有变量 ---

## 执行前保存的状态快照，用于 undo() 时还原。
var _snapshot: Variant = null


# --- 公共方法 ---

## 执行命令逻辑。子类必须重写此方法，并建议在此处先调用 set_snapshot()。
## @return 同步命令返回 null；异步命令可返回 Signal 供外部 await。
func execute() -> Variant:
	return null


## 撤销命令。子类必须重写此方法，使用 get_snapshot() 还原状态。
func undo() -> void:
	pass


## 保存执行前的状态快照。应在 execute() 内部、修改数据之前调用。
## @param data: 任意可序列化的快照数据（如字典、数值、数组）。
func set_snapshot(data: Variant) -> void:
	if typeof(data) == TYPE_DICTIONARY or typeof(data) == TYPE_ARRAY:
		_snapshot = data.duplicate(true) # 强制深拷贝，避免引用陷阱
	else:
		_snapshot = data


## 获取由 set_snapshot() 保存的状态快照。在 undo() 中调用以还原数据。
## @return 之前保存的快照数据，不存在则返回 null。
func get_snapshot() -> Variant:
	return _snapshot
