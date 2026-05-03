## GFInputConflictAnalyzer: 输入上下文冲突分析工具。
##
## 只读取输入资源与可选重映射配置，不参与运行时输入分发。适合设置界面、
## 编辑器工具或测试在应用重绑定前检查同一输入是否被多个抽象动作占用。
class_name GFInputConflictAnalyzer
extends RefCounted


# --- 常量 ---

const GFInputBindingBase = preload("res://addons/gf/input/gf_input_binding.gd")
const GFInputContextBase = preload("res://addons/gf/input/gf_input_context.gd")
const GFInputFormatterBase = preload("res://addons/gf/input/gf_input_formatter.gd")
const GFInputMappingBase = preload("res://addons/gf/input/gf_input_mapping.gd")
const GFInputRemapConfigBase = preload("res://addons/gf/input/gf_input_remap_config.gd")


# --- 公共方法 ---

## 分析单个上下文内的绑定冲突。
## @param context: 输入上下文。
## @param remap_config: 可选重映射配置。
## @param include_non_remappable: 是否包含不可重绑动作或绑定。
## @return 冲突列表。
static func analyze_context(
	context: GFInputContextBase,
	remap_config: GFInputRemapConfigBase = null,
	include_non_remappable: bool = true
) -> Array[Dictionary]:
	if context == null:
		return []
	return analyze_contexts([context], remap_config, false, include_non_remappable)


## 分析多个上下文的绑定冲突。
## @param contexts: 输入上下文列表。
## @param remap_config: 可选重映射配置。
## @param include_cross_context: 是否报告跨上下文冲突。
## @param include_non_remappable: 是否包含不可重绑动作或绑定。
## @return 冲突列表。
static func analyze_contexts(
	contexts: Array,
	remap_config: GFInputRemapConfigBase = null,
	include_cross_context: bool = false,
	include_non_remappable: bool = true
) -> Array[Dictionary]:
	var items := collect_binding_items(contexts, remap_config, include_non_remappable)
	return _analyze_items(items, include_cross_context)


## 构建重绑定诊断报告。
## @param contexts: 输入上下文列表。
## @param remap_config: 可选重映射配置。
## @param include_cross_context: 是否报告跨上下文冲突。
## @param include_non_remappable: 是否包含不可重绑动作或绑定。
## @return 包含条目与冲突的报告。
static func build_rebind_report(
	contexts: Array,
	remap_config: GFInputRemapConfigBase = null,
	include_cross_context: bool = false,
	include_non_remappable: bool = true
) -> Dictionary:
	var items := collect_binding_items(contexts, remap_config, include_non_remappable)
	var conflicts := _analyze_items(items, include_cross_context)
	return {
		"ok": conflicts.is_empty(),
		"context_count": _count_contexts(contexts),
		"item_count": items.size(),
		"conflict_count": conflicts.size(),
		"items": items,
		"conflicts": conflicts,
	}


## 收集上下文中的有效绑定条目。
## @param contexts: 输入上下文列表。
## @param remap_config: 可选重映射配置。
## @param include_non_remappable: 是否包含不可重绑动作或绑定。
## @return 绑定条目列表。
static func collect_binding_items(
	contexts: Array,
	remap_config: GFInputRemapConfigBase = null,
	include_non_remappable: bool = true
) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for context_variant: Variant in contexts:
		var context := context_variant as GFInputContextBase
		if context == null:
			continue
		_collect_context_binding_items(context, remap_config, include_non_remappable, items)
	return items


## 获取输入事件的稳定签名。
## @param input_event: 输入事件。
## @param match_device: 是否把设备 ID 纳入签名。
## @return 签名字符串；空事件返回空字符串。
static func get_event_signature(input_event: InputEvent, match_device: bool = false) -> String:
	var event_key := _get_event_key(input_event)
	if event_key.is_empty():
		return ""
	var device_scope := _get_device_scope(input_event, match_device)
	return "%s@%s" % [event_key, device_scope]


## 判断两个输入事件是否会在绑定层互相冲突。
## @param left_event: 左侧输入事件。
## @param right_event: 右侧输入事件。
## @param left_match_device: 左侧是否要求设备精确匹配。
## @param right_match_device: 右侧是否要求设备精确匹配。
## @return 冲突返回 true。
static func are_events_equivalent(
	left_event: InputEvent,
	right_event: InputEvent,
	left_match_device: bool = false,
	right_match_device: bool = false
) -> bool:
	var left_key := _get_event_key(left_event)
	var right_key := _get_event_key(right_event)
	if left_key.is_empty() or left_key != right_key:
		return false

	var left_device := _get_device_scope(left_event, left_match_device)
	var right_device := _get_device_scope(right_event, right_match_device)
	return left_device == "*" or right_device == "*" or left_device == right_device


