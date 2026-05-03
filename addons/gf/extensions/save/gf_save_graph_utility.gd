## GFSaveGraphUtility: 通用节点存档图编排工具。
##
## 负责遍历 GFSaveScope/GFSaveSource，采集、应用和落盘存档图。具体数据结构
## 由 Source、Serializer 或项目继承类决定，Utility 本身不绑定业务字段。
class_name GFSaveGraphUtility
extends GFUtility


# --- 常量 ---

const FORMAT_ID: String = "gf_save_graph"
const FORMAT_VERSION: int = 1
const GFNodeSerializerRegistryBase = preload("res://addons/gf/extensions/save/gf_node_serializer_registry.gd")
const GFSaveEntityFactoryBase = preload("res://addons/gf/extensions/save/gf_save_entity_factory.gd")
const GFSaveIdentityBase = preload("res://addons/gf/extensions/save/gf_save_identity.gd")
const GFSavePipelineStepBase = preload("res://addons/gf/extensions/save/gf_save_pipeline_step.gd")
const GFSaveScopeBase = preload("res://addons/gf/extensions/save/gf_save_scope.gd")
const GFSaveSourceBase = preload("res://addons/gf/extensions/save/gf_save_source.gd")


# --- 公共变量 ---

## 节点序列化器注册表。
var serializer_registry: GFNodeSerializerRegistryBase = GFNodeSerializerRegistryBase.new()

## 存档图流程步骤。按数组顺序执行，适合压缩前校验、调试标记、版本适配等通用处理。
var pipeline_steps: Array[GFSavePipelineStepBase] = []


# --- 私有变量 ---

var _entity_factories: Dictionary = {}


# --- 公共方法 ---

## 注册实体工厂。
## @param factory: 实体工厂。
func register_entity_factory(factory: GFSaveEntityFactoryBase) -> void:
	if factory == null:
		return

	var type_key := factory.get_type_key()
	if type_key == &"":
		return
	_entity_factories[type_key] = factory


## 注销实体工厂。
## @param type_key: 实体类型键。
func unregister_entity_factory(type_key: StringName) -> void:
	_entity_factories.erase(type_key)


## 清空实体工厂。
func clear_entity_factories() -> void:
	_entity_factories.clear()


## 添加存档流程步骤。
## @param step: 流程步骤。
func add_pipeline_step(step: GFSavePipelineStepBase) -> void:
	if step == null or pipeline_steps.has(step):
		return
	pipeline_steps.append(step)


## 移除存档流程步骤。
## @param step: 流程步骤。
func remove_pipeline_step(step: GFSavePipelineStepBase) -> void:
	pipeline_steps.erase(step)


## 清空存档流程步骤。
func clear_pipeline_steps() -> void:
	pipeline_steps.clear()


## 检查 Scope 树的可保存结构。
## @param scope: 根 Scope。
## @param context: 调用上下文字典。
## @return 诊断报告。
func inspect_scope(scope: GFSaveScopeBase, context: Dictionary = {}) -> Dictionary:
	var report := {
		"ok": true,
		"scope_key": String(scope.get_scope_key()) if scope != null else "",
		"scope_count": 0,
		"source_count": 0,
		"enabled_scope_count": 0,
		"enabled_source_count": 0,
		"scopes": [],
		"sources": [],
		"issues": [],
	}
	if scope == null:
		_append_diagnostic_issue(report, "error", "null_scope", "", "", "Scope is null.")
		report["ok"] = false
		return report

	_inspect_scope_recursive(scope, context, report, String(scope.get_scope_key()))
	report["ok"] = _report_has_no_error_issues(report)
	return report


