## GFFlowGraph: 资源化通用流程图。
##
## 只维护节点集合与起始节点，不规定具体编辑器表现或业务语义。
class_name GFFlowGraph
extends Resource


# --- 常量 ---

const _GF_VALIDATION_REPORT_DICTIONARY_SCRIPT: Script = preload("res://addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd")
const _GF_GRAPH_MATH_SCRIPT: Script = preload("res://addons/gf/standard/foundation/math/gf_graph_math.gd")


# --- 导出变量 ---

## 起始节点标识。
@export var start_node_id: StringName = &""

## 流程节点列表。
@export var nodes: Array[GFFlowNode] = []

## 节点连接列表。连接结构为 from_node_id/from_port_id/to_node_id/to_port_id/metadata。
@export var connections: Array[Dictionary] = []

## 校验时是否把端口值类型和类名提示不兼容视为错误。
@export var validate_port_compatibility: bool = true

## 校验时是否提示从 start_node_id 无法到达的节点。
@export var warn_unreachable_nodes: bool = true

## 校验时是否提示图中的循环。
@export var warn_cycles: bool = true

## 校验时是否提示没有后继的终端节点。默认关闭，避免把正常结束节点视为问题。
@export var warn_terminal_nodes: bool = false

## 编辑器分组数据。结构由编辑器工具解释，运行时不读取。
@export var editor_groups: Array[Dictionary] = []

## 编辑器或项目工具的附加元数据。
@export var editor_metadata: Dictionary = {}


# --- 公共方法 ---

## 设置或替换一个节点。
## @param node: 流程节点。
func set_node(node: GFFlowNode) -> void:
	if node == null or node.node_id == &"":
		return

	for index: int in range(nodes.size()):
		if nodes[index] != null and nodes[index].node_id == node.node_id:
			nodes[index] = node
			return
	nodes.append(node)


## 获取节点。
## @param node_id: 节点标识。
## @return 流程节点；不存在时返回 null。
func get_node(node_id: StringName) -> GFFlowNode:
	for node: GFFlowNode in nodes:
		if node != null and node.node_id == node_id:
			return node
	return null


## 检查节点是否存在。
## @param node_id: 节点标识。
## @return 存在返回 true。
func has_node(node_id: StringName) -> bool:
	return get_node(node_id) != null


## 移除节点。
## @param node_id: 节点标识。
func remove_node(node_id: StringName) -> void:
	for index: int in range(nodes.size() - 1, -1, -1):
		if nodes[index] != null and nodes[index].node_id == node_id:
			nodes.remove_at(index)
	remove_connections_for_node(node_id)


## 添加节点连接。
## @param from_node_id: 来源节点。
## @param from_port_id: 来源端口；为空时表示节点级执行连接。
## @param to_node_id: 目标节点。
## @param to_port_id: 目标端口；为空时表示节点级执行连接。
## @param metadata: 项目自定义元数据。
## @return 添加成功返回 true。
func add_connection(
	from_node_id: StringName,
	from_port_id: StringName,
	to_node_id: StringName,
	to_port_id: StringName,
	metadata: Dictionary = {}
) -> bool:
	if from_node_id == &"" or to_node_id == &"":
		return false
	if has_connection(from_node_id, from_port_id, to_node_id, to_port_id):
		return false
	if not _can_append_connection(from_node_id, from_port_id, to_node_id, to_port_id):
		return false

	connections.append(_make_connection(from_node_id, from_port_id, to_node_id, to_port_id, metadata))
	return true


## 移除指定节点连接。
## @param from_node_id: 连接起点节点标识。
## @param from_port_id: 连接起点端口标识。
## @param to_node_id: 目标标识。
## @param to_port_id: 目标标识。
## @return 移除成功返回 true。
func remove_connection(
	from_node_id: StringName,
	from_port_id: StringName,
	to_node_id: StringName,
	to_port_id: StringName
) -> bool:
	for index: int in range(connections.size() - 1, -1, -1):
		if _connection_matches(connections[index], from_node_id, from_port_id, to_node_id, to_port_id):
			connections.remove_at(index)
			return true
	return false


## 移除与指定节点相关的所有连接。
## @param node_id: 节点标识。
func remove_connections_for_node(node_id: StringName) -> void:
	for index: int in range(connections.size() - 1, -1, -1):
		var connection := connections[index]
		if StringName(connection.get("from_node_id", &"")) == node_id or StringName(connection.get("to_node_id", &"")) == node_id:
			connections.remove_at(index)


