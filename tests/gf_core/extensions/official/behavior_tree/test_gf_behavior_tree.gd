extends GutTest


func test_condition_node() -> void:
	var is_true := GFBehaviorTree.Condition.new(func(_bb: Dictionary) -> bool: return true)
	var is_false := GFBehaviorTree.Condition.new(func(_bb: Dictionary) -> bool: return false)
	
	assert_eq(is_true.tick({}), GFBehaviorTree.Status.SUCCESS)
	assert_eq(is_false.tick({}), GFBehaviorTree.Status.FAILURE)


func test_action_node() -> void:
	var bb_test := {"val": 0}
	var act := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb["val"] = 42
		return GFBehaviorTree.Status.SUCCESS
	)
	
	assert_eq(act.tick(bb_test), GFBehaviorTree.Status.SUCCESS)
	assert_eq(bb_test["val"], 42)


func test_sequence_success() -> void:
	var act1 := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int: return GFBehaviorTree.Status.SUCCESS)
	var act2 := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int: return GFBehaviorTree.Status.SUCCESS)
	
	var seq := GFBehaviorTree.Sequence.new([act1, act2] as Array[GFBehaviorTree.BTNode])
	assert_eq(seq.tick({}), GFBehaviorTree.Status.SUCCESS)


func test_sequence_failure() -> void:
	var act1 := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int: return GFBehaviorTree.Status.SUCCESS)
	var act2 := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int: return GFBehaviorTree.Status.FAILURE)
	
	var seq := GFBehaviorTree.Sequence.new([act1, act2] as Array[GFBehaviorTree.BTNode])
	assert_eq(seq.tick({}), GFBehaviorTree.Status.FAILURE)


func test_run_selector() -> void:
	var bb_test := {"run_count": 0}
	var act1 := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int: return GFBehaviorTree.Status.FAILURE)
	var act2 := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb["run_count"] += 1
		return GFBehaviorTree.Status.SUCCESS
	)
	var act3 := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb["run_count"] += 10 # 这一行不应该到达
		return GFBehaviorTree.Status.SUCCESS
	)
	
	var sel := GFBehaviorTree.Selector.new([act1, act2, act3] as Array[GFBehaviorTree.BTNode])
	assert_eq(sel.tick(bb_test), GFBehaviorTree.Status.SUCCESS)
	assert_eq(bb_test["run_count"], 1)


func test_inverter() -> void:
	var act_succ := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int: return GFBehaviorTree.Status.SUCCESS)
	var act_fail := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int: return GFBehaviorTree.Status.FAILURE)
	
	var inv1 := GFBehaviorTree.Inverter.new(act_succ)
	var inv2 := GFBehaviorTree.Inverter.new(act_fail)
	
	assert_eq(inv1.tick({}), GFBehaviorTree.Status.FAILURE)
	assert_eq(inv2.tick({}), GFBehaviorTree.Status.SUCCESS)


func test_sequence_running_state() -> void:
	var bb_test := {"state": "start"}
	var act1 := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb["state"] = "running"
		return GFBehaviorTree.Status.RUNNING
	)
	
	var seq := GFBehaviorTree.Sequence.new([act1] as Array[GFBehaviorTree.BTNode])
	var runner := GFBehaviorTree.Runner.new(seq)
	runner.blackboard = bb_test
	
	# 初次 tick 返回 RUNNING
	assert_eq(runner.tick(), GFBehaviorTree.Status.RUNNING)
	assert_eq(bb_test["state"], "running")
	
	# 第二次 tick 应该继续从处于 running 的节点开始（在本实现中直接重新 tick sequence 继续分配即可）
	assert_eq(runner.tick(), GFBehaviorTree.Status.RUNNING)


