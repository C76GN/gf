## 测试 GFAssetMetadataGltfDocumentExtension 的 glTF extras 桥接。
extends GutTest


func test_import_node_copies_gltf_extras_to_asset_metadata() -> void:
	var extension := GFAssetMetadataGltfDocumentExtension.new()
	var node := Node.new()
	var extras := {
		"authoring_id": "door_01",
		"nested": {
			"locked": true,
		},
	}

	var error := extension._import_node(null, null, { "extras": extras }, node)
	extras["nested"]["locked"] = false
	var metadata := node.get_meta(GFAssetMetadataUtility.META_ASSET_METADATA) as Dictionary

	assert_eq(error, OK)
	assert_eq(metadata.get("authoring_id"), "door_01")
	assert_eq((metadata["nested"] as Dictionary).get("locked"), true, "导入 metadata 应深拷贝。")
	assert_eq(node.get_meta(GFAssetMetadataUtility.META_ASSET_METADATA_SOURCE), "gltf_node_extras")

	node.free()


func test_import_node_ignores_nodes_without_extras() -> void:
	var extension := GFAssetMetadataGltfDocumentExtension.new()
	var node := Node.new()

	var error := extension._import_node(null, null, {}, node)

	assert_eq(error, OK)
	assert_false(node.has_meta(GFAssetMetadataUtility.META_ASSET_METADATA))

	node.free()
