# Controller 更新边界

继承自 `Node` 的 `GFController` 通常承担特效表现、玩家输入转发和 UI 动画插值等渲染职责。它们仍依附于 Godot 原生 `_process()` 与 `_physics_process()`。

```gdscript
class_name PlayerInputController extends GFController

func _process(delta: float) -> void:
	var x_input := Input.get_axis("ui_left", "ui_right")

	if x_input != 0:
		var move_cmd := MoveCommand.new()
		move_cmd.direction = Vector2(x_input, 0)
		Gf.send_command(move_cmd)
```

Controller 可以按普通 Godot 节点习惯读取输入、驱动局部动画和访问宿主节点。它应把干净的指令、命令或事件交给 System，而不是在场景节点里保存核心业务状态。
