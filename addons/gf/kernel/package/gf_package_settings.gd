## GFPackageSettings: GF 包启用状态与 ProjectSettings 桥接。
##
## 负责读取启用包 ID、解析包依赖、收集启用包 Installer，以及提供导出排除开关。
class_name GFPackageSettings
extends RefCounted


# --- 常量 ---

const GFPackageCatalogBase = preload("res://addons/gf/kernel/package/gf_package_catalog.gd")

## 项目设置：启用的 GF 包 ID 列表。
const ENABLED_PACKAGES_SETTING: String = "gf/packages/enabled"

## 项目设置：是否自动执行启用包 manifest 中声明的 installer_paths。
const AUTO_INSTALL_ENABLED_INSTALLERS_SETTING: String = "gf/packages/auto_install_enabled_installers"

## 项目设置：导出时是否跳过禁用包目录。
const EXPORT_EXCLUDE_DISABLED_SETTING: String = "gf/packages/export_exclude_disabled"

## 项目设置：导出审计发现项目仍引用禁用包时是否报告为错误。
const EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING: String = "gf/packages/export_fail_on_disabled_references"

## 默认自动执行启用包 Installer。
const AUTO_INSTALL_ENABLED_INSTALLERS_DEFAULT: bool = true

## 默认导出时排除禁用包。
const EXPORT_EXCLUDE_DISABLED_DEFAULT: bool = true

## 默认仅警告禁用包引用，避免旧项目升级后导出被直接阻断。
const EXPORT_FAIL_ON_DISABLED_REFERENCES_DEFAULT: bool = false

## 内置依赖 ID。这些不是可启停包 manifest，但允许被包声明为基础依赖。
const BUILT_IN_PACKAGE_IDS: Array[String] = [
	"gf.kernel",
	"gf.standard",
]


# --- 私有静态变量 ---

static var _manifest_cache: Dictionary = {}


# --- 公共方法 ---

## 确保包相关 ProjectSettings 存在。
## @return 写入了默认值时返回 true。
static func ensure_defaults() -> bool:
	var should_save := false
	if _ensure_default(ENABLED_PACKAGES_SETTING, get_default_enabled_package_ids()):
		should_save = true
	if _ensure_default(AUTO_INSTALL_ENABLED_INSTALLERS_SETTING, AUTO_INSTALL_ENABLED_INSTALLERS_DEFAULT):
		should_save = true
	if _ensure_default(EXPORT_EXCLUDE_DISABLED_SETTING, EXPORT_EXCLUDE_DISABLED_DEFAULT):
		should_save = true
	if _ensure_default(
		EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING,
		EXPORT_FAIL_ON_DISABLED_REFERENCES_DEFAULT
	):
		should_save = true
	return should_save


## 注册包相关 ProjectSettings 显示信息。
static func register_property_info() -> void:
	ProjectSettings.add_property_info({
		"name": ENABLED_PACKAGES_SETTING,
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "%d:" % TYPE_STRING,
	})
	ProjectSettings.set_as_basic(ENABLED_PACKAGES_SETTING, true)
	ProjectSettings.add_property_info({
		"name": AUTO_INSTALL_ENABLED_INSTALLERS_SETTING,
		"type": TYPE_BOOL,
	})
	ProjectSettings.set_as_basic(AUTO_INSTALL_ENABLED_INSTALLERS_SETTING, true)
	ProjectSettings.add_property_info({
		"name": EXPORT_EXCLUDE_DISABLED_SETTING,
		"type": TYPE_BOOL,
	})
	ProjectSettings.set_as_basic(EXPORT_EXCLUDE_DISABLED_SETTING, true)
	ProjectSettings.add_property_info({
		"name": EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING,
		"type": TYPE_BOOL,
	})
	ProjectSettings.set_as_basic(EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING, true)


## 获取默认启用的包 ID。
## @return 默认启用包 ID 列表。
static func get_default_enabled_package_ids() -> Array[String]:
	var ids: Array[String] = []
	for manifest: GFPackageManifest in get_all_manifests(true):
		if manifest.enabled_by_default:
			ids.append(manifest.id)
	return _sorted_unique(ids)


## 获取用户配置的启用包 ID。
## @return 启用包 ID 列表。
static func get_enabled_package_ids() -> Array[String]:
	var raw_value: Variant = ProjectSettings.get_setting(
		ENABLED_PACKAGES_SETTING,
		get_default_enabled_package_ids()
	)
	return _sorted_unique(_to_string_array(raw_value))


