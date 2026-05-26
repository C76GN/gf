# GFCommand 写操作

`GFCommand` 代表一次可执行的指令。它的意图是改变 Model 的数据状态或触发一系列副作用任务。

Command 应被设计成业务上的最小写操作单元。框架负责依赖注入和调用 `execute()`，但不提供数据库式事务、自动回滚、幂等保护或失败隔离；如果流程需要失败策略、顺序等待或可选回滚，应使用 `GFCommandSequence`、Flow 或项目层 System 编排。

## 创建命令

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

## 执行命令

只要获得了命令定义，在控制器或系统内部都可以通过架构发送：

```gdscript
# 在 UI 层按下攻击键后
var c = TakeDamageCommand.new()
c.target_id = "monster_99"
c.raw_damage = 999
Gf.send_command(c)
```

`Gf.send_command()` 会先向命令注入当前 `GFArchitecture`，再调用 `execute()`。只有当命令完全不依赖 `get_model()`、`get_system()`、`get_utility()` 这类框架访问时，才建议直接调用 `c.execute()`。

在存在 `GFNodeContext` 局部上下文的项目里，依赖框架对象的 Command 不应直接 `new().execute()`；未注入的命令会回退到全局架构，可能拿错局部场景的数据。
