# Capability 能力组合

本页聚焦 Capability 扩展的能力组件、节点能力、容器、Recipe、分组、启停和诊断。
## 适用场景

- 实体能力：`HealthCapability`、`InteractableCapability`、`SelectableCapability`。
- 战斗对象接口：标签、属性集合、目标候选来源等。
- 场景行为节点：命中盒、感知范围、浮字发射器、可交互提示节点。
- 临时能力：无敌、可拖拽、可选中、可被锁定等运行时开关。

如果能力需要参与全局生命周期、Tick 或跨模块调度，应继续使用 `GFSystem` / `GFUtility`；如果能力只是某个对象的局部组合行为，才使用 Capability。


## 注册 Utility

```gdscript
func install_bindings(binder: Variant) -> void:
	binder.bind_utility(GFCapabilityUtility).as_singleton()
```


## 纯代码能力

能力可以继承 `GFCapability`，获得 receiver、架构注入和依赖查询辅助方法：

```gdscript
class_name HealthCapability
extends GFCapability

var max_health: int = 100
var health: int = 100
```

挂载和查询：

```gdscript
var capabilities := Gf.get_utility(GFCapabilityUtility) as GFCapabilityUtility
var health := capabilities.add_capability(enemy, HealthCapability) as HealthCapability

if capabilities.has_capability(enemy, HealthCapability):
	health = capabilities.get_capability(enemy, HealthCapability) as HealthCapability
```


## 显式能力依赖

能力可以声明依赖，`GFCapabilityUtility` 会在挂载当前能力前先补齐依赖能力：

```gdscript
class_name DamageableCapability
extends GFCapability

func _init() -> void:
	required_capabilities = [HealthCapability]

func take_damage(amount: int) -> void:
	var health := get_capability(HealthCapability) as HealthCapability
	health.health = maxi(health.health - amount, 0)
```

GF 不使用隐式构造函数参数注入，依赖关系应优先通过 `required_capabilities` 显式声明，便于编辑器检查、搜索、测试和排错。节点能力放在场景中时，可以直接在 Inspector 的 `required_capabilities` 数组里配置依赖；纯代码能力如果需要类级默认依赖，可以在 `_init()` 中设置该数组。

`GFCapabilityUtility` 会在调用 `on_gf_capability_added()` 前写入能力实例的 `receiver` 字段，并在 `on_gf_capability_removed()` 后清空它；因此 Hook 内可以直接使用 `receiver` 或 `get_capability()` 查询同一 receiver 上已补齐的依赖能力。重写 Hook 时仍建议调用 `super`，便于兼容基类后续扩展，但依赖查询不再依赖项目脚本手动调用 `super`。

从 `2.0.0` 起，移除主能力时默认会清理“仅由它自动补齐且未被用户显式添加”的依赖能力。用户显式添加的依赖、或仍被其他能力依赖的能力不会被级联移除。若某个能力希望依赖在主能力移除后继续保留，可重写：

```gdscript
func get_dependency_removal_policy() -> int:
	return GFCapabilityUtility.DependencyRemovalPolicy.KEEP_DEPENDENCIES
```


## 能力组合 Recipe

当项目希望把一组能力作为可复用配置应用到不同 receiver，可以使用 `GFCapabilityRecipe`。Recipe 只描述能力条目、默认启停和分组，不规定实体类型、属性字段或玩法规则。

```gdscript
var recipe := GFCapabilityRecipe.new()
recipe.recipe_id = &"interactable_target"
recipe.groups = [&"targets"]

var entry := GFCapabilityRecipeEntry.new()
entry.capability_type = InteractableCapability
entry.active = true
recipe.entries = [entry]

var result := capabilities.apply_recipe(enemy, recipe)
if not result["ok"]:
	push_warning(result["failed"])
```

