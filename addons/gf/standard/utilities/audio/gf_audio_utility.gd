## GFAudioUtility: 全局音频管理器。
##
## 管理 BGM 和 SFX 的播放与音量。
## 注册 GFObjectPoolUtility 时会复用 AudioStreamPlayer，未注册时使用普通播放器。
## 支持通过 GFAssetUtility 异步加载音频资源。
class_name GFAudioUtility
extends GFUtility


# --- 枚举 ---

## SFX 超出并发上限时的处理策略。
enum SFXOverflowPolicy {
	## 跳过新的 SFX 请求。
	SKIP_NEW,
	## 停止最早播放的 SFX，并播放新的请求。
	STOP_OLDEST,
}


# --- 常量 ---

## 默认 BGM 音频总线名。
const BGM_BUS_NAME: String = "BGM"

## 默认 SFX 音频总线名。
const SFX_BUS_NAME: String = "SFX"

const _FALLBACK_BUS_NAME: String = "Master"


# --- 公共变量 ---

## 同时播放的 SFX 数量上限；小于等于 0 表示不限制。
var max_sfx_players: int = 32

## SFX 超出并发上限时采用的处理策略。
var sfx_overflow_policy: SFXOverflowPolicy = SFXOverflowPolicy.SKIP_NEW

## 默认 BGM 淡入淡出秒数。单次播放传入负数时使用该值。
var bgm_crossfade_seconds: float = 0.0

## BGM 历史记录最大数量。
var max_bgm_history: int = 16


# --- 私有变量 ---

var _bgm_player: AudioStreamPlayer
var _bgm_fade_player: AudioStreamPlayer
var _sfx_scene: PackedScene
var _root: Node
var _bgm_request_serial: int = 0
var _bgm_fade_serial: int = 0
var _sfx_lifecycle_serial: int = 0
var _missing_bus_warnings: Dictionary = {}
var _active_sfx_players: Array[AudioStreamPlayer] = []
var _bgm_history: PackedStringArray = PackedStringArray()
var _current_bgm_key: String = ""
var _ambient_players: Dictionary = {}
var _ambient_request_serials: Dictionary = {}
var _audio_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _audio_banks: Dictionary = {}
var _audio_bank_base_values: Dictionary = {}
var _audio_bank_mount_stacks: Dictionary = {}
var _audio_bank_mount_token: int = 0
var _audio_backend: GFAudioBackend = null


# --- Godot 生命周期方法 ---

func init() -> void:
	_bgm_request_serial = 0
	_bgm_fade_serial = 0
	_sfx_lifecycle_serial += 1
	_missing_bus_warnings.clear()
	_active_sfx_players.clear()
	_bgm_history = PackedStringArray()
	_current_bgm_key = ""
	_ambient_players.clear()
	_ambient_request_serials.clear()
	_audio_rng.randomize()
	_audio_banks.clear()
	_audio_bank_base_values.clear()
	_audio_bank_mount_stacks.clear()
	_audio_bank_mount_token = 0
	# 动态创建用于可选池化的 SFX 播放器模版
	var player_template := AudioStreamPlayer.new()
	_sfx_scene = PackedScene.new()
	_sfx_scene.pack(player_template)
	player_template.free()
	
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "GFBGMPlayer"
	_bgm_player.bus = _resolve_bus_name(BGM_BUS_NAME)
	_bgm_fade_player = AudioStreamPlayer.new()
	_bgm_fade_player.name = "GFBGMFadePlayer"
	_bgm_fade_player.bus = _resolve_bus_name(BGM_BUS_NAME)
	
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		_root = tree.root
		_root.call_deferred("add_child", _bgm_player)
		_root.call_deferred("add_child", _bgm_fade_player)


func dispose() -> void:
	_bgm_request_serial += 1
	_bgm_fade_serial += 1
	_sfx_lifecycle_serial += 1
	_clear_audio_backend(true)
	_release_all_sfx_players()
	_free_all_ambient_players()
	if is_instance_valid(_bgm_player):
		_bgm_player.queue_free()
	if is_instance_valid(_bgm_fade_player):
		_bgm_fade_player.queue_free()
	_root = null
	_audio_banks.clear()
	_audio_bank_base_values.clear()
	_audio_bank_mount_stacks.clear()
	
	# SFX 节点已由 _release_all_sfx_players() 统一释放。


# --- 公共方法 ---

## 播放 BGM（背景音乐）
## @param path: 音频资源的路径
## @param crossfade_seconds: 淡入淡出秒数；小于 0 时使用默认值。
func play_bgm(path: String, crossfade_seconds: float = -1.0) -> void:
	_bgm_request_serial += 1
	var request_serial := _bgm_request_serial
	if path.is_empty():
		stop_bgm(crossfade_seconds)
		return

	if _try_backend_play_bgm_path(path, {
		"crossfade_seconds": _resolve_bgm_crossfade_seconds(crossfade_seconds),
		"history_key": path,
	}):
		_record_bgm_history(path)
		return
		
	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(path) as AudioStream
		_apply_bgm_request(request_serial, stream, crossfade_seconds, path)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_bgm_request(request_serial, res as AudioStream, crossfade_seconds, path)
		asset_util.load_async(path, on_loaded)


## 播放资源化 BGM 配置。
## @param clip: 音频片段配置。
## @param crossfade_seconds: 淡入淡出秒数；小于 0 时使用默认值。
func play_bgm_clip(clip: GFAudioClip, crossfade_seconds: float = -1.0) -> void:
	if clip == null or not clip.has_source():
		return

	_bgm_request_serial += 1
	var request_serial := _bgm_request_serial
	var bus_name := clip.resolve_bus(BGM_BUS_NAME)
	var volume_db := clip.volume_db
	var pitch_scale := clip.resolve_pitch(_audio_rng)
	var history_key := _get_clip_history_key(clip)
	var backend_options := {
		"crossfade_seconds": _resolve_bgm_crossfade_seconds(crossfade_seconds),
		"bus_name": bus_name,
		"volume_db": volume_db,
		"pitch_scale": pitch_scale,
		"history_key": history_key,
	}

	if _try_backend_play_bgm_clip(clip, backend_options):
		_record_bgm_history(history_key)
		return

	if clip.stream != null:
		_apply_bgm_request_with_settings(request_serial, clip.stream, bus_name, volume_db, pitch_scale, crossfade_seconds, history_key)
		return

	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(clip.path) as AudioStream
		_apply_bgm_request_with_settings(request_serial, stream, bus_name, volume_db, pitch_scale, crossfade_seconds, history_key)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_bgm_request_with_settings(
				request_serial,
				res as AudioStream,
				bus_name,
				volume_db,
				pitch_scale,
				crossfade_seconds,
				history_key
			)
		asset_util.load_async(clip.path, on_loaded)


