# 指针活动状态

如果项目需要把鼠标或触摸事件整理成“按下、移动、拖拽、空闲”的通用状态，而不是立刻绑定到按钮、棋盘或摄像机业务，可以注册或直接持有 `GFPointerActivityUtility`。

它不会读取全局 `Input`，也不会消费事件；项目在 `_input(event)` 中显式转发即可。

```gdscript
var pointer := Gf.get_utility(GFPointerActivityUtility) as GFPointerActivityUtility
pointer.drag_threshold_pixels = 8.0
pointer.idle_threshold_seconds = 0.5

func _input(event: InputEvent) -> void:
	pointer.handle_input_event(event)

func _process(delta: float) -> void:
	pointer.tick(delta)
```

`GFPointerActivityUtility` 发出 `pointer_pressed`、`pointer_moved`、`pointer_drag_started`、`pointer_dragged`、`pointer_drag_ended`、`pointer_released` 和空闲相关信号，只描述输入活动本身。

是否把拖拽解释成地图平移、物品拖放、框选、UI 滚动或编辑器画刷，应继续留在项目层或具体工具层。
