## 测试 GF 扩展 manifest 与目录发现辅助。
extends GutTest


# --- 常量 ---

const GF_EXTENSION_CATALOG_BASE := preload("res://addons/gf/kernel/extension/gf_extension_catalog.gd")
const GF_EXTENSION_EXPORT_PLUGIN_BASE := preload("res://addons/gf/kernel/editor/extension/gf_extension_export_plugin.gd")
const GF_EXTENSION_MANIFEST_BASE := preload("res://addons/gf/kernel/extension/gf_extension_manifest.gd")
const GF_EXTENSION_SETTINGS_BASE := preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")
const GF_EXTENSION_USAGE_AUDIT_BASE := preload("res://addons/gf/kernel/extension/gf_extension_usage_audit.gd")
const OFFICIAL_EXTENSION_ROOT: String = "res://addons/gf/extensions/official"
const OFFICIAL_EXTENSION_ALLOWED_DEPENDENCIES: Array[String] = [
	"gf.kernel",
	"gf.standard",
]
const KERNEL_OFFICIAL_REFERENCE_ALLOWED_FILES: Dictionary = {
	"res://addons/gf/kernel/extension/gf_extension_catalog.gd": true,
	"res://addons/gf/kernel/extension/gf_extension_usage_audit.gd": true,
}
const KERNEL_STANDARD_OFFICIAL_CLASS_REFERENCE_ALLOWED_FILES: Dictionary = {
	"res://addons/gf/kernel/editor/gf_plugin_actions.gd": true,
}


# --- 测试方法 ---

func test_manifest_from_dictionary_normalizes_fields() -> void:
	var manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "author.terrain",
		"display_name": "Terrain Tools",
		"version": "1.0.0",
		"extension_version": "1.2.3",
		"kind": "community",
		"description": "Example extension.",
		"dependencies": ["gf.kernel", &"gf.standard"],
		"optional_dependencies": ["author.debug_overlay"],
		"installer_paths": PackedStringArray(["res://addons/gf/extensions/community/terrain/extension.gd"]),
		"editor_action_paths": ["res://addons/gf/extensions/community/terrain/editor/terrain_actions.gd"],
		"editor_dock_paths": ["res://addons/gf/extensions/community/terrain/editor/terrain_dock.gd"],
		"editor_inspector_paths": ["res://addons/gf/extensions/community/terrain/editor/terrain_inspector.gd"],
		"export_plugin_paths": ["res://addons/gf/extensions/community/terrain/editor/terrain_export_plugin.gd"],
		"access_generator_extension_paths": ["res://addons/gf/extensions/community/terrain/editor/terrain_access_generator.gd"],
		"tags": ["terrain", "editor"],
	}, "res://addons/gf/extensions/community/terrain", "res://addons/gf/extensions/community/terrain/gf_extension.json")

	assert_true(manifest.is_valid(), "完整 manifest 应通过基础校验。")
	assert_eq(manifest.id, "author.terrain", "应读取稳定扩展 ID。")
	assert_eq(manifest.version, "1.0.0", "应读取扩展发行版本。")
	assert_eq(manifest.extension_version, "1.2.3", "应读取扩展自身版本。")
	assert_eq(manifest.dependencies, ["gf.kernel", "gf.standard"], "依赖列表应归一化为字符串数组。")
	assert_eq(manifest.optional_dependencies, ["author.debug_overlay"], "可选协作依赖应归一化为字符串数组。")
	assert_eq(manifest.installer_paths.size(), 1, "installer_paths 应支持 PackedStringArray。")
	assert_eq(manifest.editor_action_paths.size(), 1, "editor_action_paths 应读取为字符串数组。")
	assert_eq(manifest.editor_dock_paths.size(), 1, "editor_dock_paths 应读取为字符串数组。")
	assert_eq(manifest.editor_inspector_paths.size(), 1, "editor_inspector_paths 应读取为字符串数组。")
	assert_eq(manifest.export_plugin_paths.size(), 1, "export_plugin_paths 应读取为字符串数组。")
	assert_eq(manifest.access_generator_extension_paths.size(), 1, "access_generator_extension_paths 应读取为字符串数组。")
	assert_false(manifest.enabled_by_default, "社区扩展默认不应自动启用。")