## 从音频集合播放 BGM。
## @param bank: 音频集合。
## @param clip_id: 片段标识。
## @param crossfade_seconds: 淡入淡出秒数；小于 0 时使用默认值。
func play_bgm_from_bank(bank: GFAudioBank, clip_id: StringName, crossfade_seconds: float = -1.0) -> void:
	if bank == null:
		return

	play_bgm_clip(bank.get_clip_with_fallback(clip_id, _audio_rng), crossfade_seconds)


## 按事件 ID 播放注册音频集合中的 BGM。
## @param event_id: 音频事件标识。
## @param bank_id: 音频集合标识；为空时搜索全部注册集合。
## @param crossfade_seconds: 淡入淡出秒数；小于 0 时使用默认值。
func play_bgm_event(
	event_id: StringName,
	bank_id: StringName = &"",
	crossfade_seconds: float = -1.0
) -> void:
	play_bgm_clip(_get_registered_clip(event_id, bank_id), crossfade_seconds)


## 停止当前 BGM。
## @param fade_seconds: 淡出秒数。
func stop_bgm(fade_seconds: float = 0.0) -> void:
	if _audio_backend != null:
		_audio_backend.stop_bgm(maxf(fade_seconds, 0.0))
	_bgm_fade_serial += 1
	_current_bgm_key = ""
	if is_instance_valid(_bgm_player):
		_stop_player(_bgm_player, fade_seconds)
	if is_instance_valid(_bgm_fade_player):
		_bgm_fade_player.stop()


## 获取 BGM 播放历史。
## @return 从旧到新的历史 key。
func get_bgm_history() -> PackedStringArray:
	return PackedStringArray(_bgm_history)


## 获取当前 BGM key。
## @return 当前 BGM key；无播放时为空。
func get_current_bgm_key() -> String:
	return _current_bgm_key


## 清空 BGM 历史。
func clear_bgm_history() -> void:
	_bgm_history = PackedStringArray()


## 注册一个全局音频集合，供事件式播放接口使用。
## @param bank_id: 音频集合标识。
## @param bank: 音频集合。
func register_audio_bank(bank_id: StringName, bank: GFAudioBank) -> void:
	if bank_id == &"":
		push_error("[GFAudioUtility] register_audio_bank 失败：bank_id 为空。")
		return
	_audio_bank_base_values.erase(bank_id)
	_audio_bank_mount_stacks.erase(bank_id)
	if bank == null:
		_audio_banks.erase(bank_id)
		return
	_audio_banks[bank_id] = bank


## 移除一个全局音频集合。
## @param bank_id: 音频集合标识。
func unregister_audio_bank(bank_id: StringName) -> void:
	_audio_bank_base_values.erase(bank_id)
	_audio_bank_mount_stacks.erase(bank_id)
	_audio_banks.erase(bank_id)


## 清空全局音频集合注册表。
func clear_audio_banks() -> void:
	_audio_bank_base_values.clear()
	_audio_bank_mount_stacks.clear()
	_audio_banks.clear()


## 挂载一个临时音频集合，并返回用于卸载的挂载令牌。
## @param bank_id: 音频集合标识。
## @param bank: 音频集合。
## @param restore_previous_bank: 卸载顶层挂载时是否恢复同 ID 的上一层音频集合。
## @return 挂载令牌；失败时返回 0。
func mount_audio_bank(
	bank_id: StringName,
	bank: GFAudioBank,
	restore_previous_bank: bool = true
) -> int:
	if bank_id == &"":
		push_error("[GFAudioUtility] mount_audio_bank 失败：bank_id 为空。")
		return 0
	if bank == null:
		push_error("[GFAudioUtility] mount_audio_bank 失败：bank 为空。")
		return 0

	if not _audio_bank_mount_stacks.has(bank_id):
		if _audio_banks.has(bank_id):
			_audio_bank_base_values[bank_id] = _audio_banks[bank_id]
		var new_stack: Array[Dictionary] = []
		_audio_bank_mount_stacks[bank_id] = new_stack

	_audio_bank_mount_token += 1
	var token := _audio_bank_mount_token
	var stack := _audio_bank_mount_stacks[bank_id] as Array
	stack.append({
		"token": token,
		"bank": bank,
		"restore_previous_bank": restore_previous_bank,
	})
	_audio_banks[bank_id] = bank
	return token


## 卸载由 mount_audio_bank() 创建的临时音频集合。
## @param bank_id: 音频集合标识。
## @param mount_token: mount_audio_bank() 返回的挂载令牌。
## @return 找到并卸载对应挂载时返回 true。
func unmount_audio_bank(bank_id: StringName, mount_token: int) -> bool:
	if bank_id == &"" or mount_token <= 0:
		return false
	if not _audio_bank_mount_stacks.has(bank_id):
		return false

	var stack := _audio_bank_mount_stacks[bank_id] as Array
	var remove_index := -1
	for index: int in range(stack.size() - 1, -1, -1):
		var entry := stack[index] as Dictionary
		if int(entry.get("token", 0)) == mount_token:
			remove_index = index
			break
	if remove_index == -1:
		return false

	var removed_entry := stack[remove_index] as Dictionary
	var was_top := remove_index == stack.size() - 1
	stack.remove_at(remove_index)
	if was_top:
		_restore_audio_bank_after_unmount(bank_id, stack, bool(removed_entry.get("restore_previous_bank", true)))
	if stack.is_empty():
		_audio_bank_mount_stacks.erase(bank_id)
		_audio_bank_base_values.erase(bank_id)
	return true


