## 测试时间段文本轨道与区域分块数据映射。
extends GutTest


# --- 常量 ---

const GFRegionMap2DBase = preload("res://addons/gf/standard/foundation/math/gf_region_map_2d.gd")
const GFTimedTextEntryBase = preload("res://addons/gf/standard/foundation/timeline/gf_timed_text_entry.gd")
const GFTimedTextTrackBase = preload("res://addons/gf/standard/foundation/timeline/gf_timed_text_track.gd")
const GFTimedTextImporterBase = preload("res://addons/gf/standard/foundation/timeline/gf_timed_text_importer.gd")


# --- 测试 ---

func test_timed_text_track_queries_entries() -> void:
	var track: Object = GFTimedTextTrackBase.new()
	track.call("add_entry", 0.0, 1.0, "A")
	track.call("add_entry", 1.0, 2.0, "B")

	assert_eq(track.call("get_text_at_time", 0.5), "A", "时间查询应返回命中文本。")
	assert_eq((track.call("get_entries_in_range", 0.5, 1.5) as Array).size(), 2, "范围查询应返回相交条目。")
	assert_eq(track.call("get_total_duration"), 2.0, "总时长应取最大结束时间。")


func test_timed_text_importer_parses_srt_and_lrc() -> void:
	var srt := "1\n00:00:01,000 --> 00:00:02,500\nHello\n"
	var srt_result := GFTimedTextImporterBase.parse_srt(srt, &"caption")
	var srt_track := srt_result["track"] as Object
	var lrc_result := GFTimedTextImporterBase.parse_lrc("[00:01.00]One\n[00:03.00]Two\n", 1.0)
	var lrc_track := lrc_result["track"] as Object

	assert_true(bool(srt_result["success"]), "SRT 应解析成功。")
	assert_eq(srt_track.get("track_id"), &"caption", "轨道 ID 应保留。")
	assert_eq(srt_track.call("get_text_at_time", 1.25), "Hello", "SRT 时间段应可查询。")
	assert_eq(lrc_track.call("get_text_at_time", 1.5), "One", "LRC 行应转换为时间段。")
	assert_eq(lrc_track.call("get_total_duration"), 4.0, "LRC 最后一行应使用默认时长。")


func test_region_map_tracks_dirty_regions() -> void:
	var region_map := GFRegionMap2DBase.new()
	region_map.region_size = Vector2i(4, 4)
	region_map.set_cell(Vector2i(1, 1), { "value": 1 })
	region_map.set_cell(Vector2i(5, 1), { "value": 2 })

	assert_eq(region_map.get_region_key_for_cell(Vector2i(5, 1)), Vector2i(1, 0), "格坐标应映射到区域键。")
	assert_eq((region_map.get_cell(Vector2i(1, 1)) as Dictionary)["value"], 1, "应能读取格子数据。")
	assert_eq(region_map.get_dirty_region_keys().size(), 2, "写入两个区域后应标记两个脏区。")

	region_map.clear_dirty(Vector2i(1, 0))

	assert_eq(region_map.get_dirty_region_keys().size(), 1, "清理指定区域后应只剩一个脏区。")
