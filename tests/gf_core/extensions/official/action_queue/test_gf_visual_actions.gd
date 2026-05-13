## 测试 GFMoveTweenAction、GFFlashAction、GFAudioAction 与 GFTweenActionStep 的基础行为。
extends GutTest


const GF_MOVE_TWEEN_ACTION := preload("res://addons/gf/extensions/official/action_queue/actions/gf_move_tween_action.gd")
const GF_FLASH_ACTION := preload("res://addons/gf/extensions/official/action_queue/actions/gf_flash_action.gd")
const GF_AUDIO_ACTION := preload("res://addons/gf/extensions/official/action_queue/actions/gf_audio_action.gd")
const GF_CONFIGURED_TWEEN_ACTION := preload("res://addons/gf/extensions/official/action_queue/actions/gf_configured_tween_action.gd")
const GF_TWEEN_ACTION_CONFIG := preload("res://addons/gf/extensions/official/action_queue/tween/gf_tween_action_config.gd")
const GFTWEEN_ACTION_STEP := preload("res://addons/gf/extensions/official/action_queue/tween/gf_tween_action_step.gd")


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
		var arch: GFArchitecture = Gf.get_architecture()
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


func test_configured_tween_action_applies_zero_duration_steps_immediately() -> void:
	var node := Node2D.new()
	add_child_autofree(node)

	var config := GF_TWEEN_ACTION_CONFIG.new()
	config.add_property_step(^"position", Vector2(8.0, 12.0), 0.0)
	var action: GFVisualAction = config.create_action(node)
	var result: Variant = action.execute()

	assert_null(result, "零时长配置化 Tween 应立即完成。")
	assert_eq(node.position, Vector2(8.0, 12.0), "零时长配置化 Tween 应写入目标属性。")


func test_configured_tween_action_waits_for_timed_steps() -> void:
	var node := Node2D.new()
	add_child_autofree(node)

	var config := GF_TWEEN_ACTION_CONFIG.new()
	config.add_property_step(^"position", Vector2(16.0, 4.0), 0.01)
	var action: GFVisualAction = config.create_action(node)
	var result: Variant = action.execute()

	assert_true(result is Signal, "带时长的配置化 Tween 应返回完成 Signal。")
	await action.await_result_safely(result)
	assert_almost_eq(node.position.x, 16.0, 0.01, "配置化 Tween 完成后应写入 x。")
	assert_almost_eq(node.position.y, 4.0, 0.01, "配置化 Tween 完成后应写入 y。")


func test_configured_tween_action_finish_handles_infinite_loop() -> void:
	var node := Node2D.new()
	add_child_autofree(node)

	var config := GF_TWEEN_ACTION_CONFIG.new()
	config.loop_count = 0
	config.add_property_step(^"position", Vector2(16.0, 4.0), 0.1)
	var action: GFVisualAction = config.create_action(node)
	var result: Variant = action.execute()
	var completed := { "value": false }
	var wait_for_action := func() -> void:
		await action.await_result_safely(result)
		completed.value = true

	wait_for_action.call()
	await get_tree().process_frame
	action.finish()
	await get_tree().process_frame

	assert_true(completed.value, "无限循环 Tween 的 finish 不应卡住等待。")


func test_gf_action_factories_create_common_actions() -> void:
	var node := Node2D.new()
	add_child_autofree(node)
	node.position = Vector2(3.0, 4.0)

	var move_action := GFAction.move_by(node, Vector2(2.0, 5.0), 0.0)
	assert_true(move_action is GFConfiguredTweenAction, "move_by 应创建配置化相对 Tween。")
	assert_null(move_action.execute())
	assert_eq(node.position, Vector2(5.0, 9.0), "零时长 move_by 应立即应用相对偏移。")

	var call_state := { "count": 0 }
	var call_action := GFAction.callback(func(amount: int) -> void:
		call_state.count += amount
	, [3])
	call_action.execute()
	assert_eq(call_state.count, 3, "callback 动作应执行回调并传递参数。")

	var group := GFAction.sequence([call_action] as Array[GFVisualAction])
	assert_false(group.is_parallel, "sequence 工厂应创建顺序动作组。")
	assert_true(GFAction.parallel([call_action] as Array[GFVisualAction]).is_parallel, "parallel 工厂应创建并行动作组。")


