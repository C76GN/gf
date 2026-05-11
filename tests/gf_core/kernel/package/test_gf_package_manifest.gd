## 测试 GF 包 manifest 与目录发现辅助。
extends GutTest


# --- 常量 ---

const GF_PACKAGE_CATALOG_BASE := preload("res://addons/gf/kernel/package/gf_package_catalog.gd")
const GF_PACKAGE_EXPORT_PLUGIN_BASE := preload("res://addons/gf/kernel/editor/package/gf_package_export_plugin.gd")
const GF_PACKAGE_MANIFEST_BASE := preload("res://addons/gf/kernel/package/gf_package_manifest.gd")
const GF_PACKAGE_SETTINGS_BASE := preload("res://addons/gf/kernel/package/gf_package_settings.gd")
const GF_PACKAGE_USAGE_AUDIT_BASE := preload("res://addons/gf/kernel/package/gf_package_usage_audit.gd")


# --- 测试方法 ---

func test_manifest_from_dictionary_normalizes_fields() -> void:
	var manifest := GF_PACKAGE_MANIFEST_BASE.from_dictionary({
		"id": "author.terrain",
		"display_name": "Terrain Tools",
		"version": "1.0.0",
		"kind": "community",
		"description": "Example package.",
		"dependencies": ["gf.kernel", &"gf.standard"],
		"installer_paths": PackedStringArray(["res://addons/gf/packages/community/terrain/package.gd"]),
		"tags": ["terrain", "editor"],
	}, "res://addons/gf/packages/community/terrain", "res://addons/gf/packages/community/terrain/gf_package.json")

	assert_true(manifest.is_valid(), "完整 manifest 应通过基础校验。")
	assert_eq(manifest.id, "author.terrain", "应读取稳定包 ID。")
	assert_eq(manifest.dependencies, ["gf.kernel", "gf.standard"], "依赖列表应归一化为字符串数组。")
	assert_eq(manifest.installer_paths.size(), 1, "installer_paths 应支持 PackedStringArray。")
	assert_false(manifest.enabled_by_default, "社区包默认不应自动启用。")


func test_official_manifest_defaults_to_enabled() -> void:
	var manifest := GF_PACKAGE_MANIFEST_BASE.from_dictionary({
		"id": "gf.official.example",
		"display_name": "GF Example",
		"version": "3.0.0",
		"kind": "official",
	}, "res://addons/gf/packages/official/example", "res://addons/gf/packages/official/example/gf_package.json")

	assert_true(manifest.enabled_by_default, "官方包默认应随 GF 启用。")


func test_manifest_validation_reports_required_fields() -> void:
	var manifest := GF_PACKAGE_MANIFEST_BASE.from_dictionary({}, "", "")
	var errors := manifest.get_validation_errors()

	assert_true(errors.has("id is required"), "缺少 id 应报告错误。")
	assert_true(errors.has("display_name is required"), "缺少 display_name 应报告错误。")
	assert_true(errors.has("version is required"), "缺少 version 应报告错误。")
	assert_true(errors.has("root_path is required"), "缺少 root_path 应报告错误。")


func test_catalog_loads_official_manifests() -> void:
	var manifests := GF_PACKAGE_CATALOG_BASE.load_official_manifests()
	var ids: Array[String] = []
	for manifest: GFPackageManifest in manifests:
		ids.append(manifest.id)
		assert_true(manifest.is_valid(), "%s manifest 应满足基础规范：%s" % [
			manifest.id,
			", ".join(manifest.get_validation_errors()),
		])

	assert_true(ids.has("gf.official.combat"), "官方包目录应能发现 combat manifest。")
	assert_true(ids.has("gf.official.network"), "官方包目录应能发现 network manifest。")
	assert_true(ids.has("gf.official.save"), "官方包目录应能发现 save manifest。")


func test_package_settings_resolves_manifest_dependencies() -> void:
	var base_manifest := GF_PACKAGE_MANIFEST_BASE.from_dictionary({
		"id": "author.base",
		"display_name": "Base",
		"version": "1.0.0",
		"kind": "community",
	}, "res://addons/gf/packages/community/base", "")
	var feature_manifest := GF_PACKAGE_MANIFEST_BASE.from_dictionary({
		"id": "author.feature",
		"display_name": "Feature",
		"version": "1.0.0",
		"kind": "community",
		"dependencies": ["gf.kernel", "author.base"],
	}, "res://addons/gf/packages/community/feature", "")

	var manifests: Array[GFPackageManifest] = [base_manifest, feature_manifest]
	var resolved := GF_PACKAGE_SETTINGS_BASE.resolve_package_dependencies(["author.feature"], manifests)

	assert_eq(resolved, ["author.base", "author.feature"], "启用包应按 manifest 顺序自动补齐内部依赖。")


