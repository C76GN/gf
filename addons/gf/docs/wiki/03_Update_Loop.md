# 03. 更新机制 (Update Loop)

在 Godot 引擎中，通常我们需要将脚本挂载在游戏场景内的 `Node` 上，利用 `_process(delta)` 和 `_physics_process(delta)` 驱动逻辑循环。

在 GF Framework 架构下，**所有的核心系统 (`GFSystem`) 不需要继承 `Node`，也不存在于场景树中。** 这种设计的最大好处是：**你的核心业务逻辑更新，可以被框架中心化进行管理、暂停、分时间流速率进行缩放运算。**

## System 层的心跳

全局自动加载单例 `Gf` 持有对游戏 `_process` 和 `_physics_process` 的监听。
每当收到 Godot 引擎帧调用时，它会将调用转发给 `GFArchitecture` ，随后遍历转发给所有注册的 `GFSystem`。

如果你的系统需要在每一帧执行更新逻辑，只需要重写 `GFSystem` 中的 `tick(delta)` 或 `physics_tick(delta)`。

```gdscript
class_name CooldownSystem extends GFSystem

func tick(delta: float) -> void:
    var combat_model := Gf.get_model(CombatModel) as CombatModel
    
    # 执行统一的核心技能冷却扣减逻辑
    if not combat_model.is_combat_paused:
         combat_model.decrease_cooldown_timers(delta)
```

### 何时使用 `tick` vs `physics_tick`

- **`tick(delta)`：** 对应渲染帧。用于处理视觉队列处理、UI数据动态演算、不涉及物理碰撞引擎参与的高频逻辑。
- **`physics_tick(delta)`：** 对应固定逻辑帧。用于控制移动插值引擎、碰撞检测前置参数传递、状态机物理更新运算。

## 脱离主更新循环的优势

将 System 解耦到纯代码抽象容器带来诸多工程化帮助：

### 1. 严格的确定性顺序
虽然当前实现是根据按注册顺序遍历执行，但在复杂的 RTS / 回合制 / ECS 类扩展中，这使得你能**严格排序哪些系统的 Update 必须在哪些系统之前执行**（例如：输入系统更新 -> 技能系统更新 -> 寻路系统更新），彻底解决了直接混杂 Godot 原生 `_process` 时难以预测的节点顺序灾难。

### 2. 全局冻结与时间穿梭
在未来接入 `GFTimeUtility` 时，可以轻易实现：表现层动画继续利用真实时间正常播放，而所有底层 `GFSystem` 可以统一接受受缩放系数调整的 `delta`。如果将缩放系数设为 0，便实现了完美的核心逻辑全局暂停（Hit Stop 或 "子弹时间"系统）。

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
