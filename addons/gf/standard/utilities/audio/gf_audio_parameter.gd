## GFAudioParameter: 通用音频参数请求。
##
## 表示可写入音频后端的全局或对象级数值参数。
## [br]
## @api public
## [br]
## @category event_contract
## [br]
## @since 3.17.0
class_name GFAudioParameter
extends Resource


# --- 导出变量 ---

## 参数稳定标识。
## [br]
## @api public
@export var parameter_id: StringName = &""

## 参数值。
## [br]
## @api public
@export var value: float = 0.0

## 可选作用域标识。
## [br]
## @api public
@export var scope_id: StringName = &""

## 可选元数据。
## [br]
## @api public
## [br]
## @schema metadata: 音频参数元数据 Dictionary；键和值由后端或项目逻辑约定。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 转换为请求字典。
## [br]
## @api public
## [br]
## @return: 请求字典。
## [br]
## @schema return: 参数请求 Dictionary，包含 parameter_id、value、scope_id 和 metadata 字段。
func to_dictionary() -> Dictionary:
	return {
		"parameter_id": parameter_id,
		"value": value,
		"scope_id": scope_id,
		"metadata": metadata.duplicate(true),
	}
