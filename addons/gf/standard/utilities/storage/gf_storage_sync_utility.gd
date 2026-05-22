## GFStorageSyncUtility: 通用存储后端同步协调器。
##
## 该工具只协调两个 GFStorageBackend 的字典数据同步、冲突检测和写回策略。
## 它不绑定本地/云/平台 SDK，也不替项目定义存档业务结构。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFStorageSyncUtility
extends GFUtility


# --- 信号 ---

## 检测到存储冲突后发出。
## [br]
## @api public
## [br]
## @param report: 冲突报告。
signal sync_conflict_detected(report: GFStorageConflictReport)

## 单个逻辑文件存在未解决冲突时发出。
## [br]
## @api public
## [br]
## @param file_name: 逻辑文件名。
## [br]
## @param result: 同步结果字典。
## [br]
## @schema result: Dictionary，由 sync_data() 为未解决冲突返回。
signal sync_conflict_unresolved(file_name: String, result: Dictionary)

## 单个逻辑文件同步完成后发出。
## [br]
## @api public
## [br]
## @param file_name: 逻辑文件名。
## [br]
## @param result: 同步结果字典。
## [br]
## @schema result: Dictionary，由 sync_data() 为已完成同步返回。
signal sync_completed(file_name: String, result: Dictionary)

## 单个逻辑文件同步失败后发出。
## [br]
## @api public
## [br]
## @param file_name: 逻辑文件名。
## [br]
## @param result: 同步结果字典。
## [br]
## @schema result: Dictionary，由 sync_data() 为失败同步返回。
signal sync_failed(file_name: String, result: Dictionary)


# --- 枚举 ---

## 冲突解决策略。
## [br]
## @api public
enum ConflictStrategy {
	## 按后端元数据中的 revision/timestamp 选择更新的一侧；无法判断时保留冲突。
	USE_NEWEST,
	## 冲突时使用 local_backend 的数据。
	USE_LOCAL,
	## 冲突时使用 remote_backend 的数据。
	USE_REMOTE,
	## 只报告冲突，不自动写回。
	MANUAL,
	## 调用 options.resolver 或 options.resolution_callback 生成结果。
	CUSTOM,
}

## 同步结果状态。
## [br]
## @api public
enum SyncStatus {
	## 两端数据已经一致。
	UNCHANGED,
	## 已把 local_backend 数据复制到 remote_backend。
	COPIED_LOCAL_TO_REMOTE,
	## 已把 remote_backend 数据复制到 local_backend。
	COPIED_REMOTE_TO_LOCAL,
	## 已用自定义合并结果写回两端。
	MERGED,
	## 存在未解决冲突。
	CONFLICT,
	## 同步失败。
	FAILED,
}


# --- 公共变量 ---

## 默认冲突策略。
## [br]
## @api public
var default_conflict_strategy: ConflictStrategy = ConflictStrategy.USE_NEWEST

## 默认是否把解析出的结果写回后端。关闭后可用于 dry-run。
## [br]
## @api public
var write_resolved_by_default: bool = true


# --- 私有变量 ---

var _sync_count: int = 0
var _conflict_count: int = 0
var _failed_count: int = 0


# --- 公共方法 ---

