# Foundation 网格、路径与空间索引

这些 Foundation 能力覆盖网格、格子选择、图搜索、寻路、TileMap 辅助、转向和空间索引等通用算法。

## `GFGridMath`

面向网格类小游戏和棋盘逻辑的纯算法工具，适合消消乐、连连看、推箱子、战棋格子等玩法原型。它不依赖 `GFArchitecture`，可以在 `Model`、`System`、测试或编辑器工具中直接静态调用。

```gdscript
var path := GFGridMath.find_path_bfs(
	Vector2i(8, 8),
	Vector2i(0, 0),
	Vector2i(5, 4),
	func(cell: Vector2i) -> bool:
		return not blocked_cells.has(cell)
)

var can_link := GFGridMath.can_connect_with_max_turns(
	Vector2i(10, 6),
	Vector2i(1, 1),
	Vector2i(8, 4),
	func(cell: Vector2i) -> bool:
		return board[cell.y][cell.x] == null
)
```

需要考虑格子代价时，可以使用 A*；需要让大量单位朝多个目标移动时，可以先生成 Flow Field。两者都只接收通行/代价回调，不规定障碍、阵营、地形或棋子语义：

```gdscript
var path := GFGridMath.find_path_a_star(
	Vector2i(32, 32),
	unit_cell,
	target_cell,
	func(cell: Vector2i) -> bool:
		return not blocked_cells.has(cell),
	false,
	func(_from_cell: Vector2i, to_cell: Vector2i) -> float:
		return terrain_costs.get(to_cell, 1.0)
)

var field := GFGridMath.build_flow_field(
	Vector2i(32, 32),
	[target_cell],
	func(cell: Vector2i) -> bool:
		return not blocked_cells.has(cell)
)

var direction := (field["directions"] as Dictionary).get(unit_cell, Vector2i.ZERO)
```


## `GFGridSelection2D` / `GFGridGenerationStep2D` / `GFGridGenerationPipeline2D`

这组三个类提供通用 2D 网格生成数据管线。它们只处理 `Vector2i` 候选格子和 `Dictionary[Vector2i, Variant]` 输出，不绑定房间、地牢、TileMap、GridMap、Mesh、碰撞或具体玩法。

- `GFGridSelection2D` 负责从候选格子中筛选坐标，支持显式包含/排除、矩形边界、反选、自定义回调和子类重写。
- `GFGridGenerationStep2D` 负责把选择器命中的格子写入一个通用值，或从结果字典中移除。
- `GFGridGenerationPipeline2D` 负责按步骤生成或修改网格字典，并提供矩形候选格子构造辅助。

```gdscript
var candidates := GFGridGenerationPipeline2D.make_rect_candidates(Vector2i.ZERO, Vector2i(8, 8))

var inner := GFGridSelection2D.new()
inner.use_bounds = true
inner.bounds_position = Vector2i(1, 1)
inner.bounds_size = Vector2i(6, 6)

var step := GFGridGenerationStep2D.new()
step.selection = inner
step.value = &"walkable"

var pipeline := GFGridGenerationPipeline2D.new()
pipeline.fill_default_value = true
pipeline.default_value = &"blocked"
pipeline.add_step(step)

var grid := pipeline.generate(candidates)
```

输出值是什么、如何转换成瓦片、场景节点、导航、碰撞或存档，仍由项目层决定。需要 3D 或六边形生成时，也应沿用“候选数据 -> 选择器 -> 步骤 -> 输出数据”的模式扩展，而不是把具体地图业务写进基础层。


## `GFHexGridMath`

面向六边形网格的纯算法工具。它和 `GFGridMath` 一样不依赖 `GFArchitecture`，但使用 cube 坐标作为内部拓扑，适合 hex 战棋、策略地图、蜂窝状解谜、区域范围和视线判定。GF 只提供坐标、邻居、路径、范围和 Flow Field 原语，不规定地形、阵营、迷雾、单位或渲染语义。

```gdscript
var cube := GFHexGridMath.offset_to_cube(Vector2i(2, 3), GFHexGridMath.OffsetLayout.ODD_R)
var cell := GFHexGridMath.cube_to_offset(cube, GFHexGridMath.OffsetLayout.ODD_R)

var neighbors := GFHexGridMath.get_neighbors(
	Vector2i(4, 4),
	Vector2i(16, 16),
	GFHexGridMath.OffsetLayout.ODD_R
)
```

