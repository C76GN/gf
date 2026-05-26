# Steering 算法

`GFSteeringAgent`、`GFSteeringAcceleration` 和 `GFSteeringMath` 提供纯 steering 计算原语。`GFSteeringAgent` 只保存位置、速度、朝向、半径和运动上限；`GFSteeringAcceleration` 保存线性/角加速度；`GFSteeringMath` 提供 `seek()`、`flee()`、`arrive()`、`pursue()`、`evade()`、`face()`、`look_where_you_go()`、`separation()`、`cohesion()`、`avoid_collisions()`、`blend()`、`priority()` 和 `path_follow_target()` 等静态计算。

```gdscript
var agent := GFSteeringAgent.new(Vector3(player.global_position.x, player.global_position.y, 0.0))
agent.velocity = Vector3(velocity.x, velocity.y, 0.0)
agent.linear_speed_max = 220.0
agent.linear_acceleration_max = 900.0

var arrive := GFSteeringMath.arrive(agent, Vector3(target.x, target.y, 0.0), 4.0, 96.0)
velocity += Vector2(arrive.linear.x, arrive.linear.y) * delta
```

需要对动态单位做轻量避让时，可以把附近候选代理交给 `avoid_collisions()`。它只基于位置、速度、半径和预测窗口计算未来最近距离，不执行物理查询，也不决定哪些目标算敌人、队友或障碍。

```gdscript
var avoidance := GFSteeringMath.avoid_collisions(agent, nearby_agents, 0.8)
var steering := GFSteeringMath.priority([
	avoidance,
	arrive,
] as Array[GFSteeringAcceleration])
```

Steering 层不直接移动 `CharacterBody2D/3D`，也不规定避障、阵营、路径点来源或群体 AI 策略。项目可以把多个加速度用 `blend()` 加权，也可以用 `priority()` 选择第一个非零行为，再自行做速度积分、碰撞和网络同步。
