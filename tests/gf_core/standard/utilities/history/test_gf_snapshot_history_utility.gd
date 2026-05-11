## 测试 GFSnapshotHistoryUtility 的通用快照历史与恢复行为。
extends GutTest


# --- 内部类 ---

class SnapshotModel:
	extends GFModel

	var value: int = 0

	func get_save_key() -> StringName:
		return &"snapshot_history_model"

	func to_dict() -> Dictionary:
		return { "value": value }

	func from_dict(data: Dictionary) -> void:
		value = int(data.get("value", 0))


# --- 测试方法 ---

## 验证自定义捕获/恢复回调可前后移动，并在新快照写入时裁剪未来分支。
func test_custom_callbacks_step_and_prune_future_branch() -> void:
	var state := { "value": 1 }
	var history := GFSnapshotHistoryUtility.new()
	var capture_callback: Callable = func() -> Dictionary:
		return state.duplicate(true)
	var restore_callback: Callable = func(data: Variant) -> void:
		_replace_dictionary_contents(state, data as Dictionary)
	history.configure(capture_callback, restore_callback)

	var first_id := history.capture({ "label": "first" })
	state["value"] = 2
	var second_id := history.capture({ "label": "second" })

	assert_true(history.step_back(), "应可恢复到上一份快照。")
	assert_eq(state["value"], 1, "step_back 应恢复旧状态。")

	state["value"] = 3
	var third_id := history.capture({ "label": "third" })
	var ids := history.get_debug_snapshot()["ids"] as PackedInt32Array

	assert_eq(first_id, 1, "首个快照 ID 应从 1 开始。")
	assert_eq(second_id, 2, "第二个快照 ID 应递增。")
	assert_eq(third_id, 3, "裁剪未来分支后也应继续递增 ID。")
	assert_eq(ids, PackedInt32Array([1, 3]), "新快照应裁剪当前位置之后的未来分支。")
	assert_false(history.restore_snapshot_id(second_id), "被裁剪的快照不应再可恢复。")


## 验证历史上限会保留最新快照，并维持有效当前索引。
func test_max_history_size_trims_old_snapshots_and_keeps_index_valid() -> void:
	var history := GFSnapshotHistoryUtility.new()
	var restored := {}
	var restore_callback: Callable = func(data: Variant) -> void:
		_replace_dictionary_contents(restored, data as Dictionary)
	history.configure(Callable(), restore_callback)
	history.max_history_size = 2

	history.push_snapshot({ "value": 1 })
	history.push_snapshot({ "value": 2 })
	history.push_snapshot({ "value": 3 })

	var ids := history.get_debug_snapshot()["ids"] as PackedInt32Array
	assert_eq(ids, PackedInt32Array([2, 3]), "超过上限时应丢弃最旧快照。")
	assert_eq(history.current_index, 1, "当前索引应指向最新保留快照。")

	assert_true(history.step_back(), "裁剪后仍应可恢复上一份保留快照。")
	assert_eq(restored["value"], 2, "step_back 应恢复到上一份保留快照。")
	history.max_history_size = 1

	var snapshot := history.get_current_snapshot()
	assert_eq(history.current_index, 0, "进一步裁剪后当前索引仍应有效。")
	assert_eq(snapshot["data"]["value"], 3, "当前被裁掉时应收敛到剩余快照。")


## 验证快照记录和读取结果都执行深拷贝。
func test_snapshots_are_deep_copied() -> void:
	var history := GFSnapshotHistoryUtility.new()
	var source := {
		"items": [1, 2],
	}
	var metadata := {
		"tags": ["a"],
	}

	history.push_snapshot(source, metadata)
	source["items"].append(3)
	metadata["tags"].append("b")

	var snapshot := history.get_current_snapshot()
	snapshot["data"]["items"].append(4)
	snapshot["metadata"]["tags"].append("c")

	var stored_snapshot := history.get_current_snapshot()
	assert_eq(stored_snapshot["data"]["items"], [1, 2], "原始数据和外部返回值都不应污染内部快照。")
	assert_eq(stored_snapshot["metadata"]["tags"], ["a"], "元数据也应深拷贝。")


## 验证恢复回调返回 false 时不会移动当前索引。
func test_restore_callback_can_reject_restore() -> void:
	var history := GFSnapshotHistoryUtility.new()
	var restore_callback: Callable = func(_data: Variant) -> bool:
		return false
	history.configure(Callable(), restore_callback)

	history.push_snapshot({ "value": 1 })
	history.push_snapshot({ "value": 2 })

	assert_false(history.restore_index(0), "恢复回调返回 false 时应报告恢复失败。")
	assert_eq(history.current_index, 1, "恢复失败不应移动当前索引。")


## 验证 configure 会忽略错误类型的可选回调，并钳制历史上限。
func test_configure_ignores_invalid_optional_callable() -> void:
	var state := { "value": 1 }
	var history := GFSnapshotHistoryUtility.new()
	var capture_callback: Callable = func() -> Dictionary:
		return state.duplicate(true)
	var restore_callback: Callable = func(data: Variant) -> void:
		_replace_dictionary_contents(state, data as Dictionary)

	history.configure(capture_callback, restore_callback, {
		"max_history_size": -10,
		"restore_command_builder": "not_callable",
	})

	assert_eq(history.max_history_size, 0, "负数历史上限应钳制为 0，表示不限制。")
	assert_ne(history.capture(), 0, "错误类型的可选回调不应阻止捕获。")
	state["value"] = 2
	assert_true(history.restore_index(0), "错误类型的可选回调不应阻止自定义恢复。")
	assert_eq(state["value"], 1, "自定义恢复回调仍应正常执行。")


## 验证默认捕获/恢复路径会使用注入架构的全局快照。
func test_default_capture_uses_injected_architecture_snapshot() -> void:
	var arch := GFArchitecture.new()
	var model := SnapshotModel.new()
	var history := GFSnapshotHistoryUtility.new()

	await arch.register_model_instance(model)
	await arch.register_utility_instance(history)

	model.value = 10
	history.capture()
	model.value = 20
	history.capture()

	assert_true(history.step_back(), "默认恢复路径应可还原架构全局快照。")
	assert_eq(model.value, 10, "Model 状态应通过架构快照恢复。")

	arch.dispose()


# --- 私有/辅助方法 ---

func _replace_dictionary_contents(target: Dictionary, source: Dictionary) -> void:
	target.clear()
	for key: Variant in source.keys():
		target[key] = source[key]
