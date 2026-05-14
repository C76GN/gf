## GFNodeRangeSerializer: Range 通用数值状态序列化器。
##
## 保存滑条、进度条等 Range 派生控件的通用数值参数。
class_name GFNodeRangeSerializer
extends GFNodeSerializer


# --- 常量 ---

const _PROPERTY_SPECS: Array[Dictionary] = [
	{ "key": "min_value", "kind": &"float" },
	{ "key": "max_value", "kind": &"float" },
	{ "key": "step", "kind": &"float" },
	{ "key": "page", "kind": &"float" },
	{ "key": "rounded", "kind": &"bool" },
	{ "key": "allow_greater", "kind": &"bool" },
	{ "key": "allow_lesser", "kind": &"bool" },
	{ "key": "value", "kind": &"float" },
]


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.range"
	display_name = "Range"


# --- 公共方法 ---

## 判断序列化器是否支持指定节点。
## @param node: 目标节点。
func supports_node(node: Node) -> bool:
	return node is Range


## 采集节点的可保存状态。
## @param node: 目标节点。
## @param _context: 操作上下文字典，默认实现不直接使用。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	var range := node as Range
	if range == null:
		return {}

	return _gather_property_specs(range, _PROPERTY_SPECS)


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var range := node as Range
	if range == null:
		return make_result(false, "Node is not Range.")

	_apply_property_specs(range, payload, _PROPERTY_SPECS)
	return make_result(true)
