## 测试 GFSceneUtility 的瞬态清理与失败回退流程。
extends GutTest


var _scene_util: TestSceneUtility


class DummyModel extends GFModel:
	var disposed := false

	func dispose() -> void:
		disposed = true


class TestSceneUtility extends GFSceneUtility:
	var current_scene_path: String = "res://tests/current_scene.tscn"
	var sync_scene_changes: Array[String] = []
	var packed_scene_changes: int = 0

	func _get_current_scene_path() -> String:
		return current_scene_path

	func _do_change_scene_sync(path: String) -> Error:
		sync_scene_changes.append(path)
		current_scene_path = path
		return OK

	func _do_change_scene(_scene: PackedScene) -> bool:
		packed_scene_changes += 1
		return true


func before_each() -> void:
	var arch := GFArchitecture.new()
	Gf._architecture = arch

	_scene_util = TestSceneUtility.new()
	Gf.register_utility(_scene_util)

	await Gf.set_architecture(arch)


func after_each() -> void:
	var arch := Gf.get_architecture()
	if arch != null:
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())


func test_transient_cleanup() -> void:
	var model := DummyModel.new()
	Gf.register_model(model)

	_scene_util.mark_transient(DummyModel)
	_scene_util.cleanup_transients()

	var arch := Gf.get_architecture()
	assert_null(arch.get_model(DummyModel), "标记为瞬态的 Model 应在清理后注销。")
	assert_true(model.disposed, "注销 Model 时应调用 dispose()。")


func test_transient_cleanup_uses_injected_architecture() -> void:
	var parent_arch := GFArchitecture.new()
	var child_arch := GFArchitecture.new(parent_arch)
	var scene_util := TestSceneUtility.new()
	var local_model := DummyModel.new()

	await child_arch.register_utility_instance(scene_util)
	await child_arch.register_model_instance(local_model)

	scene_util.mark_transient(DummyModel)
	scene_util.cleanup_transients()

	assert_null(child_arch.get_model(DummyModel), "瞬态清理应优先作用于 Utility 注入的局部架构。")
	assert_true(local_model.disposed, "局部架构中的瞬态 Model 应被释放。")

	child_arch.dispose()
	parent_arch.dispose()


func test_unmark_transient() -> void:
	var model := DummyModel.new()
	Gf.register_model(model)

	_scene_util.mark_transient(DummyModel)
	_scene_util.unmark_transient(DummyModel)
	_scene_util.cleanup_transients()

	var arch := Gf.get_architecture()
	assert_not_null(arch.get_model(DummyModel), "取消瞬态标记后不应再被清理。")
	assert_false(model.disposed, "取消标记后的 Model 不应触发 dispose()。")


func test_failed_load_restores_previous_scene_after_loading_scene() -> void:
	var original_scene_path := _scene_util.current_scene_path
	var loading_scene_path := "res://addons/gut/gui/NormalGui.tscn"

	_scene_util.load_scene_async("res://icon.svg", loading_scene_path)

	for _i in range(120):
		_scene_util.tick(0.0)
		if not _scene_util._is_loading:
			break
		await get_tree().process_frame

	assert_push_error("[GFSceneUtility] 异步加载完成，但目标资源不是 PackedScene：res://icon.svg")
	assert_false(_scene_util._is_loading, "加载失败后应退出 loading 状态。")
	assert_eq(_scene_util.sync_scene_changes.size(), 2, "失败流程应先切到 loading scene，再恢复到原场景。")
	assert_eq(_scene_util.sync_scene_changes[0], loading_scene_path, "第一步应切换到 loading scene。")
	assert_eq(_scene_util.sync_scene_changes[1], original_scene_path, "失败后应恢复到原场景路径。")
	assert_eq(_scene_util.current_scene_path, original_scene_path, "最终场景应恢复为原场景。")
	assert_eq(_scene_util.packed_scene_changes, 0, "错误资源不应触发正式场景切换。")


func test_failed_load_preserves_transients() -> void:
	var scene_util := TestSceneUtility.new()
	var model := DummyModel.new()
	Gf.register_model(model)
	scene_util.mark_transient(DummyModel)

	scene_util.load_scene_async("res://icon.svg", "res://addons/gut/gui/NormalGui.tscn")

	for _i in range(120):
		scene_util.tick(0.0)
		if not scene_util._is_loading:
			break
		await get_tree().process_frame

	var arch := Gf.get_architecture()
	assert_eq(arch.get_model(DummyModel), model, "异步切场失败后不应清理仍属于当前场景的瞬态 Model。")
	assert_false(model.disposed, "异步切场失败不应触发瞬态 Model 的 dispose()。")
	assert_push_error("[GFSceneUtility] 异步加载完成，但目标资源不是 PackedScene：res://icon.svg")
