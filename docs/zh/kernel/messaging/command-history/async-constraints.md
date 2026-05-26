# 异步撤销与重做

如果 `GFUndoableCommand.execute()` 或 `undo()` 会返回 `Signal`，例如等待动画、网络确认或异步资源流程，请使用异步版本的历史操作。

```gdscript
var history := Gf.get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility

await history.undo_last_async()
await history.redo_async()
```

同步版本 `undo_last()` / `redo()` 会保持原有立即返回的行为，适合纯数据命令。

异步版本会在命令返回 `Signal` 时等待完成后再移动撤销/重做栈。

`GFCommandHistoryUtility.async_timeout_seconds` 只会停止历史操作的等待和入栈/出栈推进，无法强制取消已经开始的 coroutine，也不会自动回滚命令已经产生的副作用。

异步命令执行期间，历史工具会拒绝新的执行、记录、清空或恢复请求并输出 warning。

需要排队的高频操作应放入项目层队列或 `GFCommandSequence`。
