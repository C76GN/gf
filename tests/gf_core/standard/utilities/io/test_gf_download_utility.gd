## 测试 GFDownloadUtility 的临时提交、续传、校验与取消行为。
extends GutTest

# --- 私有变量 ---

var _utility: FakeDownloadUtility
var _paths: Array[String] = []


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_utility = FakeDownloadUtility.new()
	_utility.init()
	_paths.clear()


func after_each() -> void:
	if _utility != null:
		_utility.dispose()
		_utility = null
	for path: String in _paths:
		if FileAccess.file_exists(path):
			var _remove_error: Error = DirAccess.remove_absolute(path)


# --- 测试 ---

func test_enqueue_download_commits_temp_and_reports_success() -> void:
	var target: String = _track_path("user://gf_download_success_%d.txt" % Time.get_ticks_usec())
	var results: Array[Dictionary] = []
	_utility.responses.append({ "success": true, "response_code": 200, "content": "ok" })

	var handle: int = _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	)
	await get_tree().process_frame
	var download_result: Dictionary = _first_result(results)

	assert_gt(handle, 0, "有效下载应返回任务句柄。")
	assert_eq(_read_text(target), "ok", "下载完成后应提交到目标文件。")
	assert_eq(results.size(), 1, "完成回调应执行一次。")
	assert_true(GFVariantData.get_option_bool(download_result, "success"), "成功结果应标记 success。")
	assert_eq(GFVariantData.get_option_int(_utility.get_result(handle), "status"), GFDownloadTask.Status.COMPLETED, "任务结果应记录完成状态。")


func test_resume_download_appends_segment_when_server_returns_partial_content() -> void:
	var target: String = _track_path("user://gf_download_resume_%d.txt" % Time.get_ticks_usec())
	var temp: String = _track_path(target + ".download")
	var segment: String = _track_path(temp + ".segment")
	_write_text(temp, "old")
	_utility.responses.append({ "success": true, "response_code": 206, "content": "new" })

	var _enqueue_download_result_54: Variant = _utility.enqueue_download("https://example.test/file", target, Callable(), {
		"temp_path": temp,
		"segment_path": segment,
		"resume": true,
	})
	await get_tree().process_frame

	var headers: PackedStringArray = _request_headers(0)

	assert_true(headers.has("Range: bytes=3-"), "存在临时文件时应带 Range 头续传。")
	assert_eq(_read_text(target), "oldnew", "206 响应应把分段文件追加到临时文件后再提交。")


func test_enqueue_download_accepts_string_name_options_and_copies_metadata() -> void:
	var target: String = _track_path("user://gf_download_options_%d.txt" % Time.get_ticks_usec())
	var source_metadata: Dictionary = {
		"nested": {
			"value": 1,
		},
	}
	var results: Array[Dictionary] = []
	_utility.responses.append({ "success": true, "response_code": 200, "content": "ok" })

	var handle: int = _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	, {
		&"overwrite": "on",
		&"max_retries": "1",
		&"metadata": source_metadata,
	})
	await get_tree().process_frame
	var download_result: Dictionary = _first_result(results)
	var result_metadata: Dictionary = GFVariantData.as_dictionary(GFVariantData.get_option_value(download_result, "metadata"))
	var result_nested: Dictionary = GFVariantData.as_dictionary(GFVariantData.get_option_value(result_metadata, "nested"))
	var source_nested: Dictionary = GFVariantData.as_dictionary(GFVariantData.get_option_value(source_metadata, "nested"))
	result_nested["value"] = 2

	assert_gt(handle, 0, "有效下载应返回任务句柄。")
	assert_true(GFVariantData.get_option_bool(download_result, "success"), "下载应成功。")
	assert_eq(GFVariantData.get_option_int(download_result, "max_retries"), 1, "StringName 选项键和值应被归一读取。")
	assert_eq(GFVariantData.get_option_int(source_nested, "value"), 1, "下载任务 metadata 应复制保存。")


