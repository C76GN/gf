## GFAudioState: 通用音频状态请求。
##
## 表示一个状态组和值，不解释其具体混音或播放含义。
class_name GFAudioState
extends Resource


# --- 导出变量 ---

## 状态组标识。
@export var group_id: StringName = &""

## 状态值标识。
@export var state_id: StringName = &""

## 可选元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 转换为请求字典。
## @return 请求字典。
func to_dictionary() -> Dictionary:
	return {
		"group_id": group_id,
		"state_id": state_id,
		"metadata": metadata.duplicate(true),
	}
