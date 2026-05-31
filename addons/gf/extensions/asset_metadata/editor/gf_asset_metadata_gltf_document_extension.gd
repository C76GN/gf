@tool

## GFAssetMetadataGltfDocumentExtension: 将 glTF extras 桥接为 GF 资产元数据。
##
## 导入节点时只复制通用 extras 数据，不解释字段含义，也不创建业务对象。
## [br]
## @api public
## [br]
## @category editor_api
## [br]
## @since 3.17.0
class_name GFAssetMetadataGltfDocumentExtension
extends GLTFDocumentExtension


# --- 可重写钩子 / 虚方法 ---

## 导入 glTF 节点时把 json.extras 写入节点元数据。
## [br]
## @api protected
## [br]
## @param _state: glTF 导入状态。
## [br]
## @param _gltf_node: 正在导入的 glTF 节点描述。
## [br]
## @param json: glTF 节点原始 JSON 字典。
## [br]
## @param node: 导入生成的 Godot 节点。
## [br]
## @schema json: Dictionary，可包含 extras 字段；extras 会归一化为资产元数据字典。
## [br]
## @return Godot 错误码。
func _import_node(
	_state: GLTFState,
	_gltf_node: GLTFNode,
	json: Dictionary,
	node: Node
) -> Error:
	if node == null or not json.has("extras"):
		return OK

	var metadata: Dictionary = GFAssetMetadataUtility.normalize_metadata(
		GFVariantData.get_option_value(json, "extras")
	)
	if metadata.is_empty():
		return OK

	node.set_meta(GFAssetMetadataUtility.META_ASSET_METADATA, metadata)
	node.set_meta(GFAssetMetadataUtility.META_ASSET_METADATA_SOURCE, "gltf_node_extras")
	return OK
