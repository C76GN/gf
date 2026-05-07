## GFStorageUtility: 基于 `user://` 的轻量存档系统。
##
## 支持槽位存档、元数据分离读取、`Resource` 存取，
## 以及可配置 codec、完整性校验、版本迁移和简单混淆，适合通用本地持久化场景。
## 该混淆不提供安全加密能力，请勿用于保护敏感数据。
class_name GFStorageUtility
extends GFUtility


# --- 信号 ---

## 解码数据失败或发现完整性校验失败后发出。
## @param file_name: 文件名。
## @param error: 错误描述。
signal data_integrity_failed(file_name: String, error: String)

## 数据版本迁移后发出。
## @param file_name: 文件名。
## @param from_version: 原版本。
## @param to_version: 目标版本。
signal data_migrated(file_name: String, from_version: int, to_version: int)

## 异步保存完成后发出。
## @param file_name: 文件名。
## @param error: Godot 的 Error 结果码。
signal save_completed(file_name: String, error: Error)

## 异步读取完成后发出。
## @param file_name: 文件名。
## @param result: 读取结果，包含 ok、data、metadata、integrity_valid、error。
signal load_completed(file_name: String, result: Dictionary)


# --- 常量 ---

const _TEMP_SUFFIX: String = ".tmp"
const _BACKUP_SUFFIX: String = ".bak"
const _TRANSACTION_SUFFIX: String = ".txn"


# --- 公共变量 ---

## 用于简单 XOR + Base64 混淆的密钥；为 `0` 时直接保存明文 JSON。该字段不是安全加密密钥。
var encrypt_key: int = 42

## 保存子目录名；为空时直接写入 `user://`。
var save_dir_name: String = "saves"

## 存档 codec。为 null 时会自动创建默认 GFStorageCodec。
var codec: GFStorageCodec = GFStorageCodec.new()

## 数据序列化格式。
var file_format: GFStorageCodec.Format = GFStorageCodec.Format.JSON

## 是否压缩存档载荷。
var use_compression: bool = false

## 是否写入并校验 SHA-256 完整性校验。
var use_integrity_checksum: bool = false

## 完整性校验失败时是否拒绝读取。
var strict_integrity: bool = true

## 启用完整性校验时，是否要求载荷必须包含 `_meta.checksum`。
var require_integrity_checksum: bool = false

## 是否写入 `_meta.version`、`_meta.timestamp` 等通用元信息。
var include_storage_metadata: bool = false

## 是否允许传入绝对路径。关闭后绝对路径会被收敛到存档目录下的同名文件。
var allow_absolute_paths: bool = true

## 写入嵌套相对路径时是否自动创建目录。
var create_directories_for_nested_paths: bool = true

## 同时运行的异步存取线程数量。小于 1 时会被钳制为 1。
var max_async_thread_count: int = 4:
	set(value):
		max_async_thread_count = maxi(value, 1)

## 当前存档数据版本。小于 1 会被钳制为 1。
var save_version: int = 1:
	set(value):
		save_version = maxi(value, 1)

## 读取旧版本数据时需要补齐的新字段默认值。
var default_values_for_new_keys: Dictionary = {}

## 迁移后的最近一次读取结果，包含 ok、data、metadata、integrity_valid、error。
var last_load_result: Dictionary = {}


# --- 私有变量 ---

var _async_tasks: Array[Dictionary] = []
var _async_queue: Array[Dictionary] = []
var _async_file_locks: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_pause = true
	var dir_path := _get_save_base_path()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)


func dispose() -> void:
	_wait_for_async_tasks()


# --- 公共方法（Resource 存取） ---

## 保存一个 `Resource` 文件。
## @param file_name: 目标文件名。
## @param resource: 要保存的资源实例。
## @return Godot 的 `Error` 结果码。
func save_resource(file_name: String, resource: Resource) -> Error:
	init()
	var path := _get_full_path(file_name)
	var dir_error := _ensure_parent_directory(path)
	if dir_error != OK:
		return dir_error
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


## 读取纯字典数据并返回 codec 结果。
## @param file_name: 目标文件名。
## @return 结果字典，包含 ok、data、metadata、integrity_valid、error。
func load_data_result(file_name: String) -> Dictionary:
	_read_json(file_name)
	return last_load_result.duplicate(true)


## 在线程中异步保存纯字典数据。完成后从主线程发出 save_completed。
## @param file_name: 目标文件名。
## @param data: 要保存的字典。
## @return 启动线程的 Error 结果码。
func save_data_async(file_name: String, data: Dictionary) -> Error:
	init()
	_async_queue.append({
		"type": &"save",
		"file_name": file_name,
		"file_key": _get_async_file_key(file_name),
		"data": data.duplicate(true),
		"codec_options": _get_codec_options(),
	})
	_start_queued_async_tasks()
	return OK


