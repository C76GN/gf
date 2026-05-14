## GFProjectileEmitter3D: 通用 3D 发射体生成节点。
##
## 负责按场景目录和生成点模式实例化发射体，并把本次发射上下文交给
## 发射体的 launch()。它不解释伤害、阵营、弹药、冷却或特效规则。
class_name GFProjectileEmitter3D
extends Node3D


# --- 信号 ---

## 发射体已生成。
## @param projectile: 生成的发射体节点。
## @param projectile_context: 本次发射上下文。
signal projectile_emitted(projectile: Node, projectile_context: Dictionary)

## 发射失败时发出。
## @param reason: 失败原因。
## @param details: 失败细节。
signal projectile_emit_failed(reason: StringName, details: Dictionary)


# --- 导出变量 ---

## 默认发射体场景。未使用目录或目录缺少 ID 时使用。
@export var projectile_scene: PackedScene = null

## 可选发射体目录。
@export var projectile_catalog: GFProjectileCatalog = null

## 默认目录 ID。
@export var default_projectile_id: StringName = &""

## 3D 发射点模式。为空时使用发射器自身全局变换。
@export var spawn_pattern: GFProjectileSpawnPattern3D = null

## 默认上下文。每次发射会深拷贝后再合并调用方上下文。
@export var default_context: Dictionary = {}

## 可选生成父节点路径。为空时优先使用发射器父节点。
@export_node_path("Node") var spawn_parent_path: NodePath = NodePath("")

## 是否在生成后调用发射体的 launch(context)。
@export var launch_after_spawn: bool = true

## 生成前是否关闭常见发射体的 auto_launch_on_ready，避免进入树时使用空上下文启动。
@export var disable_auto_launch_before_add: bool = true

## 是否使用 GFObjectPoolUtility 获取节点。池化场景应把 projectile 的 auto_launch_on_ready 设为 false。
@export var use_object_pool: bool = false

## 使用对象池时，是否在 projectile_finished 后自动归还节点。
@export var release_pooled_projectile_on_finish: bool = true


# --- 私有变量 ---

var _next_emission_token: int = 1


# --- 公共方法 ---

## 发射单个发射体。
## @param projectile_context: 本次发射上下文。
## @param projectile_id: 可选目录 ID；为空时使用 default_projectile_id。
## @return 生成的发射体节点；失败时返回 null。
func emit_projectile(projectile_context: Dictionary = {}, projectile_id: StringName = &"") -> Node:
	var projectiles := emit_projectiles(projectile_context, projectile_id, 1)
	if projectiles.is_empty():
		return null
	return projectiles[0]


## 按当前模式发射一批发射体。
## @param projectile_context: 本次发射上下文。
## @param projectile_id: 可选目录 ID；为空时使用 default_projectile_id。
## @param emit_count: 请求生成数量；小于等于 0 时由 spawn_pattern 决定。
## @return 成功生成的发射体节点列表。
func emit_projectiles(
	projectile_context: Dictionary = {},
	projectile_id: StringName = &"",
	emit_count: int = -1
) -> Array[Node]:
	var effective_id := projectile_id if projectile_id != &"" else default_projectile_id
	var scene := resolve_projectile_scene(effective_id)
	if scene == null:
		_emit_failure(&"missing_scene", { "projectile_id": effective_id })
		return []

	var parent := resolve_spawn_parent()
	if parent == null:
		_emit_failure(&"missing_parent", { "projectile_id": effective_id })
		return []

	var transforms := _get_spawn_transforms(projectile_context, emit_count)
	if transforms.is_empty():
		_emit_failure(&"empty_spawn_pattern", { "projectile_id": effective_id })
		return []

	var result: Array[Node] = []
	for index: int in range(transforms.size()):
		var spawn_transform := transforms[index]
		var projectile := _create_projectile_node(scene, parent)
		if projectile == null:
			_emit_failure(&"instantiate_failed", {
				"projectile_id": effective_id,
				"spawn_index": index,
			})
			continue

		_apply_spawn_transform(projectile, spawn_transform)
		var context := _build_spawn_context(projectile_context, effective_id, spawn_transform, index, transforms.size())
		_prepare_projectile_runtime(projectile, scene)
		if launch_after_spawn and projectile.has_method(&"launch"):
			projectile.call("launch", context)
		projectile_emitted.emit(projectile, context.duplicate(true))
		result.append(projectile)
	return result


