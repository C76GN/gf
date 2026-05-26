# 调试绘制命令缓冲

`GFDebugDrawUtility` 用于在开发期收集 2D/3D 调试绘制命令，例如路径、范围、碰撞盒、文本标注。它只维护命令、频道和生命周期，不规定具体 Overlay 或渲染节点。

```gdscript
var debug_draw := Gf.get_utility(GFDebugDrawUtility) as GFDebugDrawUtility
debug_draw.draw_line_2d(Vector2.ZERO, Vector2(64, 0), Color.RED, 0.2, &"path")
debug_draw.draw_box_3d(AABB(Vector3.ZERO, Vector3.ONE), Color.GREEN, 1.0, &"physics")

for item in debug_draw.get_items(&"path"):
	print(item)
```

项目可以按频道开关命令，再用自己的 `CanvasItem`、`Node3D` 或编辑器面板消费 `get_items()` 返回的数据。

`enabled = false` 会让默认读取返回空数组，但不删除已有命令；`get_items(channel, true)` 可用于调试面板查看被禁用频道的数据。

生命周期规则：单条命令传入负数时使用 `default_lifetime_seconds`，默认值为 `0.0`，表示等待下一次 `tick()` 后清理；`default_lifetime_seconds < 0` 表示永久保留。`max_items` 可限制缓冲区规模，超过后会丢弃最旧命令。
