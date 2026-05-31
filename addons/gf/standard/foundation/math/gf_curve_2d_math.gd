## GFCurve2DMath: Curve2D 与折线的纯算法辅助。
##
## 提供路径长度、归一化采样、点距简化和基础闭合形状生成，不持有节点状态，
## 也不解释碰撞、渲染或编辑器交互语义。
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
