# Combat 战斗通用能力

本页聚焦 Combat 包中的属性、标签、Buff、技能、目标选择、战斗事件和场景命中桥接。
## 核心组件

### 1. 可修饰属性系统 (Modified Attribute)
`GFModifiedAttribute` 管理实体的可修饰核心数值。它支持多重修饰器叠加，并自动执行标准战斗公式：
**公式：**(基础值 + 基础加值) * (1.0 + 百分比加值) + 最终加值

- **响应式更新**：对外暴露为 `GFBindableProperty`，UI 可直接绑定。
- **修饰器 (Modifier)**：支持 `BASE_ADD`, `PERCENT_ADD`, `FINAL_ADD` 三种计算方式，并区分目标属性 `attribute_id` 与来源标识 `source_id`。
- **强制重算**：通过 `force_recalculate()` 手动触发数值更新（适用于 Modifier 数值动态变动的场景）。

如果项目只需要一组可保存、可派生的通用数值记录，应使用领域层的 `GFAttributeSet`；`GFModifiedAttribute` 更适合需要实时挂载 `GFModifier`、响应 Buff 或驱动 UI 绑定的单个运行时数值。

### 2. 标签系统 (Tag)
`GFTagComponent` 记录实体的状态标签及其层数。
- **用途**：用于技能释放前提判断（如：必须要处于 `&"State.Normal"` 且不包含 `&"State.Stun"`）。
- **层数堆叠**：支持标签层数的增减与查询。
- **快照枚举**：`get_tags()` 返回当前标签名，`get_tag_snapshot()` 返回层数字典副本，便于接入通用 `GFTagQuery`、调试面板或项目自己的过滤工具。

### 3. Buff 系统 (Buff)
`GFBuff` 是状态效果的基类，负责管理生命周期和效果应用。
- **生命周期**：支持 `duration` (持续时间) 和 `on_tick(delta)` (周期驱动逻辑)。
- **效果携带**：Buff 可以携带多个 `GFModifier` 和 `Tags`，在应用时自动挂载至宿主。
- **刷新语义**：同 ID Buff 默认刷新已有实例的持续时间并按 `max_stacks` 增加层数，不替换新 Buff 的 tags、modifiers 或 max_stacks；需要替换强度时应自定义 Buff 或扩展战斗系统。
- **可配置策略**：`stack_mode` 可选择只刷新、叠层或忽略重复添加；`duration_refresh_policy` 可选择保持、重置、追加或保留更长剩余时间。
- **周期 Tick**：`tick_interval_seconds <= 0` 时保持每帧调用 `on_tick(delta)`；大于 0 时按固定间隔触发，适合低频结算。
- **Tick 边界**：`on_tick(delta)` 只在 Buff 存活帧调用，过期帧不会额外补一次 tick。
- **过期保留**：`remove_on_expire = false` 时，持续时间耗尽后不会要求 `GFCombatSystem` 移除该 Buff，项目可自行决定何时清理或复用。

### 4. 技能系统 (Skill)
`GFSkill` 提供技能的基础框架。
- **CD 管理**：内置冷却计时逻辑。
- **条件检查**：支持 `require_tags` (必须包含) 和 `ignore_tags` (禁止包含) 逻辑检查。
- **自动化索敌**：支持集成 `GFSkillTargetingRule` 实现管线化自动索敌。

### 5. 技能目标选择系统 (Targeting Pipeline)
这是一个高度通用、基于管线（Pipeline）设计的索敌方案，通过 `GFSkillTargetingUtility` 处理。

> [!NOTE]
> 该工具遵循框架的 IoC 原则，内置在 `GFSkill` 中使用。若需手动调用，应通过 `Gf.get_utility(GFSkillTargetingUtility)` 获取。

- **管线流程**：
    1. **空间收集 (Spatial Query)**: 基于形状（如圆形 CIRCLE）和半径筛选。
    2. **标签过滤 (Tag Filter)**: 检查 `GFTagComponent`，支持必须拥有（Require）和禁止拥有（Ignore）标签。
    3. **动态排序 (Sort)**: 支持基于距离或动态属性名（Attribute）进行最高/最低排序。
    4. **数量截取 (Slice)**: 严格限制返回的目标数量。
- **资源化定义**：通过创建 `GFSkillTargetingRule` 资源文件，可以在不修改代码的情况下调整索敌逻辑。

