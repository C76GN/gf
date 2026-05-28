## 测试 GFResourceRegistryTools 的扫描和注册表生成能力。
extends GutTest


# --- 常量 ---

const GFResourceRegistryBase = preload("res://addons/gf/standard/utilities/assets/gf_resource_registry.gd")
const GFResourceRegistryToolsBase = preload("res://addons/gf/standard/utilities/assets/gf_resource_registry_tools.gd")


# --- 测试方法 ---

func test_create_registry_from_paths_generates_ids_hints_and_path_fields() -> void:
	var registry := GFResourceRegistryToolsBase.create_registry_from_paths(PackedStringArray([
		"res://assets/ui/menu.tscn",
		"res://assets/audio/click.ogg",
	]), {
		"id_mode": "relative_path",
		"base_path": "res://assets",
		"path_separator": ".",
		"fields_by_id": {
			"ui.menu": {
				&"purpose": "screen",
			},
		},
	})
	var menu_fields := registry.get_entry_fields(&"ui.menu")
	var menu_tags := menu_fields.get(&"tags", PackedStringArray()) as PackedStringArray

	assert_true(registry.has_entry(&"ui.menu"), "应按相对路径生成稳定资源 ID。")
	assert_true(registry.has_entry(&"audio.click"), "应导入全部支持的路径。")
	assert_eq(registry.get_entry_type_hint(&"ui.menu"), "PackedScene", "场景路径应推导 PackedScene type_hint。")
	assert_eq(registry.get_entry_type_hint(&"audio.click"), "AudioStream", "音频路径应推导 AudioStream type_hint。")
	assert_eq(menu_fields.get(&"category", ""), "ui", "默认 category 应来自相对目录首段。")
	assert_true(menu_tags.has("ui"), "默认 tags 应包含相对目录段。")
	assert_eq(menu_fields.get(&"purpose", ""), "screen", "调用方字段覆盖应合并到条目字段。")
	assert_eq(registry.query(&"category", "ui"), PackedStringArray(["ui.menu"]), "生成字段应可直接用于注册表查询。")


func test_add_paths_to_registry_skips_existing_ids_without_overwrite() -> void:
	var registry := GFResourceRegistryBase.new()
	GFResourceRegistryToolsBase.add_paths_to_registry(registry, PackedStringArray([
		"res://assets/ui/click.png",
	]), {
		"id_mode": "basename",
	})

	var report := GFResourceRegistryToolsBase.add_paths_to_registry(registry, PackedStringArray([
		"res://assets/icons/click.png",
	]), {
		"id_mode": "basename",
	})
	var counts := report.get_issue_counts_by_kind()

	assert_eq(counts.get("resource_entry_id_exists", 0), 1, "重复 ID 且未开启覆盖时应跳过。")
	assert_eq(registry.get_entry_path(&"click"), "res://assets/ui/click.png", "原有条目不应被覆盖。")
	assert_eq(report.metadata.get("skipped_count", 0), 1, "报告应记录跳过数量。")


func test_scan_resource_paths_respects_extension_and_count_limits() -> void:
	var root_path := "user://gf_resource_registry_tools_scan"
	var nested_path := root_path.path_join("ui")
	var first_path := nested_path.path_join("first.tscn")
	var second_path := nested_path.path_join("second.png")
	var ignored_path := nested_path.path_join("ignored.txt")
	DirAccess.make_dir_recursive_absolute(nested_path)
	_write_empty_user_file(first_path)
	_write_empty_user_file(second_path)
	_write_empty_user_file(ignored_path)

	var paths := GFResourceRegistryToolsBase.scan_resource_paths(root_path, {
		"extensions": PackedStringArray(["tscn", "png"]),
		"max_resource_paths": 1,
	})

	_remove_user_file(first_path)
	_remove_user_file(second_path)
	_remove_user_file(ignored_path)
	_remove_user_dir(nested_path)
	_remove_user_dir(root_path)

	assert_eq(paths.size(), 1, "资源扫描应遵守 max_resource_paths 上限。")


# --- 私有/辅助方法 ---

func _write_empty_user_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "测试应能创建 user:// 临时文件。")
	if file != null:
		file.store_string("")
		file.close()


func _remove_user_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _remove_user_dir(path: String) -> void:
	var global_path := ProjectSettings.globalize_path(path)
	if DirAccess.dir_exists_absolute(global_path):
		DirAccess.remove_absolute(global_path)