## 获取全局音频集合。
## @param bank_id: 音频集合标识。
## @return 音频集合；不存在时返回 null。
func get_audio_bank(bank_id: StringName) -> GFAudioBank:
	return _audio_banks.get(bank_id) as GFAudioBank


## 设置可插拔音频后端。传入 null 时恢复默认 Godot 播放路径。
## @param backend: 音频后端。
func set_audio_backend(backend: GFAudioBackend) -> void:
	if _audio_backend == backend:
		return
	_clear_audio_backend(true)
	_audio_backend = backend
	if _audio_backend != null:
		_audio_backend.setup(self)


## 获取当前音频后端。
## @return 音频后端；未设置时返回 null。
func get_audio_backend() -> GFAudioBackend:
	return _audio_backend


## 清除当前音频后端。
## @param dispose_backend: 是否调用后端 dispose()。
func clear_audio_backend(dispose_backend: bool = true) -> void:
	_clear_audio_backend(dispose_backend)


## 发布资源化音频事件。
## @param event: 音频事件资源。
## @param options: 请求选项。
## @return 控制句柄；不需要或无法返回句柄时返回 null。
func post_audio_event(event: GFAudioEvent, options: Dictionary = {}) -> GFAudioEmitterHandle:
	if event == null or not event.has_request():
		return null
	var request_options := event.to_request_options(options)
	if _audio_backend != null and _audio_backend.can_handle_event(event, request_options):
		return _audio_backend.post_event(event, request_options)

	match event.channel:
		&"bgm":
			_post_bgm_event(event, request_options)
			return null
		&"ambient":
			_post_ambient_event(event, request_options)
			return null
		&"spatial_sfx":
			return null
		_:
			return _post_sfx_event(event)


## 写入音频参数。
## @param parameter: 参数请求。
## @return 后端已处理返回 true。
func set_audio_parameter(parameter: GFAudioParameter) -> bool:
	return _audio_backend != null and _audio_backend.set_parameter(parameter)


## 写入音频状态。
## @param state: 状态请求。
## @return 后端已处理返回 true。
func set_audio_state(state: GFAudioState) -> bool:
	return _audio_backend != null and _audio_backend.set_state(state)


## 写入音频开关。
## @param audio_switch: 开关请求。
## @return 后端已处理返回 true。
func set_audio_switch(audio_switch: GFAudioSwitch) -> bool:
	return _audio_backend != null and _audio_backend.set_switch(audio_switch)


## 播放环境音。
## @param path: 音频资源路径。
## @param channel: 环境音通道。
## @param fade_seconds: 淡入秒数。
func play_ambient(path: String, channel: StringName = &"default", fade_seconds: float = 0.0) -> void:
	if path.is_empty():
		stop_ambient(channel, fade_seconds)
		return

	if _try_backend_play_ambient_path(path, channel, {
		"fade_seconds": maxf(fade_seconds, 0.0),
		"bus_name": BGM_BUS_NAME,
		"volume_db": 0.0,
		"pitch_scale": 1.0,
	}):
		return

	var request_serial := _next_ambient_request_serial(channel)
	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(path) as AudioStream
		_apply_ambient_request(request_serial, channel, stream, BGM_BUS_NAME, 0.0, 1.0, fade_seconds)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_ambient_request(request_serial, channel, res as AudioStream, BGM_BUS_NAME, 0.0, 1.0, fade_seconds)
		asset_util.load_async(path, on_loaded)


## 播放资源化环境音配置。
## @param clip: 音频片段配置。
## @param channel: 环境音通道。
## @param fade_seconds: 淡入秒数。
func play_ambient_clip(
	clip: GFAudioClip,
	channel: StringName = &"default",
	fade_seconds: float = 0.0
) -> void:
	if clip == null or not clip.has_source():
		return

	var request_serial := _next_ambient_request_serial(channel)
	var bus_name := clip.resolve_bus(BGM_BUS_NAME)
	var volume_db := clip.volume_db
	var pitch_scale := clip.resolve_pitch(_audio_rng)
	var backend_options := {
		"fade_seconds": maxf(fade_seconds, 0.0),
		"bus_name": bus_name,
		"volume_db": volume_db,
		"pitch_scale": pitch_scale,
	}

	if _try_backend_play_ambient_clip(clip, channel, backend_options):
		return

	if clip.stream != null:
		_apply_ambient_request(request_serial, channel, clip.stream, bus_name, volume_db, pitch_scale, fade_seconds)
		return

	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(clip.path) as AudioStream
		_apply_ambient_request(request_serial, channel, stream, bus_name, volume_db, pitch_scale, fade_seconds)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_ambient_request(request_serial, channel, res as AudioStream, bus_name, volume_db, pitch_scale, fade_seconds)
		asset_util.load_async(clip.path, on_loaded)


## 从音频集合播放环境音。
## @param bank: 音频集合。
## @param clip_id: 片段标识。
## @param channel: 环境音通道。
## @param fade_seconds: 淡入秒数。
func play_ambient_from_bank(
	bank: GFAudioBank,
	clip_id: StringName,
	channel: StringName = &"default",
	fade_seconds: float = 0.0
) -> void:
	if bank == null:
		return

	play_ambient_clip(bank.get_clip_with_fallback(clip_id, _audio_rng), channel, fade_seconds)


## 按事件 ID 播放注册音频集合中的环境音。
## @param event_id: 音频事件标识。
## @param channel: 环境音通道。
## @param bank_id: 音频集合标识；为空时搜索全部注册集合。
## @param fade_seconds: 淡入秒数。
func play_ambient_event(
	event_id: StringName,
	channel: StringName = &"default",
	bank_id: StringName = &"",
	fade_seconds: float = 0.0
) -> void:
	play_ambient_clip(_get_registered_clip(event_id, bank_id), channel, fade_seconds)


## 停止指定环境音通道。
## @param channel: 环境音通道。
## @param fade_seconds: 淡出秒数。
func stop_ambient(channel: StringName = &"default", fade_seconds: float = 0.0) -> void:
	if _audio_backend != null:
		_audio_backend.stop_ambient(channel, maxf(fade_seconds, 0.0))
	_next_ambient_request_serial(channel)
	var player := _ambient_players.get(channel) as AudioStreamPlayer
	if player != null:
		_stop_player(player, fade_seconds)


