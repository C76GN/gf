## GFInputRemapConfig: 输入重映射配置。
##
## 只保存玩家或项目层覆盖过的输入事件，默认绑定仍来自 GFInputContext。
class_name GFInputRemapConfig
extends Resource


# --- 常量 ---

const _EVENT_CLASS_FIELD: String = "event_class"
const _EVENT_PROPERTIES_FIELD: String = "properties"
const _LEGACY_EVENT_FIELD: String = "event"

const _ALLOWED_INPUT_EVENT_CLASSES: Dictionary = {
	"InputEventAction": true,
	"InputEventJoypadButton": true,
	"InputEventJoypadMotion": true,
	"InputEventKey": true,
	"InputEventMIDI": true,
	"InputEventMagnifyGesture": true,
	"InputEventMouseButton": true,
	"InputEventMouseMotion": true,
	"InputEventPanGesture": true,
	"InputEventScreenDrag": true,
	"InputEventScreenTouch": true,
}

const _SKIPPED_EVENT_PROPERTIES: Dictionary = {
	"resource_local_to_scene": true,
	"resource_name": true,
	"resource_path": true,
	"script": true,
}


# --- 导出变量 ---

## 重绑定输入。结构为 context_id -> action_id -> binding_index -> InputEvent 或 null。
@export var remapped_events: Dictionary = {}

## 项目自定义数据。框架不解释该字段。
@export var custom_data: Dictionary = {}


# --- 公共方法 ---

## 设置绑定覆盖。
## @param context_id: 上下文标识。
## @param action_id: 动作标识。
## @param binding_index: 绑定索引。
## @param input_event: 新输入事件；null 表示显式解绑。
func set_binding(
	context_id: StringName,
	action_id: StringName,
	binding_index: int,
	input_event: InputEvent
) -> void:
	if binding_index < 0:
		return

	var action_map := _ensure_action_map(context_id, action_id)
	action_map[binding_index] = input_event.duplicate(true) as InputEvent if input_event != null else null


## 显式解绑某个绑定。
## @param context_id: 上下文标识。
## @param action_id: 动作标识。
## @param binding_index: 绑定索引。
func unbind(context_id: StringName, action_id: StringName, binding_index: int) -> void:
	set_binding(context_id, action_id, binding_index, null)


## 清除某个覆盖，使其回退到默认绑定。
## @param context_id: 上下文标识。
## @param action_id: 动作标识。
## @param binding_index: 绑定索引。
func clear_binding(context_id: StringName, action_id: StringName, binding_index: int) -> void:
	if not has_binding(context_id, action_id, binding_index):
		return

	var context_map := remapped_events[context_id] as Dictionary
	var action_map := context_map[action_id] as Dictionary
	action_map.erase(binding_index)
	if action_map.is_empty():
		context_map.erase(action_id)
	if context_map.is_empty():
		remapped_events.erase(context_id)


## 检查是否存在覆盖记录。显式解绑也会返回 true。
## @param context_id: 上下文标识。
## @param action_id: 动作标识。
## @param binding_index: 绑定索引。
## @return 是否存在覆盖。
func has_binding(context_id: StringName, action_id: StringName, binding_index: int) -> bool:
	if not remapped_events.has(context_id):
		return false
	var context_map := remapped_events[context_id] as Dictionary
	if context_map == null or not context_map.has(action_id):
		return false
	var action_map := context_map[action_id] as Dictionary
	return action_map != null and action_map.has(binding_index)


## 获取覆盖输入事件。
## @param context_id: 上下文标识。
## @param action_id: 动作标识。
## @param binding_index: 绑定索引。
## @return 覆盖事件；显式解绑或未覆盖时均可能返回 null，应先调用 has_binding() 区分。
func get_bound_event_or_null(context_id: StringName, action_id: StringName, binding_index: int) -> InputEvent:
	if not has_binding(context_id, action_id, binding_index):
		return null
	var context_map := remapped_events[context_id] as Dictionary
	var action_map := context_map[action_id] as Dictionary
	return action_map[binding_index] as InputEvent


## 设置自定义数据。
## @param key: 键。
## @param value: 值。
func set_custom_data(key: Variant, value: Variant) -> void:
	custom_data[key] = value


## 获取自定义数据。
## @param key: 键。
## @param default_value: 默认值。
## @return 自定义数据。
func get_custom_data(key: Variant, default_value: Variant = null) -> Variant:
	return custom_data.get(key, default_value)


## 转换为可写入 JSON/存档的 Dictionary。
## @return 重映射配置字典。
func to_dict() -> Dictionary:
	var serialized_events: Dictionary = {}
	for context_key: Variant in remapped_events.keys():
		var context_map := remapped_events[context_key] as Dictionary
		if context_map == null:
			continue

		var serialized_context: Dictionary = {}
		for action_key: Variant in context_map.keys():
			var action_map := context_map[action_key] as Dictionary
			if action_map == null:
				continue

			var serialized_action: Dictionary = {}
			for binding_key: Variant in action_map.keys():
				serialized_action[str(int(binding_key))] = _event_to_record(action_map[binding_key] as InputEvent)
			if not serialized_action.is_empty():
				serialized_context[String(action_key)] = serialized_action

		if not serialized_context.is_empty():
			serialized_events[String(context_key)] = serialized_context

	return {
		"remapped_events": serialized_events,
		"custom_data": GFVariantData.duplicate_variant(custom_data),
	}


