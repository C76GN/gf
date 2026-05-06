## GFNode2DCapability: 可直接作为 2D 场景节点使用的能力组件基类。
##
## 适合承载需要 2D 变换、碰撞、输入或子节点引用的局部能力。
class_name GFNode2DCapability
extends Node2D


# --- 常量 ---

const _CAPABILITY_SUPPORT_SCRIPT: Script = preload("res://addons/gf/extensions/capability/gf_node_capability_support.gd")


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
	_architecture_ref = _CAPABILITY_SUPPORT_SCRIPT.make_architecture_ref(architecture)


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
## @param model_type: 要获取的 Model 脚本类型。
func get_model(model_type: Script) -> Object:
	return _CAPABILITY_SUPPORT_SCRIPT.get_model(_architecture_ref, model_type)


## 通过当前架构获取 System。
## @param system_type: 目标类型。
func get_system(system_type: Script) -> Object:
	return _CAPABILITY_SUPPORT_SCRIPT.get_system(_architecture_ref, system_type)


## 通过当前架构获取 Utility。
## @param utility_type: 要获取的 Utility 脚本类型。
func get_utility(utility_type: Script) -> Object:
	return _CAPABILITY_SUPPORT_SCRIPT.get_utility(_architecture_ref, utility_type)


## 获取当前 receiver 上的其他能力。
## @param capability_type: 要查询、添加或移除的能力脚本类型。
func get_capability(capability_type: Script) -> Object:
	return _CAPABILITY_SUPPORT_SCRIPT.get_capability(receiver, _architecture_ref, capability_type)


# --- 私有/辅助方法 ---

func _get_architecture_or_null() -> GFArchitecture:
	return _CAPABILITY_SUPPORT_SCRIPT.get_architecture_or_null(_architecture_ref)
