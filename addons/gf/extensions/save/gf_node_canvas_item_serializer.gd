## GFNodeCanvasItemSerializer: CanvasItem 通用显示状态序列化器。
##
## 保存可见性与颜色调制等通用表现状态，不保存具体业务字段。
class_name GFNodeCanvasItemSerializer
extends GFNodeSerializer


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

	return {
		"visible": canvas_item.visible,
		"modulate": _color_to_array(canvas_item.modulate),
		"self_modulate": _color_to_array(canvas_item.self_modulate),
		"show_behind_parent": canvas_item.show_behind_parent,
		"top_level": canvas_item.top_level,
		"z_as_relative": canvas_item.z_as_relative,
		"z_index": canvas_item.z_index,
	}


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var canvas_item := node as CanvasItem
	if canvas_item == null:
		return make_result(false, "Node is not CanvasItem.")

	if payload.has("visible"):
		canvas_item.visible = bool(payload["visible"])
	if payload.has("modulate"):
		canvas_item.modulate = _array_to_color(payload["modulate"], canvas_item.modulate)
	if payload.has("self_modulate"):
		canvas_item.self_modulate = _array_to_color(payload["self_modulate"], canvas_item.self_modulate)
	if payload.has("show_behind_parent"):
		canvas_item.show_behind_parent = bool(payload["show_behind_parent"])
	if payload.has("top_level"):
		canvas_item.top_level = bool(payload["top_level"])
	if payload.has("z_as_relative"):
		canvas_item.z_as_relative = bool(payload["z_as_relative"])
	if payload.has("z_index"):
		canvas_item.z_index = int(payload["z_index"])
	return make_result(true)


# --- 私有/辅助方法 ---

func _color_to_array(value: Color) -> Array[float]:
	return [value.r, value.g, value.b, value.a]


func _array_to_color(value: Variant, fallback: Color) -> Color:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 4:
		return fallback
	return Color(float(array[0]), float(array[1]), float(array[2]), float(array[3]))
