## 测试 GFMoveTweenAction、GFFlashAction 与 GFAudioAction 的基础行为。
extends GutTest


const GF_MOVE_TWEEN_ACTION := preload("res://addons/gf/extensions/action_queue/gf_move_tween_action.gd")
const GF_FLASH_ACTION := preload("res://addons/gf/extensions/action_queue/gf_flash_action.gd")
const GF_AUDIO_ACTION := preload("res://addons/gf/extensions/action_queue/gf_audio_action.gd")


class TestAudioUtility:
	extends GFAudioUtility

	var played_paths: Array[String] = []
	var played_clip_ids: Array[StringName] = []

	func init() -> void:
		pass

	func dispose() -> void:
		pass

	func play_sfx(path: String) -> void:
		played_paths.append(path)

	func play_sfx_from_bank(_bank: GFAudioBank, clip_id: StringName) -> void:
		played_clip_ids.append(clip_id)


func after_each() -> void:
	if Gf.has_architecture():
		var arch := Gf.get_architecture()
		if arch != null:
			arch.dispose()

	await Gf.set_architecture(GFArchitecture.new())
	await get_tree().process_frame


func test_move_tween_action_sets_position_immediately_when_duration_zero() -> void:
	var node := Node2D.new()
	add_child_autofree(node)

	var action: GFVisualAction = GF_MOVE_TWEEN_ACTION.new(node, Vector2(24.0, 32.0), 0.0)
	var result: Variant = action.execute()

	assert_null(result, "零时长移动动作应立即完成。")
	assert_eq(node.position, Vector2(24.0, 32.0), "零时长移动动作应立即写入目标位置。")


func test_move_tween_action_waits_for_tween() -> void:
	var node := Node2D.new()
	add_child_autofree(node)

	var action: GFVisualAction = GF_MOVE_TWEEN_ACTION.new(node, Vector2(10.0, 0.0), 0.01)
	var result: Variant = action.execute()

	assert_true(result is Signal, "非零时长移动动作应返回 Tween 完成信号。")
	await action.await_result_safely(result)

	assert_almost_eq(node.position.x, 10.0, 0.01, "移动 Tween 完成后应到达目标 x。")
	assert_almost_eq(node.position.y, 0.0, 0.01, "移动 Tween 完成后应到达目标 y。")


func test_move_tween_action_wait_ends_when_target_exits_tree() -> void:
	var node := Node2D.new()
	add_child(node)

	var action: GFVisualAction = GF_MOVE_TWEEN_ACTION.new(node, Vector2(100.0, 0.0), 1.0)
	var result: Variant = action.execute()
	var completed := [false]
	var wait_for_action := func() -> void:
		await action.await_result_safely(result)
		completed[0] = true

	wait_for_action.call()
	await get_tree().process_frame
	node.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(completed[0], "Tween 目标节点退出树时，等待应立即结束。")


func test_flash_action_restores_modulate() -> void:
	var item := ColorRect.new()
	item.modulate = Color(0.2, 0.4, 0.6)
	add_child_autofree(item)

	var action: GFVisualAction = GF_FLASH_ACTION.new(item, Color.RED, 0.01)
	var result: Variant = action.execute()

	assert_true(result is Signal, "闪色动作应返回 Tween 完成信号。")
	await action.await_result_safely(result)

	assert_eq(item.modulate, Color(0.2, 0.4, 0.6), "闪色动作完成后应恢复原始颜色。")


func test_audio_action_is_fire_and_forget() -> void:
	var arch := GFArchitecture.new()
	Gf._architecture = arch

	var audio := TestAudioUtility.new()
	Gf.register_utility(audio)
	await Gf.set_architecture(arch)
	await get_tree().process_frame

	var action: GFVisualAction = GF_AUDIO_ACTION.new("res://audio/hit.wav")
	var result: Variant = action.execute()

	assert_eq(action.completion_mode, GFVisualAction.CompletionMode.FIRE_AND_FORGET, "音效动作默认不阻塞队列。")
	assert_null(result, "音效动作应立即完成。")
	assert_eq(audio.played_paths, ["res://audio/hit.wav"], "音效动作应委托给 GFAudioUtility。")


func test_audio_action_can_play_bank_clip() -> void:
	var arch := GFArchitecture.new()
	Gf._architecture = arch

	var audio := TestAudioUtility.new()
	Gf.register_utility(audio)
	await Gf.set_architecture(arch)
	await get_tree().process_frame

	var action := GF_AUDIO_ACTION.new() as GFAudioAction
	action.bank = GFAudioBank.new()
	action.clip_id = &"ui_accept"
	var result: Variant = action.execute()

	assert_null(result, "音频集合动作也应立即完成。")
	assert_eq(audio.played_clip_ids, [&"ui_accept"], "音效动作应按 clip_id 委托给 GFAudioUtility。")
