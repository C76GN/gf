## 测试 GFLogUtility 的日志文件生成、旧日志清理及信号触发。
extends GutTest


# --- 常量 ---

const _LOG_DIR: String = "user://logs/"


# --- 私有变量 ---

var _log_util: GFLogUtility


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_log_util = GFLogUtility.new()
	_log_util.max_log_files = 10
	_log_util.init()


func after_each() -> void:
	if _log_util != null:
		_log_util.dispose()
		_log_util = null


# --- 测试：日志文件生成 ---

## 验证 init() 后，user://logs/ 目录下至少生成了一个 .log 文件。
func test_log_file_created() -> void:
	var dir := DirAccess.open(_LOG_DIR)
	assert_not_null(dir, "logs 目录应存在。")

	var found := false
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".log"):
			found = true
			break
		file_name = dir.get_next()
	dir.list_dir_end()

	assert_true(found, "logs 目录中应至少存在一个 .log 文件。")


## 验证日志内容被写入文件。
func test_log_writes_to_file() -> void:
	_log_util.info("TestTag", "Hello Log")
	_log_util.dispose()

	var file := FileAccess.open(_log_util._log_file_path, FileAccess.READ)
	assert_not_null(file, "日志文件应可成功打开。")

	var content := file.get_as_text()
	file.close()
	assert_true(content.contains("Hello Log"), "日志文件应包含写入的消息内容。")
	assert_true(content.contains("TestTag"), "日志文件应包含标签名称。")
	assert_true(content.contains("INFO"), "日志文件应包含日志级别。")


# --- 测试：旧日志清理 ---

## 验证当日志文件超出 max_log_files 时，旧文件被自动清理。
func test_old_logs_cleanup() -> void:
	_log_util.dispose()
	_log_util = null

	# 预先创建 12 个假日志文件
	for i in range(12):
		var fake_name := "gf_log_20250101_%04d.log" % i
		var f := FileAccess.open(_LOG_DIR + fake_name, FileAccess.WRITE)
		if f != null:
			f.store_line("test")
			f.close()

	_log_util = GFLogUtility.new()
	_log_util.max_log_files = 10
	_log_util.init()

	var dir := DirAccess.open(_LOG_DIR)
	assert_not_null(dir, "logs 目录应存在。")

	var count: int = 0
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".log"):
			count += 1
		file_name = dir.get_next()
	dir.list_dir_end()

	assert_true(count <= 10, "清理后日志文件数量不应超过 max_log_files (10)，实际: %d。" % count)


func test_max_log_files_rejects_negative_values() -> void:
	_log_util.max_log_files = -5

	assert_eq(_log_util.max_log_files, 1, "max_log_files 不应允许负数导致清理越界。")


# --- 测试：信号触发 ---

## 验证调用 info() 后 log_emitted 信号正确触发。
func test_signal_emitted_on_info() -> void:
	watch_signals(_log_util)
	_log_util.info("Signal", "test message")
	assert_signal_emitted(_log_util, "log_emitted", "调用 info() 后应发出 log_emitted 信号。")


## 验证信号携带的参数正确。
func test_signal_params_correct() -> void:
	var received := {"level": - 1, "tag": "", "msg": ""}

	var handler := func(level: int, tag: String, message: String) -> void:
		received["level"] = level
		received["tag"] = tag
		received["msg"] = message

	_log_util.log_emitted.connect(handler)
	_log_util.error("ErrTag", "something broke")

	assert_eq(received["level"], GFLogUtility.LogLevel.ERROR, "信号中的 level 应为 ERROR。")
	assert_eq(received["tag"], "ErrTag", "信号中的 tag 应正确传递。")
	assert_eq(received["msg"], "something broke", "信号中的 message 应正确传递。")
	assert_push_error("[ErrTag] something broke")
