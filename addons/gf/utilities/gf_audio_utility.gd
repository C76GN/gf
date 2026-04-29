## GFAudioUtility: 全局音频管理器。
##
## 管理 BGM 和 SFX 的播放与音量。
## 结合 GFObjectPoolUtility 构建 AudioStreamPlayer 对象池避免频繁实例化。
## 支持通过 GFAssetUtility 异步加载音频资源。
class_name GFAudioUtility
extends GFUtility


# --- 常量 ---

## 默认 BGM 音频总线名。
const BGM_BUS_NAME: String = "BGM"

## 默认 SFX 音频总线名。
const SFX_BUS_NAME: String = "SFX"

const _FALLBACK_BUS_NAME: String = "Master"


# --- 枚举 ---

## SFX 超出并发上限时的处理策略。
enum SFXOverflowPolicy {
	## 跳过新的 SFX 请求。
	SKIP_NEW,
	## 停止最早播放的 SFX，并播放新的请求。
	STOP_OLDEST,
}


# --- 公共变量 ---

## 同时播放的 SFX 数量上限；小于等于 0 表示不限制。
var max_sfx_players: int = 32

## SFX 超出并发上限时采用的处理策略。
var sfx_overflow_policy: SFXOverflowPolicy = SFXOverflowPolicy.SKIP_NEW


# --- 私有变量 ---

var _bgm_player: AudioStreamPlayer
var _sfx_scene: PackedScene
var _root: Node
var _bgm_request_serial: int = 0
var _sfx_lifecycle_serial: int = 0
var _missing_bus_warnings: Dictionary = {}
var _active_sfx_players: Array[AudioStreamPlayer] = []


# --- Godot 生命周期方法 ---

func init() -> void:
	_bgm_request_serial = 0
	_sfx_lifecycle_serial += 1
	_missing_bus_warnings.clear()
	_active_sfx_players.clear()
	# 动态创建用于池化的 SFX 播放器模版
	var player_template := AudioStreamPlayer.new()
	_sfx_scene = PackedScene.new()
	_sfx_scene.pack(player_template)
	player_template.free()
	
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "GFBGMPlayer"
	_bgm_player.bus = _resolve_bus_name(BGM_BUS_NAME)
	
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		_root = tree.root
		_root.call_deferred("add_child", _bgm_player)


func dispose() -> void:
	_bgm_request_serial += 1
	_sfx_lifecycle_serial += 1
	_release_all_sfx_players()
	if is_instance_valid(_bgm_player):
		_bgm_player.queue_free()
	_root = null
	
	# SFX 节点由 ObjectPoolUtility 管理并随其一起被清理


# --- 公共方法 ---

## 播放 BGM（背景音乐）
## @param path: 音频资源的路径
func play_bgm(path: String) -> void:
	_bgm_request_serial += 1
	var request_serial := _bgm_request_serial
	if path.is_empty():
		stop_bgm()
		return
		
	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(path) as AudioStream
		_apply_bgm_request(request_serial, stream)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_bgm_request(request_serial, res as AudioStream)
		asset_util.load_async(path, on_loaded)


## 播放资源化 BGM 配置。
## @param clip: 音频片段配置。
func play_bgm_clip(clip: GFAudioClip) -> void:
	if clip == null or not clip.has_source():
		return

	_bgm_request_serial += 1
	var request_serial := _bgm_request_serial
	var bus_name := clip.resolve_bus(BGM_BUS_NAME)
	var volume_db := clip.volume_db
	var pitch_scale := clip.pitch_scale

	if clip.stream != null:
		_apply_bgm_request_with_settings(request_serial, clip.stream, bus_name, volume_db, pitch_scale)
		return

	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(clip.path) as AudioStream
		_apply_bgm_request_with_settings(request_serial, stream, bus_name, volume_db, pitch_scale)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_bgm_request_with_settings(
				request_serial,
				res as AudioStream,
				bus_name,
				volume_db,
				pitch_scale
			)
		asset_util.load_async(clip.path, on_loaded)


## 从音频集合播放 BGM。
## @param bank: 音频集合。
## @param clip_id: 片段标识。
func play_bgm_from_bank(bank: GFAudioBank, clip_id: StringName) -> void:
	if bank == null:
		return

	play_bgm_clip(bank.get_clip(clip_id))


## 停止当前 BGM。
func stop_bgm() -> void:
	if is_instance_valid(_bgm_player):
		_bgm_player.stop()


## 播放 SFX（音效），自动从池中分配播放器
## @param path: 音频资源的路径
func play_sfx(path: String) -> void:
	if path.is_empty():
		return

	var request_serial := _sfx_lifecycle_serial
	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(path) as AudioStream
		_apply_sfx_request(request_serial, stream)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_sfx_request(request_serial, res as AudioStream)
		asset_util.load_async(path, on_loaded)


## 播放资源化 SFX 配置。
## @param clip: 音频片段配置。
func play_sfx_clip(clip: GFAudioClip) -> void:
	if clip == null or not clip.has_source():
		return

	var request_serial := _sfx_lifecycle_serial
	var bus_name := clip.resolve_bus(SFX_BUS_NAME)
	var volume_db := clip.volume_db
	var pitch_scale := clip.pitch_scale

	if clip.stream != null:
		_apply_sfx_request_with_settings(request_serial, clip.stream, bus_name, volume_db, pitch_scale)
		return

	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(clip.path) as AudioStream
		_apply_sfx_request_with_settings(request_serial, stream, bus_name, volume_db, pitch_scale)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_sfx_request_with_settings(
				request_serial,
				res as AudioStream,
				bus_name,
				volume_db,
				pitch_scale
			)
		asset_util.load_async(clip.path, on_loaded)