## 检查连接是否存在。
## @param from_node_id: 连接起点节点标识。
## @param from_port_id: 连接起点端口标识。
## @param to_node_id: 目标标识。
## @param to_port_id: 目标标识。
## @return 存在返回 true。
func has_connection(
	from_node_id: StringName,
	from_port_id: StringName,
	to_node_id: StringName,
	to_port_id: StringName
) -> bool:
	for connection: Dictionary in connections:
		if _connection_matches(connection, from_node_id, from_port_id, to_node_id, to_port_id):
			return true
	return false


## 获取从指定节点或端口发出的连接。
## @param node_id: 节点标识。
## @param port_id: 端口标识；为空时返回该节点所有输出连接。
## @return 连接副本列表。
func get_connections_from(node_id: StringName, port_id: StringName = &"") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for connection: Dictionary in connections:
		if StringName(connection.get("from_node_id", &"")) != node_id:
			continue
		if port_id != &"" and StringName(connection.get("from_port_id", &"")) != port_id:
			continue
		result.append(connection.duplicate(true))
	return result


## 获取指向指定节点或端口的连接。
## @param node_id: 节点标识。
## @param port_id: 端口标识；为空时返回该节点所有输入连接。
## @return 连接副本列表。
func get_connections_to(node_id: StringName, port_id: StringName = &"") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for connection: Dictionary in connections:
		if StringName(connection.get("to_node_id", &"")) != node_id:
			continue
		if port_id != &"" and StringName(connection.get("to_port_id", &"")) != port_id:
			continue
		result.append(connection.duplicate(true))
	return result


## 获取指定节点或端口连接到的目标节点。
## @param node_id: 节点标识。
## @param port_id: 端口标识；为空时返回该节点所有输出目标。
## @return 目标节点标识列表。
func get_connected_node_ids_from(node_id: StringName, port_id: StringName = &"") -> PackedStringArray:
	var result := PackedStringArray()
	for connection: Dictionary in get_connections_from(node_id, port_id):
		var target_id := String(connection.get("to_node_id", ""))
		if target_id.is_empty() or result.has(target_id):
			continue
		result.append(target_id)
	return result


## 检查指定连接端口的兼容性。
## @param from_node_id: 来源节点。
## @param from_port_id: 来源端口。
## @param to_node_id: 目标节点。
## @param to_port_id: 目标端口。
## @return 兼容性报告。
func check_connection_compatibility(
	from_node_id: StringName,
	from_port_id: StringName,
	to_node_id: StringName,
	to_port_id: StringName
) -> Dictionary:
	var from_node := get_node(from_node_id)
	var to_node := get_node(to_node_id)
	if from_node == null:
		return _make_connection_compatibility_report(false, "missing_from_node", "Connection source node does not exist.")
	if to_node == null:
		return _make_connection_compatibility_report(false, "missing_to_node", "Connection target node does not exist.")
	if from_port_id == &"" or to_port_id == &"":
		return _make_connection_compatibility_report(true, "", "")

	var output_port := from_node.get_output_port(from_port_id)
	var input_port := to_node.get_input_port(to_port_id)
	if output_port == null:
		return _make_connection_compatibility_report(false, "missing_output_port", "Connection output port does not exist.")
	if input_port == null:
		return _make_connection_compatibility_report(false, "missing_input_port", "Connection input port does not exist.")

	var report := output_port.get_compatibility_report(input_port)
	report["from_node_id"] = from_node_id
	report["from_port_id"] = from_port_id
	report["to_node_id"] = to_node_id
	report["to_port_id"] = to_port_id
	return report


## 获取所有连接的兼容性报告。
## @return 兼容性报告列表。
func get_connection_compatibility_report() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for connection: Dictionary in connections:
		result.append(check_connection_compatibility(
			StringName(connection.get("from_node_id", &"")),
			StringName(connection.get("from_port_id", &"")),
			StringName(connection.get("to_node_id", &"")),
			StringName(connection.get("to_port_id", &""))
		))
	return result


## 设置节点编辑器位置。
## @param node_id: 节点标识。
## @param position: 编辑器坐标。
## @return 设置成功返回 true。
func set_node_editor_position(node_id: StringName, position: Vector2) -> bool:
	var node := get_node(node_id)
	if node == null:
		return false
	node.editor_position = position
	return true


