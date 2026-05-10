## GFSteeringMath: 通用 steering 行为的纯算法集合。
##
## 提供 seek、flee、arrive、pursue、separation、cohesion、blend、priority 等
## 可组合计算，不负责把结果应用到具体 Node、物理体或业务状态。
class_name GFSteeringMath
extends RefCounted


# --- 常量 ---

const EPSILON: float = 0.00001


# --- 公共方法 ---

## 创建加速度结果。
## @param linear: 线性加速度。
## @param angular: 角加速度。
## @return 新加速度结果。
static func acceleration(linear: Vector3 = Vector3.ZERO, angular: float = 0.0) -> GFSteeringAcceleration:
	return GFSteeringAcceleration.new(linear, angular)


## 计算朝目标点加速的 seek 行为。
## @param agent: 代理状态。
## @param target_position: 目标位置。
## @return steering 加速度。
static func seek(agent: GFSteeringAgent, target_position: Vector3) -> GFSteeringAcceleration:
	if agent == null:
		return GFSteeringAcceleration.new()

	var direction := target_position - agent.position
	if direction.length_squared() <= EPSILON:
		return GFSteeringAcceleration.new()
	return GFSteeringAcceleration.new(direction.normalized() * agent.linear_acceleration_max)


## 计算远离目标点的 flee 行为。
## @param agent: 代理状态。
## @param target_position: 目标位置。
## @return steering 加速度。
static func flee(agent: GFSteeringAgent, target_position: Vector3) -> GFSteeringAcceleration:
	if agent == null:
		return GFSteeringAcceleration.new()

	var direction := agent.position - target_position
	if direction.length_squared() <= EPSILON:
		return GFSteeringAcceleration.new()
	return GFSteeringAcceleration.new(direction.normalized() * agent.linear_acceleration_max)


## 计算抵达目标点并在近处减速的 arrive 行为。
## @param agent: 代理状态。
## @param target_position: 目标位置。
## @param arrival_radius: 视为到达的半径。
## @param slow_radius: 开始减速的半径。
## @param time_to_target: 期望在多少秒内逼近目标速度。
## @return steering 加速度。
static func arrive(
	agent: GFSteeringAgent,
	target_position: Vector3,
	arrival_radius: float = 4.0,
	slow_radius: float = 64.0,
	time_to_target: float = 0.1
) -> GFSteeringAcceleration:
	if agent == null:
		return GFSteeringAcceleration.new()

	var direction := target_position - agent.position
	var distance := direction.length()
	if distance <= maxf(arrival_radius, 0.0) or distance <= EPSILON:
		return GFSteeringAcceleration.new(-agent.velocity).clamp_to(agent.linear_acceleration_max)

	var target_speed := agent.linear_speed_max
	if distance < maxf(slow_radius, arrival_radius):
		target_speed *= distance / maxf(slow_radius, EPSILON)

	var desired_velocity := direction.normalized() * target_speed
	var linear := (desired_velocity - agent.velocity) / maxf(time_to_target, EPSILON)
	return GFSteeringAcceleration.new(linear).clamp_to(agent.linear_acceleration_max)


## 计算追逐移动目标的 pursue 行为。
## @param agent: 代理状态。
## @param target_agent: 目标代理状态。
## @param max_prediction_seconds: 最大预测秒数。
## @return steering 加速度。
static func pursue(
	agent: GFSteeringAgent,
	target_agent: GFSteeringAgent,
	max_prediction_seconds: float = 1.0
) -> GFSteeringAcceleration:
	if agent == null or target_agent == null:
		return GFSteeringAcceleration.new()

	var prediction := _predict_seconds(agent, target_agent, max_prediction_seconds)
	return seek(agent, target_agent.position + target_agent.velocity * prediction)


## 计算逃离移动目标的 evade 行为。
## @param agent: 代理状态。
## @param target_agent: 目标代理状态。
## @param max_prediction_seconds: 最大预测秒数。
## @return steering 加速度。
static func evade(
	agent: GFSteeringAgent,
	target_agent: GFSteeringAgent,
	max_prediction_seconds: float = 1.0
) -> GFSteeringAcceleration:
	if agent == null or target_agent == null:
		return GFSteeringAcceleration.new()

	var prediction := _predict_seconds(agent, target_agent, max_prediction_seconds)
	return flee(agent, target_agent.position + target_agent.velocity * prediction)


## 计算面向目标点的角加速度。
## @param agent: 代理状态。
## @param target_position: 目标位置。
## @param use_z_axis: 为 true 时使用 x/z 平面，否则使用 x/y 平面。
## @param align_tolerance: 视为对齐的角度阈值。
## @param slow_angle: 开始减速的角度。
## @param time_to_target: 期望在多少秒内逼近目标角速度。
## @return steering 加速度。
static func face(
	agent: GFSteeringAgent,
	target_position: Vector3,
	use_z_axis: bool = false,
	align_tolerance: float = 0.001,
	slow_angle: float = 0.5,
	time_to_target: float = 0.1
) -> GFSteeringAcceleration:
	if agent == null:
		return GFSteeringAcceleration.new()

	var direction := target_position - agent.position
	if direction.length_squared() <= EPSILON:
		return GFSteeringAcceleration.new()

	return align(
		agent,
		_direction_to_orientation(direction, use_z_axis),
		align_tolerance,
		slow_angle,
		time_to_target
	)


