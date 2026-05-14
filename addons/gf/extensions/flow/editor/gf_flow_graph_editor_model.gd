## GFFlowGraphEditorModel: FlowGraph 编辑器视图模型构建器。
##
## 将 GFFlowGraph 转换为 GraphEdit、自定义编辑器或项目工具可直接消费的
## 节点、端口、连接和校验结构。它只整理数据，不绑定具体 UI 实现。
class_name GFFlowGraphEditorModel
extends RefCounted


# --- 常量 ---

const GFGraphLayoutUtilityBase = preload("res://addons/gf/standard/foundation/math/gf_graph_layout_utility.gd")


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


## 自动生成并应用节点布局。
## @param graph: 流程图资源。
## @param options: 布局选项，透传给 GFGraphLayoutUtility.make_layered_layout()。
## @return 布局报告，包含 positions 与 changed_count。
func auto_layout(graph: GFFlowGraph, options: Dictionary = {}) -> Dictionary:
	if graph == null:
		return {
			"ok": false,
			"positions": {},
			"changed_count": 0,
			"error": "graph_is_null",
		}

	var node_ids := PackedStringArray()
	for node: GFFlowNode in graph.nodes:
		if node != null and node.node_id != &"":
			node_ids.append(String(node.node_id))

	var positions := GFGraphLayoutUtilityBase.make_layered_layout(node_ids, graph.connections, options)
	var changed_count := apply_node_positions(graph, positions)
	return {
		"ok": true,
		"positions": positions,
		"changed_count": changed_count,
	}


## 构建节点选择包，用于编辑器复制、剪切或跨工具传递。
## @param graph: 流程图资源。
## @param node_ids: 选中的节点标识列表。
## @return 选择包字典。
func build_selection_package(graph: GFFlowGraph, node_ids: PackedStringArray) -> Dictionary:
	if graph == null:
		return _make_edit_report(false, "graph_is_null")

	var selected_lookup := _make_selected_lookup(node_ids)
	var selected_nodes: Array[GFFlowNode] = []
	for node_id_text: String in node_ids:
		var node := graph.get_node(StringName(node_id_text))
		if node != null:
			selected_nodes.append(node.duplicate(true) as GFFlowNode)

	var selected_connections: Array[Dictionary] = []
	for connection: Dictionary in graph.connections:
		if _connection_is_internal(connection, selected_lookup):
			selected_connections.append(connection.duplicate(true))

	return {
		"ok": true,
		"node_count": selected_nodes.size(),
		"connection_count": selected_connections.size(),
		"nodes": selected_nodes,
		"connections": selected_connections,
		"node_ids": node_ids.duplicate(),
	}


## 将选择包粘贴到流程图。
## @param graph: 流程图资源。
## @param selection_package: build_selection_package() 返回的选择包。
## @param offset: 粘贴时叠加到节点编辑器位置的偏移。
## @param options: 可选参数，支持 keep_original_ids。
## @return 粘贴报告。
func paste_selection_package(
	graph: GFFlowGraph,
	selection_package: Dictionary,
	offset: Vector2 = Vector2.ZERO,
	options: Dictionary = {}
) -> Dictionary:
	if graph == null:
		return _make_edit_report(false, "graph_is_null")

	var source_nodes := selection_package.get("nodes", []) as Array
	if source_nodes == null:
		return _make_edit_report(false, "invalid_selection_package")

	var id_map: Dictionary = {}
	var reserved_ids: Dictionary = {}
	var added_node_ids := PackedStringArray()
	for mapping_variant: Variant in source_nodes:
		var mapping_node := mapping_variant as GFFlowNode
		if mapping_node == null:
			continue
		var mapping_source_id := mapping_node.node_id
		var mapping_next_id := _make_unique_node_id(graph, mapping_source_id, reserved_ids, bool(options.get("keep_original_ids", false)))
		id_map[mapping_source_id] = mapping_next_id
		reserved_ids[mapping_next_id] = true

	for copy_variant: Variant in source_nodes:
		var copy_source_node := copy_variant as GFFlowNode
		if copy_source_node == null:
			continue

		var next_node := copy_source_node.duplicate(true) as GFFlowNode
		if next_node == null:
			continue

		var copy_source_id := next_node.node_id
		var copy_next_id := StringName(id_map.get(copy_source_id, copy_source_id))
		next_node.node_id = copy_next_id
		next_node.editor_position += offset
		next_node.next_node_ids = _remap_node_ids(next_node.next_node_ids, id_map)
		graph.set_node(next_node)
		added_node_ids.append(String(copy_next_id))

	var source_connections := selection_package.get("connections", []) as Array
	var added_connection_count := 0
	var failed_connection_count := 0
	if source_connections != null:
		for connection_variant: Variant in source_connections:
			var connection := connection_variant as Dictionary
			if connection == null:
				continue

			var next_connection := _remap_connection(connection, id_map)
			var added := graph.add_connection(
				StringName(next_connection.get("from_node_id", &"")),
				StringName(next_connection.get("from_port_id", &"")),
				StringName(next_connection.get("to_node_id", &"")),
				StringName(next_connection.get("to_port_id", &"")),
				(next_connection.get("metadata", {}) as Dictionary).duplicate(true) if next_connection.get("metadata", {}) is Dictionary else {}
			)
			if added:
				added_connection_count += 1
			else:
				failed_connection_count += 1

	return {
		"ok": true,
		"added_node_ids": added_node_ids,
		"added_node_count": added_node_ids.size(),
		"added_connection_count": added_connection_count,
		"failed_connection_count": failed_connection_count,
		"id_map": id_map,
	}


