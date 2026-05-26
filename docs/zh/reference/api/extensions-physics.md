# Physics API

Module: `extensions/physics`

## Classes

- [`GFGravityField3D`](#gfgravityfield3d)
- [`GFGravityProbe3D`](#gfgravityprobe3d)

## GFGravityField3D

- Path: `addons/gf/extensions/physics/nodes/gf_gravity_field_3d.gd`
- Extends: `Node3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFGravityField3D: 通用 3D 重力/加速度场。 提供点重力、远离中心和固定方向三种方向模式，以及常量、线性、平方反比 和曲线衰减。项目可继承并重写方向或强度计算以实现更复杂的场。

### Signals

#### `field_changed`

- API: `public`

```gdscript
signal field_changed
```

力场参数变化时发出。

### Enums

#### `DirectionMode`

- API: `public`

```gdscript
enum DirectionMode { ## 朝向力场节点原点。 TOWARD_ORIGIN, ## 远离力场节点原点。 AWAY_FROM_ORIGIN, ## 使用固定方向。 CONSTANT_DIRECTION, }
```

力场方向模式。

#### `FalloffMode`

- API: `public`

```gdscript
enum FalloffMode { ## 半径内保持恒定强度。 CONSTANT, ## 从中心到半径边缘线性衰减。 LINEAR, ## 按平方反比衰减。 INVERSE_SQUARE, ## 使用 Curve 采样衰减；横轴为距离占半径比例。 CURVE, }
```

强度衰减模式。

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true:
```

是否启用力场。

#### `acceleration`

- API: `public`

```gdscript
var acceleration: float = 9.8:
```

基础加速度强度。

#### `radius`

- API: `public`

```gdscript
var radius: float = 0.0:
```

影响半径；小于等于 0 表示无限范围。

#### `min_distance`

- API: `public`

```gdscript
var min_distance: float = 1.0:
```

平方反比模式下用于避免近距离发散的最小距离。

#### `direction_mode`

- API: `public`

```gdscript
var direction_mode: DirectionMode = DirectionMode.TOWARD_ORIGIN:
```

方向模式。

#### `constant_direction`

- API: `public`

```gdscript
var constant_direction: Vector3 = Vector3.DOWN:
```

固定方向模式使用的方向。

#### `falloff_mode`

- API: `public`

```gdscript
var falloff_mode: FalloffMode = FalloffMode.CONSTANT:
```

强度衰减模式。

#### `falloff_curve`

- API: `public`

```gdscript
var falloff_curve: Curve = null:
```

曲线衰减模式使用的 Curve。采样值会乘以 acceleration。

### Methods

#### `get_acceleration_at`

- API: `public`

```gdscript
func get_acceleration_at(world_position: Vector3) -> Vector3:
```

获取指定世界坐标处的加速度向量。

Parameters:

| Name | Description |
|---|---|
| `world_position` | 世界坐标。 |

Returns: 加速度向量。

#### `get_strength_at_distance`

- API: `public`

```gdscript
func get_strength_at_distance(distance: float) -> float:
```

获取指定距离处的力场强度。

Parameters:

| Name | Description |
|---|---|
| `distance` | 距离。 |

Returns: 加速度强度。

## GFGravityProbe3D

- Path: `addons/gf/extensions/physics/nodes/gf_gravity_probe_3d.gd`
- Extends: `Node3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFGravityProbe3D: 通用 3D 重力采样器。 从场景树分组中采样 GFGravityField3D 或任何暴露 get_acceleration_at() 方法的对象，并汇总为当前节点位置处的加速度、上下方向。

### Properties

#### `field_group`

- API: `public`

```gdscript
var field_group: StringName = &"gf_gravity_field_3d"
```

要采样的力场分组。

#### `use_fallback_when_empty`

- API: `public`

```gdscript
var use_fallback_when_empty: bool = true
```

找不到力场时是否返回 fallback_acceleration。

#### `fallback_acceleration`

- API: `public`

```gdscript
var fallback_acceleration: Vector3 = Vector3.DOWN * 9.8
```

找不到力场时使用的默认加速度。

#### `cache_samples_per_frame`

- API: `public`

```gdscript
var cache_samples_per_frame: bool = true
```

同一帧、同一位置重复 sample() 时是否复用上次结果。

#### `last_acceleration`

- API: `public`

```gdscript
var last_acceleration: Vector3 = Vector3.ZERO
```

最近一次 sample() 得到的加速度。

### Methods

#### `sample`

- API: `public`

```gdscript
func sample() -> Vector3:
```

采样场景树分组中的所有力场。

Returns: 汇总后的加速度。

#### `sample_fields`

- API: `public`

```gdscript
func sample_fields(fields: Array) -> Vector3:
```

采样指定力场列表。

Parameters:

| Name | Description |
|---|---|
| `fields` | 力场对象列表。 |

Returns: 汇总后的加速度。

Schemas:

- `fields`: Array，包含 GFGravityField3D 或任何暴露 get_acceleration_at(Vector3) 的 Object。

#### `get_down_direction`

- API: `public`

```gdscript
func get_down_direction() -> Vector3:
```

获取当前位置的向下方向。

Returns: 向下方向。

#### `get_up_direction`

- API: `public`

```gdscript
func get_up_direction() -> Vector3:
```

获取当前位置的向上方向。

Returns: 向上方向。

