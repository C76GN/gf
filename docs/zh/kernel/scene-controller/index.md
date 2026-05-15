# 场景桥接、Controller 与数据绑定

本页描述 Node 世界如何接入 GF：Controller 更新、宿主节点、局部上下文、数据绑定以及 UI/输入表现层建议。

## 更新机制与 Controller

在 Godot 引擎中，通常我们需要将脚本挂载在游戏场景内的 `Node` 上，利用 `_process(delta)` 和 `_physics_process(delta)` 驱动逻辑循环。

在 GF Framework 架构下，**所有的核心系统 (`GFSystem`) 不需要继承 `Node`，也不存在于场景树中。** 这种设计的最大好处是：**你的核心业务逻辑更新，可以被框架中心化进行管理、暂停、分时间流速率进行缩放运算。**

## System 层的心跳

全局自动加载单例 `Gf` 持有对游戏 `_process` 和 `_physics_process` 的监听。
每当收到 Godot 引擎帧调用时，它会将调用转发给 `GFArchitecture`，随后遍历转发给参与 `tick()` / `physics_tick()` 的 `GFSystem` 与 `GFUtility`。
`Gf` 会把自身 `process_mode` 设置为 `PROCESS_MODE_ALWAYS`，因此即使项目临时使用 Godot 原生 `SceneTree.paused`，框架层的时间工具、暂停逻辑和明确声明忽略暂停的模块仍有机会继续收敛状态。

如果你的系统需要在每一帧执行更新逻辑，只需要重写 `GFSystem` 中的 `tick(delta)` 或 `physics_tick(delta)`；运行时工具需要帧驱动时，也可以在 `GFUtility` 子类中实现同名方法。
`GFSystem` 基类保留空的模板方法用于兼容，但架构只会把真实声明了对应方法的子类加入 tick 缓存，不会因为基类空模板让所有 System 每帧空转。旧项目中已经重写 `tick()` / `physics_tick()` 的模块无需改动；如果确实需要让未重写模板方法的 System 显式进入缓存，可以设置 `tick_enabled = true` 或 `physics_tick_enabled = true`。`GFUtility` 仍需要实现对应方法才会被驱动，显式标记只负责让能力声明和缓存刷新更直接。这些标记在注册前或注册后设置都可以，已注入架构的模块会自动刷新 tick 缓存。

```gdscript
class_name CooldownSystem extends GFSystem

var _combat_model: CombatModel

func ready() -> void:
	_combat_model = get_model(CombatModel) as CombatModel

func tick(delta: float) -> void:
	# 执行统一的核心技能冷却扣减逻辑
	if _combat_model != null and not _combat_model.is_combat_paused:
		_combat_model.decrease_cooldown_timers(delta)
```

在 `tick()` / `physics_tick()` 这类热路径里，推荐在 `ready()` 或初始化阶段缓存长期依赖的 `Model`、`System`、`Utility` 引用。`get_model()` / `get_system()` / `get_utility()` 适合表达依赖入口，但每帧重复查找没有必要；只有当项目会动态替换某个模块实例时，才需要在替换完成后刷新缓存。

### 何时使用 `tick` vs `physics_tick`

- **`tick(delta)`：** 对应渲染帧。用于处理视觉队列处理、UI数据动态演算、不涉及物理碰撞引擎参与的高频逻辑。
- **`physics_tick(delta)`：** 对应固定逻辑帧。用于控制移动插值引擎、碰撞检测前置参数传递、状态机物理更新运算。

## 脱离主更新循环的优势

将 System 解耦到纯代码抽象容器带来诸多工程化帮助：

### 1. 集中且可预测的顺序
默认情况下，模块会按注册进入 tick 缓存的顺序转发更新，并在 tick 遍历期间延迟刷新缓存，避免动态注销模块破坏本轮遍历。需要表达明确依赖时，可以设置 `GFSystem.tick_priority` / `GFUtility.tick_priority` 或 `physics_tick_priority`；数值越大越早执行，默认 `0` 表示同优先级下继续按注册顺序执行。
未重写 `tick()` / `physics_tick()` 且未显式启用对应标记的 System 不会进入缓存；这能减少空模板调用，同时让诊断快照中的 `has_tick` / `has_physics_tick` 更接近真实热路径。