## 在线程中异步读取纯字典数据。完成后从主线程发出 load_completed。
## @param file_name: 目标文件名。
## @return 启动线程的 Error 结果码。
func load_data_async(file_name: String) -> Error:
	_async_queue.append({
		"type": &"load",
		"file_name": file_name,
		"file_key": _get_async_file_key(file_name),
		"codec_options": _get_codec_options(),
	})
	_start_queued_async_tasks()
	return OK


## 驱动异步存档任务完成检查。
## @param _delta: 为兼容统一 tick 签名而保留的参数。
func tick(_delta: float = 0.0) -> void:
	_poll_async_tasks()


## 迁移存档数据。项目可继承 GFStorageUtility 并重写该方法。
## @param data: 已读取的数据副本。
## @param _from_version: 原版本。
## @param _to_version: 目标版本。
## @return 迁移后的数据。
func migrate_data(data: Dictionary, _from_version: int, _to_version: int) -> Dictionary:
	var migrated := data.duplicate(true)
	if not default_values_for_new_keys.is_empty():
		_deep_merge_defaults(migrated, default_values_for_new_keys)
	return migrated


# --- 私有/辅助方法 ---

func _poll_async_tasks() -> void:
	for i in range(_async_tasks.size() - 1, -1, -1):
		var task := _async_tasks[i] as Dictionary
		var thread := task.get("thread") as Thread
		if thread == null or thread.is_alive():
			continue

		var result_variant: Variant = thread.wait_to_finish()
		_async_tasks.remove_at(i)
		_async_file_locks.erase(String(task.get("file_key", "")))
		_complete_finished_async_task(task, result_variant)
	_start_queued_async_tasks()


func _wait_for_async_tasks() -> void:
	for task: Dictionary in _async_tasks:
		var thread := task.get("thread") as Thread
		if thread != null:
			var result_variant: Variant = thread.wait_to_finish()
			_complete_finished_async_task(task, result_variant)
	_async_tasks.clear()
	_async_file_locks.clear()
	_fail_queued_async_tasks("Storage utility disposed before task started.")
	_async_queue.clear()


func _start_queued_async_tasks() -> void:
	while _async_tasks.size() < maxi(max_async_thread_count, 1):
		var task_index := _find_startable_async_task_index()
		if task_index < 0:
			return

		var task := _async_queue[task_index] as Dictionary
		_async_queue.remove_at(task_index)
		_start_async_task(task)


func _find_startable_async_task_index() -> int:
	for i in range(_async_queue.size()):
		var task := _async_queue[i] as Dictionary
		var file_key := String(task.get("file_key", ""))
		if file_key.is_empty() or not _async_file_locks.has(file_key):
			return i
	return -1


func _start_async_task(task: Dictionary) -> void:
	var file_name := String(task.get("file_name", ""))
	var task_type := StringName(task.get("type", &""))
	var thread := Thread.new()
	_recover_transaction_files([file_name])

	var error: Error = ERR_INVALID_PARAMETER
	if task_type == &"save":
		error = thread.start(Callable(self, "_save_data_thread").bind(
			file_name,
			_get_full_path(file_name),
			_get_full_path(_get_temp_filename(file_name)),
			_get_full_path(_get_backup_filename(file_name)),
			_get_full_path(_get_transaction_filename(file_name)),
			task.get("data", {}) as Dictionary,
			task.get("codec_options", {}) as Dictionary
		))
	elif task_type == &"load":
		error = thread.start(Callable(self, "_load_data_thread").bind(
			file_name,
			_get_full_path(file_name),
			task.get("codec_options", {}) as Dictionary
		))

	if error != OK:
		_emit_async_start_failed(task, error)
		return

	task["thread"] = thread
	_async_file_locks[String(task.get("file_key", ""))] = true
	_async_tasks.append(task)


func _emit_async_start_failed(task: Dictionary, error: Error) -> void:
	var file_name := String(task.get("file_name", ""))
	var task_type := StringName(task.get("type", &""))
	if task_type == &"save":
		push_error("[GFStorageUtility] 无法启动异步保存线程：%s，错误码：%s" % [file_name, error])
		save_completed.emit(file_name, error)
	elif task_type == &"load":
		push_error("[GFStorageUtility] 无法启动异步读取线程：%s，错误码：%s" % [file_name, error])
		var failed_result := _make_load_result(false, {}, "Thread start failed: %s" % error_string(error), true)
		load_completed.emit(file_name, failed_result)


