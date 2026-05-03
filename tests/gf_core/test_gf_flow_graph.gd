## 测试 GFFlowGraph 的通用节点执行与动态分支。
extends GutTest


# --- 常量 ---

const GFFlowContextBase = preload("res://addons/gf/extensions/flow/gf_flow_context.gd")
const GFFlowGraphBase = preload("res://addons/gf/extensions/flow/gf_flow_graph.gd")
const GFFlowNodeBase = preload("res://addons/gf/extensions/flow/gf_flow_node.gd")
const GFFlowPortBase = preload("res://addons/gf/extensions/flow/gf_flow_port.gd")
const GFFlowRunnerBase = preload("res://addons/gf/extensions/flow/gf_flow_runner.gd")


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
	var node := GFFlowNodeBase.new()
	node.node_id = &"check"
	node.output_ports = [output_port]

	var description := node.describe_node()
	var outputs := (description["ports"] as Dictionary)["outputs"] as Array

	assert_eq(outputs.size(), 1, "节点描述应包含输出端口。")
	assert_eq(outputs[0]["port_id"], &"success", "端口标识应保留。")


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
	assert_true(_has_issue(report, "missing_next_node"), "校验报告应包含 missing_next_node。")


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