func test_official_manifest_defaults_to_enabled() -> void:
	var manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "gf.official.example",
		"display_name": "GF Example",
		"version": "3.0.0",
		"extension_version": "1.0.0",
		"kind": "official",
	}, "res://addons/gf/extensions/official/example", "res://addons/gf/extensions/official/example/gf_extension.json")

	assert_true(manifest.enabled_by_default, "官方扩展默认应随 GF 启用。")


func test_manifest_validation_reports_required_fields() -> void:
	var manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({}, "", "")
	var errors := manifest.get_validation_errors()

	assert_true(errors.has("id is required"), "缺少 id 应报告错误。")
	assert_true(errors.has("display_name is required"), "缺少 display_name 应报告错误。")
	assert_true(errors.has("version is required"), "缺少 version 应报告错误。")
	assert_true(errors.has("root_path is required"), "缺少 root_path 应报告错误。")

	var missing_extension_version_manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "gf.official.example",
		"display_name": "GF Example",
		"version": "3.1.0",
		"kind": "official",
	}, "res://addons/gf/extensions/official/example", "")
	var missing_extension_version_errors := missing_extension_version_manifest.get_validation_errors()
	var official_manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "gf.official.example",
		"display_name": "GF Example",
		"version": "3.1.0",
		"kind": "official",
		"extension_version": "",
	}, "res://addons/gf/extensions/official/example", "")
	var official_errors := official_manifest.get_validation_errors()
	var coupled_official_manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "gf.official.example",
		"display_name": "GF Example",
		"version": "3.1.0",
		"kind": "official",
		"extension_version": "1.0.0",
		"dependencies": ["gf.official.save"],
		"optional_dependencies": ["gf.official.feedback"],
	}, "res://addons/gf/extensions/official/example", "")
	var coupled_official_errors := coupled_official_manifest.get_validation_errors()

	assert_true(
		missing_extension_version_errors.has("extension_version is required for official extensions"),
		"官方扩展缺少 extension_version 应报告错误。"
	)
	assert_true(
		official_errors.has("extension_version is required for official extensions"),
		"官方扩展应显式声明 extension_version。"
	)
	assert_true(
		coupled_official_errors.has("official extension dependencies must be gf.kernel or gf.standard: gf.official.save"),
		"官方扩展不应把其他官方扩展声明为强依赖。"
	)
	assert_true(
		coupled_official_errors.has("optional_dependencies are not allowed for official extensions"),
		"官方扩展不应声明可选依赖。"
	)


func test_manifest_validation_keeps_extension_paths_inside_root() -> void:
	var manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "author.terrain",
		"display_name": "Terrain Tools",
		"version": "1.0.0",
		"kind": "community",
		"editor_action_paths": ["res://addons/gf/extensions/community/other/editor/actions.gd"],
		"export_plugin_paths": ["user://terrain_export_plugin.gd"],
	}, "res://addons/gf/extensions/community/terrain", "")
	var errors := manifest.get_validation_errors()

	assert_true(
		errors.has("editor_action_paths path must stay under root_path: res://addons/gf/extensions/community/other/editor/actions.gd"),
		"扩展编辑器扩展路径不应越过扩展根目录。"
	)
	assert_true(
		errors.has("export_plugin_paths path must be res://: user://terrain_export_plugin.gd"),
		"扩展导出扩展应声明 res:// 脚本路径。"
	)


func test_catalog_loads_official_manifests() -> void:
	var manifests := GF_EXTENSION_CATALOG_BASE.load_official_manifests()
	var ids: Array[String] = []
	for manifest: GFExtensionManifest in manifests:
		ids.append(manifest.id)
		assert_true(manifest.is_valid(), "%s manifest 应满足基础规范：%s" % [
			manifest.id,
			", ".join(manifest.get_validation_errors()),
		])

	assert_true(ids.has("gf.official.combat"), "官方扩展目录应能发现 combat manifest。")
	assert_true(ids.has("gf.official.network"), "官方扩展目录应能发现 network manifest。")
	assert_true(ids.has("gf.official.save"), "官方扩展目录应能发现 save manifest。")


