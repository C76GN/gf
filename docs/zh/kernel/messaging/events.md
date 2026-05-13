# 事件系统

GF 事件系统提供 Simple Event 与 Type Event 两条通信轨道，并围绕监听器所有权、派发时序和使用边界建立约束。

## 事件系统

大型项目里，UI、计分板、敌人、任务和战斗模块如果直接互相引用，重构和测试都会变得困难。

GF Framework 内置双轨事件系统 (`GFTypeEventSystem`)：simple event 面向轻量通知，type event 面向带协议的数据通信。两者都由当前 `GFArchitecture` 承载，并遵循 owner 绑定和生命周期清理规则。


## 双轨设计：选择最适合的事件方式

无论使用哪一种方式，事件的底层都是由 `GFArchitecture` 承载，它内部透明映射到了纯 GDScript 实现的路由机制中。

### 第 1 轨：Simple Event (`StringName` 匹配) — 用于高频、轻量、可选数据的通知

如果事件只表达轻量状态通知，例如菜单打开、玩家跳跃或分数变化，可以使用 Simple Event。Simple Event 可以不带 payload，也可以携带少量 `Variant` 数据；如果事件需要消费拦截、序列化、校验或复杂上下文，请改用 Type Event。

#### 发送端 (Sender)
```gdscript
# 发出简单无参数的事件通知，耗时极低
Gf.send_simple_event(&"EVENT_PLAYER_JUMPED")

# 也可以携带少量 Variant payload
Gf.send_simple_event(&"EVENT_SCORE_CHANGED", { "score": 1200 })
```

#### 接收端 (Receiver)
```gdscript
func ready() -> void:
	# 注册监听，并绑定到自身的回调函数
	register_simple_event(&"EVENT_PLAYER_JUMPED", _on_player_jumped)

func _on_player_jumped(_payload: Variant) -> void:
	print("UI 显示：成功跳跃！")

func dispose() -> void:
	unregister_simple_event(&"EVENT_PLAYER_JUMPED", _on_player_jumped)
```

---

### 第 2 轨：Type Event (推荐基于 `GFPayload` 的强类型事件) — 主要业务逻辑通信

当事件附带有严格的数据要求时（例如：受到伤害，数据包含：攻击者，防御者，伤害数值，元素属性等），GF Framework 提供了 `GFPayload` 让你建立严谨的类型协议。底层事件系统实际按脚本类型派发，只要求事件实例附加了脚本；继承 `GFPayload` 是推荐约定，用于统一获得 `is_consumed`、序列化和校验能力。

#### 1. 定义事件数据层载体 (Payload)
推荐继承自 `GFPayload`，此类继承于 `RefCounted`。
```gdscript
class_name DamagePayload extends GFPayload

var attacker: Node
var target: Node
var amount: int

# 你还可以实现 to_dict 以支持序列化日志打印
func to_dict() -> Dictionary:
	return {
		"attacker": attacker,
		"amount": amount
	}
```

#### 2. 发送带数据的事件
```gdscript
func attack_enemy(enemy: Node) -> void:
	var payload := DamagePayload.new()
	payload.attacker = self
	payload.target = enemy
	payload.amount = 100

	# 将包含数据的实例发送至系统总线
	Gf.send_event(payload)
```

#### 3. 监听强类型事件 (含优先级支持)
监听方法必须至少接收一个事件实例参数。推荐把回调参数声明为具体 Payload 类型，或声明为 `GFPayload` 后再恢复强类型（使用 `as`）。
```gdscript
func ready() -> void:
	# 可以通过设置第三个可选参数 priority 实现事件的截获排序 (默认优先级为0)
	register_event(DamagePayload, _on_damage_taken, 100)

func _on_damage_taken(payload: DamagePayload) -> void:
	print(payload.attacker.name, " 造成了 ", payload.amount, " 点伤害")

func dispose() -> void:
	unregister_event(DamagePayload, _on_damage_taken)
```

---


## 拥有者绑定监听

从 `1.9.1` 起，事件系统支持把监听器登记到某个 owner 名下，之后可以按 owner 一次性清理全部类型事件和简单事件监听。`GFSystem`、`GFUtility`、`GFController` 与 `GFState` 基类提供的 `register_event()` / `register_simple_event()` 已经默认使用当前实例作为 owner；模块被注销或状态被释放时，框架会自动清理这些监听。若 `GFState` 的监听只应在当前状态激活期间生效，应在 `exit()` 中调用 `unregister_owner_events()`。

```gdscript
class_name QuestHudController
extends GFController


func _ready() -> void:
	register_simple_event(&"EVENT_QUEST_UPDATED", _on_quest_updated)
	register_event(QuestCompletedPayload, _on_quest_completed, 100)


func _on_quest_updated(_payload: Variant) -> void:
	_refresh()


func _on_quest_completed(payload: GFPayload) -> void:
	var completed := payload as QuestCompletedPayload
	_show_completed(completed.quest_id)
```

