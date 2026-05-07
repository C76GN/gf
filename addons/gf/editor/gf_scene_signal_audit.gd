@tool

## GFSceneSignalAudit: 开发期场景信号连接审计工具。
##
## 扫描 PackedScene 中由编辑器保存的信号连接，报告缺失节点、缺失信号、
## 缺失方法和可选的参数数量不匹配。该工具只返回结构化报告，不修改场景，
## 也不参与运行时 GFArchitecture 生命周期。
class_name GFSceneSignalAudit
extends RefCounted


# --- 枚举 ---

enum IssueType {
	SCENE_LOAD_FAILED,
	SCENE_STATE_UNAVAILABLE,
	SCENE_INSTANTIATION_FAILED,
	MISSING_SOURCE,
	MISSING_TARGET,
	MISSING_SIGNAL,
	MISSING_METHOD,
	PARAMETER_COUNT_MISMATCH,
}


# --- 公共方法 ---

## 审计指定目录下的场景文件。
## @param root_path: 需要扫描的目录，通常为 `res://`。
## @param options: 审计选项，支持 `include_hidden`、`respect_gdignore` 与 `check_parameter_count`。
static func audit_directory(root_path: String = "res://", options: Dictionary = {}) -> Dictionary:
	var scene_paths := collect_scene_paths(root_path, options)
	var report := audit_scene_paths(scene_paths, options)
	report["root_path"] = root_path
	return report


## 审计一组场景路径并返回汇总报告。
## @param scene_paths: 需要审计的 PackedScene 路径列表。
## @param options: 审计选项，支持 `check_parameter_count`。
static func audit_scene_paths(scene_paths: PackedStringArray, options: Dictionary = {}) -> Dictionary:
	var issues: Array[Dictionary] = []
	var scanned_paths := PackedStringArray()
	for scene_path: String in scene_paths:
		scanned_paths.append(scene_path)
		issues.append_array(audit_scene(scene_path, options))

	return {
		"ok": issues.is_empty(),
		"scene_count": scanned_paths.size(),
		"issue_count": issues.size(),
		"scanned_paths": scanned_paths,
		"issues": issues,
	}


## 审计单个 PackedScene 的编辑器信号连接。
## @param scene_path: 需要审计的 PackedScene 路径。
## @param options: 审计选项，支持 `check_parameter_count`。
static func audit_scene(scene_path: String, options: Dictionary = {}) -> Array[Dictionary]:
	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		return [_make_scene_issue(
			IssueType.SCENE_LOAD_FAILED,
			scene_path,
			"无法加载场景资源。"
		)]

	var state := packed_scene.get_state()
	if state == null:
		return [_make_scene_issue(
			IssueType.SCENE_STATE_UNAVAILABLE,
			scene_path,
			"无法读取场景状态。"
		)]

	if state.get_connection_count() == 0:
		return []

	var root := packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED) as Node
	if root == null:
		return [_make_scene_issue(
			IssueType.SCENE_INSTANTIATION_FAILED,
			scene_path,
			"无法实例化场景用于检查连接目标。"
		)]

	var issues: Array[Dictionary] = []
	var check_parameter_count := bool(options.get("check_parameter_count", true))
	for connection_index: int in range(state.get_connection_count()):
		var source_path := state.get_connection_source(connection_index)
		var target_path := state.get_connection_target(connection_index)
		var signal_name := state.get_connection_signal(connection_index)
		var method_name := state.get_connection_method(connection_index)
		var source_node := _get_node_or_root(root, source_path)
		var target_node := _get_node_or_root(root, target_path)

		if source_node == null:
			issues.append(_make_connection_issue(
				IssueType.MISSING_SOURCE,
				scene_path,
				connection_index,
				source_path,
				target_path,
				signal_name,
				method_name,
				"连接源节点不存在。"
			))
			continue

		if target_node == null:
			issues.append(_make_connection_issue(
				IssueType.MISSING_TARGET,
				scene_path,
				connection_index,
				source_path,
				target_path,
				signal_name,
				method_name,
				"连接目标节点不存在。"
			))
			continue

		if not source_node.has_signal(signal_name):
			issues.append(_make_connection_issue(
				IssueType.MISSING_SIGNAL,
				scene_path,
				connection_index,
				source_path,
				target_path,
				signal_name,
				method_name,
				"连接源节点没有该信号。"
			))
			continue

		if not target_node.has_method(method_name):
			issues.append(_make_connection_issue(
				IssueType.MISSING_METHOD,
				scene_path,
				connection_index,
				source_path,
				target_path,
				signal_name,
				method_name,
				"连接目标节点没有该方法。"
			))
			continue

		if check_parameter_count:
			var mismatch_issue := _build_parameter_count_issue(
				scene_path,
				connection_index,
				state,
				source_node,
				target_node
			)
			if not mismatch_issue.is_empty():
				issues.append(mismatch_issue)

	root.free()
	return issues


## 收集目录下可审计的 `.tscn` 场景路径。
## @param root_path: 需要扫描的目录。
## @param options: 收集选项，支持 `include_hidden` 与 `respect_gdignore`。
static func collect_scene_paths(root_path: String = "res://", options: Dictionary = {}) -> PackedStringArray:
	var result := PackedStringArray()
	var include_hidden := bool(options.get("include_hidden", false))
	var respect_gdignore := bool(options.get("respect_gdignore", true))
	_collect_scene_paths_recursive(root_path, result, include_hidden, respect_gdignore)
	result.sort()
	return result


