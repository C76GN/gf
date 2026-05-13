## GFSupportReportUtility: 通用支持报告构建工具。
##
## 聚合用户描述、项目元数据、诊断快照、日志和可扩展分区，并提供 JSON 导出与回调提交入口。
## 它不绑定任何工单系统、上传服务或反馈 UI。
class_name GFSupportReportUtility
extends GFUtility


# --- 信号 ---

## 报告构建完成后发出。
signal report_built(report: Dictionary)

## 报告写入文件后发出。
signal report_saved(path: String, error: Error)

## 报告通过外部回调提交后发出。
signal report_submitted(result: Dictionary)


# --- 公共变量 ---

## 默认是否包含 GFDiagnosticsUtility 快照。
var include_diagnostics_by_default: bool = true

## 默认是否包含场景快照。
var include_scene_by_default: bool = true

## 默认最近日志数量。
var default_recent_log_count: int = 50

## 默认单个附件最大字节数。小于等于 0 表示不限制。
var default_max_attachment_bytes: int = 2 * 1024 * 1024

## 默认是否包含当前 Viewport 截图。
var include_screenshot_by_default: bool = false


# --- 私有变量 ---

var _section_providers: Dictionary = {}
var _reports_built_count: int = 0
var _reports_saved_count: int = 0
var _reports_submitted_count: int = 0


# --- Godot 生命周期方法 ---

func dispose() -> void:
	_section_providers.clear()
	_reports_built_count = 0
	_reports_saved_count = 0
	_reports_submitted_count = 0


# --- 公共方法 ---

## 注册自定义报告分区。
## @param section_id: 分区标识。
## @param provider: 分区回调，建议签名为 func(options: Dictionary) -> Variant。
## @param options: 分区元数据，支持 label、metadata。
## @return 注册成功返回 true。
func register_section(section_id: StringName, provider: Callable, options: Dictionary = {}) -> bool:
	if section_id == &"" or not provider.is_valid():
		return false

	_section_providers[section_id] = {
		"provider": provider,
		"label": _variant_to_string(options.get("label", str(section_id)), str(section_id)),
		"metadata": (options.get("metadata", {}) as Dictionary).duplicate(true) if options.get("metadata", {}) is Dictionary else {},
	}
	return true


## 注销自定义报告分区。
## @param section_id: 分区标识。
func unregister_section(section_id: StringName) -> void:
	_section_providers.erase(section_id)


## 检查自定义分区是否存在。
## @param section_id: 分区标识。
## @return 存在返回 true。
func has_section(section_id: StringName) -> bool:
	return _section_providers.has(section_id)


## 获取自定义分区目录。
## @return 分区元数据字典。
func get_section_catalog() -> Dictionary:
	var result: Dictionary = {}
	for section_id: StringName in _section_providers.keys():
		var entry := _section_providers[section_id] as Dictionary
		result[section_id] = {
			"label": _variant_to_string(entry.get("label", str(section_id)), str(section_id)),
			"metadata": (entry.get("metadata", {}) as Dictionary).duplicate(true),
		}
	return result


## 构建支持报告。
## @param description: 用户描述或问题摘要。
## @param options: 可选参数，支持 metadata、tags、include_diagnostics、diagnostics_options、include_scene、include_sections、section_options、attachments、max_attachment_bytes、include_screenshot、viewport、screenshot_path。
## @return 报告字典。
func build_report(description: String = "", options: Dictionary = {}) -> Dictionary:
	var report_id: String = _variant_to_string(options.get("report_id", null), _make_report_id())
	var attachments := collect_attachments(options.get("attachments", {}), options)
	var report := {
		"report_id": report_id,
		"timestamp_unix": Time.get_unix_time_from_system(),
		"description": description,
		"metadata": _get_dictionary_option(options, "metadata"),
		"tags": _get_tags(options.get("tags", PackedStringArray())),
		"build": GFBuildInfo.collect().to_dict(),
		"runtime": _collect_runtime_snapshot(),
		"scene": {},
		"diagnostics": {},
		"sections": {},
		"attachments": {},
	}

	if bool(options.get("include_scene", include_scene_by_default)):
		report["scene"] = _collect_scene_snapshot()
	if bool(options.get("include_diagnostics", include_diagnostics_by_default)):
		report["diagnostics"] = _collect_diagnostics_snapshot(options)
	if bool(options.get("include_sections", true)):
		report["sections"] = collect_sections(_get_dictionary_option(options, "section_options"))
	if bool(options.get("include_screenshot", include_screenshot_by_default)):
		var screenshot := _capture_viewport_png_buffer(options.get("viewport", null) as Viewport)
		if not screenshot.is_empty():
			_append_attachment(attachments, &"screenshot", screenshot, {
				"filename": "screenshot.png",
				"mime_type": "image/png",
				"max_attachment_bytes": int(options.get("max_attachment_bytes", default_max_attachment_bytes)),
				"save_path": _variant_to_string(options.get("screenshot_path", "")),
			})
	report["attachments"] = attachments

	_reports_built_count += 1
	report_built.emit(report)
	return report