需要路径、移动范围或视线时，传入项目自己的通行、代价和阻挡回调：

```gdscript
var path := GFHexGridMath.find_path_a_star(
	Vector2i(32, 32),
	unit_cell,
	target_cell,
	func(cell: Vector2i) -> bool:
		return not blocked_cells.has(cell),
	GFHexGridMath.OffsetLayout.ODD_R,
	func(_from_cell: Vector2i, to_cell: Vector2i) -> float:
		return terrain_costs.get(to_cell, 1.0)
)

var visible := GFHexGridMath.has_line_of_sight(
	unit_cell,
	target_cell,
	func(cell: Vector2i) -> bool:
		return wall_cells.has(cell)
)

var reachable := GFHexGridMath.find_reachable(
	Vector2i(32, 32),
	unit_cell,
	5.0,
	func(cell: Vector2i) -> bool:
		return not blocked_cells.has(cell)
)
```

像素换算支持 pointy-top 与 flat-top；`hex_size` 表示六边形外接圆半径。它只返回中心点或顶点偏移，最终如何创建 TileMap、Polygon2D、Mesh、碰撞或相机仍由项目层决定。


## `GFGraphMath`

`GFGraphMath` 面向任意节点类型的图搜索。它不要求节点必须是格子坐标：`StringName`、`Vector2i`、`Resource`、对象引用或项目自定义值都可以作为节点，只要邻居和代价由回调返回即可。适合对话跳转、技能依赖、地图连接、任务拓扑、资源生产链等“不是规则网格”的路径/可达性问题。

```gdscript
var path := GFGraphMath.find_path_a_star(
	start_node,
	goal_node,
	func(node):
		return graph.get(node, []),
	func(from_node, to_node):
		return edge_costs.get([from_node, to_node], 1.0),
	func(node, goal):
		return estimated_costs.get(node, {}).get(goal, 0.0)
)

var reachable := GFGraphMath.find_reachable(
	start_node,
	5.0,
	func(node):
		return graph.get(node, [])
)
```

`get_step_cost()` 返回负数时表示该边不可通行；启发函数为空时 A* 会退化为 Dijkstra。GF 不缓存图，也不维护节点生命周期，避免把项目的业务拓扑绑定进框架。


## `GFGraphLayoutUtility`

`GFGraphLayoutUtility` 根据节点标识和连接关系生成编辑器坐标，适合状态机、流程图、任务图、依赖图或项目自定义 GraphEdit 面板做初始排布。它只返回 `node_id -> Vector2` 的建议位置，不创建 UI，不保存资源，也不解释节点含义。

```gdscript
var positions := GFGraphLayoutUtility.make_layered_layout(
	PackedStringArray(["start", "check", "end"]),
	[
		{ "from_node_id": "start", "to_node_id": "check" },
		{ "from_node_id": "check", "to_node_id": "end" },
	],
	{
		"x_spacing": 280.0,
		"y_spacing": 160.0,
	}
)
```

分层布局默认读取 `from_node_id` / `to_node_id`，可通过 `from_key` / `to_key` 适配项目自己的连接字段；简单网格排布可用 `make_grid_layout()`。Flow 扩展的 `GFFlowGraphEditorModel.auto_layout()` 会复用该工具把布局写回节点的 `editor_position`，但标准库本身不硬引用任何 GF 内置扩展。


## `GFGrid3DMath`

`GFGrid3DMath` 是 3D 整数格子的纯算法工具，提供 6/26 邻域、A*、可达范围和台阶式表面邻居。它不绑定 `GridMap`、`TileMapLayer`、物理查询或角色控制器；哪些格子可站立、上下台阶限制、移动代价都由调用方回调决定。

```gdscript
var path := GFGrid3DMath.find_path_a_star(
	Vector3i(32, 8, 32),
	start_cell,
	goal_cell,
	func(cell: Vector3i) -> bool:
		return not blocked_cells.has(cell)
)

var surface_path := GFGrid3DMath.find_surface_path_a_star(
	Vector3i(32, 8, 32),
	start_surface_cell,
	goal_surface_cell,
	func(cell: Vector3i) -> bool:
		return walkable_surface_cells.has(cell),
	1,
	2
)
```

表面路径只提供“从当前站立格向水平邻列寻找可站立高度”的机制。是否需要脚底实体、头顶空间、坡度、跳跃、体型半径或动画状态，应继续由项目自己的移动系统和碰撞系统负责。


