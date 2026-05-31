## GFTimedTextImporter: 通用时间段文本解析器。
##
## 提供 SRT、WebVTT 与 LRC 的轻量解析入口，输出 `GFTimedTextTrack`。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFTimedTextImporter
extends RefCounted


# --- 公共方法 ---

## 解析 SRT 文本。
## [br]
## @api public
## [br]
## @param text: SRT 文本。
## [br]
## @param track_id: 可选轨道标识。
## [br]
## @return 解析结果字典，包含 success、track 与 error。
## [br]
## @schema return: Dictionary with success: bool, track: GFTimedTextTrack, error: String.
static func parse_srt(text: String, track_id: StringName = &"") -> Dictionary:
	var track: GFTimedTextTrack = GFTimedTextTrack.new()
	track.track_id = track_id
	var blocks: PackedStringArray = text.replace("\r\n", "\n").replace("\r", "\n").split("\n\n", false)
	for block: String in blocks:
		var lines: PackedStringArray = block.split("\n", false)
		if lines.size() < 2:
			continue
		var time_line_index: int = 0
		if not String(lines[0]).contains("-->") and lines.size() >= 3:
			time_line_index = 1
		var time_range: Dictionary = _parse_time_range(String(lines[time_line_index]))
		if time_range.is_empty():
			continue
		var text_lines: PackedStringArray = PackedStringArray()
		for index: int in range(time_line_index + 1, lines.size()):
			_append_packed_string(text_lines, String(lines[index]))
		var _add_entry_result_44: Variant = track.add_entry(
			GFVariantData.get_option_float(time_range, "start"),
			GFVariantData.get_option_float(time_range, "end"),
			"\n".join(text_lines)
		)
	track.sort_entries()
	return _make_result(true, track, "")


## 解析 WebVTT 文本。
## [br]
## @api public
## [br]
## @param text: WebVTT 文本。
## [br]
## @param track_id: 可选轨道标识。
## [br]
## @return 解析结果字典，包含 success、track 与 error。
## [br]
## @schema return: Dictionary with success: bool, track: GFTimedTextTrack, error: String.
static func parse_vtt(text: String, track_id: StringName = &"") -> Dictionary:
	var normalized: String = text.replace("\r\n", "\n").replace("\r", "\n")
	if normalized.begins_with("WEBVTT"):
		var first_newline: int = normalized.find("\n")
		normalized = normalized.substr(first_newline + 1) if first_newline >= 0 else ""
	return parse_srt(normalized, track_id)


## 解析 LRC 文本。
## [br]
## @api public
## [br]
## @param text: LRC 文本。
## [br]
## @param default_duration: 单行没有下一行时使用的默认时长。
## [br]
## @param track_id: 可选轨道标识。
## [br]
## @return 解析结果字典，包含 success、track 与 error。
## [br]
## @schema return: Dictionary with success: bool, track: GFTimedTextTrack, error: String.
static func parse_lrc(
	text: String,
	default_duration: float = 2.0,
	track_id: StringName = &""
) -> Dictionary:
	var raw_entries: Array[Dictionary] = []
	for line: String in text.replace("\r\n", "\n").replace("\r", "\n").split("\n", false):
		var parsed: Dictionary = _parse_lrc_line(line)
		if not parsed.is_empty():
			raw_entries.append(parsed)
	raw_entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return GFVariantData.get_option_float(left, "start") < GFVariantData.get_option_float(right, "start")
	)

	var track: GFTimedTextTrack = GFTimedTextTrack.new()
	track.track_id = track_id
	for index: int in range(raw_entries.size()):
		var current: Dictionary = raw_entries[index]
		var current_start: float = GFVariantData.get_option_float(current, "start")
		var next_start: float = (
			GFVariantData.get_option_float(raw_entries[index + 1], "start")
			if index + 1 < raw_entries.size()
			else current_start + default_duration
		)
		var _add_entry_result_109: Variant = track.add_entry(current_start, next_start, GFVariantData.get_option_string(current, "text"))
	return _make_result(true, track, "")


# --- 私有/辅助方法 ---

static func _parse_time_range(line: String) -> Dictionary:
	var parts: PackedStringArray = line.split("-->", false)
	if parts.size() < 2:
		return {}
	var start: float = _parse_timestamp(parts[0].strip_edges())
	var end: float = _parse_timestamp(parts[1].strip_edges().split(" ", false)[0])
	if start < 0.0 or end < start:
		return {}
	return {
		"start": start,
		"end": end,
	}


static func _parse_timestamp(text: String) -> float:
	var normalized: String = text.replace(",", ".")
	var parts: PackedStringArray = normalized.split(":", false)
	if parts.size() == 2:
		return float(parts[0]) * 60.0 + float(parts[1])
	if parts.size() == 3:
		return float(parts[0]) * 3600.0 + float(parts[1]) * 60.0 + float(parts[2])
	return -1.0


static func _parse_lrc_line(line: String) -> Dictionary:
	var end_index: int = line.find("]")
	if not line.begins_with("[") or end_index <= 1:
		return {}
	var time_text: String = line.substr(1, end_index - 1)
	var start: float = _parse_timestamp(time_text)
	if start < 0.0:
		return {}
	return {
		"start": start,
		"text": line.substr(end_index + 1),
	}


static func _append_packed_string(target: PackedStringArray, value: String) -> void:
	var appended: bool = target.append(value)
	if appended:
		return


static func _make_result(success: bool, track: GFTimedTextTrack, error: String) -> Dictionary:
	return {
		"success": success,
		"track": track,
		"error": error,
	}
