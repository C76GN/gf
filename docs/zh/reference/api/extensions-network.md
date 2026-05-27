# Network API

Module: `extensions/network`

## Classes

- [`GFENetNetworkBackend`](#gfenetnetworkbackend)
- [`GFFixedTickClock`](#gffixedtickclock)
- [`GFNetworkBackend`](#gfnetworkbackend)
- [`GFNetworkChannel`](#gfnetworkchannel)
- [`GFNetworkContract`](#gfnetworkcontract)
- [`GFNetworkContractField`](#gfnetworkcontractfield)
- [`GFNetworkContractGenerator`](#gfnetworkcontractgenerator)
- [`GFNetworkContractMessage`](#gfnetworkcontractmessage)
- [`GFNetworkFieldSerializer`](#gfnetworkfieldserializer)
- [`GFNetworkHistoryBuffer`](#gfnetworkhistorybuffer)
- [`GFNetworkMessage`](#gfnetworkmessage)
- [`GFNetworkMessageValidator`](#gfnetworkmessagevalidator)
- [`GFNetworkRateLimiter`](#gfnetworkratelimiter)
- [`GFNetworkReconnectPolicy`](#gfnetworkreconnectpolicy)
- [`GFNetworkSerializer`](#gfnetworkserializer)
- [`GFNetworkSession`](#gfnetworksession)
- [`GFNetworkSnapshot`](#gfnetworksnapshot)
- [`GFNetworkSnapshotSchema`](#gfnetworksnapshotschema)
- [`GFNetworkUtility`](#gfnetworkutility)
- [`GFWebSocketNetworkBackend`](#gfwebsocketnetworkbackend)

## GFENetNetworkBackend

- Path: `addons/gf/extensions/network/backends/gf_enet_network_backend.gd`
- Extends: `GFNetworkBackend`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFENetNetworkBackend: 基于 Godot ENetMultiplayerPeer 的网络后端。 该后端只实现 GFNetworkBackend 的 bytes 传输边界，不定义房间、同步、 RPC 或任何项目消息语义。需要更复杂协议时可以继续继承 GFNetworkBackend。

### Constants

#### `BROADCAST_PEER_ID`

- API: `public`

```gdscript
const BROADCAST_PEER_ID: int = -1
```

广播 peer 标识。

### Properties

#### `max_packets_per_poll`

- API: `public`

```gdscript
var max_packets_per_poll: int = 64
```

每次 poll 最多派发的入站包数量。小于等于 0 表示不限制。

### Methods

#### `host`

- API: `public`

```gdscript
func host(options: Dictionary = {}) -> Error:
```

启动 ENet 主机。 支持 options: port, max_clients, max_channels, in_bandwidth, out_bandwidth。

Parameters:

| Name | Description |
|---|---|
| `options` | 操作选项字典。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，支持 port、max_clients、max_channels、in_bandwidth、out_bandwidth。

#### `connect_to_endpoint`

- API: `public`

```gdscript
func connect_to_endpoint(endpoint: String, options: Dictionary = {}) -> Error:
```

连接 ENet 远端。 endpoint 可传 "host:port"，或通过 options.port 传端口。

Parameters:

| Name | Description |
|---|---|
| `endpoint` | 网络连接端点。 |
| `options` | 操作选项字典。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，支持 port、max_channels、in_bandwidth、out_bandwidth。

#### `disconnect_backend`

- API: `public`

```gdscript
func disconnect_backend() -> void:
```

断开 ENet 连接。

#### `send_bytes`

- API: `public`

```gdscript
func send_bytes(peer_id: int, bytes: PackedByteArray, options: Dictionary = {}) -> Error:
```

发送 bytes。 options 支持 reliable, transfer_mode, channel。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 目标网络 peer 标识。 |
| `bytes` | 要发送的字节数据。 |
| `options` | 操作选项字典。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，支持 reliable、transfer_mode、channel。

#### `poll`

- API: `public`

```gdscript
func poll(_delta: float) -> void:
```

轮询 ENet 事件和收包。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 本帧时间增量（秒），默认实现不直接使用。 |

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取后端调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 backend、available、endpoint、is_server、connection_status、connection_status_name、available_packet_count、max_packets_per_poll。

## GFFixedTickClock

- Path: `addons/gf/extensions/network/simulation/gf_fixed_tick_clock.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFFixedTickClock: 固定步长 tick 时钟。 用于网络同步、重放、确定性逻辑或任意固定频率调度；它只计算 tick 推进，不执行项目规则。

### Signals

#### `ticks_advanced`

- API: `public`

```gdscript
signal ticks_advanced(previous_tick: int, current_tick: int, step_count: int)
```

tick 推进后发出。

Parameters:

| Name | Description |
|---|---|
| `previous_tick` | 推进前 tick。 |
| `current_tick` | 推进后 tick。 |
| `step_count` | 本轮推进 tick 数。 |

#### `tick_loop_started`

- API: `public`

```gdscript
signal tick_loop_started(previous_tick: int, target_tick: int, step_count: int)
```

固定 tick 循环开始时发出。

Parameters:

| Name | Description |
|---|---|
| `previous_tick` | 循环前 tick。 |
| `target_tick` | 本轮预算内预计推进到的 tick。 |
| `step_count` | 本轮要处理的 tick 数。 |

#### `tick_started`

- API: `public`

```gdscript
signal tick_started(tick: int, tick_seconds: float)
```

单个固定 tick 开始时发出。

Parameters:

| Name | Description |
|---|---|
| `tick` | 正在处理的 tick。 |
| `tick_seconds` | 单个 tick 的秒数。 |

#### `tick_finished`

- API: `public`

```gdscript
signal tick_finished(tick: int, tick_seconds: float)
```

单个固定 tick 结束时发出。

Parameters:

| Name | Description |
|---|---|
| `tick` | 已处理完成的 tick。 |
| `tick_seconds` | 单个 tick 的秒数。 |

#### `tick_loop_finished`

- API: `public`

```gdscript
signal tick_loop_finished(previous_tick: int, current_tick: int, step_count: int)
```

固定 tick 循环结束时发出。

Parameters:

| Name | Description |
|---|---|
| `previous_tick` | 循环前 tick。 |
| `current_tick` | 循环后 tick。 |
| `step_count` | 本轮实际处理的 tick 数。 |

#### `tick_budget_exhausted`

- API: `public`

```gdscript
signal tick_budget_exhausted(available_steps: int, processed_steps: int, remaining_seconds: float)
```

由于单次预算限制而未处理所有可用 tick 时发出。

Parameters:

| Name | Description |
|---|---|
| `available_steps` | 本轮可用 tick 数。 |
| `processed_steps` | 本轮实际处理 tick 数。 |
| `remaining_seconds` | 预算处理后的累积剩余秒数。 |

### Properties

#### `tick_rate`

- API: `public`

```gdscript
var tick_rate: float = 30.0
```

每秒 tick 数。

#### `current_tick`

- API: `public`

```gdscript
var current_tick: int = 0
```

当前 tick。

#### `accumulator_seconds`

- API: `public`

```gdscript
var accumulator_seconds: float = 0.0
```

累积但尚未消费的时间。

#### `max_steps_per_update`

- API: `public`

```gdscript
var max_steps_per_update: int = 8
```

单次 advance() 最多推进的 tick 数；小于等于 0 表示不限制。

#### `drop_excess_time_on_budget_hit`

- API: `public`

```gdscript
var drop_excess_time_on_budget_hit: bool = true
```

达到单次预算上限时是否丢弃过量累积时间，避免长时间追帧。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure(p_tick_rate: float, p_max_steps_per_update: int = -1) -> void:
```

配置时钟。

Parameters:

| Name | Description |
|---|---|
| `p_tick_rate` | 每秒 tick 数。 |
| `p_max_steps_per_update` | 单次 advance() 最大步数；小于 0 表示保留原值。 |

#### `reset`

- API: `public`

```gdscript
func reset(start_tick: int = 0) -> void:
```

重置时钟。

Parameters:

| Name | Description |
|---|---|
| `start_tick` | 起始 tick。 |

#### `advance`

- API: `public`

```gdscript
func advance(delta_seconds: float) -> int:
```

推进时钟并返回应执行的固定步数。

Parameters:

| Name | Description |
|---|---|
| `delta_seconds` | 本次累积的真实时间。 |

Returns: 应执行的固定 tick 数。

#### `step_once`

- API: `public`

```gdscript
func step_once() -> int:
```

手动推进一个 tick。

Returns: 推进后的当前 tick。

#### `get_tick_seconds`

- API: `public`

```gdscript
func get_tick_seconds() -> float:
```

获取单个 tick 的秒数。

Returns: tick 秒数。

#### `get_interpolation_alpha`

- API: `public`

```gdscript
func get_interpolation_alpha() -> float:
```

获取插值 alpha。

Returns: 0 到 1 的累积时间比例。

#### `get_tick_factor`

- API: `public`

```gdscript
func get_tick_factor() -> float:
```

获取当前 tick 插值比例。

Returns: 0 到 1 的累积时间比例。

#### `get_lag_seconds`

- API: `public`

```gdscript
func get_lag_seconds() -> float:
```

获取当前累积延迟秒数。

Returns: 累积但尚未消费的时间。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转为字典。

Returns: 时钟状态字典。

Schemas:

- `return`: Dictionary，包含 tick_rate、current_tick、accumulator_seconds、max_steps_per_update、drop_excess_time_on_budget_hit。

#### `from_dict`

- API: `public`

```gdscript
func from_dict(data: Dictionary) -> void:
```

从字典恢复。

Parameters:

| Name | Description |
|---|---|
| `data` | 时钟状态字典。 |

Schemas:

- `data`: Dictionary，包含 tick_rate、current_tick、accumulator_seconds、max_steps_per_update、drop_excess_time_on_budget_hit。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 to_dict() 字段以及 tick_seconds、interpolation_alpha、tick_factor、lag_seconds。

## GFNetworkBackend

- Path: `addons/gf/extensions/network/backends/gf_network_backend.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNetworkBackend: 网络后端抽象基类。 后端负责具体传输协议，框架层只依赖该统一接口与信号。

### Signals

#### `connected`

- API: `public`

```gdscript
signal connected
```

连接成功后发出。

#### `disconnected`

- API: `public`

```gdscript
signal disconnected(reason: String)
```

断开连接后发出。

Parameters:

| Name | Description |
|---|---|
| `reason` | 断开原因。 |

#### `peer_connected`

- API: `public`

```gdscript
signal peer_connected(peer_id: int)
```

远端节点连接后发出。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 远端 peer 标识。 |

#### `peer_disconnected`

- API: `public`

```gdscript
signal peer_disconnected(peer_id: int)
```

远端节点断开后发出。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 远端 peer 标识。 |

#### `message_received`

- API: `public`

```gdscript
signal message_received(peer_id: int, bytes: PackedByteArray)
```

收到原始消息 bytes 后发出。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 远端 peer 标识。 |
| `bytes` | 原始消息 bytes。 |

### Methods

#### `host`

- API: `public`

```gdscript
func host(_options: Dictionary = {}) -> Error:
```

启动主机。

Parameters:

| Name | Description |
|---|---|
| `_options` | 后端自定义选项。 |

Returns: Godot 错误码。

Schemas:

- `_options`: Dictionary，后端自定义启动选项。

#### `connect_to_endpoint`

- API: `public`

```gdscript
func connect_to_endpoint(_endpoint: String, _options: Dictionary = {}) -> Error:
```

连接远端。

Parameters:

| Name | Description |
|---|---|
| `_endpoint` | 远端地址。 |
| `_options` | 后端自定义选项。 |

Returns: Godot 错误码。

Schemas:

- `_options`: Dictionary，后端自定义连接选项。

#### `disconnect_backend`

- API: `public`

```gdscript
func disconnect_backend() -> void:
```

断开连接。

#### `send_bytes`

- API: `public`

```gdscript
func send_bytes(_peer_id: int, _bytes: PackedByteArray, _options: Dictionary = {}) -> Error:
```

发送 bytes。

Parameters:

| Name | Description |
|---|---|
| `_peer_id` | 目标 peer；后端可约定 -1 表示广播。 |
| `_bytes` | 消息 bytes。 |
| `_options` | 后端自定义发送选项。 |

Returns: Godot 错误码。

Schemas:

- `_options`: Dictionary，后端自定义发送选项。

#### `poll`

- API: `public`

```gdscript
func poll(_delta: float) -> void:
```

后端轮询入口。需要轮询的后端可重写。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 帧间隔。 |

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取后端调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 backend、available 以及后端自定义状态字段。

## GFNetworkChannel

- Path: `addons/gf/extensions/network/session/gf_network_channel.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNetworkChannel: 网络发送通道描述。 描述一类消息的传输偏好，例如通道编号、可靠性和包体上限。

### Properties

#### `channel_id`

- API: `public`

```gdscript
var channel_id: StringName = &""
```

通道稳定标识。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

编辑器展示名称。

#### `transfer_channel`

- API: `public`

```gdscript
var transfer_channel: int = 0
```

后端传输通道编号。

#### `reliable`

- API: `public`

```gdscript
var reliable: bool = true
```

默认是否可靠传输。

#### `max_packet_size`

- API: `public`

```gdscript
var max_packet_size: int = 0
```

最大包体大小。小于等于 0 表示不限制。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，保存项目自定义通道元数据。

### Methods

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取展示名称。

Returns: 展示名称。

#### `build_send_options`

- API: `public`

```gdscript
func build_send_options(overrides: Dictionary = {}) -> Dictionary:
```

构建后端发送选项。

Parameters:

| Name | Description |
|---|---|
| `overrides` | 项目层额外发送选项。 |

Returns: 后端选项字典。

Schemas:

- `overrides`: Dictionary，项目层发送选项；channel 和 reliable 缺失时由通道默认值补齐。
- `return`: Dictionary，后端发送选项，至少包含 channel 和 reliable。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

描述通道。

Returns: 描述字典。

Schemas:

- `return`: Dictionary，包含 channel_id、display_name、transfer_channel、reliable、max_packet_size、metadata。

## GFNetworkContract

- Path: `addons/gf/extensions/network/contracts/gf_network_contract.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNetworkContract: 网络消息契约集合。 契约集合用于集中描述一组 GFNetworkMessage 的 message_type、字段和默认通道， 方便项目生成强类型辅助代码或在运行前校验消息结构。

### Properties

#### `contract_id`

- API: `public`

```gdscript
var contract_id: StringName = &""
```

契约稳定标识。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

编辑器展示名称。

#### `messages`

- API: `public`

```gdscript
var messages: Array[GFNetworkContractMessage] = []
```

消息契约列表。

Schemas:

- `messages`: Array[GFNetworkContractMessage]，按声明顺序保存消息契约。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，保存项目自定义契约元数据。

### Methods

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取展示名称。

Returns: 展示名称。

#### `set_message_contract`

- API: `public`

```gdscript
func set_message_contract(message_contract: GFNetworkContractMessage) -> void:
```

设置或替换一个消息契约。

Parameters:

| Name | Description |
|---|---|
| `message_contract` | 消息契约。 |

#### `get_message_contract`

- API: `public`

```gdscript
func get_message_contract(message_type: StringName) -> GFNetworkContractMessage:
```

获取消息契约。

Parameters:

| Name | Description |
|---|---|
| `message_type` | 消息类型。 |

Returns: 消息契约；不存在时返回 null。

#### `has_message_contract`

- API: `public`

```gdscript
func has_message_contract(message_type: StringName) -> bool:
```

检查消息契约是否存在。

Parameters:

| Name | Description |
|---|---|
| `message_type` | 消息类型。 |

Returns: 存在返回 true。

#### `make_message`

- API: `public`

```gdscript
func make_message(message_type: StringName, values: Dictionary = {}, options: Dictionary = {}) -> GFNetworkMessage:
```

按消息契约创建 GFNetworkMessage。

Parameters:

| Name | Description |
|---|---|
| `message_type` | 消息类型。 |
| `values` | 字段值字典。 |
| `options` | 可选元信息。 |

Returns: 网络消息；契约不存在时返回 null。

Schemas:

- `values`: Dictionary[StringName|String, Variant]，字段名到字段值的映射。
- `options`: Dictionary，支持 include_defaults、sequence、tick、sender_id、channel_id。

#### `validate_message`

- API: `public`

```gdscript
func validate_message(message: GFNetworkMessage) -> Dictionary:
```

校验网络消息是否匹配本契约集合。

Parameters:

| Name | Description |
|---|---|
| `message` | 网络消息。 |

Returns: 校验报告字典。

Schemas:

- `return`: Dictionary，GFValidationReportDictionary 格式，包含 ok、issues、issue_count 和 next_actions。

#### `validate_contract`

- API: `public`

```gdscript
func validate_contract() -> Dictionary:
```

校验契约定义是否完整。

Returns: 校验报告字典。

Schemas:

- `return`: Dictionary，GFValidationReportDictionary 格式，包含 ok、issues、issue_count 和 next_actions。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

描述契约集合。

Returns: 描述字典。

Schemas:

- `return`: Dictionary，包含 contract_id、display_name、message_count、messages、metadata。

## GFNetworkContractField

- Path: `addons/gf/extensions/network/contracts/gf_network_contract_field.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNetworkContractField: 网络契约中的单个 payload 字段。 字段只描述名称、值类型、必填性和默认值，用于生成器、校验器或项目工具， 不规定消息含义、权限或同步策略。

### Enums

#### `ValueType`

- API: `public`

```gdscript
enum ValueType { ## 任意 Variant。 VARIANT, ## 布尔值。 BOOL, ## 整数。 INT, ## 浮点数。 FLOAT, ## 字符串。 STRING, ## StringName。 STRING_NAME, ## Vector2。 VECTOR2, ## Vector3。 VECTOR3, ## Vector2i。 VECTOR2I, ## Vector3i。 VECTOR3I, ## Color。 COLOR, ## Dictionary。 DICTIONARY, ## Array。 ARRAY, ## NodePath。 NODE_PATH, ## Object 或 Resource。 OBJECT, }
```

字段值类型。

### Properties

#### `field_name`

- API: `public`

```gdscript
var field_name: StringName = &""
```

字段稳定名称。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

编辑器展示名称。

#### `value_type`

- API: `public`

```gdscript
var value_type: ValueType = ValueType.VARIANT
```

字段值类型。

#### `required`

- API: `public`

```gdscript
var required: bool = true
```

是否为必填字段。

#### `allow_null`

- API: `public`

```gdscript
var allow_null: bool = false
```

是否允许显式 null 值。

#### `default_value`

- API: `public`

```gdscript
var default_value: Variant = null
```

可选默认值。生成器会尽量把可表达的默认值写入生成函数签名。

Schemas:

- `default_value`: Variant，字段默认值；建议使用与 value_type 匹配的可复制值。

#### `class_name_hint`

- API: `public`

```gdscript
var class_name_hint: StringName = &""
```

Object / Resource 字段的类名提示，仅用于工具校验。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，保存项目自定义字段元数据。

### Methods

#### `get_field_name`

- API: `public`

```gdscript
func get_field_name() -> StringName:
```

获取字段名称。

Returns: 字段名称。

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取展示名称。

Returns: 展示名称。

#### `get_default_value`

- API: `public`

```gdscript
func get_default_value() -> Variant:
```

获取默认值副本。

Returns: 默认值。

Schemas:

- `return`: Variant，default_value 的深拷贝或原始标量值。

#### `normalize_value`

- API: `public`

```gdscript
func normalize_value(value: Variant) -> Variant:
```

归一化字段值。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |

Returns: 归一化后的值。

Schemas:

- `value`: Variant，待归一化字段值。
- `return`: Variant，字段默认值或输入值的安全副本。

#### `validate_definition`

- API: `public`

```gdscript
func validate_definition() -> Dictionary:
```

校验字段定义是否完整。

Returns: 校验报告字典。

Schemas:

- `return`: Dictionary，GFValidationReportDictionary 格式，包含 ok、issues、issue_count 和 next_actions。

#### `validate_value`

- API: `public`

```gdscript
func validate_value(value: Variant) -> Dictionary:
```

校验字段值是否符合声明类型。

Parameters:

| Name | Description |
|---|---|
| `value` | 字段值。 |

Returns: 校验报告字典。

Schemas:

- `value`: Variant，待校验字段值。
- `return`: Dictionary，GFValidationReportDictionary 格式，包含 ok、issues、issue_count 和 next_actions。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

描述字段契约。

Returns: 描述字典。

Schemas:

- `return`: Dictionary，包含 field_name、display_name、value_type、required、allow_null、default_value、class_name_hint、metadata。

## GFNetworkContractGenerator

- Path: `addons/gf/extensions/network/editor/gf_network_contract_generator.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFNetworkContractGenerator: 根据 GFNetworkContract 生成强类型消息辅助脚本。 生成结果保持为 GDScript 轻量封装，围绕 GFNetworkMessage / GFNetworkUtility 提供构造、发送、匹配和 payload 读取函数，不绑定任何具体业务协议。

### Constants

#### `DEFAULT_OUTPUT_DIR`

- API: `public`

```gdscript
const DEFAULT_OUTPUT_DIR: String = "res://gf/generated/network"
```

默认生成脚本输出目录。

### Methods

#### `generate`

- API: `public`

```gdscript
func generate( contract: GFNetworkContract, output_path: String = "", overwrite_existing: bool = true, options: Dictionary = {} ) -> Error:
```

生成单个契约访问器脚本。

Parameters:

| Name | Description |
|---|---|
| `contract` | 网络契约资源。 |
| `output_path` | 输出脚本路径；为空时按 contract_id 推导。 |
| `overwrite_existing` | 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。 |
| `options` | 可选项，支持 class_name。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，支持 class_name。

#### `generate_many`

- API: `public`

```gdscript
func generate_many( contract_paths: PackedStringArray, output_dir: String = DEFAULT_OUTPUT_DIR, overwrite_existing: bool = true, options: Dictionary = {} ) -> Dictionary:
```

批量生成多个契约访问器脚本。

Parameters:

| Name | Description |
|---|---|
| `contract_paths` | 契约资源路径列表。 |
| `output_dir` | 输出目录。 |
| `overwrite_existing` | 为 false 时目标已存在会跳过。 |
| `options` | 可选项。 |

Returns: 生成报告。

Schemas:

- `options`: Dictionary，支持 class_name。
- `return`: Dictionary，GFValidationReportDictionary 格式，包含 ok、generated_count、attempted_count、generated、issues、issue_count 和 next_actions。

#### `build_source`

- API: `public`

```gdscript
func build_source(contract: GFNetworkContract, options: Dictionary = {}) -> String:
```

构建契约访问器源码。测试或项目工具可直接调用该方法。

Parameters:

| Name | Description |
|---|---|
| `contract` | 网络契约资源。 |
| `options` | 可选项，支持 class_name。 |

Returns: GDScript 源码。

Schemas:

- `options`: Dictionary，支持 class_name。

#### `save_source`

- API: `public`

```gdscript
func save_source(output_path: String, source: String, overwrite_existing: bool = true) -> Error:
```

保存生成源码到指定路径。

Parameters:

| Name | Description |
|---|---|
| `output_path` | 输出脚本路径。 |
| `source` | 源码文本。 |
| `overwrite_existing` | 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。 |

Returns: Godot 错误码。

## GFNetworkContractMessage

- Path: `addons/gf/extensions/network/contracts/gf_network_contract_message.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNetworkContractMessage: 网络契约中的单个消息定义。 消息定义描述 message_type、默认通道和 payload 字段集合，可用于构造、 校验和生成强类型辅助函数。

### Properties

#### `message_type`

- API: `public`

```gdscript
var message_type: StringName = &""
```

消息类型标识。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

编辑器展示名称。

#### `channel_id`

- API: `public`

```gdscript
var channel_id: StringName = &""
```

默认逻辑通道。为空时发送时不强制通道。

#### `fields`

- API: `public`

```gdscript
var fields: Array[GFNetworkContractField] = []
```

payload 字段定义。

Schemas:

- `fields`: Array[GFNetworkContractField]，按声明顺序保存 payload 字段定义。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，保存项目自定义消息元数据。

### Methods

#### `get_message_type`

- API: `public`

```gdscript
func get_message_type() -> StringName:
```

获取消息类型。

Returns: 消息类型。

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取展示名称。

Returns: 展示名称。

#### `get_field`

- API: `public`

```gdscript
func get_field(target_field_name: StringName) -> GFNetworkContractField:
```

查找字段定义。

Parameters:

| Name | Description |
|---|---|
| `target_field_name` | 字段名称。 |

Returns: 字段定义；不存在时返回 null。

#### `build_payload`

- API: `public`

```gdscript
func build_payload(values: Dictionary = {}, options: Dictionary = {}) -> Dictionary:
```

构建 payload 字典。

Parameters:

| Name | Description |
|---|---|
| `values` | 字段值字典，可使用 StringName 或 String 作为键。 |
| `options` | 可选项，支持 include_defaults。 |

Returns: payload 字典。

Schemas:

- `values`: Dictionary[StringName|String, Variant]，字段名到字段值的映射。
- `options`: Dictionary，支持 include_defaults。
- `return`: Dictionary[StringName, Variant]，按字段契约归一化后的 payload。

#### `make_message`

- API: `public`

```gdscript
func make_message(values: Dictionary = {}, options: Dictionary = {}) -> GFNetworkMessage:
```

构建 GFNetworkMessage。

Parameters:

| Name | Description |
|---|---|
| `values` | 字段值字典。 |
| `options` | 可选元信息，支持 sequence、tick、sender_id、channel_id。 |

Returns: 网络消息。

Schemas:

- `values`: Dictionary[StringName|String, Variant]，字段名到字段值的映射。
- `options`: Dictionary，支持 include_defaults、sequence、tick、sender_id、channel_id。

#### `validate_definition`

- API: `public`

```gdscript
func validate_definition() -> Dictionary:
```

校验消息定义是否完整。

Returns: 校验报告字典。

Schemas:

- `return`: Dictionary，GFValidationReportDictionary 格式，包含 ok、issues、issue_count 和 next_actions。

#### `validate_payload`

- API: `public`

```gdscript
func validate_payload(payload: Dictionary) -> Dictionary:
```

校验 payload 是否符合字段契约。

Parameters:

| Name | Description |
|---|---|
| `payload` | payload 字典。 |

Returns: 校验报告字典。

Schemas:

- `payload`: Dictionary[StringName|String, Variant]，待校验 payload 字段值。
- `return`: Dictionary，GFValidationReportDictionary 格式，包含 ok、issues、issue_count 和 next_actions。

#### `validate_message`

- API: `public`

```gdscript
func validate_message(message: GFNetworkMessage) -> Dictionary:
```

校验 GFNetworkMessage 是否匹配该消息契约。

Parameters:

| Name | Description |
|---|---|
| `message` | 网络消息。 |

Returns: 校验报告字典。

Schemas:

- `return`: Dictionary，GFValidationReportDictionary 格式，包含 ok、issues、issue_count 和 next_actions。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

描述消息契约。

Returns: 描述字典。

Schemas:

- `return`: Dictionary，包含 message_type、display_name、channel_id、field_count、fields、metadata。

## GFNetworkFieldSerializer

- Path: `addons/gf/extensions/network/serialization/gf_network_field_serializer.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNetworkFieldSerializer: 网络状态字段编码器。 将常见 Godot 值归一化为可序列化 Variant。它只处理字段值的形态转换， 不规定同步方向、可靠性、预测、回滚或冲突解决策略。

### Enums

#### `ValueType`

- API: `public`

```gdscript
enum ValueType { ## 保持原始 Variant。 VARIANT, ## 布尔值。 BOOL, ## 整数。 INT, ## 浮点数。 FLOAT, ## 字符串。 STRING, ## StringName，编码时使用 String。 STRING_NAME, ## Vector2，编码为两个数值。 VECTOR2, ## Vector3，编码为三个数值。 VECTOR3, ## Vector2i，编码为两个整数。 VECTOR2I, ## Vector3i，编码为三个整数。 VECTOR3I, ## Color，编码为四个数值。 COLOR, }
```

字段值类型。

### Properties

#### `value_type`

- API: `public`

```gdscript
var value_type: ValueType = ValueType.VARIANT
```

字段值类型。

#### `quantize_decimals`

- API: `public`

```gdscript
var quantize_decimals: int = -1
```

浮点量化小数位；小于 0 表示不量化。

#### `clamp_enabled`

- API: `public`

```gdscript
var clamp_enabled: bool = false
```

是否夹取数值。

#### `min_value`

- API: `public`

```gdscript
var min_value: float = 0.0
```

数值夹取下限。

#### `max_value`

- API: `public`

```gdscript
var max_value: float = 1.0
```

数值夹取上限。

### Methods

#### `serialize_value`

- API: `public`

```gdscript
func serialize_value(value: Variant) -> Variant:
```

编码字段值。

Parameters:

| Name | Description |
|---|---|
| `value` | 原始值。 |

Returns: 可序列化值。

Schemas:

- `value`: Variant，原始字段值。
- `return`: Variant，可序列化字段值；向量和颜色会编码为 Array。

#### `deserialize_value`

- API: `public`

```gdscript
func deserialize_value(value: Variant) -> Variant:
```

解码字段值。

Parameters:

| Name | Description |
|---|---|
| `value` | 编码值。 |

Returns: 解码后的值。

Schemas:

- `value`: Variant，serialize_value() 产生的编码值或兼容输入。
- `return`: Variant，按 value_type 解码后的字段值。

#### `duplicate_serializer`

- API: `public`

```gdscript
func duplicate_serializer() -> GFNetworkFieldSerializer:
```

复制编码器配置。

Returns: 新编码器。

## GFNetworkHistoryBuffer

- Path: `addons/gf/extensions/network/snapshot/gf_network_history_buffer.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFNetworkHistoryBuffer: 按 tick 保存网络快照的环形历史。 用于插值、重放、状态对账或项目自定义同步流程；不会自动执行预测、回滚或冲突解决。

### Properties

#### `capacity`

- API: `public`

```gdscript
var capacity: int = 120
```

最大保存快照数量。小于等于 0 表示不限制。

### Methods

#### `add_snapshot`

- API: `public`

```gdscript
func add_snapshot(snapshot: GFNetworkSnapshot) -> bool:
```

添加快照。

Parameters:

| Name | Description |
|---|---|
| `snapshot` | 快照。 |

Returns: 添加成功返回 true。

#### `add_state`

- API: `public`

```gdscript
func add_state( tick: int, state: Dictionary, peer_id: int = -1, metadata: Dictionary = {} ) -> GFNetworkSnapshot:
```

添加状态字典并返回生成的快照。

Parameters:

| Name | Description |
|---|---|
| `tick` | 快照 tick。 |
| `state` | 状态字典。 |
| `peer_id` | 来源 peer。 |
| `metadata` | 元数据。 |

Returns: 新快照。

Schemas:

- `state`: Dictionary[StringName|String, Variant]，保存项目自定义同步状态。
- `metadata`: Dictionary，保存项目自定义快照元数据。

#### `has_snapshot`

- API: `public`

```gdscript
func has_snapshot(tick: int) -> bool:
```

检查指定 tick 是否存在快照。

Parameters:

| Name | Description |
|---|---|
| `tick` | 快照 tick。 |

Returns: 存在返回 true。

#### `get_snapshot`

- API: `public`

```gdscript
func get_snapshot(tick: int) -> GFNetworkSnapshot:
```

获取指定 tick 的快照副本。

Parameters:

| Name | Description |
|---|---|
| `tick` | 快照 tick。 |

Returns: 快照副本；不存在时返回 null。

#### `get_latest_snapshot`

- API: `public`

```gdscript
func get_latest_snapshot() -> GFNetworkSnapshot:
```

获取最新快照副本。

Returns: 最新快照；不存在时返回 null。

#### `get_earliest_snapshot`

- API: `public`

```gdscript
func get_earliest_snapshot() -> GFNetworkSnapshot:
```

获取最早快照副本。

Returns: 最早快照；不存在时返回 null。

#### `get_closest_snapshot`

- API: `public`

```gdscript
func get_closest_snapshot(tick: int, prefer_older: bool = true) -> GFNetworkSnapshot:
```

获取最接近指定 tick 的快照副本。

Parameters:

| Name | Description |
|---|---|
| `tick` | 查询 tick。 |
| `prefer_older` | 距离相同时是否优先旧快照。 |

Returns: 快照副本；不存在时返回 null。

#### `get_snapshots_between`

- API: `public`

```gdscript
func get_snapshots_between( from_tick: int, to_tick: int, include_bounds: bool = true ) -> Array[GFNetworkSnapshot]:
```

获取指定 tick 范围内的快照副本。

Parameters:

| Name | Description |
|---|---|
| `from_tick` | 起始 tick。 |
| `to_tick` | 结束 tick。 |
| `include_bounds` | 是否包含边界 tick。 |

Returns: 按 tick 升序排列的快照副本。

Schemas:

- `return`: Array[GFNetworkSnapshot]，按 tick 升序排列的快照副本。

#### `get_surrounding_snapshots`

- API: `public`

```gdscript
func get_surrounding_snapshots(tick: int) -> Dictionary:
```

获取包围指定 tick 的快照副本。

Parameters:

| Name | Description |
|---|---|
| `tick` | 查询 tick。 |

Returns: 字典，包含 exact、previous、next 三个可选快照。

Schemas:

- `return`: Dictionary，包含 exact、previous、next，值为 GFNetworkSnapshot 或 null。

#### `get_ticks`

- API: `public`

```gdscript
func get_ticks() -> PackedInt64Array:
```

获取已保存 tick 列表。

Returns: tick 列表。

#### `prune_before`

- API: `public`

```gdscript
func prune_before(tick: int) -> int:
```

删除指定 tick 之前的快照。

Parameters:

| Name | Description |
|---|---|
| `tick` | 保留起点 tick。 |

Returns: 删除数量。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空历史。

#### `size`

- API: `public`

```gdscript
func size() -> int:
```

获取快照数量。

Returns: 快照数量。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 capacity、size、earliest_tick、latest_tick。

## GFNetworkMessage

- Path: `addons/gf/extensions/network/messages/gf_network_message.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFNetworkMessage: 通用网络消息载体。 只描述传输元信息和字典载荷，不绑定具体协议、后端或业务消息类型。

### Properties

#### `message_type`

- API: `public`

```gdscript
var message_type: StringName = &""
```

消息类型标识。

#### `sequence`

- API: `public`

```gdscript
var sequence: int = 0
```

发送端自增序号。

#### `tick`

- API: `public`

```gdscript
var tick: int = 0
```

逻辑 tick 或帧号。

#### `sender_id`

- API: `public`

```gdscript
var sender_id: int = -1
```

发送者标识。

#### `channel_id`

- API: `public`

```gdscript
var channel_id: StringName = &""
```

逻辑网络通道标识。为空时入站侧可按 message_type 匹配同名通道。

#### `payload`

- API: `public`

```gdscript
var payload: Dictionary = {}
```

消息载荷。

Schemas:

- `payload`: Dictionary[StringName|String, Variant]，保存消息业务载荷。

### Methods

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转为可序列化字典。

Returns: 字典载荷。

Schemas:

- `return`: Dictionary，包含 type、sequence、tick、sender_id、channel_id、payload。

#### `from_dict`

- API: `public`

```gdscript
func from_dict(data: Dictionary) -> void:
```

从字典恢复。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典载荷。 |

Schemas:

- `data`: Dictionary，包含 type、sequence、tick、sender_id、channel_id、payload。

## GFNetworkMessageValidator

- Path: `addons/gf/extensions/network/messages/gf_network_message_validator.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNetworkMessageValidator: 通用网络消息校验器。 校验消息类型、包体大小和可选必需载荷字段，避免后端收到明显无效数据。

### Constants

#### `DEFAULT_MAX_PACKET_SIZE`

- API: `public`

```gdscript
const DEFAULT_MAX_PACKET_SIZE: int = 64 * 1024
```

默认全局最大包体大小，单位 bytes。

### Properties

#### `allow_empty_message_type`

- API: `public`

```gdscript
var allow_empty_message_type: bool = false
```

是否允许空 message_type。

#### `min_packet_size`

- API: `public`

```gdscript
var min_packet_size: int = 1
```

最小包体大小。小于等于 0 表示不限制。

#### `max_packet_size`

- API: `public`

```gdscript
var max_packet_size: int = DEFAULT_MAX_PACKET_SIZE
```

最大包体大小。小于等于 0 表示不限制。

#### `required_payload_keys`

- API: `public`

```gdscript
var required_payload_keys: PackedStringArray = PackedStringArray()
```

所有消息都必须包含的 payload key。

### Methods

#### `validate_message`

- API: `public`

```gdscript
func validate_message(message: GFNetworkMessage) -> Dictionary:
```

校验消息对象。

Parameters:

| Name | Description |
|---|---|
| `message` | 消息。 |

Returns: 统一校验报告。

Schemas:

- `return`: Dictionary，包含 ok 和 errors。

#### `validate_bytes`

- API: `public`

```gdscript
func validate_bytes(bytes: PackedByteArray, channel: GFNetworkChannel = null) -> Dictionary:
```

校验原始包体。

Parameters:

| Name | Description |
|---|---|
| `bytes` | 包体。 |
| `channel` | 可选通道描述。 |

Returns: 统一校验报告。

Schemas:

- `return`: Dictionary，包含 ok 和 errors。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 校验器状态。

Schemas:

- `return`: Dictionary，包含 allow_empty_message_type、min_packet_size、max_packet_size、required_payload_keys。

## GFNetworkRateLimiter

- Path: `addons/gf/extensions/network/session/gf_network_rate_limiter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFNetworkRateLimiter: 通用令牌桶限流器。 可用于限制消息发送频率，避免某类同步或 RPC 过量发送。

### Properties

#### `capacity`

- API: `public`

```gdscript
var capacity: float = 10.0:
```

令牌桶容量。

#### `refill_per_second`

- API: `public`

```gdscript
var refill_per_second: float = 10.0:
```

每秒恢复令牌数。

### Methods

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

推进限流器时间。

Parameters:

| Name | Description |
|---|---|
| `delta` | 秒数。 |

#### `consume`

- API: `public`

```gdscript
func consume(amount: float = 1.0) -> bool:
```

尝试消费令牌。

Parameters:

| Name | Description |
|---|---|
| `amount` | 令牌数量。 |

Returns: 成功消费返回 true。

#### `get_tokens`

- API: `public`

```gdscript
func get_tokens() -> float:
```

获取当前令牌数。

Returns: 令牌数。

#### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置令牌桶。

## GFNetworkReconnectPolicy

- Path: `addons/gf/extensions/network/session/gf_network_reconnect_policy.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFNetworkReconnectPolicy: 通用重连退避策略。 记录重连尝试次数，并按预设延迟序列返回下一次等待时间。它不依赖具体网络后端。

### Properties

#### `delays_msec`

- API: `public`

```gdscript
var delays_msec: Array[int] = [500, 1000, 2000, 5000]
```

重连延迟序列，单位毫秒。

Schemas:

- `delays_msec`: Array[int]，按尝试次数索引的重连延迟毫秒数。

#### `max_attempts`

- API: `public`

```gdscript
var max_attempts: int = 0
```

最大尝试次数。小于等于 0 表示无限尝试。

#### `jitter_ratio`

- API: `public`

```gdscript
var jitter_ratio: float = 0.0:
```

抖动比例。0 表示不抖动，0.2 表示在 ±20% 内随机偏移。

### Methods

#### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置尝试计数。

#### `has_attempts_remaining`

- API: `public`

```gdscript
func has_attempts_remaining() -> bool:
```

检查是否还允许继续尝试。

Returns: 允许返回 true。

#### `get_next_delay_msec`

- API: `public`

```gdscript
func get_next_delay_msec() -> int:
```

记录一次失败并返回下一次等待时长。

Returns: 下一次等待时长；没有尝试空间时返回 -1。

#### `record_success`

- API: `public`

```gdscript
func record_success() -> void:
```

记录一次成功并清空尝试计数。

#### `get_attempt_count`

- API: `public`

```gdscript
func get_attempt_count() -> int:
```

获取已经消费的失败尝试次数。

Returns: 尝试次数。

## GFNetworkSerializer

- Path: `addons/gf/extensions/network/serialization/gf_network_serializer.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNetworkSerializer: 通用网络消息编码器。 提供 Variant 二进制与 JSON 两种编码方式，供不同网络后端复用。

### Enums

#### `Format`

- API: `public`

```gdscript
enum Format { ## Godot Variant 二进制编码。 BINARY, ## UTF-8 JSON 编码。 JSON, }
```

消息编码格式。

### Properties

#### `format`

- API: `public`

```gdscript
var format: Format = Format.BINARY
```

默认编码格式。

#### `use_typed_json_codec`

- API: `public`

```gdscript
var use_typed_json_codec: bool = false
```

JSON 格式下是否使用 GFVariantJsonCodec 的类型化 Godot Variant 编码。

#### `json_codec_options`

- API: `public`

```gdscript
var json_codec_options: Dictionary = {}
```

传给 GFVariantJsonCodec JSON codec 的可选配置。

Schemas:

- `json_codec_options`: Dictionary，传给 GFVariantJsonCodec 的 JSON 编码/解码选项。

### Methods

#### `serialize_message`

- API: `public`

```gdscript
func serialize_message(message: GFNetworkMessage) -> PackedByteArray:
```

编码消息。

Parameters:

| Name | Description |
|---|---|
| `message` | 消息载体。 |

Returns: 字节数组。

#### `deserialize_message`

- API: `public`

```gdscript
func deserialize_message(bytes: PackedByteArray) -> GFNetworkMessage:
```

解码消息。

Parameters:

| Name | Description |
|---|---|
| `bytes` | 源 bytes。 |

Returns: 消息载体；失败时返回 null。

#### `deserialize_message_result`

- API: `public`

```gdscript
func deserialize_message_result(bytes: PackedByteArray) -> Dictionary:
```

解码消息并返回结果字典。

Parameters:

| Name | Description |
|---|---|
| `bytes` | 源 bytes。 |

Returns: 包含 ok、data、error 的结果字典。

Schemas:

- `return`: Dictionary，包含 ok、data、error；data 为 GFNetworkMessage 或空字典。

#### `serialize_dictionary`

- API: `public`

```gdscript
func serialize_dictionary(data: Dictionary) -> PackedByteArray:
```

编码字典。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典。 |

Returns: 字节数组。

Schemas:

- `data`: Dictionary，待编码的消息或项目自定义字典。

#### `deserialize_dictionary_result`

- API: `public`

```gdscript
func deserialize_dictionary_result(bytes: PackedByteArray) -> Dictionary:
```

解码字典并返回结果字典。

Parameters:

| Name | Description |
|---|---|
| `bytes` | 源 bytes。 |

Returns: 包含 ok、data、error 的结果字典；合法空字典会返回 ok=true。

Schemas:

- `return`: Dictionary，包含 ok、data、error；data 为解码后的 Dictionary。

## GFNetworkSession

- Path: `addons/gf/extensions/network/session/gf_network_session.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFNetworkSession: 网络会话状态快照。 记录当前网络工具的主机/客户端意图与连接状态，不绑定房间、账号或匹配逻辑。

### Signals

#### `session_started`

- API: `public`

```gdscript
signal session_started(mode: int, endpoint: String)
```

会话开始时发出。

Parameters:

| Name | Description |
|---|---|
| `mode` | Mode 枚举值。 |
| `endpoint` | 会话端点。 |

#### `session_connected`

- API: `public`

```gdscript
signal session_connected(local_peer_id: int)
```

会话连接成功时发出。

Parameters:

| Name | Description |
|---|---|
| `local_peer_id` | 本地 peer 标识。 |

#### `session_closed`

- API: `public`

```gdscript
signal session_closed(reason: String)
```

会话关闭时发出。

Parameters:

| Name | Description |
|---|---|
| `reason` | 关闭原因。 |

### Enums

#### `Mode`

- API: `public`

```gdscript
enum Mode { ## 无活动会话。 NONE, ## 主机会话。 HOST, ## 客户端会话。 CLIENT, }
```

会话模式。

### Properties

#### `mode`

- API: `public`

```gdscript
var mode: Mode = Mode.NONE
```

当前模式。

#### `endpoint`

- API: `public`

```gdscript
var endpoint: String = ""
```

会话端点。

#### `local_peer_id`

- API: `public`

```gdscript
var local_peer_id: int = -1
```

本地 peer 标识。

#### `max_peers`

- API: `public`

```gdscript
var max_peers: int = 0
```

最大远端数量。

#### `is_active`

- API: `public`

```gdscript
var is_active: bool = false
```

会话是否已经启动。

#### `is_connected`

- API: `public`

```gdscript
var is_connected: bool = false
```

后端是否已报告连接成功。

#### `started_at_unix`

- API: `public`

```gdscript
var started_at_unix: float = 0.0
```

启动时间。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: Dictionary，保存项目自定义会话元数据。

### Methods

#### `start_host`

- API: `public`

```gdscript
func start_host(options: Dictionary = {}) -> void:
```

标记主机会话已开始。

Parameters:

| Name | Description |
|---|---|
| `options` | 启动选项。 |

Schemas:

- `options`: Dictionary，支持 endpoint、port、max_clients、max_peers、local_peer_id、metadata。

#### `start_client`

- API: `public`

```gdscript
func start_client(next_endpoint: String, options: Dictionary = {}) -> void:
```

标记客户端会话已开始。

Parameters:

| Name | Description |
|---|---|
| `next_endpoint` | 远端端点。 |
| `options` | 连接选项。 |

Schemas:

- `options`: Dictionary，支持 max_peers、local_peer_id、metadata。

#### `mark_connected`

- API: `public`

```gdscript
func mark_connected(next_local_peer_id: int = -1) -> void:
```

标记后端已经连接。

Parameters:

| Name | Description |
|---|---|
| `next_local_peer_id` | 本地 peer；小于 0 时保留原值。 |

#### `close`

- API: `public`

```gdscript
func close(reason: String = "closed") -> void:
```

关闭会话。

Parameters:

| Name | Description |
|---|---|
| `reason` | 关闭原因。 |

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 会话状态字典。

Schemas:

- `return`: Dictionary，包含 mode、mode_name、endpoint、local_peer_id、max_peers、is_active、is_connected、started_at_unix、metadata。

## GFNetworkSnapshot

- Path: `addons/gf/extensions/network/snapshot/gf_network_snapshot.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFNetworkSnapshot: 通用网络状态快照。 保存 tick、peer_id、纯字典状态和元数据，可用于同步、回放、插值或项目自定义差量流程。

### Properties

#### `tick`

- API: `public`

```gdscript
var tick: int = 0
```

快照所属 tick。

#### `peer_id`

- API: `public`

```gdscript
var peer_id: int = -1
```

快照来源 peer；-1 表示未指定。

#### `state`

- API: `public`

```gdscript
var state: Dictionary = {}
```

快照状态字典。

Schemas:

- `state`: Dictionary[StringName|String, Variant]，保存项目自定义同步状态。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: Dictionary，保存项目自定义快照元数据。

### Methods

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转为字典。

Returns: 快照字典。

Schemas:

- `return`: Dictionary，包含 tick、peer_id、state、metadata。

#### `from_dict`

- API: `public`

```gdscript
func from_dict(data: Dictionary) -> void:
```

从字典恢复。

Parameters:

| Name | Description |
|---|---|
| `data` | 快照字典。 |

Schemas:

- `data`: Dictionary，包含 tick、peer_id、state、metadata。

#### `duplicate_snapshot`

- API: `public`

```gdscript
func duplicate_snapshot() -> GFNetworkSnapshot:
```

复制快照。

Returns: 新快照。

#### `has_value`

- API: `public`

```gdscript
func has_value(key: StringName) -> bool:
```

检查状态字段是否存在。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段名。 |

Returns: 存在返回 true。

#### `get_value`

- API: `public`

```gdscript
func get_value(key: StringName, default_value: Variant = null) -> Variant:
```

读取状态字段。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段名。 |
| `default_value` | 缺失时返回的默认值。 |

Returns: 字段值。

Schemas:

- `default_value`: Variant，状态字段缺失时返回的默认值。
- `return`: Variant，字段值或 default_value。

#### `set_value`

- API: `public`

```gdscript
func set_value(key: StringName, value: Variant) -> void:
```

设置状态字段。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段名。 |
| `value` | 字段值。 |

Schemas:

- `value`: Variant，字段值，会通过 GFVariantData.duplicate_variant() 复制后保存。

#### `erase_value`

- API: `public`

```gdscript
func erase_value(key: StringName) -> void:
```

删除状态字段。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段名。 |

#### `make_delta_to`

- API: `public`

```gdscript
func make_delta_to(target: GFNetworkSnapshot) -> Dictionary:
```

生成当前快照到目标快照的浅层差量。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标快照。 |

Returns: 差量字典。

Schemas:

- `return`: Dictionary，成功时包含 ok、from_tick、to_tick、peer_id、set、erase、metadata；失败时包含 ok、error。

#### `apply_delta`

- API: `public`

```gdscript
func apply_delta(delta: Dictionary) -> GFNetworkSnapshot:
```

应用浅层差量并返回新快照。

Parameters:

| Name | Description |
|---|---|
| `delta` | make_delta_to() 生成的差量字典。 |

Returns: 新快照。

Schemas:

- `delta`: Dictionary，make_delta_to() 返回的差量结构。

#### `make_message`

- API: `public`

```gdscript
func make_message(message_type: StringName = &"snapshot", channel_id: StringName = &"") -> GFNetworkMessage:
```

打包为网络消息。

Parameters:

| Name | Description |
|---|---|
| `message_type` | 消息类型。 |
| `channel_id` | 逻辑通道标识。 |

Returns: 网络消息。

## GFNetworkSnapshotSchema

- Path: `addons/gf/extensions/network/snapshot/gf_network_snapshot_schema.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNetworkSnapshotSchema: 网络快照字段编码表。 用字段级编码器转换快照 state，适合项目在自己的同步、回放或存储流程中 统一压缩、量化和恢复状态字段。

### Properties

#### `include_unregistered_fields`

- API: `public`

```gdscript
var include_unregistered_fields: bool = true
```

未注册字段是否原样保留。

#### `field_serializers`

- API: `public`

```gdscript
var field_serializers: Dictionary = {}
```

字段编码器表。Key 推荐使用 StringName 或 String，Value 为 GFNetworkFieldSerializer。

Schemas:

- `field_serializers`: Dictionary[StringName|String, GFNetworkFieldSerializer]，字段名到字段编码器的映射。

### Methods

#### `set_field_serializer`

- API: `public`

```gdscript
func set_field_serializer(field_name: StringName, serializer: GFNetworkFieldSerializer) -> void:
```

设置字段编码器。

Parameters:

| Name | Description |
|---|---|
| `field_name` | 字段名。 |
| `serializer` | 字段编码器；为空时移除。 |

#### `remove_field_serializer`

- API: `public`

```gdscript
func remove_field_serializer(field_name: StringName) -> void:
```

移除字段编码器。

Parameters:

| Name | Description |
|---|---|
| `field_name` | 字段名。 |

#### `get_field_serializer`

- API: `public`

```gdscript
func get_field_serializer(field_name: StringName) -> GFNetworkFieldSerializer:
```

获取字段编码器。

Parameters:

| Name | Description |
|---|---|
| `field_name` | 字段名。 |

Returns: 字段编码器；不存在时返回 null。

#### `has_field_serializer`

- API: `public`

```gdscript
func has_field_serializer(field_name: StringName) -> bool:
```

检查字段是否注册了编码器。

Parameters:

| Name | Description |
|---|---|
| `field_name` | 字段名。 |

Returns: 已注册时返回 true。

#### `get_registered_fields`

- API: `public`

```gdscript
func get_registered_fields() -> PackedStringArray:
```

获取已注册字段名。

Returns: 字段名列表。

#### `encode_state`

- API: `public`

```gdscript
func encode_state(state: Dictionary) -> Dictionary:
```

编码状态字典。

Parameters:

| Name | Description |
|---|---|
| `state` | 原始状态。 |

Returns: 编码后的状态。

Schemas:

- `state`: Dictionary[StringName|String, Variant]，原始快照状态字段。
- `return`: Dictionary[StringName|String, Variant]，编码后的状态字段。

#### `decode_state`

- API: `public`

```gdscript
func decode_state(encoded_state: Dictionary) -> Dictionary:
```

解码状态字典。

Parameters:

| Name | Description |
|---|---|
| `encoded_state` | 编码后的状态。 |

Returns: 解码后的状态。

Schemas:

- `encoded_state`: Dictionary[StringName|String, Variant]，编码后的状态字段。
- `return`: Dictionary[StringName|String, Variant]，解码后的状态字段。

#### `encode_snapshot`

- API: `public`

```gdscript
func encode_snapshot(snapshot: GFNetworkSnapshot) -> Dictionary:
```

编码快照。

Parameters:

| Name | Description |
|---|---|
| `snapshot` | 原始快照。 |

Returns: 快照字典；snapshot 为空时返回空字典。

Schemas:

- `return`: Dictionary，GFNetworkSnapshot.to_dict() 结构，其中 state 已按字段编码器转换。

#### `decode_snapshot`

- API: `public`

```gdscript
func decode_snapshot(data: Dictionary) -> GFNetworkSnapshot:
```

解码快照。

Parameters:

| Name | Description |
|---|---|
| `data` | encode_snapshot() 或 GFNetworkSnapshot.to_dict() 形式的字典。 |

Returns: 解码后的快照。

Schemas:

- `data`: Dictionary，encode_snapshot() 或 GFNetworkSnapshot.to_dict() 结构。

#### `duplicate_schema`

- API: `public`

```gdscript
func duplicate_schema() -> GFNetworkSnapshotSchema:
```

复制 Schema 配置。

Returns: 新 Schema。

## GFNetworkUtility

- Path: `addons/gf/extensions/network/runtime/gf_network_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFNetworkUtility: 可插拔网络后端运行时。 负责把通用 GFNetworkMessage 编码后交给后端发送，并将后端收到的 bytes 解码为消息信号。

### Signals

#### `message_received`

- API: `public`

```gdscript
signal message_received(peer_id: int, message: GFNetworkMessage)
```

收到消息后发出。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 发送方 peer 标识。 |
| `message` | 解码后的网络消息。 |

#### `message_rejected`

- API: `public`

```gdscript
signal message_rejected(peer_id: int, reason: String, details: Dictionary)
```

消息校验失败后发出。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 关联 peer 标识。 |
| `reason` | 拒绝原因。 |
| `details` | 校验或解码详情。 |

Schemas:

- `details`: Dictionary，包含 ok、errors 或 error/data 等诊断字段。

#### `connected`

- API: `public`

```gdscript
signal connected
```

后端连接成功后发出。

#### `disconnected`

- API: `public`

```gdscript
signal disconnected(reason: String)
```

后端断开后发出。

Parameters:

| Name | Description |
|---|---|
| `reason` | 断开原因。 |

#### `peer_connected`

- API: `public`

```gdscript
signal peer_connected(peer_id: int)
```

远端节点连接后发出。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 远端 peer 标识。 |

#### `peer_disconnected`

- API: `public`

```gdscript
signal peer_disconnected(peer_id: int)
```

远端节点断开后发出。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 远端 peer 标识。 |

### Properties

#### `backend`

- API: `public`

```gdscript
var backend: GFNetworkBackend
```

当前网络后端。

#### `serializer`

- API: `public`

```gdscript
var serializer: GFNetworkSerializer = GFNetworkSerializer.new()
```

消息编码器。

#### `validator`

- API: `public`

```gdscript
var validator: GFNetworkMessageValidator = GFNetworkMessageValidator.new()
```

消息校验器。

#### `session`

- API: `public`

```gdscript
var session: GFNetworkSession = GFNetworkSession.new()
```

当前会话状态。

### Methods

#### `ready`

- API: `public`

```gdscript
func ready() -> void:
```

注册网络诊断快照贡献。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `delta` | 本帧时间增量（秒）。 |

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放后端、通道和诊断贡献。

#### `set_backend`

- API: `public`

```gdscript
func set_backend(next_backend: GFNetworkBackend) -> void:
```

设置网络后端。

Parameters:

| Name | Description |
|---|---|
| `next_backend` | 新后端。 |

#### `register_channel`

- API: `public`

```gdscript
func register_channel(channel: GFNetworkChannel) -> void:
```

注册网络通道。

Parameters:

| Name | Description |
|---|---|
| `channel` | 通道资源。 |

#### `unregister_channel`

- API: `public`

```gdscript
func unregister_channel(channel_id: StringName) -> void:
```

注销网络通道。

Parameters:

| Name | Description |
|---|---|
| `channel_id` | 通道标识。 |

#### `get_channel`

- API: `public`

```gdscript
func get_channel(channel_id: StringName) -> GFNetworkChannel:
```

获取网络通道。

Parameters:

| Name | Description |
|---|---|
| `channel_id` | 通道标识。 |

Returns: 通道资源。

#### `get_channel_ids`

- API: `public`

```gdscript
func get_channel_ids() -> PackedStringArray:
```

获取已注册通道标识。

Returns: 排序后的通道标识。

#### `clear_channels`

- API: `public`

```gdscript
func clear_channels() -> void:
```

清空网络通道。

#### `host`

- API: `public`

```gdscript
func host(options: Dictionary = {}) -> Error:
```

启动主机。

Parameters:

| Name | Description |
|---|---|
| `options` | 后端选项。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，传给 session.start_host() 和 backend.host() 的后端选项。

#### `connect_to_endpoint`

- API: `public`

```gdscript
func connect_to_endpoint(endpoint: String, options: Dictionary = {}) -> Error:
```

连接远端。

Parameters:

| Name | Description |
|---|---|
| `endpoint` | 远端地址。 |
| `options` | 后端选项。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，传给 session.start_client() 和 backend.connect_to_endpoint() 的后端选项。

#### `disconnect_network`

- API: `public`

```gdscript
func disconnect_network() -> void:
```

断开连接。

#### `send_message`

- API: `public`

```gdscript
func send_message(peer_id: int, message: GFNetworkMessage, options: Dictionary = {}) -> Error:
```

发送消息。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 目标 peer；后端可约定 -1 表示广播。 |
| `message` | 消息载体。 |
| `options` | 后端发送选项。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，传给 backend.send_bytes() 的发送选项。

#### `send_message_on_channel`

- API: `public`

```gdscript
func send_message_on_channel( peer_id: int, message: GFNetworkMessage, channel_id: StringName, options: Dictionary = {} ) -> Error:
```

通过指定通道发送消息。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 目标 peer；后端可约定 -1 表示广播。 |
| `message` | 消息载体。 |
| `channel_id` | 通道标识。 |
| `options` | 后端发送选项覆盖。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，覆盖 GFNetworkChannel.build_send_options() 的发送选项。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取网络工具调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 backend_configured、serializer_configured、validator_configured、backend、session、channels、validator。

## GFWebSocketNetworkBackend

- Path: `addons/gf/extensions/network/backends/gf_websocket_network_backend.gd`
- Extends: `GFNetworkBackend`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFWebSocketNetworkBackend: 基于 Godot WebSocketPeer 的网络后端。 只实现 GFNetworkBackend 的 bytes 传输边界，适合浏览器、原生客户端或工具链 之间复用同一套 GFNetworkMessage 序列化流程。

### Enums

#### `Mode`

- API: `public`

```gdscript
enum Mode { ## 未连接。 DISCONNECTED, ## 作为服务器监听 TCP 并接受 WebSocket 握手。 SERVER, ## 作为客户端连接远端 WebSocket 地址。 CLIENT, }
```

WebSocket 后端运行模式。

### Constants

#### `BROADCAST_PEER_ID`

- API: `public`

```gdscript
const BROADCAST_PEER_ID: int = -1
```

广播 peer 标识。

#### `SERVER_PEER_ID`

- API: `public`

```gdscript
const SERVER_PEER_ID: int = 1
```

客户端视角下远端服务器的 peer 标识。

### Properties

#### `max_accepts_per_poll`

- API: `public`

```gdscript
var max_accepts_per_poll: int = 16
```

每次 poll 最多接受的 TCP 连接数量。小于等于 0 表示不限制。

#### `max_packets_per_peer_per_poll`

- API: `public`

```gdscript
var max_packets_per_peer_per_poll: int = 64
```

每个 peer 每次 poll 最多派发的入站包数量。小于等于 0 表示不限制。

### Methods

#### `host`

- API: `public`

```gdscript
func host(options: Dictionary = {}) -> Error:
```

启动 WebSocket 主机。 支持 options: port, bind_address, supported_protocols。

Parameters:

| Name | Description |
|---|---|
| `options` | 操作选项字典。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，支持 port、bind_address、address、supported_protocols、inbound_buffer_size、outbound_buffer_size、max_queued_packets、no_delay。

#### `connect_to_endpoint`

- API: `public`

```gdscript
func connect_to_endpoint(endpoint: String, options: Dictionary = {}) -> Error:
```

连接 WebSocket 远端。 endpoint 应为 ws:// 或 wss:// URL。

Parameters:

| Name | Description |
|---|---|
| `endpoint` | WebSocket 地址。 |
| `options` | 操作选项字典，支持 tls_options、supported_protocols。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，支持 tls_options、supported_protocols、inbound_buffer_size、outbound_buffer_size、max_queued_packets、no_delay。

#### `disconnect_backend`

- API: `public`

```gdscript
func disconnect_backend() -> void:
```

断开 WebSocket 连接。

#### `send_bytes`

- API: `public`

```gdscript
func send_bytes(peer_id: int, bytes: PackedByteArray, _options: Dictionary = {}) -> Error:
```

发送 bytes。

Parameters:

| Name | Description |
|---|---|
| `peer_id` | 目标 peer；服务器模式下 -1 表示广播，客户端模式下可传 1 或 -1。 |
| `bytes` | 要发送的字节数据。 |
| `_options` | 操作选项字典。 |

Returns: Godot 错误码。

Schemas:

- `_options`: Dictionary，保留给后端自定义发送选项。

#### `poll`

- API: `public`

```gdscript
func poll(_delta: float) -> void:
```

轮询 WebSocket 连接、握手和收包。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 本帧时间增量（秒），默认实现不直接使用。 |

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取后端调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 backend、available、mode、mode_name、endpoint、peer_count、open_peer_count、client_state、max_accepts_per_poll、max_packets_per_peer_per_poll。

