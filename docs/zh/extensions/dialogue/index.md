# Dialogue 通用对话资源

本页聚焦 Dialogue 扩展中的抽象对话资源、上下文和运行器。

## 对话资源、上下文与运行器

Dialogue 扩展位于 `addons/gf/extensions/dialogue/`，提供 `GFDialogueResource`、`GFDialogueLine`、`GFDialogueResponse`、`GFDialogueContext` 和 `GFDialogueRunner`。它只负责把“行、响应、跳转、条件和 mutation 请求”抽象成可运行资源，不规定剧本语言、对话框 UI、角色表、本地化格式、存档结构或项目状态字段。

`GFDialogueResource` 保存起始行和行集合。`GFDialogueLine` 可表示可展示文本、mutation、跳转或结束点；`GFDialogueResponse` 描述某个可选响应及其后继。条件和 mutation 都只保存 ID 与载荷，实际含义由项目通过 `GFDialogueContext` 的 Callable 处理。

```gdscript
var resource := GFDialogueResource.new()
resource.start_line_id = &"start"

var start := GFDialogueLine.new()
start.line_id = &"start"
start.text = "hello_key"
start.next_line_id = &"end"
resource.set_line(start)

var end := GFDialogueLine.new()
end.line_id = &"end"
end.kind = GFDialogueLine.LineKind.END
resource.set_line(end)
```

`GFDialogueContext` 保存运行时值表，并可提供 `condition_handler`、`mutation_handler` 和 `text_resolver`。这些回调建议返回 `bool` 或 `{ "ok": true, "value": ... }` 这类结构化字典；框架只包装结果，不解释条件 ID、mutation ID 或文本键。

```gdscript
var context := GFDialogueContext.new()
context.condition_handler = func(condition_id: StringName, payload: Variant, subject: Variant, ctx: GFDialogueContext) -> bool:
	return ctx.get_value(condition_id, false)

context.mutation_handler = func(mutation_id: StringName, payload: Variant, _subject: Variant, ctx: GFDialogueContext) -> Dictionary:
	ctx.set_value(mutation_id, payload)
	return { "ok": true }
```

`GFDialogueRunner` 沿资源推进，遇到可展示文本行时发出 `line_reached`，遇到 mutation 行时发出 `mutation_requested` 并调用上下文处理器，遇到响应时可通过 `choose_response(response_id)` 进入后继。它不创建 UI，也不读取输入；项目可以用任意界面层显示 `get_current_line()` 和 `get_available_responses()`。

```gdscript
var runner := GFDialogueRunner.new()
runner.line_reached.connect(func(line: GFDialogueLine) -> void:
	print(context.resolve_text(line.text, line))
)

runner.start(resource, &"", context)
runner.advance()
```

`validate_resource()` 可报告空行、空 ID、重复 ID 和缺失后继引用。复杂导入、图编辑器、分支可视化、语音/字幕、本地化表和存档恢复都应放在项目层或独立插件里；Dialogue 扩展只保留可复用的最小运行时抽象。
