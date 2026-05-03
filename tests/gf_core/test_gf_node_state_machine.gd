## 测试 GFNodeStateMachine 的节点状态加载、切换和跨组切换。
extends GutTest


# --- 常量 ---

const GFNodeStateBase = preload("res://addons/gf/extensions/state_machine/gf_node_state.gd")
const GFNodeStateGroupBase = preload("res://addons/gf/extensions/state_machine/gf_node_state_group.gd")
const GFNodeStateMachineBase = preload("res://addons/gf/extensions/state_machine/gf_node_state_machine.gd")
const GFNodeStateMachineConfigBase = preload("res://addons/gf/extensions/state_machine/gf_node_state_machine_config.gd")


# --- 辅助子类 ---

class TrackingNodeState:
	extends GFNodeStateBase

	var enter_count: int = 0
	var exit_count: int = 0
	var pause_count: int = 0
	var resume_count: int = 0
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

	func _pause(next_state: StringName = &"", args: Dictionary = {}) -> void:
		pause_count += 1
		last_next = next_state
		last_args = args

	func _resume(previous_state: StringName = &"", args: Dictionary = {}) -> void:
		resume_count += 1
		last_previous = previous_state
		last_args = args


class ExitRedirectNodeState:
	extends TrackingNodeState

	var target_state_name: StringName = &""

	func _init(p_target_state_name: StringName) -> void:
		target_state_name = p_target_state_name

	func _exit(next_state: StringName = &"", args: Dictionary = {}) -> void:
		super._exit(next_state, args)
		transition_to(target_state_name, args)


class ReadyHost:
	extends Node

	var ready_called: bool = false

	func _ready() -> void:
		ready_called = true


class HostReadyTrackingNodeState:
	extends TrackingNodeState

	var host_ready_at_enter: bool = false

	func _enter(previous_state: StringName = &"", args: Dictionary = {}) -> void:
		super._enter(previous_state, args)
		var host_node := get_host()
		host_ready_at_enter = host_node != null and "ready_called" in host_node and host_node.get("ready_called") == true


class GuardedNodeState:
	extends TrackingNodeState

	var allow_enter: bool = true
	var allow_exit: bool = true

	func _can_enter(_previous_state: StringName = &"", _args: Dictionary = {}) -> bool:
		return allow_enter

	func _can_exit(_next_state: StringName = &"", _args: Dictionary = {}) -> bool:
		return allow_exit


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


func test_manual_start_mode_loads_without_entering_initial_state() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := TrackingNodeState.new()
	var run := TrackingNodeState.new()
	idle.name = "Idle"
	run.name = "Run"
	machine.initial_state = &"Idle"
	machine.start_mode = GFNodeStateMachineBase.StartMode.MANUAL
	add_child_autofree(machine)
	machine.add_child(idle)
	machine.add_child(run)

	await get_tree().process_frame

	assert_null(machine.get_current_state(), "手动启动模式只应加载状态，不应自动进入初始状态。")
	assert_eq(idle.initialized_count, 1, "手动启动模式仍应初始化状态。")
	assert_eq(idle.enter_count, 0, "手动启动前不应调用状态 enter。")

	machine.start()

	assert_eq(machine.get_current_state(), idle, "start() 应进入内部初始状态。")
	assert_eq(idle.enter_count, 1, "start() 应调用初始状态 enter。")


func test_start_can_reload_when_reload_on_ready_is_disabled() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := TrackingNodeState.new()
	idle.name = "Idle"
	machine.initial_state = &"Idle"
	machine.reload_on_ready = false
	machine.start_mode = GFNodeStateMachineBase.StartMode.MANUAL
	add_child_autofree(machine)
	machine.add_child(idle)

	await get_tree().process_frame

	assert_null(machine.get_state_group(GFNodeStateMachineBase.INTERNAL_GROUP_NAME), "关闭 reload_on_ready 时不应自动加载状态组。")

	machine.start()

	assert_eq(machine.get_current_state(), idle, "start() 应在需要时先加载子状态再进入初始状态。")
	assert_eq(idle.enter_count, 1, "延迟加载后应进入初始状态。")