func test_official_manifest_versions_follow_release_policy() -> void:
	var framework_version := _read_framework_version()
	var issues := PackedStringArray()
	for manifest: GFExtensionManifest in GF_EXTENSION_CATALOG_BASE.load_official_manifests():
		var manifest_data := _read_json_dictionary(manifest.source_path)
		if manifest.version != framework_version:
			issues.append("%s version %s != framework %s" % [
				manifest.id,
				manifest.version,
				framework_version,
			])
		if not manifest_data.has("extension_version"):
			issues.append("%s does not declare extension_version" % manifest.id)
		if not _is_semver(manifest.extension_version):
			issues.append("%s extension_version is not semver: %s" % [
				manifest.id,
				manifest.extension_version,
			])

	assert_eq(
		Array(issues),
		[],
		"官方扩展 manifest.version 必须跟随 GF 发行版本，extension_version 必须记录扩展自身 SemVer。"
	)


func test_extension_settings_resolves_manifest_dependencies() -> void:
	var base_manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "author.base",
		"display_name": "Base",
		"version": "1.0.0",
		"kind": "community",
	}, "res://addons/gf/extensions/community/base", "")
	var feature_manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "author.feature",
		"display_name": "Feature",
		"version": "1.0.0",
		"kind": "community",
		"dependencies": ["gf.kernel", "author.base"],
	}, "res://addons/gf/extensions/community/feature", "")

	var manifests: Array[GFExtensionManifest] = [base_manifest, feature_manifest]
	var resolved := GF_EXTENSION_SETTINGS_BASE.resolve_extension_dependencies(["author.feature"], manifests)

	assert_eq(resolved, ["author.base", "author.feature"], "启用扩展应按 manifest 顺序自动补齐内部依赖。")


func test_extension_settings_resolves_dependency_cycles_without_recursing_forever() -> void:
	var first_manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "author.first",
		"display_name": "First",
		"version": "1.0.0",
		"kind": "community",
		"dependencies": ["author.second"],
	}, "res://addons/gf/extensions/community/first", "")
	var second_manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "author.second",
		"display_name": "Second",
		"version": "1.0.0",
		"kind": "community",
		"dependencies": ["author.first"],
	}, "res://addons/gf/extensions/community/second", "")

	var manifests: Array[GFExtensionManifest] = [first_manifest, second_manifest]
	var resolved := GF_EXTENSION_SETTINGS_BASE.resolve_extension_dependencies(["author.first"], manifests)
	var report := GF_EXTENSION_SETTINGS_BASE.get_manifest_graph_report(manifests)
	var cycles := report.get("dependency_cycles", []) as Array

	assert_eq(resolved, ["author.first", "author.second"], "循环依赖不应导致递归卡死，仍应返回已解析扩展。")
	assert_false(bool(report.get("ok")), "循环依赖应让图诊断失败。")
	assert_eq(cycles.size(), 1, "应报告一条依赖循环。")
	assert_eq(Array(cycles[0]), ["author.first", "author.second", "author.first"], "循环路径应保留闭环顺序。")
	assert_push_warning("[GFExtensionSettings] 检测到扩展依赖循环：author.first -> author.second -> author.first")


