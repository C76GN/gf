## GFStorageUtility: 基于 `user://` 的轻量存档系统。
##
## 支持槽位存档、元数据分离读取、`Resource` 存取，
## 以及简单的 XOR + Base64 文本混淆，适合通用本地持久化场景。
## 该混淆不提供安全加密能力，请勿用于保护敏感数据。
class_name GFStorageUtility
extends GFUtility


# --- 常量 ---

const _TEMP_SUFFIX: String = ".tmp"
const _BACKUP_SUFFIX: String = ".bak"
const _TRANSACTION_SUFFIX: String = ".txn"


# --- 公共变量 ---

## 用于简单 XOR + Base64 混淆的密钥；为 `0` 时直接保存明文 JSON。该字段不是安全加密密钥。
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
	var data_temp_file_name := _get_temp_filename(data_file_name)
	var meta_temp_file_name := _get_temp_filename(meta_file_name)

	init()
	_recover_transaction_files([data_file_name, meta_file_name])

	var data_error := _write_json(data_temp_file_name, data)
	if data_error != OK:
		_cleanup_transaction_files([data_file_name, meta_file_name])
		return data_error

	var meta_error := _write_json(meta_temp_file_name, metadata)
	if meta_error != OK:
		_cleanup_transaction_files([data_file_name, meta_file_name])
		return meta_error

	return _commit_transaction([data_file_name, meta_file_name])


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
## @return 核心数据与元数据文件都存在时返回 `true`。
func has_slot(slot_id: int) -> bool:
	_recover_transaction_files([
		_get_data_filename(slot_id),
		_get_meta_filename(slot_id),
	])

	var data_path := _get_full_path(_get_data_filename(slot_id))
	var meta_path := _get_full_path(_get_meta_filename(slot_id))
	return FileAccess.file_exists(data_path) and FileAccess.file_exists(meta_path)


## 枚举所有有效槽位。
## @return 槽位信息数组，元素包含 `slot_id`、`metadata` 与 `modified_time`。
func list_slots() -> Array[Dictionary]:
	init()
	var dir := DirAccess.open(_get_save_base_path())
	if dir == null:
		return []

	var slot_ids: Array[int] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir():
			var slot_id := _parse_slot_id_from_meta_filename(file_name)
			if slot_id >= 0 and not slot_ids.has(slot_id) and has_slot(slot_id):
				slot_ids.append(slot_id)
		file_name = dir.get_next()
	dir.list_dir_end()

	slot_ids.sort()

	var result: Array[Dictionary] = []
	for slot_id: int in slot_ids:
		var meta_path := _get_full_path(_get_meta_filename(slot_id))
		result.append({
			"slot_id": slot_id,
			"metadata": load_slot_meta(slot_id),
			"modified_time": FileAccess.get_modified_time(meta_path),
		})
	return result


## 删除指定槽位的数据与元数据。
## @param slot_id: 槽位 ID。
func delete_slot(slot_id: int) -> void:
	for file_name: String in [
		_get_data_filename(slot_id),
		_get_meta_filename(slot_id),
	]:
		_remove_file_if_exists(_get_full_path(file_name))
		_remove_file_if_exists(_get_full_path(_get_temp_filename(file_name)))
		_remove_file_if_exists(_get_full_path(_get_backup_filename(file_name)))
		_remove_file_if_exists(_get_full_path(_get_transaction_filename(file_name)))


# --- 公共方法（纯数据存取） ---

## 保存纯字典数据。
## @param file_name: 目标文件名。
## @param data: 要保存的字典。
## @return Godot 的 `Error` 结果码。
func save_data(file_name: String, data: Dictionary) -> Error:
	init()
	_recover_transaction_files([file_name])

	var temp_file_name := _get_temp_filename(file_name)
	var write_error := _write_json(temp_file_name, data)
	if write_error != OK:
		_cleanup_transaction_files([file_name])
		return write_error

	return _commit_transaction([file_name])


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


func _get_save_base_path() -> String:
	if save_dir_name.is_empty():
		return "user://"

	return "user://" + save_dir_name


func _get_full_path(file_name: String) -> String:
	if file_name.is_absolute_path():
		return file_name

	if save_dir_name.is_empty():
		return "user://" + file_name

	return "user://" + save_dir_name + "/" + file_name


func _parse_slot_id_from_meta_filename(file_name: String) -> int:
	if not file_name.begins_with("slot_") or not file_name.ends_with("_meta.sav"):
		return -1

	var id_text := file_name.trim_prefix("slot_").trim_suffix("_meta.sav")
	if not id_text.is_valid_int():
		return -1

	return id_text.to_int()


