@tool

## GF 包导出过滤插件。
##
## 导出时可跳过禁用包目录，让未启用的官方包或社区包不进入最终导出产物。
extends EditorExportPlugin


# --- 常量 ---

const GFPackageSettingsBase = preload("res://addons/gf/kernel/package/gf_package_settings.gd")
const GFPackageUsageAuditBase = preload("res://addons/gf/kernel/package/gf_package_usage_audit.gd")


# --- 私有变量 ---

var _disabled_package_roots: Array[String] = []
var _disabled_manifests: Array[GFPackageManifest] = []


# --- Godot 生命周期方法 ---

func _export_begin(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	_refresh_disabled_package_roots()
	_warn_disabled_package_references()


func _export_file(path: String, _type: String, _features: PackedStringArray) -> void:
	if _disabled_package_roots.is_empty():
		return
	for root_path: String in _disabled_package_roots:
		if _path_is_under(path, root_path):
			skip()
			return


func _export_end() -> void:
	_disabled_package_roots.clear()
	_disabled_manifests.clear()


# --- 私有/辅助方法 ---

func _refresh_disabled_package_roots() -> void:
	_disabled_package_roots.clear()
	_disabled_manifests.clear()
	if not GFPackageSettingsBase.should_export_exclude_disabled_packages():
		return

	for manifest: GFPackageManifest in GFPackageSettingsBase.get_disabled_manifests(true):
		if manifest.root_path.is_empty():
			continue
		_disabled_manifests.append(manifest)
		_disabled_package_roots.append(manifest.root_path.trim_suffix("/"))


static func _path_is_under(path: String, root_path: String) -> bool:
	var normalized_root := root_path.trim_suffix("/")
	return path == normalized_root or path.begins_with(normalized_root + "/")


func _warn_disabled_package_references() -> void:
	if _disabled_manifests.is_empty():
		return

	var report := GFPackageUsageAuditBase.audit_disabled_packages(_disabled_manifests, {
		"max_references_per_package": 8,
	})
	if bool(report.get("ok", true)):
		return

	var formatted_report := _format_reference_report(report)
	if GFPackageSettingsBase.should_fail_export_on_disabled_package_references():
		push_error("[GFPackageExportPlugin] 检测到禁用包仍被项目文件引用，当前导出策略要求报告为错误：\n%s" % formatted_report)
		return

	push_warning("[GFPackageExportPlugin] 检测到禁用包仍被项目文件引用，导出排除后可能缺文件：\n%s" % formatted_report)


func _format_reference_report(report: Dictionary) -> String:
	var lines := PackedStringArray()
	var packages := report.get("packages", {}) as Dictionary
	for package_id: String in packages.keys():
		var package_report := packages[package_id] as Dictionary
		if package_report == null:
			continue

		lines.append("- %s (%s)" % [
			String(package_report.get("display_name", package_id)),
			package_id,
		])
		var references := package_report.get("references", []) as Array
		for reference: Dictionary in references:
			lines.append("  %s:%d" % [
				String(reference.get("path", "")),
				int(reference.get("line", 0)),
			])
	return "\n".join(lines)
