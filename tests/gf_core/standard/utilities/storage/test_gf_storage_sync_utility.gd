## 测试 GFStorageSyncUtility 的后端同步、冲突解析和写回行为。
extends GutTest


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

		var record: Dictionary = GFVariantData.get_option_dictionary(records, file_name)
		return {
			"ok": true,
			"data": GFVariantData.get_option_dictionary(record, "data"),
			"metadata": GFVariantData.get_option_dictionary(record, "metadata"),
			"error": "",
		}

	func _has_data(file_name: String) -> bool:
		return records.has(file_name)

	func _list_data() -> Array[Dictionary]:
		var result: Array[Dictionary] = []
		for file_name: String in records.keys():
			var record: Dictionary = GFVariantData.get_option_dictionary(records, file_name)
			result.append({
				"file_name": file_name,
				"metadata": GFVariantData.get_option_dictionary(record, "metadata"),
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
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 }, { "timestamp_unix": 100 })

	var result: Dictionary = sync.sync_data("profile.json", local, remote)
	var remote_result: Dictionary = remote.load_data("profile.json")
	var remote_data: Dictionary = GFVariantData.get_option_dictionary(remote_result, "data")

	assert_true(GFVariantData.get_option_bool(result, "ok"), "缺失远端时同步应成功。")
	assert_eq(GFVariantData.get_option_int(result, "status"), GFStorageSyncUtility.SyncStatus.COPIED_LOCAL_TO_REMOTE, "应报告 local -> remote 写回。")
	assert_eq(GFVariantData.get_option_int(remote_data, "coins"), 10, "远端应获得本地数据。")
	assert_has(GFVariantData.get_option_array(result, "written_backends"), "remote", "结果应记录写回的后端。")


func test_newer_remote_metadata_wins_default_strategy() -> void:
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 }, { "timestamp_unix": 100 })
	remote.set_record("profile.json", { "coins": 20 }, { "timestamp_unix": 200 })

	var result: Dictionary = sync.sync_data("profile.json", local, remote)
	var local_result: Dictionary = local.load_data("profile.json")
	var local_data: Dictionary = GFVariantData.get_option_dictionary(local_result, "data")

	assert_true(GFVariantData.get_option_bool(result, "ok"), "默认 USE_NEWEST 应能处理有时间戳的冲突。")
	assert_eq(GFVariantData.get_option_string_name(result, "selected_source"), &"remote", "时间戳更新的远端应成为来源。")
	assert_eq(GFVariantData.get_option_int(result, "status"), GFStorageSyncUtility.SyncStatus.COPIED_REMOTE_TO_LOCAL, "应报告 remote -> local 写回。")
	assert_eq(GFVariantData.get_option_int(local_data, "coins"), 20, "本地应被更新为远端数据。")


func test_custom_revision_keys_accept_string_name_options() -> void:
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 }, { "build": 1 })
	remote.set_record("profile.json", { "coins": 20 }, { "build": 2 })
	var options: Dictionary = {}
	options[&"revision_keys"] = PackedStringArray(["build"])

	var result: Dictionary = sync.sync_data("profile.json", local, remote, options)

	assert_true(GFVariantData.get_option_bool(result, "ok"), "自定义 revision_keys 使用 StringName 键时仍应参与新旧判断。")
	assert_eq(GFVariantData.get_option_string_name(result, "selected_source"), &"remote", "自定义 revision key 更新的一侧应成为来源。")


func test_non_numeric_metadata_comparison_uses_safe_text_conversion() -> void:
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 }, { "revision": false })
	remote.set_record("profile.json", { "coins": 20 }, { "revision": true })

	var result: Dictionary = sync.sync_data("profile.json", local, remote)

	assert_true(GFVariantData.get_option_bool(result, "ok"), "非数字元数据也应能稳定比较。")
	assert_eq(GFVariantData.get_option_string_name(result, "selected_source"), &"remote", "文本比较后较新的远端应成为来源。")


