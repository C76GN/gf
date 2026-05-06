## 测试 GFSurfaceUtility 的 face index 到 Mesh surface/材质映射。
extends GutTest


const GFSurfaceUtilityBase = preload("res://addons/gf/utilities/gf_surface_utility.gd")


func test_surface_index_maps_across_mesh_surfaces() -> void:
	var utility := GFSurfaceUtilityBase.new()
	var mesh_instance := _make_two_surface_mesh_instance()
	add_child_autofree(mesh_instance)

	assert_eq(utility.get_surface_index(mesh_instance, 0), 0, "第一个三角面应映射到 surface 0。")
	assert_eq(utility.get_surface_index(mesh_instance, 1), 1, "第二个三角面应映射到 surface 1。")
	assert_eq(utility.get_surface_index(mesh_instance, 2), -1, "超出范围的 face index 应返回 -1。")


func test_surface_utility_returns_base_override_and_active_materials() -> void:
	var utility := GFSurfaceUtilityBase.new()
	var mesh_instance := _make_two_surface_mesh_instance()
	add_child_autofree(mesh_instance)
	var base_material := mesh_instance.mesh.surface_get_material(1)
	var override_material := StandardMaterial3D.new()
	mesh_instance.set_surface_override_material(1, override_material)

	assert_eq(utility.get_base_material(mesh_instance, 1), base_material, "base material 应来自 Mesh surface。")
	assert_eq(utility.get_surface_override_material(mesh_instance, 1), override_material, "override material 应来自 MeshInstance3D。")
	assert_eq(utility.get_active_material(mesh_instance, 1), override_material, "active material 应返回最终渲染材质。")


func test_surface_utility_resolves_mesh_from_collision_sibling() -> void:
	var utility := GFSurfaceUtilityBase.new()
	var root := Node3D.new()
	var mesh_instance := _make_two_surface_mesh_instance()
	var collider := StaticBody3D.new()
	root.add_child(mesh_instance)
	root.add_child(collider)
	add_child_autofree(root)

	assert_eq(utility.get_surface_index(collider, 1), 1, "传入碰撞体时应能解析同级 MeshInstance3D。")


func test_surface_utility_cache_can_be_cleared() -> void:
	var utility := GFSurfaceUtilityBase.new()
	var mesh_instance := _make_two_surface_mesh_instance()
	add_child_autofree(mesh_instance)

	utility.get_surface_index(mesh_instance, 0)
	assert_eq(utility.get_debug_snapshot()["cached_meshes"], 1, "查询后应缓存 Mesh surface 面数。")

	utility.clear_cache()

	assert_eq(utility.get_debug_snapshot()["cached_meshes"], 0, "clear_cache 后缓存应为空。")


func _make_two_surface_mesh_instance() -> MeshInstance3D:
	var mesh := ArrayMesh.new()
	_add_triangle_surface(mesh, Vector3.ZERO, _make_material(Color.RED))
	_add_triangle_surface(mesh, Vector3(4.0, 0.0, 0.0), _make_material(Color.BLUE))

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	return mesh_instance


func _add_triangle_surface(mesh: ArrayMesh, offset: Vector3, material: Material) -> void:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		offset + Vector3(0.0, 0.0, 0.0),
		offset + Vector3(1.0, 0.0, 0.0),
		offset + Vector3(0.0, 1.0, 0.0),
	])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(mesh.get_surface_count() - 1, material)


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
