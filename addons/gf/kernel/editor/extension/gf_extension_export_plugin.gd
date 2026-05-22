@tool

# GF 扩展导出过滤插件。
#
# 导出时可跳过禁用扩展目录，让未启用的 GF 扩展不进入最终导出产物。
extends EditorExportPlugin


# --- 常量 ---

## 扩展启用设置脚本。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
const GFExtensionSettingsBase = preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")

## 扩展引用审计脚本。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
const GFExtensionUsageAuditBase = preload("res://addons/gf/kernel/extension/gf_extension_usage_audit.gd")


# --- 私有变量 ---

var _disabled_extension_roots: Array[String] = []
var _disabled_manifests: Array[GFExtensionManifest] = []


# --- Godot 生命周期方法 ---

func _export_begin(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	_refresh_disabled_extension_roots()
	_warn_disabled_extension_references()


func _export_file(path: String, _type: String, _features: PackedStringArray) -> void:
	if _disabled_extension_roots.is_empty():
		return
	for root_path: String in _disabled_extension_roots:
		if _path_is_under(path, root_path):
			skip()
			return


func _export_end() -> void:
	_disabled_extension_roots.clear()
	_disabled_manifests.clear()


# --- 私有/辅助方法 ---

func _refresh_disabled_extension_roots() -> void:
	_disabled_extension_roots.clear()
	_disabled_manifests.clear()
	if not GFExtensionSettingsBase.should_export_exclude_disabled_extensions():
		return

	for manifest: GFExtensionManifest in GFExtensionSettingsBase.get_disabled_manifests():
		if manifest.root_path.is_empty():
			continue
		_disabled_manifests.append(manifest)
		_disabled_extension_roots.append(manifest.root_path.trim_suffix("/"))


static func _path_is_under(path: String, root_path: String) -> bool:
	var normalized_root := root_path.trim_suffix("/")
	return path == normalized_root or path.begins_with(normalized_root + "/")


func _warn_disabled_extension_references() -> void:
	if _disabled_manifests.is_empty():
		return

	var report := GFExtensionUsageAuditBase.audit_disabled_extensions(_disabled_manifests, {
		"max_references_per_extension": 8,
	})
	if bool(report.get("ok", true)):
		return

	var formatted_report := _format_reference_report(report)
	if GFExtensionSettingsBase.should_fail_export_on_disabled_extension_references():
		push_error("[GFExtensionExportPlugin] 检测到禁用扩展仍被项目文件引用，当前导出策略要求报告为错误：\n%s" % formatted_report)
		return

	push_warning("[GFExtensionExportPlugin] 检测到禁用扩展仍被项目文件引用，导出排除后可能缺文件：\n%s" % formatted_report)


func _format_reference_report(report: Dictionary) -> String:
	var lines := PackedStringArray()
	var extensions := report.get("extensions", {}) as Dictionary
	for extension_id: String in extensions.keys():
		var extension_report := extensions[extension_id] as Dictionary
		if extension_report == null:
			continue

		lines.append("- %s (%s)" % [
			String(extension_report.get("display_name", extension_id)),
			extension_id,
		])
		var references := extension_report.get("references", []) as Array
		for reference: Dictionary in references:
			lines.append("  %s:%d" % [
				String(reference.get("path", "")),
				int(reference.get("line", 0)),
			])
	return "\n".join(lines)
