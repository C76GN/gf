## GFNodeRangeSerializer: Range 通用数值状态序列化器。
##
## 保存滑条、进度条等 Range 派生控件的通用数值参数。
class_name GFNodeRangeSerializer
extends GFNodeSerializer


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

	return {
		"value": range.value,
		"min_value": range.min_value,
		"max_value": range.max_value,
		"step": range.step,
		"page": range.page,
		"rounded": range.rounded,
		"allow_greater": range.allow_greater,
		"allow_lesser": range.allow_lesser,
	}


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var range := node as Range
	if range == null:
		return make_result(false, "Node is not Range.")

	if payload.has("min_value"):
		range.min_value = float(payload["min_value"])
	if payload.has("max_value"):
		range.max_value = float(payload["max_value"])
	if payload.has("step"):
		range.step = float(payload["step"])
	if payload.has("page"):
		range.page = float(payload["page"])
	if payload.has("rounded"):
		range.rounded = bool(payload["rounded"])
	if payload.has("allow_greater"):
		range.allow_greater = bool(payload["allow_greater"])
	if payload.has("allow_lesser"):
		range.allow_lesser = bool(payload["allow_lesser"])
	if payload.has("value"):
		range.value = float(payload["value"])
	return make_result(true)
