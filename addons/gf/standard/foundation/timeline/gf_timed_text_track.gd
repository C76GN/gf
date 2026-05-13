## GFTimedTextTrack: 通用时间段文本轨道。
##
## 管理一组按时间查询的 `GFTimedTextEntry`，不绑定字幕格式或具体 UI。
class_name GFTimedTextTrack
extends Resource


# --- 导出变量 ---

## 轨道标识。
@export var track_id: StringName = &""

## 时间段文本条目列表。
@export var entries: Array[GFTimedTextEntry] = []

## 可选元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 添加时间段文本条目。
## @param start_time: 开始时间，单位秒。
## @param end_time: 结束时间，单位秒。
## @param text: 文本内容。
## @param entry_metadata: 条目元数据。
## @return 新条目。
func add_entry(
	start_time: float,
	end_time: float,
	text: String,
	entry_metadata: Dictionary = {}
) -> GFTimedTextEntry:
	var entry := GFTimedTextEntry.new()
	entry.start_time = maxf(start_time, 0.0)
	entry.end_time = maxf(end_time, entry.start_time)
	entry.text = text
	entry.metadata = entry_metadata.duplicate(true)
	entries.append(entry)
	return entry


## 清空轨道。
func clear() -> void:
	entries.clear()


## 按开始时间排序条目。
func sort_entries() -> void:
	entries.sort_custom(func(left: GFTimedTextEntry, right: GFTimedTextEntry) -> bool:
		if is_equal_approx(left.start_time, right.start_time):
			return left.end_time < right.end_time
		return left.start_time < right.start_time
	)


## 获取指定时间的第一条文本条目。
## @param time_seconds: 时间，单位秒。
## @return 命中的条目；没有命中时返回 null。
func get_entry_at_time(time_seconds: float) -> GFTimedTextEntry:
	for entry: GFTimedTextEntry in entries:
		if entry != null and entry.contains_time(time_seconds):
			return entry
	return null


## 获取指定时间的文本。
## @param time_seconds: 时间，单位秒。
## @param default_text: 没有命中时返回的文本。
## @return 文本内容。
func get_text_at_time(time_seconds: float, default_text: String = "") -> String:
	var entry := get_entry_at_time(time_seconds)
	return entry.text if entry != null else default_text


## 获取与时间范围相交的条目。
## @param range_start: 范围开始时间。
## @param range_end: 范围结束时间。
## @return 条目列表。
func get_entries_in_range(range_start: float, range_end: float) -> Array[GFTimedTextEntry]:
	var result: Array[GFTimedTextEntry] = []
	for entry: GFTimedTextEntry in entries:
		if entry != null and entry.intersects_range(range_start, range_end):
			result.append(entry)
	return result


## 获取轨道总时长。
## @return 最大结束时间。
func get_total_duration() -> float:
	var duration := 0.0
	for entry: GFTimedTextEntry in entries:
		if entry != null:
			duration = maxf(duration, entry.end_time)
	return duration


## 创建同内容拷贝。
## @return 新轨道。
func duplicate_track() -> GFTimedTextTrack:
	var track := GFTimedTextTrack.new()
	track.track_id = track_id
	track.metadata = metadata.duplicate(true)
	for entry: GFTimedTextEntry in entries:
		track.entries.append(entry.duplicate_entry() if entry != null else null)
	return track


## 转换为字典。
## @return 轨道字典。
func to_dictionary() -> Dictionary:
	var entry_data: Array[Dictionary] = []
	for entry: GFTimedTextEntry in entries:
		if entry != null:
			entry_data.append(entry.to_dictionary())
	return {
		"track_id": track_id,
		"entries": entry_data,
		"metadata": metadata.duplicate(true),
	}


## 应用字典数据。
## @param data: 字典数据。
func apply_dictionary(data: Dictionary) -> void:
	track_id = StringName(String(data.get("track_id", track_id)))
	entries.clear()
	var raw_entries := data.get("entries", []) as Array
	if raw_entries != null:
		for raw_entry: Variant in raw_entries:
			if raw_entry is Dictionary:
				var entry := GFTimedTextEntry.new()
				entry.apply_dictionary(raw_entry as Dictionary)
				entries.append(entry)
	var raw_metadata := data.get("metadata", {}) as Dictionary
	metadata = raw_metadata.duplicate(true) if raw_metadata != null else {}
