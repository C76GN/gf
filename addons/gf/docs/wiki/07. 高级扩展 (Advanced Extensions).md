# 07. 高级扩展 (Advanced Extensions)

GF Framework 虽然被设计为最小依赖型，但在 `addons/gf/extensions/` 中内置了三个能够帮助项目应对复杂中重度场景挑战的基础实战模块：**分层状态机体系**、**动画与逻辑解耦的动作队列**、**以及完整的撤销命令重做体系**。

## 1. 分层纯代码有限状态机 (GFStateMachine)

Godot 的 `AnimationTree` 更多负责混合状态的视觉控制，如果你需要对游戏底层的怪物或副本主流程做出严谨管理，纯代码基于对象的 `GFStateMachine` 是最佳帮手。

它不同于传统的巨型 `switch/case` 或者节点树，而是独立的派生类模式。

### 创建具体的独立状态类

继承 `GFState`，覆写生命周期。并且得益于继承了它，你在内部依然能够随意访问所有底层的 Model 与 System 层机制！

```gdscript
class_name EnemyChaseState extends GFState

var target: Node

func enter(params: Variant = null) -> void:
    # 状态进入
    print("开始追捕目标！")
    # 可以通过 get_machine() 拿到包含它的父类容器状态器
    
func update(delta: float) -> void:
    # 被主框架逻辑勾起不断判定
    var d = owner_entity.global_position.distance_to(target.global_position)
    if d < 10.0:
        change_state(&"AttackState")

func exit() -> void:
    # 退出前清理工作
    print("追击结束。")
```

### 初始化装配状态机器

```gdscript
var fsm := GFStateMachine.new()
var chase = EnemyChaseState.new()
# 给每一个 State 提供独立的识别上下文名称与主调实体
fsm.add_state("ChaseState", chase) 
fsm.add_state("AttackState", EnemyAttackState.new())

fsm.start("ChaseState")

# 在你自己的任何主循环 (Tick 或 _process) 中驱动分发
fsm.update(delta)
```

---

## 2. 视觉队列缓冲系统 (Action Queue)

**核心痛点：**在卡牌或者回合制战棋里，服务器或者底层系统层运算完战斗判定可能只花了 **0.01 秒**。但前端控制表现层需要给受击目标演示"走过去 -> 挥剑 -> 流血 -> 退回原位"，需要长达 **3.5 秒**。

GF Action Queue 在 `addons/gf/extensions/action_queue/` 为这个问题提供了完美隔离。通过把表现层动效视作独立可执行的类 `GFVisualAction`，将其压入 `GFActionQueueSystem` 的队列池内：

### `GFVisualActionGroup` 复合动作与并行执行

自 1.3.0 版本起，框架正式引入了复合动作节点 `GFVisualActionGroup`。你可以将一组 `GFVisualAction` 打包为一个大动作：

```gdscript
# 将两张卡牌的移动动作打包以并行方式执行（等它们俩都移动到位后才继续队列后续任务）
var group: GFVisualActionGroup = GFVisualActionGroup.new([
    MoveCardAction.new(card_a, target_pos_a),
    MoveCardAction.new(card_b, target_pos_b)
], true) # true 代表并行执行

action_queue_sys.enqueue(group)
```
或者，你可以直接使用 `enqueue_parallel([action_a, action_b])` 语法糖，底层的队列系统会自动帮你将它们用 `GFVisualActionGroup` 封装！

### 编写继承的 Action 动效

实现重写其虚函数：如若是耗时操作，务必确保 `execute()` 声明的是在自身生命周期内可完成，最后能够产生触发的信号。
```gdscript
class_name PlayCardVisualAction extends GFVisualAction

var target_card: CardNode

func execute() -> Signal:
    # 触发一个耗时两秒左右的 DOTween, 并且提取其中的完成异步信号并等待！
    var tween = create_tween()
    tween.tween_property(target_card, "position", Vector2(400,300), 2.0)
    return tween.finished
```

### 把行为打包向队列投喂推入

```gdscript
var q_sys = Gf.get_system(GFActionQueueSystem) as GFActionQueueSystem
# 队列系统支持并发 (Parallel) 及有序 (Sequential) 甚至后发先至 LIFO 设计模式。
var grp := GFVisualActionGroup.new()
grp.add(PlayCardVisualAction.new(...))

# 推入到默认缓冲队列进行有序按批等待渲染
q_sys.enqueue(grp)
```

### 显式 Fire-and-Forget 动作

默认情况下，`GFActionQueueSystem` 保持旧语义：`execute()` 返回 `Signal` 就等待，返回 `null` 就继续。自 `1.6.0` 起，如果某个动作只是发出音效、粒子、非阻塞 Tween，不希望占住队列，可以显式声明 fire-and-forget：

```gdscript
var q_sys := Gf.get_system(GFActionQueueSystem) as GFActionQueueSystem

var action := PlaySfxAction.new("res://audio/hit.wav")
q_sys.enqueue_fire_and_forget(action)

# 或者在动作自身上声明
q_sys.enqueue(SpawnParticleAction.new(...).as_fire_and_forget())
```

---

## 3. 可逆向退回历史机制 (GFUndoableCommand)

这主要应用于类似关卡编辑器，下棋走格子推关。在命令的基础语义上增加了 `save_state` 与 `undo` 这对黄金组合。

配合 `gf_command_history_utility.gd` 的自动装载栈，实现重做撤销只需如下代码。

```gdscript
class_name MoveTileUndoableCommand extends GFUndoableCommand

var old_pos: Vector2
var new_pos: Vector2

func _init(n_pos):
    new_pos = n_pos

func save_state() -> void:
    # 记录执行动作前，世界原本应该长什么样子
    old_pos = (get_model(GridModel) as GridModel).current_pos

func execute() -> void:
    # 真正向未来改变！
    (get_model(GridModel) as GridModel).current_pos = new_pos

func undo() -> void:
    # 后悔药逻辑：抹杀未来，回到过去
    (get_model(GridModel) as GridModel).current_pos = old_pos
```

执行命令时，通过工具层接管执行权限自动压栈：

```gdscript
var stack = Gf.get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility
stack.execute_command(MoveTileUndoableCommand.new(Vector2(5,6)))

# 想反悔不走了：
stack.undo() 
```