`GFCapabilityRecipeEntry` 可以通过 `capability_type` 创建普通能力，也可以通过 `scene` 挂载节点能力场景；如果两者都提供，运行时会实例化场景并按 `capability_type` 注册。`apply_recipe()` 默认会在应用后调用依赖校验，并把新增、复用、失败条目和分组写入报告；默认 `transactional = true`，任一条目失败或依赖校验失败时，会移除本次新增能力、回滚本次新增分组，并恢复被复用能力的原 active 状态，避免留下半应用的实体预设。确实需要“尽力应用”的工具流程，可在 options 中显式传 `{ "transactional": false }`。`remove_recipe()` 可按 Recipe 反向移除能力和可选分组。复杂实体预设应保持为项目资源，不应把具体敌人、卡牌、任务或 UI 规则写进 GF 能力基类。


## Node 能力与场景容器

需要输入、动画、子节点引用或编辑器 Inspector 管理的能力可以继承节点能力基类。`GFNodeCapability` 自身继承自普通 `Node`，适合做不依赖空间变换的能力根节点和依赖入口：

```gdscript
class_name HitboxCapability
extends GFNodeCapability

@export var damage: int = 1
```

如果能力本身需要继承空间变换或 UI 布局，请按 Godot 节点分支选择更具体的基类：

```gdscript
class_name Sensor2DCapability
extends GFNode2DCapability
```

```gdscript
class_name Attachment3DCapability
extends GFNode3DCapability
```

```gdscript
class_name PanelBindingCapability
extends GFControlCapability
```

当能力实例是 `Node`，且 receiver 也是 `Node` 时，能力会自动挂入 receiver 下的 `GFCapabilityContainer`。你也可以在场景中手动添加 `GFCapabilityContainer`，并把带脚本的能力节点放在容器下：

```text
Enemy
└── GFCapabilityContainer
	└── HitboxCapability
```

如果 receiver 与能力同属 `Node2D`、`Node3D` 或 `Control` 分支，框架会创建对应类型的能力容器，避免普通 `Node` 容器打断空间变换或 UI 继承。手动摆放 2D/3D/UI 能力时也推荐使用同分支容器，或直接通过 GF Inspector 添加能力，让框架自动创建匹配容器。已摆放在 receiver 直属能力容器下的子能力会被视为项目明确布局，注册时不会因为容器分支和能力节点分支不一致而强制迁移；这允许 `GFCapabilityContainer2D` 中挂载普通 `GFNodeCapability`，也避免容器进树扫描期间触发 Godot 的 children setup 限制。

碰撞类能力仍需要遵循 Godot 节点规则：`CollisionShape2D` 应放在 `Area2D`、`CharacterBody2D`、`StaticBody2D` 等 `CollisionObject2D` 下。能力根节点可以继承 `GFNode2DCapability` 保留 2D 变换，再在能力根节点下放一个 `Area2D`，并把 `CollisionShape2D` 放到该 `Area2D` 下；或者让能力场景根节点直接继承合适的 Godot 碰撞节点并实现 GF 能力 Hook。复杂场景能力的子节点如果实现了 `inject_dependencies(architecture)` 或 `inject(architecture)`，也会在能力挂载时递归收到当前架构注入。

容器进入场景树时会立即尝试把子节点能力注册到父节点 receiver，并保留一次延迟重试，便于宿主或状态机在 `_ready()` / `_enter()` 中查询已经随场景摆放好的 `GFNodeCapability`。如果旧场景或编辑器添加流程中留下的是带 `_gf_capability_container` 元数据、或命名为 `GFCapabilityContainer2D` / `GFCapabilityContainer3D` / `GFCapabilityContainerControl` / `GFCapabilityContainer` 的空间容器，但容器脚本没有成功附着，`GFCapabilityUtility.get_capability()` 也会在查询时同步扫描这些直属容器并注册其子能力。这样 Inspector 创建出的 2D/3D/UI 容器即使不是普通 `GFCapabilityContainer`，也应在 receiver `_ready()` 中可查询。该兜底只识别 GF 容器标记或 GF 容器命名，不会扫描任意普通子节点。

如果运行时代码在 receiver 自身进入场景树的 setup 阶段动态添加 Node 能力，能力记录会立即写入，容器节点挂树会延迟到安全时机，避免 Godot 拒绝在 children setup 阶段 `add_child()`。该功能需要当前上下文或全局架构中已注册 `GFCapabilityUtility`；如果项目在容器进树后才初始化架构，可在架构就绪后调用 `register_children_now()` 主动扫描。

