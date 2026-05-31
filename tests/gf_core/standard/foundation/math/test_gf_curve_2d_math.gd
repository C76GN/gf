## 测试 GFCurve2DMath 的折线采样、简化和基础形状生成。
extends GutTest

# --- 测试 ---

func test_polyline_length_and_sampling_use_distance_ratio() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(3.0, 4.0),
		Vector2(13.0, 4.0),
	])

	assert_almost_eq(GFCurve2DMath.get_polyline_length(points), 15.0, 0.001)
	assert_eq(GFCurve2DMath.sample_polyline(points, 0.0), Vector2.ZERO)
	assert_eq(GFCurve2DMath.sample_polyline(points, 1.0), Vector2(13.0, 4.0))
	assert_eq(GFCurve2DMath.sample_polyline(points, 5.0 / 15.0), Vector2(3.0, 4.0))
	assert_eq(GFCurve2DMath.sample_polyline(points, 10.0 / 15.0), Vector2(8.0, 4.0))


func test_polyline_sampling_handles_empty_single_and_degenerate_inputs() -> void:
	assert_eq(GFCurve2DMath.sample_polyline(PackedVector2Array(), 0.5), Vector2.ZERO)
	assert_eq(
		GFCurve2DMath.sample_polyline(PackedVector2Array([Vector2(2.0, 3.0)]), 0.5),
		Vector2(2.0, 3.0)
	)
	assert_eq(
		GFCurve2DMath.sample_polyline(PackedVector2Array([Vector2.ONE, Vector2.ONE]), 0.5),
		Vector2.ONE
	)


func test_simplify_polyline_by_distance_keeps_spacing_and_last_point() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(0.1, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.2, 0.0),
		Vector2(2.0, 0.0),
	])

	var simplified: PackedVector2Array = GFCurve2DMath.simplify_polyline_by_distance(points, 0.75)

	assert_eq(simplified, PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(2.0, 0.0),
	]))


func test_make_dashed_polyline_segments_splits_straight_line() -> void:
	var points: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2(10.0, 0.0)])

	var segments: Array[PackedVector2Array] = GFCurve2DMath.make_dashed_polyline_segments(
		points,
		3.0,
		2.0
	)

	assert_eq(segments.size(), 2)
	assert_eq(segments[0], PackedVector2Array([Vector2.ZERO, Vector2(3.0, 0.0)]))
	assert_eq(segments[1], PackedVector2Array([Vector2(5.0, 0.0), Vector2(8.0, 0.0)]))


func test_make_dashed_polyline_segments_continues_pattern_across_corners() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2.ZERO,
		Vector2(6.0, 0.0),
		Vector2(6.0, 6.0),
	])

	var segments: Array[PackedVector2Array] = GFCurve2DMath.make_dashed_polyline_segments(
		points,
		8.0,
		2.0
	)

	assert_eq(segments.size(), 3)
	assert_eq(segments[0], PackedVector2Array([Vector2.ZERO, Vector2(6.0, 0.0)]))
	assert_eq(segments[1], PackedVector2Array([Vector2(6.0, 0.0), Vector2(6.0, 2.0)]))
	assert_eq(segments[2], PackedVector2Array([Vector2(6.0, 4.0), Vector2(6.0, 6.0)]))


func test_make_dashed_polyline_segments_supports_offset() -> void:
	var points: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2(10.0, 0.0)])

	var segments: Array[PackedVector2Array] = GFCurve2DMath.make_dashed_polyline_segments(
		points,
		3.0,
		2.0,
		false,
		2.0
	)

	assert_eq(segments.size(), 3)
	assert_eq(segments[0], PackedVector2Array([Vector2.ZERO, Vector2(1.0, 0.0)]))
	assert_eq(segments[1], PackedVector2Array([Vector2(3.0, 0.0), Vector2(6.0, 0.0)]))
	assert_eq(segments[2], PackedVector2Array([Vector2(8.0, 0.0), Vector2(10.0, 0.0)]))