## 校验载荷是否能匹配当前 Scope 树。
## @param scope: 根 Scope。
## @param payload: 待校验载荷。
## @param strict: 为 true 时把缺失 Source/Scope 视为错误；否则视为警告。
## @return 诊断报告。
func validate_payload_for_scope(scope: GFSaveScopeBase, payload: Dictionary, strict: bool = false) -> Dictionary:
	var report := {
		"ok": true,
		"scope_key": String(scope.get_scope_key()) if scope != null else "",
		"checked_source_count": 0,
		"checked_scope_count": 0,
		"missing": [],
		"issues": [],
	}
	if scope == null:
		_append_diagnostic_issue(report, "error", "null_scope", "", "", "Scope is null.")
		report["ok"] = false
		return report
	if payload.is_empty():
		_append_diagnostic_issue(report, "error", "empty_payload", String(scope.get_scope_key()), _get_node_debug_path(scope), "Payload is empty.")
		report["ok"] = false
		return report

	if String(payload.get("format", "")) != FORMAT_ID:
		_append_diagnostic_issue(report, "error", "format_mismatch", String(scope.get_scope_key()), _get_node_debug_path(scope), "Payload format does not match GF save graph.")
	if int(payload.get("format_version", -1)) > FORMAT_VERSION:
		_append_diagnostic_issue(report, "warning", "future_format_version", String(scope.get_scope_key()), _get_node_debug_path(scope), "Payload format version is newer than this utility.")

	_validate_payload_scope_recursive(scope, payload, strict, report, String(scope.get_scope_key()))
	report["ok"] = _report_has_no_error_issues(report)
	return report


## 采集 Scope 存档图。
## @param scope: 根 Scope。
## @param context: 调用上下文字典。
## @return 存档载荷。
func gather_scope(scope: GFSaveScopeBase, context: Dictionary = {}) -> Dictionary:
	if scope == null or not scope.can_save_scope(context):
		return {}

	_run_before_gather_steps(scope, context)
	scope.before_save(context)
	var payload := {
		"format": FORMAT_ID,
		"format_version": FORMAT_VERSION,
		"scope": scope.describe_scope(),
		"sources": {},
		"scopes": {},
	}

	for source: GFSaveSourceBase in _get_sources_for_scope(scope):
		if not source.can_save_source(context):
			continue

		source.before_save(context)
		var source_key := _make_unique_key(_make_scoped_source_key(scope, source), payload["sources"] as Dictionary)
		var descriptor := source.describe_source(scope)
		_merge_identity_descriptor(source, descriptor)
		payload["sources"][source_key] = {
			"descriptor": descriptor,
			"data": source.gather_save_data(context, serializer_registry),
		}

	for child_scope: GFSaveScopeBase in _get_child_scopes(scope):
		var child_payload := gather_scope(child_scope, context)
		if child_payload.is_empty():
			continue
		var child_key := _make_unique_key(String(child_scope.get_scope_key()), payload["scopes"] as Dictionary)
		payload["scopes"][child_key] = child_payload

	scope.after_save(payload, context)
	return _run_after_gather_steps(scope, payload, context)