## 计算朝当前速度方向转向的角加速度。
## @param agent: 代理状态。
## @param use_z_axis: 为 true 时使用 x/z 平面，否则使用 x/y 平面。
## @param align_tolerance: 视为对齐的角度阈值。
## @param slow_angle: 开始减速的角度。
## @param time_to_target: 期望在多少秒内逼近目标角速度。
## @return steering 加速度。
static func look_where_you_go(
	agent: GFSteeringAgent,
	use_z_axis: bool = false,
	align_tolerance: float = 0.001,
	slow_angle: float = 0.5,
	time_to_target: float = 0.1
) -> GFSteeringAcceleration:
	if agent == null or agent.velocity.length_squared() <= EPSILON:
		return GFSteeringAcceleration.new()
	return align(
		agent,
		_direction_to_orientation(agent.velocity, use_z_axis),
		align_tolerance,
		slow_angle,
		time_to_target
	)


## 计算对齐指定朝向的角加速度。
## @param agent: 代理状态。
## @param target_orientation: 目标朝向弧度。
## @param align_tolerance: 视为对齐的角度阈值。
## @param slow_angle: 开始减速的角度。
## @param time_to_target: 期望在多少秒内逼近目标角速度。
## @return steering 加速度。
static func align(
	agent: GFSteeringAgent,
	target_orientation: float,
	align_tolerance: float = 0.001,
	slow_angle: float = 0.5,
	time_to_target: float = 0.1
) -> GFSteeringAcceleration:
	if agent == null:
		return GFSteeringAcceleration.new()

	var rotation := _map_to_pi(target_orientation - agent.orientation)
	var rotation_size := absf(rotation)
	if rotation_size <= align_tolerance:
		return GFSteeringAcceleration.new(Vector3.ZERO, -agent.angular_velocity).clamp_to(
			-1.0,
			agent.angular_acceleration_max
		)

	var target_rotation_speed := agent.angular_speed_max
	if rotation_size < maxf(slow_angle, align_tolerance):
		target_rotation_speed *= rotation_size / maxf(slow_angle, EPSILON)
	target_rotation_speed *= signf(rotation)

	var angular := (target_rotation_speed - agent.angular_velocity) / maxf(time_to_target, EPSILON)
	return GFSteeringAcceleration.new(Vector3.ZERO, angular).clamp_to(-1.0, agent.angular_acceleration_max)


## 计算邻居分离行为。
## @param agent: 代理状态。
## @param neighbors: 邻居代理列表。
## @param decay_coefficient: 距离衰减系数。
## @param max_distance: 最大影响距离；小于等于 0 时使用双方半径之和。
## @return steering 加速度。
static func separation(
	agent: GFSteeringAgent,
	neighbors: Array[GFSteeringAgent],
	decay_coefficient: float = 1.0,
	max_distance: float = -1.0
) -> GFSteeringAcceleration:
	if agent == null:
		return GFSteeringAcceleration.new()

	var result := GFSteeringAcceleration.new()
	for neighbor: GFSteeringAgent in neighbors:
		if neighbor == null or neighbor == agent:
			continue

		var direction := agent.position - neighbor.position
		var distance := direction.length()
		var effective_distance := max_distance
		if effective_distance <= 0.0:
			effective_distance = agent.radius + neighbor.radius
		if distance <= EPSILON or distance > effective_distance:
			continue

		var strength := minf(decay_coefficient / (distance * distance), agent.linear_acceleration_max)
		result.linear += direction.normalized() * strength

	return result.clamp_to(agent.linear_acceleration_max)


## 计算朝邻居中心靠拢的 cohesion 行为。
## @param agent: 代理状态。
## @param neighbors: 邻居代理列表。
## @return steering 加速度。
static func cohesion(agent: GFSteeringAgent, neighbors: Array[GFSteeringAgent]) -> GFSteeringAcceleration:
	if agent == null:
		return GFSteeringAcceleration.new()

	var center := Vector3.ZERO
	var count := 0
	for neighbor: GFSteeringAgent in neighbors:
		if neighbor == null or neighbor == agent:
			continue
		center += neighbor.position
		count += 1

	if count <= 0:
		return GFSteeringAcceleration.new()
	return seek(agent, center / float(count))


