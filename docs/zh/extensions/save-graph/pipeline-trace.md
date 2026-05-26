# Pipeline Trace

需要审计采集或应用流程时，可以按需开启 trace，或显式传入 `GFSavePipelineContext` 在外部读取事件。

```gdscript
var payload_with_trace := save_graph.gather_scope(%SaveScope, {
	"include_pipeline_trace": true,
})

var pipeline_context := save_graph.create_pipeline_context(&"apply", %SaveScope)
save_graph.apply_scope(%SaveScope, payload, {
	"pipeline_context": pipeline_context,
})
print(pipeline_context.to_dict())
```

`GFSavePipelineContext` 只是流程事件日志，不是要保存的游戏数据。保存时应写入 `gather_scope()` 返回的 payload；`pipeline_context.to_dict()` 只适合写日志、测试断言或编辑器诊断面板。

trace 中的单条记录由 `GFSavePipelineEvent` 表示，包含阶段、严重级别、Scope key、Source key、节点路径、调试消息和附加载荷。业务字段仍应放在项目自己的 payload 中，或由自定义 `GFSaveSource` 写入 SaveGraph payload。