## 应用 Scope 存档图。
## @param scope: 根 Scope。
## @param payload: 存档载荷。
## @param context: 调用上下文字典。
## @param strict: 为 true 时缺失 Source/Scope 会记录错误。
## @return 结果字典。
func apply_scope(
	scope: GFSaveScopeBase,
	payload: Dictionary,
	context: Dictionary = {},
	strict: bool = false
) -> Dictionary:
	if scope == null:
		return _make_apply_result(false, 0, ["Scope is null."], [])
	if payload.is_empty() or not scope.can_load_scope(context):
		return _make_apply_result(true, 0, [], [])

	payload = _run_before_apply_steps(scope, payload, context)
	scope.before_load(payload, context)
	var applied := 0
	var errors: Array[String] = []
	var missing: Array[String] = []
	var source_index := _index_sources_by_key(scope)
	var source_payloads: Dictionary = payload.get("sources", {}) as Dictionary
	var source_keys := source_payloads.keys()
	source_keys.sort_custom(func(left: Variant, right: Variant) -> bool:
		return _source_payload_phase(source_payloads[left]) < _source_payload_phase(source_payloads[right])
	)

	for source_key_variant: Variant in source_keys:
		var source_key := String(source_key_variant)
		var source_payload := source_payloads[source_key_variant] as Dictionary
		var source := source_index.get(source_key) as GFSaveSourceBase
		if source == null:
			source = _try_create_source_from_payload(scope, source_payload, context)
			if source != null:
				source_index[source_key] = source

		if source == null:
			missing.append(source_key)
			if strict:
				errors.append("Missing source: %s" % source_key)
			continue
		if not source.can_load_source(context):
			continue

		var result := source.apply_save_data(source_payload.get("data"), context, serializer_registry)
		if bool(result.get("ok", false)):
			applied += 1
			source.after_load(source_payload.get("data"), context)
		else:
			errors.append("%s: %s" % [source_key, String(result.get("error", "Apply failed"))])

	var child_scope_index := _index_child_scopes(scope)
	var child_payloads: Dictionary = payload.get("scopes", {}) as Dictionary
	for child_key_variant: Variant in child_payloads.keys():
		var child_key := String(child_key_variant)
		var child_scope := child_scope_index.get(child_key) as GFSaveScopeBase
		if child_scope == null:
			missing.append(child_key)
			if strict:
				errors.append("Missing scope: %s" % child_key)
			continue

		var child_result := apply_scope(child_scope, child_payloads[child_key_variant] as Dictionary, context, strict)
		applied += int(child_result.get("applied", 0))
		var child_errors := child_result.get("errors", []) as Array
		for error: String in child_errors:
			errors.append(error)
		var child_missing := child_result.get("missing", []) as Array
		for missing_key: String in child_missing:
			missing.append("%s/%s" % [child_key, missing_key])

	scope.after_load(payload, context)
	return _run_after_apply_steps(
		scope,
		payload,
		_make_apply_result(errors.is_empty(), applied, errors, missing),
		context
	)


## 采集并保存 Scope。
## @param file_name: 目标文件名。
## @param scope: 根 Scope。
## @param metadata: 附加元信息。
## @param context: 调用上下文字典。
## @return Godot Error。
func save_scope(
	file_name: String,
	scope: GFSaveScopeBase,
	metadata: Dictionary = {},
	context: Dictionary = {}
) -> Error:
	var storage := _get_storage_utility()
	if storage == null:
		return ERR_UNCONFIGURED

	var payload := gather_scope(scope, context)
	if payload.is_empty():
		return ERR_INVALID_DATA
	if not metadata.is_empty():
		payload["metadata"] = metadata.duplicate(true)
	return storage.save_data(file_name, payload)


## 从文件读取并应用 Scope。
## @param file_name: 目标文件名。
## @param scope: 根 Scope。
## @param context: 调用上下文字典。
## @param strict: 为 true 时缺失 Source/Scope 会记录错误。
## @return 结果字典。
func load_scope(
	file_name: String,
	scope: GFSaveScopeBase,
	context: Dictionary = {},
	strict: bool = false
) -> Dictionary:
	var storage := _get_storage_utility()
	if storage == null:
		return _make_apply_result(false, 0, ["GFStorageUtility is not registered."], [])

	var payload := storage.load_data(file_name)
	if payload.is_empty():
		return _make_apply_result(false, 0, ["Save payload is empty."], [])
	return apply_scope(scope, payload, context, strict)


# --- 私有/辅助方法 ---

func _get_sources_for_scope(scope: GFSaveScopeBase) -> Array[GFSaveSourceBase]:
	var result: Array[GFSaveSourceBase] = []
	_collect_sources(scope, scope, result)
	result.sort_custom(func(left: GFSaveSourceBase, right: GFSaveSourceBase) -> bool:
		if left.phase != right.phase:
			return left.phase < right.phase
		return String(left.get_source_key()) < String(right.get_source_key())
	)
	return result