### 6. 战斗事件 (Combat Events)
`GFCombatSystem` 在处理 Buff 时会通过 `GFArchitecture` 发送强类型事件，便于业务层通过订阅载体（Payload）实现引爆、致死拦截等逻辑。

- **`GFBuffAppliedPayload`**: 当新 Buff 被成功应用时。
- **`GFBuffRefreshedPayload`**: 当 Buff 持续时间被刷新时。
- **`GFBuffRemovedPayload`**: 当 Buff 耗尽或被强制移除时。

### 7. 场景命中桥接 (Hit / Hurt Boxes)
`GFHitBox2D` / `GFHitBox3D` 和 `GFHurtBox2D` / `GFHurtBox3D` 是可选的场景树桥接节点。它们只负责把 2D/3D 区域、射线或项目自己的检测结果转换为 `GFCombatHitContext` 并交给具备 `receive_hit()` 的接收器，不直接应用伤害、不修改生命值、不判断阵营，也不创建特效。

`GFCombatHitContext` 包含 `source`、`target`、`hit_id`、`payload`、`magnitude`、`tags`、2D/3D 位置和 `metadata`。这些字段都保持通用；项目可以把它们解释为伤害、治疗、打断、交互、碰撞反馈或任何自定义命中语义。

`GFHitScan2D` / `GFHitScan3D` 是同一套命中协议的射线桥接节点。它们继承 Godot 的 `RayCast2D` / `RayCast3D`，扫描到对象后构建 `GFCombatHitContext` 并调用目标的 `receive_hit(context)`；没有碰撞、目标为空或目标不支持接收时会返回统一失败报告。框架仍然不定义穿透、射程衰减、命中特效、伤害或阵营规则，这些都应在项目自己的接收器、状态机或技能系统里表达。

### 8. 通用动作与数值槽

当项目需要把“某个效果改变一个数值”抽象成可配置数据时，可以使用 `GFCombatAction`、`GFCombatActionModifier`、`GFCombatActionResult` 和 `GFCombatGauge`。

- `GFCombatAction` 保存动作类别、操作类型、数值、标签、payload 和元数据。
- `GFCombatActionModifier` 按动作类别和标签过滤后调整动作数值、操作或类别。
- `GFCombatGauge` 是可选节点组件，维护一个带上下限的通用数值，并通过动作应用、校验回调和信号输出结果。
- `GFCombatActionResult` 记录原始动作、最终动作、应用前后数值、原因和元数据，方便日志、表现或事件系统消费。

这套 API 不把 `damage`、`heal`、`hp`、`shield` 写成框架规则。项目可以把 `action_kind = &"damage"` 配成减少值，也可以把同一套机制用于耐久、能量、姿态条、资源槽或自定义交互计量。

```gdscript
var gauge := GFCombatGauge.new()
gauge.configure(0.0, 100.0, 100.0)
gauge.accepted_action_kinds = [&"impact"]

var guard := GFCombatActionModifier.new()
guard.accepted_action_kinds = [&"impact"]
guard.amount_multiplier = 0.5
gauge.add_modifier(guard)

var action := GFCombatAction.new()
action.action_kind = &"impact"
action.operation = GFCombatAction.Operation.SUBTRACT
action.amount = 40.0

var result := gauge.apply_action(action)
print(result.ok, gauge.current_value) # true, 80.0
```

```gdscript
var hit_box := GFHitBox2D.new()
hit_box.hit_id = &"impact"
hit_box.payload = {
	"amount": 10,
}

var hurt_box := GFHurtBox2D.new()
hurt_box.accepted_hit_ids = [&"impact"]
hurt_box.hit_received.connect(func(context: GFCombatHitContext, _report: Dictionary) -> void:
	# 项目层自行决定如何解释 context.payload。
	print(context.hit_id, context.payload)
)

var report := hit_box.send_to(hurt_box)
print(report["ok"])
```

#### 2D 接入示例
```gdscript
@onready var hit_box: GFHitBox2D = $HitBox

func _ready() -> void:
	hit_box.area_entered.connect(_on_hit_box_area_entered)


func _on_hit_box_area_entered(area: Area2D) -> void:
	var hurt_box := area as GFHurtBox2D
	if hurt_box == null:
		return

	hit_box.send_to(hurt_box, {
		"damage": 10,
	})
```

