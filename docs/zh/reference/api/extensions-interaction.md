# Interaction API

Module: `extensions/interaction`

## Classes

- [`GFInteractionContext`](#gfinteractioncontext)
- [`GFInteractionFlow`](#gfinteractionflow)
- [`GFInteractionReceiver`](#gfinteractionreceiver)
- [`GFInteractionSensor`](#gfinteractionsensor)
- [`GFInteractions`](#gfinteractions)
- [`GFPointerInteraction3D`](#gfpointerinteraction3d)

## GFInteractionContext

- Path: `addons/gf/extensions/interaction/runtime/gf_interaction_context.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFInteractionContext: 一次交互流程的轻量上下文。 用于在 Command、事件或项目自定义方法之间传递 sender、target、payload 与可选分组信息。

### Properties

#### `sender`

- API: `public`

```gdscript
var sender: Object = null
```

交互发起者。

#### `target`

- API: `public`

```gdscript
var target: Object = null
```

交互目标。

#### `payload`

- API: `public`

```gdscript
var payload: Variant = null
```

交互携带的数据。

Schemas:

- `payload`: 交互携带的任意项目载荷；框架只透传，不解释其中结构。

#### `group_name`

- API: `public`

```gdscript
var group_name: StringName = &""
```

交互所属的可选分组。

### Methods

#### `with_sender`

- API: `public`

```gdscript
func with_sender(value: Object) -> GFInteractionContext:
```

设置 sender 并返回自身，便于链式构造。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |

Returns: 当前上下文。

#### `with_target`

- API: `public`

```gdscript
func with_target(value: Object) -> GFInteractionContext:
```

设置 target 并返回自身，便于链式构造。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |

Returns: 当前上下文。

#### `with_payload`

- API: `public`

```gdscript
func with_payload(value: Variant) -> GFInteractionContext:
```

设置 payload 并返回自身，便于链式构造。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |

Returns: 当前上下文。

Schemas:

- `value`: 要写入 payload 的任意项目载荷。

#### `with_group`

- API: `public`

```gdscript
func with_group(value: StringName) -> GFInteractionContext:
```

设置 group_name 并返回自身，便于链式构造。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |

Returns: 当前上下文。

## GFInteractionFlow

- Path: `addons/gf/extensions/interaction/runtime/gf_interaction_flow.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFInteractionFlow: 基于 GFInteractionContext 的链式交互辅助对象。 保持上下文传递与命令执行的显式类型边界，适合一次性组织交互流程。

### Properties

#### `context`

- API: `public`

```gdscript
var context: GFInteractionContext
```

当前交互上下文。

### Methods

#### `to`

- API: `public`

```gdscript
func to(target: Object) -> GFInteractionFlow:
```

设置交互目标。

Parameters:

| Name | Description |
|---|---|
| `target` | 交互目标对象。 |

Returns: 当前交互流程。

#### `with_payload`

- API: `public`

```gdscript
func with_payload(payload: Variant) -> GFInteractionFlow:
```

设置交互 payload。

Parameters:

| Name | Description |
|---|---|
| `payload` | 随事件或交互传递的数据。 |

Returns: 当前交互流程。

Schemas:

- `payload`: 交互携带的任意项目载荷；框架只透传。

#### `in_group`

- API: `public`

```gdscript
func in_group(group_name: StringName) -> GFInteractionFlow:
```

设置交互分组。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 项目自定义分组名称。 |

Returns: 当前交互流程。

#### `execute`

- API: `public`

```gdscript
func execute(command: Object) -> Variant:
```

执行命令。命令可通过 interaction_context 属性或 set_interaction_context(context) 接收上下文。

Parameters:

| Name | Description |
|---|---|
| `command` | 要执行的命令实例。 |

Returns: 命令执行结果。

Schemas:

- `return`: GFArchitecture.send_command() 或 command.execute() 返回的任意项目结果；缺少命令时返回 null。

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

发送事件。事件可通过 interaction_context 属性或 set_interaction_context(context) 接收上下文。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要派发的事件实例。 |

## GFInteractionReceiver

- Path: `addons/gf/extensions/interaction/nodes/gf_interaction_receiver.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFInteractionReceiver: 通用交互接收节点。 用 GFInteractionContext 接收任意交互请求，并提供启用状态、交互 ID 过滤、 自定义校验回调和统一结果报告。节点不解释任何业务语义。

### Signals

#### `interaction_validating`

- API: `public`

```gdscript
signal interaction_validating(context: GFInteractionContext, report: Dictionary)
```

交互进入自定义校验阶段时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `report` | 当前结果报告副本。 |

Schemas:

- `report`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `interaction_received`

- API: `public`

```gdscript
signal interaction_received(context: GFInteractionContext, report: Dictionary)
```

交互被接受时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `report` | 结果报告。 |

Schemas:

- `report`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `interaction_rejected`

- API: `public`

```gdscript
signal interaction_rejected(context: GFInteractionContext, report: Dictionary)
```

交互被拒绝时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `report` | 结果报告。 |

Schemas:

- `report`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否允许接收交互。

#### `accepted_interaction_ids`

- API: `public`

```gdscript
var accepted_interaction_ids: Array[StringName] = []
```

非空时，只接受这些交互 ID。

#### `rejected_interaction_ids`

- API: `public`

```gdscript
var rejected_interaction_ids: Array[StringName] = []
```

始终拒绝的交互 ID。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

接收器自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 接收器自定义元数据 Dictionary；框架会复制到结果报告，但不解释其中键值。

#### `receiver_path`

- API: `public`

```gdscript
var receiver_path: NodePath = NodePath("")
```

可选业务接收节点路径；为空时由当前节点直接接收。

#### `validation_callback`

- API: `public`

```gdscript
var validation_callback: Callable = Callable()
```

自定义校验回调，建议签名为 func(context: GFInteractionContext, report: Dictionary) -> Variant。 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。

### Methods

#### `can_receive_interaction`

- API: `public`

```gdscript
func can_receive_interaction(interaction_id: StringName = &"") -> bool:
```

检查指定交互 ID 是否可被当前接收器接受。

Parameters:

| Name | Description |
|---|---|
| `interaction_id` | 交互 ID。 |

Returns: 可接受时返回 true。

#### `receive_interaction`

- API: `public`

```gdscript
func receive_interaction(context: GFInteractionContext, interaction_id: StringName = &"") -> Dictionary:
```

接收一次交互。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `interaction_id` | 交互 ID。 |

Returns: 统一结果报告。

Schemas:

- `return`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

## GFInteractionSensor

- Path: `addons/gf/extensions/interaction/nodes/gf_interaction_sensor.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFInteractionSensor: 通用交互发送节点。 负责构建 GFInteractionContext，并把交互请求发送给具备 receive_interaction() 方法的接收对象。发送者、目标、payload 和分组均保持通用，不绑定具体玩法。

### Signals

#### `interaction_sent`

- API: `public`

```gdscript
signal interaction_sent(context: GFInteractionContext, receiver: Object, report: Dictionary)
```

交互已发送。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `interaction_accepted`

- API: `public`

```gdscript
signal interaction_accepted(context: GFInteractionContext, receiver: Object, report: Dictionary)
```

交互被接收对象接受。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `interaction_rejected`

- API: `public`

```gdscript
signal interaction_rejected(context: GFInteractionContext, receiver: Object, report: Dictionary)
```

交互被接收对象拒绝或发送失败。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否允许发送交互。

#### `interaction_id`

- API: `public`

```gdscript
var interaction_id: StringName = &""
```

默认交互 ID。

#### `group_name`

- API: `public`

```gdscript
var group_name: StringName = &""
```

默认交互分组。

#### `payload`

- API: `public`

```gdscript
var payload: Dictionary = {}
```

默认 payload；发送时会深拷贝。

Schemas:

- `payload`: 默认交互载荷 Dictionary；发送时会复制，项目可定义其中键值。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

发送器自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 发送器自定义元数据 Dictionary；框架会复制到结果报告，但不解释其中键值。

#### `sender_path`

- API: `public`

```gdscript
var sender_path: NodePath = NodePath("")
```

可选发送者路径；为空时使用当前节点。

### Methods

#### `build_context`

- API: `public`

```gdscript
func build_context( target: Object = null, payload_override: Variant = null, group_override: StringName = &"" ) -> GFInteractionContext:
```

构建交互上下文。

Parameters:

| Name | Description |
|---|---|
| `target` | 交互目标。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `group_override` | 覆盖分组；为空时使用节点默认分组。 |

Returns: 交互上下文。

Schemas:

- `payload_override`: 覆盖默认 payload 的任意项目载荷；为 null 时复制节点默认 payload。

#### `send_to`

- API: `public`

```gdscript
func send_to( receiver: Object, payload_override: Variant = null, interaction_id_override: StringName = &"" ) -> Dictionary:
```

向指定接收对象发送交互。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收对象。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `interaction_id_override` | 覆盖交互 ID；为空时使用节点默认交互 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: 覆盖默认 payload 的任意项目载荷；为 null 时复制节点默认 payload。
- `return`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `send_to_path`

- API: `public`

```gdscript
func send_to_path( receiver_path: NodePath, payload_override: Variant = null, interaction_id_override: StringName = &"" ) -> Dictionary:
```

向指定节点路径发送交互。

Parameters:

| Name | Description |
|---|---|
| `receiver_path` | 接收节点路径。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `interaction_id_override` | 覆盖交互 ID；为空时使用节点默认交互 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: 覆盖默认 payload 的任意项目载荷；为 null 时复制节点默认 payload。
- `return`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `broadcast_to_group`

- API: `public`

```gdscript
func broadcast_to_group(target_group_name: StringName = &"", max_count: int = 0) -> Array[Dictionary]:
```

向场景树分组中的接收对象广播交互。

Parameters:

| Name | Description |
|---|---|
| `target_group_name` | 目标分组；为空时使用节点默认分组。 |
| `max_count` | 最多发送数量；小于等于 0 表示不限制。 |

Returns: 结果报告列表。

Schemas:

- `return`: 交互结果报告字典数组；每项包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `send_to_raycast_2d`

- API: `public`

```gdscript
func send_to_raycast_2d( raycast: RayCast2D, payload_override: Variant = null, interaction_id_override: StringName = &"" ) -> Dictionary:
```

向 RayCast2D 当前命中的接收对象发送交互。

Parameters:

| Name | Description |
|---|---|
| `raycast` | RayCast2D 节点。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `interaction_id_override` | 覆盖交互 ID；为空时使用节点默认交互 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: 覆盖默认 payload 的任意项目载荷；为 null 时复制节点默认 payload。
- `return`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `send_to_raycast_3d`

- API: `public`

```gdscript
func send_to_raycast_3d( raycast: RayCast3D, payload_override: Variant = null, interaction_id_override: StringName = &"" ) -> Dictionary:
```

向 RayCast3D 当前命中的接收对象发送交互。

Parameters:

| Name | Description |
|---|---|
| `raycast` | RayCast3D 节点。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `interaction_id_override` | 覆盖交互 ID；为空时使用节点默认交互 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: 覆盖默认 payload 的任意项目载荷；为 null 时复制节点默认 payload。
- `return`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `broadcast_to_area_2d`

- API: `public`

```gdscript
func broadcast_to_area_2d( area: Area2D, max_count: int = 0, payload_override: Variant = null, interaction_id_override: StringName = &"" ) -> Array[Dictionary]:
```

向 Area2D 当前重叠的接收对象批量发送交互。

Parameters:

| Name | Description |
|---|---|
| `area` | Area2D 节点。 |
| `max_count` | 最多发送数量；小于等于 0 表示不限制。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `interaction_id_override` | 覆盖交互 ID；为空时使用节点默认交互 ID。 |

Returns: 结果报告列表。

Schemas:

- `payload_override`: 覆盖默认 payload 的任意项目载荷；为 null 时复制节点默认 payload。
- `return`: 交互结果报告字典数组；每项包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

#### `broadcast_to_area_3d`

- API: `public`

```gdscript
func broadcast_to_area_3d( area: Area3D, max_count: int = 0, payload_override: Variant = null, interaction_id_override: StringName = &"" ) -> Array[Dictionary]:
```

向 Area3D 当前重叠的接收对象批量发送交互。

Parameters:

| Name | Description |
|---|---|
| `area` | Area3D 节点。 |
| `max_count` | 最多发送数量；小于等于 0 表示不限制。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `interaction_id_override` | 覆盖交互 ID；为空时使用节点默认交互 ID。 |

Returns: 结果报告列表。

Schemas:

- `payload_override`: 覆盖默认 payload 的任意项目载荷；为 null 时复制节点默认 payload。
- `return`: 交互结果报告字典数组；每项包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

## GFInteractions

- Path: `addons/gf/extensions/interaction/runtime/gf_interactions.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFInteractions: 创建交互上下文与链式交互流程的静态入口。

### Methods

#### `with_sender`

- API: `public`

```gdscript
static func with_sender(sender: Object, architecture: GFArchitecture = null) -> GFInteractionFlow:
```

创建以 sender 为发起者的交互流程。

Parameters:

| Name | Description |
|---|---|
| `sender` | 交互发起者。 |
| `architecture` | 用于命令或事件派发的架构实例。 |

Returns: 新交互流程。

#### `between`

- API: `public`

```gdscript
static func between( sender: Object, target: Object, payload: Variant = null, group_name: StringName = &"" ) -> GFInteractionContext:
```

创建一次 sender 到 target 的交互上下文。

Parameters:

| Name | Description |
|---|---|
| `sender` | 交互发起者。 |
| `target` | 交互目标对象。 |
| `payload` | 随事件或交互传递的数据。 |
| `group_name` | 项目自定义分组名称。 |

Returns: 新交互上下文。

Schemas:

- `payload`: 交互携带的任意项目载荷；框架只透传。

## GFPointerInteraction3D

- Path: `addons/gf/extensions/interaction/nodes/gf_pointer_interaction_3d.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFPointerInteraction3D: 将 3D 指针事件桥接为 GFInteractionContext。 监听 CollisionObject3D 的 hover、鼠标按钮与滚轮事件，构建通用交互上下文。 节点只传递位置、法线、按钮、标签和元数据，不解释点击对象的业务含义。

### Signals

#### `pointer_entered`

- API: `public`

```gdscript
signal pointer_entered(context: GFInteractionContext)
```

指针进入绑定的 3D 碰撞对象。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |

#### `pointer_exited`

- API: `public`

```gdscript
signal pointer_exited(context: GFInteractionContext)
```

指针离开绑定的 3D 碰撞对象。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |

#### `pointer_pressed`

- API: `public`

```gdscript
signal pointer_pressed(context: GFInteractionContext, event: InputEventMouseButton)
```

指针按钮按下。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `event` | 原始输入事件。 |

#### `pointer_released`

- API: `public`

```gdscript
signal pointer_released(context: GFInteractionContext, event: InputEventMouseButton)
```

指针按钮释放。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `event` | 原始输入事件。 |

#### `pointer_clicked`

- API: `public`

```gdscript
signal pointer_clicked(context: GFInteractionContext, event: InputEventMouseButton)
```

指针完成一次点击。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `event` | 原始输入事件。 |

#### `pointer_wheel`

- API: `public`

```gdscript
signal pointer_wheel(context: GFInteractionContext, event: InputEventMouseButton)
```

指针滚轮事件。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `event` | 原始输入事件。 |

#### `pointer_interaction_sent`

- API: `public`

```gdscript
signal pointer_interaction_sent(context: GFInteractionContext, receiver: Object, report: Dictionary)
```

已向接收器发送交互。

Parameters:

| Name | Description |
|---|---|
| `context` | 交互上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用指针桥接。

#### `interaction_id`

- API: `public`

```gdscript
var interaction_id: StringName = &""
```

默认交互 ID。

#### `group_name`

- API: `public`

```gdscript
var group_name: StringName = &""
```

默认交互分组。

#### `payload`

- API: `public`

```gdscript
var payload: Dictionary = {}
```

默认 payload；发送时会深拷贝并附加 pointer_* 字段。

Schemas:

- `payload`: 默认交互载荷 Dictionary；发送时会复制并附加 pointer_event、pointer_tags、pointer_metadata 等 pointer_* 字段。

#### `tags`

- API: `public`

```gdscript
var tags: PackedStringArray = PackedStringArray()
```

指针标签。框架不解释标签含义。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 指针交互自定义元数据 Dictionary；会写入 payload.pointer_metadata 并复制到结果报告。

#### `collision_object_path`

- API: `public`

```gdscript
var collision_object_path: NodePath = NodePath("")
```

可选 3D 碰撞对象路径；为空时优先使用父节点。

#### `receiver_path`

- API: `public`

```gdscript
var receiver_path: NodePath = NodePath("")
```

可选交互接收器路径；为空时从碰撞对象向父级解析 receive_interaction()。

#### `sender_path`

- API: `public`

```gdscript
var sender_path: NodePath = NodePath("")
```

可选发送者路径；为空时使用当前节点。

#### `send_on_clicked`

- API: `public`

```gdscript
var send_on_clicked: bool = true
```

是否在点击完成时发送交互。

#### `send_on_pressed`

- API: `public`

```gdscript
var send_on_pressed: bool = false
```

是否在按钮按下时发送交互。

#### `send_on_released`

- API: `public`

```gdscript
var send_on_released: bool = false
```

是否在按钮释放时发送交互。

#### `send_on_wheel`

- API: `public`

```gdscript
var send_on_wheel: bool = false
```

是否在滚轮事件时发送交互。

#### `send_on_hover`

- API: `public`

```gdscript
var send_on_hover: bool = false
```

是否在 hover 进入和离开时发送交互。

#### `ensure_input_ray_pickable`

- API: `public`

```gdscript
var ensure_input_ray_pickable: bool = true
```

绑定碰撞对象时是否确保 input_ray_pickable 为 true。

#### `change_cursor_on_hover`

- API: `public`

```gdscript
var change_cursor_on_hover: bool = false
```

hover 时是否临时切换鼠标光标。

#### `cursor_shape`

- API: `public`

```gdscript
var cursor_shape: Input.CursorShape = Input.CURSOR_ARROW
```

hover 时使用的鼠标光标。

### Methods

#### `bind_collision_object`

- API: `public`

```gdscript
func bind_collision_object(collision_object: CollisionObject3D) -> void:
```

绑定 3D 碰撞对象。

Parameters:

| Name | Description |
|---|---|
| `collision_object` | 要监听的碰撞对象。 |

#### `get_collision_object`

- API: `public`

```gdscript
func get_collision_object() -> CollisionObject3D:
```

获取当前绑定的 3D 碰撞对象。

Returns: 碰撞对象；不存在时返回 null。

#### `build_context`

- API: `public`

```gdscript
func build_context( pointer_event: StringName, pointer_data: Dictionary = {}, receiver: Object = null ) -> GFInteractionContext:
```

构建指针交互上下文。

Parameters:

| Name | Description |
|---|---|
| `pointer_event` | 指针事件标识。 |
| `pointer_data` | 指针事件数据。 |
| `receiver` | 可选接收对象；为空时自动解析。 |

Returns: 交互上下文。

Schemas:

- `pointer_data`: 指针事件数据 Dictionary；常见字段包括 pointer_position、pointer_normal、pointer_shape_idx、pointer_camera 和 pointer_input_event。

#### `send_pointer_interaction`

- API: `public`

```gdscript
func send_pointer_interaction( pointer_event: StringName, pointer_data: Dictionary = {}, interaction_id_override: StringName = &"" ) -> Dictionary:
```

发送一次指针交互。

Parameters:

| Name | Description |
|---|---|
| `pointer_event` | 指针事件标识。 |
| `pointer_data` | 指针事件数据。 |
| `interaction_id_override` | 可选交互 ID 覆盖。 |

Returns: 统一结果报告。

Schemas:

- `pointer_data`: 指针事件数据 Dictionary；常见字段包括 pointer_position、pointer_normal、pointer_shape_idx、pointer_camera 和 pointer_input_event。
- `return`: 交互结果报告 Dictionary，包含 ok、interaction_id、receiver、reason、message 和 metadata 等字段。