```gdscript
var input_system := InputCollectSystem.new()
input_system.tick_priority = 100

var battle_system := BattleSystem.new()
battle_system.tick_priority = 0

Gf.register_system(input_system)
Gf.register_system(battle_system)
```

生命周期也支持同样的“显式优先，同级按注册顺序”的思路：`lifecycle_priority` 越大，`init()` / `async_init()` / `ready()` 越早执行，`dispose()` 越晚释放。它只解决框架模块之间的初始化和释放顺序，不应替代项目自己的流程状态机或命令队列。

### 2. 全局冻结与时间穿梭
注册 `GFTimeUtility` 后，表现层动画可以继续利用真实时间正常播放，而底层 `GFSystem` 与参与 tick 的 `GFUtility` 会统一接受受缩放系数调整的 `delta`。如果将缩放系数设为 0，便实现了核心逻辑全局暂停（Hit Stop 或 "子弹时间"系统）。

## 控制器 (Controllers) 的更新

对于继承自 Node 的 `GFController`，由于它们通常承担特效表现、玩家输入转发和 UI 动画插值等渲染职责，它们**依然依附于 Godot 原生的 `_process` 与 `_physics_process`**。

你完全可以依照平常的 Godot 节点开发习惯在控制器中编写更新块：

```gdscript
class_name PlayerInputController extends GFController

func _process(delta: float) -> void:
	# 直接在此处获取输入状态
	var x_input = Input.get_axis("ui_left", "ui_right")

	# 仅将干净的指令转交给系统处理
	if x_input != 0:
		var move_cmd = MoveCommand.new()
		move_cmd.direction = Vector2(x_input, 0)
		Gf.send_command(move_cmd)
```

## 数据绑定

在没有 GF Framework 之前，如果 UI 想要在玩家等级发生变化时更新文字显示，往往需要玩家模块广播专门的 `PlayerLvlChangedEvent` 事件，然后 UI 端再订阅、解析 payload 并更新界面。

如果大量 UI 字段都用全局事件同步，事件总线会承担过多局部展示职责，也会让调试日志和事件追踪变得嘈杂。

这就是 GF Framework 中 `GFBindableProperty` 的由来，旨在提供**局部、无事件总线开销的数据驱动绑定机制。**

## 什么是 GFBindableProperty

`GFBindableProperty` 位于 `addons/gf/kernel/core/gf_bindable_property.gd` 下。它是对所有单实例值的再封装槽体，内部含有一个 `value_changed` 响应信号。

### 工作模型
它是典型的观察者模式（Observer Meta-Pattern）:
`Model (Hold Property) ---> Controller (Subscribe)`

## 基础用法

### 1. 在 Model 中定义一个绑定属性

请注意，普通 `GFBindableProperty` 本身并不阻止外部调用 `set_value()`。如果某个值只应该由 Model 内部修改，应在 Model 上封装业务方法，或对外暴露 `GFReadOnlyBindableProperty` 只读视图。

```gdscript
class_name PlayerModel extends GFModel

# 定义属性，初始化值为 1
var level := GFBindableProperty.new(1)
var player_name := GFBindableProperty.new("Guest")

func level_up() -> void:
	# 修改它的 .value 将安全地向所有订阅者触发出原生 signal
	level.set_value(level.get_value() + 1)
```

### 2. 在 Controller（表现层）订阅变化

UI 不需要订阅全局业务事件，只需处理当前字段变化的回调。

```gdscript
class_name PlayerHUDController extends GFController

@onready var lvl_label: Label = $LvlLabel

func _ready() -> void:
	var player_model := Gf.get_model(PlayerModel) as PlayerModel

	# 【绑定】：绑定到自身，节点退出树时自动断开，不经过全局 Event System
	player_model.level.bind_to(self, _on_level_changed)

	# 【立即刷新一次初始状态】
	_on_level_changed(null, player_model.level.get_value())

# 注意回调会自动接收旧值和新值！
func _on_level_changed(_old_level: Variant, new_level: Variant) -> void:
	lvl_label.text = "Lv: " + str(new_level)
```


### 3. 自动解绑（架构推荐方法）

