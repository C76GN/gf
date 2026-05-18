## GFProjectile2D: 可组合移动策略的 2D 发射体命中节点。
##
## 它继承 GFHitBox2D，命中仍通过 GFCombatHitContext 发送给 receive_hit()。
## 节点只负责移动、寿命和碰撞触发，不解释伤害、阵营或生命值规则。
class_name GFProjectile2D
extends GFHitBox2D


# --- 信号 ---

## 发射体启动时发出。
## @param projectile: 当前发射体。
signal projectile_launched(projectile: GFProjectile2D)

## 发射体结束时发出。
## @param projectile: 当前发射体。
## @param reason: 结束原因。
signal projectile_finished(projectile: GFProjectile2D, reason: StringName)


# --- 常量 ---

# --- 导出变量 ---

## ready 后是否自动启动本次发射。
@export var auto_launch_on_ready: bool = true

## 移动策略。应实现 setup(projectile, context) 与 step(projectile, delta, context)。
@export var motion: Resource = null

## 生命周期策略。应实现 setup(projectile, context) 与 should_finish(projectile, elapsed, context)。
@export var lifetime_policy: Resource = null

## 命中任意 receive_hit() 接收器后是否结束。
@export var finish_on_impact: bool = true

## 结束时是否 queue_free。使用对象池时通常应关闭。
@export var queue_free_on_finish: bool = true


# --- 私有变量 ---

var _active: bool = false
var _elapsed_seconds: float = 0.0
var _projectile_context: Dictionary = {}


# --- Godot 生命周期方法 ---

func _ready() -> void:
	super._ready()
	_connect_impact_signals()
	set_physics_process(false)
	if auto_launch_on_ready:
		launch()


func _physics_process(delta: float) -> void:
	if not _active:
		return

	_elapsed_seconds += delta
	if motion != null and motion.has_method(&"step"):
		motion.call("step", self, delta, _projectile_context)
	if (
		lifetime_policy != null
		and lifetime_policy.has_method(&"should_finish")
		and bool(lifetime_policy.call("should_finish", self, _elapsed_seconds, _projectile_context))
	):
		finish(&"lifetime")


# --- 公共方法 ---

## 启动或重置本次发射。
## @param projectile_context: 本次发射的上下文字典。
func launch(projectile_context: Dictionary = {}) -> void:
	_active = true
	_elapsed_seconds = 0.0
	_projectile_context = projectile_context.duplicate(true)
	if motion != null and motion.has_method(&"setup"):
		motion.call("setup", self, _projectile_context)
	if lifetime_policy != null and lifetime_policy.has_method(&"setup"):
		lifetime_policy.call("setup", self, _projectile_context)
	set_physics_process(true)
	projectile_launched.emit(self)


## 结束本次发射。
## @param reason: 结束原因。
func finish(reason: StringName = &"finished") -> void:
	if not _active:
		return

	_active = false
	set_physics_process(false)
	projectile_finished.emit(self, reason)
	if queue_free_on_finish:
		queue_free()


## 判断发射体是否处于已启动状态。
## @return 已启动且未结束时返回 true。
func is_projectile_active() -> bool:
	return _active


## 获取本次发射经过的秒数。
## @return 经过的秒数。
func get_elapsed_seconds() -> float:
	return _elapsed_seconds


## 获取本次发射上下文副本。
## @return 上下文字典副本。
func get_projectile_context() -> Dictionary:
	return _projectile_context.duplicate(true)


## 向碰撞候选对象发送一次发射体命中。
## @param candidate: 碰撞候选对象，可为接收器或其子节点。
func send_impact_to(candidate: Object) -> void:
	_send_impact_to_candidate(candidate)


# --- 私有/辅助方法 ---

func _connect_impact_signals() -> void:
	if not area_entered.is_connected(_on_collision_candidate_entered):
		area_entered.connect(_on_collision_candidate_entered)
	if not body_entered.is_connected(_on_collision_candidate_entered):
		body_entered.connect(_on_collision_candidate_entered)


func _send_impact_to_candidate(candidate: Object) -> void:
	if not _active or not enabled:
		return

	var receiver := _resolve_receiver_from_candidate(candidate)
	if receiver == null:
		return
	var report_value: Variant = _resolve_collision_dispatch_host().call("send_to", receiver, null, &"")
	if not report_value is Dictionary:
		return
	var report := report_value as Dictionary
	var accepted := bool(report.get("ok", false))
	_record_impact(report)
	if finish_on_impact and accepted:
		finish(&"impact")
	elif _lifetime_should_finish():
		finish(&"lifetime")


func _resolve_receiver_from_candidate(candidate: Object) -> Object:
	if candidate == null or candidate == self:
		return null
	if candidate.has_method(&"receive_hit"):
		return candidate

	var node := candidate as Node
	while node != null:
		if node.has_method(&"receive_hit"):
			return node
		node = node.get_parent()
	return null


func _record_impact(report: Dictionary) -> void:
	_projectile_context["impact_attempt_count"] = int(_projectile_context.get("impact_attempt_count", 0)) + 1
	if bool(report.get("ok", false)):
		_projectile_context["impact_count"] = int(_projectile_context.get("impact_count", 0)) + 1


func _lifetime_should_finish() -> bool:
	return (
		lifetime_policy != null
		and lifetime_policy.has_method(&"should_finish")
		and bool(lifetime_policy.call("should_finish", self, _elapsed_seconds, _projectile_context))
	)


# --- 信号处理函数 ---

func _on_collision_candidate_entered(candidate: Node) -> void:
	_send_impact_to_candidate(candidate)
