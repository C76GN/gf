## 测试 GFFlowGraph 的通用节点执行与动态分支。
extends GutTest


# --- 常量 ---

const GFFlowContextBase = preload("res://addons/gf/packages/official/flow/runtime/gf_flow_context.gd")
const GFFlowGraphBase = preload("res://addons/gf/packages/official/flow/resources/gf_flow_graph.gd")
const GFFlowNodeBase = preload("res://addons/gf/packages/official/flow/resources/gf_flow_node.gd")
const GFFlowPortBase = preload("res://addons/gf/packages/official/flow/resources/gf_flow_port.gd")
const GFFlowRunnerBase = preload("res://addons/gf/packages/official/flow/runtime/gf_flow_runner.gd")


# --- 辅助类 ---

class RecordingFlowNode extends GFFlowNode:
	var order: Array[String] = []

	func _init(p_node_id: StringName, p_order: Array[String], p_next: PackedStringArray = PackedStringArray()) -> void:
		node_id = p_node_id
		order = p_order
		next_node_ids = p_next

	func execute(_context: GFFlowContext) -> Variant:
		order.append(String(node_id))
		return null


class BranchFlowNode extends GFFlowNode:
	func _init() -> void:
		node_id = &"branch"

	func execute(context: GFFlowContext) -> Variant:
		context.set_next_nodes(PackedStringArray(["right"]))
		return null


class StopFlowNode extends GFFlowNode:
	func _init() -> void:
		node_id = &"stop"

	func execute(context: GFFlowContext) -> Variant:
		context.set_next_nodes(PackedStringArray())
		return null


# --- 测试方法 ---

## 验证流程节点会按后继关系执行。
func test_flow_runner_executes_node_links() -> void:
	var order: Array[String] = []
	var graph := GFFlowGraphBase.new()
	graph.start_node_id = &"start"
	graph.nodes = [
		RecordingFlowNode.new(&"start", order, PackedStringArray(["end"])),
		RecordingFlowNode.new(&"end", order),
	]
	var runner := GFFlowRunnerBase.new()

	runner.run(graph, GFFlowContextBase.new())

	assert_eq(order, ["start", "end"], "流程应按节点后继顺序执行。")
	assert_false(runner.is_running, "同步流程完成后不应保持 running。")


## 验证节点可通过上下文覆盖后继节点。
func test_flow_node_can_override_next_nodes() -> void:
	var order: Array[String] = []
	var graph := GFFlowGraphBase.new()
	graph.start_node_id = &"branch"
	graph.nodes = [
		BranchFlowNode.new(),
		RecordingFlowNode.new(&"left", order),
		RecordingFlowNode.new(&"right", order),
	]
	var runner := GFFlowRunnerBase.new()

	runner.run(graph, GFFlowContextBase.new())

	assert_eq(order, ["right"], "上下文覆盖的分支应决定后继节点。")


## 验证流程节点端口描述可用于图结构描述。
func test_flow_node_describes_ports() -> void:
	var output_port := GFFlowPortBase.new()
	output_port.port_id = &"success"
	output_port.direction = GFFlowPort.Direction.OUTPUT
	output_port.value_type = GFFlowPort.ValueType.BOOL
	output_port.editor_color = Color.GREEN
	output_port.type_hint = &"result"
	output_port.semantic_tags = PackedStringArray(["logic"])
	var node := GFFlowNodeBase.new()
	node.node_id = &"check"
	node.output_ports = [output_port]

	var description := node.describe_node()
	var outputs := (description["ports"] as Dictionary)["outputs"] as Array

	assert_eq(outputs.size(), 1, "节点描述应包含输出端口。")
	assert_eq(outputs[0]["port_id"], &"success", "端口标识应保留。")
	assert_eq(outputs[0]["editor_color"], Color.GREEN, "端口描述应包含编辑器颜色。")
	assert_eq(outputs[0]["type_hint"], &"result", "端口描述应包含类型提示。")
	assert_true((outputs[0]["semantic_tags"] as PackedStringArray).has("logic"), "端口描述应包含语义标签。")