func _complete_finished_async_task(task: Dictionary, result_variant: Variant) -> void:
	var file_name := String(task.get("file_name", ""))
	var task_type := StringName(task.get("type", &""))
	if task_type == &"save":
		var save_result := result_variant as Dictionary
		var error: Error = ERR_BUG
		if save_result != null:
			error = int(save_result.get("error", ERR_BUG))
		save_completed.emit(file_name, error)
	elif task_type == &"load":
		_complete_async_load(file_name, result_variant)


func _fail_queued_async_tasks(reason: String) -> void:
	for task: Dictionary in _async_queue:
		var file_name := String(task.get("file_name", ""))
		var task_type := StringName(task.get("type", &""))
		if task_type == &"save":
			save_completed.emit(file_name, ERR_UNAVAILABLE)
		elif task_type == &"load":
			var failed_result := _make_load_result(false, {}, reason, true)
			last_load_result = failed_result.duplicate(true)
			load_completed.emit(file_name, failed_result)


func _complete_async_load(file_name: String, result_variant: Variant) -> void:
	var result := result_variant as Dictionary
	if result == null:
		result = _make_load_result(false, {}, "Async load failed", true)

	last_load_result = result.duplicate(true)
	if not bool(result.get("ok", false)):
		if _should_emit_load_integrity_failed(result):
			data_integrity_failed.emit(file_name, String(result.get("error", "Decode failed")))
		load_completed.emit(file_name, last_load_result.duplicate(true))
		return

	if not bool(result.get("integrity_valid", true)):
		data_integrity_failed.emit(file_name, String(result.get("error", "Integrity checksum mismatch")))

	var data_value: Variant = result.get("data", {})
	if not (data_value is Dictionary):
		last_load_result = {
			"ok": false,
			"data": {},
			"metadata": {},
			"integrity_valid": bool(result.get("integrity_valid", true)),
			"error": "Decoded storage payload is not a Dictionary.",
		}
		data_integrity_failed.emit(file_name, String(last_load_result["error"]))
		load_completed.emit(file_name, last_load_result.duplicate(true))
		return

	var data: Dictionary = data_value as Dictionary
	data = _apply_schema_migrations(file_name, data)
	last_load_result["data"] = data
	last_load_result["metadata"] = _get_storage_metadata(data)
	load_completed.emit(file_name, last_load_result.duplicate(true))


func _should_emit_load_integrity_failed(result: Dictionary) -> bool:
	var error := String(result.get("error", ""))
	if error == "File not found" or error == "File is empty" or error.begins_with("File open failed"):
		return false
	return true


func _save_data_thread(
	file_name: String,
	final_path: String,
	temp_path: String,
	backup_path: String,
	transaction_path: String,
	data: Dictionary,
	codec_options: Dictionary
) -> Dictionary:
	var dir_error := _ensure_absolute_parent_directory(final_path)
	if dir_error != OK:
		return { "error": dir_error }

	var codec := GFStorageCodec.new()
	var bytes := codec.encode(data, codec_options)
	var write_error := _write_buffer_absolute(temp_path, bytes)
	if write_error != OK:
		_remove_absolute_file_if_exists(temp_path)
		return { "error": write_error }

	var had_final := FileAccess.file_exists(final_path)
	var marker_error := _write_plain_json_absolute(transaction_path, {
		"files": [file_name],
		"committed": false,
		"had_final": had_final,
	})
	if marker_error != OK:
		_remove_absolute_file_if_exists(temp_path)
		return { "error": marker_error }

	var backed_up := false
	var committed := false
	if had_final:
		var backup_error := DirAccess.rename_absolute(final_path, backup_path)
		if backup_error != OK:
			_remove_absolute_file_if_exists(temp_path)
			_remove_absolute_file_if_exists(transaction_path)
			return { "error": backup_error }
		backed_up = true

	var commit_error := DirAccess.rename_absolute(temp_path, final_path)
	if commit_error != OK:
		_rollback_absolute_transaction(final_path, temp_path, backup_path, backed_up, committed)
		_remove_absolute_file_if_exists(transaction_path)
		return { "error": commit_error }
	committed = true

	var complete_marker_error := _write_plain_json_absolute(transaction_path, {
		"files": [file_name],
		"committed": true,
		"had_final": had_final,
	})
	if complete_marker_error != OK:
		_rollback_absolute_transaction(final_path, temp_path, backup_path, backed_up, committed)
		_remove_absolute_file_if_exists(transaction_path)
		return { "error": complete_marker_error }

	_remove_absolute_file_if_exists(backup_path)
	_remove_absolute_file_if_exists(transaction_path)
	return { "error": OK }


