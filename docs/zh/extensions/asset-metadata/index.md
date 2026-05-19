# Asset Metadata

`GF Asset Metadata` 是一个可选扩展，用于把导入资产、节点或资源片段上的结构化元数据统一放入 GF 可查询的记录中。它只处理元数据的存储键、复制、收集和报告，不解释任何字段业务含义。

## 定位

项目经常需要把美术资产、关卡资产或外部工具中的标记带进运行时或编辑器工具。若每个系统都各自解析节点名、组名、导入脚本或自定义字典，约定会分散在很多地方。Asset Metadata 把这类约定收束为一个通用 Module：

- glTF 节点 `extras` 会在导入时复制到节点的 Object metadata。
- `GFAssetMetadataUtility` 用统一键读取、写入和收集节点树元数据。
- `GFAssetMetadataRecord` 用稳定结构表达来源路径、对象路径、对象类别和 metadata 字典。

扩展不内置 `spawn_point`、`loot`、`quest`、`door` 等业务字段。项目可以自由定义 metadata schema，并在项目 Installer、导入管线或项目自己的工具中消费这些记录。

## 核心类

- `GFAssetMetadataUtility`：运行时工具，负责对象 metadata 读写、节点树收集和报告生成。
- `GFAssetMetadataRecord`：资源化记录，保存 `source_path`、`subject_path`、`subject_kind` 和 `metadata`。
- `GFAssetMetadataGltfDocumentExtension`：编辑器导入桥接，将 glTF 节点的 `extras` 复制为 GF 资产元数据。

## 典型流程

导入 glTF 后，节点上的 `extras` 会被写入 `gf_asset_metadata`。项目可以在需要时收集场景树：

```gdscript
var utility := Gf.get_utility(GFAssetMetadataUtility) as GFAssetMetadataUtility
var records := utility.collect_node_tree(imported_root, {
	"source_path": "res://levels/forest.glb",
})

for record: GFAssetMetadataRecord in records:
	var metadata := record.metadata
	# 项目层在这里解释 metadata 字段。
```

也可以对普通对象或自定义导入流程写入同一套 metadata：

```gdscript
utility.write_object_metadata(node, {
	"authoring_id": "gate_01",
	"tags": ["blocking"],
})
```

## 常用 API

`GFAssetMetadataUtility.normalize_metadata(value)` 会把输入归一为 Dictionary。Dictionary 会深拷贝；其他非 null 值会保存在 `value` 字段中，避免丢失导入数据。

`write_object_metadata(target, metadata, options)` 使用默认键 `gf_asset_metadata` 写入 metadata。`options.metadata_key` 可覆盖键名，`metadata_source` 可记录来源说明。

`read_object_metadata(target, options)` 返回 metadata 副本。`options.metadata_keys` 可以传入多个键，工具会按顺序读取第一个存在的键。

`collect_node_tree(root, options)` 从根节点开始递归收集记录。`max_depth` 可限制递归深度，`source_path` 可覆盖记录中的来源路径。

`build_node_tree_report(root, options)` 返回统一校验报告字典，适合编辑器工具或项目导入检查展示。

## 注意事项

Asset Metadata 只提供导入资产元数据的稳定通道，不负责项目规则校验。若项目需要强 schema、必填字段或跨资产引用检查，应在项目自己的导入检查工具中基于 `GFAssetMetadataRecord` 实现。

不要让其他 GF 内置扩展直接依赖 Asset Metadata。跨扩展组合应放在项目 Installer 或 `addons/gf` 外的独立插件中。
