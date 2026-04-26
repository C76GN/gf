## GFAudioAction: 将一次 SFX 播放包装为视觉队列动作。
##
## 音效通常不应该阻塞表现队列，因此默认使用 fire-and-forget 完成模式。
class_name GFAudioAction
extends GFVisualAction


# --- 公共变量 ---

## 要播放的音频资源路径。
var path: String = ""


# --- Godot 生命周期方法 ---

func _init(p_path: String = "") -> void:
	path = p_path
	completion_mode = CompletionMode.FIRE_AND_FORGET


# --- 公共方法 ---

func execute() -> Variant:
	if path.is_empty() or not Gf.has_architecture():
		return null

	var audio := Gf.get_utility(GFAudioUtility) as GFAudioUtility
	if audio != null:
		audio.play_sfx(path)

	return null