## 从流程图移除一组节点及其相关连接。
## @param graph: 流程图资源。
## @param node_ids: 节点标识列表。
## @return 移除报告。
func remove_nodes(graph: GFFlowGraph, node_ids: PackedStringArray) -> Dictionary:
	if graph == null:
		return _make_edit_report(false, "graph_is_null")

	var removed_node_ids := PackedStringArray()
	for node_id_text: String in node_ids:
		var node_id := StringName(node_id_text)
		if not graph.has_node(node_id):
			continue
		graph.remove_node(node_id)
		removed_node_ids.append(String(node_id))

	return {
		"ok": true,
		"removed_node_ids": removed_node_ids,
		"removed_node_count": removed_node_ids.size(),
		"connection_count": graph.connections.size(),
	}


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
			"execution_slot_index": 0,
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
		description["graph_slot_index"] = result.size() + 1
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
		"from_graph_slot_index": _to_graph_slot_index(from_port_id, from_port_index),
		"to_node_id": to_node_id,
		"to_port_id": to_port_id,
		"to_port_index": to_port_index,
		"to_graph_slot_index": _to_graph_slot_index(to_port_id, to_port_index),
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


func _to_graph_slot_index(port_id: StringName, port_index: int) -> int:
	if port_id == &"":
		return 0
	if port_index < 0:
		return -1
	return port_index + 1


func _make_selected_lookup(node_ids: PackedStringArray) -> Dictionary:
	var result: Dictionary = {}
	for node_id_text: String in node_ids:
		result[StringName(node_id_text)] = true
	return result


func _connection_is_internal(connection: Dictionary, selected_lookup: Dictionary) -> bool:
	return (
		selected_lookup.has(StringName(connection.get("from_node_id", &"")))
		and selected_lookup.has(StringName(connection.get("to_node_id", &"")))
	)


func _make_unique_node_id(
	graph: GFFlowGraph,
	preferred_id: StringName,
	reserved_ids: Dictionary,
	keep_original_id: bool
) -> StringName:
	var base := String(preferred_id)
	if base.is_empty():
		base = "node"
	if keep_original_id and not graph.has_node(preferred_id) and not reserved_ids.has(preferred_id):
		return preferred_id
	if not graph.has_node(preferred_id) and not reserved_ids.has(preferred_id):
		return preferred_id

	var index := 2
	while true:
		var candidate := StringName("%s_%d" % [base, index])
		if not graph.has_node(candidate) and not reserved_ids.has(candidate):
			return candidate
		index += 1
	return StringName(base)


func _remap_node_ids(node_ids: PackedStringArray, id_map: Dictionary) -> PackedStringArray:
	var result := PackedStringArray()
	for node_id_text: String in node_ids:
		var node_id := StringName(node_id_text)
		result.append(String(id_map.get(node_id, node_id)))
	return result


func _remap_connection(connection: Dictionary, id_map: Dictionary) -> Dictionary:
	var result := connection.duplicate(true)
	var from_node_id := StringName(connection.get("from_node_id", &""))
	var to_node_id := StringName(connection.get("to_node_id", &""))
	result["from_node_id"] = id_map.get(from_node_id, from_node_id)
	result["to_node_id"] = id_map.get(to_node_id, to_node_id)
	return result


func _make_edit_report(ok: bool, error: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
	}
