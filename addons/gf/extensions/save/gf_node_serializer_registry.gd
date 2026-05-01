## GFNodeSerializerRegistry: 节点序列化器注册表。
##
## 负责按 serializer_id 管理序列化器，并为节点执行一组可组合的采集和应用。
class_name GFNodeSerializerRegistry
extends RefCounted


# --- 常量 ---

const GFNodeSerializerBase = preload("res://addons/gf/extensions/save/gf_node_serializer.gd")
const GFNodeCanvasItemSerializerBase = preload("res://addons/gf/extensions/save/gf_node_canvas_item_serializer.gd")
const GFNodeControlSerializerBase = preload("res://addons/gf/extensions/save/gf_node_control_serializer.gd")
const GFNodeRangeSerializerBase = preload("res://addons/gf/extensions/save/gf_node_range_serializer.gd")
const GFNodeTransform2DSerializerBase = preload("res://addons/gf/extensions/save/gf_node_transform_2d_serializer.gd")
const GFNodeTransform3DSerializerBase = preload("res://addons/gf/extensions/save/gf_node_transform_3d_serializer.gd")


# --- 私有变量 ---

var _serializers: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(include_default_serializers: bool = true) -> void:
	if include_default_serializers:
		register_serializer(GFNodeTransform2DSerializerBase.new())
		register_serializer(GFNodeTransform3DSerializerBase.new())
		register_serializer(GFNodeCanvasItemSerializerBase.new())
		register_serializer(GFNodeControlSerializerBase.new())
		register_serializer(GFNodeRangeSerializerBase.new())


# --- 公共方法 ---

## 注册序列化器。相同 id 会被后注册的实例覆盖。
## @param serializer: 序列化器。
func register_serializer(serializer: GFNodeSerializerBase) -> void:
	if serializer == null:
		return

	var serializer_id := serializer.get_serializer_id()
	if serializer_id == &"":
		return
	_serializers[serializer_id] = serializer


## 注销序列化器。
## @param serializer_id: 序列化器标识。
func unregister_serializer(serializer_id: StringName) -> void:
	_serializers.erase(serializer_id)


## 清空注册表。
func clear() -> void:
	_serializers.clear()


## 获取指定序列化器。
## @param serializer_id: 序列化器标识。
## @return 序列化器实例。
func get_serializer(serializer_id: StringName) -> GFNodeSerializerBase:
	return _serializers.get(serializer_id) as GFNodeSerializerBase


## 获取所有支持指定节点的序列化器。
## @param node: 目标节点。
## @return 序列化器数组。
func get_serializers_for_node(node: Node) -> Array[GFNodeSerializerBase]:
	var result: Array[GFNodeSerializerBase] = []
	for serializer_variant: Variant in _serializers.values():
		var serializer := serializer_variant as GFNodeSerializerBase
		if serializer != null and serializer.supports_node(node):
			result.append(serializer)
	return result


## 采集节点上所有支持的默认序列化器数据。
## @param node: 目标节点。
## @param context: 调用上下文字典。
## @return 序列化片段数组。
func gather_node(node: Node, context: Dictionary = {}) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for serializer: GFNodeSerializerBase in get_serializers_for_node(node):
		var data := serializer.gather(node, context)
		if data.is_empty():
			continue
		result.append({
			"id": serializer.get_serializer_id(),
			"data": data,
		})
	return result


## 应用节点序列化片段。
## @param node: 目标节点。
## @param serializer_payloads: 由 gather_node 返回的片段数组。
## @param context: 调用上下文字典。
## @return 结果字典。
func apply_node(node: Node, serializer_payloads: Array, context: Dictionary = {}) -> Dictionary:
	var errors: Array[String] = []
	var applied := 0
	for payload_variant: Variant in serializer_payloads:
		if not (payload_variant is Dictionary):
			continue

		var payload := payload_variant as Dictionary
		var serializer_id := StringName(payload.get("id", &""))
		var serializer := get_serializer(serializer_id)
		if serializer == null:
			errors.append("Missing serializer: %s" % String(serializer_id))
			continue
		if not serializer.supports_node(node):
			errors.append("Serializer does not support node: %s" % String(serializer_id))
			continue

		var data: Dictionary = payload.get("data", {}) as Dictionary
		var result := serializer.apply(node, data, context)
		if bool(result.get("ok", false)):
			applied += 1
		else:
			errors.append(String(result.get("error", "Apply failed: %s" % String(serializer_id))))

	return {
		"ok": errors.is_empty(),
		"applied": applied,
		"errors": errors,
	}