func test_unordered_conflict_is_reported_without_write() -> void:
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 })
	remote.set_record("profile.json", { "coins": 20 })
	watch_signals(sync)

	var result: Dictionary = sync.sync_data("profile.json", local, remote)
	var local_data: Dictionary = GFVariantData.get_option_dictionary(local.load_data("profile.json"), "data")
	var remote_data: Dictionary = GFVariantData.get_option_dictionary(remote.load_data("profile.json"), "data")

	assert_false(GFVariantData.get_option_bool(result, "ok"), "无法判断新旧时不应自动解决冲突。")
	assert_eq(GFVariantData.get_option_int(result, "status"), GFStorageSyncUtility.SyncStatus.CONFLICT, "结果应标记为冲突。")
	assert_eq(GFVariantData.get_option_array(result, "conflicts").size(), 1, "应返回冲突报告。")
	assert_eq(GFVariantData.get_option_int(local_data, "coins"), 10, "本地不应被改写。")
	assert_eq(GFVariantData.get_option_int(remote_data, "coins"), 20, "远端不应被改写。")
	assert_signal_emitted(sync, "sync_conflict_detected", "检测冲突时应发出信号。")
	assert_signal_emitted(sync, "sync_conflict_unresolved", "未解决冲突应以独立终止信号报告。")
	assert_signal_not_emitted(sync, "sync_completed", "未解决冲突不应伪装成同步完成。")
	assert_signal_not_emitted(sync, "sync_failed", "未解决冲突不应伪装成后端失败。")


func test_explicit_local_strategy_resolves_conflict() -> void:
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 })
	remote.set_record("profile.json", { "coins": 20 })

	var result: Dictionary = sync.sync_data("profile.json", local, remote, {
		"strategy": GFStorageSyncUtility.ConflictStrategy.USE_LOCAL,
	})
	var remote_data: Dictionary = GFVariantData.get_option_dictionary(remote.load_data("profile.json"), "data")

	assert_true(GFVariantData.get_option_bool(result, "ok"), "显式 USE_LOCAL 应解决冲突。")
	assert_eq(GFVariantData.get_option_string_name(result, "selected_source"), &"local", "来源应为本地。")
	assert_eq(GFVariantData.get_option_int(remote_data, "coins"), 10, "远端应被本地数据覆盖。")


func test_custom_resolver_can_merge_and_write_both_sides() -> void:
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 }, { "timestamp_unix": 100 })
	remote.set_record("profile.json", { "coins": 20 }, { "timestamp_unix": 200 })

	var result: Dictionary = sync.sync_data("profile.json", local, remote, {
		"strategy": GFStorageSyncUtility.ConflictStrategy.CUSTOM,
		"resolver": func(_report: GFStorageConflictReport, local_record: Dictionary, remote_record: Dictionary, _options: Dictionary) -> Dictionary:
			var local_record_data: Dictionary = GFVariantData.get_option_dictionary(local_record, "data")
			var remote_record_data: Dictionary = GFVariantData.get_option_dictionary(remote_record, "data")
			return {
				"data": {
					"coins": GFVariantData.get_option_int(local_record_data, "coins") + GFVariantData.get_option_int(remote_record_data, "coins"),
				},
				"metadata": {
					"timestamp_unix": 300,
				},
				"resolution": GFStorageConflictReport.Resolution.MERGED,
			}
	})
	var local_data: Dictionary = GFVariantData.get_option_dictionary(local.load_data("profile.json"), "data")
	var remote_data: Dictionary = GFVariantData.get_option_dictionary(remote.load_data("profile.json"), "data")

	assert_true(GFVariantData.get_option_bool(result, "ok"), "自定义 resolver 应能合并冲突。")
	assert_eq(GFVariantData.get_option_int(result, "status"), GFStorageSyncUtility.SyncStatus.MERGED, "自定义结果应报告 merged。")
	assert_eq(GFVariantData.get_option_int(local_data, "coins"), 30, "本地应写入合并结果。")
	assert_eq(GFVariantData.get_option_int(remote_data, "coins"), 30, "远端应写入合并结果。")