## `GFPattern2D`

`GFPattern2D` 是一个资源化二维格子模式，用 `Array[Vector2i]` 表达范围、形状、阵型、AOE 或 tile pattern。它只负责尺寸、去重、边界过滤和查询，不规定格子含义；启用 GF 插件后，Inspector 会为 `cells` 提供网格化编辑器，便于小尺寸 pattern 直接勾选、拖拽涂抹，并可按住 Ctrl 擦除格子。

```gdscript
var pattern := GFPattern2D.new()
pattern.pattern_dimensions = Vector2i(5, 5)
pattern.set_cell(Vector2i(2, 2), true)
pattern.set_cell(Vector2i(2, 3), true)

for cell in pattern.get_cells():
	# 项目层自行解释这些格子是攻击范围、建筑 footprint 还是生成模板。
	pass
```


## `GFSteeringAgent` / `GFSteeringAcceleration` / `GFSteeringMath` / `GFSteeringBehaviorResource` / `GFSteeringBehaviorStack`

这组类提供纯 steering 计算原语。`GFSteeringAgent` 只保存位置、速度、朝向、半径和运动上限；`GFSteeringAcceleration` 保存线性/角加速度；`GFSteeringMath` 提供 `seek()`、`flee()`、`arrive()`、`pursue()`、`evade()`、`face()`、`look_where_you_go()`、`separation()`、`cohesion()`、`avoid_collisions()`、`blend()`、`priority()` 和 `path_follow_target()` 等静态计算。

```gdscript
var agent := GFSteeringAgent.new(Vector3(player.global_position.x, player.global_position.y, 0.0))
agent.velocity = Vector3(velocity.x, velocity.y, 0.0)
agent.linear_speed_max = 220.0
agent.linear_acceleration_max = 900.0

var arrive := GFSteeringMath.arrive(agent, Vector3(target.x, target.y, 0.0), 4.0, 96.0)
velocity += Vector2(arrive.linear.x, arrive.linear.y) * delta
```

需要对动态单位做轻量避让时，可以把附近候选代理交给 `avoid_collisions()`。它只基于位置、速度、半径和预测窗口计算未来最近距离，不执行物理查询，也不决定哪些目标算敌人、队友或障碍：

```gdscript
var avoidance := GFSteeringMath.avoid_collisions(agent, nearby_agents, 0.8)
var steering := GFSteeringMath.priority([
	avoidance,
	arrive,
] as Array[GFSteeringAcceleration])
```

Steering 层不直接移动 `CharacterBody2D/3D`，也不规定避障、阵营、路径点来源或群体 AI 策略。项目可以把多个加速度用 `blend()` 加权，也可以用 `priority()` 选择第一个非零行为，再自行做速度积分、碰撞和网络同步。

需要把 steering 行为暴露给资源配置时，可以用 `GFSteeringBehaviorResource` 包装单个通用行为，再用 `GFSteeringBehaviorStack` 做加权混合或优先级选择。动态目标、邻居、路径仍通过 `context` 传入，资源只保存算法参数：

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


## `GFGridOccupancy`

面向格子运行时状态的占用与预约结构。它是普通 `RefCounted`，不参与 `GFArchitecture` 生命周期，适合由项目自己的 `System` 持有，用来表达“谁当前占着哪个格子”“谁预定了下一步目标格”这类通用机制。

它不负责地图生成、寻路策略、碰撞检测、棋子规则或胜负判定，因此可以用于推箱子、战棋、棋盘解谜、消除棋盘等不同项目：

```gdscript
var occupancy := GFGridOccupancy.new(Vector2i(8, 8))

occupancy.occupy(player, Vector2i(1, 1))

if occupancy.reserve_cell(player, Vector2i(2, 1)):
	# 项目层自行播放移动表现或执行命令
	occupancy.confirm_reservation(player)

var blocked := occupancy.is_cell_occupied(Vector2i(3, 1))
```

对象接收者使用弱引用记录，`prune_invalid_receivers()` 可清理已释放对象留下的占用或预约；失效对象释放占用时也会发出 `cell_released(null, cell)`，方便 UI 或棋盘缓存同步刷新。非 `Object` 接收者会以 `typeof + str(value)` 生成内部 key，推荐使用 `StringName`、`int`、稳定字符串或 `Object`，不要直接把 `Dictionary` / `Array` 当作长期唯一标识。


## `GFTileMapCache`

