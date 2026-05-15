## GFSteeringBehaviorStack: 资源化 steering 行为组合。
##
## 以 blend 或 priority 模式组合 GFSteeringBehaviorResource。它只返回加速度结果，
## 不负责移动节点、应用物理或解释项目 AI 状态。
class_name GFSteeringBehaviorStack
extends Resource


# --- 枚举 ---

## 行为组合方式。
enum CompositionMode {
	## 按权重混合所有行为。
	BLEND,
	## 选择第一个超过阈值的行为。
	PRIORITY,
}


# --- 常量 ---

const GFSteeringBehaviorResourceBase = preload("res://addons/gf/standard/foundation/math/gf_steering_behavior_resource.gd")


# --- 导出变量 ---

## 组合方式。
@export var mode: CompositionMode = CompositionMode.BLEND

## 行为列表。
@export var behaviors: Array[GFSteeringBehaviorResourceBase] = []

## 混合后最大线性加速度；小于 0 时使用 agent 上限。
@export var max_linear: float = -1.0

## 混合后最大角加速度；小于 0 时使用 agent 上限。
@export var max_angular: float = -1.0

## Priority 模式下判断非零的阈值。
@export var priority_threshold: float = 0.001


# --- 公共方法 ---

## 添加行为。
## @param behavior: 行为资源。
## @return 添加成功返回 true。
func add_behavior(behavior: GFSteeringBehaviorResourceBase) -> bool:
	if behavior == null:
		return false
	behaviors.append(behavior)
	return true


## 检查是否没有有效行为。
## @return 没有有效行为时返回 true。
func is_empty() -> bool:
	for behavior: GFSteeringBehaviorResourceBase in behaviors:
		if behavior != null and behavior.enabled:
			return false
	return true


## 计算组合后的 steering 加速度。
## @param agent: 代理状态。
## @param context: 传给每个行为的动态上下文。
## @return steering 加速度。
func calculate(agent: GFSteeringAgent, context: Dictionary = {}) -> GFSteeringAcceleration:
	if agent == null:
		return GFSteeringAcceleration.new()
	match mode:
		CompositionMode.PRIORITY:
			return _calculate_priority(agent, context)
		_:
			return _calculate_blend(agent, context)


## 创建配置副本。
## @return 新行为组合。
func duplicate_stack() -> Resource:
	var stack := get_script().new() as Resource
	stack.set("mode", mode)
	stack.set("max_linear", max_linear)
	stack.set("max_angular", max_angular)
	stack.set("priority_threshold", priority_threshold)
	var duplicated_behaviors: Array[GFSteeringBehaviorResourceBase] = []
	for behavior: GFSteeringBehaviorResourceBase in behaviors:
		duplicated_behaviors.append(behavior.duplicate_behavior() as GFSteeringBehaviorResourceBase if behavior != null else null)
	stack.set("behaviors", duplicated_behaviors)
	return stack


# --- 私有/辅助方法 ---

func _calculate_blend(agent: GFSteeringAgent, context: Dictionary) -> GFSteeringAcceleration:
	var accelerations: Array[GFSteeringAcceleration] = []
	var weights: Array[float] = []
	for behavior: GFSteeringBehaviorResourceBase in behaviors:
		if behavior == null or not behavior.enabled:
			continue
		accelerations.append(behavior.calculate(agent, context))
		weights.append(behavior.weight)
	return GFSteeringMath.blend(
		accelerations,
		weights,
		_resolve_max_linear(agent),
		_resolve_max_angular(agent)
	)


func _calculate_priority(agent: GFSteeringAgent, context: Dictionary) -> GFSteeringAcceleration:
	for behavior: GFSteeringBehaviorResourceBase in behaviors:
		if behavior == null or not behavior.enabled:
			continue
		var acceleration := behavior.calculate(agent, context)
		if behavior.weight != 1.0:
			acceleration.add_scaled(acceleration.duplicate_acceleration(), behavior.weight - 1.0)
		if not acceleration.is_zero(priority_threshold):
			return acceleration.clamp_to(_resolve_max_linear(agent), _resolve_max_angular(agent))
	return GFSteeringAcceleration.new()


func _resolve_max_linear(agent: GFSteeringAgent) -> float:
	return agent.linear_acceleration_max if max_linear < 0.0 else max_linear


func _resolve_max_angular(agent: GFSteeringAgent) -> float:
	return agent.angular_acceleration_max if max_angular < 0.0 else max_angular
