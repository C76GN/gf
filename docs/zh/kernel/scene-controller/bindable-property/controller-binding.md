# Controller 订阅

UI 不需要订阅全局业务事件，只需处理当前字段变化的回调。

```gdscript
class_name PlayerHUDController extends GFController

@onready var lvl_label: Label = $LvlLabel

func _ready() -> void:
	var player_model := Gf.get_model(PlayerModel) as PlayerModel

	# 绑定到自身，节点退出树时自动断开，不经过全局 Event System
	player_model.level.bind_to(self, _on_level_changed)

	# 立即刷新一次初始状态
	_on_level_changed(null, player_model.level.get_value())

func _on_level_changed(_old_level: Variant, new_level: Variant) -> void:
	lvl_label.text = "Lv: " + str(new_level)
```

回调会接收旧值和新值。Controller 应在绑定后主动刷新一次初始 UI，避免等到下一次字段变化才显示正确状态。

没有 Node 生命周期可以绑定时，可以使用 `subscribe()` 获取取消订阅函数，并由持有方在自己的释放流程中调用。`emit_current` 为 `true` 时会立即以当前值调用一次回调：

```gdscript
var unsubscribe_level := player_model.level.subscribe(_on_level_changed, true)

func dispose() -> void:
	if unsubscribe_level.is_valid():
		unsubscribe_level.call()
```
