## GFNodePropertySerializer: 通用节点属性序列化器。
##
## 通过显式属性白名单保存和恢复节点属性，适合项目层快速接入简单状态。
class_name GFNodePropertySerializer
extends GFNodeSerializer


# --- 常量 ---

const _OBJECT_PROPERTY_TOOLS: Script = preload("res://addons/gf/kernel/core/gf_object_property_tools.gd")
const _VARIANT_JSON_CODEC: Script = preload("res://addons/gf/standard/foundation/variant/gf_variant_json_codec.gd")
const _PROPERTY_MARKER_KEY: String = "__gf_save_property__"
const _PROPERTY_MARKER_VERSION: int = 1
const _PROPERTY_TYPE_KEY: String = "type"
const _PROPERTY_VERSION_KEY: String = "version"
const _PROPERTY_RESOURCE_PATH_KEY: String = "path"
const _PROPERTY_UNSUPPORTED_CLASS_KEY: String = "class"
const _PROPERTY_TYPE_RESOURCE_PATH: String = "ResourcePath"
const _PROPERTY_TYPE_UNSUPPORTED_OBJECT: String = "UnsupportedObject"


# --- 导出变量 ---

## 需要保存的属性名。
@export var properties: PackedStringArray = PackedStringArray()

## 应用数据时遇到缺失属性是否跳过。
@export var skip_missing_properties: bool = true


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.property"


# --- 公共方法 ---

## 采集节点的可保存状态。
## @param node: 目标节点。
## @param _context: 操作上下文字典，默认实现不直接使用。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	if node == null:
		return {}

	var available: Dictionary = _OBJECT_PROPERTY_TOOLS.get_property_info_map(node)
	var result: Dictionary = {}
	for property_name: String in properties:
		if not available.has(StringName(property_name)):
			continue
		var property_value: Variant = _OBJECT_PROPERTY_TOOLS.read_property(node, NodePath(property_name))
		var encoded_value: Variant = _encode_payload_property_value(property_value)
		if _is_unsupported_property_marker(encoded_value):
			push_warning("[GFNodePropertySerializer] Unsupported property value skipped: %s" % property_name)
			continue
		result[property_name] = encoded_value
	return result


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	if node == null:
		return make_result(false, "Node is null.")

	for property_variant: Variant in payload.keys():
		var property_name := String(property_variant)
		if not _OBJECT_PROPERTY_TOOLS.has_property(node, StringName(property_name)):
			if skip_missing_properties:
				continue
			return make_result(false, "Missing property: %s" % property_name)
		var decode_result := _decode_payload_property_value(payload[property_variant])
		if not bool(decode_result.get("ok", false)):
			return make_result(false, String(decode_result.get("error", "")))
		var result: Dictionary = _OBJECT_PROPERTY_TOOLS.write_property(
			node,
			NodePath(property_name),
			decode_result.get("value")
		)
		if not bool(result.get("ok", false)):
			return make_result(false, String(result.get("error", "")))

	return make_result(true)


# --- 私有/辅助方法 ---

func _encode_payload_property_value(value: Variant) -> Variant:
	if value is Resource:
		var resource := value as Resource
		if resource.resource_path.is_empty():
			return _make_property_marker(_PROPERTY_TYPE_UNSUPPORTED_OBJECT, {
				_PROPERTY_UNSUPPORTED_CLASS_KEY: resource.get_class(),
			})
		return _make_property_marker(_PROPERTY_TYPE_RESOURCE_PATH, {
			_PROPERTY_RESOURCE_PATH_KEY: resource.resource_path,
		})
	if value is Object:
		var object := value as Object
		return _make_property_marker(_PROPERTY_TYPE_UNSUPPORTED_OBJECT, {
			_PROPERTY_UNSUPPORTED_CLASS_KEY: object.get_class(),
		})
	return _VARIANT_JSON_CODEC.variant_to_json_compatible(value, { "encode_dictionary_keys": true })


func _decode_payload_property_value(value: Variant) -> Dictionary:
	if _is_property_marker(value):
		var marker := (value as Dictionary).get(_PROPERTY_MARKER_KEY) as Dictionary
		var marker_type := String(marker.get(_PROPERTY_TYPE_KEY, ""))
		match marker_type:
			_PROPERTY_TYPE_RESOURCE_PATH:
				var resource_path := String(marker.get(_PROPERTY_RESOURCE_PATH_KEY, ""))
				if resource_path.is_empty():
					return _make_decode_result(false, null, "Resource path is empty.")
				var resource := ResourceLoader.load(resource_path)
				if resource == null:
					return _make_decode_result(false, null, "Resource could not be loaded: %s" % resource_path)
				return _make_decode_result(true, resource)
			_PROPERTY_TYPE_UNSUPPORTED_OBJECT:
				return _make_decode_result(false, null, "Unsupported object property value.")
	return _make_decode_result(true, _VARIANT_JSON_CODEC.json_compatible_to_variant(value))


func _make_property_marker(marker_type: String, data: Dictionary = {}) -> Dictionary:
	var marker := data.duplicate(true)
	marker[_PROPERTY_VERSION_KEY] = _PROPERTY_MARKER_VERSION
	marker[_PROPERTY_TYPE_KEY] = marker_type
	return {
		_PROPERTY_MARKER_KEY: marker,
	}


func _is_property_marker(value: Variant) -> bool:
	if not (value is Dictionary):
		return false
	var dictionary := value as Dictionary
	if dictionary.size() != 1 or not dictionary.has(_PROPERTY_MARKER_KEY):
		return false
	var marker := dictionary.get(_PROPERTY_MARKER_KEY) as Dictionary
	return marker != null and marker.has(_PROPERTY_TYPE_KEY)


func _is_unsupported_property_marker(value: Variant) -> bool:
	if not _is_property_marker(value):
		return false
	var marker := (value as Dictionary).get(_PROPERTY_MARKER_KEY) as Dictionary
	return String(marker.get(_PROPERTY_TYPE_KEY, "")) == _PROPERTY_TYPE_UNSUPPORTED_OBJECT


func _make_decode_result(ok: bool, value: Variant = null, error: String = "") -> Dictionary:
	return {
		"ok": ok,
		"value": value,
		"error": error,
	}
