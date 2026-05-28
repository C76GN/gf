## GFPersistPropertiesSource: 属性白名单存档 Source。
##
## 以节点形式包装 `GFNodePropertySerializer`，让项目可以直接在场景树中声明
## 需要保存的目标属性。它仍然使用 SaveGraph 的 Source/Serializer 协议，
## 不引入独立存储格式。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.23.0
class_name GFPersistPropertiesSource
extends GFSaveSource


# --- 导出变量 ---

## 需要保存的目标节点属性名。
## [br]
## @api public
@export var properties: PackedStringArray = PackedStringArray()

## 应用数据时遇到缺失属性是否跳过。
## [br]
## @api public
@export var skip_missing_properties: bool = true


# --- 私有变量 ---

var _property_serializer: GFNodePropertySerializer = GFNodePropertySerializer.new()


# --- 可重写钩子 / 虚方法 ---

## 采集属性白名单保存数据。
## [br]
## @api protected
## [br]
## @param context: 调用上下文字典。
## [br]
## @param serializer_registry: 可选节点序列化器注册表。
## [br]
## @return 可写入存档的数据。
## [br]
## @schema context: Dictionary，可包含 pipeline_context、pipeline_shared、include_pipeline_trace 等流程字段。
## [br]
## @schema return: Variant，通常为 Dictionary；默认实现返回包含 serializers: Array[Dictionary] 的载荷，或空 Dictionary。
func _gather_save_data(
	context: Dictionary = {},
	serializer_registry: GFNodeSerializerRegistry = null
) -> Variant:
	var target := get_target_node()
	if target == null:
		return {}

	var serializer_payloads := _gather_configured_serializers(target, context, serializer_registry)
	if serializer_payloads.is_empty():
		return {}

	return {
		"serializers": serializer_payloads,
	}


## 应用属性白名单保存数据。
## [br]
## @api protected
## [br]
## @param data: 保存数据。
## [br]
## @param context: 调用上下文字典。
## [br]
## @param serializer_registry: 可选节点序列化器注册表。
## [br]
## @return 结果字典。
## [br]
## @schema data: Variant，默认实现要求为包含 serializers: Array[Dictionary] 的 Dictionary。
## [br]
## @schema context: Dictionary，可包含 pipeline_context、pipeline_shared、include_pipeline_trace 等流程字段。
## [br]
## @schema return: Dictionary，包含 ok、applied 与 errors。
func _apply_save_data(
	data: Variant,
	context: Dictionary = {},
	serializer_registry: GFNodeSerializerRegistry = null
) -> Dictionary:
	if not (data is Dictionary):
		return make_result(false, "Source data must be a Dictionary.")

	var target := get_target_node()
	if target == null:
		return make_result(false, "Target node is null.")

	var dictionary := data as Dictionary
	if dictionary.is_empty():
		return make_result(true)
	if not dictionary.has("serializers"):
		return make_result(false, "Serializer payloads are missing.")

	var serializer_payloads_variant: Variant = dictionary.get("serializers", [])
	if not (serializer_payloads_variant is Array):
		return make_result(false, "Serializer payloads must be an Array.")

	var serializer_payloads := serializer_payloads_variant as Array
	if serializer_payloads.is_empty():
		return make_result(true)

	return _apply_configured_serializers(target, serializer_payloads, context, serializer_registry)


# --- 私有/辅助方法 ---

func _gather_configured_serializers(
	target: Node,
	context: Dictionary,
	serializer_registry: GFNodeSerializerRegistry
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for serializer: GFNodeSerializer in _get_configured_serializers(target, serializer_registry):
		if serializer == null or not serializer.supports_node(target):
			continue
		var serializer_data := serializer.gather(target, context)
		if serializer_data.is_empty():
			continue
		result.append({
			"id": serializer.get_serializer_id(),
			"data": serializer_data,
		})
	return result


func _apply_configured_serializers(
	target: Node,
	serializer_payloads: Array,
	context: Dictionary,
	serializer_registry: GFNodeSerializerRegistry
) -> Dictionary:
	var by_id := _index_configured_serializers(target, serializer_registry)
	var errors: Array[String] = []
	var applied := 0

	for payload_variant: Variant in serializer_payloads:
		if not (payload_variant is Dictionary):
			continue

		var payload := payload_variant as Dictionary
		var serializer_id := StringName(payload.get("id", &""))
		var serializer := by_id.get(serializer_id) as GFNodeSerializer
		if serializer == null:
			errors.append("Missing serializer: %s" % String(serializer_id))
			continue
		if not serializer.supports_node(target):
			errors.append("Serializer does not support target: %s" % String(serializer_id))
			continue
		if not (payload.get("data", {}) is Dictionary):
			errors.append("Serializer data must be a Dictionary: %s" % String(serializer_id))
			continue

		var serializer_data := payload.get("data", {}) as Dictionary
		var result := serializer.apply(target, serializer_data, context)
		if bool(result.get("ok", false)):
			applied += 1
		else:
			errors.append(String(result.get("error", "Apply failed: %s" % String(serializer_id))))

	return {
		"ok": errors.is_empty(),
		"applied": applied,
		"errors": errors,
	}


func _index_configured_serializers(
	target: Node,
	serializer_registry: GFNodeSerializerRegistry
) -> Dictionary:
	var result: Dictionary = {}
	for serializer: GFNodeSerializer in _get_configured_serializers(target, serializer_registry):
		if serializer != null:
			result[serializer.get_serializer_id()] = serializer
	return result


func _get_configured_serializers(
	target: Node,
	serializer_registry: GFNodeSerializerRegistry
) -> Array[GFNodeSerializer]:
	var result: Array[GFNodeSerializer] = []
	_prepare_property_serializer()
	if not properties.is_empty():
		result.append(_property_serializer)

	for serializer: GFNodeSerializer in serializers:
		if serializer == null:
			continue
		if serializer.get_serializer_id() == _property_serializer.get_serializer_id():
			continue
		result.append(serializer)

	if use_registry_serializers and serializer_registry != null:
		for serializer: GFNodeSerializer in serializer_registry.get_serializers_for_node(target):
			if serializer != null:
				result.append(serializer)
	return result


func _prepare_property_serializer() -> void:
	_property_serializer.properties = properties
	_property_serializer.skip_missing_properties = skip_missing_properties
