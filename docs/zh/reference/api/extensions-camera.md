# Camera API

Module: `extensions/camera`

## Classes

- [`GFCameraBlend`](#gfcamerablend)
- [`GFCameraDirector2D`](#gfcameradirector2d)
- [`GFCameraDirector3D`](#gfcameradirector3d)
- [`GFCameraOrbitInput3D`](#gfcameraorbitinput3d)
- [`GFCameraOrbitRig3D`](#gfcameraorbitrig3d)
- [`GFCameraRig2D`](#gfcamerarig2d)
- [`GFCameraRig3D`](#gfcamerarig3d)

## GFCameraBlend

- Path: `addons/gf/extensions/camera/resources/gf_camera_blend.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFCameraBlend: 通用相机过渡资源。 描述两个相机姿态之间的时间和缓动方式，不绑定具体相机节点、 目标选择规则、反馈效果或场景业务。

### Properties

#### `duration_seconds`

- API: `public`

```gdscript
var duration_seconds: float = 0.35
```

过渡持续时间，单位秒。小于等于 0 时表示立即切换。

#### `transition_type`

- API: `public`

```gdscript
var transition_type: Tween.TransitionType = Tween.TRANS_SINE
```

Tween 过渡类型。

#### `ease_type`

- API: `public`

```gdscript
var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
```

Tween 缓动类型。

### Methods

#### `is_instant`

- API: `public`

```gdscript
func is_instant() -> bool:
```

是否为立即切换。

Returns: 持续时间小于等于 0 时返回 true。

#### `sample_weight`

- API: `public`

```gdscript
func sample_weight(elapsed_seconds: float) -> float:
```

按已过时间采样 0..1 权重。

Parameters:

| Name | Description |
|---|---|
| `elapsed_seconds` | 已过时间。 |

Returns: 缓动后的权重。

#### `duplicate_blend`

- API: `public`

```gdscript
func duplicate_blend() -> GFCameraBlend:
```

创建深拷贝。

Returns: 新过渡资源。

## GFCameraDirector2D

- Path: `addons/gf/extensions/camera/nodes/gf_camera_director_2d.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFCameraDirector2D: 通用 2D 相机编排节点。 Director 从显式路径或分组中收集 GFCameraRig2D，按优先级选择当前 Rig， 并把过渡后的姿态应用到 Camera2D。它不规定目标含义、输入来源或业务流程。

### Signals

#### `active_rig_changed`

- API: `public`

```gdscript
signal active_rig_changed(previous_rig: GFCameraRig2D, new_rig: GFCameraRig2D)
```

当前 Rig 变化后发出。

Parameters:

| Name | Description |
|---|---|
| `previous_rig` | 上一个 Rig。 |
| `new_rig` | 新 Rig。 |

#### `camera_pose_applied`

- API: `public`

```gdscript
signal camera_pose_applied(rig: GFCameraRig2D)
```

相机姿态应用后发出。

Parameters:

| Name | Description |
|---|---|
| `rig` | 当前 Rig。 |

### Enums

#### `UpdateMode`

- API: `public`

```gdscript
enum UpdateMode { ## 在 _process 中更新。 IDLE, ## 在 _physics_process 中更新。 PHYSICS, ## 只在 process_camera() 被显式调用时更新。 MANUAL, }
```

Director 自动更新模式。

### Properties

#### `camera_path`

- API: `public`

```gdscript
var camera_path: NodePath = NodePath("")
```

要控制的 Camera2D。

#### `rig_paths`

- API: `public`

```gdscript
var rig_paths: Array[NodePath] = []
```

显式候选 Rig 路径。

Schemas:

- `rig_paths`: Array[NodePath]，按顺序保存显式候选 GFCameraRig2D 节点路径。

#### `collect_group_rigs`

- API: `public`

```gdscript
var collect_group_rigs: bool = true
```

是否按分组收集候选 Rig。

#### `rig_group_name`

- API: `public`

```gdscript
var rig_group_name: StringName = &"gf_camera_rig_2d"
```

候选 Rig 分组名。

#### `update_mode`

- API: `public`

```gdscript
var update_mode: UpdateMode = UpdateMode.IDLE
```

自动更新模式。

#### `default_blend`

- API: `public`

```gdscript
var default_blend: GFCameraBlend = GFCameraBlend.new()
```

默认过渡资源。Rig 没有设置 blend 时使用它。

#### `keep_camera_when_no_rig`

- API: `public`

```gdscript
var keep_camera_when_no_rig: bool = true
```

没有 Rig 时是否保持相机当前姿态。

### Methods

#### `get_camera`

- API: `public`

```gdscript
func get_camera() -> Camera2D:
```

获取当前相机。

Returns: Camera2D；不存在时返回 null。

#### `get_active_rig`

- API: `public`

```gdscript
func get_active_rig() -> GFCameraRig2D:
```

获取当前激活 Rig。

Returns: 当前 Rig；没有时返回 null。

#### `collect_candidate_rigs`

- API: `public`

```gdscript
func collect_candidate_rigs() -> Array[GFCameraRig2D]:
```

收集候选 Rig。

Returns: 候选 Rig 列表。

Schemas:

- `return`: Array[GFCameraRig2D]，已去重并按优先级排序的候选 Rig。

#### `refresh_active_rig`

- API: `public`

```gdscript
func refresh_active_rig(force_snap: bool = false) -> GFCameraRig2D:
```

刷新当前激活 Rig。

Parameters:

| Name | Description |
|---|---|
| `force_snap` | 为 true 时立即切到新 Rig。 |

Returns: 当前 Rig。

#### `set_active_rig`

- API: `public`

```gdscript
func set_active_rig(rig: GFCameraRig2D, force_snap: bool = false) -> bool:
```

显式设置当前 Rig。

Parameters:

| Name | Description |
|---|---|
| `rig` | 新 Rig；可为 null。 |
| `force_snap` | 为 true 时立即切换。 |

Returns: 设置成功返回 true。

#### `process_camera`

- API: `public`

```gdscript
func process_camera(delta: float) -> bool:
```

推进并应用相机姿态。

Parameters:

| Name | Description |
|---|---|
| `delta` | 秒。 |

Returns: 成功应用时返回 true。

## GFCameraDirector3D

- Path: `addons/gf/extensions/camera/nodes/gf_camera_director_3d.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFCameraDirector3D: 通用 3D 相机编排节点。 Director 从显式路径或分组中收集 GFCameraRig3D，按优先级选择当前 Rig， 并把过渡后的 Transform 应用到 Camera3D。它不规定目标含义、输入来源或业务流程。

### Signals

#### `active_rig_changed`

- API: `public`

```gdscript
signal active_rig_changed(previous_rig: GFCameraRig3D, new_rig: GFCameraRig3D)
```

当前 Rig 变化后发出。

Parameters:

| Name | Description |
|---|---|
| `previous_rig` | 上一个 Rig。 |
| `new_rig` | 新 Rig。 |

#### `camera_pose_applied`

- API: `public`

```gdscript
signal camera_pose_applied(rig: GFCameraRig3D)
```

相机姿态应用后发出。

Parameters:

| Name | Description |
|---|---|
| `rig` | 当前 Rig。 |

### Enums

#### `UpdateMode`

- API: `public`

```gdscript
enum UpdateMode { ## 在 _process 中更新。 IDLE, ## 在 _physics_process 中更新。 PHYSICS, ## 只在 process_camera() 被显式调用时更新。 MANUAL, }
```

Director 自动更新模式。

### Properties

#### `camera_path`

- API: `public`

```gdscript
var camera_path: NodePath = NodePath("")
```

要控制的 Camera3D。

#### `rig_paths`

- API: `public`

```gdscript
var rig_paths: Array[NodePath] = []
```

显式候选 Rig 路径。

Schemas:

- `rig_paths`: Array[NodePath]，按顺序保存显式候选 GFCameraRig3D 节点路径。

#### `collect_group_rigs`

- API: `public`

```gdscript
var collect_group_rigs: bool = true
```

是否按分组收集候选 Rig。

#### `rig_group_name`

- API: `public`

```gdscript
var rig_group_name: StringName = &"gf_camera_rig_3d"
```

候选 Rig 分组名。

#### `update_mode`

- API: `public`

```gdscript
var update_mode: UpdateMode = UpdateMode.IDLE
```

自动更新模式。

#### `default_blend`

- API: `public`

```gdscript
var default_blend: GFCameraBlend = GFCameraBlend.new()
```

默认过渡资源。Rig 没有设置 blend 时使用它。

#### `keep_camera_when_no_rig`

- API: `public`

```gdscript
var keep_camera_when_no_rig: bool = true
```

没有 Rig 时是否保持相机当前姿态。

### Methods

#### `get_camera`

- API: `public`

```gdscript
func get_camera() -> Camera3D:
```

获取当前相机。

Returns: Camera3D；不存在时返回 null。

#### `get_active_rig`

- API: `public`

```gdscript
func get_active_rig() -> GFCameraRig3D:
```

获取当前激活 Rig。

Returns: 当前 Rig；没有时返回 null。

#### `collect_candidate_rigs`

- API: `public`

```gdscript
func collect_candidate_rigs() -> Array[GFCameraRig3D]:
```

收集候选 Rig。

Returns: 候选 Rig 列表。

Schemas:

- `return`: Array[GFCameraRig3D]，已去重并按优先级排序的候选 Rig。

#### `refresh_active_rig`

- API: `public`

```gdscript
func refresh_active_rig(force_snap: bool = false) -> GFCameraRig3D:
```

刷新当前激活 Rig。

Parameters:

| Name | Description |
|---|---|
| `force_snap` | 为 true 时立即切到新 Rig。 |

Returns: 当前 Rig。

#### `set_active_rig`

- API: `public`

```gdscript
func set_active_rig(rig: GFCameraRig3D, force_snap: bool = false) -> bool:
```

显式设置当前 Rig。

Parameters:

| Name | Description |
|---|---|
| `rig` | 新 Rig；可为 null。 |
| `force_snap` | 为 true 时立即切换。 |

Returns: 设置成功返回 true。

#### `process_camera`

- API: `public`

```gdscript
func process_camera(delta: float) -> bool:
```

推进并应用相机姿态。

Parameters:

| Name | Description |
|---|---|
| `delta` | 秒。 |

Returns: 成功应用时返回 true。

## GFCameraOrbitInput3D

- Path: `addons/gf/extensions/camera/nodes/gf_camera_orbit_input_3d.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_service`
- Since: `3.23.0`

GFCameraOrbitInput3D: 通用 3D 环绕相机输入桥接节点。 将 GFInputMappingUtility 的可配置动作值或鼠标拖拽转换为 GFCameraOrbitRig3D 的角度和距离增量。 它不创建输入上下文，也不定义项目动作绑定。

### Enums

#### `UpdateMode`

- API: `public`

```gdscript
enum UpdateMode { ## 在 _process 中读取输入。 IDLE, ## 在 _physics_process 中读取输入。 PHYSICS, ## 只在 process_input() 被显式调用时读取输入。 MANUAL, }
```

输入自动处理模式。

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用输入桥接。

#### `orbit_rig_path`

- API: `public`

```gdscript
var orbit_rig_path: NodePath = NodePath("")
```

要控制的环绕 Rig。为空时使用父节点中的 GFCameraOrbitRig3D。

#### `update_mode`

- API: `public`

```gdscript
var update_mode: UpdateMode = UpdateMode.IDLE
```

自动处理模式。

#### `use_input_mapping`

- API: `public`

```gdscript
var use_input_mapping: bool = false
```

是否从 GFInputMappingUtility 读取动作值。默认关闭，项目应显式启用并配置动作 ID。

#### `node_context_path`

- API: `public`

```gdscript
var node_context_path: NodePath = NodePath("")
```

可选 GFNodeContext 路径。设置后会从该上下文获取 GFInputMappingUtility。

#### `orbit_action_id`

- API: `public`

```gdscript
var orbit_action_id: StringName = &"camera_orbit"
```

环绕输入动作 ID。动作值应为 Vector2。

#### `zoom_action_id`

- API: `public`

```gdscript
var zoom_action_id: StringName = &"camera_zoom"
```

缩放输入动作 ID。动作值应为 float 或 bool。

#### `orbit_degrees_per_second`

- API: `public`

```gdscript
var orbit_degrees_per_second: float = 120.0
```

每秒环绕角速度，单位度。

#### `zoom_units_per_second`

- API: `public`

```gdscript
var zoom_units_per_second: float = 8.0
```

每秒缩放速度，单位距离。

#### `invert_y`

- API: `public`

```gdscript
var invert_y: bool = false
```

是否反转垂直环绕输入。

#### `mouse_orbit_enabled`

- API: `public`

```gdscript
var mouse_orbit_enabled: bool = false
```

是否启用鼠标拖拽环绕。默认关闭，避免框架节点隐式接管项目输入。

#### `mouse_button`

- API: `public`

```gdscript
var mouse_button: MouseButton = MOUSE_BUTTON_RIGHT
```

鼠标拖拽环绕使用的按键。

#### `mouse_degrees_per_pixel`

- API: `public`

```gdscript
var mouse_degrees_per_pixel: float = 0.15
```

鼠标每像素对应的角度。

#### `mouse_zoom_enabled`

- API: `public`

```gdscript
var mouse_zoom_enabled: bool = false
```

是否启用鼠标滚轮缩放。默认关闭，避免框架节点隐式接管项目输入。

#### `mouse_wheel_step`

- API: `public`

```gdscript
var mouse_wheel_step: float = 1.0
```

鼠标滚轮每格缩放距离。

#### `consume_mouse_input`

- API: `public`

```gdscript
var consume_mouse_input: bool = true
```

鼠标输入被应用后是否标记为已处理。

#### `input_mapping_utility`

- API: `public`

```gdscript
var input_mapping_utility: GFInputMappingUtility = null
```

显式注入的输入映射工具。为空时尝试从 node_context_path 或父级 GFNodeContext 获取。

### Methods

#### `get_orbit_rig`

- API: `public`

```gdscript
func get_orbit_rig() -> GFCameraOrbitRig3D:
```

获取当前控制的环绕 Rig。

Returns: 环绕 Rig；不存在时返回 null。

#### `set_input_mapping_utility`

- API: `public`

```gdscript
func set_input_mapping_utility(utility: GFInputMappingUtility) -> void:
```

显式设置输入映射工具。

Parameters:

| Name | Description |
|---|---|
| `utility` | 输入映射工具；传 null 表示回退到上下文查找。 |

#### `process_input`

- API: `public`

```gdscript
func process_input(delta: float) -> bool:
```

读取输入映射并推进环绕 Rig。

Parameters:

| Name | Description |
|---|---|
| `delta` | 本帧时间增量（秒）。 |

Returns: 应用了任意输入时返回 true。

#### `apply_orbit_vector`

- API: `public`

```gdscript
func apply_orbit_vector(value: Vector2, scale: float = 1.0) -> bool:
```

应用二维环绕输入。

Parameters:

| Name | Description |
|---|---|
| `value` | x 为 yaw 输入，y 为 pitch 输入。 |
| `scale` | 输入缩放量，通常是每秒速度乘以 delta。 |

Returns: 成功应用时返回 true。

#### `apply_zoom_value`

- API: `public`

```gdscript
func apply_zoom_value(value: float, scale: float = 1.0) -> bool:
```

应用一维缩放输入。

Parameters:

| Name | Description |
|---|---|
| `value` | 缩放输入；正数拉远，负数拉近。 |
| `scale` | 输入缩放量，通常是每秒速度乘以 delta。 |

Returns: 成功应用时返回 true。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取输入桥接调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含 enabled、update_mode、use_input_mapping、orbit_action_id、zoom_action_id、has_rig 和 has_input_mapping。

## GFCameraOrbitRig3D

- Path: `addons/gf/extensions/camera/nodes/gf_camera_orbit_rig_3d.gd`
- Extends: `GFCameraRig3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.23.0`

GFCameraOrbitRig3D: 通用 3D 环绕相机 Rig。 基于目标焦点、yaw / pitch 和距离计算期望 Camera3D Transform。 它只描述相机姿态，不处理碰撞、锁定目标、遮挡或具体玩法输入。

### Signals

#### `orbit_changed`

- API: `public`

```gdscript
signal orbit_changed(yaw_degrees_value: float, pitch_degrees_value: float, distance_value: float)
```

环绕参数变化后发出。

Parameters:

| Name | Description |
|---|---|
| `yaw_degrees_value` | 当前水平角度。 |
| `pitch_degrees_value` | 当前俯仰角度。 |
| `distance_value` | 当前距离。 |

### Properties

#### `yaw_degrees`

- API: `public`

```gdscript
var yaw_degrees: float = 0.0:
```

水平角度，单位度。

#### `pitch_degrees`

- API: `public`

```gdscript
var pitch_degrees: float = -20.0:
```

俯仰角度，单位度。

#### `distance`

- API: `public`

```gdscript
var distance: float = 8.0:
```

与焦点的距离。

#### `min_distance`

- API: `public`

```gdscript
var min_distance: float = 1.0:
```

最小距离。

#### `max_distance`

- API: `public`

```gdscript
var max_distance: float = 50.0:
```

最大距离。

#### `min_pitch_degrees`

- API: `public`

```gdscript
var min_pitch_degrees: float = -80.0:
```

最小俯仰角度。

#### `max_pitch_degrees`

- API: `public`

```gdscript
var max_pitch_degrees: float = 80.0:
```

最大俯仰角度。

#### `look_at_focus`

- API: `public`

```gdscript
var look_at_focus: bool = true
```

是否让相机始终朝向焦点。

#### `orbit_up_axis`

- API: `public`

```gdscript
var orbit_up_axis: Vector3 = Vector3.UP
```

环绕相机的上方向。为零向量时回退到 Vector3.UP。

### Methods

#### `get_focus_position`

- API: `public`

```gdscript
func get_focus_position() -> Vector3:
```

获取环绕焦点位置。

Returns: 当前焦点的全局位置。

#### `get_orbit_direction`

- API: `public`

```gdscript
func get_orbit_direction() -> Vector3:
```

获取从焦点指向相机的单位方向。

Returns: 环绕方向。

#### `get_camera_transform`

- API: `public`

```gdscript
func get_camera_transform() -> Transform3D:
```

获取当前期望相机 Transform。

Returns: 期望全局 Transform。

#### `set_orbit`

- API: `public`

```gdscript
func set_orbit(new_yaw_degrees: float, new_pitch_degrees: float, new_distance: float) -> void:
```

设置环绕参数。

Parameters:

| Name | Description |
|---|---|
| `new_yaw_degrees` | 水平角度，单位度。 |
| `new_pitch_degrees` | 俯仰角度，单位度。 |
| `new_distance` | 与焦点的距离。 |

#### `apply_orbit_delta`

- API: `public`

```gdscript
func apply_orbit_delta(delta_degrees: Vector2) -> void:
```

应用环绕角度增量。

Parameters:

| Name | Description |
|---|---|
| `delta_degrees` | x 为 yaw 增量，y 为 pitch 增量，单位度。 |

#### `apply_zoom_delta`

- API: `public`

```gdscript
func apply_zoom_delta(delta_distance: float) -> void:
```

应用距离增量。

Parameters:

| Name | Description |
|---|---|
| `delta_distance` | 距离增量；正数拉远，负数拉近。 |

#### `clamp_orbit`

- API: `public`

```gdscript
func clamp_orbit() -> void:
```

按当前上下限夹紧环绕参数。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取环绕 Rig 调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含 yaw_degrees、pitch_degrees、distance、focus_position 和 direction。

## GFCameraRig2D

- Path: `addons/gf/extensions/camera/nodes/gf_camera_rig_2d.gd`
- Extends: `Node2D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFCameraRig2D: 通用 2D 相机姿态提供节点。 Rig 只计算期望相机位置、旋转和缩放，不直接控制 Camera2D。 项目可用多个 Rig 表达不同视角，再交给 GFCameraDirector2D 按优先级选择。

### Signals

#### `active_changed`

- API: `public`

```gdscript
signal active_changed(active: bool)
```

Rig 激活状态变化后发出。

Parameters:

| Name | Description |
|---|---|
| `active` | 当前是否激活。 |

#### `priority_changed`

- API: `public`

```gdscript
signal priority_changed(priority: int)
```

Rig 优先级变化后发出。

Parameters:

| Name | Description |
|---|---|
| `priority` | 当前优先级。 |

### Properties

#### `active`

- API: `public`

```gdscript
var active: bool = true:
```

是否参与 Director 选择。

#### `priority`

- API: `public`

```gdscript
var priority: int = 0:
```

选择优先级。数值越大越优先。

#### `target_path`

- API: `public`

```gdscript
var target_path: NodePath = NodePath("")
```

可选跟随目标。为空时使用 Rig 自身的全局姿态。

#### `offset`

- API: `public`

```gdscript
var offset: Vector2 = Vector2.ZERO
```

位置偏移。

#### `offset_follows_rotation`

- API: `public`

```gdscript
var offset_follows_rotation: bool = false
```

偏移是否跟随目标旋转。

#### `use_target_rotation`

- API: `public`

```gdscript
var use_target_rotation: bool = true
```

是否读取目标旋转。

#### `rotation_degrees_offset`

- API: `public`

```gdscript
var rotation_degrees_offset: float = 0.0
```

额外旋转偏移，单位度。

#### `zoom`

- API: `public`

```gdscript
var zoom: Vector2 = Vector2.ONE
```

期望相机缩放。

#### `blend`

- API: `public`

```gdscript
var blend: GFCameraBlend = null
```

进入该 Rig 时使用的过渡。为空时使用 Director 默认过渡。

#### `group_name`

- API: `public`

```gdscript
var group_name: StringName = &"gf_camera_rig_2d"
```

自动加入的分组名。Director 可按该分组收集候选。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，项目自定义元数据；框架不会读取或改写其中字段。

### Methods

#### `get_target_node`

- API: `public`

```gdscript
func get_target_node() -> Node2D:
```

获取跟随目标。

Returns: 目标 Node2D；不存在时返回 null。

#### `get_camera_pose`

- API: `public`

```gdscript
func get_camera_pose() -> Dictionary:
```

获取当前期望相机姿态。

Returns: 包含 position、rotation、zoom 和 rig 的字典。

Schemas:

- `return`: Dictionary，包含 position: Vector2、rotation: float、zoom: Vector2 与 rig: GFCameraRig2D。

#### `is_available`

- API: `public`

```gdscript
func is_available() -> bool:
```

检查 Rig 是否可被选择。

Returns: 可用时返回 true。

## GFCameraRig3D

- Path: `addons/gf/extensions/camera/nodes/gf_camera_rig_3d.gd`
- Extends: `Node3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFCameraRig3D: 通用 3D 相机姿态提供节点。 Rig 只计算期望 Camera3D Transform，不直接控制 Camera3D。 项目可用多个 Rig 表达不同视角，再交给 GFCameraDirector3D 按优先级选择。

### Signals

#### `active_changed`

- API: `public`

```gdscript
signal active_changed(active: bool)
```

Rig 激活状态变化后发出。

Parameters:

| Name | Description |
|---|---|
| `active` | 当前是否激活。 |

#### `priority_changed`

- API: `public`

```gdscript
signal priority_changed(priority: int)
```

Rig 优先级变化后发出。

Parameters:

| Name | Description |
|---|---|
| `priority` | 当前优先级。 |

### Properties

#### `active`

- API: `public`

```gdscript
var active: bool = true:
```

是否参与 Director 选择。

#### `priority`

- API: `public`

```gdscript
var priority: int = 0:
```

选择优先级。数值越大越优先。

#### `target_path`

- API: `public`

```gdscript
var target_path: NodePath = NodePath("")
```

可选跟随目标。为空时使用 Rig 自身的全局姿态。

#### `look_at_target_path`

- API: `public`

```gdscript
var look_at_target_path: NodePath = NodePath("")
```

可选朝向目标。look_at_enabled 为 true 时生效。

#### `offset`

- API: `public`

```gdscript
var offset: Vector3 = Vector3.ZERO
```

位置偏移。

#### `offset_follows_rotation`

- API: `public`

```gdscript
var offset_follows_rotation: bool = false
```

偏移是否跟随目标旋转。

#### `use_target_rotation`

- API: `public`

```gdscript
var use_target_rotation: bool = true
```

是否读取目标旋转。

#### `look_at_enabled`

- API: `public`

```gdscript
var look_at_enabled: bool = false
```

是否朝向 look_at_target_path。

#### `up_axis`

- API: `public`

```gdscript
var up_axis: Vector3 = Vector3.UP
```

look_at 使用的上方向。为零向量时会回退到 Vector3.UP。

#### `rotation_degrees_offset`

- API: `public`

```gdscript
var rotation_degrees_offset: Vector3 = Vector3.ZERO
```

额外旋转偏移，单位度。

#### `blend`

- API: `public`

```gdscript
var blend: GFCameraBlend = null
```

进入该 Rig 时使用的过渡。为空时使用 Director 默认过渡。

#### `group_name`

- API: `public`

```gdscript
var group_name: StringName = &"gf_camera_rig_3d"
```

自动加入的分组名。Director 可按该分组收集候选。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，项目自定义元数据；框架不会读取或改写其中字段。

### Methods

#### `get_target_node`

- API: `public`

```gdscript
func get_target_node() -> Node3D:
```

获取跟随目标。

Returns: 目标 Node3D；不存在时返回 null。

#### `get_look_at_target_node`

- API: `public`

```gdscript
func get_look_at_target_node() -> Node3D:
```

获取朝向目标。

Returns: 目标 Node3D；不存在时返回 null。

#### `get_camera_transform`

- API: `public`

```gdscript
func get_camera_transform() -> Transform3D:
```

获取当前期望相机 Transform。

Returns: 期望全局 Transform。

#### `is_available`

- API: `public`

```gdscript
func is_available() -> bool:
```

检查 Rig 是否可被选择。

Returns: 可用时返回 true。

