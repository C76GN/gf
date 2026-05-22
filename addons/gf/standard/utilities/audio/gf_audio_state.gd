## GFAudioState: 通用音频状态请求。
##
## 表示一个状态组和值，不解释其具体混音或播放含义。
## [br]
## @api public
## [br]
## @category event_contract
## [br]
## @since 3.17.0
class_name GFAudioState
extends Resource


# --- 导出变量 ---

## 状态组标识。
## [br]
## @api public
@export var group_id: StringName = &""

## 状态值标识。
## [br]
## @api public
@export var state_id: StringName = &""

## 可选元数据。
## [br]
## @api public
## [br]
## @schema metadata: 音频状态元数据 Dictionary；键和值由后端或项目逻辑约定。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 转换为请求字典。
## [br]
## @api public
## [br]
## @return: 请求字典。
## [br]
## @schema return: 状态请求 Dictionary，包含 group_id、state_id 和 metadata 字段。
func to_dictionary() -> Dictionary:
	return {
		"group_id": group_id,
		"state_id": state_id,
		"metadata": metadata.duplicate(true),
	}
