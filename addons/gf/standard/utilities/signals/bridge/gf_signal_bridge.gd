## GFSignalBridge: 声明式信号到 Callable 的桥接资源。
##
## 桥接只描述信号来源、目标方法、参数重排和常量参数。它不修改场景结构、
## 不解释信号业务含义，也不要求调用方使用特定 UI 或状态机。
class_name GFSignalBridge
extends Resource


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
## @return 包含 ok 与 issues 的报告。
func get_validation_report(root: Node) -> Dictionary:
	var issues: Array[String] = []
	if source == null:
		issues.append("missing_source")
	elif not source.is_valid_for(root):
		issues.append("invalid_source_signal")

	if target == null:
		issues.append("missing_target")
	elif not target.is_valid_for(root):
		issues.append("invalid_callable_target")

	if argument_indices.has(-1):
		issues.append("negative_argument_index")

	return {
		"ok": issues.is_empty(),
		"issues": issues,
		"bridge_id": bridge_id,
	}


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
