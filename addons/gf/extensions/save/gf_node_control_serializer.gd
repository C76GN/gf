## GFNodeControlSerializer: Control 通用布局状态序列化器。
##
## 保存 Control 的锚点、偏移、尺寸和交互开关，适合简单 UI 状态恢复。
class_name GFNodeControlSerializer
extends GFNodeSerializer


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

	return {
		"anchor_left": control.anchor_left,
		"anchor_top": control.anchor_top,
		"anchor_right": control.anchor_right,
		"anchor_bottom": control.anchor_bottom,
		"offset_left": control.offset_left,
		"offset_top": control.offset_top,
		"offset_right": control.offset_right,
		"offset_bottom": control.offset_bottom,
		"pivot_offset": _vector2_to_array(control.pivot_offset),
		"rotation": control.rotation,
		"scale": _vector2_to_array(control.scale),
		"mouse_filter": control.mouse_filter,
		"focus_mode": control.focus_mode,
	}


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var control := node as Control
	if control == null:
		return make_result(false, "Node is not Control.")

	if payload.has("anchor_left"):
		control.anchor_left = float(payload["anchor_left"])
	if payload.has("anchor_top"):
		control.anchor_top = float(payload["anchor_top"])
	if payload.has("anchor_right"):
		control.anchor_right = float(payload["anchor_right"])
	if payload.has("anchor_bottom"):
		control.anchor_bottom = float(payload["anchor_bottom"])
	if payload.has("offset_left"):
		control.offset_left = float(payload["offset_left"])
	if payload.has("offset_top"):
		control.offset_top = float(payload["offset_top"])
	if payload.has("offset_right"):
		control.offset_right = float(payload["offset_right"])
	if payload.has("offset_bottom"):
		control.offset_bottom = float(payload["offset_bottom"])
	if payload.has("pivot_offset"):
		control.pivot_offset = _array_to_vector2(payload["pivot_offset"], control.pivot_offset)
	if payload.has("rotation"):
		control.rotation = float(payload["rotation"])
	if payload.has("scale"):
		control.scale = _array_to_vector2(payload["scale"], control.scale)
	if payload.has("mouse_filter"):
		control.mouse_filter = int(payload["mouse_filter"]) as Control.MouseFilter
	if payload.has("focus_mode"):
		control.focus_mode = int(payload["focus_mode"]) as Control.FocusMode
	return make_result(true)


# --- 私有/辅助方法 ---

func _vector2_to_array(value: Vector2) -> Array[float]:
	return [value.x, value.y]


func _array_to_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 2:
		return fallback
	return Vector2(float(array[0]), float(array[1]))