func test_custom_resolver_options_accept_string_name_keys_and_copy_metadata() -> void:
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	var resolver_metadata: Dictionary = {
		"nested": {
			"revision": 3,
		},
	}
	local.set_record("profile.json", { "coins": 10 })
	remote.set_record("profile.json", { "coins": 20 })
	var options: Dictionary = {}
	options[&"strategy"] = GFStorageSyncUtility.ConflictStrategy.CUSTOM
	options[&"write_to_local"] = "off"
	options[&"write_to_remote"] = "on"
	options[&"resolver"] = func(
		_report: GFStorageConflictReport,
		_local_record: Dictionary,
		_remote_record: Dictionary,
		_options: Dictionary
	) -> Dictionary:
		return {
			"data": {
				"coins": 99,
			},
			"metadata": resolver_metadata,
			"resolution": GFStorageConflictReport.Resolution.MERGED,
		}

	var result: Dictionary = sync.sync_data("profile.json", local, remote, options)
	var result_metadata_value: Variant = GFVariantData.get_option_value(result, "metadata")
	assert_true(result_metadata_value is Dictionary, "同步结果应带有 metadata 字典。")
	if not (result_metadata_value is Dictionary):
		return
	var result_metadata: Dictionary = result_metadata_value
	var result_nested_value: Variant = GFVariantData.get_option_value(result_metadata, "nested")
	assert_true(result_nested_value is Dictionary, "同步结果 metadata 应保留嵌套字典。")
	if not (result_nested_value is Dictionary):
		return
	var result_nested: Dictionary = result_nested_value
	result_nested["revision"] = 100
	var local_data: Dictionary = GFVariantData.get_option_dictionary(local.load_data("profile.json"), "data")
	var remote_data: Dictionary = GFVariantData.get_option_dictionary(remote.load_data("profile.json"), "data")
	var resolver_nested: Dictionary = GFVariantData.get_option_dictionary(resolver_metadata, "nested")

	assert_true(GFVariantData.get_option_bool(result, "ok"), "自定义 resolver 应接受 StringName 选项键。")
	assert_eq(GFVariantData.get_option_int(result, "status"), GFStorageSyncUtility.SyncStatus.MERGED, "自定义结果应报告 merged。")
	assert_eq(
		GFVariantData.get_option_int(local_data, "coins"),
		10,
		"write_to_local=off 时不应写回本地。"
	)
	assert_eq(
		GFVariantData.get_option_int(remote_data, "coins"),
		99,
		"write_to_remote=on 时应写回远端。"
	)
	assert_eq(GFVariantData.get_option_int(resolver_nested, "revision"), 3, "resolver 元数据应被深拷贝。")


func test_backend_write_failure_is_reported() -> void:
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	local.set_record("profile.json", { "coins": 10 })
	remote.fail_on_save = true
	watch_signals(sync)

	var result: Dictionary = sync.sync_data("profile.json", local, remote)
	var errors: Dictionary = GFVariantData.get_option_dictionary(result, "errors")

	assert_false(GFVariantData.get_option_bool(result, "ok"), "后端写入失败时同步应失败。")
	assert_eq(GFVariantData.get_option_int(result, "status"), GFStorageSyncUtility.SyncStatus.FAILED, "结果应标记为失败。")
	assert_true(errors.has(&"remote"), "应记录失败后端。")
	assert_signal_emitted(sync, "sync_failed", "同步失败时应发出信号。")


func test_sync_many_returns_status_counts() -> void:
	var sync: GFStorageSyncUtility = GFStorageSyncUtility.new()
	var local: MemoryStorageBackend = MemoryStorageBackend.new()
	var remote: MemoryStorageBackend = MemoryStorageBackend.new()
	local.set_record("a.json", { "value": 1 })
	local.set_record("b.json", { "value": 2 })
	remote.set_record("b.json", { "value": 2 })

	var result: Dictionary = sync.sync_many(PackedStringArray(["a.json", "b.json"]), local, remote)
	var counts: Dictionary = GFVariantData.get_option_dictionary(result, "status_counts")

	assert_true(GFVariantData.get_option_bool(result, "ok"), "批量同步应整体成功。")
	assert_eq(GFVariantData.get_option_int(counts, "copied_local_to_remote"), 1, "应统计复制项。")
	assert_eq(GFVariantData.get_option_int(counts, "unchanged"), 1, "应统计未变化项。")
