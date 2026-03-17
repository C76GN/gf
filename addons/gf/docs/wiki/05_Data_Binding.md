# 05. 数据绑定 (Data Binding)

在没有 GF Framework 之前，如果 UI 想要在玩家等级发生变化时更新文字显示，往往需要玩家模块广播极其繁琐的 `PlayerLvlChangedEvent` 事件，然后 UI 端去订阅、解析 payload 并进行更新。

如果有100个属性需要这样的同步怎么办？事件总线将成为"上帝对象"（God Object），污染并且阻塞大量系统调试日志。

这就是 GF Framework 中 `BindableProperty` 的由来，旨在提供**局部、无事件总线开销的数据驱动绑定机制。**

## 什么是 BindableProperty

`BindableProperty` 位于 `addons/gf/core/bindable_property.gd` 下。它是对所有单实例值的再封装槽体，内部含有一个 `value_changed` 响应信号。

### 工作模型
它是典型的观察者模式（Observer Meta-Pattern）:
`Model (Hold Property) ---> Controller (Subscribe)`

## 基础用法

### 1. 在 Model 中定义一个绑定属性

请注意，要暴露出去供 UI 更新的数据，一律禁止外部直接对其直接写入修改，这也是我们使用该类型封装的重要原因。

```gdscript
class_name PlayerModel extends GFModel

# 定义属性，初始化值为 1
var level := BindableProperty.new(1)
var player_name := BindableProperty.new("Guest")

func level_up() -> void:
	# 修改它的 .value 将安全地向所有订阅者触发出原生 signal
	level.value += 1
```

### 2. 在 Controller（表现层）订阅变化

UI不需要进行任何繁重的强转验证协议交互，只需关心自身数据变更的回调即可！

```gdscript
class_name PlayerHUDController extends GFController

@onready var lvl_label: Label = $LvlLabel

func _ready() -> void:
	var player_model := Gf.get_model(PlayerModel) as PlayerModel
	
	# 【绑定】：使用原生信号实现，不经过全局的 Event System
	player_model.level.value_changed.connect(_on_level_changed)
	
	# 【立即刷新一次初始状态】
	_on_level_changed(player_model.level.value)

# 注意回调会自动接收它变更后的新值！
func _on_level_changed(new_level: Variant) -> void:
	lvl_label.text = "Lv: " + str(new_level)


### 3. 自动解绑（架构推荐方法）

在 UI 开发中，最担心的就是 Node 销毁后监听器未释放导致的内存泄漏。`BindableProperty` 提供了 `bind_to` 语法糖解决此问题：

```gdscript
func _ready() -> void:
	# 绑定到自身，当该 Controller(Node) 销毁时，会自动 disconnect _on_level_changed
	player_model.level.bind_to(self, _on_level_changed)
	
	# 依然建议手动刷新一次初始值
	_on_level_changed(player_model.level.get_value())
```
```

## 数据绑定的局限性与设计哲学

你可能会思考一个问题：如果局部 `value_changed` 这么好用，为什么不把全局事件框架全部废弃采用它代替？

- **数据绑定适合于：单一流向的状态展示。** 例如 UI 显示血条数值、冷却读条刻度、金币数量显示。
- **全局事件系统适合：多路业务交错。** 例如当某系统（成就系统）关注另外一系统（战斗）发生了某行为，需要触发极其复杂的跨界计算时；这时 `GFPayload` 是承载计算上下文信息的必要载体。

**经验法则：**
*如果你是为了把数据"显示在屏幕上"，请使用 `BindableProperty` 订阅；如果你想表示"发生了一个业务动作导致其他系统也要开始运算"，发送 `Gf.send_event(...)`。*
