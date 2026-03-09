# 06. 命令与查询 (Commands & Queries)

在 GF Framework 中可以把大量的纯计算逻辑直接堆积在 System 层的某个实例下。但这依然可能造成部分核心系统极度臃肿（譬如 `BattleSystem` 上千行逻辑，包含了开始战斗、技能结算、伤害衰减、撤退行为等所有逻辑）。

使用 `GFCommand` (写操作) 与 `GFQuery` (读操作) 可以通过典型的 **Command Pattern (命令模式)** 将代码模块化，让 `System` 代码保持清爽与易读。

## GFCommand: 封装具有原子语义的“改变”动作

`GFCommand` 代表了一次可执行的指令。它的意图是**改变 Model 的数据状态或触发一系列副作用任务。** 

### 创建命令
继承并重写 `execute()` 抽象方法：

```gdscript
class_name TakeDamageCommand extends GFCommand

# 这通常可以视为命令实例携带的参数上下文
var target_id: String
var raw_damage: int

func execute() -> void:
    # 框架基类中提供了方便的 getter 可以取用全局组件
    var battle_model := get_model(BattleModel) as BattleModel
    
    # 从状态中找到受击人并结算伤害
    var ent := battle_model.get_entity(target_id)
    if ent:
        var final_dmg = raw_damage - ent.defense
        ent.health -= max(1, final_dmg)
```

### 执行命令
只要获得了命令定义，在控制器或系统内部都能够无脑调用：

```gdscript
# 在 UI层按下攻击键后
var c = TakeDamageCommand.new()
c.target_id = "monster_99"
c.raw_damage = 999
Gf.send_command(c) # 或者 c.execute()，本质是一样的
```

## GFQuery: 封装跨模块读取提取数据的“获取”动作

当有些数据显示的运算（比如要渲染的属性面板），需要合并 `PlayerModel`，`BuffModel`，`EquipmentModel` 三个底层模型中的多维度状态时，将其封装入 `GFQuery` 极度合适。

### 创建查询

这代表了查询的返回值是安全的，**绝不应该在 `execute()` 内部出现状态和数据的修改变动**。

```gdscript
class_name GetPlayerTotalAttackPowerQuery extends GFQuery

func execute() -> Variant:
    # 从三处采集数据
    var raw_atk = (get_model(PlayerModel) as PlayerModel).base_atk
    var wpn_atk = (get_model(EquipmentModel) as EquipmentModel).get_equipped_weapon_atk()
    var buff_atk_pct = (get_model(BuffModel) as BuffModel).get_global_atk_buff()
    
    return (raw_atk + wpn_atk) * (1.0 + buff_atk_pct)
```

### 执行查询

通常控制器表现层（Controller）会发出查询获取数据再做展示：

```gdscript
func update_attack_power_ui() -> void:
    var final_atk = GetPlayerTotalAttackPowerQuery.new().execute() as float
    $UI/AttackLabel.text = str(final_atk)
```

## 配合撤销栈的超级形态 (Undo/Redo)

当你使用了 `GFCommand` 这种严谨模式编码操作指令时，你就意外解锁了 GF Framework 提供的超级功能：**基于 `GFUndoableCommand` 的撤销重做栈扩展体系**！

你只需要：
1. 使它继承自 `GFUndoableCommand`
2. 使用 `GFCommandHistoryUtility` 管理系统对它施加 `execute_command(cmd)` 调用
3. 然后便能任意使用撤回方法无缝追溯游戏历史！

### 命令历史的序列化与持久化 (Command History Persistence)

自 v1.1.0 起，`GFCommandHistoryUtility` 支持将整个撤销/重做栈序列化为纯数据，以便于存入玩家存档文件（JSON 等）。

**序列化历史记录：**
```gdscript
var history := Gf.get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility
var saved_data_array: Array = history.serialize_history()
# 将 saved_data_array 使用 GFStorageUtility 等方式写入你的存档文件
```
> 若你想定制序列化结构，需确保你的 `GFUndoableCommand` 子类覆盖了 `serialize() -> Dictionary` 方法。如果未提供，框架默认将只提取其 `get_snapshot()` 作为数据。

**反序列化历史记录：**
```gdscript
var history := Gf.get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility

# 由于框架层不感知具体的 Command 类型，需要外部传入构建器(Callable)来实现控制反转
var command_builder = func(data: Dictionary) -> GFUndoableCommand:
    var cmd_type = data.get("type", "")
    if cmd_type == "TakeDamage":
        var c = TakeDamageCommand.new()
        c.set_snapshot(data.get("snapshot", null)) # 恢复快照
        return c
    return null

history.deserialize_history(saved_data_array, command_builder)
```
> **提示：** `GFCommandHistoryUtility` 具有最大历史数限制属性 `max_history_size`（默认为 `1024`）。当保存突破限制时，底部的旧操作将自动被抛弃以释放内存。

> 请查阅文档中关于 *Advanced Extensions (高级扩展)* 中具体提供的 Undo/Redo 组件范例来获得更多实战经验。
