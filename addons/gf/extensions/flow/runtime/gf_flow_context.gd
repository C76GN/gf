## GFFlowContext: 通用流程图执行上下文。
##
## 用于在流程节点之间共享数据，并提供可选的 GFArchitecture 访问入口。
class_name GFFlowContext
extends RefCounted


# --- 公共变量 ---

## 共享数据表。
var values: Dictionary = {}

## 下一个节点覆盖。流程节点可写入该列表动态控制分支。
var next_node_ids: PackedStringArray = PackedStringArray()

## 是否显式覆盖了下一个节点。允许节点用空列表表达“停止继续推进”。
var has_next_node_override: bool = false


# --- 私有变量 ---

var _architecture_ref: WeakRef = null
var _condition_handlers: Dictionary = {}
var _node_runtime_states: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(architecture: GFArchitecture = null, p_values: Dictionary = {}) -> void:
	values = p_values.duplicate(true)
	set_architecture(architecture)


# --- 公共方法 ---

## 设置上下文所属架构。
## @param architecture: 架构实例。
func set_architecture(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null


## 获取上下文所属架构。
## @return 架构实例；不可用时返回 null。
func get_architecture() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	return GFAutoload.get_architecture_or_null()


## 写入共享值。
## @param key: 键。
## @param value: 值。
## @return 当前上下文，便于链式构造。
func set_value(key: StringName, value: Variant) -> GFFlowContext:
	values[key] = value
	return self


## 读取共享值。
## @param key: 键。
## @param default_value: 默认值。
## @return 共享值或默认值。
func get_value(key: StringName, default_value: Variant = null) -> Variant:
	return values.get(key, default_value)


## 覆盖当前节点执行后的下一个节点列表。
## @param node_ids: 节点标识列表。
func set_next_nodes(node_ids: PackedStringArray) -> void:
	next_node_ids = node_ids.duplicate()
	has_next_node_override = true


## 检查当前节点是否显式覆盖了后继节点。
## @return 已覆盖返回 true。
func has_next_nodes_override() -> bool:
	return has_next_node_override


## 清空下一个节点覆盖。
func clear_next_nodes() -> void:
	next_node_ids.clear()
	has_next_node_override = false


## 注册条件查询处理器。
## @param condition_id: 条件标识。
## @param handler: 查询回调，建议签名为 func(condition_id: StringName, payload: Variant, context: GFFlowContext) -> Variant。
## @return 注册成功返回 true。
func register_condition_handler(condition_id: StringName, handler: Callable) -> bool:
	if condition_id == &"" or not handler.is_valid():
		return false
	_condition_handlers[condition_id] = handler
	return true


## 注销条件查询处理器。
## @param condition_id: 条件标识。
func unregister_condition_handler(condition_id: StringName) -> void:
	_condition_handlers.erase(condition_id)


## 检查条件查询处理器是否存在。
## @param condition_id: 条件标识。
## @return 存在返回 true。
func has_condition_handler(condition_id: StringName) -> bool:
	return _condition_handlers.has(condition_id)


## 清空所有条件查询处理器。
func clear_condition_handlers() -> void:
	_condition_handlers.clear()


## 查询条件值。
## @param condition_id: 条件标识。
## @param payload: 调用方传入的载荷。
## @param default_value: 缺失处理器或处理器未返回值时使用的默认值。
## @return 统一条件查询结果。
func query_condition(
	condition_id: StringName,
	payload: Variant = null,
	default_value: Variant = false
) -> Dictionary:
	if condition_id == &"":
		return _make_condition_result(false, condition_id, default_value, "condition_id_is_empty")
	if not _condition_handlers.has(condition_id):
		return _make_condition_result(false, condition_id, default_value, "missing_condition_handler")

	var handler: Callable = _condition_handlers.get(condition_id, Callable())
	if not handler.is_valid():
		return _make_condition_result(false, condition_id, default_value, "invalid_condition_handler")

	var raw_result: Variant = handler.call(condition_id, payload, self)
	return _normalize_condition_result(condition_id, raw_result, default_value)


## 写入指定流程节点的运行态值。
## @param node_id: 节点标识。
## @param key: 运行态键。
## @param value: 运行态值。
func set_node_runtime_value(node_id: StringName, key: StringName, value: Variant) -> void:
	if node_id == &"" or key == &"":
		return
	if not _node_runtime_states.has(node_id):
		_node_runtime_states[node_id] = {}
	var state := _node_runtime_states[node_id] as Dictionary
	state[key] = value


## 读取指定流程节点的运行态值。
## @param node_id: 节点标识。
## @param key: 运行态键。
## @param default_value: 缺失时返回的默认值。
## @return 运行态值或默认值。
func get_node_runtime_value(node_id: StringName, key: StringName, default_value: Variant = null) -> Variant:
	var state := _node_runtime_states.get(node_id, {}) as Dictionary
	if state == null:
		return default_value
	return state.get(key, default_value)


## 清空节点运行态。node_id 为空时清空全部节点运行态。
## @param node_id: 节点标识。
func clear_node_runtime_state(node_id: StringName = &"") -> void:
	if node_id == &"":
		_node_runtime_states.clear()
		return
	_node_runtime_states.erase(node_id)


## 序列化上下文持有的节点运行态。
## @return 运行态快照。
func serialize_runtime_state() -> Dictionary:
	return {
		"nodes": _node_runtime_states.duplicate(true),
	}


## 反序列化节点运行态到当前上下文。
## @param data: 运行态快照。
func deserialize_runtime_state(data: Dictionary) -> void:
	_node_runtime_states.clear()
	var node_states := data.get("nodes", {}) as Dictionary
	if node_states == null:
		return
	for node_id_variant: Variant in node_states.keys():
		var state := node_states[node_id_variant] as Dictionary
		if state != null:
			_node_runtime_states[StringName(node_id_variant)] = state.duplicate(true)


# --- 私有/辅助方法 ---

func _normalize_condition_result(condition_id: StringName, raw_result: Variant, default_value: Variant) -> Dictionary:
	if raw_result is Dictionary:
		var data := raw_result as Dictionary
		return {
			"ok": bool(data.get("ok", true)),
			"condition_id": condition_id,
			"value": data.get("value", default_value),
			"reason": String(data.get("reason", data.get("error", ""))),
			"metadata": (data.get("metadata", {}) as Dictionary).duplicate(true) if data.get("metadata", {}) is Dictionary else {},
		}
	return _make_condition_result(true, condition_id, raw_result, "")


func _make_condition_result(ok: bool, condition_id: StringName, value: Variant, reason: String) -> Dictionary:
	return {
		"ok": ok,
		"condition_id": condition_id,
		"value": value,
		"reason": reason,
		"metadata": {},
	}