func test_make_dashed_polyline_segments_handles_closed_and_solid_inputs() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2.ZERO,
		Vector2(2.0, 0.0),
		Vector2(2.0, 2.0),
	])

	var segments: Array[PackedVector2Array] = GFCurve2DMath.make_dashed_polyline_segments(
		points,
		1.0,
		0.0,
		true
	)

	assert_eq(segments.size(), 3)
	assert_eq(segments[0], PackedVector2Array([Vector2.ZERO, Vector2(2.0, 0.0)]))
	assert_eq(segments[1], PackedVector2Array([Vector2(2.0, 0.0), Vector2(2.0, 2.0)]))
	assert_eq(segments[2], PackedVector2Array([Vector2(2.0, 2.0), Vector2.ZERO]))
	assert_true(GFCurve2DMath.make_dashed_polyline_segments(points, 0.0, 1.0).is_empty())


func test_round_polygon_points_generates_corner_anchors_and_samples() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(4.0, 0.0),
		Vector2(4.0, 4.0),
		Vector2(0.0, 4.0),
	])

	var rounded: PackedVector2Array = GFCurve2DMath.round_polygon_points(points, 1.0, 2)

	assert_eq(rounded.size(), 12, "每个顶点应输出两侧锚点和细分点。")
	assert_eq(rounded[0], Vector2(0.0, 1.0), "第一个顶点应先输出朝向前一顶点的锚点。")
	assert_eq(rounded[2], Vector2(1.0, 0.0), "第一个顶点应再输出朝向后一顶点的锚点。")
	assert_true(rounded[1].x > 0.0 and rounded[1].y > 0.0, "细分点应位于圆角内部。")


func test_round_polygon_points_clamps_radius_and_ignores_duplicate_closing_point() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(4.0, 0.0),
		Vector2(4.0, 4.0),
		Vector2(0.0, 4.0),
		Vector2(0.0, 0.0),
	])

	var rounded: PackedVector2Array = GFCurve2DMath.round_polygon_points(points, 99.0, 1)

	assert_eq(rounded.size(), 8, "重复闭合点不应作为额外顶点参与圆角生成。")
	assert_eq(rounded[0], Vector2(0.0, 2.0), "过大半径应被相邻边长度限制。")
	assert_eq(rounded[1], Vector2(2.0, 0.0), "过大半径应被相邻边长度限制。")


func test_round_polygon_points_returns_unclosed_copy_for_degenerate_inputs() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2.ZERO,
		Vector2.RIGHT,
		Vector2.ZERO,
	])

	var rounded: PackedVector2Array = GFCurve2DMath.round_polygon_points(points, 0.0, 8)

	assert_eq(rounded, PackedVector2Array([Vector2.ZERO, Vector2.RIGHT]), "无效输入应返回去除重复末点后的副本。")


func test_rect_curve_is_closed_and_reusable() -> void:
	var curve: Curve2D = Curve2D.new()
	var returned: Curve2D = GFCurve2DMath.set_rect_curve(curve, Vector2(10.0, 4.0))

	assert_eq(returned, curve)
	assert_eq(curve.point_count, 5)
	assert_eq(curve.get_point_position(0), Vector2(-5.0, -2.0))
	assert_eq(curve.get_point_position(curve.point_count - 1), curve.get_point_position(0))
	assert_eq(GFCurve2DMath.sample_curve(curve, 0.5), Vector2(5.0, 2.0))


func test_rounded_rect_curve_clamps_radius() -> void:
	var curve: Curve2D = GFCurve2DMath.create_rect_curve(Vector2(10.0, 4.0), Vector2(99.0, 99.0))

	assert_eq(curve.point_count, 9)
	assert_eq(curve.get_point_position(0), Vector2(0.0, -2.0))
	assert_eq(curve.get_point_position(curve.point_count - 1), curve.get_point_position(0))


func test_ellipse_curve_is_closed_and_centered() -> void:
	var curve: Curve2D = GFCurve2DMath.create_ellipse_curve(Vector2(10.0, 4.0), Vector2(1.0, 2.0))

	assert_eq(curve.point_count, 5)
	assert_eq(curve.get_point_position(0), Vector2(6.0, 2.0))
	assert_eq(curve.get_point_position(curve.point_count - 1), curve.get_point_position(0))
	assert_true(curve.get_baked_length() > 0.0)