## 设置节点编辑器布局。
## @param node_id: 节点标识。
## @param position: 编辑器坐标。
## @param size: 编辑器尺寸；Vector2.ZERO 表示由编辑器自行决定。
## @param collapsed: 是否折叠显示。
## @return 设置成功返回 true。
func set_node_editor_layout(
	node_id: StringName,
	position: Vector2,
	size: Vector2 = Vector2.ZERO,
	collapsed: bool = false
) -> bool:
	var node := get_node(node_id)
	if node == null:
		return false
	node.editor_position = position
	node.editor_size = size
	node.editor_collapsed = collapsed
	return true


## 获取编辑器或可视化工具可消费的节点目录。
## @return 节点目录字典。
func get_editor_catalog() -> Dictionary:
	var node_entries: Array[Dictionary] = []
	var categories: Dictionary = {}
	for node: GFFlowNode in nodes:
		if node == null:
			continue

		var category := String(node.category)
		if category.is_empty():
			category = "Flow"
		var entry := {
			"node_id": node.node_id,
			"display_name": node.get_display_name(),
			"category": category,
			"ports": node.describe_ports(),
			"editor": node.describe_editor(),
			"metadata": node.metadata.duplicate(true),
		}
		node_entries.append(entry)
		if not categories.has(category):
			categories[category] = []
		(categories[category] as Array).append(entry)

	node_entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_category := String(left.get("category", ""))
		var right_category := String(right.get("category", ""))
		if left_category != right_category:
			return left_category < right_category
		return String(left.get("display_name", "")) < String(right.get("display_name", ""))
	)
	return {
		"node_count": node_entries.size(),
		"nodes": node_entries,
		"categories": categories,
	}


## 描述流程图结构。
## @return 图描述字典。
func describe_graph() -> Dictionary:
	var node_descriptions: Array[Dictionary] = []
	for node: GFFlowNode in nodes:
		if node != null:
			node_descriptions.append(node.describe_node())
	return {
		"start_node_id": start_node_id,
		"node_count": node_descriptions.size(),
		"nodes": node_descriptions,
		"connection_count": connections.size(),
		"connections": _describe_connections(),
		"validate_port_compatibility": validate_port_compatibility,
		"diagnostics": {
			"warn_unreachable_nodes": warn_unreachable_nodes,
			"warn_cycles": warn_cycles,
			"warn_terminal_nodes": warn_terminal_nodes,
		},
		"editor": {
			"groups": editor_groups.duplicate(true),
			"metadata": editor_metadata.duplicate(true),
		},
	}


## 校验流程图结构。
## @return 校验报告。
func validate_graph() -> Dictionary:
	var report := {
		"ok": true,
		"healthy": true,
		"node_count": nodes.size(),
		"connection_count": connections.size(),
		"error_count": 0,
		"warning_count": 0,
		"issue_counts_by_kind": {},
		"summary": "",
		"next_action": "",
		"issues": [],
	}
	var node_ids: Dictionary = {}
	for index: int in range(nodes.size()):
		var node := nodes[index]
		if node == null:
			_append_validation_issue(report, "warning", "null_node", "", "Node at index %d is null." % index)
			continue

		var node_id := node.node_id
		if node_id == &"":
			_append_validation_issue(report, "error", "empty_node_id", "", "Flow node id is empty.")
			continue
		if node_ids.has(node_id):
			_append_validation_issue(report, "error", "duplicate_node_id", String(node_id), "Duplicate flow node id.")
		node_ids[node_id] = true
		_validate_node_ports(node, report)

	if start_node_id != &"" and not node_ids.has(start_node_id):
		_append_validation_issue(report, "error", "missing_start_node", String(start_node_id), "Start node does not exist.")

	for node: GFFlowNode in nodes:
		if node == null:
			continue
		for next_id: String in node.next_node_ids:
			if StringName(next_id) == &"":
				continue
			if not node_ids.has(StringName(next_id)):
				_append_validation_issue(report, "error", "missing_next_node", String(node.node_id), "Next node does not exist: %s" % next_id)

	_validate_connections(report, node_ids)
	_validate_topology_diagnostics(report, node_ids)
	return _GF_VALIDATION_REPORT_DICTIONARY_SCRIPT.finalize_report(report, "Flow graph", {
		"next_actions": _get_validation_next_actions(),
		"fallback_action": "Review the first reported flow graph issue before using this graph.",
	})


