## GFCurve2DMath: Curve2D 与折线的纯算法辅助。
##
## 提供路径长度、归一化采样、点距简化、虚线切分和基础闭合形状生成，
## 不持有节点状态，也不解释碰撞、渲染或编辑器交互语义。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.19.0
class_name GFCurve2DMath
extends RefCounted


# --- 常量 ---

## 圆弧贝塞尔控制点近似系数。
## [br]
## @api public
const CIRCLE_BEZIER_KAPPA: float = 0.5522847498307936

const _DASH_EPSILON: float = 0.00001


# --- 公共方法 ---

## 计算折线总长度。
## [br]
## @api public
## [br]
## @param points: 折线点序列。
## [br]
## @return 折线长度；少于两个点时返回 0。
static func get_polyline_length(points: PackedVector2Array) -> float:
	var length: float = 0.0
	for index: int in range(1, points.size()):
		length += points[index - 1].distance_to(points[index])
	return length


## 按 0 到 1 的比例采样折线。
## [br]
## @api public
## [br]
## @param points: 折线点序列。
## [br]
## @param ratio: 归一化采样位置；会被限制在 0 到 1。
## [br]
## @param total_length: 可选预计算长度；小于 0 时内部计算。
## [br]
## @return 采样点；空折线返回 Vector2.ZERO。
static func sample_polyline(
	points: PackedVector2Array,
	ratio: float,
	total_length: float = -1.0
) -> Vector2:
	if points.is_empty():
		return Vector2.ZERO
	if points.size() == 1:
		return points[0]

	var clamped_ratio: float = clampf(ratio, 0.0, 1.0)
	if clamped_ratio <= 0.0:
		return points[0]
	if clamped_ratio >= 1.0:
		return points[points.size() - 1]

	var length: float = total_length if total_length >= 0.0 else get_polyline_length(points)
	if length <= 0.0:
		return points[points.size() - 1]

	var target_distance: float = length * clamped_ratio
	var travelled: float = 0.0
	for index: int in range(1, points.size()):
		var from_point: Vector2 = points[index - 1]
		var to_point: Vector2 = points[index]
		var segment_length: float = from_point.distance_to(to_point)
		if segment_length <= 0.0:
			continue

		if travelled + segment_length >= target_distance:
			var segment_ratio: float = (target_distance - travelled) / segment_length
			return from_point.lerp(to_point, segment_ratio)
		travelled += segment_length

	return points[points.size() - 1]


## 按 0 到 1 的比例采样 Curve2D 的 baked 路径。
## [br]
## @api public
## [br]
## @param curve: 目标曲线。
## [br]
## @param ratio: 归一化采样位置；会被限制在 0 到 1。
## [br]
## @param cubic: 是否使用 Curve2D.sample_baked() 的三次插值。
## [br]
## @return 采样点；曲线为空或无点时返回 Vector2.ZERO。
static func sample_curve(curve: Curve2D, ratio: float, cubic: bool = false) -> Vector2:
	if curve == null or curve.point_count <= 0:
		return Vector2.ZERO
	if curve.point_count == 1:
		return curve.get_point_position(0)

	var length: float = curve.get_baked_length()
	if length <= 0.0:
		return curve.get_point_position(curve.point_count - 1)

	return curve.sample_baked(length * clampf(ratio, 0.0, 1.0), cubic)


## 按最小点距简化折线，适合压缩手绘、采样或导入得到的密集点。
## [br]
## @api public
## [br]
## @param points: 原始折线点序列。
## [br]
## @param min_distance: 相邻保留点的最小距离；小于等于 0 时返回原始副本。
## [br]
## @param keep_last: 是否始终保留末点。
## [br]
## @return 简化后的折线点序列。
static func simplify_polyline_by_distance(
	points: PackedVector2Array,
	min_distance: float,
	keep_last: bool = true
) -> PackedVector2Array:
	if points.size() <= 2 or min_distance <= 0.0:
		return points.duplicate()

	var simplified: PackedVector2Array = PackedVector2Array()
	var _first_point_appended: bool = simplified.append(points[0])
	var min_distance_squared: float = min_distance * min_distance
	for index: int in range(1, points.size()):
		if points[index].distance_squared_to(simplified[simplified.size() - 1]) >= min_distance_squared:
			var _point_appended: bool = simplified.append(points[index])

	var last_point: Vector2 = points[points.size() - 1]
	if keep_last and simplified[simplified.size() - 1] != last_point:
		var _last_point_appended: bool = simplified.append(last_point)
	return simplified


