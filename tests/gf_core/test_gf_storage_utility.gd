## 测试 GFStorageUtility 的读写、加密与失败回滚行为。
extends GutTest


var _storage: GFStorageUtility


class FaultyStorageUtility extends GFStorageUtility:
	var fail_on_file_name: String = ""

	func _write_json(file_name: String, data: Dictionary) -> Error:
		if file_name == fail_on_file_name:
			return ERR_FILE_CANT_WRITE
		return super._write_json(file_name, data)


func _cleanup_file_family(file_name: String) -> void:
	for suffix: String in ["", ".tmp", ".bak", ".txn"]:
		var path := _storage._get_full_path(file_name + suffix)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func before_each() -> void:
	_storage = GFStorageUtility.new()
	_storage.save_dir_name = "test_saves"
	_storage.init()


func after_each() -> void:
	if _storage != null:
		for i in range(10):
			_storage.delete_slot(i)
			_cleanup_file_family(_storage._get_data_filename(i))
			_cleanup_file_family(_storage._get_meta_filename(i))

		for file_name: String in [
			"test_legacy.json",
			"test_integrity.json",
			"test_checksum_only.json",
			"test_legacy_version.json",
			"test_async.json",
			"recover_from_backup.json",
			"recover_from_temp.json",
			"recover_from_stale_temp.json",
			"queued_async.json",
			"escape.json",
			"nested/test_nested.json",
		]:
			_cleanup_file_family(file_name)

		_cleanup_file_family("test_resource.tres")
		var nested_dir := _storage._get_full_path("nested")
		if DirAccess.dir_exists_absolute(nested_dir):
			DirAccess.remove_absolute(nested_dir)

		_storage = null


func test_save_and_load_slot() -> void:
	_storage.encrypt_key = 0
	var data := {"hp": 100, "name": "Hero"}
	var meta := {"level": 10, "time": "2023-01-01"}

	assert_eq(_storage.save_slot(1, data, meta), OK, "保存槽位 1 应成功。")
	assert_true(_storage.has_slot(1), "槽位 1 应存在。")

	var loaded_meta := _storage.load_slot_meta(1)
	assert_eq(int(loaded_meta.get("level")), 10, "读取的元数据应与保存值一致。")

	var loaded_data := _storage.load_slot(1)
	assert_eq(loaded_data.get("name"), "Hero", "读取的核心数据应与保存值一致。")


func test_encryption() -> void:
	_storage.encrypt_key = 42
	var data := {"secret": "confidential_data"}
	_storage.save_slot(2, data)

	var raw_content := FileAccess.get_file_as_string(_storage._get_full_path(_storage._get_data_filename(2)))
	assert_false(raw_content.contains("confidential_data"), "开启混淆后，文件内容不应包含明文。")

	var loaded := _storage.load_slot(2)
	assert_eq(loaded.get("secret"), "confidential_data", "读取时应正确解码并恢复原始内容。")


func test_delete_slot() -> void:
	_storage.save_slot(3, {"a": 1}, {"b": 2})
	assert_true(_storage.has_slot(3))

	_storage.delete_slot(3)
	assert_false(_storage.has_slot(3), "删除槽位后不应再存在。")


func test_list_slots_returns_valid_slots_sorted_with_metadata() -> void:
	_storage.encrypt_key = 0
	assert_eq(_storage.save_slot(7, {"value": 7}, {"name": "seven"}), OK, "应能保存槽位 7。")
	assert_eq(_storage.save_slot(2, {"value": 2}, {"name": "two"}), OK, "应能保存槽位 2。")
	assert_eq(_storage._write_json(_storage._get_meta_filename(8), {"name": "orphan"}), OK, "应能构造孤立 metadata。")

	var slots := _storage.list_slots()

	assert_eq(slots.size(), 2, "只应枚举同时存在数据与元数据的有效槽位。")
	assert_eq(int(slots[0].get("slot_id")), 2, "槽位应按 ID 升序。")
	assert_eq(int(slots[1].get("slot_id")), 7, "槽位应按 ID 升序。")
	assert_eq((slots[0].get("metadata") as Dictionary).get("name"), "two", "应包含槽位元数据。")
	assert_true(int(slots[0].get("modified_time", 0)) > 0, "应包含 metadata 修改时间。")


func test_has_slot_requires_data_and_metadata_files() -> void:
	_storage.encrypt_key = 0
	var meta_file_name := _storage._get_meta_filename(6)
	assert_eq(_storage._write_json(meta_file_name, {"level": 1}), OK, "应能构造孤立 metadata 文件。")

	assert_false(_storage.has_slot(6), "只有 metadata 没有核心数据时不应视为有效槽位。")


