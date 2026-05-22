## GFRenderWarmupUtility: 通用渲染资源预热工具。
##
## 通过清单或节点树收集 Mesh、Material、Texture 等渲染资源，并按帧预算提前加载和触碰 RID。
## 它不决定项目何时预热、预热哪些场景或如何展示加载进度。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFRenderWarmupUtility
extends GFUtility


# --- 信号 ---

## 清单加入预热队列时发出。
## [br]
## @api public
## [br]
## @param queue_id: 预热队列标识。
## [br]
## @param manifest_id: 清单标识。
## [br]
## @param entry_count: 清单条目数量。
signal warmup_queued(queue_id: int, manifest_id: StringName, entry_count: int)

## 单个条目预热完成后发出。
## [br]
## @api public
## [br]
## @param queue_id: 预热队列标识。
## [br]
## @param entry_index: 清单条目索引。
## [br]
## @param result: 单个条目的预热结果。
## [br]
## @schema result: Dictionary，包含 ok、resource_path、kind、resource_class、touched_count、error、metadata 和 entry_index。
signal warmup_entry_processed(queue_id: int, entry_index: int, result: Dictionary)

## 单个清单预热完成后发出。
## [br]
## @api public
## [br]
## @param queue_id: 预热队列标识。
## [br]
## @param summary: 清单预热摘要。
## [br]
## @schema summary: Dictionary，包含 queue_id、manifest_id、total_count、processed_count、failed_count、ok、elapsed_seconds、stopped_by_budget、completed_at_unix 和 results。
signal warmup_completed(queue_id: int, summary: Dictionary)


# --- 枚举 ---

## 预热触碰模式。
## [br]
## @api public
enum TouchMode {
	## 只加载资源并触碰 RID。
	RID_ONLY,
	## 使用离屏临时渲染节点让材质或 Mesh 参与一次渲染。
	TEMPORARY_RENDER_NODES,
}


# --- 公共变量 ---

## 每次 tick 默认处理的最大条目数。
## [br]
## @api public
var default_entries_per_tick: int = 4

## 默认预热时间预算，单位秒。小于等于 0 表示不限制。
## [br]
## @api public
var default_max_seconds: float = 0.0

## 默认触碰模式。
## [br]
## @api public
var default_touch_mode: TouchMode = TouchMode.RID_ONLY

## 是否保留已加载资源引用，避免预热后立刻被释放。
## [br]
## @api public
var keep_resources_cached: bool = true

## 从 PackedScene 条目预热时是否实例化场景并扫描其渲染资源。默认关闭以避免触发项目脚本副作用。
## [br]
## @api public
var instantiate_packed_scenes: bool = false


# --- 私有变量 ---

var _queue: Array[Dictionary] = []
var _cached_resources: Dictionary = {}
var _next_queue_id: int = 1
var _processed_entry_count: int = 0
var _failed_entry_count: int = 0
var _temporary_render_nodes: Array[Node] = []


# --- GF 生命周期方法 ---

## 推进预热队列。
## [br]
## @api public
## [br]
## @param _delta: 本帧时间增量。
func tick(_delta: float) -> void:
	release_temporary_render_nodes()
	process_queue(default_entries_per_tick)


## 清空预热队列、缓存资源和临时渲染节点。
## [br]
## @api public
func dispose() -> void:
	clear_queue()
	release_cached_resources()
	release_temporary_render_nodes()
	_processed_entry_count = 0
	_failed_entry_count = 0


# --- 公共方法 ---

