## 测试 Combat 扩展的通用发射体节点与策略资源。
extends GutTest


# --- 常量 ---

const GFLinearProjectileMotionBase = preload("res://addons/gf/extensions/combat/projectiles/gf_linear_projectile_motion.gd")
const GFHomingProjectileMotionBase = preload("res://addons/gf/extensions/combat/projectiles/gf_homing_projectile_motion.gd")
const GFProjectileBurstPattern2DBase = preload("res://addons/gf/extensions/combat/projectiles/gf_projectile_burst_pattern_2d.gd")
const GFProjectileCatalogBase = preload("res://addons/gf/extensions/combat/projectiles/gf_projectile_catalog.gd")
const GFProjectileEmitter2DBase = preload("res://addons/gf/extensions/combat/projectiles/gf_projectile_emitter_2d.gd")
const GFProjectileLineSpawnPattern2DBase = preload("res://addons/gf/extensions/combat/projectiles/gf_projectile_line_spawn_pattern_2d.gd")
const GFProjectile2DBase = preload("res://addons/gf/extensions/combat/projectiles/gf_projectile_2d.gd")
const GFProjectile3DBase = preload("res://addons/gf/extensions/combat/projectiles/gf_projectile_3d.gd")
const GFProjectileLifetimePolicyBase = preload("res://addons/gf/extensions/combat/projectiles/gf_projectile_lifetime_policy.gd")


# --- 辅助子类 ---

class HitReceiver2D:
	extends Node2D

	var received_context: GFCombatHitContext = null

	func receive_hit(context: GFCombatHitContext) -> Dictionary:
		received_context = context
		return { "ok": true }


class RejectingHitReceiver2D:
	extends Node2D

	func receive_hit(_context: GFCombatHitContext) -> Dictionary:
		return {
			"ok": false,
			"reason": "blocked",
		}


class HitReceiver3D:
	extends Node3D

	func receive_hit(_context: GFCombatHitContext) -> Dictionary:
		return { "ok": true }


class RecordingProjectileSender2D:
	extends Node2D

	var received_receiver: Object = null
	var received_payload: Variant = null
	var received_hit_id: StringName = &""

	func send_to(receiver: Object, payload_override: Variant = null, hit_id_override: StringName = &"") -> Dictionary:
		received_receiver = receiver
		received_payload = payload_override
		received_hit_id = hit_id_override
		return {
			"ok": true,
			"hit_id": hit_id_override,
			"receiver": receiver,
			"metadata": {},
		}


class RecordingProjectileSender3D:
	extends Node3D

	var received_receiver: Object = null
	var received_payload: Variant = null
	var received_hit_id: StringName = &""

	func send_to(receiver: Object, payload_override: Variant = null, hit_id_override: StringName = &"") -> Dictionary:
		received_receiver = receiver
		received_payload = payload_override
		received_hit_id = hit_id_override
		return {
			"ok": true,
			"hit_id": hit_id_override,
			"receiver": receiver,
			"metadata": {},
		}


# --- 私有/辅助方法 ---

func _make_projectile_2d_scene() -> PackedScene:
	var projectile := GFProjectile2DBase.new() as GFProjectile2D
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	var scene := PackedScene.new()
	scene.pack(projectile)
	projectile.free()
	return scene


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


func test_projectile_2d_impact_uses_sender_send_to_override() -> void:
	var root := Node2D.new()
	var projectile := GFProjectile2DBase.new()
	var sender := RecordingProjectileSender2D.new()
	var receiver := HitReceiver2D.new()
	add_child_autofree(root)
	root.add_child(projectile)
	root.add_child(sender)
	root.add_child(receiver)
	sender.name = "Sender"
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	projectile.finish_on_impact = false
	projectile.sender_path = NodePath("../Sender")

	projectile.launch()
	projectile.send_impact_to(receiver)
	var context := projectile.get_projectile_context()

	assert_same(sender.received_receiver, receiver, "2D 发射体自动命中应交给 sender_path 指向的业务发送者。")
	assert_null(sender.received_payload, "未覆盖 payload 时应透传 null，让业务发送者使用自身默认值。")
	assert_eq(sender.received_hit_id, &"", "未覆盖命中 ID 时应透传空值，让业务发送者使用自身默认值。")
	assert_eq(context.get("impact_count"), 1, "业务发送者接受后仍应记录发射体命中次数。")


