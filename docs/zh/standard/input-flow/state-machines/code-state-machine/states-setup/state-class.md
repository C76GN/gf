# 创建状态类

纯代码状态脚本继承 `GFState`。它适合不需要直接依赖场景树的流程状态，例如 AI 决策、界面逻辑、回合阶段或工具流程。

## 状态生命周期

```gdscript
class_name MoveState
extends GFState

var owner_entity: Node2D

func enter(_msg: Dictionary = {}) -> void:
	# 可以通过 change_state() 或 get_model()/get_system() 访问状态机上下文。
	pass


func update(delta: float) -> void:
	if owner_entity == null:
		return


func exit() -> void:
	pass
```

## 守卫与事件

```gdscript
func can_exit(next_state: StringName = &"", _msg: Dictionary = {}) -> bool:
	return next_state != &"Locked"


func handle_state_event(event_id: StringName, payload: Variant = null) -> bool:
	if event_id == &"cancel":
		change_state(&"Idle")
		return true
	return false
```

状态内部可以通过明确的 `get_model()`、`get_system()`、`get_utility()` 访问需要的依赖。依赖访问的细节见 [依赖代理与事件监听](../dependencies-events.md)。

## 使用边界

状态类应表达状态进入、更新、退出和局部事件处理。长期数据应放在 Model，跨状态调度应放在 System 或状态机外部流程中。
