## 测试 GFAssetMetadataRecord 的复制与字典转换。
extends GutTest


func test_record_duplicates_metadata() -> void:
	var record := GFAssetMetadataRecord.new()
	record.configure("res://assets/tree.glb", NodePath("Root/Branch"), &"node", {
		"nested": {
			"hp": 3,
		},
	})

	var duplicated_record := record.duplicate_record()
	(duplicated_record.metadata["nested"] as Dictionary)["hp"] = 9

	assert_eq((record.metadata["nested"] as Dictionary).get("hp"), 3, "记录副本不应共享嵌套 metadata。")
	assert_eq(duplicated_record.source_path, "res://assets/tree.glb")
	assert_eq(duplicated_record.subject_path, NodePath("Root/Branch"))
	assert_eq(duplicated_record.subject_kind, &"node")


func test_get_value_supports_string_name_and_string_keys() -> void:
	var record := GFAssetMetadataRecord.new()
	record.metadata = {
		"group": "environment",
		&"tags": ["forest"],
	}

	var tags := record.get_value(&"tags") as Array
	tags.append("changed")

	assert_true(record.has_value(&"group"), "StringName 查询应能读取 String 键。")
	assert_eq(record.get_value(&"group"), "environment")
	assert_eq((record.metadata[&"tags"] as Array).size(), 1, "读取集合值时应返回副本。")


func test_apply_dict_ignores_non_dictionary_metadata() -> void:
	var record := GFAssetMetadataRecord.new()
	record.apply_dict({
		"source_path": "res://asset.glb",
		"subject_path": "Node",
		"subject_kind": "node",
		"metadata": "bad",
	})

	assert_eq(record.source_path, "res://asset.glb")
	assert_eq(record.subject_path, NodePath("Node"))
	assert_eq(record.subject_kind, &"node")
	assert_true(record.metadata.is_empty(), "非 Dictionary metadata 不应进入记录。")
