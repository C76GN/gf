## GFNodeAudioStreamPlayerSerializer: AudioStreamPlayer 通用播放状态序列化器。
##
## 支持 AudioStreamPlayer、AudioStreamPlayer2D 与 AudioStreamPlayer3D 的通用播放参数。
class_name GFNodeAudioStreamPlayerSerializer
extends GFNodeSerializer


# --- 常量 ---

const _OPTIONAL_PROPERTIES: PackedStringArray = [
	"stream_paused",
	"volume_db",
	"pitch_scale",
	"bus",
	"max_distance",
	"attenuation",
]


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.audio_stream_player"
	display_name = "Audio Stream Player"


# --- 公共方法 ---

## 判断序列化器是否支持指定节点。
## @param node: 目标节点。
func supports_node(node: Node) -> bool:
	return node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D


## 采集节点的可保存状态。
## @param node: 目标节点。
## @param _context: 操作上下文字典，默认实现不直接使用。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	if not supports_node(node):
		return {}

	var result := {
		"playing": bool(node.call("is_playing")) if node.has_method("is_playing") else false,
		"playback_position": float(node.call("get_playback_position")) if node.has_method("get_playback_position") else 0.0,
	}
	_copy_properties_to_payload(node, result, _OPTIONAL_PROPERTIES)
	return result


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	if not supports_node(node):
		return make_result(false, "Node is not AudioStreamPlayer.")

	_apply_properties_from_payload(node, payload, PackedStringArray([
		"volume_db",
		"pitch_scale",
		"bus",
		"max_distance",
		"attenuation",
	]))

	var should_play := bool(payload.get("playing", false))
	var should_pause := bool(payload.get("stream_paused", false))
	if (should_play or should_pause) and node.has_method("play") and _can_start_playback(node):
		node.call("play", maxf(float(payload.get("playback_position", 0.0)), 0.0))
	elif not should_play and not should_pause and node.has_method("stop"):
		node.call("stop")

	_apply_property_from_payload(node, payload, "stream_paused")
	return make_result(true)


# --- 私有/辅助方法 ---


func _can_start_playback(node: Object) -> bool:
	if not _has_property(node, "stream"):
		return true
	return node.get("stream") != null