在 UI 开发中，最担心的就是 Node 销毁后监听器未释放导致的内存泄漏。`GFBindableProperty.bind_to()` 会额外监听目标 Node 的 `tree_exited`，适合作为表现层默认绑定方式：

```gdscript
func _ready() -> void:
	# 绑定到自身，当该 Controller(Node) 销毁时，会自动 disconnect _on_level_changed
	player_model.level.bind_to(self, _on_level_changed)

	# 依然建议手动刷新一次初始值
	_on_level_changed(null, player_model.level.get_value())
```

需要手动清理 UI 绑定时，`unbind(node, callable)` 只断开指定节点绑定；如果传入的是已经失效的节点引用，会先清理失效绑定，再决定是否释放框架托管的 `value_changed` 连接。`unbind_all()` / `unbind_all_node_bindings()` 只清理由 `bind_to()` 创建的节点生命周期绑定，不会断开业务层直接连接到 `value_changed` 的订阅。同一个 callable 绑定到多个节点时，只要仍有一个节点绑定存活，框架创建的 `value_changed` 连接就会保留；最后一个绑定离开后才自动断开。确实要清空 `value_changed` 上所有订阅者时，使用语义更明确的 `disconnect_all_subscribers()`。

## 数据绑定的局限性与设计哲学

## 派生属性与组合副作用

当 UI 或 Controller 需要同时依赖多个 `GFBindableProperty` 时，不必把它升级成全局事件，也不需要把计算结果写死在某个业务 Model 中。`GFReactiveEffect` 可监听一组来源属性并执行回调；`GFComputedProperty` 则把多个来源派生成一个只读属性。

```gdscript
var first_name := GFBindableProperty.new("Ada")
var last_name := GFBindableProperty.new("Lovelace")

var full_name := GFComputedProperty.new(
	[first_name, last_name],
	func() -> String:
		return "%s %s" % [first_name.get_value(), last_name.get_value()],
	""
)

full_name.bind_to(self, func(_old_value: Variant, new_value: Variant) -> void:
	%NameLabel.text = new_value
)
```

`GFReactiveEffect` 适合处理“多个值变化后刷新一段表现”的场景，并可绑定 `Node` 生命周期：

```gdscript
var effect := GFReactiveEffect.new(
	[player_model.hp, player_model.max_hp],
	func() -> void:
		%HpBar.value = float(player_model.hp.get_value()) / float(player_model.max_hp.get_value()),
	self
)
```

这两者都只服务局部响应式组合，不替代 `GFModel` 的数据归属，也不规定属性字段含义。无 owner 的 `GFReactiveEffect` 或 `GFComputedProperty` 需要由持有方在生命周期结束时调用 `stop()` 或 `dispose()`；传入 owner 时会随该节点退出树自动停止。

如果某个对象需要把属性暴露给 UI 读取和订阅，但不希望外部调用方直接 `set_value()`，可以返回 `GFReadOnlyBindableProperty` 或由宿主对象封装只读视图。它复用 `GFBindableProperty` 的读取、`value_changed` 信号和 `bind_to()` 生命周期绑定能力，但外部写入和原地修改 helper 都会报错；真正的值更新应由宿主对象内部完成。对于 `Array` / `Dictionary` 等引用值，普通 `GFBindableProperty` 的原地修改不会自动触发变更信号；需要通知监听者时应重新 `set_value()` 一个副本，或在明确接受引用语义时调用 `force_emit()`、`mutate()`、`append_to_array()`、`set_dictionary_value()` 等辅助方法。

你可能会思考一个问题：如果局部 `value_changed` 这么好用，为什么不把全局事件框架全部改用它代替？

- **数据绑定适合于：单一流向的状态展示。** 例如 UI 显示血条数值、冷却读条刻度、金币数量显示。
- **全局事件系统适合：多路业务交错。** 例如成就系统关注战斗系统中的某类行为，并需要触发跨模块结算时，`GFPayload` 是承载计算上下文信息的必要载体。

**经验法则：**
*如果你是为了把数据"显示在屏幕上"，请使用 `GFBindableProperty` 订阅；如果你想表示"发生了一个业务动作导致其他系统也要开始运算"，发送 `Gf.send_event(...)`。*