func _load_data_thread(file_name: String, path: String, codec_options: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _make_thread_load_result(false, {}, "File not found", true)

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _make_thread_load_result(
			false,
			{},
			"File open failed: %s" % error_string(FileAccess.get_open_error()),
			true
		)

	var bytes := file.get_buffer(file.get_length())
	file.close()
	if bytes.is_empty():
		return _make_thread_load_result(false, {}, "File is empty", true)

	var codec := GFStorageCodec.new()
	return codec.decode(bytes, codec_options)


func _make_thread_load_result(ok: bool, data: Dictionary, error: String, integrity_valid: bool) -> Dictionary:
	var codec := GFStorageCodec.new()
	return {
		"ok": ok,
		"data": data,
		"metadata": codec.get_metadata(data),
		"integrity_valid": integrity_valid,
		"error": error,
	}


func _ensure_absolute_parent_directory(path: String) -> Error:
	var base_dir := path.get_base_dir()
	if base_dir.is_empty() or base_dir == "user://":
		return OK
	if DirAccess.dir_exists_absolute(base_dir):
		return OK
	return DirAccess.make_dir_recursive_absolute(base_dir)


func _write_buffer_absolute(path: String, bytes: PackedByteArray) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer(bytes)
	var error := file.get_error()
	file.close()
	return error


func _write_plain_json_absolute(path: String, data: Dictionary) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	var error := file.get_error()
	file.close()
	return error


func _remove_absolute_file_if_exists(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _rollback_absolute_transaction(
	final_path: String,
	temp_path: String,
	backup_path: String,
	backed_up: bool,
	committed: bool
) -> void:
	if committed or backed_up:
		_remove_absolute_file_if_exists(final_path)
	_remove_absolute_file_if_exists(temp_path)
	if backed_up and FileAccess.file_exists(backup_path):
		DirAccess.rename_absolute(backup_path, final_path)


func _get_data_filename(slot_id: int) -> String:
	return "slot_%d_data.sav" % slot_id


func _get_meta_filename(slot_id: int) -> String:
	return "slot_%d_meta.sav" % slot_id


func _get_save_base_path() -> String:
	if save_dir_name.is_empty():
		return "user://"

	return "user://" + _sanitize_storage_relative_path(save_dir_name, "save_dir_name")


func _get_full_path(file_name: String) -> String:
	if file_name.is_absolute_path():
		if allow_absolute_paths:
			return file_name
		push_error("[GFStorageUtility] 已禁用绝对路径：%s" % file_name)
		file_name = file_name.get_file()

	file_name = _sanitize_storage_relative_path(file_name, "file_name")
	if save_dir_name.is_empty():
		return "user://" + file_name

	return _get_save_base_path() + "/" + file_name


func _sanitize_storage_relative_path(path: String, label: String) -> String:
	var original_path := path
	var normalized := path.replace("\\", "/").simplify_path()
	if normalized == ".":
		normalized = ""
	if _is_parent_directory_path(normalized):
		push_error("[GFStorageUtility] 已拒绝跨目录路径（%s）：%s" % [label, original_path])
		normalized = original_path.get_file()
	if normalized.is_empty() or normalized == "." or normalized == "..":
		push_error("[GFStorageUtility] %s 为空。" % label)
		return "_invalid_storage_file"
	return normalized


func _is_parent_directory_path(path: String) -> bool:
	return path == ".." or path.begins_with("../") or path.contains("/../")


func _get_async_file_key(file_name: String) -> String:
	return _get_full_path(file_name)


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
	var dir_error := _ensure_parent_directory(path)
	if dir_error != OK:
		return dir_error
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[GFStorageUtility] 无法写入文件：%s，错误码：%s" % [path, FileAccess.get_open_error()])
		return FileAccess.get_open_error()

	var bytes := _get_codec().encode(data, _get_codec_options())
	file.store_buffer(bytes)
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("[GFStorageUtility] 写入文件失败：%s，错误码：%s" % [path, write_error])
	return write_error


func _write_plain_json(file_name: String, data: Dictionary) -> Error:
	var path := _get_full_path(file_name)
	var dir_error := _ensure_parent_directory(path)
	if dir_error != OK:
		return dir_error
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[GFStorageUtility] 无法写入文件：%s，错误码：%s" % [path, FileAccess.get_open_error()])
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(data, "\t"))
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("[GFStorageUtility] 写入文件失败：%s，错误码：%s" % [path, write_error])
	return write_error


func _ensure_parent_directory(path: String) -> Error:
	if not create_directories_for_nested_paths:
		return OK

	var base_dir := path.get_base_dir()
	if base_dir.is_empty() or base_dir == "user://":
		return OK
	if DirAccess.dir_exists_absolute(base_dir):
		return OK

	var error := DirAccess.make_dir_recursive_absolute(base_dir)
	if error != OK:
		push_error("[GFStorageUtility] 无法创建目录：%s，错误码：%s" % [base_dir, error])
	return error


func _read_json(file_name: String) -> Dictionary:
	_recover_transaction_files([file_name])

	var path := _get_full_path(file_name)
	if not FileAccess.file_exists(path):
		last_load_result = _make_load_result(false, {}, "File not found", true)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		var open_error := FileAccess.get_open_error()
		push_error("[GFStorageUtility] 无法读取文件：%s，错误码：%s" % [path, open_error])
		last_load_result = _make_load_result(
			false,
			{},
			"File open failed: %s" % error_string(open_error),
			true
		)
		return {}

	var bytes := file.get_buffer(file.get_length())
	file.close()

	if bytes.is_empty():
		last_load_result = _make_load_result(false, {}, "File is empty", true)
		return {}

	var result := _get_codec().decode(bytes, _get_codec_options())
	last_load_result = result.duplicate(true)
	if not bool(result.get("ok", false)):
		var error := String(result.get("error", "Decode failed"))
		data_integrity_failed.emit(file_name, error)
		if not bool(result.get("integrity_valid", true)):
			push_warning("[GFStorageUtility] 读取数据失败：%s，原因：%s" % [path, error])
		else:
			push_error("[GFStorageUtility] 读取数据失败：%s，原因：%s" % [path, error])
		return {}

	if not bool(result.get("integrity_valid", true)):
		data_integrity_failed.emit(file_name, String(result.get("error", "Integrity checksum mismatch")))

	var data_value: Variant = result.get("data", {})
	if not (data_value is Dictionary):
		last_load_result = {
			"ok": false,
			"data": {},
			"metadata": {},
			"integrity_valid": bool(result.get("integrity_valid", true)),
			"error": "Decoded storage payload is not a Dictionary.",
		}
		data_integrity_failed.emit(file_name, String(last_load_result["error"]))
		return {}

	var data: Dictionary = data_value as Dictionary
	data = _apply_schema_migrations(file_name, data)
	last_load_result["data"] = data
	last_load_result["metadata"] = _get_storage_metadata(data)
	return data


func _get_codec() -> GFStorageCodec:
	if codec == null:
		codec = GFStorageCodec.new()
	return codec


func _get_codec_options() -> Dictionary:
	return {
		"format": file_format,
		"use_compression": use_compression,
		"use_integrity_checksum": use_integrity_checksum,
		"strict_integrity": strict_integrity,
		"require_integrity_checksum": require_integrity_checksum,
		"include_metadata": include_storage_metadata,
		"version": save_version,
		"obfuscation_key": encrypt_key,
	}


func _apply_schema_migrations(file_name: String, data: Dictionary) -> Dictionary:
	var metadata := _get_storage_metadata(data)
	var from_version := int(metadata.get("version", 1))
	var to_version := save_version
	if from_version >= to_version:
		if not default_values_for_new_keys.is_empty():
			_deep_merge_defaults(data, default_values_for_new_keys)
		return data

	var migrated := migrate_data(data, from_version, to_version)
	var migrated_metadata := _get_storage_metadata(migrated)
	migrated_metadata["version"] = to_version
	migrated[GFStorageCodec.META_KEY] = migrated_metadata
	data_migrated.emit(file_name, from_version, to_version)
	return migrated


func _get_storage_metadata(data: Dictionary) -> Dictionary:
	return _get_codec().get_metadata(data)


func _make_load_result(ok: bool, data: Dictionary, error: String, integrity_valid: bool) -> Dictionary:
	return {
		"ok": ok,
		"data": data,
		"metadata": _get_storage_metadata(data),
		"integrity_valid": integrity_valid,
		"error": error,
	}


func _deep_merge_defaults(base: Dictionary, defaults: Dictionary) -> void:
	for key: Variant in defaults.keys():
		if not base.has(key):
			base[key] = _duplicate_collection(defaults[key])
			continue

		if base[key] is Dictionary and defaults[key] is Dictionary:
			_deep_merge_defaults(base[key], defaults[key])


func _duplicate_collection(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
