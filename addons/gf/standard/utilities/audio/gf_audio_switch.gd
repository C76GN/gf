## GFAudioSwitch: 通用音频开关请求。
##
## 表示某个对象或作用域上的开关组和值。
class_name GFAudioSwitch
extends Resource


# --- 导出变量 ---

## 开关组标识。
@export var group_id: StringName = &""

## 开关值标识。
@export var switch_id: StringName = &""

## 可选作用域标识。
@export var scope_id: StringName = &""

## 可选元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 转换为请求字典。
## @return 请求字典。
func to_dictionary() -> Dictionary:
	return {
		"group_id": group_id,
		"switch_id": switch_id,
		"scope_id": scope_id,
		"metadata": metadata.duplicate(true),
	}
