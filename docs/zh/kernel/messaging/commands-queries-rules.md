# 命令、查询与规则

本页拆出 `GFCommand`、`GFQuery`、`GFRule`、命令/查询工厂和跨模块读写动作的表达方式。
## 命令与查询

如果把所有读写流程都直接堆到同一个 `GFSystem` 中，核心系统会很快变得难以拆分和测试。例如 `BattleSystem` 同时负责开始战斗、技能结算、伤害衰减和撤退流程时，职责边界就会变得模糊。

使用 `GFCommand` (写操作) 与 `GFQuery` (读操作) 可以通过典型的 **Command Pattern (命令模式)** 将跨模块读写封装成明确对象，让 `System` 保持稳定的职责边界。


## GFCommand: 封装最小写操作单元

`GFCommand` 代表了一次可执行的指令。它的意图是**改变 Model 的数据状态或触发一系列副作用任务。**

Command 应被设计成业务上的最小写操作单元。框架负责依赖注入和调用 `execute()`，但不提供数据库式事务、自动回滚、幂等保护或失败隔离；如果流程需要失败策略、顺序等待或可选回滚，应使用 `GFCommandSequence`、Flow 或项目层 System 编排。

### 创建命令
继承并重写 `execute()` 抽象方法：

```gdscript
class_name TakeDamageCommand extends GFCommand

# 这通常可以视为命令实例携带的参数上下文
var target_id: String
var raw_damage: int

func execute() -> Variant:
	# 框架基类中提供了方便的 getter 可以取用全局组件
	var battle_model := get_model(BattleModel) as BattleModel

	# 从状态中找到受击人并结算伤害
	var ent := battle_model.get_entity(target_id)
	if ent:
		var final_dmg = raw_damage - ent.defense
		ent.health -= max(1, final_dmg)
	return null
```

### 执行命令
只要获得了命令定义，在控制器或系统内部都可以通过架构发送：

```gdscript
# 在 UI层按下攻击键后
var c = TakeDamageCommand.new()
c.target_id = "monster_99"
c.raw_damage = 999
Gf.send_command(c)
```

`Gf.send_command()` 会先向命令注入当前 `GFArchitecture`，再调用 `execute()`。只有当命令完全不依赖 `get_model()`、`get_system()`、`get_utility()` 这类框架访问时，才建议直接调用 `c.execute()`。在存在 `GFNodeContext` 局部上下文的项目里，依赖框架对象的 Command 不应直接 `new().execute()`；未注入的命令会回退到全局架构，可能拿错局部场景的数据。


## GFQuery: 封装跨模块读取提取数据的“获取”动作

当某个读取结果需要组合多个底层模型时，例如属性面板同时读取 `PlayerModel`、`BuffModel` 和 `EquipmentModel`，可以把这类派生读取封装成 `GFQuery`。

### 创建查询

Query 代表读操作。它的返回值应当是安全的，**绝不应该在 `execute()` 内部出现状态和数据的修改变动**。框架不会强制只读隔离；是否修改 Model、发送事件或调用 System，仍由项目代码规范保证。

```gdscript
class_name GetPlayerTotalAttackPowerQuery extends GFQuery

func execute() -> Variant:
	# 从三处采集数据
	var raw_atk = (get_model(PlayerModel) as PlayerModel).base_atk
	var wpn_atk = (get_model(EquipmentModel) as EquipmentModel).get_equipped_weapon_atk()
	var buff_atk_pct = (get_model(BuffModel) as BuffModel).get_global_atk_buff()

	return (raw_atk + wpn_atk) * (1.0 + buff_atk_pct)
```

### 执行查询

通常控制器表现层（Controller）会发出查询获取数据再做展示：

```gdscript
func update_attack_power_ui() -> void:
	var final_atk = Gf.send_query(GetPlayerTotalAttackPowerQuery.new()) as float
	$UI/AttackLabel.text = str(final_atk)
```

简单数值可以直接返回；复杂查询建议返回专门的结果对象或 `GFPayload` 子类，避免调用方长期依赖裸 `Dictionary` 或不明确的 `Variant` 结构。

