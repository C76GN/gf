## 测试 GFResourceRegistryTools 的扫描和注册表生成能力。
extends GutTest


func test_create_registry_from_paths_generates_ids_hints_and_path_fields() -> void:
	var registry: GFResourceRegistry = GFResourceRegistryTools.create_registry_from_paths(PackedStringArray([
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
	var menu_fields: Dictionary = registry.get_entry_fields(&"ui.menu")
	var menu_tags: PackedStringArray = GFVariantData.get_option_packed_string_array(menu_fields, &"tags")

	assert_true(registry.has_entry(&"ui.menu"), "应按相对路径生成稳定资源 ID。")
	assert_true(registry.has_entry(&"audio.click"), "应导入全部支持的路径。")
	assert_eq(registry.get_entry_type_hint(&"ui.menu"), "PackedScene", "场景路径应推导 PackedScene type_hint。")
	assert_eq(registry.get_entry_type_hint(&"audio.click"), "AudioStream", "音频路径应推导 AudioStream type_hint。")
	assert_eq(GFVariantData.get_option_string(menu_fields, &"category"), "ui", "默认 category 应来自相对目录首段。")
	assert_true(menu_tags.has("ui"), "默认 tags 应包含相对目录段。")
	assert_eq(GFVariantData.get_option_string(menu_fields, &"purpose"), "screen", "调用方字段覆盖应合并到条目字段。")
	assert_eq(registry.query(&"category", "ui"), PackedStringArray(["ui.menu"]), "生成字段应可直接用于注册表查询。")


func test_add_paths_to_registry_skips_existing_ids_without_overwrite() -> void:
	var registry: GFResourceRegistry = GFResourceRegistry.new()
	var _initial_report: GFValidationReport = GFResourceRegistryTools.add_paths_to_registry(registry, PackedStringArray([
		"res://assets/ui/click.png",
	]), {
		"id_mode": "basename",
	})

	var report: GFValidationReport = GFResourceRegistryTools.add_paths_to_registry(registry, PackedStringArray([
		"res://assets/icons/click.png",
	]), {
		"id_mode": "basename",
	})
	var counts: Dictionary = report.get_issue_counts_by_kind()

	assert_eq(GFVariantData.get_option_int(counts, "resource_entry_id_exists"), 1, "重复 ID 且未开启覆盖时应跳过。")
	assert_eq(registry.get_entry_path(&"click"), "res://assets/ui/click.png", "原有条目不应被覆盖。")
	assert_eq(GFVariantData.get_option_int(report.metadata, "skipped_count"), 1, "报告应记录跳过数量。")


func test_scan_resource_paths_respects_extension_and_count_limits() -> void:
	var root_path: String = "user://gf_resource_registry_tools_scan"
	var nested_path: String = root_path.path_join("ui")
	var first_path: String = nested_path.path_join("first.tscn")
	var second_path: String = nested_path.path_join("second.png")
	var ignored_path: String = nested_path.path_join("ignored.txt")
	var make_error: Error = DirAccess.make_dir_recursive_absolute(nested_path)
	assert_true(make_error == OK or make_error == ERR_ALREADY_EXISTS, "测试应能创建 user:// 临时目录。")
	_write_empty_user_file(first_path)
	_write_empty_user_file(second_path)
	_write_empty_user_file(ignored_path)

	var paths: PackedStringArray = GFResourceRegistryTools.scan_resource_paths(root_path, {
		"extensions": PackedStringArray(["tscn", "png"]),
		"max_resource_paths": 1,
	})

	_remove_user_file(first_path)
	_remove_user_file(second_path)
	_remove_user_file(ignored_path)
	_remove_user_dir(nested_path)
	_remove_user_dir(root_path)

	assert_push_warning("[GFResourceRegistryTools] scan_resource_paths 已达到 max_resource_paths=1，后续资源已跳过。")
	assert_eq(paths.size(), 1, "资源扫描应遵守 max_resource_paths 上限。")


func test_collect_dependency_paths_reads_direct_external_resource_dependencies() -> void:
	var dependency_path: String = "user://gf_resource_registry_tools_dependency_entry.tres"
	var root_path: String = "user://gf_resource_registry_tools_dependency_registry.tres"
	var entry: GFResourceRegistryEntry = GFResourceRegistryEntry.new()
	var _configured_entry: Resource = entry.configure(&"menu", "res://assets/ui/menu.tscn", "PackedScene")
	assert_eq(ResourceSaver.save(entry, dependency_path), OK, "测试应能保存依赖资源。")

	var dependency: GFResourceRegistryEntry = ResourceLoader.load(dependency_path) as GFResourceRegistryEntry
	assert_not_null(dependency, "测试应能加载依赖资源。")
	var registry: GFResourceRegistry = GFResourceRegistry.new()
	registry.entries.append(dependency)
	assert_eq(ResourceSaver.save(registry, root_path), OK, "测试应能保存引用依赖的根资源。")

	var paths: PackedStringArray = GFResourceRegistryTools.collect_dependency_paths(root_path, {
		"recursive": false,
		"include_root": true,
		"extensions": PackedStringArray(["tres"]),
	})

	_remove_user_file(root_path)
	_remove_user_file(dependency_path)

	assert_true(paths.has(root_path), "include_root 应包含入口资源。")
	assert_true(paths.has(dependency_path), "依赖收集应包含外部 Resource 引用。")


func test_collect_dependency_paths_respects_limit() -> void:
	var dependency_path: String = "user://gf_resource_registry_tools_limited_dependency.tres"
	var root_path: String = "user://gf_resource_registry_tools_limited_registry.tres"
	var entry: GFResourceRegistryEntry = GFResourceRegistryEntry.new()
	var _configured_entry: Resource = entry.configure(&"menu", "res://assets/ui/menu.tscn", "PackedScene")
	assert_eq(ResourceSaver.save(entry, dependency_path), OK, "测试应能保存依赖资源。")
	var registry: GFResourceRegistry = GFResourceRegistry.new()
	registry.entries.append(ResourceLoader.load(dependency_path) as GFResourceRegistryEntry)
	assert_eq(ResourceSaver.save(registry, root_path), OK, "测试应能保存引用依赖的根资源。")

	var paths: PackedStringArray = GFResourceRegistryTools.collect_dependency_paths(root_path, {
		"include_root": true,
		"max_dependency_paths": 1,
		"extensions": PackedStringArray(["tres"]),
	})

	_remove_user_file(root_path)
	_remove_user_file(dependency_path)

	assert_push_warning("[GFResourceRegistryTools] collect_dependency_paths 已达到 max_dependency_paths=1，后续依赖已跳过。")
	assert_eq(paths.size(), 1, "依赖收集应遵守 max_dependency_paths 上限。")


# --- 私有/辅助方法 ---

func _write_empty_user_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "测试应能创建 user:// 临时文件。")
	if file != null:
		var _store_string_result_85: Variant = file.store_string("")
		file.close()


func _remove_user_file(path: String) -> void:
	if FileAccess.file_exists(path):
		var remove_error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		assert_eq(remove_error, OK, "测试应能删除 user:// 临时文件。")


func _remove_user_dir(path: String) -> void:
	var global_path: String = ProjectSettings.globalize_path(path)
	if DirAccess.dir_exists_absolute(global_path):
		var remove_error: Error = DirAccess.remove_absolute(global_path)
		assert_eq(remove_error, OK, "测试应能删除 user:// 临时目录。")