func test_parallel_require_all_waits_for_running_children() -> void:
	var state := { "first": GFBehaviorTree.Status.RUNNING }
	var running := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return int(state.first)
	)
	var success := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.SUCCESS
	)
	var parallel := GFBehaviorTree.Parallel.new(
		[running, success] as Array[GFBehaviorTree.BTNode],
		GFBehaviorTree.ParallelPolicy.REQUIRE_ALL
	)

	assert_eq(parallel.tick({}), GFBehaviorTree.Status.RUNNING)
	state.first = GFBehaviorTree.Status.SUCCESS
	assert_eq(parallel.tick({}), GFBehaviorTree.Status.SUCCESS)


func test_parallel_require_all_does_not_retick_completed_children_while_running() -> void:
	var state := {
		"running_status": GFBehaviorTree.Status.RUNNING,
		"success_ticks": 0,
	}
	var running := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return int(state.running_status)
	)
	var success := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.success_ticks += 1
		return GFBehaviorTree.Status.SUCCESS
	)
	var parallel := GFBehaviorTree.Parallel.new(
		[running, success] as Array[GFBehaviorTree.BTNode],
		GFBehaviorTree.ParallelPolicy.REQUIRE_ALL
	)

	assert_eq(parallel.tick(state), GFBehaviorTree.Status.RUNNING)
	assert_eq(parallel.tick(state), GFBehaviorTree.Status.RUNNING)
	state.running_status = GFBehaviorTree.Status.SUCCESS
	assert_eq(parallel.tick(state), GFBehaviorTree.Status.SUCCESS)
	assert_eq(state.success_ticks, 1, "已成功的并行子节点不应在同一轮运行中重复 tick。")


func test_parallel_require_one_succeeds_when_any_child_succeeds() -> void:
	var fail := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.FAILURE
	)
	var success := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.SUCCESS
	)
	var parallel := GFBehaviorTree.Parallel.new(
		[fail, success] as Array[GFBehaviorTree.BTNode],
		GFBehaviorTree.ParallelPolicy.REQUIRE_ONE
	)

	assert_eq(parallel.tick({}), GFBehaviorTree.Status.SUCCESS)


func test_parallel_require_one_does_not_retick_failed_children_while_running() -> void:
	var state := {
		"running_status": GFBehaviorTree.Status.RUNNING,
		"failure_ticks": 0,
	}
	var fail := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.failure_ticks += 1
		return GFBehaviorTree.Status.FAILURE
	)
	var running := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return int(state.running_status)
	)
	var parallel := GFBehaviorTree.Parallel.new(
		[fail, running] as Array[GFBehaviorTree.BTNode],
		GFBehaviorTree.ParallelPolicy.REQUIRE_ONE
	)

	assert_eq(parallel.tick(state), GFBehaviorTree.Status.RUNNING)
	assert_eq(parallel.tick(state), GFBehaviorTree.Status.RUNNING)
	state.running_status = GFBehaviorTree.Status.FAILURE
	assert_eq(parallel.tick(state), GFBehaviorTree.Status.FAILURE)
	assert_eq(state.failure_ticks, 1, "已失败的并行子节点不应在同一轮运行中重复 tick。")

	state.running_status = GFBehaviorTree.Status.SUCCESS
	assert_eq(parallel.tick(state), GFBehaviorTree.Status.SUCCESS, "终止失败后下一轮应重新评估子节点。")
	assert_eq(state.failure_ticks, 2)


func test_random_sequence_uses_sequence_semantics() -> void:
	var state := { "count": 0 }
	var first := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.count += 1
		return GFBehaviorTree.Status.SUCCESS
	)
	var second := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.count += 1
		return GFBehaviorTree.Status.SUCCESS
	)
	var random_sequence := GFBehaviorTree.RandomSequence.new(
		[first, second] as Array[GFBehaviorTree.BTNode]
	)

	assert_eq(random_sequence.tick(state), GFBehaviorTree.Status.SUCCESS)
	assert_eq(state.count, 2)


func test_random_sequence_can_use_seeded_rng_for_reproducible_order() -> void:
	var first_order := _run_random_sequence_with_seed(1234)
	var second_order := _run_random_sequence_with_seed(1234)

	assert_eq(first_order, second_order, "相同随机种子应产生一致的随机顺序。")
	assert_eq(_count_unique(first_order), 3)