## 将预热清单加入队列。
## [br]
## @api public
## [br]
## @param manifest: 预热清单。
## [br]
## @param options: 可选参数，支持 entries_per_tick、max_seconds、touch_mode、keep_cached、instantiate_packed_scenes。
## [br]
## @return 队列标识；失败返回 -1。
## [br]
## @schema options: Dictionary，包含 entries_per_tick、max_seconds、touch_mode、keep_cached、instantiate_packed_scenes、temporary_parent 和 temporary_viewport_size。
func queue_manifest(manifest: GFRenderWarmupManifest, options: Dictionary = {}) -> int:
	if manifest == null or manifest.is_empty():
		return -1

	var queue_id := _next_queue_id
	_next_queue_id += 1
	var entry_list := manifest.get_entries()
	_queue.append({
		"queue_id": queue_id,
		"manifest_id": manifest.manifest_id,
		"entries": entry_list,
		"index": 0,
		"processed": 0,
		"failed": 0,
		"options": options.duplicate(true),
		"started_at_unix": Time.get_unix_time_from_system(),
		"started_at_msec": Time.get_ticks_msec(),
	})
	warmup_queued.emit(queue_id, manifest.manifest_id, entry_list.size())
	return queue_id


## 立即预热整个清单。
## [br]
## @api public
## [br]
## @param manifest: 预热清单。
## [br]
## @param options: 可选参数，支持 max_seconds、touch_mode、keep_cached、instantiate_packed_scenes。
## [br]
## @return 预热摘要。
## [br]
## @schema options: Dictionary，包含 max_seconds、touch_mode、keep_cached、instantiate_packed_scenes、temporary_parent 和 temporary_viewport_size。
## [br]
## @schema return: Dictionary，包含 queue_id、manifest_id、total_count、processed_count、failed_count、ok、elapsed_seconds、stopped_by_budget、completed_at_unix 和 results。
func warmup_manifest_now(manifest: GFRenderWarmupManifest, options: Dictionary = {}) -> Dictionary:
	if manifest == null:
		return _make_summary(-1, &"", 0, 0, 0, [], 0.0, false)

	var queue_id := _next_queue_id
	_next_queue_id += 1
	var results: Array[Dictionary] = []
	var failed_count := 0
	var entries := manifest.get_entries()
	var started_at_msec := Time.get_ticks_msec()
	var stopped_by_budget := false
	for index: int in range(entries.size()):
		if _is_budget_exhausted(started_at_msec, options):
			stopped_by_budget = true
			break

		var result := _process_entry(entries[index], options)
		result["entry_index"] = index
		results.append(result)
		if not bool(result.get("ok", false)):
			failed_count += 1
		warmup_entry_processed.emit(queue_id, index, result)

	var summary := _make_summary(
		queue_id,
		manifest.manifest_id,
		entries.size(),
		results.size(),
		failed_count,
		results,
		_get_elapsed_seconds(started_at_msec),
		stopped_by_budget
	)
	warmup_completed.emit(queue_id, summary)
	return summary


## 按预算处理队列。
## [br]
## @api public
## [br]
## @param max_entries: 最多处理条目数。
## [br]
## @return 实际处理条目数。
func process_queue(max_entries: int = 1) -> int:
	if max_entries <= 0:
		return 0

	var processed_now := 0
	while processed_now < max_entries and not _queue.is_empty():
		var item := _queue[0] as Dictionary
		if _is_queue_item_budget_exhausted(item):
			_finish_queue_item(item, true)
			_queue.remove_at(0)
			continue

		var entries := item.get("entries", []) as Array
		var index := int(item.get("index", 0))
		if entries == null or index >= entries.size():
			_finish_queue_item(item, false)
			_queue.remove_at(0)
			continue

		var options := item.get("options", {}) as Dictionary
		var result := _process_entry(entries[index] as Dictionary, options if options != null else {})
		result["entry_index"] = index
		item["index"] = index + 1
		item["processed"] = int(item.get("processed", 0)) + 1
		if not bool(result.get("ok", false)):
			item["failed"] = int(item.get("failed", 0)) + 1
		processed_now += 1
		warmup_entry_processed.emit(int(item.get("queue_id", -1)), index, result)

		if int(item.get("index", 0)) >= entries.size():
			_finish_queue_item(item, false)
			_queue.remove_at(0)

	return processed_now


