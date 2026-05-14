## 测试 GFNodeRangeSerializer 与 GFNodeTransform2DSerializer 的采集与应用。
extends GutTest


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
