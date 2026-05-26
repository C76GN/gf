# 碰撞形状配置

如果不同攻击想复用同一个 HitBox / HurtBox 节点，只切换碰撞形状，可以使用 `GFHitCollisionShapeConfig2D` 或 `GFHitCollisionShapeConfig3D`。

配置只描述 Godot 原生 `Shape2D` / `Shape3D`、偏移、旋转、缩放、调试颜色和 disabled 状态，不表达伤害、阵营或特效规则；这些仍由 `hit_id`、`payload`、状态机或项目逻辑决定。

## 单形状

```gdscript
var slash_shape := GFHitCollisionShapeConfig2D.new()
slash_shape.shape = RectangleShape2D.new()
slash_shape.position = Vector2(24.0, 0.0)
slash_shape.scale = Vector2(1.5, 0.5)
slash_shape.debug_color = Color(1.0, 0.2, 0.1, 0.8)

hit_box.apply_collision_shape_config(slash_shape)
hit_box.hit_id = &"slash"
hit_box.payload = { "damage": 12 }
```

`collision_shape_config` 会在节点进入场景树时自动应用；运行时也可以调用 `apply_collision_shape_config()` 切换配置。它们只会创建或更新一个框架管理的 `CollisionShape2D` / `CollisionShape3D` 子节点，不会修改项目手写的其他碰撞节点。

配置置空、配置缺少 `shape` 或调用 `clear_generated_collision_shape()` 时，会清理这类自动生成节点。

## 多形状

如果一个攻击窗口需要多个形状，可以使用 `collision_shape_configs` 或 `apply_collision_shape_configs()`。配置列表会创建多个框架管理的 CollisionShape 子节点，列表缩短时多余的自动节点会被清理；项目手写的碰撞节点仍不会被修改：

```gdscript
var close_range := GFHitCollisionShapeConfig2D.new()
close_range.shape = CircleShape2D.new()

var wide_arc := GFHitCollisionShapeConfig2D.new()
wide_arc.shape = RectangleShape2D.new()
wide_arc.position = Vector2(32.0, 0.0)

var shape_configs: Array[GFHitCollisionShapeConfig2D] = [close_range, wide_arc]
hit_box.apply_collision_shape_configs(shape_configs)
```
