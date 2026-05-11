## 测试 GFScenePreloadMap 与 GFSceneUtility 的图谱预加载流程。
extends GutTest


const GFScenePreloadEntryBase = preload("res://addons/gf/standard/utilities/scene/gf_scene_preload_entry.gd")
const NORMAL_GUI_SCENE: String = "res://addons/gut/gui/NormalGui.tscn"
const MIN_GUI_SCENE: String = "res://addons/gut/gui/MinGui.tscn"
const GUT_RUNNER_SCENE: String = "res://addons/gut/gui/GutRunner.tscn"


class TestSceneUtility extends GFSceneUtility:
	var packed_scene_changes: int = 0
	var requested_fixed_paths: PackedStringArray = PackedStringArray()
	var requested_temporary_paths: PackedStringArray = PackedStringArray()

	func _do_change_scene(_scene: PackedScene) -> bool:
		packed_scene_changes += 1
		return true

	func preload_scene(path: String, fixed: bool = false) -> Error:
		if fixed:
			requested_fixed_paths.append(path)
		else:
			requested_temporary_paths.append(path)
		return OK


func test_preload_map_collects_neighbors_by_radius() -> void:
	var preload_map := GFScenePreloadMap.new()
	preload_map.entries = [
		_make_entry("res://hub.tscn", PackedStringArray(["res://a.tscn", "res://b.tscn"])),
		_make_entry("res://a.tscn", PackedStringArray(["res://c.tscn"])),
	]

	assert_eq(
		preload_map.get_neighbor_scene_paths("res://hub.tscn", 1),
		PackedStringArray(["res://a.tscn", "res://b.tscn"]),
		"半径 1 应只返回直接相邻场景。"
	)
	assert_eq(
		preload_map.get_neighbor_scene_paths("res://hub.tscn", 2),
		PackedStringArray(["res://a.tscn", "res://b.tscn", "res://c.tscn"]),
		"半径 2 应包含下一层相邻场景。"
	)


func test_preload_plan_separates_fixed_and_temporary_paths() -> void:
	var preload_map := GFScenePreloadMap.new()
	preload_map.fixed_scene_paths = PackedStringArray(["res://global.tscn"])
	preload_map.entries = [
		_make_entry("res://hub.tscn", PackedStringArray(["res://a.tscn", "res://b.tscn"])),
		_make_entry("res://b.tscn", PackedStringArray(), true),
	]

	var plan := preload_map.get_preload_plan("res://hub.tscn", 1)

	assert_eq(plan["fixed_paths"], PackedStringArray(["res://global.tscn", "res://b.tscn"]), "固定路径应单独归类。")
	assert_eq(plan["temporary_paths"], PackedStringArray(["res://a.tscn"]), "非固定相邻场景应进入临时路径。")
	assert_eq(plan["paths"], PackedStringArray(["res://global.tscn", "res://b.tscn", "res://a.tscn"]), "总路径应固定优先并去重。")


func test_preload_map_validation_reports_duplicates_and_missing_resources() -> void:
	var preload_map := GFScenePreloadMap.new()
	preload_map.entries = [
		_make_entry("res://missing_scene.tscn"),
		_make_entry("res://missing_scene.tscn"),
	]

	var report := preload_map.validate_map({ "check_exists": true })

	assert_false(report["healthy"], "重复和缺失资源应让报告不健康。")
	assert_eq((report["issue_counts_by_kind"] as Dictionary)["duplicate_scene_path"], 1, "应报告重复场景路径。")
	assert_true((report["issue_counts_by_kind"] as Dictionary).has("missing_scene_resource"), "应报告缺失资源。")


func test_scene_utility_preloads_map_plan() -> void:
	var preload_map := GFScenePreloadMap.new()
	preload_map.fixed_scene_paths = PackedStringArray([GUT_RUNNER_SCENE])
	preload_map.entries = [
		_make_entry(NORMAL_GUI_SCENE, PackedStringArray([MIN_GUI_SCENE])),
	]
	var scene_utility := TestSceneUtility.new()
	scene_utility.configure_scene_preload_map(preload_map, 1, false)

	var result := scene_utility.preload_scene_map_for(NORMAL_GUI_SCENE)

	assert_true(result["ok"], "有效图谱路径应能发起预加载。")
	assert_eq(result["fixed_requested"], PackedStringArray([GUT_RUNNER_SCENE]), "固定路径应以固定缓存预加载。")
	assert_eq(result["temporary_requested"], PackedStringArray([MIN_GUI_SCENE]), "相邻路径应以临时缓存预加载。")
	assert_eq(scene_utility.requested_fixed_paths, PackedStringArray([GUT_RUNNER_SCENE]), "固定路径应以 fixed=true 发起。")
	assert_eq(scene_utility.requested_temporary_paths, PackedStringArray([MIN_GUI_SCENE]), "相邻路径应以 fixed=false 发起。")
	scene_utility.dispose()


func test_scene_utility_auto_preloads_neighbors_after_successful_switch() -> void:
	var preload_map := GFScenePreloadMap.new()
	preload_map.entries = [
		_make_entry(NORMAL_GUI_SCENE, PackedStringArray([MIN_GUI_SCENE])),
	]
	var scene_utility := TestSceneUtility.new()
	scene_utility.configure_scene_preload_map(preload_map)
	scene_utility.put_preloaded_scene(NORMAL_GUI_SCENE, _make_empty_scene())

	scene_utility.load_scene_async(NORMAL_GUI_SCENE)
	scene_utility.tick(0.0)

	assert_eq(scene_utility.packed_scene_changes, 1, "缓存命中应完成场景切换。")
	assert_eq(scene_utility.requested_temporary_paths, PackedStringArray([MIN_GUI_SCENE]), "切换成功后应自动预加载相邻场景。")
	scene_utility.dispose()


func _make_entry(
	scene_path: String,
	adjacent_paths: PackedStringArray = PackedStringArray(),
	fixed: bool = false
) -> GFScenePreloadEntryBase:
	var entry := GFScenePreloadEntryBase.new()
	entry.scene_path = scene_path
	entry.adjacent_scene_paths = adjacent_paths
	entry.fixed = fixed
	return entry


func _make_empty_scene() -> PackedScene:
	var node := Node.new()
	var scene := PackedScene.new()
	scene.pack(node)
	node.free()
	return scene