# --- 私有/辅助方法 ---

static func _collect_context_binding_items(
	context: GFInputContextBase,
	remap_config: GFInputRemapConfigBase,
	include_non_remappable: bool,
	items: Array[Dictionary]
) -> void:
	var context_id := context.get_context_id()
	for mapping: GFInputMappingBase in context.mappings:
		if mapping == null:
			continue
		if not include_non_remappable and mapping.action != null and not mapping.action.remappable:
			continue

		var action_id := mapping.get_action_id()
		for binding_index: int in range(mapping.bindings.size()):
			var binding := mapping.bindings[binding_index]
			if binding == null:
				continue
			if not include_non_remappable and not binding.remappable:
				continue

			var event := binding.input_event
			if remap_config != null and remap_config.has_binding(context_id, action_id, binding_index):
				event = remap_config.get_bound_event_or_null(context_id, action_id, binding_index)
			if event == null:
				continue

			var event_key := _get_event_key(event)
			if event_key.is_empty():
				continue

			items.append({
				"context_id": context_id,
				"context_name": context.get_display_name(),
				"action_id": action_id,
				"action_name": mapping.get_display_name(),
				"binding_index": binding_index,
				"event": event,
				"event_text": GFInputFormatterBase.input_event_as_text(event),
				"event_key": event_key,
				"signature": get_event_signature(event, binding.match_device),
				"device_scope": _get_device_scope(event, binding.match_device),
				"match_device": binding.match_device,
			})


static func _analyze_items(items: Array[Dictionary], include_cross_context: bool) -> Array[Dictionary]:
	var conflicts: Array[Dictionary] = []
	for left_index: int in range(items.size()):
		var left := items[left_index]
		for right_index: int in range(left_index + 1, items.size()):
			var right := items[right_index]
			if not include_cross_context and left["context_id"] != right["context_id"]:
				continue
			if not _items_conflict(left, right):
				continue
			conflicts.append(_make_conflict(left, right))
	return conflicts


static func _count_contexts(contexts: Array) -> int:
	var count := 0
	for context_variant: Variant in contexts:
		var context := context_variant as GFInputContextBase
		if context != null:
			count += 1
	return count


static func _items_conflict(left: Dictionary, right: Dictionary) -> bool:
	if String(left.get("event_key", "")) != String(right.get("event_key", "")):
		return false

	var left_device := String(left.get("device_scope", "*"))
	var right_device := String(right.get("device_scope", "*"))
	return left_device == "*" or right_device == "*" or left_device == right_device


static func _make_conflict(left: Dictionary, right: Dictionary) -> Dictionary:
	return {
		"context_id": left["context_id"],
		"action_id": left["action_id"],
		"binding_index": left["binding_index"],
		"other_context_id": right["context_id"],
		"other_action_id": right["action_id"],
		"other_binding_index": right["binding_index"],
		"event_text": left["event_text"],
		"signature": left["signature"],
		"items": [left, right],
	}


static func _get_event_key(input_event: InputEvent) -> String:
	if input_event == null:
		return ""

	if input_event is InputEventAction:
		return "action:%s" % String((input_event as InputEventAction).action)

	if input_event is InputEventKey:
		var key_event := input_event as InputEventKey
		var keycode := key_event.physical_keycode
		if keycode == KEY_NONE:
			keycode = key_event.keycode
		return "key:%d:%d:%d:%d:%d" % [
			int(keycode),
			1 if key_event.ctrl_pressed else 0,
			1 if key_event.alt_pressed else 0,
			1 if key_event.shift_pressed else 0,
			1 if key_event.meta_pressed else 0,
		]

	if input_event is InputEventMouseButton:
		return "mouse_button:%d" % int((input_event as InputEventMouseButton).button_index)

	if input_event is InputEventJoypadButton:
		return "joy_button:%d" % int((input_event as InputEventJoypadButton).button_index)

	if input_event is InputEventJoypadMotion:
		return "joy_axis:%d" % int((input_event as InputEventJoypadMotion).axis)

	if input_event is InputEventScreenTouch:
		return "screen_touch"

	return "event:%s" % input_event.as_text()


static func _get_device_scope(input_event: InputEvent, match_device: bool) -> String:
	if input_event == null or not match_device:
		return "*"
	return str(input_event.device)