func test_random_selector_can_use_blackboard_rng() -> void:
	var first_state := {
		"rng": _make_rng(77),
		"order": [],
	}
	var second_state := {
		"rng": _make_rng(77),
		"order": [],
	}
	var first_selector := GFBehaviorTree.RandomSelector.new([
		_make_recording_action("A", GFBehaviorTree.Status.FAILURE),
		_make_recording_action("B", GFBehaviorTree.Status.FAILURE),
		_make_recording_action("C", GFBehaviorTree.Status.SUCCESS),
	] as Array[GFBehaviorTree.BTNode])
	var second_selector := GFBehaviorTree.RandomSelector.new([
		_make_recording_action("A", GFBehaviorTree.Status.FAILURE),
		_make_recording_action("B", GFBehaviorTree.Status.FAILURE),
		_make_recording_action("C", GFBehaviorTree.Status.SUCCESS),
	] as Array[GFBehaviorTree.BTNode])

	assert_eq(first_selector.tick(first_state), GFBehaviorTree.Status.SUCCESS)
	assert_eq(second_selector.tick(second_state), GFBehaviorTree.Status.SUCCESS)
	assert_eq(first_state.order, second_state.order)


func test_random_selector_uses_selector_semantics() -> void:
	var fail := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.FAILURE
	)
	var success := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.SUCCESS
	)
	var random_selector := GFBehaviorTree.RandomSelector.new(
		[fail, success] as Array[GFBehaviorTree.BTNode]
	)

	assert_eq(random_selector.tick({}), GFBehaviorTree.Status.SUCCESS)


func test_always_succeed_and_always_fail_preserve_running() -> void:
	var running := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.RUNNING
	)
	var fail := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.FAILURE
	)
	var success := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.SUCCESS
	)

	assert_eq(GFBehaviorTree.AlwaysSucceed.new(fail).tick({}), GFBehaviorTree.Status.SUCCESS)
	assert_eq(GFBehaviorTree.AlwaysFail.new(success).tick({}), GFBehaviorTree.Status.FAILURE)
	assert_eq(GFBehaviorTree.AlwaysSucceed.new(running).tick({}), GFBehaviorTree.Status.RUNNING)
	assert_eq(GFBehaviorTree.AlwaysFail.new(running).tick({}), GFBehaviorTree.Status.RUNNING)


func test_limit_blocks_after_max_ticks() -> void:
	var state := { "count": 0 }
	var child := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.count += 1
		return GFBehaviorTree.Status.SUCCESS
	)
	var limit := GFBehaviorTree.Limit.new(child, 2)

	assert_eq(limit.tick(state), GFBehaviorTree.Status.SUCCESS)
	assert_eq(limit.tick(state), GFBehaviorTree.Status.SUCCESS)
	assert_eq(limit.tick(state), GFBehaviorTree.Status.FAILURE)
	assert_eq(state.count, 2)


func test_repeat_returns_success_after_count() -> void:
	var state := { "count": 0 }
	var child := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.count += 1
		return GFBehaviorTree.Status.SUCCESS
	)
	var repeat := GFBehaviorTree.Repeat.new(child, 3)

	assert_eq(repeat.tick(state), GFBehaviorTree.Status.RUNNING)
	assert_eq(repeat.tick(state), GFBehaviorTree.Status.RUNNING)
	assert_eq(repeat.tick(state), GFBehaviorTree.Status.SUCCESS)
	assert_eq(state.count, 3)