## 验证流程图连接可驱动无 next_node_ids 的节点推进。
func test_flow_runner_executes_graph_connections() -> void:
	var order: Array[String] = []
	var graph := GFFlowGraphBase.new()
	graph.start_node_id = &"start"
	graph.nodes = [
		RecordingFlowNode.new(&"start", order),
		RecordingFlowNode.new(&"end", order),
	]
	graph.add_connection(&"start", &"", &"end", &"")
	var runner := GFFlowRunnerBase.new()

	runner.run(graph, GFFlowContextBase.new())

	assert_eq(order, ["start", "end"], "流程应能通过图连接推进后继节点。")


## 验证上下文显式空后继会阻止连接回退。
func test_flow_context_empty_override_stops_connection_fallback() -> void:
	var order: Array[String] = []
	var graph := GFFlowGraphBase.new()
	graph.start_node_id = &"stop"
	graph.nodes = [
		StopFlowNode.new(),
		RecordingFlowNode.new(&"end", order),
	]
	graph.add_connection(&"stop", &"", &"end", &"")
	var runner := GFFlowRunnerBase.new()

	runner.run(graph, GFFlowContextBase.new())

	assert_eq(order, [], "显式空后继应表示停止，而不是回退到图连接。")


## 验证流程图会校验连接端点与端口。
func test_flow_graph_validate_reports_connection_port_issues() -> void:
	var graph := GFFlowGraphBase.new()
	var start := GFFlowNodeBase.new()
	start.node_id = &"start"
	start.output_ports = [_make_port(&"done", GFFlowPort.Direction.OUTPUT)]
	var end := GFFlowNodeBase.new()
	end.node_id = &"end"
	end.input_ports = [_make_port(&"enter", GFFlowPort.Direction.INPUT)]
	graph.nodes = [start, end]
	graph.connections = [
		{
			"from_node_id": &"start",
			"from_port_id": &"missing",
			"to_node_id": &"end",
			"to_port_id": &"enter",
			"metadata": {},
		},
	]

	var report := graph.validate_graph()

	assert_false(bool(report["ok"]), "缺失连接端口应使校验失败。")
	assert_true(_has_issue(report, "missing_connection_output_port"), "校验报告应包含 missing_connection_output_port。")


## 验证流程图默认端口兼容性校验会报告类型不匹配。
func test_flow_graph_validate_reports_incompatible_ports_by_default() -> void:
	var graph := GFFlowGraphBase.new()
	var start := GFFlowNodeBase.new()
	start.node_id = &"start"
	start.output_ports = [_make_typed_port(&"value", GFFlowPort.Direction.OUTPUT, GFFlowPort.ValueType.NUMBER)]
	var end := GFFlowNodeBase.new()
	end.node_id = &"end"
	end.input_ports = [_make_typed_port(&"value", GFFlowPort.Direction.INPUT, GFFlowPort.ValueType.STRING)]
	graph.nodes = [start, end]
	graph.connections = [
		{
			"from_node_id": &"start",
			"from_port_id": &"value",
			"to_node_id": &"end",
			"to_port_id": &"value",
			"metadata": {},
		},
	]

	var report := graph.validate_graph()
	var compatibility := graph.check_connection_compatibility(&"start", &"value", &"end", &"value")

	assert_true(graph.validate_port_compatibility, "2.0 默认应启用端口兼容性校验。")
	assert_false(bool(report["ok"]), "默认严格校验下类型不匹配应失败。")
	assert_true(_has_issue(report, "incompatible_connection_ports"), "校验报告应包含 incompatible_connection_ports。")
	assert_false(bool(compatibility["ok"]), "兼容性检查应返回失败。")


## 验证流程图默认拒绝新增不兼容端口连接。
func test_flow_graph_add_connection_rejects_incompatible_ports_by_default() -> void:
	var graph := GFFlowGraphBase.new()
	var start := GFFlowNodeBase.new()
	start.node_id = &"start"
	start.output_ports = [_make_typed_port(&"value", GFFlowPort.Direction.OUTPUT, GFFlowPort.ValueType.NUMBER)]
	var end := GFFlowNodeBase.new()
	end.node_id = &"end"
	end.input_ports = [_make_typed_port(&"value", GFFlowPort.Direction.INPUT, GFFlowPort.ValueType.STRING)]
	graph.nodes = [start, end]

	assert_false(graph.add_connection(&"start", &"value", &"end", &"value"), "2.0 默认不应追加不兼容端口连接。")

	graph.validate_port_compatibility = false
	assert_true(graph.add_connection(&"start", &"value", &"end", &"value"), "项目可显式关闭端口兼容性校验以迁移旧资源。")


