# 启动状态变化信号

`start()` 会把初始进入也视为一次状态变化。

进入成功后默认发出 `state_changed`，其中 `from_state = &""`，`to_state` 为初始状态名。

这样 UI、调试面板、动画桥和日志系统只需要监听同一个信号，不必为“启动时的当前状态”单独写初始化分支。

```gdscript
fsm.state_changed.connect(_on_state_changed)
fsm.start(&"Idle") # 发出 from_state = &""，to_state = &"Idle"
```

只有在少数需要静默装配内部状态的场景，才建议传入第三个参数 `false`。
