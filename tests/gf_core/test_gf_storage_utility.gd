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
	for suffix: String in ["", ".tmp", ".bak"]:
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
			"recover_from_backup.json",
			"recover_from_temp.json",
			"recover_from_stale_temp.json",
		]:
			_cleanup_file_family(file_name)

		_cleanup_file_family("test_resource.tres")

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