## 保存启用包 ID，可选自动补齐依赖。
## @param package_ids: 要启用的包 ID 列表。
## @param include_dependencies: 是否自动包含依赖包。
static func set_enabled_package_ids(package_ids: Array[String], include_dependencies: bool = true) -> void:
	var ids := _sorted_unique(package_ids)
	if include_dependencies:
		ids = resolve_package_dependencies(ids)
	ProjectSettings.set_setting(ENABLED_PACKAGES_SETTING, ids)


## 判断是否自动运行启用包 Installer。
## @return 自动运行时返回 true。
static func should_auto_install_enabled_installers() -> bool:
	return bool(ProjectSettings.get_setting(
		AUTO_INSTALL_ENABLED_INSTALLERS_SETTING,
		AUTO_INSTALL_ENABLED_INSTALLERS_DEFAULT
	))


## 设置是否自动运行启用包 Installer。
## @param enabled: 是否自动运行。
static func set_auto_install_enabled_installers(enabled: bool) -> void:
	ProjectSettings.set_setting(AUTO_INSTALL_ENABLED_INSTALLERS_SETTING, enabled)


## 判断导出时是否排除禁用包目录。
## @return 排除禁用包时返回 true。
static func should_export_exclude_disabled_packages() -> bool:
	return bool(ProjectSettings.get_setting(
		EXPORT_EXCLUDE_DISABLED_SETTING,
		EXPORT_EXCLUDE_DISABLED_DEFAULT
	))


## 设置导出时是否排除禁用包目录。
## @param enabled: 是否排除禁用包。
static func set_export_exclude_disabled_packages(enabled: bool) -> void:
	ProjectSettings.set_setting(EXPORT_EXCLUDE_DISABLED_SETTING, enabled)


## 判断导出审计发现禁用包引用时是否报告为错误。
## @return 报告为错误时返回 true；默认仅警告。
static func should_fail_export_on_disabled_package_references() -> bool:
	return bool(ProjectSettings.get_setting(
		EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING,
		EXPORT_FAIL_ON_DISABLED_REFERENCES_DEFAULT
	))


## 设置导出审计发现禁用包引用时是否报告为错误。
## @param enabled: 是否报告为错误。
static func set_fail_export_on_disabled_package_references(enabled: bool) -> void:
	ProjectSettings.set_setting(EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING, enabled)


## 获取所有 manifest。
## @param include_community: 是否包含社区包。
## @return manifest 列表。
static func get_all_manifests(include_community: bool = true) -> Array[GFPackageManifest]:
	var cache_key := "all" if include_community else "official"
	if not _manifest_cache.has(cache_key):
		_manifest_cache[cache_key] = GFPackageCatalogBase.load_all_manifests(include_community)
	return (_manifest_cache[cache_key] as Array[GFPackageManifest]).duplicate()


## 清空 manifest 发现缓存。编辑器或工具在包目录发生变化后可主动调用。
static func clear_manifest_cache() -> void:
	_manifest_cache.clear()


## 按 ID 获取 manifest。
## @param package_id: 包 ID。
## @param include_community: 是否包含社区包。
## @return 找到时返回 manifest，否则返回 null。
static func get_manifest_by_id(package_id: String, include_community: bool = true) -> GFPackageManifest:
	var normalized_id := package_id.strip_edges()
	if normalized_id.is_empty():
		return null

	for manifest: GFPackageManifest in get_all_manifests(include_community):
		if manifest.id == normalized_id:
			return manifest
	return null


## 判断包 manifest 是否存在。
## @param package_id: 包 ID。
## @param include_community: 是否包含社区包。
## @return 存在 manifest 时返回 true。
static func has_package(package_id: String, include_community: bool = true) -> bool:
	return get_manifest_by_id(package_id, include_community) != null


## 获取包内资源路径。
## @param package_id: 包 ID。
## @param relative_path: 相对包根目录的资源路径；传入 `res://` 或 `user://` 时会原样返回。
## @param include_community: 是否包含社区包。
## @return 包资源路径；包不存在时返回空字符串。
static func get_package_resource_path(
	package_id: String,
	relative_path: String = "",
	include_community: bool = true
) -> String:
	var manifest := get_manifest_by_id(package_id, include_community)
	if manifest == null or manifest.root_path.is_empty():
		return ""

	var normalized_path := relative_path.strip_edges()
	if normalized_path.is_empty():
		return manifest.root_path
	if normalized_path.begins_with("res://") or normalized_path.begins_with("user://"):
		return normalized_path
	return manifest.root_path.path_join(normalized_path.trim_prefix("/"))