能力实例具有单一 owner 语义，同一个 `GFCapability` / `GFNodeCapability` 实例不能同时挂到多个 receiver；需要复用配置时应创建新实例或使用 `GFCapabilityRecipe`。场景中的 `GFCapabilityContainer` 会跟踪已注册子能力的弱引用和退出树回调；子能力被提前 `remove_child()`、reparent 或释放时，也会从原 receiver 上注销，避免容器退出时只遍历当前子节点而漏掉已经移走的能力记录。`remove_capability()` 表示移除并释放由能力系统管理的实例；场景容器离树时会使用 `unregister_capability()` 只解除登记，不释放本来由场景树拥有的子节点。框架自动创建的空能力容器会在最后一个 Node 能力被移除后释放，避免场景树残留空容器。

启用 GF 插件后，选中普通 `Node` 时 Inspector 会显示 `GF Capabilities` 区域。这里可以添加、启停、编辑和移除继承 `GFNodeCapability`、`GFNode2DCapability`、`GFNode3DCapability` 或 `GFControlCapability` 的能力脚本或能力场景；也可以从 `Recipe` 菜单把 `GFCapabilityRecipe` 中的节点能力条目应用到当前节点。通过 Inspector 添加的容器和能力是可见场景节点，便于在场景树中检查与保存。Inspector 内联区域只展示能力脚本自己的导出属性；需要编辑完整 Node 属性时可点击“编辑”进入能力节点自身 Inspector。

Inspector 的“校验”按钮会检查当前节点能力的重复脚本和 `required_capabilities` 声明缺失项，并用统一报告展示错误、警告和下一步建议。编辑器校验只读取场景结构与导出属性，不会执行非 `@tool` 的项目能力脚本方法；这避免业务逻辑在编辑器中运行。它只辅助编辑器排查节点能力组合，不会自动补齐业务能力，也不会替代运行时 `GFCapabilityUtility.inspect_receiver()`。编辑器菜单也提供 `工具 > GF > 生成 Capability`、`生成 NodeCapability`、`生成 Node2DCapability`、`生成 Node3DCapability` 与 `生成 ControlCapability` 模板入口。


## 能力启停

`GFCapability` 与节点能力基类都内置 `active` 状态。建议通过 Utility 修改启停状态：

```gdscript
var capabilities := Gf.get_utility(GFCapabilityUtility) as GFCapabilityUtility
capabilities.set_capability_active(enemy, HitboxCapability, false)
```

停用 Node 能力时，框架会临时禁用该能力节点树的 `process_mode`，重新启用时恢复原状态。若停用期间项目层主动把某个子节点的 `process_mode` 改成其他值，重新启用时会保留这次运行时修改，避免覆盖项目层控制。能力可实现 Hook 响应状态变化：

```gdscript
func on_gf_capability_active_changed(receiver: Object, active: bool) -> void:
	pass
```


## 反向索引与分组查询

能力挂载后会进入运行时索引，便于从全局角度查询“哪些对象拥有某个能力”：

```gdscript
var damageables := capabilities.get_receivers_with(DamageableCapability)
var all_health_caps := capabilities.get_capabilities(HealthCapability)
```

也可以把 receiver 加入轻量分组，并执行分组与能力交集查询：

```gdscript
capabilities.add_receiver_to_group(enemy, &"enemies")

var enemy_targets := capabilities.get_receivers_in_group_with(
	&"enemies",
	DamageableCapability
)
```

分组只负责查询索引，不改变 Godot 场景树分组，也不接管 receiver 生命周期。receiver 释放后，查询路径会自动清理失效索引；如果索引中的能力实例已经失效，`get_receivers_with()` 也会在返回前清理对应记录。`tick()` 中的周期性清理会按 `prune_invalid_receivers_per_tick` 分批推进，避免大量 receiver 同时失效时造成单帧尖峰；如果需要立刻得到精确索引，仍可主动调用 `prune_invalid_receivers()` 做全量清理。


## 能力诊断

