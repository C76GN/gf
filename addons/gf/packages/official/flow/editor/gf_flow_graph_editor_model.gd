## GFFlowGraphEditorModel: FlowGraph 编辑器视图模型构建器。
##
## 将 GFFlowGraph 转换为 GraphEdit、自定义编辑器或项目工具可直接消费的
## 节点、端口、连接和校验结构。它只整理数据，不绑定具体 UI 实现。
class_name GFFlowGraphEditorModel
extends RefCounted


# --- 公共变量 ---

## 节点未显式设置尺寸时使用的默认编辑器尺寸。
var default_node_size: Vector2 = Vector2(220.0, 120.0)

## 是否把校验失败的连接也写入视图模型。
var include_invalid_connections: bool = true


# --- 公共方法 ---

## 构建流程图编辑器视图模型。
## @param graph: 流程图资源。
## @return 视图模型字典。
func build_view_model(graph: GFFlowGraph) -> Dictionary:
	if graph == null:
		return {
			"ok": false,
			"node_count": 0,
			"connection_count": 0,
			"nodes": [],
			"connections": [],
			"validation": {
				"ok": false,
				"summary": "Flow graph is null.",
				"issues": [],
			},
		}

	var validation := graph.validate_graph()
	var node_entries := _build_node_entries(graph)
	var node_lookup := _build_node_lookup(node_entries)
	var connection_entries := _build_connection_entries(graph, node_lookup)
	return {
		"ok": bool(validation.get("ok", false)),
		"start_node_id": graph.start_node_id,
		"node_count": node_entries.size(),
		"connection_count": connection_entries.size(),
		"nodes": node_entries,
		"node_lookup": node_lookup,
		"connections": connection_entries,
		"groups": graph.editor_groups.duplicate(true),
		"metadata": graph.editor_metadata.duplicate(true),
		"validation": validation,
	}


## 应用单个节点布局。
## @param graph: 流程图资源。
## @param node_id: 节点标识。
## @param position: 编辑器坐标。
## @param size: 编辑器尺寸；Vector2.ZERO 表示使用默认尺寸。
## @param collapsed: 是否折叠。
## @return 应用成功返回 true。
func apply_node_layout(
	graph: GFFlowGraph,
	node_id: StringName,
	position: Vector2,
	size: Vector2 = Vector2.ZERO,
	collapsed: bool = false
) -> bool:
	if graph == null:
		return false
	return graph.set_node_editor_layout(node_id, position, size, collapsed)


## 批量应用节点位置。
## @param graph: 流程图资源。
## @param positions: node_id 到 Vector2 的映射。
## @return 成功更新的节点数量。
func apply_node_positions(graph: GFFlowGraph, positions: Dictionary) -> int:
	if graph == null:
		return 0

	var changed_count := 0
	for key: Variant in positions.keys():
		var position: Variant = positions[key]
		if position is Vector2 and graph.set_node_editor_position(StringName(key), position):
			changed_count += 1
	return changed_count


# --- 私有/辅助方法 ---

func _build_node_entries(graph: GFFlowGraph) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node: GFFlowNode in graph.nodes:
		if node == null:
			continue

		var input_ports := _build_port_entries(node.get_input_ports())
		var output_ports := _build_port_entries(node.get_output_ports())
		var size := node.editor_size
		if size == Vector2.ZERO:
			size = default_node_size
		result.append({
			"node_id": node.node_id,
			"display_name": node.get_display_name(),
			"category": node.category,
			"position": node.editor_position,
			"size": size,
			"collapsed": node.editor_collapsed,
			"input_ports": input_ports,
			"output_ports": output_ports,
			"input_port_indices": _build_port_index(input_ports),
			"output_port_indices": _build_port_index(output_ports),
			"metadata": node.metadata.duplicate(true),
		})
	return result


func _build_node_lookup(node_entries: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {}
	for node_entry: Dictionary in node_entries:
		result[node_entry.get("node_id", &"")] = node_entry
	return result


func _build_port_entries(ports: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for port_index: int in range(ports.size()):
		var port := ports[port_index] as GFFlowPort
		if port == null:
			continue

		var description := port.describe()
		description["index"] = result.size()
		description["source_index"] = port_index
		result.append(description)
	return result


func _build_port_index(port_entries: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {}
	for port_entry: Dictionary in port_entries:
		result[port_entry.get("port_id", &"")] = int(port_entry.get("index", -1))
	return result


func _build_connection_entries(graph: GFFlowGraph, node_lookup: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for connection: Dictionary in graph.connections:
		var entry := _build_connection_entry(connection, node_lookup)
		if include_invalid_connections or bool(entry.get("valid", false)):
			result.append(entry)
	return result


func _build_connection_entry(connection: Dictionary, node_lookup: Dictionary) -> Dictionary:
	var from_node_id := StringName(connection.get("from_node_id", &""))
	var from_port_id := StringName(connection.get("from_port_id", &""))
	var to_node_id := StringName(connection.get("to_node_id", &""))
	var to_port_id := StringName(connection.get("to_port_id", &""))
	var from_node := node_lookup.get(from_node_id, {}) as Dictionary
	var to_node := node_lookup.get(to_node_id, {}) as Dictionary
	var from_port_index := _get_port_index(from_node, "output_port_indices", from_port_id)
	var to_port_index := _get_port_index(to_node, "input_port_indices", to_port_id)
	var valid := from_node != null and not from_node.is_empty() and to_node != null and not to_node.is_empty()
	if from_port_id != &"" and from_port_index < 0:
		valid = false
	if to_port_id != &"" and to_port_index < 0:
		valid = false
	return {
		"from_node_id": from_node_id,
		"from_port_id": from_port_id,
		"from_port_index": from_port_index,
		"to_node_id": to_node_id,
		"to_port_id": to_port_id,
		"to_port_index": to_port_index,
		"valid": valid,
		"metadata": (connection.get("metadata", {}) as Dictionary).duplicate(true) if connection.get("metadata", {}) is Dictionary else {},
	}


func _get_port_index(node_entry: Dictionary, index_key: String, port_id: StringName) -> int:
	if port_id == &"":
		return 0
	if node_entry == null or node_entry.is_empty():
		return -1

	var indices := node_entry.get(index_key, {}) as Dictionary
	if indices == null:
		return -1
	return int(indices.get(port_id, -1))