func test_wait_action_can_finish_early() -> void:
	var action := GFAction.wait(1.0, self)
	var result: Variant = action.execute()
	var completed := { "value": false }
	var wait_for_action := func() -> void:
		await action.await_result_safely(result)
		completed.value = true

	wait_for_action.call()
	await get_tree().process_frame
	action.finish()
	await get_tree().process_frame

	assert_true(completed.value, "finish 应提前完成等待动作。")


func test_repeat_action_creates_fresh_action_each_iteration() -> void:
	var order: Array[int] = []
	var repeat := GFAction.repeat(func() -> GFVisualAction:
		return GFAction.callback(func() -> void:
			order.append(order.size())
		)
	, 3)
	var result: Variant = repeat.execute()
	await repeat.await_result_safely(result)

	assert_eq(order, [0, 1, 2], "repeat 应按次数执行工厂创建的动作。")


func test_tween_action_step_apply_instant_relative_vector2() -> void:
	var node := Node2D.new()
	add_child_autofree(node)
	node.position = Vector2(10.0, 20.0)
	var step := GFTWEEN_ACTION_STEP.new() as GFTweenActionStep
	step.property_name = ^"position"
	step.target_value = Vector2(1.0, 2.0)
	step.as_relative = true
	step.apply_instant(node)
	assert_eq(node.position, Vector2(11.0, 22.0), "相对 Vector2 应与当前位置相加。")


func test_tween_action_step_apply_instant_relative_rotation_scalar() -> void:
	var node := Node2D.new()
	add_child_autofree(node)
	node.rotation = 1.0
	var step := GFTWEEN_ACTION_STEP.new() as GFTweenActionStep
	step.property_name = ^"rotation"
	step.target_value = 0.5
	step.as_relative = true
	step.apply_instant(node)
	assert_almost_eq(node.rotation, 1.5, 0.0001, "相对浮点属性应与当前值相加。")


func test_tween_action_step_duplicate_step_preserves_exported_fields() -> void:
	var step := GFTWEEN_ACTION_STEP.new() as GFTweenActionStep
	step.property_name = ^"modulate"
	step.target_value = Color.RED
	step.duration = 0.5
	step.delay = 0.1
	step.as_relative = true
	step.parallel = true
	step.transition_type = Tween.TRANS_LINEAR
	step.ease_type = Tween.EASE_IN_OUT
	var dup := step.duplicate_step()
	assert_ne(dup, step, "duplicate_step 应创建新 Resource。")
	assert_eq(dup.property_name, step.property_name)
	assert_eq(dup.target_value, step.target_value)
	assert_eq(dup.duration, 0.5)
	assert_eq(dup.delay, 0.1)
	assert_true(dup.as_relative)
	assert_true(dup.parallel)
	assert_eq(dup.transition_type, Tween.TRANS_LINEAR)
	assert_eq(dup.ease_type, Tween.EASE_IN_OUT)


func test_tween_action_step_rejects_relative_type_mismatch() -> void:
	var node := Node2D.new()
	add_child_autofree(node)
	var step := GFTWEEN_ACTION_STEP.new() as GFTweenActionStep
	step.property_name = ^"position"
	step.target_value = 5
	step.as_relative = true
	assert_false(step.can_apply_to(node), "position 为 Vector2 时不应与标量 target 做相对相加。")
	assert_true(
		step.get_validation_error(node).contains("Relative"),
		"校验错误应提示相对值类型不兼容。"
	)


func test_tween_action_step_append_to_tween_returns_null_for_null_tween() -> void:
	var node := Node2D.new()
	add_child_autofree(node)
	var step := GFTWEEN_ACTION_STEP.new() as GFTweenActionStep
	step.property_name = ^"position"
	step.target_value = Vector2.ZERO
	assert_null(step.append_to_tween(null, node), "Tween 为 null 时应安全返回 null。")


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
