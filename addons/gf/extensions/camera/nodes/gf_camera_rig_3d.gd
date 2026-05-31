## GFCameraRig3D: 通用 3D 相机姿态提供节点。
##
## Rig 只计算期望 Camera3D Transform，不直接控制 Camera3D。
## 项目可用多个 Rig 表达不同视角，再交给 GFCameraDirector3D 按优先级选择。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFCameraRig3D
extends Node3D


# --- 信号 ---

## Rig 激活状态变化后发出。
## [br]
## @api public
## [br]
## @param active: 当前是否激活。
signal active_changed(active: bool)

## Rig 优先级变化后发出。
## [br]
## @api public
## [br]
## @param priority: 当前优先级。
signal priority_changed(priority: int)


# --- 导出变量 ---

## 是否参与 Director 选择。
## [br]
## @api public
@export var active: bool = true:
	set(value):
		if active == value:
			return
		active = value
		active_changed.emit(active)

## 选择优先级。数值越大越优先。
## [br]
## @api public
@export var priority: int = 0:
	set(value):
		if priority == value:
			return
		priority = value
		priority_changed.emit(priority)

## 可选跟随目标。为空时使用 Rig 自身的全局姿态。
## [br]
## @api public
@export_node_path("Node3D") var target_path: NodePath = NodePath("")

## 可选朝向目标。look_at_enabled 为 true 时生效。
## [br]
## @api public
@export_node_path("Node3D") var look_at_target_path: NodePath = NodePath("")

## 位置偏移。
## [br]
## @api public
@export var offset: Vector3 = Vector3.ZERO

## 偏移是否跟随目标旋转。
## [br]
## @api public
@export var offset_follows_rotation: bool = false

## 是否读取目标旋转。
## [br]
## @api public
@export var use_target_rotation: bool = true

## 是否朝向 look_at_target_path。
## [br]
## @api public
@export var look_at_enabled: bool = false

## look_at 使用的上方向。为零向量时会回退到 Vector3.UP。
## [br]
## @api public
@export var up_axis: Vector3 = Vector3.UP

## 额外旋转偏移，单位度。
## [br]
## @api public
@export var rotation_degrees_offset: Vector3 = Vector3.ZERO

## 进入该 Rig 时使用的过渡。为空时使用 Director 默认过渡。
## [br]
## @api public
@export var blend: GFCameraBlend = null

## 自动加入的分组名。Director 可按该分组收集候选。
## [br]
## @api public
@export var group_name: StringName = &"gf_camera_rig_3d"

## 项目自定义元数据。框架不解释该字段。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，项目自定义元数据；框架不会读取或改写其中字段。
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
## [br]
## @api public
## [br]
## @return 目标 Node3D；不存在时返回 null。
func get_target_node() -> Node3D:
	if target_path.is_empty():
		return null
	return _get_node_3d_value(get_node_or_null(target_path))


## 获取朝向目标。
## [br]
## @api public
## [br]
## @return 目标 Node3D；不存在时返回 null。
func get_look_at_target_node() -> Node3D:
	if look_at_target_path.is_empty():
		return null
	return _get_node_3d_value(get_node_or_null(look_at_target_path))


## 获取当前期望相机 Transform。
## [br]
## @api public
## [br]
## @return 期望全局 Transform。
func get_camera_transform() -> Transform3D:
	var target: Node3D = get_target_node()
	var camera_transform: Transform3D = global_transform
	if target != null:
		camera_transform.origin = target.global_transform.origin
		if use_target_rotation:
			camera_transform.basis = target.global_transform.basis

	var effective_offset: Vector3 = camera_transform.basis * offset if offset_follows_rotation else offset
	camera_transform.origin += effective_offset
	if look_at_enabled:
		var look_at_target: Node3D = get_look_at_target_node()
		if look_at_target != null and not camera_transform.origin.is_equal_approx(look_at_target.global_position):
			camera_transform = camera_transform.looking_at(look_at_target.global_position, _get_safe_up_axis())
	if rotation_degrees_offset != Vector3.ZERO:
		camera_transform.basis = camera_transform.basis.rotated(camera_transform.basis.x.normalized(), deg_to_rad(rotation_degrees_offset.x))
		camera_transform.basis = camera_transform.basis.rotated(camera_transform.basis.y.normalized(), deg_to_rad(rotation_degrees_offset.y))
		camera_transform.basis = camera_transform.basis.rotated(camera_transform.basis.z.normalized(), deg_to_rad(rotation_degrees_offset.z))
	return camera_transform


## 检查 Rig 是否可被选择。
## [br]
## @api public
## [br]
## @return 可用时返回 true。
func is_available() -> bool:
	return active and is_inside_tree()


# --- 私有/辅助方法 ---

func _get_safe_up_axis() -> Vector3:
	if up_axis.length_squared() <= 0.000001:
		return Vector3.UP
	return up_axis.normalized()


func _get_node_3d_value(value: Variant) -> Node3D:
	if value is Node3D:
		var node: Node3D = value
		return node
	return null
