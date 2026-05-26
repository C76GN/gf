# 支持报告

`GFSupportReportUtility` 用于把用户描述、项目元数据、构建信息、运行时信息、`GFDiagnosticsUtility` 快照、日志缓存和项目自定义分区聚合成一个普通字典。它可以导出 JSON、写入本地文件，也可以通过项目传入的 `Callable` 提交给任意自有流程；GF 不内置上传地址、工单系统或玩家反馈 UI。

```gdscript
var reports := Gf.get_utility(GFSupportReportUtility) as GFSupportReportUtility
reports.register_section(&"save_slot", func(_options: Dictionary) -> Dictionary:
	return {
		"slot_id": current_slot_id,
		"checkpoint": current_checkpoint_id,
	}
)

var report := reports.build_report("设置界面打开后无法返回", {
	"metadata": {
		"screen": "settings",
	},
	"tags": ["ui", "runtime"],
	"include_diagnostics": true,
	"scene_options": {
		"max_depth": 64,
		"max_nodes": 10000,
	},
})
reports.save_report(report, "user://support/report_latest.json")
var markdown_summary := reports.export_report_markdown(report, {
	"title": "Support Report",
})
```

场景快照只记录当前场景名称、路径和节点数量，节点数量统计默认限制深度与节点数；被截断时 `scene.node_count_truncated` 为 `true`。`export_report_json()` 适合自动化传输和持久化；`export_report_markdown()` 适合把同一份报告摘要贴进 Issue、PR、客服工单或测试记录。