func test_legacy_methods() -> void:
	_storage.encrypt_key = 0
	_storage.save_data("test_legacy.json", {"old": "data"})
	var d := _storage.load_data("test_legacy.json")
	assert_eq(d.get("old"), "data", "旧版纯数据 API 仍应正常读写。")


func test_async_save_and_load_data_emit_completion_signals() -> void:
	_storage.encrypt_key = 0
	watch_signals(_storage)

	var save_error := _storage.save_data_async("test_async.json", { "coins": 123 })
	await _pump_storage_async_tasks()

	assert_eq(save_error, OK, "异步保存应成功启动。")
	assert_signal_emitted(_storage, "save_completed", "异步保存完成时应发出 save_completed。")
	assert_eq(int(_storage.load_data("test_async.json").get("coins")), 123, "异步保存后的数据应可被同步读取。")

	var load_error := _storage.load_data_async("test_async.json")
	await _pump_storage_async_tasks()

	assert_eq(load_error, OK, "异步读取应成功启动。")
	assert_signal_emitted(_storage, "load_completed", "异步读取完成时应发出 load_completed。")
	assert_true(bool(_storage.last_load_result.get("ok")), "异步读取结果应标记成功。")
	assert_eq(int((_storage.last_load_result.get("data") as Dictionary).get("coins")), 123, "异步读取应恢复保存的数据。")


func test_save_data_creates_nested_directories() -> void:
	_storage.encrypt_key = 0
	var err := _storage.save_data("nested/test_nested.json", {"value": 7})

	assert_eq(err, OK, "嵌套相对路径应自动创建目录并写入。")
	assert_true(FileAccess.file_exists(_storage._get_full_path("nested/test_nested.json")), "嵌套路径文件应存在。")
	assert_eq(int(_storage.load_data("nested/test_nested.json").get("value")), 7, "嵌套路径数据应可读取。")


func test_absolute_path_can_be_rejected_to_save_directory() -> void:
	_storage.allow_absolute_paths = false

	var path := _storage._get_full_path("C:/outside/save.json")

	assert_eq(path, "user://test_saves/save.json", "禁用绝对路径后应收敛到存档目录同名文件。")
	assert_push_error("[GFStorageUtility] 已禁用绝对路径：C:/outside/save.json")


func test_parent_directory_path_is_rebased_to_save_directory_file_name() -> void:
	var path := _storage._get_full_path("../escape.json")

	assert_eq(path, "user://test_saves/escape.json", "跨目录相对路径应收敛到存档目录内的同名文件。")
	assert_push_error("[GFStorageUtility] 已拒绝跨目录路径（file_name）：../escape.json")


func test_async_saves_to_same_file_are_serialized() -> void:
	_storage.encrypt_key = 0
	_storage.max_async_thread_count = 2

	assert_eq(_storage.save_data_async("queued_async.json", { "value": 1 }), OK, "第一次异步保存应入队。")
	assert_eq(_storage.save_data_async("queued_async.json", { "value": 2 }), OK, "同文件第二次异步保存应入队等待。")
	assert_eq(_storage.save_data_async("queued_async.json", { "value": 3 }), OK, "同文件第三次异步保存应入队等待。")

	await _pump_storage_async_tasks()

	assert_eq(int(_storage.load_data("queued_async.json").get("value")), 3, "同文件异步保存应按入队顺序串行，最终保留最后一次数据。")


func test_save_and_load_resource() -> void:
	var res := NoiseTexture2D.new()
	res.width = 128
	res.height = 128

	var file_name := "test_resource.tres"
	var err := _storage.save_resource(file_name, res)
	assert_eq(err, OK, "保存 Resource 应成功。")

	var loaded_res := _storage.load_resource(file_name) as NoiseTexture2D
	assert_not_null(loaded_res, "读取的 Resource 不应为 null。")
	if loaded_res != null:
		assert_eq(loaded_res.width, 128, "读取的 Resource 宽度应与保存值一致。")
		assert_eq(loaded_res.height, 128, "读取的 Resource 高度应与保存值一致。")


func test_save_slot_removes_orphaned_data_when_meta_write_fails() -> void:
	_storage = FaultyStorageUtility.new()
	_storage.save_dir_name = "test_saves"
	_storage.init()
	_storage.fail_on_file_name = _storage._get_temp_filename(_storage._get_meta_filename(4))

	var err := _storage.save_slot(4, {"hp": 1}, {"level": 1})
	var data_path := _storage._get_full_path(_storage._get_data_filename(4))

	assert_ne(err, OK, "元数据写入失败时应返回错误码。")
	assert_false(_storage.has_slot(4), "元数据失败后不应留下假阳性的槽位。")
	assert_false(FileAccess.file_exists(data_path), "新建槽位失败时应清理已写入的核心数据文件。")