`area_entered` 传入的是 Godot 的 `Area2D`；`send_to()` 的目标必须是 `GFHurtBox2D`，或自行实现了 `receive_hit(context)` 的对象。

被击中方监听 `hit_received`，读取 `context.payload` 后自行处理扣血、击退或特效；框架不会解释 `"damage"` 字段。若 HurtBox 配了 `accepted_hit_ids`，记得给 HitBox 设置对应的 `hit_id`。

3D 版本用法相同：`GFHitBox3D` 发送给 `GFHurtBox3D`，传入目标仍需要能处理 `receive_hit(context)`。

`GFHitBox2D` / `GFHitBox3D` 和 `GFHurtBox2D` / `GFHurtBox3D` 的 `enabled` 变化时会发出 `enabled_changed(enabled)`。它只报告框架命中收发开关，项目可以用它同步调试可见性、调试面板或外部状态；如果需要统一管理一组区域的 `enabled`、`monitoring` / `monitorable` 和 `visible`，优先使用下面的状态组。

如果不同攻击想复用同一个 HitBox / HurtBox 节点，只切换碰撞形状，可以使用 `GFHitCollisionShapeConfig2D` 或 `GFHitCollisionShapeConfig3D`。配置只描述 Godot 原生 `Shape2D` / `Shape3D`、偏移、旋转、缩放和 disabled 状态，不表达伤害、阵营或特效规则；这些仍由 `hit_id`、`payload`、状态机或项目逻辑决定：

```gdscript
var slash_shape := GFHitCollisionShapeConfig2D.new()
slash_shape.shape = RectangleShape2D.new()
slash_shape.position = Vector2(24.0, 0.0)
slash_shape.scale = Vector2(1.5, 0.5)

hit_box.apply_collision_shape_config(slash_shape)
hit_box.hit_id = &"slash"
hit_box.payload = { "damage": 12 }
```

`collision_shape_config` 会在节点进入场景树时自动应用；运行时也可以调用 `apply_collision_shape_config()` 切换配置。它们只会创建或更新一个框架管理的 `CollisionShape2D` / `CollisionShape3D` 子节点，不会修改项目手写的其他碰撞节点。配置置空、配置缺少 `shape` 或调用 `clear_generated_collision_shape()` 时，会清理这类自动生成节点。

HitBox 的 `broadcast_overlaps()` 会从当前重叠的 Area/Body 中向上查找具备 `receive_hit()` 的节点，并去重发送。HurtBox 支持 `accepted_hit_ids`、`rejected_hit_ids` 和 `validation_callback`，适合项目层接入护盾、无敌帧、阵营过滤或编辑器调试；这些规则都在回调里表达，不写进框架默认逻辑。

需要随状态统一开关一组命中区域时，可以把 `GFHitBoxState2D` 或 `GFHitBoxState3D` 放在区域节点上层。它会递归管理子树内的 `GFHitBox*`、`GFHurtBox*` 和 `Area*`，可选择同步 `enabled`、`monitoring` / `monitorable` 和可见性：

```gdscript
@onready var attack_state: GFHitBoxState2D = $AttackHitBoxes

func _on_attack_started() -> void:
	attack_state.activate()


func _on_attack_finished() -> void:
	attack_state.deactivate()
```

状态组只表达“这一组区域当前是否参与收发命中”，不决定伤害窗口、动画帧、阵营或技能逻辑。项目应在自己的状态机、动画事件或技能系统中决定何时调用 `activate()` / `deactivate()`。

和节点状态机配合时，推荐在具体 `GFNodeState` 的 `_enter()` / `_exit()` 中控制攻击窗口，这样命中盒开关和角色状态生命周期保持一致：

```gdscript
class_name AttackState
extends GFNodeState

@onready var attack_state: GFHitBoxState2D = $AttackHitBoxes


func _enter(_previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	attack_state.activate()


func _exit(_next_state: StringName = &"", _args: Dictionary = {}) -> void:
	attack_state.deactivate()
```

#### 监听范例：
```gdscript
# 监听 Buff 应用事件
Gf.listen(GFCombatPayloads.GFBuffAppliedPayload, func(payload: GFCombatPayloads.GFBuffAppliedPayload):
	var buff := payload.buff as GFBuff
	print("实体 ", payload.target, " 获得了 Buff: ", buff.id)
)
```


