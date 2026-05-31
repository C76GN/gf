## 测试 GFLevelEntry 的 ID 回退与 duplicate_entry 深拷贝。
extends GutTest


func test_get_level_id_uses_exported_value() -> void:
	var entry: GFLevelEntry = GFLevelEntry.new()
	entry.level_id = &"forest_01"
	assert_eq(entry.get_level_id(), &"forest_01")


func test_duplicate_entry_copies_metadata_deeply() -> void:
	var entry: GFLevelEntry = GFLevelEntry.new()
	entry.level_id = &"a"
	entry.sort_order = 5
	entry.metadata = { "n": 1 }
	entry.unlocks_on_complete = [&"b", &"c"]
	var dup: GFLevelEntry = entry.duplicate_entry()
	dup.metadata["n"] = 99
	dup.unlocks_on_complete[0] = &"z"
	assert_eq(GFVariantData.get_option_int(entry.metadata, "n"), 1, "副本不应与原件共享 metadata。")
	assert_eq(entry.unlocks_on_complete[0], &"b", "副本不应与原件共享解锁数组引用。")
	assert_eq(dup.sort_order, 5)
	assert_eq(dup.level_id, &"a")