## 验证流程图连接描述可供编辑器或可视化工具消费。
func test_flow_graph_describes_connections() -> void:
	var graph := GFFlowGraphBase.new()
	var order: Array[String] = []
	graph.nodes = [
		RecordingFlowNode.new(&"start", order),
		RecordingFlowNode.new(&"end", order),
	]
	assert_true(graph.add_connection(&"start", &"", &"end", &"", { "label": "ok" }), "节点级连接应添加成功。")

	var description := graph.describe_graph()
	var connections := description["connections"] as Array

	assert_eq(description["connection_count"], 1, "图描述应包含连接数量。")
	assert_eq(connections[0]["to_node_id"], &"end", "图描述应包含目标节点。")
	assert_eq((connections[0]["metadata"] as Dictionary).get("label"), "ok", "连接元数据应保留。")


## 验证流程图提供编辑器目录和布局元数据。
func test_flow_graph_editor_catalog_describes_nodes() -> void:
	var graph := GFFlowGraphBase.new()
	var node := GFFlowNodeBase.new()
	node.node_id = &"start"
	node.display_name = "Start"
	node.category = &"Core"
	graph.nodes = [node]

	assert_true(graph.set_node_editor_layout(&"start", Vector2(12.0, 24.0), Vector2(160.0, 80.0), true), "应能设置节点编辑器布局。")
	var report := graph.build_editor_report()
	var catalog := report["catalog"] as Dictionary
	var nodes := catalog["nodes"] as Array
	var editor := nodes[0]["editor"] as Dictionary

	assert_true(bool(report["ok"]), "有效流程图编辑器报告应通过。")
	assert_eq(nodes[0]["display_name"], "Start", "目录应包含显示名。")
	assert_eq(nodes[0]["category"], "Core", "目录应包含分类。")
	assert_eq(editor["position"], Vector2(12.0, 24.0), "目录应包含编辑器位置。")
	assert_true(bool(editor["collapsed"]), "目录应包含折叠状态。")


## 验证 FlowGraph 编辑器视图模型包含端口索引、布局和连接信息。
func test_flow_graph_editor_model_builds_graph_edit_ready_data() -> void:
	var graph := GFFlowGraphBase.new()
	var start := GFFlowNodeBase.new()
	start.node_id = &"start"
	start.display_name = "Start"
	start.output_ports = [_make_port(&"done", GFFlowPort.Direction.OUTPUT)]
	start.editor_position = Vector2(10.0, 20.0)
	var end := GFFlowNodeBase.new()
	end.node_id = &"end"
	end.input_ports = [_make_port(&"enter", GFFlowPort.Direction.INPUT)]
	graph.nodes = [start, end]
	graph.add_connection(&"start", &"done", &"end", &"enter")
	var editor_model := GFFlowGraphEditorModel.new()

	var view_model := editor_model.build_view_model(graph)
	var nodes := view_model["nodes"] as Array
	var connections := view_model["connections"] as Array

	assert_true(bool(view_model["ok"]), "有效流程图应生成 ok 视图模型。")
	assert_eq(nodes[0]["position"], Vector2(10.0, 20.0), "节点布局应进入视图模型。")
	assert_eq(((nodes[0] as Dictionary)["output_port_indices"] as Dictionary)[&"done"], 0, "输出端口应有稳定索引。")
	assert_eq(connections[0]["from_port_index"], 0, "连接应包含 GraphEdit 可用的输出端口索引。")
	assert_eq(connections[0]["to_port_index"], 0, "连接应包含 GraphEdit 可用的输入端口索引。")


