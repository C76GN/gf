# 节点序列化器与槽位

SaveGraph 的默认节点序列化器按节点类型拆分，覆盖常见场景状态片段。复杂迁移、旧字段别名、业务范围钳制、内嵌资源快照和节点引用恢复应放在项目自己的 Serializer 或 Pipeline Step 中处理。

## 默认节点序列化器

- `GFNodeTransform2DSerializer` / `GFNodeTransform3DSerializer`：保存空间变换。
- `GFNodeCanvasItemSerializer`：保存可见性与调制等 2D 表现状态。
- `GFNodeControlSerializer`：保存常见 UI Control 状态。
- `GFNodeRangeSerializer`：保存 Slider/ProgressBar 等 Range 值。
- `GFNodeTimerSerializer`：保存 Timer 运行状态。
- `GFNodeAnimationPlayerSerializer`：保存动画播放器状态。
- `GFNodeAudioStreamPlayerSerializer`：保存音频播放器状态。
- `GFNodePropertySerializer`：保存项目显式声明的属性列表。

属性序列化器采集时会把常见 Godot 值类型转成可 JSON 落盘的类型化值，并可按 `resource_path` 保存外部 `Resource` 引用。没有路径的内嵌资源、节点对象引用或其他裸 `Object` 会被跳过并输出 warning。应用数据时会先恢复类型化值，再检查属性存在、可写性和基础 Variant 类型兼容性。

需要给动态实体稳定身份时，可在节点上挂 `GFSaveIdentity`。它只描述 `persistent_id`、`type_key` 和扩展描述，不负责实例化。

## 槽位工作流

读档选单可使用 `GFSaveSlotWorkflow` 构建通用槽位元数据和卡片 DTO；它只处理槽位索引、逻辑标识、显示名、标签和自定义字典，不规定 UI 布局或存档内容。

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

槽位工作流内部使用 `GFSaveSlotMetadata` 描述槽位 ID、展示名、schema、版本、标签、耗时和自定义元数据；`validate_metadata()` 返回标准校验报告字典，用 `kind`、统计、摘要和下一步建议描述元数据结构问题。

`GFSaveSlotCard` 是给读档 UI 消费的轻量 DTO，包含空槽、当前选中、兼容性、修改时间和原始 metadata 副本。卡片会从整数 `slot_index`、整数/字符串 `slot_id`、metadata 里的 `slot_id` 或兜底逻辑 ID 中反推整数索引，兼容默认 `slot_3` 这类逻辑标识。它们都不绑定具体 UI 卡片布局，也不定义项目的存档字段。
