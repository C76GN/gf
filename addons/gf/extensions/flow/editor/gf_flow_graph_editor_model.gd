## GFFlowGraphEditorModel: FlowGraph 编辑器视图模型构建器。
##
## 将 GFFlowGraph 转换为 GraphEdit、自定义编辑器或项目工具可直接消费的
## 节点、端口、连接和校验结构。它只整理数据，不绑定具体 UI 实现。
## [br]
## @api public
## [br]
## @category editor_api
## [br]
## @since 3.17.0
class_name GFFlowGraphEditorModel
extends RefCounted


# --- 常量 ---

const _GF_GRAPH_LAYOUT_UTILITY_SCRIPT: Script = preload("res://addons/gf/standard/foundation/math/gf_graph_layout_utility.gd")
const _GF_GRAPH_MATH_SCRIPT: Script = preload("res://addons/gf/standard/foundation/math/gf_graph_math.gd")
const _GF_VALIDATION_REPORT_DICTIONARY_SCRIPT: Script = preload("res://addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd")


# --- 公共变量 ---

## 节点未显式设置尺寸时使用的默认编辑器尺寸。
## [br]
## @api public
var default_node_size: Vector2 = Vector2(220.0, 120.0)

## 是否把校验失败的连接也写入视图模型。
## [br]
## @api public
var include_invalid_connections: bool = true


# --- 公共方法 ---

## 构建流程图编辑器视图模型。
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @return 视图模型字典。
## [br]
## @schema return: Dictionary，包含 ok、start_node_id、node_count、connection_count、nodes、node_lookup、connections、groups、metadata、validation。
func build_view_model(graph: Resource) -> Dictionary:
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

	var validation := validate_graph_for_editor(graph)
	var node_entries := _build_node_entries(graph)
	var node_lookup := _build_node_lookup(node_entries)
	var connection_entries := _build_connection_entries(graph, node_lookup)
	return {
		"ok": bool(validation.get("ok", false)),
		"start_node_id": _get_string_name_property(graph, &"start_node_id"),
		"node_count": node_entries.size(),
		"connection_count": connection_entries.size(),
		"nodes": node_entries,
		"node_lookup": node_lookup,
		"connections": connection_entries,
		"groups": _get_dictionary_array_property(graph, &"editor_groups"),
		"metadata": _get_dictionary_property(graph, &"editor_metadata"),
		"validation": validation,
	}


## 构建 FlowGraph 编辑器报告。
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @return 编辑器诊断、目录和元数据报告。
## [br]
## @schema return: Dictionary，包含 ok、healthy、summary、next_action、validation、catalog 和 editor。
func build_editor_report(graph: Resource) -> Dictionary:
	if graph == null:
		var validation := _make_null_validation_report()
		return {
			"ok": false,
			"healthy": false,
			"summary": String(validation.get("summary", "")),
			"next_action": String(validation.get("next_action", "")),
			"validation": validation,
			"catalog": _make_empty_catalog(),
			"editor": {
				"groups": [],
				"metadata": {},
				"metadata_schema": {},
				"metadata_validation": validate_metadata_for_editor({}, {}),
			},
		}

	var validation := validate_graph_for_editor(graph)
	var metadata := _get_dictionary_property(graph, &"editor_metadata")
	var metadata_schema := _get_dictionary_property(graph, &"metadata_schema")
	return {
		"ok": bool(validation.get("ok", false)),
		"healthy": bool(validation.get("healthy", false)),
		"summary": String(validation.get("summary", "")),
		"next_action": String(validation.get("next_action", "")),
		"validation": validation,
		"catalog": build_editor_catalog(graph),
		"editor": {
			"groups": _get_dictionary_array_property(graph, &"editor_groups"),
			"metadata": metadata,
			"metadata_schema": metadata_schema,
			"metadata_validation": validate_metadata_for_editor(metadata, metadata_schema),
		},
	}


