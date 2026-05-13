## GFAudioParameter: 通用音频参数请求。
##
## 表示可写入音频后端的全局或对象级数值参数。
class_name GFAudioParameter
extends Resource


# --- 导出变量 ---

## 参数稳定标识。
@export var parameter_id: StringName = &""

## 参数值。
@export var value: float = 0.0

## 可选作用域标识。
@export var scope_id: StringName = &""

## 可选元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 转换为请求字典。
## @return 请求字典。
func to_dictionary() -> Dictionary:
	return {
		"parameter_id": parameter_id,
		"value": value,
		"scope_id": scope_id,
		"metadata": metadata.duplicate(true),
	}
