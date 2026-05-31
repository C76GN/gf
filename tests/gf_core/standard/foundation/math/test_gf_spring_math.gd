## 测试 GFSpringMath 的标量、角度和向量弹簧步进。
extends GutTest

# --- 测试 ---

func test_step_float_moves_towards_target_and_tracks_velocity() -> void:
	var value: float = 0.0
	var velocity: float = 0.0

	for _index: int in range(12):
		var state: Dictionary = GFSpringMath.step_float(
			value,
			velocity,
			1.0,
			1.0 / 60.0,
			4.0,
			1.0
		)
		value = GFVariantData.get_option_float(state, "value")
		velocity = GFVariantData.get_option_float(state, "velocity")

	assert_true(value > 0.0, "弹簧应向目标推进。")
	assert_true(value < 1.2, "临界阻尼附近不应在短时间内产生大幅过冲。")
	assert_true(absf(velocity) > 0.0, "返回速度应可继续用于下一帧。")


func test_step_float_keeps_state_when_delta_is_zero() -> void:
	var state: Dictionary = GFSpringMath.step_float(
		2.0,
		-3.0,
		10.0,
		0.0,
		5.0,
		1.0
	)

	assert_eq(GFVariantData.get_option_float(state, "value"), 2.0)
	assert_eq(GFVariantData.get_option_float(state, "velocity"), -3.0)


func test_step_angle_uses_shortest_direction() -> void:
	var current_radians: float = deg_to_rad(350.0)
	var target_radians: float = deg_to_rad(10.0)

	var state: Dictionary = GFSpringMath.step_angle(
		current_radians,
		0.0,
		target_radians,
		1.0 / 60.0,
		4.0,
		1.0
	)
	var value: float = GFVariantData.get_option_float(state, "value")

	assert_true(value > current_radians, "350 度到 10 度应沿正向 20 度短弧推进。")
	assert_true(value < current_radians + deg_to_rad(20.0), "单步不应直接跳到短弧终点之后。")


func test_step_vector2_applies_component_spring() -> void:
	var state: Dictionary = GFSpringMath.step_vector2(
		Vector2.ZERO,
		Vector2.ZERO,
		Vector2(2.0, -4.0),
		1.0 / 60.0,
		4.0,
		1.0
	)
	var value: Vector2 = GFVariantData.get_option_vector2(state, "value")
	var velocity: Vector2 = GFVariantData.get_option_vector2(state, "velocity")

	assert_true(value.x > 0.0)
	assert_true(value.y < 0.0)
	assert_true(velocity.length() > 0.0)


func test_step_vector3_sanitizes_frequency_and_damping() -> void:
	var state: Dictionary = GFSpringMath.step_vector3(
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3.ONE,
		1.0 / 60.0,
		-5.0,
		-1.0
	)
	var value: Vector3 = GFVariantData.get_option_vector3(state, "value")
	var velocity: Vector3 = GFVariantData.get_option_vector3(state, "velocity")

	assert_false(is_nan(value.x))
	assert_false(is_nan(value.y))
	assert_false(is_nan(value.z))
	assert_false(is_nan(velocity.x))
	assert_false(is_nan(velocity.y))
	assert_false(is_nan(velocity.z))
