@tool

## GFAudioBankTools: 音频集合扫描、导入和校验辅助。
##
## 面向编辑器工具和构建脚本复用；它只生成 `GFAudioBank` / `GFAudioClip`
## 配置，不接管运行时播放策略。
class_name GFAudioBankTools
extends RefCounted


# --- 枚举 ---

## 从音频路径生成片段 ID 的方式。
enum ClipIdMode {
	## 使用文件名，不包含扩展名。
	BASENAME,
	## 使用相对 base_path 的路径，不包含扩展名。
	RELATIVE_PATH,
	## 使用完整资源路径，不包含扩展名。
	FULL_PATH,
}


# --- 常量 ---

const AUDIO_EXTENSIONS: PackedStringArray = ["wav", "ogg", "mp3", "opus"]
const DEFAULT_EXCLUDED_PATHS: PackedStringArray = ["res://addons"]
const GFAudioBankBase = preload("res://addons/gf/standard/utilities/audio/gf_audio_bank.gd")
const GFAudioClipBase = preload("res://addons/gf/standard/utilities/audio/gf_audio_clip.gd")
const GFValidationReportBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")


# --- 公共方法 ---

## 判断路径是否指向 GF 默认支持的音频扩展名。
## @param path: 资源路径或文件名。
## @param extensions: 可选扩展名白名单，不包含点号。
## @return 是音频路径时返回 true。
static func is_audio_path(path: String, extensions: PackedStringArray = AUDIO_EXTENSIONS) -> bool:
	var extension := path.get_extension().to_lower()
	return not extension.is_empty() and extensions.has(extension)


## 递归扫描音频路径。
## @param root_path: 扫描起点，通常是 res:// 下的目录。
## @param options: 可选项，支持 recursive、include_addons、excluded_paths、extensions。
## @return 按字典序排序的音频路径。
static func scan_audio_paths(root_path: String = "res://", options: Dictionary = {}) -> PackedStringArray:
	var result := PackedStringArray()
	var normalized_root := _normalize_dir_path(root_path)
	var extensions := _get_extensions(options)
	var recursive := bool(options.get("recursive", true))
	var excluded_paths := _get_excluded_paths(options)
	_scan_audio_paths_recursive(normalized_root, recursive, excluded_paths, extensions, result)
	result.sort()
	return result


## 从路径列表创建新的音频集合。
## @param paths: 音频资源路径列表。
## @param options: 可选项，支持 id_mode、base_path、path_separator、strip_extension、bus_name、volume_db、pitch_scale。
## @return 新建的音频集合。
static func create_bank_from_paths(paths: PackedStringArray, options: Dictionary = {}) -> GFAudioBank:
	var bank := GFAudioBankBase.new() as GFAudioBank
	add_paths_to_bank(bank, paths, options.merged({ "overwrite": true }))
	return bank


## 将路径列表加入音频集合。
## @param bank: 要写入的音频集合。
## @param paths: 音频资源路径列表。
## @param options: 可选项，支持 id_mode、base_path、path_separator、strip_extension、overwrite、bus_name、volume_db、pitch_scale。
## @return 导入报告。
static func add_paths_to_bank(
	bank: GFAudioBank,
	paths: PackedStringArray,
	options: Dictionary = {}
) -> GFValidationReport:
	var report := GFValidationReportBase.new("GFAudioBankTools.add_paths_to_bank") as GFValidationReport
	if bank == null:
		report.add_error(&"missing_audio_bank", "Audio bank is null.")
		return report

	var overwrite := bool(options.get("overwrite", false))
	var added_count := 0
	var skipped_count := 0
	for path: String in paths:
		if not is_audio_path(path, _get_extensions(options)):
			report.add_warning(&"invalid_audio_path", "Path is not a supported audio file.", path, path)
			skipped_count += 1
			continue

		var clip_id := make_clip_id(path, options)
		if clip_id == &"":
			report.add_warning(&"empty_audio_clip_id", "Generated clip id is empty.", path, path)
			skipped_count += 1
			continue

		if bank.has_clip(clip_id) and not overwrite:
			report.add_warning(
				&"audio_clip_id_exists",
				"Audio clip id already exists and overwrite is disabled.",
				clip_id,
				path
			)
			skipped_count += 1
			continue

		var clip := _make_clip(path, options)
		bank.set_clip(clip_id, clip)
		added_count += 1

	report.metadata["added_count"] = added_count
	report.metadata["skipped_count"] = skipped_count
	return report


## 校验音频集合是否适合交给 GFAudioUtility 播放。
## @param bank: 要校验的音频集合。
## @param options: 可选项，支持 check_resource_exists、check_bus_exists、extensions。
## @return 校验报告。
static func validate_bank_playback(bank: GFAudioBank, options: Dictionary = {}) -> GFValidationReport:
	var report := GFValidationReportBase.new("GFAudioBankPlayback") as GFValidationReport
	if bank == null:
		report.add_error(&"missing_audio_bank", "Audio bank is null.")
		return report

	report.merge(bank.validate_bank(bool(options.get("check_resource_exists", false))), true)
	var check_bus_exists := bool(options.get("check_bus_exists", true))
	var extensions := _get_extensions(options)
	var clip_count := 0
	for clip_id_text: String in bank.get_clip_ids():
		var clip_id := StringName(clip_id_text)
		var clips := bank.get_clips(clip_id)
		clip_count += clips.size()
		for index: int in range(clips.size()):
			_validate_clip_playback(report, clip_id, clips[index], index, extensions, check_bus_exists)

	report.metadata["clip_count"] = clip_count
	return report