## 解析当前要使用的发射体场景。
## @param projectile_id: 可选目录 ID。
## @return 找到时返回 PackedScene，否则返回 null。
func resolve_projectile_scene(projectile_id: StringName = &"") -> PackedScene:
	if projectile_catalog != null and projectile_id != &"":
		var catalog_scene := projectile_catalog.get_scene(projectile_id)
		if catalog_scene != null:
			return catalog_scene
	return projectile_scene


## 解析发射体生成父节点。
## @return 有效父节点；找不到时返回 null。
func resolve_spawn_parent() -> Node:
	if spawn_parent_path != NodePath(""):
		var configured_parent := get_node_or_null(spawn_parent_path)
		if configured_parent != null:
			return configured_parent
	var parent := get_parent()
	if parent != null:
		return parent
	return self if is_inside_tree() else null


## 预热对象池。
## @param count: 预热数量。
## @param projectile_id: 可选目录 ID。
## @return 预热请求被接受时返回 true。
func prewarm_projectiles(count: int, projectile_id: StringName = &"") -> bool:
	if count <= 0:
		return false
	var pool := _get_object_pool()
	if pool == null:
		return false
	var scene := resolve_projectile_scene(projectile_id if projectile_id != &"" else default_projectile_id)
	var parent := resolve_spawn_parent()
	if scene == null or parent == null:
		return false
	pool.prewarm(scene, parent, count)
	return true


# --- 私有/辅助方法 ---

func _get_spawn_transforms(projectile_context: Dictionary, emit_count: int) -> Array[Transform3D]:
	if spawn_pattern != null:
		return spawn_pattern.get_spawn_transforms(self, projectile_context, emit_count)
	return [global_transform]


func _create_projectile_node(scene: PackedScene, parent: Node) -> Node:
	if use_object_pool:
		var pool := _get_object_pool()
		if pool != null:
			return pool.acquire(scene, parent)

	var projectile := scene.instantiate() as Node
	if projectile == null:
		return null
	_disable_auto_launch_if_supported(projectile)
	parent.add_child(projectile)
	return projectile


func _prepare_projectile_runtime(projectile: Node, scene: PackedScene) -> void:
	_disable_auto_launch_if_supported(projectile)
	var emission_token := _next_emission_token
	_next_emission_token += 1
	projectile.set_meta(&"gf_emission_token", emission_token)
	if use_object_pool and "queue_free_on_finish" in projectile:
		projectile.set("queue_free_on_finish", false)
	if use_object_pool and release_pooled_projectile_on_finish and projectile.has_signal("projectile_finished"):
		projectile.connect(
			"projectile_finished",
			_on_pooled_projectile_finished.bind(projectile, scene, emission_token),
			CONNECT_ONE_SHOT
		)


func _disable_auto_launch_if_supported(projectile: Node) -> void:
	if disable_auto_launch_before_add and "auto_launch_on_ready" in projectile:
		projectile.set("auto_launch_on_ready", false)


func _apply_spawn_transform(projectile: Node, spawn_transform: Transform3D) -> void:
	if projectile is Node3D:
		(projectile as Node3D).global_transform = spawn_transform
	elif "global_position" in projectile:
		projectile.set("global_position", spawn_transform.origin)
	elif "position" in projectile:
		projectile.set("position", spawn_transform.origin)


func _build_spawn_context(
	projectile_context: Dictionary,
	projectile_id: StringName,
	spawn_transform: Transform3D,
	spawn_index: int,
	spawn_count: int
) -> Dictionary:
	var context := default_context.duplicate(true)
	for key: Variant in projectile_context.keys():
		context[key] = projectile_context[key]
	context["projectile_id"] = projectile_id
	context["emitter"] = self
	context["spawn_index"] = spawn_index
	context["spawn_count"] = spawn_count
	context["spawn_transform_3d"] = spawn_transform
	return context


func _get_object_pool() -> GFObjectPoolUtility:
	if not Gf.has_architecture():
		return null
	var architecture: GFArchitecture = Gf.get_architecture()
	if architecture == null:
		return null
	return architecture.get_utility(GFObjectPoolUtility) as GFObjectPoolUtility


func _emit_failure(reason: StringName, details: Dictionary) -> void:
	projectile_emit_failed.emit(reason, details)


# --- 信号处理函数 ---

func _on_pooled_projectile_finished(
	_projectile_arg: Node,
	_reason: StringName,
	projectile: Node,
	scene: PackedScene,
	emission_token: int
) -> void:
	if not is_instance_valid(projectile):
		return
	if int(projectile.get_meta(&"gf_emission_token", -1)) != emission_token:
		return
	var pool := _get_object_pool()
	if pool != null:
		pool.release(projectile, scene)
