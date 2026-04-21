## 测试 GFQuestUtility 的任务推进与 simple event 清理行为。
extends GutTest


var _quest: TrackingQuestUtility


class TrackingQuestUtility extends GFQuestUtility:
	var disposed_called: bool = false
	var triggered_after_dispose: bool = false

	func dispose() -> void:
		disposed_called = true
		super.dispose()

	func _on_quest_event_triggered(payload: Variant, event_id: StringName) -> void:
		if disposed_called:
			triggered_after_dispose = true
		super._on_quest_event_triggered(payload, event_id)


func before_each() -> void:
	var arch := GFArchitecture.new()
	Gf._architecture = arch

	_quest = TrackingQuestUtility.new()
	Gf.register_utility(_quest)
	await Gf.set_architecture(arch)
	await get_tree().process_frame


func after_each() -> void:
	var arch := Gf.get_architecture()
	if arch != null:
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())
	await get_tree().process_frame


func test_quest_progress() -> void:
	_quest.start_quest(&"kill_slimes", &"enemy_died", 3)

	_quest.emit_quest_event(&"enemy_died", 1)
	var q_data: Object = _quest._quests[&"kill_slimes"]
	assert_eq(q_data.current_count, 1)
	assert_false(_quest.is_quest_completed(&"kill_slimes"))

	_quest.emit_quest_event(&"enemy_died", 2)
	assert_eq(q_data.current_count, 3)
	assert_true(_quest.is_quest_completed(&"kill_slimes"))


func test_quest_integration_with_simple_event() -> void:
	_quest.start_quest(&"collect_coins", &"money_looted", 10)

	Gf.send_simple_event(&"money_looted", 5)
	assert_eq(_quest.get_quest_progress(&"collect_coins"), 0.5)

	Gf.send_simple_event(&"money_looted", {"amount": 5})
	assert_true(_quest.is_quest_completed(&"collect_coins"))


func test_dispose_unregisters_simple_event_listener() -> void:
	_quest.start_quest(&"cleanup_listener", &"enemy_died", 1)

	var arch := Gf.get_architecture()
	arch.unregister_utility(_quest.get_script() as Script)

	assert_true(_quest.disposed_called, "注销 Utility 时应执行 dispose。")
	Gf.send_simple_event(&"enemy_died", 1)
	assert_false(_quest.triggered_after_dispose, "dispose 后不应再收到旧的 simple event 回调。")