func _inspect_scope_recursive(
	scope: GFSaveScopeBase,
	context: Dictionary,
	report: Dictionary,
	scope_path: String
) -> void:
	report["scope_count"] = int(report.get("scope_count", 0)) + 1
	if scope.can_save_scope(context):
		report["enabled_scope_count"] = int(report.get("enabled_scope_count", 0)) + 1

	var scope_key := String(scope.get_scope_key())
	(report["scopes"] as Array).append({
		"key": scope_key,
		"path": _get_node_debug_path(scope),
		"can_save": scope.can_save_scope(context),
		"can_load": scope.can_load_scope(context),
		"phase": scope.phase,
	})

	var source_key_counts: Dictionary = {}
	for source: GFSaveSourceBase in _get_sources_for_scope(scope):
		report["source_count"] = int(report.get("source_count", 0)) + 1
		if source.can_save_source(context):
			report["enabled_source_count"] = int(report.get("enabled_source_count", 0)) + 1

		var source_key := _make_scoped_source_key(scope, source)
		source_key_counts[source_key] = int(source_key_counts.get(source_key, 0)) + 1
		var target := source.get_target_node()
		var serializer_ids := _get_source_serializer_ids(source, target)
		(report["sources"] as Array).append({
			"key": source_key,
			"path": _get_node_debug_path(source),
			"target_path": _get_node_debug_path(target),
			"can_save": source.can_save_source(context),
			"can_load": source.can_load_source(context),
			"phase": source.phase,
			"serializer_ids": serializer_ids,
		})

		if source_key.is_empty():
			_append_diagnostic_issue(report, "error", "empty_source_key", scope_path, _get_node_debug_path(source), "Save source key is empty.")
		if source.can_save_source(context) and not source.target_node_path.is_empty() and target == null:
			_append_diagnostic_issue(report, "warning", "missing_target", source_key, _get_node_debug_path(source), "Save source target node is missing.")
		if (
			source.can_save_source(context)
			and target != null
			and (source.use_registry_serializers or not source.serializers.is_empty())
			and serializer_ids.is_empty()
		):
			_append_diagnostic_issue(report, "warning", "no_matching_serializer", source_key, _get_node_debug_path(source), "No configured serializer supports the target node.")

	for source_key_variant: Variant in source_key_counts.keys():
		var count := int(source_key_counts[source_key_variant])
		if count > 1:
			_append_diagnostic_issue(report, "error", "duplicate_source_key", String(source_key_variant), _get_node_debug_path(scope), "Duplicate save source key in the same scope.")

	var child_scope_key_counts: Dictionary = {}
	for child_scope: GFSaveScopeBase in _get_child_scopes(scope):
		var child_key := String(child_scope.get_scope_key())
		child_scope_key_counts[child_key] = int(child_scope_key_counts.get(child_key, 0)) + 1
	for child_key_variant: Variant in child_scope_key_counts.keys():
		var count := int(child_scope_key_counts[child_key_variant])
		if count > 1:
			_append_diagnostic_issue(report, "error", "duplicate_scope_key", String(child_key_variant), _get_node_debug_path(scope), "Duplicate child scope key in the same scope.")

	for child_scope: GFSaveScopeBase in _get_child_scopes(scope):
		_inspect_scope_recursive(child_scope, context, report, "%s/%s" % [scope_path, String(child_scope.get_scope_key())])


func _validate_payload_scope_recursive(
	scope: GFSaveScopeBase,
	payload: Dictionary,
	strict: bool,
	report: Dictionary,
	scope_path: String
) -> void:
	report["checked_scope_count"] = int(report.get("checked_scope_count", 0)) + 1
	var severity := "error" if strict else "warning"
	var source_index := _index_sources_by_key(scope)
	var source_payloads: Dictionary = payload.get("sources", {}) as Dictionary
	if source_payloads == null:
		_append_diagnostic_issue(report, "error", "invalid_sources_payload", scope_path, _get_node_debug_path(scope), "Payload sources must be a Dictionary.")
		source_payloads = {}
	for source_key_variant: Variant in source_payloads.keys():
		report["checked_source_count"] = int(report.get("checked_source_count", 0)) + 1
		var source_key := String(source_key_variant)
		if not source_index.has(source_key):
			(report["missing"] as Array).append("%s:%s" % [scope_path, source_key])
			_append_diagnostic_issue(report, severity, "missing_source", source_key, _get_node_debug_path(scope), "Payload source does not exist in the current scope.")

	var child_scope_index := _index_child_scopes(scope)
	var child_payloads: Dictionary = payload.get("scopes", {}) as Dictionary
	if child_payloads == null:
		_append_diagnostic_issue(report, "error", "invalid_scopes_payload", scope_path, _get_node_debug_path(scope), "Payload scopes must be a Dictionary.")
		child_payloads = {}
	for child_key_variant: Variant in child_payloads.keys():
		var child_key := String(child_key_variant)
		var child_scope := child_scope_index.get(child_key) as GFSaveScopeBase
		if child_scope == null:
			(report["missing"] as Array).append("%s/%s" % [scope_path, child_key])
			_append_diagnostic_issue(report, severity, "missing_scope", child_key, _get_node_debug_path(scope), "Payload child scope does not exist in the current scope.")
			continue

		var child_payload := child_payloads[child_key_variant] as Dictionary
		if child_payload == null:
			_append_diagnostic_issue(report, "error", "invalid_child_payload", child_key, _get_node_debug_path(child_scope), "Child scope payload must be a Dictionary.")
			continue
		_validate_payload_scope_recursive(child_scope, child_payload, strict, report, "%s/%s" % [scope_path, child_key])