## 停止所有环境音通道。
## @param fade_seconds: 淡出秒数。
func stop_all_ambient(fade_seconds: float = 0.0) -> void:
	if _audio_backend != null:
		_audio_backend.stop_all_ambient(maxf(fade_seconds, 0.0))
	var channels := _ambient_players.keys()
	for channel_variant: Variant in channels:
		stop_ambient(StringName(channel_variant), fade_seconds)


## 检查环境音通道是否正在播放。
## @param channel: 环境音通道。
## @return 正在播放时返回 true。
func is_ambient_playing(channel: StringName = &"default") -> bool:
	if _audio_backend != null and _audio_backend.is_ambient_playing(channel):
		return true
	var player := _ambient_players.get(channel) as AudioStreamPlayer
	return is_instance_valid(player) and player.playing


## 播放 SFX（音效），自动从池中分配播放器
## @param path: 音频资源的路径
func play_sfx(path: String) -> void:
	play_sfx_handle(path)


## 播放 SFX 并返回控制句柄。
## @param path: 音频资源的路径。
## @return 控制句柄；路径为空时返回 null。
func play_sfx_handle(path: String) -> GFAudioEmitterHandle:
	if path.is_empty():
		return null

	var backend_handle := _try_backend_play_sfx_path(path, {
		"bus_name": SFX_BUS_NAME,
		"volume_db": 0.0,
		"pitch_scale": 1.0,
	})
	if backend_handle != null:
		return backend_handle

	var handle := GFAudioEmitterHandle.new(null, Callable(self, "_release_sfx_player"))
	var request_serial := _sfx_lifecycle_serial
	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(path) as AudioStream
		_apply_sfx_request(request_serial, stream, handle)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_sfx_request(request_serial, res as AudioStream, handle)
		asset_util.load_async(path, on_loaded)
	return handle


## 播放资源化 SFX 配置。
## @param clip: 音频片段配置。
func play_sfx_clip(clip: GFAudioClip) -> void:
	play_sfx_clip_handle(clip)


## 播放资源化 SFX 配置并返回控制句柄。
## @param clip: 音频片段配置。
## @return 控制句柄；片段无播放来源时返回 null。
func play_sfx_clip_handle(clip: GFAudioClip) -> GFAudioEmitterHandle:
	if clip == null or not clip.has_source():
		return null

	var handle := GFAudioEmitterHandle.new(null, Callable(self, "_release_sfx_player"))
	var request_serial := _sfx_lifecycle_serial
	var bus_name := clip.resolve_bus(SFX_BUS_NAME)
	var volume_db := clip.volume_db
	var pitch_scale := clip.resolve_pitch(_audio_rng)
	var backend_handle := _try_backend_play_sfx_clip(clip, {
		"bus_name": bus_name,
		"volume_db": volume_db,
		"pitch_scale": pitch_scale,
	})
	if backend_handle != null:
		return backend_handle

	if clip.stream != null:
		_apply_sfx_request_with_settings(request_serial, clip.stream, bus_name, volume_db, pitch_scale, handle)
		return handle

	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(clip.path) as AudioStream
		_apply_sfx_request_with_settings(request_serial, stream, bus_name, volume_db, pitch_scale, handle)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_sfx_request_with_settings(
				request_serial,
				res as AudioStream,
				bus_name,
				volume_db,
				pitch_scale,
				handle
			)
		asset_util.load_async(clip.path, on_loaded)
	return handle


## 从音频集合播放 SFX。
## @param bank: 音频集合。
## @param clip_id: 片段标识。
func play_sfx_from_bank(bank: GFAudioBank, clip_id: StringName) -> void:
	play_sfx_from_bank_handle(bank, clip_id)


## 从音频集合播放 SFX 并返回控制句柄。
## @param bank: 音频集合。
## @param clip_id: 片段标识。
## @return 控制句柄；无法播放时返回 null。
func play_sfx_from_bank_handle(bank: GFAudioBank, clip_id: StringName) -> GFAudioEmitterHandle:
	if bank == null:
		return null

	return play_sfx_clip_handle(bank.get_clip_with_fallback(clip_id, _audio_rng))


## 按事件 ID 播放注册音频集合中的 SFX。
## @param event_id: 音频事件标识。
## @param bank_id: 音频集合标识；为空时搜索全部注册集合。
func play_sfx_event(event_id: StringName, bank_id: StringName = &"") -> void:
	play_sfx_event_handle(event_id, bank_id)


## 按事件 ID 播放注册音频集合中的 SFX 并返回控制句柄。
## @param event_id: 音频事件标识。
## @param bank_id: 音频集合标识；为空时搜索全部注册集合。
## @return 控制句柄；无法播放时返回 null。
func play_sfx_event_handle(event_id: StringName, bank_id: StringName = &"") -> GFAudioEmitterHandle:
	return play_sfx_clip_handle(_get_registered_clip(event_id, bank_id))


## 按事件 ID 在 2D 节点位置播放注册音频集合中的 SFX。
## @param event_id: 音频事件标识。
## @param source: 2D 声源节点。
## @param bank_id: 音频集合标识；为空时搜索全部注册集合。
## @param follow_source: 为 true 时播放器会作为 source 子节点跟随移动。
## @return 创建的播放器；无法播放时返回 null。
func play_sfx_event_2d(
	event_id: StringName,
	source: Node2D,
	bank_id: StringName = &"",
	follow_source: bool = false
) -> AudioStreamPlayer2D:
	return play_sfx_clip_2d(_get_registered_clip(event_id, bank_id), source, follow_source)


## 按事件 ID 在 2D 节点位置播放注册音频集合中的 SFX，并返回控制句柄。
## @param event_id: 音频事件标识。
## @param source: 2D 声源节点。
## @param bank_id: 音频集合标识；为空时搜索全部注册集合。
## @param follow_source: 为 true 时播放器会作为 source 子节点跟随移动。
## @return 控制句柄；无法播放时返回 null。
func play_sfx_event_2d_handle(
	event_id: StringName,
	source: Node2D,
	bank_id: StringName = &"",
	follow_source: bool = false
) -> GFAudioEmitterHandle:
	return play_sfx_clip_2d_handle(_get_registered_clip(event_id, bank_id), source, follow_source)


