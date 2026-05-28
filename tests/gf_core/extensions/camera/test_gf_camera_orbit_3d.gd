extends GutTest


func test_orbit_rig_computes_transform_around_target() -> void:
	var root := Node3D.new()
	add_child_autofree(root)

	var target := Node3D.new()
	target.position = Vector3(1.0, 2.0, 3.0)
	root.add_child(target)

	var rig := GFCameraOrbitRig3D.new()
	root.add_child(rig)
	rig.target_path = rig.get_path_to(target)
	rig.set_orbit(0.0, 0.0, 10.0)
	await get_tree().process_frame

	var transform := rig.get_camera_transform()
	assert_almost_eq(transform.origin.distance_to(target.global_position), 10.0, 0.001, "相机位置应保持指定距离。")
	assert_almost_eq(transform.origin.x, 1.0, 0.001, "yaw 为 0 时 x 应与焦点一致。")
	assert_almost_eq(transform.origin.z, 13.0, 0.001, "yaw 为 0 时相机应位于焦点后方。")


func test_orbit_rig_clamps_pitch_and_distance() -> void:
	var rig := GFCameraOrbitRig3D.new()
	add_child_autofree(rig)
	rig.min_pitch_degrees = -30.0
	rig.max_pitch_degrees = 45.0
	rig.min_distance = 2.0
	rig.max_distance = 6.0

	rig.set_orbit(0.0, 90.0, 20.0)

	assert_almost_eq(rig.pitch_degrees, 45.0, 0.001, "pitch 应按上限夹紧。")
	assert_almost_eq(rig.distance, 6.0, 0.001, "distance 应按上限夹紧。")

	rig.apply_zoom_delta(-20.0)
	assert_almost_eq(rig.distance, 2.0, 0.001, "缩放拉近时应按下限夹紧。")


func test_orbit_input_applies_direct_values() -> void:
	var rig := GFCameraOrbitRig3D.new()
	add_child_autofree(rig)
	rig.set_orbit(0.0, 0.0, 8.0)

	var input := GFCameraOrbitInput3D.new()
	input.update_mode = GFCameraOrbitInput3D.UpdateMode.MANUAL
	input.use_input_mapping = false
	rig.add_child(input)
	await get_tree().process_frame

	assert_true(input.apply_orbit_vector(Vector2(1.0, -0.5), 10.0), "直接环绕输入应能应用。")
	assert_almost_eq(rig.yaw_degrees, 10.0, 0.001, "yaw 应按输入和缩放变化。")
	assert_almost_eq(rig.pitch_degrees, -5.0, 0.001, "pitch 应按输入和缩放变化。")

	assert_true(input.apply_zoom_value(-1.0, 2.0), "直接缩放输入应能应用。")
	assert_almost_eq(rig.distance, 6.0, 0.001, "缩放输入应改变 Rig 距离。")


func test_orbit_input_is_inert_by_default() -> void:
	var input := GFCameraOrbitInput3D.new()
	add_child_autofree(input)

	assert_false(input.use_input_mapping, "输入映射桥接默认应关闭，避免隐式绑定项目动作。")
	assert_false(input.mouse_orbit_enabled, "鼠标环绕默认应关闭，避免隐式接管鼠标拖拽。")
	assert_false(input.mouse_zoom_enabled, "鼠标缩放默认应关闭，避免隐式接管鼠标滚轮。")
