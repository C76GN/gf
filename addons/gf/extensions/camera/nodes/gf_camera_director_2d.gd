## GFCameraDirector2D: 通用 2D 相机编排节点。
##
## Director 从显式路径或分组中收集 GFCameraRig2D，按优先级选择当前 Rig，
## 并把过渡后的姿态应用到 Camera2D。它不规定目标含义、输入来源或业务流程。
class_name GFCameraDirector2D
extends Node


# --- 信号 ---

## 当前 Rig 变化后发出。
## @param previous_rig: 上一个 Rig。
## @param new_rig: 新 Rig。
signal active_rig_changed(previous_rig: Node, new_rig: Node)

## 相机姿态应用后发出。
## @param rig: 当前 Rig。
signal camera_pose_applied(rig: Node)


# --- 枚举 ---

## Director 自动更新模式。
enum UpdateMode {
	## 在 _process 中更新。
	IDLE,
	## 在 _physics_process 中更新。
	PHYSICS,
	## 只在 process_camera() 被显式调用时更新。
	MANUAL,
}


# --- 导出变量 ---

## 要控制的 Camera2D。
@export_node_path("Camera2D") var camera_path: NodePath = NodePath("")

## 显式候选 Rig 路径。
@export var rig_paths: Array[NodePath] = []

## 是否按分组收集候选 Rig。
@export var collect_group_rigs: bool = true

## 候选 Rig 分组名。
@export var rig_group_name: StringName = &"gf_camera_rig_2d"

## 自动更新模式。
@export var update_mode: UpdateMode = UpdateMode.IDLE

## 默认过渡资源。Rig 没有设置 blend 时使用它。
@export var default_blend: GFCameraBlend = GFCameraBlend.new()

## 没有 Rig 时是否保持相机当前姿态。
@export var keep_camera_when_no_rig: bool = true


# --- 私有变量 ---

var _active_rig: GFCameraRig2D = null
var _blend: GFCameraBlend = null
var _blend_elapsed_seconds: float = 0.0
var _blend_from_pose: Dictionary = {}
var _is_blending: bool = false


# --- Godot 生命周期方法 ---

func _process(delta: float) -> void:
	if update_mode == UpdateMode.IDLE:
		process_camera(delta)


func _physics_process(delta: float) -> void:
	if update_mode == UpdateMode.PHYSICS:
		process_camera(delta)


# --- 公共方法 ---

## 获取当前相机。
## @return Camera2D；不存在时返回 null。
func get_camera() -> Camera2D:
	if camera_path.is_empty():
		return null
	return get_node_or_null(camera_path) as Camera2D


## 获取当前激活 Rig。
## @return 当前 Rig；没有时返回 null。
func get_active_rig() -> GFCameraRig2D:
	return _active_rig


## 收集候选 Rig。
## @return 候选 Rig 列表。
func collect_candidate_rigs() -> Array[GFCameraRig2D]:
	var result: Array[GFCameraRig2D] = []
	var seen: Dictionary = {}
	for rig_path: NodePath in rig_paths:
		var rig := get_node_or_null(rig_path) as GFCameraRig2D
		_append_unique_rig(result, seen, rig)

	if collect_group_rigs and is_inside_tree() and rig_group_name != &"":
		for node: Node in get_tree().get_nodes_in_group(rig_group_name):
			_append_unique_rig(result, seen, node as GFCameraRig2D)
	result.sort_custom(_sort_rigs)
	return result


## 刷新当前激活 Rig。
## @param force_snap: 为 true 时立即切到新 Rig。
## @return 当前 Rig。
func refresh_active_rig(force_snap: bool = false) -> GFCameraRig2D:
	var best_rig: GFCameraRig2D = null
	for rig: GFCameraRig2D in collect_candidate_rigs():
		if rig != null and rig.is_available():
			best_rig = rig
			break
	set_active_rig(best_rig, force_snap)
	return _active_rig


## 显式设置当前 Rig。
## @param rig: 新 Rig；可为 null。
## @param force_snap: 为 true 时立即切换。
## @return 设置成功返回 true。
func set_active_rig(rig: GFCameraRig2D, force_snap: bool = false) -> bool:
	if rig == _active_rig:
		if force_snap:
			_prepare_blend(true)
		return true
	var previous := _active_rig
	_active_rig = rig
	_prepare_blend(force_snap)
	active_rig_changed.emit(previous, _active_rig)
	return true


## 推进并应用相机姿态。
## @param delta: 秒。
## @return 成功应用时返回 true。
func process_camera(delta: float) -> bool:
	refresh_active_rig(false)
	var camera := get_camera()
	if camera == null:
		return false
	if _active_rig == null:
		return keep_camera_when_no_rig

	var target_pose := _active_rig.get_camera_pose()
	var pose := target_pose
	if _is_blending:
		_blend_elapsed_seconds += maxf(delta, 0.0)
		var weight := _blend.sample_weight(_blend_elapsed_seconds) if _blend != null else 1.0
		pose = _interpolate_pose(_blend_from_pose, target_pose, weight)
		if weight >= 1.0:
			_is_blending = false

	_apply_pose(camera, pose)
	camera_pose_applied.emit(_active_rig)
	return true


# --- 私有/辅助方法 ---

func _prepare_blend(force_snap: bool) -> void:
	var camera := get_camera()
	_blend = _active_rig.blend if _active_rig != null and _active_rig.blend != null else default_blend
	_blend_elapsed_seconds = 0.0
	_blend_from_pose = _get_camera_pose(camera)
	_is_blending = (
		not force_snap
		and camera != null
		and _active_rig != null
		and _blend != null
		and not _blend.is_instant()
	)


func _get_camera_pose(camera: Camera2D) -> Dictionary:
	if camera == null:
		return {
			"position": Vector2.ZERO,
			"rotation": 0.0,
			"zoom": Vector2.ONE,
		}
	return {
		"position": camera.global_position,
		"rotation": camera.global_rotation,
		"zoom": camera.zoom,
	}


func _interpolate_pose(from_pose: Dictionary, to_pose: Dictionary, weight: float) -> Dictionary:
	var safe_weight := clampf(weight, 0.0, 1.0)
	var from_position: Vector2 = from_pose.get("position", Vector2.ZERO)
	var to_position: Vector2 = to_pose.get("position", Vector2.ZERO)
	var from_zoom: Vector2 = from_pose.get("zoom", Vector2.ONE)
	var to_zoom: Vector2 = to_pose.get("zoom", Vector2.ONE)
	return {
		"position": from_position.lerp(to_position, safe_weight),
		"rotation": lerp_angle(float(from_pose.get("rotation", 0.0)), float(to_pose.get("rotation", 0.0)), safe_weight),
		"zoom": from_zoom.lerp(to_zoom, safe_weight),
		"rig": to_pose.get("rig", null),
	}


func _apply_pose(camera: Camera2D, pose: Dictionary) -> void:
	camera.global_position = pose.get("position", camera.global_position)
	camera.global_rotation = float(pose.get("rotation", camera.global_rotation))
	camera.zoom = pose.get("zoom", camera.zoom)


func _append_unique_rig(result: Array[GFCameraRig2D], seen: Dictionary, rig: GFCameraRig2D) -> void:
	if rig == null:
		return
	var instance_id := rig.get_instance_id()
	if seen.has(instance_id):
		return
	seen[instance_id] = true
	result.append(rig)


func _sort_rigs(left: GFCameraRig2D, right: GFCameraRig2D) -> bool:
	if left.priority != right.priority:
		return left.priority > right.priority
	return left.get_instance_id() < right.get_instance_id()
