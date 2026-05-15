## GFCameraRig3D: 通用 3D 相机姿态提供节点。
##
## Rig 只计算期望 Camera3D Transform，不直接控制 Camera3D。
## 项目可用多个 Rig 表达不同视角，再交给 GFCameraDirector3D 按优先级选择。
class_name GFCameraRig3D
extends Node3D


# --- 信号 ---

## Rig 激活状态变化后发出。
## @param active: 当前是否激活。
signal active_changed(active: bool)

## Rig 优先级变化后发出。
## @param priority: 当前优先级。
signal priority_changed(priority: int)


# --- 导出变量 ---

## 是否参与 Director 选择。
@export var active: bool = true:
	set(value):
		if active == value:
			return
		active = value
		active_changed.emit(active)

## 选择优先级。数值越大越优先。
@export var priority: int = 0:
	set(value):
		if priority == value:
			return
		priority = value
		priority_changed.emit(priority)

## 可选跟随目标。为空时使用 Rig 自身的全局姿态。
@export_node_path("Node3D") var target_path: NodePath = NodePath("")

## 可选朝向目标。look_at_enabled 为 true 时生效。
@export_node_path("Node3D") var look_at_target_path: NodePath = NodePath("")

## 位置偏移。
@export var offset: Vector3 = Vector3.ZERO

## 偏移是否跟随目标旋转。
@export var offset_follows_rotation: bool = false

## 是否读取目标旋转。
@export var use_target_rotation: bool = true

## 是否朝向 look_at_target_path。
@export var look_at_enabled: bool = false

## look_at 使用的上方向。为零向量时会回退到 Vector3.UP。
@export var up_axis: Vector3 = Vector3.UP

## 额外旋转偏移，单位度。
@export var rotation_degrees_offset: Vector3 = Vector3.ZERO

## 进入该 Rig 时使用的过渡。为空时使用 Director 默认过渡。
@export var blend: GFCameraBlend = null

## 自动加入的分组名。Director 可按该分组收集候选。
@export var group_name: StringName = &"gf_camera_rig_3d"

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	if group_name != &"":
		add_to_group(group_name)


func _exit_tree() -> void:
	if group_name != &"":
		remove_from_group(group_name)


# --- 公共方法 ---

## 获取跟随目标。
## @return 目标 Node3D；不存在时返回 null。
func get_target_node() -> Node3D:
	if target_path.is_empty():
		return null
	return get_node_or_null(target_path) as Node3D


## 获取朝向目标。
## @return 目标 Node3D；不存在时返回 null。
func get_look_at_target_node() -> Node3D:
	if look_at_target_path.is_empty():
		return null
	return get_node_or_null(look_at_target_path) as Node3D


## 获取当前期望相机 Transform。
## @return 期望全局 Transform。
func get_camera_transform() -> Transform3D:
	var target := get_target_node()
	var transform := global_transform
	if target != null:
		transform.origin = target.global_transform.origin
		if use_target_rotation:
			transform.basis = target.global_transform.basis

	var effective_offset := transform.basis * offset if offset_follows_rotation else offset
	transform.origin += effective_offset
	if look_at_enabled:
		var look_at_target := get_look_at_target_node()
		if look_at_target != null and not transform.origin.is_equal_approx(look_at_target.global_position):
			transform = transform.looking_at(look_at_target.global_position, _get_safe_up_axis())
	if rotation_degrees_offset != Vector3.ZERO:
		transform.basis = transform.basis.rotated(transform.basis.x.normalized(), deg_to_rad(rotation_degrees_offset.x))
		transform.basis = transform.basis.rotated(transform.basis.y.normalized(), deg_to_rad(rotation_degrees_offset.y))
		transform.basis = transform.basis.rotated(transform.basis.z.normalized(), deg_to_rad(rotation_degrees_offset.z))
	return transform


## 检查 Rig 是否可被选择。
## @return 可用时返回 true。
func is_available() -> bool:
	return active and is_inside_tree()


# --- 私有/辅助方法 ---

func _get_safe_up_axis() -> Vector3:
	if up_axis.length_squared() <= 0.000001:
		return Vector3.UP
	return up_axis.normalized()

