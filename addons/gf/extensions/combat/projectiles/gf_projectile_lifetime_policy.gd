## GFProjectileLifetimePolicy: 发射体生命周期策略。
##
## 默认支持按时间和距离结束。项目可继承后叠加自定义结束条件。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFProjectileLifetimePolicy
extends Resource


# --- 导出变量 ---

## 最长存活时间。小于等于 0 表示不按时间结束。
## [br]
## @api public
@export var max_seconds: float = 0.0

## 最远移动距离。小于等于 0 表示不按距离结束。
## [br]
## @api public
@export var max_distance: float = 0.0

## 最大成功命中次数。小于等于 0 表示不按命中次数结束。
## [br]
## @api public
@export var max_impacts: int = 0


# --- 公共方法 ---

## 发射体启动时调用。
## [br]
## @api public
## [br]
## @param projectile: 发射体节点。
## [br]
## @param projectile_context: 本次发射的上下文字典。
## [br]
## @schema projectile_context: Dictionary，本次发射上下文；会写入初始位置和 impact_count。
func setup(projectile: Node, projectile_context: Dictionary = {}) -> void:
	if not projectile_context.has("impact_count"):
		projectile_context["impact_count"] = 0
	if projectile is Node2D:
		var node_2d: Node2D = projectile
		projectile_context["spawn_position_2d"] = node_2d.global_position if node_2d.is_inside_tree() else node_2d.position
	elif projectile is Node3D:
		var node_3d: Node3D = projectile
		projectile_context["spawn_position_3d"] = node_3d.global_position if node_3d.is_inside_tree() else node_3d.position
	_setup(projectile, projectile_context)


## 判断发射体是否应结束。
## [br]
## @api public
## [br]
## @param projectile: 发射体节点。
## [br]
## @param elapsed_seconds: 本次发射已经运行的秒数。
## [br]
## @param projectile_context: 本次发射的上下文字典。
## [br]
## @return 应结束时返回 true。
## [br]
## @schema projectile_context: Dictionary，本次发射上下文；用于读取初始位置和 impact_count。
func should_finish(projectile: Node, elapsed_seconds: float, projectile_context: Dictionary = {}) -> bool:
	if max_seconds > 0.0 and elapsed_seconds >= max_seconds:
		return true
	if max_distance > 0.0 and _get_travel_distance(projectile, projectile_context) >= max_distance:
		return true
	if max_impacts > 0 and GFVariantData.get_option_int(projectile_context, "impact_count", 0) >= max_impacts:
		return true
	return _should_finish(projectile, elapsed_seconds, projectile_context)


# --- 可重写钩子 / 虚方法 ---

## 发射体启动扩展点。
## [br]
## @api protected
## [br]
## @param _projectile: 发射体节点。
## [br]
## @param _projectile_context: 本次发射上下文字典。
## [br]
## @schema _projectile_context: Dictionary，本次发射上下文；可写入生命周期策略状态。
func _setup(_projectile: Node, _projectile_context: Dictionary = {}) -> void:
	pass


## 自定义结束条件扩展点。
## [br]
## @api protected
## [br]
## @param _projectile: 发射体节点。
## [br]
## @param _elapsed_seconds: 本次发射已经运行的秒数。
## [br]
## @param _projectile_context: 本次发射上下文字典。
## [br]
## @return 应结束时返回 true。
## [br]
## @schema _projectile_context: Dictionary，本次发射上下文；可读取生命周期策略状态。
func _should_finish(
	_projectile: Node,
	_elapsed_seconds: float,
	_projectile_context: Dictionary = {}
) -> bool:
	return false


# --- 私有/辅助方法 ---

func _get_travel_distance(projectile: Node, projectile_context: Dictionary) -> float:
	if projectile is Node2D and projectile_context.has("spawn_position_2d"):
		var node_2d: Node2D = projectile
		var current_position_2d: Vector2 = node_2d.global_position if node_2d.is_inside_tree() else node_2d.position
		var spawn_position_2d: Vector2 = GFVariantData.get_option_vector2(projectile_context, "spawn_position_2d")
		return current_position_2d.distance_to(spawn_position_2d)
	if projectile is Node3D and projectile_context.has("spawn_position_3d"):
		var node_3d: Node3D = projectile
		var current_position_3d: Vector3 = node_3d.global_position if node_3d.is_inside_tree() else node_3d.position
		var spawn_position_3d: Vector3 = GFVariantData.get_option_vector3(projectile_context, "spawn_position_3d")
		return current_position_3d.distance_to(spawn_position_3d)
	return 0.0
