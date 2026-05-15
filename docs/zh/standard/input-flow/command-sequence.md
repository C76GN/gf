# 撤销历史与指令序列

这些命令工具面向操作撤销、重做和顺序编排，适合编辑器、棋盘、流程脚本和可回滚交互。

## 可撤销命令历史 (`GFUndoableCommand`)

`GFUndoableCommand` 在命令的基础语义上增加 `set_snapshot()` / `get_snapshot()` 与 `undo()`，适合关卡编辑器、棋盘移动、编辑器预览和其他需要按步骤撤销的流程。

配合 `GFCommandHistoryUtility` 管理执行、撤销和重做：

`set_snapshot()` 适合保存标量、数组和字典等值数据；如果快照里包含 `Object`、`Resource`、`Node` 或自定义引用，业务层应自行转换为可恢复的纯数据，避免撤销时继续引用同一个运行时对象。异步可撤销命令应使用历史工具的异步入口，并理解超时只能停止历史栈等待，不能取消已经开始的命令副作用。

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

执行命令时，通过工具层接管执行权限自动压栈：

```gdscript
var stack = Gf.get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility
stack.execute_command(MoveTileUndoableCommand.new(Vector2(5, 6)))

stack.undo_last()
```

---


## 通用指令序列 (`GFCommandSequence`)

`GFCommandSequence` 用于把一组步骤、命令对象或 callable 串行执行。它只处理顺序、等待和架构注入，不绑定任何项目规则。步骤可以继承 `GFSequenceStep`，也可以是实现了 `execute()` / `resolve()` 的普通对象。

```gdscript
class_name WaitForTweenStep
extends GFSequenceStep

var target: Node2D


func execute(_context: GFSequenceContext) -> Variant:
	var tween := target.create_tween()
	tween.tween_property(target, "modulate:a", 0.0, 0.2)
	return tween.finished
```

```gdscript
var context := GFSequenceContext.new()
var wait_step := GFWaitSequenceStep.new()
wait_step.duration = 0.2

var sequence := GFCommandSequence.new([
	WaitForTweenStep.new(),
	wait_step,
	func() -> void:
		print("sequence finished")
], context)

sequence.run()
```

如果步骤返回 `Signal`，默认会等待；Signal 发出的第一个参数会作为该步骤结果继续进入失败策略判断，多个参数会以数组形式保留。因此异步步骤可以 `completed.emit({ "ok": false, "error": "..." })`，序列会像同步返回失败字典一样处理。`GFSequenceStep.wait_for_result = false` 可把某个步骤声明为不阻塞序列。`cancel()` 会先通知当前步骤的 `cancel(context)` 钩子；普通对象步骤如果提供无参 `cancel()` 也会被调用。随后序列会停止当前等待、不再执行后续步骤，并发出 `sequence_cancelled`。Signal 等待默认有 30 秒超时，`with_signal_timeout(seconds, respect_time_scale)` 可配置等待上限，并默认跟随 `GFTimeUtility` 的暂停与 `time_scale`。

需要更严格的流程控制时，可以配置失败策略。步骤返回 `{"ok": false, "error": "..."}`、`{"success": false}` 或 `{"status": "error"}` / `"failed"` / `"failure"` 这类失败字典时，序列会发出 `step_failed`，并把结果写入 `last_run_report`；失败步骤不会同时发出 `step_completed`。只 `push_error()` 或返回任意自定义对象不会自动被视为失败；项目层应把可判定失败的步骤收敛为这些结果字典。默认继续执行后续步骤；开启 `stop_on_error` 后会停止，开启 `rollback_on_failure` 后会逆序调用已完成步骤的 `undo()`。

```gdscript
var sequence := GFCommandSequence.new([
	PrepareStep.new(),
	ApplyStep.new(),
	CommitStep.new(),
]).with_failure_policy(true, true)

await sequence.run()

if sequence.last_run_report.get("failed", false):
	push_warning(sequence.last_run_report.get("error", "Sequence failed."))
```

失败报告只描述流程执行状态，不解释错误业务含义。项目层可以把它接到日志、诊断面板或编辑器验证工具。

---
