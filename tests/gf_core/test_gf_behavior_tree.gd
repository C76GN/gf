# tests/gf_core/test_gf_behavior_tree.gd
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
