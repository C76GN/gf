extends GutTest


var _audio: GFAudioUtility
var _pool: GFObjectPoolUtility


class MockAssetUtility:
	extends GFAssetUtility

	var pending: Dictionary = {}

	func load_async(path: String, on_loaded: Callable, _type_hint: String = "") -> void:
		pending[path] = on_loaded

	func finish(path: String, resource: Resource) -> void:
		if not pending.has(path):
			return

		var callback := pending[path] as Callable
		pending.erase(path)
		callback.call(resource)


class TestAudioUtility:
	extends GFAudioUtility

	var mock_asset_util: GFAssetUtility

	func _init(asset_util: GFAssetUtility) -> void:
		mock_asset_util = asset_util

	func _get_asset_util() -> GFAssetUtility:
		return mock_asset_util


class RecordingAudioUtility:
	extends TestAudioUtility

	var sfx_play_count: int = 0

	func _init(asset_util: GFAssetUtility) -> void:
		super(asset_util)

	func _play_sfx_stream(stream: AudioStream) -> AudioStreamPlayer:
		sfx_play_count += 1
		return super._play_sfx_stream(stream)


func before_each() -> void:
	var arch := GFArchitecture.new()
	Gf._architecture = arch # 提早设置引用以便可以使用 Gf 全局代理
	
	_pool = GFObjectPoolUtility.new()
	Gf.register_utility(_pool)
	
	_audio = GFAudioUtility.new()
	Gf.register_utility(_audio)
	
	await Gf.set_architecture(arch) # 正式执行三阶段初始化
	await get_tree().process_frame


func after_each() -> void:
	var arch: GFArchitecture = Gf.get_architecture()
	if arch != null:
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())
	await get_tree().process_frame


func test_play_bgm() -> void:
	var stream := AudioStreamGenerator.new()
	_audio._play_bgm_stream(stream)
	
	assert_true(_audio._bgm_player.playing, "BGM 应该正在播放。")
	assert_eq(_audio._bgm_player.stream, stream, "BGM 的 Stream 应该对应。")
	
	_audio.play_bgm("")
	assert_false(_audio._bgm_player.playing, "传入空路径应停止播放。")


func test_play_bgm_empty_path_respects_crossfade() -> void:
	var stream := AudioStreamGenerator.new()
	_audio._play_bgm_stream(stream)

	_audio.play_bgm("", 0.05)

	assert_true(_audio._bgm_player.playing, "传入淡出时间时，空路径停止 BGM 应先执行淡出。")
	await get_tree().create_timer(0.08).timeout
	assert_false(_audio._bgm_player.playing, "淡出完成后 BGM 应停止播放。")


func test_play_bgm_clip_applies_settings() -> void:
	var stream := AudioStreamGenerator.new()
	var clip := GFAudioClip.new()
	clip.stream = stream
	clip.bus_name = "Master"
	clip.volume_db = -6.0
	clip.pitch_scale = 1.25

	_audio.play_bgm_clip(clip)

	assert_eq(_audio._bgm_player.stream, stream, "BGM Clip 应写入对应音频流。")
	assert_eq(_audio._bgm_player.bus, "Master", "BGM Clip 应应用总线配置。")
	assert_almost_eq(_audio._bgm_player.volume_db, -6.0, 0.001, "BGM Clip 应应用音量配置。")
	assert_almost_eq(_audio._bgm_player.pitch_scale, 1.25, 0.001, "BGM Clip 应应用音高配置。")


func test_play_bgm_clip_tracks_history() -> void:
	var first := GFAudioClip.new()
	first.path = "res://audio/first.ogg"
	first.stream = AudioStreamGenerator.new()
	var second := GFAudioClip.new()
	second.path = "res://audio/second.ogg"
	second.stream = AudioStreamGenerator.new()

	_audio.max_bgm_history = 1
	_audio.play_bgm_clip(first)
	_audio.play_bgm_clip(second)

	var history := _audio.get_bgm_history()
	assert_eq(history.size(), 1, "BGM 历史应遵守容量上限。")
	assert_eq(history[0], "res://audio/second.ogg", "历史中应保留最新 BGM key。")
	assert_eq(_audio.get_current_bgm_key(), "res://audio/second.ogg", "当前 BGM key 应指向最新请求。")


