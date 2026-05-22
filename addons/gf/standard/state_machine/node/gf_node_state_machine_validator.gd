@tool

## GFNodeStateMachineValidator: 节点状态机结构校验工具。
##
## 只检查状态机、状态组和状态资源挂接是否自洽，不执行状态切换，
## 也不推断项目业务中的转移规则。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFNodeStateMachineValidator
extends RefCounted


# --- 常量 ---

const _GF_NODE_STATE_BASE := preload("res://addons/gf/standard/state_machine/node/gf_node_state.gd")
const _GF_NODE_STATE_BEHAVIOR_BASE := preload("res://addons/gf/standard/state_machine/node/gf_node_state_behavior.gd")
const _GF_NODE_STATE_CONDITION_BASE := preload("res://addons/gf/standard/state_machine/node/gf_node_state_condition.gd")
const _GF_NODE_STATE_GROUP_BASE := preload("res://addons/gf/standard/state_machine/node/gf_node_state_group.gd")
const _GF_NODE_STATE_MACHINE_BASE := preload("res://addons/gf/standard/state_machine/node/gf_node_state_machine.gd")
const _GF_VALIDATION_REPORT_BASE := preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")


# --- 公共方法 ---

## 校验一个节点状态机的直接子状态和显式状态组。
## [br]
## @api public
## [br]
## @param machine: 要校验的节点状态机。
## [br]
## @param options: 可选校验选项，支持 check_state_resources、require_initial_state。
## [br]
## @schema options: 校验选项 Dictionary；支持 check_state_resources: bool 和 require_initial_state: bool。
## [br]
## @return: 校验报告。
static func validate_machine(machine: GFNodeStateMachine, options: Dictionary = {}) -> GFValidationReport:
	var report := _GF_VALIDATION_REPORT_BASE.new("GFNodeStateMachine") as GFValidationReport
	if machine == null:
		report.add_error(&"missing_state_machine", "State machine is null.")
		return report

	var internal_states: Array[GFNodeState] = []
	var groups: Array[GFNodeStateGroup] = []
	for child: Node in machine.get_children():
		if bool(child.get_meta(_GF_NODE_STATE_MACHINE_BASE.META_INTERNAL_GROUP, false)):
			continue
		if child is _GF_NODE_STATE_GROUP_BASE:
			groups.append(child as GFNodeStateGroup)
		elif child is _GF_NODE_STATE_BASE:
			internal_states.append(child as GFNodeState)

	var group_names: Dictionary = {}
	if not internal_states.is_empty():
		_validate_group_shape(
			report,
			_GF_NODE_STATE_MACHINE_BASE.INTERNAL_GROUP_NAME,
			internal_states,
			_get_machine_initial_state(machine),
			_should_require_machine_initial_state(machine, options),
			_get_node_path_text(machine),
			options
		)
		group_names[_GF_NODE_STATE_MACHINE_BASE.INTERNAL_GROUP_NAME] = _get_node_path_text(machine)

	for group: GFNodeStateGroup in groups:
		var group_name := _get_group_name(group)
		var group_path := _get_node_path_text(group)
		if group_names.has(group_name):
			report.add_error(
				&"duplicate_state_group",
				"State group name is duplicated.",
				group_name,
				group_path,
				{ "first_path": String(group_names[group_name]) }
			)
		else:
			group_names[group_name] = group_path
		report.merge(validate_group(group, options), false)

	if internal_states.is_empty() and groups.is_empty():
		report.add_error(
			&"empty_state_machine",
			"State machine has no direct states or state groups.",
			null,
			_get_node_path_text(machine)
		)

	report.metadata["group_count"] = group_names.size()
	report.metadata["direct_state_count"] = internal_states.size()
	return report


## 校验一个节点状态组的直接子状态。
## [br]
## @api public
## [br]
## @param group: 要校验的状态组。
## [br]
## @param options: 可选校验选项，支持 check_state_resources、require_initial_state。
## [br]
## @schema options: 校验选项 Dictionary；支持 check_state_resources: bool 和 require_initial_state: bool。
## [br]
## @return: 校验报告。
static func validate_group(group: GFNodeStateGroup, options: Dictionary = {}) -> GFValidationReport:
	var report := _GF_VALIDATION_REPORT_BASE.new("GFNodeStateGroup") as GFValidationReport
	if group == null:
		report.add_error(&"missing_state_group", "State group is null.")
		return report

	var states := _collect_direct_states(group)
	_validate_group_shape(
		report,
		_get_group_name(group),
		states,
		_get_group_initial_state(group),
		_should_require_group_initial_state(group, options),
		_get_node_path_text(group),
		options
	)
	return report