func _collect_sources(root_scope: GFSaveScopeBase, current: Node, result: Array[GFSaveSourceBase]) -> void:
	for child: Node in current.get_children():
		if child is GFSaveScopeBase:
			continue
		if child is GFSaveSourceBase:
			result.append(child as GFSaveSourceBase)
		_collect_sources(root_scope, child, result)


func _get_child_scopes(scope: GFSaveScopeBase) -> Array[GFSaveScopeBase]:
	var result: Array[GFSaveScopeBase] = []
	for child: Node in scope.get_children():
		if child is GFSaveScopeBase:
			result.append(child as GFSaveScopeBase)
	return result


func _index_sources_by_key(scope: GFSaveScopeBase) -> Dictionary:
	var result: Dictionary = {}
	for source: GFSaveSourceBase in _get_sources_for_scope(scope):
		result[_make_scoped_source_key(scope, source)] = source
	return result


func _index_child_scopes(scope: GFSaveScopeBase) -> Dictionary:
	var result: Dictionary = {}
	for child_scope: GFSaveScopeBase in _get_child_scopes(scope):
		result[String(child_scope.get_scope_key())] = child_scope
	return result


func _make_scoped_source_key(scope: GFSaveScopeBase, source: GFSaveSourceBase) -> String:
	var prefix := scope.get_key_prefix()
	var key := String(source.get_source_key())
	if prefix.is_empty():
		return key
	return "%s/%s" % [prefix, key]


func _make_unique_key(base_key: String, existing: Dictionary) -> String:
	if not existing.has(base_key):
		return base_key

	var index := 2
	var candidate := "%s#%d" % [base_key, index]
	while existing.has(candidate):
		index += 1
		candidate = "%s#%d" % [base_key, index]
	return candidate


func _merge_identity_descriptor(source: GFSaveSourceBase, descriptor: Dictionary) -> void:
	var identity := _find_identity(source)
	if identity == null:
		return

	var identity_descriptor := identity.describe_identity()
	for key: Variant in identity_descriptor.keys():
		descriptor[key] = identity_descriptor[key]


func _find_identity(source: GFSaveSourceBase) -> GFSaveIdentityBase:
	for child: Node in source.get_children():
		if child is GFSaveIdentityBase:
			return child as GFSaveIdentityBase

	var target := source.get_target_node()
	if target == null:
		return null
	for child: Node in target.get_children():
		if child is GFSaveIdentityBase:
			return child as GFSaveIdentityBase
	return null


func _try_create_source_from_payload(
	scope: GFSaveScopeBase,
	source_payload: Dictionary,
	context: Dictionary
) -> GFSaveSourceBase:
	if scope.restore_policy != GFSaveScopeBase.RestorePolicy.ALLOW_FACTORIES:
		return null

	var descriptor: Dictionary = source_payload.get("descriptor", {}) as Dictionary
	var type_key := StringName(descriptor.get("type_key", &""))
	var factory := _entity_factories.get(type_key) as GFSaveEntityFactoryBase
	if factory == null:
		return null

	var entity := factory.create_entity(descriptor, context)
	if entity == null:
		return null
	scope.add_child(entity)
	factory.after_entity_created(entity, descriptor, context)
	if entity is GFSaveSourceBase:
		return entity as GFSaveSourceBase
	return _find_first_source(entity)