func test_checksum_failure_reports_failed_without_target_commit() -> void:
	var target: String = _track_path("user://gf_download_checksum_%d.txt" % Time.get_ticks_usec())
	var results: Array[Dictionary] = []
	_utility.responses.append({ "success": true, "response_code": 200, "content": "bad" })

	var _enqueue_download_result_102: Variant = _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	, {
		"expected_sha256": "0000",
	})
	await get_tree().process_frame
	var download_result: Dictionary = _first_result(results)

	assert_eq(results.size(), 1, "校验失败也应返回结果。")
	assert_false(GFVariantData.get_option_bool(download_result, "success"), "校验失败应标记失败。")
	assert_false(FileAccess.file_exists(target), "校验失败不应提交目标文件。")


func test_existing_target_without_overwrite_accepts_matching_checksum() -> void:
	var target: String = _track_path("user://gf_download_existing_ok_%d.txt" % Time.get_ticks_usec())
	_write_text(target, "cached")
	var checksum: String = FileAccess.get_sha256(target)
	var results: Array[Dictionary] = []

	var handle: int = _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	, {
		"overwrite": false,
		"expected_sha256": checksum,
	})
	await get_tree().process_frame
	var download_result: Dictionary = _first_result(results)

	assert_gt(handle, 0, "有效下载应返回任务句柄。")
	assert_true(_utility.request_log.is_empty(), "已有文件校验通过时不应发起 HTTP 请求。")
	assert_eq(results.size(), 1, "已有文件命中也应返回结果。")
	assert_true(GFVariantData.get_option_bool(download_result, "success"), "已有文件 checksum 匹配时应视为完成。")
	assert_true(GFVariantData.get_option_bool(download_result, "from_existing_file"), "结果应标记来自已有目标文件。")
	assert_eq(_read_text(target), "cached", "已有目标文件不应被改写。")


func test_existing_target_without_overwrite_rejects_checksum_mismatch() -> void:
	var target: String = _track_path("user://gf_download_existing_bad_%d.txt" % Time.get_ticks_usec())
	_write_text(target, "cached")
	var results: Array[Dictionary] = []

	var _enqueue_download_result_143: Variant = _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	, {
		"overwrite": false,
		"expected_sha256": "0000",
	})
	await get_tree().process_frame
	var download_result: Dictionary = _first_result(results)

	assert_true(_utility.request_log.is_empty(), "已有文件 checksum 不匹配时不应绕过目标文件策略再发起请求。")
	assert_eq(results.size(), 1, "校验失败应返回结果。")
	assert_false(GFVariantData.get_option_bool(download_result, "success"), "checksum 不匹配应标记失败。")
	assert_eq(GFVariantData.get_option_int(download_result, "status"), GFDownloadTask.Status.FAILED, "任务状态应标记失败。")
	assert_true(GFVariantData.get_option_string(download_result, "error").contains("checksum mismatch"), "失败原因应说明 checksum 不匹配。")
	assert_eq(_read_text(target), "cached", "失败时不应改写已有目标文件。")


func test_retryable_failure_requeues_before_reporting_result() -> void:
	var target: String = _track_path("user://gf_download_retry_%d.txt" % Time.get_ticks_usec())
	var results: Array[Dictionary] = []
	_utility.responses.append({
		"success": false,
		"response_code": 0,
		"error": "temporary",
		"retryable": true,
	})
	_utility.responses.append({ "success": true, "response_code": 200, "content": "ok" })

	var handle: int = _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	, {
		"max_retries": 1,
	})
	await get_tree().process_frame
	await get_tree().process_frame
	var download_result: Dictionary = _first_result(results)

	assert_gt(handle, 0, "有效下载应返回任务句柄。")
	assert_eq(_utility.request_log.size(), 2, "可重试失败应再次发起请求。")
	assert_eq(results.size(), 1, "重试成功后只应报告最终结果。")
	assert_true(GFVariantData.get_option_bool(download_result, "success"), "重试成功应返回成功结果。")
	assert_eq(GFVariantData.get_option_int(download_result, "retry_count"), 1, "结果应记录已重试次数。")
	assert_eq(_read_text(target), "ok", "重试成功后应提交最终文件。")


