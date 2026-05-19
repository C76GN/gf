## 测试 GFViewportUtility 的分屏布局和相机挂载。
extends GutTest


var _utility: GFViewportUtility
var _root: Control


func before_each() -> void:
	_utility = GFViewportUtility.new()
	_root = Control.new()
	add_child_autofree(_root)


func after_each() -> void:
	if _utility != null:
		_utility.clear_split_screen()
	_utility = null
	_root = null
	await get_tree().process_frame


func test_setup_split_screen_creates_viewports() -> void:
	var viewports := _utility.setup_split_screen(_root, 3, {
		"viewport_size": Vector2i(320, 180),
	})

	assert_eq(viewports.size(), 3)
	assert_eq(_utility.get_viewport_count(), 3)
	assert_eq(_utility.get_container(0).get_child(0), viewports[0])
	assert_eq(viewports[0].size, Vector2i(320, 180))
	assert_eq(_utility.get_debug_snapshot().viewport_count, 3)


func test_viewport_resolution_scale_reduces_render_size() -> void:
	_utility.viewport_resolution_scale = 0.5
	var viewports := _utility.setup_split_screen(_root, 1, {
		"viewport_size": Vector2i(640, 360),
	})

	assert_eq(viewports[0].size, Vector2i(320, 180))


func test_set_viewport_camera_adds_camera_to_subviewport() -> void:
	_utility.setup_split_screen(_root, 1)
	var camera := Camera2D.new()

	assert_true(_utility.set_viewport_camera(0, camera))
	assert_eq(camera.get_parent(), _utility.get_viewport(0))
	assert_true(camera.enabled)

	_utility.clear_split_screen(false)
	assert_null(camera.get_parent(), "清理布局但不释放相机时，应先从 SubViewport 移除。")
	camera.free()


func test_clear_split_screen_detaches_grid_immediately() -> void:
	_utility.setup_split_screen(_root, 2)
	var grid := _root.get_node("GFViewportGrid") as GridContainer

	_utility.clear_split_screen(false)

	assert_null(grid.get_parent(), "清理分屏布局时 GridContainer 应立即脱离 root。")
	assert_eq(_root.get_child_count(), 0, "清理分屏布局后 root 不应继续持有旧布局节点。")

	await get_tree().process_frame
	assert_false(is_instance_valid(grid), "下一帧旧布局节点应完成释放。")


func test_clear_split_screen_with_free_cameras_detaches_camera_immediately() -> void:
	_utility.setup_split_screen(_root, 1)
	var camera := Camera2D.new()
	assert_true(_utility.set_viewport_camera(0, camera))

	_utility.clear_split_screen(true)

	assert_null(camera.get_parent(), "释放相机时应立即从 SubViewport 移除。")

	await get_tree().process_frame
	assert_false(is_instance_valid(camera), "下一帧相机应完成释放。")


func test_set_postprocess_material_updates_container() -> void:
	_utility.setup_split_screen(_root, 1)
	var material := ShaderMaterial.new()

	assert_true(_utility.set_postprocess_material(0, material))
	assert_eq(_utility.get_container(0).material, material)


func test_screen_to_world_ray_3d_uses_camera_projection() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(200, 200)
	add_child_autofree(viewport)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.current = true
	await get_tree().process_frame

	var ray := _utility.screen_to_world_ray_3d(camera, Vector2(100.0, 100.0), 10.0)
	var direction := ray["direction"] as Vector3

	assert_true(bool(ray["ok"]), "有效 Camera3D 应生成射线。")
	assert_almost_eq(direction.x, 0.0, 0.01, "屏幕中心射线 X 分量应接近 0。")
	assert_almost_eq(direction.y, 0.0, 0.01, "屏幕中心射线 Y 分量应接近 0。")
	assert_lt(direction.z, -0.9, "默认 Camera3D 应朝 -Z 方向投射。")


func test_world_screen_2d_roundtrip() -> void:
	var node := Node2D.new()
	node.position = Vector2(10.0, 20.0)
	add_child_autofree(node)
	await get_tree().process_frame

	var world_position := Vector2(32.0, 48.0)
	var screen_position := _utility.world_to_screen_2d(node, world_position)
	var restored_position := _utility.screen_to_world_2d(node, screen_position)

	assert_almost_eq(restored_position.x, world_position.x, 0.001)
	assert_almost_eq(restored_position.y, world_position.y, 0.001)


func test_setup_with_zero_count_clears_layout() -> void:
	_utility.setup_split_screen(_root, 2)
	var viewports := _utility.setup_split_screen(_root, 0)

	assert_eq(viewports, [])
	assert_eq(_utility.get_viewport_count(), 0)
	assert_eq(_root.get_child_count(), 0, "viewport_count 为 0 时应立即清空旧布局节点。")