func test_after_host_ready_start_mode_waits_for_host_ready() -> void:
	var host := ReadyHost.new()
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := HostReadyTrackingNodeState.new()
	idle.name = "Idle"
	machine.initial_state = &"Idle"
	machine.start_mode = GFNodeStateMachineBase.StartMode.AFTER_HOST_READY
	add_child_autofree(host)
	host.add_child(machine)
	machine.add_child(idle)

	await get_tree().process_frame

	assert_true(host.ready_called, "测试宿主应已进入 ready。")
	assert_eq(machine.get_current_state(), idle, "AFTER_HOST_READY 应在宿主 ready 后进入初始状态。")
	assert_true(idle.host_ready_at_enter, "状态 enter 发生时宿主应已经 ready。")


func test_manual_start_mode_prevents_external_group_auto_start() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var body_group: Node = GFNodeStateGroupBase.new()
	var idle := TrackingNodeState.new()
	body_group.name = "Body"
	body_group.group_name = &"Body"
	body_group.initial_state = &"Idle"
	idle.name = "Idle"
	machine.start_mode = GFNodeStateMachineBase.StartMode.MANUAL
	add_child_autofree(machine)
	machine.add_child(body_group)
	body_group.add_child(idle)

	await get_tree().process_frame

	assert_null(body_group.get_current_state(), "手动启动模式下外部状态组也不应自动启动。")

	machine.start()

	assert_eq(body_group.get_current_state(), idle, "start() 应启动已加载的外部状态组。")
	assert_eq(idle.enter_count, 1, "外部状态组初始状态应被进入一次。")


func test_state_group_auto_start_can_be_disabled() -> void:
	var group: Node = GFNodeStateGroupBase.new()
	var idle := TrackingNodeState.new()
	group.name = "Body"
	group.group_name = &"Body"
	group.initial_state = &"Idle"
	group.auto_start = false
	idle.name = "Idle"
	add_child_autofree(group)
	group.add_child(idle)

	await get_tree().process_frame

	assert_null(group.get_current_state(), "auto_start 关闭后状态组 ready 时不应进入初始状态。")
	assert_eq(idle.initialized_count, 1, "auto_start 关闭后仍应加载并初始化状态。")

	group.start()

	assert_eq(group.get_current_state(), idle, "状态组 start() 应进入初始状态。")
	assert_eq(idle.enter_count, 1, "状态组 start() 应调用初始状态 enter。")


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


func test_push_and_pop_state_uses_pause_and_resume() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := TrackingNodeState.new()
	var menu := TrackingNodeState.new()
	idle.name = "Idle"
	menu.name = "Menu"
	machine.initial_state = &"Idle"
	add_child_autofree(machine)
	machine.add_child(idle)
	machine.add_child(menu)
	await get_tree().process_frame

	machine.push_state(&"Menu", { "modal": true })

	assert_eq(machine.get_current_state(), menu, "push_state 后当前状态应为子状态。")
	assert_eq(machine.get_stack_depth(), 1, "push_state 应压入上一层状态。")
	assert_eq(idle.pause_count, 1, "push_state 应暂停旧状态而不是退出旧状态。")
	assert_eq(idle.exit_count, 0, "push_state 不应触发旧状态 exit。")
	assert_true(machine.is_in_state(&"Idle"), "暂停栈中的状态应被视为仍处于状态机内。")
	assert_true(machine.is_in_state(&"Menu"), "当前子状态应被视为处于状态机内。")

	var popped: bool = machine.pop_state(GFNodeStateMachineBase.INTERNAL_GROUP_NAME, { "closed": true })

	assert_true(popped, "pop_state 有上一层状态时应返回 true。")
	assert_eq(machine.get_current_state(), idle, "pop_state 后应恢复上一层状态。")
	assert_eq(machine.get_stack_depth(), 0, "pop_state 后状态栈应为空。")
	assert_eq(menu.exit_count, 1, "pop_state 应退出当前子状态。")
	assert_eq(idle.resume_count, 1, "pop_state 应恢复上一层状态。")
	assert_eq(idle.last_previous, &"Menu", "恢复状态应收到来源子状态名。")