func test_projectile_3d_impact_uses_sender_send_to_override() -> void:
	var root := Node3D.new()
	var projectile := GFProjectile3DBase.new()
	var sender := RecordingProjectileSender3D.new()
	var receiver := HitReceiver3D.new()
	add_child_autofree(root)
	root.add_child(projectile)
	root.add_child(sender)
	root.add_child(receiver)
	sender.name = "Sender"
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	projectile.finish_on_impact = false
	projectile.sender_path = NodePath("../Sender")

	projectile.launch()
	projectile.send_impact_to(receiver)
	var context := projectile.get_projectile_context()

	assert_same(sender.received_receiver, receiver, "3D 发射体自动命中应交给 sender_path 指向的业务发送者。")
	assert_eq(context.get("impact_count"), 1, "3D 业务发送者接受后仍应记录发射体命中次数。")


func test_projectile_finish_on_impact_waits_for_accepted_hit() -> void:
	var projectile := GFProjectile2DBase.new()
	projectile.auto_launch_on_ready = false
	projectile.queue_free_on_finish = false
	projectile.finish_on_impact = true
	var receiver := RejectingHitReceiver2D.new()

	projectile.launch()
	projectile.send_impact_to(receiver)
	var context := projectile.get_projectile_context()

	assert_true(projectile.is_projectile_active(), "被接收器拒绝的命中不应结束发射体。")
	assert_eq(context.get("impact_attempt_count"), 1, "拒绝命中仍应记录尝试次数。")
	assert_eq(context.get("impact_count", 0), 0, "拒绝命中不应累计成功命中次数。")

	projectile.free()
	receiver.free()


func test_projectile_emitter_2d_spawns_contextual_burst() -> void:
	var parent := Node2D.new()
	add_child_autofree(parent)
	var emitter := GFProjectileEmitter2DBase.new() as GFProjectileEmitter2D
	parent.add_child(emitter)
	emitter.projectile_scene = _make_projectile_2d_scene()
	emitter.default_context = { "team": "player" }
	var pattern := GFProjectileBurstPattern2DBase.new() as GFProjectileBurstPattern2D
	pattern.projectile_count = 3
	pattern.spread_degrees = 60.0
	pattern.radius = 10.0
	emitter.spawn_pattern = pattern

	var projectiles := emitter.emit_projectiles({ "skill_id": "fan" })

	assert_eq(projectiles.size(), 3, "发射器应按 burst pattern 生成多个发射体。")
	for index: int in range(projectiles.size()):
		var projectile := projectiles[index] as GFProjectile2D
		assert_not_null(projectile, "生成节点应为 2D 发射体。")
		assert_true(projectile.is_projectile_active(), "生成后应调用 launch(context)。")
		var context := projectile.get_projectile_context()
		assert_eq(context.get("team"), "player", "默认上下文应合并到发射上下文。")
		assert_eq(context.get("skill_id"), "fan", "调用方上下文应合并到发射上下文。")
		assert_eq(int(context.get("spawn_index")), index, "上下文应记录发射序号。")
		assert_eq(int(context.get("spawn_count")), 3, "上下文应记录本次发射数量。")


func test_projectile_emitter_2d_resolves_catalog_scene() -> void:
	var parent := Node2D.new()
	add_child_autofree(parent)
	var emitter := GFProjectileEmitter2DBase.new() as GFProjectileEmitter2D
	parent.add_child(emitter)
	var catalog := GFProjectileCatalogBase.new() as GFProjectileCatalog
	catalog.set_scene(&"arrow", _make_projectile_2d_scene())
	emitter.projectile_catalog = catalog
	emitter.default_projectile_id = &"arrow"

	var projectile := emitter.emit_projectile()

	assert_not_null(projectile, "发射器应能从目录 ID 解析场景。")
	assert_true(projectile is GFProjectile2D, "目录场景应被实例化为发射体。")