## 按事件 ID 在 3D 节点位置播放注册音频集合中的 SFX。
## @param event_id: 音频事件标识。
## @param source: 3D 声源节点。
## @param bank_id: 音频集合标识；为空时搜索全部注册集合。
## @param follow_source: 为 true 时播放器会作为 source 子节点跟随移动。
## @return 创建的播放器；无法播放时返回 null。
func play_sfx_event_3d(
	event_id: StringName,
	source: Node3D,
	bank_id: StringName = &"",
	follow_source: bool = false
) -> AudioStreamPlayer3D:
	return play_sfx_clip_3d(_get_registered_clip(event_id, bank_id), source, follow_source)


## 按事件 ID 在 3D 节点位置播放注册音频集合中的 SFX，并返回控制句柄。
## @param event_id: 音频事件标识。
## @param source: 3D 声源节点。
## @param bank_id: 音频集合标识；为空时搜索全部注册集合。
## @param follow_source: 为 true 时播放器会作为 source 子节点跟随移动。
## @return 控制句柄；无法播放时返回 null。
func play_sfx_event_3d_handle(
	event_id: StringName,
	source: Node3D,
	bank_id: StringName = &"",
	follow_source: bool = false
) -> GFAudioEmitterHandle:
	return play_sfx_clip_3d_handle(_get_registered_clip(event_id, bank_id), source, follow_source)


## 在 2D 节点位置播放资源化 SFX 配置。
## @param clip: 音频片段配置。
## @param source: 2D 声源节点。
## @param follow_source: 为 true 时播放器会作为 source 子节点跟随移动。
## @return 创建的播放器；无法播放时返回 null。
func play_sfx_clip_2d(
	clip: GFAudioClip,
	source: Node2D,
	follow_source: bool = false
) -> AudioStreamPlayer2D:
	return _play_spatial_sfx_clip(clip, source, follow_source) as AudioStreamPlayer2D


## 在 2D 节点位置播放资源化 SFX 配置，并返回控制句柄。
## @param clip: 音频片段配置。
## @param source: 2D 声源节点。
## @param follow_source: 为 true 时播放器会作为 source 子节点跟随移动。
## @return 控制句柄；无法播放时返回 null。
func play_sfx_clip_2d_handle(
	clip: GFAudioClip,
	source: Node2D,
	follow_source: bool = false
) -> GFAudioEmitterHandle:
	var backend_handle := _try_backend_play_spatial_sfx_clip(clip, source, follow_source, {
		"space": "2d",
	})
	if backend_handle != null:
		return backend_handle

	var player := _play_spatial_sfx_clip(clip, source, follow_source)
	if player == null:
		return null
	var handle := GFAudioEmitterHandle.new(player, Callable(self, "_queue_free_audio_player"))
	if follow_source:
		handle.bind_to_owner(source)
	return handle


## 在 3D 节点位置播放资源化 SFX 配置。
## @param clip: 音频片段配置。
## @param source: 3D 声源节点。
## @param follow_source: 为 true 时播放器会作为 source 子节点跟随移动。
## @return 创建的播放器；无法播放时返回 null。
func play_sfx_clip_3d(
	clip: GFAudioClip,
	source: Node3D,
	follow_source: bool = false
) -> AudioStreamPlayer3D:
	return _play_spatial_sfx_clip(clip, source, follow_source) as AudioStreamPlayer3D


## 在 3D 节点位置播放资源化 SFX 配置，并返回控制句柄。
## @param clip: 音频片段配置。
## @param source: 3D 声源节点。
## @param follow_source: 为 true 时播放器会作为 source 子节点跟随移动。
## @return 控制句柄；无法播放时返回 null。
func play_sfx_clip_3d_handle(
	clip: GFAudioClip,
	source: Node3D,
	follow_source: bool = false
) -> GFAudioEmitterHandle:
	var backend_handle := _try_backend_play_spatial_sfx_clip(clip, source, follow_source, {
		"space": "3d",
	})
	if backend_handle != null:
		return backend_handle

	var player := _play_spatial_sfx_clip(clip, source, follow_source)
	if player == null:
		return null
	var handle := GFAudioEmitterHandle.new(player, Callable(self, "_queue_free_audio_player"))
	if follow_source:
		handle.bind_to_owner(source)
	return handle


## 获取环境音通道的控制句柄。
## @param channel: 环境音通道。
## @return 控制句柄；通道不存在时返回 null。
func get_ambient_handle(channel: StringName = &"default") -> GFAudioEmitterHandle:
	var player := _ambient_players.get(channel) as AudioStreamPlayer
	if not is_instance_valid(player):
		return null
	return GFAudioEmitterHandle.new(player, Callable(self, "_stop_audio_player"), channel)


## 设置音频总线音量
## @param bus_name: 总线名称，如 "Master", "BGM", "SFX"
## @param volume_linear: 线性音量 (0.0 到 1.0)
func set_bus_volume(bus_name: String, volume_linear: float) -> void:
	if _audio_backend != null and _audio_backend.set_bus_volume(bus_name, volume_linear):
		return

	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		if volume_linear <= 0.0:
			AudioServer.set_bus_volume_db(bus_idx, -80.0)
			AudioServer.set_bus_mute(bus_idx, true)
			return
		AudioServer.set_bus_mute(bus_idx, false)
		var db := linear_to_db(minf(volume_linear, 1.0))
		AudioServer.set_bus_volume_db(bus_idx, db)
	else:
		push_warning("[GFAudioUtility] 无法找到音轨总线: " + bus_name)


## 获取音频总线音量
## @param bus_name: 总线名称
## @return 线性音量 (0.0 到 1.0)
func get_bus_volume(bus_name: String) -> float:
	if _audio_backend != null:
		var backend_volume := _audio_backend.get_bus_volume(bus_name)
		if backend_volume >= 0.0:
			return backend_volume

	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		if AudioServer.is_bus_mute(bus_idx):
			return 0.0
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return 0.0