## 构建面向编辑器和可视化工具的流程图报告。
## @return 包含校验、目录和编辑器元数据的报告。
func build_editor_report() -> Dictionary:
	var validation := validate_graph()
	return {
		"ok": bool(validation.get("ok", false)),
		"healthy": bool(validation.get("healthy", false)),
		"summary": String(validation.get("summary", "")),
		"next_action": String(validation.get("next_action", "")),
		"validation": validation,
		"catalog": get_editor_catalog(),
		"editor": {
			"groups": editor_groups.duplicate(true),
			"metadata": editor_metadata.duplicate(true),
		},
	}


# --- 私有/辅助方法 ---

func _get_validation_next_actions() -> Dictionary:
	return {
		"null_node": "Remove the null entry or replace it with a valid GFFlowNode resource.",
		"empty_node_id": "Assign a stable node_id to every flow node.",
		"duplicate_node_id": "Rename one of the duplicated flow node ids.",
		"missing_start_node": "Set start_node_id to an existing node or leave it empty for manual runner selection.",
		"missing_next_node": "Create the referenced next node or remove it from next_node_ids.",
		"invalid_connection": "Fill both from_node_id and to_node_id for every flow connection.",
		"duplicate_connection": "Remove the duplicated flow connection.",
		"missing_connection_from_node": "Create the connection source node or remove the connection.",
		"missing_connection_to_node": "Create the connection target node or remove the connection.",
		"missing_connection_input_port": "Update the connection port id or add the missing port to the node.",
		"missing_connection_output_port": "Update the connection port id or add the missing port to the node.",
		"input_port_allows_single_connection": "Enable allow_multiple on the port or keep only one connection.",
		"output_port_allows_single_connection": "Enable allow_multiple on the port or keep only one connection.",
		"incompatible_connection_ports": "Update the connected port value types or disable strict compatibility validation for this graph.",
		"unreachable_node": "Connect the node from start_node_id or remove it from this graph resource.",
		"cycle_detected": "Review the reported cycle and make sure the runner loop guard is intentional for this graph.",
		"terminal_node": "Connect a successor, disable warn_terminal_nodes, or keep the node as an intentional endpoint.",
	}


func _validate_node_ports(node: GFFlowNode, report: Dictionary) -> void:
	_validate_ports(node.node_id, "input", node.input_ports, report)
	_validate_ports(node.node_id, "output", node.output_ports, report)


func _validate_ports(node_id: StringName, label: String, ports: Array, report: Dictionary) -> void:
	var port_ids: Dictionary = {}
	for port_variant: Variant in ports:
		var port := port_variant as GFFlowPort
		if port == null:
			_append_validation_issue(report, "warning", "null_%s_port" % label, String(node_id), "Flow node contains a null %s port." % label)
			continue

		var port_id := port.get_port_id()
		if port_id == &"":
			_append_validation_issue(report, "error", "empty_%s_port_id" % label, String(node_id), "Flow node contains an empty %s port id." % label)
			continue
		if port_ids.has(port_id):
			_append_validation_issue(report, "error", "duplicate_%s_port_id" % label, String(node_id), "Duplicate %s port id: %s" % [label, String(port_id)])
		port_ids[port_id] = true


func _validate_connections(report: Dictionary, node_ids: Dictionary) -> void:
	var connection_keys: Dictionary = {}
	var input_counts: Dictionary = {}
	var output_counts: Dictionary = {}
	for index: int in range(connections.size()):
		var connection := connections[index]
		var from_node_id := StringName(connection.get("from_node_id", &""))
		var from_port_id := StringName(connection.get("from_port_id", &""))
		var to_node_id := StringName(connection.get("to_node_id", &""))
		var to_port_id := StringName(connection.get("to_port_id", &""))
		var connection_key := _get_connection_key(from_node_id, from_port_id, to_node_id, to_port_id)

		if from_node_id == &"" or to_node_id == &"":
			_append_validation_issue(report, "error", "invalid_connection", str(index), "Flow connection requires from_node_id and to_node_id.")
			continue
		if connection_keys.has(connection_key):
			_append_validation_issue(report, "error", "duplicate_connection", String(from_node_id), "Duplicate flow connection.")
		connection_keys[connection_key] = true

		var from_node := get_node(from_node_id)
		var to_node := get_node(to_node_id)
		if from_node == null or not node_ids.has(from_node_id):
			_append_validation_issue(report, "error", "missing_connection_from_node", String(from_node_id), "Connection source node does not exist.")
		if to_node == null or not node_ids.has(to_node_id):
			_append_validation_issue(report, "error", "missing_connection_to_node", String(to_node_id), "Connection target node does not exist.")

		var output_port := _validate_connection_port(from_node, from_port_id, false, report)
		var input_port := _validate_connection_port(to_node, to_port_id, true, report)
		_count_connection_port(output_counts, from_node_id, from_port_id, output_port, false, report)
		_count_connection_port(input_counts, to_node_id, to_port_id, input_port, true, report)
		if validate_port_compatibility and output_port != null and input_port != null:
			var compatibility := output_port.get_compatibility_report(input_port)
			if not bool(compatibility.get("ok", false)):
				_append_validation_issue(report, "error", "incompatible_connection_ports", String(from_node_id), String(compatibility.get("message", "")))


