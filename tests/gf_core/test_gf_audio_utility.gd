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

	func _play_sfx_stream(stream: AudioStream) -> void:
		sfx_play_count += 1
		super._play_sfx_stream(stream)


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
	var arch := Gf.get_architecture()
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
	_audio.set_bus_volume("Master", 0.5)
	assert_almost_eq(_audio.get_bus_volume("Master"), 0.5, 0.05, "音量设置取回应该近乎一致。")
