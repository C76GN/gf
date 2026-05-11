## 测试 GFStorageSyncUtility 的后端同步、冲突解析和写回行为。
extends GutTest


const GFStorageSyncUtilityBase = preload("res://addons/gf/standard/utilities/storage/gf_storage_sync_utility.gd")


class MemoryStorageBackend extends GFStorageBackend:
	var records: Dictionary = {}
	var fail_on_save: bool = false

	func set_record(file_name: String, data: Dictionary, metadata: Dictionary = {}) -> void:
		records[file_name] = {
			"data": data.duplicate(true),
			"metadata": metadata.duplicate(true),
		}

	func _save_data(file_name: String, data: Dictionary, metadata: Dictionary) -> Error:
		if fail_on_save:
			return ERR_FILE_CANT_WRITE
		set_record(file_name, data, metadata)
		return OK

	func _load_data(file_name: String) -> Dictionary:
		if not records.has(file_name):
			return {
				"ok": false,
				"data": {},
				"metadata": {},
				"error": "missing",
			}

		var record := records[file_name] as Dictionary
		return {
			"ok": true,
			"data": (record.get("data", {}) as Dictionary).duplicate(true),
			"metadata": (record.get("metadata", {}) as Dictionary).duplicate(true),
			"error": "",
		}

	func _has_data(file_name: String) -> bool:
		return records.has(file_name)

	func _list_data() -> Array[Dictionary]:
		var result: Array[Dictionary] = []
		for file_name: String in records.keys():
			result.append({
				"file_name": file_name,
				"metadata": (records[file_name].get("metadata", {}) as Dictionary).duplicate(true),
			})
		return result

	func _get_capabilities() -> Dictionary:
		return {
			"read": true,
			"write": true,
			"delete": false,
			"list": true,
			"sync": true,
		}


func test_missing_remote_is_filled_from_local() -> void:
	var sync := GFStorageSyncUtilityBase.new()
	var local := MemoryStorageBackend.new()
	var remote := MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 }, { "timestamp_unix": 100 })

	var result := sync.sync_data("profile.json", local, remote)
	var remote_result := remote.load_data("profile.json")

	assert_true(bool(result.get("ok")), "缺失远端时同步应成功。")
	assert_eq(result.get("status"), GFStorageSyncUtilityBase.SyncStatus.COPIED_LOCAL_TO_REMOTE, "应报告 local -> remote 写回。")
	assert_eq(int((remote_result.get("data") as Dictionary).get("coins")), 10, "远端应获得本地数据。")
	assert_has(result.get("written_backends") as Array, "remote", "结果应记录写回的后端。")


func test_newer_remote_metadata_wins_default_strategy() -> void:
	var sync := GFStorageSyncUtilityBase.new()
	var local := MemoryStorageBackend.new()
	var remote := MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 }, { "timestamp_unix": 100 })
	remote.set_record("profile.json", { "coins": 20 }, { "timestamp_unix": 200 })

	var result := sync.sync_data("profile.json", local, remote)
	var local_result := local.load_data("profile.json")

	assert_true(bool(result.get("ok")), "默认 USE_NEWEST 应能处理有时间戳的冲突。")
	assert_eq(result.get("selected_source"), &"remote", "时间戳更新的远端应成为来源。")
	assert_eq(result.get("status"), GFStorageSyncUtilityBase.SyncStatus.COPIED_REMOTE_TO_LOCAL, "应报告 remote -> local 写回。")
	assert_eq(int((local_result.get("data") as Dictionary).get("coins")), 20, "本地应被更新为远端数据。")


func test_unordered_conflict_is_reported_without_write() -> void:
	var sync := GFStorageSyncUtilityBase.new()
	var local := MemoryStorageBackend.new()
	var remote := MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 })
	remote.set_record("profile.json", { "coins": 20 })
	watch_signals(sync)

	var result := sync.sync_data("profile.json", local, remote)

	assert_false(bool(result.get("ok")), "无法判断新旧时不应自动解决冲突。")
	assert_eq(result.get("status"), GFStorageSyncUtilityBase.SyncStatus.CONFLICT, "结果应标记为冲突。")
	assert_eq((result.get("conflicts") as Array).size(), 1, "应返回冲突报告。")
	assert_eq(int((local.load_data("profile.json").get("data") as Dictionary).get("coins")), 10, "本地不应被改写。")
	assert_eq(int((remote.load_data("profile.json").get("data") as Dictionary).get("coins")), 20, "远端不应被改写。")
	assert_signal_emitted(sync, "sync_conflict_detected", "检测冲突时应发出信号。")