## 按 dash/gap 模式把折线切分为可见线段。
## [br]
## @api public
## [br]
## @param points: 折线点序列。
## [br]
## @param dash_length: 每段可见长度；小于等于 0 或接近 0 时返回空数组。
## [br]
## @param gap_length: 每段间隔长度；小于等于 0 或接近 0 时返回原折线的非零长度段。
## [br]
## @param closed: 是否把末点连回首点；少于三个点时不会追加闭合段。
## [br]
## @param offset: 沿路径推进 dash/gap 模式的偏移距离，可用于滚动或动画。
## [br]
## @return 可见线段数组；每项是包含起点和终点的 PackedVector2Array。
## [br]
## @schema return: Array[PackedVector2Array]，每项包含 from/to 两个 Vector2，顶点处会拆分以避免跨角连线。
static func make_dashed_polyline_segments(
	points: PackedVector2Array,
	dash_length: float,
	gap_length: float,
	closed: bool = false,
	offset: float = 0.0
) -> Array[PackedVector2Array]:
	var visible_segments: Array[PackedVector2Array] = []
	if points.size() < 2 or dash_length <= _DASH_EPSILON:
		return visible_segments

	var normalized_gap_length: float = maxf(gap_length, 0.0)
	if normalized_gap_length <= _DASH_EPSILON:
		_append_source_polyline_segments(visible_segments, points, closed)
		return visible_segments

	var path_points: PackedVector2Array = _get_polyline_points(points, closed)
	var pattern_length: float = dash_length + normalized_gap_length
	var phase: float = fposmod(offset, pattern_length)
	var in_dash: bool = phase < dash_length
	var phase_remaining: float = dash_length - phase if in_dash else pattern_length - phase

	for index: int in range(1, path_points.size()):
		var from_point: Vector2 = path_points[index - 1]
		var to_point: Vector2 = path_points[index]
		var segment_vector: Vector2 = to_point - from_point
		var segment_length: float = segment_vector.length()
		if segment_length <= _DASH_EPSILON:
			continue

		var segment_direction: Vector2 = segment_vector / segment_length
		var travelled: float = 0.0
		while travelled < segment_length - _DASH_EPSILON:
			if phase_remaining <= _DASH_EPSILON:
				in_dash = not in_dash
				phase_remaining = dash_length if in_dash else normalized_gap_length
				continue

			var step_length: float = minf(phase_remaining, segment_length - travelled)
			if step_length <= _DASH_EPSILON:
				break

			if in_dash:
				_append_visible_polyline_segment(
					visible_segments,
					from_point + segment_direction * travelled,
					from_point + segment_direction * (travelled + step_length)
				)
			travelled += step_length
			phase_remaining -= step_length

	return visible_segments


