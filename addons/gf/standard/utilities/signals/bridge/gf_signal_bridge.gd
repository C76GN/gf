## GFSignalBridge: 声明式信号到 Callable 的桥接资源。
##
## 桥接只描述信号来源、目标方法、参数重排和常量参数。它不修改场景结构、
## 不解释信号业务含义，也不要求调用方使用特定 UI 或状态机。
class_name GFSignalBridge
extends Resource


# --- 常量 ---

const GFValidationReportDictionaryBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd")


# --- 导出变量 ---

## 桥接 ID，便于调试和项目侧索引。
@export var bridge_id: StringName = &""

## 是否启用该桥接。
@export var enabled: bool = true

## 信号来源引用。
@export var source: GFSignalSourceRef = GFSignalSourceRef.new()

## 调用目标引用。
@export var target: GFCallableTargetRef = GFCallableTargetRef.new()

## 要从原始信号参数中抽取的索引。为空时透传全部信号参数。
@export var argument_indices: PackedInt32Array = PackedInt32Array()

## 追加到桥接参数末尾的常量参数。
@export var constant_args: Array = []

## 是否把桥接上下文字典追加到参数末尾。
@export var append_context: bool = false

## 是否只触发一次。
@export var one_shot: bool = false

## Godot 信号连接标记。
@export var connect_flags: int = 0

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 连接桥接。
## @param root: 路径解析根节点。
## @param owner: 可选连接拥有者。
## @param signal_utility: 可选 GFSignalUtility；为空时创建独立连接。
## @return 运行中的桥接绑定；失败时返回 null。
func connect_bridge(
	root: Node,
	owner: Object = null,
	signal_utility: GFSignalUtility = null
) -> GFSignalBridgeBinding:
	if not enabled:
		return null
	if source == null or target == null:
		return null

	var source_signal := source.get_signal(root)
	if source_signal.is_null() or not target.is_valid_for(root):
		return null

	var binding := GFSignalBridgeBinding.new()
	var callback := Callable(binding, "_invoke_from_signal")
	var connection: GFSignalConnection = null
	if signal_utility != null:
		connection = signal_utility.connect_signal(source_signal, callback, owner, [], connect_flags)
	else:
		connection = GFSignalConnection.new(source_signal, callback, owner, [], connect_flags)
		connection.start()

	if connection == null or not connection.is_active():
		return null
	if one_shot:
		connection.once()

	binding.setup(self, root, connection)
	return binding


## 直接执行桥接调用。
## @param root: 路径解析根节点。
## @param signal_args: 原始信号参数。
## @return 结构化调用结果。
func invoke(root: Node, signal_args: Array = []) -> Dictionary:
	if not enabled:
		return _make_result(false, &"disabled", null)
	if target == null:
		return _make_result(false, &"missing_target", null)

	var args := build_callable_args(signal_args)
	var call_result := target.call_with_args(root, args)
	return {
		"ok": bool(call_result.get("ok", false)),
		"reason": call_result.get("reason", &"ok"),
		"value": call_result.get("value"),
		"bridge_id": bridge_id,
		"args": args,
	}


## 构建目标 Callable 参数。
## @param signal_args: 原始信号参数。
## @return 映射后的参数。
func build_callable_args(signal_args: Array = []) -> Array:
	var args: Array = []
	if argument_indices.is_empty():
		args.append_array(signal_args)
	else:
		for index: int in argument_indices:
			args.append(signal_args[index] if index >= 0 and index < signal_args.size() else null)
	args.append_array(constant_args)
	if append_context:
		args.append(_make_context(signal_args))
	return args


## 获取校验报告。
## @param root: 路径解析根节点。
## @return 兼容 GFValidationReportDictionary 的报告字典。
func get_validation_report(root: Node) -> Dictionary:
	var report := {
		"subject": "Signal bridge",
		"bridge_id": bridge_id,
		"issues": [],
	}
	var source_is_valid := false
	if source == null:
		_append_validation_issue(report, &"missing_source", "source", "Signal bridge source is missing.")
	elif not source.is_valid_for(root):
		_append_validation_issue(report, &"invalid_source_signal", "source", "Signal bridge source signal is invalid.")
	else:
		source_is_valid = true

	var target_is_valid := false
	if target == null:
		_append_validation_issue(report, &"missing_target", "target", "Signal bridge target is missing.")
	elif not target.is_valid_for(root):
		_append_validation_issue(report, &"invalid_callable_target", "target", "Signal bridge target callable is invalid.")
	else:
		target_is_valid = true

	var signal_argument_count := source.get_signal_argument_count(root) if source_is_valid else -1
	_validate_argument_indices(report, signal_argument_count)
	if target_is_valid:
		_validate_callable_argument_count(report, root, signal_argument_count)

	return GFValidationReportDictionaryBase.finalize_report(report, "Signal bridge", {
		"include_issue_count": true,
		"next_actions": _get_validation_next_actions(),
	})


