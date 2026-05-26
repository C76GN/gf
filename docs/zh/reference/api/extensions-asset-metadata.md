# Asset Metadata API

Module: `extensions/asset_metadata`

## Classes

- [`GFAssetMetadataGltfDocumentExtension`](#gfassetmetadatagltfdocumentextension)
- [`GFAssetMetadataRecord`](#gfassetmetadatarecord)
- [`GFAssetMetadataUtility`](#gfassetmetadatautility)

## GFAssetMetadataGltfDocumentExtension

- Path: `addons/gf/extensions/asset_metadata/editor/gf_asset_metadata_gltf_document_extension.gd`
- Extends: `GLTFDocumentExtension`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFAssetMetadataGltfDocumentExtension: 将 glTF extras 桥接为 GF 资产元数据。 导入节点时只复制通用 extras 数据，不解释字段含义，也不创建业务对象。

## GFAssetMetadataRecord

- Path: `addons/gf/extensions/asset_metadata/resources/gf_asset_metadata_record.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFAssetMetadataRecord: 资产元数据记录。 记录某个导入资产、节点或资源片段上的结构化元数据，不解释字段业务含义。

### Properties

#### `source_path`

- API: `public`

```gdscript
var source_path: String = ""
```

元数据来源资产路径。

#### `subject_path`

- API: `public`

```gdscript
var subject_path: NodePath = NodePath(".")
```

元数据所属对象相对路径。节点树中通常是相对根节点的 NodePath。

#### `subject_kind`

- API: `public`

```gdscript
var subject_kind: StringName = &""
```

元数据所属对象类别，例如 node、resource 或 asset。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

结构化元数据。框架只复制和查询，不解释业务字段。

Schemas:

- `metadata`: Dictionary，保存导入资产、节点或资源片段的项目自定义元数据字段。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( p_source_path: String = "", p_subject_path: NodePath = NodePath("."), p_subject_kind: StringName = &"", p_metadata: Dictionary = {} ) -> GFAssetMetadataRecord:
```

配置记录。

Parameters:

| Name | Description |
|---|---|
| `p_source_path` | 来源资产路径。 |
| `p_subject_path` | 所属对象路径。 |
| `p_subject_kind` | 所属对象类别。 |
| `p_metadata` | 结构化元数据。 |

Returns: 当前记录。

Schemas:

- `p_metadata`: Dictionary，保存导入资产、节点或资源片段的项目自定义元数据字段。

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

检查记录是否没有元数据。

Returns: 没有元数据时返回 true。

#### `has_value`

- API: `public`

```gdscript
func has_value(key: StringName) -> bool:
```

检查元数据键是否存在。StringName 与 String 形式会被同时识别。

Parameters:

| Name | Description |
|---|---|
| `key` | 元数据键。 |

Returns: 存在时返回 true。

#### `get_value`

- API: `public`

```gdscript
func get_value(key: StringName, default_value: Variant = null) -> Variant:
```

读取元数据值并返回安全副本。

Parameters:

| Name | Description |
|---|---|
| `key` | 元数据键。 |
| `default_value` | 缺失时返回的默认值。 |

Returns: 元数据值副本或默认值。

Schemas:

- `default_value`: Variant，缺失时返回的调用方默认值，会按 GFVariantData 规则复制。
- `return`: Variant，元数据值副本；缺失时为 default_value 的安全副本。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为字典。

Returns: 记录字典副本。

Schemas:

- `return`: Dictionary，包含 source_path、subject_path、subject_kind 与 metadata 字段。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

从字典应用字段。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Schemas:

- `data`: Dictionary，可包含 source_path、subject_path、subject_kind 与 metadata 字段。

#### `duplicate_record`

- API: `public`

```gdscript
func duplicate_record() -> GFAssetMetadataRecord:
```

创建记录深拷贝。

Returns: 新记录。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFAssetMetadataRecord:
```

从字典创建记录。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Returns: 新记录。

Schemas:

- `data`: Dictionary，可包含 source_path、subject_path、subject_kind 与 metadata 字段。

## GFAssetMetadataUtility

- Path: `addons/gf/extensions/asset_metadata/runtime/gf_asset_metadata_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFAssetMetadataUtility: 资产元数据收集与查询工具。 统一管理导入资产元数据在 Object metadata 中的存储键、复制规则和节点树收集流程。 它不解释任何项目字段；业务语义应由项目代码或项目扩展消费。

### Constants

#### `META_ASSET_METADATA`

- API: `public`

```gdscript
const META_ASSET_METADATA: StringName = &"gf_asset_metadata"
```

Object metadata 中保存 GF 资产元数据的默认键。

#### `META_ASSET_METADATA_SOURCE`

- API: `public`

```gdscript
const META_ASSET_METADATA_SOURCE: StringName = &"gf_asset_metadata_source"
```

Object metadata 中保存元数据来源说明的默认键。

### Methods

#### `normalize_metadata`

- API: `public`

```gdscript
static func normalize_metadata(value: Variant) -> Dictionary:
```

将任意导入元数据归一为 Dictionary。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入元数据。Dictionary 会深拷贝；其他非 null 值会保存在 value 字段中。 |

Returns: 归一化后的元数据字典。

Schemas:

- `value`: Variant，Dictionary 会深拷贝；其他非 null 值会保存为 { "value": value }。
- `return`: Dictionary，归一化后的资产元数据字段。

#### `write_object_metadata`

- API: `public`

```gdscript
func write_object_metadata( target: Object, metadata: Dictionary, options: Dictionary = {} ) -> GFAssetMetadataRecord:
```

写入对象资产元数据。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标 Object。 |
| `metadata` | 结构化元数据。 |
| `options` | 可选项，支持 metadata_key、source_path、subject_path、subject_kind、metadata_source。 |

Returns: 写入后的记录；目标无效时返回 null。

Schemas:

- `metadata`: Dictionary，要写入 Object metadata 的结构化资产元数据字段。
- `options`: Dictionary，可包含 metadata_key、source_path、subject_path、subject_kind 与 metadata_source。

#### `read_object_metadata`

- API: `public`

```gdscript
func read_object_metadata(target: Object, options: Dictionary = {}) -> Dictionary:
```

读取对象资产元数据。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标 Object。 |
| `options` | 可选项，支持 metadata_key 或 metadata_keys。 |

Returns: 元数据字典副本；不存在时返回空字典。

Schemas:

- `options`: Dictionary，可包含 metadata_key 或 metadata_keys。
- `return`: Dictionary，读取到的结构化资产元数据字段。

#### `has_object_metadata`

- API: `public`

```gdscript
func has_object_metadata(target: Object, options: Dictionary = {}) -> bool:
```

检查对象是否带有资产元数据。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标 Object。 |
| `options` | 可选项，支持 metadata_key 或 metadata_keys。 |

Returns: 存在资产元数据时返回 true。

Schemas:

- `options`: Dictionary，可包含 metadata_key 或 metadata_keys。

#### `clear_object_metadata`

- API: `public`

```gdscript
func clear_object_metadata(target: Object, options: Dictionary = {}) -> void:
```

清除对象资产元数据。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标 Object。 |
| `options` | 可选项，支持 metadata_key 或 metadata_keys。 |

Schemas:

- `options`: Dictionary，可包含 metadata_key、metadata_keys 与 clear_source。

#### `collect_node_tree`

- API: `public`

```gdscript
func collect_node_tree(root: Node, options: Dictionary = {}) -> Array[GFAssetMetadataRecord]:
```

收集节点树中的资产元数据记录。

Parameters:

| Name | Description |
|---|---|
| `root` | 节点树根节点。 |
| `options` | 可选项，支持 metadata_key、metadata_keys、source_path、subject_kind、max_depth。 |

Returns: 资产元数据记录列表。

Schemas:

- `options`: Dictionary，可包含 metadata_key、metadata_keys、source_path、subject_kind 与 max_depth。

#### `collect_node_tree_dicts`

- API: `public`

```gdscript
func collect_node_tree_dicts(root: Node, options: Dictionary = {}) -> Array[Dictionary]:
```

收集节点树中的资产元数据记录字典。

Parameters:

| Name | Description |
|---|---|
| `root` | 节点树根节点。 |
| `options` | 可选项，支持 metadata_key、metadata_keys、source_path、subject_kind、max_depth。 |

Returns: 资产元数据记录字典列表。

Schemas:

- `options`: Dictionary，可包含 metadata_key、metadata_keys、source_path、subject_kind 与 max_depth。
- `return`: Array[Dictionary]，每一项包含 source_path、subject_path、subject_kind 与 metadata 字段。

#### `build_node_tree_report`

- API: `public`

```gdscript
func build_node_tree_report(root: Node, options: Dictionary = {}) -> Dictionary:
```

构建节点树资产元数据报告。

Parameters:

| Name | Description |
|---|---|
| `root` | 节点树根节点。 |
| `options` | 可选项，支持 collect_node_tree() 的参数。 |

Returns: 报告字典。

Schemas:

- `options`: Dictionary，可包含 metadata_key、metadata_keys、source_path、subject_kind 与 max_depth。
- `return`: Dictionary，包含 ok、healthy、summary、next_action、source_path、entry_count、entries 与 issues。

