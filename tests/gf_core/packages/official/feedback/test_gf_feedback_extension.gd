## 测试通用反馈采样与接收器。
extends GutTest


## 验证反馈工具可播放、采样并在持续时间结束后清理。
func test_shake_utility_samples_and_finishes() -> void:
	var utility := GFShakeUtility.new()
	utility.init()
	utility.randomize_phase = false

	var preset := GFShakePreset.new()
	preset.duration_seconds = 0.1
	preset.frequency = 10.0
	preset.waveform = GFShakePreset.Waveform.SINE
	preset.position_axis = Vector3.RIGHT

	var shake_id := utility.play_shake(&"camera", preset)
	utility.tick(0.025)
	var sample := utility.sample_channel(&"camera")

	assert_true(utility.is_shake_active(shake_id), "播放后反馈实例应处于活跃状态。")
	assert_gt(absf((sample["position"] as Vector3).x), 0.5, "采样应产生位移偏移。")

	utility.tick(0.2)

	assert_false(utility.is_shake_active(shake_id), "超过持续时间后反馈实例应自动结束。")


## 验证 2D 接收器能把 channel 采样应用到目标节点。
func test_shake_receiver_2d_applies_sample_to_target() -> void:
	var utility := GFShakeUtility.new()
	utility.init()
	utility.randomize_phase = false

	var preset := GFShakePreset.new()
	preset.duration_seconds = 0.2
	preset.frequency = 10.0
	preset.waveform = GFShakePreset.Waveform.SINE
	preset.position_axis = Vector3.RIGHT

	var target := Node2D.new()
	var receiver := GFShakeReceiver2D.new()
	receiver.utility = utility
	target.add_child(receiver)
	add_child_autofree(target)
	await get_tree().process_frame

	utility.play_shake(&"default", preset)
	utility.tick(0.025)
	receiver.apply_current_sample()

	assert_gt(target.position.x, 0.5, "接收器应把采样位移叠加到目标节点。")


## 验证反馈动作可通过架构注入使用反馈工具。
func test_shake_action_uses_registered_utility() -> void:
	var architecture := GFArchitecture.new()
	var utility := GFShakeUtility.new()
	await architecture.register_utility_instance(utility)
	await architecture.init()

	var preset := GFShakePreset.new()
	preset.duration_seconds = 0.1
	var action := GFShakeAction.new(preset, &"fx")
	action.inject_dependencies(architecture)
	action.execute()

	assert_eq(utility.get_active_shake_count(&"fx"), 1, "反馈动作应在指定 channel 播放预设。")

	architecture.dispose()
