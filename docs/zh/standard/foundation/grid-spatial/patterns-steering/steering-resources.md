# 资源化 Steering 组合

需要把 steering 行为暴露给资源配置时，可以用 `GFSteeringBehaviorResource` 包装单个通用行为，再用 `GFSteeringBehaviorStack` 做加权混合或优先级选择。动态目标、邻居、路径仍通过 `context` 传入，资源只保存算法参数。

```gdscript
var arrive_behavior := GFSteeringBehaviorResource.new()
arrive_behavior.behavior_type = GFSteeringBehaviorResource.BehaviorType.ARRIVE
arrive_behavior.slow_radius = 96.0

var avoid_behavior := GFSteeringBehaviorResource.new()
avoid_behavior.behavior_type = GFSteeringBehaviorResource.BehaviorType.AVOID_COLLISIONS

var stack := GFSteeringBehaviorStack.new()
stack.mode = GFSteeringBehaviorStack.CompositionMode.PRIORITY
stack.add_behavior(avoid_behavior)
stack.add_behavior(arrive_behavior)

var steering := stack.calculate(agent, {
	"target_position": Vector3(target.x, target.y, 0.0),
	"targets": nearby_agents,
})
```

资源化组合只让编辑器配置和复用更方便，不提供实体适配器。如何从 `CharacterBody2D`、`RigidBody3D`、导航路径或项目感知系统同步 `GFSteeringAgent`，以及如何把加速度积分回速度和位置，仍由项目自己的移动层负责。