## 为闭合多边形生成圆角点序列。
## [br]
## @api public
## [br]
## @param points: 多边形顶点序列；不要求末点重复，若末点重复会忽略。
## [br]
## @param radius: 每个顶点两侧的圆角裁切距离；会按相邻边长度限制。
## [br]
## @param corner_detail: 每个圆角的细分数量；1 表示只输出两侧锚点。
## [br]
## @param uniform_corners: 是否用相邻两边的较短可用距离统一限制圆角。
## [br]
## @return 圆角化后的多边形点序列；无效输入会返回去除重复末点后的原始点副本。
static func round_polygon_points(
	points: PackedVector2Array,
	radius: float,
	corner_detail: int = 8,
	uniform_corners: bool = true
) -> PackedVector2Array:
	var source_points: PackedVector2Array = _get_unclosed_polygon_points(points)
	if source_points.size() < 3 or radius <= 0.0 or corner_detail <= 0:
		return source_points

	var result: PackedVector2Array = PackedVector2Array()
	var point_count: int = source_points.size()
	for index: int in range(point_count):
		var point: Vector2 = source_points[index]
		var previous_point: Vector2 = source_points[posmod(index - 1, point_count)]
		var next_point: Vector2 = source_points[(index + 1) % point_count]
		_append_rounded_polygon_corner(
			result,
			point,
			previous_point,
			next_point,
			radius,
			corner_detail,
			uniform_corners
		)
	return result


## 创建闭合矩形 Curve2D。
## [br]
## @api public
## [br]
## @param size: 矩形尺寸。
## [br]
## @param radius: 圆角半径；会限制到尺寸的一半。
## [br]
## @param offset: 曲线中心偏移。
## [br]
## @param rotation: 曲线旋转弧度。
## [br]
## @return 新建的 Curve2D。
static func create_rect_curve(
	size: Vector2,
	radius: Vector2 = Vector2.ZERO,
	offset: Vector2 = Vector2.ZERO,
	rotation: float = 0.0
) -> Curve2D:
	return set_rect_curve(Curve2D.new(), size, radius, offset, rotation)


## 将已有 Curve2D 改写为闭合矩形。
## [br]
## @api public
## [br]
## @param curve: 要写入的曲线；为空时会创建新曲线。
## [br]
## @param size: 矩形尺寸。
## [br]
## @param radius: 圆角半径；会限制到尺寸的一半。
## [br]
## @param offset: 曲线中心偏移。
## [br]
## @param rotation: 曲线旋转弧度。
## [br]
## @return 写入后的 Curve2D。
static func set_rect_curve(
	curve: Curve2D,
	size: Vector2,
	radius: Vector2 = Vector2.ZERO,
	offset: Vector2 = Vector2.ZERO,
	rotation: float = 0.0
) -> Curve2D:
	var target_curve: Curve2D = curve if curve != null else Curve2D.new()
	var half_size: Vector2 = Vector2(absf(size.x), absf(size.y)) * 0.5
	var clamped_radius: Vector2 = Vector2(
		clampf(absf(radius.x), 0.0, half_size.x),
		clampf(absf(radius.y), 0.0, half_size.y)
	)

	target_curve.set_block_signals(true)
	target_curve.clear_points()
	if half_size.x <= 0.0 or half_size.y <= 0.0:
		target_curve.add_point(offset)
	elif clamped_radius == Vector2.ZERO:
		_add_corner_points(target_curve, half_size, offset, rotation)
	else:
		_add_rounded_rect_points(target_curve, half_size, clamped_radius, offset, rotation)
	target_curve.set_block_signals(false)
	target_curve.changed.emit()
	return target_curve


## 创建闭合椭圆 Curve2D。
## [br]
## @api public
## [br]
## @param size: 椭圆外接框尺寸。
## [br]
## @param offset: 曲线中心偏移。
## [br]
## @param rotation: 曲线旋转弧度。
## [br]
## @return 新建的 Curve2D。
static func create_ellipse_curve(
	size: Vector2,
	offset: Vector2 = Vector2.ZERO,
	rotation: float = 0.0
) -> Curve2D:
	return set_ellipse_curve(Curve2D.new(), size, offset, rotation)


