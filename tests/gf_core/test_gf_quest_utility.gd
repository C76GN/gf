# tests/gf_core/test_gf_quest_utility.gd
extends GutTest


var _quest: GFQuestUtility


func before_each() -> void:
	var arch := GFArchitecture.new()
	Gf._architecture = arch
	_quest = GFQuestUtility.new()
	Gf.register_utility(_quest)
	await Gf.set_architecture(arch)
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


func after_each() -> void:
	var arch := Gf.get_architecture()
	if arch != null:
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())
	await get_tree().process_frame
