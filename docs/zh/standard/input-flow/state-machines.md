# 纯代码状态机与节点状态机

标准库提供纯代码有限状态机和场景树节点状态机两种状态组织方式，分别服务逻辑流程和节点生命周期。

## 分层纯代码有限状态机 (`GFStateMachine`)

Godot 的 `AnimationTree` 更多负责混合状态的视觉控制，如果你需要对游戏底层流程、实体决策或系统阶段做出严谨管理，纯代码基于对象的 `GFStateMachine` 是更合适的核心状态机。

它不同于传统的巨型 `switch/case`，而是独立状态类模式。简单项目可以把它当作平铺 FSM 使用；复杂项目可以通过 `parent_state_name` 建立父子状态路径，让切换时只退出和进入必要的分支。

### 创建具体的独立状态类

继承 `GFState` 并覆写生命周期方法。状态对象会接收架构注入，因此可以通过明确的 `get_model()` / `get_system()` / `get_utility()` 访问需要的依赖。

```gdscript
class_name MoveState
extends GFState

var owner_entity: Node2D

func enter(_msg: Dictionary = {}) -> void:
	# 可以通过 change_state() 或 get_model()/get_system() 访问状态机上下文。
	pass


func update(delta: float) -> void:
	if owner_entity == null:
		return


func exit() -> void:
	pass


func can_exit(next_state: StringName = &"", _msg: Dictionary = {}) -> bool:
	return next_state != &"Locked"


func handle_state_event(event_id: StringName, payload: Variant = null) -> bool:
	if event_id == &"cancel":
		change_state(&"Idle")
		return true
	return false
```

### 初始化装配状态机器

```gdscript
var fsm := GFStateMachine.new()
fsm.add_state(&"Grounded", GroundedState.new())
fsm.add_state(&"Idle", IdleState.new(), &"Grounded")
fsm.add_state(&"Run", MoveState.new(), &"Grounded")
fsm.add_state(&"Airborne", AirborneState.new())

fsm.start(&"Idle")
fsm.change_state(&"Run")

# 在你自己的任何主循环 (Tick 或 _process) 中驱动分发
fsm.update(delta)
```

当从 `Grounded/Idle` 切换到 `Grounded/Run` 时，`Grounded` 会保持激活，只退出 `Idle` 并进入 `Run`；当切换到 `Airborne` 时，则会先退出 `Idle`，再退出 `Grounded`，最后进入 `Airborne`。这就是典型 HSM 的最近公共祖先切换语义。

`start()` 会把初始进入也视为一次状态变化：进入成功后默认发出 `state_changed`，其中 `from_state = &""`，`to_state` 为初始状态名。这样 UI、调试面板、动画桥和日志系统只需要监听同一个信号，不必为“启动时的当前状态”单独写初始化分支：

```gdscript
fsm.state_changed.connect(_on_state_changed)
fsm.start(&"Idle") # 发出 from_state = &""，to_state = &"Idle"
```

只有在少数需要静默装配内部状态的场景，才建议传入第三个参数 `false`。

`GFState` 可重写 `can_enter()` / `can_exit()` 作为进入和退出守卫；守卫拒绝时，状态机发出 `transition_blocked`，并保持当前激活路径不变。需要让子状态把未处理输入或领域事件交给父状态时，调用：

```gdscript
fsm.dispatch_state_event(&"cancel", { "source": "input" })
```

事件会从当前叶子状态开始，沿父状态路径向上调用 `handle_state_event()`，直到某个状态返回 `true`。运行时可用 `get_active_state_path()`、`is_in_state()`、`get_state_snapshot()` 和共享 `blackboard` 做调试、诊断或 UI 展示；`update(delta, true)` 可按 root -> leaf 顺序更新整条激活路径，默认只更新当前叶子状态，适合大多数有限状态机的单活跃状态逻辑。

状态内部访问框架依赖时，应使用 `get_model()`、`get_system()`、`get_utility()`、`send_command()`、`send_query()` 这些状态机代理。它们会沿着创建 `GFStateMachine.new(context)` 时传入的上下文解析架构，适配局部 `GFNodeContext`；只有明确要访问全局架构时才直接调用 `Gf`。对于每帧移动输入、速度、冷却这类简单热路径读取，优先在 `enter()` 或状态持有者初始化时缓存 Model/Utility，再直接读取；Query 更适合封装跨模块派生结果或表现层不应理解的组合读取。

