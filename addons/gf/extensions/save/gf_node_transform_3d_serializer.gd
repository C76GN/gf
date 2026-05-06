## GFNodeTransform3DSerializer: Node3D Transform 序列化器。
##
## 以 JSON 友好的标量数组保存 position、rotation 与 scale。
class_name GFNodeTransform3DSerializer
extends GFNodeSerializer


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.transform_3d"
	display_name = "Transform 3D"


# --- 公共方法 ---

## 判断序列化器是否支持指定节点。
## @param node: 目标节点。
func supports_node(node: Node) -> bool:
	return node is Node3D


## 采集节点的可保存状态。
## @param node: 目标节点。
## @param _context: 操作上下文字典，默认实现不直接使用。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	var node_3d := node as Node3D
	if node_3d == null:
		return {}

	return {
		"position": _vector3_to_array(node_3d.position),
		"rotation": _vector3_to_array(node_3d.rotation),
		"scale": _vector3_to_array(node_3d.scale),
	}


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var node_3d := node as Node3D
	if node_3d == null:
		return make_result(false, "Node is not Node3D.")

	if payload.has("position"):
		node_3d.position = _array_to_vector3(payload["position"], node_3d.position)
	if payload.has("rotation"):
		node_3d.rotation = _array_to_vector3(payload["rotation"], node_3d.rotation)
	if payload.has("scale"):
		node_3d.scale = _array_to_vector3(payload["scale"], node_3d.scale)
	return make_result(true)


# --- 私有/辅助方法 ---

func _vector3_to_array(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _array_to_vector3(value: Variant, fallback: Vector3) -> Vector3:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 3:
		return fallback
	return Vector3(float(array[0]), float(array[1]), float(array[2]))
