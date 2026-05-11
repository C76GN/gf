## GFSurfaceUtility: 3D 表面材质查询工具。
##
## 根据碰撞命中的 face index 推导 MeshInstance3D surface，并返回基础材质、
## 覆盖材质或最终 active material。框架只负责几何到材质的映射，不解释材质语义。
class_name GFSurfaceUtility
extends GFUtility


# --- 私有变量 ---

var _surface_face_counts_by_mesh: Dictionary = {}


# --- Godot 生命周期方法 ---

func dispose() -> void:
	clear_cache()


# --- 公共方法 ---

## 获取命中表面最终渲染使用的材质。
## @param source: MeshInstance3D、CollisionObject3D 或其相邻节点。
## @param face_index: RayCast3D.get_collision_face_index() 返回的面索引。
## @return 命中材质；无法解析时返回 null。
func get_active_material(source: Object, face_index: int) -> Material:
	var mesh_instance := _resolve_mesh_instance(source)
	var surface_index := get_surface_index(source, face_index)
	if mesh_instance == null or surface_index < 0:
		return null
	return mesh_instance.get_active_material(surface_index)


## 获取 MeshInstance3D surface override 材质。
## @param source: MeshInstance3D、CollisionObject3D 或其相邻节点。
## @param face_index: RayCast3D.get_collision_face_index() 返回的面索引。
## @return 覆盖材质；未设置或无法解析时返回 null。
func get_surface_override_material(source: Object, face_index: int) -> Material:
	var mesh_instance := _resolve_mesh_instance(source)
	var surface_index := get_surface_index(source, face_index)
	if mesh_instance == null or surface_index < 0:
		return null
	return mesh_instance.get_surface_override_material(surface_index)


## 获取 Mesh 资源自身的 surface 材质。
## @param source: MeshInstance3D、CollisionObject3D 或其相邻节点。
## @param face_index: RayCast3D.get_collision_face_index() 返回的面索引。
## @return 基础材质；无法解析时返回 null。
func get_base_material(source: Object, face_index: int) -> Material:
	var mesh_instance := _resolve_mesh_instance(source)
	var surface_index := get_surface_index(source, face_index)
	if mesh_instance == null or mesh_instance.mesh == null or surface_index < 0:
		return null
	return mesh_instance.mesh.surface_get_material(surface_index)


## 获取 face index 所属的 Mesh surface 索引。
## @param source: MeshInstance3D、CollisionObject3D 或其相邻节点。
## @param face_index: RayCast3D.get_collision_face_index() 返回的面索引。
## @return surface 索引；无法解析时返回 -1。
func get_surface_index(source: Object, face_index: int) -> int:
	if face_index < 0:
		return -1

	var mesh_instance := _resolve_mesh_instance(source)
	if mesh_instance == null or mesh_instance.mesh == null:
		return -1

	var face_counts := _get_surface_face_counts(mesh_instance.mesh)
	var remaining_face_index := face_index
	for surface_index: int in range(face_counts.size()):
		var face_count := int(face_counts[surface_index])
		if remaining_face_index < face_count:
			return surface_index
		remaining_face_index -= face_count
	return -1


## 清空 Mesh surface face count 缓存。
func clear_cache() -> void:
	_surface_face_counts_by_mesh.clear()


## 获取调试快照。
## @return 缓存状态。
func get_debug_snapshot() -> Dictionary:
	return {
		"cached_meshes": _surface_face_counts_by_mesh.size(),
	}


# --- 私有/辅助方法 ---

func _resolve_mesh_instance(source: Object) -> MeshInstance3D:
	if source is MeshInstance3D:
		var direct_mesh_instance := source as MeshInstance3D
		return direct_mesh_instance if direct_mesh_instance.mesh != null else null

	var node := source as Node
	if node == null:
		return null

	var parent := node.get_parent()
	if parent is MeshInstance3D and (parent as MeshInstance3D).mesh != null:
		return parent as MeshInstance3D

	for child: Node in node.get_children():
		if child is MeshInstance3D and (child as MeshInstance3D).mesh != null:
			return child as MeshInstance3D

	if parent != null:
		for sibling: Node in parent.get_children():
			if sibling is MeshInstance3D and (sibling as MeshInstance3D).mesh != null:
				return sibling as MeshInstance3D

	return null


func _get_surface_face_counts(mesh: Mesh) -> Array[int]:
	var cache_key := _get_mesh_cache_key(mesh)
	if _surface_face_counts_by_mesh.has(cache_key):
		return (_surface_face_counts_by_mesh[cache_key] as Array[int]).duplicate()

	var face_counts: Array[int] = []
	for surface_index: int in range(mesh.get_surface_count()):
		face_counts.append(_get_surface_face_count(mesh, surface_index))

	_surface_face_counts_by_mesh[cache_key] = face_counts.duplicate()
	return face_counts


func _get_surface_face_count(mesh: Mesh, surface_index: int) -> int:
	var arrays := mesh.surface_get_arrays(surface_index)
	if arrays.size() > Mesh.ARRAY_INDEX:
		var index_data: Variant = arrays[Mesh.ARRAY_INDEX]
		if index_data is PackedInt32Array:
			var indices: PackedInt32Array = index_data
			if not indices.is_empty():
				return indices.size() / 3

	if arrays.size() > Mesh.ARRAY_VERTEX:
		var vertex_data: Variant = arrays[Mesh.ARRAY_VERTEX]
		if vertex_data is PackedVector3Array:
			var vertices: PackedVector3Array = vertex_data
			if not vertices.is_empty():
				return vertices.size() / 3

	return _get_surface_face_count_with_mesh_data_tool(mesh, surface_index)


func _get_surface_face_count_with_mesh_data_tool(mesh: Mesh, surface_index: int) -> int:
	var mesh_data_tool := MeshDataTool.new()
	var error := mesh_data_tool.create_from_surface(mesh, surface_index)
	if error != OK:
		return 0
	return mesh_data_tool.get_face_count()


func _get_mesh_cache_key(mesh: Mesh) -> int:
	if mesh == null:
		return 0
	return mesh.get_rid().get_id()