## 将已有 Curve2D 改写为闭合椭圆。
## [br]
## @api public
## [br]
## @param curve: 要写入的曲线；为空时会创建新曲线。
## [br]
## @param size: 椭圆外接框尺寸。
## [br]
## @param offset: 曲线中心偏移。
## [br]
## @param rotation: 曲线旋转弧度。
## [br]
## @return 写入后的 Curve2D。
static func set_ellipse_curve(
	curve: Curve2D,
	size: Vector2,
	offset: Vector2 = Vector2.ZERO,
	rotation: float = 0.0
) -> Curve2D:
	var target_curve: Curve2D = curve if curve != null else Curve2D.new()
	var radius: Vector2 = Vector2(absf(size.x), absf(size.y)) * 0.5

	target_curve.set_block_signals(true)
	target_curve.clear_points()
	if radius.x <= 0.0 or radius.y <= 0.0:
		target_curve.add_point(offset)
	else:
		_add_ellipse_points(target_curve, radius, offset, rotation)
	target_curve.set_block_signals(false)
	target_curve.changed.emit()
	return target_curve


# --- 私有/辅助方法 ---

static func _add_corner_points(curve: Curve2D, half_size: Vector2, offset: Vector2, rotation: float) -> void:
	var top_left: Vector2 = Vector2(-half_size.x, -half_size.y)
	var top_right: Vector2 = Vector2(half_size.x, -half_size.y)
	var bottom_right: Vector2 = Vector2(half_size.x, half_size.y)
	var bottom_left: Vector2 = Vector2(-half_size.x, half_size.y)
	curve.add_point(_transform_point(top_left, offset, rotation))
	curve.add_point(_transform_point(top_right, offset, rotation))
	curve.add_point(_transform_point(bottom_right, offset, rotation))
	curve.add_point(_transform_point(bottom_left, offset, rotation))
	curve.add_point(_transform_point(top_left, offset, rotation))


static func _add_rounded_rect_points(
	curve: Curve2D,
	half_size: Vector2,
	radius: Vector2,
	offset: Vector2,
	rotation: float
) -> void:
	var left: float = -half_size.x
	var right: float = half_size.x
	var top: float = -half_size.y
	var bottom: float = half_size.y
	var rx: float = radius.x
	var ry: float = radius.y
	var ox: float = rx * CIRCLE_BEZIER_KAPPA
	var oy: float = ry * CIRCLE_BEZIER_KAPPA

	_add_transformed_point(curve, Vector2(right - rx, top), Vector2.ZERO, Vector2(ox, 0.0), offset, rotation)
	_add_transformed_point(curve, Vector2(right, top + ry), Vector2(0.0, -oy), Vector2.ZERO, offset, rotation)
	_add_transformed_point(curve, Vector2(right, bottom - ry), Vector2.ZERO, Vector2(0.0, oy), offset, rotation)
	_add_transformed_point(curve, Vector2(right - rx, bottom), Vector2(ox, 0.0), Vector2.ZERO, offset, rotation)
	_add_transformed_point(curve, Vector2(left + rx, bottom), Vector2.ZERO, Vector2(-ox, 0.0), offset, rotation)
	_add_transformed_point(curve, Vector2(left, bottom - ry), Vector2(0.0, oy), Vector2.ZERO, offset, rotation)
	_add_transformed_point(curve, Vector2(left, top + ry), Vector2.ZERO, Vector2(0.0, -oy), offset, rotation)
	_add_transformed_point(curve, Vector2(left + rx, top), Vector2(-ox, 0.0), Vector2.ZERO, offset, rotation)
	_add_transformed_point(curve, Vector2(right - rx, top), Vector2.ZERO, Vector2(ox, 0.0), offset, rotation)


static func _add_ellipse_points(
	curve: Curve2D,
	radius: Vector2,
	offset: Vector2,
	rotation: float
) -> void:
	var ox: float = radius.x * CIRCLE_BEZIER_KAPPA
	var oy: float = radius.y * CIRCLE_BEZIER_KAPPA
	_add_transformed_point(curve, Vector2(radius.x, 0.0), Vector2.ZERO, Vector2(0.0, oy), offset, rotation)
	_add_transformed_point(curve, Vector2.ZERO + Vector2(0.0, radius.y), Vector2(ox, 0.0), Vector2(-ox, 0.0), offset, rotation)
	_add_transformed_point(curve, Vector2(-radius.x, 0.0), Vector2(0.0, oy), Vector2(0.0, -oy), offset, rotation)
	_add_transformed_point(curve, Vector2(0.0, -radius.y), Vector2(-ox, 0.0), Vector2(ox, 0.0), offset, rotation)
	_add_transformed_point(curve, Vector2(radius.x, 0.0), Vector2(0.0, -oy), Vector2.ZERO, offset, rotation)