func test_save_slot_preserves_existing_files_when_overwrite_meta_write_fails() -> void:
	_storage.encrypt_key = 0
	assert_eq(_storage.save_slot(5, {"hp": 10}, {"level": 1}), OK, "预置旧槽位应成功。")

	_storage = FaultyStorageUtility.new()
	_storage.save_dir_name = "test_saves"
	_storage.encrypt_key = 0
	_storage.init()
	_storage.fail_on_file_name = _storage._get_temp_filename(_storage._get_meta_filename(5))

	var err := _storage.save_slot(5, {"hp": 999}, {"level": 9})

	assert_ne(err, OK, "覆盖槽位时 metadata 写失败应返回错误码。")
	assert_eq(int(_storage.load_slot(5).get("hp")), 10, "覆盖失败后应保留旧的核心数据。")
	assert_eq(int(_storage.load_slot_meta(5).get("level")), 1, "覆盖失败后应保留旧的元数据。")


func test_slot_transaction_recovery_rolls_back_partial_group_commit() -> void:
	_storage.encrypt_key = 0
	assert_eq(_storage.save_slot(9, {"hp": 10}, {"level": 1}), OK, "预置旧槽位应成功。")

	var data_file_name := _storage._get_data_filename(9)
	var meta_file_name := _storage._get_meta_filename(9)
	var file_names: Array[String] = [data_file_name, meta_file_name]
	assert_eq(_storage._write_transaction_markers(file_names, false), OK, "应能构造未完成事务标记。")

	assert_eq(
		DirAccess.rename_absolute(_storage._get_full_path(data_file_name), _storage._get_full_path(_storage._get_backup_filename(data_file_name))),
		OK,
		"应能模拟核心数据备份。",
	)
	assert_eq(
		DirAccess.rename_absolute(_storage._get_full_path(meta_file_name), _storage._get_full_path(_storage._get_backup_filename(meta_file_name))),
		OK,
		"应能模拟元数据备份。",
	)
	assert_eq(_storage._write_json(_storage._get_temp_filename(data_file_name), {"hp": 999}), OK, "应能构造新核心数据临时文件。")
	assert_eq(_storage._write_json(_storage._get_temp_filename(meta_file_name), {"level": 9}), OK, "应能构造新元数据临时文件。")
	assert_eq(
		DirAccess.rename_absolute(_storage._get_full_path(_storage._get_temp_filename(data_file_name)), _storage._get_full_path(data_file_name)),
		OK,
		"应能模拟只提交了核心数据。",
	)

	assert_true(_storage.has_slot(9), "恢复后旧槽位仍应有效。")
	assert_eq(int(_storage.load_slot(9).get("hp")), 10, "未完成事务恢复后应回滚核心数据。")
	assert_eq(int(_storage.load_slot_meta(9).get("level")), 1, "未完成事务恢复后应回滚元数据。")


func test_load_data_restores_backup_when_primary_file_is_missing() -> void:
	_storage.encrypt_key = 0
	var file_name := "recover_from_backup.json"
	var backup_file_name := _storage._get_backup_filename(file_name)
	assert_eq(_storage._write_json(backup_file_name, {"hp": 77}), OK, "应能预先写入备份文件。")

	var loaded := _storage.load_data(file_name)
	var final_path := _storage._get_full_path(file_name)
	var backup_path := _storage._get_full_path(backup_file_name)

	assert_eq(int(loaded.get("hp")), 77, "主文件缺失但存在备份时，应自动恢复最近一次已提交的数据。")
	assert_true(FileAccess.file_exists(final_path), "恢复后应重新生成主文件。")
	assert_false(FileAccess.file_exists(backup_path), "恢复完成后不应残留备份文件。")


func test_load_data_promotes_temp_file_when_no_committed_file_exists() -> void:
	_storage.encrypt_key = 0
	var file_name := "recover_from_temp.json"
	var temp_file_name := _storage._get_temp_filename(file_name)
	assert_eq(_storage._write_json(temp_file_name, {"hp": 88}), OK, "应能预先写入临时文件。")

	var loaded := _storage.load_data(file_name)
	var final_path := _storage._get_full_path(file_name)
	var temp_path := _storage._get_full_path(temp_file_name)

	assert_eq(int(loaded.get("hp")), 88, "仅存在临时文件时，应自动提升为正式文件。")
	assert_true(FileAccess.file_exists(final_path), "恢复后应生成主文件。")
	assert_false(FileAccess.file_exists(temp_path), "恢复完成后不应残留临时文件。")


