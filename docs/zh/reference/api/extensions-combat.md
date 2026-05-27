# Combat API

Module: `extensions/combat`

## Classes

- [`GFBuff`](#gfbuff)
- [`GFCombatAction`](#gfcombataction)
- [`GFCombatActionModifier`](#gfcombatactionmodifier)
- [`GFCombatActionResult`](#gfcombatactionresult)
- [`GFCombatGauge`](#gfcombatgauge)
- [`GFCombatHitContext`](#gfcombathitcontext)
- [`GFCombatPayloads`](#gfcombatpayloads)
- [`GFCombatPayloads.GFBuffAppliedPayload`](#gfcombatpayloadsgfbuffappliedpayload)
- [`GFCombatPayloads.GFBuffRefreshedPayload`](#gfcombatpayloadsgfbuffrefreshedpayload)
- [`GFCombatPayloads.GFBuffRemovedPayload`](#gfcombatpayloadsgfbuffremovedpayload)
- [`GFCombatSystem`](#gfcombatsystem)
- [`GFHitBox2D`](#gfhitbox2d)
- [`GFHitBox3D`](#gfhitbox3d)
- [`GFHitBoxState2D`](#gfhitboxstate2d)
- [`GFHitBoxState3D`](#gfhitboxstate3d)
- [`GFHitCollisionShapeConfig2D`](#gfhitcollisionshapeconfig2d)
- [`GFHitCollisionShapeConfig3D`](#gfhitcollisionshapeconfig3d)
- [`GFHitScan2D`](#gfhitscan2d)
- [`GFHitScan3D`](#gfhitscan3d)
- [`GFHomingProjectileMotion`](#gfhomingprojectilemotion)
- [`GFHurtBox2D`](#gfhurtbox2d)
- [`GFHurtBox3D`](#gfhurtbox3d)
- [`GFLinearProjectileMotion`](#gflinearprojectilemotion)
- [`GFModifiedAttribute`](#gfmodifiedattribute)
- [`GFModifiedAttributeSet`](#gfmodifiedattributeset)
- [`GFModifier`](#gfmodifier)
- [`GFProjectile2D`](#gfprojectile2d)
- [`GFProjectile3D`](#gfprojectile3d)
- [`GFProjectileBurstPattern2D`](#gfprojectileburstpattern2d)
- [`GFProjectileCatalog`](#gfprojectilecatalog)
- [`GFProjectileCatalogEntry`](#gfprojectilecatalogentry)
- [`GFProjectileConePattern3D`](#gfprojectileconepattern3d)
- [`GFProjectileEmitter2D`](#gfprojectileemitter2d)
- [`GFProjectileEmitter3D`](#gfprojectileemitter3d)
- [`GFProjectileLifetimePolicy`](#gfprojectilelifetimepolicy)
- [`GFProjectileLineSpawnPattern2D`](#gfprojectilelinespawnpattern2d)
- [`GFProjectileLineSpawnPattern3D`](#gfprojectilelinespawnpattern3d)
- [`GFProjectileMotion`](#gfprojectilemotion)
- [`GFProjectileSpawnPattern2D`](#gfprojectilespawnpattern2d)
- [`GFProjectileSpawnPattern3D`](#gfprojectilespawnpattern3d)
- [`GFSkill`](#gfskill)
- [`GFSkillActivationContext`](#gfskillactivationcontext)
- [`GFSkillTargetingRule`](#gfskilltargetingrule)
- [`GFSkillTargetingUtility`](#gfskilltargetingutility)
- [`GFTagComponent`](#gftagcomponent)

## GFBuff

- Path: `addons/gf/extensions/combat/attributes/gf_buff.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFBuff: 状态效果基类。 管理 Buff 的生命周期、层数以及对属性/标签的影响。 在 GFCombatSystem 的 tick 中驱动 update。

### Enums

#### `StackMode`

- API: `public`

```gdscript
enum StackMode { ## 只刷新持续时间，不改变层数。 REFRESH_ONLY, ## 刷新持续时间，并在 max_stacks 允许时增加层数。 ADD_STACK, ## 忽略重复添加，不刷新持续时间或层数。 IGNORE, }
```

重复添加同 ID Buff 时的层数策略。

#### `DurationRefreshPolicy`

- API: `public`

```gdscript
enum DurationRefreshPolicy { ## 保持当前剩余时间。 KEEP_CURRENT, ## 使用新的持续时间重置剩余时间。 RESET_TO_NEW_DURATION, ## 将新的持续时间追加到当前剩余时间。 EXTEND_BY_NEW_DURATION, ## 保留当前剩余时间与新持续时间中较长者。 KEEP_LONGER_REMAINING, }
```

重复添加同 ID Buff 时的持续时间刷新策略。

### Properties

#### `id`

- API: `public`

```gdscript
var id: StringName = &""
```

Buff 的唯一标识名（通常用于排斥逻辑）。

#### `duration`

- API: `public`

```gdscript
var duration: float = 0.0
```

Buff 的总持续时间（秒）。如果为 -1 则视为永久 Buff。

#### `time_left`

- API: `public`

```gdscript
var time_left: float = 0.0
```

当前剩余剩余时间。

#### `stacks`

- API: `public`

```gdscript
var stacks: int = 1
```

当前层数。

#### `max_stacks`

- API: `public`

```gdscript
var max_stacks: int = 1
```

最大层数。

#### `stack_mode`

- API: `public`

```gdscript
var stack_mode: StackMode = StackMode.ADD_STACK
```

重复添加同 ID Buff 时的层数策略。

#### `duration_refresh_policy`

- API: `public`

```gdscript
var duration_refresh_policy: DurationRefreshPolicy = DurationRefreshPolicy.RESET_TO_NEW_DURATION
```

重复添加同 ID Buff 时的持续时间刷新策略。

#### `tick_interval_seconds`

- API: `public`

```gdscript
var tick_interval_seconds: float = 0.0
```

周期 Tick 间隔。小于等于 0 时保持每帧调用 on_tick() 的旧行为。

#### `max_periodic_ticks_per_update`

- API: `public`

```gdscript
var max_periodic_ticks_per_update: int = 8
```

单次 update 允许补偿触发的最大周期 Tick 次数。小于等于 0 时不限制。

#### `remove_on_expire`

- API: `public`

```gdscript
var remove_on_expire: bool = true
```

持续时间耗尽时是否由 CombatSystem 移除。

#### `modifiers`

- API: `public`

```gdscript
var modifiers: Array[GFModifier] = []
```

Buff 携带的属性修饰器列表。应用时会自动挂载到宿主的 Attribute 上。

#### `tags`

- API: `public`

```gdscript
var tags: Array[StringName] = []
```

Buff 携带的标签列表。应用时会自动挂载到宿主的 TagComponent 上。

#### `owner`

- API: `public`

```gdscript
var owner: Object = null
```

Buff 的拥有者（通常是一个持有 Combat 数据的 Object）。

### Methods

#### `setup`

- API: `public`

```gdscript
func setup(p_id: StringName, p_duration: float, p_owner: Object) -> void:
```

初始化 Buff，由系统或工厂调用。

Parameters:

| Name | Description |
|---|---|
| `p_id` | Buff 标识。 |
| `p_duration` | Buff 持续时间（秒）。 |
| `p_owner` | Buff 所属对象。 |

#### `on_apply`

- API: `public`

```gdscript
func on_apply() -> void:
```

当 Buff 首次应用时触发。

#### `on_remove`

- API: `public`

```gdscript
func on_remove() -> void:
```

当 Buff 被移除时触发。

#### `on_refresh`

- API: `public`

```gdscript
func on_refresh(p_new_duration: float) -> void:
```

当 Buff 层数增加时触发（通常用于刷新持续时间）。

Parameters:

| Name | Description |
|---|---|
| `p_new_duration` | 刷新后的持续时间（秒）。 |

#### `refresh_from`

- API: `public`

```gdscript
func refresh_from(source_buff: GFBuff) -> void:
```

使用同 ID 的新 Buff 刷新当前运行中实例。

Parameters:

| Name | Description |
|---|---|
| `source_buff` | 本次尝试添加的新 Buff。 |

#### `on_tick`

- API: `public`

```gdscript
func on_tick(_p_delta: float) -> void:
```

周期性触发逻辑。

Parameters:

| Name | Description |
|---|---|
| `_p_delta` | 帧间隔。 |

#### `update`

- API: `public`

```gdscript
func update(p_delta: float) -> bool:
```

内部状态更新流程。

Parameters:

| Name | Description |
|---|---|
| `p_delta` | 帧间隔。 |

Returns: 如果 Buff 已耗尽生命周期需要被移除，则返回 true。

## GFCombatAction

- Path: `addons/gf/extensions/combat/actions/gf_combat_action.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFCombatAction: 通用战斗动作数据。 表达一次对目标系统可解释的数值动作。框架只保存动作类别、操作、数值、 标签和元数据，不规定伤害、治疗、阵营或生命值语义。

### Enums

#### `Operation`

- API: `public`

```gdscript
enum Operation { ## 增加目标值。 ADD, ## 减少目标值。 SUBTRACT, ## 直接设置目标值。 SET, }
```

数值操作类型。

### Properties

#### `action_id`

- API: `public`

```gdscript
var action_id: StringName = &""
```

动作标识。

#### `action_kind`

- API: `public`

```gdscript
var action_kind: StringName = &""
```

动作类别，由项目定义。

#### `operation`

- API: `public`

```gdscript
var operation: Operation = Operation.SUBTRACT
```

数值操作。

#### `amount`

- API: `public`

```gdscript
var amount: float = 0.0
```

动作数值。

#### `tags`

- API: `public`

```gdscript
var tags: Array[StringName] = []
```

动作标签，由项目定义。

#### `payload`

- API: `public`

```gdscript
var payload: Variant = null
```

项目自定义 payload。

Schemas:

- `payload`: Variant，可保存项目自定义动作载荷；框架只复制并透传。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: Dictionary，项目自定义元数据；框架只复制并透传。

### Methods

#### `duplicate_action`

- API: `public`

```gdscript
func duplicate_action() -> GFCombatAction:
```

复制动作。

Returns: 新动作。

#### `with_action_id`

- API: `public`

```gdscript
func with_action_id(value: StringName) -> GFCombatAction:
```

设置动作标识并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 动作标识。 |

Returns: 当前动作。

#### `with_kind`

- API: `public`

```gdscript
func with_kind(value: StringName) -> GFCombatAction:
```

设置动作类别并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 动作类别。 |

Returns: 当前动作。

#### `with_operation`

- API: `public`

```gdscript
func with_operation(value: Operation) -> GFCombatAction:
```

设置数值操作并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 数值操作。 |

Returns: 当前动作。

#### `with_amount`

- API: `public`

```gdscript
func with_amount(value: float) -> GFCombatAction:
```

设置动作数值并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 动作数值。 |

Returns: 当前动作。

#### `with_tags`

- API: `public`

```gdscript
func with_tags(value: Array[StringName]) -> GFCombatAction:
```

设置动作标签并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 动作标签。 |

Returns: 当前动作。

#### `with_payload`

- API: `public`

```gdscript
func with_payload(value: Variant) -> GFCombatAction:
```

设置 payload 并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 载荷。 |

Returns: 当前动作。

Schemas:

- `value`: Variant，可保存项目自定义动作载荷；框架只复制并透传。

#### `with_metadata`

- API: `public`

```gdscript
func with_metadata(value: Dictionary) -> GFCombatAction:
```

设置元数据并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 元数据。 |

Returns: 当前动作。

Schemas:

- `value`: Dictionary，项目自定义元数据；框架只复制并透传。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转为字典。

Returns: 字典快照。

Schemas:

- `return`: Dictionary，包含 action_id、action_kind、operation、amount、tags、payload 和 metadata。

## GFCombatActionModifier

- Path: `addons/gf/extensions/combat/actions/gf_combat_action_modifier.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFCombatActionModifier: 通用战斗动作修正器。 按动作类别和标签过滤后，调整动作数值或操作。它不解释动作业务语义， 只负责把一个 GFCombatAction 转换为另一个 GFCombatAction。

### Properties

#### `modifier_id`

- API: `public`

```gdscript
var modifier_id: StringName = &""
```

修正器标识。

#### `accepted_action_kinds`

- API: `public`

```gdscript
var accepted_action_kinds: Array[StringName] = []
```

非空时，只匹配这些动作类别。

#### `rejected_action_kinds`

- API: `public`

```gdscript
var rejected_action_kinds: Array[StringName] = []
```

始终拒绝匹配的动作类别。

#### `required_tags`

- API: `public`

```gdscript
var required_tags: Array[StringName] = []
```

非空时，动作必须包含这些标签。

#### `amount_add`

- API: `public`

```gdscript
var amount_add: float = 0.0
```

数值加成。

#### `amount_multiplier`

- API: `public`

```gdscript
var amount_multiplier: float = 1.0
```

数值乘区。

#### `override_operation`

- API: `public`

```gdscript
var override_operation: bool = false
```

是否覆盖动作操作。

#### `operation`

- API: `public`

```gdscript
var operation: GFCombatAction.Operation = GFCombatAction.Operation.SUBTRACT
```

覆盖后的动作操作。

#### `override_action_kind`

- API: `public`

```gdscript
var override_action_kind: bool = false
```

是否覆盖动作类别。

#### `action_kind`

- API: `public`

```gdscript
var action_kind: StringName = &""
```

覆盖后的动作类别。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

修正器元数据。

Schemas:

- `metadata`: Dictionary，项目自定义元数据；应用修正器时复制到动作结果的 modifiers 记录中。

### Methods

#### `matches`

- API: `public`

```gdscript
func matches(action: GFCombatAction) -> bool:
```

检查修正器是否匹配动作。

Parameters:

| Name | Description |
|---|---|
| `action` | 原始动作。 |

Returns: 匹配时返回 true。

#### `apply`

- API: `public`

```gdscript
func apply(action: GFCombatAction) -> GFCombatAction:
```

应用修正器。

Parameters:

| Name | Description |
|---|---|
| `action` | 原始动作。 |

Returns: 修正后的动作副本。

#### `duplicate_modifier`

- API: `public`

```gdscript
func duplicate_modifier() -> GFCombatActionModifier:
```

复制修正器。

Returns: 新修正器。

## GFCombatActionResult

- Path: `addons/gf/extensions/combat/actions/gf_combat_action_result.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFCombatActionResult: 通用战斗动作应用结果。 保存动作是否被接受、原始动作、最终动作、数值变化和元数据， 方便项目统一记录日志、派发事件或驱动反馈。

### Properties

#### `ok`

- API: `public`

```gdscript
var ok: bool = false
```

是否成功应用。

#### `reason`

- API: `public`

```gdscript
var reason: StringName = &""
```

结果原因。

#### `original_action`

- API: `public`

```gdscript
var original_action: GFCombatAction = null
```

原始动作副本。

#### `action`

- API: `public`

```gdscript
var action: GFCombatAction = null
```

最终动作副本。

#### `previous_value`

- API: `public`

```gdscript
var previous_value: float = 0.0
```

应用前数值。

#### `current_value`

- API: `public`

```gdscript
var current_value: float = 0.0
```

应用后数值。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: Dictionary，项目自定义结果元数据；框架只复制并透传。

### Methods

#### `make_success`

- API: `public`

```gdscript
static func make_success( p_original_action: GFCombatAction, p_action: GFCombatAction, p_previous_value: float, p_current_value: float, p_metadata: Dictionary = {} ) -> GFCombatActionResult:
```

创建成功结果。

Parameters:

| Name | Description |
|---|---|
| `p_original_action` | 原始动作。 |
| `p_action` | 最终动作。 |
| `p_previous_value` | 应用前数值。 |
| `p_current_value` | 应用后数值。 |
| `p_metadata` | 元数据。 |

Returns: 成功结果。

Schemas:

- `p_metadata`: Dictionary，项目自定义结果元数据；框架只复制并透传。

#### `make_failure`

- API: `public`

```gdscript
static func make_failure( p_reason: StringName, p_original_action: GFCombatAction = null, p_previous_value: float = 0.0, p_metadata: Dictionary = {} ) -> GFCombatActionResult:
```

创建失败结果。

Parameters:

| Name | Description |
|---|---|
| `p_reason` | 失败原因。 |
| `p_original_action` | 原始动作。 |
| `p_previous_value` | 当前数值。 |
| `p_metadata` | 元数据。 |

Returns: 失败结果。

Schemas:

- `p_metadata`: Dictionary，项目自定义结果元数据；框架只复制并透传。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转为字典。

Returns: 字典快照。

Schemas:

- `return`: Dictionary，包含 ok、reason、original_action、action、previous_value、current_value、delta 和 metadata。

## GFCombatGauge

- Path: `addons/gf/extensions/combat/attributes/gf_combat_gauge.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFCombatGauge: 通用可变数值槽。 用 GFCombatAction 驱动一个带上下限的数值。它可表示生命、护盾、能量、 耐久或任意项目自定义资源，但框架不绑定这些业务语义。

### Signals

#### `value_changed`

- API: `public`

```gdscript
signal value_changed(previous_value: float, current_value: float)
```

数值变化时发出。

Parameters:

| Name | Description |
|---|---|
| `previous_value` | 旧值。 |
| `current_value` | 新值。 |

#### `action_validating`

- API: `public`

```gdscript
signal action_validating(action: GFCombatAction, report: Dictionary)
```

动作进入自定义校验阶段时发出。

Parameters:

| Name | Description |
|---|---|
| `action` | 已经应用修正器的动作副本。 |
| `report` | 当前校验报告。 |

Schemas:

- `report`: Dictionary，包含 ok、reason 和 metadata，可由监听者调整。

#### `action_applied`

- API: `public`

```gdscript
signal action_applied(result: GFCombatActionResult)
```

动作成功应用时发出。

Parameters:

| Name | Description |
|---|---|
| `result` | 应用结果。 |

#### `action_rejected`

- API: `public`

```gdscript
signal action_rejected(result: GFCombatActionResult)
```

动作被拒绝时发出。

Parameters:

| Name | Description |
|---|---|
| `result` | 拒绝结果。 |

#### `minimum_reached`

- API: `public`

```gdscript
signal minimum_reached(current_value: float)
```

数值到达下限时发出。

Parameters:

| Name | Description |
|---|---|
| `current_value` | 当前值。 |

#### `maximum_reached`

- API: `public`

```gdscript
signal maximum_reached(current_value: float)
```

数值到达上限时发出。

Parameters:

| Name | Description |
|---|---|
| `current_value` | 当前值。 |

### Properties

#### `min_value`

- API: `public`

```gdscript
var min_value: float = 0.0
```

数值下限。

#### `max_value`

- API: `public`

```gdscript
var max_value: float = 100.0
```

数值上限。

#### `current_value`

- API: `public`

```gdscript
var current_value: float = 100.0
```

当前数值。

#### `accepted_action_kinds`

- API: `public`

```gdscript
var accepted_action_kinds: Array[StringName] = []
```

非空时，只接受这些动作类别。

#### `rejected_action_kinds`

- API: `public`

```gdscript
var rejected_action_kinds: Array[StringName] = []
```

始终拒绝的动作类别。

#### `modifiers`

- API: `public`

```gdscript
var modifiers: Array[GFCombatActionModifier] = []
```

动作修正器。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: Dictionary，项目自定义数值槽元数据；默认进入动作校验报告。

#### `validation_callback`

- API: `public`

```gdscript
var validation_callback: Callable = Callable()
```

自定义校验回调，建议签名为 func(action: GFCombatAction, report: Dictionary) -> Variant。 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure(p_min_value: float, p_max_value: float, p_current_value: float) -> void:
```

配置数值槽。

Parameters:

| Name | Description |
|---|---|
| `p_min_value` | 数值下限。 |
| `p_max_value` | 数值上限。 |
| `p_current_value` | 当前数值。 |

#### `set_value`

- API: `public`

```gdscript
func set_value(value: float) -> void:
```

设置当前数值。

Parameters:

| Name | Description |
|---|---|
| `value` | 新数值。 |

#### `set_bounds`

- API: `public`

```gdscript
func set_bounds(p_min_value: float, p_max_value: float) -> void:
```

设置上下限并夹取当前值。

Parameters:

| Name | Description |
|---|---|
| `p_min_value` | 数值下限。 |
| `p_max_value` | 数值上限。 |

#### `get_ratio`

- API: `public`

```gdscript
func get_ratio() -> float:
```

获取 0 到 1 的当前比例。

Returns: 当前比例。

#### `can_receive_action_kind`

- API: `public`

```gdscript
func can_receive_action_kind(action_kind: StringName) -> bool:
```

检查动作类别是否可被当前数值槽接收。

Parameters:

| Name | Description |
|---|---|
| `action_kind` | 动作类别。 |

Returns: 可接收时返回 true。

#### `add_modifier`

- API: `public`

```gdscript
func add_modifier(modifier: GFCombatActionModifier) -> void:
```

添加动作修正器。

Parameters:

| Name | Description |
|---|---|
| `modifier` | 修正器。 |

#### `remove_modifier`

- API: `public`

```gdscript
func remove_modifier(modifier: GFCombatActionModifier) -> void:
```

移除动作修正器。

Parameters:

| Name | Description |
|---|---|
| `modifier` | 修正器。 |

#### `clear_modifiers`

- API: `public`

```gdscript
func clear_modifiers() -> void:
```

清空动作修正器。

#### `apply_action`

- API: `public`

```gdscript
func apply_action(action: GFCombatAction) -> GFCombatActionResult:
```

应用动作。

Parameters:

| Name | Description |
|---|---|
| `action` | 原始动作。 |

Returns: 应用结果。

## GFCombatHitContext

- Path: `addons/gf/extensions/combat/hit_detection/gf_combat_hit_context.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFCombatHitContext: 一次通用命中交互的上下文。 只保存 source、target、hit_id、payload、位置和元数据。 它不解释伤害、阵营、生命值、命中结果或任何业务语义。

### Properties

#### `source`

- API: `public`

```gdscript
var source: Object = null
```

命中发起者。

#### `target`

- API: `public`

```gdscript
var target: Object = null
```

命中目标。

#### `hit_id`

- API: `public`

```gdscript
var hit_id: StringName = &""
```

命中 ID。

#### `payload`

- API: `public`

```gdscript
var payload: Variant = null
```

命中携带的数据。框架不解释该字段。

Schemas:

- `payload`: Variant，项目自定义命中载荷；框架只复制并透传。

#### `magnitude`

- API: `public`

```gdscript
var magnitude: float = 0.0
```

通用强度值。框架不解释该字段。

#### `tags`

- API: `public`

```gdscript
var tags: Array[StringName] = []
```

命中标签。框架不解释该字段。

#### `position_2d`

- API: `public`

```gdscript
var position_2d: Vector2 = Vector2.ZERO
```

2D 命中位置。

#### `normal_2d`

- API: `public`

```gdscript
var normal_2d: Vector2 = Vector2.ZERO
```

2D 命中法线。

#### `position_3d`

- API: `public`

```gdscript
var position_3d: Vector3 = Vector3.ZERO
```

3D 命中位置。

#### `normal_3d`

- API: `public`

```gdscript
var normal_3d: Vector3 = Vector3.ZERO
```

3D 命中法线。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，项目自定义命中元数据；框架只复制并透传。

### Methods

#### `with_source`

- API: `public`

```gdscript
func with_source(value: Object) -> GFCombatHitContext:
```

设置 source 并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | source 对象。 |

Returns: 当前上下文。

#### `with_target`

- API: `public`

```gdscript
func with_target(value: Object) -> GFCombatHitContext:
```

设置 target 并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | target 对象。 |

Returns: 当前上下文。

#### `with_hit_id`

- API: `public`

```gdscript
func with_hit_id(value: StringName) -> GFCombatHitContext:
```

设置 hit_id 并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 命中 ID。 |

Returns: 当前上下文。

#### `with_payload`

- API: `public`

```gdscript
func with_payload(value: Variant) -> GFCombatHitContext:
```

设置 payload 并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | payload 数据。 |

Returns: 当前上下文。

Schemas:

- `value`: Variant，项目自定义命中载荷；框架只复制并透传。

#### `with_magnitude`

- API: `public`

```gdscript
func with_magnitude(value: float) -> GFCombatHitContext:
```

设置通用强度值并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 通用强度值。 |

Returns: 当前上下文。

#### `with_tags`

- API: `public`

```gdscript
func with_tags(value: Array[StringName]) -> GFCombatHitContext:
```

设置标签并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 标签数组。 |

Returns: 当前上下文。

#### `with_metadata`

- API: `public`

```gdscript
func with_metadata(value: Dictionary) -> GFCombatHitContext:
```

设置元数据并返回自身。

Parameters:

| Name | Description |
|---|---|
| `value` | 元数据。 |

Returns: 当前上下文。

Schemas:

- `value`: Dictionary，项目自定义命中元数据；框架只复制并透传。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为字典快照。

Returns: 字典快照。

Schemas:

- `return`: Dictionary，包含 source、target、hit_id、payload、magnitude、tags、position_2d、normal_2d、position_3d、normal_3d 和 metadata。

## GFCombatPayloads

- Path: `addons/gf/extensions/combat/core/gf_combat_payloads.gd`
- Extends: `Node`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

GFCombatPayloads: 存放战斗相关的事件载体类。

### Inner Classes

#### GFCombatPayloads.GFBuffAppliedPayload

- Extends: `GFPayload`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

Buff 已应用事件。

##### Properties

###### `target`

- API: `public`

```gdscript
var target: Object
```

目标对象。

###### `buff`

- API: `public`

```gdscript
var buff: GFBuff
```

已应用的 Buff 实例。

#### GFCombatPayloads.GFBuffRefreshedPayload

- Extends: `GFPayload`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

Buff 已变动/刷新事件。

##### Properties

###### `target`

- API: `public`

```gdscript
var target: Object
```

目标对象。

###### `buff`

- API: `public`

```gdscript
var buff: GFBuff
```

已刷新的 Buff 实例。

#### GFCombatPayloads.GFBuffRemovedPayload

- Extends: `GFPayload`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

Buff 已移除事件。

##### Properties

###### `target`

- API: `public`

```gdscript
var target: Object
```

目标对象。

###### `buff_id`

- API: `public`

```gdscript
var buff_id: StringName
```

被移除的 Buff ID。

## GFCombatSystem

- Path: `addons/gf/extensions/combat/core/gf_combat_system.gd`
- Extends: `GFSystem`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFCombatSystem: 战斗核心系统。 负责驱动所有注册实体的 Buff 计时、周期触发以及技能 CD 更新。 继承自 GFSystem，可通过架构的 tick 自动运行。

### Methods

#### `tick`

- API: `public`

```gdscript
func tick(p_delta: float) -> void:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `p_delta` | 本帧时间增量（秒）。 |

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放系统持有的实体、Buff 与技能连接。

#### `register_entity`

- API: `public`

```gdscript
func register_entity(p_entity: Object) -> void:
```

注册战斗实体。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |

#### `unregister_entity`

- API: `public`

```gdscript
func unregister_entity(p_entity: Object) -> void:
```

注销战斗实体。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |

#### `add_buff`

- API: `public`

```gdscript
func add_buff(p_entity: Object, p_buff: GFBuff) -> void:
```

给实体添加一个 Buff。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |
| `p_buff` | Buff 实例。 |

#### `add_skill`

- API: `public`

```gdscript
func add_skill(p_entity: Object, p_skill: GFSkill) -> void:
```

为实体添加技能。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |
| `p_skill` | 技能实例。 |

#### `get_buff`

- API: `public`

```gdscript
func get_buff(p_entity: Object, p_buff_id: StringName) -> GFBuff:
```

获取实体上的指定 Buff。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |
| `p_buff_id` | Buff 标识。 |

Returns: 找到时返回正在系统中生效的 Buff 实例，否则返回 null。

#### `has_buff`

- API: `public`

```gdscript
func has_buff(p_entity: Object, p_buff_id: StringName) -> bool:
```

检查实体上是否存在指定 Buff。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |
| `p_buff_id` | Buff 标识。 |

Returns: 存在返回 true。

#### `get_buffs`

- API: `public`

```gdscript
func get_buffs(p_entity: Object) -> Array[GFBuff]:
```

获取实体当前持有的 Buff 列表副本。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |

Returns: Buff 实例数组副本；数组本身可安全修改，但元素仍是运行中的 Buff 引用。

#### `refresh_buff_modifiers`

- API: `public`

```gdscript
func refresh_buff_modifiers(p_entity: Object, p_buff_id: StringName) -> bool:
```

强制刷新指定 Buff 已挂载修饰器影响到的属性。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |
| `p_buff_id` | Buff 标识。 |

Returns: 至少刷新了一个属性时返回 true。

#### `remove_buff`

- API: `public`

```gdscript
func remove_buff(p_entity: Object, p_buff_id: StringName) -> bool:
```

移除实体上的指定 Buff。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |
| `p_buff_id` | Buff 标识。 |

Returns: 找到并移除 Buff 时返回 true。

#### `clear_buffs`

- API: `public`

```gdscript
func clear_buffs(p_entity: Object, predicate: Callable = Callable()) -> int:
```

清理实体上的 Buff。predicate 为空时清理全部；否则仅清理返回 true 的 Buff。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |
| `predicate` | 可选过滤回调，签名为 `func(buff: GFBuff) -> bool`。 |

Returns: 被清理的 Buff 数量。

#### `remove_skill`

- API: `public`

```gdscript
func remove_skill(p_entity: Object, p_skill: GFSkill) -> bool:
```

移除实体上的指定技能。

Parameters:

| Name | Description |
|---|---|
| `p_entity` | 实体对象。 |
| `p_skill` | 技能实例。 |

Returns: 找到并移除技能时返回 true。

## GFHitBox2D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hit_box_2d.gd`
- Extends: `Area2D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHitBox2D: 2D 通用命中发送区域。 节点负责构建 GFCombatHitContext 并发送给具备 receive_hit() 的接收对象， 不规定伤害、阵营、冷却、命中特效或生命值规则。

### Signals

#### `hit_sent`

- API: `public`

```gdscript
signal hit_sent(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中已发送。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_accepted`

- API: `public`

```gdscript
signal hit_accepted(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中被接收对象接受。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_rejected`

- API: `public`

```gdscript
signal hit_rejected(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中被接收对象拒绝或发送失败。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `enabled_changed`

- API: `public`

```gdscript
signal enabled_changed(enabled: bool)
```

启用状态变化时发出。

Parameters:

| Name | Description |
|---|---|
| `enabled` | 当前是否允许发送命中。 |

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true:
```

是否允许发送命中。

#### `hit_id`

- API: `public`

```gdscript
var hit_id: StringName = &""
```

默认命中 ID。

#### `payload`

- API: `public`

```gdscript
var payload: Dictionary = {}
```

默认 payload；发送时会深拷贝。

Schemas:

- `payload`: Dictionary，默认命中载荷；框架只复制并透传。

#### `magnitude`

- API: `public`

```gdscript
var magnitude: float = 0.0
```

通用强度值。框架不解释该字段。

#### `tags`

- API: `public`

```gdscript
var tags: Array[StringName] = []
```

命中标签。框架不解释该字段。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

发送器自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，发送器自定义命中元数据；会进入命中上下文和结果报告。

#### `sender_path`

- API: `public`

```gdscript
var sender_path: NodePath = NodePath("")
```

可选发送者路径；为空时使用当前节点。

#### `collision_shape_config`

- API: `public`

```gdscript
var collision_shape_config: GFHitCollisionShapeConfig2D = null:
```

可选碰撞形状配置。设置后可自动生成或更新 CollisionShape2D 子节点。

#### `collision_shape_configs`

- API: `public`

```gdscript
var collision_shape_configs: Array[GFHitCollisionShapeConfig2D] = []:
```

可选碰撞形状配置列表。非空时可自动生成或更新多个 CollisionShape2D 子节点。

#### `auto_apply_collision_shape_config`

- API: `public`

```gdscript
var auto_apply_collision_shape_config: bool = true
```

是否在进入场景树或配置变化时自动应用碰撞形状配置。

### Methods

#### `apply_collision_shape_config`

- API: `public`

```gdscript
func apply_collision_shape_config(config: GFHitCollisionShapeConfig2D = null) -> CollisionShape2D:
```

应用碰撞形状配置，创建或更新框架管理的 CollisionShape2D 子节点。

Parameters:

| Name | Description |
|---|---|
| `config` | 可选配置；为空时使用 collision_shape_config。 |

Returns: 创建或更新的 CollisionShape2D；配置无效时返回 null。

#### `apply_collision_shape_configs`

- API: `public`

```gdscript
func apply_collision_shape_configs(configs: Array[GFHitCollisionShapeConfig2D] = []) -> Array[CollisionShape2D]:
```

应用碰撞形状配置列表，创建或更新框架管理的多个 CollisionShape2D 子节点。

Parameters:

| Name | Description |
|---|---|
| `configs` | 可选配置列表；为空时使用 collision_shape_configs。 |

Returns: 创建或更新的 CollisionShape2D 列表。

#### `get_generated_collision_shape`

- API: `public`

```gdscript
func get_generated_collision_shape() -> CollisionShape2D:
```

获取框架管理的 CollisionShape2D 子节点。

Returns: 存在则返回 CollisionShape2D，否则返回 null。

#### `get_generated_collision_shapes`

- API: `public`

```gdscript
func get_generated_collision_shapes() -> Array[CollisionShape2D]:
```

获取框架管理的 CollisionShape2D 子节点列表。

Returns: 已生成的 CollisionShape2D 列表。

#### `clear_generated_collision_shape`

- API: `public`

```gdscript
func clear_generated_collision_shape() -> void:
```

移除框架管理的 CollisionShape2D 子节点。

#### `clear_generated_collision_shapes`

- API: `public`

```gdscript
func clear_generated_collision_shapes() -> void:
```

移除框架管理的全部 CollisionShape2D 子节点。

#### `build_hit_context`

- API: `public`

```gdscript
func build_hit_context( target: Object = null, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> GFCombatHitContext:
```

构建命中上下文。

Parameters:

| Name | Description |
|---|---|
| `target` | 命中目标。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 命中上下文。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。

#### `send_to`

- API: `public`

```gdscript
func send_to( receiver: Object, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> Dictionary:
```

向指定接收对象发送命中。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收对象。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。
- `return`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `send_to_path`

- API: `public`

```gdscript
func send_to_path( receiver_path: NodePath, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> Dictionary:
```

向指定节点路径发送命中。

Parameters:

| Name | Description |
|---|---|
| `receiver_path` | 接收节点路径。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。
- `return`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `broadcast_overlaps`

- API: `public`

```gdscript
func broadcast_overlaps( max_count: int = 0, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> Array[Dictionary]:
```

向当前重叠对象中的命中接收器批量发送命中。

Parameters:

| Name | Description |
|---|---|
| `max_count` | 最多发送数量；小于等于 0 表示不限制。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 结果报告列表。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。
- `return`: Array[Dictionary]，每项为统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

## GFHitBox3D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hit_box_3d.gd`
- Extends: `Area3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHitBox3D: 3D 通用命中发送区域。 节点负责构建 GFCombatHitContext 并发送给具备 receive_hit() 的接收对象， 不规定伤害、阵营、冷却、命中特效或生命值规则。

### Signals

#### `hit_sent`

- API: `public`

```gdscript
signal hit_sent(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中已发送。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_accepted`

- API: `public`

```gdscript
signal hit_accepted(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中被接收对象接受。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_rejected`

- API: `public`

```gdscript
signal hit_rejected(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中被接收对象拒绝或发送失败。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `enabled_changed`

- API: `public`

```gdscript
signal enabled_changed(enabled: bool)
```

启用状态变化时发出。

Parameters:

| Name | Description |
|---|---|
| `enabled` | 当前是否允许发送命中。 |

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true:
```

是否允许发送命中。

#### `hit_id`

- API: `public`

```gdscript
var hit_id: StringName = &""
```

默认命中 ID。

#### `payload`

- API: `public`

```gdscript
var payload: Dictionary = {}
```

默认 payload；发送时会深拷贝。

Schemas:

- `payload`: Dictionary，默认命中载荷；框架只复制并透传。

#### `magnitude`

- API: `public`

```gdscript
var magnitude: float = 0.0
```

通用强度值。框架不解释该字段。

#### `tags`

- API: `public`

```gdscript
var tags: Array[StringName] = []
```

命中标签。框架不解释该字段。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

发送器自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，发送器自定义命中元数据；会进入命中上下文和结果报告。

#### `sender_path`

- API: `public`

```gdscript
var sender_path: NodePath = NodePath("")
```

可选发送者路径；为空时使用当前节点。

#### `collision_shape_config`

- API: `public`

```gdscript
var collision_shape_config: GFHitCollisionShapeConfig3D = null:
```

可选碰撞形状配置。设置后可自动生成或更新 CollisionShape3D 子节点。

#### `collision_shape_configs`

- API: `public`

```gdscript
var collision_shape_configs: Array[GFHitCollisionShapeConfig3D] = []:
```

可选碰撞形状配置列表。非空时可自动生成或更新多个 CollisionShape3D 子节点。

#### `auto_apply_collision_shape_config`

- API: `public`

```gdscript
var auto_apply_collision_shape_config: bool = true
```

是否在进入场景树或配置变化时自动应用碰撞形状配置。

### Methods

#### `apply_collision_shape_config`

- API: `public`

```gdscript
func apply_collision_shape_config(config: GFHitCollisionShapeConfig3D = null) -> CollisionShape3D:
```

应用碰撞形状配置，创建或更新框架管理的 CollisionShape3D 子节点。

Parameters:

| Name | Description |
|---|---|
| `config` | 可选配置；为空时使用 collision_shape_config。 |

Returns: 创建或更新的 CollisionShape3D；配置无效时返回 null。

#### `apply_collision_shape_configs`

- API: `public`

```gdscript
func apply_collision_shape_configs(configs: Array[GFHitCollisionShapeConfig3D] = []) -> Array[CollisionShape3D]:
```

应用碰撞形状配置列表，创建或更新框架管理的多个 CollisionShape3D 子节点。

Parameters:

| Name | Description |
|---|---|
| `configs` | 可选配置列表；为空时使用 collision_shape_configs。 |

Returns: 创建或更新的 CollisionShape3D 列表。

#### `get_generated_collision_shape`

- API: `public`

```gdscript
func get_generated_collision_shape() -> CollisionShape3D:
```

获取框架管理的 CollisionShape3D 子节点。

Returns: 存在则返回 CollisionShape3D，否则返回 null。

#### `get_generated_collision_shapes`

- API: `public`

```gdscript
func get_generated_collision_shapes() -> Array[CollisionShape3D]:
```

获取框架管理的 CollisionShape3D 子节点列表。

Returns: 已生成的 CollisionShape3D 列表。

#### `clear_generated_collision_shape`

- API: `public`

```gdscript
func clear_generated_collision_shape() -> void:
```

移除框架管理的 CollisionShape3D 子节点。

#### `clear_generated_collision_shapes`

- API: `public`

```gdscript
func clear_generated_collision_shapes() -> void:
```

移除框架管理的全部 CollisionShape3D 子节点。

#### `build_hit_context`

- API: `public`

```gdscript
func build_hit_context( target: Object = null, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> GFCombatHitContext:
```

构建命中上下文。

Parameters:

| Name | Description |
|---|---|
| `target` | 命中目标。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 命中上下文。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。

#### `send_to`

- API: `public`

```gdscript
func send_to( receiver: Object, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> Dictionary:
```

向指定接收对象发送命中。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收对象。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。
- `return`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `send_to_path`

- API: `public`

```gdscript
func send_to_path( receiver_path: NodePath, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> Dictionary:
```

向指定节点路径发送命中。

Parameters:

| Name | Description |
|---|---|
| `receiver_path` | 接收节点路径。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。
- `return`: Dictionary，统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `broadcast_overlaps`

- API: `public`

```gdscript
func broadcast_overlaps( max_count: int = 0, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> Array[Dictionary]:
```

向当前重叠对象中的命中接收器批量发送命中。

Parameters:

| Name | Description |
|---|---|
| `max_count` | 最多发送数量；小于等于 0 表示不限制。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 结果报告列表。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。
- `return`: Array[Dictionary]，每项为统一命中发送结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

## GFHitBoxState2D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hit_box_state_2d.gd`
- Extends: `Node2D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHitBoxState2D: 2D 命中区域状态组。 统一启停子树内的 GFHitBox2D、GFHurtBox2D 与 Area2D，不处理伤害、阵营或技能规则。

### Signals

#### `active_changed`

- API: `public`

```gdscript
signal active_changed(active: bool)
```

状态应用后发出。

Parameters:

| Name | Description |
|---|---|
| `active` | 当前是否激活。 |

### Properties

#### `active`

- API: `public`

```gdscript
var active: bool = true:
```

当前状态是否激活。

#### `apply_on_ready`

- API: `public`

```gdscript
var apply_on_ready: bool = true
```

是否在 _ready() 时应用当前状态。

#### `recursive`

- API: `public`

```gdscript
var recursive: bool = true
```

是否递归管理子节点。

#### `manage_enabled`

- API: `public`

```gdscript
var manage_enabled: bool = true
```

是否同步 GFHitBox2D/GFHurtBox2D 的 enabled 字段。

#### `manage_monitoring`

- API: `public`

```gdscript
var manage_monitoring: bool = true
```

是否同步 Area2D 的 monitoring 与 monitorable。

#### `manage_visibility`

- API: `public`

```gdscript
var manage_visibility: bool = false
```

是否同步 CanvasItem.visible。

### Methods

#### `activate`

- API: `public`

```gdscript
func activate() -> void:
```

激活状态组。

#### `deactivate`

- API: `public`

```gdscript
func deactivate() -> void:
```

关闭状态组。

#### `set_active_state`

- API: `public`

```gdscript
func set_active_state(value: bool) -> void:
```

设置状态组激活状态。

Parameters:

| Name | Description |
|---|---|
| `value` | 是否激活。 |

#### `apply_state`

- API: `public`

```gdscript
func apply_state() -> void:
```

应用当前状态到所有受管理节点。

#### `get_managed_nodes`

- API: `public`

```gdscript
func get_managed_nodes() -> Array[Node]:
```

获取受管理节点列表。

Returns: 节点列表。

## GFHitBoxState3D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hit_box_state_3d.gd`
- Extends: `Node3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHitBoxState3D: 3D 命中区域状态组。 统一启停子树内的 GFHitBox3D、GFHurtBox3D 与 Area3D，不处理伤害、阵营或技能规则。

### Signals

#### `active_changed`

- API: `public`

```gdscript
signal active_changed(active: bool)
```

状态应用后发出。

Parameters:

| Name | Description |
|---|---|
| `active` | 当前是否激活。 |

### Properties

#### `active`

- API: `public`

```gdscript
var active: bool = true:
```

当前状态是否激活。

#### `apply_on_ready`

- API: `public`

```gdscript
var apply_on_ready: bool = true
```

是否在 _ready() 时应用当前状态。

#### `recursive`

- API: `public`

```gdscript
var recursive: bool = true
```

是否递归管理子节点。

#### `manage_enabled`

- API: `public`

```gdscript
var manage_enabled: bool = true
```

是否同步 GFHitBox3D/GFHurtBox3D 的 enabled 字段。

#### `manage_monitoring`

- API: `public`

```gdscript
var manage_monitoring: bool = true
```

是否同步 Area3D 的 monitoring 与 monitorable。

#### `manage_visibility`

- API: `public`

```gdscript
var manage_visibility: bool = false
```

是否同步 Node3D.visible。

### Methods

#### `activate`

- API: `public`

```gdscript
func activate() -> void:
```

激活状态组。

#### `deactivate`

- API: `public`

```gdscript
func deactivate() -> void:
```

关闭状态组。

#### `set_active_state`

- API: `public`

```gdscript
func set_active_state(value: bool) -> void:
```

设置状态组激活状态。

Parameters:

| Name | Description |
|---|---|
| `value` | 是否激活。 |

#### `apply_state`

- API: `public`

```gdscript
func apply_state() -> void:
```

应用当前状态到所有受管理节点。

#### `get_managed_nodes`

- API: `public`

```gdscript
func get_managed_nodes() -> Array[Node]:
```

获取受管理节点列表。

Returns: 节点列表。

## GFHitCollisionShapeConfig2D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hit_collision_shape_config_2d.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFHitCollisionShapeConfig2D: 2D 命中区域碰撞形状配置。 用于把可复用的 Shape2D、偏移、旋转、缩放、调试颜色和禁用状态应用到 HitBox / HurtBox 自动生成的 CollisionShape2D 上。不表达伤害、阵营或其他玩法规则。

### Properties

#### `shape`

- API: `public`

```gdscript
var shape: Shape2D = null
```

要应用的 Godot 2D 碰撞形状。

#### `position`

- API: `public`

```gdscript
var position: Vector2 = Vector2.ZERO
```

碰撞形状相对 HitBox / HurtBox 节点的位置。

#### `rotation_degrees`

- API: `public`

```gdscript
var rotation_degrees: float = 0.0
```

碰撞形状相对 HitBox / HurtBox 节点的旋转角度。

#### `scale`

- API: `public`

```gdscript
var scale: Vector2 = Vector2.ONE
```

碰撞形状相对 HitBox / HurtBox 节点的缩放。

#### `debug_color`

- API: `public`

```gdscript
var debug_color: Color = Color(0.0, 0.0, 0.0, 0.0)
```

调试绘制颜色。透明色会沿用 Godot 默认调试显示。

#### `disabled`

- API: `public`

```gdscript
var disabled: bool = false
```

是否禁用生成的 CollisionShape2D。

### Methods

#### `apply_to`

- API: `public`

```gdscript
func apply_to(collision_shape: CollisionShape2D) -> bool:
```

将配置应用到指定 CollisionShape2D。

Parameters:

| Name | Description |
|---|---|
| `collision_shape` | 目标 CollisionShape2D。 |

Returns: 应用成功返回 true。

#### `instantiate_collision_shape`

- API: `public`

```gdscript
func instantiate_collision_shape() -> CollisionShape2D:
```

创建一个已应用当前配置的 CollisionShape2D。

Returns: 创建成功返回 CollisionShape2D；配置缺少 shape 时返回 null。

## GFHitCollisionShapeConfig3D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hit_collision_shape_config_3d.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFHitCollisionShapeConfig3D: 3D 命中区域碰撞形状配置。 用于把可复用的 Shape3D、偏移、旋转、缩放、调试颜色和禁用状态应用到 HitBox / HurtBox 自动生成的 CollisionShape3D 上。不表达伤害、阵营或其他玩法规则。

### Properties

#### `shape`

- API: `public`

```gdscript
var shape: Shape3D = null
```

要应用的 Godot 3D 碰撞形状。

#### `position`

- API: `public`

```gdscript
var position: Vector3 = Vector3.ZERO
```

碰撞形状相对 HitBox / HurtBox 节点的位置。

#### `rotation_degrees`

- API: `public`

```gdscript
var rotation_degrees: Vector3 = Vector3.ZERO
```

碰撞形状相对 HitBox / HurtBox 节点的旋转角度。

#### `scale`

- API: `public`

```gdscript
var scale: Vector3 = Vector3.ONE
```

碰撞形状相对 HitBox / HurtBox 节点的缩放。

#### `debug_color`

- API: `public`

```gdscript
var debug_color: Color = Color(0.0, 0.0, 0.0, 0.0)
```

调试绘制颜色。透明色会沿用 Godot 默认调试显示。

#### `disabled`

- API: `public`

```gdscript
var disabled: bool = false
```

是否禁用生成的 CollisionShape3D。

### Methods

#### `apply_to`

- API: `public`

```gdscript
func apply_to(collision_shape: CollisionShape3D) -> bool:
```

将配置应用到指定 CollisionShape3D。

Parameters:

| Name | Description |
|---|---|
| `collision_shape` | 目标 CollisionShape3D。 |

Returns: 应用成功返回 true。

#### `instantiate_collision_shape`

- API: `public`

```gdscript
func instantiate_collision_shape() -> CollisionShape3D:
```

创建一个已应用当前配置的 CollisionShape3D。

Returns: 创建成功返回 CollisionShape3D；配置缺少 shape 时返回 null。

## GFHitScan2D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hit_scan_2d.gd`
- Extends: `RayCast2D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHitScan2D: 2D 通用射线命中发送器。 基于 RayCast2D 构建 GFCombatHitContext 并发送给具备 receive_hit() 的接收对象。 它不规定伤害、穿透、命中特效或任何业务规则。

### Signals

#### `scan_hit`

- API: `public`

```gdscript
signal scan_hit(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

扫描命中对象后发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一扫描命中结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `scan_missed`

- API: `public`

```gdscript
signal scan_missed(report: Dictionary)
```

扫描没有命中可发送对象时发出。

Parameters:

| Name | Description |
|---|---|
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，扫描未命中报告，包含 ok、reason 和 metadata。

#### `hit_accepted`

- API: `public`

```gdscript
signal hit_accepted(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中被接收对象接受。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一扫描命中结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_rejected`

- API: `public`

```gdscript
signal hit_rejected(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中被接收对象拒绝或发送失败。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一扫描命中结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

### Properties

#### `hit_enabled`

- API: `public`

```gdscript
var hit_enabled: bool = true
```

是否允许发送命中。

#### `force_update_before_scan`

- API: `public`

```gdscript
var force_update_before_scan: bool = true
```

扫描前是否强制刷新射线。

#### `hit_id`

- API: `public`

```gdscript
var hit_id: StringName = &""
```

默认命中 ID。

#### `payload`

- API: `public`

```gdscript
var payload: Dictionary = {}
```

默认 payload；发送时会深拷贝。

Schemas:

- `payload`: Dictionary，默认命中载荷；框架只复制并透传。

#### `magnitude`

- API: `public`

```gdscript
var magnitude: float = 0.0
```

通用强度值。框架不解释该字段。

#### `tags`

- API: `public`

```gdscript
var tags: Array[StringName] = []
```

命中标签。框架不解释该字段。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

发送器自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，发送器自定义扫描命中元数据；会进入命中上下文和结果报告。

#### `sender_path`

- API: `public`

```gdscript
var sender_path: NodePath = NodePath("")
```

可选发送者路径；为空时使用当前节点。

### Methods

#### `build_hit_context`

- API: `public`

```gdscript
func build_hit_context( target: Object = null, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> GFCombatHitContext:
```

构建命中上下文。

Parameters:

| Name | Description |
|---|---|
| `target` | 命中目标。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 命中上下文。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。

#### `scan`

- API: `public`

```gdscript
func scan(payload_override: Variant = null, hit_id_override: StringName = &"") -> Dictionary:
```

执行一次射线扫描并尝试发送命中。

Parameters:

| Name | Description |
|---|---|
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。
- `return`: Dictionary，统一扫描命中或未命中结果，包含 ok、reason、metadata，并在命中时包含 hit_id、receiver 和 message。

## GFHitScan3D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hit_scan_3d.gd`
- Extends: `RayCast3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHitScan3D: 3D 通用射线命中发送器。 基于 RayCast3D 构建 GFCombatHitContext 并发送给具备 receive_hit() 的接收对象。 它不规定伤害、穿透、命中特效或任何业务规则。

### Signals

#### `scan_hit`

- API: `public`

```gdscript
signal scan_hit(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

扫描命中对象后发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一扫描命中结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `scan_missed`

- API: `public`

```gdscript
signal scan_missed(report: Dictionary)
```

扫描没有命中可发送对象时发出。

Parameters:

| Name | Description |
|---|---|
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，扫描未命中报告，包含 ok、reason 和 metadata。

#### `hit_accepted`

- API: `public`

```gdscript
signal hit_accepted(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中被接收对象接受。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一扫描命中结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_rejected`

- API: `public`

```gdscript
signal hit_rejected(context: GFCombatHitContext, receiver: Object, report: Dictionary)
```

命中被接收对象拒绝或发送失败。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `receiver` | 接收对象。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一扫描命中结果，包含 ok、hit_id、receiver、reason、message 和 metadata。

### Properties

#### `hit_enabled`

- API: `public`

```gdscript
var hit_enabled: bool = true
```

是否允许发送命中。

#### `force_update_before_scan`

- API: `public`

```gdscript
var force_update_before_scan: bool = true
```

扫描前是否强制刷新射线。

#### `hit_id`

- API: `public`

```gdscript
var hit_id: StringName = &""
```

默认命中 ID。

#### `payload`

- API: `public`

```gdscript
var payload: Dictionary = {}
```

默认 payload；发送时会深拷贝。

Schemas:

- `payload`: Dictionary，默认命中载荷；框架只复制并透传。

#### `magnitude`

- API: `public`

```gdscript
var magnitude: float = 0.0
```

通用强度值。框架不解释该字段。

#### `tags`

- API: `public`

```gdscript
var tags: Array[StringName] = []
```

命中标签。框架不解释该字段。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

发送器自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，发送器自定义扫描命中元数据；会进入命中上下文和结果报告。

#### `sender_path`

- API: `public`

```gdscript
var sender_path: NodePath = NodePath("")
```

可选发送者路径；为空时使用当前节点。

### Methods

#### `build_hit_context`

- API: `public`

```gdscript
func build_hit_context( target: Object = null, payload_override: Variant = null, hit_id_override: StringName = &"" ) -> GFCombatHitContext:
```

构建命中上下文。

Parameters:

| Name | Description |
|---|---|
| `target` | 命中目标。 |
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 命中上下文。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。

#### `scan`

- API: `public`

```gdscript
func scan(payload_override: Variant = null, hit_id_override: StringName = &"") -> Dictionary:
```

执行一次射线扫描并尝试发送命中。

Parameters:

| Name | Description |
|---|---|
| `payload_override` | 覆盖 payload；为 null 时使用节点默认 payload。 |
| `hit_id_override` | 覆盖命中 ID；为空时使用节点默认命中 ID。 |

Returns: 统一结果报告。

Schemas:

- `payload_override`: Variant，可为 null、Dictionary 或项目自定义命中载荷；为 null 时使用节点默认 payload。
- `return`: Dictionary，统一扫描命中或未命中结果，包含 ok、reason、metadata，并在命中时包含 hit_id、receiver 和 message。

## GFHomingProjectileMotion

- Path: `addons/gf/extensions/combat/projectiles/gf_homing_projectile_motion.gd`
- Extends: `GFProjectileMotion`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFHomingProjectileMotion: 2D/3D 通用追踪发射体移动策略。 目标可通过 launch() 上下文中的 target、target_position、target_position_2d 或 target_position_3d 传入，也可以用 target_path 从发射体节点相对查找。

### Properties

#### `speed`

- API: `public`

```gdscript
var speed: float = 0.0
```

每秒移动距离。

#### `target_path`

- API: `public`

```gdscript
var target_path: NodePath = NodePath("")
```

可选目标节点路径。为空时只读取 projectile_context。

#### `target_context_key`

- API: `public`

```gdscript
var target_context_key: StringName = &"target"
```

从 projectile_context 读取目标对象或位置的键。

#### `target_position_context_key`

- API: `public`

```gdscript
var target_position_context_key: StringName = &"target_position"
```

从 projectile_context 读取通用目标位置的键。

#### `arrival_distance`

- API: `public`

```gdscript
var arrival_distance: float = 0.0
```

到目标的距离小于等于该值时视为到达。小于 0 表示不标记到达。

#### `track_target`

- API: `public`

```gdscript
var track_target: bool = true
```

是否每帧重新朝向当前目标。关闭后只在首次解析目标时锁定方向。

#### `stop_when_reached`

- API: `public`

```gdscript
var stop_when_reached: bool = true
```

到达目标范围时是否停止并夹住位移，避免越过目标。

## GFHurtBox2D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hurt_box_2d.gd`
- Extends: `Area2D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHurtBox2D: 2D 通用命中接收区域。 节点只过滤和接收 GFCombatHitContext，不直接修改生命、属性或 Buff。

### Signals

#### `hit_validating`

- API: `public`

```gdscript
signal hit_validating(context: GFCombatHitContext, report: Dictionary)
```

命中进入自定义校验阶段时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `report` | 当前结果报告副本。 |

Schemas:

- `report`: Dictionary，当前命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_received`

- API: `public`

```gdscript
signal hit_received(context: GFCombatHitContext, report: Dictionary)
```

命中被接受时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_rejected`

- API: `public`

```gdscript
signal hit_rejected(context: GFCombatHitContext, report: Dictionary)
```

命中被拒绝时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `enabled_changed`

- API: `public`

```gdscript
signal enabled_changed(enabled: bool)
```

启用状态变化时发出。

Parameters:

| Name | Description |
|---|---|
| `enabled` | 当前是否允许接收命中。 |

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true:
```

是否允许接收命中。

#### `accepted_hit_ids`

- API: `public`

```gdscript
var accepted_hit_ids: Array[StringName] = []
```

非空时，只接受这些命中 ID。

#### `rejected_hit_ids`

- API: `public`

```gdscript
var rejected_hit_ids: Array[StringName] = []
```

始终拒绝的命中 ID。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

接收器自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，接收器自定义命中元数据；会进入命中接收报告。

#### `receiver_path`

- API: `public`

```gdscript
var receiver_path: NodePath = NodePath("")
```

可选业务接收节点路径；为空时由当前 HurtBox 直接接收。

#### `collision_shape_config`

- API: `public`

```gdscript
var collision_shape_config: GFHitCollisionShapeConfig2D = null:
```

可选碰撞形状配置。设置后可自动生成或更新 CollisionShape2D 子节点。

#### `collision_shape_configs`

- API: `public`

```gdscript
var collision_shape_configs: Array[GFHitCollisionShapeConfig2D] = []:
```

可选碰撞形状配置列表。非空时可自动生成或更新多个 CollisionShape2D 子节点。

#### `auto_apply_collision_shape_config`

- API: `public`

```gdscript
var auto_apply_collision_shape_config: bool = true
```

是否在进入场景树或配置变化时自动应用碰撞形状配置。

#### `validation_callback`

- API: `public`

```gdscript
var validation_callback: Callable = Callable()
```

自定义校验回调，建议签名为 func(context: GFCombatHitContext, report: Dictionary) -> Variant。 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。

### Methods

#### `apply_collision_shape_config`

- API: `public`

```gdscript
func apply_collision_shape_config(config: GFHitCollisionShapeConfig2D = null) -> CollisionShape2D:
```

应用碰撞形状配置，创建或更新框架管理的 CollisionShape2D 子节点。

Parameters:

| Name | Description |
|---|---|
| `config` | 可选配置；为空时使用 collision_shape_config。 |

Returns: 创建或更新的 CollisionShape2D；配置无效时返回 null。

#### `apply_collision_shape_configs`

- API: `public`

```gdscript
func apply_collision_shape_configs(configs: Array[GFHitCollisionShapeConfig2D] = []) -> Array[CollisionShape2D]:
```

应用碰撞形状配置列表，创建或更新框架管理的多个 CollisionShape2D 子节点。

Parameters:

| Name | Description |
|---|---|
| `configs` | 可选配置列表；为空时使用 collision_shape_configs。 |

Returns: 创建或更新的 CollisionShape2D 列表。

#### `get_generated_collision_shape`

- API: `public`

```gdscript
func get_generated_collision_shape() -> CollisionShape2D:
```

获取框架管理的 CollisionShape2D 子节点。

Returns: 存在则返回 CollisionShape2D，否则返回 null。

#### `get_generated_collision_shapes`

- API: `public`

```gdscript
func get_generated_collision_shapes() -> Array[CollisionShape2D]:
```

获取框架管理的 CollisionShape2D 子节点列表。

Returns: 已生成的 CollisionShape2D 列表。

#### `clear_generated_collision_shape`

- API: `public`

```gdscript
func clear_generated_collision_shape() -> void:
```

移除框架管理的 CollisionShape2D 子节点。

#### `clear_generated_collision_shapes`

- API: `public`

```gdscript
func clear_generated_collision_shapes() -> void:
```

移除框架管理的全部 CollisionShape2D 子节点。

#### `can_receive_hit`

- API: `public`

```gdscript
func can_receive_hit(p_hit_id: StringName = &"") -> bool:
```

检查指定命中 ID 是否可被当前接收器接受。

Parameters:

| Name | Description |
|---|---|
| `p_hit_id` | 命中 ID。 |

Returns: 可接受时返回 true。

#### `receive_hit`

- API: `public`

```gdscript
func receive_hit(context: GFCombatHitContext) -> Dictionary:
```

接收一次命中。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |

Returns: 统一结果报告。

Schemas:

- `return`: Dictionary，统一命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。

## GFHurtBox3D

- Path: `addons/gf/extensions/combat/hit_detection/gf_hurt_box_3d.gd`
- Extends: `Area3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHurtBox3D: 3D 通用命中接收区域。 节点只过滤和接收 GFCombatHitContext，不直接修改生命、属性或 Buff。

### Signals

#### `hit_validating`

- API: `public`

```gdscript
signal hit_validating(context: GFCombatHitContext, report: Dictionary)
```

命中进入自定义校验阶段时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `report` | 当前结果报告副本。 |

Schemas:

- `report`: Dictionary，当前命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_received`

- API: `public`

```gdscript
signal hit_received(context: GFCombatHitContext, report: Dictionary)
```

命中被接受时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `hit_rejected`

- API: `public`

```gdscript
signal hit_rejected(context: GFCombatHitContext, report: Dictionary)
```

命中被拒绝时发出。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |
| `report` | 结果报告。 |

Schemas:

- `report`: Dictionary，统一命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。

#### `enabled_changed`

- API: `public`

```gdscript
signal enabled_changed(enabled: bool)
```

启用状态变化时发出。

Parameters:

| Name | Description |
|---|---|
| `enabled` | 当前是否允许接收命中。 |

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true:
```

是否允许接收命中。

#### `accepted_hit_ids`

- API: `public`

```gdscript
var accepted_hit_ids: Array[StringName] = []
```

非空时，只接受这些命中 ID。

#### `rejected_hit_ids`

- API: `public`

```gdscript
var rejected_hit_ids: Array[StringName] = []
```

始终拒绝的命中 ID。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

接收器自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，接收器自定义命中元数据；会进入命中接收报告。

#### `receiver_path`

- API: `public`

```gdscript
var receiver_path: NodePath = NodePath("")
```

可选业务接收节点路径；为空时由当前 HurtBox 直接接收。

#### `collision_shape_config`

- API: `public`

```gdscript
var collision_shape_config: GFHitCollisionShapeConfig3D = null:
```

可选碰撞形状配置。设置后可自动生成或更新 CollisionShape3D 子节点。

#### `collision_shape_configs`

- API: `public`

```gdscript
var collision_shape_configs: Array[GFHitCollisionShapeConfig3D] = []:
```

可选碰撞形状配置列表。非空时可自动生成或更新多个 CollisionShape3D 子节点。

#### `auto_apply_collision_shape_config`

- API: `public`

```gdscript
var auto_apply_collision_shape_config: bool = true
```

是否在进入场景树或配置变化时自动应用碰撞形状配置。

#### `validation_callback`

- API: `public`

```gdscript
var validation_callback: Callable = Callable()
```

自定义校验回调，建议签名为 func(context: GFCombatHitContext, report: Dictionary) -> Variant。 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。

### Methods

#### `apply_collision_shape_config`

- API: `public`

```gdscript
func apply_collision_shape_config(config: GFHitCollisionShapeConfig3D = null) -> CollisionShape3D:
```

应用碰撞形状配置，创建或更新框架管理的 CollisionShape3D 子节点。

Parameters:

| Name | Description |
|---|---|
| `config` | 可选配置；为空时使用 collision_shape_config。 |

Returns: 创建或更新的 CollisionShape3D；配置无效时返回 null。

#### `apply_collision_shape_configs`

- API: `public`

```gdscript
func apply_collision_shape_configs(configs: Array[GFHitCollisionShapeConfig3D] = []) -> Array[CollisionShape3D]:
```

应用碰撞形状配置列表，创建或更新框架管理的多个 CollisionShape3D 子节点。

Parameters:

| Name | Description |
|---|---|
| `configs` | 可选配置列表；为空时使用 collision_shape_configs。 |

Returns: 创建或更新的 CollisionShape3D 列表。

#### `get_generated_collision_shape`

- API: `public`

```gdscript
func get_generated_collision_shape() -> CollisionShape3D:
```

获取框架管理的 CollisionShape3D 子节点。

Returns: 存在则返回 CollisionShape3D，否则返回 null。

#### `get_generated_collision_shapes`

- API: `public`

```gdscript
func get_generated_collision_shapes() -> Array[CollisionShape3D]:
```

获取框架管理的 CollisionShape3D 子节点列表。

Returns: 已生成的 CollisionShape3D 列表。

#### `clear_generated_collision_shape`

- API: `public`

```gdscript
func clear_generated_collision_shape() -> void:
```

移除框架管理的 CollisionShape3D 子节点。

#### `clear_generated_collision_shapes`

- API: `public`

```gdscript
func clear_generated_collision_shapes() -> void:
```

移除框架管理的全部 CollisionShape3D 子节点。

#### `can_receive_hit`

- API: `public`

```gdscript
func can_receive_hit(p_hit_id: StringName = &"") -> bool:
```

检查指定命中 ID 是否可被当前接收器接受。

Parameters:

| Name | Description |
|---|---|
| `p_hit_id` | 命中 ID。 |

Returns: 可接受时返回 true。

#### `receive_hit`

- API: `public`

```gdscript
func receive_hit(context: GFCombatHitContext) -> Dictionary:
```

接收一次命中。

Parameters:

| Name | Description |
|---|---|
| `context` | 命中上下文。 |

Returns: 统一结果报告。

Schemas:

- `return`: Dictionary，统一命中接收报告，包含 ok、hit_id、receiver、reason、message 和 metadata。

## GFLinearProjectileMotion

- Path: `addons/gf/extensions/combat/projectiles/gf_linear_projectile_motion.gd`
- Extends: `GFProjectileMotion`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFLinearProjectileMotion: 2D/3D 通用直线发射体移动策略。 该策略只处理线性位移，不处理碰撞、伤害、生命周期或目标选择。

### Properties

#### `speed`

- API: `public`

```gdscript
var speed: float = 0.0
```

每秒移动距离。

#### `direction_2d`

- API: `public`

```gdscript
var direction_2d: Vector2 = Vector2.RIGHT
```

2D 方向。use_local_direction 为 true 时按发射体当前变换转换。

#### `direction_3d`

- API: `public`

```gdscript
var direction_3d: Vector3 = Vector3.FORWARD
```

3D 方向。use_local_direction 为 true 时按发射体当前变换转换。

#### `use_local_direction`

- API: `public`

```gdscript
var use_local_direction: bool = true
```

是否把方向视为发射体本地坐标。

#### `normalize_direction`

- API: `public`

```gdscript
var normalize_direction: bool = true
```

是否归一化方向。

## GFModifiedAttribute

- Path: `addons/gf/extensions/combat/attributes/gf_modified_attribute.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFModifiedAttribute: 带修饰器公式的响应式属性。 持有基础值并管理多个修饰器 (GFModifier)。 内部使用公式 (Base + BaseAdd) * (1.0 + PercentAdd) + FinalAdd 进行自动重算。 对外通过只读的 current_value 暴露响应式结果，方便 UI 绑定。

### Properties

#### `current_value`

- API: `public`

```gdscript
var current_value: GFBindableProperty:
```

属性的只读响应式当前值。

### Methods

#### `set_base_value`

- API: `public`

```gdscript
func set_base_value(p_value: float) -> void:
```

设置基础值。

Parameters:

| Name | Description |
|---|---|
| `p_value` | 新的基础值。 |

#### `get_base_value`

- API: `public`

```gdscript
func get_base_value() -> float:
```

获取基础值。

Returns: 当前基础值。

#### `add_modifier`

- API: `public`

```gdscript
func add_modifier(p_modifier: GFModifier) -> void:
```

添加修饰器。

Parameters:

| Name | Description |
|---|---|
| `p_modifier` | 修饰器实例。 |

#### `remove_modifier`

- API: `public`

```gdscript
func remove_modifier(p_modifier: GFModifier) -> void:
```

移除修饰器。

Parameters:

| Name | Description |
|---|---|
| `p_modifier` | 要移除的修饰器实例。 |

#### `remove_modifiers_by_source`

- API: `public`

```gdscript
func remove_modifiers_by_source(p_source_id: StringName) -> void:
```

根据 source_id 移除所有匹配的修饰器。

Parameters:

| Name | Description |
|---|---|
| `p_source_id` | 来源标识。 |

#### `force_recalculate`

- API: `public`

```gdscript
func force_recalculate() -> void:
```

强制执行一次属性重算。 当外部直接修改了 Modifier 的数值时，可手动调用此方法触发 UI 更新。

## GFModifiedAttributeSet

- Path: `addons/gf/extensions/combat/attributes/gf_modified_attribute_set.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFModifiedAttributeSet: 一组可修饰运行时属性。 用 StringName 管理多个 GFModifiedAttribute，便于角色、装备或能力对象集中维护 移动速度、攻击、防御等项目自定义数值。它不规定属性含义，也不直接处理 Buff 生命周期。

### Signals

#### `attribute_defined`

- API: `public`

```gdscript
signal attribute_defined(attribute_id: StringName, attribute: GFModifiedAttribute)
```

属性被定义或替换时发出。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `attribute` | 属性实例。 |

#### `attribute_removed`

- API: `public`

```gdscript
signal attribute_removed(attribute_id: StringName)
```

属性被移除时发出。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |

#### `attribute_changed`

- API: `public`

```gdscript
signal attribute_changed(attribute_id: StringName, current_value: float, previous_value: float)
```

属性当前值变化时发出。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `current_value` | 当前值。 |
| `previous_value` | 变化前的值。 |

### Methods

#### `define_attribute`

- API: `public`

```gdscript
func define_attribute(attribute_id: StringName, base_value: float = 0.0) -> GFModifiedAttribute:
```

定义或替换属性。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `base_value` | 基础值。 |

Returns: 新创建的属性；attribute_id 为空时返回 null。

#### `set_attribute`

- API: `public`

```gdscript
func set_attribute(attribute_id: StringName, attribute: GFModifiedAttribute) -> bool:
```

设置已有属性实例。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `attribute` | 属性实例。 |

Returns: 设置成功返回 true。

#### `define_defaults`

- API: `public`

```gdscript
func define_defaults(defaults: Dictionary) -> void:
```

批量定义默认属性。

Parameters:

| Name | Description |
|---|---|
| `defaults` | attribute_id -> base_value 字典。 |

Schemas:

- `defaults`: Dictionary，键为属性标识，值为基础数值。

#### `has_attribute`

- API: `public`

```gdscript
func has_attribute(attribute_id: StringName) -> bool:
```

检查属性是否存在。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |

Returns: 存在返回 true。

#### `get_attribute`

- API: `public`

```gdscript
func get_attribute(attribute_id: StringName) -> GFModifiedAttribute:
```

获取属性实例。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |

Returns: 属性实例；不存在时返回 null。

#### `get_or_define_attribute`

- API: `public`

```gdscript
func get_or_define_attribute(attribute_id: StringName, base_value: float = 0.0) -> GFModifiedAttribute:
```

获取属性实例，不存在时自动定义。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `base_value` | 自动定义时使用的基础值。 |

Returns: 属性实例；attribute_id 为空时返回 null。

#### `remove_attribute`

- API: `public`

```gdscript
func remove_attribute(attribute_id: StringName) -> bool:
```

移除属性。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |

Returns: 移除成功返回 true。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空所有属性。

#### `get_attribute_ids`

- API: `public`

```gdscript
func get_attribute_ids() -> Array[StringName]:
```

获取属性 ID 列表。

Returns: 属性 ID 列表。

Schemas:

- `return`: Array[StringName]，元素为属性标识。

#### `get_attributes`

- API: `public`

```gdscript
func get_attributes() -> Dictionary:
```

获取属性字典副本。

Returns: attribute_id -> GFModifiedAttribute 字典副本。

Schemas:

- `return`: Dictionary，键为属性标识，值为 GFModifiedAttribute 实例。

#### `get_value`

- API: `public`

```gdscript
func get_value(attribute_id: StringName, default_value: float = 0.0) -> float:
```

获取属性当前值。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `default_value` | 属性不存在时返回的默认值。 |

Returns: 当前值。

#### `set_base_value`

- API: `public`

```gdscript
func set_base_value(attribute_id: StringName, base_value: float) -> bool:
```

设置属性基础值。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `base_value` | 新基础值。 |

Returns: 设置成功返回 true。

#### `get_base_value`

- API: `public`

```gdscript
func get_base_value(attribute_id: StringName, default_value: float = 0.0) -> float:
```

获取属性基础值。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `default_value` | 属性不存在时返回的默认值。 |

Returns: 基础值。

#### `add_modifier`

- API: `public`

```gdscript
func add_modifier( attribute_id: StringName, modifier: GFModifier, define_if_missing: bool = false ) -> bool:
```

添加修饰器。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `modifier` | 修饰器实例。 |
| `define_if_missing` | 属性不存在时是否自动定义。 |

Returns: 添加成功返回 true。

#### `remove_modifier`

- API: `public`

```gdscript
func remove_modifier(attribute_id: StringName, modifier: GFModifier) -> bool:
```

移除修饰器。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `modifier` | 修饰器实例。 |

Returns: 属性存在且 modifier 有效时返回 true。

#### `remove_modifiers_by_source`

- API: `public`

```gdscript
func remove_modifiers_by_source(source_id: StringName, attribute_id: StringName = &"") -> void:
```

按来源移除修饰器；attribute_id 为空时会作用于全部属性。

Parameters:

| Name | Description |
|---|---|
| `source_id` | 来源标识。 |
| `attribute_id` | 可选属性标识。 |

#### `force_recalculate`

- API: `public`

```gdscript
func force_recalculate(attribute_id: StringName = &"") -> void:
```

强制重算属性；attribute_id 为空时会重算全部属性。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 可选属性标识。 |

#### `get_base_value_snapshot`

- API: `public`

```gdscript
func get_base_value_snapshot() -> Dictionary:
```

导出基础值快照。修饰器属于运行时状态，不会进入该快照。

Returns: attribute_id -> base_value 字典。

Schemas:

- `return`: Dictionary，键为属性标识，值为基础数值。

#### `restore_base_value_snapshot`

- API: `public`

```gdscript
func restore_base_value_snapshot(snapshot: Dictionary, clear_existing: bool = false) -> void:
```

从基础值快照恢复。

Parameters:

| Name | Description |
|---|---|
| `snapshot` | attribute_id -> base_value 字典。 |
| `clear_existing` | 是否先清空现有属性。 |

Schemas:

- `snapshot`: Dictionary，键为属性标识，值为基础数值。

## GFModifier

- Path: `addons/gf/extensions/combat/attributes/gf_modifier.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFModifier: 属性修饰器数据类。 定义了如何修改一个通用属性（如加值、乘值）。 `attribute_id` 表示目标属性，`source_id` 表示来源，避免把“改谁”和“从哪来”混在一起。 通常由 Buff、装备或被动技能产生。

### Enums

#### `Type`

- API: `public`

```gdscript
enum Type { ## 基础加值。 BASE_ADD, ## 百分比乘区。 PERCENT_ADD, ## 最终加值。 FINAL_ADD, }
```

修饰器计算类型。

### Properties

#### `type`

- API: `public`

```gdscript
var type: Type = Type.BASE_ADD
```

修饰器类型。

#### `value`

- API: `public`

```gdscript
var value: float = 0.0
```

修饰器的数值。

#### `attribute_id`

- API: `public`

```gdscript
var attribute_id: StringName = &""
```

目标属性标识，例如 &"ATK"、&"HP"。

#### `source_id`

- API: `public`

```gdscript
var source_id: StringName = &""
```

来源标识，例如 Buff ID、装备 ID 或被动技能 ID，用于查找和移除。

### Methods

#### `create_base_add`

- API: `public`

```gdscript
static func create_base_add( p_value: float, p_attribute_id: StringName = &"", p_source_id: StringName = &"" ) -> GFModifier:
```

静态工厂方法：创建基础加值修饰器。

Parameters:

| Name | Description |
|---|---|
| `p_value` | 修饰器数值。 |
| `p_attribute_id` | 修饰器作用的属性标识。 |
| `p_source_id` | 修饰器来源标识。 |

Returns: 新修饰器。

#### `create_percent_add`

- API: `public`

```gdscript
static func create_percent_add( p_value: float, p_attribute_id: StringName = &"", p_source_id: StringName = &"" ) -> GFModifier:
```

静态工厂方法：创建百分比加值修饰器。

Parameters:

| Name | Description |
|---|---|
| `p_value` | 修饰器数值。 |
| `p_attribute_id` | 修饰器作用的属性标识。 |
| `p_source_id` | 修饰器来源标识。 |

Returns: 新修饰器。

#### `create_final_add`

- API: `public`

```gdscript
static func create_final_add( p_value: float, p_attribute_id: StringName = &"", p_source_id: StringName = &"" ) -> GFModifier:
```

静态工厂方法：创建最终加值修饰器。

Parameters:

| Name | Description |
|---|---|
| `p_value` | 修饰器数值。 |
| `p_attribute_id` | 修饰器作用的属性标识。 |
| `p_source_id` | 修饰器来源标识。 |

Returns: 新修饰器。

## GFProjectile2D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_2d.gd`
- Extends: `GFHitBox2D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFProjectile2D: 可组合移动策略的 2D 发射体命中节点。 它继承 GFHitBox2D，命中仍通过 GFCombatHitContext 发送给 receive_hit()。 节点只负责移动、寿命和碰撞触发，不解释伤害、阵营或生命值规则。

### Signals

#### `projectile_launched`

- API: `public`

```gdscript
signal projectile_launched(projectile: GFProjectile2D)
```

发射体启动时发出。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 当前发射体。 |

#### `projectile_finished`

- API: `public`

```gdscript
signal projectile_finished(projectile: GFProjectile2D, reason: StringName)
```

发射体结束时发出。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 当前发射体。 |
| `reason` | 结束原因。 |

### Properties

#### `auto_launch_on_ready`

- API: `public`

```gdscript
var auto_launch_on_ready: bool = true
```

ready 后是否自动启动本次发射。

#### `motion`

- API: `public`

```gdscript
var motion: Resource = null
```

移动策略。应实现 setup(projectile, context) 与 step(projectile, delta, context)。

#### `lifetime_policy`

- API: `public`

```gdscript
var lifetime_policy: Resource = null
```

生命周期策略。应实现 setup(projectile, context) 与 should_finish(projectile, elapsed, context)。

#### `finish_on_impact`

- API: `public`

```gdscript
var finish_on_impact: bool = true
```

命中任意 receive_hit() 接收器后是否结束。

#### `queue_free_on_finish`

- API: `public`

```gdscript
var queue_free_on_finish: bool = true
```

结束时是否 queue_free。使用对象池时通常应关闭。

### Methods

#### `launch`

- API: `public`

```gdscript
func launch(projectile_context: Dictionary = {}) -> void:
```

启动或重置本次发射。

Parameters:

| Name | Description |
|---|---|
| `projectile_context` | 本次发射的上下文字典。 |

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；会复制后传给 motion、lifetime_policy 和命中记录。

#### `finish`

- API: `public`

```gdscript
func finish(reason: StringName = &"finished") -> void:
```

结束本次发射。

Parameters:

| Name | Description |
|---|---|
| `reason` | 结束原因。 |

#### `is_projectile_active`

- API: `public`

```gdscript
func is_projectile_active() -> bool:
```

判断发射体是否处于已启动状态。

Returns: 已启动且未结束时返回 true。

#### `get_elapsed_seconds`

- API: `public`

```gdscript
func get_elapsed_seconds() -> float:
```

获取本次发射经过的秒数。

Returns: 经过的秒数。

#### `get_projectile_context`

- API: `public`

```gdscript
func get_projectile_context() -> Dictionary:
```

获取本次发射上下文副本。

Returns: 上下文字典副本。

Schemas:

- `return`: Dictionary，本次发射上下文副本，包含调用方上下文、发射器写入字段和 impact 计数。

#### `send_impact_to`

- API: `public`

```gdscript
func send_impact_to(candidate: Object) -> void:
```

向碰撞候选对象发送一次发射体命中。

Parameters:

| Name | Description |
|---|---|
| `candidate` | 碰撞候选对象，可为接收器或其子节点。 |

## GFProjectile3D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_3d.gd`
- Extends: `GFHitBox3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFProjectile3D: 可组合移动策略的 3D 发射体命中节点。 它继承 GFHitBox3D，命中仍通过 GFCombatHitContext 发送给 receive_hit()。 节点只负责移动、寿命和碰撞触发，不解释伤害、阵营或生命值规则。

### Signals

#### `projectile_launched`

- API: `public`

```gdscript
signal projectile_launched(projectile: GFProjectile3D)
```

发射体启动时发出。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 当前发射体。 |

#### `projectile_finished`

- API: `public`

```gdscript
signal projectile_finished(projectile: GFProjectile3D, reason: StringName)
```

发射体结束时发出。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 当前发射体。 |
| `reason` | 结束原因。 |

### Properties

#### `auto_launch_on_ready`

- API: `public`

```gdscript
var auto_launch_on_ready: bool = true
```

ready 后是否自动启动本次发射。

#### `motion`

- API: `public`

```gdscript
var motion: Resource = null
```

移动策略。应实现 setup(projectile, context) 与 step(projectile, delta, context)。

#### `lifetime_policy`

- API: `public`

```gdscript
var lifetime_policy: Resource = null
```

生命周期策略。应实现 setup(projectile, context) 与 should_finish(projectile, elapsed, context)。

#### `finish_on_impact`

- API: `public`

```gdscript
var finish_on_impact: bool = true
```

命中任意 receive_hit() 接收器后是否结束。

#### `queue_free_on_finish`

- API: `public`

```gdscript
var queue_free_on_finish: bool = true
```

结束时是否 queue_free。使用对象池时通常应关闭。

### Methods

#### `launch`

- API: `public`

```gdscript
func launch(projectile_context: Dictionary = {}) -> void:
```

启动或重置本次发射。

Parameters:

| Name | Description |
|---|---|
| `projectile_context` | 本次发射的上下文字典。 |

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；会复制后传给 motion、lifetime_policy 和命中记录。

#### `finish`

- API: `public`

```gdscript
func finish(reason: StringName = &"finished") -> void:
```

结束本次发射。

Parameters:

| Name | Description |
|---|---|
| `reason` | 结束原因。 |

#### `is_projectile_active`

- API: `public`

```gdscript
func is_projectile_active() -> bool:
```

判断发射体是否处于已启动状态。

Returns: 已启动且未结束时返回 true。

#### `get_elapsed_seconds`

- API: `public`

```gdscript
func get_elapsed_seconds() -> float:
```

获取本次发射经过的秒数。

Returns: 经过的秒数。

#### `get_projectile_context`

- API: `public`

```gdscript
func get_projectile_context() -> Dictionary:
```

获取本次发射上下文副本。

Returns: 上下文字典副本。

Schemas:

- `return`: Dictionary，本次发射上下文副本，包含调用方上下文、发射器写入字段和 impact 计数。

#### `send_impact_to`

- API: `public`

```gdscript
func send_impact_to(candidate: Object) -> void:
```

向碰撞候选对象发送一次发射体命中。

Parameters:

| Name | Description |
|---|---|
| `candidate` | 碰撞候选对象，可为接收器或其子节点。 |

## GFProjectileBurstPattern2D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_burst_pattern_2d.gd`
- Extends: `GFProjectileSpawnPattern2D`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFProjectileBurstPattern2D: 2D 扇形/环形发射点模式。 通过数量、角度和半径生成一组通用发射变换，适合散射、圆环、扇形或单点发射。

### Properties

#### `projectile_count`

- API: `public`

```gdscript
var projectile_count: int = 1
```

默认发射数量。

#### `spread_degrees`

- API: `public`

```gdscript
var spread_degrees: float = 0.0
```

总扩散角度（度）。数量大于 1 时在该范围内均匀分布。

#### `center_angle_degrees`

- API: `public`

```gdscript
var center_angle_degrees: float = 0.0
```

相对发射器朝向的中心角度（度）。

#### `radius`

- API: `public`

```gdscript
var radius: float = 0.0
```

生成点距离发射器的半径。

#### `rotate_to_direction`

- API: `public`

```gdscript
var rotate_to_direction: bool = true
```

生成变换是否朝向对应发射方向。

#### `include_emitter_rotation`

- API: `public`

```gdscript
var include_emitter_rotation: bool = true
```

是否把发射器自身旋转计入方向。

## GFProjectileCatalog

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_catalog.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFProjectileCatalog: 发射体场景目录。 用稳定 ID 管理 PackedScene，供发射器、技能或项目自己的生成流程复用。 目录不规定发射体的伤害、阵营、消耗或命中特效。

### Properties

#### `entries`

- API: `public`

```gdscript
var entries: Array[GFProjectileCatalogEntry] = []
```

发射体场景条目列表。

### Methods

#### `set_scene`

- API: `public`

```gdscript
func set_scene(projectile_id: StringName, scene: PackedScene) -> void:
```

设置或替换一个发射体场景。

Parameters:

| Name | Description |
|---|---|
| `projectile_id` | 发射体 ID。 |
| `scene` | 发射体场景；为 null 时移除该 ID。 |

#### `get_scene`

- API: `public`

```gdscript
func get_scene(projectile_id: StringName) -> PackedScene:
```

获取指定 ID 的发射体场景。

Parameters:

| Name | Description |
|---|---|
| `projectile_id` | 发射体 ID。 |

Returns: 找到时返回 PackedScene，否则返回 null。

#### `remove_scene`

- API: `public`

```gdscript
func remove_scene(projectile_id: StringName) -> bool:
```

移除指定 ID 的发射体场景。

Parameters:

| Name | Description |
|---|---|
| `projectile_id` | 发射体 ID。 |

Returns: 移除成功返回 true。

#### `has_scene`

- API: `public`

```gdscript
func has_scene(projectile_id: StringName) -> bool:
```

检查指定 ID 是否存在有效场景。

Parameters:

| Name | Description |
|---|---|
| `projectile_id` | 发射体 ID。 |

Returns: 存在有效场景时返回 true。

#### `get_projectile_ids`

- API: `public`

```gdscript
func get_projectile_ids() -> PackedStringArray:
```

获取所有有效发射体 ID。

Returns: 按字典序排序的 ID 数组。

#### `prune_invalid_entries`

- API: `public`

```gdscript
func prune_invalid_entries() -> int:
```

清理空条目、空 ID 或空场景。

Returns: 被清理的条目数量。

## GFProjectileCatalogEntry

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_catalog_entry.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFProjectileCatalogEntry: 发射体目录中的单个场景映射。 只把稳定 ID 映射到 PackedScene，不解释该场景的玩法含义。

### Properties

#### `projectile_id`

- API: `public`

```gdscript
var projectile_id: StringName = &""
```

发射体 ID。

#### `scene`

- API: `public`

```gdscript
var scene: PackedScene = null
```

发射体场景。

### Methods

#### `is_valid_entry`

- API: `public`

```gdscript
func is_valid_entry() -> bool:
```

检查条目是否可用于实例化。

Returns: ID 和场景都有效时返回 true。

## GFProjectileConePattern3D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_cone_pattern_3d.gd`
- Extends: `GFProjectileSpawnPattern3D`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFProjectileConePattern3D: 3D 水平扇形发射点模式。 围绕发射器局部 Y 轴分布 yaw，可叠加固定 pitch，并按变换前向生成点位。

### Properties

#### `projectile_count`

- API: `public`

```gdscript
var projectile_count: int = 1
```

默认发射数量。

#### `yaw_spread_degrees`

- API: `public`

```gdscript
var yaw_spread_degrees: float = 0.0
```

总水平扩散角度（度）。

#### `pitch_degrees`

- API: `public`

```gdscript
var pitch_degrees: float = 0.0
```

额外俯仰角度（度）。

#### `radius`

- API: `public`

```gdscript
var radius: float = 0.0
```

生成点距离发射器的半径。

## GFProjectileEmitter2D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_emitter_2d.gd`
- Extends: `Node2D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFProjectileEmitter2D: 通用 2D 发射体生成节点。 负责按场景目录和生成点模式实例化发射体，并把本次发射上下文交给 发射体的 launch()。它不解释伤害、阵营、弹药、冷却或特效规则。

### Signals

#### `projectile_emitted`

- API: `public`

```gdscript
signal projectile_emitted(projectile: Node, projectile_context: Dictionary)
```

发射体已生成。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 生成的发射体节点。 |
| `projectile_context` | 本次发射上下文。 |

Schemas:

- `projectile_context`: Dictionary，本次发射上下文副本，包含默认上下文、调用方上下文和 spawn 信息。

#### `projectile_emit_failed`

- API: `public`

```gdscript
signal projectile_emit_failed(reason: StringName, details: Dictionary)
```

发射失败时发出。

Parameters:

| Name | Description |
|---|---|
| `reason` | 失败原因。 |
| `details` | 失败细节。 |

Schemas:

- `details`: Dictionary，失败上下文，通常包含 projectile_id、spawn_index 等诊断字段。

### Properties

#### `projectile_scene`

- API: `public`

```gdscript
var projectile_scene: PackedScene = null
```

默认发射体场景。未使用目录或目录缺少 ID 时使用。

#### `projectile_catalog`

- API: `public`

```gdscript
var projectile_catalog: GFProjectileCatalog = null
```

可选发射体目录。

#### `default_projectile_id`

- API: `public`

```gdscript
var default_projectile_id: StringName = &""
```

默认目录 ID。

#### `spawn_pattern`

- API: `public`

```gdscript
var spawn_pattern: GFProjectileSpawnPattern2D = null
```

2D 发射点模式。为空时使用发射器自身全局变换。

#### `default_context`

- API: `public`

```gdscript
var default_context: Dictionary = {}
```

默认上下文。每次发射会深拷贝后再合并调用方上下文。

Schemas:

- `default_context`: Dictionary，默认发射上下文；每次发射会深拷贝后合并调用方上下文。

#### `spawn_parent_path`

- API: `public`

```gdscript
var spawn_parent_path: NodePath = NodePath("")
```

可选生成父节点路径。为空时优先使用发射器父节点。

#### `launch_after_spawn`

- API: `public`

```gdscript
var launch_after_spawn: bool = true
```

是否在生成后调用发射体的 launch(context)。

#### `disable_auto_launch_before_add`

- API: `public`

```gdscript
var disable_auto_launch_before_add: bool = true
```

生成前是否关闭常见发射体的 auto_launch_on_ready，避免进入树时使用空上下文启动。

#### `use_object_pool`

- API: `public`

```gdscript
var use_object_pool: bool = false
```

是否使用 GFObjectPoolUtility 获取节点。池化场景应把 projectile 的 auto_launch_on_ready 设为 false。

#### `release_pooled_projectile_on_finish`

- API: `public`

```gdscript
var release_pooled_projectile_on_finish: bool = true
```

使用对象池时，是否在 projectile_finished 后自动归还节点。

#### `object_pool_utility`

- API: `public`

```gdscript
var object_pool_utility: GFObjectPoolUtility = null
```

可选对象池工具。为空时会从注入架构或最近的 GFNodeContext 查询。

### Methods

#### `emit_projectile`

- API: `public`

```gdscript
func emit_projectile(projectile_context: Dictionary = {}, projectile_id: StringName = &"") -> Node:
```

发射单个发射体。

Parameters:

| Name | Description |
|---|---|
| `projectile_context` | 本次发射上下文。 |
| `projectile_id` | 可选目录 ID；为空时使用 default_projectile_id。 |

Returns: 生成的发射体节点；失败时返回 null。

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；会与 default_context 合并后传给发射体。

#### `emit_projectiles`

- API: `public`

```gdscript
func emit_projectiles( projectile_context: Dictionary = {}, projectile_id: StringName = &"", emit_count: int = -1 ) -> Array[Node]:
```

按当前模式发射一批发射体。

Parameters:

| Name | Description |
|---|---|
| `projectile_context` | 本次发射上下文。 |
| `projectile_id` | 可选目录 ID；为空时使用 default_projectile_id。 |
| `emit_count` | 请求生成数量；小于等于 0 时由 spawn_pattern 决定。 |

Returns: 成功生成的发射体节点列表。

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；会与 default_context 合并后传给每个发射体。

#### `resolve_projectile_scene`

- API: `public`

```gdscript
func resolve_projectile_scene(projectile_id: StringName = &"") -> PackedScene:
```

解析当前要使用的发射体场景。

Parameters:

| Name | Description |
|---|---|
| `projectile_id` | 可选目录 ID。 |

Returns: 找到时返回 PackedScene，否则返回 null。

#### `resolve_spawn_parent`

- API: `public`

```gdscript
func resolve_spawn_parent() -> Node:
```

解析发射体生成父节点。

Returns: 有效父节点；找不到时返回 null。

#### `prewarm_projectiles`

- API: `public`

```gdscript
func prewarm_projectiles(count: int, projectile_id: StringName = &"") -> bool:
```

预热对象池。

Parameters:

| Name | Description |
|---|---|
| `count` | 预热数量。 |
| `projectile_id` | 可选目录 ID。 |

Returns: 预热请求被接受时返回 true。

## GFProjectileEmitter3D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_emitter_3d.gd`
- Extends: `Node3D`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFProjectileEmitter3D: 通用 3D 发射体生成节点。 负责按场景目录和生成点模式实例化发射体，并把本次发射上下文交给 发射体的 launch()。它不解释伤害、阵营、弹药、冷却或特效规则。

### Signals

#### `projectile_emitted`

- API: `public`

```gdscript
signal projectile_emitted(projectile: Node, projectile_context: Dictionary)
```

发射体已生成。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 生成的发射体节点。 |
| `projectile_context` | 本次发射上下文。 |

Schemas:

- `projectile_context`: Dictionary，本次发射上下文副本，包含默认上下文、调用方上下文和 spawn 信息。

#### `projectile_emit_failed`

- API: `public`

```gdscript
signal projectile_emit_failed(reason: StringName, details: Dictionary)
```

发射失败时发出。

Parameters:

| Name | Description |
|---|---|
| `reason` | 失败原因。 |
| `details` | 失败细节。 |

Schemas:

- `details`: Dictionary，失败上下文，通常包含 projectile_id、spawn_index 等诊断字段。

### Properties

#### `projectile_scene`

- API: `public`

```gdscript
var projectile_scene: PackedScene = null
```

默认发射体场景。未使用目录或目录缺少 ID 时使用。

#### `projectile_catalog`

- API: `public`

```gdscript
var projectile_catalog: GFProjectileCatalog = null
```

可选发射体目录。

#### `default_projectile_id`

- API: `public`

```gdscript
var default_projectile_id: StringName = &""
```

默认目录 ID。

#### `spawn_pattern`

- API: `public`

```gdscript
var spawn_pattern: GFProjectileSpawnPattern3D = null
```

3D 发射点模式。为空时使用发射器自身全局变换。

#### `default_context`

- API: `public`

```gdscript
var default_context: Dictionary = {}
```

默认上下文。每次发射会深拷贝后再合并调用方上下文。

Schemas:

- `default_context`: Dictionary，默认发射上下文；每次发射会深拷贝后合并调用方上下文。

#### `spawn_parent_path`

- API: `public`

```gdscript
var spawn_parent_path: NodePath = NodePath("")
```

可选生成父节点路径。为空时优先使用发射器父节点。

#### `launch_after_spawn`

- API: `public`

```gdscript
var launch_after_spawn: bool = true
```

是否在生成后调用发射体的 launch(context)。

#### `disable_auto_launch_before_add`

- API: `public`

```gdscript
var disable_auto_launch_before_add: bool = true
```

生成前是否关闭常见发射体的 auto_launch_on_ready，避免进入树时使用空上下文启动。

#### `use_object_pool`

- API: `public`

```gdscript
var use_object_pool: bool = false
```

是否使用 GFObjectPoolUtility 获取节点。池化场景应把 projectile 的 auto_launch_on_ready 设为 false。

#### `release_pooled_projectile_on_finish`

- API: `public`

```gdscript
var release_pooled_projectile_on_finish: bool = true
```

使用对象池时，是否在 projectile_finished 后自动归还节点。

#### `object_pool_utility`

- API: `public`

```gdscript
var object_pool_utility: GFObjectPoolUtility = null
```

可选对象池工具。为空时会从注入架构或最近的 GFNodeContext 查询。

### Methods

#### `emit_projectile`

- API: `public`

```gdscript
func emit_projectile(projectile_context: Dictionary = {}, projectile_id: StringName = &"") -> Node:
```

发射单个发射体。

Parameters:

| Name | Description |
|---|---|
| `projectile_context` | 本次发射上下文。 |
| `projectile_id` | 可选目录 ID；为空时使用 default_projectile_id。 |

Returns: 生成的发射体节点；失败时返回 null。

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；会与 default_context 合并后传给发射体。

#### `emit_projectiles`

- API: `public`

```gdscript
func emit_projectiles( projectile_context: Dictionary = {}, projectile_id: StringName = &"", emit_count: int = -1 ) -> Array[Node]:
```

按当前模式发射一批发射体。

Parameters:

| Name | Description |
|---|---|
| `projectile_context` | 本次发射上下文。 |
| `projectile_id` | 可选目录 ID；为空时使用 default_projectile_id。 |
| `emit_count` | 请求生成数量；小于等于 0 时由 spawn_pattern 决定。 |

Returns: 成功生成的发射体节点列表。

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；会与 default_context 合并后传给每个发射体。

#### `resolve_projectile_scene`

- API: `public`

```gdscript
func resolve_projectile_scene(projectile_id: StringName = &"") -> PackedScene:
```

解析当前要使用的发射体场景。

Parameters:

| Name | Description |
|---|---|
| `projectile_id` | 可选目录 ID。 |

Returns: 找到时返回 PackedScene，否则返回 null。

#### `resolve_spawn_parent`

- API: `public`

```gdscript
func resolve_spawn_parent() -> Node:
```

解析发射体生成父节点。

Returns: 有效父节点；找不到时返回 null。

#### `prewarm_projectiles`

- API: `public`

```gdscript
func prewarm_projectiles(count: int, projectile_id: StringName = &"") -> bool:
```

预热对象池。

Parameters:

| Name | Description |
|---|---|
| `count` | 预热数量。 |
| `projectile_id` | 可选目录 ID。 |

Returns: 预热请求被接受时返回 true。

## GFProjectileLifetimePolicy

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_lifetime_policy.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFProjectileLifetimePolicy: 发射体生命周期策略。 默认支持按时间和距离结束。项目可继承后叠加自定义结束条件。

### Properties

#### `max_seconds`

- API: `public`

```gdscript
var max_seconds: float = 0.0
```

最长存活时间。小于等于 0 表示不按时间结束。

#### `max_distance`

- API: `public`

```gdscript
var max_distance: float = 0.0
```

最远移动距离。小于等于 0 表示不按距离结束。

#### `max_impacts`

- API: `public`

```gdscript
var max_impacts: int = 0
```

最大成功命中次数。小于等于 0 表示不按命中次数结束。

### Methods

#### `setup`

- API: `public`

```gdscript
func setup(projectile: Node, projectile_context: Dictionary = {}) -> void:
```

发射体启动时调用。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 发射体节点。 |
| `projectile_context` | 本次发射的上下文字典。 |

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；会写入初始位置和 impact_count。

#### `should_finish`

- API: `public`

```gdscript
func should_finish(projectile: Node, elapsed_seconds: float, projectile_context: Dictionary = {}) -> bool:
```

判断发射体是否应结束。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 发射体节点。 |
| `elapsed_seconds` | 本次发射已经运行的秒数。 |
| `projectile_context` | 本次发射的上下文字典。 |

Returns: 应结束时返回 true。

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；用于读取初始位置和 impact_count。

## GFProjectileLineSpawnPattern2D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_line_spawn_pattern_2d.gd`
- Extends: `GFProjectileSpawnPattern2D`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFProjectileLineSpawnPattern2D: 沿 2D 局部线段生成发射点。 只描述发射点分布，适合多炮口、线性随机点或沿武器边缘生成发射体。

### Properties

#### `point_count`

- API: `public`

```gdscript
var point_count: int = 1
```

默认发射数量。

#### `local_start`

- API: `public`

```gdscript
var local_start: Vector2 = Vector2.ZERO
```

线段局部起点。

#### `local_end`

- API: `public`

```gdscript
var local_end: Vector2 = Vector2.ZERO
```

线段局部终点。

#### `rotate_to_line`

- API: `public`

```gdscript
var rotate_to_line: bool = false
```

生成变换是否朝向线段方向。

## GFProjectileLineSpawnPattern3D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_line_spawn_pattern_3d.gd`
- Extends: `GFProjectileSpawnPattern3D`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFProjectileLineSpawnPattern3D: 沿 3D 局部线段生成发射点。 只描述发射点分布，适合多炮口、轨道点或沿空间线段生成发射体。

### Properties

#### `point_count`

- API: `public`

```gdscript
var point_count: int = 1
```

默认发射数量。

#### `local_start`

- API: `public`

```gdscript
var local_start: Vector3 = Vector3.ZERO
```

线段局部起点。

#### `local_end`

- API: `public`

```gdscript
var local_end: Vector3 = Vector3.ZERO
```

线段局部终点。

#### `rotate_to_line`

- API: `public`

```gdscript
var rotate_to_line: bool = false
```

生成变换是否朝向线段方向。

## GFProjectileMotion

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_motion.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFProjectileMotion: 发射体移动策略基类。 移动策略只负责根据 delta 推进节点位置。需要跨帧保存的数据应写入 projectile_context，避免共享 Resource 在多个发射体之间串状态。

### Methods

#### `setup`

- API: `public`

```gdscript
func setup(projectile: Node, projectile_context: Dictionary = {}) -> void:
```

发射体启动时调用。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 发射体节点。 |
| `projectile_context` | 本次发射的上下文字典。 |

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；移动策略可写入跨帧状态。

#### `step`

- API: `public`

```gdscript
func step(projectile: Node, delta: float, projectile_context: Dictionary = {}) -> void:
```

推进一帧移动。

Parameters:

| Name | Description |
|---|---|
| `projectile` | 发射体节点。 |
| `delta` | 物理帧间隔。 |
| `projectile_context` | 本次发射的上下文字典。 |

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；移动策略可读取或写入跨帧状态。

## GFProjectileSpawnPattern2D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_spawn_pattern_2d.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFProjectileSpawnPattern2D: 2D 发射体生成点模式基类。 模式只返回全局 Transform2D 列表，不实例化节点，也不解释伤害、弹药或阵营。

### Methods

#### `get_spawn_transforms`

- API: `public`

```gdscript
func get_spawn_transforms( emitter: Node2D, projectile_context: Dictionary = {}, emit_count: int = -1 ) -> Array[Transform2D]:
```

计算本次发射的全局生成变换。

Parameters:

| Name | Description |
|---|---|
| `emitter` | 发射器节点。 |
| `projectile_context` | 本次发射上下文。 |
| `emit_count` | 调用方请求的数量；小于等于 0 时由模式自行决定。 |

Returns: 全局 Transform2D 列表。

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；模式只读取调用方约定的数据。

## GFProjectileSpawnPattern3D

- Path: `addons/gf/extensions/combat/projectiles/gf_projectile_spawn_pattern_3d.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFProjectileSpawnPattern3D: 3D 发射体生成点模式基类。 模式只返回全局 Transform3D 列表，不实例化节点，也不解释伤害、弹药或阵营。

### Methods

#### `get_spawn_transforms`

- API: `public`

```gdscript
func get_spawn_transforms( emitter: Node3D, projectile_context: Dictionary = {}, emit_count: int = -1 ) -> Array[Transform3D]:
```

计算本次发射的全局生成变换。

Parameters:

| Name | Description |
|---|---|
| `emitter` | 发射器节点。 |
| `projectile_context` | 本次发射上下文。 |
| `emit_count` | 调用方请求的数量；小于等于 0 时由模式自行决定。 |

Returns: 全局 Transform3D 列表。

Schemas:

- `projectile_context`: Dictionary，本次发射上下文；模式只读取调用方约定的数据。

## GFSkill

- Path: `addons/gf/extensions/combat/skills/gf_skill.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFSkill: 技能基类。 负责冷却、施放校验与目标解析入口， 具体技能逻辑通过子类重写 `_on_execute()` 实现。

### Signals

#### `cooldown_started`

- API: `public`

```gdscript
signal cooldown_started(skill: GFSkill)
```

当技能开始进入冷却时发出。

Parameters:

| Name | Description |
|---|---|
| `skill` | 进入冷却的技能实例。 |

#### `activation_failed`

- API: `public`

```gdscript
signal activation_failed(skill: GFSkill, context)
```

当技能激活失败时发出。

Parameters:

| Name | Description |
|---|---|
| `skill` | 激活失败的技能实例。 |
| `context` | 技能激活上下文。 |

#### `activation_committed`

- API: `public`

```gdscript
signal activation_committed(skill: GFSkill, context)
```

当技能完成激活提交并进入冷却时发出。

Parameters:

| Name | Description |
|---|---|
| `skill` | 已提交的技能实例。 |
| `context` | 技能激活上下文。 |

### Properties

#### `id`

- API: `public`

```gdscript
var id: StringName = &""
```

技能 ID。

#### `cooldown_max`

- API: `public`

```gdscript
var cooldown_max: float = 0.0
```

最大冷却时间。

#### `cooldown_left`

- API: `public`

```gdscript
var cooldown_left: float = 0.0
```

当前剩余冷却时间。

#### `require_tags`

- API: `public`

```gdscript
var require_tags: Array[StringName] = []
```

释放技能所需标签。

#### `ignore_tags`

- API: `public`

```gdscript
var ignore_tags: Array[StringName] = []
```

释放技能时禁止存在的标签。

#### `owner`

- API: `public`

```gdscript
var owner: Object = null
```

技能拥有者。

#### `targeting_rule`

- API: `public`

```gdscript
var targeting_rule: GFSkillTargetingRule = null
```

技能索敌规则。

#### `activation_query`

- API: `public`

```gdscript
var activation_query: GFTagQuery = null
```

可选标签查询。为空时使用 require_tags / ignore_tags。

#### `activation_checks`

- API: `public`

```gdscript
var activation_checks: Array[Callable] = []
```

激活检查回调。每个回调接收 GFSkillActivationContext，可返回 bool 或 { ok, reason, metadata }。

Schemas:

- `activation_checks`: Array[Callable]，用于项目自定义成本、状态或上下文检查。

#### `activation_commit_callbacks`

- API: `public`

```gdscript
var activation_commit_callbacks: Array[Callable] = []
```

激活提交回调。检查和目标解析通过后、执行技能逻辑前调用。

Schemas:

- `activation_commit_callbacks`: Array[Callable]，用于项目自定义成本提交、资源预留或日志写入。

### Methods

#### `update`

- API: `public`

```gdscript
func update(p_delta: float) -> void:
```

更新冷却时间。

Parameters:

| Name | Description |
|---|---|
| `p_delta` | 本次更新经过的时间。 |

#### `can_execute`

- API: `public`

```gdscript
func can_execute() -> bool:
```

检查技能当前是否允许施放。

Returns: 可施放时返回 `true`。

#### `build_activation_context`

- API: `public`

```gdscript
func build_activation_context( manual_target: Object = null, cast_center: Variant = null, activation_metadata: Dictionary = {} ) -> RefCounted:
```

创建技能激活上下文。

Parameters:

| Name | Description |
|---|---|
| `manual_target` | 可选的手动目标。 |
| `cast_center` | 可选施法中心；传入 `null` 时回退到施法者位置。 |
| `activation_metadata` | 项目自定义激活元数据。 |

Returns: 技能激活上下文。

Schemas:

- `cast_center`: Variant，可为 null 或 Vector2；为 null 时从 owner.global_position 推导。
- `activation_metadata`: Dictionary，复制到上下文中供项目检查、提交或诊断使用。

#### `get_activation_report`

- API: `public`

```gdscript
func get_activation_report(context: RefCounted = null) -> Dictionary:
```

获取技能激活报告。

Parameters:

| Name | Description |
|---|---|
| `context` | 可选激活上下文；为空时创建默认上下文。 |

Returns: 激活报告。

Schemas:

- `return`: Dictionary，包含 ok、reason、skill_id、target_count 和 metadata。

#### `execute`

- API: `public`

```gdscript
func execute( manual_target: Object = null, cast_center: Variant = null, activation_metadata: Dictionary = {} ) -> bool:
```

执行技能。

Parameters:

| Name | Description |
|---|---|
| `manual_target` | 可选的手动目标。 |
| `cast_center` | 可选施法中心；传入 `null` 时回退到施法者位置。 |
| `activation_metadata` | 项目自定义激活元数据。 |

Returns: 技能实际执行并进入冷却时返回 `true`。

Schemas:

- `cast_center`: Variant，可为 null 或 Vector2；为 null 时从 owner.global_position 推导。
- `activation_metadata`: Dictionary，复制到上下文中供项目检查、提交或诊断使用。

## GFSkillActivationContext

- Path: `addons/gf/extensions/combat/skills/gf_skill_activation_context.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.20.0`

GFSkillActivationContext: 技能激活上下文。 保存一次技能激活过程中的 owner、目标、位置、失败原因和项目元数据。 它只承载通用上下文，不解释成本、阵营、属性或具体玩法规则。

### Properties

#### `skill`

- API: `public`

```gdscript
var skill: GFSkill = null
```

技能实例。

#### `owner`

- API: `public`

```gdscript
var owner: Object = null
```

技能拥有者。

#### `manual_target`

- API: `public`

```gdscript
var manual_target: Object = null
```

手动传入的目标。

#### `cast_center`

- API: `public`

```gdscript
var cast_center: Variant = null
```

原始施放中心。

Schemas:

- `cast_center`: Variant，可为 null 或 Vector2。

#### `resolved_center`

- API: `public`

```gdscript
var resolved_center: Vector2 = Vector2.ZERO
```

解析后的施放中心。

#### `targets`

- API: `public`

```gdscript
var targets: Array[Object] = []
```

最终目标列表。

Schemas:

- `targets`: Array[Object]，经过项目目标规则过滤后的目标。

#### `failure_reason`

- API: `public`

```gdscript
var failure_reason: StringName = &""
```

激活报告中的失败原因。空值表示尚未失败。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，项目持有的成本、日志、调试或表现数据。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( p_skill: GFSkill, p_owner: Object, p_manual_target: Object = null, p_cast_center: Variant = null, p_resolved_center: Vector2 = Vector2.ZERO, p_metadata: Dictionary = {} ) -> RefCounted:
```

配置上下文并返回自身。

Parameters:

| Name | Description |
|---|---|
| `p_skill` | 技能实例。 |
| `p_owner` | 技能拥有者。 |
| `p_manual_target` | 手动传入目标。 |
| `p_cast_center` | 原始施放中心。 |
| `p_resolved_center` | 解析后的施放中心。 |
| `p_metadata` | 项目自定义元数据。 |

Returns: 当前上下文。

Schemas:

- `p_cast_center`: Variant，可为 null 或 Vector2。
- `p_metadata`: Dictionary，复制到上下文中供项目检查、提交或诊断使用。
- `return`: GFSkillActivationContext 当前上下文。

#### `fail`

- API: `public`

```gdscript
func fail(reason: StringName, extra_metadata: Dictionary = {}) -> void:
```

标记激活失败。

Parameters:

| Name | Description |
|---|---|
| `reason` | 失败原因。 |
| `extra_metadata` | 追加到上下文的元数据。 |

Schemas:

- `extra_metadata`: Dictionary，复制到 metadata 中供项目诊断或串联使用。

#### `is_ok`

- API: `public`

```gdscript
func is_ok() -> bool:
```

检查上下文当前是否未失败。

Returns: 未失败时返回 true。

#### `to_report`

- API: `public`

```gdscript
func to_report() -> Dictionary:
```

创建报告字典。

Returns: 报告字典。

Schemas:

- `return`: Dictionary，包含 ok、reason、skill_id、target_count 和 metadata。

## GFSkillTargetingRule

- Path: `addons/gf/extensions/combat/skills/gf_skill_targeting_rule.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFSkillTargetingRule: 技能索敌规则资源。 使用纯数据结构描述目标筛选时的空间范围、 朝向约束、排序规则与标签过滤条件。

### Enums

#### `Shape`

- API: `public`

```gdscript
enum Shape { ## 轴对齐矩形范围。 RECTANGLE, ## 圆形范围。 CIRCLE, ## 扇形范围。 SECTOR, ## 单体目标。 SINGLE, }
```

索敌形状。

#### `SortRule`

- API: `public`

```gdscript
enum SortRule { ## 距离最近优先。 DISTANCE_CLOSEST, ## 距离最远优先。 DISTANCE_FURTHEST, ## 属性值最低优先。 ATTRIBUTE_LOWEST, ## 属性值最高优先。 ATTRIBUTE_HIGHEST, ## 随机顺序。 RANDOM, }
```

排序规则。

### Properties

#### `shape`

- API: `public`

```gdscript
var shape: Shape = Shape.CIRCLE
```

索敌形状。

#### `radius`

- API: `public`

```gdscript
var radius: float = 100.0
```

圆形、扇形与单体规则使用的最大半径。

#### `rectangle_size`

- API: `public`

```gdscript
var rectangle_size: Vector2 = Vector2(200.0, 200.0)
```

矩形范围尺寸，使用轴对齐包围盒判断。

#### `max_count`

- API: `public`

```gdscript
var max_count: int = 1
```

最多选中的目标数量。

#### `forward_direction`

- API: `public`

```gdscript
var forward_direction: Vector2 = Vector2.RIGHT
```

扇形朝向；为零向量时回退到 `Vector2.RIGHT`。

#### `sector_angle_degrees`

- API: `public`

```gdscript
var sector_angle_degrees: float = 90.0
```

扇形夹角，单位为角度。

#### `sort_rule`

- API: `public`

```gdscript
var sort_rule: SortRule = SortRule.DISTANCE_CLOSEST
```

目标排序逻辑。

#### `sort_attribute_name`

- API: `public`

```gdscript
var sort_attribute_name: StringName = &"HP"
```

按属性排序时使用的属性名。

#### `require_tags`

- API: `public`

```gdscript
var require_tags: Array[StringName] = []
```

目标必须拥有的标签列表。

#### `ignore_tags`

- API: `public`

```gdscript
var ignore_tags: Array[StringName] = []
```

目标禁止拥有的标签列表。

## GFSkillTargetingUtility

- Path: `addons/gf/extensions/combat/skills/gf_skill_targeting_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSkillTargetingUtility: 技能索敌处理工具。 提供统一的目标筛选流程：先做空间过滤， 再执行标签过滤、排序与数量截断。

### Methods

#### `find_targets`

- API: `public`

```gdscript
func find_targets(p_center: Vector2, p_rule: GFSkillTargetingRule, p_available_entities: Array) -> Array[Object]:
```

执行索敌 pipeline。

Parameters:

| Name | Description |
|---|---|
| `p_center` | 索敌中心点。 |
| `p_rule` | 索敌规则资源。 |
| `p_available_entities` | 候选实体池。 |

Returns: 最终筛选出的目标数组。

Schemas:

- `p_available_entities`: Array，元素为候选实体 Object；无效实例会被跳过。

## GFTagComponent

- Path: `addons/gf/extensions/combat/tags/gf_tag_component.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFTagComponent: 标签组件。 基于 StringName 管理实体的标签及层数（如 &"State.Stun", &"Element.Fire"）。 标签系统通常用于技能释放前提检查、伤害加成判定等。

### Signals

#### `tag_changed`

- API: `public`

```gdscript
signal tag_changed(tag_name: StringName, count: int)
```

当标签层数发生变化时发出。

Parameters:

| Name | Description |
|---|---|
| `tag_name` | 标签名。 |
| `count` | 变化后的最终层数。 |

### Methods

#### `add_tag`

- API: `public`

```gdscript
func add_tag(p_tag: StringName, p_count: int = 1) -> void:
```

添加标签。

Parameters:

| Name | Description |
|---|---|
| `p_tag` | 标签名。 |
| `p_count` | 增加的层数。 |

#### `remove_tag`

- API: `public`

```gdscript
func remove_tag(p_tag: StringName, p_count: int = 1) -> void:
```

移除标签或减少层数。

Parameters:

| Name | Description |
|---|---|
| `p_tag` | 标签名。 |
| `p_count` | 减少的层数，如果为 -1 则直接完全移除。 |

#### `has_tag`

- API: `public`

```gdscript
func has_tag(p_tag: StringName, p_min_count: int = 1) -> bool:
```

检查是否拥有指定标签且层数达到要求。

Parameters:

| Name | Description |
|---|---|
| `p_tag` | 标签名。 |
| `p_min_count` | 要求的最小层数。 |

Returns: 拥有指定标签且层数不低于要求时返回 true。

#### `get_tag_count`

- API: `public`

```gdscript
func get_tag_count(p_tag: StringName) -> int:
```

获取标签的当前层数。

Parameters:

| Name | Description |
|---|---|
| `p_tag` | 标签名。 |

Returns: 当前标签层数；不存在时返回 0。

#### `get_tags`

- API: `public`

```gdscript
func get_tags() -> PackedStringArray:
```

获取当前持有的标签名。

Returns: 排序后的标签名。

#### `get_tag_snapshot`

- API: `public`

```gdscript
func get_tag_snapshot() -> Dictionary:
```

获取标签层数快照。

Returns: 标签层数字典副本。

Schemas:

- `return`: Dictionary，键为标签名，值为当前层数。

#### `clear_all`

- API: `public`

```gdscript
func clear_all() -> void:
```

清空所有标签。

