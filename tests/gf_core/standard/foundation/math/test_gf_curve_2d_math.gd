## 测试 GFCurve2DMath 的折线采样、简化和基础形状生成。
extends GutTest


# --- 常量 ---

const GF_CURVE_2D_MATH := preload("res://addons/gf/standard/foundation/math/gf_curve_2d_math.gd")


# --- 测试 ---

func test_polyline_length_and_sampling_use_distance_ratio() -> void:
	var points := PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(3.0, 4.0),
		Vector2(13.0, 4.0),
	])

	assert_almost_eq(GF_CURVE_2D_MATH.get_polyline_length(points), 15.0, 0.001)
	assert_eq(GF_CURVE_2D_MATH.sample_polyline(points, 0.0), Vector2.ZERO)
	assert_eq(GF_CURVE_2D_MATH.sample_polyline(points, 1.0), Vector2(13.0, 4.0))
	assert_eq(GF_CURVE_2D_MATH.sample_polyline(points, 5.0 / 15.0), Vector2(3.0, 4.0))
	assert_eq(GF_CURVE_2D_MATH.sample_polyline(points, 10.0 / 15.0), Vector2(8.0, 4.0))


func test_polyline_sampling_handles_empty_single_and_degenerate_inputs() -> void:
	assert_eq(GF_CURVE_2D_MATH.sample_polyline(PackedVector2Array(), 0.5), Vector2.ZERO)
	assert_eq(
		GF_CURVE_2D_MATH.sample_polyline(PackedVector2Array([Vector2(2.0, 3.0)]), 0.5),
		Vector2(2.0, 3.0)
	)
	assert_eq(
		GF_CURVE_2D_MATH.sample_polyline(PackedVector2Array([Vector2.ONE, Vector2.ONE]), 0.5),
		Vector2.ONE
	)


func test_simplify_polyline_by_distance_keeps_spacing_and_last_point() -> void:
	var points := PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(0.1, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.2, 0.0),
		Vector2(2.0, 0.0),
	])

	var simplified := GF_CURVE_2D_MATH.simplify_polyline_by_distance(points, 0.75)

	assert_eq(simplified, PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(2.0, 0.0),
	]))


func test_rect_curve_is_closed_and_reusable() -> void:
	var curve := Curve2D.new()
	var returned := GF_CURVE_2D_MATH.set_rect_curve(curve, Vector2(10.0, 4.0))

	assert_eq(returned, curve)
	assert_eq(curve.point_count, 5)
	assert_eq(curve.get_point_position(0), Vector2(-5.0, -2.0))
	assert_eq(curve.get_point_position(curve.point_count - 1), curve.get_point_position(0))
	assert_eq(GF_CURVE_2D_MATH.sample_curve(curve, 0.5), Vector2(5.0, 2.0))


func test_rounded_rect_curve_clamps_radius() -> void:
	var curve := GF_CURVE_2D_MATH.create_rect_curve(Vector2(10.0, 4.0), Vector2(99.0, 99.0))

	assert_eq(curve.point_count, 9)
	assert_eq(curve.get_point_position(0), Vector2(0.0, -2.0))
	assert_eq(curve.get_point_position(curve.point_count - 1), curve.get_point_position(0))


func test_ellipse_curve_is_closed_and_centered() -> void:
	var curve := GF_CURVE_2D_MATH.create_ellipse_curve(Vector2(10.0, 4.0), Vector2(1.0, 2.0))

	assert_eq(curve.point_count, 5)
	assert_eq(curve.get_point_position(0), Vector2(6.0, 2.0))
	assert_eq(curve.get_point_position(curve.point_count - 1), curve.get_point_position(0))
	assert_true(curve.get_baked_length() > 0.0)
