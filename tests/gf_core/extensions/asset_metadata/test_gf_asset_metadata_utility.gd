## 测试 GFAssetMetadataUtility 的对象读写和节点树收集。
extends GutTest


func test_write_and_read_object_metadata_use_safe_copies() -> void:
	var utility := GFAssetMetadataUtility.new()
	var node := Node.new()
	var source_metadata := {
		"nested": {
			"value": 1,
		},
	}

	var record := utility.write_object_metadata(node, source_metadata, {
		"source_path": "res://assets/item.glb",
		"subject_path": "Item",
		"subject_kind": &"node",
		"metadata_source": "test",
	})
	source_metadata["nested"]["value"] = 9
	var read_metadata := utility.read_object_metadata(node)
	(read_metadata["nested"] as Dictionary)["value"] = 7

	assert_true(utility.has_object_metadata(node), "写入后对象应带有资产元数据。")
	assert_eq((node.get_meta(GFAssetMetadataUtility.META_ASSET_METADATA) as Dictionary)["nested"]["value"], 1, "对象 metadata 应保存输入副本。")
	assert_eq(record.source_path, "res://assets/item.glb")
	assert_eq(record.subject_path, NodePath("Item"))
	assert_eq(record.subject_kind, &"node")
	assert_eq(node.get_meta(GFAssetMetadataUtility.META_ASSET_METADATA_SOURCE), "test")

	node.free()


func test_collect_node_tree_returns_relative_paths() -> void:
	var utility := GFAssetMetadataUtility.new()
	var root := Node.new()
	root.name = "Root"
	var branch := Node.new()
	branch.name = "Branch"
	var leaf := Node.new()
	leaf.name = "Leaf"
	root.add_child(branch)
	branch.add_child(leaf)
	utility.write_object_metadata(root, { "root": true })
	utility.write_object_metadata(leaf, { "leaf": true })

	var records := utility.collect_node_tree(root, {
		"source_path": "res://assets/tree.glb",
	})

	assert_eq(records.size(), 2, "应收集根节点和子节点元数据。")
	assert_eq(records[0].source_path, "res://assets/tree.glb")
	assert_eq(records[0].subject_path, NodePath("."))
	assert_eq(records[1].subject_path, NodePath("Branch/Leaf"))
	assert_eq(records[1].metadata.get("leaf"), true)

	root.free()


func test_collect_node_tree_respects_custom_keys_and_depth() -> void:
	var utility := GFAssetMetadataUtility.new()
	var root := Node.new()
	var child := Node.new()
	root.add_child(child)
	child.set_meta(&"custom_metadata", {
		"kind": "child",
	})

	var no_depth_records := utility.collect_node_tree(root, {
		"metadata_keys": [&"custom_metadata"],
		"max_depth": 0,
	})
	var records := utility.collect_node_tree(root, {
		"metadata_keys": [&"custom_metadata"],
		"max_depth": 1,
	})

	assert_true(no_depth_records.is_empty(), "max_depth 为 0 时不应进入子节点。")
	assert_eq(records.size(), 1, "自定义 metadata key 应可被收集。")
	assert_eq(records[0].metadata.get("kind"), "child")

	root.free()


func test_build_node_tree_report_reports_missing_root() -> void:
	var utility := GFAssetMetadataUtility.new()
	var report := utility.build_node_tree_report(null)

	assert_false(bool(report.get("ok")), "缺少 root 时报告应失败。")
	assert_eq(int(report.get("error_count", 0)), 1)
	assert_eq(String(((report.get("issues", []) as Array)[0] as Dictionary).get("kind", "")), "missing_root")


func test_extension_installer_registers_asset_metadata_utility() -> void:
	var architecture := GFArchitecture.new()
	var installer_script := load("res://addons/gf/extensions/asset_metadata/extension.gd") as Script
	var installer := installer_script.new() as GFInstaller

	installer.install(architecture)

	assert_not_null(
		architecture.get_local_utility(GFAssetMetadataUtility),
		"Asset Metadata installer 应注册 GFAssetMetadataUtility。"
	)