`send_query()` 可以出现在 `tick()`、状态机 `update()` 或 UI 刷新路径里，但它不是“必须经过”的读取方式。Query 适合封装跨多个 Model/System 的派生读取、权限检查或表现层不应该知道的组合逻辑；如果每帧只读同一个 Model 上的简单字段，建议在 `ready()`、`enter()` 或状态初始化时缓存对应 Model/Utility 引用，再直接读取字段或调用轻量方法。不要在热路径里反复 `new()` 查询对象；可复用的无状态 Query 可以预先创建，或直接把读取逻辑下沉到 Model/System 的稳定接口中。

在 `GFController`、`GFCommand`、`GFState` 这类已经拥有架构上下文的对象里，优先使用自身的 `send_query()` / `send_command()` 代理，而不是全局 `Gf.send_query()` / `Gf.send_command()`。这样在 `GFNodeContext` 局部架构下，查询会命中当前上下文的模块；全局 `Gf` 只适合明确访问全局架构的代码。


## GFRule: 资源化规则对象

`GFRule` 是继承自 `Resource` 的规则抽象基类，用于把“可配置策略”从 `System` 中拆出来。它适合技能筛选、结算策略、AI 条件、关卡评分、掉落规则这类需要在编辑器中配置、在运行时由系统执行的逻辑片段。

```gdscript
class_name DamageReductionRule
extends GFRule

@export var min_damage: int = 1

func execute(context: Object = null) -> Variant:
	var payload := context as DamagePayload
	if payload == null:
		return min_damage
	return maxi(payload.raw_damage - payload.defense, min_damage)

func validate() -> bool:
	return min_damage >= 0
```

`execute(context)` 的上下文当前是 `Object`，通常是 `GFPayload` 子类，也可以是项目自己的 `Resource`、`RefCounted` 或 `Node` 对象；如果规则需要 `Dictionary`、`Array` 这类纯数据上下文，建议包装成明确的上下文对象再传入。返回值保持 `Variant`，异步规则也可以返回 `Signal` 供调用方等待。

`GFRule` 只提供资源化策略边界，不负责规则调度、优先级、失败策略或业务含义；这些应由调用它的 `System` 或流程节点决定。`validate()` 不会自动执行，项目应在加载配置、进入战斗或执行规则前主动调用并处理失败。`GFRule` 也不参与 `GFArchitecture` 依赖注入；如果规则需要架构中的 Model/System/Utility，优先由调用方把必要数据或服务放入 context，而不是让 Resource 自己查全局。

由于 `GFRule` 是 `Resource`，同一个 `.tres` 可能被多个对象共享。规则应尽量保持无状态；运行时缓存、计数器或临时结果应放在 context、System 或 Command 中。如果必须修改规则实例本身，调用方应先 `duplicate(true)`，避免共享资源污染。


## 通过工厂创建带注入的命令与查询

如果命令或查询内部会调用 `get_model()`、`get_system()`、`get_utility()`，推荐通过架构工厂创建实例，而不是直接 `new()`。这样对象会自动接收当前 `GFArchitecture` 注入，在 `GFNodeContext` 局部上下文中也能优先访问本地模块。局部上下文中的 Command / Query 应通过当前 architecture 的 `create_instance()`、`send_command()`、`send_query()` 或显式 `inject_dependencies()` 进入执行流程。

```gdscript
func install_bindings(binder: Variant) -> void:
	binder.bind_factory(TakeDamageCommand).as_transient()
	binder.bind_factory(GetPlayerTotalAttackPowerQuery).as_transient()
```

```gdscript
var command := Gf.create_instance(TakeDamageCommand) as TakeDamageCommand
command.target_id = "monster_99"
command.raw_damage = 999
Gf.send_command(command)

var query := Gf.create_instance(GetPlayerTotalAttackPowerQuery) as GetPlayerTotalAttackPowerQuery
var final_atk := Gf.send_query(query) as float
```

工厂默认生命周期是 `GFBindingLifetimes.Lifetime.TRANSIENT`，每次解析都会调用 provider，通常用于创建新的 Command / Query，适合携带本次执行参数的对象。框架不会强制校验 provider 返回的一定是新对象；如果需要复用昂贵的无状态执行器，可以用 `register_factory(..., GFBindingLifetimes.Lifetime.SINGLETON)` 或 `register_factory_instance()`，但不要把带有本次执行参数的命令注册成 singleton。

当局部架构回退到父级 transient 工厂时，新对象会注入发起解析的局部架构；singleton 工厂则始终注入拥有该绑定的架构。这使全局工厂定义可以服务局部场景，同时保留单例对象的稳定归属。