如果监听者不是 GF 基类实例，可以使用全局门面的 owner 版本：

```gdscript
func _ready() -> void:
	Gf.listen_simple_owned(self, &"EVENT_PLAYER_JUMPED", _on_player_jumped)
	Gf.listen_owned(self, DamagePayload, _on_damage_taken, 100)


func _exit_tree() -> void:
	Gf.unlisten_owner(self)
```

`Gf.listen()` / `Gf.listen_simple()` 没有 owner 归属，只适合 AutoLoad、全局常驻服务或明确手动管理生命周期的监听；动态节点、临时 Utility、关卡局部模块应使用 owner 绑定写法。

如果在事件回调中调用 `Gf.unlisten_owner()`，框架会延迟到最外层派发结束后统一合并清理，并会在当前派发中跳过该 owner 后续尚未执行的 exact、assignable 与 simple 监听器。这个规则能避免遍历中的监听列表被直接改写，同时保证已明确释放的 owner 不会继续处理本轮事件。


## 最佳实践与注意点

1. **避免在 `Controller` 的 `_init()` 阶段进行挂载**：因为彼时可能对应的 `GFArchitecture` 事件总线还没有准备完毕。请始终在 `ready` (System/Model) 阶段或 `_ready` (ControllerNode) 阶段注册监听。
2. **优先使用 owner 绑定监听**：`GFSystem`、`GFUtility`、`GFController`、`GFState` 内部优先调用基类 `register_event()` / `register_simple_event()`；普通对象使用 `Gf.listen_owned()` / `Gf.listen_simple_owned()` 并在退出时调用 `Gf.unlisten_owner()`。如果使用无 owner 的 `Gf.listen()` / `Gf.listen_simple()`，必须手动 `unlisten`。
3. **保持 Payload 轻量**：虽然 Godot 4 的内存回收针对 `RefCounted` 优化巨大，但在诸如物理碰撞这样`_physics_process`高频循环内部，大量 `new` 实例强类型 Payload 仍会构成 GC 压力。这种场景下考虑改为使用 `send_simple_event`。
4. **事件签名安全性校验**：类型事件回调必须至少接收一个事件实例参数；简单事件回调也必须至少接收一个 `payload` 参数。框架会对对象方法形式的回调做运行时反射校验，参数不足或额外必填参数未通过默认值/`bind()` 满足时输出错误并跳过注册。
5. **事件消费是字段约定**：`GFPayload` 提供了 `is_consumed` 字段。Type Event 派发后会检查事件实例上的 `is_consumed == true`，命中时停止后续监听。非 `GFPayload` 事件如果也定义并设置了同名字段，同样会触发消费语义。
6. **监听器默认同步执行**：事件系统只调用回调，不会等待回调返回的 `Signal`。需要串行等待、失败处理、超时控制或可取消流程时，请使用 `GFCommandSequence`、Flow、Action Queue 或项目层 System 调度。
7. **exact 与 assignable 不自动去重**：同一个 callable 如果同时注册到精确类型监听和 assignable 监听，可能在同一次派发中被调用两次。需要避免重复处理时，只注册其中一种，或在业务侧自行去重。
8. **嵌套派发安全**：事件回调中再次发送事件时，遍历中新增或移除的监听器会延迟到最外层派发结束后统一合并，避免内层事件提前改变外层监听器列表。同一轮派发里先注册再注销的监听器不会在 flush 后残留，即使注册和注销的是另一个事件类型或简单事件 ID。
9. **默认启用深度保护**：从 `2.0.0` 起，`GFTypeEventSystem.max_dispatch_depth` 默认使用 `GFTypeEventSystem.DEFAULT_MAX_DISPATCH_DEPTH`，也就是 `64` 层，避免递归事件链无限嵌套。确实需要不受限制的项目可显式设为 `0`。`trace_enabled` 默认关闭，开启后可通过 `Gf.get_event_dispatch_trace()` 读取最近派发条目，包括轨道、事件标识、监听数量、深度和时间戳；生产环境只建议在诊断面板或临时排查中开启。
10. **避免每帧重复注册/注销监听**：类型事件派发会缓存脚本类型匹配结果，并在监听器变化时只刷新受影响的类型条目。这个缓存能降低运行时抖动，但监听生命周期仍应跟随模块、节点或 owner，而不是在 `tick()` 中反复注册和注销。

```gdscript
Gf.configure_event_debugging(8, true, 32)

Gf.send_simple_event(&"ui_opened", { "panel": "inventory" })
print(Gf.get_event_dispatch_trace())
```
