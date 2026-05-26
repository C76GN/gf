# Behavior Tree API

Module: `extensions/behavior_tree`

## Classes

- [`GFBehaviorTree`](#gfbehaviortree)
- [`GFBehaviorTree.Action`](#gfbehaviortreeaction)
- [`GFBehaviorTree.AlwaysFail`](#gfbehaviortreealwaysfail)
- [`GFBehaviorTree.AlwaysSucceed`](#gfbehaviortreealwayssucceed)
- [`GFBehaviorTree.BTNode`](#gfbehaviortreebtnode)
- [`GFBehaviorTree.BlackboardScope`](#gfbehaviortreeblackboardscope)
- [`GFBehaviorTree.Condition`](#gfbehaviortreecondition)
- [`GFBehaviorTree.Cooldown`](#gfbehaviortreecooldown)
- [`GFBehaviorTree.Decorator`](#gfbehaviortreedecorator)
- [`GFBehaviorTree.Inverter`](#gfbehaviortreeinverter)
- [`GFBehaviorTree.Limit`](#gfbehaviortreelimit)
- [`GFBehaviorTree.Parallel`](#gfbehaviortreeparallel)
- [`GFBehaviorTree.Probability`](#gfbehaviortreeprobability)
- [`GFBehaviorTree.RandomSelector`](#gfbehaviortreerandomselector)
- [`GFBehaviorTree.RandomSequence`](#gfbehaviortreerandomsequence)
- [`GFBehaviorTree.Repeat`](#gfbehaviortreerepeat)
- [`GFBehaviorTree.Runner`](#gfbehaviortreerunner)
- [`GFBehaviorTree.Selector`](#gfbehaviortreeselector)
- [`GFBehaviorTree.Sequence`](#gfbehaviortreesequence)
- [`GFBehaviorTree.TimeLimit`](#gfbehaviortreetimelimit)
- [`GFBehaviorTree.UntilFail`](#gfbehaviortreeuntilfail)
- [`GFBehaviorTree.UntilSuccess`](#gfbehaviortreeuntilsuccess)

## GFBehaviorTree

- Path: `addons/gf/extensions/behavior_tree/runtime/gf_behavior_tree.gd`
- Extends: `Object`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFBehaviorTree: 轻量级、纯代码的行为树实现。 提供无需编辑器的、以代码方式构建 AI 或通用决策逻辑的轻量方案。 可以在任何 System 中通过 Runner 来驱动 tick()。核心节点包含 Sequence、Selector、Parallel、Action、Condition 以及常用装饰节点。

### Enums

#### `Status`

- API: `public`

```gdscript
enum Status { ## 节点尚未被 tick。 FRESH = -1, ## 节点本次执行成功。 SUCCESS = 0, ## 节点本次执行失败。 FAILURE = 1, ## 节点仍在运行，需要后续 tick 继续推进。 RUNNING = 2, ## 节点被外部中止。 ABORTED = 3, }
```

行为树节点的执行状态。

#### `ParallelPolicy`

- API: `public`

```gdscript
enum ParallelPolicy { ## 所有子节点成功才成功，任意子节点失败即失败。 REQUIRE_ALL, ## 任意子节点成功即成功，所有子节点失败才失败。 REQUIRE_ONE, }
```

Parallel 节点的完成策略。

### Methods

#### `status_to_string`

- API: `public`

```gdscript
static func status_to_string(status: int) -> StringName:
```

将状态枚举转换为稳定文本。

Parameters:

| Name | Description |
|---|---|
| `status` | 行为树状态。 |

Returns: 状态文本。

#### `build_debug_snapshot`

- API: `public`

```gdscript
static func build_debug_snapshot(node: Variant) -> Dictionary:
```

获取节点调试快照。

Parameters:

| Name | Description |
|---|---|
| `node` | 行为树节点。 |

Returns: 调试快照字典。

Schemas:

- `node`: GFBehaviorTree.BTNode、null 或提供 get_debug_snapshot() 的对象。
- `return`: 包含节点调试状态的 Dictionary；null 节点返回空字典。

### Inner Classes

#### GFBehaviorTree.Action

- Extends: `BTNode`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

动作节点 (叶子节点)。 包装一个回调函数执行具体指令。回调需返回 Status 类型。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的动作节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.AlwaysFail

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

总是失败装饰节点。 子节点运行中时保持 RUNNING，子节点结束时统一返回 FAILURE。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的总是失败装饰节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.AlwaysSucceed

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

总是成功装饰节点。 子节点运行中时保持 RUNNING，子节点结束时统一返回 SUCCESS。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的总是成功装饰节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.BTNode

- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

行为树所有节点的基类。

##### Properties

###### `name`

- API: `public`

```gdscript
var name: String = "BTNode"
```

节点名称，用于调试。

###### `node_id`

- API: `public`

```gdscript
var node_id: StringName = &""
```

可选稳定节点标识。

###### `last_status`

- API: `public`

```gdscript
var last_status: int = Status.FRESH
```

最近一次 tick 状态。

###### `last_reason`

- API: `public`

```gdscript
var last_reason: StringName = &""
```

最近一次状态原因。

###### `tick_count`

- API: `public`

```gdscript
var tick_count: int = 0
```

累计 tick 次数。

###### `last_tick_usec`

- API: `public`

```gdscript
var last_tick_usec: int = 0
```

最近一次 tick 耗时，单位微秒。

###### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

调用方附加元数据。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；键和值由调用方维护。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(_blackboard: Dictionary) -> int:
```

执行该节点的逻辑。子类应重写此方法。

Parameters:

| Name | Description |
|---|---|
| `_blackboard` | 运行时共享的数据字典。 |

Returns: 返回 Status 枚举。

Schemas:

- `_blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置节点内部运行状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建一份可独立运行的节点副本，不复制调试计数和正在运行的内部状态。 自定义节点若持有运行态，应重写此方法并复制自身类型；默认返回自身， 以避免未知子类被错误降级为基础 BTNode。

Returns: 运行时副本。

###### `clear_debug_state`

- API: `public`

```gdscript
func clear_debug_state(recursive: bool = true) -> void:
```

清空节点调试状态。

Parameters:

| Name | Description |
|---|---|
| `recursive` | 是否同时清空子节点调试状态。 |

###### `record_status`

- API: `public`

```gdscript
func record_status(status: int, reason: StringName = &"", elapsed_usec: int = 0) -> int:
```

记录节点状态。

Parameters:

| Name | Description |
|---|---|
| `status` | 新状态。 |
| `reason` | 可选状态原因。 |
| `elapsed_usec` | 可选耗时。 |

Returns: 原状态值，便于子类直接 return。

###### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: 包含 node_id、name、status、status_text、reason、tick_count、last_tick_usec、child_count、children 和 metadata 字段的 Dictionary；children 为子节点快照数组。

#### GFBehaviorTree.BlackboardScope

- Extends: `RefCounted`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

行为树黑板作用域。 支持父级回退和局部覆盖，可在项目层按需转换为 Dictionary 传给既有节点。

##### Properties

###### `values`

- API: `public`

```gdscript
var values: Dictionary = {}
```

当前作用域值。

Schemas:

- `values`: 当前作用域持有的黑板值 Dictionary；键通常为 StringName，值由项目自定义。

###### `parent`

- API: `public`

```gdscript
var parent: BlackboardScope = null
```

可选父级作用域。

##### Methods

###### `set_value`

- API: `public`

```gdscript
func set_value(key: StringName, value: Variant) -> void:
```

设置作用域值。

Parameters:

| Name | Description |
|---|---|
| `key` | 值标识。 |
| `value` | 值。 |

Schemas:

- `value`: 任意可存入黑板的项目值。

###### `get_value`

- API: `public`

```gdscript
func get_value(key: StringName, default_value: Variant = null) -> Variant:
```

获取作用域值。

Parameters:

| Name | Description |
|---|---|
| `key` | 值标识。 |
| `default_value` | 缺失时返回的默认值。 |

Returns: 作用域值。

Schemas:

- `default_value`: 缺失时返回的任意项目值。
- `return`: 找到的黑板值，或传入的 default_value。

###### `has_value`

- API: `public`

```gdscript
func has_value(key: StringName) -> bool:
```

检查作用域值是否存在。

Parameters:

| Name | Description |
|---|---|
| `key` | 值标识。 |

Returns: 存在返回 true。

###### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为合并后的字典。

Returns: 黑板字典。

Schemas:

- `return`: 父级与当前作用域合并后的 Dictionary；当前作用域同名键覆盖父级键。

#### GFBehaviorTree.Condition

- Extends: `BTNode`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

条件检查节点 (叶子节点)。 包装一个返回布尔值的回调。true 为 SUCCESS，false 为 FAILURE。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的条件节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.Cooldown

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

冷却装饰节点。 子节点结束后进入冷却期，冷却未结束时返回 FAILURE。

##### Properties

###### `cooldown_seconds`

- API: `public`

```gdscript
var cooldown_seconds: float = 0.0
```

冷却秒数。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；可提供 time_msec: int，其余字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置运行状态，保留已经开始的冷却。

###### `clear_cooldown`

- API: `public`

```gdscript
func clear_cooldown() -> void:
```

清空冷却状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的冷却装饰节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.Decorator

- Extends: `BTNode`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

单子节点装饰器基类。

##### Methods

###### `set_child`

- API: `public`

```gdscript
func set_child(child_node: BTNode) -> Decorator:
```

设置被装饰的子节点。

Parameters:

| Name | Description |
|---|---|
| `child_node` | 子节点。 |

Returns: 当前装饰器。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置子节点状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的装饰器副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.Inverter

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

反转装饰节点。 翻转子节点的成功与失败状态。RUNNING 状态保持不变。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的反转装饰节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.Limit

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

次数限制装饰节点。 子节点最多被 tick 指定次数；超过次数后返回 FAILURE。

##### Properties

###### `max_ticks`

- API: `public`

```gdscript
var max_ticks: int = 1
```

最大允许 tick 次数。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置调用计数与子节点状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的次数限制装饰节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.Parallel

- Extends: `BTNode`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

并行节点。 每次 tick 推进全部子节点，并根据 ParallelPolicy 汇总状态。

##### Properties

###### `policy`

- API: `public`

```gdscript
var policy: ParallelPolicy = ParallelPolicy.REQUIRE_ALL
```

并行节点完成策略。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置所有子节点状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的并行节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.Probability

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

概率装饰节点。 每轮按 probability 判定是否允许子节点执行，未命中时返回 FAILURE。

##### Properties

###### `probability`

- API: `public`

```gdscript
var probability: float = 1.0
```

执行概率，范围 0.0 到 1.0。

###### `rng`

- API: `public`

```gdscript
var rng: RandomNumberGenerator = null
```

可选随机源；为空时优先使用 blackboard["rng"]。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；可提供 rng: RandomNumberGenerator，其余字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置当前概率轮次与子节点状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的概率装饰节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.RandomSelector

- Extends: `BTNode`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

随机选择节点。 与 Selector 语义一致，但每轮从随机顺序尝试子节点。

##### Properties

###### `rng`

- API: `public`

```gdscript
var rng: RandomNumberGenerator = null
```

可选随机源；为空时优先使用 blackboard["rng"]，否则退回全局随机。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；可提供 rng: RandomNumberGenerator，其余字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置当前随机轮次与子节点状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的随机选择节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.RandomSequence

- Extends: `BTNode`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

随机顺序节点。 与 Sequence 语义一致，但每轮从随机顺序尝试子节点。

##### Properties

###### `rng`

- API: `public`

```gdscript
var rng: RandomNumberGenerator = null
```

可选随机源；为空时优先使用 blackboard["rng"]，否则退回全局随机。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；可提供 rng: RandomNumberGenerator，其余字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置当前随机轮次与子节点状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的随机顺序节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.Repeat

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

重复装饰节点。 子节点成功后重复执行，达到 repeat_count 后返回 SUCCESS；repeat_count 为 0 表示无限重复。

##### Properties

###### `repeat_count`

- API: `public`

```gdscript
var repeat_count: int = 1
```

成功重复次数；0 表示无限重复。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置重复计数与子节点状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的重复装饰节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.Runner

- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

行为树的执行入口容器。

##### Properties

###### `blackboard`

- API: `public`

```gdscript
var blackboard: Dictionary = {}
```

运行时共享黑板。

Schemas:

- `blackboard`: 传给根节点 tick() 的共享 Dictionary；键和值由项目自定义。

###### `duplicates_runtime_tree`

- API: `public`

```gdscript
var duplicates_runtime_tree: bool = true
```

是否在构造运行器时复制内置节点运行态，避免多个 Runner 共享同一棵树的进度。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick() -> int:
```

驱动行为树运行逻辑。 通常在 GFSystem 的 tick 中被调用。

Returns: 返回根节点 Status 枚举。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置整棵行为树的运行状态。

###### `clear_debug_state`

- API: `public`

```gdscript
func clear_debug_state() -> void:
```

清空整棵行为树的调试状态。

###### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取运行器调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: 包含 root 和 blackboard_keys 字段的 Dictionary；root 为根节点调试快照，blackboard_keys 为排序后的黑板键列表。

#### GFBehaviorTree.Selector

- Extends: `BTNode`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

选择节点 (OR 逻辑)。 依次执行子节点，直到有一个子节点返回 SUCCESS 或 RUNNING，否则返回 FAILURE。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置当前子节点索引与所有子节点状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的选择节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.Sequence

- Extends: `BTNode`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

顺序节点 (AND 逻辑)。 依次执行子节点，只有全部成功才返回 SUCCESS。遇到 RUNNING 或 FAILURE 则中断并返回对应状态。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置当前子节点索引与所有子节点状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的顺序节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.TimeLimit

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

时间限制装饰节点。 子节点 RUNNING 持续超过限制时返回 FAILURE 并重置子节点。

##### Properties

###### `limit_seconds`

- API: `public`

```gdscript
var limit_seconds: float = 1.0
```

最大运行秒数。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；可提供 time_msec: int，其余字段由项目自定义。

###### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置计时状态。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的时间限制装饰节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.UntilFail

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

直到失败装饰节点。 子节点成功时继续返回 RUNNING，直到子节点失败。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的直到失败装饰节点副本。

Returns: 复制后的运行时节点。

#### GFBehaviorTree.UntilSuccess

- Extends: `Decorator`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

直到成功装饰节点。 子节点失败时继续返回 RUNNING，直到子节点成功。

##### Methods

###### `tick`

- API: `public`

```gdscript
func tick(blackboard: Dictionary) -> int:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `blackboard` | 行为树本次 tick 使用的黑板数据。 |

Returns: 返回 Status 枚举。

Schemas:

- `blackboard`: Dictionary 形式黑板；字段由项目自定义。

###### `duplicate_runtime`

- API: `public`

```gdscript
func duplicate_runtime() -> BTNode:
```

创建可独立运行的直到成功装饰节点副本。

Returns: 复制后的运行时节点。