func test_projectile_emitter_2d_uses_explicit_object_pool() -> void:
	var parent := Node2D.new()
	add_child_autofree(parent)
	var emitter := GFProjectileEmitter2DBase.new() as GFProjectileEmitter2D
	parent.add_child(emitter)
	var scene := _make_projectile_2d_scene()
	var pool := GFObjectPoolUtility.new()
	pool.init()
	emitter.projectile_scene = scene
	emitter.use_object_pool = true
	emitter.object_pool_utility = pool

	var projectile := emitter.emit_projectile()

	assert_not_null(projectile, "显式对象池可用时发射器应生成发射体。")
	assert_eq(pool.get_active_count(scene), 1, "发射器应通过显式对象池获取节点。")

	pool.dispose()


func test_projectile_emitter_2d_uses_injected_architecture_pool() -> void:
	var parent := Node2D.new()
	add_child_autofree(parent)
	var emitter := GFProjectileEmitter2DBase.new() as GFProjectileEmitter2D
	parent.add_child(emitter)
	var scene := _make_projectile_2d_scene()
	var architecture := GFArchitecture.new()
	var pool := GFObjectPoolUtility.new()
	await architecture.register_utility_instance(pool)
	await architecture.init()
	emitter.projectile_scene = scene
	emitter.use_object_pool = true
	emitter.inject_dependencies(architecture)

	var projectile := emitter.emit_projectile()

	assert_not_null(projectile, "注入架构提供对象池时发射器应生成发射体。")
	assert_eq(pool.get_active_count(scene), 1, "发射器应通过注入架构查询对象池。")

	architecture.dispose()


func test_projectile_line_spawn_pattern_2d_distributes_points() -> void:
	var emitter := Node2D.new()
	add_child_autofree(emitter)
	var pattern := GFProjectileLineSpawnPattern2DBase.new() as GFProjectileLineSpawnPattern2D
	pattern.local_start = Vector2(-10.0, 0.0)
	pattern.local_end = Vector2(10.0, 0.0)
	pattern.point_count = 3

	var transforms := pattern.get_spawn_transforms(emitter)

	assert_eq(transforms.size(), 3, "线段模式应按数量生成点。")
	assert_eq(transforms[0].origin, Vector2(-10.0, 0.0), "第一个点应位于线段起点。")
	assert_eq(transforms[1].origin, Vector2.ZERO, "中间点应位于线段中心。")
	assert_eq(transforms[2].origin, Vector2(10.0, 0.0), "最后一个点应位于线段终点。")


func test_projectile_emitter_reports_missing_scene() -> void:
	var emitter := GFProjectileEmitter2DBase.new() as GFProjectileEmitter2D
	add_child_autofree(emitter)
	watch_signals(emitter)

	var projectiles := emitter.emit_projectiles()

	assert_true(projectiles.is_empty(), "缺少场景时不应生成发射体。")
	assert_signal_emitted(emitter, "projectile_emit_failed", "缺少场景时应发出失败信号。")


func test_projectile_emitter_assigns_new_emission_token_per_prepare() -> void:
	var emitter := GFProjectileEmitter2DBase.new() as GFProjectileEmitter2D
	var projectile := GFProjectile2DBase.new()
	var scene := PackedScene.new()

	emitter._prepare_projectile_runtime(projectile, scene)
	var first_token := int(projectile.get_meta(&"gf_emission_token", -1))
	emitter._prepare_projectile_runtime(projectile, scene)
	var second_token := int(projectile.get_meta(&"gf_emission_token", -1))

	assert_gt(first_token, 0, "发射器应写入本次发射 token。")
	assert_gt(second_token, first_token, "复用同一 projectile 时 token 应递增，避免旧回调释放新一轮发射。")

	projectile.free()
	emitter.free()


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