`change_state()` 只负责请求状态机切换，不能替调用它的 `update()` 自动结束后续代码。一个状态内同时判断移动、攻击、受击等条件时，应按优先级使用 `return` 或 `elif`，避免同一帧连续触发多个切换：

```gdscript
func update(_delta: float) -> void:
	if _input_map_util.consume_action(&"light_attack"):
		change_state(&"Attack")
		return

	if _input_model.move_value.x != 0:
		change_state(&"Run")
		return
```

`GFState` 也提供和 `GFSystem` / `GFUtility` / `GFController` 风格一致的事件代理：`register_event()`、`register_assignable_event()`、`register_simple_event()` 会以当前状态作为 owner 注册监听；`dispose()` 会做最终兜底清理。若监听只在该状态激活期间有效，应在 `exit()` 里调用 `unregister_owner_events()`：

```gdscript
func enter(_msg: Dictionary = {}) -> void:
	register_event(AnimFinishedPayload, _on_anim_finished)


func exit() -> void:
	unregister_owner_events()


func _on_anim_finished(payload: AnimFinishedPayload) -> void:
	if payload.animation_name == &"attack":
		change_state(&"Idle")
```

---


## 场景树节点状态机 (`GFNodeStateMachine`)

当状态逻辑需要直接引用动画、碰撞、输入节点或子节点时，可以使用节点式状态机。它不会替代纯代码 `GFStateMachine`，而是服务于角色控制器、UI 流程、复杂交互对象这类天然依赖场景树的状态。

```text
Player
└── GFNodeStateMachine
	├── IdleState.gd  (extends GFNodeState)
	├── RunState.gd   (extends GFNodeState)
	└── Combat        (GFNodeStateGroup)
		├── AimState.gd
		└── FireState.gd
```

状态脚本继承 `GFNodeState`：

```gdscript
class_name IdleState
extends GFNodeState


func _enter(previous_state: StringName = &"", args: Dictionary = {}) -> void:
	$AnimationPlayer.play("idle")


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		transition_to(&"Run")
```

状态机支持直接子状态组成内部组，也支持 `GFNodeStateGroup` 形成多个并行状态层。`ready` 后动态加入的状态节点会自动重新加载；跨组切换使用 `"Group/State"` 路径：

```gdscript
transition_to(&"Combat/Fire", { "target": enemy })
```

从 `2.0.0` 起，默认 `start_mode` 为 `AFTER_HOST_READY`，会等待状态机宿主节点完成 `_ready()` 后再进入 `initial_state`。如果旧项目依赖“状态机自身 `_ready()` 后立刻进入初始状态”的顺序，可以显式设回 `ON_READY`；需要完全由业务时机控制时使用 `MANUAL`：

```gdscript
# Inspector: StateMachine.start_mode = GFNodeStateMachine.StartMode.MANUAL
@onready var state_machine: GFNodeStateMachine = $StateMachine


func _ready() -> void:
	# 完成宿主节点自己的初始化后再启动状态机。
	state_machine.start()
```

也可以直接在 Inspector 中把 `start_mode` 设为 `AFTER_HOST_READY`，让状态机自动等待宿主 ready 后再进入初始状态。

如需把弹窗、瞄准、短暂硬直等“覆盖式”状态叠加在当前状态之上，可使用状态栈。`push_state()` 会调用旧状态的 `_pause()` 并进入新状态，`pop_state()` 会退出当前子状态并调用上一层状态的 `_resume()`：

```gdscript
machine.push_state(&"Inventory", { "source": "shortcut" })
machine.pop_state()
```

状态机还提供 `GFNodeStateMachineConfig` 资源，用于复用内部组初始状态、初始参数、历史容量与最大栈深度。运行时可通过 `get_current_state()`、`get_current_group_state()`、`get_current_state_name()`、`get_state_history()`、`get_stack_depth()` 和 `is_in_state()` 查询状态机状态；状态脚本内部可用 `get_host()` 或 `host` 获取状态机所在宿主节点。`GFNodeStateMachine` 的状态组、状态切换和状态事件信号使用 `GFNodeStateGroup` / `GFNodeState` 参数，监听者可以直接访问状态 API，不需要先把 `Node` 再转型。

`GFNodeState` 与纯代码 `GFState` 保持同一套架构代理：`get_model()`、`get_system()`、`get_utility()`、`send_command()`、`send_query()`、`send_event()`、`send_simple_event()`、`register_event()`、`register_assignable_event()`、`register_simple_event()` 和 `unregister_owner_events()`。这些代理会优先解析最近的 `GFNodeContext`，再回退全局 `Gf` 架构。监听只在状态激活期间有效时，应在 `_exit()` 中调用 `unregister_owner_events()`：