## 转换为调试字典。
## @return 桥接快照。
func to_dictionary() -> Dictionary:
	return {
		"bridge_id": bridge_id,
		"enabled": enabled,
		"source": source.to_dictionary() if source != null else {},
		"target": target.to_dictionary() if target != null else {},
		"argument_indices": argument_indices,
		"constant_args": constant_args.duplicate(true),
		"append_context": append_context,
		"one_shot": one_shot,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _make_context(signal_args: Array) -> Dictionary:
	return {
		"bridge_id": bridge_id,
		"source_path": source.source_path if source != null else NodePath(""),
		"signal_name": source.signal_name if source != null else &"",
		"signal_args": signal_args.duplicate(true),
		"metadata": metadata.duplicate(true),
	}


func _make_result(ok: bool, reason: StringName, value: Variant) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"value": value,
		"bridge_id": bridge_id,
	}


func _validate_argument_indices(report: Dictionary, signal_argument_count: int) -> void:
	for argument_index: int in argument_indices:
		if argument_index < 0:
			_append_validation_issue(
				report,
				&"negative_argument_index",
				"argument_indices",
				"Signal bridge argument index cannot be negative.",
				{ "argument_index": argument_index }
			)
		elif signal_argument_count >= 0 and argument_index >= signal_argument_count:
			_append_validation_issue(
				report,
				&"argument_index_out_of_range",
				"argument_indices",
				"Signal bridge argument index %d is outside the source signal argument count %d." % [
					argument_index,
					signal_argument_count,
				],
				{
					"argument_index": argument_index,
					"signal_argument_count": signal_argument_count,
				}
			)


func _validate_callable_argument_count(report: Dictionary, root: Node, signal_argument_count: int) -> void:
	var provided_argument_count := _get_provided_callable_argument_count(signal_argument_count)
	if provided_argument_count < 0:
		return

	var target_object := target.resolve_target(root)
	if target_object == null:
		return

	for method_info: Dictionary in target_object.get_method_list():
		if StringName(method_info.get("name", &"")) != target.method_name:
			continue

		var method_args: Array = method_info.get("args", [])
		var default_args: Array = method_info.get("default_args", [])
		var required_argument_count := maxi(method_args.size() - default_args.size(), 0)
		var maximum_argument_count := method_args.size()
		var accepts_extra_args := (int(method_info.get("flags", 0)) & METHOD_FLAG_VARARG) != 0
		if provided_argument_count >= required_argument_count and (accepts_extra_args or provided_argument_count <= maximum_argument_count):
			return

		_append_validation_issue(
			report,
			&"callable_argument_mismatch",
			"target",
			"Signal bridge provides %d argument(s), but target method expects %d-%s." % [
				provided_argument_count,
				required_argument_count,
				"*" if accepts_extra_args else str(maximum_argument_count),
			],
			{
				"provided_argument_count": provided_argument_count,
				"required_argument_count": required_argument_count,
				"maximum_argument_count": maximum_argument_count,
				"accepts_extra_args": accepts_extra_args,
			}
		)
		return


func _get_provided_callable_argument_count(signal_argument_count: int) -> int:
	var count := 0
	if argument_indices.is_empty():
		if signal_argument_count < 0:
			return -1
		count = signal_argument_count
	else:
		count = argument_indices.size()
	count += constant_args.size()
	if append_context:
		count += 1
	if target != null:
		count += target.default_args.size()
	return count


func _append_validation_issue(
	report: Dictionary,
	kind: StringName,
	path: String,
	message: String,
	fields: Dictionary = {}
) -> void:
	var issue_fields := {
		"bridge_id": bridge_id,
		"path": path,
	}
	issue_fields.merge(fields, true)
	GFValidationReportDictionaryBase.append_issue(report, "error", kind, message, issue_fields)


func _get_validation_next_actions() -> Dictionary:
	return {
		"missing_source": "Assign a GFSignalSourceRef before connecting the bridge.",
		"invalid_source_signal": "Check the source path and signal name against the bridge root.",
		"missing_target": "Assign a GFCallableTargetRef before connecting the bridge.",
		"invalid_callable_target": "Check the target path and method name against the bridge root.",
		"negative_argument_index": "Remove negative values from argument_indices.",
		"argument_index_out_of_range": "Keep argument_indices within the source signal argument list.",
		"callable_argument_mismatch": "Adjust argument_indices, constant_args, append_context, or the target method signature.",
	}