## 获取音频工具调试快照。
## @return 调试快照。
func get_debug_snapshot() -> Dictionary:
	_prune_inactive_sfx_players()
	var ambient_channels := PackedStringArray()
	for channel_variant: Variant in _ambient_players.keys():
		var channel := String(channel_variant)
		if is_ambient_playing(StringName(channel)):
			ambient_channels.append(channel)
	ambient_channels.sort()

	var backend_snapshot := {}
	var backend_capabilities := {}
	var backend_name := ""
	if _audio_backend != null:
		var backend_script := _audio_backend.get_script() as Script
		backend_name = backend_script.resource_path if backend_script != null else _audio_backend.get_class()
		backend_snapshot = _audio_backend.get_debug_snapshot()
		backend_capabilities = _audio_backend.get_capabilities().to_dictionary()

	return {
		"backend": backend_name,
		"backend_snapshot": backend_snapshot,
		"backend_capabilities": backend_capabilities,
		"current_bgm_key": _current_bgm_key,
		"bgm_history": get_bgm_history(),
		"active_sfx_count": _active_sfx_players.size(),
		"max_sfx_players": max_sfx_players,
		"ambient_channels": ambient_channels,
		"audio_bank_count": _audio_banks.size(),
	}


# --- 私有辅助方法 ---

func _clear_audio_backend(dispose_backend: bool) -> void:
	if _audio_backend == null:
		return
	if dispose_backend:
		_audio_backend.dispose()
	_audio_backend = null


func _restore_audio_bank_after_unmount(
	bank_id: StringName,
	stack: Array,
	restore_previous_bank: bool
) -> void:
	if not restore_previous_bank:
		_audio_banks.erase(bank_id)
		return
	if not stack.is_empty():
		var top_entry := stack[stack.size() - 1] as Dictionary
		var top_bank := top_entry.get("bank") as GFAudioBank
		if top_bank != null:
			_audio_banks[bank_id] = top_bank
			return
	if _audio_bank_base_values.has(bank_id):
		var base_bank := _audio_bank_base_values[bank_id] as GFAudioBank
		if base_bank != null:
			_audio_banks[bank_id] = base_bank
			return
	_audio_banks.erase(bank_id)


func _try_backend_play_bgm_path(path: String, options: Dictionary) -> bool:
	if _audio_backend == null:
		return false
	if not _audio_backend.can_handle_path(path, &"bgm", options):
		return false
	return _audio_backend.play_bgm_path(path, options)


func _try_backend_play_bgm_clip(clip: GFAudioClip, options: Dictionary) -> bool:
	if _audio_backend == null:
		return false
	if not _audio_backend.can_handle_clip(clip, &"bgm", options):
		return false
	return _audio_backend.play_bgm_clip(clip, options)


func _try_backend_play_ambient_path(path: String, channel: StringName, options: Dictionary) -> bool:
	if _audio_backend == null:
		return false
	var context := options.duplicate(true)
	context["ambient_channel"] = channel
	if not _audio_backend.can_handle_path(path, &"ambient", context):
		return false
	return _audio_backend.play_ambient_path(path, channel, options)


func _try_backend_play_ambient_clip(clip: GFAudioClip, channel: StringName, options: Dictionary) -> bool:
	if _audio_backend == null:
		return false
	var context := options.duplicate(true)
	context["ambient_channel"] = channel
	if not _audio_backend.can_handle_clip(clip, &"ambient", context):
		return false
	return _audio_backend.play_ambient_clip(clip, channel, options)


func _try_backend_play_sfx_path(path: String, options: Dictionary) -> GFAudioEmitterHandle:
	if _audio_backend == null:
		return null
	if not _audio_backend.can_handle_path(path, &"sfx", options):
		return null
	return _audio_backend.play_sfx_path(path, options)


func _try_backend_play_sfx_clip(clip: GFAudioClip, options: Dictionary) -> GFAudioEmitterHandle:
	if _audio_backend == null:
		return null
	if not _audio_backend.can_handle_clip(clip, &"sfx", options):
		return null
	return _audio_backend.play_sfx_clip(clip, options)


func _try_backend_play_spatial_sfx_clip(
	clip: GFAudioClip,
	source: Node,
	follow_source: bool,
	options: Dictionary
) -> GFAudioEmitterHandle:
	if _audio_backend == null:
		return null
	var context := options.duplicate(true)
	context["follow_source"] = follow_source
	context["source"] = source
	if not _audio_backend.can_handle_clip(clip, &"spatial_sfx", context):
		return null
	return _audio_backend.play_spatial_sfx_clip(clip, source, follow_source, options)


func _post_bgm_event(event: GFAudioEvent, options: Dictionary) -> void:
	var fade_seconds := float(options.get("fade_seconds", 0.0))
	if event.clip != null:
		play_bgm_clip(event.clip, fade_seconds)
	elif event.event_id != &"":
		play_bgm_event(event.event_id, event.bank_id, fade_seconds)
	elif not event.path.is_empty():
		play_bgm(event.path, fade_seconds)


func _post_ambient_event(event: GFAudioEvent, options: Dictionary) -> void:
	var fade_seconds := float(options.get("fade_seconds", 0.0))
	if event.clip != null:
		play_ambient_clip(event.clip, event.ambient_channel, fade_seconds)
	elif event.event_id != &"":
		play_ambient_event(event.event_id, event.ambient_channel, event.bank_id, fade_seconds)
	elif not event.path.is_empty():
		play_ambient(event.path, event.ambient_channel, fade_seconds)


func _post_sfx_event(event: GFAudioEvent) -> GFAudioEmitterHandle:
	if event.clip != null:
		return play_sfx_clip_handle(event.clip)
	if event.event_id != &"":
		return play_sfx_event_handle(event.event_id, event.bank_id)
	if not event.path.is_empty():
		return play_sfx_handle(event.path)
	return null