func test_play_sfx_and_pool() -> void:
	var stream := AudioStreamGenerator.new()
	_audio._play_sfx_stream(stream)
	
	var available := _pool.get_available_count(_audio._sfx_scene)
	assert_eq(available, 0, "最初分配的播放器应该在使用中。")
	
	var players_in_root := 0
	for child: Node in _audio._root.get_children():
		if child is AudioStreamPlayer and child.get_meta("_gf_pool_active", false):
			players_in_root += 1
			child.finished.emit()
	
	assert_eq(players_in_root, 1, "应该有一个激活的 SFX 播放器。")
	assert_eq(_pool.get_available_count(_audio._sfx_scene), 1, "SFX 播放器响应 finished 后应该回收到池中。")


func test_sfx_handle_can_stop_and_release_player() -> void:
	var clip := GFAudioClip.new()
	clip.stream = AudioStreamGenerator.new()
	clip.bus_name = "Master"

	var handle := _audio.play_sfx_clip_handle(clip)

	assert_not_null(handle, "SFX 句柄应被创建。")
	assert_true(handle.is_valid(), "播放后句柄应绑定播放器。")
	assert_eq(_audio._active_sfx_players.size(), 1, "播放后应有一个活跃 SFX 播放器。")

	handle.stop()

	assert_false(handle.is_valid(), "停止后句柄应释放播放器引用。")
	assert_eq(_audio._active_sfx_players.size(), 0, "停止句柄应从活跃 SFX 列表移除播放器。")
	assert_eq(_pool.get_available_count(_audio._sfx_scene), 1, "停止句柄应把播放器归还对象池。")


func test_sfx_handle_can_bind_to_owner_exit() -> void:
	var owner_node := Node.new()
	add_child(owner_node)
	var clip := GFAudioClip.new()
	clip.stream = AudioStreamGenerator.new()
	clip.bus_name = "Master"

	var handle := _audio.play_sfx_clip_handle(clip)
	handle.bind_to_owner(owner_node)

	assert_true(handle.is_valid(), "绑定 owner 前应已经持有播放器。")
	owner_node.queue_free()
	await get_tree().process_frame

	assert_false(handle.is_valid(), "owner 退出树时句柄应自动停止并释放播放器。")
	assert_eq(_audio._active_sfx_players.size(), 0, "owner 自动停止后不应残留活跃 SFX。")
	assert_eq(_pool.get_available_count(_audio._sfx_scene), 1, "owner 自动停止后应归还对象池。")


func test_play_sfx_from_bank_applies_clip_settings() -> void:
	var stream := AudioStreamGenerator.new()
	var clip := GFAudioClip.new()
	clip.stream = stream
	clip.bus_name = "Master"
	clip.volume_db = -3.0
	clip.pitch_scale = 0.8

	var bank := GFAudioBank.new()
	bank.set_clip(&"select", clip)

	_audio.play_sfx_from_bank(bank, &"select")

	assert_eq(_audio._active_sfx_players.size(), 1, "播放 SFX Clip 后应有一个活跃播放器。")
	var player := _audio._active_sfx_players[0] as AudioStreamPlayer
	assert_eq(player.stream, stream, "SFX Clip 应写入对应音频流。")
	assert_eq(player.bus, "Master", "SFX Clip 应应用总线配置。")
	assert_almost_eq(player.volume_db, -3.0, 0.001, "SFX Clip 应应用音量配置。")
	assert_almost_eq(player.pitch_scale, 0.8, 0.001, "SFX Clip 应应用音高配置。")


func test_audio_bank_supports_variants_and_fallback() -> void:
	var first := GFAudioClip.new()
	first.stream = AudioStreamGenerator.new()
	var second := GFAudioClip.new()
	second.stream = AudioStreamGenerator.new()
	second.weight = 3.0

	var bank := GFAudioBank.new()
	var clips: Array[GFAudioClip] = [first, second]
	bank.set_clips(&"ui+select", clips)

	assert_eq(bank.get_clip(&"ui+select"), first, "兼容 get_clip 时应返回第一个有效候选。")
	assert_eq(bank.get_clips(&"ui+select").size(), 2, "同一 ID 应可保存多个候选片段。")
	assert_eq(bank.get_clip_with_fallback(&"ui+select+primary"), first, "分层 ID 缺失时应逐级回退。")


