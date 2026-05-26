# Physics 物理辅助

Physics 扩展当前提供通用 3D 重力场采样。它适合局部重力、行星引力、磁力、推斥场、风场或任何“按位置采样一个加速度向量”的 3D 项目。

它不直接修改角色控制器、RigidBody、相机或网络状态；项目代码仍负责运动积分、碰撞响应和玩法解释。

## 核心模型

- `GFGravityField3D`：提供一个可采样的加速度场，支持朝向原点、远离原点或固定方向。
- `GFGravityProbe3D`：从场景树分组采样所有暴露 `get_acceleration_at(world_position)` 的对象，并汇总当前位置的加速度、上方向和下方向。
- 默认分组是 `gf_gravity_field_3d`，`GFGravityField3D` 进树时会自动加入。

## 最小流程

```gdscript
var field := GFGravityField3D.new()
field.direction_mode = GFGravityField3D.DirectionMode.TOWARD_ORIGIN
field.acceleration = 12.0
field.radius = 20.0
add_child(field)

var probe := GFGravityProbe3D.new()
add_child(probe)

func _physics_process(delta: float) -> void:
	var acceleration := probe.sample()
	velocity += acceleration * delta
	up_direction = probe.get_up_direction()
```

## 使用边界

- Physics 只提供场采样和方向计算。
- 角色移动、碰撞响应、朝向修正、相机控制、网络同步、性能分区和具体玩法规则由项目代码负责。
- 项目可以继承 `GFGravityField3D` 重写方向计算，也可以把自定义对象加入同一分组，只要实现 `get_acceleration_at()`。
- 同一帧重复采样默认会缓存结果；如果项目在同一帧内移动 field 或需要强制重新采样，可以关闭 `cache_samples_per_frame`。

## API Reference

完整类、方法和信号列表见 [Physics API Reference](../../reference/api/extensions-physics.md)。
