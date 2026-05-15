# Save 场景存档图

本页聚焦 GF Save 扩展如何把场景树节点状态组织成可采集、可校验、可应用的存档图。
## Save 扩展与标准存储

`GFStorageUtility`、`GFStorageCodec`、`GFStorageSyncUtility` 和 `GFSnapshotHistoryUtility` 是标准库能力，负责本地读写、编码、同步和快照历史，主说明见 [本地存储、编码、同步与快照](../../standard/utilities/io/storage-snapshot.md)。GF Save 扩展负责把场景树节点状态组织成可采集、可校验、可应用的存档图；两者可以组合使用，但职责不同。


## 场景存档图 (`GFSaveGraphUtility`)

需要把场景树上的多个节点状态组合成一个存档图时，可以使用 `GFSaveGraphUtility`。`GFSaveScope` 定义保存边界，`GFSaveSource` 定义数据入口，`GFNodeSerializerRegistry` 管理可组合节点序列化器；框架只负责遍历、聚合和应用，不规定玩家、关卡、背包或实体字段。

```gdscript
var save_graph := Gf.get_utility(GFSaveGraphUtility) as GFSaveGraphUtility
var report := save_graph.inspect_scope(%SaveScope)
var payload := save_graph.gather_scope(%SaveScope)
var payload_report := save_graph.validate_payload_for_scope(%SaveScope, payload, true)
save_graph.apply_scope(%SaveScope, payload)
```

项目可以继承 `GFSaveSource` 或注册自定义 `GFNodeSerializer`，也可以在需要补建实体时注册 `GFSaveEntityFactory`。默认能力提供 Transform、CanvasItem、Control、Range 等通用节点状态片段，并可通过 `GFSavePipelineStep` 在采集/应用前后插入校验、版本适配或调试标记；`inspect_scope()` / `validate_payload_for_scope()` 用于开发期提前发现重复 key、缺失目标或载荷不匹配，报告会包含 `healthy`、`error_count`、`warning_count`、`summary` 与 `next_action`，便于编辑器面板、CI 或测试直接消费。`load_scope()` 从存储读取后会先校验载荷格式与当前 Scope 树，不会把明显不匹配的文件继续应用。`apply_scope()` 会拒绝非 Dictionary 的 `sources`、`scopes`、子 Scope 载荷、Source `data` 和 Serializer `data`，把结构错误写入结果而不是继续应用，并清理本次事务使用的临时实体上下文。若 `GFSaveScope.restore_policy` 允许工厂恢复，工厂创建出的实体必须自身就是 `GFSaveSource`，或子树中能找到 `GFSaveSource`；否则该实体会被释放，不会残留在场景树中。默认 `transactional_apply = true` 时，本次应用中新建的工厂实体会在后续 Source 或子 Scope 应用失败时回滚释放，避免读档一半失败后留下半恢复场景。`gather_scope()` 遇到重复 Source key、重复子 Scope key 或子 Scope 采集失败时会整体返回空载荷，并把错误写入共享的 `GFSavePipelineContext`，避免生成缺失子树的部分存档。插件菜单 `工具 > GF > 校验当前场景 SaveGraph` 与 `GF Workspace > Save` 页面会扫描当前编辑场景里的 `GFSaveScope` 并展示同一套健康报告；工作区页面还可以按需采集预览 payload 和 pipeline trace，具体 schema 仍由项目层决定。

默认节点序列化器按节点类型拆分：`GFNodeTransform2DSerializer` / `GFNodeTransform3DSerializer` 保存空间变换，`GFNodeCanvasItemSerializer` 保存可见性与调制等 2D 表现状态，`GFNodeControlSerializer` 保存常见 UI Control 状态，`GFNodeRangeSerializer` 保存 Slider/ProgressBar 等 Range 值，`GFNodeTimerSerializer` 保存 Timer 运行状态，`GFNodeAnimationPlayerSerializer` 保存动画播放器状态，`GFNodeAudioStreamPlayerSerializer` 保存音频播放器状态，`GFNodePropertySerializer` 则用于项目显式声明的属性列表。属性序列化器应用数据时会检查属性存在、可写性和基础 Variant 类型兼容性；复杂迁移、旧字段别名和业务范围钳制应放在项目自己的 Serializer 或 Pipeline Step 中处理。需要给动态实体稳定身份时，可在节点上挂 `GFSaveIdentity`，它只描述 `persistent_id`、`type_key` 和扩展描述，不负责实例化。

读档选单可使用 `GFSaveSlotWorkflow` 构建通用槽位元数据和卡片 DTO；它只处理槽位索引、逻辑标识、显示名、标签和自定义字典，不规定 UI 布局或存档内容：

```gdscript
var storage := Gf.get_utility(GFStorageUtility) as GFStorageUtility
var workflow := GFSaveSlotWorkflow.new()
workflow.active_slot_index = 1

var metadata := workflow.build_active_metadata("Manual Slot 1", {
	"chapter": 3,
})
storage.save_slot(workflow.get_active_storage_slot_id(), payload, metadata.to_dict())

var cards := workflow.build_cards_from_storage(storage, [1, 2, 3])
```

槽位工作流内部使用 `GFSaveSlotMetadata` 描述槽位 ID、展示名、schema、版本、标签、耗时和自定义元数据；`GFSaveSlotCard` 则是给读档 UI 消费的轻量 DTO，包含空槽、当前选中、兼容性、修改时间和原始 metadata 副本。卡片会从整数 `slot_index`、整数/字符串 `slot_id`、metadata 里的 `slot_id` 或兜底逻辑 ID 中反推整数索引，兼容默认 `slot_3` 这类逻辑标识。它们都不绑定具体 UI 卡片布局，也不定义项目的存档字段。

需要审计采集或应用流程时，可以按需开启 trace，或显式传入 `GFSavePipelineContext` 在外部读取事件：

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

trace 中的单条记录由 `GFSavePipelineEvent` 表示，包含阶段、严重级别、Scope key、Source key、节点路径、调试消息和附加载荷。它适合写入日志、测试断言或编辑器诊断面板；业务字段仍应放在项目自己的 payload 中。
