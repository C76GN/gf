# 04. 事件系统 (Event System)

游戏开发中最常见的痛点是模块间互相耦合：UI 引用了玩家脚本，计分板引用了怪物脚本，导致代码难以重构。

GF Framework 内置了高性能的**双轨事件系统引擎 (`TypeEventSystem`)**，它彻底解耦了模块，并且提供了根据场景灵活选择的通讯途径。

## 双轨设计：选择最适合的事件方式

无论使用哪一种方式，事件的底层都是由 `GFArchitecture` 承载，它内部透明映射到了纯 GDScript 实现的路由机制中。

### 第 1 轨：Simple Event (`StringName` 匹配) — 用于高频、无数据的通知

如果你只是用作标记状态（例如：主菜单被点击、玩家跳跃、BOSS出现等），不需要复杂的上下文参数传递，那么这种机制最为极速。

#### 发送端 (Sender)
```gdscript
# 发出简单无参数的事件通知，耗时极低
Gf.send_simple_event(&"EVENT_PLAYER_JUMPED")
```

#### 接收端 (Receiver)
```gdscript
func ready() -> void:
    # 注册监听，并绑定到自身的回调函数
    Gf.listen_simple(&"EVENT_PLAYER_JUMPED", _on_player_jumped)

func _on_player_jumped() -> void:
    print("UI 显示：成功跳跃！")

func _exit_tree() -> void:
    # 不要忘记在节点销毁时手动解绑！
    Gf.unlisten_simple(&"EVENT_PLAYER_JUMPED", _on_player_jumped)
```

---

### 第 2 轨：Type Event (基于 `GFPayload` 的强类型事件) — 主要业务逻辑通信

当事件附带有严格的数据要求时（例如：受到伤害，数据包含：攻击者，防御者，伤害数值，元素属性等），GF Framework 提供了 `GFPayload` 让你建立严谨的类型协议。

#### 1. 定义事件数据层载体 (Payload)
必须继承自 `GFPayload`，此类继承于 `RefCounted`。
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
监听方法签名被严格约束必须接收一个 `GFPayload`，并在内联方法中恢复其强类型（使用 `as`）。
```gdscript
func ready() -> void:
    # 可以通过设置第三个可选参数 priority 实现事件的截获排序 (默认优先级为0)
    Gf.listen(DamagePayload, _on_damage_taken, 100)

func _on_damage_taken(payload: GFPayload) -> void:
    var dmg = payload as DamagePayload
    print(dmg.attacker.name, " 造成了 ", dmg.amount, " 点伤害")

func _exit_tree() -> void:
    # 同样记得适时解绑
    Gf.unlisten(DamagePayload, _on_damage_taken)
```

---

## 最佳实践与注意点

1. **避免在 `Controller` 的 `_init()` 阶段进行挂载**：因为彼时可能对应的 `GFArchitecture` 事件总线还没有准备完毕。请始终在 `ready` (System/Model) 阶段或 `_ready` (ControllerNode) 阶段注册监听。
2. **切勿遗漏取消监听（Unlisten）**：这会导致内存泄漏或向已销毁的节点回调导致引擎崩溃！
3. **保持 Payload 轻量**：虽然 Godot 4 的内存回收针对 `RefCounted` 优化巨大，但在诸如物理碰撞这样`_physics_process`高频循环内部，大量 `new` 实例强类型 Payload 仍会构成 GC 压力。这种场景下考虑改为使用 `send_simple_event`。
4. **事件闭包签名安全性校验**：自 1.3.0 版本起，框架会在运行时反射校验你试图赋予的回调签名参数 `on_event.get_method_argument_count()`。如果签名少于 1 个参数，框架将利用 assert() 断言抛错以提醒你防患于未然。
