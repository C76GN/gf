## GFFlowContext: 通用流程图执行上下文。
##
## 用于在流程节点之间共享数据，并提供可选的 GFArchitecture 访问入口。
class_name GFFlowContext
extends RefCounted


# --- 公共变量 ---

## 共享数据表。
var values: Dictionary = {}

## 下一个节点覆盖。流程节点可写入该列表动态控制分支。
var next_node_ids: PackedStringArray = PackedStringArray()


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
func set_value(key: StringName, value: Variant) -> GFFlowContext:
	values[key] = value
	return self


## 读取共享值。
## @param key: 键。
## @param default_value: 默认值。
## @return 共享值或默认值。
func get_value(key: StringName, default_value: Variant = null) -> Variant:
	return values.get(key, default_value)


## 覆盖当前节点执行后的下一个节点列表。
## @param node_ids: 节点标识列表。
func set_next_nodes(node_ids: PackedStringArray) -> void:
	next_node_ids = node_ids.duplicate()


## 清空下一个节点覆盖。
func clear_next_nodes() -> void:
	next_node_ids.clear()