func test_manifest_graph_report_includes_missing_dependencies_and_duplicates() -> void:
	var first_manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "author.feature",
		"display_name": "Feature",
		"version": "1.0.0",
		"kind": "community",
		"dependencies": ["gf.kernel", "author.missing"],
	}, "res://addons/gf/extensions/community/feature", "")
	var duplicate_manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "author.feature",
		"display_name": "Feature Duplicate",
		"version": "1.0.0",
		"kind": "community",
	}, "res://addons/gf/extensions/community/feature_duplicate", "")

	var report := GF_EXTENSION_SETTINGS_BASE.get_manifest_graph_report([first_manifest, duplicate_manifest])
	var missing_dependencies := report.get("missing_dependencies", []) as Array
	var duplicate_ids := report.get("duplicate_ids", PackedStringArray()) as PackedStringArray

	assert_false(bool(report.get("ok")), "缺失依赖或重复 ID 应让图诊断失败。")
	assert_true(duplicate_ids.has("author.feature"), "重复扩展 ID 应写入 duplicate_ids。")
	assert_eq(missing_dependencies.size(), 1, "内置依赖不应被当作缺失扩展，真实缺失依赖应被报告。")
	assert_eq(String((missing_dependencies[0] as Dictionary).get("dependency_id", "")), "author.missing", "缺失依赖 ID 应可用于编辑器提示。")


func test_manifest_graph_report_treats_missing_optional_dependencies_as_warnings() -> void:
	var manifest := GF_EXTENSION_MANIFEST_BASE.from_dictionary({
		"id": "author.feature",
		"display_name": "Feature",
		"version": "1.0.0",
		"kind": "community",
		"optional_dependencies": ["author.overlay"],
	}, "res://addons/gf/extensions/community/feature", "")

	var report := GF_EXTENSION_SETTINGS_BASE.get_manifest_graph_report([manifest])
	var optional_warnings := report.get("optional_dependency_warnings", []) as Array

	assert_true(bool(report.get("ok")), "缺失可选依赖不应让扩展图失败。")
	assert_eq(int(report.get("warning_count", 0)), 1, "缺失可选依赖应进入提示计数。")
	assert_eq(optional_warnings.size(), 1, "缺失可选依赖应保留可展示记录。")
	assert_eq(String((optional_warnings[0] as Dictionary).get("dependency_id", "")), "author.overlay", "可选依赖提示应包含依赖 ID。")


func test_default_enabled_extension_ids_include_official_extensions() -> void:
	var ids := GF_EXTENSION_SETTINGS_BASE.get_default_enabled_extension_ids()
	var expected_ids: Array[String] = []
	for manifest: GFExtensionManifest in GF_EXTENSION_CATALOG_BASE.load_official_manifests():
		if manifest.enabled_by_default:
			expected_ids.append(manifest.id)
	expected_ids.sort()

	assert_eq(ids, expected_ids, "默认启用扩展应与官方 manifest 的 enabled_by_default 保持一致。")
	assert_true(ids.has("gf.official.combat"), "官方 combat 扩展应默认启用。")
	assert_true(ids.has("gf.official.save"), "官方 save 扩展应默认启用。")


func test_official_extension_installer_paths_exist_when_declared() -> void:
	for manifest: GFExtensionManifest in GF_EXTENSION_CATALOG_BASE.load_official_manifests():
		for installer_path: String in manifest.installer_paths:
			assert_true(
				ResourceLoader.exists(installer_path),
				"%s installer 应指向存在的脚本：%s" % [manifest.id, installer_path]
			)


func test_enabled_installer_paths_follow_extension_selection() -> void:
	var setting_restore := _set_project_setting(
		GF_EXTENSION_SETTINGS_BASE.ENABLED_EXTENSIONS_SETTING,
		["gf.official.save"]
	)
	var auto_install_restore := _set_project_setting(
		GF_EXTENSION_SETTINGS_BASE.AUTO_INSTALL_ENABLED_INSTALLERS_SETTING,
		true
	)

	var installer_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_installer_paths()

	_restore_project_setting(GF_EXTENSION_SETTINGS_BASE.AUTO_INSTALL_ENABLED_INSTALLERS_SETTING, auto_install_restore)
	_restore_project_setting(GF_EXTENSION_SETTINGS_BASE.ENABLED_EXTENSIONS_SETTING, setting_restore)

	assert_eq(
		installer_paths,
		["res://addons/gf/extensions/official/save/extension.gd"],
		"启用扩展 installer 应只来自当前启用扩展 manifest。"
	)


