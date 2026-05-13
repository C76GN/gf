## 测试 Combat 扩展的通用发射体节点与策略资源。
extends GutTest


# --- 常量 ---

const GFLinearProjectileMotionBase = preload("res://addons/gf/extensions/official/combat/projectiles/gf_linear_projectile_motion.gd")
const GFHomingProjectileMotionBase = preload("res://addons/gf/extensions/official/combat/projectiles/gf_homing_projectile_motion.gd")
const GFProjectile2DBase = preload("res://addons/gf/extensions/official/combat/projectiles/gf_projectile_2d.gd")
const GFProjectile3DBase = preload("res://addons/gf/extensions/official/combat/projectiles/gf_projectile_3d.gd")
const GFProjectileLifetimePolicyBase = preload("res://addons/gf/extensions/official/combat/projectiles/gf_projectile_lifetime_policy.gd")


# --- 辅助子类 ---

class HitReceiver2D:
	extends Node2D

	var received_context: GFCombatHitContext = null

	func receive_hit(context: GFCombatHitContext) -> Dictionary:
		received_context = context
		return { "ok": true }


# --- 测试 ---

func test_projectile_2d_moves_with_linear_motion() -> void:
	var projectile := GFProjectile2DBase.new()
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	var motion := GFLinearProjectileMotionBase.new()
	motion.speed = 10.0
	motion.use_local_direction = false
	motion.direction_2d = Vector2.RIGHT
	projectile.motion = motion

	projectile.launch()
	projectile._physics_process(0.5)

	assert_eq(projectile.position, Vector2(5.0, 0.0), "直线移动策略应推进 2D 发射体。")

	projectile.free()


func test_projectile_lifetime_policy_finishes_after_elapsed_time() -> void:
	var projectile := GFProjectile2DBase.new()
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	var lifetime := GFProjectileLifetimePolicyBase.new()
	lifetime.max_seconds = 0.25
	projectile.lifetime_policy = lifetime

	projectile.launch()
	projectile._physics_process(0.3)

	assert_false(projectile.is_projectile_active(), "超过生命周期后应结束。")

	projectile.free()


func test_projectile_lifetime_policy_finishes_after_accepted_impacts() -> void:
	var projectile := GFProjectile2DBase.new()
	projectile.auto_launch_on_ready = false
	projectile.finish_on_impact = false
	projectile.queue_free_on_finish = false
	var lifetime := GFProjectileLifetimePolicyBase.new()
	lifetime.max_impacts = 2
	projectile.lifetime_policy = lifetime
	var receiver := HitReceiver2D.new()

	projectile.launch()
	projectile.send_impact_to(receiver)
	var first_context := projectile.get_projectile_context()
	projectile.send_impact_to(receiver)

	assert_eq(first_context.get("impact_count"), 1, "第一次成功命中后应记录命中次数。")
	assert_false(projectile.is_projectile_active(), "达到最大命中次数后应结束。")

	projectile.free()
	receiver.free()


func test_projectile_impact_sends_combat_hit_context() -> void:
	var projectile := GFProjectile2DBase.new()
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	projectile.finish_on_impact = true
	projectile.hit_id = &"projectile_hit"
	projectile.payload = { "kind": "test" }
	var receiver := HitReceiver2D.new()

	projectile.launch()
	projectile.send_impact_to(receiver)

	assert_not_null(receiver.received_context, "命中接收器应收到 GFCombatHitContext。")
	assert_eq(receiver.received_context.hit_id, &"projectile_hit", "命中 ID 应来自发射体节点。")
	assert_eq(receiver.received_context.payload.get("kind"), "test", "payload 应随命中上下文传递。")
	assert_false(projectile.is_projectile_active(), "finish_on_impact 开启时命中后应结束。")

	projectile.free()
	receiver.free()


func test_homing_motion_moves_toward_context_target_position() -> void:
	var projectile := GFProjectile2DBase.new()
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	var motion := GFHomingProjectileMotionBase.new()
	motion.speed = 10.0
	projectile.motion = motion

	projectile.launch({ "target_position_2d": Vector2(10.0, 0.0) })
	projectile._physics_process(0.5)

	assert_eq(projectile.position, Vector2(5.0, 0.0), "追踪移动策略应朝 2D 目标位置推进。")

	projectile.free()


func test_homing_motion_clamps_to_arrival_distance() -> void:
	var projectile := GFProjectile2DBase.new()
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	var motion := GFHomingProjectileMotionBase.new()
	motion.speed = 10.0
	motion.arrival_distance = 1.0
	motion.stop_when_reached = true
	projectile.motion = motion

	projectile.launch({ "target_position_2d": Vector2(3.0, 0.0) })
	projectile._physics_process(0.5)
	var context := projectile.get_projectile_context()

	assert_eq(projectile.position, Vector2(2.0, 0.0), "开启到达夹取时不应越过 arrival_distance。")
	assert_true(bool(context.get("target_reached", false)), "到达目标范围时应在上下文中标记。")

	projectile.free()


func test_linear_motion_supports_3d_projectiles() -> void:
	var projectile := GFProjectile3DBase.new()
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	var motion := GFLinearProjectileMotionBase.new()
	motion.speed = 4.0
	motion.use_local_direction = false
	motion.direction_3d = Vector3.FORWARD
	projectile.motion = motion

	projectile.launch()
	projectile._physics_process(0.5)

	assert_eq(projectile.position, Vector3(0.0, 0.0, -2.0), "直线移动策略应推进 3D 发射体。")

	projectile.free()
