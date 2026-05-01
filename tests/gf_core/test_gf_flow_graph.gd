## 测试 GFFlowGraph 的通用节点执行与动态分支。
extends GutTest


# --- 常量 ---

const GFFlowContextBase = preload("res://addons/gf/extensions/flow/gf_flow_context.gd")
const GFFlowGraphBase = preload("res://addons/gf/extensions/flow/gf_flow_graph.gd")
const GFFlowNodeBase = preload("res://addons/gf/extensions/flow/gf_flow_node.gd")
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
