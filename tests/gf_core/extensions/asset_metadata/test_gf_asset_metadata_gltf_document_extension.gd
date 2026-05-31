## 测试 GFAssetMetadataGltfDocumentExtension 的 glTF extras 桥接。
extends GutTest


func test_import_node_copies_gltf_extras_to_asset_metadata() -> void:
	var extension: GFAssetMetadataGltfDocumentExtension = GFAssetMetadataGltfDocumentExtension.new()
	var node: Node = Node.new()
	var extras: Dictionary = {
		"authoring_id": "door_01",
		"nested": {
			"locked": true,
		},
	}

	var error: Error = extension._import_node(null, null, { "extras": extras }, node)
	extras["nested"]["locked"] = false
	var metadata: Dictionary = GFVariantData.as_dictionary(node.get_meta(GFAssetMetadataUtility.META_ASSET_METADATA))
	var nested_metadata: Dictionary = GFVariantData.get_option_dictionary(metadata, "nested")

	assert_eq(error, OK)
	assert_eq(GFVariantData.get_option_string(metadata, "authoring_id"), "door_01")
	assert_eq(GFVariantData.get_option_bool(nested_metadata, "locked"), true, "导入 metadata 应深拷贝。")
	assert_eq(GFVariantData.to_text(node.get_meta(GFAssetMetadataUtility.META_ASSET_METADATA_SOURCE)), "gltf_node_extras")

	node.free()


func test_import_node_ignores_nodes_without_extras() -> void:
	var extension: GFAssetMetadataGltfDocumentExtension = GFAssetMetadataGltfDocumentExtension.new()
	var node: Node = Node.new()

	var error: Error = extension._import_node(null, null, {}, node)

	assert_eq(error, OK)
	assert_false(node.has_meta(GFAssetMetadataUtility.META_ASSET_METADATA))

	node.free()
