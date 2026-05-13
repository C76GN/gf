## 测试通用 3D 重力场与采样器。
extends GutTest


func test_point_gravity_field_returns_acceleration_toward_origin() -> void:
	var field := GFGravityField3D.new()
	add_child_autofree(field)
	field.global_position = Vector3.ZERO
	field.acceleration = 10.0

	var acceleration := field.get_acceleration_at(Vector3(0.0, 5.0, 0.0))

	assert_almost_eq(acceleration.y, -10.0, 0.001, "点重力应朝向力场原点。")
	assert_almost_eq(acceleration.x, 0.0, 0.001)


func test_gravity_field_linear_falloff_respects_radius() -> void:
	var field := GFGravityField3D.new()
	add_child_autofree(field)
	field.acceleration = 10.0
	field.radius = 10.0
	field.falloff_mode = GFGravityField3D.FalloffMode.LINEAR

	assert_almost_eq(field.get_strength_at_distance(5.0), 5.0, 0.001, "线性衰减应按距离占比降低强度。")
	assert_almost_eq(field.get_strength_at_distance(11.0), 0.0, 0.001, "半径外应无力场强度。")


func test_gravity_probe_sums_group_fields() -> void:
	var field := GFGravityField3D.new()
	var probe := GFGravityProbe3D.new()
	add_child_autofree(field)
	add_child_autofree(probe)
	field.direction_mode = GFGravityField3D.DirectionMode.CONSTANT_DIRECTION
	field.constant_direction = Vector3.DOWN
	field.acceleration = 4.0
	probe.use_fallback_when_empty = false

	var acceleration := probe.sample()

	assert_almost_eq(acceleration.y, -4.0, 0.001, "采样器应汇总分组中的力场。")
	assert_eq(probe.get_up_direction(), Vector3.UP, "向上方向应与加速度方向相反。")