func _find_first_source(root: Node) -> GFSaveSourceBase:
	for child: Node in root.get_children():
		if child is GFSaveSourceBase:
			return child as GFSaveSourceBase
		var nested := _find_first_source(child)
		if nested != null:
			return nested
	return null


func _source_payload_phase(source_payload_variant: Variant) -> int:
	if not (source_payload_variant is Dictionary):
		return 0

	var source_payload := source_payload_variant as Dictionary
	var descriptor: Dictionary = source_payload.get("descriptor", {}) as Dictionary
	return int(descriptor.get("phase", GFSaveScopeBase.Phase.NORMAL))


func _make_apply_result(ok: bool, applied: int, errors: Array[String], missing: Array[String]) -> Dictionary:
	return {
		"ok": ok,
		"applied": applied,
		"errors": errors,
		"missing": missing,
	}


func _run_before_gather_steps(scope: GFSaveScopeBase, context: Dictionary) -> void:
	for step: GFSavePipelineStepBase in pipeline_steps:
		if step != null and step.enabled:
			step.before_gather_scope(scope, context)


func _run_after_gather_steps(
	scope: GFSaveScopeBase,
	payload: Dictionary,
	context: Dictionary
) -> Dictionary:
	var result := payload
	for step: GFSavePipelineStepBase in pipeline_steps:
		if step == null or not step.enabled:
			continue
		var next_payload: Variant = step.after_gather_scope(scope, result, context)
		if next_payload is Dictionary:
			result = next_payload as Dictionary
	return result


func _run_before_apply_steps(
	scope: GFSaveScopeBase,
	payload: Dictionary,
	context: Dictionary
) -> Dictionary:
	var result := payload
	for step: GFSavePipelineStepBase in pipeline_steps:
		if step == null or not step.enabled:
			continue
		var next_payload: Variant = step.before_apply_scope(scope, result, context)
		if next_payload is Dictionary:
			result = next_payload as Dictionary
	return result


func _run_after_apply_steps(
	scope: GFSaveScopeBase,
	payload: Dictionary,
	result: Dictionary,
	context: Dictionary
) -> Dictionary:
	var final_result := result
	for step: GFSavePipelineStepBase in pipeline_steps:
		if step == null or not step.enabled:
			continue
		var next_result: Variant = step.after_apply_scope(scope, payload, final_result, context)
		if next_result is Dictionary:
			final_result = next_result as Dictionary
	return final_result


func _get_storage_utility() -> GFStorageUtility:
	return get_utility(GFStorageUtility) as GFStorageUtility


func _get_source_serializer_ids(source: GFSaveSourceBase, target: Node) -> PackedStringArray:
	var result := PackedStringArray()
	if target == null:
		return result

	if not source.serializers.is_empty():
		for serializer: GFNodeSerializer in source.serializers:
			if serializer != null and serializer.supports_node(target):
				result.append(String(serializer.get_serializer_id()))
		return result

	if source.use_registry_serializers and serializer_registry != null:
		for serializer: GFNodeSerializer in serializer_registry.get_serializers_for_node(target):
			if serializer != null:
				result.append(String(serializer.get_serializer_id()))
	return result


func _append_diagnostic_issue(
	report: Dictionary,
	severity: String,
	kind: String,
	key: String,
	path: String,
	message: String
) -> void:
	(report["issues"] as Array).append({
		"severity": severity,
		"kind": kind,
		"key": key,
		"path": path,
		"message": message,
	})


func _report_has_no_error_issues(report: Dictionary) -> bool:
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue != null and String(issue.get("severity", "")) == "error":
			return false
	return true


func _get_node_debug_path(node: Node) -> String:
	if node == null:
		return ""
	if node.is_inside_tree():
		return String(node.get_path())
	return node.name
