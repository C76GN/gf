# Feedback API

Module: `extensions/feedback`

## Classes

- [`GFShakePreset`](#gfshakepreset)
- [`GFShakeReceiver2D`](#gfshakereceiver2d)
- [`GFShakeReceiver3D`](#gfshakereceiver3d)
- [`GFShakeTrack`](#gfshaketrack)
- [`GFShakeUtility`](#gfshakeutility)

## GFShakePreset

- Path: `addons/gf/extensions/feedback/resources/gf_shake_preset.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFShakePreset: 通用反馈采样预设。 描述一段可采样的位移、旋转和缩放偏移，不绑定相机、角色、UI 或业务事件。

### Enums

#### `Waveform`

- API: `public`

```gdscript
enum Waveform { ## 正弦波，适合可预期的摆动。 SINE, ## 逐步随机值，适合冲击感。 RANDOM, ## 平滑随机值，适合持续扰动。 NOISE, ## 使用 wave_curve 采样，曲线值 0.5 表示零偏移。 CURVE, }
```

反馈采样波形。

### Properties

#### `duration_seconds`

- API: `public`

```gdscript
var duration_seconds: float = 0.25
```

持续时间，单位秒。

#### `amplitude`

- API: `public`

```gdscript
var amplitude: float = 1.0
```

采样振幅倍率。

#### `frequency`

- API: `public`

```gdscript
var frequency: float = 24.0
```

每秒采样频率。

#### `waveform`

- API: `public`

```gdscript
var waveform: Waveform = Waveform.NOISE
```

波形类型。

#### `position_axis`

- API: `public`

```gdscript
var position_axis: Vector3 = Vector3.ONE
```

位移轴权重。

#### `rotation_axis_degrees`

- API: `public`

```gdscript
var rotation_axis_degrees: Vector3 = Vector3.ZERO
```

旋转轴权重，单位度。

#### `scale_axis`

- API: `public`

```gdscript
var scale_axis: Vector3 = Vector3.ZERO
```

缩放偏移轴权重。返回值是叠加到基础 scale 上的偏移。

#### `decay_curve`

- API: `public`

```gdscript
var decay_curve: Curve = null
```

包络曲线。为空时使用线性衰减；曲线值越高，当前采样越强。

#### `wave_curve`

- API: `public`

```gdscript
var wave_curve: Curve = null
```

自定义波形曲线。仅在 waveform 为 CURVE 时使用，曲线值 0.5 表示零偏移。

#### `sample_seed`

- API: `public`

```gdscript
var sample_seed: int = 1
```

确定性采样种子。

#### `tracks`

- API: `public`

```gdscript
var tracks: Array[GFShakeTrack] = []
```

可组合反馈轨道。为空时使用兼容的单波形字段。

Schemas:

- `tracks`: Array[GFShakeTrack]，按顺序采样并根据每个轨道 blend_mode 合成。

### Methods

#### `get_duration_seconds`

- API: `public`

```gdscript
func get_duration_seconds() -> float:
```

获取有效持续时间。

Returns: 持续时间，最小为 0。

#### `sample`

- API: `public`

```gdscript
func sample(elapsed_seconds: float, strength: float = 1.0, phase_offset: float = 0.0) -> Dictionary:
```

按时间采样反馈偏移。

Parameters:

| Name | Description |
|---|---|
| `elapsed_seconds` | 已经过的秒数。 |
| `strength` | 本次播放强度倍率。 |
| `phase_offset` | 相位偏移，用于同一预设多次播放时错开采样。 |

Returns: 采样结果字典。

Schemas:

- `return`: Dictionary，包含 position: Vector3、rotation_degrees: Vector3、scale: Vector3、intensity: float 与 progress: float。

#### `sample_at_progress`

- API: `public`

```gdscript
func sample_at_progress( progress: float, elapsed_seconds: float, strength: float = 1.0, phase_offset: float = 0.0 ) -> Dictionary:
```

按归一化进度采样反馈偏移。

Parameters:

| Name | Description |
|---|---|
| `progress` | 归一化进度，范围 0 到 1。 |
| `elapsed_seconds` | 已经过的秒数。 |
| `strength` | 本次播放强度倍率。 |
| `phase_offset` | 相位偏移。 |

Returns: 采样结果字典。

Schemas:

- `return`: Dictionary，包含 position: Vector3、rotation_degrees: Vector3、scale: Vector3、intensity: float 与 progress: float。

#### `add_track`

- API: `public`

```gdscript
func add_track(track: GFShakeTrack) -> bool:
```

添加反馈轨道。

Parameters:

| Name | Description |
|---|---|
| `track` | 反馈轨道。 |

Returns: 添加成功返回 true。

#### `clear_tracks`

- API: `public`

```gdscript
func clear_tracks() -> void:
```

清空反馈轨道。

#### `has_tracks`

- API: `public`

```gdscript
func has_tracks() -> bool:
```

检查是否存在有效轨道。

Returns: 存在有效轨道返回 true。

#### `zero_sample`

- API: `public`

```gdscript
static func zero_sample() -> Dictionary:
```

创建空采样结果。

Returns: 空采样结果字典。

Schemas:

- `return`: Dictionary，包含零值 position、rotation_degrees、scale、intensity 与 progress。

#### `combine_samples`

- API: `public`

```gdscript
static func combine_samples(samples: Array[Dictionary]) -> Dictionary:
```

合并多个反馈采样。

Parameters:

| Name | Description |
|---|---|
| `samples` | 采样结果数组。 |

Returns: 合并后的采样结果。

Schemas:

- `samples`: Array[Dictionary]，每项包含 position、rotation_degrees、scale、intensity 与 progress。
- `return`: Dictionary，合并后的反馈采样，包含 position、rotation_degrees、scale、intensity 与 progress。

## GFShakeReceiver2D

- Path: `addons/gf/extensions/feedback/nodes/gf_shake_receiver_2d.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFShakeReceiver2D: 将反馈采样应用到 Node2D 的通用接收器。

### Properties

#### `target_path`

- API: `public`

```gdscript
var target_path: NodePath = NodePath("")
```

目标 Node2D 路径；为空时优先使用自身，其次使用父节点。

#### `channel`

- API: `public`

```gdscript
var channel: StringName = &"default"
```

采样 channel。

#### `apply_position`

- API: `public`

```gdscript
var apply_position: bool = true
```

是否应用 position 偏移。

#### `apply_rotation`

- API: `public`

```gdscript
var apply_rotation: bool = true
```

是否应用 rotation_degrees 偏移。

#### `apply_scale`

- API: `public`

```gdscript
var apply_scale: bool = false
```

是否应用 scale 偏移。

#### `capture_on_ready`

- API: `public`

```gdscript
var capture_on_ready: bool = true
```

ready 时是否记录基础变换。

#### `restore_on_exit`

- API: `public`

```gdscript
var restore_on_exit: bool = true
```

退出树时是否恢复基础变换。

#### `utility`

- API: `public`

```gdscript
var utility: GFShakeUtility = null
```

可选反馈工具实例；为空时从全局架构查询。

### Methods

#### `set_utility`

- API: `public`

```gdscript
func set_utility(shake_utility: GFShakeUtility) -> void:
```

设置反馈工具实例。

Parameters:

| Name | Description |
|---|---|
| `shake_utility` | 反馈工具实例。 |

#### `get_target`

- API: `public`

```gdscript
func get_target() -> Node2D:
```

获取当前目标节点。

Returns: 目标 Node2D；不存在时返回 null。

#### `capture_base_transform`

- API: `public`

```gdscript
func capture_base_transform() -> bool:
```

记录当前目标基础变换。

Returns: 记录成功返回 true。

#### `apply_current_sample`

- API: `public`

```gdscript
func apply_current_sample() -> bool:
```

应用当前 channel 采样。

Returns: 应用成功返回 true。

#### `reset_to_base`

- API: `public`

```gdscript
func reset_to_base() -> bool:
```

恢复目标基础变换。

Returns: 恢复成功返回 true。

## GFShakeReceiver3D

- Path: `addons/gf/extensions/feedback/nodes/gf_shake_receiver_3d.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFShakeReceiver3D: 将反馈采样应用到 Node3D 的通用接收器。

### Properties

#### `target_path`

- API: `public`

```gdscript
var target_path: NodePath = NodePath("")
```

目标 Node3D 路径；为空时优先使用自身，其次使用父节点。

#### `channel`

- API: `public`

```gdscript
var channel: StringName = &"default"
```

采样 channel。

#### `apply_position`

- API: `public`

```gdscript
var apply_position: bool = true
```

是否应用 position 偏移。

#### `apply_rotation`

- API: `public`

```gdscript
var apply_rotation: bool = true
```

是否应用 rotation_degrees 偏移。

#### `apply_scale`

- API: `public`

```gdscript
var apply_scale: bool = false
```

是否应用 scale 偏移。

#### `capture_on_ready`

- API: `public`

```gdscript
var capture_on_ready: bool = true
```

ready 时是否记录基础变换。

#### `restore_on_exit`

- API: `public`

```gdscript
var restore_on_exit: bool = true
```

退出树时是否恢复基础变换。

#### `utility`

- API: `public`

```gdscript
var utility: GFShakeUtility = null
```

可选反馈工具实例；为空时从全局架构查询。

### Methods

#### `set_utility`

- API: `public`

```gdscript
func set_utility(shake_utility: GFShakeUtility) -> void:
```

设置反馈工具实例。

Parameters:

| Name | Description |
|---|---|
| `shake_utility` | 反馈工具实例。 |

#### `get_target`

- API: `public`

```gdscript
func get_target() -> Node3D:
```

获取当前目标节点。

Returns: 目标 Node3D；不存在时返回 null。

#### `capture_base_transform`

- API: `public`

```gdscript
func capture_base_transform() -> bool:
```

记录当前目标基础变换。

Returns: 记录成功返回 true。

#### `apply_current_sample`

- API: `public`

```gdscript
func apply_current_sample() -> bool:
```

应用当前 channel 采样。

Returns: 应用成功返回 true。

#### `reset_to_base`

- API: `public`

```gdscript
func reset_to_base() -> bool:
```

恢复目标基础变换。

Returns: 恢复成功返回 true。

## GFShakeTrack

- Path: `addons/gf/extensions/feedback/resources/gf_shake_track.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFShakeTrack: 通用反馈采样轨道。 描述一段可组合的反馈偏移轨道，供 GFShakePreset 混合采样。 轨道只输出通用 position、rotation_degrees 和 scale 偏移，不绑定目标节点或业务事件。

### Enums

#### `Waveform`

- API: `public`

```gdscript
enum Waveform { ## 正弦波，适合可预期的摆动。 SINE, ## 逐步随机值，适合短促冲击。 RANDOM, ## 平滑随机值，适合持续扰动。 NOISE, ## 使用 wave_curve 采样，曲线值 0.5 表示零偏移。 CURVE, }
```

反馈采样波形。

#### `BlendMode`

- API: `public`

```gdscript
enum BlendMode { ## 叠加到已有采样上。 ADD, ## 覆盖已有采样。 OVERRIDE, ## 按分量相乘。 MULTIPLY, ## 从已有采样中减去当前轨道。 SUBTRACT, ## 与已有采样求平均。 AVERAGE, ## 逐分量取最大值。 MAX, ## 逐分量取最小值。 MIN, }
```

轨道混合模式。

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用该轨道。

#### `blend_mode`

- API: `public`

```gdscript
var blend_mode: BlendMode = BlendMode.ADD
```

轨道混合模式。

#### `waveform`

- API: `public`

```gdscript
var waveform: Waveform = Waveform.NOISE
```

轨道采样波形。

#### `start_progress`

- API: `public`

```gdscript
var start_progress: float = 0.0
```

轨道开始进度，范围 0 到 1。

#### `end_progress`

- API: `public`

```gdscript
var end_progress: float = 1.0
```

轨道结束进度，范围 0 到 1。

#### `amplitude`

- API: `public`

```gdscript
var amplitude: float = 1.0
```

轨道振幅倍率。

#### `frequency`

- API: `public`

```gdscript
var frequency: float = 24.0
```

每秒采样频率。

#### `position_axis`

- API: `public`

```gdscript
var position_axis: Vector3 = Vector3.ONE
```

位移轴权重。

#### `rotation_axis_degrees`

- API: `public`

```gdscript
var rotation_axis_degrees: Vector3 = Vector3.ZERO
```

旋转轴权重，单位度。

#### `scale_axis`

- API: `public`

```gdscript
var scale_axis: Vector3 = Vector3.ZERO
```

缩放偏移轴权重。

#### `envelope_curve`

- API: `public`

```gdscript
var envelope_curve: Curve = null
```

轨道包络曲线。为空时使用线性衰减。

#### `wave_curve`

- API: `public`

```gdscript
var wave_curve: Curve = null
```

自定义波形曲线。仅在 waveform 为 CURVE 时使用。

#### `sample_seed`

- API: `public`

```gdscript
var sample_seed: int = 1
```

确定性采样种子。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，项目自定义轨道元数据；框架会在采样结果中复制透传。

### Methods

#### `sample`

- API: `public`

```gdscript
func sample( preset_progress: float, elapsed_seconds: float, strength: float = 1.0, phase_offset: float = 0.0 ) -> Dictionary:
```

按预设归一化进度采样轨道。

Parameters:

| Name | Description |
|---|---|
| `preset_progress` | 预设归一化进度，范围 0 到 1。 |
| `elapsed_seconds` | 预设已播放秒数。 |
| `strength` | 播放强度倍率。 |
| `phase_offset` | 相位偏移。 |

Returns: 采样结果字典。

Schemas:

- `return`: Dictionary，包含 position: Vector3、rotation_degrees: Vector3、scale: Vector3、intensity: float、progress: float、track_progress: float 与 metadata: Dictionary。

#### `zero_sample`

- API: `public`

```gdscript
static func zero_sample() -> Dictionary:
```

创建空采样结果。

Returns: 空采样结果字典。

Schemas:

- `return`: Dictionary，包含零值 position、rotation_degrees、scale、intensity、progress、track_progress 与空 metadata。

#### `blend_sample`

- API: `public`

```gdscript
static func blend_sample(base_sample: Dictionary, track_sample: Dictionary, mode: BlendMode) -> Dictionary:
```

将轨道采样混合到当前采样。

Parameters:

| Name | Description |
|---|---|
| `base_sample` | 当前合成采样。 |
| `track_sample` | 轨道采样。 |
| `mode` | 混合模式。 |

Returns: 合成后的采样。

Schemas:

- `base_sample`: Dictionary，包含 position、rotation_degrees、scale、intensity 与 progress 字段的当前合成采样。
- `track_sample`: Dictionary，包含 position、rotation_degrees、scale、intensity 与 progress 字段的轨道采样。
- `return`: Dictionary，合并后的反馈采样，包含 position、rotation_degrees、scale、intensity 与 progress。

## GFShakeUtility

- Path: `addons/gf/extensions/feedback/runtime/gf_shake_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFShakeUtility: 通用反馈播放与采样工具。 管理命名 channel 上的 `GFShakePreset` 播放状态，项目可按需把采样结果应用到 Camera、Node2D、Node3D、Control 或任意自定义表现对象。

### Signals

#### `shake_started`

- API: `public`

```gdscript
signal shake_started(shake_id: int, channel: StringName)
```

反馈播放开始时发出。

Parameters:

| Name | Description |
|---|---|
| `shake_id` | 播放实例 ID。 |
| `channel` | 反馈 channel。 |

#### `shake_finished`

- API: `public`

```gdscript
signal shake_finished(shake_id: int, channel: StringName)
```

反馈播放结束时发出。

Parameters:

| Name | Description |
|---|---|
| `shake_id` | 播放实例 ID。 |
| `channel` | 反馈 channel。 |

#### `shake_stopped`

- API: `public`

```gdscript
signal shake_stopped(shake_id: int, channel: StringName)
```

反馈播放被停止时发出。

Parameters:

| Name | Description |
|---|---|
| `shake_id` | 播放实例 ID。 |
| `channel` | 反馈 channel。 |

### Enums

#### `OverflowPolicy`

- API: `public`

```gdscript
enum OverflowPolicy { ## 跳过新的播放请求。 SKIP_NEW, ## 停止最早的播放实例。 STOP_OLDEST, }
```

活跃反馈达到上限时的处理方式。

### Properties

#### `default_channel`

- API: `public`

```gdscript
var default_channel: StringName = &"default"
```

默认 channel。

#### `max_active_shakes`

- API: `public`

```gdscript
var max_active_shakes: int = 64
```

最大活跃反馈数量；小于等于 0 表示不限制。

#### `overflow_policy`

- API: `public`

```gdscript
var overflow_policy: OverflowPolicy = OverflowPolicy.STOP_OLDEST
```

达到上限时的处理方式。

#### `randomize_phase`

- API: `public`

```gdscript
var randomize_phase: bool = true
```

是否为每次播放随机化相位。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化反馈运行时状态和随机源。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放全部反馈播放状态。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

推进反馈播放状态。

Parameters:

| Name | Description |
|---|---|
| `delta` | 本帧时间增量。 |

#### `play_shake`

- API: `public`

```gdscript
func play_shake( channel: StringName, preset: GFShakePreset, strength: float = 1.0, metadata: Dictionary = {} ) -> int:
```

播放一个反馈预设。

Parameters:

| Name | Description |
|---|---|
| `channel` | 反馈 channel；为空时使用 default_channel。 |
| `preset` | 反馈预设。 |
| `strength` | 播放强度倍率。 |
| `metadata` | 项目自定义元数据。 |

Returns: 播放实例 ID；无法播放时返回 -1。

Schemas:

- `metadata`: Dictionary，播放实例自定义元数据，会在 get_shake_info() 快照中复制返回。

#### `stop_shake`

- API: `public`

```gdscript
func stop_shake(shake_id: int, emit_stopped: bool = true) -> bool:
```

停止指定反馈实例。

Parameters:

| Name | Description |
|---|---|
| `shake_id` | 播放实例 ID。 |
| `emit_stopped` | 是否发出停止信号。 |

Returns: 成功停止返回 true。

#### `stop_channel`

- API: `public`

```gdscript
func stop_channel(channel: StringName) -> int:
```

停止指定 channel 上的全部反馈实例。

Parameters:

| Name | Description |
|---|---|
| `channel` | 反馈 channel；为空时使用 default_channel。 |

Returns: 停止数量。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空全部反馈实例。

#### `is_shake_active`

- API: `public`

```gdscript
func is_shake_active(shake_id: int) -> bool:
```

检查反馈实例是否仍在播放。

Parameters:

| Name | Description |
|---|---|
| `shake_id` | 播放实例 ID。 |

Returns: 正在播放返回 true。

#### `get_active_shake_count`

- API: `public`

```gdscript
func get_active_shake_count(channel: StringName = &"") -> int:
```

获取活跃反馈数量。

Parameters:

| Name | Description |
|---|---|
| `channel` | 可选 channel；为空时统计全部。 |

Returns: 活跃反馈数量。

#### `sample_channel`

- API: `public`

```gdscript
func sample_channel(channel: StringName = &"") -> Dictionary:
```

采样指定 channel 当前的合成反馈。

Parameters:

| Name | Description |
|---|---|
| `channel` | 反馈 channel；为空时使用 default_channel。 |

Returns: 合成采样结果。

Schemas:

- `return`: Dictionary，包含 position: Vector3、rotation_degrees: Vector3、scale: Vector3、intensity: float 与 progress: float。

#### `sample_channels`

- API: `public`

```gdscript
func sample_channels(channels: PackedStringArray) -> Dictionary:
```

采样多个 channel 当前的合成反馈。

Parameters:

| Name | Description |
|---|---|
| `channels` | 反馈 channel 列表。 |

Returns: 合成采样结果。

Schemas:

- `return`: Dictionary，包含 position: Vector3、rotation_degrees: Vector3、scale: Vector3、intensity: float 与 progress: float。

#### `get_shake_info`

- API: `public`

```gdscript
func get_shake_info(shake_id: int) -> Dictionary:
```

获取指定反馈实例的只读快照。

Parameters:

| Name | Description |
|---|---|
| `shake_id` | 播放实例 ID。 |

Returns: 播放实例快照。

Schemas:

- `return`: Dictionary，包含 id、channel、elapsed_seconds、duration_seconds、strength 与 metadata；实例不存在时为空。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取反馈系统调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含 active_count、max_active_shakes、channels 与 play_order。