func test_extension_settings_can_query_manifest_and_enabled_state() -> void:
	var setting_name: String = GF_EXTENSION_SETTINGS_BASE.ENABLED_EXTENSIONS_SETTING
	var had_setting := ProjectSettings.has_setting(setting_name)
	var previous_value: Variant = ProjectSettings.get_setting(setting_name, [])

	ProjectSettings.set_setting(setting_name, ["gf.official.save"])
	var save_manifest := GF_EXTENSION_SETTINGS_BASE.get_manifest_by_id("gf.official.save")
	var has_save_extension := GF_EXTENSION_SETTINGS_BASE.has_extension("gf.official.save")
	var has_missing_extension := GF_EXTENSION_SETTINGS_BASE.has_extension("gf.official.missing")
	var save_enabled := GF_EXTENSION_SETTINGS_BASE.is_extension_enabled("gf.official.save")
	var combat_enabled := GF_EXTENSION_SETTINGS_BASE.is_extension_enabled("gf.official.combat")
	var missing_enabled := GF_EXTENSION_SETTINGS_BASE.is_extension_enabled("gf.official.missing")
	var save_scope_path := GF_EXTENSION_SETTINGS_BASE.get_extension_resource_path(
		"gf.official.save",
		"core/gf_save_scope.gd"
	)
	var save_scope_script := GF_EXTENSION_SETTINGS_BASE.load_enabled_extension_script(
		"gf.official.save",
		"core/gf_save_scope.gd"
	)
	var save_action_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_editor_action_paths()
	var save_dock_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_editor_dock_paths()
	var save_inspector_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_editor_inspector_paths()
	var save_export_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_export_plugin_paths()
	var save_access_extension_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_access_generator_extension_paths()
	var combat_script := GF_EXTENSION_SETTINGS_BASE.load_enabled_extension_script(
		"gf.official.combat",
		"actions/gf_combat_action.gd"
	)

	if had_setting:
		ProjectSettings.set_setting(setting_name, previous_value)
	else:
		ProjectSettings.clear(setting_name)

	assert_not_null(save_manifest, "应能按 ID 查询官方扩展 manifest。")
	assert_eq(save_manifest.id, "gf.official.save", "manifest 查询结果应匹配请求 ID。")
	assert_true(has_save_extension, "存在 manifest 的扩展应报告存在。")
	assert_false(has_missing_extension, "不存在 manifest 的扩展不应报告存在。")
	assert_true(save_enabled, "显式启用的扩展应报告为启用。")
	assert_false(combat_enabled, "未被当前设置启用的扩展应报告为禁用。")
	assert_false(missing_enabled, "不存在 manifest 的扩展不应报告为启用。")
	assert_eq(save_scope_path, "res://addons/gf/extensions/official/save/core/gf_save_scope.gd", "扩展内资源路径应由 manifest 根目录拼接。")
	assert_not_null(save_scope_script, "启用扩展内脚本应能通过扩展设置统一加载。")
	assert_true(
		save_action_paths.has("res://addons/gf/extensions/official/save/editor/gf_save_editor_actions.gd"),
		"启用扩展的菜单动作路径应由统一查询入口返回。"
	)
	assert_true(save_dock_paths.is_empty(), "Save 扩展未声明 Dock 时应返回空 Dock 路径。")
	assert_true(save_inspector_paths.is_empty(), "Save 扩展未声明 Inspector 时应返回空 Inspector 路径。")
	assert_true(save_export_paths.is_empty(), "Save 扩展未声明导出插件时应返回空导出插件路径。")
	assert_true(save_access_extension_paths.is_empty(), "Save 扩展未声明访问器扩展时应返回空访问器扩展路径。")
	assert_null(combat_script, "未启用扩展内脚本不应被统一加载入口加载。")