## 判断包当前是否启用。
## @param package_id: 包 ID。
## @param include_dependencies: 是否把依赖补齐后的启用结果纳入判断。
## @param include_community: 是否包含社区包。
## @return 包存在且启用时返回 true。
static func is_package_enabled(
	package_id: String,
	include_dependencies: bool = true,
	include_community: bool = true
) -> bool:
	var normalized_id := package_id.strip_edges()
	if normalized_id.is_empty():
		return false

	var manifests := get_all_manifests(include_community)
	if not _build_manifest_map(manifests).has(normalized_id):
		return false

	var enabled_ids := get_enabled_package_ids()
	if include_dependencies:
		enabled_ids = resolve_package_dependencies(enabled_ids, manifests)
	return enabled_ids.has(normalized_id)


## 加载启用包内的脚本资源。
## @param package_id: 包 ID。
## @param relative_path: 相对包根目录的脚本路径；传入 `res://` 或 `user://` 时会原样解析。
## @param include_dependencies: 是否把依赖补齐后的启用结果纳入判断。
## @param include_community: 是否包含社区包。
## @return 包存在、已启用且脚本可加载时返回 Script，否则返回 null。
static func load_enabled_package_script(
	package_id: String,
	relative_path: String,
	include_dependencies: bool = true,
	include_community: bool = true
) -> Script:
	if not is_package_enabled(package_id, include_dependencies, include_community):
		return null

	var script_path := get_package_resource_path(package_id, relative_path, include_community)
	if script_path.is_empty() or not ResourceLoader.exists(script_path):
		return null
	return load(script_path) as Script


## 获取启用包的 manifest。
## @param include_community: 是否包含社区包。
## @return 启用 manifest 列表。
static func get_enabled_manifests(include_community: bool = true) -> Array[GFPackageManifest]:
	var manifests := get_all_manifests(include_community)
	var enabled_ids := resolve_package_dependencies(get_enabled_package_ids(), manifests)
	var result: Array[GFPackageManifest] = []
	for manifest: GFPackageManifest in manifests:
		if enabled_ids.has(manifest.id):
			result.append(manifest)
	return result


## 获取禁用包的 manifest。
## @param include_community: 是否包含社区包。
## @return 禁用 manifest 列表。
static func get_disabled_manifests(include_community: bool = true) -> Array[GFPackageManifest]:
	var manifests := get_all_manifests(include_community)
	var enabled_ids := resolve_package_dependencies(get_enabled_package_ids(), manifests)
	var result: Array[GFPackageManifest] = []
	for manifest: GFPackageManifest in manifests:
		if not enabled_ids.has(manifest.id):
			result.append(manifest)
	return result


## 获取启用包声明的 Installer 路径。
## @param include_community: 是否包含社区包。
## @return Installer 路径列表。
static func get_enabled_installer_paths(include_community: bool = true) -> Array[String]:
	if not should_auto_install_enabled_installers():
		return []

	return _collect_enabled_manifest_paths("installer_paths", include_community)


## 获取启用包声明的编辑器菜单动作路径。
## @param include_community: 是否包含社区包。
## @return 编辑器菜单动作脚本路径列表。
static func get_enabled_editor_action_paths(include_community: bool = true) -> Array[String]:
	return _collect_enabled_manifest_paths("editor_action_paths", include_community)


## 获取启用包声明的编辑器底部面板路径。
## @param include_community: 是否包含社区包。
## @return 编辑器底部面板脚本路径列表。
static func get_enabled_editor_dock_paths(include_community: bool = true) -> Array[String]:
	return _collect_enabled_manifest_paths("editor_dock_paths", include_community)


## 获取启用包声明的 Inspector 扩展路径。
## @param include_community: 是否包含社区包。
## @return EditorInspectorPlugin 脚本路径列表。
static func get_enabled_editor_inspector_paths(include_community: bool = true) -> Array[String]:
	return _collect_enabled_manifest_paths("editor_inspector_paths", include_community)


## 获取启用包声明的导出插件路径。
## @param include_community: 是否包含社区包。
## @return EditorExportPlugin 脚本路径列表。
static func get_enabled_export_plugin_paths(include_community: bool = true) -> Array[String]:
	return _collect_enabled_manifest_paths("export_plugin_paths", include_community)