func test_audio_bank_resolution_reports_fallback_and_validation() -> void:
	var clip := GFAudioClip.new()
	clip.stream = AudioStreamGenerator.new()
	var missing_clip := GFAudioClip.new()
	var bank := GFAudioBank.new()
	bank.set_clip(&"ui+select", clip)
	bank.set_clip(&"missing", missing_clip)

	var resolution := bank.resolve_clip(&"ui+select+primary")
	var report := bank.validate_bank()

	assert_true(bool(resolution["ok"]), "解析报告应标记 fallback 命中成功。")
	assert_true(bool(resolution["fallback_used"]), "解析报告应标记使用了 fallback。")
	assert_eq(resolution["resolved_id"], &"ui+select", "解析报告应记录最终命中的 ID。")
	assert_eq(bank.get_clip_ids(), PackedStringArray(["missing", "ui+select"]), "音频集合应能列出全部片段 ID。")
	assert_eq(report.get_warning_count(), 1, "缺少 stream/path 的片段应进入校验警告。")


func test_audio_clip_resolve_pitch_without_rng_uses_base_pitch() -> void:
	var clip := GFAudioClip.new()
	clip.pitch_scale = 1.25
	clip.pitch_random_min = 0.5
	clip.pitch_random_max = 2.0

	assert_almost_eq(clip.resolve_pitch(null), 1.25, 0.001, "未传入 RNG 时应保持基础音高。")


func test_registered_audio_bank_event_uses_clip_settings() -> void:
	var stream := AudioStreamGenerator.new()
	var clip := GFAudioClip.new()
	clip.stream = stream
	clip.bus_name = "Master"
	clip.pitch_scale = 0.5
	clip.pitch_random_min = 2.0
	clip.pitch_random_max = 2.0

	var bank := GFAudioBank.new()
	bank.set_clip(&"confirm", clip)
	_audio.register_audio_bank(&"ui", bank)
	_audio.play_sfx_event(&"confirm", &"ui")

	assert_eq(_audio._active_sfx_players.size(), 1, "事件式 SFX 应复用注册的音频集合。")
	var player := _audio._active_sfx_players[0] as AudioStreamPlayer
	assert_eq(player.stream, stream, "事件式 SFX 应播放对应音频流。")
	assert_almost_eq(player.pitch_scale, 1.0, 0.001, "事件式 SFX 应应用片段音高随机范围。")


func test_audio_bank_mounter_restores_previous_bank() -> void:
	var previous_bank := GFAudioBank.new()
	var mounted_bank := GFAudioBank.new()
	_audio.register_audio_bank(&"scene", previous_bank)

	var mounter := GFAudioBankMounter.new()
	mounter.bank_id = &"scene"
	mounter.bank = mounted_bank
	mounter.set_audio_utility(_audio)

	assert_true(mounter.mount(), "挂载器应能注册音频集合。")
	assert_same(_audio.get_audio_bank(&"scene"), mounted_bank, "挂载后应使用新音频集合。")
	assert_true(mounter.unmount(), "卸载应成功。")
	assert_same(_audio.get_audio_bank(&"scene"), previous_bank, "卸载后应恢复旧音频集合。")
	mounter.free()


func test_play_sfx_clip_2d_creates_spatial_player() -> void:
	var source := Node2D.new()
	add_child_autofree(source)
	var stream := AudioStreamGenerator.new()
	var clip := GFAudioClip.new()
	clip.stream = stream
	clip.bus_name = "Master"

	var player := _audio.play_sfx_clip_2d(clip, source)

	assert_not_null(player, "2D 空间 SFX 应创建播放器。")
	assert_eq(player.stream, stream, "2D 空间 SFX 应写入对应音频流。")
	assert_eq(player.bus, "Master", "2D 空间 SFX 应应用总线配置。")
	if is_instance_valid(player):
		player.queue_free()


func test_play_sfx_clip_2d_can_follow_source() -> void:
	var source := Node2D.new()
	source.global_position = Vector2(10.0, 20.0)
	add_child_autofree(source)
	var clip := GFAudioClip.new()
	clip.stream = AudioStreamGenerator.new()
	clip.bus_name = "Master"

	var player := _audio.play_sfx_clip_2d(clip, source, true)

	assert_not_null(player, "跟随模式下仍应创建 2D 空间 SFX 播放器。")
	assert_same(player.get_parent(), source, "跟随模式下播放器应挂到声源节点下。")
	assert_eq(player.position, Vector2.ZERO, "跟随模式下播放器应使用本地零偏移。")
	source.global_position = Vector2(32.0, 48.0)
	assert_eq(player.global_position, source.global_position, "声源移动后播放器应跟随全局位置。")