func test_extension_selection_report_includes_unknown_enabled_ids() -> void:
	var restore := _set_project_setting(
		GF_EXTENSION_SETTINGS_BASE.ENABLED_EXTENSIONS_SETTING,
		["gf.official.save", "author.missing"]
	)

	var report := GF_EXTENSION_SETTINGS_BASE.get_extension_selection_report()
	var unknown_enabled_ids := report.get("unknown_enabled_ids", []) as Array

	_restore_project_setting(GF_EXTENSION_SETTINGS_BASE.ENABLED_EXTENSIONS_SETTING, restore)

	assert_true(unknown_enabled_ids.has("author.missing"), "启用列表中不存在 manifest 的扩展 ID 应被报告。")
	assert_false(bool(report.get("ok", true)), "存在未知启用扩展时选择诊断不应通过。")


func test_extension_settings_defaults_to_strict_disabled_reference_policy() -> void:
	var setting_name: String = GF_EXTENSION_SETTINGS_BASE.EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING
	var restore := {
		"had_setting": ProjectSettings.has_setting(setting_name),
		"value": ProjectSettings.get_setting(setting_name, null),
	}
	ProjectSettings.clear(setting_name)

	assert_true(
		GF_EXTENSION_SETTINGS_BASE.should_fail_export_on_disabled_extension_references(),
		"默认应把禁用扩展引用审计报告为错误。"
	)

	_restore_project_setting(setting_name, restore)


func test_extension_settings_allows_explicit_warning_only_disabled_reference_policy() -> void:
	var restore := _set_project_setting(
		GF_EXTENSION_SETTINGS_BASE.EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING,
		false
	)

	assert_false(
		GF_EXTENSION_SETTINGS_BASE.should_fail_export_on_disabled_extension_references(),
		"显式 false 时禁用扩展引用审计应仅告警。"
	)

	GF_EXTENSION_SETTINGS_BASE.set_fail_export_on_disabled_extension_references(true)

	assert_true(
		GF_EXTENSION_SETTINGS_BASE.should_fail_export_on_disabled_extension_references(),
		"启用策略后禁用扩展引用审计应报告为错误。"
	)

	_restore_project_setting(GF_EXTENSION_SETTINGS_BASE.EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING, restore)


func test_official_manifest_dependency_graph_is_valid() -> void:
	var report := GF_EXTENSION_SETTINGS_BASE.get_manifest_graph_report(
		GF_EXTENSION_CATALOG_BASE.load_official_manifests()
	)

	assert_true(
		bool(report.get("ok")),
		"官方扩展依赖图必须无缺失、无重复、无环：%s" % report
	)


func test_official_manifests_are_atomic_capability_bundles() -> void:
	var issues := PackedStringArray()
	for manifest: GFExtensionManifest in GF_EXTENSION_CATALOG_BASE.load_official_manifests():
		for dependency_id: String in manifest.dependencies:
			if not OFFICIAL_EXTENSION_ALLOWED_DEPENDENCIES.has(dependency_id):
				issues.append("%s declares dependency %s" % [manifest.id, dependency_id])

		if not manifest.optional_dependencies.is_empty():
			issues.append("%s declares optional_dependencies" % manifest.id)

	assert_eq(
		Array(issues),
		[],
		"官方扩展必须保持原子化：只允许依赖 gf.kernel 与 gf.standard，不能声明官方扩展硬依赖或可选协作。"
	)


func test_kernel_and_standard_do_not_hard_preload_official_extensions() -> void:
	var files: Array[String] = []
	_collect_gd_files("res://addons/gf/kernel", files)
	_collect_gd_files("res://addons/gf/standard", files)

	var issues := PackedStringArray()
	for path: String in files:
		var source := _read_text(path)
		if source.contains("preload(\"res://addons/gf/extensions/official"):
			issues.append(path)

	assert_eq(Array(issues), [], "kernel 与 standard 不能硬 preload 可选官方扩展脚本。")


func test_kernel_official_extension_path_references_stay_in_extension_infrastructure() -> void:
	var files: Array[String] = []
	_collect_gd_files("res://addons/gf/kernel", files)
	_collect_gd_files("res://addons/gf/standard", files)

	var issues := PackedStringArray()
	for path: String in files:
		if KERNEL_OFFICIAL_REFERENCE_ALLOWED_FILES.has(path):
			continue
		var source := _read_text(path)
		if source.contains(OFFICIAL_EXTENSION_ROOT + "/"):
			issues.append(path)

	assert_eq(
		Array(issues),
		[],
		"kernel/standard 只有 extension 基础设施可以知道官方扩展根目录。"
	)