func test_load_data_discards_stale_temp_when_primary_file_already_exists() -> void:
	_storage.encrypt_key = 0
	var file_name := "recover_from_stale_temp.json"
	var temp_file_name := _storage._get_temp_filename(file_name)
	assert_eq(_storage._write_json(file_name, {"hp": 11}), OK, "应能预先写入主文件。")
	assert_eq(_storage._write_json(temp_file_name, {"hp": 99}), OK, "应能预先写入悬挂临时文件。")

	var loaded := _storage.load_data(file_name)
	var temp_path := _storage._get_full_path(temp_file_name)

	assert_eq(int(loaded.get("hp")), 11, "已有主文件时，应优先保留已提交数据。")
	assert_false(FileAccess.file_exists(temp_path), "恢复完成后应清理悬挂临时文件。")


func test_integrity_checksum_rejects_tampered_data() -> void:
	_storage.encrypt_key = 0
	_storage.include_storage_metadata = true
	_storage.use_integrity_checksum = true
	_storage.strict_integrity = true
	var file_name := "test_integrity.json"
	assert_eq(_storage.save_data(file_name, { "coins": 10 }), OK, "应能保存带 checksum 的数据。")

	var path := _storage._get_full_path(file_name)
	var content := FileAccess.get_file_as_string(path)
	var tampered := JSON.parse_string(content) as Dictionary
	tampered["coins"] = 99
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(tampered))
	file.close()
	watch_signals(_storage)

	var loaded := _storage.load_data(file_name)

	assert_true(loaded.is_empty(), "严格校验失败时不应返回被篡改数据。")
	assert_signal_emitted(_storage, "data_integrity_failed", "校验失败应发出信号。")


func test_checksum_without_storage_metadata_does_not_write_version() -> void:
	_storage.encrypt_key = 0
	_storage.include_storage_metadata = false
	_storage.use_integrity_checksum = true
	var file_name := "test_checksum_only.json"

	assert_eq(_storage.save_data(file_name, { "coins": 10 }), OK, "应能保存只带 checksum 的数据。")
	var loaded := _storage.load_data(file_name)
	var metadata := loaded.get("_meta") as Dictionary

	assert_eq(int(loaded.get("coins")), 10, "只启用 checksum 时应能正常读取。")
	assert_true(metadata.has("checksum"), "只启用 checksum 时仍应写入 checksum。")
	assert_false(metadata.has("version"), "未启用 include_storage_metadata 时不应写入 version。")
	assert_false(metadata.has("timestamp"), "未启用 include_storage_metadata 时不应写入 timestamp。")


func test_load_data_result_reports_missing_file() -> void:
	var result := _storage.load_data_result("missing_result.json")

	assert_false(bool(result.get("ok")), "缺失文件的结构化读取结果应标记失败。")
	assert_eq(String(result.get("error")), "File not found", "缺失文件应返回明确错误。")


func test_load_data_applies_version_defaults() -> void:
	_storage.encrypt_key = 0
	_storage.save_version = 2
	_storage.default_values_for_new_keys = {
		"stats": {
			"hp": 100,
		},
		"unlocked": true,
	}
	var file_name := "test_legacy_version.json"
	var legacy_data := {
		"_meta": {
			"version": 1,
		},
		"stats": {},
	}
	var codec := GFStorageCodec.new()
	var file := FileAccess.open(_storage._get_full_path(file_name), FileAccess.WRITE)
	file.store_buffer(codec.encode(legacy_data, { "obfuscation_key": 0 }))
	file.close()
	watch_signals(_storage)

	var loaded := _storage.load_data(file_name)
	var metadata := loaded.get("_meta") as Dictionary
	var stats := loaded.get("stats") as Dictionary

	assert_eq(int(metadata.get("version")), 2, "迁移后版本应更新为当前 save_version。")
	assert_eq(int(stats.get("hp")), 100, "迁移时应深合并新增默认字段。")
	assert_eq(loaded.get("unlocked"), true, "迁移时应补齐顶层新增默认字段。")
	assert_signal_emitted(_storage, "data_migrated", "旧版本数据迁移后应发出信号。")


func _pump_storage_async_tasks() -> void:
	for _i in range(120):
		_storage.tick(0.0)
		if _storage._async_tasks.is_empty() and _storage._async_queue.is_empty():
			return
		await get_tree().process_frame
