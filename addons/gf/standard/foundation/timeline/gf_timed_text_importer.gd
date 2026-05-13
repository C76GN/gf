## GFTimedTextImporter: 通用时间段文本解析器。
##
## 提供 SRT、WebVTT 与 LRC 的轻量解析入口，输出 `GFTimedTextTrack`。
class_name GFTimedTextImporter
extends RefCounted


# --- 公共方法 ---

## 解析 SRT 文本。
## @param text: SRT 文本。
## @param track_id: 可选轨道标识。
## @return 解析结果字典，包含 success、track 与 error。
static func parse_srt(text: String, track_id: StringName = &"") -> Dictionary:
	var track := GFTimedTextTrack.new()
	track.track_id = track_id
	var blocks := text.replace("\r\n", "\n").replace("\r", "\n").split("\n\n", false)
	for block: String in blocks:
		var lines := block.split("\n", false)
		if lines.size() < 2:
			continue
		var time_line_index := 0
		if not String(lines[0]).contains("-->") and lines.size() >= 3:
			time_line_index = 1
		var time_range := _parse_time_range(String(lines[time_line_index]))
		if time_range.is_empty():
			continue
		var text_lines := PackedStringArray()
		for index: int in range(time_line_index + 1, lines.size()):
			text_lines.append(String(lines[index]))
		track.add_entry(float(time_range["start"]), float(time_range["end"]), "\n".join(text_lines))
	track.sort_entries()
	return _make_result(true, track, "")


## 解析 WebVTT 文本。
## @param text: WebVTT 文本。
## @param track_id: 可选轨道标识。
## @return 解析结果字典，包含 success、track 与 error。
static func parse_vtt(text: String, track_id: StringName = &"") -> Dictionary:
	var normalized := text.replace("\r\n", "\n").replace("\r", "\n")
	if normalized.begins_with("WEBVTT"):
		var first_newline := normalized.find("\n")
		normalized = normalized.substr(first_newline + 1) if first_newline >= 0 else ""
	return parse_srt(normalized, track_id)


## 解析 LRC 文本。
## @param text: LRC 文本。
## @param default_duration: 单行没有下一行时使用的默认时长。
## @param track_id: 可选轨道标识。
## @return 解析结果字典，包含 success、track 与 error。
static func parse_lrc(
	text: String,
	default_duration: float = 2.0,
	track_id: StringName = &""
) -> Dictionary:
	var raw_entries: Array[Dictionary] = []
	for line: String in text.replace("\r\n", "\n").replace("\r", "\n").split("\n", false):
		var parsed := _parse_lrc_line(line)
		if not parsed.is_empty():
			raw_entries.append(parsed)
	raw_entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return float(left["start"]) < float(right["start"])
	)

	var track := GFTimedTextTrack.new()
	track.track_id = track_id
	for index: int in range(raw_entries.size()):
		var current := raw_entries[index]
		var next_start := float(raw_entries[index + 1]["start"]) if index + 1 < raw_entries.size() else float(current["start"]) + default_duration
		track.add_entry(float(current["start"]), next_start, String(current["text"]))
	return _make_result(true, track, "")


# --- 私有/辅助方法 ---

static func _parse_time_range(line: String) -> Dictionary:
	var parts := line.split("-->", false)
	if parts.size() < 2:
		return {}
	var start := _parse_timestamp(parts[0].strip_edges())
	var end := _parse_timestamp(parts[1].strip_edges().split(" ", false)[0])
	if start < 0.0 or end < start:
		return {}
	return {
		"start": start,
		"end": end,
	}


static func _parse_timestamp(text: String) -> float:
	var normalized := text.replace(",", ".")
	var parts := normalized.split(":", false)
	if parts.size() == 2:
		return float(parts[0]) * 60.0 + float(parts[1])
	if parts.size() == 3:
		return float(parts[0]) * 3600.0 + float(parts[1]) * 60.0 + float(parts[2])
	return -1.0


static func _parse_lrc_line(line: String) -> Dictionary:
	var end_index := line.find("]")
	if not line.begins_with("[") or end_index <= 1:
		return {}
	var time_text := line.substr(1, end_index - 1)
	var start := _parse_timestamp(time_text)
	if start < 0.0:
		return {}
	return {
		"start": start,
		"text": line.substr(end_index + 1),
	}


static func _make_result(success: bool, track: GFTimedTextTrack, error: String) -> Dictionary:
	return {
		"success": success,
		"track": track,
		"error": error,
	}
