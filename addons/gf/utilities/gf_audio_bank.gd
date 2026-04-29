## GFAudioBank: 音频片段配置集合。
##
## 用 StringName 管理一组 `GFAudioClip`，便于 UI、表现动作或项目配置
## 通过稳定 ID 播放音频。
class_name GFAudioBank
extends Resource


# --- 导出变量 ---

## 音频片段表。Key 推荐使用 StringName，Value 应为 GFAudioClip。
@export var clips: Dictionary = {}


# --- 公共方法 ---

## 设置一个音频片段。
## @param clip_id: 片段标识。
## @param clip: 片段配置。
func set_clip(clip_id: StringName, clip: GFAudioClip) -> void:
	if clip_id == &"":
		push_error("[GFAudioBank] set_clip 失败：clip_id 为空。")
		return
	if clip == null:
		clips.erase(clip_id)
		return
	clips[clip_id] = clip


## 获取音频片段。
## @param clip_id: 片段标识。
## @return 片段配置；不存在时返回 null。
func get_clip(clip_id: StringName) -> GFAudioClip:
	return clips.get(clip_id) as GFAudioClip


## 检查是否存在指定片段。
## @param clip_id: 片段标识。
## @return 存在时返回 true。
func has_clip(clip_id: StringName) -> bool:
	return clips.has(clip_id) and clips[clip_id] is GFAudioClip

