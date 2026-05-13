## GFTimedTextEntry: 通用时间段文本条目。
##
## 表示一段开始时间、结束时间和文本，可用于字幕、对白、提示或时间轴注释。
class_name GFTimedTextEntry
extends Resource


# --- 导出变量 ---

## 开始时间，单位秒。
@export var start_time: float = 0.0

## 结束时间，单位秒。
@export var end_time: float = 0.0

## 文本内容。
@export_multiline var text: String = ""

## 可选元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查时间是否落在条目范围内。
## @param time_seconds: 时间，单位秒。
## @return 落在范围内返回 true。
func contains_time(time_seconds: float) -> bool:
	return time_seconds >= start_time and time_seconds < end_time


## 检查条目是否与时间范围相交。
## @param range_start: 范围开始时间。
## @param range_end: 范围结束时间。
## @return 相交返回 true。
func intersects_range(range_start: float, range_end: float) -> bool:
	return end_time > range_start and start_time < range_end


## 创建同内容拷贝。
## @return 新条目。
func duplicate_entry() -> GFTimedTextEntry:
	var entry := GFTimedTextEntry.new()
	entry.start_time = start_time
	entry.end_time = end_time
	entry.text = text
	entry.metadata = metadata.duplicate(true)
	return entry


## 转换为字典。
## @return 条目字典。
func to_dictionary() -> Dictionary:
	return {
		"start_time": start_time,
		"end_time": end_time,
		"text": text,
		"metadata": metadata.duplicate(true),
	}


## 应用字典数据。
## @param data: 字典数据。
func apply_dictionary(data: Dictionary) -> void:
	start_time = float(data.get("start_time", start_time))
	end_time = float(data.get("end_time", end_time))
	text = String(data.get("text", text))
	var raw_metadata := data.get("metadata", {}) as Dictionary
	metadata = raw_metadata.duplicate(true) if raw_metadata != null else {}