## 获取编辑器可消费的节点目录，不调用节点/端口脚本方法。
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @return 节点目录字典。
## [br]
## @schema return: Dictionary，包含 node_count、nodes 和 categories；nodes 为节点目录记录数组。
func build_editor_catalog(graph: Resource) -> Dictionary:
	if graph == null:
		return _make_empty_catalog()

	var node_entries: Array[Dictionary] = []
	var categories: Dictionary = {}
	for node: Resource in _get_resource_array_property(graph, &"nodes"):
		if node == null:
			continue

		var category := String(_get_string_name_property(node, &"category"))
		if category.is_empty():
			category = "Flow"
		var entry := {
			"node_id": _get_node_id_for_editor(node),
			"display_name": _get_node_display_name_for_editor(node),
			"category": category,
			"ports": {
				"inputs": _build_port_entries(_get_resource_array_property(node, &"input_ports")),
				"outputs": _build_port_entries(_get_resource_array_property(node, &"output_ports")),
			},
			"editor": {
				"display_name": _get_node_display_name_for_editor(node),
				"category": _get_string_name_property(node, &"category"),
				"position": _get_vector2_property(node, &"editor_position"),
				"size": _get_vector2_property(node, &"editor_size"),
				"collapsed": _get_bool_property(node, &"editor_collapsed"),
			},
			"metadata": _get_dictionary_property(node, &"metadata"),
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


## 校验 FlowGraph 结构，不调用项目节点/端口脚本方法。
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @return 校验报告。
## [br]
## @schema return: GFValidationReportDictionary.finalize_report() 生成的 Dictionary，包含 ok、healthy、summary、issues、next_action 和计数字段。
func validate_graph_for_editor(graph: Resource) -> Dictionary:
	if graph == null:
		return _make_null_validation_report()

	var nodes := _get_resource_array_property(graph, &"nodes")
	var connections := _get_dictionary_array_property(graph, &"connections")
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
	var node_lookup: Dictionary = {}
	for index: int in range(nodes.size()):
		var node := nodes[index] as Resource
		if node == null:
			_append_validation_issue(report, "warning", "null_node", "", "Node at index %d is null." % index)
			continue

		var node_id := _get_node_id_for_editor(node)
		if node_id == &"":
			_append_validation_issue(report, "error", "empty_node_id", "", "Flow node id is empty.")
			continue
		if node_ids.has(node_id):
			_append_validation_issue(report, "error", "duplicate_node_id", String(node_id), "Duplicate flow node id.")
		node_ids[node_id] = true
		node_lookup[node_id] = node
		_validate_node_ports_for_editor(node, report)

	var start_node_id := _get_string_name_property(graph, &"start_node_id")
	if start_node_id != &"" and not node_ids.has(start_node_id):
		_append_validation_issue(report, "error", "missing_start_node", String(start_node_id), "Start node does not exist.")

	for node: Resource in nodes:
		if node == null:
			continue
		var node_id := _get_node_id_for_editor(node)
		for next_id_text: String in _get_packed_string_array_property(node, &"next_node_ids"):
			var next_id := StringName(next_id_text)
			if next_id == &"":
				continue
			if not node_ids.has(next_id):
				_append_validation_issue(report, "error", "missing_next_node", String(node_id), "Next node does not exist: %s" % next_id_text)

	_validate_connections_for_editor(graph, report, node_ids, node_lookup)
	_validate_topology_diagnostics_for_editor(graph, report, node_ids, node_lookup)
	var metadata_schema := _get_dictionary_property(graph, &"metadata_schema")
	if not metadata_schema.is_empty():
		_validate_metadata_against_schema(report, _get_dictionary_property(graph, &"editor_metadata"), metadata_schema, "editor_metadata")
	return _GF_VALIDATION_REPORT_DICTIONARY_SCRIPT.finalize_report(report, "Flow graph", {
		"next_actions": _get_validation_next_actions(),
		"fallback_action": "Review the first reported flow graph issue before using this graph.",
	})


## 校验编辑器元数据。
## [br]
## @api public
## [br]
## @param target_metadata: 待校验元数据。
## [br]
## @param schema: 轻量 Schema。
## [br]
## @return 校验报告。
## [br]
## @schema target_metadata: Dictionary，待校验的编辑器或项目工具元数据。
## [br]
## @schema schema: Dictionary，键为元数据 key，值为包含 required、allow_null、type、class_name、allowed_values 等字段的规则字典。
## [br]
## @schema return: GFValidationReportDictionary.finalize_report() 生成的 Dictionary，包含 ok、healthy、summary、issues、next_action 和计数字段。
func validate_metadata_for_editor(target_metadata: Dictionary, schema: Dictionary = {}) -> Dictionary:
	var report := {
		"ok": true,
		"healthy": true,
		"error_count": 0,
		"warning_count": 0,
		"issue_counts_by_kind": {},
		"summary": "",
		"next_action": "",
		"issues": [],
	}
	_validate_metadata_against_schema(report, target_metadata, schema, "metadata")
	return _GF_VALIDATION_REPORT_DICTIONARY_SCRIPT.finalize_report(report, "Flow metadata", {
		"next_actions": _get_metadata_validation_next_actions(),
		"fallback_action": "Review the reported metadata issue before saving or running this graph.",
	})


## 应用单个节点布局。
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @param node_id: 节点标识。
## [br]
## @param position: 编辑器坐标。
## [br]
## @param size: 编辑器尺寸；Vector2.ZERO 表示使用默认尺寸。
## [br]
## @param collapsed: 是否折叠。
## [br]
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
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @param positions: node_id 到 Vector2 的映射。
## [br]
## @return 成功更新的节点数量。
## [br]
## @schema positions: Dictionary，键为节点标识，值为 Vector2 编辑器坐标。
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
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @param options: 布局选项，透传给 GFGraphLayoutUtility.make_layered_layout()。
## [br]
## @return 布局报告，包含 positions 与 changed_count。
## [br]
## @schema options: Dictionary，传给 GFGraphLayoutUtility.make_layered_layout() 的布局选项。
## [br]
## @schema return: Dictionary，包含 ok、positions、changed_count，失败时包含 error。
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

	var positions: Dictionary = _GF_GRAPH_LAYOUT_UTILITY_SCRIPT.make_layered_layout(node_ids, graph.connections, options)
	var changed_count := apply_node_positions(graph, positions)
	return {
		"ok": true,
		"positions": positions,
		"changed_count": changed_count,
	}


## 构建节点选择包，用于编辑器复制、剪切或跨工具传递。
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @param node_ids: 选中的节点标识列表。
## [br]
## @return 选择包字典。
## [br]
## @schema return: Dictionary，包含 ok、node_count、connection_count、nodes、connections 和 node_ids。
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
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @param selection_package: build_selection_package() 返回的选择包。
## [br]
## @param offset: 粘贴时叠加到节点编辑器位置的偏移。
## [br]
## @param options: 可选参数，支持 keep_original_ids。
## [br]
## @return 粘贴报告。
## [br]
## @schema selection_package: Dictionary，由 build_selection_package() 返回，包含 nodes、connections 和 node_ids。
## [br]
## @schema options: Dictionary，可包含 keep_original_ids。
## [br]
## @schema return: Dictionary，包含 ok、added_node_ids、added_node_count、added_connection_count、failed_connection_count 和 id_map。
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
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @param node_ids: 节点标识列表。
## [br]
## @return 移除报告。
## [br]
## @schema return: Dictionary，包含 ok、removed_node_ids、removed_node_count 和 connection_count。
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

func _build_node_entries(graph: Resource) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node: Resource in _get_resource_array_property(graph, &"nodes"):
		if node == null:
			continue

		var input_ports := _build_port_entries(_get_resource_array_property(node, &"input_ports"))
		var output_ports := _build_port_entries(_get_resource_array_property(node, &"output_ports"))
		var size := _get_vector2_property(node, &"editor_size")
		if size == Vector2.ZERO:
			size = default_node_size
		result.append({
			"node_id": _get_node_id_for_editor(node),
			"display_name": _get_node_display_name_for_editor(node),
			"category": _get_string_name_property(node, &"category"),
			"position": _get_vector2_property(node, &"editor_position"),
			"size": size,
			"collapsed": _get_bool_property(node, &"editor_collapsed"),
			"execution_slot_index": 0,
			"input_ports": input_ports,
			"output_ports": output_ports,
			"input_port_indices": _build_port_index(input_ports),
			"output_port_indices": _build_port_index(output_ports),
			"metadata": _get_dictionary_property(node, &"metadata"),
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
		var port := ports[port_index] as Resource
		if port == null:
			continue

		var description := _describe_port_for_editor(port)
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


func _build_connection_entries(graph: Resource, node_lookup: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for connection: Dictionary in _get_dictionary_array_property(graph, &"connections"):
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


func _describe_port_for_editor(port: Resource) -> Dictionary:
	var port_id := _get_port_id_for_editor(port)
	return {
		"port_id": port_id,
		"display_name": _get_port_display_name_for_editor(port, port_id),
		"direction": _get_int_property(port, &"direction", GFFlowPort.Direction.OUTPUT),
		"value_type": _get_int_property(port, &"value_type", GFFlowPort.ValueType.ANY),
		"allow_multiple": _get_bool_property(port, &"allow_multiple"),
		"editor_color": _get_color_property(port, &"editor_color", Color.TRANSPARENT),
		"type_hint": _get_string_name_property(port, &"type_hint"),
		"class_name_hint": _get_string_name_property(port, &"class_name_hint"),
		"semantic_tags": _get_packed_string_array_property(port, &"semantic_tags"),
		"metadata": _get_dictionary_property(port, &"metadata"),
	}


func _get_node_id_for_editor(node: Resource) -> StringName:
	return _get_string_name_property(node, &"node_id")


func _get_node_display_name_for_editor(node: Resource) -> String:
	var display_name := _get_string_property(node, &"display_name")
	if not display_name.is_empty():
		return display_name

	var node_id := _get_node_id_for_editor(node)
	if node_id != &"":
		return String(node_id)
	return "Flow Node"


func _get_port_id_for_editor(port: Resource) -> StringName:
	var port_id := _get_string_name_property(port, &"port_id")
	if port_id != &"":
		return port_id
	if port != null and not port.resource_path.is_empty():
		return StringName(port.resource_path)
	return &""


func _get_port_display_name_for_editor(port: Resource, port_id: StringName) -> String:
	var display_name := _get_string_property(port, &"display_name")
	if not display_name.is_empty():
		return display_name
	if port_id != &"":
		return String(port_id)
	if port != null and not port.resource_path.is_empty():
		return port.resource_path.get_file().get_basename().capitalize()
	return "Flow Port"


func _validate_node_ports_for_editor(node: Resource, report: Dictionary) -> void:
	var node_id := _get_node_id_for_editor(node)
	_validate_ports_for_editor(node_id, "input", _get_resource_array_property(node, &"input_ports"), report)
	_validate_ports_for_editor(node_id, "output", _get_resource_array_property(node, &"output_ports"), report)


func _validate_ports_for_editor(node_id: StringName, label: String, ports: Array, report: Dictionary) -> void:
	var port_ids: Dictionary = {}
	for port_variant: Variant in ports:
		var port := port_variant as Resource
		if port == null:
			_append_validation_issue(report, "warning", "null_%s_port" % label, String(node_id), "Flow node contains a null %s port." % label)
			continue

		var port_id := _get_port_id_for_editor(port)
		if port_id == &"":
			_append_validation_issue(report, "error", "empty_%s_port_id" % label, String(node_id), "Flow node contains an empty %s port id." % label)
			continue
		if port_ids.has(port_id):
			_append_validation_issue(report, "error", "duplicate_%s_port_id" % label, String(node_id), "Duplicate %s port id: %s" % [label, String(port_id)])
		port_ids[port_id] = true


func _validate_connections_for_editor(
	graph: Resource,
	report: Dictionary,
	node_ids: Dictionary,
	node_lookup: Dictionary
) -> void:
	var connection_keys: Dictionary = {}
	var input_counts: Dictionary = {}
	var output_counts: Dictionary = {}
	var validate_port_compatibility := _get_bool_property(graph, &"validate_port_compatibility", true)
	var connections := _get_dictionary_array_property(graph, &"connections")
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

		var from_node := node_lookup.get(from_node_id, null) as Resource
		var to_node := node_lookup.get(to_node_id, null) as Resource
		if from_node == null or not node_ids.has(from_node_id):
			_append_validation_issue(report, "error", "missing_connection_from_node", String(from_node_id), "Connection source node does not exist.")
		if to_node == null or not node_ids.has(to_node_id):
			_append_validation_issue(report, "error", "missing_connection_to_node", String(to_node_id), "Connection target node does not exist.")

		var output_port := _validate_connection_port_for_editor(from_node, from_port_id, false, report)
		var input_port := _validate_connection_port_for_editor(to_node, to_port_id, true, report)
		_count_connection_port_for_editor(output_counts, from_node_id, from_port_id, output_port, false, report)
		_count_connection_port_for_editor(input_counts, to_node_id, to_port_id, input_port, true, report)
		if validate_port_compatibility and output_port != null and input_port != null:
			var compatibility := _get_compatibility_report_for_editor(output_port, input_port)
			if not bool(compatibility.get("ok", false)):
				_append_validation_issue(report, "error", "incompatible_connection_ports", String(from_node_id), String(compatibility.get("message", "")))


func _validate_connection_port_for_editor(
	node: Resource,
	port_id: StringName,
	is_input: bool,
	report: Dictionary
) -> Resource:
	if node == null or port_id == &"":
		return null

	var ports := _get_resource_array_property(node, &"input_ports" if is_input else &"output_ports")
	var port := _find_port_for_editor(ports, port_id)
	if port == null:
		var kind := "missing_connection_input_port" if is_input else "missing_connection_output_port"
		var label := "input" if is_input else "output"
		_append_validation_issue(report, "error", kind, String(_get_node_id_for_editor(node)), "Connection %s port does not exist: %s" % [label, String(port_id)])
	return port


func _find_port_for_editor(ports: Array, port_id: StringName) -> Resource:
	for port_variant: Variant in ports:
		var port := port_variant as Resource
		if port != null and _get_port_id_for_editor(port) == port_id:
			return port
	return null


func _count_connection_port_for_editor(
	counts: Dictionary,
	node_id: StringName,
	port_id: StringName,
	port: Resource,
	is_input: bool,
	report: Dictionary
) -> void:
	if port_id == &"" or port == null:
		return

	var key := "%s:%s" % [String(node_id), String(port_id)]
	counts[key] = int(counts.get(key, 0)) + 1
	if int(counts[key]) <= 1 or _get_bool_property(port, &"allow_multiple"):
		return

	var kind := "input_port_allows_single_connection" if is_input else "output_port_allows_single_connection"
	_append_validation_issue(report, "error", kind, String(node_id), "Flow port allows only one connection: %s" % String(port_id))


func _get_compatibility_report_for_editor(source_port: Resource, target_port: Resource) -> Dictionary:
	if target_port == null:
		return _make_compatibility_report_for_editor(false, "missing_target_port", "Target port is null.")

	var source_direction := _get_int_property(source_port, &"direction", GFFlowPort.Direction.OUTPUT)
	var target_direction := _get_int_property(target_port, &"direction", GFFlowPort.Direction.INPUT)
	if source_direction != GFFlowPort.Direction.OUTPUT or target_direction != GFFlowPort.Direction.INPUT:
		return _make_compatibility_report_for_editor(false, "invalid_direction", "Connections require an output port and an input port.")

	var source_type := _get_int_property(source_port, &"value_type", GFFlowPort.ValueType.ANY)
	var target_type := _get_int_property(target_port, &"value_type", GFFlowPort.ValueType.ANY)
	if not _value_types_are_compatible_for_editor(source_type, target_type):
		return _make_compatibility_report_for_editor(false, "value_type_mismatch", "Port value types are not compatible.")
	if not _class_hints_are_compatible_for_editor(source_port, target_port):
		return _make_compatibility_report_for_editor(false, "class_hint_mismatch", "Port class hints are not compatible.")

	return _make_compatibility_report_for_editor(true, "", "")


func _value_types_are_compatible_for_editor(source_type: int, target_type: int) -> bool:
	if source_type == GFFlowPort.ValueType.ANY or target_type == GFFlowPort.ValueType.ANY:
		return true
	return source_type == target_type


func _class_hints_are_compatible_for_editor(source_port: Resource, target_port: Resource) -> bool:
	var source_type := _get_int_property(source_port, &"value_type", GFFlowPort.ValueType.ANY)
	var target_type := _get_int_property(target_port, &"value_type", GFFlowPort.ValueType.ANY)
	if source_type != GFFlowPort.ValueType.OBJECT or target_type != GFFlowPort.ValueType.OBJECT:
		return true

	var source_class := _get_string_name_property(source_port, &"class_name_hint")
	var target_class := _get_string_name_property(target_port, &"class_name_hint")
	if source_class == &"" or target_class == &"":
		return true
	return source_class == target_class


func _make_compatibility_report_for_editor(ok: bool, reason: String, message: String) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"message": message,
	}


func _validate_topology_diagnostics_for_editor(
	graph: Resource,
	report: Dictionary,
	node_ids: Dictionary,
	node_lookup: Dictionary
) -> void:
	if node_ids.is_empty():
		return
	if _get_bool_property(graph, &"warn_unreachable_nodes", true):
		_validate_unreachable_nodes_for_editor(graph, report, node_ids, node_lookup)
	if _get_bool_property(graph, &"warn_cycles", true):
		_validate_cycles_for_editor(graph, report, node_ids, node_lookup)
	if _get_bool_property(graph, &"warn_terminal_nodes"):
		_validate_terminal_nodes_for_editor(graph, report, node_ids, node_lookup)


func _validate_unreachable_nodes_for_editor(
	graph: Resource,
	report: Dictionary,
	node_ids: Dictionary,
	node_lookup: Dictionary
) -> void:
	var start_node_id := _get_string_name_property(graph, &"start_node_id")
	if start_node_id == &"" or not node_ids.has(start_node_id):
		return

	var reachable: Dictionary = _GF_GRAPH_MATH_SCRIPT.find_reachable(
		start_node_id,
		INF,
		func(node_id: Variant) -> Array:
			return _get_successor_node_ids_for_editor(graph, StringName(node_id), node_ids, node_lookup)
	)
	for node_id: StringName in _get_sorted_node_ids(node_ids):
		if not reachable.has(node_id):
			_append_validation_issue(report, "warning", "unreachable_node", String(node_id), "Node is not reachable from start_node_id: %s" % String(node_id))


func _validate_cycles_for_editor(
	graph: Resource,
	report: Dictionary,
	node_ids: Dictionary,
	node_lookup: Dictionary
) -> void:
	var states: Dictionary = {}
	var reported_cycles: Dictionary = {}
	for node_id: StringName in _get_sorted_node_ids(node_ids):
		if int(states.get(node_id, 0)) == 0:
			_visit_node_for_cycles_for_editor(graph, node_id, node_ids, node_lookup, states, [], reported_cycles, report)


func _visit_node_for_cycles_for_editor(
	graph: Resource,
	node_id: StringName,
	node_ids: Dictionary,
	node_lookup: Dictionary,
	states: Dictionary,
	stack: Array[StringName],
	reported_cycles: Dictionary,
	report: Dictionary
) -> void:
	states[node_id] = 1
	stack.append(node_id)
	for successor_id: StringName in _get_successor_node_ids_for_editor(graph, node_id, node_ids, node_lookup):
		var successor_state := int(states.get(successor_id, 0))
		if successor_state == 1:
			var cycle_key := _make_cycle_key(successor_id, stack)
			if not reported_cycles.has(cycle_key):
				reported_cycles[cycle_key] = true
				_append_validation_issue(report, "warning", "cycle_detected", cycle_key, "Flow graph contains a cycle: %s" % cycle_key)
			continue
		if successor_state == 0:
			_visit_node_for_cycles_for_editor(graph, successor_id, node_ids, node_lookup, states, stack, reported_cycles, report)

	stack.pop_back()
	states[node_id] = 2


func _validate_terminal_nodes_for_editor(
	graph: Resource,
	report: Dictionary,
	node_ids: Dictionary,
	node_lookup: Dictionary
) -> void:
	for node_id: StringName in _get_sorted_node_ids(node_ids):
		if _get_successor_node_ids_for_editor(graph, node_id, node_ids, node_lookup).is_empty():
			_append_validation_issue(report, "warning", "terminal_node", String(node_id), "Node has no outgoing successor: %s" % String(node_id))


func _get_successor_node_ids_for_editor(
	graph: Resource,
	node_id: StringName,
	node_ids: Dictionary,
	node_lookup: Dictionary
) -> Array[StringName]:
	var result: Array[StringName] = []
	var node := node_lookup.get(node_id, null) as Resource
	if node != null:
		for next_id_text: String in _get_packed_string_array_property(node, &"next_node_ids"):
			_append_successor_id_for_editor(result, StringName(next_id_text), node_ids)

	for connection: Dictionary in _get_dictionary_array_property(graph, &"connections"):
		if StringName(connection.get("from_node_id", &"")) != node_id:
			continue
		_append_successor_id_for_editor(result, StringName(connection.get("to_node_id", &"")), node_ids)
	return result


func _append_successor_id_for_editor(result: Array[StringName], node_id: StringName, node_ids: Dictionary) -> void:
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


func _validate_metadata_against_schema(
	report: Dictionary,
	target_metadata: Dictionary,
	schema: Dictionary,
	label: String
) -> void:
	for key_variant: Variant in schema.keys():
		var key := StringName(key_variant)
		var rule := schema[key_variant] as Dictionary
		if rule == null:
			_append_validation_issue(report, "warning", "metadata_invalid_rule", String(key), "%s schema rule must be a Dictionary: %s" % [label, String(key)])
			continue

		var has_key := _metadata_has_key(target_metadata, key)
		var required := bool(rule.get("required", false))
		if required and not has_key:
			_append_validation_issue(report, "error", "metadata_missing_required", String(key), "%s is missing required metadata: %s" % [label, String(key)])
			continue
		if not has_key:
			continue

		var value: Variant = _metadata_get_value(target_metadata, key)
		if value == null:
			if not bool(rule.get("allow_null", true)):
				_append_validation_issue(report, "error", "metadata_null_not_allowed", String(key), "%s metadata does not allow null: %s" % [label, String(key)])
			continue

		if rule.has("type"):
			var expected_type := int(rule.get("type", TYPE_NIL))
			if expected_type != TYPE_NIL and typeof(value) != expected_type:
				_append_validation_issue(report, "error", "metadata_type_mismatch", String(key), "%s metadata type does not match schema: %s" % [label, String(key)])

		var expected_class := String(rule.get("class_name", ""))
		if not expected_class.is_empty() and not (value is Object and (value as Object).is_class(expected_class)):
			_append_validation_issue(report, "error", "metadata_class_mismatch", String(key), "%s metadata class does not match schema: %s" % [label, String(key)])

		var allowed_values := rule.get("allowed_values", []) as Array
		if allowed_values != null and not allowed_values.is_empty() and not allowed_values.has(value):
			_append_validation_issue(report, "error", "metadata_value_not_allowed", String(key), "%s metadata value is not allowed: %s" % [label, String(key)])


func _metadata_has_key(target_metadata: Dictionary, key: StringName) -> bool:
	return target_metadata.has(key) or target_metadata.has(String(key))


func _metadata_get_value(target_metadata: Dictionary, key: StringName) -> Variant:
	if target_metadata.has(key):
		return target_metadata[key]
	return target_metadata.get(String(key), null)


func _append_validation_issue(report: Dictionary, severity: String, kind: String, key: String, message: String) -> void:
	_GF_VALIDATION_REPORT_DICTIONARY_SCRIPT.append_issue(report, severity, StringName(kind), message, { "key": key })


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
		"metadata_missing_required": "Add the required metadata key or relax the metadata schema.",
		"metadata_null_not_allowed": "Provide a non-null metadata value or allow null in the schema.",
		"metadata_type_mismatch": "Update the metadata value type or the schema type hint.",
		"metadata_class_mismatch": "Update the metadata object class or the schema class_name hint.",
		"metadata_value_not_allowed": "Use one of the schema allowed_values or remove the restriction.",
		"metadata_invalid_rule": "Replace the metadata schema entry with a Dictionary rule.",
	}


func _get_metadata_validation_next_actions() -> Dictionary:
	return {
		"metadata_missing_required": "Add the required metadata key or relax the metadata schema.",
		"metadata_null_not_allowed": "Provide a non-null metadata value or allow null in the schema.",
		"metadata_type_mismatch": "Update the metadata value type or the schema type hint.",
		"metadata_class_mismatch": "Update the metadata object class or the schema class_name hint.",
		"metadata_value_not_allowed": "Use one of the schema allowed_values or remove the restriction.",
		"metadata_invalid_rule": "Replace the metadata schema entry with a Dictionary rule.",
	}


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


func _make_null_validation_report() -> Dictionary:
	var report := {
		"ok": false,
		"healthy": false,
		"node_count": 0,
		"connection_count": 0,
		"error_count": 0,
		"warning_count": 0,
		"issue_counts_by_kind": {},
		"summary": "",
		"next_action": "",
		"issues": [],
	}
	_append_validation_issue(report, "error", "graph_is_null", "", "Flow graph is null.")
	return _GF_VALIDATION_REPORT_DICTIONARY_SCRIPT.finalize_report(report, "Flow graph", {
		"next_actions": {},
		"fallback_action": "Load a valid GFFlowGraph resource before editing.",
	})


func _make_empty_catalog() -> Dictionary:
	return {
		"node_count": 0,
		"nodes": [],
		"categories": {},
	}


func _get_resource_array_property(object: Object, property_name: StringName) -> Array:
	if object == null:
		return []
	var value: Variant = object.get(property_name)
	if value is Array:
		return (value as Array).duplicate()
	return []


func _get_dictionary_array_property(object: Object, property_name: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if object == null:
		return result
	var value: Variant = object.get(property_name)
	var source := value as Array
	if source == null:
		return result
	for item: Variant in source:
		var dictionary := item as Dictionary
		if dictionary != null:
			result.append(dictionary.duplicate(true))
	return result


func _get_dictionary_property(object: Object, property_name: StringName) -> Dictionary:
	if object == null:
		return {}
	var value: Variant = object.get(property_name)
	var dictionary := value as Dictionary
	if dictionary == null:
		return {}
	return dictionary.duplicate(true)


func _get_packed_string_array_property(object: Object, property_name: StringName) -> PackedStringArray:
	if object == null:
		return PackedStringArray()
	var value: Variant = object.get(property_name)
	if value is PackedStringArray:
		return (value as PackedStringArray).duplicate()
	if value is Array:
		var result := PackedStringArray()
		for item: Variant in value:
			result.append(String(item))
		return result
	return PackedStringArray()


func _get_string_name_property(object: Object, property_name: StringName, default_value: StringName = &"") -> StringName:
	if object == null:
		return default_value
	var value: Variant = object.get(property_name)
	if value == null:
		return default_value
	return StringName(value)


func _get_string_property(object: Object, property_name: StringName, default_value: String = "") -> String:
	if object == null:
		return default_value
	var value: Variant = object.get(property_name)
	if value == null:
		return default_value
	return String(value)


func _get_bool_property(object: Object, property_name: StringName, default_value: bool = false) -> bool:
	if object == null:
		return default_value
	var value: Variant = object.get(property_name)
	if value == null:
		return default_value
	return bool(value)


func _get_int_property(object: Object, property_name: StringName, default_value: int = 0) -> int:
	if object == null:
		return default_value
	var value: Variant = object.get(property_name)
	if value == null:
		return default_value
	return int(value)


func _get_vector2_property(object: Object, property_name: StringName, default_value: Vector2 = Vector2.ZERO) -> Vector2:
	if object == null:
		return default_value
	var value: Variant = object.get(property_name)
	if value is Vector2:
		return value
	return default_value


func _get_color_property(object: Object, property_name: StringName, default_value: Color = Color.TRANSPARENT) -> Color:
	if object == null:
		return default_value
	var value: Variant = object.get(property_name)
	if value is Color:
		return value
	return default_value


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
