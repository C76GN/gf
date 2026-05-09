## GFRenderWarmupUtility: 通用渲染资源预热工具。
##
## 通过清单或节点树收集 Mesh、Material、Texture 等渲染资源，并按帧预算提前加载和触碰 RID。
## 它不决定项目何时预热、预热哪些场景或如何展示加载进度。
class_name GFRenderWarmupUtility
extends GFUtility


# --- 信号 ---

## 清单加入预热队列时发出。
signal warmup_queued(queue_id: int, manifest_id: StringName, entry_count: int)

## 单个条目预热完成后发出。
signal warmup_entry_processed(queue_id: int, entry_index: int, result: Dictionary)

## 单个清单预热完成后发出。
signal warmup_completed(queue_id: int, summary: Dictionary)


# --- 常量 ---

const GFRenderWarmupManifestBase = preload("res://addons/gf/utilities/gf_render_warmup_manifest.gd")


# --- 公共变量 ---

## 每次 tick 默认处理的最大条目数。
var default_entries_per_tick: int = 4

## 是否保留已加载资源引用，避免预热后立刻被释放。
var keep_resources_cached: bool = true

## 从 PackedScene 条目预热时是否实例化场景并扫描其渲染资源。默认关闭以避免触发项目脚本副作用。
var instantiate_packed_scenes: bool = false


# --- 私有变量 ---

var _queue: Array[Dictionary] = []
var _cached_resources: Dictionary = {}
var _next_queue_id: int = 1
var _processed_entry_count: int = 0
var _failed_entry_count: int = 0


# --- Godot 生命周期方法 ---

## 推进预热队列。
## @param _delta: 本帧时间增量。
func tick(_delta: float) -> void:
	process_queue(default_entries_per_tick)


func dispose() -> void:
	clear_queue()
	release_cached_resources()
	_processed_entry_count = 0
	_failed_entry_count = 0


# --- 公共方法 ---

## 将预热清单加入队列。
## @param manifest: 预热清单。
## @param options: 可选参数，支持 entries_per_tick、keep_cached、instantiate_packed_scenes。
## @return 队列标识；失败返回 -1。
func queue_manifest(manifest: GFRenderWarmupManifestBase, options: Dictionary = {}) -> int:
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
	})
	warmup_queued.emit(queue_id, manifest.manifest_id, entry_list.size())
	return queue_id


## 立即预热整个清单。
## @param manifest: 预热清单。
## @param options: 可选参数，支持 keep_cached、instantiate_packed_scenes。
## @return 预热摘要。
func warmup_manifest_now(manifest: GFRenderWarmupManifestBase, options: Dictionary = {}) -> Dictionary:
	if manifest == null:
		return _make_summary(-1, &"", 0, 0, 0, [])

	var queue_id := _next_queue_id
	_next_queue_id += 1
	var results: Array[Dictionary] = []
	var failed_count := 0
	var entries := manifest.get_entries()
	for index: int in range(entries.size()):
		var result := _process_entry(entries[index], options)
		result["entry_index"] = index
		results.append(result)
		if not bool(result.get("ok", false)):
			failed_count += 1
		warmup_entry_processed.emit(queue_id, index, result)

	var summary := _make_summary(queue_id, manifest.manifest_id, entries.size(), entries.size(), failed_count, results)
	warmup_completed.emit(queue_id, summary)
	return summary


## 按预算处理队列。
## @param max_entries: 最多处理条目数。
## @return 实际处理条目数。
func process_queue(max_entries: int = 1) -> int:
	if max_entries <= 0:
		return 0

	var processed_now := 0
	while processed_now < max_entries and not _queue.is_empty():
		var item := _queue[0] as Dictionary
		var entries := item.get("entries", []) as Array
		var index := int(item.get("index", 0))
		if entries == null or index >= entries.size():
			_finish_queue_item(item)
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
			_finish_queue_item(item)
			_queue.remove_at(0)

	return processed_now