## 采集所有自定义分区。
## @param options: 传给每个 provider 的选项。
## @return 分区结果字典。
func collect_sections(options: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {}
	for section_id: StringName in _section_providers.keys():
		var entry := _section_providers[section_id] as Dictionary
		var provider: Callable = entry.get("provider", Callable())
		var section := {
			"label": _variant_to_string(entry.get("label", str(section_id)), str(section_id)),
			"metadata": (entry.get("metadata", {}) as Dictionary).duplicate(true),
			"value": null,
			"ok": false,
			"error": "",
		}
		if provider.is_valid():
			section["value"] = provider.call(options.duplicate(true))
			section["ok"] = true
		else:
			section["error"] = "Section provider is invalid."
		result[section_id] = section
	return result


## 采集并规范化报告附件。
## @param attachments: 附件集合。Dictionary 使用键作为附件标识；Array 中的 Dictionary 可提供 id 或 attachment_id。
## @param options: 可选参数，支持 max_attachment_bytes。
## @return 附件字典。
func collect_attachments(attachments: Variant, options: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {}
	if attachments is Dictionary:
		var attachment_map := attachments as Dictionary
		for attachment_id_variant: Variant in attachment_map.keys():
			_append_attachment(result, StringName(attachment_id_variant), attachment_map[attachment_id_variant], options)
	elif attachments is Array:
		var attachment_array := attachments as Array
		for index: int in range(attachment_array.size()):
			var entry := attachment_array[index] as Dictionary
			if entry == null:
				continue
			var attachment_id := StringName(entry.get("attachment_id", entry.get("id", "attachment_%d" % index)))
			_append_attachment(result, attachment_id, entry, options)
	return result


## 向已有报告追加附件。
## @param report: 报告字典。
## @param attachment_id: 附件标识。
## @param content: 附件内容，可为 PackedByteArray、String 或带 bytes/text/path 字段的 Dictionary。
## @param options: 可选参数，支持 filename、mime_type、metadata、max_attachment_bytes、save_path。
## @return 规范化附件结果。
func add_attachment_to_report(
	report: Dictionary,
	attachment_id: StringName,
	content: Variant,
	options: Dictionary = {}
) -> Dictionary:
	if not report.has("attachments") or not (report["attachments"] is Dictionary):
		report["attachments"] = {}
	var attachments := report["attachments"] as Dictionary
	return _append_attachment(attachments, attachment_id, content, options)


## 将报告导出为 JSON 文本。
## @param report: 报告字典。
## @param indent: JSON 缩进字符串。
## @return JSON 文本。
func export_report_json(report: Dictionary, indent: String = "\t") -> String:
	return JSON.stringify(report, indent)


## 保存报告到文件。
## @param report: 报告字典。
## @param path: 目标路径。
## @return Godot 错误码。
func save_report(report: Dictionary, path: String) -> Error:
	if path.is_empty():
		report_saved.emit(path, ERR_INVALID_PARAMETER)
		return ERR_INVALID_PARAMETER

	var base_dir := path.get_base_dir()
	if not base_dir.is_empty() and base_dir != "user://":
		var dir_error := DirAccess.make_dir_recursive_absolute(base_dir)
		if dir_error != OK:
			report_saved.emit(path, dir_error)
			return dir_error

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var open_error := FileAccess.get_open_error()
		report_saved.emit(path, open_error)
		return open_error

	file.store_string(export_report_json(report))
	var error := file.get_error()
	file.close()
	if error == OK:
		_reports_saved_count += 1
	report_saved.emit(path, error)
	return error


## 构建并保存支持报告。
## @param path: 目标路径。
## @param description: 用户描述或问题摘要。
## @param options: 构建选项。
## @return Godot 错误码。
func build_and_save_report(path: String, description: String = "", options: Dictionary = {}) -> Error:
	return save_report(build_report(description, options), path)


## 通过外部回调提交报告。
## @param report: 报告字典。
## @param transport: 提交回调，签名为 func(report: Dictionary, options: Dictionary) -> Variant。
## @param options: 提交选项。
## @return 提交结果字典。
func submit_report(report: Dictionary, transport: Callable, options: Dictionary = {}) -> Dictionary:
	var result := {
		"ok": false,
		"value": null,
		"error": "",
		"metadata": {},
	}
	if not transport.is_valid():
		result["error"] = "Transport callback is invalid."
		report_submitted.emit(result)
		return result

	var raw_result: Variant = transport.call(report.duplicate(true), options.duplicate(true))
	result = _normalize_submit_result(raw_result)
	result["submitted_at_unix"] = Time.get_unix_time_from_system()
	if bool(result.get("ok", false)):
		_reports_submitted_count += 1
	report_submitted.emit(result)
	return result


## 获取调试快照。
## @return 调试信息字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"section_count": _section_providers.size(),
		"reports_built_count": _reports_built_count,
		"reports_saved_count": _reports_saved_count,
		"reports_submitted_count": _reports_submitted_count,
		"include_diagnostics_by_default": include_diagnostics_by_default,
		"include_scene_by_default": include_scene_by_default,
		"default_recent_log_count": default_recent_log_count,
		"default_max_attachment_bytes": default_max_attachment_bytes,
		"include_screenshot_by_default": include_screenshot_by_default,
	}


# --- 私有/辅助方法 ---

func _make_report_id() -> String:
	return "%d-%d" % [int(Time.get_unix_time_from_system()), Time.get_ticks_msec()]


func _collect_runtime_snapshot() -> Dictionary:
	return {
		"engine": Engine.get_version_info(),
		"locale": TranslationServer.get_locale(),
		"platform": OS.get_name(),
		"processor_count": OS.get_processor_count(),
		"static_memory": Performance.get_monitor(Performance.MEMORY_STATIC),
		"object_count": Performance.get_monitor(Performance.OBJECT_COUNT),
	}


func _collect_scene_snapshot() -> Dictionary:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.current_scene == null:
		return {
			"available": false,
		}

	var scene := tree.current_scene
	return {
		"available": true,
		"name": scene.name,
		"path": scene.scene_file_path,
		"node_count": _count_nodes(scene),
	}


func _collect_diagnostics_snapshot(options: Dictionary) -> Dictionary:
	var diagnostics := get_utility(GFDiagnosticsUtility) as GFDiagnosticsUtility
	if diagnostics != null:
		var diagnostics_options := _get_dictionary_option(options, "diagnostics_options")
		if not diagnostics_options.has("recent_log_count"):
			diagnostics_options["recent_log_count"] = default_recent_log_count
		return diagnostics.collect_snapshot(diagnostics_options)

	var log_utility := get_utility(GFLogUtility) as GFLogUtility
	if log_utility == null:
		return {
			"available": false,
		}
	return {
		"available": true,
		"logs": {
			"memory_count": log_utility.get_memory_entry_count(),
			"dropped_count": log_utility.get_dropped_memory_entry_count(),
			"recent": log_utility.get_recent_entries(default_recent_log_count),
		},
	}


func _capture_viewport_png_buffer(viewport: Viewport) -> PackedByteArray:
	var target_viewport := viewport
	if target_viewport == null:
		var tree := Engine.get_main_loop() as SceneTree
		if tree != null:
			target_viewport = tree.root
	if target_viewport == null:
		return PackedByteArray()

	var image := target_viewport.get_texture().get_image()
	if image == null:
		return PackedByteArray()
	return image.save_png_to_buffer()


func _append_attachment(
	attachments: Dictionary,
	attachment_id: StringName,
	content: Variant,
	options: Dictionary
) -> Dictionary:
	if attachment_id == &"":
		return {
			"ok": false,
			"reason": "attachment_id_is_empty",
		}

	var entry := _make_attachment_entry(attachment_id, content, options)
	attachments[attachment_id] = entry
	return entry


func _make_attachment_entry(attachment_id: StringName, content: Variant, options: Dictionary) -> Dictionary:
	var attachment_options := options.duplicate(true)
	var payload: Variant = content
	if content is Dictionary:
		var content_dictionary := content as Dictionary
		attachment_options.merge(content_dictionary, true)
		if content_dictionary.has("bytes"):
			payload = content_dictionary["bytes"]
		elif content_dictionary.has("text"):
			payload = content_dictionary["text"]
		elif content_dictionary.has("path"):
			payload = _read_attachment_path(_variant_to_string(content_dictionary.get("path", "")))

	var filename := _variant_to_string(attachment_options.get("filename", String(attachment_id)))
	var mime_type := _variant_to_string(attachment_options.get("mime_type", "application/octet-stream"))
	var metadata := (attachment_options.get("metadata", {}) as Dictionary).duplicate(true) if attachment_options.get("metadata", {}) is Dictionary else {}
	if payload is PackedByteArray:
		return _make_binary_attachment_entry(payload as PackedByteArray, filename, mime_type, metadata, attachment_options)
	if payload is String:
		var text := payload as String
		return _make_text_attachment_entry(text, filename, mime_type, metadata, attachment_options)

	return {
		"ok": false,
		"filename": filename,
		"mime_type": mime_type,
		"size_bytes": 0,
		"reason": "unsupported_attachment_content",
		"metadata": metadata,
	}


func _make_binary_attachment_entry(
	bytes: PackedByteArray,
	filename: String,
	mime_type: String,
	metadata: Dictionary,
	options: Dictionary
) -> Dictionary:
	var max_bytes := int(options.get("max_attachment_bytes", default_max_attachment_bytes))
	if max_bytes > 0 and bytes.size() > max_bytes:
		return _make_rejected_attachment_entry(filename, mime_type, bytes.size(), max_bytes, metadata)

	var entry := {
		"ok": true,
		"filename": filename,
		"mime_type": mime_type,
		"size_bytes": bytes.size(),
		"encoding": "base64",
		"data": Marshalls.raw_to_base64(bytes),
		"metadata": metadata,
	}
	_save_attachment_if_requested(entry, bytes, options)
	return entry


func _make_text_attachment_entry(
	text: String,
	filename: String,
	mime_type: String,
	metadata: Dictionary,
	options: Dictionary
) -> Dictionary:
	var bytes := text.to_utf8_buffer()
	var max_bytes := int(options.get("max_attachment_bytes", default_max_attachment_bytes))
	if max_bytes > 0 and bytes.size() > max_bytes:
		return _make_rejected_attachment_entry(filename, mime_type, bytes.size(), max_bytes, metadata)

	return {
		"ok": true,
		"filename": filename,
		"mime_type": mime_type,
		"size_bytes": bytes.size(),
		"encoding": "text",
		"data": text,
		"metadata": metadata,
	}


func _make_rejected_attachment_entry(
	filename: String,
	mime_type: String,
	size_bytes: int,
	max_bytes: int,
	metadata: Dictionary
) -> Dictionary:
	return {
		"ok": false,
		"filename": filename,
		"mime_type": mime_type,
		"size_bytes": size_bytes,
		"max_bytes": max_bytes,
		"reason": "attachment_too_large",
		"metadata": metadata,
	}


func _save_attachment_if_requested(entry: Dictionary, bytes: PackedByteArray, options: Dictionary) -> void:
	var save_path := _variant_to_string(options.get("save_path", ""))
	if save_path.is_empty():
		return

	var base_dir := save_path.get_base_dir()
	if not base_dir.is_empty() and base_dir != "user://":
		var dir_error := DirAccess.make_dir_recursive_absolute(base_dir)
		if dir_error != OK:
			entry["save_error"] = dir_error
			return

	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		entry["save_error"] = FileAccess.get_open_error()
		return

	file.store_buffer(bytes)
	var error := file.get_error()
	file.close()
	if error == OK:
		entry["saved_path"] = save_path
	else:
		entry["save_error"] = error


func _read_attachment_path(path: String) -> PackedByteArray:
	if path.is_empty() or not FileAccess.file_exists(path):
		return PackedByteArray()

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return PackedByteArray()

	var bytes := file.get_buffer(file.get_length())
	file.close()
	return bytes


func _normalize_submit_result(raw_result: Variant) -> Dictionary:
	if raw_result is Dictionary:
		var data := raw_result as Dictionary
		if data.has("ok"):
			return {
				"ok": bool(data.get("ok", false)),
				"value": data.get("value", data.get("data", null)),
				"error": _variant_to_string(data.get("error", "")),
				"metadata": (data.get("metadata", {}) as Dictionary).duplicate(true) if data.get("metadata", {}) is Dictionary else {},
			}
	return {
		"ok": true,
		"value": raw_result,
		"error": "",
		"metadata": {},
	}


func _get_dictionary_option(options: Dictionary, key: String) -> Dictionary:
	var value: Variant = options.get(key, {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


func _get_tags(value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if value is PackedStringArray:
		return (value as PackedStringArray).duplicate()
	if value is Array:
		for item: Variant in value:
			result.append(_variant_to_string(item))
	return result


func _count_nodes(root: Node) -> int:
	if root == null:
		return 0

	var count := 1
	for child: Node in root.get_children():
		count += _count_nodes(child)
	return count


func _variant_to_string(value: Variant, fallback: String = "") -> String:
	if value == null:
		return fallback
	if value is String:
		return value as String
	return str(value)