## 从音频集合播放 SFX。
## @param bank: 音频集合。
## @param clip_id: 片段标识。
func play_sfx_from_bank(bank: GFAudioBank, clip_id: StringName) -> void:
	if bank == null:
		return

	play_sfx_clip(bank.get_clip(clip_id))


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
	_play_bgm_stream_with_settings(stream, BGM_BUS_NAME, 0.0, 1.0)


func _play_bgm_stream_with_settings(
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float
) -> void:
	if stream == null or not is_instance_valid(_bgm_player):
		return
	_bgm_player.bus = _resolve_bus_name(bus_name)
	_bgm_player.volume_db = volume_db
	_bgm_player.pitch_scale = pitch_scale
	_bgm_player.stream = stream
	_bgm_player.play()


func _apply_bgm_request(request_serial: int, stream: AudioStream) -> void:
	if request_serial != _bgm_request_serial:
		return

	_play_bgm_stream(stream)


func _apply_bgm_request_with_settings(
	request_serial: int,
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float
) -> void:
	if request_serial != _bgm_request_serial:
		return

	_play_bgm_stream_with_settings(stream, bus_name, volume_db, pitch_scale)


func _apply_sfx_request(request_serial: int, stream: AudioStream) -> void:
	if request_serial != _sfx_lifecycle_serial:
		return

	_play_sfx_stream(stream)


func _apply_sfx_request_with_settings(
	request_serial: int,
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float
) -> void:
	if request_serial != _sfx_lifecycle_serial:
		return

	_play_sfx_stream_with_settings(stream, bus_name, volume_db, pitch_scale)


func _play_sfx_stream(stream: AudioStream) -> void:
	_play_sfx_stream_with_settings(stream, SFX_BUS_NAME, 0.0, 1.0)


func _play_sfx_stream_with_settings(
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float
) -> void:
	if stream == null or not is_instance_valid(_root):
		return
		
	var pool := _get_pool_util()
	if pool == null:
		push_warning("[GFAudioUtility] GFObjectPoolUtility 未注册，正在略过 SFX。")
		return

	if _is_sfx_capacity_full():
		if sfx_overflow_policy == SFXOverflowPolicy.STOP_OLDEST:
			_stop_oldest_sfx()
		else:
			return
		
	var player := pool.acquire(_sfx_scene, _root) as AudioStreamPlayer
	if player != null:
		player.bus = _resolve_bus_name(bus_name)
		player.volume_db = volume_db
		player.pitch_scale = pitch_scale
		player.stream = stream
		var finished_callback := _get_sfx_finished_callback(player)
		if not player.finished.is_connected(finished_callback):
			player.finished.connect(finished_callback, CONNECT_ONE_SHOT)
		_track_sfx_player(player)
		player.play()


func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	_untrack_sfx_player(player)
	var pool := _get_pool_util()
	if pool != null:
		pool.release(player, _sfx_scene)
	else:
		player.queue_free()


func _get_asset_util() -> GFAssetUtility:
	var arch: Object = _get_architecture_or_null()
	if arch != null and arch.has_method("get_utility"):
		var util: Object = arch.get_utility(GFAssetUtility)
		if util != null:
			return util as GFAssetUtility
	return null


func _get_pool_util() -> GFObjectPoolUtility:
	var arch: Object = _get_architecture_or_null()
	if arch != null and arch.has_method("get_utility"):
		var util: Object = arch.get_utility(GFObjectPoolUtility)
		if util != null:
			return util as GFObjectPoolUtility
	return null


func _resolve_bus_name(bus_name: String) -> String:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return bus_name

	if not _missing_bus_warnings.has(bus_name):
		_missing_bus_warnings[bus_name] = true
		push_warning("[GFAudioUtility] 无法找到音轨总线: %s，已回退到 %s。" % [bus_name, _FALLBACK_BUS_NAME])
	return _FALLBACK_BUS_NAME


func _is_sfx_capacity_full() -> bool:
	if max_sfx_players <= 0:
		return false

	_prune_inactive_sfx_players()
	return _active_sfx_players.size() >= max_sfx_players


func _track_sfx_player(player: AudioStreamPlayer) -> void:
	_prune_inactive_sfx_players()
	if not _active_sfx_players.has(player):
		_active_sfx_players.append(player)


func _untrack_sfx_player(player: AudioStreamPlayer) -> void:
	_active_sfx_players.erase(player)


func _stop_oldest_sfx() -> void:
	_prune_inactive_sfx_players()
	if _active_sfx_players.is_empty():
		return

	var player := _active_sfx_players.pop_front() as AudioStreamPlayer
	_release_sfx_player(player)


func _release_all_sfx_players() -> void:
	_prune_inactive_sfx_players()
	var players := _active_sfx_players.duplicate()
	_active_sfx_players.clear()
	for player: AudioStreamPlayer in players:
		_release_sfx_player(player)


func _release_sfx_player(player: AudioStreamPlayer) -> void:
	if not is_instance_valid(player):
		return

	var finished_callback := _get_sfx_finished_callback(player)
	if player.finished.is_connected(finished_callback):
		player.finished.disconnect(finished_callback)
	player.stop()

	var pool := _get_pool_util()
	if pool != null and is_instance_valid(_sfx_scene):
		pool.release(player, _sfx_scene)
	else:
		player.queue_free()


func _prune_inactive_sfx_players() -> void:
	for i: int in range(_active_sfx_players.size() - 1, -1, -1):
		var player := _active_sfx_players[i]
		if not is_instance_valid(player) or player.is_queued_for_deletion():
			_active_sfx_players.remove_at(i)


func _get_sfx_finished_callback(player: AudioStreamPlayer) -> Callable:
	return _on_sfx_finished.bind(player)
