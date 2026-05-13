## 测试 GFRenderWarmupUtility 的清单预热与节点树资源收集。
extends GutTest


# --- 常量 ---

const GFRenderWarmupManifestBase = preload("res://addons/gf/standard/utilities/display/gf_render_warmup_manifest.gd")
const GFRenderWarmupUtilityBase = preload("res://addons/gf/standard/utilities/display/gf_render_warmup_utility.gd")


# --- 测试方法 ---

## 验证预热清单可以立即处理材质资源并保留缓存。
func test_render_warmup_manifest_processes_material_resource() -> void:
	var manifest := GFRenderWarmupManifestBase.new()
	manifest.manifest_id = &"test"
	var material := StandardMaterial3D.new()
	manifest.add_resource(material, &"material", { "label": "red" })
	var utility := GFRenderWarmupUtilityBase.new()

	var summary := utility.warmup_manifest_now(manifest)

	assert_true(bool(summary["ok"]), "材质资源预热应成功。")
	assert_eq(int(summary["processed_count"]), 1, "应处理一个条目。")
	assert_eq(utility.get_cached_resource_count(), 1, "默认应缓存已预热资源引用。")


## 验证 Utility 可以从节点树收集 Mesh 与材质资源。
func test_render_warmup_builds_manifest_from_mesh_tree() -> void:
	var utility := GFRenderWarmupUtilityBase.new()
	var mesh_instance := _make_mesh_instance()
	add_child_autofree(mesh_instance)

	var manifest := utility.build_manifest_from_tree(mesh_instance, { "manifest_id": &"tree" })
	var description := manifest.describe()

	assert_eq(description["manifest_id"], &"tree", "收集清单应保留 manifest_id。")
	assert_gt(int(description["entry_count"]), 1, "MeshInstance3D 应贡献 Mesh 和材质资源。")


## 验证队列按预算分批处理。
func test_render_warmup_queue_respects_entry_budget() -> void:
	var manifest := GFRenderWarmupManifestBase.new()
	manifest.add_resource(StandardMaterial3D.new(), &"material")
	manifest.add_resource(StandardMaterial3D.new(), &"material")
	var utility := GFRenderWarmupUtilityBase.new()
	utility.queue_manifest(manifest)

	var first_count := utility.process_queue(1)
	var second_count := utility.process_queue(1)

	assert_eq(first_count, 1, "第一次只应处理一个条目。")
	assert_eq(second_count, 1, "第二次处理剩余条目。")
	assert_eq(utility.get_queue_size(), 0, "全部处理后队列应为空。")


## 验证离屏临时渲染节点模式会创建并释放临时节点。
func test_render_warmup_temporary_render_nodes_can_be_released() -> void:
	var manifest := GFRenderWarmupManifestBase.new()
	manifest.add_resource(StandardMaterial3D.new(), &"material")
	var utility := GFRenderWarmupUtilityBase.new()

	var summary := utility.warmup_manifest_now(manifest, {
		"touch_mode": GFRenderWarmupUtilityBase.TouchMode.TEMPORARY_RENDER_NODES,
		"temporary_parent": self,
	})

	assert_true(bool(summary["ok"]), "临时渲染节点预热应完成。")
	assert_gt(int(summary["processed_count"]), 0, "应处理至少一个条目。")
	assert_gt(int(utility.get_debug_snapshot()["temporary_render_node_count"]), 0, "应保留临时节点到下一次释放。")

	utility.release_temporary_render_nodes()

	assert_eq(int(utility.get_debug_snapshot()["temporary_render_node_count"]), 0, "释放后临时节点数量应归零。")

	await get_tree().process_frame


## 验证 Utility 可以从场景资源中收集渲染资源。
func test_render_warmup_builds_manifest_from_packed_scene() -> void:
	var root := Node3D.new()
	var mesh_instance := _make_mesh_instance()
	root.add_child(mesh_instance)
	mesh_instance.owner = root
	var scene := PackedScene.new()
	assert_eq(scene.pack(root), OK, "测试场景应能打包。")
	var utility := GFRenderWarmupUtilityBase.new()

	var manifest := utility.build_manifest_from_scene(scene, { "manifest_id": &"scene" })

	assert_eq(manifest.manifest_id, &"scene", "场景清单应保留 manifest_id。")
	assert_gt(manifest.get_entry_count(), 1, "场景内 MeshInstance3D 应贡献资源。")

	root.free()


## 验证预热条目规范化会生成隔离的元数据副本。
func test_render_warmup_manifest_normalizes_entries() -> void:
	var source_metadata := { "label": "preview" }
	var normalized: Dictionary = GFRenderWarmupManifestBase.normalize_entry({
		"resource_path": 123,
		"kind": "texture",
		"metadata": source_metadata,
	})
	source_metadata["label"] = "changed"

	assert_eq(normalized["resource_path"], "123", "资源路径应规范化为字符串。")
	assert_eq(normalized["kind"], &"texture", "kind 应规范化为 StringName。")
	assert_eq((normalized["metadata"] as Dictionary)["label"], "preview", "元数据应深拷贝。")


# --- 私有/辅助方法 ---

func _make_mesh_instance() -> MeshInstance3D:
	var mesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(0.0, 0.0, 0.0),
		Vector3(1.0, 0.0, 0.0),
		Vector3(0.0, 1.0, 0.0),
	])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, StandardMaterial3D.new())

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = StandardMaterial3D.new()
	return mesh_instance
