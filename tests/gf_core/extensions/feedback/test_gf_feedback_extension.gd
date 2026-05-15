## 测试通用反馈采样与接收器。
extends GutTest


# --- 常量 ---

const GFShakeTrackBase = preload("res://addons/gf/extensions/feedback/resources/gf_shake_track.gd")


# --- 测试方法 ---

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


func test_shake_receiver_2d_preserves_external_motion_between_samples() -> void:
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
	target.position.y += 12.0
	utility.tick(0.025)
	receiver.apply_current_sample()

	assert_almost_eq(target.position.y, 12.0, 0.001, "接收器应只撤销自身上一帧偏移，不应覆盖外部移动。")


## 验证反馈预设可以按多轨道合成采样。
func test_shake_preset_combines_tracks() -> void:
	var preset := GFShakePreset.new()
	preset.duration_seconds = 1.0
	var position_track := GFShakeTrackBase.new()
	position_track.waveform = GFShakeTrackBase.Waveform.CURVE
	position_track.position_axis = Vector3.RIGHT
	position_track.amplitude = 2.0
	position_track.wave_curve = Curve.new()
	position_track.wave_curve.add_point(Vector2(0.0, 1.0))
	position_track.wave_curve.add_point(Vector2(1.0, 1.0))
	position_track.envelope_curve = Curve.new()
	position_track.envelope_curve.add_point(Vector2(0.0, 1.0))
	position_track.envelope_curve.add_point(Vector2(1.0, 1.0))
	var rotation_track := GFShakeTrackBase.new()
	rotation_track.waveform = GFShakeTrackBase.Waveform.CURVE
	rotation_track.position_axis = Vector3.ZERO
	rotation_track.rotation_axis_degrees = Vector3(0.0, 0.0, 1.0)
	rotation_track.amplitude = 3.0
	rotation_track.wave_curve = Curve.new()
	rotation_track.wave_curve.add_point(Vector2(0.0, 1.0))
	rotation_track.wave_curve.add_point(Vector2(1.0, 1.0))
	rotation_track.envelope_curve = Curve.new()
	rotation_track.envelope_curve.add_point(Vector2(0.0, 1.0))
	rotation_track.envelope_curve.add_point(Vector2(1.0, 1.0))
	preset.tracks = [position_track, rotation_track]

	var sample := preset.sample_at_progress(0.5, 0.5)

	assert_eq((sample["position"] as Vector3).x, 2.0, "位置轨道应贡献位移。")
	assert_eq((sample["rotation_degrees"] as Vector3).z, 3.0, "旋转轨道应贡献旋转。")
