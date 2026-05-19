## 测试 GFAudioBankTools 的音频集合导入和校验辅助。
extends GutTest


# --- 常量 ---

const GFAudioBankBase = preload("res://addons/gf/standard/utilities/audio/gf_audio_bank.gd")
const GFAudioBankInspectorPluginBase = preload("res://addons/gf/standard/utilities/audio/editor/gf_audio_bank_inspector_plugin.gd")
const GFAudioBankToolsBase = preload("res://addons/gf/standard/utilities/audio/gf_audio_bank_tools.gd")
const GFAudioClipBase = preload("res://addons/gf/standard/utilities/audio/gf_audio_clip.gd")


# --- 私有/辅助方法 ---

func _write_empty_user_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "测试应能创建 user:// 临时文件。")
	if file != null:
		file.store_string("")
		file.close()


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


func test_sync_bank_from_scan_imports_audio_paths() -> void:
	var root_path := "user://gf_audio_bank_tools_scan"
	DirAccess.make_dir_recursive_absolute(root_path)
	_write_empty_user_file(root_path.path_join("click.ogg"))
	_write_empty_user_file(root_path.path_join("ignore.txt"))
	var bank := GFAudioBankBase.new()

	var report := GFAudioBankToolsBase.sync_bank_from_scan(bank, root_path, {
		"id_mode": "relative_path",
		"base_path": root_path,
		"bus_name": "SFX",
	})

	assert_eq(report.metadata.get("scanned_count", 0), 1, "扫描同步只应收集支持的音频扩展名。")
	assert_eq(report.metadata.get("added_count", 0), 1, "扫描同步应导入新音频片段。")
	assert_true(bank.has_clip(&"click"), "扫描同步应按相对路径生成片段 ID。")
	assert_eq(bank.get_clip(&"click").bus_name, "SFX", "扫描同步应传递导入选项。")


func test_scan_audio_paths_respects_audio_path_limit() -> void:
	var root_path := "user://gf_audio_bank_tools_limit"
	var first_path := root_path.path_join("first.ogg")
	var second_path := root_path.path_join("second.ogg")
	DirAccess.make_dir_recursive_absolute(root_path)
	_write_empty_user_file(first_path)
	_write_empty_user_file(second_path)

	var paths := GFAudioBankToolsBase.scan_audio_paths(root_path, {
		"max_audio_paths": 1,
	})

	DirAccess.remove_absolute(ProjectSettings.globalize_path(first_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(second_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(root_path))

	assert_eq(paths.size(), 1, "音频扫描应遵守 max_audio_paths 上限。")


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


func test_audio_bank_inspector_tooltip_formats_validation_issue_objects() -> void:
	var bank := GFAudioBankBase.new()
	var clip := GFAudioClipBase.new()
	clip.path = "res://audio/not_audio.txt"
	bank.set_clip(&"bad", clip)

	var report := GFAudioBankToolsBase.validate_bank_playback(bank)
	var tooltip := GFAudioBankInspectorPluginBase._format_report_tooltip(report)

	assert_true(tooltip.contains("unsupported_audio_extension"), "Inspector tooltip 应能读取 GFValidationIssue.kind。")
	assert_true(tooltip.contains("Audio clip path uses an unsupported extension."), "Inspector tooltip 应能读取 GFValidationIssue.message。")
