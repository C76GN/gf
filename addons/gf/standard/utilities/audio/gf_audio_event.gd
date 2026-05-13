## GFAudioEvent: 通用资源化音频事件。
##
## 描述一个可以交给 `GFAudioUtility` 或音频后端处理的事件请求。
class_name GFAudioEvent
extends Resource


# --- 导出变量 ---

## 事件稳定标识。
@export var event_id: StringName = &""

## 事件通道，例如 bgm、sfx、ambient。
@export var channel: StringName = &"sfx"

## 可选音频集合标识。
@export var bank_id: StringName = &""

## 可选资源路径或后端事件路径。
@export var path: String = ""

## 可选音频片段。
@export var clip: GFAudioClip = null

## 可选环境音通道。
@export var ambient_channel: StringName = &"default"

## 可选元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查事件是否有可请求内容。
## @return 有事件 ID、路径或片段时返回 true。
func has_request() -> bool:
	return event_id != &"" or not path.is_empty() or clip != null


## 转换为请求选项。
## @param extra_options: 额外选项。
## @return 请求选项字典。
func to_request_options(extra_options: Dictionary = {}) -> Dictionary:
	var result := metadata.duplicate(true)
	for key: Variant in extra_options.keys():
		result[key] = extra_options[key]
	result["event_id"] = event_id
	result["channel"] = channel
	result["bank_id"] = bank_id
	result["path"] = path
	result["ambient_channel"] = ambient_channel
	return result