## 验证流程图校验会报告缺失后继节点。
func test_flow_graph_validate_reports_missing_next_node() -> void:
	var order: Array[String] = []
	var graph := GFFlowGraphBase.new()
	graph.start_node_id = &"start"
	graph.nodes = [
		RecordingFlowNode.new(&"start", order, PackedStringArray(["missing"])),
	]

	var report := graph.validate_graph()

	assert_false(bool(report["ok"]), "缺失后继节点应使校验失败。")
	assert_gt(int(report["error_count"]), 0, "校验报告应统计错误数量。")
	assert_false(String(report["next_action"]).is_empty(), "校验报告应包含下一步建议。")
	assert_true(_has_issue(report, "missing_next_node"), "校验报告应包含 missing_next_node。")


## 验证流程图校验会提示不可达节点。
func test_flow_graph_validate_warns_unreachable_nodes() -> void:
	var order: Array[String] = []
	var graph := GFFlowGraphBase.new()
	graph.start_node_id = &"start"
	graph.nodes = [
		RecordingFlowNode.new(&"start", order, PackedStringArray(["middle"])),
		RecordingFlowNode.new(&"middle", order),
		RecordingFlowNode.new(&"orphan", order),
	]

	var report := graph.validate_graph()

	assert_true(bool(report["ok"]), "不可达节点只应作为结构警告，不应阻止图通过基础校验。")
	assert_false(bool(report["healthy"]), "存在警告时 healthy 应为 false。")
	assert_true(_has_issue(report, "unreachable_node"), "校验报告应包含 unreachable_node。")


## 验证流程图校验会提示循环结构。
func test_flow_graph_validate_warns_cycles() -> void:
	var order: Array[String] = []
	var graph := GFFlowGraphBase.new()
	graph.start_node_id = &"start"
	graph.nodes = [
		RecordingFlowNode.new(&"start", order, PackedStringArray(["middle"])),
		RecordingFlowNode.new(&"middle", order, PackedStringArray(["start"])),
	]

	var report := graph.validate_graph()

	assert_true(bool(report["ok"]), "循环只应作为结构警告，运行时仍由 loop guard 保护。")
	assert_true(_has_issue(report, "cycle_detected"), "校验报告应包含 cycle_detected。")


## 验证项目可显式开启终端节点提示。
func test_flow_graph_validate_can_warn_terminal_nodes() -> void:
	var order: Array[String] = []
	var graph := GFFlowGraphBase.new()
	graph.start_node_id = &"start"
	graph.warn_terminal_nodes = true
	graph.nodes = [
		RecordingFlowNode.new(&"start", order),
	]

	var report := graph.validate_graph()

	assert_true(bool(report["ok"]), "终端节点提示不应阻止基础校验通过。")
	assert_true(_has_issue(report, "terminal_node"), "校验报告应包含 terminal_node。")


## 验证 Flow Signal 超时可以跟随 GFTimeUtility 的暂停与 time_scale。
func test_flow_runner_signal_timeout_respects_time_utility() -> void:
	var arch := GFArchitecture.new()
	var time_utility := GFTimeUtility.new()
	await arch.register_utility_instance(time_utility)
	await arch.init()
	var runner := GFFlowRunnerBase.new()
	runner.inject_dependencies(arch)

	time_utility.time_scale = 0.5
	assert_almost_eq(runner._get_timeout_elapsed_msec(1000, 2000), 500.0, 0.001, "默认应按 GFTimeUtility.time_scale 推进超时。")

	time_utility.is_paused = true
	assert_almost_eq(runner._get_timeout_elapsed_msec(2000, 3000), 0.0, 0.001, "GFTimeUtility 暂停时超时不应推进。")

	runner.with_signal_timeout(1.0, false)
	assert_almost_eq(runner._get_timeout_elapsed_msec(3000, 4000), 1000.0, 0.001, "关闭 time scale 后应使用真实时间。")

	arch.dispose()


# --- 私有/辅助方法 ---

func _has_issue(report: Dictionary, kind: String) -> bool:
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue != null and String(issue.get("kind", "")) == kind:
			return true
	return false


func _make_port(port_id: StringName, direction: GFFlowPort.Direction) -> GFFlowPortBase:
	var port := GFFlowPortBase.new()
	port.port_id = port_id
	port.direction = direction
	return port


func _make_typed_port(
	port_id: StringName,
	direction: GFFlowPort.Direction,
	value_type: GFFlowPort.ValueType
) -> GFFlowPortBase:
	var port := _make_port(port_id, direction)
	port.value_type = value_type
	return port