func test_explicit_local_strategy_resolves_conflict() -> void:
	var sync := GFStorageSyncUtilityBase.new()
	var local := MemoryStorageBackend.new()
	var remote := MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 })
	remote.set_record("profile.json", { "coins": 20 })

	var result := sync.sync_data("profile.json", local, remote, {
		"strategy": GFStorageSyncUtilityBase.ConflictStrategy.USE_LOCAL,
	})

	assert_true(bool(result.get("ok")), "显式 USE_LOCAL 应解决冲突。")
	assert_eq(result.get("selected_source"), &"local", "来源应为本地。")
	assert_eq(int((remote.load_data("profile.json").get("data") as Dictionary).get("coins")), 10, "远端应被本地数据覆盖。")


func test_custom_resolver_can_merge_and_write_both_sides() -> void:
	var sync := GFStorageSyncUtilityBase.new()
	var local := MemoryStorageBackend.new()
	var remote := MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 }, { "timestamp_unix": 100 })
	remote.set_record("profile.json", { "coins": 20 }, { "timestamp_unix": 200 })

	var result := sync.sync_data("profile.json", local, remote, {
		"strategy": GFStorageSyncUtilityBase.ConflictStrategy.CUSTOM,
		"resolver": func(_report: GFStorageConflictReport, local_record: Dictionary, remote_record: Dictionary, _options: Dictionary) -> Dictionary:
			var local_data := local_record.get("data", {}) as Dictionary
			var remote_data := remote_record.get("data", {}) as Dictionary
			return {
				"data": {
					"coins": int(local_data.get("coins", 0)) + int(remote_data.get("coins", 0)),
				},
				"metadata": {
					"timestamp_unix": 300,
				},
				"resolution": GFStorageConflictReport.Resolution.MERGED,
			}
	})

	assert_true(bool(result.get("ok")), "自定义 resolver 应能合并冲突。")
	assert_eq(result.get("status"), GFStorageSyncUtilityBase.SyncStatus.MERGED, "自定义结果应报告 merged。")
	assert_eq(int((local.load_data("profile.json").get("data") as Dictionary).get("coins")), 30, "本地应写入合并结果。")
	assert_eq(int((remote.load_data("profile.json").get("data") as Dictionary).get("coins")), 30, "远端应写入合并结果。")


func test_backend_write_failure_is_reported() -> void:
	var sync := GFStorageSyncUtilityBase.new()
	var local := MemoryStorageBackend.new()
	var remote := MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 })
	remote.fail_on_save = true
	watch_signals(sync)

	var result := sync.sync_data("profile.json", local, remote)

	assert_false(bool(result.get("ok")), "后端写入失败时同步应失败。")
	assert_eq(result.get("status"), GFStorageSyncUtilityBase.SyncStatus.FAILED, "结果应标记为失败。")
	assert_true((result.get("errors") as Dictionary).has(&"remote"), "应记录失败后端。")
	assert_signal_emitted(sync, "sync_failed", "同步失败时应发出信号。")


func test_sync_many_returns_status_counts() -> void:
	var sync := GFStorageSyncUtilityBase.new()
	var local := MemoryStorageBackend.new()
	var remote := MemoryStorageBackend.new()
	local.set_record("a.json", { "value": 1 })
	local.set_record("b.json", { "value": 2 })
	remote.set_record("b.json", { "value": 2 })

	var result := sync.sync_many(PackedStringArray(["a.json", "b.json"]), local, remote)
	var counts := result.get("status_counts") as Dictionary

	assert_true(bool(result.get("ok")), "批量同步应整体成功。")
	assert_eq(int(counts.get("copied_local_to_remote", 0)), 1, "应统计复制项。")
	assert_eq(int(counts.get("unchanged", 0)), 1, "应统计未变化项。")