func test_kernel_and_standard_do_not_hard_reference_official_extension_class_names() -> void:
	var official_class_roots := _collect_official_class_roots()
	var files: Array[String] = []
	_collect_gd_files("res://addons/gf/kernel", files)
	_collect_gd_files("res://addons/gf/standard", files)

	var issues := PackedStringArray()
	for path: String in files:
		if KERNEL_STANDARD_OFFICIAL_CLASS_REFERENCE_ALLOWED_FILES.has(path):
			continue

		var source := _read_text(path)
		for class_name_variant: Variant in official_class_roots.keys():
			var class_name_text := String(class_name_variant)
			if _source_contains_identifier(source, class_name_text):
				issues.append("%s references %s" % [path, class_name_text])

	assert_eq(
		Array(issues),
		[],
		"kernel/standard 不应直接引用官方扩展 class_name；可选联动应通过扩展设置和动态脚本加载完成。"
	)


func test_official_extensions_do_not_hard_reference_other_official_extensions() -> void:
	var files: Array[String] = []
	_collect_gd_files(OFFICIAL_EXTENSION_ROOT, files)
	var official_class_roots := _collect_official_class_roots()

	var issues := PackedStringArray()
	for path: String in files:
		var extension_root := _get_official_extension_root(path)
		var source := _read_text(path)
		var referenced_roots := _extract_official_extension_roots(source)
		for referenced_root: String in referenced_roots:
			if not _official_root_can_reference(extension_root, referenced_root):
				issues.append("%s references %s" % [path, referenced_root])

		for class_name_variant: Variant in official_class_roots.keys():
			var class_name_text := String(class_name_variant)
			var class_root := String(official_class_roots[class_name_text])
			if (
				not _official_root_can_reference(extension_root, class_root)
				and _source_contains_identifier(source, class_name_text)
			):
				issues.append("%s references class %s" % [path, class_name_text])

	assert_eq(Array(issues), [], "官方扩展只能硬引用自身；跨官方扩展组合属于项目或社区扩展。")


func test_extension_export_plugin_matches_disabled_roots() -> void:
	assert_true(
		GF_EXTENSION_EXPORT_PLUGIN_BASE._path_is_under(
			"res://addons/gf/extensions/official/save/graph/gf_save_graph_utility.gd",
			"res://addons/gf/extensions/official/save"
		),
		"禁用扩展根目录下的文件应被导出过滤命中。"
	)
	assert_true(
		GF_EXTENSION_EXPORT_PLUGIN_BASE._path_is_under(
			"res://addons/gf/extensions/official/save",
			"res://addons/gf/extensions/official/save"
		),
		"禁用扩展根目录本身也应被导出过滤命中。"
	)
	assert_false(
		GF_EXTENSION_EXPORT_PLUGIN_BASE._path_is_under(
			"res://addons/gf/extensions/official/save_extra/gf_extension.json",
			"res://addons/gf/extensions/official/save"
		),
		"前缀相似但不在根目录内的路径不应被误过滤。"
	)


func test_extension_usage_audit_finds_project_reference() -> void:
	var directory := "user://gf_extension_usage_audit"
	var path := directory.path_join("uses_save.gd")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string('const SaveGraph = preload("res://addons/gf/extensions/official/save/graph/gf_save_graph_utility.gd")')
	file.close()

	var references: Array = GF_EXTENSION_USAGE_AUDIT_BASE.find_references_to_root(
		"res://addons/gf/extensions/official/save",
		{
			"scan_roots": [directory],
			"ignored_roots": [],
		}
	)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))

	assert_eq(references.size(), 1, "直接 preload 禁用扩展目录下的脚本应被审计发现。")
	assert_eq(String(references[0].get("path", "")), path, "审计结果应包含引用文件路径。")


