# Turn Based API

Module: `extensions/turn_based`

## Classes

- [`GFTurnAction`](#gfturnaction)
- [`GFTurnContext`](#gfturncontext)
- [`GFTurnFlowSystem`](#gfturnflowsystem)
- [`GFTurnPhase`](#gfturnphase)

## GFTurnAction

- Path: `addons/gf/extensions/turn_based/runtime/gf_turn_action.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFTurnAction: 通用回合行动基类。 行动只描述“谁执行、对谁执行、排序值与载荷”，具体效果由子类重写 `_resolve()`。

### Properties

#### `action_id`

- API: `public`

```gdscript
var action_id: StringName = &""
```

行动标识。

#### `actor`

- API: `public`

```gdscript
var actor: Object = null
```

行动发起者。

#### `targets`

- API: `public`

```gdscript
var targets: Array[Object] = []
```

行动目标列表。

#### `payload`

- API: `public`

```gdscript
var payload: Variant = null
```

行动载荷，框架只存储并传递，不解释其结构。

Schemas:

- `payload`: Variant payload consumed by project-specific action resolvers.

#### `priority`

- API: `public`

```gdscript
var priority: int = 0
```

主排序优先级，值越大越先处理。

#### `sort_value`

- API: `public`

```gdscript
var sort_value: float = 0.0
```

次排序值，值越大越先处理。

#### `is_cancelled`

- API: `public`

```gdscript
var is_cancelled: bool = false
```

是否已取消。

### Methods

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

取消行动。

## GFTurnContext

- Path: `addons/gf/extensions/turn_based/runtime/gf_turn_context.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFTurnContext: 通用回合流程上下文。 只记录参与者、行动、轮次和元数据，不假设生命值、阵营、技能等业务概念。

### Properties

#### `actors`

- API: `public`

```gdscript
var actors: Array[Object] = []
```

当前流程参与者。

#### `actions`

- API: `public`

```gdscript
var actions: Array[GFTurnAction] = []
```

当前待处理行动。

#### `current_actor`

- API: `public`

```gdscript
var current_actor: Object = null
```

当前行动主体。

#### `turn_index`

- API: `public`

```gdscript
var turn_index: int = 0
```

当前回合索引。

#### `round_index`

- API: `public`

```gdscript
var round_index: int = 0
```

当前轮次索引。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

自定义元数据，框架不解释该字段。

Schemas:

- `metadata`: Dictionary[String, Variant] project-defined turn flow metadata.

### Methods

#### `add_actor`

- API: `public`

```gdscript
func add_actor(actor: Object) -> void:
```

添加参与者。

Parameters:

| Name | Description |
|---|---|
| `actor` | 参与者对象。 |

#### `remove_actor`

- API: `public`

```gdscript
func remove_actor(actor: Object) -> void:
```

移除参与者。

Parameters:

| Name | Description |
|---|---|
| `actor` | 参与者对象。 |

#### `clear_actions`

- API: `public`

```gdscript
func clear_actions() -> void:
```

清空运行时行动。

#### `get_actor_value`

- API: `public`

```gdscript
func get_actor_value(actor: Object, key: StringName, fallback: Variant = null) -> Variant:
```

从参与者读取排序或判定值。 优先调用 `get_turn_value(key, fallback)`，其次读取对象属性。

Parameters:

| Name | Description |
|---|---|
| `actor` | 参与者对象。 |
| `key` | 值键。 |
| `fallback` | 读取失败时的兜底值。 |

Returns: 读取到的值。

Schemas:

- `fallback`: Variant returned when no actor value can be read.
- `return`: Variant read from get_turn_value(), object property access, or fallback.

## GFTurnFlowSystem

- Path: `addons/gf/extensions/turn_based/runtime/gf_turn_flow_system.gd`
- Extends: `GFSystem`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTurnFlowSystem: 通用回合流程系统。 提供阶段推进、行动排队和按优先级解析能力。 它不关心战斗、卡牌、棋盘等具体业务，只调度抽象行动。

### Signals

#### `flow_started`

- API: `public`

```gdscript
signal flow_started(context: GFTurnContext)
```

流程开始时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 当前回合上下文。 |

#### `flow_stopped`

- API: `public`

```gdscript
signal flow_stopped(context: GFTurnContext)
```

流程停止时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 当前回合上下文。 |

#### `phase_changed`

- API: `public`

```gdscript
signal phase_changed(phase: GFTurnPhase, index: int)
```

阶段切换时发出。

Parameters:

| Name | Description |
|---|---|
| `phase` | 当前阶段。 |
| `index` | 当前阶段索引。 |

#### `action_enqueued`

- API: `public`

```gdscript
signal action_enqueued(action: GFTurnAction)
```

行动入队时发出。

Parameters:

| Name | Description |
|---|---|
| `action` | 入队行动。 |

#### `action_resolved`

- API: `public`

```gdscript
signal action_resolved(action: GFTurnAction)
```

行动解析完成时发出。

Parameters:

| Name | Description |
|---|---|
| `action` | 已解析行动。 |

### Properties

#### `context`

- API: `public`

```gdscript
var context: GFTurnContext = GFTurnContext.new()
```

当前回合上下文。

#### `phases`

- API: `public`

```gdscript
var phases: Array[GFTurnPhase] = []
```

阶段列表。

#### `current_phase_index`

- API: `public`

```gdscript
var current_phase_index: int = -1
```

当前阶段索引。

#### `is_running`

- API: `public`

```gdscript
var is_running: bool = false
```

当前是否正在运行。

#### `sort_actions_before_resolve`

- API: `public`

```gdscript
var sort_actions_before_resolve: bool = true
```

解析行动前是否按优先级排序。

#### `signal_timeout_seconds`

- API: `public`

```gdscript
var signal_timeout_seconds: float = 30.0
```

Signal 等待超时时间。小于等于 0 表示不启用超时。

#### `signal_timeout_respects_time_scale`

- API: `public`

```gdscript
var signal_timeout_respects_time_scale: bool = true
```

Signal 超时计时是否跟随 GFTimeUtility 的暂停与 time_scale。

### Methods

#### `set_context`

- API: `public`

```gdscript
func set_context(p_context: GFTurnContext) -> void:
```

设置上下文。

Parameters:

| Name | Description |
|---|---|
| `p_context` | 新上下文。 |

#### `set_phases`

- API: `public`

```gdscript
func set_phases(p_phases: Array[GFTurnPhase]) -> void:
```

设置阶段列表。

Parameters:

| Name | Description |
|---|---|
| `p_phases` | 新阶段列表。 |

#### `start`

- API: `public`

```gdscript
func start(reset_indices: bool = true) -> void:
```

开始流程。

Parameters:

| Name | Description |
|---|---|
| `reset_indices` | 是否重置阶段索引和轮次数据。 |

#### `stop`

- API: `public`

```gdscript
func stop(clear_actions: bool = true) -> void:
```

停止流程。

Parameters:

| Name | Description |
|---|---|
| `clear_actions` | 是否清空待处理行动。 |

#### `advance_phase`

- API: `public`

```gdscript
func advance_phase() -> void:
```

推进到下一个阶段。

#### `enqueue_action`

- API: `public`

```gdscript
func enqueue_action(action: GFTurnAction) -> void:
```

加入一个行动。

Parameters:

| Name | Description |
|---|---|
| `action` | 行动实例。 |

#### `resolve_actions`

- API: `public`

```gdscript
func resolve_actions(order_resolver: Callable = Callable()) -> void:
```

解析当前上下文中的所有行动。

Parameters:

| Name | Description |
|---|---|
| `order_resolver` | 可选排序回调，签名为 func(a, b) -> bool。 |

## GFTurnPhase

- Path: `addons/gf/extensions/turn_based/resources/gf_turn_phase.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFTurnPhase: 通用回合阶段基类。 阶段只提供 _enter/_execute/_exit 生命周期和完成信号， 不绑定任何具体游戏流程。

### Signals

#### `finished`

- API: `public`

```gdscript
signal finished
```

阶段完成时发出。

### Properties

#### `phase_id`

- API: `public`

```gdscript
var phase_id: StringName = &""
```

阶段标识。

#### `auto_finish`

- API: `public`

```gdscript
var auto_finish: bool = true
```

`_execute()` 返回后是否自动完成阶段。

#### `is_finished`

- API: `public`

```gdscript
var is_finished: bool = false
```

当前阶段是否已经完成。

### Methods

#### `finish`

- API: `public`

```gdscript
func finish() -> void:
```

标记阶段完成。

#### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置阶段运行状态。