func _get_registered_clip(event_id: StringName, bank_id: StringName = &"") -> GFAudioClip:
	if event_id == &"":
		return null
	if bank_id != &"":
		var bank := get_audio_bank(bank_id)
		return bank.get_clip_with_fallback(event_id, _audio_rng) if bank != null else null

	var bank_ids := PackedStringArray()
	for key: Variant in _audio_banks.keys():
		bank_ids.append(String(key))
	bank_ids.sort()
	for key_text: String in bank_ids:
		var bank := _audio_banks.get(StringName(key_text)) as GFAudioBank
		if bank == null:
			continue
		var clip := bank.get_clip_with_fallback(event_id, _audio_rng)
		if clip != null:
			return clip
	return null


func _play_spatial_sfx_clip(clip: GFAudioClip, source: Node, follow_source: bool = false) -> Node:
	if clip == null or not clip.has_source() or not is_instance_valid(source):
		return null

	var parent := source if follow_source else _get_spatial_sfx_parent(source)
	if parent == null:
		return null

	var player: Node = null
	if source is Node3D:
		player = AudioStreamPlayer3D.new()
		if follow_source:
			(player as AudioStreamPlayer3D).position = Vector3.ZERO
		else:
			(player as AudioStreamPlayer3D).global_position = (source as Node3D).global_position
	elif source is Node2D:
		player = AudioStreamPlayer2D.new()
		if follow_source:
			(player as AudioStreamPlayer2D).position = Vector2.ZERO
		else:
			(player as AudioStreamPlayer2D).global_position = (source as Node2D).global_position
	else:
		return null

	player.name = "GFSpatialSFXPlayer"
	parent.add_child(player)

	var request_serial := _sfx_lifecycle_serial
	var bus_name := clip.resolve_bus(SFX_BUS_NAME)
	var volume_db := clip.volume_db
	var pitch_scale := clip.resolve_pitch(_audio_rng)
	if clip.stream != null:
		_apply_spatial_sfx_request(request_serial, player, clip.stream, bus_name, volume_db, pitch_scale)
		return player

	var asset_util := _get_asset_util()
	if asset_util == null:
		var stream := load(clip.path) as AudioStream
		_apply_spatial_sfx_request(request_serial, player, stream, bus_name, volume_db, pitch_scale)
	else:
		var on_loaded := func(res: Resource) -> void:
			_apply_spatial_sfx_request(request_serial, player, res as AudioStream, bus_name, volume_db, pitch_scale)
		asset_util.load_async(clip.path, on_loaded)
	return player


func _apply_spatial_sfx_request(
	request_serial: int,
	player: Node,
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float
) -> void:
	if request_serial != _sfx_lifecycle_serial:
		if is_instance_valid(player):
			player.queue_free()
		return
	if stream == null or not is_instance_valid(player):
		if is_instance_valid(player):
			player.queue_free()
		return

	if player is AudioStreamPlayer2D:
		var player_2d := player as AudioStreamPlayer2D
		player_2d.bus = _resolve_bus_name(bus_name)
		player_2d.volume_db = volume_db
		player_2d.pitch_scale = pitch_scale
		player_2d.stream = stream
		player_2d.finished.connect(player_2d.queue_free, CONNECT_ONE_SHOT)
		player_2d.play()
	elif player is AudioStreamPlayer3D:
		var player_3d := player as AudioStreamPlayer3D
		player_3d.bus = _resolve_bus_name(bus_name)
		player_3d.volume_db = volume_db
		player_3d.pitch_scale = pitch_scale
		player_3d.stream = stream
		player_3d.finished.connect(player_3d.queue_free, CONNECT_ONE_SHOT)
		player_3d.play()
	else:
		player.queue_free()


func _get_spatial_sfx_parent(source: Node) -> Node:
	var tree := source.get_tree()
	if tree != null and tree.current_scene != null:
		return tree.current_scene
	return _root if is_instance_valid(_root) else source


func _play_bgm_stream(stream: AudioStream) -> void:
	_play_bgm_stream_with_settings(stream, BGM_BUS_NAME, 0.0, 1.0)


func _play_bgm_stream_with_settings(
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float,
	crossfade_seconds: float = -1.0,
	history_key: String = ""
) -> void:
	if stream == null or not is_instance_valid(_bgm_player):
		return

	_record_bgm_history(history_key)
	var fade_seconds := _resolve_bgm_crossfade_seconds(crossfade_seconds)
	if fade_seconds > 0.0 and _bgm_player.playing and _bgm_player.stream != null:
		_start_bgm_crossfade(stream, bus_name, volume_db, pitch_scale, fade_seconds)
		return

	_apply_player_settings(_bgm_player, stream, bus_name, volume_db, pitch_scale)
	_bgm_player.play()


func _apply_bgm_request(
	request_serial: int,
	stream: AudioStream,
	crossfade_seconds: float = -1.0,
	history_key: String = ""
) -> void:
	if request_serial != _bgm_request_serial:
		return

	_play_bgm_stream_with_settings(stream, BGM_BUS_NAME, 0.0, 1.0, crossfade_seconds, history_key)


func _apply_bgm_request_with_settings(
	request_serial: int,
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float,
	crossfade_seconds: float = -1.0,
	history_key: String = ""
) -> void:
	if request_serial != _bgm_request_serial:
		return

	_play_bgm_stream_with_settings(stream, bus_name, volume_db, pitch_scale, crossfade_seconds, history_key)


func _start_bgm_crossfade(
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float,
	fade_seconds: float
) -> void:
	if not is_instance_valid(_bgm_fade_player):
		_apply_player_settings(_bgm_player, stream, bus_name, volume_db, pitch_scale)
		_bgm_player.play()
		return

	_bgm_fade_serial += 1
	var fade_serial := _bgm_fade_serial
	_apply_player_settings(_bgm_fade_player, stream, bus_name, -80.0, pitch_scale)
	_bgm_fade_player.play()

	var tween := _create_tween_or_null()
	if tween == null:
		_complete_bgm_crossfade(fade_serial, volume_db)
		return

	tween.tween_property(_bgm_player, "volume_db", -80.0, fade_seconds)
	tween.parallel().tween_property(_bgm_fade_player, "volume_db", volume_db, fade_seconds)
	var finished_callback := func() -> void:
		_complete_bgm_crossfade(fade_serial, volume_db)
	tween.finished.connect(finished_callback, CONNECT_ONE_SHOT)


