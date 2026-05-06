## GFNodeTransform2DSerializer: Node2D Transform 序列化器。
##
## 以 JSON 友好的标量数组保存 position、rotation 与 scale。
class_name GFNodeTransform2DSerializer
extends GFNodeSerializer


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.transform_2d"
	display_name = "Transform 2D"


# --- 公共方法 ---

## 判断序列化器是否支持指定节点。
## @param node: 目标节点。
func supports_node(node: Node) -> bool:
	return node is Node2D


## 采集节点的可保存状态。
## @param node: 目标节点。
## @param _context: 操作上下文字典，默认实现不直接使用。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	var node_2d := node as Node2D
	if node_2d == null:
		return {}

	return {
		"position": [node_2d.position.x, node_2d.position.y],
		"rotation": node_2d.rotation,
		"scale": [node_2d.scale.x, node_2d.scale.y],
		"z_index": node_2d.z_index,
	}


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var node_2d := node as Node2D
	if node_2d == null:
		return make_result(false, "Node is not Node2D.")

	if payload.has("position"):
		node_2d.position = _array_to_vector2(payload["position"], node_2d.position)
	if payload.has("rotation"):
		node_2d.rotation = float(payload["rotation"])
	if payload.has("scale"):
		node_2d.scale = _array_to_vector2(payload["scale"], node_2d.scale)
	if payload.has("z_index"):
		node_2d.z_index = int(payload["z_index"])
	return make_result(true)


# --- 私有/辅助方法 ---

func _array_to_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 2:
		return fallback
	return Vector2(float(array[0]), float(array[1]))