## 从节点树收集可预热的渲染资源。
## [br]
## @api public
## [br]
## @param root: 根节点。
## [br]
## @param options: 可选参数，支持 manifest_id、include_materials、include_meshes、include_textures。
## [br]
## @return 预热清单。
## [br]
## @schema options: Dictionary，包含 manifest_id、include_materials、include_meshes 和 include_textures。
func build_manifest_from_tree(root: Node, options: Dictionary = {}) -> GFRenderWarmupManifest:
	var manifest := GFRenderWarmupManifest.new()
	manifest.manifest_id = StringName(options.get("manifest_id", &""))
	if root == null:
		return manifest

	var seen: Dictionary = {}
	_collect_node_resources(root, manifest, seen, options)
	return manifest


## 从场景资源收集可预热的渲染资源。
## [br]
## @api public
## [br]
## @param scene: 场景资源。
## [br]
## @param options: 可选参数，支持 manifest_id、include_materials、include_meshes、include_textures。
## [br]
## @return 预热清单。
## [br]
## @schema options: Dictionary，包含 manifest_id、include_materials、include_meshes 和 include_textures。
func build_manifest_from_scene(scene: PackedScene, options: Dictionary = {}) -> GFRenderWarmupManifest:
	var manifest := GFRenderWarmupManifest.new()
	manifest.manifest_id = StringName(options.get("manifest_id", &""))
	if scene == null:
		return manifest

	var root := scene.instantiate()
	if root == null:
		return manifest

	manifest = build_manifest_from_tree(root, options)
	root.free()
	return manifest


## 从场景路径收集可预热的渲染资源。
## [br]
## @api public
## [br]
## @param scene_path: 场景资源路径。
## [br]
## @param options: 可选参数，支持 manifest_id、include_materials、include_meshes、include_textures。
## [br]
## @return 预热清单。
## [br]
## @schema options: Dictionary，包含 manifest_id、include_materials、include_meshes 和 include_textures。
func build_manifest_from_scene_path(scene_path: String, options: Dictionary = {}) -> GFRenderWarmupManifest:
	var manifest := GFRenderWarmupManifest.new()
	manifest.manifest_id = StringName(options.get("manifest_id", &""))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path, "PackedScene"):
		return manifest

	var scene := ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	return build_manifest_from_scene(scene, options)


## 清空尚未处理的预热队列。
## [br]
## @api public
func clear_queue() -> void:
	_queue.clear()


## 释放预热缓存的资源引用。
## [br]
## @api public
func release_cached_resources() -> void:
	_cached_resources.clear()


## 释放尚未清理的离屏临时渲染节点。
## [br]
## @api public
func release_temporary_render_nodes() -> void:
	for node: Node in _temporary_render_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_temporary_render_nodes.clear()


## 获取预热缓存资源数量。
## [br]
## @api public
## [br]
## @return 缓存资源数量。
func get_cached_resource_count() -> int:
	return _cached_resources.size()


## 获取待处理队列数量。
## [br]
## @api public
## [br]
## @return 队列数量。
func get_queue_size() -> int:
	return _queue.size()


## 获取调试快照。
## [br]
## @api public
## [br]
## @return 调试信息字典。
## [br]
## @schema return: Dictionary，包含 queue_size、cached_resource_count、processed_entry_count、failed_entry_count、default_entries_per_tick、default_max_seconds、default_touch_mode、keep_resources_cached、instantiate_packed_scenes 和 temporary_render_node_count。
func get_debug_snapshot() -> Dictionary:
	return {
		"queue_size": _queue.size(),
		"cached_resource_count": _cached_resources.size(),
		"processed_entry_count": _processed_entry_count,
		"failed_entry_count": _failed_entry_count,
		"default_entries_per_tick": default_entries_per_tick,
		"default_max_seconds": default_max_seconds,
		"default_touch_mode": default_touch_mode,
		"keep_resources_cached": keep_resources_cached,
		"instantiate_packed_scenes": instantiate_packed_scenes,
		"temporary_render_node_count": _temporary_render_nodes.size(),
	}