## 应用由 to_dict() 生成的重映射配置。
## @param data: 重映射配置字典。
func apply_dict(data: Dictionary) -> void:
	remapped_events.clear()
	var serialized_events := data.get("remapped_events", {}) as Dictionary
	if serialized_events != null:
		for context_key: Variant in serialized_events.keys():
			var context_map := serialized_events[context_key] as Dictionary
			if context_map == null:
				continue

			for action_key: Variant in context_map.keys():
				var action_map := context_map[action_key] as Dictionary
				if action_map == null:
					continue

				for binding_key: Variant in action_map.keys():
					var binding_index := String(binding_key).to_int()
					if binding_index < 0:
						continue
					var record := action_map[binding_key] as Dictionary
					if record == null:
						continue
					if bool(record.get("unbound", false)):
						unbind(StringName(context_key), StringName(action_key), binding_index)
					else:
						var input_event := _event_from_record(record)
						if input_event != null:
							set_binding(StringName(context_key), StringName(action_key), binding_index, input_event)

	var custom_data_value := data.get("custom_data", {}) as Dictionary
	custom_data = GFVariantData.duplicate_variant(custom_data_value) if custom_data_value != null else {}


## 从 Dictionary 创建重映射配置。
## @param data: 重映射配置字典。
## @return 新重映射配置。
static func from_dict(data: Dictionary) -> GFInputRemapConfig:
	var config := GFInputRemapConfig.new()
	config.apply_dict(data)
	return config


## 复制重映射配置。
## @return 深拷贝后的重映射配置。
func duplicate_config() -> GFInputRemapConfig:
	return GFInputRemapConfig.from_dict(to_dict())


# --- 私有/辅助方法 ---

func _ensure_action_map(context_id: StringName, action_id: StringName) -> Dictionary:
	if not remapped_events.has(context_id):
		remapped_events[context_id] = {}

	var context_map := remapped_events[context_id] as Dictionary
	if not context_map.has(action_id):
		context_map[action_id] = {}

	return context_map[action_id] as Dictionary


func _event_to_record(input_event: InputEvent) -> Dictionary:
	if input_event == null:
		return {"unbound": true}

	var event_class := input_event.get_class()
	if not _ALLOWED_INPUT_EVENT_CLASSES.has(event_class):
		return {"unbound": true}

	return {
		"unbound": false,
		_EVENT_CLASS_FIELD: event_class,
		_EVENT_PROPERTIES_FIELD: _event_properties_to_record(input_event),
	}


func _event_from_record(record: Dictionary) -> InputEvent:
	var event_class := String(record.get(_EVENT_CLASS_FIELD, ""))
	if not event_class.is_empty():
		return _event_from_structured_record(event_class, record)

	var event_text := String(record.get(_LEGACY_EVENT_FIELD, ""))
	if event_text.is_empty():
		return null
	var value: Variant = str_to_var(event_text)
	return value as InputEvent


func _event_from_structured_record(event_class: String, record: Dictionary) -> InputEvent:
	if not _ALLOWED_INPUT_EVENT_CLASSES.has(event_class):
		return null
	if not ClassDB.can_instantiate(event_class):
		return null

	var input_event := ClassDB.instantiate(event_class) as InputEvent
	if input_event == null:
		return null

	var writable_properties := _get_event_writable_properties(input_event)
	var properties := record.get(_EVENT_PROPERTIES_FIELD, {}) as Dictionary
	if properties == null:
		return input_event

	for property_key: Variant in properties.keys():
		var property_name := String(property_key)
		if not writable_properties.has(property_name):
			continue
		input_event.set(property_name, GFVariantJsonCodec.json_compatible_to_variant(properties[property_key]))
	return input_event


func _event_properties_to_record(input_event: InputEvent) -> Dictionary:
	var result: Dictionary = {}
	for property: Dictionary in input_event.get_property_list():
		var property_name := String(property.get("name", ""))
		if property_name.is_empty() or _SKIPPED_EVENT_PROPERTIES.has(property_name):
			continue
		if not _is_stored_event_property(property):
			continue

		var value: Variant = input_event.get(property_name)
		if _can_store_event_property(value):
			result[property_name] = GFVariantJsonCodec.variant_to_json_compatible(value)
	return result


func _get_event_writable_properties(input_event: InputEvent) -> Dictionary:
	var result: Dictionary = {}
	for property: Dictionary in input_event.get_property_list():
		var property_name := String(property.get("name", ""))
		if property_name.is_empty() or _SKIPPED_EVENT_PROPERTIES.has(property_name):
			continue
		if _is_stored_event_property(property):
			result[property_name] = true
	return result


func _is_stored_event_property(property: Dictionary) -> bool:
	var usage := int(property.get("usage", 0))
	return (usage & PROPERTY_USAGE_STORAGE) != 0


func _can_store_event_property(value: Variant) -> bool:
	var value_type := typeof(value)
	return (
		value_type == TYPE_NIL
		or value_type == TYPE_BOOL
		or value_type == TYPE_INT
		or value_type == TYPE_FLOAT
		or value_type == TYPE_STRING
		or value_type == TYPE_STRING_NAME
		or value_type == TYPE_NODE_PATH
		or value_type == TYPE_VECTOR2
		or value_type == TYPE_VECTOR2I
	)
