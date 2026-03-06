# addons/gf/utilities/gf_storage_utility.gd

## GFStorageUtility: 商业级存档系统。
##
## 封装了基于 user:// 目录的文件存取逻辑，内部使用 FileAccess 和 JSON 进行序列化/反序列化。
## 支持多槽位存档、元数据分离读取（用于展示 UI），以及简单的 Base64 XOR 加密混淆以防篡改玩家随意用记事本修改 JSON。
class_name GFStorageUtility
extends GFUtility

# --- 公共变量 ---

## 用于简单的 XOR 混淆密钥字符。为 0 则不混淆并保存为明文 JSON。默认为 42（开启混淆）。
var encrypt_key: int = 42

## 保存的子目录。若是空则直接存在 user:// 下。
var save_dir_name: String = "saves"


# --- Godot 生命周期方法 ---

func init() -> void:
	var dir_path := "user://"
	if not save_dir_name.is_empty():
		dir_path += save_dir_name
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_recursive_absolute(dir_path)


# --- 公共方法 (新体系) ---

## 保存 Godot Resource 对象到指定内部路径。
## @param file_name: 资源文件名（如 "player_data.tres"）。
## @param resource: 要保存的 Resource 实例。
## @return 写入成功返回 OK，否则返回对应的 Error。
func save_resource(file_name: String, resource: Resource) -> Error:
	init()
	var path := _get_full_path(file_name)
	return ResourceSaver.save(resource, path)


## 读取指定名称的 Godot Resource 对象。
## @param file_name: 资源文件名（如 "player_data.tres"）。
## @param type_hint: 可选的资源类型提示。
## @return 读取成功的 Resource 实例，失败则返回 null。
func load_resource(file_name: String, type_hint: String = "") -> Resource:
	var path := _get_full_path(file_name)
	if not FileAccess.file_exists(path):
		return null
	
	return ResourceLoader.load(path, type_hint)


## 保存存档至指定槽位。
## 若提供了 metadata，则将元数据分离存储，以便在不加载巨大 data 体时快速读取展示。
## @param slot_id: 存档槽位 ID，如 1, 2, 3。
## @param data: 核心存档字典。
## @param metadata: 可选的仅用于列表展示的信息字典（如游玩时长、等级等）。
## @return 写入成功返回 OK，否则返回对应的 Error。
func save_slot(slot_id: int, data: Dictionary, metadata: Dictionary = {}) -> Error:
	var data_file_name := _get_data_filename(slot_id)
	var meta_file_name := _get_meta_filename(slot_id)
	
	# 确保目录存在（首次或者意外删除后重建）
	init()
	
	# 写入元数据
	var err1 := _write_json(meta_file_name, metadata)
	if err1 != OK:
		return err1
		
	# 写入核心数据
	var err2 := _write_json(data_file_name, data)
	return err2


## 读取指定槽位的完整核心存档。如果不存在则返回空字典。
## @param slot_id: 存档槽位 ID。
## @return 反序列化后的数据字典。
func load_slot(slot_id: int) -> Dictionary:
	var data_file_name := _get_data_filename(slot_id)
	return _read_json(data_file_name)


## 仅读取指定槽位的元数据。无需反序列化巨大的游戏对象字典，性能极高。
## @param slot_id: 存档槽位 ID。
## @return 反序列化后的元数据字典。
func load_slot_meta(slot_id: int) -> Dictionary:
	var meta_file_name := _get_meta_filename(slot_id)
	return _read_json(meta_file_name)


## 检查指定槽位是否存在有效存档（以 metadata 文件是否存在为准）。
## @param slot_id: 存档槽位 ID。
## @return 存在返回 true。
func has_slot(slot_id: int) -> bool:
	var path := _get_full_path(_get_meta_filename(slot_id))
	return FileAccess.file_exists(path)


## 删除指定槽位的存档（同时删除数据和元数据）。
## @param slot_id: 存档槽位 ID。
func delete_slot(slot_id: int) -> void:
	var core_path := _get_full_path(_get_data_filename(slot_id))
	var meta_path := _get_full_path(_get_meta_filename(slot_id))
	if FileAccess.file_exists(core_path):
		DirAccess.remove_absolute(core_path)
	if FileAccess.file_exists(meta_path):
		DirAccess.remove_absolute(meta_path)


# --- 原有兼容方法 ---

## 兼容旧版，直接将字典数据序列化为 JSON 并写入指定文件名称。
## @param file_name: 存档文件名（如 "save.json"）。
## @param data: 要保存的字典数据。
## @return 写入成功返回 OK。
func save_data(file_name: String, data: Dictionary) -> Error:
	init()
	return _write_json(file_name, data)


## 兼容旧版，从指定文件读取并反序列化为字典。
## 若文件不存在或解析失败，返回空字典。
## @param file_name: 存档文件名。
## @return 解析后的字典，失败时返回空字典。
func load_data(file_name: String) -> Dictionary:
	return _read_json(file_name)


# --- 私有方法 ---

func _get_data_filename(slot_id: int) -> String:
	return "slot_%d_data.sav" % slot_id


func _get_meta_filename(slot_id: int) -> String:
	return "slot_%d_meta.sav" % slot_id


func _get_full_path(file_name: String) -> String:
	if save_dir_name.is_empty():
		return "user://" + file_name
	return "user://" + save_dir_name + "/" + file_name


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
		var encoded_str := Marshalls.raw_to_base64(bytes)
		file.store_string(encoded_str)
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
		if bytes.is_empty():
			# 为了能平滑过渡旧版未加密的明文 JSON，或读取时意外解密失败，回退尝试不解密
			pass
		else:
			for i in range(bytes.size()):
				bytes[i] = bytes[i] ^ encrypt_key
			json_str = bytes.get_string_from_utf8()
		
	var parse_result: Variant = JSON.parse_string(json_str)
	if parse_result == null:
		# 兼容退路：万一之前真的存了明文，尝试直接当作明文解析
		var fallback_result: Variant = JSON.parse_string(content)
		if fallback_result != null and typeof(fallback_result) == TYPE_DICTIONARY:
			return fallback_result as Dictionary
			
		push_error("[GFStorageUtility] JSON 解析失败，文件路径：%s" % path)
		return {}
		
	if typeof(parse_result) == TYPE_DICTIONARY:
		return parse_result as Dictionary
	return {}
