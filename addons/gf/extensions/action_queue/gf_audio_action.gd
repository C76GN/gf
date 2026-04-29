## GFAudioAction: 将一次 SFX 播放包装为视觉队列动作。
##
## 音效通常不应该阻塞表现队列，因此默认使用 fire-and-forget 完成模式。
class_name GFAudioAction
extends GFVisualAction


# --- 公共变量 ---

## 要播放的音频资源路径。
var path: String = ""

## 要播放的音频片段配置。优先级高于 path。
var clip: GFAudioClip = null

## 要播放的音频集合。与 clip_id 配合使用，优先级高于 clip。
var bank: GFAudioBank = null

## 音频集合中的片段标识。
var clip_id: StringName = &""


# --- Godot 生命周期方法 ---

func _init(p_path: String = "", p_clip: GFAudioClip = null) -> void:
	path = p_path
	clip = p_clip
	completion_mode = CompletionMode.FIRE_AND_FORGET


# --- 公共方法 ---

## 执行动作并通过 GFAudioUtility 播放一次 SFX。
## @return 始终返回 null，避免阻塞表现队列。
func execute() -> Variant:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null

	var audio := architecture.get_utility(GFAudioUtility) as GFAudioUtility
	if audio == null:
		return null

	if bank != null and clip_id != &"":
		audio.play_sfx_from_bank(bank, clip_id)
	elif clip != null:
		audio.play_sfx_clip(clip)
	elif not path.is_empty():
		audio.play_sfx(path)

	return null
