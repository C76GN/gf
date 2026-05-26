# Camera API

Module: `extensions/camera`

## Classes

- [`GFCameraBlend`](#gfcamerablend)
- [`GFCameraDirector2D`](#gfcameradirector2d)
- [`GFCameraDirector3D`](#gfcameradirector3d)
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

#### `transition_type`

- API: `public`

```gdscript
var transition_type: Tween.TransitionType = Tween.TRANS_SINE
```

过渡持续时间，单位秒。小于等于 0 时表示立即切换。 Tween 过渡类型。

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

#### `rig_paths`

- API: `public`

```gdscript
var rig_paths: Array[NodePath] = []
```

要控制的 Camera2D。 显式候选 Rig 路径。

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

#### `rig_paths`

- API: `public`

```gdscript
var rig_paths: Array[NodePath] = []
```

要控制的 Camera3D。 显式候选 Rig 路径。

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

#### `offset`

- API: `public`

```gdscript
var offset: Vector2 = Vector2.ZERO
```

可选跟随目标。为空时使用 Rig 自身的全局姿态。 位置偏移。

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

#### `offset`

- API: `public`

```gdscript
var offset: Vector3 = Vector3.ZERO
```

可选跟随目标。为空时使用 Rig 自身的全局姿态。 可选朝向目标。look_at_enabled 为 true 时生效。 位置偏移。

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