func _remove_file_if_exists(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _get_temp_filename(file_name: String) -> String:
	return file_name + _TEMP_SUFFIX


func _get_backup_filename(file_name: String) -> String:
	return file_name + _BACKUP_SUFFIX


func _get_transaction_filename(file_name: String) -> String:
	return file_name + _TRANSACTION_SUFFIX


func _cleanup_transaction_files(file_names: Array[String]) -> void:
	for file_name: String in file_names:
		_remove_file_if_exists(_get_full_path(_get_temp_filename(file_name)))
		_remove_file_if_exists(_get_full_path(_get_backup_filename(file_name)))
		_remove_file_if_exists(_get_full_path(_get_transaction_filename(file_name)))


func _recover_transaction_files(file_names: Array[String]) -> void:
	var recovered_files: Dictionary = {}
	for file_name: String in file_names:
		var marker := _read_transaction_marker(file_name)
		if marker.is_empty():
			continue

		var transaction_files := _get_transaction_marker_files(marker, file_name)
		_recover_transaction_group(transaction_files)
		for transaction_file_name: String in transaction_files:
			recovered_files[transaction_file_name] = true

	for file_name: String in file_names:
		if not recovered_files.has(file_name):
			_recover_transaction_file(file_name)


func _recover_transaction_group(file_names: Array[String]) -> void:
	if file_names.is_empty():
		return

	var should_keep_new_files := _is_transaction_group_committed(file_names)
	if should_keep_new_files:
		for file_name: String in file_names:
			var final_path := _get_full_path(file_name)
			var temp_path := _get_full_path(_get_temp_filename(file_name))
			if not FileAccess.file_exists(final_path) and FileAccess.file_exists(temp_path):
				var promote_error := _move_file(temp_path, final_path)
				if promote_error != OK:
					push_error("[GFStorageUtility] 恢复已提交事务文件失败：%s，错误码：%s" % [final_path, promote_error])
					continue
			_remove_file_if_exists(temp_path)
			_remove_file_if_exists(_get_full_path(_get_backup_filename(file_name)))
			_remove_file_if_exists(_get_full_path(_get_transaction_filename(file_name)))
		return

	for file_name: String in file_names:
		var marker := _read_transaction_marker(file_name)
		var final_path := _get_full_path(file_name)
		var temp_path := _get_full_path(_get_temp_filename(file_name))
		var backup_path := _get_full_path(_get_backup_filename(file_name))
		var had_final := bool(marker.get("had_final", true))

		if FileAccess.file_exists(backup_path):
			_remove_file_if_exists(final_path)
			var restore_error := _move_file(backup_path, final_path)
			if restore_error != OK:
				push_error("[GFStorageUtility] 回滚事务文件失败：%s，错误码：%s" % [final_path, restore_error])
		elif not had_final:
			_remove_file_if_exists(final_path)

		_remove_file_if_exists(temp_path)
		_remove_file_if_exists(_get_full_path(_get_transaction_filename(file_name)))


func _recover_transaction_file(file_name: String) -> void:
	var final_path := _get_full_path(file_name)
	var temp_path := _get_full_path(_get_temp_filename(file_name))
	var backup_path := _get_full_path(_get_backup_filename(file_name))
	var has_final: bool = FileAccess.file_exists(final_path)
	var has_temp: bool = FileAccess.file_exists(temp_path)
	var has_backup: bool = FileAccess.file_exists(backup_path)

	if has_backup and (not has_final or has_temp):
		if has_final:
			_remove_file_if_exists(final_path)

		var restore_error := _move_file(backup_path, final_path)
		if restore_error != OK:
			push_error("[GFStorageUtility] 恢复备份文件失败：%s，错误码：%s" % [final_path, restore_error])
			return

		_remove_file_if_exists(temp_path)
		return

	if has_backup and has_final:
		_remove_file_if_exists(backup_path)
		has_backup = false

	if has_temp and not has_final and not has_backup:
		var promote_error := _move_file(temp_path, final_path)
		if promote_error != OK:
			push_error("[GFStorageUtility] 恢复临时文件失败：%s，错误码：%s" % [final_path, promote_error])
		return

	if has_temp and has_final:
		_remove_file_if_exists(temp_path)


func _commit_transaction(file_names: Array[String]) -> Error:
	file_names = _unique_file_names(file_names)
	var marker_error := _write_transaction_markers(file_names, false)
	if marker_error != OK:
		_cleanup_transaction_files(file_names)
		return marker_error

	var transaction_state: Dictionary = {}
	for file_name: String in file_names:
		transaction_state[file_name] = {
			"backed_up": false,
			"committed": false,
		}

	for file_name: String in file_names:
		var backup_path := _get_full_path(_get_backup_filename(file_name))
		var final_path := _get_full_path(file_name)
		if FileAccess.file_exists(final_path):
			var backup_error := _move_file(final_path, backup_path)
			if backup_error != OK:
				_rollback_transaction(file_names, transaction_state)
				return backup_error
			transaction_state[file_name]["backed_up"] = true

	for file_name: String in file_names:
		var temp_path := _get_full_path(_get_temp_filename(file_name))
		var final_path := _get_full_path(file_name)
		var commit_error := _move_file(temp_path, final_path)
		if commit_error != OK:
			_rollback_transaction(file_names, transaction_state)
			_cleanup_transaction_markers(file_names)
			return commit_error
		transaction_state[file_name]["committed"] = true

	var complete_marker_error := _write_transaction_markers(file_names, true)
	if complete_marker_error != OK:
		_rollback_transaction(file_names, transaction_state)
		_cleanup_transaction_markers(file_names)
		return complete_marker_error

	for file_name: String in file_names:
		_remove_file_if_exists(_get_full_path(_get_backup_filename(file_name)))
		_remove_file_if_exists(_get_full_path(_get_transaction_filename(file_name)))

	return OK


func _rollback_transaction(file_names: Array[String], transaction_state: Dictionary) -> void:
	for file_name: String in file_names:
		var final_path := _get_full_path(file_name)
		var temp_path := _get_full_path(_get_temp_filename(file_name))
		var backup_path := _get_full_path(_get_backup_filename(file_name))
		var state: Dictionary = transaction_state.get(file_name, {})
		var committed: bool = state.get("committed", false)
		var backed_up: bool = state.get("backed_up", false)

		if committed or backed_up:
			_remove_file_if_exists(final_path)
		_remove_file_if_exists(temp_path)

		if backed_up and FileAccess.file_exists(backup_path):
			var restore_error := _move_file(backup_path, final_path)
			if restore_error != OK:
				push_error("[GFStorageUtility] 回滚文件失败：%s，错误码：%s" % [final_path, restore_error])


func _write_transaction_markers(file_names: Array[String], committed: bool) -> Error:
	for file_name: String in file_names:
		var existing_marker := _read_transaction_marker(file_name)
		var had_final := bool(existing_marker.get("had_final", FileAccess.file_exists(_get_full_path(file_name))))
		var marker := {
			"files": file_names,
			"committed": committed,
			"had_final": had_final,
		}
		var error := _write_plain_json(_get_transaction_filename(file_name), marker)
		if error != OK:
			return error
	return OK


func _cleanup_transaction_markers(file_names: Array[String]) -> void:
	for file_name: String in file_names:
		_remove_file_if_exists(_get_full_path(_get_transaction_filename(file_name)))


func _read_transaction_marker(file_name: String) -> Dictionary:
	var path := _get_full_path(_get_transaction_filename(file_name))
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[GFStorageUtility] 无法读取事务标记：%s，错误码：%s" % [path, FileAccess.get_open_error()])
		return {}

	var content := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}


