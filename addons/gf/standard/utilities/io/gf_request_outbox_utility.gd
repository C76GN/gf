## GFRequestOutboxUtility: 通用离线请求队列。
##
## 负责把项目提交的请求描述持久化、按重试策略重放，并通过 transport_callback
## 交给项目自己的网络、SDK 或工具链发送。它不内置任何账号、云服务或业务协议。
class_name GFRequestOutboxUtility
extends GFUtility


# --- 信号 ---

## 请求成功进入队列。
## @param envelope: 请求描述。
signal request_enqueued(envelope: RefCounted)

## 请求开始重放。
## @param envelope: 请求描述。
signal request_started(envelope: RefCounted)

## 请求成功完成。
## @param envelope: 请求描述。
## @param result: transport 返回的结果字典。
signal request_completed(envelope: RefCounted, result: Dictionary)

## 请求失败。
## @param envelope: 请求描述。
## @param result: transport 返回的结果字典。
signal request_failed(envelope: RefCounted, result: Dictionary)

## 队列快照变化。
## @param snapshot: 调试快照。
signal queue_changed(snapshot: Dictionary)


# --- 常量 ---

const GFRequestEnvelopeBase = preload("res://addons/gf/standard/utilities/io/gf_request_envelope.gd")


# --- 公共变量 ---

## 队列持久化路径。
var storage_path: String = "user://gf_request_outbox.json"

## init() 时是否自动读取持久化队列。
var auto_load_on_init: bool = true

## 队列变化后是否自动写入 storage_path。
var auto_persist: bool = true

## 最大等待队列长度；小于等于 0 表示不限制。
var max_queue_size: int = 128

## 新入队请求默认最大尝试次数；小于等于 0 表示不限制。
var default_max_attempts: int = 3

## 重试延迟序列，单位毫秒；超过长度后复用最后一个值。
var retry_delays_msec: Array[int] = [500, 1000, 2000, 5000]

## 请求耗尽尝试次数后是否保留在失败列表中。
var keep_failed_requests: bool = true

## 失败列表最多保留数量；小于等于 0 表示不保留。
var max_failed_requests: int = 32

## 传输回调，签名为 func(envelope: GFRequestEnvelope) -> Dictionary；也可返回会发出结果值的 Signal。
var transport_callback: Callable = Callable()

## 可选重放过滤回调，签名为 func(envelope: GFRequestEnvelope) -> bool。
var replay_filter: Callable = Callable()


# --- 私有变量 ---

var _queue: Array[GFRequestEnvelopeBase] = []
var _failed_requests: Array[GFRequestEnvelopeBase] = []
var _is_replaying: bool = false


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_pause = true
	if auto_load_on_init:
		load_queue()


func dispose() -> void:
	if auto_persist:
		save_queue()
	_queue.clear()
	_failed_requests.clear()
	_is_replaying = false


# --- 公共方法 ---

## 创建并入队一个请求。
## @param method: HTTPClient.Method 数值。
## @param url: 请求目标地址或项目自定义端点。
## @param body: 请求载荷。
## @param headers: 请求 Header。
## @param metadata: 项目自定义元数据。
## @return 入队成功时返回请求描述；失败返回 null。
func enqueue_request(
	method: int,
	url: String,
	body: Dictionary = {},
	headers: PackedStringArray = PackedStringArray(),
	metadata: Dictionary = {}
) -> GFRequestEnvelopeBase:
	var envelope := GFRequestEnvelopeBase.new(method, url, body, headers, metadata)
	envelope.max_attempts = default_max_attempts
	return envelope if enqueue(envelope) else null


## 入队已有请求描述。
## @param envelope: 请求描述。
## @return 入队成功返回 true。
func enqueue(envelope: GFRequestEnvelopeBase) -> bool:
	if envelope == null or not envelope.is_valid():
		return false
	if max_queue_size > 0 and _queue.size() >= max_queue_size:
		return false

	if envelope.request_id == &"":
		envelope.request_id = StringName(_generate_request_id())
	if envelope.created_at_unix <= 0:
		envelope.created_at_unix = int(Time.get_unix_time_from_system())

	_queue.append(envelope)
	request_enqueued.emit(envelope)
	_persist_and_emit_changed()
	return true


