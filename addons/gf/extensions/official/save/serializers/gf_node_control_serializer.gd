## GFNodeControlSerializer: Control 通用布局状态序列化器。
##
## 保存 Control 的锚点、偏移、尺寸和交互开关，适合简单 UI 状态恢复。
class_name GFNodeControlSerializer
extends GFNodeSerializer


# --- 常量 ---

const _PROPERTY_SPECS: Array[Dictionary] = [
	{ "key": "anchor_left", "kind": &"float" },
	{ "key": "anchor_top", "kind": &"float" },
	{ "key": "anchor_right", "kind": &"float" },
	{ "key": "anchor_bottom", "kind": &"float" },
	{ "key": "offset_left", "kind": &"float" },
	{ "key": "offset_top", "kind": &"float" },
	{ "key": "offset_right", "kind": &"float" },
	{ "key": "offset_bottom", "kind": &"float" },
	{ "key": "pivot_offset", "kind": &"vector2" },
	{ "key": "rotation", "kind": &"float" },
	{ "key": "scale", "kind": &"vector2" },
	{ "key": "mouse_filter", "kind": &"int" },
	{ "key": "focus_mode", "kind": &"int" },
]


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.control"
	display_name = "Control"


# --- 公共方法 ---

## 判断序列化器是否支持指定节点。
## @param node: 目标节点。
func supports_node(node: Node) -> bool:
	return node is Control


## 采集节点的可保存状态。
## @param node: 目标节点。
## @param _context: 操作上下文字典，默认实现不直接使用。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	var control := node as Control
	if control == null:
		return {}

	return _gather_property_specs(control, _PROPERTY_SPECS)


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var control := node as Control
	if control == null:
		return make_result(false, "Node is not Control.")

	_apply_property_specs(control, payload, _PROPERTY_SPECS)
	return make_result(true)