func _validate_topology_diagnostics(report: Dictionary, node_ids: Dictionary) -> void:
	if node_ids.is_empty():
		return
	if warn_unreachable_nodes:
		_validate_unreachable_nodes(report, node_ids)
	if warn_cycles:
		_validate_cycles(report, node_ids)
	if warn_terminal_nodes:
		_validate_terminal_nodes(report, node_ids)


func _validate_unreachable_nodes(report: Dictionary, node_ids: Dictionary) -> void:
	if start_node_id == &"" or not node_ids.has(start_node_id):
		return

	var reachable: Dictionary = _GF_GRAPH_MATH_SCRIPT.find_reachable(
		start_node_id,
		INF,
		func(node_id: Variant) -> Array:
			return _get_successor_node_ids(StringName(node_id), node_ids)
	)
	for node_id: StringName in _get_sorted_node_ids(node_ids):
		if not reachable.has(node_id):
			_append_validation_issue(report, "warning", "unreachable_node", String(node_id), "Node is not reachable from start_node_id: %s" % String(node_id))


func _validate_cycles(report: Dictionary, node_ids: Dictionary) -> void:
	var states: Dictionary = {}
	var reported_cycles: Dictionary = {}
	for node_id: StringName in _get_sorted_node_ids(node_ids):
		if int(states.get(node_id, 0)) == 0:
			_visit_node_for_cycles(node_id, node_ids, states, [], reported_cycles, report)


func _visit_node_for_cycles(
	node_id: StringName,
	node_ids: Dictionary,
	states: Dictionary,
	stack: Array[StringName],
	reported_cycles: Dictionary,
	report: Dictionary
) -> void:
	states[node_id] = 1
	stack.append(node_id)
	for successor_id: StringName in _get_successor_node_ids(node_id, node_ids):
		var successor_state := int(states.get(successor_id, 0))
		if successor_state == 1:
			var cycle_key := _make_cycle_key(successor_id, stack)
			if not reported_cycles.has(cycle_key):
				reported_cycles[cycle_key] = true
				_append_validation_issue(report, "warning", "cycle_detected", cycle_key, "Flow graph contains a cycle: %s" % cycle_key)
			continue
		if successor_state == 0:
			_visit_node_for_cycles(successor_id, node_ids, states, stack, reported_cycles, report)

	stack.pop_back()
	states[node_id] = 2


func _validate_terminal_nodes(report: Dictionary, node_ids: Dictionary) -> void:
	for node_id: StringName in _get_sorted_node_ids(node_ids):
		if _get_successor_node_ids(node_id, node_ids).is_empty():
			_append_validation_issue(report, "warning", "terminal_node", String(node_id), "Node has no outgoing successor: %s" % String(node_id))


func _get_successor_node_ids(node_id: StringName, node_ids: Dictionary) -> Array[StringName]:
	var result: Array[StringName] = []
	var node := get_node(node_id)
	if node != null:
		for next_id_text: String in node.next_node_ids:
			_append_successor_id(result, StringName(next_id_text), node_ids)

	for connection: Dictionary in connections:
		if StringName(connection.get("from_node_id", &"")) != node_id:
			continue
		_append_successor_id(result, StringName(connection.get("to_node_id", &"")), node_ids)
	return result


func _append_successor_id(result: Array[StringName], node_id: StringName, node_ids: Dictionary) -> void:
	if node_id == &"" or not node_ids.has(node_id) or result.has(node_id):
		return
	result.append(node_id)