## 重放可尝试的请求。
## @param max_count: 最多处理数量；小于等于 0 表示不限制。
## @return 重放报告。
func replay(max_count: int = 0) -> Dictionary:
	var report := {
		"ok": true,
		"processed": 0,
		"succeeded": 0,
		"failed": 0,
		"skipped": 0,
		"pending": _queue.size(),
		"failed_stored": _failed_requests.size(),
		"reason": "",
	}
	if not transport_callback.is_valid():
		report["ok"] = false
		report["reason"] = "missing_transport"
		return report
	if _is_replaying:
		report["ok"] = false
		report["reason"] = "replay_in_progress"
		return report

	_is_replaying = true
	var now_msec := Time.get_ticks_msec()
	var index := 0
	while index < _queue.size():
		if max_count > 0 and int(report["processed"]) >= max_count:
			break

		var envelope := _queue[index]
		if not _can_replay_envelope(envelope, now_msec):
			report["skipped"] = int(report["skipped"]) + 1
			index += 1
			continue

		report["processed"] = int(report["processed"]) + 1
		request_started.emit(envelope)
		envelope.mark_attempt()
		var result: Dictionary = await _call_transport(envelope)
		var queue_index := _find_queue_index(envelope)
		if _is_success_result(result):
			envelope.mark_success()
			if queue_index >= 0:
				_queue.remove_at(queue_index)
				index = queue_index
			else:
				index = mini(index, _queue.size())
			report["succeeded"] = int(report["succeeded"]) + 1
			request_completed.emit(envelope, result)
			continue

		report["failed"] = int(report["failed"]) + 1
		envelope.mark_failure(String(result.get("error", result.get("reason", "request_failed"))), _get_retry_delay_msec(envelope.attempt_count))
		request_failed.emit(envelope, result)
		if envelope.is_exhausted():
			if queue_index >= 0:
				_queue.remove_at(queue_index)
				index = queue_index
			else:
				index = mini(index, _queue.size())
			_store_failed_request(envelope)
			continue
		if queue_index >= 0:
			index = queue_index + 1
		else:
			index = mini(index, _queue.size())

	report["pending"] = _queue.size()
	report["failed_stored"] = _failed_requests.size()
	_is_replaying = false
	_persist_and_emit_changed()
	return report


## 移除指定请求。
## @param request_id: 请求标识。
## @return 移除成功返回 true。
func remove_request(request_id: StringName) -> bool:
	for index: int in range(_queue.size()):
		if _queue[index].request_id == request_id:
			_queue.remove_at(index)
			_persist_and_emit_changed()
			return true
	return false


## 清空等待队列。
func clear_queue() -> void:
	_queue.clear()
	_persist_and_emit_changed()


## 清空失败请求列表。
func clear_failed_requests() -> void:
	_failed_requests.clear()
	_persist_and_emit_changed()


## 获取等待队列长度。
## @return 队列长度。
func get_queue_size() -> int:
	return _queue.size()


## 获取失败请求数量。
## @return 失败请求数量。
func get_failed_request_count() -> int:
	return _failed_requests.size()


## 获取等待请求副本。
## @return 请求副本数组。
func get_pending_requests() -> Array[GFRequestEnvelopeBase]:
	var result: Array[GFRequestEnvelopeBase] = []
	for envelope: GFRequestEnvelopeBase in _queue:
		result.append(envelope.duplicate_request() as GFRequestEnvelopeBase)
	return result


## 获取失败请求副本。
## @return 失败请求副本数组。
func get_failed_requests() -> Array[GFRequestEnvelopeBase]:
	var result: Array[GFRequestEnvelopeBase] = []
	for envelope: GFRequestEnvelopeBase in _failed_requests:
		result.append(envelope.duplicate_request() as GFRequestEnvelopeBase)
	return result