func test_retryable_http_error_does_not_resume_from_error_body() -> void:
	var target: String = _track_path("user://gf_download_retry_body_%d.txt" % Time.get_ticks_usec())
	var results: Array[Dictionary] = []
	_utility.responses.append({
		"success": false,
		"response_code": 500,
		"content": "server-error",
		"error": "HTTP 500",
	})
	_utility.responses.append({ "success": true, "response_code": 200, "content": "ok" })

	var _enqueue_download_result_199: Variant = _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	, {
		"max_retries": 1,
	})
	await get_tree().process_frame
	await get_tree().process_frame

	var retry_headers: PackedStringArray = _request_headers(1)
	var download_result: Dictionary = _first_result(results)

	assert_false(retry_headers.has("Range: bytes=12-"), "HTTP 错误响应体不应被当作可续传内容。")
	assert_eq(results.size(), 1, "重试成功后只应报告最终结果。")
	assert_true(GFVariantData.get_option_bool(download_result, "success"), "HTTP 错误重试成功应返回成功结果。")
	assert_eq(_read_text(target), "ok", "最终文件不应包含错误响应体。")


func test_cancel_active_download_reports_cancelled() -> void:
	var target: String = _track_path("user://gf_download_cancel_%d.txt" % Time.get_ticks_usec())
	_utility.auto_complete = false
	var results: Array[Dictionary] = []

	var handle: int = _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	)
	var cancelled: bool = _utility.cancel(handle, true)
	var download_result: Dictionary = _first_result(results)
	var active_task: Dictionary = GFVariantData.get_option_dictionary(_utility.get_debug_snapshot(), "active_task")

	assert_true(cancelled, "当前下载任务应可取消。")
	assert_eq(results.size(), 1, "取消应触发回调结果。")
	assert_true(GFVariantData.get_option_bool(download_result, "cancelled"), "取消结果应标记 cancelled。")
	assert_true(active_task.is_empty(), "取消后不应保留 active_task。")


# --- 私有/辅助方法 ---

func _track_path(path: String) -> String:
	_paths.append(path)
	return path


func _write_text(path: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	var _store_string_result_245: Variant = file.store_string(text)
	file.close()


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _first_result(results: Array[Dictionary]) -> Dictionary:
	if results.is_empty():
		return {}
	return results[0]


func _request_headers(index: int) -> PackedStringArray:
	var request_data: Dictionary = _utility.request_log[index]
	return GFVariantData.get_option_packed_string_array(request_data, "headers")


# --- 内部类 ---

class FakeDownloadUtility:
	extends GFDownloadUtility

	var responses: Array[Dictionary] = []
	var request_log: Array[Dictionary] = []
	var auto_complete: bool = true

	func _start_http_request(request_data: Dictionary) -> Error:
		request_log.append(request_data.duplicate(true))
		if not auto_complete:
			return OK

		var response: Dictionary = {
			"success": true,
			"response_code": 200,
			"content": "payload",
			"error": "",
		}
		if not responses.is_empty():
			response = responses.pop_front()

		var download_file_path: String = GFVariantData.get_option_string(request_data, "download_file")
		var file: FileAccess = FileAccess.open(download_file_path, FileAccess.WRITE)
		if file != null:
			var _store_string_result_295: Variant = file.store_string(GFVariantData.get_option_string(response, "content"))
			file.close()

		call_deferred(
			"_complete_active_download",
			GFVariantData.get_option_bool(response, "success", true),
			GFVariantData.get_option_int(response, "response_code", 200),
			GFVariantData.get_option_string(response, "error"),
			GFVariantData.get_option_bool(response, "retryable")
		)
		return OK
