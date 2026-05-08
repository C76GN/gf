## GFAudioBank: 音频片段配置集合。
##
## 用 StringName 管理一组 `GFAudioClip`，便于 UI、表现动作或项目配置
## 通过稳定 ID 播放音频。单个 ID 可保存一个片段或多个候选片段。
class_name GFAudioBank
extends Resource


# --- 导出变量 ---

## 音频片段表。Key 推荐使用 StringName，Value 可为 GFAudioClip 或 GFAudioClip 数组。
@export var clips: Dictionary = {}

## 分层事件 ID 的回退分隔符。例如 `ui+confirm+primary` 可回退到 `ui+confirm` 再到 `ui`。
@export var fallback_separator: String = "+"


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


## 设置一个音频片段候选列表。
## @param clip_id: 片段标识。
## @param clip_list: 片段候选列表。
func set_clips(clip_id: StringName, clip_list: Array[GFAudioClip]) -> void:
	if clip_id == &"":
		push_error("[GFAudioBank] set_clips 失败：clip_id 为空。")
		return

	var valid_clips: Array[GFAudioClip] = []
	for clip: GFAudioClip in clip_list:
		if clip != null:
			valid_clips.append(clip)
	if valid_clips.is_empty():
		clips.erase(clip_id)
		return
	clips[clip_id] = valid_clips


## 获取音频片段。
## @param clip_id: 片段标识。
## @return 片段配置；多个候选时返回第一个有效片段，不存在时返回 null。
func get_clip(clip_id: StringName) -> GFAudioClip:
	var clip_list := get_clips(clip_id)
	if clip_list.is_empty():
		return null
	return clip_list[0]


## 获取音频片段候选列表。
## @param clip_id: 片段标识。
## @return 片段候选列表。
func get_clips(clip_id: StringName) -> Array[GFAudioClip]:
	var result: Array[GFAudioClip] = []
	var raw_value: Variant = clips.get(clip_id)
	if raw_value is GFAudioClip:
		result.append(raw_value as GFAudioClip)
	elif raw_value is Array:
		for clip_variant: Variant in raw_value:
			if clip_variant is GFAudioClip:
				result.append(clip_variant as GFAudioClip)
	return result


## 按候选权重获取片段。
## @param clip_id: 片段标识。
## @param rng: 可选随机数生成器；为空时返回第一个有效片段。
## @return 片段配置；不存在时返回 null。
func get_weighted_clip(clip_id: StringName, rng: RandomNumberGenerator = null) -> GFAudioClip:
	var clip_list := get_clips(clip_id)
	if clip_list.is_empty():
		return null
	if rng == null or clip_list.size() == 1:
		return clip_list[0]

	var total_weight := 0.0
	for clip: GFAudioClip in clip_list:
		total_weight += maxf(clip.weight, 0.0)
	if total_weight <= 0.0:
		return clip_list[0]

	var cursor := rng.randf_range(0.0, total_weight)
	for clip: GFAudioClip in clip_list:
		cursor -= maxf(clip.weight, 0.0)
		if cursor <= 0.0:
			return clip
	return clip_list[clip_list.size() - 1]


## 按 ID 获取片段；找不到时按 fallback_separator 逐级回退。
## @param clip_id: 片段标识。
## @param rng: 可选随机数生成器。
## @return 片段配置；不存在时返回 null。
func get_clip_with_fallback(clip_id: StringName, rng: RandomNumberGenerator = null) -> GFAudioClip:
	var clip := get_weighted_clip(clip_id, rng)
	if clip != null:
		return clip

	var separator := fallback_separator
	if separator.is_empty():
		return null

	var parts := String(clip_id).split(separator, false)
	while parts.size() > 1:
		parts.remove_at(parts.size() - 1)
		var fallback_id := StringName(separator.join(parts))
		clip = get_weighted_clip(fallback_id, rng)
		if clip != null:
			return clip
	return null


## 检查是否存在指定片段。
## @param clip_id: 片段标识。
## @return 存在时返回 true。
func has_clip(clip_id: StringName) -> bool:
	return not get_clips(clip_id).is_empty()
