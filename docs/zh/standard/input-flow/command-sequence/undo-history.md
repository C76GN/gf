# 可撤销命令历史

`GFUndoableCommand` 在命令基础语义上增加 `set_snapshot()`、`get_snapshot()` 和 `undo()`，适合关卡编辑器、棋盘移动、编辑器预览和其他需要按步骤撤销的流程。`GFCommandHistoryUtility` 负责执行命令、自动压栈、撤销和重做。

## 快照语义

`set_snapshot()` 适合保存标量、数组和字典等值数据。如果快照里包含 `Object`、`Resource`、`Node` 或自定义引用，业务层应自行转换为可恢复的纯数据，避免撤销时继续引用同一个运行时对象。

```gdscript
class_name MoveTileUndoableCommand extends GFUndoableCommand

var new_pos: Vector2

func _init(n_pos):
	new_pos = n_pos

func execute() -> Variant:
	var grid_model := get_model(GridModel) as GridModel
	if grid_model == null:
		return null

	set_snapshot(grid_model.current_pos)
	grid_model.current_pos = new_pos
	return null

func undo() -> Variant:
	var grid_model := get_model(GridModel) as GridModel
	if grid_model == null:
		return null

	grid_model.current_pos = get_snapshot()
	return null
```

## 历史栈

```gdscript
var stack := Gf.get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility
stack.execute_command(MoveTileUndoableCommand.new(Vector2(5, 6)))

stack.undo_last()
```

## 使用边界

异步可撤销命令应使用历史工具的异步入口。超时只能停止历史栈等待，不能取消已经开始的命令副作用；如果命令需要取消，应在项目命令里显式实现可取消逻辑。
