# 逻辑延迟定时器

Godot 的 `get_tree().create_timer(1.0).timeout` 与场景树绑定。如果等待期间切换场景，临时节点或控制器容易留下失效回调。需要受 `GFTimeUtility` 控制、可按 owner 自动清理的逻辑计时时，使用 `GFTimerUtility`。

## 基础用法

```gdscript
var timer_util := Gf.get_utility(GFTimerUtility) as GFTimerUtility

# 延迟 1.5 秒后执行一次回调
timer_util.execute_after(1.5, func() -> void:
	print("1.5秒逻辑时间后触发")
)

var handle := timer_util.execute_repeating(0.25, func() -> void:
	print("tick")
, 4)

timer_util.execute_after_owned(self, 2.0, func() -> void:
	print("owner 仍然存在时才会触发")
)
```

`execute_after()` 处理一次性延迟任务；`execute_repeating()` 处理固定间隔任务，`repeat_count < 0` 表示无限重复。

`execute_after_owned()` / `execute_repeating_owned()` 会用弱引用追踪 owner，owner 释放后任务自动丢弃，适合 UI、临时场景对象或短生命周期控制器注册逻辑计时。

排队成功时会返回大于 `0` 的句柄，可用 `cancel(handle)` 取消，或用 `cancel_owner(owner)` 批量取消同一 owner 的任务。

它由架构 tick 传入的逻辑 delta 推进；通常会自然受到 `GFTimeUtility` 的缩放和暂停结果影响，但如果项目手动调用 `timer_util.tick(delta)`，传入什么 delta 就按什么时间推进。

`get_debug_snapshot()` 可查看 pending 数量、句柄和 owner 绑定任务数量；框架 `dispose()` 时会清空尚未触发的任务。