## 校验一组状态名、初始状态和状态资源挂接。
## [br]
## @api public
## [br]
## @param states: 要校验的状态列表。
## [br]
## @schema states: 元素为 GFNodeState 的状态列表。
## [br]
## @param initial_state: 可选初始状态名。
## [br]
## @param subject: 报告主题。
## [br]
## @param options: 可选校验选项，支持 check_state_resources、require_initial_state。
## [br]
## @schema options: 校验选项 Dictionary；支持 check_state_resources: bool 和 require_initial_state: bool。
## [br]
## @return: 校验报告。
static func validate_state_list(
	states: Array[GFNodeState],
	initial_state: StringName = &"",
	subject: String = "GFNodeStateList",
	options: Dictionary = {}
) -> GFValidationReport:
	var report := _GF_VALIDATION_REPORT_BASE.new(subject) as GFValidationReport
	_validate_group_shape(
		report,
		StringName(subject),
		states,
		initial_state,
		bool(options.get("require_initial_state", false)),
		"",
		options
	)
	return report


# --- 私有/辅助方法 ---

static func _validate_group_shape(
	report: GFValidationReport,
	group_name: StringName,
	states: Array[GFNodeState],
	initial_state: StringName,
	require_initial_state: bool,
	group_path: String,
	options: Dictionary
) -> void:
	if states.is_empty():
		report.add_error(
			&"empty_state_group",
			"State group has no states.",
			group_name,
			group_path
		)
		return

	var state_paths_by_name: Dictionary = {}
	for state: GFNodeState in states:
		_validate_state(report, group_name, state, state_paths_by_name, options)

	if require_initial_state and initial_state == &"":
		report.add_warning(
			&"missing_initial_state",
			"State group has no initial state.",
			group_name,
			group_path
		)
	elif initial_state != &"" and not state_paths_by_name.has(initial_state):
		report.add_error(
			&"invalid_initial_state",
			"Initial state does not exist in this state group.",
			initial_state,
			group_path,
			{ "group_name": group_name }
		)

	report.metadata["state_count"] = int(report.metadata.get("state_count", 0)) + states.size()


static func _validate_state(
	report: GFValidationReport,
	group_name: StringName,
	state: GFNodeState,
	state_paths_by_name: Dictionary,
	options: Dictionary
) -> void:
	if state == null:
		report.add_error(&"missing_state", "State entry is null.", group_name)
		return

	var state_name := _get_state_name(state)
	var state_path := _get_node_path_text(state)
	if state_name == &"":
		report.add_error(
			&"empty_state_name",
			"State name is empty.",
			group_name,
			state_path
		)
	elif state_paths_by_name.has(state_name):
		report.add_error(
			&"duplicate_state_name",
			"State name is duplicated inside the group.",
			state_name,
			state_path,
			{
				"group_name": group_name,
				"first_path": String(state_paths_by_name[state_name]),
			}
		)
	else:
		state_paths_by_name[state_name] = state_path

	if bool(options.get("check_state_resources", true)):
		_validate_resource_list(
			report,
			_get_resource_array_property(state, &"enter_conditions"),
			&"enter_conditions",
			&"evaluate",
			state_name,
			state_path
		)
		_validate_resource_list(
			report,
			_get_resource_array_property(state, &"exit_conditions"),
			&"exit_conditions",
			&"evaluate",
			state_name,
			state_path
		)
		_validate_behavior_resources(
			report,
			_get_resource_array_property(state, &"behaviors"),
			state_name,
			state_path
		)


static func _validate_resource_list(
	report: GFValidationReport,
	resources: Array[Resource],
	field_name: StringName,
	required_method: StringName,
	state_name: StringName,
	state_path: String
) -> void:
	var ids: Dictionary = {}
	for index: int in range(resources.size()):
		var resource := resources[index]
		var metadata := {
			"field": field_name,
			"index": index,
			"state_name": state_name,
		}
		if resource == null:
			report.add_warning(
				&"missing_state_resource",
				"State resource slot is empty.",
				state_name,
				state_path,
				metadata
			)
			continue
		if not _resource_exposes_required_method(resource, field_name, required_method):
			report.add_error(
				&"invalid_state_resource",
				"State resource does not expose the required method.",
				state_name,
				state_path,
				metadata.merged({ "required_method": required_method })
			)
		_track_duplicate_resource_id(report, resource, field_name, ids, state_name, state_path, metadata)


static func _validate_behavior_resources(
	report: GFValidationReport,
	behaviors: Array[Resource],
	state_name: StringName,
	state_path: String
) -> void:
	var ids: Dictionary = {}
	for index: int in range(behaviors.size()):
		var behavior := behaviors[index]
		var metadata := {
			"field": &"behaviors",
			"index": index,
			"state_name": state_name,
		}
		if behavior == null:
			report.add_warning(
				&"missing_state_resource",
				"State behavior slot is empty.",
				state_name,
				state_path,
				metadata
			)
			continue
		if not _has_any_behavior_method(behavior):
			report.add_warning(
				&"inert_state_behavior",
				"State behavior exposes no known lifecycle hook.",
				state_name,
				state_path,
				metadata
			)
		_track_duplicate_resource_id(report, behavior, &"behaviors", ids, state_name, state_path, metadata)