## 混合多个 steering 加速度。
## @param accelerations: 加速度列表。
## @param weights: 对应权重；缺失时使用 1。
## @param max_linear: 最大线性加速度；小于 0 时不限制。
## @param max_angular: 最大角加速度；小于 0 时不限制。
## @return 混合后的加速度。
static func blend(
	accelerations: Array[GFSteeringAcceleration],
	weights: Array[float] = [],
	max_linear: float = -1.0,
	max_angular: float = -1.0
) -> GFSteeringAcceleration:
	var result := GFSteeringAcceleration.new()
	for index: int in range(accelerations.size()):
		var acceleration_item := accelerations[index]
		var weight := weights[index] if index < weights.size() else 1.0
		result.add_scaled(acceleration_item, weight)
	return result.clamp_to(max_linear, max_angular)


## 从多个 steering 加速度中选择第一个超过阈值的结果。
## @param accelerations: 加速度列表。
## @param threshold: 非零阈值。
## @return 第一个有效加速度；没有时返回零加速度。
static func priority(
	accelerations: Array[GFSteeringAcceleration],
	threshold: float = 0.001
) -> GFSteeringAcceleration:
	for acceleration_item: GFSteeringAcceleration in accelerations:
		if acceleration_item != null and not acceleration_item.is_zero(threshold):
			return acceleration_item.duplicate_acceleration()
	return GFSteeringAcceleration.new()


## 获取半径内的邻居代理。
## @param agent: 代理状态。
## @param candidates: 候选代理列表。
## @param radius: 查询半径；小于 0 时使用 agent.radius。
## @return 半径内邻居列表。
static func radius_neighbors(
	agent: GFSteeringAgent,
	candidates: Array[GFSteeringAgent],
	radius: float = -1.0
) -> Array[GFSteeringAgent]:
	var result: Array[GFSteeringAgent] = []
	if agent == null:
		return result

	var effective_radius := agent.radius if radius < 0.0 else radius
	var radius_squared := effective_radius * effective_radius
	for candidate: GFSteeringAgent in candidates:
		if candidate == null or candidate == agent:
			continue
		if agent.position.distance_squared_to(candidate.position) <= radius_squared:
			result.append(candidate)
	return result


## 计算路径跟随的下一个目标点。
## @param agent: 代理状态。
## @param path: 路径点列表。
## @param path_offset: 沿路径前进的距离。
## @return 路径上的目标点；路径为空时返回代理当前位置。
static func path_follow_target(
	agent: GFSteeringAgent,
	path: Array[Vector3],
	path_offset: float = 0.0
) -> Vector3:
	if agent == null or path.is_empty():
		return Vector3.ZERO if agent == null else agent.position
	if path.size() == 1:
		return path[0]

	var closest := _find_closest_path_projection(agent.position, path)
	return _advance_along_path(path, int(closest["segment_index"]), float(closest["segment_t"]), path_offset)


# --- 私有/辅助方法 ---

static func _predict_seconds(
	agent: GFSteeringAgent,
	target_agent: GFSteeringAgent,
	max_prediction_seconds: float
) -> float:
	var direction := target_agent.position - agent.position
	var distance := direction.length()
	var speed := agent.velocity.length()
	if speed <= EPSILON:
		return maxf(max_prediction_seconds, 0.0)
	return minf(distance / speed, maxf(max_prediction_seconds, 0.0))


static func _direction_to_orientation(direction: Vector3, use_z_axis: bool) -> float:
	if use_z_axis:
		return atan2(direction.x, direction.z)
	return atan2(direction.y, direction.x)


static func _map_to_pi(angle: float) -> float:
	var mapped := fmod(angle + PI, TAU)
	if mapped < 0.0:
		mapped += TAU
	return mapped - PI


static func _find_closest_path_projection(position: Vector3, path: Array[Vector3]) -> Dictionary:
	var best_distance_squared := INF
	var best_segment_index := 0
	var best_t := 0.0

	for index: int in range(path.size() - 1):
		var start := path[index]
		var end := path[index + 1]
		var segment := end - start
		var length_squared := segment.length_squared()
		var t := 0.0
		if length_squared > EPSILON:
			t = clampf((position - start).dot(segment) / length_squared, 0.0, 1.0)
		var projection := start + segment * t
		var distance_squared := position.distance_squared_to(projection)
		if distance_squared < best_distance_squared:
			best_distance_squared = distance_squared
			best_segment_index = index
			best_t = t

	return {
		"segment_index": best_segment_index,
		"segment_t": best_t,
	}


static func _advance_along_path(
	path: Array[Vector3],
	segment_index: int,
	segment_t: float,
	distance: float
) -> Vector3:
	var index := clampi(segment_index, 0, path.size() - 2)
	var current := path[index].lerp(path[index + 1], clampf(segment_t, 0.0, 1.0))
	var remaining := maxf(distance, 0.0)

	while remaining > EPSILON and index < path.size() - 1:
		var end := path[index + 1]
		var segment_remaining := current.distance_to(end)
		if remaining <= segment_remaining:
			var direction := (end - current).normalized()
			return current + direction * remaining
		remaining -= segment_remaining
		index += 1
		if index >= path.size() - 1:
			return path[path.size() - 1]
		current = path[index]

	return current
