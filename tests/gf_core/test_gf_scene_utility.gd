## 测试 GFSceneUtility 的瞬态清理与失败回退流程。
extends GutTest


const GFSceneTransitionConfigBase = preload("res://addons/gf/utilities/gf_scene_transition_config.gd")


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
	var arch: GFArchitecture = Gf.get_architecture()
	if arch != null:
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())


func test_transient_cleanup() -> void:
	var model := DummyModel.new()
	Gf.register_model(model)

	_scene_util.mark_transient(DummyModel)
	_scene_util.cleanup_transients()

	var arch: GFArchitecture = Gf.get_architecture()
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

	var arch: GFArchitecture = Gf.get_architecture()
	assert_not_null(arch.get_model(DummyModel), "取消瞬态标记后不应再被清理。")
	assert_false(model.disposed, "取消标记后的 Model 不应触发 dispose()。")


func test_failed_load_restores_previous_scene_after_loading_scene() -> void:
	var loading_scene_path := "res://addons/gut/gui/NormalGui.tscn"

	_scene_util.load_scene_async("res://icon.svg", loading_scene_path)

	assert_push_error("[GFSceneUtility] load_scene_async 失败：资源不是 PackedScene：res://icon.svg")
	assert_false(_scene_util._is_loading, "前置校验失败后不应进入 loading 状态。")
	assert_eq(_scene_util.sync_scene_changes.size(), 0, "前置校验失败不应切到 loading scene。")
	assert_eq(_scene_util.packed_scene_changes, 0, "错误资源不应触发正式场景切换。")


func test_failed_load_preserves_transients() -> void:
	var scene_util := TestSceneUtility.new()
	var model := DummyModel.new()
	Gf.register_model(model)
	scene_util.mark_transient(DummyModel)

	scene_util.load_scene_async("res://icon.svg", "res://addons/gut/gui/NormalGui.tscn")

	var arch: GFArchitecture = Gf.get_architecture()
	assert_eq(arch.get_model(DummyModel), model, "异步切场失败后不应清理仍属于当前场景的瞬态 Model。")
	assert_false(model.disposed, "异步切场失败不应触发瞬态 Model 的 dispose()。")
	assert_push_error("[GFSceneUtility] load_scene_async 失败：资源不是 PackedScene：res://icon.svg")


func test_empty_scene_path_fails_before_loading_state_changes() -> void:
	watch_signals(_scene_util)

	_scene_util.load_scene_async("")

	assert_false(_scene_util._is_loading, "空路径不应进入 loading 状态。")
	assert_signal_emitted(_scene_util, "scene_load_failed", "前置校验失败仍应发出失败信号。")
	assert_push_error("[GFSceneUtility] load_scene_async 失败：path 为空。")


func test_preloaded_scene_cache_uses_lru_eviction() -> void:
	_scene_util.max_preloaded_scene_resources = 2
	_scene_util.put_preloaded_scene("res://addons/gut/gui/NormalGui.tscn", _make_empty_scene())
	_scene_util.put_preloaded_scene("res://addons/gut/gui/MinGui.tscn", _make_empty_scene())

	_scene_util.get_preloaded_scene("res://addons/gut/gui/NormalGui.tscn")
	_scene_util.put_preloaded_scene("res://addons/gut/gui/GutRunner.tscn", _make_empty_scene())

	assert_true(_scene_util.is_scene_preloaded("res://addons/gut/gui/NormalGui.tscn"), "最近访问的预加载场景应保留。")
	assert_false(_scene_util.is_scene_preloaded("res://addons/gut/gui/MinGui.tscn"), "最久未访问的预加载场景应被淘汰。")
	assert_true(_scene_util.is_scene_preloaded("res://addons/gut/gui/GutRunner.tscn"), "新写入的预加载场景应保留。")


func test_setting_preloaded_scene_limit_to_zero_clears_cache() -> void:
	_scene_util.put_preloaded_scene("res://addons/gut/gui/NormalGui.tscn", _make_empty_scene())

	_scene_util.max_preloaded_scene_resources = 0

	assert_false(_scene_util.is_scene_preloaded("res://addons/gut/gui/NormalGui.tscn"), "容量设为 0 时应清空预加载缓存。")


func test_load_scene_async_uses_preloaded_scene() -> void:
	var scene_path := "res://addons/gut/gui/NormalGui.tscn"
	_scene_util.put_preloaded_scene(scene_path, _make_empty_scene())
	watch_signals(_scene_util)

	_scene_util.load_scene_async(scene_path)

	assert_eq(_scene_util.packed_scene_changes, 1, "命中预加载缓存时应直接切换 PackedScene。")
	assert_false(_scene_util._is_loading, "缓存命中完成切场后应重置 loading 状态。")
	assert_signal_emitted(_scene_util, "scene_load_completed", "缓存命中也应发出加载完成信号。")


func test_scene_transition_config_can_drive_scene_load() -> void:
	var config := GFSceneTransitionConfigBase.new()
	config.target_scene_path = "res://addons/gut/gui/NormalGui.tscn"
	config.cache_loaded_scene = false

	var error := _scene_util.load_scene_with_transition(config)

	assert_eq(error, OK, "场景切换配置应能发起加载。")
	assert_true(_scene_util._is_loading, "配置化场景切换应进入加载状态。")
	assert_false(_scene_util._active_load_cache_loaded_scene, "配置化场景切换应应用本次缓存策略。")


func test_scene_cache_debug_snapshot_reports_cached_paths() -> void:
	_scene_util.put_preloaded_scene("res://addons/gut/gui/NormalGui.tscn", _make_empty_scene())

	var snapshot := _scene_util.get_scene_cache_debug_snapshot()
	var preload_cache := snapshot["preload_cache"] as Dictionary

	assert_eq(preload_cache["size"], 1, "调试快照应包含预加载缓存数量。")
	assert_true((preload_cache["paths"] as PackedStringArray).has("res://addons/gut/gui/NormalGui.tscn"), "调试快照应包含缓存路径。")


func _make_empty_scene() -> PackedScene:
	var node := Node.new()
	var scene := PackedScene.new()
	scene.pack(node)
	node.free()
	return scene