static func _track_duplicate_resource_id(
	report: GFValidationReport,
	resource: Resource,
	field_name: StringName,
	ids: Dictionary,
	state_name: StringName,
	state_path: String,
	metadata: Dictionary
) -> void:
	var id_value := _get_resource_id(resource, field_name)
	if id_value == &"":
		return
	if ids.has(id_value):
		report.add_warning(
			&"duplicate_state_resource_id",
			"State resource id is duplicated inside the same resource list.",
			state_name,
			state_path,
			metadata.merged({
				"resource_id": id_value,
				"first_index": int(ids[id_value]),
			})
		)
	else:
		ids[id_value] = int(metadata.get("index", -1))


static func _has_any_behavior_method(resource: Resource) -> bool:
	if resource is _GF_NODE_STATE_BEHAVIOR_BASE:
		return true
	return (
		resource.has_method(&"initialize")
		or resource.has_method(&"enter")
		or resource.has_method(&"exit")
		or resource.has_method(&"pause")
		or resource.has_method(&"resume")
		or resource.has_method(&"handle_state_event")
	)


static func _resource_exposes_required_method(resource: Resource, field_name: StringName, required_method: StringName) -> bool:
	if resource == null:
		return false
	if field_name == &"enter_conditions" or field_name == &"exit_conditions":
		if resource is _GF_NODE_STATE_CONDITION_BASE:
			return true
	return resource.has_method(required_method)


static func _get_resource_id(resource: Resource, field_name: StringName) -> StringName:
	if field_name == &"behaviors":
		var behavior_id := _get_string_name_property(resource, &"behavior_id", &"")
		if behavior_id != &"":
			return behavior_id

	var condition_id := _get_string_name_property(resource, &"condition_id", &"")
	if condition_id != &"":
		return condition_id
	var resource_id := _get_string_name_property(resource, &"resource_id", &"")
	if resource_id != &"":
		return resource_id
	return &""


static func _collect_direct_states(parent: Node) -> Array[GFNodeState]:
	var result: Array[GFNodeState] = []
	for child: Node in parent.get_children():
		if child is _GF_NODE_STATE_BASE:
			result.append(child as GFNodeState)
	return result


static func _get_machine_initial_state(machine: GFNodeStateMachine) -> StringName:
	var config := machine.get("config") as Resource
	if config != null:
		return _get_string_name_property(config, &"initial_state", &"")
	return _get_string_name_property(machine, &"initial_state", &"")


static func _should_require_machine_initial_state(machine: GFNodeStateMachine, options: Dictionary) -> bool:
	if options.has("require_initial_state"):
		return bool(options["require_initial_state"])
	var start_mode := int(machine.get("start_mode"))
	return start_mode != _GF_NODE_STATE_MACHINE_BASE.StartMode.MANUAL


static func _should_require_group_initial_state(group: GFNodeStateGroup, options: Dictionary) -> bool:
	if options.has("require_initial_state"):
		return bool(options["require_initial_state"])
	return _get_bool_property(group, &"auto_start", true)


static func _get_group_name(group: Node) -> StringName:
	return _get_string_name_property(group, &"group_name", StringName(group.name))


static func _get_group_initial_state(group: Node) -> StringName:
	return _get_string_name_property(group, &"initial_state", &"")


static func _get_state_name(state: Node) -> StringName:
	return _get_string_name_property(state, &"state_name", StringName(state.name))


static func _get_string_name_property(object: Object, property_name: StringName, fallback: StringName = &"") -> StringName:
	if object == null:
		return fallback

	var value: Variant = object.get(property_name)
	if value is StringName:
		var string_name := value as StringName
		return fallback if string_name == &"" else string_name
	if value is String:
		var text := String(value).strip_edges()
		return fallback if text.is_empty() else StringName(text)
	return fallback


static func _get_bool_property(object: Object, property_name: StringName, fallback: bool = false) -> bool:
	if object == null:
		return fallback

	var value: Variant = object.get(property_name)
	return bool(value) if value is bool else fallback


static func _get_resource_array_property(object: Object, property_name: StringName) -> Array[Resource]:
	var result: Array[Resource] = []
	if object == null:
		return result

	var value: Variant = object.get(property_name)
	if not value is Array:
		return result

	for entry: Variant in value as Array:
		result.append(entry as Resource)
	return result


static func _get_node_path_text(node: Node) -> String:
	if node == null:
		return ""
	if node.is_inside_tree():
		return String(node.get_path())
	return String(node.name)