## 同步一个逻辑文件。
## [br]
## @api public
## [br]
## @param file_name: 逻辑文件名。
## [br]
## @param local_backend: 本地或主后端。
## [br]
## @param remote_backend: 远端或副后端。
## [br]
## @param options: 同步选项，支持 strategy、write_resolved、write_to_local、write_to_remote、resolver、revision_keys、timestamp_keys。
## [br]
## @return 同步结果字典。
## [br]
## @schema options: Dictionary，包含 strategy: ConflictStrategy、write_resolved: bool、write_to_local: bool、write_to_remote: bool、resolver: Callable、resolution_callback: Callable、revision_keys: Array[String] 和 timestamp_keys: Array[String]。
## [br]
## @schema return: Dictionary，包含 ok、file_name、status、status_name、selected_source、written_backends、conflicts、errors、error、data、metadata、local 和 remote。
func sync_data(
	file_name: String,
	local_backend: GFStorageBackend,
	remote_backend: GFStorageBackend,
	options: Dictionary = {}
) -> Dictionary:
	var result := _make_base_result(file_name)
	if file_name.is_empty():
		return _finish_failed(result, "file_name is empty")
	if local_backend == null or remote_backend == null:
		return _finish_failed(result, "Storage backend is null.")

	var local_record := _load_record(&"local", local_backend, file_name)
	var remote_record := _load_record(&"remote", remote_backend, file_name)
	result["local"] = _summarize_record(local_record)
	result["remote"] = _summarize_record(remote_record)

	var local_ok := bool(local_record.get("ok", false))
	var remote_ok := bool(remote_record.get("ok", false))
	if not local_ok and not remote_ok:
		return _finish_failed(result, "No readable data in either backend.")
	if local_ok and not remote_ok:
		return _copy_record_to_backend(
			result,
			local_record,
			remote_backend,
			&"remote",
			SyncStatus.COPIED_LOCAL_TO_REMOTE,
			options
		)
	if remote_ok and not local_ok:
		return _copy_record_to_backend(
			result,
			remote_record,
			local_backend,
			&"local",
			SyncStatus.COPIED_REMOTE_TO_LOCAL,
			options
		)
	if _records_have_same_data(local_record, remote_record):
		result["ok"] = true
		result["status"] = SyncStatus.UNCHANGED
		result["status_name"] = _get_status_name(SyncStatus.UNCHANGED)
		result["data"] = (local_record.get("data", {}) as Dictionary).duplicate(true)
		result["metadata"] = (local_record.get("metadata", {}) as Dictionary).duplicate(true)
		return _finish_completed(result)

	return _resolve_and_write_conflict(result, local_record, remote_record, local_backend, remote_backend, options)


## 批量同步多个逻辑文件。
## [br]
## @api public
## [br]
## @param file_names: 逻辑文件名列表。
## [br]
## @param local_backend: 本地或主后端。
## [br]
## @param remote_backend: 远端或副后端。
## [br]
## @param options: 传给 sync_data() 的同步选项。
## [br]
## @return 批量结果字典。
## [br]
## @schema options: Dictionary，支持字段与 sync_data() 相同。
## [br]
## @schema return: Dictionary，包含 ok: bool、count: int、results: Array[Dictionary] 和 status_counts: Dictionary。
func sync_many(
	file_names: PackedStringArray,
	local_backend: GFStorageBackend,
	remote_backend: GFStorageBackend,
	options: Dictionary = {}
) -> Dictionary:
	var results: Array[Dictionary] = []
	var status_counts: Dictionary = {}
	var all_ok := true
	for file_name: String in file_names:
		var item_result := sync_data(file_name, local_backend, remote_backend, options)
		results.append(item_result)
		all_ok = all_ok and bool(item_result.get("ok", false))
		var status_name := String(item_result.get("status_name", "unknown"))
		status_counts[status_name] = int(status_counts.get(status_name, 0)) + 1

	return {
		"ok": all_ok,
		"count": results.size(),
		"results": results,
		"status_counts": status_counts,
	}


## 获取同步工具调试快照。
## [br]
## @api public
## [br]
## @return 调试快照字典。
## [br]
## @schema return: Dictionary，包含 sync_count、conflict_count、failed_count、default_conflict_strategy 和 write_resolved_by_default。
func get_debug_snapshot() -> Dictionary:
	return {
		"sync_count": _sync_count,
		"conflict_count": _conflict_count,
		"failed_count": _failed_count,
		"default_conflict_strategy": default_conflict_strategy,
		"write_resolved_by_default": write_resolved_by_default,
	}


# --- 私有/辅助方法 ---

