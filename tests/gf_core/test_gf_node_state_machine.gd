## 测试 GFNodeStateMachine 的节点状态加载、切换和跨组切换。
extends GutTest


# --- 常量 ---

const GFNodeStateBase = preload("res://addons/gf/extensions/state_machine/gf_node_state.gd")
const GFNodeStateGroupBase = preload("res://addons/gf/extensions/state_machine/gf_node_state_group.gd")
const GFNodeStateMachineBase = preload("res://addons/gf/extensions/state_machine/gf_node_state_machine.gd")


# --- 辅助子类 ---

class TrackingNodeState:
	extends GFNodeStateBase

	var enter_count: int = 0
	var exit_count: int = 0
	var initialized_count: int = 0
	var last_previous: StringName = &""
	var last_next: StringName = &""
	var last_args: Dictionary = {}

	func _initialize() -> void:
		initialized_count += 1

	func _enter(previous_state: StringName = &"", args: Dictionary = {}) -> void:
		enter_count += 1
		last_previous = previous_state
		last_args = args

	func _exit(next_state: StringName = &"", args: Dictionary = {}) -> void:
		exit_count += 1
		last_next = next_state
		last_args = args


class ExitRedirectNodeState:
	extends TrackingNodeState

	var target_state_name: StringName = &""

	func _init(p_target_state_name: StringName) -> void:
		target_state_name = p_target_state_name

	func _exit(next_state: StringName = &"", args: Dictionary = {}) -> void:
		super._exit(next_state, args)
		transition_to(target_state_name, args)


# --- 测试 ---

func test_internal_group_loads_direct_child_states() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := TrackingNodeState.new()
	var run := TrackingNodeState.new()
	idle.name = "Idle"
	run.name = "Run"
	machine.initial_state = &"Idle"
	add_child_autofree(machine)
	machine.add_child(idle)
	machine.add_child(run)

	await get_tree().process_frame

	assert_eq(machine.get_current_state(), idle, "直接子状态应进入内部状态组。")
	assert_eq(idle.enter_count, 1, "初始状态应被进入。")
	assert_eq(run.initialized_count, 1, "未激活状态也应完成初始化。")


func test_transition_to_changes_internal_state() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := TrackingNodeState.new()
	var run := TrackingNodeState.new()
	idle.name = "Idle"
	run.name = "Run"
	machine.initial_state = &"Idle"
	add_child_autofree(machine)
	machine.add_child(idle)
	machine.add_child(run)
	await get_tree().process_frame

	machine.transition_to(&"Run", { "speed": 5 })

	assert_eq(idle.exit_count, 1, "切换状态应退出旧状态。")
	assert_eq(idle.last_next, &"Run", "旧状态应收到目标状态名。")
	assert_eq(run.enter_count, 1, "切换状态应进入新状态。")
	assert_eq(run.last_previous, &"Idle", "新状态应收到来源状态名。")
	assert_eq(run.last_args.get("speed"), 5, "切换参数应传给新状态。")


func test_state_can_request_cross_group_transition() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var body_group: Node = GFNodeStateGroupBase.new()
	var idle := TrackingNodeState.new()
	var attack := TrackingNodeState.new()
	body_group.name = "Body"
	body_group.group_name = &"Body"
	body_group.initial_state = &"Idle"
	idle.name = "Idle"
	attack.name = "Attack"
	add_child_autofree(machine)
	machine.add_child(body_group)
	body_group.add_child(idle)
	body_group.add_child(attack)
	await get_tree().process_frame

	idle.transition_to(&"Body/Attack")

	assert_eq(body_group.get_current_state(), attack, "状态应能通过 Group/State 请求跨组切换。")
	assert_eq(idle.exit_count, 1, "跨组切换应退出旧状态。")
	assert_eq(attack.enter_count, 1, "跨组切换应进入目标状态。")


func test_transition_requested_during_exit_replaces_outer_target() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := ExitRedirectNodeState.new(&"Attack")
	var run := TrackingNodeState.new()
	var attack := TrackingNodeState.new()
	idle.name = "Idle"
	run.name = "Run"
	attack.name = "Attack"
	machine.initial_state = &"Idle"
	add_child_autofree(machine)
	machine.add_child(idle)
	machine.add_child(run)
	machine.add_child(attack)
	await get_tree().process_frame

	machine.transition_to(&"Run")

	assert_eq(idle.exit_count, 1, "exit 内部请求切换时，旧状态不应重复 exit。")
	assert_eq(run.enter_count, 0, "exit 内部请求的新状态应替代外层目标。")
	assert_eq(attack.enter_count, 1, "exit 内部请求的状态应成为最终状态。")
	assert_eq(machine.get_current_state(), attack, "最终当前状态应为 exit 内部请求的状态。")