## 保存队列到 storage_path。
## @return Godot 错误码。
func save_queue() -> Error:
	if storage_path.is_empty():
		return ERR_INVALID_PARAMETER

	var base_dir := storage_path.get_base_dir()
	if not base_dir.is_empty() and base_dir != "user://":
		var dir_error := DirAccess.make_dir_recursive_absolute(base_dir)
		if dir_error != OK:
			return dir_error

	var file := FileAccess.open(storage_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	var data := GFVariantJsonCodec.variant_to_json_compatible(_to_storage_dict())
	file.store_string(JSON.stringify(data, "\t"))
	var error := file.get_error()
	file.close()
	return error


## 从 storage_path 读取队列。
## @return Godot 错误码。
func load_queue() -> Error:
	_queue.clear()
	_failed_requests.clear()
	if storage_path.is_empty() or not FileAccess.file_exists(storage_path):
		queue_changed.emit(get_debug_snapshot())
		return OK

	var file := FileAccess.open(storage_path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()

	var text := file.get_as_text()
	var error := file.get_error()
	file.close()
	if error != OK:
		return error

	var parsed: Variant = JSON.parse_string(text)
	var data_value: Variant = GFVariantJsonCodec.json_compatible_to_variant(parsed)
	if not (data_value is Dictionary):
		return ERR_PARSE_ERROR

	_apply_storage_dict(data_value as Dictionary)
	queue_changed.emit(get_debug_snapshot())
	return OK


## 获取调试快照。
## @return 调试快照。
func get_debug_snapshot() -> Dictionary:
	return {
		"storage_path": storage_path,
		"auto_persist": auto_persist,
		"max_queue_size": max_queue_size,
		"default_max_attempts": default_max_attempts,
		"pending_count": _queue.size(),
		"failed_count": _failed_requests.size(),
		"has_transport": transport_callback.is_valid(),
		"pending_request_ids": _get_request_ids(_queue),
		"failed_request_ids": _get_request_ids(_failed_requests),
	}


# --- 私有/辅助方法 ---

func _can_replay_envelope(envelope: GFRequestEnvelopeBase, now_msec: int) -> bool:
	if envelope == null or not envelope.can_attempt(now_msec):
		return false
	if replay_filter.is_valid():
		return bool(replay_filter.call(envelope))
	return true


func _call_transport(envelope: GFRequestEnvelopeBase) -> Dictionary:
	var value: Variant = transport_callback.call(envelope)
	if value is Signal:
		value = await (value as Signal)
	return _normalize_transport_result(value)


func _normalize_transport_result(value: Variant) -> Dictionary:
	if value is Array:
		var values := value as Array
		if values.is_empty():
			return { "ok": false, "error": "empty_transport_result" }
		var result := _normalize_transport_result(values[0])
		if values.size() > 1:
			result["signal_args"] = GFVariantData.duplicate_variant(values)
		return result
	if value is Dictionary:
		var result := GFVariantData.duplicate_variant(value) as Dictionary
		if not result.has("ok") and result.has("success"):
			result["ok"] = bool(result["success"])
		return result
	if value is bool:
		return { "ok": bool(value) }
	if value is int:
		var error := int(value)
		return { "ok": error == OK, "error_code": error, "error": error_string(error) }
	return { "ok": value != null }


func _is_success_result(result: Dictionary) -> bool:
	if result.has("ok"):
		return bool(result["ok"])
	if result.has("success"):
		return bool(result["success"])
	return false


func _find_queue_index(envelope: GFRequestEnvelopeBase) -> int:
	for index: int in range(_queue.size()):
		if _queue[index] == envelope:
			return index
	return -1


func _get_retry_delay_msec(attempt_count: int) -> int:
	if retry_delays_msec.is_empty():
		return 0
	var index := clampi(attempt_count - 1, 0, retry_delays_msec.size() - 1)
	return maxi(retry_delays_msec[index], 0)


func _store_failed_request(envelope: GFRequestEnvelopeBase) -> void:
	if not keep_failed_requests or max_failed_requests <= 0:
		return
	_failed_requests.append(envelope)
	while _failed_requests.size() > max_failed_requests:
		_failed_requests.pop_front()


func _persist_and_emit_changed() -> void:
	if auto_persist:
		save_queue()
	queue_changed.emit(get_debug_snapshot())


func _to_storage_dict() -> Dictionary:
	var pending: Array[Dictionary] = []
	for envelope: GFRequestEnvelopeBase in _queue:
		pending.append(envelope.to_dict(true))

	var failed: Array[Dictionary] = []
	for envelope: GFRequestEnvelopeBase in _failed_requests:
		failed.append(envelope.to_dict(true))

	return {
		"version": 1,
		"pending": pending,
		"failed": failed,
	}


func _apply_storage_dict(data: Dictionary) -> void:
	for entry_value: Variant in data.get("pending", []):
		if entry_value is Dictionary:
			var envelope := GFRequestEnvelopeBase.from_dict(entry_value as Dictionary) as GFRequestEnvelopeBase
			if envelope.is_valid():
				_queue.append(envelope)

	for entry_value: Variant in data.get("failed", []):
		if entry_value is Dictionary:
			var envelope := GFRequestEnvelopeBase.from_dict(entry_value as Dictionary) as GFRequestEnvelopeBase
			if envelope.is_valid():
				_failed_requests.append(envelope)


func _get_request_ids(requests: Array[GFRequestEnvelopeBase]) -> PackedStringArray:
	var result := PackedStringArray()
	for envelope: GFRequestEnvelopeBase in requests:
		result.append(String(envelope.request_id))
	return result


func _generate_request_id() -> String:
	return "req_%d_%d" % [Time.get_unix_time_from_system(), randi()]
