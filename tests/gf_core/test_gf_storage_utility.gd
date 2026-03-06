# tests/gf_core/test_gf_storage_utility.gd
extends GutTest


var _storage: GFStorageUtility


func before_each() -> void:
	_storage = GFStorageUtility.new()
	_storage.save_dir_name = "test_saves"
	_storage.init()


func after_each() -> void:
	if _storage != null:
		for i in range(10):
			_storage.delete_slot(i)
		var path := _storage._get_full_path("test_legacy.json")
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		var res_path := _storage._get_full_path("test_resource.tres")
		if FileAccess.file_exists(res_path):
			DirAccess.remove_absolute(res_path)
		_storage = null


func test_save_and_load_slot() -> void:
	_storage.encrypt_key = 0
	var data := {"hp": 100, "name": "Hero"}
	var meta := {"level": 10, "time": "2023-01-01"}
	
	assert_eq(_storage.save_slot(1, data, meta), OK, "保存槽位 1 应该成功。")
	assert_true(_storage.has_slot(1), "槽位 1 应该存在。")
	
	var loaded_meta := _storage.load_slot_meta(1)
	assert_eq(loaded_meta.get("level"), 10, "读取的 meta 数据应该一致。")
	
	var loaded_data := _storage.load_slot(1)
	assert_eq(loaded_data.get("name"), "Hero", "读取的 data 数据应该一致。")


func test_encryption() -> void:
	_storage.encrypt_key = 42
	var data := {"secret": "confidential_data"}
	_storage.save_slot(2, data)
	
	# 验证是否真的加密了
	var raw_content := FileAccess.get_file_as_string(_storage._get_full_path(_storage._get_data_filename(2)))
	assert_false(raw_content.contains("confidential_data"), "加密后的文件中不应包含明文数据。")
	
	var loaded := _storage.load_slot(2)
	assert_eq(loaded.get("secret"), "confidential_data", "解密后的数据应恢复原始结构。")


func test_delete_slot() -> void:
	_storage.save_slot(3, {"a": 1}, {"b": 2})
	assert_true(_storage.has_slot(3))
	
	_storage.delete_slot(3)
	assert_false(_storage.has_slot(3), "删除槽位后不应再存在。")


func test_legacy_methods() -> void:
	_storage.encrypt_key = 0
	_storage.save_data("test_legacy.json", {"old": "data"})
	var d := _storage.load_data("test_legacy.json")
	assert_eq(d.get("old"), "data", "兼容旧有 API 应读写一致。")


func test_save_and_load_resource() -> void:
	var res := NoiseTexture2D.new()
	res.width = 128
	res.height = 128
	
	var file_name := "test_resource.tres"
	var err := _storage.save_resource(file_name, res)
	assert_eq(err, OK, "保存 Resource 应该成功。")
	
	var loaded_res := _storage.load_resource(file_name) as NoiseTexture2D
	assert_not_null(loaded_res, "读取的 Resource 不应为 null。")
	if loaded_res != null:
		assert_eq(loaded_res.width, 128, "读取的 Resource 属性应与保存时一致。")
		assert_eq(loaded_res.height, 128, "读取的 Resource 属性应与保存时一致。")