# --- 私有/辅助方法 ---

func _process_entry(entry: Dictionary, options: Dictionary) -> Dictionary:
	var normalized: Dictionary = GFRenderWarmupManifest.normalize_entry(entry)
	var resource := normalized.get("resource", null) as Resource
	var resource_path := String(normalized.get("resource_path", ""))
	if resource == null and not resource_path.is_empty():
		resource = _load_resource(resource_path, String(normalized.get("type_hint", "")))

	var result := {
		"ok": resource != null,
		"resource_path": resource_path if not resource_path.is_empty() else (resource.resource_path if resource != null else ""),
		"kind": StringName(normalized.get("kind", &"")),
		"resource_class": resource.get_class() if resource != null else "",
		"touched_count": 0,
		"error": "",
		"metadata": (normalized.get("metadata", {}) as Dictionary).duplicate(true),
	}
	if resource == null:
		result["error"] = "Resource could not be loaded."
		_failed_entry_count += 1
		return result

	result["touched_count"] = _touch_resource(resource, normalized, options)
	if bool(options.get("keep_cached", keep_resources_cached)):
		_cache_resource(resource, result["resource_path"])
	_processed_entry_count += 1
	return result


func _load_resource(resource_path: String, type_hint: String) -> Resource:
	if not ResourceLoader.exists(resource_path, type_hint):
		return null
	return ResourceLoader.load(resource_path, type_hint, ResourceLoader.CACHE_MODE_REUSE)


func _touch_resource(resource: Resource, entry: Dictionary, options: Dictionary) -> int:
	if resource == null:
		return 0

	var touched_count := 0
	if resource is Texture2D:
		(resource as Texture2D).get_rid()
		touched_count += 1
	elif resource is Material:
		(resource as Material).get_rid()
		touched_count += 1
		if _uses_temporary_render_nodes(options):
			touched_count += _touch_material_with_temporary_node(resource as Material, StringName(entry.get("kind", &"")), options)
	elif resource is Shader:
		(resource as Shader).get_rid()
		touched_count += 1
	elif resource is Mesh:
		touched_count += _touch_mesh(resource as Mesh)
		if _uses_temporary_render_nodes(options):
			touched_count += _touch_mesh_with_temporary_node(resource as Mesh, options)
	elif resource is PackedScene and bool(options.get("instantiate_packed_scenes", instantiate_packed_scenes)):
		touched_count += _touch_packed_scene(resource as PackedScene, options)
	return touched_count


func _touch_mesh(mesh: Mesh) -> int:
	if mesh == null:
		return 0

	var touched_count := 1
	mesh.get_rid()
	for surface_index: int in range(mesh.get_surface_count()):
		var material := mesh.surface_get_material(surface_index)
		if material != null:
			material.get_rid()
			touched_count += 1
	return touched_count


func _touch_packed_scene(scene: PackedScene, options: Dictionary) -> int:
	var root := scene.instantiate()
	if root == null:
		return 0

	var manifest := build_manifest_from_tree(root, options)
	var touched_count := 0
	for entry: Dictionary in manifest.get_entries():
		touched_count += int(_process_entry(entry, options).get("touched_count", 0))
	root.free()
	return touched_count


func _touch_material_with_temporary_node(material: Material, kind: StringName, options: Dictionary) -> int:
	var parent := _resolve_temporary_parent(options)
	if parent == null:
		return 0

	var viewport := _make_temporary_viewport(options)
	parent.add_child(viewport)
	if kind == &"particle_material":
		_add_particle_warmup_node(viewport, material)
	else:
		_add_mesh_warmup_node(viewport, _make_dummy_mesh(), material)
	_temporary_render_nodes.append(viewport)
	return 1


