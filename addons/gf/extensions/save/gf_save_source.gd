## GFSaveSource: 存档图数据源节点。
##
## Source 是存档图的最小数据入口。项目可继承并重写 gather/apply，
## 也可配置节点序列化器保存通用节点属性。
class_name GFSaveSource
extends Node


# --- 常量 ---

const GFNodeSerializerBase = preload("res://addons/gf/extensions/save/gf_node_serializer.gd")
const GFNodeSerializerRegistryBase = preload("res://addons/gf/extensions/save/gf_node_serializer_registry.gd")


# --- 导出变量 ---

## Source 稳定标识。留空时回退到节点名。
@export var source_key: StringName = &""

## 目标节点路径。留空时默认序列化父节点。
@export var target_node_path: NodePath

## 是否启用该 Source。
@export var enabled: bool = true

## 是否参与保存。
@export var save_enabled: bool = true

## 是否参与加载。
@export var load_enabled: bool = true

## 执行阶段。数值越小越早执行。
@export var phase: int = GFSaveScope.Phase.NORMAL

## Source 局部序列化器。为空时可使用注册表中的默认序列化器。
@export var serializers: Array[GFNodeSerializerBase] = []

## 是否在未配置局部序列化器时使用注册表默认序列化器。
@export var use_registry_serializers: bool = false

## 附加描述字段。
@export var descriptor_extra: Dictionary = {}


# --- 公共方法 ---

## 获取 Source 稳定标识。
## @return Source key。
func get_source_key() -> StringName:
	if source_key != &"":
		return source_key
	return StringName(name)


## 获取目标节点。
## @return 目标节点；不存在时返回 null。
func get_target_node() -> Node:
	if not target_node_path.is_empty():
		return get_node_or_null(target_node_path)
	return get_parent()


## 判断是否可保存。
## @param _context: 调用上下文字典。
## @return 可保存时返回 true。
func can_save_source(_context: Dictionary = {}) -> bool:
	return enabled and save_enabled


## 判断是否可加载。
## @param _context: 调用上下文字典。
## @return 可加载时返回 true。
func can_load_source(_context: Dictionary = {}) -> bool:
	return enabled and load_enabled


## 保存前 Hook。
## @param _context: 调用上下文字典。
func before_save(_context: Dictionary = {}) -> void:
	pass


## 采集保存数据。
## @param context: 调用上下文字典。
## @param serializer_registry: 可选节点序列化器注册表。
## @return 可写入存档的数据。
func gather_save_data(
	context: Dictionary = {},
	serializer_registry: GFNodeSerializerRegistryBase = null
) -> Variant:
	var target := get_target_node()
	if target == null:
		return {}

	var serializer_payloads := _gather_serializer_payloads(target, context, serializer_registry)
	if serializer_payloads.is_empty():
		return {}

	return {
		"serializers": serializer_payloads,
	}


## 应用保存数据。
## @param data: 保存数据。
## @param context: 调用上下文字典。
## @param serializer_registry: 可选节点序列化器注册表。
## @return 结果字典。
func apply_save_data(
	data: Variant,
	context: Dictionary = {},
	serializer_registry: GFNodeSerializerRegistryBase = null
) -> Dictionary:
	if not (data is Dictionary):
		return make_result(true)

	var target := get_target_node()
	if target == null:
		return make_result(false, "Target node is null.")

	var dictionary := data as Dictionary
	var serializer_payloads: Array = dictionary.get("serializers", []) as Array
	if serializer_payloads.is_empty():
		return make_result(true)

	if not serializers.is_empty():
		return _apply_local_serializers(target, serializer_payloads, context)
	if serializer_registry != null:
		return serializer_registry.apply_node(target, serializer_payloads, context)
	return make_result(false, "Serializer registry is null.")


## 加载后 Hook。
## @param _data: 已应用的数据。
## @param _context: 调用上下文字典。
func after_load(_data: Variant, _context: Dictionary = {}) -> void:
	pass


## 构造 Source 描述。
## @param scope: 当前 Scope。
## @return 描述字典。
func describe_source(scope: Node = null) -> Dictionary:
	var descriptor := descriptor_extra.duplicate(true)
	descriptor["source_key"] = get_source_key()
	descriptor["phase"] = phase
	if scope != null and is_inside_tree() and scope.is_inside_tree():
		descriptor["node_path"] = String(scope.get_path_to(self))
	return descriptor


## 构造统一结果。
## @param ok: 是否成功。
## @param error: 错误描述。
## @return 结果字典。
func make_result(ok: bool, error: String = "") -> Dictionary:
	return {
		"ok": ok,
		"error": error,
	}


# --- 私有/辅助方法 ---

func _gather_serializer_payloads(
	target: Node,
	context: Dictionary,
	serializer_registry: GFNodeSerializerRegistryBase
) -> Array[Dictionary]:
	if not serializers.is_empty():
		var result: Array[Dictionary] = []
		for serializer: GFNodeSerializerBase in serializers:
			if serializer == null or not serializer.supports_node(target):
				continue
			var data := serializer.gather(target, context)
			if data.is_empty():
				continue
			result.append({
				"id": serializer.get_serializer_id(),
				"data": data,
			})
		return result

	if use_registry_serializers and serializer_registry != null:
		return serializer_registry.gather_node(target, context)
	return []


func _apply_local_serializers(target: Node, serializer_payloads: Array, context: Dictionary) -> Dictionary:
	var by_id: Dictionary = {}
	for serializer: GFNodeSerializerBase in serializers:
		if serializer != null:
			by_id[serializer.get_serializer_id()] = serializer

	var errors: Array[String] = []
	var applied := 0
	for payload_variant: Variant in serializer_payloads:
		if not (payload_variant is Dictionary):
			continue

		var payload := payload_variant as Dictionary
		var serializer_id := StringName(payload.get("id", &""))
		var serializer := by_id.get(serializer_id) as GFNodeSerializerBase
		if serializer == null:
			errors.append("Missing serializer: %s" % String(serializer_id))
			continue
		if not serializer.supports_node(target):
			errors.append("Serializer does not support target: %s" % String(serializer_id))
			continue

		var data: Dictionary = payload.get("data", {}) as Dictionary
		var result := serializer.apply(target, data, context)
		if bool(result.get("ok", false)):
			applied += 1
		else:
			errors.append(String(result.get("error", "Apply failed: %s" % String(serializer_id))))

	return {
		"ok": errors.is_empty(),
		"applied": applied,
		"errors": errors,
	}