复杂实体组合能力时，可以用 `inspect_receiver()` 获取当前 receiver 的能力、依赖、自动补齐关系和分组信息，便于调试面板、编辑器工具或测试断言使用。

```gdscript
var report := capabilities.inspect_receiver(enemy)
if not report["ok"]:
	for item in report["missing_dependencies"]:
		push_warning("%s missing %s" % [item["capability"], item["required"]])

var dependency_check := capabilities.validate_receiver_dependencies(enemy)
```

诊断报告只描述“能力是否完整”和“索引中有什么”，不替代项目自己的实体合法性规则。


## 动态属性包

`GFPropertyBagCapability` 提供轻量键值属性存取，适合原型、调试或少量临时运行时数据：

```gdscript
var bag := capabilities.add_capability(enemy, GFPropertyBagCapability) as GFPropertyBagCapability
bag.set_property_value(&"rarity", "elite")
bag.set_property_value(&"score", 100)
```

`get_int()`、`get_float()`、`get_bool()`、`get_string()`、`get_vector2()` 和 `get_color()` 只在值符合对应类型时返回属性值；缺失或类型不匹配会返回调用方传入的默认值。长期核心状态仍应放在 `GFModel` 或配置资源中，避免把属性包变成隐藏数据模型。


## Hook

能力实例可选择实现以下方法：

```gdscript
func on_gf_capability_added(receiver: Object) -> void:
	pass

func on_gf_capability_removed(receiver: Object) -> void:
	pass

func on_gf_capability_active_changed(receiver: Object, active: bool) -> void:
	pass

func get_dependency_removal_policy() -> int:
	return GFCapabilityUtility.DependencyRemovalPolicy.REMOVE_AUTO_DEPENDENCIES

func inject_dependencies(architecture: GFArchitecture) -> void:
	pass
```

依赖声明不是 Hook，优先写入 `required_capabilities`；基类的 `get_required_capabilities()` 默认会返回这个数组。只有确实需要运行时动态依赖时，才建议重写 `get_required_capabilities()`；编辑器 Inspector 不会调用该方法。

继承 `GFCapability`、`GFNodeCapability`、`GFNode2DCapability`、`GFNode3DCapability` 或 `GFControlCapability` 时这些方法已有默认实现。自定义 Node 能力不强制继承特定基类，只要实现需要的 Hook 也能被运行时识别；但需要编辑器添加与统一补全时，推荐继承最匹配的 GF 能力基类。


## 强类型访问器生成

编辑器菜单 `工具 > GF > 生成强类型访问器` 会扫描项目中的 `class_name`，为 `GFModel`、`GFSystem`、`GFUtility`、`GFCommand`、`GFQuery` 生成强类型 helper。输出路径由 `Project Settings > gf/codegen/access_output_path` 控制，默认是：

```text
res://gf/generated/gf_access.gd
```

生成后的调用示例：

```gdscript
var player := GFAccess.get_player_model() as PlayerModel
var battle := GFAccess.get_battle_system() as BattleSystem
var command := GFAccess.create_deal_damage_command()
var health := GFAccess.get_health_capability(enemy) as HealthCapability
```

生成访问器默认只使用显式传入的 `GFArchitecture`，未传入时回退到全局 `Gf` 架构；它不会沿场景树自动寻找最近的 `GFNodeContext`。在局部上下文的 Controller 或普通节点中使用时，应传入 `await wait_for_context_ready()` / `context.get_architecture()` 得到的架构：

```gdscript
var architecture := await wait_for_context_ready()
var player := GFAccess.get_player_model(architecture) as PlayerModel
var command := GFAccess.create_deal_damage_command(architecture)
```

Command / Query 创建时会优先使用当前架构中注册的工厂；如果没有工厂且脚本可实例化，则回退到 `new()` 并注入当前架构。回退路径适合无构造依赖的简单对象；如果某个 Command / Query 必须走项目自定义工厂，应在调用前用 `architecture.has_factory(Type)` 或项目层包装函数显式检查。

能力访问器会生成 `get_*_capability()`、`add_*_capability()`、`has_*_capability()`、`remove_*_capability()` 与 `if_has_*_capability()`，内部依赖已注册的 `GFCapabilityUtility`。