func _touch_mesh_with_temporary_node(mesh: Mesh, options: Dictionary) -> int:
	var parent := _resolve_temporary_parent(options)
	if parent == null:
		return 0

	var viewport := _make_temporary_viewport(options)
	parent.add_child(viewport)
	_add_mesh_warmup_node(viewport, mesh, null)
	_temporary_render_nodes.append(viewport)
	return 1


func _make_temporary_viewport(options: Dictionary) -> SubViewport:
	var viewport := SubViewport.new()
	var viewport_size := maxi(int(options.get("temporary_viewport_size", 16)), 1)
	viewport.size = Vector2i(viewport_size, viewport_size)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var camera := Camera3D.new()
	camera.current = true
	camera.look_at_from_position(Vector3(0.0, 0.0, 2.0), Vector3.ZERO, Vector3.UP)
	viewport.add_child(camera)
	return viewport


func _add_mesh_warmup_node(viewport: SubViewport, mesh: Mesh, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if material != null:
		mesh_instance.material_override = material
	viewport.add_child(mesh_instance)


func _add_particle_warmup_node(viewport: SubViewport, material: Material) -> void:
	var particles := GPUParticles3D.new()
	particles.amount = 8
	particles.lifetime = 0.25
	particles.one_shot = false
	particles.emitting = true
	particles.process_material = material
	particles.draw_pass_1 = _make_dummy_mesh()
	viewport.add_child(particles)


func _make_dummy_mesh() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(-0.5, -0.5, 0.0),
		Vector3(0.5, -0.5, 0.0),
		Vector3(0.0, 0.5, 0.0),
	])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _resolve_temporary_parent(options: Dictionary) -> Node:
	var option_parent := options.get("temporary_parent", null) as Node
	if option_parent != null:
		return option_parent

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	if tree.current_scene != null:
		return tree.current_scene
	return tree.root


func _cache_resource(resource: Resource, resource_path: String) -> void:
	var key := resource_path
	if key.is_empty():
		key = "instance:%d" % resource.get_instance_id()
	_cached_resources[key] = resource


func _finish_queue_item(item: Dictionary, stopped_by_budget: bool) -> void:
	var entries := item.get("entries", []) as Array
	var summary := _make_summary(
		int(item.get("queue_id", -1)),
		StringName(item.get("manifest_id", &"")),
		entries.size() if entries != null else 0,
		int(item.get("processed", 0)),
		int(item.get("failed", 0)),
		[],
		_get_elapsed_seconds(int(item.get("started_at_msec", Time.get_ticks_msec()))),
		stopped_by_budget
	)
	warmup_completed.emit(int(item.get("queue_id", -1)), summary)


func _make_summary(
	queue_id: int,
	manifest_id: StringName,
	total_count: int,
	processed_count: int,
	failed_count: int,
	results: Array[Dictionary],
	elapsed_seconds: float,
	stopped_by_budget: bool
) -> Dictionary:
	return {
		"queue_id": queue_id,
		"manifest_id": manifest_id,
		"total_count": total_count,
		"processed_count": processed_count,
		"failed_count": failed_count,
		"ok": failed_count == 0,
		"elapsed_seconds": elapsed_seconds,
		"stopped_by_budget": stopped_by_budget,
		"completed_at_unix": Time.get_unix_time_from_system(),
		"results": results.duplicate(true),
	}


