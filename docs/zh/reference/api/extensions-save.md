# Save API

Module: `extensions/save`

## Classes

- [`GFNodeAnimationPlayerSerializer`](#gfnodeanimationplayerserializer)
- [`GFNodeAudioStreamPlayerSerializer`](#gfnodeaudiostreamplayerserializer)
- [`GFNodeCanvasItemSerializer`](#gfnodecanvasitemserializer)
- [`GFNodeControlSerializer`](#gfnodecontrolserializer)
- [`GFNodePropertySerializer`](#gfnodepropertyserializer)
- [`GFNodeRangeSerializer`](#gfnoderangeserializer)
- [`GFNodeSerializer`](#gfnodeserializer)
- [`GFNodeSerializerRegistry`](#gfnodeserializerregistry)
- [`GFNodeTimerSerializer`](#gfnodetimerserializer)
- [`GFNodeTransform2DSerializer`](#gfnodetransform2dserializer)
- [`GFNodeTransform3DSerializer`](#gfnodetransform3dserializer)
- [`GFSaveDataSource`](#gfsavedatasource)
- [`GFSaveEntityFactory`](#gfsaveentityfactory)
- [`GFSaveGraphUtility`](#gfsavegraphutility)
- [`GFSaveIdentity`](#gfsaveidentity)
- [`GFSavePipelineContext`](#gfsavepipelinecontext)
- [`GFSavePipelineEvent`](#gfsavepipelineevent)
- [`GFSavePipelineStep`](#gfsavepipelinestep)
- [`GFSaveScope`](#gfsavescope)
- [`GFSaveSlotCard`](#gfsaveslotcard)
- [`GFSaveSlotMetadata`](#gfsaveslotmetadata)
- [`GFSaveSlotWorkflow`](#gfsaveslotworkflow)
- [`GFSaveSource`](#gfsavesource)

## GFNodeAnimationPlayerSerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_animation_player_serializer.gd`
- Extends: `GFNodeSerializer`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodeAnimationPlayerSerializer: AnimationPlayer 通用播放状态序列化器。 保存当前动画、播放位置与速度缩放等通用播放状态，不保存动画资源内容。

### Methods

#### `supports_node`

- API: `public`

```gdscript
func supports_node(node: Node) -> bool:
```

判断序列化器是否支持指定节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

Returns: 节点是否为 AnimationPlayer。

#### `gather`

- API: `public`

```gdscript
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点的可保存状态。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: AnimationPlayer 播放状态载荷。

Schemas:

- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，可包含 current_animation、assigned_animation、current_animation_position、speed_scale、playing 与 active。

#### `apply`

- API: `public`

```gdscript
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

将序列化数据应用到节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `payload` | AnimationPlayer 播放状态载荷。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 应用结果字典。

Schemas:

- `payload`: Dictionary，可包含 current_animation、assigned_animation、current_animation_position、speed_scale、playing 与 active。
- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFNodeAudioStreamPlayerSerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_audio_stream_player_serializer.gd`
- Extends: `GFNodeSerializer`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodeAudioStreamPlayerSerializer: AudioStreamPlayer 通用播放状态序列化器。 支持 AudioStreamPlayer、AudioStreamPlayer2D 与 AudioStreamPlayer3D 的通用播放参数。

### Methods

#### `supports_node`

- API: `public`

```gdscript
func supports_node(node: Node) -> bool:
```

判断序列化器是否支持指定节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

Returns: 节点是否为 AudioStreamPlayer、AudioStreamPlayer2D 或 AudioStreamPlayer3D。

#### `gather`

- API: `public`

```gdscript
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点的可保存状态。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 音频播放状态载荷。

Schemas:

- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，可包含 playing、playback_position、stream_paused、volume_db、pitch_scale、bus、max_distance 与 attenuation。

#### `apply`

- API: `public`

```gdscript
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

将序列化数据应用到节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `payload` | 音频播放状态载荷。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 应用结果字典。

Schemas:

- `payload`: Dictionary，可包含 playing、playback_position、stream_paused、volume_db、pitch_scale、bus、max_distance 与 attenuation。
- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFNodeCanvasItemSerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_canvas_item_serializer.gd`
- Extends: `GFNodeSerializer`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodeCanvasItemSerializer: CanvasItem 通用显示状态序列化器。 保存可见性与颜色调制等通用表现状态，不保存具体业务字段。

### Methods

#### `supports_node`

- API: `public`

```gdscript
func supports_node(node: Node) -> bool:
```

判断序列化器是否支持指定节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

Returns: 节点是否为 CanvasItem。

#### `gather`

- API: `public`

```gdscript
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点的可保存状态。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: CanvasItem 显示状态载荷。

Schemas:

- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，可包含 visible、modulate、self_modulate、show_behind_parent、top_level、z_as_relative 与 z_index。

#### `apply`

- API: `public`

```gdscript
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

将序列化数据应用到节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `payload` | CanvasItem 显示状态载荷。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 应用结果字典。

Schemas:

- `payload`: Dictionary，可包含 visible、modulate、self_modulate、show_behind_parent、top_level、z_as_relative 与 z_index。
- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFNodeControlSerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_control_serializer.gd`
- Extends: `GFNodeSerializer`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodeControlSerializer: Control 通用布局状态序列化器。 保存 Control 的锚点、偏移、尺寸和交互开关，适合简单 UI 状态恢复。

### Methods

#### `supports_node`

- API: `public`

```gdscript
func supports_node(node: Node) -> bool:
```

判断序列化器是否支持指定节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

Returns: 节点是否为 Control。

#### `gather`

- API: `public`

```gdscript
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点的可保存状态。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: Control 布局状态载荷。

Schemas:

- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，可包含 anchor_*、offset_*、pivot_offset、rotation、scale、mouse_filter 与 focus_mode。

#### `apply`

- API: `public`

```gdscript
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

将序列化数据应用到节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `payload` | Control 布局状态载荷。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 应用结果字典。

Schemas:

- `payload`: Dictionary，可包含 anchor_*、offset_*、pivot_offset、rotation、scale、mouse_filter 与 focus_mode。
- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFNodePropertySerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_property_serializer.gd`
- Extends: `GFNodeSerializer`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodePropertySerializer: 通用节点属性序列化器。 通过显式属性白名单保存和恢复节点属性，适合项目层快速接入简单状态。

### Properties

#### `properties`

- API: `public`

```gdscript
var properties: PackedStringArray = PackedStringArray()
```

需要保存的属性名。

#### `skip_missing_properties`

- API: `public`

```gdscript
var skip_missing_properties: bool = true
```

应用数据时遇到缺失属性是否跳过。

### Methods

#### `gather`

- API: `public`

```gdscript
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点的可保存状态。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 属性载荷字典。

Schemas:

- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，键为 properties 中声明的属性名，值为 JSON 兼容值；Resource 引用使用 __gf_save_property__ 标记。

#### `apply`

- API: `public`

```gdscript
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

将序列化数据应用到节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `payload` | 属性载荷字典。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 应用结果字典。

Schemas:

- `payload`: Dictionary，键为属性名，值为 JSON 兼容值或 __gf_save_property__ 标记。
- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFNodeRangeSerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_range_serializer.gd`
- Extends: `GFNodeSerializer`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodeRangeSerializer: Range 通用数值状态序列化器。 保存滑条、进度条等 Range 派生控件的通用数值参数。

### Methods

#### `supports_node`

- API: `public`

```gdscript
func supports_node(node: Node) -> bool:
```

判断序列化器是否支持指定节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

Returns: 节点是否为 Range。

#### `gather`

- API: `public`

```gdscript
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点的可保存状态。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: Range 状态载荷。

Schemas:

- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，可包含 min_value、max_value、step、page、rounded、allow_greater、allow_lesser 与 value。

#### `apply`

- API: `public`

```gdscript
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

将序列化数据应用到节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `payload` | Range 状态载荷。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 应用结果字典。

Schemas:

- `payload`: Dictionary，可包含 min_value、max_value、step、page、rounded、allow_greater、allow_lesser 与 value。
- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFNodeSerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_serializer.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNodeSerializer: 节点序列化器基类。 用于把通用节点状态拆成可组合的序列化片段。具体项目可以继承该类， 在不修改存档图编排逻辑的前提下接入自己的节点状态。

### Properties

#### `serializer_id`

- API: `public`

```gdscript
var serializer_id: StringName = &""
```

序列化器稳定标识。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

编辑器展示名称。

#### `supported_class_name`

- API: `public`

```gdscript
var supported_class_name: String = ""
```

可选 Godot 类名过滤。为空时由子类自行判断。

### Methods

#### `get_serializer_id`

- API: `public`

```gdscript
func get_serializer_id() -> StringName:
```

获取序列化器标识。

Returns: 稳定标识。

#### `supports_node`

- API: `public`

```gdscript
func supports_node(node: Node) -> bool:
```

判断当前序列化器是否支持节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 待序列化节点。 |

Returns: 支持时返回 true。

#### `gather`

- API: `public`

```gdscript
func gather(_node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点数据。

Parameters:

| Name | Description |
|---|---|
| `_node` | 待序列化节点。 |
| `_context` | 调用上下文字典。 |

Returns: 可写入存档的字典。

Schemas:

- `_context`: Dictionary，调用方附加上下文；基础实现保留给子类扩展。
- `return`: Dictionary，当前序列化器写入存档的字段集合；空字典表示无需保存。

#### `apply`

- API: `public`

```gdscript
func apply(_node: Node, _payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

应用节点数据。

Parameters:

| Name | Description |
|---|---|
| `_node` | 目标节点。 |
| `_payload` | 当前序列化器的数据。 |
| `_context` | 调用上下文字典。 |

Returns: 结果字典。

Schemas:

- `_payload`: Dictionary，来自 gather() 的当前序列化器数据。
- `_context`: Dictionary，调用方附加上下文；基础实现保留给子类扩展。
- `return`: Dictionary，包含 ok: bool 与 error: String。

#### `make_result`

- API: `public`

```gdscript
func make_result(ok: bool, error: String = "") -> Dictionary:
```

构造统一结果。

Parameters:

| Name | Description |
|---|---|
| `ok` | 是否成功。 |
| `error` | 错误描述。 |

Returns: 结果字典。

Schemas:

- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFNodeSerializerRegistry

- Path: `addons/gf/extensions/save/serializers/gf_node_serializer_registry.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFNodeSerializerRegistry: 节点序列化器注册表。 负责按 serializer_id 管理序列化器，并为节点执行一组可组合的采集和应用。

### Methods

#### `register_serializer`

- API: `public`

```gdscript
func register_serializer(serializer: GFNodeSerializer) -> void:
```

注册序列化器。相同 id 会被后注册的实例覆盖。

Parameters:

| Name | Description |
|---|---|
| `serializer` | 序列化器。 |

#### `unregister_serializer`

- API: `public`

```gdscript
func unregister_serializer(serializer_id: StringName) -> void:
```

注销序列化器。

Parameters:

| Name | Description |
|---|---|
| `serializer_id` | 序列化器标识。 |

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空注册表。

#### `get_serializer`

- API: `public`

```gdscript
func get_serializer(serializer_id: StringName) -> GFNodeSerializer:
```

获取指定序列化器。

Parameters:

| Name | Description |
|---|---|
| `serializer_id` | 序列化器标识。 |

Returns: 序列化器实例。

#### `get_serializers_for_node`

- API: `public`

```gdscript
func get_serializers_for_node(node: Node) -> Array[GFNodeSerializer]:
```

获取所有支持指定节点的序列化器。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

Returns: 序列化器数组。

#### `gather_node`

- API: `public`

```gdscript
func gather_node(node: Node, context: Dictionary = {}) -> Array[Dictionary]:
```

采集节点上所有支持的默认序列化器数据。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `context` | 调用上下文字典。 |

Returns: 序列化片段数组。

Schemas:

- `context`: Dictionary，传递给各序列化器的调用上下文，可包含项目自定义字段。
- `return`: Array[Dictionary]，每项包含 id: StringName 与 data: Dictionary。

#### `apply_node`

- API: `public`

```gdscript
func apply_node(node: Node, serializer_payloads: Array, context: Dictionary = {}) -> Dictionary:
```

应用节点序列化片段。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `serializer_payloads` | 由 gather_node 返回的片段数组。 |
| `context` | 调用上下文字典。 |

Returns: 结果字典。

Schemas:

- `serializer_payloads`: Array[Dictionary]，每项包含 id: StringName 与 data: Dictionary。
- `context`: Dictionary，传递给各序列化器的调用上下文，可包含项目自定义字段。
- `return`: Dictionary，包含 ok: bool、applied: int 与 errors: Array[String]。

## GFNodeTimerSerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_timer_serializer.gd`
- Extends: `GFNodeSerializer`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodeTimerSerializer: Timer 通用状态序列化器。 保存 Timer 的等待时间、暂停、一次性和当前剩余时间等通用状态。

### Methods

#### `supports_node`

- API: `public`

```gdscript
func supports_node(node: Node) -> bool:
```

判断序列化器是否支持指定节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

Returns: 节点是否为 Timer。

#### `gather`

- API: `public`

```gdscript
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点的可保存状态。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: Timer 状态载荷。

Schemas:

- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，可包含 wait_time、one_shot、autostart、paused、time_left 与 stopped。

#### `apply`

- API: `public`

```gdscript
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

将序列化数据应用到节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `payload` | Timer 状态载荷。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 应用结果字典。

Schemas:

- `payload`: Dictionary，可包含 wait_time、one_shot、autostart、paused、time_left 与 stopped。
- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFNodeTransform2DSerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_transform_2d_serializer.gd`
- Extends: `GFNodeSerializer`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodeTransform2DSerializer: Node2D Transform 序列化器。 以 JSON 友好的标量数组保存 position、rotation 与 scale。

### Methods

#### `supports_node`

- API: `public`

```gdscript
func supports_node(node: Node) -> bool:
```

判断序列化器是否支持指定节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

Returns: 节点是否为 Node2D。

#### `gather`

- API: `public`

```gdscript
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点的可保存状态。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: Node2D transform 载荷。

Schemas:

- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，可包含 position: Array[float]、rotation: float、scale: Array[float] 与 z_index: int。

#### `apply`

- API: `public`

```gdscript
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

将序列化数据应用到节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `payload` | Node2D transform 载荷。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 应用结果字典。

Schemas:

- `payload`: Dictionary，可包含 position: Array[float]、rotation: float、scale: Array[float] 与 z_index: int。
- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFNodeTransform3DSerializer

- Path: `addons/gf/extensions/save/serializers/gf_node_transform_3d_serializer.gd`
- Extends: `GFNodeSerializer`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodeTransform3DSerializer: Node3D Transform 序列化器。 以 JSON 友好的标量数组保存 position、rotation 与 scale。

### Methods

#### `supports_node`

- API: `public`

```gdscript
func supports_node(node: Node) -> bool:
```

判断序列化器是否支持指定节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

Returns: 节点是否为 Node3D。

#### `gather`

- API: `public`

```gdscript
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
```

采集节点的可保存状态。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: Node3D transform 载荷。

Schemas:

- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，可包含 position: Array[float]、rotation: Array[float] 与 scale: Array[float]。

#### `apply`

- API: `public`

```gdscript
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
```

将序列化数据应用到节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |
| `payload` | Node3D transform 载荷。 |
| `_context` | 操作上下文字典，默认实现不直接使用。 |

Returns: 应用结果字典。

Schemas:

- `payload`: Dictionary，可包含 position: Array[float]、rotation: Array[float] 与 scale: Array[float]。
- `_context`: Dictionary，调用方附加上下文；当前实现不读取。
- `return`: Dictionary，包含 ok: bool 与 error: String。

## GFSaveDataSource

- Path: `addons/gf/extensions/save/core/gf_save_data_source.gd`
- Extends: `GFSaveSource`
- API: `public`
- Category: `protocol`
- Since: `3.18.0`

GFSaveDataSource: 通用对象数据源适配器。 将 Resource、目标 Node 或目标属性上的对象按 Dictionary 载荷接入 SaveGraph。 适合已有 Model、Resource 或数据持有对象复用 to_dict()/from_dict() 等通用协议， 不要求项目为每份纯数据状态额外编写 GFSaveSource 子类。

### Properties

#### `data`

- API: `public`

```gdscript
var data: Resource = null
```

直接保存的数据对象。设置后优先于 target_node_path 和 provider_property。

#### `provider_property`

- API: `public`

```gdscript
var provider_property: StringName = &""
```

目标节点上的数据对象属性。留空时使用目标节点自身作为数据对象。

#### `gather_method`

- API: `public`

```gdscript
var gather_method: StringName = &"to_dict"
```

采集载荷时调用的数据对象方法。方法必须返回 Dictionary。

#### `apply_method`

- API: `public`

```gdscript
var apply_method: StringName = &"from_dict"
```

应用载荷时调用的数据对象方法。方法接收 Dictionary。

#### `duplicate_payload`

- API: `public`

```gdscript
var duplicate_payload: bool = true
```

是否复制传入/传出的 Dictionary，避免流程外部误改同一个引用。

### Methods

#### `get_data_provider`

- API: `public`

```gdscript
func get_data_provider() -> Object:
```

获取当前数据对象。

Returns: 数据对象；无法解析时返回 null。

#### `describe_data_provider`

- API: `public`

```gdscript
func describe_data_provider() -> Dictionary:
```

构造数据对象诊断描述。

Returns: 诊断字典。

Schemas:

- `return`: Dictionary，包含 valid、reason、source_key、provider_location、provider_property、provider_class、provider_script、gather_method、apply_method、has_gather_method、has_apply_method 等字段。

#### `describe_source`

- API: `public`

```gdscript
func describe_source(scope: Node = null) -> Dictionary:
```

构造 Source 描述。

Parameters:

| Name | Description |
|---|---|
| `scope` | 当前 Scope。 |

Returns: 描述字典。

Schemas:

- `return`: Dictionary，包含父类描述字段，并追加 kind 与 data_provider 诊断字段。

## GFSaveEntityFactory

- Path: `addons/gf/extensions/save/core/gf_save_entity_factory.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFSaveEntityFactory: 存档恢复实体工厂基类。 由 GFSaveGraphUtility 在缺失 Source 且 Scope 允许工厂恢复时调用。

### Properties

#### `type_key`

- API: `public`

```gdscript
var type_key: StringName = &""
```

工厂可创建的实体类型键。

#### `packed_scene`

- API: `public`

```gdscript
var packed_scene: PackedScene
```

可选场景模板。项目也可继承 _create_entity 实现自定义创建。

### Methods

#### `get_type_key`

- API: `public`

```gdscript
func get_type_key() -> StringName:
```

获取实体类型键。

Returns: 类型键。

## GFSaveGraphUtility

- Path: `addons/gf/extensions/save/graph/gf_save_graph_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSaveGraphUtility: 通用节点存档图编排工具。 负责遍历 GFSaveScope/GFSaveSource，采集、应用和落盘存档图。具体数据结构 由 Source、Serializer 或项目继承类决定，Utility 本身不绑定业务字段。

### Constants

#### `FORMAT_ID`

- API: `public`

```gdscript
const FORMAT_ID: String = "gf_save_graph"
```

存档图载荷格式标识。

#### `FORMAT_VERSION`

- API: `public`

```gdscript
const FORMAT_VERSION: int = 1
```

当前存档图载荷格式版本。

### Properties

#### `serializer_registry`

- API: `public`

```gdscript
var serializer_registry: GFNodeSerializerRegistry = GFNodeSerializerRegistry.new()
```

节点序列化器注册表。

#### `pipeline_steps`

- API: `public`

```gdscript
var pipeline_steps: Array[GFSavePipelineStep] = []
```

存档图流程步骤。按数组顺序执行，适合压缩前校验、调试标记、版本适配等通用处理。

### Methods

#### `register_entity_factory`

- API: `public`

```gdscript
func register_entity_factory(factory: GFSaveEntityFactory) -> void:
```

注册实体工厂。

Parameters:

| Name | Description |
|---|---|
| `factory` | 实体工厂。 |

#### `unregister_entity_factory`

- API: `public`

```gdscript
func unregister_entity_factory(type_key: StringName) -> void:
```

注销实体工厂。

Parameters:

| Name | Description |
|---|---|
| `type_key` | 实体类型键。 |

#### `clear_entity_factories`

- API: `public`

```gdscript
func clear_entity_factories() -> void:
```

清空实体工厂。

#### `add_pipeline_step`

- API: `public`

```gdscript
func add_pipeline_step(step: GFSavePipelineStep) -> void:
```

添加存档流程步骤。

Parameters:

| Name | Description |
|---|---|
| `step` | 流程步骤。 |

#### `remove_pipeline_step`

- API: `public`

```gdscript
func remove_pipeline_step(step: GFSavePipelineStep) -> void:
```

移除存档流程步骤。

Parameters:

| Name | Description |
|---|---|
| `step` | 流程步骤。 |

#### `clear_pipeline_steps`

- API: `public`

```gdscript
func clear_pipeline_steps() -> void:
```

清空存档流程步骤。

#### `create_pipeline_context`

- API: `public`

```gdscript
func create_pipeline_context( operation: StringName, scope: GFSaveScope = null, shared: Dictionary = {} ) -> GFSavePipelineContext:
```

创建存档流程上下文。

Parameters:

| Name | Description |
|---|---|
| `operation` | 操作类型。 |
| `scope` | 可选根 Scope。 |
| `shared` | 初始共享数据。 |

Returns: 新上下文。

Schemas:

- `shared`: Dictionary，流程共享数据，可由步骤写入调试标记、迁移状态或项目自定义键。

#### `inspect_scope`

- API: `public`

```gdscript
func inspect_scope(scope: GFSaveScope, context: Dictionary = {}) -> Dictionary:
```

检查 Scope 树的可保存结构。

Parameters:

| Name | Description |
|---|---|
| `scope` | 根 Scope。 |
| `context` | 调用上下文字典。 |

Returns: 诊断报告。

Schemas:

- `context`: Dictionary，可包含诊断调用方自定义键，不会被 Utility 写入私有状态。
- `return`: Dictionary，包含 ok、healthy、scope_key、计数字段、issue_counts_by_kind、summary、next_action、scopes、sources 与 issues。

#### `build_scope_health_report`

- API: `public`

```gdscript
func build_scope_health_report(scope: GFSaveScope, context: Dictionary = {}) -> Dictionary:
```

构建 Scope 健康报告。

Parameters:

| Name | Description |
|---|---|
| `scope` | 根 Scope。 |
| `context` | 调用上下文字典。 |

Returns: 含 summary、next_action 与 issue 统计的诊断报告。

Schemas:

- `context`: Dictionary，可包含诊断调用方自定义键，不会被 Utility 写入私有状态。
- `return`: Dictionary，结构与 inspect_scope 的返回诊断报告一致。

#### `validate_payload_for_scope`

- API: `public`

```gdscript
func validate_payload_for_scope(scope: GFSaveScope, payload: Dictionary, strict: bool = false) -> Dictionary:
```

校验载荷是否能匹配当前 Scope 树。

Parameters:

| Name | Description |
|---|---|
| `scope` | 根 Scope。 |
| `payload` | 待校验载荷。 |
| `strict` | 为 true 时把缺失 Source/Scope 视为错误；否则视为警告。 |

Returns: 诊断报告。

Schemas:

- `payload`: Dictionary，存档图载荷，包含 format、format_version、scope、sources、scopes，可选 metadata 与 pipeline_trace。
- `return`: Dictionary，包含 ok、healthy、scope_key、checked_source_count、checked_scope_count、missing、issues、summary 与 next_action。

#### `build_payload_health_report`

- API: `public`

```gdscript
func build_payload_health_report(scope: GFSaveScope, payload: Dictionary, strict: bool = false) -> Dictionary:
```

构建载荷匹配健康报告。

Parameters:

| Name | Description |
|---|---|
| `scope` | 根 Scope。 |
| `payload` | 待校验载荷。 |
| `strict` | 为 true 时把缺失 Source/Scope 视为错误；否则视为警告。 |

Returns: 含 summary、next_action 与 issue 统计的诊断报告。

Schemas:

- `payload`: Dictionary，存档图载荷，包含 format、format_version、scope、sources、scopes，可选 metadata 与 pipeline_trace。
- `return`: Dictionary，结构与 validate_payload_for_scope 的返回诊断报告一致。

#### `gather_scope`

- API: `public`

```gdscript
func gather_scope(scope: GFSaveScope, context: Dictionary = {}) -> Dictionary:
```

采集 Scope 存档图。

Parameters:

| Name | Description |
|---|---|
| `scope` | 根 Scope。 |
| `context` | 调用上下文字典。 |

Returns: 存档载荷。

Schemas:

- `context`: Dictionary，可包含 pipeline_context、pipeline_shared、include_pipeline_trace、transactional_apply 及项目自定义键。
- `return`: Dictionary，存档图载荷，包含 format、format_version、scope、sources、scopes，可选 metadata 与 pipeline_trace。

#### `apply_scope`

- API: `public`

```gdscript
func apply_scope( scope: GFSaveScope, payload: Dictionary, context: Dictionary = {}, strict: bool = false ) -> Dictionary:
```

应用 Scope 存档图。

Parameters:

| Name | Description |
|---|---|
| `scope` | 根 Scope。 |
| `payload` | 存档载荷。 |
| `context` | 调用上下文字典。 |
| `strict` | 为 true 时缺失 Source/Scope 会记录错误。 |

Returns: 结果字典。

Schemas:

- `payload`: Dictionary，存档图载荷，包含 format、format_version、scope、sources、scopes，可选 metadata 与 pipeline_trace。
- `context`: Dictionary，可包含 pipeline_context、pipeline_shared、include_pipeline_trace、transactional_apply 及项目自定义键。
- `return`: Dictionary，包含 ok、applied、errors、missing，可选 pipeline_trace。

#### `save_scope`

- API: `public`

```gdscript
func save_scope( file_name: String, scope: GFSaveScope, metadata: Dictionary = {}, context: Dictionary = {} ) -> Error:
```

采集并保存 Scope。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 目标文件名。 |
| `scope` | 根 Scope。 |
| `metadata` | 附加元信息。 |
| `context` | 调用上下文字典。 |

Returns: Godot 错误码。

Schemas:

- `metadata`: Dictionary，写入载荷 metadata 字段的项目元信息。
- `context`: Dictionary，可包含 pipeline_context、pipeline_shared、include_pipeline_trace 及项目自定义键。

#### `load_scope`

- API: `public`

```gdscript
func load_scope( file_name: String, scope: GFSaveScope, context: Dictionary = {}, strict: bool = false ) -> Dictionary:
```

从文件读取并应用 Scope。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 目标文件名。 |
| `scope` | 根 Scope。 |
| `context` | 调用上下文字典。 |
| `strict` | 为 true 时缺失 Source/Scope 会记录错误。 |

Returns: 结果字典。

Schemas:

- `context`: Dictionary，可包含 pipeline_context、pipeline_shared、include_pipeline_trace、transactional_apply 及项目自定义键。
- `return`: Dictionary，包含 ok、applied、errors、missing，可选 pipeline_trace。

## GFSaveIdentity

- Path: `addons/gf/extensions/save/core/gf_save_identity.gd`
- Extends: `Node`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFSaveIdentity: 场景节点的持久化身份描述。 用于为可恢复实体提供稳定 id、类型键和额外描述信息。它只描述身份， 不直接负责保存或实例化。

### Properties

#### `persistent_id`

- API: `public`

```gdscript
var persistent_id: StringName = &""
```

稳定实体 id。留空时由调用方决定是否使用节点路径等回退方案。

#### `type_key`

- API: `public`

```gdscript
var type_key: StringName = &""
```

可选实体类型键，通常用于恢复时选择工厂。

#### `descriptor_extra`

- API: `public`

```gdscript
var descriptor_extra: Dictionary = {}
```

可写入存档描述的扩展字段。

Schemas:

- `descriptor_extra`: Dictionary，会合并进 describe_identity() 返回值的项目自定义描述字段。

### Methods

#### `get_persistent_id`

- API: `public`

```gdscript
func get_persistent_id() -> StringName:
```

获取稳定实体 id。

Returns: 实体 id。

#### `get_type_key`

- API: `public`

```gdscript
func get_type_key() -> StringName:
```

获取实体类型键。

Returns: 类型键。

#### `describe_identity`

- API: `public`

```gdscript
func describe_identity() -> Dictionary:
```

构造身份描述。

Returns: 描述字典。

Schemas:

- `return`: Dictionary，包含 descriptor_extra，并在非空时包含 persistent_id 与 type_key。

## GFSavePipelineContext

- Path: `addons/gf/extensions/save/pipeline/gf_save_pipeline_context.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFSavePipelineContext: 存档图流程上下文。 在一次 gather/apply 操作中收集通用事件、警告、错误与共享数据。 上下文通过调用者传入的 context 字典传播，不要求存档载荷写死任何字段。

### Properties

#### `operation`

- API: `public`

```gdscript
var operation: StringName = &""
```

当前操作类型，如 gather 或 apply。

#### `root_scope_key`

- API: `public`

```gdscript
var root_scope_key: StringName = &""
```

根作用域键。

#### `shared`

- API: `public`

```gdscript
var shared: Dictionary = {}
```

流程共享数据。项目层可写入自己的临时状态。

Schemas:

- `shared`: Dictionary，一次流程中的临时共享字段，不会自动写入存档载荷。

#### `events`

- API: `public`

```gdscript
var events: Array[GFSavePipelineEvent] = []
```

流程事件列表。

#### `warnings`

- API: `public`

```gdscript
var warnings: PackedStringArray = PackedStringArray()
```

通用警告信息。

#### `errors`

- API: `public`

```gdscript
var errors: PackedStringArray = PackedStringArray()
```

通用错误信息。

#### `started_at_msec`

- API: `public`

```gdscript
var started_at_msec: int = 0
```

开始时间。

#### `finished_at_msec`

- API: `public`

```gdscript
var finished_at_msec: int = 0
```

结束时间。

### Methods

#### `begin_operation`

- API: `public`

```gdscript
func begin_operation( p_operation: StringName, p_root_scope_key: StringName = &"", p_shared: Dictionary = {} ) -> GFSavePipelineContext:
```

开始一次流程操作。

Parameters:

| Name | Description |
|---|---|
| `p_operation` | 操作类型。 |
| `p_root_scope_key` | 根作用域键。 |
| `p_shared` | 初始共享数据。 |

Returns: 当前上下文。

Schemas:

- `p_shared`: Dictionary，一次流程中的临时共享字段，不会自动写入存档载荷。

#### `record_event`

- API: `public`

```gdscript
func record_event( stage: StringName, scope: Object = null, source: Object = null, message: String = "", payload: Dictionary = {}, severity: StringName = &"info" ) -> GFSavePipelineEvent:
```

记录流程事件。

Parameters:

| Name | Description |
|---|---|
| `stage` | 阶段标识。 |
| `scope` | 可选 Scope。 |
| `source` | 可选 Source。 |
| `message` | 调试消息。 |
| `payload` | 附加载荷。 |
| `severity` | 严重级别。 |

Returns: 新事件。

Schemas:

- `payload`: Dictionary，项目或流程步骤附加的诊断字段。

#### `add_warning`

- API: `public`

```gdscript
func add_warning(message: String, payload: Dictionary = {}) -> void:
```

记录警告并同步生成 warning 事件。

Parameters:

| Name | Description |
|---|---|
| `message` | 警告内容。 |
| `payload` | 附加载荷。 |

Schemas:

- `payload`: Dictionary，项目或流程步骤附加的诊断字段。

#### `add_error`

- API: `public`

```gdscript
func add_error(message: String, payload: Dictionary = {}) -> void:
```

记录错误并同步生成 error 事件。

Parameters:

| Name | Description |
|---|---|
| `message` | 错误内容。 |
| `payload` | 附加载荷。 |

Schemas:

- `payload`: Dictionary，项目或流程步骤附加的诊断字段。

#### `finish`

- API: `public`

```gdscript
func finish() -> void:
```

标记流程结束。

#### `is_finished`

- API: `public`

```gdscript
func is_finished() -> bool:
```

当前流程是否已结束。

Returns: 已结束返回 true。

#### `get_elapsed_msec`

- API: `public`

```gdscript
func get_elapsed_msec() -> int:
```

获取耗时毫秒。

Returns: 耗时。

#### `to_dict`

- API: `public`

```gdscript
func to_dict(include_events: bool = true) -> Dictionary:
```

转换为 Dictionary。

Parameters:

| Name | Description |
|---|---|
| `include_events` | 是否包含事件列表。 |

Returns: 上下文字典。

Schemas:

- `return`: Dictionary，包含 operation、root_scope_key、shared、warnings、errors、started_at_msec、finished_at_msec、elapsed_msec、event_count；include_events 为 true 时包含 events: Array[Dictionary]。

## GFSavePipelineEvent

- Path: `addons/gf/extensions/save/pipeline/gf_save_pipeline_event.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

GFSavePipelineEvent: 存档图流程事件。 用于描述 GFSaveGraphUtility 在采集/应用过程中的通用阶段、Scope、Source 与诊断信息。事件本身不携带业务字段，项目层可通过 payload 扩展。

### Properties

#### `stage`

- API: `public`

```gdscript
var stage: StringName = &""
```

流程阶段标识。

#### `severity`

- API: `public`

```gdscript
var severity: StringName = &"info"
```

事件严重级别，建议使用 info/warning/error。

#### `scope_key`

- API: `public`

```gdscript
var scope_key: StringName = &""
```

事件关联的作用域键。

#### `source_key`

- API: `public`

```gdscript
var source_key: StringName = &""
```

事件关联的来源键。

#### `node_path`

- API: `public`

```gdscript
var node_path: String = ""
```

事件关联节点路径。

#### `message`

- API: `public`

```gdscript
var message: String = ""
```

面向调试的短消息。

#### `payload`

- API: `public`

```gdscript
var payload: Dictionary = {}
```

附加通用载荷。

Schemas:

- `payload`: Dictionary，项目或流程步骤附加的诊断字段。

#### `timestamp_msec`

- API: `public`

```gdscript
var timestamp_msec: int = 0
```

事件创建时间。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( p_stage: StringName, scope: Object = null, source: Object = null, p_message: String = "", p_payload: Dictionary = {}, p_severity: StringName = &"info" ) -> GFSavePipelineEvent:
```

配置事件内容并返回自身。

Parameters:

| Name | Description |
|---|---|
| `p_stage` | 流程阶段。 |
| `scope` | 可选 Scope 或节点对象。 |
| `source` | 可选 Source 或节点对象。 |
| `p_message` | 调试消息。 |
| `p_payload` | 附加载荷。 |
| `p_severity` | 严重级别。 |

Returns: 当前事件。

Schemas:

- `p_payload`: Dictionary，项目或流程步骤附加的诊断字段。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为 Dictionary，便于日志、存档或测试断言。

Returns: 事件字典。

Schemas:

- `return`: Dictionary，包含 stage、severity、scope_key、source_key、node_path、message、payload 与 timestamp_msec。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFSavePipelineEvent:
```

从 Dictionary 恢复事件。

Parameters:

| Name | Description |
|---|---|
| `data` | 事件字典。 |

Returns: 新事件。

Schemas:

- `data`: Dictionary，可包含 stage、severity、scope_key、source_key、node_path、message、payload 与 timestamp_msec。

## GFSavePipelineStep

- Path: `addons/gf/extensions/save/pipeline/gf_save_pipeline_step.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFSavePipelineStep: 存档图流程步骤基类。 用于在 GFSaveGraphUtility 的 Scope 采集/应用流程前后插入通用处理。 步骤只接收 scope、payload、context 和 result，不绑定任何业务字段。

### Properties

#### `step_id`

- API: `public`

```gdscript
var step_id: StringName = &""
```

步骤标识，便于调试与项目层开关。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用该步骤。

## GFSaveScope

- Path: `addons/gf/extensions/save/core/gf_save_scope.gd`
- Extends: `Node`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFSaveScope: 存档图作用域节点。 Scope 定义一次保存/加载的边界。它可嵌套组织子 Scope，但不假设具体业务结构。

### Enums

#### `RestorePolicy`

- API: `public`

```gdscript
enum RestorePolicy { ## 只把数据应用到已存在的 Source。 APPLY_ONLY_EXISTING, ## 允许 GFSaveGraphUtility 使用注册的工厂补建实体。 ALLOW_FACTORIES, }
```

恢复未知实体时的处理策略。

#### `Phase`

- API: `public`

```gdscript
enum Phase { ## 早期执行。 EARLY, ## 普通执行。 NORMAL, ## 后期执行。 LATE, }
```

Scope/Source 执行阶段。

### Properties

#### `scope_key`

- API: `public`

```gdscript
var scope_key: StringName = &""
```

Scope 稳定标识。留空时回退到节点名。

#### `key_namespace`

- API: `public`

```gdscript
var key_namespace: StringName = &""
```

可选键命名空间。用于多处复用同名子结构时隔离 source key。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用该 Scope。

#### `save_enabled`

- API: `public`

```gdscript
var save_enabled: bool = true
```

是否参与保存。

#### `load_enabled`

- API: `public`

```gdscript
var load_enabled: bool = true
```

是否参与加载。

#### `phase`

- API: `public`

```gdscript
var phase: Phase = Phase.NORMAL
```

执行阶段。

#### `restore_policy`

- API: `public`

```gdscript
var restore_policy: RestorePolicy = RestorePolicy.APPLY_ONLY_EXISTING
```

恢复策略。

### Methods

#### `get_scope_key`

- API: `public`

```gdscript
func get_scope_key() -> StringName:
```

获取 Scope 稳定标识。

Returns: 作用域键。

#### `get_key_prefix`

- API: `public`

```gdscript
func get_key_prefix() -> String:
```

获取来源键前缀。

Returns: 前缀字符串。

#### `describe_scope`

- API: `public`

```gdscript
func describe_scope() -> Dictionary:
```

返回当前 Scope 的通用描述。

Returns: 描述字典。

Schemas:

- `return`: Dictionary，包含 scope_key、key_namespace、phase 与 restore_policy。

## GFSaveSlotCard

- Path: `addons/gf/extensions/save/slots/gf_save_slot_card.gd`
- Extends: `Resource`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFSaveSlotCard: 通用存档槽展示卡片数据。 作为 UI 和存档系统之间的轻量 DTO，不规定具体界面布局或业务字段。

### Properties

#### `slot_index`

- API: `public`

```gdscript
var slot_index: int = -1
```

整数槽位索引。文件名/云端 key 场景可保持为 -1。

#### `slot_id`

- API: `public`

```gdscript
var slot_id: StringName = &""
```

逻辑槽位标识。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

展示名称。

#### `description`

- API: `public`

```gdscript
var description: String = ""
```

展示描述。

#### `is_empty`

- API: `public`

```gdscript
var is_empty: bool = true
```

是否为空槽位。

#### `is_active`

- API: `public`

```gdscript
var is_active: bool = false
```

是否为当前选中槽位。

#### `is_compatible`

- API: `public`

```gdscript
var is_compatible: bool = true
```

是否兼容当前项目版本或数据结构。

#### `modified_time`

- API: `public`

```gdscript
var modified_time: int = 0
```

最近修改时间戳。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

原始元数据副本。

Schemas:

- `metadata`: Dictionary，通常来自 GFSaveSlotMetadata.to_dict() 或 GFStorageUtility.list_slots() 的 metadata 字段。

#### `compatibility_errors`

- API: `public`

```gdscript
var compatibility_errors: PackedStringArray = PackedStringArray()
```

兼容性问题列表。

### Methods

#### `configure_from_slot_summary`

- API: `public`

```gdscript
func configure_from_slot_summary( summary: Dictionary, fallback_slot_id: StringName = &"", active_slot_index: int = -1 ) -> GFSaveSlotCard:
```

从 GFStorageUtility.list_slots() 风格的摘要配置卡片。

Parameters:

| Name | Description |
|---|---|
| `summary` | 槽位摘要。 |
| `fallback_slot_id` | 摘要缺少 slot_id 时的兜底标识。 |
| `active_slot_index` | 当前选中槽位索引。 |

Returns: 当前卡片。

Schemas:

- `summary`: Dictionary，可包含 slot_index、slot_id、modified_time、is_compatible、compatibility_errors 与 metadata。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为 Dictionary。

Returns: 卡片字典。

Schemas:

- `return`: Dictionary，包含 slot_index、slot_id、display_name、description、is_empty、is_active、is_compatible、modified_time、metadata 与 compatibility_errors。

#### `get_status_text`

- API: `public`

```gdscript
func get_status_text() -> String:
```

获取通用状态文本。

Returns: 状态文本。

#### `from_slot_summary`

- API: `public`

```gdscript
static func from_slot_summary( summary: Dictionary, fallback_slot_id: StringName = &"", active_slot_index: int = -1 ) -> GFSaveSlotCard:
```

从摘要创建卡片。

Parameters:

| Name | Description |
|---|---|
| `summary` | 槽位摘要。 |
| `fallback_slot_id` | 兜底标识。 |
| `active_slot_index` | 当前选中槽位索引。 |

Returns: 新卡片。

Schemas:

- `summary`: Dictionary，可包含 slot_index、slot_id、modified_time、is_compatible、compatibility_errors 与 metadata。

## GFSaveSlotMetadata

- Path: `addons/gf/extensions/save/slots/gf_save_slot_metadata.gd`
- Extends: `Resource`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFSaveSlotMetadata: 通用存档槽元数据。 只描述槽位、版本、时间、标签和项目自定义字典，不绑定任何具体游戏业务字段。

### Properties

#### `slot_id`

- API: `public`

```gdscript
var slot_id: StringName = &""
```

槽位逻辑标识。可由项目映射到整数槽、文件名或云端 key。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

展示名称。

#### `description`

- API: `public`

```gdscript
var description: String = ""
```

展示描述。

#### `schema_id`

- API: `public`

```gdscript
var schema_id: StringName = &""
```

存档数据结构标识。

#### `schema_version`

- API: `public`

```gdscript
var schema_version: int = 1
```

存档数据结构版本。

#### `app_version`

- API: `public`

```gdscript
var app_version: String = ""
```

项目版本号。

#### `created_at_unix`

- API: `public`

```gdscript
var created_at_unix: int = 0
```

创建时间戳。

#### `updated_at_unix`

- API: `public`

```gdscript
var updated_at_unix: int = 0
```

更新时间戳。

#### `elapsed_seconds`

- API: `public`

```gdscript
var elapsed_seconds: float = 0.0
```

通用游玩时长或业务耗时。

#### `tags`

- API: `public`

```gdscript
var tags: PackedStringArray = PackedStringArray()
```

通用标签。

#### `custom_metadata`

- API: `public`

```gdscript
var custom_metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `custom_metadata`: Dictionary，可包含项目自定义展示、兼容性或索引字段。

### Methods

#### `to_dict`

- API: `public`

```gdscript
func to_dict(include_empty: bool = true) -> Dictionary:
```

转换为 Dictionary。

Parameters:

| Name | Description |
|---|---|
| `include_empty` | 是否包含空值。 |

Returns: 元数据字典。

Schemas:

- `return`: Dictionary，可包含 slot_id、display_name、description、schema_id、schema_version、app_version、created_at_unix、updated_at_unix、elapsed_seconds、tags 与 custom_metadata。

#### `to_patch_dict`

- API: `public`

```gdscript
func to_patch_dict() -> Dictionary:
```

转换为只包含非空值的补丁字典。

Returns: 补丁字典。

Schemas:

- `return`: Dictionary，字段同 to_dict()，但会省略空值。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

应用字典数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 元数据字典。 |

Schemas:

- `data`: Dictionary，可包含 slot_id、display_name、description、schema_id、schema_version、app_version、created_at_unix、updated_at_unix、elapsed_seconds、tags 与 custom_metadata。

#### `duplicate_metadata`

- API: `public`

```gdscript
func duplicate_metadata() -> GFSaveSlotMetadata:
```

创建深拷贝。

Returns: 新元数据。

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name(fallback: String = "") -> String:
```

获取展示名称，允许调用方提供兜底文本。

Parameters:

| Name | Description |
|---|---|
| `fallback` | 兜底文本。 |

Returns: 展示名称。

#### `validate_metadata`

- API: `public`

```gdscript
func validate_metadata() -> Dictionary:
```

校验元数据的通用结构。

Returns: 诊断报告。

Schemas:

- `return`: Dictionary，包含 ok、healthy、issues、issue_count、warning_count、error_count、summary 与 next_actions 等校验报告字段。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFSaveSlotMetadata:
```

从 Dictionary 创建元数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 元数据字典。 |

Returns: 新元数据。

Schemas:

- `data`: Dictionary，字段同 to_dict() 返回值。

#### `from_values`

- API: `public`

```gdscript
static func from_values( p_slot_id: StringName, p_display_name: String = "", p_custom_metadata: Dictionary = {} ) -> GFSaveSlotMetadata:
```

使用常用字段创建元数据。

Parameters:

| Name | Description |
|---|---|
| `p_slot_id` | 槽位标识。 |
| `p_display_name` | 展示名称。 |
| `p_custom_metadata` | 自定义元数据。 |

Returns: 新元数据。

Schemas:

- `p_custom_metadata`: Dictionary，可包含项目自定义展示、兼容性或索引字段。

## GFSaveSlotWorkflow

- Path: `addons/gf/extensions/save/slots/gf_save_slot_workflow.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFSaveSlotWorkflow: 通用存档槽工作流配置。 负责把槽位索引、逻辑标识、元数据和 UI 卡片摘要串起来。 不执行具体存取逻辑，也不写死任何游戏业务字段。

### Properties

#### `active_slot_index`

- API: `public`

```gdscript
var active_slot_index: int = 1
```

当前选中槽位索引。默认从 1 开始，贴近常见存档 UI。

#### `slot_id_template`

- API: `public`

```gdscript
var slot_id_template: String = "slot_{index}"
```

槽位标识模板，支持 {index} 占位符。

#### `empty_display_name_template`

- API: `public`

```gdscript
var empty_display_name_template: String = "Slot {index}"
```

空槽位展示名模板，支持 {index} 占位符。

#### `metadata_script`

- API: `public`

```gdscript
var metadata_script: Script = _GF_SAVE_SLOT_METADATA_SCRIPT
```

可替换的元数据资源脚本，项目层可继承 GFSaveSlotMetadata 扩展。

#### `card_script`

- API: `public`

```gdscript
var card_script: Script = _GF_SAVE_SLOT_CARD_SCRIPT
```

可替换的卡片资源脚本，项目层可继承 GFSaveSlotCard 扩展。

#### `slot_role`

- API: `public`

```gdscript
var slot_role: StringName = &""
```

槽位角色。用于区分 autosave/manual/cloud 等抽象类别。

### Methods

#### `select_slot_index`

- API: `public`

```gdscript
func select_slot_index(index: int) -> StringName:
```

选择当前槽位。

Parameters:

| Name | Description |
|---|---|
| `index` | 槽位索引。 |

Returns: 当前槽位逻辑标识。

#### `set_slot_id_override`

- API: `public`

```gdscript
func set_slot_id_override(index: int, slot_id: StringName) -> void:
```

设置指定索引的逻辑标识覆盖。

Parameters:

| Name | Description |
|---|---|
| `index` | 槽位索引。 |
| `slot_id` | 逻辑标识。 |

#### `clear_slot_id_overrides`

- API: `public`

```gdscript
func clear_slot_id_overrides() -> void:
```

清空逻辑标识覆盖。

#### `get_active_slot_id`

- API: `public`

```gdscript
func get_active_slot_id() -> StringName:
```

获取当前槽位逻辑标识。

Returns: 槽位标识。

#### `get_active_storage_slot_id`

- API: `public`

```gdscript
func get_active_storage_slot_id() -> int:
```

获取当前 GFStorageUtility 整数槽位。

Returns: 整数槽位。

#### `get_slot_id_for_index`

- API: `public`

```gdscript
func get_slot_id_for_index(index: int) -> StringName:
```

获取指定索引的逻辑标识。

Parameters:

| Name | Description |
|---|---|
| `index` | 槽位索引。 |

Returns: 槽位标识。

#### `get_empty_display_name_for_index`

- API: `public`

```gdscript
func get_empty_display_name_for_index(index: int) -> String:
```

获取空槽位展示名。

Parameters:

| Name | Description |
|---|---|
| `index` | 槽位索引。 |

Returns: 展示名。

#### `build_active_metadata`

- API: `public`

```gdscript
func build_active_metadata( display_name: String = "", custom_metadata: Dictionary = {} ) -> GFSaveSlotMetadata:
```

构建当前槽位元数据。

Parameters:

| Name | Description |
|---|---|
| `display_name` | 可选展示名。 |
| `custom_metadata` | 自定义元数据。 |

Returns: 元数据资源。

Schemas:

- `custom_metadata`: Dictionary，会写入 GFSaveSlotMetadata.custom_metadata；slot_role 非空时会额外写入 slot_role。

#### `build_slot_metadata`

- API: `public`

```gdscript
func build_slot_metadata( index: int, display_name: String = "", custom_metadata: Dictionary = {} ) -> GFSaveSlotMetadata:
```

构建指定槽位元数据。

Parameters:

| Name | Description |
|---|---|
| `index` | 槽位索引。 |
| `display_name` | 可选展示名。 |
| `custom_metadata` | 自定义元数据。 |

Returns: 元数据资源。

Schemas:

- `custom_metadata`: Dictionary，会写入 GFSaveSlotMetadata.custom_metadata；slot_role 非空时会额外写入 slot_role。

#### `build_empty_card`

- API: `public`

```gdscript
func build_empty_card(index: int) -> GFSaveSlotCard:
```

构建空槽位卡片。

Parameters:

| Name | Description |
|---|---|
| `index` | 槽位索引。 |

Returns: 卡片资源。

#### `build_card_for_index`

- API: `public`

```gdscript
func build_card_for_index( index: int, summary: Dictionary = {}, p_active_slot_index: int = -1 ) -> GFSaveSlotCard:
```

根据摘要构建槽位卡片。摘要为空时返回空卡片。

Parameters:

| Name | Description |
|---|---|
| `index` | 槽位索引。 |
| `summary` | 槽位摘要。 |
| `p_active_slot_index` | 当前选中索引；小于 0 时使用 active_slot_index。 |

Returns: 卡片资源。

Schemas:

- `summary`: Dictionary，可包含 slot_index、slot_id、modified_time、is_compatible、compatibility_errors 与 metadata。

#### `build_cards_for_indices`

- API: `public`

```gdscript
func build_cards_for_indices(indices: Array, summaries: Array = []) -> Array[GFSaveSlotCard]:
```

根据索引和摘要列表构建卡片列表。

Parameters:

| Name | Description |
|---|---|
| `indices` | 槽位索引列表。 |
| `summaries` | 槽位摘要列表。 |

Returns: 卡片列表。

Schemas:

- `indices`: Array，元素为可转换为 int 的槽位索引。
- `summaries`: Array，每项为 GFStorageUtility.list_slots() 风格的 Dictionary 摘要。

#### `build_cards_from_storage`

- API: `public`

```gdscript
func build_cards_from_storage(storage: GFStorageUtility, indices: Array = []) -> Array[GFSaveSlotCard]:
```

从 GFStorageUtility 读取摘要并构建卡片。

Parameters:

| Name | Description |
|---|---|
| `storage` | 存储工具。 |
| `indices` | 需要展示的槽位索引；为空时使用已有槽位。 |

Returns: 卡片列表。

Schemas:

- `indices`: Array，元素为可转换为 int 的槽位索引。

## GFSaveSource

- Path: `addons/gf/extensions/save/core/gf_save_source.gd`
- Extends: `Node`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFSaveSource: 存档图数据源节点。 Source 是存档图的最小数据入口。项目可继承并重写 gather/apply， 也可配置节点序列化器保存通用节点属性。

### Properties

#### `source_key`

- API: `public`

```gdscript
var source_key: StringName = &""
```

Source 稳定标识。留空时回退到节点名。

#### `target_node_path`

- API: `public`

```gdscript
var target_node_path: NodePath
```

目标节点路径。留空时默认序列化父节点。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用该 Source。

#### `save_enabled`

- API: `public`

```gdscript
var save_enabled: bool = true
```

是否参与保存。

#### `load_enabled`

- API: `public`

```gdscript
var load_enabled: bool = true
```

是否参与加载。

#### `phase`

- API: `public`

```gdscript
var phase: int = GFSaveScope.Phase.NORMAL
```

执行阶段。数值越小越早执行。

#### `serializers`

- API: `public`

```gdscript
var serializers: Array[GFNodeSerializer] = []
```

Source 局部序列化器。为空时可使用注册表中的默认序列化器。

#### `use_registry_serializers`

- API: `public`

```gdscript
var use_registry_serializers: bool = false
```

是否在未配置局部序列化器时使用注册表默认序列化器。

#### `descriptor_extra`

- API: `public`

```gdscript
var descriptor_extra: Dictionary = {}
```

附加描述字段。

Schemas:

- `descriptor_extra`: Dictionary，会合并进 describe_source() 返回值的项目自定义描述字段。

### Methods

#### `get_source_key`

- API: `public`

```gdscript
func get_source_key() -> StringName:
```

获取 Source 稳定标识。

Returns: 来源键。

#### `get_target_node`

- API: `public`

```gdscript
func get_target_node() -> Node:
```

获取目标节点。

Returns: 目标节点；不存在时返回 null。

#### `describe_source`

- API: `public`

```gdscript
func describe_source(scope: Node = null) -> Dictionary:
```

构造 Source 描述。

Parameters:

| Name | Description |
|---|---|
| `scope` | 当前 Scope。 |

Returns: 描述字典。

Schemas:

- `return`: Dictionary，包含 descriptor_extra、source_key、phase，并在可用时包含 node_path。

#### `make_result`

- API: `public`

```gdscript
func make_result(ok: bool, error: String = "") -> Dictionary:
```

构造统一结果。

Parameters:

| Name | Description |
|---|---|
| `ok` | 是否成功。 |
| `error` | 错误描述。 |

Returns: 结果字典。

Schemas:

- `return`: Dictionary，包含 ok: bool 与 error: String。

