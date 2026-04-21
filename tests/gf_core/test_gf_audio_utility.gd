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


func test_bus_volume() -> void:
	# "Master" 是默认存在的总线
	_audio.set_bus_volume("Master", 0.5)
	assert_almost_eq(_audio.get_bus_volume("Master"), 0.5, 0.05, "音量设置取回应该近乎一致。")
