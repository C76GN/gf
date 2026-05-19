## 测试 GFNodeRangeSerializer 与 GFNodeTransform2DSerializer 的采集与应用。
extends GutTest


# --- 常量 ---

const GFNodePropertySerializerBase = preload("res://addons/gf/extensions/save/serializers/gf_node_property_serializer.gd")


# --- 测试方法 ---

func test_node_serializer_supports_gdscript_class_name_string() -> void:
	var serializer := GFNodeSerializer.new()
	serializer.supported_class_name = "GFNodeStateMachine"
	var node := GFNodeStateMachine.new()
	add_child_autofree(node)

	assert_true(serializer.supports_node(node), "supported_class_name 应支持 GDScript class_name。")


func test_range_serializer_supports_and_gather_apply() -> void:
	var ser := GFNodeRangeSerializer.new()
	var slider := HSlider.new()
	add_child_autofree(slider)
	slider.min_value = 0.0
	slider.max_value = 10.0
	slider.step = 0.5
	slider.value = 3.0
	assert_true(ser.supports_node(slider))
	var payload := ser.gather(slider)
	assert_eq(float(payload.get("value")), 3.0)
	slider.value = 0.0
	assert_true(bool(ser.apply(slider, payload).get("ok", false)))
	assert_almost_eq(slider.value, 3.0, 0.0001)


func test_range_serializer_rejects_non_range_on_apply() -> void:
	var ser := GFNodeRangeSerializer.new()
	var node := Node.new()
	add_child_autofree(node)
	var result := ser.apply(node, { "value": 1.0 })
	assert_false(bool(result.get("ok", true)))


func test_transform_2d_serializer_roundtrip() -> void:
	var ser := GFNodeTransform2DSerializer.new()
	var n := Node2D.new()
	add_child_autofree(n)
	n.position = Vector2(1.0, 2.0)
	n.rotation = 0.25
	n.scale = Vector2(1.5, 0.5)
	n.z_index = 3
	assert_true(ser.supports_node(n))
	var payload := ser.gather(n)
	n.position = Vector2.ZERO
	n.rotation = 0.0
	n.scale = Vector2.ONE
	n.z_index = 0
	assert_true(bool(ser.apply(n, payload).get("ok", false)))
	assert_almost_eq(n.position.x, 1.0, 0.0001)
	assert_almost_eq(n.rotation, 0.25, 0.0001)
	assert_eq(n.z_index, 3)


func test_property_serializer_roundtrips_godot_values_through_json_payload() -> void:
	var serializer := GFNodePropertySerializerBase.new()
	serializer.properties = PackedStringArray(["position"])
	var node := Node2D.new()
	add_child_autofree(node)
	node.position = Vector2(8.0, -2.5)

	var payload := serializer.gather(node)
	var json_payload := JSON.parse_string(JSON.stringify(payload)) as Dictionary
	node.position = Vector2.ZERO
	var result := serializer.apply(node, json_payload)

	assert_true(bool(result.get("ok", false)), "JSON 往返后的属性 payload 应能应用。")
	assert_eq(node.position, Vector2(8.0, -2.5), "Vector2 属性应从类型化 JSON payload 恢复。")


func test_property_serializer_restores_external_resource_reference() -> void:
	var resource_path := "user://gf_property_serializer_resource.tres"
	var resource := Resource.new()
	resource.resource_name = "PropertyResource"
	assert_eq(ResourceSaver.save(resource, resource_path), OK, "测试资源应能保存到 user://。")

	var holder := ResourcePropertyNode.new()
	add_child_autofree(holder)
	holder.resource_value = ResourceLoader.load(resource_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	var serializer := GFNodePropertySerializerBase.new()
	serializer.properties = PackedStringArray(["resource_value"])

	var payload := serializer.gather(holder)
	var json_payload := JSON.parse_string(JSON.stringify(payload)) as Dictionary
	holder.resource_value = null
	var result := serializer.apply(holder, json_payload)

	assert_true(bool(result.get("ok", false)), "Resource 引用 payload 应能应用。")
	assert_not_null(holder.resource_value, "Resource 属性应被重新加载。")
	assert_eq(holder.resource_value.resource_path, resource_path, "Resource 属性应按保存路径恢复。")

	var absolute_path := ProjectSettings.globalize_path(resource_path)
	if FileAccess.file_exists(resource_path):
		DirAccess.remove_absolute(absolute_path)


# --- 内部类 ---

class ResourcePropertyNode extends Node:
	var resource_value: Resource = null


	func _get_property_list() -> Array[Dictionary]:
		return [{
			"name": "resource_value",
			"type": TYPE_OBJECT,
			"class_name": "Resource",
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
		}]


	func _get(property: StringName) -> Variant:
		if property == &"resource_value":
			return resource_value
		return null


	func _set(property: StringName, value: Variant) -> bool:
		if property == &"resource_value":
			resource_value = value as Resource
			return true
		return false
