## GFAudioSwitch: 通用音频开关请求。
##
## 表示某个对象或作用域上的开关组和值。
## [br]
## @api public
## [br]
## @category event_contract
## [br]
## @since 3.17.0
class_name GFAudioSwitch
extends Resource


# --- 导出变量 ---

## 开关组标识。
## [br]
## @api public
@export var group_id: StringName = &""

## 开关值标识。
## [br]
## @api public
@export var switch_id: StringName = &""

## 可选作用域标识。
## [br]
## @api public
@export var scope_id: StringName = &""

## 可选元数据。
## [br]
## @api public
## [br]
## @schema metadata: 音频开关元数据 Dictionary；键和值由后端或项目逻辑约定。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 转换为请求字典。
## [br]
## @api public
## [br]
## @return: 请求字典。
## [br]
## @schema return: 开关请求 Dictionary，包含 group_id、switch_id、scope_id 和 metadata 字段。
func to_dictionary() -> Dictionary:
	return {
		"group_id": group_id,
		"switch_id": switch_id,
		"scope_id": scope_id,
		"metadata": metadata.duplicate(true),
	}
