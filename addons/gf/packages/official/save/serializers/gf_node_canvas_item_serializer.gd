## GFNodeCanvasItemSerializer: CanvasItem 通用显示状态序列化器。
##
## 保存可见性与颜色调制等通用表现状态，不保存具体业务字段。
class_name GFNodeCanvasItemSerializer
extends GFNodeSerializer


# --- 常量 ---

const _PROPERTY_SPECS: Array[Dictionary] = [
	{ "key": "visible", "kind": &"bool" },
	{ "key": "modulate", "kind": &"color" },
	{ "key": "self_modulate", "kind": &"color" },
	{ "key": "show_behind_parent", "kind": &"bool" },
	{ "key": "top_level", "kind": &"bool" },
	{ "key": "z_as_relative", "kind": &"bool" },
	{ "key": "z_index", "kind": &"int" },
]


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.canvas_item"
	display_name = "Canvas Item"


# --- 公共方法 ---

## 判断序列化器是否支持指定节点。
## @param node: 目标节点。
func supports_node(node: Node) -> bool:
	return node is CanvasItem


## 采集节点的可保存状态。
## @param node: 目标节点。
## @param _context: 操作上下文字典，默认实现不直接使用。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	var canvas_item := node as CanvasItem
	if canvas_item == null:
		return {}

	return _gather_property_specs(canvas_item, _PROPERTY_SPECS)


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var canvas_item := node as CanvasItem
	if canvas_item == null:
		return make_result(false, "Node is not CanvasItem.")

	_apply_property_specs(canvas_item, payload, _PROPERTY_SPECS)
	return make_result(true)