func test_config_controls_initial_state_and_history_limit() -> void:
	var config: Resource = GFNodeStateMachineConfigBase.new()
	config.set("initial_state", &"Run")
	config.set("history_max_size", 2)

	var machine: Node = GFNodeStateMachineBase.new()
	var idle := TrackingNodeState.new()
	var run := TrackingNodeState.new()
	var attack := TrackingNodeState.new()
	idle.name = "Idle"
	run.name = "Run"
	attack.name = "Attack"
	machine.set("config", config)
	add_child_autofree(machine)
	machine.add_child(idle)
	machine.add_child(run)
	machine.add_child(attack)
	await get_tree().process_frame

	assert_eq(machine.get_current_state(), run, "配置资源应驱动内部状态组初始状态。")

	machine.transition_to(&"Idle")
	machine.transition_to(&"Attack")

	var history: Array[StringName] = machine.get_state_history()
	assert_eq(machine.get_current_state(), attack, "状态机应完成后续切换。")
	assert_eq(history.size(), 2, "状态历史应遵守配置资源容量。")
	assert_eq(history[0], &"Idle", "历史应保留最近状态。")
	assert_eq(history[1], &"Attack", "历史应保留最新状态。")


func test_state_can_access_machine_host() -> void:
	var host := Node.new()
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := TrackingNodeState.new()
	idle.name = "Idle"
	machine.initial_state = &"Idle"
	add_child_autofree(host)
	host.add_child(machine)
	machine.add_child(idle)
	await get_tree().process_frame

	assert_eq(idle.get_host(), host, "状态应能获取状态机所在宿主节点。")


func test_state_guard_can_block_transition() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := GuardedNodeState.new()
	var run := GuardedNodeState.new()
	idle.name = "Idle"
	run.name = "Run"
	run.allow_enter = false
	machine.initial_state = &"Idle"
	add_child_autofree(machine)
	machine.add_child(idle)
	machine.add_child(run)
	await get_tree().process_frame

	var group := machine.get_state_group(GFNodeStateMachineBase.INTERNAL_GROUP_NAME) as GFNodeStateGroup
	watch_signals(group)
	machine.transition_to(&"Run")

	assert_eq(machine.get_current_state(), idle, "目标状态拒绝进入时应保持当前状态。")
	assert_eq(idle.exit_count, 0, "进入守卫失败时旧状态不应退出。")
	assert_signal_emitted(group, "transition_blocked", "守卫阻止切换时应发出 transition_blocked。")


func test_state_group_blackboard_is_shared_with_states() -> void:
	var group: Node = GFNodeStateGroupBase.new()
	var idle := TrackingNodeState.new()
	group.name = "Body"
	group.group_name = &"Body"
	group.initial_state = &"Idle"
	group.auto_start = false
	idle.name = "Idle"
	add_child_autofree(group)
	group.add_child(idle)
	await get_tree().process_frame

	var blackboard := idle.get_blackboard()
	blackboard["speed"] = 4

	assert_eq(group.blackboard.get("speed"), 4, "状态应能访问并修改状态组共享黑板。")


func test_clear_state_groups_disconnects_external_group_signals() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var group: Node = GFNodeStateGroupBase.new()
	group.name = "Body"
	group.group_name = &"Body"
	add_child_autofree(machine)
	add_child_autofree(group)
	machine.add_state_group(group)
	watch_signals(machine)

	machine.clear_state_groups()
	group.current_state_changed.emit(null, null)

	assert_signal_not_emitted(machine, "state_changed", "清理状态组后旧 group 信号不应继续转发到状态机。")


func test_clear_states_exits_current_and_stacked_states() -> void:
	var machine: Node = GFNodeStateMachineBase.new()
	var idle := TrackingNodeState.new()
	var menu := TrackingNodeState.new()
	idle.name = "Idle"
	menu.name = "Menu"
	machine.initial_state = &"Idle"
	add_child_autofree(machine)
	machine.add_child(idle)
	machine.add_child(menu)
	await get_tree().process_frame

	machine.push_state(&"Menu")
	var group := machine.get_state_group(GFNodeStateMachineBase.INTERNAL_GROUP_NAME) as GFNodeStateGroup
	group.clear_states(false)

	assert_eq(menu.exit_count, 1, "清空状态时当前状态应执行 exit。")
	assert_eq(idle.exit_count, 1, "清空状态时暂停栈状态也应执行 exit。")
	assert_eq(menu.process_mode, Node.PROCESS_MODE_DISABLED, "当前状态清空后应停止处理。")
	assert_eq(idle.process_mode, Node.PROCESS_MODE_DISABLED, "暂停栈状态清空后应保持停止处理。")
