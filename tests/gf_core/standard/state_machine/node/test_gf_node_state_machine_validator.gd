## 测试 GFNodeStateMachineValidator 的结构校验报告。
extends GutTest


# --- 常量 ---

const GFNodeStateBase = preload("res://addons/gf/standard/state_machine/node/gf_node_state.gd")
const GFNodeStateMachineDockBase = preload("res://addons/gf/standard/state_machine/node/editor/gf_node_state_machine_dock.gd")
const GFNodeStateGroupBase = preload("res://addons/gf/standard/state_machine/node/gf_node_state_group.gd")
const GFNodeStateMachineBase = preload("res://addons/gf/standard/state_machine/node/gf_node_state_machine.gd")
const GFNodeStateMachineValidatorBase = preload("res://addons/gf/standard/state_machine/node/gf_node_state_machine_validator.gd")


# --- 测试 ---

func test_validator_reports_duplicate_state_names_and_missing_initial() -> void:
	var machine := GFNodeStateMachineBase.new()
	var idle_a := GFNodeStateBase.new()
	var idle_b := GFNodeStateBase.new()
	idle_a.name = "IdleA"
	idle_b.name = "IdleB"
	idle_a.state_name = &"idle"
	idle_b.state_name = &"idle"
	machine.add_child(idle_a)
	machine.add_child(idle_b)

	var report := GFNodeStateMachineValidatorBase.validate_machine(machine)
	var counts := report.get_issue_counts_by_kind()

	assert_gt(report.get_error_count(), 0, "重复状态名应产生错误。")
	assert_eq(counts.get("duplicate_state_name", 0), 1, "应报告同组重复状态名。")
	assert_eq(counts.get("missing_initial_state", 0), 1, "自动启动状态机缺少初始状态时应给出警告。")

	machine.free()


func test_manual_machine_can_validate_without_initial_state() -> void:
	var machine := GFNodeStateMachineBase.new()
	machine.start_mode = GFNodeStateMachineBase.StartMode.MANUAL
	var idle := GFNodeStateBase.new()
	idle.name = "Idle"
	machine.add_child(idle)

	var report := GFNodeStateMachineValidatorBase.validate_machine(machine)

	assert_true(report.is_healthy(), "手动启动状态机允许不声明初始状态。")

	machine.free()


func test_validator_reports_invalid_initial_state_and_resource_slots() -> void:
	var group := GFNodeStateGroupBase.new()
	group.name = "Movement"
	group.initial_state = &"missing"
	var idle := GFNodeStateBase.new()
	idle.name = "Idle"
	idle.enter_conditions.append(Resource.new())
	idle.behaviors.append(Resource.new())
	group.add_child(idle)

	var report := GFNodeStateMachineValidatorBase.validate_group(group)
	var counts := report.get_issue_counts_by_kind()

	assert_eq(counts.get("invalid_initial_state", 0), 1, "不存在的初始状态应产生错误。")
	assert_eq(counts.get("invalid_state_resource", 0), 1, "缺少 evaluate() 的条件资源应产生错误。")
	assert_eq(counts.get("inert_state_behavior", 0), 1, "无生命周期钩子的行为资源应产生警告。")

	group.free()


func test_state_machine_dock_scans_scene_root_and_reports_selected_machine() -> void:
	var root := Node.new()
	root.name = "Root"
	var machine := GFNodeStateMachineBase.new()
	machine.name = "StateMachine"
	machine.initial_state = &"idle"
	var idle := GFNodeStateBase.new()
	idle.name = "Idle"
	idle.state_name = &"idle"
	machine.add_child(idle)
	root.add_child(machine)
	var dock: GFNodeStateMachineDock = GFNodeStateMachineDockBase.new()

	dock.set_state_machine_source(root)
	var report := dock.get_last_report()

	assert_eq(dock.get_machine_count(), 1, "状态机工具面板应能扫描场景根节点。")
	assert_true(bool(report.get("ok", false)), "有效状态机应在工具面板报告为通过。")

	dock.free()
	root.free()


func test_state_machine_dock_uses_compact_empty_state() -> void:
	var root := Node.new()
	var dock: GFNodeStateMachineDock = GFNodeStateMachineDockBase.new()

	dock.set_state_machine_source(root)

	assert_true(dock._empty_label.visible, "没有状态机时应显示空状态。")
	assert_false(dock._tree.visible, "没有状态机时不应显示空表格。")
	assert_false(dock._details.visible, "没有状态机时不应留下空详情面板。")

	dock.free()
	root.free()