```gdscript
class_name AttackState
extends GFNodeState


var _combat_model: CombatModel


func _enter(_previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	_combat_model = get_model(CombatModel) as CombatModel
	register_event(AnimFinishedPayload, _on_anim_finished)


func _exit(_next_state: StringName = &"", _args: Dictionary = {}) -> void:
	unregister_owner_events()


func _on_anim_finished(payload: AnimFinishedPayload) -> void:
	if payload.animation_name == &"attack":
		transition_to(&"Idle")
```

状态脚本可重写 `_can_enter()` 与 `_can_exit()` 作为进入/退出守卫；状态组会在守卫拒绝时发出 `transition_blocked`，并保持当前状态不变。需要把可复用条件和行为放到资源里时，可以继承 `GFNodeStateCondition` 或 `GFNodeStateBehavior`，再挂到状态的 `enter_conditions`、`exit_conditions` 或 `behaviors` 数组上。条件会和脚本守卫一起决定是否允许切换；行为会在状态自己的 `_initialize()`、`_enter()`、`_exit()`、`_pause()`、`_resume()` 或 `_handle_state_event()` 之后运行，适合复用动画播放、音效、输入门禁、调试标记等横切逻辑。

```gdscript
class_name HasTargetCondition
extends GFNodeStateCondition


func _evaluate(state: GFNodeState, _phase: StringName, _peer_state: StringName = &"", _args: Dictionary = {}) -> bool:
	return state.get_blackboard().has("target")
```

```gdscript
class_name PlayStateAudioBehavior
extends GFNodeStateBehavior


func _enter(state: GFNodeState, _previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	var host := state.get_host()
	if host != null and host.has_method("play_state_audio"):
		host.call("play_state_audio", state.get_state_name())
```

这两个资源基类只定义状态节点上下文和生命周期钩子，不规定动画命名、输入动作、AI 黑板字段或业务事件含义。复杂状态仍应继续写成 `GFNodeState` 子类；Resource 钩子适合抽出可组合、可在 Inspector 复用的通用片段。需要在同一状态组内共享少量运行时上下文时，可使用 `GFNodeStateGroup.blackboard` 或状态内的 `get_blackboard()`；字段含义仍由项目层决定。

节点状态也支持状态事件分发。`GFNodeStateMachine.dispatch_state_event(event_id, payload, group_name)` 可以指定某个状态组，也可以在 `group_name` 为空时按已注册状态组顺序广播；单个 `GFNodeStateGroup` 会先交给当前状态，再交给暂停栈中的状态。状态脚本重写 `_handle_state_event()` 并返回 `true` 即表示事件已处理。`get_state_snapshot()` 可返回各状态组当前状态、栈、历史、注册状态和黑板副本，适合调试面板或诊断命令消费。

编辑器菜单提供 `工具 > GF > 生成 NodeState` 与 `工具 > GF > 生成 NodeStateMachine` 模板，适合快速建立节点状态脚本。选中 `GFNodeStateMachine` 时，Inspector 会从直接子状态中提供初始状态选择，减少手填状态名带来的拼写错误；该列表读取状态节点导出的 `state_name`，为空时退回节点名，不要求状态脚本声明 `@tool`。Inspector 也提供结构验证入口，底层使用 `GFNodeStateMachineValidator` 返回 `GFValidationReport`，会检查空状态机、重复状态组、同组重复状态名、缺失或无效初始状态，以及 `enter_conditions`、`exit_conditions`、`behaviors` 中空槽位或缺少约定方法的资源。GF 工作区中的 `GFNodeStateMachineDock` 会扫描当前场景里的状态机，集中展示校验摘要和问题列表，适合在大型场景中快速切换检查对象；它仍然只复用标准结构校验，不推断项目自己的状态跳转表、动画命名或输入语义：

```gdscript
var report := GFNodeStateMachineValidator.validate_machine($StateMachine)
if not report.is_ok():
	print(report.make_summary("Player StateMachine"))
```

该校验器只检查框架结构是否自洽，不要求项目把状态转移表写进资源，也不会推断“巡逻”“攻击”“死亡”等业务状态是否可达。项目可以在编辑器工具、CI 或自定义诊断命令中复用它；需要更严格规则时，可读取报告中的 `issues` 后叠加项目自己的检查。

---
