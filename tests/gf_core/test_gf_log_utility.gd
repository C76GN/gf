## 测试 GFLogUtility 的日志文件生成、旧日志清理及信号触发。
extends GutTest


# --- 常量 ---

const _LOG_DIR: String = "user://logs/"


# --- 测试辅助类 ---

class CapturingLogSink extends GFLogSink:
	var init_count: int = 0
	var flush_count: int = 0
	var shutdown_count: int = 0
	var owner_instance: Object
	var entries: Array[Dictionary] = []

	func init(owner: Object) -> void:
		init_count += 1
		owner_instance = owner


	func write(entry: Dictionary) -> void:
		entries.append(entry.duplicate(true))


	func flush() -> void:
		flush_count += 1


	func shutdown() -> void:
		shutdown_count += 1


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
	var log_file_path := _log_util.get_log_file_path()
	_log_util.dispose()

	var file := FileAccess.open(log_file_path, FileAccess.READ)
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
		if not dir.current_is_dir() and file_name.begins_with("gf_log_") and file_name.ends_with(".log"):
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


func test_structured_log_entry_signal_includes_context() -> void:
	var received := {"entry": {}}

	_log_util.log_entry_emitted.connect(func(log_entry: Dictionary) -> void:
		received["entry"] = log_entry
	)

	_log_util.info("Struct", "with context", {
		"entity_id": 12,
		"state": "ready",
	})

	var received_entry: Dictionary = received["entry"]
	assert_eq(received_entry["level"], GFLogUtility.LogLevel.INFO, "结构化条目应包含日志等级。")
	assert_eq(received_entry["tag"], "Struct", "结构化条目应包含标签。")
	assert_eq(received_entry["message"], "with context", "结构化条目应包含原始消息。")
	assert_eq(received_entry["context"]["entity_id"], 12, "结构化条目应包含上下文字段。")
	assert_true(String(received_entry["text"]).contains("entity_id"), "格式化文本应包含上下文字段，便于文件和控制台查看。")


func test_sink_receives_structured_entries_and_lifecycle() -> void:
	var sink := CapturingLogSink.new()

	_log_util.add_sink(sink)
	_log_util.warn("Sink", "captured", {"code": "W1"})
	_log_util.flush_sinks()
	_log_util.remove_sink(sink)

	assert_eq(sink.init_count, 1, "初始化后的日志工具注册 sink 时应立即调用 init。")
	assert_eq(sink.owner_instance, _log_util, "sink init 应收到日志工具实例。")
	assert_eq(sink.entries.size(), 1, "sink 应收到结构化日志条目。")
	assert_eq(sink.entries[0]["context"]["code"], "W1", "sink 应收到上下文副本。")
	assert_eq(sink.flush_count, 1, "flush_sinks 应转发到 sink。")
	assert_eq(sink.shutdown_count, 1, "remove_sink 默认应关闭 sink。")


func test_json_line_log_sink_writes_sanitized_entries() -> void:
	var jsonl_path := _LOG_DIR + "gf_json_line_sink_test.jsonl"
	DirAccess.remove_absolute(jsonl_path)
	var sink := GFJsonLineLogSink.new()
	sink.file_path = jsonl_path
	sink.flush_immediately = true

	_log_util.add_sink(sink)
	_log_util.info("JsonSink", "structured", {
		"profile": &"keyboard",
		"position": Vector2(1.0, 2.0),
	})
	_log_util.remove_sink(sink)

	var file := FileAccess.open(jsonl_path, FileAccess.READ)
	assert_not_null(file, "JSONL sink 应创建可读取文件。")
	var line := file.get_line()
	file.close()

	var parsed := JSON.parse_string(line) as Dictionary
	assert_not_null(parsed, "JSONL 每一行应是合法 JSON 对象。")
	assert_eq(parsed["tag"], "JsonSink", "JSONL 应保留 tag 字段。")
	assert_eq(parsed["message"], "structured", "JSONL 应保留 message 字段。")
	assert_eq(parsed["context"]["profile"], "keyboard", "StringName 上下文应被转成 JSON 字符串。")
	assert_true(String(parsed["context"]["position"]).contains("Vector2"), "非 JSON 原生值应被稳定字符串化。")


