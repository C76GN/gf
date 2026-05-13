## 测试 GFAudioBankTools 的音频集合导入和校验辅助。
extends GutTest


# --- 常量 ---

const GFAudioBankBase = preload("res://addons/gf/standard/utilities/audio/gf_audio_bank.gd")
const GFAudioBankToolsBase = preload("res://addons/gf/standard/utilities/audio/gf_audio_bank_tools.gd")
const GFAudioClipBase = preload("res://addons/gf/standard/utilities/audio/gf_audio_clip.gd")


# --- 测试 ---

func test_create_bank_from_paths_uses_relative_clip_ids() -> void:
	var paths := PackedStringArray([
		"res://audio/ui/click.ogg",
		"res://audio/ui/confirm.wav",
	])

	var bank := GFAudioBankToolsBase.create_bank_from_paths(paths, {
		"id_mode": "relative_path",
		"base_path": "res://audio",
		"path_separator": "+",
		"bus_name": "SFX",
	})

	assert_true(bank.has_clip(&"ui+click"), "应按相对路径生成稳定片段 ID。")
	assert_true(bank.has_clip(&"ui+confirm"), "应导入全部支持的音频路径。")
	assert_eq(bank.get_clip(&"ui+click").bus_name, "SFX", "导入时应写入默认 bus。")


func test_add_paths_to_bank_skips_existing_ids_without_overwrite() -> void:
	var bank := GFAudioBankBase.new()
	var existing_clip := GFAudioClipBase.new()
	existing_clip.path = "res://audio/existing.ogg"
	bank.set_clip(&"click", existing_clip)

	var report := GFAudioBankToolsBase.add_paths_to_bank(bank, PackedStringArray([
		"res://audio/click.ogg",
	]))
	var counts := report.get_issue_counts_by_kind()

	assert_eq(counts.get("audio_clip_id_exists", 0), 1, "重复 ID 且未开启覆盖时应跳过。")
	assert_eq(bank.get_clip(&"click").path, "res://audio/existing.ogg", "原有片段不应被覆盖。")
	assert_eq(report.metadata.get("skipped_count", 0), 1, "报告应记录跳过数量。")


func test_validate_bank_playback_reports_bus_and_extension_issues() -> void:
	var bank := GFAudioBankBase.new()
	var clip := GFAudioClipBase.new()
	clip.path = "res://audio/not_audio.txt"
	clip.bus_name = "__missing_gf_test_bus__"
	bank.set_clip(&"bad", clip)

	var report := GFAudioBankToolsBase.validate_bank_playback(bank, {
		"check_bus_exists": true,
	})
	var counts := report.get_issue_counts_by_kind()

	assert_eq(counts.get("unsupported_audio_extension", 0), 1, "不支持的扩展名应产生警告。")
	assert_eq(counts.get("missing_audio_bus", 0), 1, "不存在的音频总线应产生警告。")