# --- 私有/辅助方法 ---

static func _collect_scene_paths_recursive(
	root_path: String,
	result: PackedStringArray,
	include_hidden: bool,
	respect_gdignore: bool
) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.include_hidden = include_hidden
	dir.include_navigational = false
	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var child_path := root_path.path_join(entry)
		if dir.current_is_dir():
			if _should_scan_directory(child_path, entry, include_hidden, respect_gdignore):
				_collect_scene_paths_recursive(child_path, result, include_hidden, respect_gdignore)
		elif entry.ends_with(".tscn"):
			result.append(child_path)
		entry = dir.get_next()
	dir.list_dir_end()


static func _should_scan_directory(
	path: String,
	dir_name: String,
	include_hidden: bool,
	respect_gdignore: bool
) -> bool:
	if not include_hidden and dir_name.begins_with("."):
		return false
	if respect_gdignore and FileAccess.file_exists(path.path_join(".gdignore")):
		return false
	return true


static func _get_node_or_root(root: Node, path: NodePath) -> Node:
	if path.is_empty() or String(path) == ".":
		return root
	return root.get_node_or_null(path)


static func _build_parameter_count_issue(
	scene_path: String,
	connection_index: int,
	state: SceneState,
	source_node: Node,
	target_node: Node
) -> Dictionary:
	var source_path := state.get_connection_source(connection_index)
	var target_path := state.get_connection_target(connection_index)
	var signal_name := state.get_connection_signal(connection_index)
	var method_name := state.get_connection_method(connection_index)
	var signal_arg_count := _get_signal_argument_count(source_node, signal_name)
	if signal_arg_count < 0:
		return {}

	var method_info := _get_method_info(target_node, method_name)
	if method_info.is_empty():
		return {}

	var binds: Array = state.get_connection_binds(connection_index)
	var unbind_count := int(state.get_connection_unbinds(connection_index))
	var delivered_arg_count: int = maxi(signal_arg_count - unbind_count, 0) + binds.size()
	var method_args: Array = method_info.get("args", [])
	var method_defaults: Array = method_info.get("default_args", [])
	var required_arg_count: int = maxi(method_args.size() - method_defaults.size(), 0)
	var maximum_arg_count: int = method_args.size()
	var accepts_extra_args := (int(method_info.get("flags", 0)) & METHOD_FLAG_VARARG) != 0
	if delivered_arg_count >= required_arg_count and (accepts_extra_args or delivered_arg_count <= maximum_arg_count):
		return {}

	var issue := _make_connection_issue(
		IssueType.PARAMETER_COUNT_MISMATCH,
		scene_path,
		connection_index,
		source_path,
		target_path,
		signal_name,
		method_name,
		"连接传入参数数量与目标方法签名不匹配。"
	)
	issue["signal_arg_count"] = signal_arg_count
	issue["bind_arg_count"] = binds.size()
	issue["unbind_count"] = unbind_count
	issue["delivered_arg_count"] = delivered_arg_count
	issue["required_arg_count"] = required_arg_count
	issue["maximum_arg_count"] = maximum_arg_count
	return issue


static func _get_signal_argument_count(source_node: Node, signal_name: StringName) -> int:
	for signal_info: Dictionary in source_node.get_signal_list():
		if StringName(signal_info.get("name", "")) == signal_name:
			var args: Array = signal_info.get("args", [])
			return args.size()
	return -1


static func _get_method_info(target_node: Node, method_name: StringName) -> Dictionary:
	for method_info: Dictionary in target_node.get_method_list():
		if StringName(method_info.get("name", "")) == method_name:
			return method_info
	return {}


static func _make_scene_issue(issue_type: IssueType, scene_path: String, message: String) -> Dictionary:
	return {
		"type": issue_type,
		"type_name": _issue_type_name(issue_type),
		"scene_path": scene_path,
		"connection_index": -1,
		"message": message,
	}


static func _make_connection_issue(
	issue_type: IssueType,
	scene_path: String,
	connection_index: int,
	source_path: NodePath,
	target_path: NodePath,
	signal_name: StringName,
	method_name: StringName,
	message: String
) -> Dictionary:
	return {
		"type": issue_type,
		"type_name": _issue_type_name(issue_type),
		"scene_path": scene_path,
		"connection_index": connection_index,
		"source_node_path": String(source_path),
		"target_node_path": String(target_path),
		"signal_name": String(signal_name),
		"method_name": String(method_name),
		"message": message,
	}


static func _issue_type_name(issue_type: IssueType) -> String:
	match issue_type:
		IssueType.SCENE_LOAD_FAILED:
			return "scene_load_failed"
		IssueType.SCENE_STATE_UNAVAILABLE:
			return "scene_state_unavailable"
		IssueType.SCENE_INSTANTIATION_FAILED:
			return "scene_instantiation_failed"
		IssueType.MISSING_SOURCE:
			return "missing_source"
		IssueType.MISSING_TARGET:
			return "missing_target"
		IssueType.MISSING_SIGNAL:
			return "missing_signal"
		IssueType.MISSING_METHOD:
			return "missing_method"
		IssueType.PARAMETER_COUNT_MISMATCH:
			return "parameter_count_mismatch"
	return "unknown"