func test_default_enabled_package_ids_include_official_packages() -> void:
	var ids := GF_PACKAGE_SETTINGS_BASE.get_default_enabled_package_ids()

	assert_true(ids.has("gf.official.combat"), "官方 combat 包应默认启用。")
	assert_true(ids.has("gf.official.save"), "官方 save 包应默认启用。")


func test_official_manifests_do_not_depend_on_other_official_packages() -> void:
	var issues := PackedStringArray()
	for manifest: GFPackageManifest in GF_PACKAGE_CATALOG_BASE.load_official_manifests():
		for dependency_id: String in manifest.dependencies:
			if dependency_id.begins_with("gf.official."):
				issues.append("%s depends on %s" % [manifest.id, dependency_id])

	assert_eq(Array(issues), [], "官方包之间不应建立强依赖；需要联动时应通过协议或动态探测。")


func test_kernel_and_standard_do_not_hard_preload_official_packages() -> void:
	var files: Array[String] = []
	_collect_gd_files("res://addons/gf/kernel", files)
	_collect_gd_files("res://addons/gf/standard", files)

	var issues := PackedStringArray()
	for path: String in files:
		var source := _read_text(path)
		if source.contains("preload(\"res://addons/gf/packages/official"):
			issues.append(path)

	assert_eq(Array(issues), [], "kernel 与 standard 不能硬 preload 可选官方包脚本。")


func test_package_export_plugin_matches_disabled_roots() -> void:
	assert_true(
		GF_PACKAGE_EXPORT_PLUGIN_BASE._path_is_under(
			"res://addons/gf/packages/official/save/graph/gf_save_graph_utility.gd",
			"res://addons/gf/packages/official/save"
		),
		"禁用包根目录下的文件应被导出过滤命中。"
	)
	assert_true(
		GF_PACKAGE_EXPORT_PLUGIN_BASE._path_is_under(
			"res://addons/gf/packages/official/save",
			"res://addons/gf/packages/official/save"
		),
		"禁用包根目录本身也应被导出过滤命中。"
	)
	assert_false(
		GF_PACKAGE_EXPORT_PLUGIN_BASE._path_is_under(
			"res://addons/gf/packages/official/save_extra/gf_package.json",
			"res://addons/gf/packages/official/save"
		),
		"前缀相似但不在根目录内的路径不应被误过滤。"
	)


func test_package_usage_audit_finds_project_reference() -> void:
	var directory := "user://gf_package_usage_audit"
	var path := directory.path_join("uses_save.gd")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string('const SaveGraph = preload("res://addons/gf/packages/official/save/graph/gf_save_graph_utility.gd")')
	file.close()

	var references: Array = GF_PACKAGE_USAGE_AUDIT_BASE.find_references_to_root(
		"res://addons/gf/packages/official/save",
		{
			"scan_roots": [directory],
			"ignored_roots": [],
		}
	)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))

	assert_eq(references.size(), 1, "直接 preload 禁用包目录下的脚本应被审计发现。")
	assert_eq(String(references[0].get("path", "")), path, "审计结果应包含引用文件路径。")


func test_package_usage_audit_does_not_match_similar_prefix() -> void:
	var directory := "user://gf_package_usage_audit"
	var path := directory.path_join("uses_save_extra.gd")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string('const Other = preload("res://addons/gf/packages/official/save_extra/example.gd")')
	file.close()

	var references: Array = GF_PACKAGE_USAGE_AUDIT_BASE.find_references_to_root(
		"res://addons/gf/packages/official/save",
		{
			"scan_roots": [directory],
			"ignored_roots": [],
		}
	)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))

	assert_true(references.is_empty(), "包根目录前缀相似但不在目录内时不应误报。")


func test_package_usage_audit_finds_class_name_reference() -> void:
	var directory := "user://gf_package_usage_audit"
	var path := directory.path_join("uses_save_class.gd")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("var save_graph: GFSaveGraphUtility = null")
	file.close()

	var references: Array = GF_PACKAGE_USAGE_AUDIT_BASE.find_references_to_root(
		"res://addons/gf/packages/official/save",
		{
			"scan_roots": [directory],
			"ignored_roots": [],
		}
	)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))

	assert_eq(references.size(), 1, "直接使用禁用包 class_name 时应被审计发现。")
	assert_eq(String(references[0].get("kind", "")), "class_name", "审计结果应标记 class_name 引用。")
	assert_eq(String(references[0].get("symbol", "")), "GFSaveGraphUtility", "审计结果应包含命中的类名。")


# --- 私有/辅助方法 ---

func _collect_gd_files(root_path: String, result: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var path := root_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_collect_gd_files(path, result)
		elif entry.ends_with(".gd"):
			result.append(path)
		entry = dir.get_next()
	dir.list_dir_end()


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text
