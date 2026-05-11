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

## 默认自动执行启用包 Installer。
const AUTO_INSTALL_ENABLED_INSTALLERS_DEFAULT: bool = true

## 默认导出时排除禁用包。
const EXPORT_EXCLUDE_DISABLED_DEFAULT: bool = true


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


## 获取默认启用的包 ID。
## @return 默认启用包 ID 列表。
static func get_default_enabled_package_ids() -> Array[String]:
	var ids: Array[String] = []
	for manifest: GFPackageManifest in GFPackageCatalogBase.load_all_manifests(true):
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


## 获取所有 manifest。
## @param include_community: 是否包含社区包。
## @return manifest 列表。
static func get_all_manifests(include_community: bool = true) -> Array[GFPackageManifest]:
	return GFPackageCatalogBase.load_all_manifests(include_community)


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

	var paths: Array[String] = []
	for manifest: GFPackageManifest in get_enabled_manifests(include_community):
		for installer_path: String in manifest.installer_paths:
			if not paths.has(installer_path):
				paths.append(installer_path)
	return paths


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
	for package_id: String in package_ids:
		_resolve_package_dependency(package_id, manifest_by_id, resolved)

	var ordered: Array[String] = []
	for manifest: GFPackageManifest in source_manifests:
		if resolved.has(manifest.id):
			ordered.append(manifest.id)
	for package_id: String in package_ids:
		if resolved.has(package_id) and not ordered.has(package_id):
			ordered.append(package_id)
	return ordered


## 获取启用状态诊断。
## @return 诊断字典。
static func get_package_selection_report() -> Dictionary:
	var manifests := get_all_manifests(true)
	var manifest_by_id := _build_manifest_map(manifests)
	var configured_ids := get_enabled_package_ids()
	var resolved_ids := resolve_package_dependencies(configured_ids, manifests)
	var missing_dependencies: Array[Dictionary] = []

	for manifest: GFPackageManifest in manifests:
		if not resolved_ids.has(manifest.id):
			continue
		for dependency_id: String in manifest.dependencies:
			if dependency_id == "gf.kernel" or dependency_id == "gf.standard":
				continue
			if not manifest_by_id.has(dependency_id):
				missing_dependencies.append({
					"package_id": manifest.id,
					"dependency_id": dependency_id,
				})

	return {
		"configured_ids": configured_ids,
		"resolved_ids": resolved_ids,
		"missing_dependencies": missing_dependencies,
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
		result[manifest.id] = manifest
	return result


static func _resolve_package_dependency(package_id: String, manifest_by_id: Dictionary, resolved: Dictionary) -> void:
	if package_id.is_empty() or resolved.has(package_id):
		return
	if not manifest_by_id.has(package_id):
		resolved[package_id] = true
		return

	var manifest := manifest_by_id[package_id] as GFPackageManifest
	if manifest == null:
		return

	for dependency_id: String in manifest.dependencies:
		if manifest_by_id.has(dependency_id):
			_resolve_package_dependency(dependency_id, manifest_by_id, resolved)
	resolved[package_id] = true
