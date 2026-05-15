## 测试通用相机 Rig、Director 与过渡资源。
extends GutTest


# --- 测试方法 ---

## 验证 2D Director 会选择最高优先级 Rig 并应用姿态。
func test_camera_director_2d_applies_highest_priority_rig() -> void:
	var root := Node2D.new()
	add_child_autofree(root)

	var camera := Camera2D.new()
	camera.name = "Camera"
	root.add_child(camera)

	var director := GFCameraDirector2D.new()
	director.name = "Director"
	director.update_mode = GFCameraDirector2D.UpdateMode.MANUAL
	director.default_blend.duration_seconds = 0.0
	root.add_child(director)
	director.camera_path = director.get_path_to(camera)

	var low_rig := GFCameraRig2D.new()
	low_rig.priority = 1
	low_rig.global_position = Vector2(10.0, 0.0)
	root.add_child(low_rig)

	var high_rig := GFCameraRig2D.new()
	high_rig.priority = 5
	high_rig.global_position = Vector2(42.0, 8.0)
	root.add_child(high_rig)
	await get_tree().process_frame

	assert_true(director.process_camera(0.0), "Director 应能应用相机姿态。")
	assert_eq(director.get_active_rig(), high_rig, "Director 应选择最高优先级 Rig。")
	assert_eq(camera.global_position, Vector2(42.0, 8.0), "Camera2D 应应用 Rig 姿态。")


## 验证 2D Director 使用过渡资源采样中间姿态。
func test_camera_director_2d_blends_from_current_camera_pose() -> void:
	var root := Node2D.new()
	add_child_autofree(root)

	var camera := Camera2D.new()
	camera.name = "Camera"
	camera.global_position = Vector2.ZERO
	root.add_child(camera)

	var director := GFCameraDirector2D.new()
	director.name = "Director"
	director.update_mode = GFCameraDirector2D.UpdateMode.MANUAL
	var blend := GFCameraBlend.new()
	blend.duration_seconds = 1.0
	blend.transition_type = Tween.TRANS_LINEAR
	blend.ease_type = Tween.EASE_IN_OUT
	director.default_blend = blend
	root.add_child(director)
	director.camera_path = director.get_path_to(camera)

	var rig := GFCameraRig2D.new()
	rig.global_position = Vector2(100.0, 0.0)
	root.add_child(rig)
	await get_tree().process_frame

	director.process_camera(0.5)

	assert_almost_eq(camera.global_position.x, 50.0, 0.001, "过渡中点应位于当前姿态与目标姿态之间。")
	assert_eq(director.set_active_rig(rig, true), true, "同一 Rig 也应允许强制停止过渡。")
	director.process_camera(0.0)
	assert_almost_eq(camera.global_position.x, 100.0, 0.001, "强制切换后应立即应用目标姿态。")


## 验证 3D Director 会应用最高优先级 Rig 的 Transform。
func test_camera_director_3d_applies_highest_priority_rig() -> void:
	var root := Node3D.new()
	add_child_autofree(root)

	var camera := Camera3D.new()
	camera.name = "Camera"
	root.add_child(camera)

	var director := GFCameraDirector3D.new()
	director.name = "Director"
	director.update_mode = GFCameraDirector3D.UpdateMode.MANUAL
	director.default_blend.duration_seconds = 0.0
	root.add_child(director)
	director.camera_path = director.get_path_to(camera)

	var low_rig := GFCameraRig3D.new()
	low_rig.priority = 1
	low_rig.position = Vector3(1.0, 0.0, 0.0)
	root.add_child(low_rig)

	var high_rig := GFCameraRig3D.new()
	high_rig.priority = 5
	high_rig.position = Vector3(0.0, 3.0, 7.0)
	root.add_child(high_rig)
	await get_tree().process_frame

	assert_true(director.process_camera(0.0), "Director 应能应用 3D 相机姿态。")
	assert_eq(director.get_active_rig(), high_rig, "Director 应选择最高优先级 3D Rig。")
	assert_eq(camera.global_position, Vector3(0.0, 3.0, 7.0), "Camera3D 应应用 Rig Transform。")
