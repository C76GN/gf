# 校验规则套件与 Runner

当项目需要把一组资源、场景或运行时对象纳入同一套质量检查时，可以用资源化套件组织规则，再由 Runner 聚合成 `GFValidationReport`。

规则不会按约定调用项目脚本方法；只有显式设置的 `Callable` 或子类重写的 `_validate()` 会参与校验，因此框架不会把业务字段、节点命名或资源类型写死进标准库。

## 套件示例

```gdscript
var rule := GFValidationRule.new().configure(
	&"node_name_required",
	func(target: Variant, report: GFValidationReport, _context: Dictionary) -> Variant:
		var node := target as Node
		if node != null and String(node.name).is_empty():
			report.add_error(&"empty_name", "Node name is empty.")
		return null,
	{ "target_kind": GFValidationRule.TargetKind.NODE }
)

var suite := GFValidationSuite.new()
suite.suite_id = &"scene_health"
suite.include_paths = PackedStringArray(["res://levels"])
suite.scene_extensions = PackedStringArray(["tscn"])
suite.add_rule(rule)

var report := GFValidationRunner.new().run_suite(suite)
var junit_xml := GFValidationJUnitExporter.export_report(report, {
	"suite_name": "Scene Health",
})
```

## 运行边界

`GFValidationSuite` 只保存规则、include/exclude 路径、支持扩展名和是否把 warning 当 error。`GFValidationRunner` 可以直接校验对象数组，也可以加载路径；遇到 `PackedScene` 时默认会额外实例化根节点给 Node 规则检查。

路径扫描只按扩展名和显式排除规则工作，不推断项目资源目录职责。`collect_paths()` 默认限制 `max_scan_depth = 32`、`max_collected_paths = 10000`；需要深度扫描时可以显式调高，设为 `0` 表示不限制。

`GFValidationJUnitExporter` 只把报告转成 CI 友好的 XML 字符串，构建是否失败、报告保存到哪里、如何展示问题都留给项目或流水线决定。
