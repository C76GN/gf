## 测试 GFDownloadUtility 的临时提交、续传、校验与取消行为。
extends GutTest


const GFDownloadUtilityBase = preload("res://addons/gf/standard/utilities/io/gf_download_utility.gd")


# --- 辅助子类 ---

class FakeDownloadUtility:
	extends GFDownloadUtilityBase

	var responses: Array[Dictionary] = []
	var request_log: Array[Dictionary] = []
	var auto_complete: bool = true

	func _start_http_request(request_data: Dictionary) -> Error:
		request_log.append(request_data.duplicate(true))
		if not auto_complete:
			return OK

		var response := {
			"success": true,
			"response_code": 200,
			"content": "payload",
			"error": "",
		}
		if not responses.is_empty():
			response = responses.pop_front()

		var file := FileAccess.open(str(request_data["download_file"]), FileAccess.WRITE)
		if file != null:
			file.store_string(str(response.get("content", "")))
			file.close()

		call_deferred(
			"_complete_active_download",
			bool(response.get("success", true)),
			int(response.get("response_code", 200)),
			str(response.get("error", ""))
		)
		return OK


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
			DirAccess.remove_absolute(path)


# --- 测试 ---

func test_enqueue_download_commits_temp_and_reports_success() -> void:
	var target := _track_path("user://gf_download_success_%d.txt" % Time.get_ticks_usec())
	var results: Array[Dictionary] = []
	_utility.responses.append({ "success": true, "response_code": 200, "content": "ok" })

	var handle := _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	)
	await get_tree().process_frame

	assert_gt(handle, 0, "有效下载应返回任务句柄。")
	assert_eq(_read_text(target), "ok", "下载完成后应提交到目标文件。")
	assert_eq(results.size(), 1, "完成回调应执行一次。")
	assert_true(bool(results[0]["success"]), "成功结果应标记 success。")
	assert_eq(int(_utility.get_result(handle)["status"]), GFDownloadTask.Status.COMPLETED, "任务结果应记录完成状态。")


func test_resume_download_appends_segment_when_server_returns_partial_content() -> void:
	var target := _track_path("user://gf_download_resume_%d.txt" % Time.get_ticks_usec())
	var temp := _track_path(target + ".download")
	var segment := _track_path(temp + ".segment")
	_write_text(temp, "old")
	_utility.responses.append({ "success": true, "response_code": 206, "content": "new" })

	_utility.enqueue_download("https://example.test/file", target, Callable(), {
		"temp_path": temp,
		"segment_path": segment,
		"resume": true,
	})
	await get_tree().process_frame

	var headers := (_utility.request_log[0] as Dictionary)["headers"] as PackedStringArray

	assert_true(headers.has("Range: bytes=3-"), "存在临时文件时应带 Range 头续传。")
	assert_eq(_read_text(target), "oldnew", "206 响应应把分段文件追加到临时文件后再提交。")


func test_checksum_failure_reports_failed_without_target_commit() -> void:
	var target := _track_path("user://gf_download_checksum_%d.txt" % Time.get_ticks_usec())
	var results: Array[Dictionary] = []
	_utility.responses.append({ "success": true, "response_code": 200, "content": "bad" })

	_utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	, {
		"expected_sha256": "0000",
	})
	await get_tree().process_frame

	assert_eq(results.size(), 1, "校验失败也应返回结果。")
	assert_false(bool(results[0]["success"]), "校验失败应标记失败。")
	assert_false(FileAccess.file_exists(target), "校验失败不应提交目标文件。")


func test_existing_target_without_overwrite_accepts_matching_checksum() -> void:
	var target := _track_path("user://gf_download_existing_ok_%d.txt" % Time.get_ticks_usec())
	_write_text(target, "cached")
	var checksum := FileAccess.get_sha256(target)
	var results: Array[Dictionary] = []

	var handle := _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	, {
		"overwrite": false,
		"expected_sha256": checksum,
	})
	await get_tree().process_frame

	assert_gt(handle, 0, "有效下载应返回任务句柄。")
	assert_true(_utility.request_log.is_empty(), "已有文件校验通过时不应发起 HTTP 请求。")
	assert_eq(results.size(), 1, "已有文件命中也应返回结果。")
	assert_true(bool(results[0]["success"]), "已有文件 checksum 匹配时应视为完成。")
	assert_true(bool(results[0]["from_existing_file"]), "结果应标记来自已有目标文件。")
	assert_eq(_read_text(target), "cached", "已有目标文件不应被改写。")


func test_existing_target_without_overwrite_rejects_checksum_mismatch() -> void:
	var target := _track_path("user://gf_download_existing_bad_%d.txt" % Time.get_ticks_usec())
	_write_text(target, "cached")
	var results: Array[Dictionary] = []

	_utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	, {
		"overwrite": false,
		"expected_sha256": "0000",
	})
	await get_tree().process_frame

	assert_true(_utility.request_log.is_empty(), "已有文件 checksum 不匹配时不应绕过目标文件策略再发起请求。")
	assert_eq(results.size(), 1, "校验失败应返回结果。")
	assert_false(bool(results[0]["success"]), "checksum 不匹配应标记失败。")
	assert_eq(int(results[0]["status"]), GFDownloadTask.Status.FAILED, "任务状态应标记失败。")
	assert_true(String(results[0]["error"]).contains("checksum mismatch"), "失败原因应说明 checksum 不匹配。")
	assert_eq(_read_text(target), "cached", "失败时不应改写已有目标文件。")


func test_cancel_active_download_reports_cancelled() -> void:
	var target := _track_path("user://gf_download_cancel_%d.txt" % Time.get_ticks_usec())
	_utility.auto_complete = false
	var results: Array[Dictionary] = []

	var handle := _utility.enqueue_download("https://example.test/file", target, func(result: Dictionary) -> void:
		results.append(result)
	)
	var cancelled := _utility.cancel(handle, true)

	assert_true(cancelled, "当前下载任务应可取消。")
	assert_eq(results.size(), 1, "取消应触发回调结果。")
	assert_true(bool(results[0]["cancelled"]), "取消结果应标记 cancelled。")
	assert_true(_utility.get_debug_snapshot()["active_task"].is_empty(), "取消后不应保留 active_task。")


# --- 私有/辅助方法 ---

func _track_path(path: String) -> String:
	_paths.append(path)
	return path


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(text)
	file.close()


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text