func test_extension_usage_audit_does_not_match_similar_prefix() -> void:
	var directory := "user://gf_extension_usage_audit"
	var path := directory.path_join("uses_save_extra.gd")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string('const Other = preload("res://addons/gf/extensions/official/save_extra/example.gd")')
	file.close()

	var references: Array = GF_EXTENSION_USAGE_AUDIT_BASE.find_references_to_root(
		"res://addons/gf/extensions/official/save",
		{
			"scan_roots": [directory],
			"ignored_roots": [],
		}
	)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))

	assert_true(references.is_empty(), "扩展根目录前缀相似但不在目录内时不应误报。")


func test_extension_usage_audit_finds_class_name_reference() -> void:
	var directory := "user://gf_extension_usage_audit"
	var path := directory.path_join("uses_save_class.gd")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("var save_graph: GFSaveGraphUtility = null")
	file.close()

	var references: Array = GF_EXTENSION_USAGE_AUDIT_BASE.find_references_to_root(
		"res://addons/gf/extensions/official/save",
		{
			"scan_roots": [directory],
			"ignored_roots": [],
		}
	)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))

	assert_eq(references.size(), 1, "直接使用禁用扩展 class_name 时应被审计发现。")
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


func _get_official_extension_root(path: String) -> String:
	var marker := OFFICIAL_EXTENSION_ROOT + "/"
	if not path.begins_with(marker):
		return ""

	var slash_index := path.find("/", marker.length())
	if slash_index == -1:
		return ""
	return path.substr(0, slash_index)


func _extract_official_extension_roots(source: String) -> Array[String]:
	var roots: Array[String] = []
	var marker := OFFICIAL_EXTENSION_ROOT + "/"
	var search_from := 0
	while search_from < source.length():
		var start_index := source.find(marker, search_from)
		if start_index == -1:
			break

		var slash_index := source.find("/", start_index + marker.length())
		if slash_index == -1:
			break

		var root := source.substr(start_index, slash_index - start_index)
		if not roots.has(root):
			roots.append(root)
		search_from = slash_index + 1
	return roots


func _collect_official_class_roots() -> Dictionary:
	var files: Array[String] = []
	_collect_gd_files(OFFICIAL_EXTENSION_ROOT, files)

	var result: Dictionary = {}
	var regex := RegEx.new()
	regex.compile("^\\s*class_name\\s+([A-Za-z_]\\w*)")
	for path: String in files:
		var extension_root := _get_official_extension_root(path)
		for line: String in _read_text(path).split("\n"):
			var match_result := regex.search(line)
			if match_result == null:
				continue

			result[match_result.get_string(1)] = extension_root
	return result


func _official_root_can_reference(extension_root: String, referenced_root: String) -> bool:
	return referenced_root.is_empty() or referenced_root == extension_root


func _source_contains_identifier(source: String, identifier: String) -> bool:
	var regex := RegEx.new()
	var error := regex.compile("(^|[^A-Za-z0-9_])%s([^A-Za-z0-9_]|$)" % identifier)
	if error != OK:
		return source.contains(identifier)
	return regex.search(source) != null


func _set_project_setting(setting_name: String, value: Variant) -> Dictionary:
	var restore := {
		"had_setting": ProjectSettings.has_setting(setting_name),
		"value": ProjectSettings.get_setting(setting_name, null),
	}
	ProjectSettings.set_setting(setting_name, value)
	return restore


func _restore_project_setting(setting_name: String, restore: Dictionary) -> void:
	if bool(restore.get("had_setting", false)):
		ProjectSettings.set_setting(setting_name, restore.get("value"))
	else:
		ProjectSettings.clear(setting_name)


func _read_framework_version() -> String:
	var config := ConfigFile.new()
	var error := config.load("res://addons/gf/plugin.cfg")
	if error != OK:
		return ""
	return String(config.get_value("plugin", "version", ""))


func _read_json_dictionary(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}


func _is_semver(version: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^\\d+\\.\\d+\\.\\d+$")
	return regex.search(version) != null
