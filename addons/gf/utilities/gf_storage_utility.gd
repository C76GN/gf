# addons/gf/utilities/gf_storage_utility.gd

## GFStorageUtility: 本地存档读写管理器。
##
## 封装了基于 user:// 目录的文件存取逻辑，内部使用 FileAccess
## 和 JSON 进行序列化/反序列化。
## 文件名仅需传入不含路径的文件名称（如 "save_slot_1.json"）。
class_name GFStorageUtility
extends GFUtility


# --- 私有变量 ---

## 所有存档文件的基础目录路径。
var _base_path: String


# --- Godot 生命周期方法 ---

## 第一阶段初始化：设置基础目录路径。
func init() -> void:
	_base_path = "user://"


# --- 公共方法 ---

## 将字典数据序列化为 JSON 并写入指定文件。
## @param file_name: 存档文件名（如 "save.json"）。
## @param data: 要保存的字典数据。
## @return 写入成功返回 OK，否则返回对应的 Error 枚举值。
func save_data(file_name: String, data: Dictionary) -> Error:
	var path := _base_path + file_name
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[GFStorageUtility] 无法写入文件：%s，错误码：%s" % [path, FileAccess.get_open_error()])
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return OK


## 从指定文件读取并反序列化为字典。
## 若文件不存在或解析失败，返回空字典。
## @param file_name: 存档文件名（如 "save.json"）。
## @return 解析后的字典，失败时返回空字典。
func load_data(file_name: String) -> Dictionary:
	var path := _base_path + file_name
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[GFStorageUtility] 无法读取文件：%s，错误码：%s" % [path, FileAccess.get_open_error()])
		return {}
	var content := file.get_as_text()
	file.close()
	var parse_result: Variant = JSON.parse_string(content)
	if parse_result == null:
		push_error("[GFStorageUtility] JSON 解析失败，文件路径：%s" % path)
		return {}
	return parse_result as Dictionary