func test_play_ambient_clip_uses_channel_player() -> void:
	var stream := AudioStreamGenerator.new()
	var clip := GFAudioClip.new()
	clip.stream = stream
	clip.bus_name = "Master"
	clip.volume_db = -4.0
	clip.pitch_scale = 0.9

	_audio.play_ambient_clip(clip, &"rain")

	assert_true(_audio.is_ambient_playing(&"rain"), "播放环境音后指定通道应处于播放状态。")
	var player := _audio._ambient_players[&"rain"] as AudioStreamPlayer
	assert_eq(player.stream, stream, "环境音通道应写入对应音频流。")
	assert_eq(player.bus, "Master", "环境音应应用总线配置。")
	assert_almost_eq(player.volume_db, -4.0, 0.001, "环境音应应用音量配置。")
	assert_almost_eq(player.pitch_scale, 0.9, 0.001, "环境音应应用音高配置。")

	_audio.stop_ambient(&"rain")
	assert_false(_audio.is_ambient_playing(&"rain"), "停止通道后环境音应结束。")


func test_play_bgm_ignores_stale_async_load() -> void:
	var mock_asset := MockAssetUtility.new()
	var audio := TestAudioUtility.new(mock_asset)
	audio.init()
	await get_tree().process_frame

	var first_stream := AudioStreamGenerator.new()
	var second_stream := AudioStreamGenerator.new()

	audio.play_bgm("res://audio/first.ogg")
	audio.play_bgm("res://audio/second.ogg")

	mock_asset.finish("res://audio/second.ogg", second_stream)
	assert_eq(audio._bgm_player.stream, second_stream, "后发起的 BGM 请求完成后应成为当前播放流。")

	mock_asset.finish("res://audio/first.ogg", first_stream)
	assert_eq(audio._bgm_player.stream, second_stream, "旧请求迟到返回时，不应覆盖最新的 BGM。")

	audio.dispose()
	await get_tree().process_frame


func test_play_sfx_ignores_async_load_after_dispose() -> void:
	var mock_asset := MockAssetUtility.new()
	var audio := RecordingAudioUtility.new(mock_asset)
	audio.init()
	await get_tree().process_frame

	audio.play_sfx("res://audio/sfx.ogg")
	audio.dispose()

	mock_asset.finish("res://audio/sfx.ogg", AudioStreamGenerator.new())

	assert_eq(audio.sfx_play_count, 0, "SFX 异步加载在 Utility 销毁后不应继续播放。")
	await get_tree().process_frame


func test_sfx_capacity_can_skip_new_requests() -> void:
	_audio.max_sfx_players = 1
	_audio.sfx_overflow_policy = GFAudioUtility.SFXOverflowPolicy.SKIP_NEW

	var first_stream := AudioStreamGenerator.new()
	var second_stream := AudioStreamGenerator.new()

	_audio._play_sfx_stream(first_stream)
	_audio._play_sfx_stream(second_stream)

	assert_eq(_audio._active_sfx_players.size(), 1, "SFX 达到上限后应只保留一个播放器。")
	assert_eq(_audio._active_sfx_players[0].stream, first_stream, "跳过策略不应替换正在播放的 SFX。")


func test_sfx_capacity_can_stop_oldest_request() -> void:
	_audio.max_sfx_players = 1
	_audio.sfx_overflow_policy = GFAudioUtility.SFXOverflowPolicy.STOP_OLDEST

	var first_stream := AudioStreamGenerator.new()
	var second_stream := AudioStreamGenerator.new()

	_audio._play_sfx_stream(first_stream)
	_audio._play_sfx_stream(second_stream)

	assert_eq(_audio._active_sfx_players.size(), 1, "替换策略也应遵守 SFX 数量上限。")
	assert_eq(_audio._active_sfx_players[0].stream, second_stream, "替换策略应让新的 SFX 接管播放器。")


func test_bus_volume() -> void:
	# "Master" 是默认存在的总线
	var bus_idx := AudioServer.get_bus_index("Master")
	var original_db := AudioServer.get_bus_volume_db(bus_idx)
	var original_muted := AudioServer.is_bus_mute(bus_idx)

	_audio.set_bus_volume("Master", 0.5)
	assert_almost_eq(_audio.get_bus_volume("Master"), 0.5, 0.05, "音量设置取回应该近乎一致。")

	_audio.set_bus_volume("Master", 0.0)
	assert_true(AudioServer.is_bus_mute(bus_idx), "设置 0.0 时应真正静音总线。")
	assert_eq(_audio.get_bus_volume("Master"), 0.0, "静音总线读取音量应返回 0.0。")

	AudioServer.set_bus_volume_db(bus_idx, original_db)
	AudioServer.set_bus_mute(bus_idx, original_muted)
