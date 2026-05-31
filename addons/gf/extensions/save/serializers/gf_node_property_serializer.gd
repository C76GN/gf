## GFNodePropertySerializer: 通用节点属性序列化器。
##
## 通过显式属性白名单保存和恢复节点属性，适合项目层快速接入简单状态。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFNodePropertySerializer
extends GFNodeSerializer


# --- 常量 ---

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
## [br]
## @api public
@export var properties: PackedStringArray = PackedStringArray()

## 应用数据时遇到缺失属性是否跳过。
## [br]
## @api public
@export var skip_missing_properties: bool = true


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.property"


# --- 公共方法 ---

## 采集节点的可保存状态。
## [br]
## @api public
## [br]
## @param node: 目标节点。
## [br]
## @param _context: 操作上下文字典，默认实现不直接使用。
## [br]
## @return 属性载荷字典。
## [br]
## @schema _context: Dictionary，调用方附加上下文；当前实现不读取。
## [br]
## @schema return: Dictionary，键为 properties 中声明的属性名，值为 JSON 兼容值；Resource 引用使用 __gf_save_property__ 标记。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	if node == null:
		return {}

	var available: Dictionary = GFObjectPropertyTools.get_property_info_map(node)
	var result: Dictionary = {}
	for property_name: String in properties:
		if not available.has(StringName(property_name)):
			continue
		var property_value: Variant = GFObjectPropertyTools.read_property(node, NodePath(property_name))
		var encoded_value: Variant = _encode_payload_property_value(property_value)
		if _is_unsupported_property_marker(encoded_value):
			push_warning("[GFNodePropertySerializer] Unsupported property value skipped: %s" % property_name)
			continue
		result[property_name] = encoded_value
	return result


## 将序列化数据应用到节点。
## [br]
## @api public
## [br]
## @param node: 目标节点。
## [br]
## @param payload: 属性载荷字典。
## [br]
## @param _context: 操作上下文字典，默认实现不直接使用。
## [br]
## @return 应用结果字典。
## [br]
## @schema payload: Dictionary，键为属性名，值为 JSON 兼容值或 __gf_save_property__ 标记。
## [br]
## @schema _context: Dictionary，调用方附加上下文；当前实现不读取。
## [br]
## @schema return: Dictionary，包含 ok: bool 与 error: String。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	if node == null:
		return make_result(false, "Node is null.")

	for property_variant: Variant in payload.keys():
		var property_name: String = GFVariantData.to_text(property_variant)
		if not GFObjectPropertyTools.has_property(node, StringName(property_name)):
			if skip_missing_properties:
				continue
			return make_result(false, "Missing property: %s" % property_name)
		var decode_result: Dictionary = _decode_payload_property_value(payload[property_variant])
		if not GFVariantData.get_option_bool(decode_result, "ok", false):
			return make_result(false, GFVariantData.get_option_string(decode_result, "error"))
		var result: Dictionary = GFObjectPropertyTools.write_property(
			node,
			NodePath(property_name),
			GFVariantData.get_option_value(decode_result, "value")
		)
		if not GFVariantData.get_option_bool(result, "ok", false):
			return make_result(false, GFVariantData.get_option_string(result, "error"))

	return make_result(true)


# --- 私有/辅助方法 ---

func _encode_payload_property_value(value: Variant) -> Variant:
	if value is Resource:
		var resource: Resource = value
		if resource.resource_path.is_empty():
			return _make_property_marker(_PROPERTY_TYPE_UNSUPPORTED_OBJECT, {
				_PROPERTY_UNSUPPORTED_CLASS_KEY: resource.get_class(),
			})
		return _make_property_marker(_PROPERTY_TYPE_RESOURCE_PATH, {
			_PROPERTY_RESOURCE_PATH_KEY: resource.resource_path,
		})
	if value is Object:
		var object: Object = value
		return _make_property_marker(_PROPERTY_TYPE_UNSUPPORTED_OBJECT, {
			_PROPERTY_UNSUPPORTED_CLASS_KEY: object.get_class(),
		})
	return GFVariantJsonCodec.variant_to_json_compatible(value, { "encode_dictionary_keys": true })


func _decode_payload_property_value(value: Variant) -> Dictionary:
	if _is_property_marker(value):
		var marker: Dictionary = _get_property_marker(value)
		var marker_type: String = GFVariantData.get_option_string(marker, _PROPERTY_TYPE_KEY)
		match marker_type:
			_PROPERTY_TYPE_RESOURCE_PATH:
				var encoded_resource_path: String = GFVariantData.get_option_string(marker, _PROPERTY_RESOURCE_PATH_KEY)
				if encoded_resource_path.is_empty():
					return _make_decode_result(false, null, "Resource path is empty.")
				var resource: Resource = ResourceLoader.load(encoded_resource_path)
				if resource == null:
					return _make_decode_result(false, null, "Resource could not be loaded: %s" % encoded_resource_path)
				return _make_decode_result(true, resource)
			_PROPERTY_TYPE_UNSUPPORTED_OBJECT:
				return _make_decode_result(false, null, "Unsupported object property value.")
	return _make_decode_result(true, GFVariantJsonCodec.json_compatible_to_variant(value))


func _make_property_marker(marker_type: String, data: Dictionary = {}) -> Dictionary:
	var marker: Dictionary = data.duplicate(true)
	marker[_PROPERTY_VERSION_KEY] = _PROPERTY_MARKER_VERSION
	marker[_PROPERTY_TYPE_KEY] = marker_type
	return {
		_PROPERTY_MARKER_KEY: marker,
	}


func _is_property_marker(value: Variant) -> bool:
	if not (value is Dictionary):
		return false
	var dictionary: Dictionary = GFVariantData.as_dictionary(value)
	if dictionary.size() != 1 or not dictionary.has(_PROPERTY_MARKER_KEY):
		return false
	var marker: Dictionary = GFVariantData.as_dictionary(GFVariantData.get_option_value(dictionary, _PROPERTY_MARKER_KEY))
	return marker.has(_PROPERTY_TYPE_KEY)


func _is_unsupported_property_marker(value: Variant) -> bool:
	if not _is_property_marker(value):
		return false
	var marker: Dictionary = _get_property_marker(value)
	return GFVariantData.get_option_string(marker, _PROPERTY_TYPE_KEY) == _PROPERTY_TYPE_UNSUPPORTED_OBJECT


func _make_decode_result(ok: bool, value: Variant = null, error: String = "") -> Dictionary:
	return {
		"ok": ok,
		"value": value,
		"error": error,
	}


func _get_property_marker(value: Variant) -> Dictionary:
	var dictionary: Dictionary = GFVariantData.as_dictionary(value)
	return GFVariantData.as_dictionary(GFVariantData.get_option_value(dictionary, _PROPERTY_MARKER_KEY))
