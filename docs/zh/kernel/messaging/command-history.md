# 命令历史与撤销重做

本页拆出 `GFCommandHistoryUtility` 的执行历史、撤销、重做、序列化、恢复和异步操作约束。
## 配合撤销栈实现 Undo/Redo

当你使用了 `GFCommand` 这种严谨模式编码操作指令时，可以接入 GF Framework 提供的 **基于 `GFUndoableCommand` 的撤销重做栈扩展体系**。

你只需要：
1. 使它继承自 `GFUndoableCommand`
2. 使用 `GFCommandHistoryUtility` 管理系统对它施加 `execute_command(cmd)` 调用
3. 通过历史工具统一执行、撤销和重做命令。

### 命令历史的序列化与持久化 (Command History Persistence)

自 v1.1.0 起，`GFCommandHistoryUtility` 支持将整个撤销/重做栈序列化为纯数据，以便于存入玩家存档文件（JSON 等）。

**序列化历史记录：**
```gdscript
var history := Gf.get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility
var saved_data_array: Array = history.serialize_history()
# 将 saved_data_array 使用 GFStorageUtility 等方式写入你的存档文件
```
> 若你想定制序列化结构，需确保你的 `GFUndoableCommand` 子类覆盖了 `serialize() -> Dictionary` 方法。如果未提供，框架默认将只提取其 `get_snapshot()` 作为数据。
> `set_snapshot()` 会对 `Dictionary` 和 `Array` 做深拷贝，但其中包含的 `Object`、`Resource`、`Node` 或自定义引用仍可能共享同一实例。复杂对象快照应由业务层转换为标量、字典或自定义序列化数据。

**反序列化历史记录：**
```gdscript
var history := Gf.get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility

# 由于框架层不感知具体的 Command 类型，需要外部传入构建器(Callable)来实现控制反转
var command_builder = func(data: Dictionary) -> GFUndoableCommand:
	var cmd_type = data.get("type", "")
	if cmd_type == "TakeDamage":
		var c = TakeDamageCommand.new()
		c.set_snapshot(data.get("snapshot", null)) # 恢复快照
		return c
	return null

history.deserialize_history(saved_data_array, command_builder)
```
> **提示：** `GFCommandHistoryUtility` 具有最大历史数限制属性 `max_history_size`（默认为 `1024`）。当历史数量超过限制时，最早的操作会被移除以释放内存。

### 异步撤销与重做

如果你的 `GFUndoableCommand.execute()` 或 `undo()` 会返回 `Signal`（例如等待动画、网络确认或异步资源流程），请使用异步版本的历史操作：

```gdscript
var history := Gf.get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility

await history.undo_last_async()
await history.redo_async()
```

同步版本 `undo_last()` / `redo()` 会保持原有立即返回的行为，适合纯数据命令；异步版本会在命令返回 `Signal` 时等待完成后再移动撤销/重做栈。`GFCommandHistoryUtility.async_timeout_seconds` 只会停止历史操作的等待和入栈/出栈推进，无法强制取消已经开始的 coroutine，也不会自动回滚命令已经产生的副作用。异步命令执行期间，历史工具会拒绝新的执行、记录、清空或恢复请求并输出 warning；需要排队的高频操作应放入项目层队列或 `GFCommandSequence`。

命令历史、快照历史和流程编排的更多用法，可继续阅读 [本地存储、编码、同步与快照](../../standard/utilities/io/storage-snapshot.md) 与 [撤销历史与指令序列](../../standard/input-flow/command-sequence.md)。