## 从节点树收集可预热的渲染资源。
## @param root: 根节点。
## @param options: 可选参数，支持 manifest_id、include_materials、include_meshes、include_textures。
## @return 预热清单。
func build_manifest_from_tree(root: Node, options: Dictionary = {}) -> GFRenderWarmupManifestBase:
	var manifest := GFRenderWarmupManifestBase.new()
	manifest.manifest_id = StringName(options.get("manifest_id", &""))
	if root == null:
		return manifest

	var seen: Dictionary = {}
	_collect_node_resources(root, manifest, seen, options)
	return manifest


## 清空尚未处理的预热队列。
func clear_queue() -> void:
	_queue.clear()


## 释放预热缓存的资源引用。
func release_cached_resources() -> void:
	_cached_resources.clear()


## 获取预热缓存资源数量。
## @return 缓存资源数量。
func get_cached_resource_count() -> int:
	return _cached_resources.size()


## 获取待处理队列数量。
## @return 队列数量。
func get_queue_size() -> int:
	return _queue.size()


## 获取调试快照。
## @return 调试信息字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"queue_size": _queue.size(),
		"cached_resource_count": _cached_resources.size(),
		"processed_entry_count": _processed_entry_count,
		"failed_entry_count": _failed_entry_count,
		"default_entries_per_tick": default_entries_per_tick,
		"keep_resources_cached": keep_resources_cached,
		"instantiate_packed_scenes": instantiate_packed_scenes,
	}


# --- 私有/辅助方法 ---

func _process_entry(entry: Dictionary, options: Dictionary) -> Dictionary:
	var normalized: Dictionary = GFRenderWarmupManifestBase.normalize_entry(entry)
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

	result["touched_count"] = _touch_resource(resource, options)
	if bool(options.get("keep_cached", keep_resources_cached)):
		_cache_resource(resource, result["resource_path"])
	_processed_entry_count += 1
	return result


func _load_resource(resource_path: String, type_hint: String) -> Resource:
	if not ResourceLoader.exists(resource_path, type_hint):
		return null
	return ResourceLoader.load(resource_path, type_hint, ResourceLoader.CACHE_MODE_REUSE)


func _touch_resource(resource: Resource, options: Dictionary) -> int:
	if resource == null:
		return 0

	var touched_count := 0
	if resource is Texture2D:
		(resource as Texture2D).get_rid()
		touched_count += 1
	elif resource is Material:
		(resource as Material).get_rid()
		touched_count += 1
	elif resource is Shader:
		(resource as Shader).get_rid()
		touched_count += 1
	elif resource is Mesh:
		touched_count += _touch_mesh(resource as Mesh)
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


func _cache_resource(resource: Resource, resource_path: String) -> void:
	var key := resource_path
	if key.is_empty():
		key = "instance:%d" % resource.get_instance_id()
	_cached_resources[key] = resource


func _finish_queue_item(item: Dictionary) -> void:
	var entries := item.get("entries", []) as Array
	var summary := _make_summary(
		int(item.get("queue_id", -1)),
		StringName(item.get("manifest_id", &"")),
		entries.size() if entries != null else 0,
		int(item.get("processed", 0)),
		int(item.get("failed", 0)),
		[]
	)
	warmup_completed.emit(int(item.get("queue_id", -1)), summary)


func _make_summary(
	queue_id: int,
	manifest_id: StringName,
	total_count: int,
	processed_count: int,
	failed_count: int,
	results: Array[Dictionary]
) -> Dictionary:
	return {
		"queue_id": queue_id,
		"manifest_id": manifest_id,
		"total_count": total_count,
		"processed_count": processed_count,
		"failed_count": failed_count,
		"ok": failed_count == 0,
		"completed_at_unix": Time.get_unix_time_from_system(),
		"results": results.duplicate(true),
	}


func _collect_node_resources(
	node: Node,
	manifest: GFRenderWarmupManifestBase,
	seen: Dictionary,
	options: Dictionary
) -> void:
	if node == null:
		return

	if bool(options.get("include_materials", true)) and node is CanvasItem:
		_add_resource_once(manifest, (node as CanvasItem).material, &"material", seen)
	if node is MeshInstance3D:
		_collect_mesh_instance_resources(node as MeshInstance3D, manifest, seen, options)
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
	manifest: GFRenderWarmupManifestBase,
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


func _add_resource_once(
	manifest: GFRenderWarmupManifestBase,
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
