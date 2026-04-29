## GFInputRemapConfig: 输入重映射配置。
##
## 只保存玩家或项目层覆盖过的输入事件，默认绑定仍来自 GFInputContext。
class_name GFInputRemapConfig
extends Resource


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


# --- 私有/辅助方法 ---

func _ensure_action_map(context_id: StringName, action_id: StringName) -> Dictionary:
	if not remapped_events.has(context_id):
		remapped_events[context_id] = {}

	var context_map := remapped_events[context_id] as Dictionary
	if not context_map.has(action_id):
		context_map[action_id] = {}

	return context_map[action_id] as Dictionary
