## GFStorageUtility: 基于 `user://` 的轻量存档系统。
##
## 支持槽位存档、元数据分离读取、`Resource` 存取，
## 以及简单的 XOR + Base64 混淆，适合通用本地持久化场景。
class_name GFStorageUtility
extends GFUtility


# --- 公共变量 ---

## 用于简单 XOR 混淆的密钥；为 `0` 时直接保存明文 JSON。
var encrypt_key: int = 42

## 保存子目录名；为空时直接写入 `user://`。
var save_dir_name: String = "saves"


# --- Godot 生命周期方法 ---

func init() -> void:
	var dir_path := "user://"
	if not save_dir_name.is_empty():
		dir_path += save_dir_name
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_recursive_absolute(dir_path)


# --- 公共方法（Resource 存取） ---

## 保存一个 `Resource` 文件。
## @param file_name: 目标文件名。
## @param resource: 要保存的资源实例。
## @return Godot 的 `Error` 结果码。
func save_resource(file_name: String, resource: Resource) -> Error:
	init()
	var path := _get_full_path(file_name)
	return ResourceSaver.save(resource, path)


## 读取一个 `Resource` 文件。
## @param file_name: 目标文件名。
## @param type_hint: 可选类型提示。
## @return 读取到的资源实例；不存在时返回 `null`。
func load_resource(file_name: String, type_hint: String = "") -> Resource:
	var path := _get_full_path(file_name)
	if not FileAccess.file_exists(path):
		return null

	return ResourceLoader.load(path, type_hint)


## 保存一个槽位存档。
## @param slot_id: 槽位 ID。
## @param data: 核心存档数据。
## @param metadata: 展示用元数据。
## @return Godot 的 `Error` 结果码。
func save_slot(slot_id: int, data: Dictionary, metadata: Dictionary = {}) -> Error:
	var data_file_name := _get_data_filename(slot_id)
	var meta_file_name := _get_meta_filename(slot_id)

	init()

	var meta_path := _get_full_path(meta_file_name)
	var had_meta_before := FileAccess.file_exists(meta_path)

	var data_error := _write_json(data_file_name, data)
	if data_error != OK:
		return data_error

	var meta_error := _write_json(meta_file_name, metadata)
	if meta_error != OK:
		if not had_meta_before:
			_remove_file_if_exists(_get_full_path(data_file_name))
		return meta_error

	return OK


## 读取槽位核心数据。
## @param slot_id: 槽位 ID。
## @return 反序列化后的核心数据字典。
func load_slot(slot_id: int) -> Dictionary:
	var data_file_name := _get_data_filename(slot_id)
	return _read_json(data_file_name)


## 读取槽位元数据。
## @param slot_id: 槽位 ID。
## @return 反序列化后的元数据字典。
func load_slot_meta(slot_id: int) -> Dictionary:
	var meta_file_name := _get_meta_filename(slot_id)
	return _read_json(meta_file_name)


## 检查槽位是否存在有效存档。
## @param slot_id: 槽位 ID。
## @return 元数据文件存在时返回 `true`。
func has_slot(slot_id: int) -> bool:
	var path := _get_full_path(_get_meta_filename(slot_id))
	return FileAccess.file_exists(path)


## 删除指定槽位的数据与元数据。
## @param slot_id: 槽位 ID。
func delete_slot(slot_id: int) -> void:
	_remove_file_if_exists(_get_full_path(_get_data_filename(slot_id)))
	_remove_file_if_exists(_get_full_path(_get_meta_filename(slot_id)))


# --- 公共方法（纯数据存取） ---

## 保存纯字典数据。
## @param file_name: 目标文件名。
## @param data: 要保存的字典。
## @return Godot 的 `Error` 结果码。
func save_data(file_name: String, data: Dictionary) -> Error:
	init()
	return _write_json(file_name, data)


## 读取纯字典数据。
## @param file_name: 目标文件名。
## @return 反序列化后的字典数据。
func load_data(file_name: String) -> Dictionary:
	return _read_json(file_name)


# --- 私有/辅助方法 ---

func _get_data_filename(slot_id: int) -> String:
	return "slot_%d_data.sav" % slot_id


func _get_meta_filename(slot_id: int) -> String:
	return "slot_%d_meta.sav" % slot_id


func _get_full_path(file_name: String) -> String:
	if file_name.is_absolute_path():
		return file_name

	if save_dir_name.is_empty():
		return "user://" + file_name

	return "user://" + save_dir_name + "/" + file_name


func _remove_file_if_exists(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _write_json(file_name: String, data: Dictionary) -> Error:
	var path := _get_full_path(file_name)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[GFStorageUtility] 无法写入文件：%s，错误码：%s" % [path, FileAccess.get_open_error()])
		return FileAccess.get_open_error()

	var json_str := JSON.stringify(data, "\t")

	if encrypt_key != 0:
		var bytes := json_str.to_utf8_buffer()
		for i in range(bytes.size()):
			bytes[i] = bytes[i] ^ encrypt_key
		file.store_string(Marshalls.raw_to_base64(bytes))
	else:
		file.store_string(json_str)

	file.close()
	return OK


func _read_json(file_name: String) -> Dictionary:
	var path := _get_full_path(file_name)
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[GFStorageUtility] 无法读取文件：%s，错误码：%s" % [path, FileAccess.get_open_error()])
		return {}

	var content := file.get_as_text()
	file.close()

	if content.is_empty():
		return {}

	var json_str := content
	if encrypt_key != 0:
		var bytes := Marshalls.base64_to_raw(content)
		if not bytes.is_empty():
			for i in range(bytes.size()):
				bytes[i] = bytes[i] ^ encrypt_key
			json_str = bytes.get_string_from_utf8()

	var parse_result: Variant = JSON.parse_string(json_str)
	if parse_result == null:
		var fallback_result: Variant = JSON.parse_string(content)
		if fallback_result != null and typeof(fallback_result) == TYPE_DICTIONARY:
			return fallback_result as Dictionary

		push_error("[GFStorageUtility] JSON 解析失败，文件路径：%s" % path)
		return {}

	if typeof(parse_result) == TYPE_DICTIONARY:
		return parse_result as Dictionary

	return {}