static func _add_transformed_point(
	curve: Curve2D,
	position: Vector2,
	in_handle: Vector2,
	out_handle: Vector2,
	offset: Vector2,
	rotation: float
) -> void:
	curve.add_point(
		_transform_point(position, offset, rotation),
		in_handle.rotated(rotation),
		out_handle.rotated(rotation)
	)


static func _transform_point(point: Vector2, offset: Vector2, rotation: float) -> Vector2:
	return point.rotated(rotation) + offset


static func _get_unclosed_polygon_points(points: PackedVector2Array) -> PackedVector2Array:
	var result: PackedVector2Array = points.duplicate()
	if result.size() > 1 and result[0] == result[result.size() - 1]:
		result.remove_at(result.size() - 1)
	return result


static func _get_polyline_points(points: PackedVector2Array, closed: bool) -> PackedVector2Array:
	var result: PackedVector2Array = points.duplicate()
	if closed and result.size() > 2 and result[0] != result[result.size() - 1]:
		var _first_point_appended: bool = result.append(result[0])
	return result


static func _append_source_polyline_segments(
	target: Array[PackedVector2Array],
	points: PackedVector2Array,
	closed: bool
) -> void:
	for index: int in range(1, points.size()):
		_append_visible_polyline_segment(target, points[index - 1], points[index])
	if closed and points.size() > 2:
		_append_visible_polyline_segment(target, points[points.size() - 1], points[0])


static func _append_visible_polyline_segment(
	target: Array[PackedVector2Array],
	from_point: Vector2,
	to_point: Vector2
) -> void:
	if from_point.distance_squared_to(to_point) <= _DASH_EPSILON * _DASH_EPSILON:
		return
	target.append(PackedVector2Array([from_point, to_point]))


static func _append_rounded_polygon_corner(
	target: PackedVector2Array,
	point: Vector2,
	previous_point: Vector2,
	next_point: Vector2,
	radius: float,
	corner_detail: int,
	uniform_corners: bool
) -> void:
	var previous_length: float = point.distance_to(previous_point)
	var next_length: float = point.distance_to(next_point)
	if previous_length <= 0.0 or next_length <= 0.0:
		var _point_appended: bool = target.append(point)
		return

	var previous_distance: float = radius
	var next_distance: float = radius
	if uniform_corners:
		var shared_limit: float = maxf(minf(previous_length, next_length) * 0.5, 0.0)
		previous_distance = minf(radius, shared_limit)
		next_distance = previous_distance
	else:
		previous_distance = minf(radius, maxf(previous_length * 0.5, 0.0))
		next_distance = minf(radius, maxf(next_length * 0.5, 0.0))

	if previous_distance <= 0.0 or next_distance <= 0.0:
		var _point_appended: bool = target.append(point)
		return

	var anchor_previous: Vector2 = point + point.direction_to(previous_point) * previous_distance
	var anchor_next: Vector2 = point + point.direction_to(next_point) * next_distance
	var _previous_appended: bool = target.append(anchor_previous)
	for step: int in range(1, corner_detail):
		var ratio: float = float(step) / float(corner_detail)
		var corner_point: Vector2 = anchor_previous.bezier_interpolate(
			point.lerp(anchor_previous, 0.5),
			point.lerp(anchor_next, 0.5),
			anchor_next,
			ratio
		)
		var _corner_appended: bool = target.append(corner_point)
	var _next_appended: bool = target.append(anchor_next)