func test_until_success_and_until_fail() -> void:
	var success_state := { "count": 0 }
	var eventually_success := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.count += 1
		return GFBehaviorTree.Status.SUCCESS if int(bb.count) >= 2 else GFBehaviorTree.Status.FAILURE
	)
	var until_success := GFBehaviorTree.UntilSuccess.new(eventually_success)

	assert_eq(until_success.tick(success_state), GFBehaviorTree.Status.RUNNING)
	assert_eq(until_success.tick(success_state), GFBehaviorTree.Status.SUCCESS)

	var fail_state := { "count": 0 }
	var eventually_fail := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.count += 1
		return GFBehaviorTree.Status.FAILURE if int(bb.count) >= 2 else GFBehaviorTree.Status.SUCCESS
	)
	var until_fail := GFBehaviorTree.UntilFail.new(eventually_fail)

	assert_eq(until_fail.tick(fail_state), GFBehaviorTree.Status.RUNNING)
	assert_eq(until_fail.tick(fail_state), GFBehaviorTree.Status.SUCCESS)


func test_runner_debug_snapshot_records_status_and_blackboard_keys() -> void:
	var action := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.SUCCESS
	)
	action.node_id = &"root_action"
	var runner := GFBehaviorTree.Runner.new(action)
	runner.blackboard["target"] = "value"

	assert_eq(runner.tick(), GFBehaviorTree.Status.SUCCESS)
	var snapshot := runner.get_debug_snapshot()
	var root := snapshot["root"] as Dictionary

	assert_eq(root["node_id"], &"root_action", "调试快照应包含节点标识。")
	assert_eq(root["status_text"], &"success", "调试快照应记录最近状态。")
	assert_eq(snapshot["blackboard_keys"], PackedStringArray(["target"]), "运行器快照应列出黑板键。")


func test_blackboard_scope_overlays_parent_values() -> void:
	var parent := GFBehaviorTree.BlackboardScope.new({ &"speed": 3, &"mode": "base" })
	var child := GFBehaviorTree.BlackboardScope.new({ &"speed": 5 }, parent)
	var data := child.to_dictionary()

	assert_eq(child.get_value(&"speed"), 5, "子作用域应覆盖父级值。")
	assert_eq(child.get_value(&"mode"), "base", "缺失值应回退到父作用域。")
	assert_eq(data[&"speed"], 5, "合并字典应保留覆盖后的值。")


func test_probability_cooldown_and_time_limit_decorators() -> void:
	var rng := _make_rng(1)
	var action_count := { "value": 0 }
	var action := GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.value += 1
		return GFBehaviorTree.Status.SUCCESS
	)
	var probability := GFBehaviorTree.Probability.new(action, 1.0, rng)
	var cooldown := GFBehaviorTree.Cooldown.new(probability, 1.0)

	assert_eq(cooldown.tick({ "value": action_count.value, "time_msec": 1000 }), GFBehaviorTree.Status.SUCCESS)
	assert_eq(cooldown.tick({ "value": action_count.value, "time_msec": 1200 }), GFBehaviorTree.Status.FAILURE)

	var running := GFBehaviorTree.Action.new(func(_bb: Dictionary) -> int:
		return GFBehaviorTree.Status.RUNNING
	)
	var limited := GFBehaviorTree.TimeLimit.new(running, 0.5)

	assert_eq(limited.tick({ "time_msec": 1000 }), GFBehaviorTree.Status.RUNNING)
	assert_eq(limited.tick({ "time_msec": 1601 }), GFBehaviorTree.Status.FAILURE)


func _run_random_sequence_with_seed(seed_value: int) -> Array:
	var state := { "order": [] }
	var random_sequence := GFBehaviorTree.RandomSequence.new([
		_make_recording_action("A"),
		_make_recording_action("B"),
		_make_recording_action("C"),
	] as Array[GFBehaviorTree.BTNode], _make_rng(seed_value))

	assert_eq(random_sequence.tick(state), GFBehaviorTree.Status.SUCCESS)
	return state.order


func _make_recording_action(
	label: String,
	status: int = GFBehaviorTree.Status.SUCCESS
) -> GFBehaviorTree.Action:
	return GFBehaviorTree.Action.new(func(bb: Dictionary) -> int:
		bb.order.append(label)
		return status
	)


func _make_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _count_unique(values: Array) -> int:
	var lookup := {}
	for value in values:
		lookup[value] = true
	return lookup.size()