## 按选项从路径生成稳定片段 ID。
## @param path: 音频资源路径。
## @param options: 可选项，支持 id_mode、base_path、path_separator、strip_extension。
## @return 片段 ID。
static func make_clip_id(path: String, options: Dictionary = {}) -> StringName:
	var mode := _resolve_id_mode(options.get("id_mode", ClipIdMode.BASENAME))
	var id_text := path.replace("\\", "/")
	match mode:
		ClipIdMode.BASENAME:
			id_text = id_text.get_file()
		ClipIdMode.RELATIVE_PATH:
			id_text = _make_relative_path(id_text, String(options.get("base_path", "res://")))
		ClipIdMode.FULL_PATH:
			pass

	if bool(options.get("strip_extension", true)):
		id_text = id_text.get_basename()
	id_text = id_text.replace("/", String(options.get("path_separator", "/"))).strip_edges()
	return StringName(id_text)


# --- 私有/辅助方法 ---

static func _make_clip(path: String, options: Dictionary) -> GFAudioClip:
	var clip := GFAudioClipBase.new() as GFAudioClip
	clip.path = path
	clip.bus_name = String(options.get("bus_name", ""))
	clip.volume_db = float(options.get("volume_db", 0.0))
	clip.pitch_scale = float(options.get("pitch_scale", 1.0))
	return clip


static func _validate_clip_playback(
	report: GFValidationReport,
	clip_id: StringName,
	clip: GFAudioClip,
	index: int,
	extensions: PackedStringArray,
	check_bus_exists: bool
) -> void:
	if clip == null:
		return

	var metadata := {
		"clip_id": clip_id,
		"index": index,
	}
	if not clip.path.is_empty() and not is_audio_path(clip.path, extensions):
		report.add_warning(
			&"unsupported_audio_extension",
			"Audio clip path uses an unsupported extension.",
			clip_id,
			clip.path,
			metadata
		)
	if check_bus_exists and not clip.bus_name.is_empty() and AudioServer.get_bus_index(clip.bus_name) < 0:
		report.add_warning(
			&"missing_audio_bus",
			"Audio clip references an audio bus that does not exist.",
			clip_id,
			clip.path,
			metadata.merged({ "bus_name": clip.bus_name })
		)


static func _scan_audio_paths_recursive(
	dir_path: String,
	recursive: bool,
	excluded_paths: PackedStringArray,
	extensions: PackedStringArray,
	result: PackedStringArray
) -> void:
	if _is_excluded_path(dir_path, excluded_paths):
		return

	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		if entry.begins_with("."):
			entry = dir.get_next()
			continue

		var child_path := dir_path.path_join(entry)
		if dir.current_is_dir():
			if recursive:
				_scan_audio_paths_recursive(child_path, recursive, excluded_paths, extensions, result)
		elif is_audio_path(entry, extensions):
			result.append(child_path)
		entry = dir.get_next()
	dir.list_dir_end()


static func _get_extensions(options: Dictionary) -> PackedStringArray:
	var value: Variant = options.get("extensions", AUDIO_EXTENSIONS)
	if value is PackedStringArray:
		return value
	if value is Array:
		var result := PackedStringArray()
		for item: Variant in value:
			var text := String(item)
			if text.begins_with("."):
				text = text.substr(1)
			result.append(text.to_lower())
		return result
	return AUDIO_EXTENSIONS


static func _get_excluded_paths(options: Dictionary) -> PackedStringArray:
	if bool(options.get("include_addons", false)):
		return PackedStringArray()
	var value: Variant = options.get("excluded_paths", DEFAULT_EXCLUDED_PATHS)
	if value is PackedStringArray:
		return value
	if value is Array:
		var result := PackedStringArray()
		for item: Variant in value:
			result.append(_normalize_dir_path(String(item)))
		return result
	return DEFAULT_EXCLUDED_PATHS


static func _resolve_id_mode(value: Variant) -> ClipIdMode:
	if typeof(value) == TYPE_INT:
		return clampi(int(value), ClipIdMode.BASENAME, ClipIdMode.FULL_PATH) as ClipIdMode

	match String(value).strip_edges().to_lower():
		"relative", "relative_path":
			return ClipIdMode.RELATIVE_PATH
		"full", "full_path", "path":
			return ClipIdMode.FULL_PATH
		_:
			return ClipIdMode.BASENAME


static func _make_relative_path(path: String, base_path: String) -> String:
	var normalized_base := _normalize_dir_path(base_path)
	if path.begins_with(normalized_base):
		var relative_path := path.substr(normalized_base.length())
		if relative_path.begins_with("/"):
			relative_path = relative_path.substr(1)
		return relative_path
	return path


static func _normalize_dir_path(path: String) -> String:
	var normalized := path.replace("\\", "/").strip_edges()
	while normalized.ends_with("/") and normalized.length() > "res://".length():
		normalized = normalized.substr(0, normalized.length() - 1)
	return normalized


static func _is_excluded_path(path: String, excluded_paths: PackedStringArray) -> bool:
	var normalized_path := _normalize_dir_path(path)
	for excluded_path: String in excluded_paths:
		var normalized_excluded := _normalize_dir_path(excluded_path)
		if normalized_path == normalized_excluded or normalized_path.begins_with(normalized_excluded + "/"):
			return true
	return false
