@tool

## GFAssetMetadataGltfDocumentExtension: 将 glTF extras 桥接为 GF 资产元数据。
##
## 导入节点时只复制通用 extras 数据，不解释字段含义，也不创建业务对象。
class_name GFAssetMetadataGltfDocumentExtension
extends GLTFDocumentExtension


# --- 常量 ---

const GFAssetMetadataUtilityBase = preload("res://addons/gf/extensions/asset_metadata/runtime/gf_asset_metadata_utility.gd")


# --- 可重写钩子 ---

func _import_node(
	_state: GLTFState,
	_gltf_node: GLTFNode,
	json: Dictionary,
	node: Node
) -> Error:
	if node == null or not json.has("extras"):
		return OK

	var metadata := GFAssetMetadataUtilityBase.normalize_metadata(json.get("extras"))
	if metadata.is_empty():
		return OK

	node.set_meta(GFAssetMetadataUtilityBase.META_ASSET_METADATA, metadata)
	node.set_meta(GFAssetMetadataUtilityBase.META_ASSET_METADATA_SOURCE, "gltf_node_extras")
	return OK
