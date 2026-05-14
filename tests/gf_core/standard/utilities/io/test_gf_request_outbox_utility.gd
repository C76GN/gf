## 测试 GFRequestOutboxUtility 的通用请求排队、重放和持久化。
extends GutTest


# --- 常量 ---

const GFRequestEnvelopeBase = preload("res://addons/gf/standard/utilities/io/gf_request_envelope.gd")
const GFRequestOutboxUtilityBase = preload("res://addons/gf/standard/utilities/io/gf_request_outbox_utility.gd")


# --- 私有变量 ---

var _outbox: GFRequestOutboxUtilityBase
var _storage_path: String = ""


# --- 辅助类 ---

class AsyncTransport:
	extends RefCounted

	signal finished(result: Dictionary)

	var captured: Array[GFRequestEnvelopeBase] = []

	func send(envelope: GFRequestEnvelopeBase) -> Signal:
		captured.append(envelope)
		call_deferred("_emit_success")
		return finished

	func _emit_success() -> void:
		finished.emit({ "ok": true, "accepted": true })


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_storage_path = "user://gf_request_outbox_test_%d.json" % Time.get_ticks_usec()
	_outbox = GFRequestOutboxUtilityBase.new()
	_outbox.storage_path = _storage_path
	_outbox.auto_load_on_init = false
	_outbox.auto_persist = false
	_outbox.retry_delays_msec = [0]
	_outbox.init()


func after_each() -> void:
	if _outbox != null:
		_outbox.dispose()
		_outbox = null
	if FileAccess.file_exists(_storage_path):
		DirAccess.remove_absolute(_storage_path)


# --- 测试方法 ---

func test_replay_success_removes_request_from_queue() -> void:
	var captured: Array[GFRequestEnvelopeBase] = []
	_outbox.transport_callback = func(envelope: GFRequestEnvelopeBase) -> Dictionary:
		captured.append(envelope)
		return { "ok": true, "accepted": true }
	_outbox.enqueue_request(HTTPClient.METHOD_POST, "https://example.test/events", { "value": 1 })

	var report: Dictionary = await _outbox.replay()

	assert_eq(captured.size(), 1, "重放应调用一次 transport。")
	assert_eq(int(report["succeeded"]), 1, "成功请求应计入报告。")
	assert_eq(_outbox.get_queue_size(), 0, "成功后请求应从等待队列移除。")


func test_replay_waits_for_async_transport_signal() -> void:
	var transport := AsyncTransport.new()
	_outbox.transport_callback = Callable(transport, "send")
	_outbox.enqueue_request(HTTPClient.METHOD_POST, "https://example.test/events", { "value": 1 })

	var report: Dictionary = await _outbox.replay()

	assert_eq(transport.captured.size(), 1, "异步重放应调用一次 transport。")
	assert_eq(int(report["succeeded"]), 1, "异步成功请求应计入报告。")
	assert_eq(_outbox.get_queue_size(), 0, "异步成功后请求应从等待队列移除。")


func test_replay_failure_retries_until_success() -> void:
	var state := { "attempts": 0 }
	_outbox.transport_callback = func(_envelope: GFRequestEnvelopeBase) -> Dictionary:
		state["attempts"] = int(state["attempts"]) + 1
		return { "ok": int(state["attempts"]) >= 2, "error": "offline" }
	var envelope: GFRequestEnvelopeBase = _outbox.enqueue_request(HTTPClient.METHOD_POST, "https://example.test/retry")
	envelope.max_attempts = 3

	var failed_report: Dictionary = await _outbox.replay()
	assert_eq(envelope.retry_after_msec, 0, "0ms 重试延迟应允许立即重试。")
	var success_report: Dictionary = await _outbox.replay()

	assert_eq(int(failed_report["failed"]), 1, "首次失败应计入失败报告。")
	assert_eq(int(success_report["succeeded"]), 1, "第二次成功应计入成功报告。")
	assert_eq(int(state["attempts"]), 2, "应按重试机制再次调用 transport。")
	assert_eq(_outbox.get_queue_size(), 0, "成功后队列应清空。")


func test_exhausted_request_moves_to_failed_store() -> void:
	_outbox.transport_callback = func(_envelope: GFRequestEnvelopeBase) -> Dictionary:
		return { "ok": false, "error": "denied" }
	var envelope: GFRequestEnvelopeBase = _outbox.enqueue_request(HTTPClient.METHOD_DELETE, "https://example.test/delete")
	envelope.max_attempts = 1

	await _outbox.replay()

	assert_eq(_outbox.get_queue_size(), 0, "耗尽尝试次数后应离开等待队列。")
	assert_eq(_outbox.get_failed_request_count(), 1, "耗尽请求应进入失败列表。")
	assert_eq(_outbox.get_failed_requests()[0].last_error, "denied", "失败列表应保留最近错误。")


func test_queue_persistence_round_trips_typed_body_values() -> void:
	var envelope: GFRequestEnvelopeBase = _outbox.enqueue_request(HTTPClient.METHOD_PUT, "https://example.test/state", {
		"position": Vector2(3.0, 4.0),
	})
	envelope.metadata = { "tags": PackedStringArray(["state"]) }
	var save_error: Error = _outbox.save_queue()

	var loaded := GFRequestOutboxUtilityBase.new()
	loaded.storage_path = _storage_path
	loaded.auto_load_on_init = false
	loaded.auto_persist = false
	var load_error: Error = loaded.load_queue()
	var requests: Array[GFRequestEnvelopeBase] = loaded.get_pending_requests()

	assert_eq(save_error, OK, "保存队列应成功。")
	assert_eq(load_error, OK, "读取队列应成功。")
	assert_eq(requests.size(), 1, "读取后应恢复一个请求。")
	assert_eq(requests[0].body["position"], Vector2(3.0, 4.0), "请求 body 中的 Godot 类型应经 JSON 持久化恢复。")
	assert_eq(requests[0].metadata["tags"], PackedStringArray(["state"]), "请求 metadata 中的 PackedStringArray 应恢复。")
	loaded.dispose()
