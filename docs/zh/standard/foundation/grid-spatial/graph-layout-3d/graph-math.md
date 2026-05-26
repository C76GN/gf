# 任意拓扑图搜索

`GFGraphMath` 面向任意节点类型的图搜索。它不要求节点必须是格子坐标：`StringName`、`Vector2i`、`Resource`、对象引用或项目自定义值都可以作为节点，只要邻居和代价由回调返回即可。

适合对话跳转、技能依赖、地图连接、任务拓扑、资源生产链等“不是规则网格”的路径/可达性问题。

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

`get_step_cost()` 返回负数时表示该边不可通行；启发函数为空时 A* 会退化为 Dijkstra。

GF 不缓存图，也不维护节点生命周期，避免把项目的业务拓扑绑定进框架。
