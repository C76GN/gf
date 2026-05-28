## 测试 GFDirectoryWatchUtility 的快照差异检测。
extends GutTest


# --- 常量 ---

const GFDirectoryWatchUtilityBase = preload("res://addons/gf/standard/utilities/io/gf_directory_watch_utility.gd")


# --- 测试方法 ---

func test_poll_builds_baseline_then_reports_created_and_deleted_paths() -> void:
	var root_path := "user://gf_directory_watch_utility_scan"
	var first_path := root_path.path_join("first.txt")
	var second_path := root_path.path_join("second.txt")
	DirAccess.make_dir_recursive_absolute(root_path)
	_write_text_file(first_path, "first")

	var watcher := GFDirectoryWatchUtilityBase.new()
	var events: Array[GFDirectoryChangeSet] = []
	watcher.configure({ "extensions": PackedStringArray(["txt"]) })
	watcher.watch_path(root_path)
	watcher.changed.connect(func(change_set: GFDirectoryChangeSet) -> void:
		events.append(change_set.duplicate_change_set())
	)

	var baseline := watcher.poll()
	_write_text_file(second_path, "second")
	var created := watcher.poll()
	_remove_user_file(first_path)
	var deleted := watcher.poll()

	_remove_user_file(second_path)
	_remove_user_dir(root_path)

	assert_true(baseline.is_empty(), "默认首次扫描只建立基线，不应报告已存在文件。")
	assert_eq(baseline.snapshot_size, 1, "首次扫描仍应记录快照数量。")
	assert_true(created.created.has(second_path), "新增文件应进入 created 列表。")
	assert_true(deleted.deleted.has(first_path), "删除文件应进入 deleted 列表。")
	assert_eq(events.size(), 2, "只有实际变化应触发 changed 信号。")


func test_poll_can_report_existing_files_on_first_scan() -> void:
	var root_path := "user://gf_directory_watch_utility_first_scan"
	var first_path := root_path.path_join("first.txt")
	DirAccess.make_dir_recursive_absolute(root_path)
	_write_text_file(first_path, "first")

	var watcher := GFDirectoryWatchUtilityBase.new()
	watcher.report_existing_on_first_scan = true
	watcher.watch_path(root_path)

	var change_set := watcher.poll()

	_remove_user_file(first_path)
	_remove_user_dir(root_path)

	assert_true(change_set.created.has(first_path), "开启 report_existing_on_first_scan 后首次扫描应报告已有文件。")


# --- 私有/辅助方法 ---

func _write_text_file(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "测试应能创建 user:// 临时文件。")
	if file != null:
		file.store_string(content)
		file.close()


func _remove_user_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _remove_user_dir(path: String) -> void:
	var global_path := ProjectSettings.globalize_path(path)
	if DirAccess.dir_exists_absolute(global_path):
		DirAccess.remove_absolute(global_path)