func _get_transaction_marker_files(marker: Dictionary, fallback_file_name: String) -> Array[String]:
	var result: Array[String] = []
	var raw_files: Variant = marker.get("files", [])
	if raw_files is Array:
		for raw_file: Variant in raw_files:
			var file_name := String(raw_file)
			if not file_name.is_empty() and not result.has(file_name):
				result.append(file_name)

	if result.is_empty():
		result.append(fallback_file_name)
	return result


func _is_transaction_group_committed(file_names: Array[String]) -> bool:
	for file_name: String in file_names:
		var marker := _read_transaction_marker(file_name)
		if marker.is_empty() or not bool(marker.get("committed", false)):
			return false
	return true


func _unique_file_names(file_names: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for file_name: String in file_names:
		if not result.has(file_name):
			result.append(file_name)
	return result


func _move_file(from_path: String, to_path: String) -> Error:
	if not FileAccess.file_exists(from_path):
		return ERR_FILE_NOT_FOUND
	return DirAccess.rename_absolute(from_path, to_path)


func _write_json(file_name: String, data: Dictionary) -> Error:
	var path := _get_full_path(file_name)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[GFStorageUtility] 无法写入文件：%s，错误码：%s" % [path, FileAccess.get_open_error()])
		return FileAccess.get_open_error()

	var json_str := JSON.stringify(data, "\t")

	if encrypt_key != 0:
		var key_byte := _get_obfuscation_key_byte()
		var bytes := json_str.to_utf8_buffer()
		for i in range(bytes.size()):
			bytes[i] = bytes[i] ^ key_byte
		file.store_string(Marshalls.raw_to_base64(bytes))
	else:
		file.store_string(json_str)

	file.close()
	return OK


func _write_plain_json(file_name: String, data: Dictionary) -> Error:
	var path := _get_full_path(file_name)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[GFStorageUtility] 无法写入文件：%s，错误码：%s" % [path, FileAccess.get_open_error()])
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return OK


func _read_json(file_name: String) -> Dictionary:
	_recover_transaction_files([file_name])

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
			var key_byte := _get_obfuscation_key_byte()
			for i in range(bytes.size()):
				bytes[i] = bytes[i] ^ key_byte
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


func _get_obfuscation_key_byte() -> int:
	return encrypt_key & 0xff
