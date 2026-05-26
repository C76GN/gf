# 初始化状态机

```gdscript
var fsm := GFStateMachine.new()
fsm.add_state(&"Grounded", GroundedState.new())
fsm.add_state(&"Idle", IdleState.new(), &"Grounded")
fsm.add_state(&"Run", MoveState.new(), &"Grounded")
fsm.add_state(&"Airborne", AirborneState.new())

fsm.start(&"Idle")
fsm.change_state(&"Run")

# 在你自己的任何主循环 (Tick 或 _process) 中驱动分发
fsm.update(delta)
```

状态机可以由项目自己的 tick、`_process()`、测试代码或局部系统驱动。GFStateMachine 只负责状态组织和切换语义，不规定主循环来源。