## 使用范例

### 定义一个通过 Tick 恢复生命值的 Buff
```gdscript
class_name RegenBuff
extends GFBuff

func on_tick(p_delta: float) -> void:
	# 假设宿主有方法获取 HP 属性
	var hp := owner.get_attribute(&"HP") as GFModifiedAttribute
	hp.set_base_value(hp.get_base_value() + 5.0 * p_delta)
	hp.force_recalculate()
```

### 定义一个具有自动索敌逻辑的技能
```gdscript
class_name FireBallSkill
extends GFSkill

func _init(p_owner: Object) -> void:
	super._init(p_owner)
	id = &"FireBall"
	cooldown_max = 2.0

	# 配置自动化索敌规则
	targeting_rule = GFSkillTargetingRule.new()
	targeting_rule.shape = GFSkillTargetingRule.Shape.CIRCLE
	targeting_rule.radius = 300.0
	targeting_rule.max_count = 3
	targeting_rule.sort_rule = GFSkillTargetingRule.SortRule.ATTRIBUTE_LOWEST
	targeting_rule.sort_attribute_name = &"HP" # 优先打血量最低的目标

func _on_execute(p_targets: Array[Object]) -> void:
	for target in p_targets:
		print("Fireball hits: ", target)
```

### 给属性挂载 Buff
```gdscript
var strength_buff := GFBuff.new()
strength_buff.setup(&"StrBoost", 5.0, entity)
strength_buff.modifiers.append(GFModifier.create_percent_add(0.2, &"STR", &"StrBoost")) # 力量提升 20%，来源为 StrBoost
combat_system.add_buff(entity, strength_buff)
```

`attribute_id` 表示这个修饰器要挂到哪一个属性上；`source_id` 表示它来自哪个装备、Buff 或技能，便于按来源批量移除。2.0 起 Buff 不再把 `source_id` 当作目标属性回退，也不再提供旧字段名 `source_tag`；迁移旧代码时应把目标属性写入 `attribute_id`，把来源写入 `source_id`。

运行时可通过 `get_buff(entity, buff_id)` 取得正在系统中生效的 Buff 实例，通过 `has_buff(entity, buff_id)` 判断是否存在，通过 `get_buffs(entity)` 取得 Buff 列表副本。列表副本可安全排序、过滤或清空，不会修改系统内部数组；但数组里的 `GFBuff` 仍是运行中的对象引用，适合调整剩余时间、层数或周期参数：

```gdscript
var buff := combat_system.get_buff(entity, &"StrBoost")
if buff != null:
	buff.time_left = 8.0
	buff.stacks = mini(buff.stacks + 1, buff.max_stacks)
```

如果只修改已挂载 `GFModifier` 的 `value`，需要让目标属性重新计算。可以调用 `refresh_buff_modifiers(entity, buff_id)`，它会刷新该 Buff 当前修饰器影响到的属性：

```gdscript
var buff := combat_system.get_buff(entity, &"StrBoost")
if buff != null and not buff.modifiers.is_empty():
	buff.modifiers[0].value = 0.35
	combat_system.refresh_buff_modifiers(entity, &"StrBoost")
```

如果要增删 `modifiers` 或 `tags` 列表本身，应优先 `remove_buff()` 后重新构造并 `add_buff()`，因为标签和修饰器的挂载/卸载由 Buff 生命周期负责。运行时可通过 `remove_buff(entity, buff_id)` 驱散单个 Buff，通过 `clear_buffs(entity, predicate)` 清理全部或部分 Buff，通过 `remove_skill(entity, skill)` 取消某个技能的系统驱动与冷却信号监听。手动目标施放会先经过 `targeting_rule` 校验；即使 `max_count <= 0` 表示不截断目标，未通过校验的手动目标也不会让技能以空目标执行。若技能 owner 没有 `global_position` 且调用时未传入 `cast_center`，索敌中心会回退到 `Vector2.ZERO`，项目应为非空间对象显式传入施法中心。


## 系统驱动
`GFCombatSystem` 继承自 `GFSystem`，只需将其注册到架构中，它就会在每一帧自动更新所有已注册实体的 Buff 和技能状态。

```gdscript
# 在架构初始化时
func install(architecture: GFArchitecture) -> void:
	var combat_sys := GFCombatSystem.new()
	await architecture.register_system_instance(combat_sys)
```
