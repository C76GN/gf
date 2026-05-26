# Model 属性定义

在没有 GF Framework 之前，如果 UI 想要在玩家等级发生变化时更新文字显示，往往需要玩家模块广播专门的 `PlayerLvlChangedEvent` 事件，然后 UI 端再订阅、解析 payload 并更新界面。

如果大量 UI 字段都用全局事件同步，事件总线会承担过多局部展示职责，也会让调试日志和事件追踪变得嘈杂。

`GFBindableProperty` 位于 `addons/gf/kernel/core/gf_bindable_property.gd`。它是对单实例值的封装槽体，内部含有一个 `value_changed` 响应信号。

工作模型是标准观察者模式：

```text
Model (Hold Property) -> Controller (Subscribe)
```

普通 `GFBindableProperty` 本身不阻止外部调用 `set_value()`。如果某个值只应该由 Model 内部修改，应在 Model 上封装业务方法，或对外暴露 `GFReadOnlyBindableProperty` 只读视图。

```gdscript
class_name PlayerModel extends GFModel

# 定义属性，初始化值为 1
var level := GFBindableProperty.new(1)
var player_name := GFBindableProperty.new("Guest")

func level_up() -> void:
	# 修改值会向订阅者触发原生 signal
	level.set_value(level.get_value() + 1)
```
