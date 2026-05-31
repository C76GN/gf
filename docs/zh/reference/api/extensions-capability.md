# Capability API

Module: `extensions/capability`

## Classes

- [`GFCapability`](#gfcapability)
- [`GFCapabilityContainer`](#gfcapabilitycontainer)
- [`GFCapabilityRecipe`](#gfcapabilityrecipe)
- [`GFCapabilityRecipeEntry`](#gfcapabilityrecipeentry)
- [`GFCapabilityUtility`](#gfcapabilityutility)
- [`GFControlCapability`](#gfcontrolcapability)
- [`GFNode2DCapability`](#gfnode2dcapability)
- [`GFNode3DCapability`](#gfnode3dcapability)
- [`GFNodeCapability`](#gfnodecapability)
- [`GFPropertyBagCapability`](#gfpropertybagcapability)

## GFCapability

- Path: `addons/gf/extensions/capability/core/gf_capability.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFCapability: 可挂载到任意 Object 的能力组件基类。 适合承载可复用的实体能力，例如 Health、Interactable、Selectable 等。 能力实例由 GFCapabilityUtility 挂载、查询与移除。

### Properties

#### `required_capabilities`

- API: `public`

```gdscript
var required_capabilities: Array[Script] = []
```

当前能力依赖的其他能力类型。运行时挂载前会先确保这些能力存在。

#### `receiver`

- API: `public`

```gdscript
var receiver: Object = null
```

当前能力所属对象。由 GFCapabilityUtility 挂载时写入。

#### `active`

- API: `public`

```gdscript
var active: bool = true
```

当前能力是否启用。请优先通过 GFCapabilityUtility.set_capability_active() 修改。

### Methods

#### `get_required_capabilities`

- API: `public`

```gdscript
func get_required_capabilities() -> Array[Script]:
```

返回当前能力依赖的其他能力类型。 默认返回 required_capabilities；只有运行时动态依赖才建议在子类中重写。 GFCapabilityUtility 会在挂载当前能力前先确保这些能力存在。

Returns: 当前能力依赖的能力脚本类型列表。

#### `get_dependency_removal_policy`

- API: `public`

```gdscript
func get_dependency_removal_policy() -> int:
```

返回移除当前能力时对自动补齐依赖能力的处理策略。

Returns: DependencyRemovalPolicy 枚举值。

#### `on_gf_capability_added`

- API: `public`

```gdscript
func on_gf_capability_added(target: Object) -> void:
```

能力挂载到对象后调用。

Parameters:

| Name | Description |
|---|---|
| `target` | 当前能力所属对象。 |

#### `on_gf_capability_removed`

- API: `public`

```gdscript
func on_gf_capability_removed(_target: Object) -> void:
```

能力从对象移除前调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |

#### `on_gf_capability_active_changed`

- API: `public`

```gdscript
func on_gf_capability_active_changed(_target: Object, _active: bool) -> void:
```

能力启停状态变化后调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |
| `_active` | 当前启停状态。 |

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script) -> Object:
```

通过当前架构获取 Model。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 要获取的 Model 脚本类型。 |

Returns: Model 实例；不可用时返回 null。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script) -> Object:
```

通过当前架构获取 System。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 目标类型。 |

Returns: System 实例；不可用时返回 null。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script) -> Object:
```

通过当前架构获取 Utility。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 要获取的 Utility 脚本类型。 |

Returns: Utility 实例；不可用时返回 null。

#### `get_capability`

- API: `public`

```gdscript
func get_capability(capability_type: Script) -> Object:
```

获取当前 receiver 上的其他能力。

Parameters:

| Name | Description |
|---|---|
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

Returns: 能力实例；不存在时返回 null。

## GFCapabilityContainer

- Path: `addons/gf/extensions/capability/nodes/gf_capability_container.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFCapabilityContainer: 场景树中的能力组件容器。 将该节点作为某个 Node 的子节点后，容器内带脚本的子节点会被注册为父节点的能力。 需要在当前架构中注册 GFCapabilityUtility。

### Properties

#### `auto_register_children`

- API: `public`

```gdscript
var auto_register_children: bool = true
```

是否在进入场景树后自动注册已有子节点。

#### `watch_child_changes`

- API: `public`

```gdscript
var watch_child_changes: bool = true
```

是否在子节点顺序变化时自动注册新增子节点。

### Methods

#### `get_receiver`

- API: `public`

```gdscript
func get_receiver() -> Node:
```

获取容器服务的能力接收者。

Returns: 容器的父节点；容器尚未挂载时返回 null。

#### `register_children_now`

- API: `public`

```gdscript
func register_children_now() -> void:
```

立即扫描并注册容器中的子节点能力。

## GFCapabilityRecipe

- Path: `addons/gf/extensions/capability/recipes/gf_capability_recipe.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFCapabilityRecipe: 可复用的能力组合资源。 Recipe 用于把一组通用 Capability 条目批量应用到 receiver。它只描述组合结构， 不规定实体类型、玩法规则、UI 或存档字段。

### Properties

#### `recipe_id`

- API: `public`

```gdscript
var recipe_id: StringName = &""
```

Recipe 稳定标识。为空时可由项目层按资源路径管理。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

Recipe 展示名，仅供编辑器和项目工具显示。

#### `entries`

- API: `public`

```gdscript
var entries: Array[GFCapabilityRecipeEntry] = []
```

能力条目列表。

#### `groups`

- API: `public`

```gdscript
var groups: Array[StringName] = []
```

应用 Recipe 时附加到 receiver 的能力查询分组。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；框架保留并复制该字段，但不解释其中键值。

### Methods

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取展示名。

Returns: 展示名。

#### `describe_recipe`

- API: `public`

```gdscript
func describe_recipe() -> Dictionary:
```

描述 Recipe。

Returns: Recipe 描述字典。

Schemas:

- `return`: 包含 recipe_id、display_name、entry_count、entries、groups 和 metadata 字段的 Dictionary；entries 为各条目的 describe_entry() 快照数组。

#### `validate_recipe`

- API: `public`

```gdscript
func validate_recipe() -> Dictionary:
```

校验 Recipe 结构。

Returns: 校验报告。

Schemas:

- `return`: GFValidationReport.to_dict() 生成的 Dictionary，包含 ok、healthy、summary、issues、next_action 和 entry_count 等字段。

## GFCapabilityRecipeEntry

- Path: `addons/gf/extensions/capability/recipes/gf_capability_recipe_entry.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFCapabilityRecipeEntry: 能力组合资源中的单个能力条目。 条目只描述能力提供方式、注册类型和默认启停状态，不解释项目业务含义。

### Properties

#### `capability_type`

- API: `public`

```gdscript
var capability_type: Script = null
```

能力注册类型。为空且 scene 不为空时，会使用实例脚本类型。

#### `scene`

- API: `public`

```gdscript
var scene: PackedScene = null
```

可选场景能力。为空时通过 capability_type.new() 创建纯对象能力。

#### `active`

- API: `public`

```gdscript
var active: bool = true
```

应用 Recipe 后是否启用该能力。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；框架保留并复制该字段，但不解释其中键值。

### Methods

#### `is_valid_entry`

- API: `public`

```gdscript
func is_valid_entry() -> bool:
```

检查条目是否至少提供了一种能力创建方式。

Returns: 有效返回 true。

#### `describe_entry`

- API: `public`

```gdscript
func describe_entry() -> Dictionary:
```

描述条目。

Returns: 条目描述字典。

Schemas:

- `return`: 包含 capability_type、scene_path、active 和 metadata 字段的 Dictionary。

## GFCapabilityUtility

- Path: `addons/gf/extensions/capability/core/gf_capability_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFCapabilityUtility: 对象能力组件管理器。 提供面向任意 Object / Node 的能力挂载、查询、移除、启停、索引查询与依赖补齐能力。 能力组合是可选扩展，不改变核心分层容器。

### Signals

#### `capability_added`

- API: `public`

```gdscript
signal capability_added(receiver: Object, capability_type: Script, capability: Object)
```

当能力成功挂载到对象后发出。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 实际注册的能力脚本类型。 |
| `capability` | 已挂载的能力实例。 |

#### `capability_removed`

- API: `public`

```gdscript
signal capability_removed(receiver: Object, capability_type: Script, capability: Object)
```

当能力从对象移除前发出。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 实际注册的能力脚本类型。 |
| `capability` | 将被移除的能力实例。 |

#### `capability_active_changed`

- API: `public`

```gdscript
signal capability_active_changed(receiver: Object, capability_type: Script, capability: Object, active: bool)
```

当能力启停状态变化后发出。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 实际注册的能力脚本类型。 |
| `capability` | 状态变化的能力实例。 |
| `active` | 新的启用状态。 |

### Enums

#### `DependencyRemovalPolicy`

- API: `public`

```gdscript
enum DependencyRemovalPolicy { ## 保留依赖能力，适合依赖能力需要在主能力移除后继续存在的场景。 KEEP_DEPENDENCIES, ## 移除仅由当前能力自动补齐且未被显式添加的依赖能力。 REMOVE_AUTO_DEPENDENCIES, }
```

移除能力时自动补齐依赖的清理策略。

### Constants

#### `HOOK_GET_REQUIRED_CAPABILITIES`

- API: `public`

```gdscript
const HOOK_GET_REQUIRED_CAPABILITIES: StringName = &"get_required_capabilities"
```

能力对象可选实现：返回运行时依赖的能力类型列表。

#### `HOOK_GET_DEPENDENCY_REMOVAL_POLICY`

- API: `public`

```gdscript
const HOOK_GET_DEPENDENCY_REMOVAL_POLICY: StringName = &"get_dependency_removal_policy"
```

能力对象可选实现：返回自动依赖能力的移除策略。

#### `HOOK_ON_ADDED`

- API: `public`

```gdscript
const HOOK_ON_ADDED: StringName = &"on_gf_capability_added"
```

能力对象可选实现：挂载到 receiver 后调用。

#### `HOOK_ON_REMOVED`

- API: `public`

```gdscript
const HOOK_ON_REMOVED: StringName = &"on_gf_capability_removed"
```

能力对象可选实现：从 receiver 移除前调用。

#### `HOOK_ON_ACTIVE_CHANGED`

- API: `public`

```gdscript
const HOOK_ON_ACTIVE_CHANGED: StringName = &"on_gf_capability_active_changed"
```

能力对象可选实现：启停状态变化后调用。

### Properties

#### `prune_invalid_receivers_per_tick`

- API: `public`

```gdscript
var prune_invalid_receivers_per_tick: int = 128:
```

tick() 自动清理失效 receiver 时每次最多检查的数量，避免大型索引在单帧产生尖峰。 主动调用 prune_invalid_receivers() 仍会执行全量清理。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化能力管理器的运行时游标。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

注销已索引 receiver 上的能力并清理分组状态。 由本 Utility 创建或 PackedScene 实例化的能力会随架构销毁释放；外部传入或场景中已有的能力只注销，不抢占其节点所有权。

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

#### `has_capability`

- API: `public`

```gdscript
func has_capability(receiver: Object, capability_type: Script) -> bool:
```

检查对象是否拥有指定能力。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

Returns: 拥有该能力或其唯一子类能力时返回 true。

#### `get_capability`

- API: `public`

```gdscript
func get_capability(receiver: Object, capability_type: Script) -> Object:
```

获取对象上的指定能力。 未命中精确类型时，会尝试寻找唯一的子类能力。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

Returns: 匹配的能力实例；未命中或匹配不唯一时返回 null。

#### `get_capability_types`

- API: `public`

```gdscript
func get_capability_types(receiver: Object) -> Array[Script]:
```

获取对象当前拥有的所有能力类型。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |

Returns: 当前注册的能力脚本类型列表。

Schemas:

- `return`: Array[Script]，元素为 receiver 上当前注册的能力脚本类型。

#### `get_receivers_with`

- API: `public`

```gdscript
func get_receivers_with(capability_type: Script, include_subclasses: bool = true) -> Array[Object]:
```

获取所有拥有指定能力的 receiver。

Parameters:

| Name | Description |
|---|---|
| `capability_type` | 要查询的能力脚本类型。 |
| `include_subclasses` | 为 true 时同时匹配指定能力的子类能力。 |

Returns: 当前拥有该能力的 receiver 列表。

Schemas:

- `return`: Array[Object]，元素为当前仍有效的能力接收对象。

#### `prune_invalid_receivers`

- API: `public`

```gdscript
func prune_invalid_receivers() -> void:
```

主动清理已经失效的 receiver 弱引用与反向索引。

#### `get_capabilities`

- API: `public`

```gdscript
func get_capabilities(capability_type: Script, include_subclasses: bool = true) -> Array[Object]:
```

获取当前已挂载的指定能力实例列表。

Parameters:

| Name | Description |
|---|---|
| `capability_type` | 要查询的能力脚本类型。 |
| `include_subclasses` | 为 true 时同时返回指定能力的子类能力实例。 |

Returns: 匹配的能力实例列表。

Schemas:

- `return`: Array[Object]，元素为当前仍有效的能力实例。

#### `add_receiver_to_group`

- API: `public`

```gdscript
func add_receiver_to_group(receiver: Object, group_name: StringName) -> void:
```

把 receiver 加入一个能力查询分组。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `group_name` | 能力组或状态组名称。 |

#### `remove_receiver_from_group`

- API: `public`

```gdscript
func remove_receiver_from_group(receiver: Object, group_name: StringName) -> void:
```

从一个能力查询分组移除 receiver。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `group_name` | 能力组或状态组名称。 |

#### `get_receiver_groups`

- API: `public`

```gdscript
func get_receiver_groups(receiver: Object) -> Array[StringName]:
```

获取 receiver 当前所属的能力查询分组。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |

Returns: receiver 当前所属的分组名称。

Schemas:

- `return`: Array[StringName]，元素为能力查询分组名称。

#### `get_receivers_in_group`

- API: `public`

```gdscript
func get_receivers_in_group(group_name: StringName) -> Array[Object]:
```

获取指定分组内的 receiver。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |

Returns: 分组内仍有效的 receiver 列表。

Schemas:

- `return`: Array[Object]，元素为当前仍有效的能力接收对象。

#### `get_receivers_in_group_with`

- API: `public`

```gdscript
func get_receivers_in_group_with( group_name: StringName, capability_type: Script, include_subclasses: bool = true ) -> Array[Object]:
```

获取指定分组内拥有某个能力的 receiver。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |
| `include_subclasses` | 为 true 时同时匹配指定类型的子类。 |

Returns: 分组内拥有该能力的 receiver 列表。

Schemas:

- `return`: Array[Object]，元素为当前仍有效的能力接收对象。

#### `add_capability`

- API: `public`

```gdscript
func add_capability(receiver: Object, capability_type: Script, provider: Variant = null) -> Object:
```

给对象挂载指定能力类型。 provider 可为 Callable、PackedScene、Object；为空时使用 capability_type.new()。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |
| `provider` | 用于创建能力实例的 provider。 |

Returns: 已挂载或复用的能力实例；失败时返回 null。

Schemas:

- `provider`: Variant，可为 null、Callable、PackedScene 或 Object 能力实例。

#### `add_required_capability`

- API: `public`

```gdscript
func add_required_capability(receiver: Object, capability_type: Script, provider: Variant = null) -> Object:
```

给对象挂载指定能力类型，并标记为自动依赖能力。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |
| `provider` | 用于创建能力实例的 provider。 |

Returns: 已挂载或复用的能力实例；失败时返回 null。

Schemas:

- `provider`: Variant，可为 null、Callable、PackedScene 或 Object 能力实例。

#### `add_capability_instance`

- API: `public`

```gdscript
func add_capability_instance(receiver: Object, capability: Object, as_type: Script = null) -> Object:
```

给对象挂载一个已经存在的能力实例。 该入口不会接管传入实例的所有权；架构销毁时只注销能力记录。需要由 Utility 创建并接管节点释放时，请使用 add_capability() 或 add_scene_capability()。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability` | 要挂载的能力实例。 |
| `as_type` | 能力实例注册时使用的类型；为 null 时使用实例脚本类型。 |

Returns: 已挂载或复用的能力实例；失败时返回 null。

#### `add_scene_capability`

- API: `public`

```gdscript
func add_scene_capability(receiver: Node, scene: PackedScene, as_type: Script = null) -> Object:
```

实例化 PackedScene 并作为能力挂载。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `scene` | 要实例化的能力场景资源。 |
| `as_type` | 能力实例注册时使用的类型；为 null 时使用实例脚本类型。 |

Returns: 已挂载的能力节点；失败时返回 null。

#### `set_capability_active`

- API: `public`

```gdscript
func set_capability_active(receiver: Object, capability_type: Script, active: bool) -> void:
```

设置对象上指定能力的启停状态。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |
| `active` | 要设置的激活状态。 |

#### `is_capability_active`

- API: `public`

```gdscript
func is_capability_active(receiver: Object, capability_type: Script) -> bool:
```

查询对象上指定能力当前是否启用。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

Returns: 能力存在且处于启用状态时返回 true。

#### `remove_capability`

- API: `public`

```gdscript
func remove_capability(receiver: Object, capability_type: Script) -> void:
```

从对象移除指定能力。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

#### `unregister_capability`

- API: `public`

```gdscript
func unregister_capability(receiver: Object, capability_type: Script) -> void:
```

从对象注销指定能力，但不释放能力实例。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

#### `clear_capabilities`

- API: `public`

```gdscript
func clear_capabilities(receiver: Object) -> void:
```

清空对象上的所有能力。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |

#### `clear_receiver_groups`

- API: `public`

```gdscript
func clear_receiver_groups(receiver: Object) -> void:
```

清空 receiver 所属的所有能力查询分组。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |

#### `apply_recipe`

- API: `public`

```gdscript
func apply_recipe(receiver: Object, recipe: GFCapabilityRecipe, options: Dictionary = {}) -> Dictionary:
```

把能力组合 Recipe 应用到 receiver。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `recipe` | 能力组合资源。 |
| `options` | 可选参数，支持 skip_groups、validate_after_apply 与 transactional。 |

Returns: 应用报告。

Schemas:

- `options`: Dictionary，可包含 skip_groups、validate_after_apply、transactional 布尔选项。
- `return`: Dictionary，包含 ok、recipe_id、added、reused、failed、groups、dependency_validation 与 rolled_back。

#### `remove_recipe`

- API: `public`

```gdscript
func remove_recipe(receiver: Object, recipe: GFCapabilityRecipe, remove_groups: bool = true) -> Dictionary:
```

移除 Recipe 描述的能力和可选分组。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 能力接收对象。 |
| `recipe` | 能力组合资源。 |
| `remove_groups` | 是否同步移除 Recipe groups。 |

Returns: 移除报告。

Schemas:

- `return`: Dictionary，包含 ok、recipe_id、removed、skipped 和 groups_removed。

#### `validate_receiver_dependencies`

- API: `public`

```gdscript
func validate_receiver_dependencies(receiver: Object) -> Dictionary:
```

检查 receiver 上能力依赖是否完整。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 目标对象。 |

Returns: 统一检查结果，包含 ok 与 missing_dependencies。

Schemas:

- `return`: Dictionary，包含 ok 与 missing_dependencies；missing_dependencies 为缺失依赖记录数组。

#### `inspect_receiver`

- API: `public`

```gdscript
func inspect_receiver(receiver: Object) -> Dictionary:
```

获取 receiver 能力诊断报告。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 目标对象。 |

Returns: 能力、依赖、缺失项和分组信息。

Schemas:

- `return`: Dictionary，包含 ok、error、receiver_id、capability_count、capabilities、missing_dependencies 和 groups。

## GFControlCapability

- Path: `addons/gf/extensions/capability/nodes/gf_control_capability.gd`
- Extends: `Control`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFControlCapability: 可直接作为 UI Control 节点使用的能力组件基类。 适合承载需要 Control 布局、输入或子节点引用的局部能力。

### Properties

#### `required_capabilities`

- API: `public`

```gdscript
var required_capabilities: Array[Script] = []
```

当前能力依赖的其他能力类型。运行时挂载前会先确保这些能力存在。

Schemas:

- `required_capabilities`: 元素为 Script 的能力类型列表。

#### `receiver`

- API: `public`

```gdscript
var receiver: Object = null
```

当前能力所属对象。由 GFCapabilityUtility 挂载时写入。

#### `active`

- API: `public`

```gdscript
var active: bool = true
```

当前能力是否启用。请优先通过 GFCapabilityUtility.set_capability_active() 修改。

### Methods

#### `get_required_capabilities`

- API: `public`

```gdscript
func get_required_capabilities() -> Array[Script]:
```

返回当前能力依赖的其他能力类型。 默认返回 required_capabilities；只有运行时动态依赖才建议在子类中重写。 GFCapabilityUtility 会在挂载当前能力前先确保这些能力存在。

Returns: 当前能力依赖的能力脚本类型列表。

Schemas:

- `return`: 元素为 Script 的能力类型列表。

#### `get_dependency_removal_policy`

- API: `public`

```gdscript
func get_dependency_removal_policy() -> int:
```

返回移除当前能力时对自动补齐依赖能力的处理策略。

Returns: DependencyRemovalPolicy 枚举值。

#### `on_gf_capability_added`

- API: `public`

```gdscript
func on_gf_capability_added(target: Object) -> void:
```

能力挂载到对象后调用。

Parameters:

| Name | Description |
|---|---|
| `target` | 当前能力所属对象。 |

#### `on_gf_capability_removed`

- API: `public`

```gdscript
func on_gf_capability_removed(_target: Object) -> void:
```

能力从对象移除前调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |

#### `on_gf_capability_active_changed`

- API: `public`

```gdscript
func on_gf_capability_active_changed(_target: Object, _active: bool) -> void:
```

能力启停状态变化后调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |
| `_active` | 当前启停状态。 |

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script) -> Object:
```

通过当前架构获取 Model。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 要获取的 Model 脚本类型。 |

Returns: Model 实例；不可用时返回 null。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script) -> Object:
```

通过当前架构获取 System。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 目标类型。 |

Returns: System 实例；不可用时返回 null。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script) -> Object:
```

通过当前架构获取 Utility。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 要获取的 Utility 脚本类型。 |

Returns: Utility 实例；不可用时返回 null。

#### `get_capability`

- API: `public`

```gdscript
func get_capability(capability_type: Script) -> Object:
```

获取当前 receiver 上的其他能力。

Parameters:

| Name | Description |
|---|---|
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

Returns: 能力实例；不存在时返回 null。

## GFNode2DCapability

- Path: `addons/gf/extensions/capability/nodes/gf_node_2d_capability.gd`
- Extends: `Node2D`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNode2DCapability: 可直接作为 2D 场景节点使用的能力组件基类。 适合承载需要 2D 变换、碰撞、输入或子节点引用的局部能力。

### Properties

#### `required_capabilities`

- API: `public`

```gdscript
var required_capabilities: Array[Script] = []
```

当前能力依赖的其他能力类型。运行时挂载前会先确保这些能力存在。

Schemas:

- `required_capabilities`: 元素为 Script 的能力类型列表。

#### `receiver`

- API: `public`

```gdscript
var receiver: Object = null
```

当前能力所属对象。由 GFCapabilityUtility 挂载时写入。

#### `active`

- API: `public`

```gdscript
var active: bool = true
```

当前能力是否启用。请优先通过 GFCapabilityUtility.set_capability_active() 修改。

### Methods

#### `get_required_capabilities`

- API: `public`

```gdscript
func get_required_capabilities() -> Array[Script]:
```

返回当前能力依赖的其他能力类型。 默认返回 required_capabilities；只有运行时动态依赖才建议在子类中重写。 GFCapabilityUtility 会在挂载当前能力前先确保这些能力存在。

Returns: 当前能力依赖的能力脚本类型列表。

Schemas:

- `return`: 元素为 Script 的能力类型列表。

#### `get_dependency_removal_policy`

- API: `public`

```gdscript
func get_dependency_removal_policy() -> int:
```

返回移除当前能力时对自动补齐依赖能力的处理策略。

Returns: DependencyRemovalPolicy 枚举值。

#### `on_gf_capability_added`

- API: `public`

```gdscript
func on_gf_capability_added(target: Object) -> void:
```

能力挂载到对象后调用。

Parameters:

| Name | Description |
|---|---|
| `target` | 当前能力所属对象。 |

#### `on_gf_capability_removed`

- API: `public`

```gdscript
func on_gf_capability_removed(_target: Object) -> void:
```

能力从对象移除前调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |

#### `on_gf_capability_active_changed`

- API: `public`

```gdscript
func on_gf_capability_active_changed(_target: Object, _active: bool) -> void:
```

能力启停状态变化后调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |
| `_active` | 当前启停状态。 |

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script) -> Object:
```

通过当前架构获取 Model。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 要获取的 Model 脚本类型。 |

Returns: Model 实例；不可用时返回 null。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script) -> Object:
```

通过当前架构获取 System。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 目标类型。 |

Returns: System 实例；不可用时返回 null。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script) -> Object:
```

通过当前架构获取 Utility。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 要获取的 Utility 脚本类型。 |

Returns: Utility 实例；不可用时返回 null。

#### `get_capability`

- API: `public`

```gdscript
func get_capability(capability_type: Script) -> Object:
```

获取当前 receiver 上的其他能力。

Parameters:

| Name | Description |
|---|---|
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

Returns: 能力实例；不存在时返回 null。

## GFNode3DCapability

- Path: `addons/gf/extensions/capability/nodes/gf_node_3d_capability.gd`
- Extends: `Node3D`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNode3DCapability: 可直接作为 3D 场景节点使用的能力组件基类。 适合承载需要 3D 变换、碰撞、输入或子节点引用的局部能力。

### Properties

#### `required_capabilities`

- API: `public`

```gdscript
var required_capabilities: Array[Script] = []
```

当前能力依赖的其他能力类型。运行时挂载前会先确保这些能力存在。

Schemas:

- `required_capabilities`: 元素为 Script 的能力类型列表。

#### `receiver`

- API: `public`

```gdscript
var receiver: Object = null
```

当前能力所属对象。由 GFCapabilityUtility 挂载时写入。

#### `active`

- API: `public`

```gdscript
var active: bool = true
```

当前能力是否启用。请优先通过 GFCapabilityUtility.set_capability_active() 修改。

### Methods

#### `get_required_capabilities`

- API: `public`

```gdscript
func get_required_capabilities() -> Array[Script]:
```

返回当前能力依赖的其他能力类型。 默认返回 required_capabilities；只有运行时动态依赖才建议在子类中重写。 GFCapabilityUtility 会在挂载当前能力前先确保这些能力存在。

Returns: 当前能力依赖的能力脚本类型列表。

Schemas:

- `return`: 元素为 Script 的能力类型列表。

#### `get_dependency_removal_policy`

- API: `public`

```gdscript
func get_dependency_removal_policy() -> int:
```

返回移除当前能力时对自动补齐依赖能力的处理策略。

Returns: DependencyRemovalPolicy 枚举值。

#### `on_gf_capability_added`

- API: `public`

```gdscript
func on_gf_capability_added(target: Object) -> void:
```

能力挂载到对象后调用。

Parameters:

| Name | Description |
|---|---|
| `target` | 当前能力所属对象。 |

#### `on_gf_capability_removed`

- API: `public`

```gdscript
func on_gf_capability_removed(_target: Object) -> void:
```

能力从对象移除前调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |

#### `on_gf_capability_active_changed`

- API: `public`

```gdscript
func on_gf_capability_active_changed(_target: Object, _active: bool) -> void:
```

能力启停状态变化后调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |
| `_active` | 当前启停状态。 |

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script) -> Object:
```

通过当前架构获取 Model。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 要获取的 Model 脚本类型。 |

Returns: Model 实例；不可用时返回 null。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script) -> Object:
```

通过当前架构获取 System。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 目标类型。 |

Returns: System 实例；不可用时返回 null。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script) -> Object:
```

通过当前架构获取 Utility。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 要获取的 Utility 脚本类型。 |

Returns: Utility 实例；不可用时返回 null。

#### `get_capability`

- API: `public`

```gdscript
func get_capability(capability_type: Script) -> Object:
```

获取当前 receiver 上的其他能力。

Parameters:

| Name | Description |
|---|---|
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

Returns: 能力实例；不存在时返回 null。

## GFNodeCapability

- Path: `addons/gf/extensions/capability/nodes/gf_node_capability.gd`
- Extends: `Node`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNodeCapability: 可直接作为场景节点使用的能力组件基类。 适合承载通用节点逻辑、输入、动画或子节点引用的局部能力。 需要 2D/3D/UI 空间继承时，优先使用 GFNode2DCapability、GFNode3DCapability 或 GFControlCapability。

### Properties

#### `required_capabilities`

- API: `public`

```gdscript
var required_capabilities: Array[Script] = []
```

当前能力依赖的其他能力类型。运行时挂载前会先确保这些能力存在。

Schemas:

- `required_capabilities`: 元素为 Script 的能力类型列表。

#### `receiver`

- API: `public`

```gdscript
var receiver: Object = null
```

当前能力所属对象。由 GFCapabilityUtility 挂载时写入。

#### `active`

- API: `public`

```gdscript
var active: bool = true
```

当前能力是否启用。请优先通过 GFCapabilityUtility.set_capability_active() 修改。

### Methods

#### `get_required_capabilities`

- API: `public`

```gdscript
func get_required_capabilities() -> Array[Script]:
```

返回当前能力依赖的其他能力类型。 默认返回 required_capabilities；只有运行时动态依赖才建议在子类中重写。 GFCapabilityUtility 会在挂载当前能力前先确保这些能力存在。

Returns: 当前能力依赖的能力脚本类型列表。

Schemas:

- `return`: 元素为 Script 的能力类型列表。

#### `get_dependency_removal_policy`

- API: `public`

```gdscript
func get_dependency_removal_policy() -> int:
```

返回移除当前能力时对自动补齐依赖能力的处理策略。

Returns: DependencyRemovalPolicy 枚举值。

#### `on_gf_capability_added`

- API: `public`

```gdscript
func on_gf_capability_added(target: Object) -> void:
```

能力挂载到对象后调用。

Parameters:

| Name | Description |
|---|---|
| `target` | 当前能力所属对象。 |

#### `on_gf_capability_removed`

- API: `public`

```gdscript
func on_gf_capability_removed(_target: Object) -> void:
```

能力从对象移除前调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |

#### `on_gf_capability_active_changed`

- API: `public`

```gdscript
func on_gf_capability_active_changed(_target: Object, _active: bool) -> void:
```

能力启停状态变化后调用。

Parameters:

| Name | Description |
|---|---|
| `_target` | 当前能力所属对象。 |
| `_active` | 当前启停状态。 |

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script) -> Object:
```

通过当前架构获取 Model。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 要获取的 Model 脚本类型。 |

Returns: Model 实例；不可用时返回 null。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script) -> Object:
```

通过当前架构获取 System。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 目标类型。 |

Returns: System 实例；不可用时返回 null。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script) -> Object:
```

通过当前架构获取 Utility。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 要获取的 Utility 脚本类型。 |

Returns: Utility 实例；不可用时返回 null。

#### `get_capability`

- API: `public`

```gdscript
func get_capability(capability_type: Script) -> Object:
```

获取当前 receiver 上的其他能力。

Parameters:

| Name | Description |
|---|---|
| `capability_type` | 要查询、添加或移除的能力脚本类型。 |

Returns: 能力实例；不存在时返回 null。

## GFPropertyBagCapability

- Path: `addons/gf/extensions/capability/core/gf_property_bag_capability.gd`
- Extends: `GFCapability`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFPropertyBagCapability: 轻量动态属性扩展能力。 适合为对象挂载少量运行时标签值、编辑器调试值或原型数据。 长期核心状态仍应放入 GFModel 或配置资源。

### Signals

#### `property_changed`

- API: `public`

```gdscript
signal property_changed(key: StringName, old_value: Variant, new_value: Variant)
```

当属性值发生变化时发出。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `old_value` | 旧属性值。 |
| `new_value` | 新属性值。 |

Schemas:

- `old_value`: 属性表中的任意项目值；属性之前不存在时为 null。
- `new_value`: 属性表中的任意项目值。

#### `property_removed`

- API: `public`

```gdscript
signal property_removed(key: StringName, old_value: Variant)
```

当属性被移除时发出。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `old_value` | 被移除的旧属性值。 |

Schemas:

- `old_value`: 属性表中的任意项目值。

### Properties

#### `values`

- API: `public`

```gdscript
var values: Dictionary = {}
```

当前属性表。

Schemas:

- `values`: 动态属性 Dictionary；键通常为 StringName，值由项目决定。

### Methods

#### `set_property_value`

- API: `public`

```gdscript
func set_property_value(key: StringName, value: Variant) -> void:
```

设置属性值。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `value` | 要写入或修改的值。 |

Schemas:

- `value`: 要写入属性表的任意项目值。

#### `get_property_value`

- API: `public`

```gdscript
func get_property_value(key: StringName, default_value: Variant = null) -> Variant:
```

获取属性值。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `default_value` | 缺失时返回的默认值。 |

Returns: 属性值或默认值。

Schemas:

- `default_value`: 属性缺失时返回的任意默认值。
- `return`: 属性表中的项目值，或传入的 default_value。

#### `has_property_value`

- API: `public`

```gdscript
func has_property_value(key: StringName) -> bool:
```

检查属性是否存在。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |

Returns: 存在返回 true。

#### `remove_property_value`

- API: `public`

```gdscript
func remove_property_value(key: StringName) -> bool:
```

移除属性。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |

Returns: 移除成功返回 true。

#### `clear_properties`

- API: `public`

```gdscript
func clear_properties() -> void:
```

清空全部属性。

#### `get_int`

- API: `public`

```gdscript
func get_int(key: StringName, default_value: int = 0) -> int:
```

获取 int 属性。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `default_value` | 缺失或类型不匹配时返回的默认值。 |

Returns: int 属性值或默认值。

#### `get_float`

- API: `public`

```gdscript
func get_float(key: StringName, default_value: float = 0.0) -> float:
```

获取 float 属性。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `default_value` | 缺失或类型不匹配时返回的默认值。 |

Returns: float 属性值或默认值。

#### `get_bool`

- API: `public`

```gdscript
func get_bool(key: StringName, default_value: bool = false) -> bool:
```

获取 bool 属性。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `default_value` | 缺失或类型不匹配时返回的默认值。 |

Returns: bool 属性值或默认值。

#### `get_string`

- API: `public`

```gdscript
func get_string(key: StringName, default_value: String = "") -> String:
```

获取 String 属性。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `default_value` | 缺失或类型不匹配时返回的默认值。 |

Returns: String 属性值或默认值。

#### `get_vector2`

- API: `public`

```gdscript
func get_vector2(key: StringName, default_value: Vector2 = Vector2.ZERO) -> Vector2:
```

获取 Vector2 属性。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `default_value` | 缺失或类型不匹配时返回的默认值。 |

Returns: Vector2 属性值或默认值。

#### `get_color`

- API: `public`

```gdscript
func get_color(key: StringName, default_value: Color = Color.WHITE) -> Color:
```

获取 Color 属性。

Parameters:

| Name | Description |
|---|---|
| `key` | 属性键。 |
| `default_value` | 缺失或类型不匹配时返回的默认值。 |

Returns: Color 属性值或默认值。

