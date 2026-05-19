## GFShakeReceiver2D: 将反馈采样应用到 Node2D 的通用接收器。
class_name GFShakeReceiver2D
extends Node


# --- 常量 ---

const _INSTANCE_GUARD: Script = preload("res://addons/gf/kernel/core/gf_instance_guard.gd")


# --- 导出变量 ---

## 目标 Node2D 路径；为空时优先使用自身，其次使用父节点。
@export_node_path("Node2D") var target_path: NodePath = NodePath("")

## 采样 channel。
@export var channel: StringName = &"default"

## 是否应用 position 偏移。
@export var apply_position: bool = true

## 是否应用 rotation_degrees 偏移。
@export var apply_rotation: bool = true

## 是否应用 scale 偏移。
@export var apply_scale: bool = false

## ready 时是否记录基础变换。
@export var capture_on_ready: bool = true

## 退出树时是否恢复基础变换。
@export var restore_on_exit: bool = true


# --- 公共变量 ---

## 可选反馈工具实例；为空时从全局架构查询。
var utility: GFShakeUtility = null


# --- 私有变量 ---

var _target_ref: WeakRef = null
var _base_position: Vector2 = Vector2.ZERO
var _base_rotation_degrees: float = 0.0
var _base_scale: Vector2 = Vector2.ONE
var _last_position_offset: Vector2 = Vector2.ZERO
var _last_rotation_offset: float = 0.0
var _last_scale_offset: Vector2 = Vector2.ZERO


# --- Godot 生命周期方法 ---

func _ready() -> void:
	_target_ref = weakref(_resolve_target())
	if capture_on_ready:
		capture_base_transform()


func _process(_delta: float) -> void:
	apply_current_sample()


func _exit_tree() -> void:
	if restore_on_exit:
		reset_to_base()


# --- 公共方法 ---

## 设置反馈工具实例。
## @param shake_utility: 反馈工具实例。
func set_utility(shake_utility: GFShakeUtility) -> void:
	utility = shake_utility


## 获取当前目标节点。
## @return 目标 Node2D；不存在时返回 null。
func get_target() -> Node2D:
	if _target_ref == null:
		return null
	var target: Node = _INSTANCE_GUARD._get_live_node_from_ref(_target_ref)
	return target as Node2D if target is Node2D else null


## 记录当前目标基础变换。
## @return 记录成功返回 true。
func capture_base_transform() -> bool:
	var target := get_target()
	if target == null:
		return false
	_base_position = target.position
	_base_rotation_degrees = target.rotation_degrees
	_base_scale = target.scale
	_last_position_offset = Vector2.ZERO
	_last_rotation_offset = 0.0
	_last_scale_offset = Vector2.ZERO
	return true


## 应用当前 channel 采样。
## @return 应用成功返回 true。
func apply_current_sample() -> bool:
	var target := get_target()
	var shake_utility := _get_utility()
	if target == null or shake_utility == null:
		return false

	var sample := shake_utility.sample_channel(channel)
	var position := sample.get("position", Vector3.ZERO) as Vector3
	var rotation_degrees := sample.get("rotation_degrees", Vector3.ZERO) as Vector3
	var scale := sample.get("scale", Vector3.ZERO) as Vector3
	if apply_position:
		var position_offset := Vector2(position.x, position.y)
		target.position = target.position - _last_position_offset + position_offset
		_last_position_offset = position_offset
	elif _last_position_offset != Vector2.ZERO:
		target.position -= _last_position_offset
		_last_position_offset = Vector2.ZERO
	if apply_rotation:
		target.rotation_degrees = target.rotation_degrees - _last_rotation_offset + rotation_degrees.z
		_last_rotation_offset = rotation_degrees.z
	elif not is_zero_approx(_last_rotation_offset):
		target.rotation_degrees -= _last_rotation_offset
		_last_rotation_offset = 0.0
	if apply_scale:
		var scale_offset := Vector2(scale.x, scale.y)
		target.scale = target.scale - _last_scale_offset + scale_offset
		_last_scale_offset = scale_offset
	elif _last_scale_offset != Vector2.ZERO:
		target.scale -= _last_scale_offset
		_last_scale_offset = Vector2.ZERO
	return true


## 恢复目标基础变换。
## @return 恢复成功返回 true。
func reset_to_base() -> bool:
	var target := get_target()
	if target == null:
		return false
	target.position -= _last_position_offset
	target.rotation_degrees -= _last_rotation_offset
	target.scale -= _last_scale_offset
	_base_position = target.position
	_base_rotation_degrees = target.rotation_degrees
	_base_scale = target.scale
	_last_position_offset = Vector2.ZERO
	_last_rotation_offset = 0.0
	_last_scale_offset = Vector2.ZERO
	return true


# --- 私有/辅助方法 ---

func _get_utility() -> GFShakeUtility:
	if utility != null:
		return utility
	var architecture := GFAutoload.get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(GFShakeUtility) as GFShakeUtility


func _resolve_target() -> Node2D:
	if target_path != NodePath(""):
		return get_node_or_null(target_path) as Node2D
	return get_parent() as Node2D
