## GFDialogueContext: 通用对话运行上下文。
##
## 上下文保存运行时值，并把条件判断、mutation 和文本解析委托给项目提供的
## Callable。框架只负责规范调用与结果包装。
class_name GFDialogueContext
extends RefCounted


# --- 公共变量 ---

## 运行时值表。字段含义由项目决定。
var values: Dictionary = {}

## 条件处理器，建议签名为 func(condition_id, payload, subject, context) -> Variant。
var condition_handler: Callable = Callable()

## mutation 处理器，建议签名为 func(mutation_id, payload, subject, context) -> Variant。
var mutation_handler: Callable = Callable()

## 文本解析器，建议签名为 func(text, subject, context) -> String。
var text_resolver: Callable = Callable()


# --- 私有变量 ---

var _architecture_ref: WeakRef = null


# --- Godot 生命周期方法 ---

func _init(architecture: GFArchitecture = null, initial_values: Dictionary = {}) -> void:
	set_architecture(architecture)
	values = initial_values.duplicate(true)


# --- 公共方法 ---

## 设置架构引用。
## @param architecture: 架构实例。
## @return 当前上下文。
func set_architecture(architecture: GFArchitecture) -> GFDialogueContext:
	_architecture_ref = weakref(architecture) if architecture != null else null
	return self


## 获取架构引用。
## @return 架构实例；不存在时返回 null。
func get_architecture() -> GFArchitecture:
	if _architecture_ref == null:
		return null
	return _architecture_ref.get_ref() as GFArchitecture


## 写入上下文值。
## @param key: 值键。
## @param value: 值。
## @return 当前上下文。
func set_value(key: StringName, value: Variant) -> GFDialogueContext:
	values[key] = value
	return self


## 读取上下文值。
## @param key: 值键。
## @param default_value: 默认值。
## @return 当前值或默认值。
func get_value(key: StringName, default_value: Variant = null) -> Variant:
	return values.get(key, default_value)


## 检查条件。
## @param condition_id: 条件 ID。
## @param payload: 条件载荷。
## @param subject: 触发条件的行、响应或项目对象。
## @return 结构化结果。
func check_condition(condition_id: StringName, payload: Variant = null, subject: Variant = null) -> Dictionary:
	if condition_id == &"":
		return _normalize_result(true)
	if not condition_handler.is_valid():
		return _normalize_result(false, &"missing_condition_handler")
	return _normalize_result(condition_handler.call(condition_id, payload, subject, self))


## 请求执行 mutation。
## @param mutation_id: mutation ID。
## @param payload: mutation 载荷。
## @param subject: 触发 mutation 的行、响应或项目对象。
## @return 结构化结果。
func apply_mutation(mutation_id: StringName, payload: Variant = null, subject: Variant = null) -> Dictionary:
	if mutation_id == &"":
		return _normalize_result(true)
	if not mutation_handler.is_valid():
		return _normalize_result(false, &"missing_mutation_handler")
	return _normalize_result(mutation_handler.call(mutation_id, payload, subject, self))


## 解析文本。
## @param text: 原始文本或文本键。
## @param subject: 文本所属行、响应或项目对象。
## @return 解析后的文本。
func resolve_text(text: String, subject: Variant = null) -> String:
	if not text_resolver.is_valid():
		return text
	return String(text_resolver.call(text, subject, self))


## 序列化运行值。
## @return 值表副本。
func serialize_values() -> Dictionary:
	return values.duplicate(true)


## 恢复运行值。
## @param data: 值表。
func deserialize_values(data: Dictionary) -> void:
	values = data.duplicate(true)


# --- 私有/辅助方法 ---

func _normalize_result(raw_result: Variant, default_reason: StringName = &"ok") -> Dictionary:
	if raw_result is Dictionary:
		var result := (raw_result as Dictionary).duplicate(true)
		if not result.has("ok"):
			result["ok"] = true
		if not result.has("reason"):
			result["reason"] = default_reason if bool(result.get("ok", false)) else &"rejected"
		return result

	var ok := bool(raw_result) if raw_result is bool else true
	return {
		"ok": ok,
		"reason": default_reason if ok else &"rejected",
		"value": raw_result,
	}