通用格子数据快照与差分缓存，适合把 `TileMapLayer` 当前格子信息采集成纯字典，也可以完全由项目手动写入。它不规定字段语义，因此可用于自动铺砖预览、地图差分刷新、编辑器工具或存档片段。

```gdscript
var previous := GFTileMapCache.new()
previous.update_from_tile_map(tile_map_layer)

# 项目层修改地图后再次采集
var current := GFTileMapCache.new()
current.update_from_tile_map(tile_map_layer)

for cell in current.diff_cells(previous, &"source_id"):
	refresh_cell_visual(cell)

var saved := current.to_dict()
```

`GFTileMetadataLayer` 在 `GFTileMapCache` 的格子字典基础上提供更直接的元数据读写、批量绘制、字段擦除、按值查询和可选 schema。它适合支撑编辑器画刷、运行时标记、导出预处理或调试覆盖层，但仍只保存 `Vector2i -> Dictionary`，不解释字段语义：

```gdscript
var metadata := GFTileMetadataLayer.new()
metadata.set_schema_entry(&"cost", {
	"type": TYPE_INT,
	"default": 1,
})
metadata.paint_cells([Vector2i(1, 1), Vector2i(2, 1)], &"blocked", true)
metadata.merge_cell_data(Vector2i(3, 1), {
	"cost": 5,
	"tag": "road",
})

for cell in metadata.get_cells_with_value(&"blocked", true):
	# 项目层自行决定 blocked 影响寻路、渲染还是编辑器显示。
	pass
```

`schema` 只是给项目或编辑器 UI 使用的元数据字典，GF 不内置字段类型校验、TileSet 写回或业务规则。需要和基础缓存交换数据时，可用 `to_tile_map_cache()` / `from_tile_map_cache()`。

`GFRegionMap2D` 提供更粗粒度的区域分块映射：调用方按格坐标写入任意值，结构会根据 `region_size` 归入区域，并记录被修改过的脏区域。它适合大地图局部保存、编辑器批量处理、运行时地图缓存或导出预处理；GF 只维护 `region -> cell -> value` 和 dirty 标记，不解释地形、区块加载或存档策略：

```gdscript
var regions := GFRegionMap2D.new()
regions.region_size = Vector2i(32, 32)
regions.set_cell(Vector2i(40, 2), { "cost": 3 })

for region_key in regions.get_dirty_region_keys():
	var snapshot := regions.get_region_snapshot(region_key)
	# 项目层自行决定如何保存或刷新该区域。
	pass
```


## `GFTileRuleSet`

基于邻域值序列解析结果的资源化规则表。它只接收 `Variant` 邻域值并返回 `Variant` 结果，不绑定 Godot `TileSet` terrain、source id 或任何具体地图语义。

```gdscript
var rules := GFTileRuleSet.new()
rules.fallback_neighbor_value = 0
rules.default_result = &"plain"

# 例如按上、右、下、左四邻域状态选择结果。
rules.register_rule([1, 1, 1, 1], &"center")
rules.register_rule([1, 0, 1, 0], &"vertical")

var variant_id := rules.resolve([1, 0, 1, 0], Vector2i(4, 8))
```

同一规则可以注册多个带权重结果，并通过格坐标和 seed 做确定性选择。项目层仍负责定义邻域采样顺序、值含义和最终如何应用到 TileMap。


## `GFSpatialHash3D`

面向 3D 实体的纯逻辑空间哈希。它只维护调用方传入的 `AABB` 索引，适合在 `System` 中做大量动态实体的粗筛查询，例如感知范围、区域触发、编辑器预览或轻量服务器模拟。

```gdscript
var spatial_hash := GFSpatialHash3D.new(4.0)
spatial_hash.insert(unit_id, AABB(unit_position, Vector3.ONE))

for entity in spatial_hash.query_radius(Vector3.ZERO, 12.0):
	# 项目层自行做精确规则判断
	pass
```

它不依赖物理节点，也不负责碰撞、阵营、视线或目标选择规则；这些语义仍应留在项目自己的 `System` 或规则对象中。

`GFGridMath` 的连线访问状态、`GFGridOccupancy` 的格子索引和 `GFSpatialHash3D` 的空间桶索引都使用坐标值作为内部 key，避免在高频网格/空间查询中反复拼接临时字符串。调用方仍只依赖公开方法；如果需要序列化格子坐标，应在项目层或专门缓存结构中显式转换成稳定文本。