func _collect_node_resources(
	node: Node,
	manifest: GFRenderWarmupManifest,
	seen: Dictionary,
	options: Dictionary
) -> void:
	if node == null:
		return

	if bool(options.get("include_materials", true)) and node is CanvasItem:
		_add_resource_once(manifest, (node as CanvasItem).material, &"material", seen)
	if node is MeshInstance3D:
		_collect_mesh_instance_resources(node as MeshInstance3D, manifest, seen, options)
	elif node is MultiMeshInstance3D:
		_collect_multimesh_instance_resources(node as MultiMeshInstance3D, manifest, seen, options)
	elif node is GPUParticles3D:
		_collect_gpu_particles_resources(node as GPUParticles3D, manifest, seen, options)
	if bool(options.get("include_textures", true)):
		if node is Sprite2D:
			_add_resource_once(manifest, (node as Sprite2D).texture, &"texture", seen)
		elif node is TextureRect:
			_add_resource_once(manifest, (node as TextureRect).texture, &"texture", seen)
		elif node is NinePatchRect:
			_add_resource_once(manifest, (node as NinePatchRect).texture, &"texture", seen)

	for child: Node in node.get_children():
		_collect_node_resources(child, manifest, seen, options)


func _collect_mesh_instance_resources(
	mesh_instance: MeshInstance3D,
	manifest: GFRenderWarmupManifest,
	seen: Dictionary,
	options: Dictionary
) -> void:
	if mesh_instance == null:
		return

	if bool(options.get("include_meshes", true)):
		_add_resource_once(manifest, mesh_instance.mesh, &"mesh", seen)
	if bool(options.get("include_materials", true)):
		_add_resource_once(manifest, mesh_instance.material_override, &"material", seen)
		var mesh := mesh_instance.mesh
		if mesh != null:
			for surface_index: int in range(mesh.get_surface_count()):
				_add_resource_once(manifest, mesh.surface_get_material(surface_index), &"material", seen)
				_add_resource_once(manifest, mesh_instance.get_surface_override_material(surface_index), &"material", seen)


func _collect_multimesh_instance_resources(
	multimesh_instance: MultiMeshInstance3D,
	manifest: GFRenderWarmupManifest,
	seen: Dictionary,
	options: Dictionary
) -> void:
	if multimesh_instance == null:
		return

	var multimesh := multimesh_instance.multimesh
	if multimesh != null and bool(options.get("include_meshes", true)):
		_add_resource_once(manifest, multimesh.mesh, &"mesh", seen)
	if bool(options.get("include_materials", true)):
		_add_resource_once(manifest, multimesh_instance.material_override, &"material", seen)


func _collect_gpu_particles_resources(
	particles: GPUParticles3D,
	manifest: GFRenderWarmupManifest,
	seen: Dictionary,
	options: Dictionary
) -> void:
	if particles == null:
		return

	if bool(options.get("include_materials", true)):
		_add_resource_once(manifest, particles.process_material, &"particle_material", seen)
	if bool(options.get("include_meshes", true)):
		for pass_index: int in range(particles.draw_passes):
			_add_resource_once(manifest, particles.get_draw_pass_mesh(pass_index), &"mesh", seen)


func _add_resource_once(
	manifest: GFRenderWarmupManifest,
	resource: Resource,
	kind: StringName,
	seen: Dictionary
) -> void:
	if resource == null:
		return

	var key := resource.resource_path
	if key.is_empty():
		key = "instance:%d" % resource.get_instance_id()
	if seen.has(key):
		return

	seen[key] = true
	manifest.add_resource(resource, kind)


func _uses_temporary_render_nodes(options: Dictionary) -> bool:
	return int(options.get("touch_mode", default_touch_mode)) == TouchMode.TEMPORARY_RENDER_NODES


func _is_queue_item_budget_exhausted(item: Dictionary) -> bool:
	var options := item.get("options", {}) as Dictionary
	return _is_budget_exhausted(int(item.get("started_at_msec", Time.get_ticks_msec())), options if options != null else {})


func _is_budget_exhausted(started_at_msec: int, options: Dictionary) -> bool:
	var max_seconds := float(options.get("max_seconds", default_max_seconds))
	return max_seconds > 0.0 and _get_elapsed_seconds(started_at_msec) >= max_seconds


func _get_elapsed_seconds(started_at_msec: int) -> float:
	return maxf(float(Time.get_ticks_msec() - started_at_msec) / 1000.0, 0.0)
