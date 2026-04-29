## GFSequenceContext: 指令序列执行上下文。
##
## 用于在一组序列步骤之间传递共享数据，并为步骤提供架构访问入口。
class_name GFSequenceContext
extends RefCounted


# --- 公共变量 ---

## 共享数据表。
var values: Dictionary = {}


# --- 私有变量 ---

var _architecture_ref: WeakRef = null


# --- Godot 生命周期方法 ---

func _init(architecture: GFArchitecture = null, p_values: Dictionary = {}) -> void:
	values = p_values.duplicate(true)
	set_architecture(architecture)


# --- 公共方法 ---

## 设置上下文所属架构。
## @param architecture: 架构实例。
func set_architecture(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null


## 获取上下文所属架构。
## @return 架构实例；不可用时返回 null。
func get_architecture() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	return GFAutoload.get_architecture_or_null()


## 写入共享值。
## @param key: 键。
## @param value: 值。
## @return 当前上下文，便于链式构造。
func set_value(key: StringName, value: Variant) -> GFSequenceContext:
	values[key] = value
	return self


## 读取共享值。
## @param key: 键。
## @param default_value: 默认值。
## @return 共享值或默认值。
func get_value(key: StringName, default_value: Variant = null) -> Variant:
	return values.get(key, default_value)
