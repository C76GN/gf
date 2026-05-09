## GFAudioEmitterHandle: 一次音频播放的轻量控制句柄。
##
## 句柄只包装底层 AudioStreamPlayer 节点的通用生命周期和播放属性，
## 不规定音频事件、混音策略或业务含义。
class_name GFAudioEmitterHandle
extends RefCounted


# --- 信号 ---

## 句柄绑定到底层播放器时发出。
## @param handle: 当前句柄。
## @param player: 绑定的播放器节点。
signal player_attached(handle: GFAudioEmitterHandle, player: Node)

## 句柄主动停止并释放绑定时发出。
## @param handle: 当前句柄。
signal stopped(handle: GFAudioEmitterHandle)


# --- 公共变量 ---

## 可选通道标识。框架不解释该字段。
var channel: StringName = &""

## 项目自定义元数据。框架不解释该字段。
var metadata: Dictionary = {}


# --- 私有变量 ---

var _player_ref: WeakRef = null
var _release_callback: Callable = Callable()
var _stop_requested: bool = false
var _pending_stop_fade_seconds: float = 0.0
var _fade_tween_ref: WeakRef = null
var _owner_ref: WeakRef = null
var _owner_exit_callback: Callable = Callable()
var _owner_stop_fade_seconds: float = 0.0


# --- Godot 生命周期方法 ---

func _init(
	player: Node = null,
	release_callback: Callable = Callable(),
	p_channel: StringName = &"",
	p_metadata: Dictionary = {}
) -> void:
	_release_callback = release_callback
	channel = p_channel
	metadata = p_metadata.duplicate(true)
	if player != null:
		set_player(player)


# --- 公共方法 ---

## 绑定底层播放器。
## @param player: 要绑定的播放器节点。
func set_player(player: Node) -> void:
	_player_ref = weakref(player) if player != null else null
	if player != null:
		player_attached.emit(self, player)
	if _stop_requested:
		stop(_pending_stop_fade_seconds)


## 设置释放回调。
## @param release_callback: 停止完成时调用的释放回调。
func set_release_callback(release_callback: Callable) -> void:
	_release_callback = release_callback


## 绑定一个拥有者节点，节点退出树时自动停止当前播放。
## @param owner: 生命周期拥有者。
## @param fade_seconds: 自动停止时使用的淡出秒数。
func bind_to_owner(owner: Node, fade_seconds: float = 0.0) -> void:
	_disconnect_owner_exit()
	if owner == null:
		return

	_owner_ref = weakref(owner)
	_owner_stop_fade_seconds = maxf(fade_seconds, 0.0)
	_owner_exit_callback = Callable(self, "_on_owner_tree_exiting")
	if not owner.tree_exiting.is_connected(_owner_exit_callback):
		owner.tree_exiting.connect(_owner_exit_callback)


## 取消拥有者生命周期绑定。
func unbind_owner() -> void:
	_disconnect_owner_exit()


## 获取底层播放器。
## @return 播放器节点；不存在或已释放时返回 null。
func get_player() -> Node:
	if _player_ref == null:
		return null
	return _player_ref.get_ref() as Node


## 检查句柄是否仍绑定有效播放器。
## @return 有效时返回 true。
func is_valid() -> bool:
	return get_player() != null


## 检查播放器是否正在播放。
## @return 正在播放时返回 true。
func is_playing() -> bool:
	var player := get_player()
	return player != null and bool(player.get("playing"))


## 停止播放；传入淡出秒数时先淡出再释放。
## @param fade_seconds: 淡出秒数。
func stop(fade_seconds: float = 0.0) -> void:
	_stop_requested = true
	_pending_stop_fade_seconds = maxf(fade_seconds, 0.0)
	var player := get_player()
	if player == null:
		return

	if _pending_stop_fade_seconds > 0.0 and bool(player.get("playing")):
		fade_to(-80.0, _pending_stop_fade_seconds)
		var tween := _fade_tween_ref.get_ref() as Tween if _fade_tween_ref != null else null
		if tween != null:
			tween.finished.connect(_finish_stop.bind(player), CONNECT_ONE_SHOT)
			return

	_finish_stop(player)


## 淡入淡出到指定音量。
## @param volume_db: 目标音量，单位 dB。
## @param fade_seconds: 淡入淡出秒数。
func fade_to(volume_db: float, fade_seconds: float) -> void:
	var player := get_player()
	if player == null:
		return
	if fade_seconds <= 0.0:
		player.set("volume_db", volume_db)
		return

	var tween := player.create_tween()
	_fade_tween_ref = weakref(tween)
	tween.tween_property(player, "volume_db", volume_db, maxf(fade_seconds, 0.0))


## 设置当前音量。
## @param volume_db: 音量，单位 dB。
func set_volume_db(volume_db: float) -> void:
	var player := get_player()
	if player != null:
		player.set("volume_db", volume_db)


## 获取当前音量。
## @return 音量，单位 dB；无播放器时返回 0。
func get_volume_db() -> float:
	var player := get_player()
	return float(player.get("volume_db")) if player != null else 0.0


## 设置当前音高。
## @param pitch_scale: 音高缩放。
func set_pitch_scale(pitch_scale: float) -> void:
	var player := get_player()
	if player != null:
		player.set("pitch_scale", pitch_scale)


## 获取当前音高。
## @return 音高缩放；无播放器时返回 1。
func get_pitch_scale() -> float:
	var player := get_player()
	return float(player.get("pitch_scale")) if player != null else 1.0


## 获取调试快照。
## @return 调试快照。
func get_debug_snapshot() -> Dictionary:
	var player := get_player()
	return {
		"valid": player != null,
		"playing": bool(player.get("playing")) if player != null else false,
		"channel": String(channel),
		"volume_db": float(player.get("volume_db")) if player != null else 0.0,
		"pitch_scale": float(player.get("pitch_scale")) if player != null else 1.0,
		"owner_valid": _get_owner() != null,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _finish_stop(player: Node) -> void:
	if player == null:
		_player_ref = null
		_disconnect_owner_exit()
		stopped.emit(self)
		return

	if is_instance_valid(player) and player.has_method("stop"):
		player.call("stop")
	if is_instance_valid(player) and _release_callback.is_valid():
		_release_callback.call(player)
	_player_ref = null
	_disconnect_owner_exit()
	stopped.emit(self)


func _get_owner() -> Node:
	if _owner_ref == null:
		return null
	return _owner_ref.get_ref() as Node


func _disconnect_owner_exit() -> void:
	var owner := _get_owner()
	if owner != null and _owner_exit_callback.is_valid():
		if owner.tree_exiting.is_connected(_owner_exit_callback):
			owner.tree_exiting.disconnect(_owner_exit_callback)
	_owner_ref = null
	_owner_exit_callback = Callable()
	_owner_stop_fade_seconds = 0.0


func _on_owner_tree_exiting() -> void:
	var fade_seconds := _owner_stop_fade_seconds
	_owner_ref = null
	_owner_exit_callback = Callable()
	_owner_stop_fade_seconds = 0.0
	stop(fade_seconds)