## 获取启用包声明的访问器生成扩展路径。
## @param include_community: 是否包含社区包。
## @return GFAccessGenerator 扩展脚本路径列表。
static func get_enabled_access_generator_extension_paths(include_community: bool = true) -> Array[String]:
	return _collect_enabled_manifest_paths("access_generator_extension_paths", include_community)


## 根据 manifest 依赖关系补齐启用包。
## @param package_ids: 原始启用包 ID。
## @param manifests: 可选 manifest 列表。
## @return 补齐依赖后的包 ID。
static func resolve_package_dependencies(
	package_ids: Array[String],
	manifests: Array[GFPackageManifest] = []
) -> Array[String]:
	var source_manifests := manifests
	if source_manifests.is_empty():
		source_manifests = get_all_manifests(true)

	var manifest_by_id := _build_manifest_map(source_manifests)
	var resolved: Dictionary = {}
	var visiting: Dictionary = {}
	var cycles: Array[PackedStringArray] = []
	for package_id: String in package_ids:
		_resolve_package_dependency(package_id, manifest_by_id, resolved, visiting, [], cycles)

	var ordered: Array[String] = []
	for manifest: GFPackageManifest in source_manifests:
		if resolved.has(manifest.id):
			ordered.append(manifest.id)
	for package_id: String in package_ids:
		if resolved.has(package_id) and not ordered.has(package_id):
			ordered.append(package_id)
	return ordered


## 获取 manifest 依赖图诊断。
## @param manifests: 可选 manifest 列表；为空时扫描所有官方与社区包。
## @return 包含重复 ID、缺失依赖和循环依赖的诊断字典。
static func get_manifest_graph_report(manifests: Array[GFPackageManifest] = []) -> Dictionary:
	var source_manifests := manifests
	if source_manifests.is_empty():
		source_manifests = get_all_manifests(true)

	var manifest_by_id: Dictionary = {}
	var seen_ids: Dictionary = {}
	var duplicate_ids := PackedStringArray()
	var invalid_manifests: Array[Dictionary] = []
	var missing_dependencies: Array[Dictionary] = []
	var dependency_cycles: Array[PackedStringArray] = []

	for manifest: GFPackageManifest in source_manifests:
		if manifest == null:
			continue

		var errors := manifest.get_validation_errors()
		if not errors.is_empty():
			invalid_manifests.append({
				"package_id": manifest.id,
				"source_path": manifest.source_path,
				"errors": errors,
			})

		if manifest.id.strip_edges().is_empty():
			continue
		if seen_ids.has(manifest.id):
			if not duplicate_ids.has(manifest.id):
				duplicate_ids.append(manifest.id)
			continue

		seen_ids[manifest.id] = true
		manifest_by_id[manifest.id] = manifest

	for manifest: GFPackageManifest in source_manifests:
		if manifest == null:
			continue
		for dependency_id: String in manifest.dependencies:
			if _is_builtin_package_id(dependency_id):
				continue
			if not manifest_by_id.has(dependency_id):
				missing_dependencies.append({
					"package_id": manifest.id,
					"dependency_id": dependency_id,
				})

	var resolved: Dictionary = {}
	var visiting: Dictionary = {}
	for package_id: String in manifest_by_id.keys():
		_resolve_package_dependency(
			package_id,
			manifest_by_id,
			resolved,
			visiting,
			[],
			dependency_cycles,
			false
		)

	var issue_count := (
		duplicate_ids.size()
		+ invalid_manifests.size()
		+ missing_dependencies.size()
		+ dependency_cycles.size()
	)
	return {
		"ok": issue_count == 0,
		"package_count": manifest_by_id.size(),
		"issue_count": issue_count,
		"duplicate_ids": duplicate_ids,
		"invalid_manifests": invalid_manifests,
		"missing_dependencies": missing_dependencies,
		"dependency_cycles": dependency_cycles,
	}


## 获取启用状态诊断。
## @return 诊断字典。
static func get_package_selection_report() -> Dictionary:
	var manifests := get_all_manifests(true)
	var configured_ids := get_enabled_package_ids()
	var resolved_ids := resolve_package_dependencies(configured_ids, manifests)
	var graph_report := get_manifest_graph_report(manifests)
	var unknown_enabled_ids := _get_unknown_enabled_ids(configured_ids, _build_manifest_map(manifests))
	var graph_ok := bool(graph_report.get("ok", true))

	return {
		"configured_ids": configured_ids,
		"resolved_ids": resolved_ids,
		"unknown_enabled_ids": unknown_enabled_ids,
		"missing_dependencies": graph_report.get("missing_dependencies", []),
		"dependency_cycles": graph_report.get("dependency_cycles", []),
		"duplicate_ids": graph_report.get("duplicate_ids", PackedStringArray()),
		"invalid_manifests": graph_report.get("invalid_manifests", []),
		"graph_ok": graph_ok,
		"ok": graph_ok and unknown_enabled_ids.is_empty(),
		"enabled_count": resolved_ids.size(),
		"package_count": manifests.size(),
	}


