# 纯代码能力

能力可以继承 `GFCapability`，获得 receiver、架构注入和依赖查询辅助方法。

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

纯代码能力适合表达对象局部行为或数据，不应替代全局 System、长期 Model 或跨实体调度流程。