func _load_record(source: StringName, backend: GFStorageBackend, file_name: String) -> Dictionary:
	var load_result := backend.load_data(file_name)
	var data_value: Variant = load_result.get("data", {})
	var metadata_value: Variant = load_result.get("metadata", {})
	var ok := bool(load_result.get("ok", false))
	var error := String(load_result.get("error", ""))
	if ok and not (data_value is Dictionary):
		ok = false
		error = "Backend returned non-Dictionary data."

	return {
		"source": source,
		"ok": ok,
		"data": (data_value as Dictionary).duplicate(true) if data_value is Dictionary else {},
		"metadata": (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {},
		"error": error,
	}


func _summarize_record(record: Dictionary) -> Dictionary:
	return {
		"source": record.get("source", &""),
		"ok": bool(record.get("ok", false)),
		"metadata": (record.get("metadata", {}) as Dictionary).duplicate(true),
		"error": String(record.get("error", "")),
	}


func _records_have_same_data(local_record: Dictionary, remote_record: Dictionary) -> bool:
	return local_record.get("data", {}) == remote_record.get("data", {})


func _resolve_and_write_conflict(
	result: Dictionary,
	local_record: Dictionary,
	remote_record: Dictionary,
	local_backend: GFStorageBackend,
	remote_backend: GFStorageBackend,
	options: Dictionary
) -> Dictionary:
	var report := _make_conflict_report(result.get("file_name", ""), local_record, remote_record)
	_conflict_count += 1
	sync_conflict_detected.emit(report)

	var resolution := _resolve_conflict(report, local_record, remote_record, options)
	var resolved_report := resolution.get("report", report) as GFStorageConflictReport
	if resolved_report != null:
		(result["conflicts"] as Array).append(resolved_report.to_dict())

	if not bool(resolution.get("ok", false)):
		result["status"] = SyncStatus.CONFLICT
		result["status_name"] = _get_status_name(SyncStatus.CONFLICT)
		result["error"] = String(resolution.get("error", "Storage conflict is unresolved."))
		return _finish_conflict(result)

	var selected_source := StringName(resolution.get("source", &"custom"))
	var data := (resolution.get("data", {}) as Dictionary).duplicate(true)
	var metadata := (resolution.get("metadata", {}) as Dictionary).duplicate(true)
	result["selected_source"] = selected_source
	result["data"] = data
	result["metadata"] = metadata

	var write_local := _should_write_to_backend(options, "write_to_local", selected_source != &"local")
	var write_remote := _should_write_to_backend(options, "write_to_remote", selected_source != &"remote")
	if selected_source == &"custom":
		write_local = _should_write_to_backend(options, "write_to_local", true)
		write_remote = _should_write_to_backend(options, "write_to_remote", true)

	if not _write_resolved_enabled(options):
		write_local = false
		write_remote = false

	if write_local:
		_write_backend(result, local_backend, &"local", data, metadata)
	if write_remote:
		_write_backend(result, remote_backend, &"remote", data, metadata)
	if not (result["errors"] as Dictionary).is_empty():
		return _finish_failed(result, "One or more backend writes failed.")

	result["ok"] = true
	if selected_source == &"local":
		result["status"] = SyncStatus.COPIED_LOCAL_TO_REMOTE
	elif selected_source == &"remote":
		result["status"] = SyncStatus.COPIED_REMOTE_TO_LOCAL
	else:
		result["status"] = SyncStatus.MERGED
	result["status_name"] = _get_status_name(int(result["status"]))
	return _finish_completed(result)


func _resolve_conflict(
	report: GFStorageConflictReport,
	local_record: Dictionary,
	remote_record: Dictionary,
	options: Dictionary
) -> Dictionary:
	var strategy := _get_strategy(options)
	match strategy:
		ConflictStrategy.USE_LOCAL:
			return _make_record_resolution(report, local_record, GFStorageConflictReport.Resolution.USE_LOCAL)
		ConflictStrategy.USE_REMOTE:
			return _make_record_resolution(report, remote_record, GFStorageConflictReport.Resolution.USE_REMOTE)
		ConflictStrategy.USE_NEWEST:
			var comparison := _compare_records(local_record, remote_record, options)
			if comparison > 0:
				return _make_record_resolution(report, local_record, GFStorageConflictReport.Resolution.USE_LOCAL)
			if comparison < 0:
				return _make_record_resolution(report, remote_record, GFStorageConflictReport.Resolution.USE_REMOTE)
			return _make_unresolved_resolution(report, "Cannot determine newest storage record.")
		ConflictStrategy.CUSTOM:
			return _resolve_with_callback(report, local_record, remote_record, options)
		_:
			return _make_unresolved_resolution(report, "Manual storage conflict resolution required.")


func _make_record_resolution(
	report: GFStorageConflictReport,
	record: Dictionary,
	resolution: GFStorageConflictReport.Resolution
) -> Dictionary:
	var data := (record.get("data", {}) as Dictionary).duplicate(true)
	var metadata := (record.get("metadata", {}) as Dictionary).duplicate(true)
	report.resolution = resolution
	report.resolved_value = data.duplicate(true)
	return {
		"ok": true,
		"source": record.get("source", &""),
		"data": data,
		"metadata": metadata,
		"report": report,
	}


func _resolve_with_callback(
	report: GFStorageConflictReport,
	local_record: Dictionary,
	remote_record: Dictionary,
	options: Dictionary
) -> Dictionary:
	var resolver := options.get("resolver", options.get("resolution_callback", Callable())) as Callable
	if resolver == null or not resolver.is_valid():
		return _make_unresolved_resolution(report, "Custom resolver is invalid.")

	var value: Variant = resolver.call(
		report.duplicate_report(),
		_make_callback_record(local_record),
		_make_callback_record(remote_record),
		options.duplicate(true)
	)
	if not (value is Dictionary):
		return _make_unresolved_resolution(report, "Custom resolver must return a Dictionary.")

	var dictionary := value as Dictionary
	var data_value: Variant = dictionary.get("data", {})
	if not (data_value is Dictionary):
		return _make_unresolved_resolution(report, "Custom resolver returned non-Dictionary data.")

	var metadata_value: Variant = dictionary.get("metadata", {})
	var data := (data_value as Dictionary).duplicate(true)
	var metadata := (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}
	report.resolution = int(dictionary.get("resolution", GFStorageConflictReport.Resolution.MERGED)) as GFStorageConflictReport.Resolution
	report.resolved_value = data.duplicate(true)
	report.metadata = metadata.duplicate(true)
	return {
		"ok": true,
		"source": &"custom",
		"data": data,
		"metadata": metadata,
		"report": report,
	}


func _make_unresolved_resolution(report: GFStorageConflictReport, error: String) -> Dictionary:
	report.resolution = GFStorageConflictReport.Resolution.UNRESOLVED
	return {
		"ok": false,
		"error": error,
		"report": report,
	}


func _make_callback_record(record: Dictionary) -> Dictionary:
	return {
		"source": record.get("source", &""),
		"data": (record.get("data", {}) as Dictionary).duplicate(true),
		"metadata": (record.get("metadata", {}) as Dictionary).duplicate(true),
	}


func _make_conflict_report(file_name: String, local_record: Dictionary, remote_record: Dictionary) -> GFStorageConflictReport:
	var report := GFStorageConflictReport.new()
	report.file_name = file_name
	report.key = ""
	report.local_value = (local_record.get("data", {}) as Dictionary).duplicate(true)
	report.remote_value = (remote_record.get("data", {}) as Dictionary).duplicate(true)
	report.metadata = {
		"local_metadata": (local_record.get("metadata", {}) as Dictionary).duplicate(true),
		"remote_metadata": (remote_record.get("metadata", {}) as Dictionary).duplicate(true),
	}
	return report


func _copy_record_to_backend(
	result: Dictionary,
	source_record: Dictionary,
	target_backend: GFStorageBackend,
	target_name: StringName,
	status: SyncStatus,
	options: Dictionary
) -> Dictionary:
	var data := (source_record.get("data", {}) as Dictionary).duplicate(true)
	var metadata := (source_record.get("metadata", {}) as Dictionary).duplicate(true)
	result["selected_source"] = source_record.get("source", &"")
	result["data"] = data
	result["metadata"] = metadata
	if _write_resolved_enabled(options):
		_write_backend(result, target_backend, target_name, data, metadata)
	if not (result["errors"] as Dictionary).is_empty():
		return _finish_failed(result, "One or more backend writes failed.")

	result["ok"] = true
	result["status"] = status
	result["status_name"] = _get_status_name(status)
	return _finish_completed(result)


func _write_backend(
	result: Dictionary,
	backend: GFStorageBackend,
	backend_name: StringName,
	data: Dictionary,
	metadata: Dictionary
) -> void:
	var error := backend.save_data(String(result.get("file_name", "")), data, metadata)
	if error == OK:
		(result["written_backends"] as Array).append(String(backend_name))
		return

	(result["errors"] as Dictionary)[backend_name] = error_string(error)


func _compare_records(local_record: Dictionary, remote_record: Dictionary, options: Dictionary) -> int:
	var revision_comparison := _compare_metadata_by_keys(
		local_record,
		remote_record,
		_get_string_array_option(options, "revision_keys", ["revision", "updated_revision", "sync_revision", "modified_revision"])
	)
	if revision_comparison != 0:
		return revision_comparison

	return _compare_metadata_by_keys(
		local_record,
		remote_record,
		_get_string_array_option(options, "timestamp_keys", ["timestamp_unix", "modified_unix", "updated_unix", "saved_unix", "modified_time", "mtime", "timestamp"])
	)


func _compare_metadata_by_keys(local_record: Dictionary, remote_record: Dictionary, keys: Array[String]) -> int:
	var local_metadata := local_record.get("metadata", {}) as Dictionary
	var remote_metadata := remote_record.get("metadata", {}) as Dictionary
	if local_metadata == null or remote_metadata == null:
		return 0

	for key: String in keys:
		if not local_metadata.has(key) or not remote_metadata.has(key):
			continue
		var comparison := _compare_metadata_values(local_metadata[key], remote_metadata[key])
		if comparison != 0:
			return comparison
	return 0


func _compare_metadata_values(left: Variant, right: Variant) -> int:
	if _is_numeric_value(left) and _is_numeric_value(right):
		var left_number := _to_float_value(left)
		var right_number := _to_float_value(right)
		if is_equal_approx(left_number, right_number):
			return 0
		return 1 if left_number > right_number else -1

	var left_text := str(left)
	var right_text := str(right)
	if left_text == right_text:
		return 0
	return 1 if left_text > right_text else -1


func _is_numeric_value(value: Variant) -> bool:
	return (
		typeof(value) == TYPE_INT
		or typeof(value) == TYPE_FLOAT
		or (value is String and (value as String).is_valid_float())
	)


func _to_float_value(value: Variant) -> float:
	if value is String:
		return (value as String).to_float()
	return float(value)


func _get_strategy(options: Dictionary) -> ConflictStrategy:
	return int(options.get("strategy", default_conflict_strategy)) as ConflictStrategy


func _write_resolved_enabled(options: Dictionary) -> bool:
	return bool(options.get("write_resolved", write_resolved_by_default))


func _should_write_to_backend(options: Dictionary, key: String, fallback: bool) -> bool:
	return bool(options.get(key, fallback))


func _get_string_array_option(options: Dictionary, key: String, fallback: Array[String]) -> Array[String]:
	var value: Variant = options.get(key, fallback)
	var result: Array[String] = []
	if value is PackedStringArray:
		for item: String in value:
			result.append(item)
		return result
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
		return result
	return fallback.duplicate()


func _make_base_result(file_name: String) -> Dictionary:
	return {
		"ok": false,
		"file_name": file_name,
		"status": SyncStatus.FAILED,
		"status_name": _get_status_name(SyncStatus.FAILED),
		"selected_source": &"",
		"written_backends": [],
		"conflicts": [],
		"errors": {},
		"error": "",
		"data": {},
		"metadata": {},
		"local": {},
		"remote": {},
	}


func _finish_completed(result: Dictionary) -> Dictionary:
	_sync_count += 1
	sync_completed.emit(String(result.get("file_name", "")), result.duplicate(true))
	return result


func _finish_failed(result: Dictionary, error: String) -> Dictionary:
	result["ok"] = false
	result["status"] = SyncStatus.FAILED
	result["status_name"] = _get_status_name(SyncStatus.FAILED)
	result["error"] = error
	_failed_count += 1
	sync_failed.emit(String(result.get("file_name", "")), result.duplicate(true))
	return result


func _finish_conflict(result: Dictionary) -> Dictionary:
	result["ok"] = false
	sync_conflict_unresolved.emit(String(result.get("file_name", "")), result.duplicate(true))
	return result


func _get_status_name(status: int) -> StringName:
	match status:
		SyncStatus.UNCHANGED:
			return &"unchanged"
		SyncStatus.COPIED_LOCAL_TO_REMOTE:
			return &"copied_local_to_remote"
		SyncStatus.COPIED_REMOTE_TO_LOCAL:
			return &"copied_remote_to_local"
		SyncStatus.MERGED:
			return &"merged"
		SyncStatus.CONFLICT:
			return &"conflict"
		_:
			return &"failed"