func test_json_line_log_sink_derives_path_and_cleans_old_default_files() -> void:
	for index: int in range(4):
		var fake_file := FileAccess.open(_LOG_DIR + "gf_log_20240101_000000_%03d.jsonl" % index, FileAccess.WRITE)
		if fake_file != null:
			fake_file.store_line("{}")
			fake_file.close()

	var sink := GFJsonLineLogSink.new()
	sink.max_jsonl_files = 2
	_log_util.add_sink(sink)
	_log_util.remove_sink(sink)

	var count := 0
	var dir := DirAccess.open(_LOG_DIR)
	assert_not_null(dir, "logs 目录应存在。")
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.begins_with("gf_log_") and file_name.ends_with(".jsonl"):
			count += 1
		file_name = dir.get_next()
	dir.list_dir_end()

	assert_true(sink.get_file_path().ends_with(".jsonl"), "默认 JSONL 路径应由当前日志文件派生。")
	assert_true(count <= 2, "默认 JSONL 文件数量应按 max_jsonl_files 清理。")


func test_min_level_filters_lower_level_logs() -> void:
	watch_signals(_log_util)
	_log_util.min_level = GFLogUtility.LogLevel.WARN

	_log_util.info("Filtered", "hidden")

	assert_signal_not_emitted(_log_util, "log_emitted", "低于 min_level 的日志不应发出信号。")


func test_lazy_log_does_not_build_filtered_message() -> void:
	var counter := {"build": 0}
	_log_util.min_level = GFLogUtility.LogLevel.ERROR

	_log_util.debug_lazy("Lazy", func() -> String:
		counter["build"] += 1
		return "expensive"
	)

	assert_eq(counter["build"], 0, "被等级过滤的 lazy 日志不应执行 message_builder。")


func test_lazy_log_does_not_build_filtered_context() -> void:
	var counter := {"message": 0, "context": 0}
	_log_util.min_level = GFLogUtility.LogLevel.ERROR

	var message_builder := func() -> String:
		counter["message"] += 1
		return "expensive"
	var context_builder := func() -> Dictionary:
		counter["context"] += 1
		return {"expensive": true}

	_log_util.debug_lazy("Lazy", message_builder, context_builder)

	assert_eq(counter["message"], 0, "被等级过滤的 lazy 日志不应执行 message_builder。")
	assert_eq(counter["context"], 0, "被等级过滤的 lazy 日志不应执行 context_builder。")


func test_lazy_log_builds_message_when_enabled() -> void:
	var counter := {"build": 0}
	var received := {"msg": ""}
	_log_util.log_emitted.connect(func(_level: int, _tag: String, message: String) -> void:
		received["msg"] = message
	)

	_log_util.info_lazy("Lazy", func() -> String:
		counter["build"] += 1
		return "built"
	)

	assert_eq(counter["build"], 1, "未被过滤的 lazy 日志应执行 message_builder。")
	assert_eq(received["msg"], "built", "lazy 日志应输出构造后的消息。")


func test_memory_entries_are_capped_and_ordered() -> void:
	_log_util.max_memory_entries = 2
	_log_util.clear_memory_entries()

	_log_util.info("Memory", "one")
	_log_util.info("Memory", "two")
	_log_util.info("Memory", "three")

	var entries := _log_util.get_recent_entries()
	assert_eq(entries.size(), 2, "内存日志应遵守容量上限。")
	assert_eq(entries[0]["message"], "two", "内存日志应保留较新的条目并保持从旧到新排序。")
	assert_eq(entries[1]["message"], "three", "最新条目应位于末尾。")
	assert_eq(_log_util.get_dropped_memory_entry_count(), 1, "超出容量的条目应计入丢弃数量。")


func test_memory_entries_support_offset_reads_after_wrap() -> void:
	_log_util.max_memory_entries = 3
	_log_util.clear_memory_entries()

	_log_util.info("Memory", "one")
	_log_util.info("Memory", "two")
	_log_util.info("Memory", "three")
	_log_util.info("Memory", "four")

	var entries := _log_util.get_entries(1, 2)
	assert_eq(entries.size(), 2, "按偏移读取应返回请求数量。")
	assert_eq(entries[0]["message"], "three", "环形缓冲按偏移读取应保持逻辑顺序。")
	assert_eq(entries[1]["message"], "four", "环形缓冲最新条目应位于读取结果末尾。")


func test_lowering_memory_limit_keeps_newest_entries() -> void:
	_log_util.max_memory_entries = 4
	_log_util.clear_memory_entries()

	_log_util.info("Memory", "one")
	_log_util.info("Memory", "two")
	_log_util.info("Memory", "three")
	_log_util.info("Memory", "four")

	_log_util.max_memory_entries = 2

	var entries := _log_util.get_recent_entries()
	assert_eq(entries.size(), 2, "降低容量后内存日志应立即裁剪。")
	assert_eq(entries[0]["message"], "three", "降低容量后应保留较新的条目。")
	assert_eq(entries[1]["message"], "four", "降低容量后最新条目应位于末尾。")
	assert_eq(_log_util.get_dropped_memory_entry_count(), 2, "降低容量裁剪的条目应计入丢弃数量。")
