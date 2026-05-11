## GFStorageBackend: 存储后端扩展接口。
##
## 该类只定义通用后端协议，不绑定本地、云、平台 SDK 或同步策略。
## 默认实现返回不可用结果；项目可继承它并由自定义 Utility 或派生的
## GFStorageUtility 组合使用。
class_name GFStorageBackend
extends RefCounted


# --- 公共方法 ---

## 初始化后端。
## @param config: 后端配置字典。
## @return Godot Error 结果码。
func initialize(config: Dictionary = {}) -> Error:
	return _initialize(config)


## 关闭后端并释放资源。
func shutdown() -> void:
	_shutdown()


## 保存纯字典数据。
## @param file_name: 逻辑文件名。
## @param data: 要保存的数据。
## @param metadata: 可选元数据。
## @return Godot Error 结果码。
func save_data(file_name: String, data: Dictionary, metadata: Dictionary = {}) -> Error:
	if file_name.is_empty():
		return ERR_INVALID_PARAMETER
	return _save_data(file_name, data.duplicate(true), metadata.duplicate(true))


## 读取纯字典数据。
## @param file_name: 逻辑文件名。
## @return 结果字典，包含 ok、data、metadata、error。
func load_data(file_name: String) -> Dictionary:
	if file_name.is_empty():
		return _make_result(false, {}, {}, "file_name is empty")
	return _load_data(file_name)


## 删除纯字典数据。
## @param file_name: 逻辑文件名。
## @return Godot Error 结果码。
func delete_data(file_name: String) -> Error:
	if file_name.is_empty():
		return ERR_INVALID_PARAMETER
	return _delete_data(file_name)


## 判断逻辑文件是否存在。
## @param file_name: 逻辑文件名。
## @return 存在时返回 true。
func has_data(file_name: String) -> bool:
	if file_name.is_empty():
		return false
	return _has_data(file_name)


## 枚举后端中的逻辑文件。
## @return 文件摘要数组。
func list_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item: Dictionary in _list_data():
		result.append(item.duplicate(true))
	return result


## 获取后端能力描述。
## @return 能力字典副本。
func get_capabilities() -> Dictionary:
	return _get_capabilities().duplicate(true)


# --- 可重写钩子 ---

func _initialize(_config: Dictionary) -> Error:
	return OK


func _shutdown() -> void:
	pass


func _save_data(_file_name: String, _data: Dictionary, _metadata: Dictionary) -> Error:
	return ERR_UNAVAILABLE


func _load_data(_file_name: String) -> Dictionary:
	return _make_result(false, {}, {}, "backend unavailable")


func _delete_data(_file_name: String) -> Error:
	return ERR_UNAVAILABLE


func _has_data(_file_name: String) -> bool:
	return false


func _list_data() -> Array[Dictionary]:
	return []


func _get_capabilities() -> Dictionary:
	return {
		"read": false,
		"write": false,
		"delete": false,
		"list": false,
		"sync": false,
	}


# --- 私有/辅助方法 ---

func _make_result(ok: bool, data: Dictionary, metadata: Dictionary, error: String) -> Dictionary:
	return GFResultUtility.make(ok, {
		GFResultUtility.KEY_DATA: data.duplicate(true),
		GFResultUtility.KEY_METADATA: metadata.duplicate(true),
		GFResultUtility.KEY_ERROR: error,
	})
