## GFNodePropertySerializer: 通用节点属性序列化器。
##
## 通过显式属性白名单保存和恢复节点属性，适合项目层快速接入简单状态。
class_name GFNodePropertySerializer
extends GFNodeSerializer


# --- 导出变量 ---

## 需要保存的属性名。
@export var properties: PackedStringArray = PackedStringArray()

## 应用数据时遇到缺失属性是否跳过。
@export var skip_missing_properties: bool = true


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.property"


# --- 公共方法 ---

func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	if node == null:
		return {}

	var available := _get_property_names(node)
	var result: Dictionary = {}
	for property_name: String in properties:
		if not available.has(property_name):
			continue
		result[property_name] = node.get(property_name)
	return result


func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	if node == null:
		return make_result(false, "Node is null.")

	var available := _get_property_names(node)
	for property_variant: Variant in payload.keys():
		var property_name := String(property_variant)
		if not available.has(property_name):
			if skip_missing_properties:
				continue
			return make_result(false, "Missing property: %s" % property_name)
		node.set(property_name, payload[property_variant])

	return make_result(true)


# --- 私有/辅助方法 ---

func _get_property_names(node: Object) -> Dictionary:
	var result: Dictionary = {}
	for property: Dictionary in node.get_property_list():
		result[String(property.get("name", ""))] = true
	return result
