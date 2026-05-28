## 测试 GFSaveSlotWorkflow 的槽位标识、元数据/卡片构建与存储摘要索引。
extends GutTest


var _storage: GFStorageUtility


func before_each() -> void:
	_storage = GFStorageUtility.new()
	_storage.save_dir_name = "test_workflow_slot_build"
	_storage.init()


func after_each() -> void:
	if _storage != null:
		for i in range(8):
			_storage.delete_slot(i)
		_storage = null


func test_get_slot_id_for_index_replaces_template() -> void:
	var wf := GFSaveSlotWorkflow.new()
	assert_eq(wf.active_slot_index, 0)
	wf.slot_id_template = "save_{index}_data"
	assert_eq(wf.get_slot_id_for_index(3), &"save_3_data")


func test_slot_id_override_and_clear() -> void:
	var wf := GFSaveSlotWorkflow.new()
	wf.set_slot_id_override(2, &"cloud_a")
	assert_eq(wf.get_slot_id_for_index(2), &"cloud_a")
	wf.set_slot_id_override(2, &"")
	assert_eq(wf.get_slot_id_for_index(2), &"slot_2")
	wf.set_slot_id_override(1, &"x")
	wf.clear_slot_id_overrides()
	assert_eq(wf.get_slot_id_for_index(1), &"slot_1")


func test_select_slot_index_clamps_negative() -> void:
	var wf := GFSaveSlotWorkflow.new()
	wf.select_slot_index(-3)
	assert_eq(wf.active_slot_index, 0)


func test_build_slot_metadata_injects_slot_role() -> void:
	var wf := GFSaveSlotWorkflow.new()
	wf.slot_role = &"manual"
	var meta := wf.build_slot_metadata(1, "标题", { "k": 1 })
	assert_eq(meta.slot_id, &"slot_1")
	assert_eq(meta.display_name, "标题")
	assert_eq(meta.custom_metadata.get("k"), 1)
	assert_eq(meta.custom_metadata.get("slot_role"), &"manual")


func test_build_empty_card_marks_active_slot() -> void:
	var wf := GFSaveSlotWorkflow.new()
	wf.active_slot_index = 2
	var card := wf.build_empty_card(2)
	assert_true(card.is_empty)
	assert_true(card.is_active)
	assert_eq(card.slot_index, 2)


func test_empty_display_name_template_is_opt_in() -> void:
	var wf := GFSaveSlotWorkflow.new()
	var default_card := wf.build_empty_card(2)
	var default_metadata := wf.build_slot_metadata(2)

	assert_eq(wf.get_empty_display_name_for_index(2), "")
	assert_eq(default_card.display_name, "")
	assert_eq(default_metadata.display_name, "")

	wf.empty_display_name_template = "Slot {index}"
	assert_eq(wf.get_empty_display_name_for_index(2), "Slot 2")
	assert_eq(wf.build_empty_card(2).display_name, "Slot 2")


func test_build_card_for_index_empty_summary_returns_empty_card() -> void:
	var wf := GFSaveSlotWorkflow.new()
	var card := wf.build_card_for_index(1, {})
	assert_true(card.is_empty)


func test_build_cards_for_indices_matches_summary_by_index() -> void:
	var wf := GFSaveSlotWorkflow.new()
	var summaries: Array = [
		{ "slot_index": 1, "metadata": { "display_name": "A" }, "is_compatible": true },
	]
	var cards := wf.build_cards_for_indices([1, 2], summaries)
	assert_eq(cards.size(), 2)
	assert_false(cards[0].is_empty)
	assert_eq(cards[0].display_name, "A")
	assert_true(cards[1].is_empty)


func test_build_cards_from_storage_null_returns_empty() -> void:
	var wf := GFSaveSlotWorkflow.new()
	assert_eq(wf.build_cards_from_storage(null).size(), 0)


func test_build_cards_from_storage_collects_indices() -> void:
	assert_eq(_storage.save_slot(1, { "hp": 1 }, { "slot_id": "1", "display_name": "存档一" }), OK)
	var wf := GFSaveSlotWorkflow.new()
	var cards := wf.build_cards_from_storage(_storage, [])
	assert_eq(cards.size(), 1)
	assert_false(cards[0].is_empty)
	assert_eq(cards[0].display_name, "存档一")


func test_parse_slot_index_from_custom_template_id() -> void:
	var wf := GFSaveSlotWorkflow.new()
	wf.slot_id_template = "save_{index}_data"
	var summaries: Array = [{ "slot_id": "save_4_data", "metadata": {}, "is_compatible": true }]
	var cards := wf.build_cards_for_indices([4], summaries)
	assert_false(cards[0].is_empty)
