## GFNodeSerializer: 节点序列化器基类。
##
## 用于把通用节点状态拆成可组合的序列化片段。具体项目可以继承该类，
## 在不修改存档图编排逻辑的前提下接入自己的节点状态。
class_name GFNodeSerializer
extends Resource


# --- 导出变量 ---

## 序列化器稳定标识。
@export var serializer_id: StringName = &""

## 编辑器展示名称。
@export var display_name: String = ""

## 可选 Godot 类名过滤。为空时由子类自行判断。
@export var supported_class_name: String = ""


# --- 公共方法 ---

## 获取序列化器标识。
## @return 稳定标识。
func get_serializer_id() -> StringName:
	if serializer_id != &"":
		return serializer_id
	if not resource_path.is_empty():
		return StringName(resource_path)
	return StringName(get_script().resource_path)


## 判断当前序列化器是否支持节点。
## @param node: 待序列化节点。
## @return 支持时返回 true。
func supports_node(node: Node) -> bool:
	if node == null:
		return false
	if supported_class_name.is_empty():
		return true
	return node.is_class(supported_class_name)


## 采集节点数据。
## @param _node: 待序列化节点。
## @param _context: 调用上下文字典。
## @return 可写入存档的字典。
func gather(_node: Node, _context: Dictionary = {}) -> Dictionary:
	return {}


## 应用节点数据。
## @param _node: 目标节点。
## @param _payload: 当前序列化器的数据。
## @param _context: 调用上下文字典。
## @return 结果字典。
func apply(_node: Node, _payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	return make_result(true)


## 构造统一结果。
## @param ok: 是否成功。
## @param error: 错误描述。
## @return 结果字典。
func make_result(ok: bool, error: String = "") -> Dictionary:
	return {
		"ok": ok,
		"error": error,
	}
