## GFNodeCapability: 可直接作为场景节点使用的能力组件基类。
##
## 适合承载需要碰撞、输入、动画或子节点引用的局部能力。
class_name GFNodeCapability
extends Node


# --- 常量 ---

const _CAPABILITY_UTILITY_SCRIPT: Script = preload("res://addons/gf/extensions/capability/gf_capability_utility.gd")


# --- 公共变量 ---

## 当前能力所属对象。由 GFCapabilityUtility 挂载时写入。
var receiver: Object = null

## 当前能力是否启用。请优先通过 GFCapabilityUtility.set_capability_active() 修改。
var active: bool = true


# --- 私有变量 ---

var _architecture_ref: WeakRef = null


# --- 公共方法 ---

## 注入当前能力所属架构。
## @param architecture: 当前架构实例。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null


## 返回当前能力依赖的其他能力类型。
## GFCapabilityUtility 会在挂载当前能力前先确保这些能力存在。
func get_required_capabilities() -> Array[Script]:
	return [] as Array[Script]


## 返回移除当前能力时对自动补齐依赖能力的处理策略。
func get_dependency_removal_policy() -> int:
	return GFCapabilityUtility.DependencyRemovalPolicy.KEEP_DEPENDENCIES


## 能力挂载到对象后调用。
## @param target: 当前能力所属对象。
func on_gf_capability_added(target: Object) -> void:
	receiver = target


## 能力从对象移除前调用。
## @param _target: 当前能力所属对象。
func on_gf_capability_removed(_target: Object) -> void:
	receiver = null


## 能力启停状态变化后调用。
## @param _target: 当前能力所属对象。
## @param _active: 当前启停状态。
func on_gf_capability_active_changed(_target: Object, _active: bool) -> void:
	pass


## 通过当前架构获取 Model。
func get_model(model_type: Script) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_model(model_type)


## 通过当前架构获取 System。
func get_system(system_type: Script) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_system(system_type)


## 通过当前架构获取 Utility。
func get_utility(utility_type: Script) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(utility_type)


## 获取当前 receiver 上的其他能力。
func get_capability(capability_type: Script) -> Object:
	if receiver == null:
		return null

	var capability_utility := get_utility(_CAPABILITY_UTILITY_SCRIPT)
	if capability_utility == null:
		return null

	return capability_utility.get_capability(receiver, capability_type)


# --- 私有/辅助方法 ---

func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	if Gf.has_architecture():
		return Gf.get_architecture()
	return null
