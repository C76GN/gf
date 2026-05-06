## GFInteractionContext: 一次交互流程的轻量上下文。
##
## 用于在 Command、事件或能力方法之间传递 sender、target、payload 与可选分组信息。
class_name GFInteractionContext
extends RefCounted


# --- 常量 ---

const _CAPABILITY_UTILITY_SCRIPT: Script = preload("res://addons/gf/extensions/capability/gf_capability_utility.gd")


# --- 公共变量 ---

## 交互发起者。
var sender: Object = null

## 交互目标。
var target: Object = null

## 交互携带的数据。
var payload: Variant = null

## 交互所属的可选分组。
var group_name: StringName = &""


# --- 私有变量 ---

var _architecture_ref: WeakRef = null


# --- Godot 生命周期方法 ---

func _init(
	p_sender: Object = null,
	p_target: Object = null,
	p_payload: Variant = null,
	p_group_name: StringName = &""
) -> void:
	sender = p_sender
	target = p_target
	payload = p_payload
	group_name = p_group_name


# --- 公共方法 ---

## 注入当前上下文所属架构。
## @param architecture: 用于依赖注入和能力查询的架构实例。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null


## 设置 sender 并返回自身，便于链式构造。
## @param value: 要写入或修改的值。
func with_sender(value: Object) -> GFInteractionContext:
	sender = value
	return self


## 设置 target 并返回自身，便于链式构造。
## @param value: 要写入或修改的值。
func with_target(value: Object) -> GFInteractionContext:
	target = value
	return self


## 设置 payload 并返回自身，便于链式构造。
## @param value: 要写入或修改的值。
func with_payload(value: Variant) -> GFInteractionContext:
	payload = value
	return self


## 设置 group_name 并返回自身，便于链式构造。
## @param value: 要写入或修改的值。
func with_group(value: StringName) -> GFInteractionContext:
	group_name = value
	return self


## 获取 sender 上的指定能力。
## @param capability_type: 要查询、添加或移除的能力脚本类型。
func get_sender_capability(capability_type: Script) -> Object:
	return get_capability(sender, capability_type)


## 获取 target 上的指定能力。
## @param capability_type: 要查询、添加或移除的能力脚本类型。
func get_target_capability(capability_type: Script) -> Object:
	return get_capability(target, capability_type)


## 获取任意 receiver 上的指定能力。
## @param receiver: 能力接收对象。
## @param capability_type: 要查询、添加或移除的能力脚本类型。
func get_capability(receiver: Object, capability_type: Script) -> Object:
	var capability_utility := _get_capability_utility()
	if capability_utility == null:
		return null
	return capability_utility.get_capability(receiver, capability_type)


## 获取当前 group_name 分组中的 receiver。
## @param capability_type: 要查询、添加或移除的能力脚本类型。
func get_group_receivers(capability_type: Script = null) -> Array[Object]:
	if group_name == &"":
		return [] as Array[Object]

	var capability_utility := _get_capability_utility()
	if capability_utility == null:
		return [] as Array[Object]

	if capability_type == null:
		return capability_utility.get_receivers_in_group(group_name)
	return capability_utility.get_receivers_in_group_with(group_name, capability_type)


# --- 私有/辅助方法 ---

func _get_capability_utility() -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(_CAPABILITY_UTILITY_SCRIPT)


func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	return GFAutoload.get_architecture_or_null()