func _get_sorted_node_ids(node_ids: Dictionary) -> Array[StringName]:
	var values := PackedStringArray()
	for node_id_variant: Variant in node_ids.keys():
		values.append(String(node_id_variant))
	values.sort()

	var result: Array[StringName] = []
	for node_id_text: String in values:
		result.append(StringName(node_id_text))
	return result


func _make_cycle_key(first_repeated_node_id: StringName, stack: Array[StringName]) -> String:
	var parts := PackedStringArray()
	var include := false
	for node_id: StringName in stack:
		if node_id == first_repeated_node_id:
			include = true
		if include:
			parts.append(String(node_id))
	parts.append(String(first_repeated_node_id))
	return " -> ".join(parts)


func _validate_connection_port(
	node: GFFlowNode,
	port_id: StringName,
	is_input: bool,
	report: Dictionary
) -> GFFlowPort:
	if node == null or port_id == &"":
		return null

	var port := node.get_input_port(port_id) if is_input else node.get_output_port(port_id)
	if port == null:
		var kind := "missing_connection_input_port" if is_input else "missing_connection_output_port"
		var label := "input" if is_input else "output"
		_append_validation_issue(report, "error", kind, String(node.node_id), "Connection %s port does not exist: %s" % [label, String(port_id)])
	return port


func _count_connection_port(
	counts: Dictionary,
	node_id: StringName,
	port_id: StringName,
	port: GFFlowPort,
	is_input: bool,
	report: Dictionary
) -> void:
	if port_id == &"" or port == null:
		return

	var key := "%s:%s" % [String(node_id), String(port_id)]
	counts[key] = int(counts.get(key, 0)) + 1
	if int(counts[key]) <= 1 or port.allow_multiple:
		return

	var kind := "input_port_allows_single_connection" if is_input else "output_port_allows_single_connection"
	_append_validation_issue(report, "error", kind, String(node_id), "Flow port allows only one connection: %s" % String(port_id))


func _can_append_connection(
	from_node_id: StringName,
	from_port_id: StringName,
	to_node_id: StringName,
	to_port_id: StringName
) -> bool:
	var from_node := get_node(from_node_id)
	var to_node := get_node(to_node_id)
	if from_node == null or to_node == null:
		return true

	var output_port := from_node.get_output_port(from_port_id) if from_port_id != &"" else null
	var input_port := to_node.get_input_port(to_port_id) if to_port_id != &"" else null
	if from_port_id != &"" and output_port == null:
		return false
	if to_port_id != &"" and input_port == null:
		return false
	if input_port != null and not input_port.allow_multiple and not get_connections_to(to_node_id, to_port_id).is_empty():
		return false
	if output_port != null and not output_port.allow_multiple and not get_connections_from(from_node_id, from_port_id).is_empty():
		return false
	if validate_port_compatibility and output_port != null and input_port != null and not output_port.is_compatible_with(input_port):
		return false
	return true


func _make_connection(
	from_node_id: StringName,
	from_port_id: StringName,
	to_node_id: StringName,
	to_port_id: StringName,
	metadata: Dictionary
) -> Dictionary:
	return {
		"from_node_id": from_node_id,
		"from_port_id": from_port_id,
		"to_node_id": to_node_id,
		"to_port_id": to_port_id,
		"metadata": metadata.duplicate(true),
	}


func _connection_matches(
	connection: Dictionary,
	from_node_id: StringName,
	from_port_id: StringName,
	to_node_id: StringName,
	to_port_id: StringName
) -> bool:
	return (
		StringName(connection.get("from_node_id", &"")) == from_node_id
		and StringName(connection.get("from_port_id", &"")) == from_port_id
		and StringName(connection.get("to_node_id", &"")) == to_node_id
		and StringName(connection.get("to_port_id", &"")) == to_port_id
	)


func _get_connection_key(
	from_node_id: StringName,
	from_port_id: StringName,
	to_node_id: StringName,
	to_port_id: StringName
) -> String:
	return "%s:%s>%s:%s" % [
		String(from_node_id),
		String(from_port_id),
		String(to_node_id),
		String(to_port_id),
	]


func _describe_connections() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for connection: Dictionary in connections:
		result.append(connection.duplicate(true))
	return result


func _append_validation_issue(report: Dictionary, severity: String, kind: String, key: String, message: String) -> void:
	_GF_VALIDATION_REPORT_DICTIONARY_SCRIPT.append_issue(report, severity, StringName(kind), message, { "key": key })


func _make_connection_compatibility_report(ok: bool, reason: String, message: String) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"message": message,
	}
