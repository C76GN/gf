# 快照与场景树诊断

`GFDiagnosticsUtility` 可以采集运行时快照，并通过内置命令读取性能、工具状态和场景树摘要。

```gdscript
var diagnostics := Gf.get_utility(GFDiagnosticsUtility) as GFDiagnosticsUtility
var snapshot := diagnostics.collect_snapshot({
	"recent_log_count": 10,
})
var performance := diagnostics.execute_command(&"diagnostics.performance")
var tools := diagnostics.execute_command(&"diagnostics.tools")
```

## 场景树快照

需要在运行时查看当前场景结构时，可显式采集只读场景树快照。它只记录节点名、类型、路径、可选脚本路径和子节点摘要，不读取任意属性、不调用业务方法，也不修改节点。

```gdscript
var scene := diagnostics.execute_command(&"diagnostics.scene", {
	"max_depth": 3,
	"max_nodes": 128,
	"include_groups": true,
})

var snapshot_with_scene := diagnostics.collect_snapshot({
	"include_scene_tree": true,
	"scene_tree_options": {
		"max_depth": 2,
	},
})
```

场景树快照适合编辑器诊断、支持报告和测试断言。它不是运行时对象查询 API，不应作为业务逻辑分支条件。
