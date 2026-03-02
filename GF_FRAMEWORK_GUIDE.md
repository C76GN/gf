# GF Framework 使用指南

> 版本：适用于 Godot 4.x · GDScript

---

## 目录

1. [框架概述 (Architecture Overview)](#1-框架概述-architecture-overview)
2. [生命周期与初始化 (Lifecycle & Initialization)](#2-生命周期与初始化-lifecycle--initialization)
3. [系统帧更新 (Update Loop)](#3-系统帧更新-update-loop)
4. [IDE 智能提示规范 (IDE Autocomplete Convention)](#4-ide-智能提示规范-ide-autocomplete-convention)
5. [事件与数据载体规范 (Event & Payload Guidelines)](#5-事件与数据载体规范-event--payload-guidelines)

---

## 1. 框架概述 (Architecture Overview)

GF Framework 是一套面向 Godot 4 的轻量级架构框架，核心思想是**关注点分离**。框架将业务拆分为四个明确的层次：

| 层次 | 基类 | 职责 |
|---|---|---|
| **Model（数据层）** | `GFModel` | 存储和持有应用状态数据，不包含任何业务逻辑。 |
| **System（逻辑层）** | `GFSystem` | 实现核心业务逻辑，读写 Model，响应和分发事件。 |
| **Controller（表现层）** | `GFController` / Node | 场景中的 UI 或游戏对象节点，负责展示数据、监听事件、转发用户输入为 Command 或 Query。 |
| **Utility（工具层）** | `GFUtility` | 无状态的纯工具类（如对象池、加密、文件操作），可被任意层安全复用。 |

**架构容器**（`GFArchitecture`）负责所有模块的注册与生命周期管理。**全局入口**（`Gf` 自动加载单例）是外部访问架构的唯一入口。

```
Gf (AutoLoad Singleton)
└── GFArchitecture
    ├── GFModel  × N   —— 数据
    ├── GFSystem × N   —— 逻辑（受 tick / physics_tick 驱动）
    └── GFUtility × N  —— 工具
```

> **核心原则**：数据向上流动（Model → System → Controller），指令向下流动（Controller → Command → System / Model）。层与层之间通过事件系统解耦，禁止跨层直接持有引用。

---

## 2. 生命周期与初始化 (Lifecycle & Initialization)

框架采用**独创的三阶段初始化机制**，解决了模块之间的初始化顺序依赖问题。

### 三个阶段

```
阶段一：init()
  所有 Model / System / Utility 依次调用 init()
  ─────────────────────────────────────────────────
  约束：只允许初始化自身内部的变量（如 _score = 0）。
        严禁在此阶段跨模块获取依赖（get_model / get_system 等）。

阶段二：async_init()
  所有 Model / System / Utility 依次 await async_init()
  ─────────────────────────────────────────────────────
  可使用 await：适合异步资源加载、网络请求、读取存档等耗时操作。
  此阶段结束时，所有模块的 init() 均已完成。

阶段三：ready()
  所有 Model / System / Utility 依次调用 ready()
  ─────────────────────────────────────────────────
  安全区：可自由跨模块获取依赖（get_model / get_system 等）。
          适合完成模块间的信号绑定、事件订阅、数据同步初始化等。
```

### 使用示例

```gdscript
# MyGameSystem.gd
class_name MyGameSystem
extends GFSystem


# --- 私有变量 ---

var _score: int = 0
var _player_model: PlayerModel = null


# --- Godot 生命周期方法 ---

## 第一阶段：仅初始化本地变量。
func init() -> void:
    _score = 0


## 第二阶段：可执行异步操作，例如加载存档。
func async_init() -> void:
    var save_data: Dictionary = await SaveUtility.load_async()
    _score = save_data.get("score", 0)


## 第三阶段：所有模块已就绪，可安全获取跨模块引用。
func ready() -> void:
    _player_model = get_model(PlayerModel) as PlayerModel
    register_event(PlayerDiedEvent, _on_player_died)
```

### 架构启动

在你的 AutoLoad 或入口场景中，使用 `await` 等待三阶段完成：

```gdscript
func _ready() -> void:
    await Gf.set_architecture(MyGameArchitecture.new())
    # 至此，所有模块均已完成三阶段初始化，游戏可以安全启动。
```

> **重要**：`Gf.set_architecture()` 内部包含 `await`，**调用方必须加 `await`**，否则 `async_init` 和 `ready` 阶段将在后台异步执行，导致时序错误。

---

## 3. 系统帧更新 (Update Loop)

### 概述

`GFSystem` 继承自 `RefCounted`，无法直接接收 Godot 的 `_process` / `_physics_process` 回调。为此，框架提供了由架构统一驱动的 **tick 机制**，将帧更新注入到所有 System 中。

### 调用链

```
Gf._process(delta)
    └── GFArchitecture.tick(delta)
            └── for system in _systems:
                    system.tick(delta)   ← 你在 System 中重写这里

Gf._physics_process(delta)
    └── GFArchitecture.physics_tick(delta)
            └── for system in _systems:
                    system.physics_tick(delta)   ← 你在 System 中重写这里
```

### 使用方法

在你的 `GFSystem` 子类中重写 `tick()` 或 `physics_tick()` 即可：

```gdscript
# MyMovementSystem.gd
class_name MyMovementSystem
extends GFSystem


## 每帧更新逻辑。无需任何额外注册，架构自动驱动。
## @param delta: 距上一帧的时间（秒）。
func tick(delta: float) -> void:
    var model := get_model(PlayerModel) as PlayerModel
    model.position += model.velocity * delta


## 物理帧更新逻辑。适合刚体运动、碰撞检测等场景。
## @param delta: 距上一物理帧的时间（秒）。
func physics_tick(delta: float) -> void:
    # 物理相关逻辑写在这里
    pass
```

### 为何不让 System 直接继承 Node？

| 对比 | System 继承 Node | GF 的 tick 机制 |
|---|---|---|
| 性能 | 每个 System 是独立节点，有场景树开销 | 纯 `RefCounted`，无场景树开销 |
| 生命周期 | 需要手动 add_child / remove_child | 架构统一管理，无需关心 |
| 更新顺序 | 由场景树决定，难以控制 | 注册顺序即调用顺序，可预测 |
| 原则 | 逻辑层混入表现层 | 严格保持逻辑/表现分离 |

> `tick` 仅在架构完成三阶段初始化（`_inited == true`）后才会派发，无需在 System 内自行判断初始化状态。

---

## 4. IDE 智能提示规范 (IDE Autocomplete Convention)

> ⚠️ **这是最容易犯错的地方，请务必遵守！**

### 问题根源

`GFArchitecture.get_model()`、`get_system()`、`get_utility()` 等方法的返回类型均为 `Object`，以支持任意注册类型。GDScript 无法在编译期知道具体类型，因此 **IDE 将无法提供任何智能提示**。

### 解决方案：始终使用 `as` 进行强制类型转换

无论在 System、Controller 还是任何地方调用这些方法，**必须**紧跟 `as 具体类型`，让 GDScript 推断出正确的类型。

#### ✅ 正确做法

```gdscript
# 在 System 的 ready() 阶段缓存引用
func ready() -> void:
    var model := get_model(PlayerModel) as PlayerModel
    #                                    ^^^^^^^^^^^^^ 有了这个，IDE 才有提示

    var inventory := get_system(InventorySystem) as InventorySystem
    var pool := get_utility(ObjectPoolUtility) as ObjectPoolUtility


# 在 Controller（Node）中访问
func _ready() -> void:
    var arch := Gf.get_architecture()
    var model := arch.get_model(PlayerModel) as PlayerModel
    model.score  # ← IDE 现在能提示 PlayerModel 的所有属性和方法
```

#### ❌ 错误做法（无类型提示）

```gdscript
# 错误：变量类型被推断为 Object，没有任何智能提示
var model := get_model(PlayerModel)
model.score  # ← IDE 不知道这是什么，无法提示

# 错误：显式声明为 Object，同样没有提示
var model: Object = get_model(PlayerModel)
```

### 规范总结

| 场景 | 写法 |
|---|---|
| 获取 Model | `var m := get_model(MyModel) as MyModel` |
| 获取 System | `var s := get_system(MySystem) as MySystem` |
| 获取 Utility | `var u := get_utility(MyUtil) as MyUtil` |
| 从 Gf 单例获取架构 | `var arch := Gf.get_architecture()` （返回 `GFArchitecture`，IDE 有提示） |

> **建议**：在 `GFSystem.ready()` 阶段将常用依赖缓存到私有成员变量（已类型化），避免在 `tick()` 等高频函数中重复调用 `get_model()`，既有性能收益，又保持代码整洁。

---

## 5. 事件与数据载体规范 (Event & Payload Guidelines)

框架提供了**两套**事件机制，分别适用于不同场景。**选错会影响性能或可维护性，请仔细阅读本节。**

---

### 5.1 `send_simple_event`（StringName 轻量事件）

#### 适用场景

- **高频触发**的事件：每帧碰撞检测、子弹发射、粒子消亡、玩家移动等。
- 事件**无需传递参数**，或仅需传递 `int`、`float`、`bool`、`Vector2` 等**基础值类型**。
- 需要极致性能，严格规避 GC 卡顿的场景。

#### 为何选用

大量高频触发的事件若每次创建一个 `GFPayload` 对象（`RefCounted.new()`），Godot 的垃圾回收器（GC）将承受巨大压力，在低端设备上会引发明显的卡顿帧。使用 `StringName` 字面量作为事件标识符，完全避免了堆内存分配。

#### 使用示例

```gdscript
# 定义事件 ID（推荐集中管理在一个常量文件中）
const BULLET_HIT: StringName = &"BulletHit"
const PLAYER_MOVED: StringName = &"PlayerMoved"


# 订阅（在 System.ready() 中完成）
func ready() -> void:
    register_simple_event(BULLET_HIT, _on_bullet_hit)


# 发送（可在 tick() 等高频位置安全调用）
func tick(delta: float) -> void:
    if _check_collision():
        send_simple_event(BULLET_HIT, _collision_damage)  # payload 可选


# 回调
func _on_bullet_hit(damage: Variant) -> void:
    var model := get_model(PlayerModel) as PlayerModel
    model.hp -= damage as int
```

---

### 5.2 `TypeEventSystem` 与 `GFPayload`（类型安全事件）

#### 适用场景

- **低频**但业务意义重大的事件：结算结果、背包物品变动、关卡切换、任务完成等。
- 事件需要携带**复杂的、多字段的结构化数据**。
- 需要**编译期类型安全**，让 IDE 对事件数据字段提供完整提示。

#### 为何选用

对于业务事件，数据结构的清晰性和安全性远比零 GC 更重要。`GFPayload` 强类型子类使数据字段一目了然，`TypeEventSystem` 通过脚本类型作为 key 分发，编译器可在调用处检查类型错误。

#### 定义 Payload

```gdscript
# battle_result_event.gd
class_name BattleResultEvent
extends GFPayload


# --- 公共变量 ---

## 是否胜利。
var is_victory: bool = false

## 获得的金币数量。
var gold_earned: int = 0

## 获得的经验值。
var exp_earned: int = 0
```

#### 使用示例

```gdscript
# 在 System 中订阅（ready() 阶段）
func ready() -> void:
    register_event(BattleResultEvent, _on_battle_result)


# 发送（结算时，低频触发）
func _end_battle(victory: bool) -> void:
    var event := BattleResultEvent.new()
    event.is_victory = victory
    event.gold_earned = _calculate_gold()
    event.exp_earned = _calculate_exp()
    send_event(event)


# 回调（IDE 对 result 有完整类型提示）
func _on_battle_result(result: BattleResultEvent) -> void:
    var ui_model := get_model(UIModel) as UIModel
    ui_model.show_result_panel = true
    ui_model.victory = result.is_victory
```

---

### 5.3 速查对比表

| 维度 | `send_simple_event` | `TypeEventSystem` + `GFPayload` |
|---|---|---|
| **适用频率** | 高频（每帧 / 每次碰撞） | 低频（业务节点） |
| **数据复杂度** | 无参数 / 简单基础类型 | 多字段结构化数据 |
| **类型安全** | 弱（`Variant` payload） | 强（具体 Payload 子类） |
| **GC 压力** | 无（无堆分配） | 有（每次 `new()` 一个对象） |
| **IDE 提示** | 无（payload 为 Variant） | 完整（Payload 字段全提示） |
| **推荐场景** | 碰撞、移动、帧级状态更新 | 结算、背包变动、任务完成 |
