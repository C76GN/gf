# addons/gf/utilities/gf_audio_utility.gd
class_name GFAudioUtility
extends GFUtility


## GFAudioUtility: 全局音频管理器。
##
## 管理 BGM 和 SFX 的播放与音量。
## 结合 GFObjectPoolUtility 构建 AudioStreamPlayer 对象池避免频繁实例化。
## 支持通过 GFAssetUtility 异步加载音频资源。


# --- 私有变量 ---

var _bgm_player: AudioStreamPlayer
var _sfx_scene: PackedScene
var _root: Node


# --- Godot 生命周期方法 ---

func init() -> void:
	# 动态创建用于池化的 SFX 播放器模版
	var player_template := AudioStreamPlayer.new()
	_sfx_scene = PackedScene.new()
	_sfx_scene.pack(player_template)
	player_template.free()
	
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "GFBGMPlayer"
	_bgm_player.bus = "BGM"
	
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		_root = tree.root
		_root.call_deferred("add_child", _bgm_player)


func dispose() -> void:
	if is_instance_valid(_bgm_player):
		_bgm_player.queue_free()
	
	# SFX 节点由 ObjectPoolUtility 管理并随其一起被清理


# --- 公共方法 ---

## 播放 BGM（背景音乐）
## @param path: 音频资源的路径
func play_bgm(path: String) -> void:
	if path.is_empty():
		if is_instance_valid(_bgm_player):
			_bgm_player.stop()
		return
		
	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(path) as AudioStream
		_play_bgm_stream(stream)
	else:
		var on_loaded := func(res: Resource) -> void:
			_play_bgm_stream(res as AudioStream)
		asset_util.load_async(path, on_loaded)


## 播放 SFX（音效），自动从池中分配播放器
## @param path: 音频资源的路径
func play_sfx(path: String) -> void:
	if path.is_empty():
		return
		
	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(path) as AudioStream
		_play_sfx_stream(stream)
	else:
		var on_loaded := func(res: Resource) -> void:
			_play_sfx_stream(res as AudioStream)
		asset_util.load_async(path, on_loaded)


## 设置音频总线音量
## @param bus_name: 总线名称，如 "Master", "BGM", "SFX"
## @param volume_linear: 线性音量 (0.0 到 1.0)
func set_bus_volume(bus_name: String, volume_linear: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		var db := linear_to_db(maxf(volume_linear, 0.0001))
		AudioServer.set_bus_volume_db(bus_idx, db)
	else:
		push_warning("[GFAudioUtility] 无法找到音轨总线: " + bus_name)


## 获取音频总线音量
## @param bus_name: 总线名称
## @return 线性音量 (0.0 到 1.0)
func get_bus_volume(bus_name: String) -> float:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return 0.0


# --- 私有辅助方法 ---

func _play_bgm_stream(stream: AudioStream) -> void:
	if stream == null or not is_instance_valid(_bgm_player):
		return
	_bgm_player.stream = stream
	_bgm_player.play()


func _play_sfx_stream(stream: AudioStream) -> void:
	if stream == null:
		return
		
	var pool := _get_pool_util()
	if pool == null:
		push_warning("[GFAudioUtility] GFObjectPoolUtility 未注册，正在略过 SFX。")
		return
		
	var player := pool.acquire(_sfx_scene, _root) as AudioStreamPlayer
	if player != null:
		player.bus = "SFX"
		player.stream = stream
		if not player.finished.is_connected(_on_sfx_finished):
			player.finished.connect(_on_sfx_finished.bind(player), CONNECT_ONE_SHOT)
		player.play()


func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	var pool := _get_pool_util()
	if pool != null:
		pool.release(player, _sfx_scene)
	else:
		player.queue_free()


func _get_asset_util() -> GFAssetUtility:
	if Gf.has_method("has_architecture") and Gf.has_architecture():
		var arch: Object = Gf.get_architecture()
		if arch != null and arch.has_method("get_utility"):
			var util: Object = arch.get_utility(GFAssetUtility)
			if util != null:
				return util as GFAssetUtility
	return null


func _get_pool_util() -> GFObjectPoolUtility:
	if Gf.has_method("has_architecture") and Gf.has_architecture():
		var arch: Object = Gf.get_architecture()
		if arch != null and arch.has_method("get_utility"):
			var util: Object = arch.get_utility(GFObjectPoolUtility)
			if util != null:
				return util as GFObjectPoolUtility
	return null
