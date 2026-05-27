# Action Queue API

Module: `extensions/action_queue`

## Classes

- [`GFAction`](#gfaction)
- [`GFActionInterceptionResult`](#gfactioninterceptionresult)
- [`GFActionInterceptor`](#gfactioninterceptor)
- [`GFActionQueueSystem`](#gfactionqueuesystem)
- [`GFAudioAction`](#gfaudioaction)
- [`GFCallableAction`](#gfcallableaction)
- [`GFConfiguredTweenAction`](#gfconfiguredtweenaction)
- [`GFFlashAction`](#gfflashaction)
- [`GFMoveTweenAction`](#gfmovetweenaction)
- [`GFRepeatAction`](#gfrepeataction)
- [`GFTweenActionConfig`](#gftweenactionconfig)
- [`GFTweenActionStep`](#gftweenactionstep)
- [`GFVisualAction`](#gfvisualaction)
- [`GFVisualActionGroup`](#gfvisualactiongroup)
- [`GFWaitAction`](#gfwaitaction)

## GFAction

- Path: `addons/gf/extensions/action_queue/core/gf_action.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFAction: 动作队列常用工厂。 提供轻量、静态的动作创建入口，让项目用更少样板组合 ActionQueue。 它只创建通用动作，不隐含任何项目业务流程。

### Methods

#### `sequence`

- API: `public`

```gdscript
static func sequence(actions: Array) -> GFVisualActionGroup:
```

创建顺序动作组。

Parameters:

| Name | Description |
|---|---|
| `actions` | 子动作列表。 |

Returns: 顺序动作组。

Schemas:

- `actions`: Array，元素为 GFVisualAction 或实现 execute() 协议的动作对象。

#### `parallel`

- API: `public`

```gdscript
static func parallel(actions: Array) -> GFVisualActionGroup:
```

创建并行动作组。

Parameters:

| Name | Description |
|---|---|
| `actions` | 子动作列表。 |

Returns: 并行动作组。

Schemas:

- `actions`: Array，元素为 GFVisualAction 或实现 execute() 协议的动作对象。

#### `wait`

- API: `public`

```gdscript
static func wait(seconds: float, host_node: Node = null) -> GFWaitAction:
```

创建等待动作。

Parameters:

| Name | Description |
|---|---|
| `seconds` | 等待秒数。 |
| `host_node` | 可选宿主节点。 |

Returns: 等待动作。

#### `callback`

- API: `public`

```gdscript
static func callback(callback: Callable, args: Array = []) -> GFCallableAction:
```

创建回调动作。

Parameters:

| Name | Description |
|---|---|
| `callback` | 要执行的回调。 |
| `args` | 回调参数。 |

Returns: 回调动作。

Schemas:

- `args`: Array，传给 callback.callv() 的参数列表。

#### `repeat`

- API: `public`

```gdscript
static func repeat(action_factory: Callable, count: int = 1) -> GFRepeatAction:
```

创建重复动作。

Parameters:

| Name | Description |
|---|---|
| `action_factory` | 每轮创建动作的工厂。 |
| `count` | 重复次数；0 表示无限重复。 |

Returns: 重复动作。

#### `repeat_forever`

- API: `public`

```gdscript
static func repeat_forever(action_factory: Callable) -> GFRepeatAction:
```

创建无限重复动作。

Parameters:

| Name | Description |
|---|---|
| `action_factory` | 每轮创建动作的工厂。 |

Returns: 无限重复动作。

#### `tween`

- API: `public`

```gdscript
static func tween( target: Object, property_name: NodePath, target_value: Variant, duration: float = 0.2, options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建通用属性 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `property_name` | 属性路径。 |
| `target_value` | 目标值。 |
| `duration` | 持续时间。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `target_value`: Variant，可被 Tween 写入 property_name 的目标值。
- `options`: Dictionary，支持 host_node、duration_scale、loop_count、ignore_time_scale、process_mode、pause_mode、delay、parallel、as_relative、transition_type 和 ease_type。

#### `tween_by`

- API: `public`

```gdscript
static func tween_by( target: Object, property_name: NodePath, offset: Variant, duration: float = 0.2, options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建通用相对属性 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `property_name` | 属性路径。 |
| `offset` | 相对偏移值。 |
| `duration` | 持续时间。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `offset`: Variant，会与当前属性值相加的相对偏移。
- `options`: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。

#### `move_to`

- API: `public`

```gdscript
static func move_to( target: Node, target_position: Variant, duration: float = 0.2, property_name: NodePath = ^"position" ) -> GFMoveTweenAction:
```

创建移动到目标位置的 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标节点。 |
| `target_position` | 目标位置。 |
| `duration` | 持续时间。 |
| `property_name` | 位置属性路径。 |

Returns: 移动动作。

Schemas:

- `target_position`: Variant，可写入 property_name 的目标位置，通常为 Vector2、Vector3 或 float。

#### `move_by`

- API: `public`

```gdscript
static func move_by( target: Object, offset: Variant, duration: float = 0.2, property_name: NodePath = ^"position", options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建相对移动 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `offset` | 相对偏移。 |
| `duration` | 持续时间。 |
| `property_name` | 位置属性路径。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `offset`: Variant，会与当前 property_name 值相加的相对偏移。
- `options`: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。

#### `scale_to`

- API: `public`

```gdscript
static func scale_to( target: Object, scale_value: Variant, duration: float = 0.2, property_name: NodePath = ^"scale", options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建缩放到目标值的 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `scale_value` | 目标缩放。 |
| `duration` | 持续时间。 |
| `property_name` | 缩放属性路径。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `scale_value`: Variant，可写入 property_name 的目标缩放值。
- `options`: Dictionary，字段同 tween() 的 options。

#### `scale_by`

- API: `public`

```gdscript
static func scale_by( target: Object, scale_delta: Variant, duration: float = 0.2, property_name: NodePath = ^"scale", options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建相对缩放 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `scale_delta` | 相对缩放偏移。 |
| `duration` | 持续时间。 |
| `property_name` | 缩放属性路径。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `scale_delta`: Variant，会与当前 property_name 值相加的相对缩放偏移。
- `options`: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。

#### `rotate_to`

- API: `public`

```gdscript
static func rotate_to( target: Object, rotation_value: Variant, duration: float = 0.2, property_name: NodePath = ^"rotation", options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建旋转到目标值的 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `rotation_value` | 目标旋转值。 |
| `duration` | 持续时间。 |
| `property_name` | 旋转属性路径。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `rotation_value`: Variant，可写入 property_name 的目标旋转值。
- `options`: Dictionary，字段同 tween() 的 options。

#### `rotate_by`

- API: `public`

```gdscript
static func rotate_by( target: Object, rotation_delta: Variant, duration: float = 0.2, property_name: NodePath = ^"rotation", options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建相对旋转 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `rotation_delta` | 相对旋转偏移。 |
| `duration` | 持续时间。 |
| `property_name` | 旋转属性路径。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `rotation_delta`: Variant，会与当前 property_name 值相加的相对旋转偏移。
- `options`: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。

#### `fade_to`

- API: `public`

```gdscript
static func fade_to( target: Object, alpha: float, duration: float = 0.2, options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建透明度 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象，通常为 CanvasItem。 |
| `alpha` | 目标 alpha。 |
| `duration` | 持续时间。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `options`: Dictionary，字段同 tween() 的 options。

#### `fade_by`

- API: `public`

```gdscript
static func fade_by( target: Object, alpha_delta: float, duration: float = 0.2, options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建相对透明度 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象，通常为 CanvasItem。 |
| `alpha_delta` | 相对 alpha 偏移。 |
| `duration` | 持续时间。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `options`: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。

#### `colorize`

- API: `public`

```gdscript
static func colorize( target: Object, color: Color, duration: float = 0.2, options: Dictionary = {} ) -> GFConfiguredTweenAction:
```

创建整体颜色 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象，通常为 CanvasItem。 |
| `color` | 目标颜色。 |
| `duration` | 持续时间。 |
| `options` | 可选 Tween 配置。 |

Returns: 配置化 Tween 动作。

Schemas:

- `options`: Dictionary，字段同 tween() 的 options。

#### `set_property`

- API: `public`

```gdscript
static func set_property(target: Object, property_name: NodePath, value: Variant) -> GFCallableAction:
```

创建设置任意属性的瞬时动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `property_name` | 属性路径。 |
| `value` | 要写入的值。 |

Returns: 回调动作。

Schemas:

- `value`: Variant，会通过 target.set_indexed(property_name, value) 写入的值。

#### `set_visible`

- API: `public`

```gdscript
static func set_visible(target: Object, visible: bool, property_name: NodePath = ^"visible") -> GFCallableAction:
```

创建设置 visible 属性的瞬时动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `visible` | 可见性。 |
| `property_name` | 可见性属性路径。 |

Returns: 回调动作。

#### `show`

- API: `public`

```gdscript
static func show(target: Object, property_name: NodePath = ^"visible") -> GFCallableAction:
```

创建显示目标的瞬时动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `property_name` | 可见性属性路径。 |

Returns: 回调动作。

#### `hide`

- API: `public`

```gdscript
static func hide(target: Object, property_name: NodePath = ^"visible") -> GFCallableAction:
```

创建隐藏目标的瞬时动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `property_name` | 可见性属性路径。 |

Returns: 回调动作。

#### `remove_node`

- API: `public`

```gdscript
static func remove_node(target: Node) -> GFCallableAction:
```

创建释放节点的瞬时动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 要释放的节点。 |

Returns: 回调动作。

## GFActionInterceptionResult

- Path: `addons/gf/extensions/action_queue/core/gf_action_interception_result.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFActionInterceptionResult: 动作队列拦截器的处理结果。 用于在动作执行前后表达继续、跳过、替换或停止队列等通用决策。

### Enums

#### `Decision`

- API: `public`

```gdscript
enum Decision { ## 继续当前动作。 CONTINUE, ## 跳过当前动作并继续后续队列。 SKIP, ## 用 replacement_action 替换当前动作。 REPLACE, ## 停止并清空当前队列。 STOP_QUEUE, }
```

拦截器决策类型。

### Properties

#### `decision`

- API: `public`

```gdscript
var decision: Decision = Decision.CONTINUE
```

当前决策。

#### `replacement_action`

- API: `public`

```gdscript
var replacement_action: Object = null
```

替换动作，仅在 decision 为 REPLACE 时使用。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

调用方自定义元数据。

Schemas:

- `metadata`: Dictionary，由项目或拦截器定义的附加诊断数据。

### Methods

#### `is_continue`

- API: `public`

```gdscript
func is_continue() -> bool:
```

判断结果是否表示继续当前动作。

Returns: 继续时返回 true。

#### `is_skip`

- API: `public`

```gdscript
func is_skip() -> bool:
```

判断结果是否表示跳过当前动作。

Returns: 跳过时返回 true。

#### `is_replace`

- API: `public`

```gdscript
func is_replace() -> bool:
```

判断结果是否表示替换当前动作。

Returns: 替换时返回 true。

#### `is_stop_queue`

- API: `public`

```gdscript
func is_stop_queue() -> bool:
```

判断结果是否表示停止队列。

Returns: 停止时返回 true。

#### `continue_action`

- API: `public`

```gdscript
static func continue_action(p_metadata: Dictionary = {}) -> GFActionInterceptionResult:
```

创建继续结果。

Parameters:

| Name | Description |
|---|---|
| `p_metadata` | 可选元数据。 |

Returns: 继续结果。

Schemas:

- `p_metadata`: Dictionary，由项目或拦截器定义的附加诊断数据。

#### `skip_action`

- API: `public`

```gdscript
static func skip_action(p_metadata: Dictionary = {}) -> GFActionInterceptionResult:
```

创建跳过结果。

Parameters:

| Name | Description |
|---|---|
| `p_metadata` | 可选元数据。 |

Returns: 跳过结果。

Schemas:

- `p_metadata`: Dictionary，由项目或拦截器定义的附加诊断数据。

#### `replace_with`

- API: `public`

```gdscript
static func replace_with( action: Object, p_metadata: Dictionary = {} ) -> GFActionInterceptionResult:
```

创建替换结果。

Parameters:

| Name | Description |
|---|---|
| `action` | 替换动作。 |
| `p_metadata` | 可选元数据。 |

Returns: 替换结果。

Schemas:

- `p_metadata`: Dictionary，由项目或拦截器定义的附加诊断数据。

#### `stop_queue`

- API: `public`

```gdscript
static func stop_queue(p_metadata: Dictionary = {}) -> GFActionInterceptionResult:
```

创建停止队列结果。

Parameters:

| Name | Description |
|---|---|
| `p_metadata` | 可选元数据。 |

Returns: 停止队列结果。

Schemas:

- `p_metadata`: Dictionary，由项目或拦截器定义的附加诊断数据。

## GFActionInterceptor

- Path: `addons/gf/extensions/action_queue/core/gf_action_interceptor.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFActionInterceptor: 动作队列的通用拦截器基类。 拦截器可在表现动作执行前后做横切处理，例如跳过、替换、停止后续队列、 记录诊断或根据运行时状态调整表现，不绑定任何具体玩法规则。

### Properties

#### `priority`

- API: `public`

```gdscript
var priority: int = 0
```

拦截器优先级，数值越大越早执行。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用当前拦截器。

## GFActionQueueSystem

- Path: `addons/gf/extensions/action_queue/core/gf_action_queue_system.gd`
- Extends: `GFSystem`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFActionQueueSystem: 逻辑与表现解耦的动作队列系统。 负责串行或并行消费动作对象，并在等待 Signal 时对发射源失效做防死锁保护。 动作可继承 `GFVisualAction`，也可直接实现 execute()/can_execute()/cancel() 等同名协议方法。

### Signals

#### `queue_drained`

- API: `public`

```gdscript
signal queue_drained
```

当队列从有内容变为全部执行完毕时发出。

### Properties

#### `is_processing`

- API: `public`

```gdscript
var is_processing: bool = false
```

是否正在处理队列。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化主队列、命名队列和拦截器状态。

#### `ready`

- API: `public`

```gdscript
func ready() -> void:
```

注册诊断工具快照。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放当前队列、命名队列和诊断注册。

#### `enqueue`

- API: `public`

```gdscript
func enqueue(action: Object) -> void:
```

将一个动作加入顺序队列。

Parameters:

| Name | Description |
|---|---|
| `action` | 要处理的动作对象。 |

#### `enqueue_fire_and_forget`

- API: `public`

```gdscript
func enqueue_fire_and_forget(action: Object) -> void:
```

将一个动作以显式 fire-and-forget 模式加入队列。

Parameters:

| Name | Description |
|---|---|
| `action` | 要处理的动作对象。 |

#### `enqueue_parallel`

- API: `public`

```gdscript
func enqueue_parallel(actions: Array) -> void:
```

将一批动作加入队列并并行执行。

Parameters:

| Name | Description |
|---|---|
| `actions` | 要处理的动作对象列表。 |

Schemas:

- `actions`: Array，元素为 GFVisualAction 或实现 execute() 协议的动作对象。

#### `push_front`

- API: `public`

```gdscript
func push_front(action: Object) -> void:
```

将一个动作插入队列头部。

Parameters:

| Name | Description |
|---|---|
| `action` | 要处理的动作对象。 |

#### `push_front_fire_and_forget`

- API: `public`

```gdscript
func push_front_fire_and_forget(action: Object) -> void:
```

将一个动作以显式 fire-and-forget 模式插入队列头部。

Parameters:

| Name | Description |
|---|---|
| `action` | 要处理的动作对象。 |

#### `push_front_parallel`

- API: `public`

```gdscript
func push_front_parallel(actions: Array) -> void:
```

将一批并行动作插入队列头部。

Parameters:

| Name | Description |
|---|---|
| `actions` | 要处理的动作对象列表。 |

Schemas:

- `actions`: Array，元素为 GFVisualAction 或实现 execute() 协议的动作对象。

#### `clear_queue`

- API: `public`

```gdscript
func clear_queue(stop_current: bool = false) -> void:
```

清空队列中尚未执行的动作。

Parameters:

| Name | Description |
|---|---|
| `stop_current` | 为 true 时同时取消当前正在等待 Signal 的动作队列消费。 |

#### `get_named_queue`

- API: `public`

```gdscript
func get_named_queue(queue_name: StringName) -> GFActionQueueSystem:
```

获取或创建一个命名动作队列。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 动作队列名称。 |

Returns: 命名队列；queue_name 为空时返回 null。

#### `get_linked_queue`

- API: `public`

```gdscript
func get_linked_queue(queue_name: StringName, linked_node: Node) -> GFActionQueueSystem:
```

创建或获取一个绑定到节点生命周期的命名队列。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 动作队列名称。 |
| `linked_node` | 与队列生命周期绑定的节点。 |

Returns: 绑定后的命名队列；queue_name 为空时返回 null。

#### `bind_to_node`

- API: `public`

```gdscript
func bind_to_node(linked_node: Node) -> void:
```

将当前队列绑定到节点生命周期；节点失效后队列会停止并清空。

Parameters:

| Name | Description |
|---|---|
| `linked_node` | 与队列生命周期绑定的节点。 |

#### `add_interceptor`

- API: `public`

```gdscript
func add_interceptor(interceptor: GFActionInterceptor) -> bool:
```

添加动作执行拦截器。

Parameters:

| Name | Description |
|---|---|
| `interceptor` | 拦截器实例。 |

Returns: 添加成功返回 true。

#### `remove_interceptor`

- API: `public`

```gdscript
func remove_interceptor(interceptor: GFActionInterceptor) -> bool:
```

移除动作执行拦截器。

Parameters:

| Name | Description |
|---|---|
| `interceptor` | 拦截器实例。 |

Returns: 移除成功返回 true。

#### `set_interceptors`

- API: `public`

```gdscript
func set_interceptors(interceptors: Array[GFActionInterceptor]) -> void:
```

批量替换动作执行拦截器。

Parameters:

| Name | Description |
|---|---|
| `interceptors` | 新拦截器列表。 |

#### `clear_interceptors`

- API: `public`

```gdscript
func clear_interceptors() -> void:
```

清空动作执行拦截器。

#### `get_interceptors`

- API: `public`

```gdscript
func get_interceptors() -> Array[GFActionInterceptor]:
```

获取动作执行拦截器副本。

Returns: 拦截器列表副本。

#### `enqueue_to`

- API: `public`

```gdscript
func enqueue_to(queue_name: StringName, action: Object) -> void:
```

将动作加入指定命名队列。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 动作队列名称。 |
| `action` | 要处理的动作对象。 |

#### `enqueue_fire_and_forget_to`

- API: `public`

```gdscript
func enqueue_fire_and_forget_to(queue_name: StringName, action: Object) -> void:
```

将动作以 fire-and-forget 模式加入指定命名队列。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 动作队列名称。 |
| `action` | 要处理的动作对象。 |

#### `enqueue_parallel_to`

- API: `public`

```gdscript
func enqueue_parallel_to(queue_name: StringName, actions: Array) -> void:
```

将一批动作加入指定命名队列并行执行。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 动作队列名称。 |
| `actions` | 要处理的动作对象列表。 |

Schemas:

- `actions`: Array，元素为 GFVisualAction 或实现 execute() 协议的动作对象。

#### `push_front_to`

- API: `public`

```gdscript
func push_front_to(queue_name: StringName, action: Object) -> void:
```

将动作插入指定命名队列头部。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 动作队列名称。 |
| `action` | 要处理的动作对象。 |

#### `clear_named_queue`

- API: `public`

```gdscript
func clear_named_queue(queue_name: StringName, stop_current: bool = false) -> void:
```

清理指定命名队列。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 动作队列名称。 |
| `stop_current` | 是否停止当前正在执行的动作。 |

#### `clear_all_named_queues`

- API: `public`

```gdscript
func clear_all_named_queues(stop_current: bool = false) -> void:
```

清理所有命名队列。

Parameters:

| Name | Description |
|---|---|
| `stop_current` | 是否停止当前正在执行的动作。 |

#### `skip_current_action`

- API: `public`

```gdscript
func skip_current_action() -> void:
```

跳过当前动作并继续消费后续动作。

#### `pause_current_action`

- API: `public`

```gdscript
func pause_current_action() -> bool:
```

暂停当前动作。

Returns: 存在当前动作时返回 true。

#### `resume_current_action`

- API: `public`

```gdscript
func resume_current_action() -> bool:
```

恢复当前动作。

Returns: 存在当前动作时返回 true。

#### `finish_current_action`

- API: `public`

```gdscript
func finish_current_action() -> void:
```

将当前动作标记为立即完成并继续消费后续动作。

#### `get_current_action`

- API: `public`

```gdscript
func get_current_action() -> Object:
```

获取当前正在执行或等待的动作。

Returns: 当前动作；没有动作时返回 null。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取动作队列诊断快照。

Returns: 诊断快照字典。

Schemas:

- `return`: Dictionary，包含 is_processing、queued_count、has_current_action、processing_serial、named_queue_count、named_queues、linked_node_alive 和 interceptor_count。

#### `tick`

- API: `public`

```gdscript
func tick(_delta: float) -> void:
```

驱动命名队列的生命周期清理。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 本帧时间增量（秒），默认实现不直接使用。 |

## GFAudioAction

- Path: `addons/gf/extensions/action_queue/actions/gf_audio_action.gd`
- Extends: `GFVisualAction`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFAudioAction: 将一次 SFX 播放包装为视觉队列动作。 音效通常不应该阻塞表现队列，因此默认使用 fire-and-forget 完成模式。

### Properties

#### `path`

- API: `public`

```gdscript
var path: String = ""
```

要播放的音频资源路径。

#### `clip`

- API: `public`

```gdscript
var clip: GFAudioClip = null
```

要播放的音频片段配置。优先级高于 path。

#### `bank`

- API: `public`

```gdscript
var bank: GFAudioBank = null
```

要播放的音频集合。与 clip_id 配合使用，优先级高于 clip。

#### `clip_id`

- API: `public`

```gdscript
var clip_id: StringName = &""
```

音频集合中的片段标识。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行动作并通过 GFAudioUtility 播放一次 SFX。

Returns: 始终返回 null，避免阻塞表现队列。

Schemas:

- `return`: Variant，始终为 null。

## GFCallableAction

- Path: `addons/gf/extensions/action_queue/actions/gf_callable_action.gd`
- Extends: `GFVisualAction`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFCallableAction: 将 Callable 包装为队列动作。 适合把轻量表现指令、日志、回调或项目自定义命令插入 GFActionQueueSystem。

### Properties

#### `callback`

- API: `public`

```gdscript
var callback: Callable
```

要执行的回调。

#### `args`

- API: `public`

```gdscript
var args: Array = []
```

传给回调的参数。

Schemas:

- `args`: Array，传给 callback.callv() 的参数列表。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行回调并返回回调结果。

Returns: callback.callv(args) 的返回值；回调无效时返回 null。

Schemas:

- `return`: Variant，由 callback 返回，可能是 Signal、null 或项目自定义值。

## GFConfiguredTweenAction

- Path: `addons/gf/extensions/action_queue/actions/gf_configured_tween_action.gd`
- Extends: `GFVisualAction`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFConfiguredTweenAction: 由 GFTweenActionConfig 驱动的通用 Tween 动作。 允许项目把表现动画拆成 Resource 配置，再交给 GFActionQueueSystem 编排。

### Signals

#### `marker_reached`

- API: `public`

```gdscript
signal marker_reached(marker_id: StringName, step_index: int, target: Object)
```

Tween 步骤标记到达后发出。

Parameters:

| Name | Description |
|---|---|
| `marker_id` | 标记标识。 |
| `step_index` | 步骤索引。 |
| `target` | 被缓动目标。 |

### Properties

#### `target`

- API: `public`

```gdscript
var target: Object
```

被缓动的目标对象。

#### `config`

- API: `public`

```gdscript
var config: GFTweenActionConfig
```

Tween 配置。

#### `host_node`

- API: `public`

```gdscript
var host_node: Node
```

可选 Tween 宿主节点。目标不是 Node 时必须提供。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行配置化 Tween。

Returns: 需要等待时返回内部完成 Signal；配置无效、目标无效或瞬时写入时返回 null。

Schemas:

- `return`: Variant，返回内部完成 Signal 或 null。

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

取消当前 Tween，并按配置恢复初始值。

#### `pause`

- API: `public`

```gdscript
func pause() -> void:
```

暂停当前 Tween。

#### `resume`

- API: `public`

```gdscript
func resume() -> void:
```

恢复当前 Tween。

#### `finish`

- API: `public`

```gdscript
func finish() -> void:
```

立即完成当前 Tween，并按配置恢复初始值。

#### `get_wait_guard_node`

- API: `public`

```gdscript
func get_wait_guard_node() -> Node:
```

获取用于保护等待生命周期的 Tween 宿主节点。

Returns: 有效宿主节点；无效时返回 null。

## GFFlashAction

- Path: `addons/gf/extensions/action_queue/actions/gf_flash_action.gd`
- Extends: `GFVisualAction`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFFlashAction: 通用 CanvasItem 闪色动作。 将目标节点的颜色属性短暂切到指定颜色，再恢复为原始值。 默认等待 Tween 完成后队列才会继续。

### Properties

#### `target`

- API: `public`

```gdscript
var target: CanvasItem
```

需要闪色的目标节点。

#### `flash_color`

- API: `public`

```gdscript
var flash_color: Color = Color.WHITE
```

闪色时写入的颜色。

#### `duration`

- API: `public`

```gdscript
var duration: float = 0.12
```

闪色总时长。

#### `property_name`

- API: `public`

```gdscript
var property_name: NodePath = ^"modulate"
```

要缓动的颜色属性名。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行闪色 Tween。

Returns: 需要等待时返回内部完成 Signal；目标无效、属性无效或瞬时写入时返回 null。

Schemas:

- `return`: Variant，返回内部完成 Signal 或 null。

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

取消当前 Tween 并释放等待者。

#### `get_wait_guard_node`

- API: `public`

```gdscript
func get_wait_guard_node() -> Node:
```

获取用于保护等待生命周期的目标节点。

Returns: 有效目标节点；无效时返回 null。

## GFMoveTweenAction

- Path: `addons/gf/extensions/action_queue/actions/gf_move_tween_action.gd`
- Extends: `GFVisualAction`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFMoveTweenAction: 通用节点移动 Tween 动作。 将目标节点的指定位置属性缓动到目标值，适合卡牌、棋子、UI 面板等 常见表现动作。默认等待 Tween 完成后队列才会继续。

### Properties

#### `target`

- API: `public`

```gdscript
var target: Node
```

被移动的目标节点。

#### `target_position`

- API: `public`

```gdscript
var target_position: Variant
```

要写入的位置值，通常为 Vector2 或 Vector3。

Schemas:

- `target_position`: Variant，可写入 property_name 的目标位置值，通常为 Vector2、Vector3 或 float。

#### `duration`

- API: `public`

```gdscript
var duration: float = 0.2
```

Tween 持续时间。

#### `property_name`

- API: `public`

```gdscript
var property_name: NodePath = ^"position"
```

要缓动的属性名。

#### `transition_type`

- API: `public`

```gdscript
var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC
```

Tween 过渡类型。

#### `ease_type`

- API: `public`

```gdscript
var ease_type: Tween.EaseType = Tween.EASE_OUT
```

Tween 缓动类型。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行移动 Tween。

Returns: 需要等待时返回内部完成 Signal；目标无效、配置无效或瞬时写入时返回 null。

Schemas:

- `return`: Variant，返回内部完成 Signal 或 null。

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

取消当前 Tween 并释放等待者。

#### `pause`

- API: `public`

```gdscript
func pause() -> void:
```

暂停当前 Tween。

#### `resume`

- API: `public`

```gdscript
func resume() -> void:
```

恢复当前 Tween。

#### `finish`

- API: `public`

```gdscript
func finish() -> void:
```

立即推进并完成当前 Tween。

#### `get_wait_guard_node`

- API: `public`

```gdscript
func get_wait_guard_node() -> Node:
```

获取用于保护等待生命周期的目标节点。

Returns: 有效目标节点；无效时返回 null。

## GFRepeatAction

- Path: `addons/gf/extensions/action_queue/actions/gf_repeat_action.gd`
- Extends: `GFVisualAction`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFRepeatAction: 按工厂重复创建并执行队列动作。 每轮通过 action_factory 创建一个新的动作对象，避免复用同一个动作实例时 残留 Tween、Timer 或节点引用状态。

### Signals

#### `repeat_completed`

- API: `public`

```gdscript
signal repeat_completed
```

重复流程结束时发出。

### Constants

#### `DEFAULT_MAX_IMMEDIATE_ITERATIONS_PER_FRAME`

- API: `public`

```gdscript
const DEFAULT_MAX_IMMEDIATE_ITERATIONS_PER_FRAME: int = 256
```

单帧最多连续执行的瞬时重复次数，避免无限重复的瞬时动作锁住主线程。

### Properties

#### `action_factory`

- API: `public`

```gdscript
var action_factory: Callable
```

动作工厂。每次调用应返回一个动作对象；返回 null 会结束重复。

#### `repeat_count`

- API: `public`

```gdscript
var repeat_count: int = 1
```

重复次数。0 表示无限重复，直到 cancel()、finish() 或工厂返回 null。

#### `max_immediate_iterations_per_frame`

- API: `public`

```gdscript
var max_immediate_iterations_per_frame: int = DEFAULT_MAX_IMMEDIATE_ITERATIONS_PER_FRAME
```

单帧最多连续执行的瞬时重复次数。小于 1 时按 1 处理。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

启动重复执行流程。

Returns: action_factory 有效时返回 repeat_completed Signal；无效时返回 null。

Schemas:

- `return`: Variant，返回 repeat_completed Signal 或 null。

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

取消重复流程并取消当前动作。

#### `pause`

- API: `public`

```gdscript
func pause() -> void:
```

暂停重复流程和当前动作。

#### `resume`

- API: `public`

```gdscript
func resume() -> void:
```

恢复重复流程和当前动作。

#### `finish`

- API: `public`

```gdscript
func finish() -> void:
```

立即完成重复流程并释放等待者。

## GFTweenActionConfig

- Path: `addons/gf/extensions/action_queue/tween/gf_tween_action_config.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTweenActionConfig: 配置化 Tween 动作资源。 可复用地描述一组属性 Tween 步骤，并生成 GFVisualAction。

### Properties

#### `steps`

- API: `public`

```gdscript
var steps: Array[GFTweenActionStep] = []
```

Tween 步骤列表。

Schemas:

- `steps`: Array，元素为 GFTweenActionStep。

#### `duration_scale`

- API: `public`

```gdscript
var duration_scale: float = 1.0
```

全局时长缩放。

#### `loop_count`

- API: `public`

```gdscript
var loop_count: int = 1
```

播放次数。1 表示播放一次，0 表示无限循环。

#### `ignore_time_scale`

- API: `public`

```gdscript
var ignore_time_scale: bool = false
```

是否忽略全局 time scale。

#### `process_mode`

- API: `public`

```gdscript
var process_mode: Tween.TweenProcessMode = Tween.TWEEN_PROCESS_IDLE
```

Tween 处理模式。

#### `pause_mode`

- API: `public`

```gdscript
var pause_mode: Tween.TweenPauseMode = Tween.TWEEN_PAUSE_BOUND
```

Tween 暂停模式。

#### `restore_initial_values_on_cancel`

- API: `public`

```gdscript
var restore_initial_values_on_cancel: bool = false
```

取消动作时是否恢复播放前捕获的属性值。

#### `restore_initial_values_on_finish`

- API: `public`

```gdscript
var restore_initial_values_on_finish: bool = false
```

动作正常完成或 finish() 时是否恢复播放前捕获的属性值。

### Methods

#### `create_action`

- API: `public`

```gdscript
func create_action(target: Object, host_node: Node = null) -> GFVisualAction:
```

创建配置化 Tween 动作。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `host_node` | 可选 Tween 宿主节点。 |

Returns: 动作实例。

#### `add_property_step`

- API: `public`

```gdscript
func add_property_step( property_name: NodePath, target_value: Variant, duration: float = 0.2 ) -> GFTweenActionStep:
```

添加一个属性步骤并返回该步骤。

Parameters:

| Name | Description |
|---|---|
| `property_name` | 属性路径。 |
| `target_value` | 目标值。 |
| `duration` | 持续时间。 |

Returns: 新步骤。

Schemas:

- `target_value`: Variant，可写入 property_name 的目标值。

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

是否没有有效步骤。

Returns: 无步骤返回 true。

#### `has_timed_steps`

- API: `public`

```gdscript
func has_timed_steps() -> bool:
```

是否包含需要等待的步骤。

Returns: 包含耗时步骤返回 true。

#### `apply_instant`

- API: `public`

```gdscript
func apply_instant(target: Object) -> void:
```

立即应用全部步骤。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |

#### `capture_initial_values`

- API: `public`

```gdscript
func capture_initial_values(target: Object) -> Dictionary:
```

捕获所有有效步骤的初始属性值。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |

Returns: 属性路径字符串到初始值的字典。

Schemas:

- `return`: Dictionary，key 为属性路径 String，value 为对应初始属性值的深拷贝。

#### `restore_initial_values`

- API: `public`

```gdscript
func restore_initial_values(target: Object, snapshot: Dictionary) -> void:
```

恢复 capture_initial_values() 捕获的属性值。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `snapshot` | 初始值快照。 |

Schemas:

- `snapshot`: Dictionary，key 为属性路径 String，value 为要恢复的属性值。

#### `get_validation_report`

- API: `public`

```gdscript
func get_validation_report(target: Object) -> GFValidationReport:
```

获取配置对目标对象的校验报告。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |

Returns: 校验报告。

#### `duplicate_config`

- API: `public`

```gdscript
func duplicate_config() -> GFTweenActionConfig:
```

创建深拷贝。

Returns: 新配置。

## GFTweenActionStep

- Path: `addons/gf/extensions/action_queue/tween/gf_tween_action_step.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTweenActionStep: 配置化 Tween 属性步骤。 描述一个目标对象属性如何缓动，不绑定具体节点或业务动作。

### Properties

#### `property_name`

- API: `public`

```gdscript
var property_name: NodePath = ^"position"
```

要缓动的属性路径。

#### `target_value`

- API: `public`

```gdscript
var target_value: Variant = null
```

目标值。

Schemas:

- `target_value`: Variant，可写入 property_name 的目标值；相对步骤中会与当前值相加。

#### `duration`

- API: `public`

```gdscript
var duration: float = 0.2
```

步骤持续时间。

#### `delay`

- API: `public`

```gdscript
var delay: float = 0.0
```

步骤延迟。

#### `as_relative`

- API: `public`

```gdscript
var as_relative: bool = false
```

是否相对当前值偏移。

#### `parallel`

- API: `public`

```gdscript
var parallel: bool = false
```

是否与前一个步骤并行。

#### `transition_type`

- API: `public`

```gdscript
var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC
```

Tween 过渡类型。

#### `ease_type`

- API: `public`

```gdscript
var ease_type: Tween.EaseType = Tween.EASE_OUT
```

Tween 缓动类型。

#### `marker_id`

- API: `public`

```gdscript
var marker_id: StringName = &""
```

可选步骤标记。非空时 GFConfiguredTweenAction 会在步骤结束后发出 marker_reached。

### Methods

#### `append_to_tween`

- API: `public`

```gdscript
func append_to_tween(tween: Tween, target: Object, duration_scale: float = 1.0) -> Variant:
```

追加到 Tween。

Parameters:

| Name | Description |
|---|---|
| `tween` | 目标 Tween。 |
| `target` | 目标对象。 |
| `duration_scale` | 时长缩放。 |

Returns: 创建的 Tweener。

Schemas:

- `return`: Variant，成功时为 PropertyTweener；无效时为 null。

#### `apply_instant`

- API: `public`

```gdscript
func apply_instant(target: Object) -> void:
```

立即应用步骤目标值。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |

#### `duplicate_step`

- API: `public`

```gdscript
func duplicate_step() -> GFTweenActionStep:
```

创建深拷贝。

Returns: 新步骤。

#### `can_apply_to`

- API: `public`

```gdscript
func can_apply_to(target: Object) -> bool:
```

检查目标对象是否能应用当前步骤。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |

Returns: 可应用时返回 true。

#### `get_validation_error`

- API: `public`

```gdscript
func get_validation_error(target: Object) -> String:
```

获取当前步骤对目标对象的校验错误。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |

Returns: 校验通过时返回空字符串。

#### `capture_initial_value`

- API: `public`

```gdscript
func capture_initial_value(target: Object) -> Variant:
```

捕获当前属性值。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |

Returns: 属性值；步骤无效时返回 null。

Schemas:

- `return`: Variant，目标属性的深拷贝值；步骤无效时为 null。

## GFVisualAction

- Path: `addons/gf/extensions/action_queue/actions/gf_visual_action.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFVisualAction: 视觉表现动作的抽象基类。 继承自 RefCounted，代表一个具体的、可 await 的表现动作单元， 如移动动画、卡牌翻面、粒子爆炸等。 通过将每个视觉动作封装为独立对象，GFActionQueueSystem 可以严格按序 或并行地消费它们，从而彻底隔离底层逻辑时序与 UI 表现时序。 子类必须重写 execute() 以实现具体的视觉逻辑： - 若动作是瞬时的（无需等待），直接执行并返回 null。 - 若动作需要等待（如 Tween/动画），返回一个 Signal， 外部可 await 此 Signal 以知悉动作结束。

### Enums

#### `CompletionMode`

- API: `public`

```gdscript
enum CompletionMode { ## 自动模式：返回 Signal 时等待，否则视为立即完成。 AUTO, ## 显式等待：语义上声明本动作需要等待返回的 Signal。 WAIT_FOR_SIGNAL, ## 发出即走：即使 execute() 返回 Signal，队列也不会等待。 FIRE_AND_FORGET, }
```

队列如何处理 execute() 的返回值。

### Properties

#### `completion_mode`

- API: `public`

```gdscript
var completion_mode: CompletionMode = CompletionMode.AUTO
```

动作完成模式。默认自动等待 Signal，返回 null 则继续。

#### `signal_timeout_seconds`

- API: `public`

```gdscript
var signal_timeout_seconds: float = 30.0
```

等待 Signal 的超时时间（秒）。小于等于 0 时表示不启用超时。

#### `signal_timeout_respects_time_scale`

- API: `public`

```gdscript
var signal_timeout_respects_time_scale: bool = true
```

Signal 超时计时是否跟随 GFTimeUtility 的暂停与 time_scale。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行此视觉动作。子类必须重写此方法。

Returns: 瞬时动作返回 null；需要等待的动作返回一个 Signal 供 await。

Schemas:

- `return`: Variant，瞬时动作返回 null；需要等待的动作返回 Signal。

#### `is_valid`

- API: `public`

```gdscript
func is_valid() -> bool:
```

判断动作在入队消费时是否仍然有效。 子类可根据目标节点、战斗目标或运行时状态决定是否跳过。

Returns: 有效返回 true。

#### `can_execute`

- API: `public`

```gdscript
func can_execute() -> bool:
```

判断动作是否可以执行。默认委托 is_valid()，便于子类覆盖更明确的语义。

Returns: 可以执行返回 true。

#### `as_fire_and_forget`

- API: `public`

```gdscript
func as_fire_and_forget() -> GFVisualAction:
```

将动作标记为显式 fire-and-forget，并返回自身以便链式调用。

Returns: 当前动作实例。

#### `as_wait_for_signal`

- API: `public`

```gdscript
func as_wait_for_signal() -> GFVisualAction:
```

将动作标记为显式等待 Signal，并返回自身以便链式调用。

Returns: 当前动作实例。

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

请求取消动作。基础实现不做处理；持有 Tween、Timer、信号连接或外部任务的自定义动作应重写。

#### `pause`

- API: `public`

```gdscript
func pause() -> void:
```

请求暂停动作。基础实现不做处理；可暂停动作应重写。

#### `resume`

- API: `public`

```gdscript
func resume() -> void:
```

请求恢复动作。基础实现不做处理；可暂停动作应重写。

#### `finish`

- API: `public`

```gdscript
func finish() -> void:
```

请求立即完成动作。基础实现委托 cancel()；需要区分取消和完成的动作应重写。

#### `get_wait_guard_node`

- API: `public`

```gdscript
func get_wait_guard_node() -> Node:
```

返回用于保护 Signal 等待生命周期的节点。 Tween 等非 Node 信号可通过该节点的 tree_exited 提前结束等待。

Returns: 等待保护节点；没有时返回 null。

#### `with_signal_timeout`

- API: `public`

```gdscript
func with_signal_timeout(seconds: float, respect_time_scale: bool = true) -> GFVisualAction:
```

设置等待 Signal 的超时时间，并返回自身以便链式调用。

Parameters:

| Name | Description |
|---|---|
| `seconds` | 超时时间；小于等于 0 时表示不启用超时。 |
| `respect_time_scale` | 是否跟随 GFTimeUtility 的暂停与 time_scale。 |

Returns: 当前动作实例。

#### `should_wait_for_result`

- API: `public`

```gdscript
func should_wait_for_result(result: Variant) -> bool:
```

根据当前完成模式判断队列是否应该等待 execute() 的返回值。

Parameters:

| Name | Description |
|---|---|
| `result` | execute() 返回值。 |

Returns: 应等待返回 true。

Schemas:

- `result`: Variant，由 execute() 返回，通常为 Signal 或 null。

#### `await_result_safely`

- API: `public`

```gdscript
func await_result_safely(result: Variant, should_continue: Callable = Callable()) -> void:
```

安全等待 execute() 返回的 Signal。 当发射源失效或 Node 提前退出树时，会自动结束等待，避免队列永久卡死。

Parameters:

| Name | Description |
|---|---|
| `result` | execute() 返回值。 |
| `should_continue` | 可选取消检查回调；返回 false 时立即停止等待。 |

Schemas:

- `result`: Variant，由 execute() 返回，等待时必须是 Signal。

## GFVisualActionGroup

- Path: `addons/gf/extensions/action_queue/actions/gf_visual_action_group.gd`
- Extends: `GFVisualAction`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFVisualActionGroup: 动作组复合节点 (Composite Pattern) 继承自 GFVisualAction。允许将一组子动作打包，按并行（全部一起发出并等待全部完成） 或顺序（逐个执行并等待各自完成）两种模式执行。 子动作可以继承 GFVisualAction，也可以直接实现动作协议方法。

### Properties

#### `actions`

- API: `public`

```gdscript
var actions: Array[Object] = []
```

包含的子动作列表。

Schemas:

- `actions`: Array，元素为 GFVisualAction 或实现 execute() 协议的动作对象。

#### `is_parallel`

- API: `public`

```gdscript
var is_parallel: bool = true
```

是否并行执行。为 true 时，并行触发所有子动作并等待全部完成； 为 false 时，按数组顺序依次执行并等待各自完成。

### Methods

#### `add`

- API: `public`

```gdscript
func add(action: Object) -> void:
```

添加一个子动作。

Parameters:

| Name | Description |
|---|---|
| `action` | 动作对象。 |

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行动作组逻辑。根据 is_parallel 决定并发还是串行。

Returns: 需要等待则返回内部完成信号，否则返回 null。

Schemas:

- `return`: Variant，动作组为空时返回 null；否则返回内部完成 Signal。

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

请求取消当前动作组执行。

#### `pause`

- API: `public`

```gdscript
func pause() -> void:
```

暂停所有有效子动作。

#### `resume`

- API: `public`

```gdscript
func resume() -> void:
```

恢复所有有效子动作。

#### `finish`

- API: `public`

```gdscript
func finish() -> void:
```

立即完成所有有效子动作并释放等待者。

## GFWaitAction

- Path: `addons/gf/extensions/action_queue/actions/gf_wait_action.gd`
- Extends: `GFVisualAction`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFWaitAction: 动作队列中的通用等待动作。 通过 SceneTreeTimer 表达一段时间等待，不携带业务含义。

### Signals

#### `wait_completed`

- API: `public`

```gdscript
signal wait_completed
```

等待完成时发出。取消后的旧计时器不会触发该信号。

### Properties

#### `seconds`

- API: `public`

```gdscript
var seconds: float = 0.0
```

等待秒数。

#### `host_node`

- API: `public`

```gdscript
var host_node: Node
```

可选宿主节点。存在时优先从该节点获取 SceneTree。

#### `process_always`

- API: `public`

```gdscript
var process_always: bool = true
```

计时器是否在暂停时继续处理。

#### `process_in_physics`

- API: `public`

```gdscript
var process_in_physics: bool = false
```

是否按物理帧处理。

#### `ignore_time_scale`

- API: `public`

```gdscript
var ignore_time_scale: bool = false
```

是否忽略 Engine.time_scale。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

启动等待计时器。

Returns: 需要等待时返回 wait_completed Signal；无需等待或无法获取 SceneTree 时返回 null。

Schemas:

- `return`: Variant，返回 wait_completed Signal 或 null。

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

取消当前等待。

#### `finish`

- API: `public`

```gdscript
func finish() -> void:
```

立即完成当前等待并发出 wait_completed。

