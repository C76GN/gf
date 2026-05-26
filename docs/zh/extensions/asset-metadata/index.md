# Asset Metadata

Asset Metadata 扩展用于把导入资产、节点或资源片段上的结构化元数据收束为 GF 可查询的记录。它只处理元数据键、复制、读取、收集和报告，不解释字段业务含义。

适合场景包括：从 glTF `extras` 带入作者标记、扫描关卡节点 metadata、在编辑器导入检查中生成统一报告，或让项目工具用同一套记录读取资产标签。

## 阅读入口

- `GFAssetMetadataUtility`：读取、写入、归一化和收集对象 metadata。
- `GFAssetMetadataRecord`：用稳定结构保存来源路径、对象路径、对象类别和 metadata 字典。
- `GFAssetMetadataGltfDocumentExtension`：在 glTF 导入时把节点 `extras` 复制为 GF metadata。

## 典型流程

导入 glTF 后，节点上的 `extras` 会被写入默认键 `gf_asset_metadata`。项目可以在需要时收集场景树：

```gdscript
var utility := Gf.get_utility(GFAssetMetadataUtility) as GFAssetMetadataUtility
var records := utility.collect_node_tree(imported_root, {
	"source_path": "res://levels/forest.glb",
})

for record: GFAssetMetadataRecord in records:
	var metadata := record.metadata
	# 项目层在这里解释 metadata 字段。
```

## 使用边界

- Asset Metadata 不内置 `spawn_point`、`loot`、`quest`、`door` 等业务字段。
- 项目可以自由定义 metadata schema，并在自己的导入管线、Installer 或工具中消费记录。
- 需要强 schema、必填字段或跨资产引用检查时，应在项目工具中基于 `GFAssetMetadataRecord` 实现。
- 其他 GF 内置扩展不应直接依赖 Asset Metadata；跨扩展组合应放在项目 Installer 或独立插件中。

## API Reference

完整类、方法和属性清单见 [Asset Metadata API Reference](../../reference/api/extensions-asset-metadata.md)。
