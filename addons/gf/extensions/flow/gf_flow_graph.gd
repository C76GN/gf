## GFFlowGraph: 资源化通用流程图。
##
## 只维护节点集合与起始节点，不规定具体编辑器表现或业务语义。
class_name GFFlowGraph
extends Resource


# --- 导出变量 ---

## 起始节点标识。
@export var start_node_id: StringName = &""

## 流程节点列表。
@export var nodes: Array[GFFlowNode] = []

## 节点连接列表。连接结构为 from_node_id/from_port_id/to_node_id/to_port_id/metadata。
@export var connections: Array[Dictionary] = []

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
	report["ok"] = _validation_has_no_error_issues(report)
	return _finalize_validation_report(report)


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

func _finalize_validation_report(report: Dictionary) -> Dictionary:
	var error_count := 0
	var warning_count := 0
	var issue_counts_by_kind: Dictionary = {}
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue == null:
			continue

		var severity := String(issue.get("severity", ""))
		var kind := String(issue.get("kind", "unknown"))
		issue_counts_by_kind[kind] = int(issue_counts_by_kind.get(kind, 0)) + 1
		if severity == "error":
			error_count += 1
		elif severity == "warning":
			warning_count += 1

	report["error_count"] = error_count
	report["warning_count"] = warning_count
	report["issue_counts_by_kind"] = issue_counts_by_kind
	report["ok"] = error_count == 0
	report["healthy"] = error_count == 0 and warning_count == 0
	report["summary"] = _make_validation_summary(error_count, warning_count)
	report["next_action"] = _get_next_action_for_validation_report(report)
	return report


func _make_validation_summary(error_count: int, warning_count: int) -> String:
	if error_count > 0:
		return "Flow graph has %d error(s) and %d warning(s)." % [error_count, warning_count]
	if warning_count > 0:
		return "Flow graph has %d warning(s)." % warning_count
	return "Flow graph is healthy."


func _get_next_action_for_validation_report(report: Dictionary) -> String:
	var first_warning: Dictionary = {}
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue == null:
			continue
		if String(issue.get("severity", "")) == "error":
			return _get_next_action_for_issue(issue)
		if first_warning.is_empty() and String(issue.get("severity", "")) == "warning":
			first_warning = issue

	if not first_warning.is_empty():
		return _get_next_action_for_issue(first_warning)
	return "No action required."


func _get_next_action_for_issue(issue: Dictionary) -> String:
	match String(issue.get("kind", "")):
		"null_node":
			return "Remove the null entry or replace it with a valid GFFlowNode resource."
		"empty_node_id":
			return "Assign a stable node_id to every flow node."
		"duplicate_node_id":
			return "Rename one of the duplicated flow node ids."
		"missing_start_node":
			return "Set start_node_id to an existing node or leave it empty for manual runner selection."
		"missing_next_node":
			return "Create the referenced next node or remove it from next_node_ids."
		"invalid_connection":
			return "Fill both from_node_id and to_node_id for every flow connection."
		"duplicate_connection":
			return "Remove the duplicated flow connection."
		"missing_connection_from_node":
			return "Create the connection source node or remove the connection."
		"missing_connection_to_node":
			return "Create the connection target node or remove the connection."
		"missing_connection_input_port", "missing_connection_output_port":
			return "Update the connection port id or add the missing port to the node."
		"input_port_allows_single_connection", "output_port_allows_single_connection":
			return "Enable allow_multiple on the port or keep only one connection."
		_:
			return "Review the first reported flow graph issue before using this graph."


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
	(report["issues"] as Array).append({
		"severity": severity,
		"kind": kind,
		"key": key,
		"message": message,
	})


func _validation_has_no_error_issues(report: Dictionary) -> bool:
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue != null and String(issue.get("severity", "")) == "error":
			return false
	return true