func _complete_bgm_crossfade(fade_serial: int, target_volume_db: float) -> void:
	if fade_serial != _bgm_fade_serial:
		return
	if not is_instance_valid(_bgm_player) or not is_instance_valid(_bgm_fade_player):
		return

	_bgm_player.stop()
	var previous_player := _bgm_player
	_bgm_player = _bgm_fade_player
	_bgm_player.volume_db = target_volume_db
	_bgm_fade_player = previous_player
	_bgm_fade_player.volume_db = 0.0


func _apply_player_settings(
	player: AudioStreamPlayer,
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float
) -> void:
	player.bus = _resolve_bus_name(bus_name)
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.stream = stream


func _resolve_bgm_crossfade_seconds(crossfade_seconds: float) -> float:
	var seconds := bgm_crossfade_seconds if crossfade_seconds < 0.0 else crossfade_seconds
	return maxf(seconds, 0.0)


func _record_bgm_history(history_key: String) -> void:
	if history_key.is_empty():
		return

	_current_bgm_key = history_key
	if _bgm_history.is_empty() or _bgm_history[_bgm_history.size() - 1] != history_key:
		_bgm_history.append(history_key)

	var limit := maxi(max_bgm_history, 0)
	while limit > 0 and _bgm_history.size() > limit:
		_bgm_history.remove_at(0)
	if limit == 0:
		_bgm_history = PackedStringArray()


func _get_clip_history_key(clip: GFAudioClip) -> String:
	if clip == null:
		return ""
	if not clip.path.is_empty():
		return clip.path
	if not clip.resource_path.is_empty():
		return clip.resource_path
	return "clip:%d" % clip.get_instance_id()


func _next_ambient_request_serial(channel: StringName) -> int:
	var next_serial := int(_ambient_request_serials.get(channel, 0)) + 1
	_ambient_request_serials[channel] = next_serial
	return next_serial


func _apply_ambient_request(
	request_serial: int,
	channel: StringName,
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float,
	fade_seconds: float
) -> void:
	if request_serial != int(_ambient_request_serials.get(channel, 0)):
		return

	_play_ambient_stream_with_settings(channel, stream, bus_name, volume_db, pitch_scale, fade_seconds)


func _play_ambient_stream_with_settings(
	channel: StringName,
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float,
	fade_seconds: float
) -> void:
	if stream == null:
		return

	var player := _get_or_create_ambient_player(channel)
	if player == null:
		return

	var should_fade := fade_seconds > 0.0
	_apply_player_settings(player, stream, bus_name, -80.0 if should_fade else volume_db, pitch_scale)
	player.play()
	if should_fade:
		_fade_player_volume(player, volume_db, fade_seconds)


func _get_or_create_ambient_player(channel: StringName) -> AudioStreamPlayer:
	var existing := _ambient_players.get(channel) as AudioStreamPlayer
	if is_instance_valid(existing):
		return existing
	if not is_instance_valid(_root):
		return null

	var player := AudioStreamPlayer.new()
	player.name = "GFAmbientPlayer_%s" % String(channel)
	player.bus = _resolve_bus_name(BGM_BUS_NAME)
	_root.add_child(player)
	_ambient_players[channel] = player
	return player


func _free_all_ambient_players() -> void:
	for player_variant: Variant in _ambient_players.values():
		var player := player_variant as AudioStreamPlayer
		if is_instance_valid(player):
			player.queue_free()
	_ambient_players.clear()
	_ambient_request_serials.clear()


func _stop_player(player: AudioStreamPlayer, fade_seconds: float) -> void:
	if not is_instance_valid(player):
		return
	if fade_seconds <= 0.0 or not player.playing:
		player.stop()
		return

	var tween := _fade_player_volume(player, -80.0, fade_seconds)
	if tween != null:
		var finished_callback := func() -> void:
			if is_instance_valid(player):
				player.stop()
		tween.finished.connect(finished_callback, CONNECT_ONE_SHOT)


func _fade_player_volume(player: AudioStreamPlayer, volume_db: float, fade_seconds: float) -> Tween:
	var tween := _create_tween_or_null()
	if tween == null:
		player.volume_db = volume_db
		return null

	tween.tween_property(player, "volume_db", volume_db, maxf(fade_seconds, 0.0))
	return tween


func _create_tween_or_null() -> Tween:
	if is_instance_valid(_root):
		return _root.create_tween()
	return null


func _apply_sfx_request(
	request_serial: int,
	stream: AudioStream,
	handle: GFAudioEmitterHandle = null
) -> void:
	if request_serial != _sfx_lifecycle_serial:
		return

	var player := _play_sfx_stream(stream)
	if handle != null:
		handle.set_player(player)


func _apply_sfx_request_with_settings(
	request_serial: int,
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float,
	handle: GFAudioEmitterHandle = null
) -> void:
	if request_serial != _sfx_lifecycle_serial:
		return

	var player := _play_sfx_stream_with_settings(stream, bus_name, volume_db, pitch_scale)
	if handle != null:
		handle.set_player(player)


func _play_sfx_stream(stream: AudioStream) -> AudioStreamPlayer:
	return _play_sfx_stream_with_settings(stream, SFX_BUS_NAME, 0.0, 1.0)


func _play_sfx_stream_with_settings(
	stream: AudioStream,
	bus_name: String,
	volume_db: float,
	pitch_scale: float
) -> AudioStreamPlayer:
	if stream == null or not is_instance_valid(_root):
		return null

	if _is_sfx_capacity_full():
		if sfx_overflow_policy == SFXOverflowPolicy.STOP_OLDEST:
			_stop_oldest_sfx()
		else:
			return null

	var pool := _get_pool_util()
	var player: AudioStreamPlayer = null
	if pool != null:
		player = pool.acquire(_sfx_scene, _root) as AudioStreamPlayer
	else:
		player = AudioStreamPlayer.new()
		player.name = "GFSFXPlayer"
		_root.add_child(player)

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
	return player


func _stop_audio_player(player: Node) -> void:
	if is_instance_valid(player) and player.has_method("stop"):
		player.call("stop")


func _queue_free_audio_player(player: Node) -> void:
	if is_instance_valid(player):
		player.queue_free()


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

	_untrack_sfx_player(player)
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
