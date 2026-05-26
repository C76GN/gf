# 编辑器图布局

`GFGraphLayoutUtility` 根据节点标识和连接关系生成编辑器坐标，适合状态机、流程图、任务图、依赖图或项目自定义 GraphEdit 面板做初始排布。

它只返回 `node_id -> Vector2` 的建议位置，不创建 UI，不保存资源，也不解释节点含义。

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

分层布局默认读取 `from_node_id` / `to_node_id`，可通过 `from_key` / `to_key` 适配项目自己的连接字段；简单网格排布可用 `make_grid_layout()`。

Flow 扩展的 `GFFlowGraphEditorModel.auto_layout()` 会复用该工具把布局写回节点的 `editor_position`，但标准库本身不硬引用任何 GF 内置扩展。