# --- 私有/辅助方法 ---

static func _ensure_default(setting_name: String, default_value: Variant) -> bool:
	if ProjectSettings.has_setting(setting_name):
		return false
	ProjectSettings.set_setting(setting_name, default_value)
	ProjectSettings.set_initial_value(setting_name, default_value)
	return true


static func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is PackedStringArray:
		for item: String in value:
			result.append(item)
		return result
	if value is Array:
		for item: Variant in value:
			if typeof(item) == TYPE_STRING or item is StringName:
				result.append(String(item))
	return result


static func _sorted_unique(values: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for value: String in values:
		var id := value.strip_edges()
		if id.is_empty() or result.has(id):
			continue
		result.append(id)
	result.sort()
	return result


static func _build_manifest_map(manifests: Array[GFPackageManifest]) -> Dictionary:
	var result: Dictionary = {}
	for manifest: GFPackageManifest in manifests:
		if manifest == null or manifest.id.strip_edges().is_empty() or result.has(manifest.id):
			continue
		result[manifest.id] = manifest
	return result


static func _collect_enabled_manifest_paths(property_name: String, include_community: bool = true) -> Array[String]:
	var paths: Array[String] = []
	for manifest: GFPackageManifest in get_enabled_manifests(include_community):
		var raw_paths := manifest.get(property_name) as Array
		if raw_paths == null:
			continue
		for path_variant: Variant in raw_paths:
			var path := String(path_variant).strip_edges()
			if path.is_empty() or paths.has(path):
				continue
			paths.append(path)
	return paths


static func _get_unknown_enabled_ids(package_ids: Array[String], manifest_by_id: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for package_id: String in package_ids:
		if _is_builtin_package_id(package_id):
			continue
		if not manifest_by_id.has(package_id) and not result.has(package_id):
			result.append(package_id)
	result.sort()
	return result


static func _resolve_package_dependency(
	package_id: String,
	manifest_by_id: Dictionary,
	resolved: Dictionary,
	visiting: Dictionary,
	stack: Array[String],
	cycles: Array[PackedStringArray],
	emit_warning: bool = true
) -> void:
	if package_id.is_empty() or resolved.has(package_id):
		return
	if visiting.has(package_id):
		_append_dependency_cycle(cycles, stack, package_id)
		if emit_warning:
			push_warning("[GFPackageSettings] 检测到包依赖循环：%s" % " -> ".join(cycles[cycles.size() - 1]))
		return
	if not manifest_by_id.has(package_id):
		resolved[package_id] = true
		return

	var manifest := manifest_by_id[package_id] as GFPackageManifest
	if manifest == null:
		return

	visiting[package_id] = true
	var next_stack := stack.duplicate()
	next_stack.append(package_id)
	for dependency_id: String in manifest.dependencies:
		if manifest_by_id.has(dependency_id):
			_resolve_package_dependency(
				dependency_id,
				manifest_by_id,
				resolved,
				visiting,
				next_stack,
				cycles,
				emit_warning
			)
	visiting.erase(package_id)
	resolved[package_id] = true


static func _append_dependency_cycle(
	cycles: Array[PackedStringArray],
	stack: Array[String],
	package_id: String
) -> void:
	var start_index := stack.find(package_id)
	var cycle := PackedStringArray()
	if start_index == -1:
		cycle.append(package_id)
	else:
		for index: int in range(start_index, stack.size()):
			cycle.append(stack[index])
	cycle.append(package_id)

	var cycle_key := _make_cycle_key(cycle)
	for existing_cycle: PackedStringArray in cycles:
		if _make_cycle_key(existing_cycle) == cycle_key:
			return
	cycles.append(cycle)


static func _make_cycle_key(cycle: PackedStringArray) -> String:
	return " -> ".join(cycle)


static func _is_builtin_package_id(package_id: String) -> bool:
	return BUILT_IN_PACKAGE_IDS.has(package_id)
