## GFInputMappingUtility: 资源化输入上下文与动作映射运行时。
##
## 负责把 Godot InputEvent 转换为项目定义的抽象动作状态，并支持上下文优先级、
## 运行时重绑定、动作值查询和一次性触发消费。
class_name GFInputMappingUtility
extends GFUtility


# --- 信号 ---

## 启用上下文变化后发出。
signal contexts_changed(contexts: Array)

## 有效映射变化后发出。
signal mappings_changed

## 动作值变化时发出。
signal action_value_changed(action_id: StringName, value: Variant)

## 动作从非活跃变为活跃时发出。
signal action_started(action_id: StringName, value: Variant)

## 动作活跃且收到匹配输入事件时发出。
signal action_triggered(action_id: StringName, value: Variant)

## 动作从活跃变为非活跃时发出。
signal action_completed(action_id: StringName, value: Variant)

## 玩家动作值变化时发出。
signal player_action_value_changed(player_index: int, action_id: StringName, value: Variant)

## 玩家动作从非活跃变为活跃时发出。
signal player_action_started(player_index: int, action_id: StringName, value: Variant)

## 玩家动作活跃且收到匹配输入事件时发出。
signal player_action_triggered(player_index: int, action_id: StringName, value: Variant)

## 玩家动作从活跃变为非活跃时发出。
signal player_action_completed(player_index: int, action_id: StringName, value: Variant)


# --- 常量 ---

const GFInputActionBase = preload("res://addons/gf/input/gf_input_action.gd")
const GFInputBindingBase = preload("res://addons/gf/input/gf_input_binding.gd")
const GFInputContextBase = preload("res://addons/gf/input/gf_input_context.gd")
const GFInputMappingBase = preload("res://addons/gf/input/gf_input_mapping.gd")
const GFInputModifierBase = preload("res://addons/gf/input/gf_input_modifier.gd")
const GFInputRemapConfigBase = preload("res://addons/gf/input/gf_input_remap_config.gd")
const GFInputTriggerBase = preload("res://addons/gf/input/gf_input_trigger.gd")


# --- 私有变量 ---

var _active_contexts: Dictionary = {}
var _effective_entries: Array[Dictionary] = []
var _binding_values: Dictionary = {}
var _binding_to_action: Dictionary = {}
var _player_binding_values: Dictionary = {}
var _player_binding_to_action: Dictionary = {}
var _actions: Dictionary = {}
var _action_modifiers: Dictionary = {}
var _action_triggers: Dictionary = {}
var _action_trigger_states: Dictionary = {}
var _action_values: Dictionary = {}
var _action_active: Dictionary = {}
var _raw_action_active: Dictionary = {}
var _just_started: Dictionary = {}
var _player_action_values: Dictionary = {}
var _player_action_active: Dictionary = {}
var _player_raw_action_active: Dictionary = {}
var _player_trigger_states: Dictionary = {}
var _player_just_started: Dictionary = {}
var _remap_config: GFInputRemapConfigBase
var _timestamp: int = 0
var _router: _GFInputRouter
var _router_attach_serial: int = 0
var _clear_just_started_queued: bool = false
var _just_started_clear_serial: int = 0


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_pause = true
	ignore_time_scale = true
	_clear_runtime_state()
	_ensure_router()


func dispose() -> void:
	_router_attach_serial += 1
	_active_contexts.clear()
	_effective_entries.clear()
	_clear_runtime_state()
	if is_instance_valid(_router):
		_router.queue_free()
	_router = null


## 推进运行时逻辑。
## @param _delta: 本帧时间增量（秒），默认实现不直接使用。
func tick(_delta: float) -> void:
	_refresh_triggered_action_states(_delta)


# --- 公共方法 ---

## 设置重映射配置。
## @param config: 输入重映射配置；传 null 表示使用默认绑定。
func set_remap_config(config: GFInputRemapConfigBase) -> void:
	_remap_config = config
	_rebuild_effective_entries()


## 获取当前重映射配置。若不存在且 create_if_missing 为 true，会自动创建。
## @param create_if_missing: 是否在缺失时创建。
## @return 重映射配置。
func get_remap_config(create_if_missing: bool = false) -> GFInputRemapConfigBase:
	if _remap_config == null and create_if_missing:
		_remap_config = GFInputRemapConfigBase.new()
	return _remap_config


## 启用输入上下文。
## @param context: 输入上下文资源。
## @param priority: 优先级，数值越大越先处理。
func enable_context(context: GFInputContextBase, priority: int = 0) -> void:
	if context == null:
		push_error("[GFInputMappingUtility] enable_context 失败：context 为空。")
		return

	_timestamp += 1
	_active_contexts[context] = {
		"priority": priority,
		"timestamp": _timestamp,
	}
	_rebuild_effective_entries()


## 禁用输入上下文。
## @param context: 输入上下文资源。
func disable_context(context: GFInputContextBase) -> void:
	if context == null:
		return
	_active_contexts.erase(context)
	_rebuild_effective_entries()


## 批量替换当前启用的上下文。
## @param contexts: 输入上下文数组。
## @param priority: 批量上下文默认优先级；数组越靠后，同优先级下越先处理。
func set_enabled_contexts(contexts: Array[GFInputContextBase], priority: int = 0) -> void:
	_active_contexts.clear()
	for context: GFInputContextBase in contexts:
		if context == null:
			continue
		_timestamp += 1
		_active_contexts[context] = {
			"priority": priority,
			"timestamp": _timestamp,
		}
	_rebuild_effective_entries()


## 清空所有启用上下文。
func clear_contexts() -> void:
	_active_contexts.clear()
	_rebuild_effective_entries()


## 检查上下文是否启用。
## @param context: 输入上下文资源。
## @return 是否启用。
func is_context_enabled(context: GFInputContextBase) -> bool:
	return _active_contexts.has(context)


## 获取已启用上下文，按实际处理顺序返回。
## @return 上下文数组。
func get_enabled_contexts() -> Array[GFInputContextBase]:
	return _get_sorted_contexts()


## 手动处理输入事件。通常由内部路由节点自动调用，也可用于测试或自定义输入桥接。
## @param event: Godot 输入事件。
func handle_input_event(event: InputEvent) -> void:
	if event == null or _should_ignore_event(event):
		return

	var player_index := _resolve_player_index(event)
	var event_blocked := false
	for entry: Dictionary in _effective_entries:
		if event_blocked:
			continue

		var matched := _apply_entry_event(entry, event, player_index)
		if not matched:
			continue

		var action := entry["action"] as GFInputActionBase
		var action_id := action.get_action_id()
		var value: Variant = get_action_value(action_id)
		if action.block_lower_priority_actions and is_action_active(action_id):
			event_blocked = true

		if is_action_active(action_id):
			action_triggered.emit(action_id, value)
		if player_index >= 0 and is_action_active_for_player(player_index, action_id):
			player_action_triggered.emit(player_index, action_id, get_action_value_for_player(player_index, action_id))


## 获取动作当前值。
## @param action_id: 动作标识。
## @return bool、float、Vector2 或 Vector3，取决于动作值类型。
func get_action_value(action_id: StringName) -> Variant:
	if _action_values.has(action_id):
		return _action_values[action_id]

	var action := _actions.get(action_id) as GFInputActionBase
	if action == null:
		return null
	return _default_value_for_type(action.value_type)


## 获取动作当前二维向量值。
## @param action_id: 动作标识。
## @return 二维向量值；三维轴会返回 x/y 分量。
func get_action_vector(action_id: StringName) -> Vector2:
	var vector := _calculate_action_vector3(action_id)
	return Vector2(vector.x, vector.y)


## 获取动作当前三维向量值。
## @param action_id: 动作标识。
## @return 三维向量值；非三维动作的 z 分量为 0。
func get_action_vector3(action_id: StringName) -> Vector3:
	return _calculate_action_vector3(action_id)


## 检查动作是否活跃。
## @param action_id: 动作标识。
## @return 是否活跃。
func is_action_active(action_id: StringName) -> bool:
	return bool(_action_active.get(action_id, false))


## 检查动作是否在当前帧刚刚开始。
## @param action_id: 动作标识。
## @return 是否刚开始。
func was_action_just_started(action_id: StringName) -> bool:
	return bool(_just_started.get(action_id, false))


## 消费一次刚开始的动作。
## @param action_id: 动作标识。
## @return 成功消费返回 true。
func consume_action(action_id: StringName) -> bool:
	if not was_action_just_started(action_id):
		return false
	_just_started.erase(action_id)
	return true


## 获取指定玩家动作当前值。
## @param player_index: 玩家索引。
## @param action_id: 动作标识。
## @return bool、float、Vector2 或 Vector3，取决于动作值类型。
func get_action_value_for_player(player_index: int, action_id: StringName) -> Variant:
	var key := _make_player_action_key(player_index, action_id)
	if _player_action_values.has(key):
		return _player_action_values[key]

	var action := _actions.get(action_id) as GFInputActionBase
	if action == null:
		return null
	return _default_value_for_type(action.value_type)


## 获取指定玩家动作当前二维向量值。
## @param player_index: 玩家索引。
## @param action_id: 动作标识。
## @return 二维向量值；三维轴会返回 x/y 分量。
func get_action_vector_for_player(player_index: int, action_id: StringName) -> Vector2:
	var vector := _calculate_player_action_vector3(player_index, action_id)
	return Vector2(vector.x, vector.y)


## 获取指定玩家动作当前三维向量值。
## @param player_index: 玩家索引。
## @param action_id: 动作标识。
## @return 三维向量值；非三维动作的 z 分量为 0。
func get_action_vector3_for_player(player_index: int, action_id: StringName) -> Vector3:
	return _calculate_player_action_vector3(player_index, action_id)


## 检查指定玩家动作是否活跃。
## @param player_index: 玩家索引。
## @param action_id: 动作标识。
## @return 是否活跃。
func is_action_active_for_player(player_index: int, action_id: StringName) -> bool:
	return bool(_player_action_active.get(_make_player_action_key(player_index, action_id), false))


## 检查指定玩家动作是否在当前帧刚刚开始。
## @param player_index: 玩家索引。
## @param action_id: 动作标识。
## @return 是否刚开始。
func was_action_just_started_for_player(player_index: int, action_id: StringName) -> bool:
	return bool(_player_just_started.get(_make_player_action_key(player_index, action_id), false))


## 消费指定玩家的一次刚开始动作。
## @param player_index: 玩家索引。
## @param action_id: 动作标识。
## @return 成功消费返回 true。
func consume_action_for_player(player_index: int, action_id: StringName) -> bool:
	var key := _make_player_action_key(player_index, action_id)
	if not bool(_player_just_started.get(key, false)):
		return false
	_player_just_started.erase(key)
	return true


## 设置某个绑定的运行时覆盖。
## @param context_id: 上下文标识。
## @param action_id: 动作标识。
## @param binding_index: 绑定索引。
## @param input_event: 新输入事件。
func set_binding_override(
	context_id: StringName,
	action_id: StringName,
	binding_index: int,
	input_event: InputEvent
) -> void:
	get_remap_config(true).set_binding(context_id, action_id, binding_index, input_event)
	_rebuild_effective_entries()


## 显式解绑某个绑定。
## @param context_id: 上下文标识。
## @param action_id: 动作标识。
## @param binding_index: 绑定索引。
func unbind(context_id: StringName, action_id: StringName, binding_index: int) -> void:
	get_remap_config(true).unbind(context_id, action_id, binding_index)
	_rebuild_effective_entries()


## 清除某个绑定覆盖。
## @param context_id: 上下文标识。
## @param action_id: 动作标识。
## @param binding_index: 绑定索引。
func clear_binding_override(context_id: StringName, action_id: StringName, binding_index: int) -> void:
	if _remap_config != null:
		_remap_config.clear_binding(context_id, action_id, binding_index)
		_rebuild_effective_entries()


## 获取可重绑条目。
## @param context_filter: 可选上下文过滤。
## @param display_category_filter: 可选显示分类过滤。
## @return 条目字典数组。
func get_remappable_items(
	context_filter: StringName = &"",
	display_category_filter: String = ""
) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for context: GFInputContextBase in _get_sorted_contexts():
		var context_id := context.get_context_id()
		if context_filter != &"" and context_id != context_filter:
			continue

		for mapping: GFInputMappingBase in context.mappings:
			if mapping == null or mapping.action == null or not mapping.action.remappable:
				continue
			if not display_category_filter.is_empty() and mapping.get_display_category() != display_category_filter:
				continue

			for index: int in range(mapping.bindings.size()):
				var binding := mapping.bindings[index]
				if binding == null or not binding.remappable:
					continue
				items.append({
					"context": context,
					"context_id": context_id,
					"mapping": mapping,
					"action": mapping.action,
					"action_id": mapping.get_action_id(),
					"binding": binding,
					"binding_index": index,
					"display_name": mapping.get_display_name(),
					"display_category": mapping.get_display_category(),
					"event": _get_effective_event(context_id, mapping.get_action_id(), index, binding),
				})
	return items


## 清空所有动作运行时状态。
func clear_input_state() -> void:
	_clear_runtime_state(true)


## 清空指定玩家动作运行时状态。
## @param player_index: 玩家索引。
func clear_player_input_state(player_index: int) -> void:
	_clear_player_runtime_state(player_index, true)


# --- 私有/辅助方法 ---

func _ensure_router() -> void:
	if is_instance_valid(_router):
		return

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return

	_router = _GFInputRouter.new()
	_router.name = "GFInputMappingRouter"
	_router.input_callback = Callable(self, "handle_input_event")
	_router.focus_lost_callback = Callable(self, "clear_input_state")
	_router_attach_serial += 1
	call_deferred("_attach_router_to_root", _router, _router_attach_serial)


func _attach_router_to_root(router_variant: Variant, attach_serial: int) -> void:
	var router := router_variant as Node
	if attach_serial != _router_attach_serial or router != _router:
		if is_instance_valid(router):
			router.queue_free()
		return

	if (not is_instance_valid(router)
		or router.is_queued_for_deletion()
		or router.is_inside_tree()
	):
		return

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		_router = null
		router.queue_free()
		return

	tree.root.add_child(router)


func _rebuild_effective_entries() -> void:
	_clear_runtime_state(true)
	_effective_entries.clear()
	_actions.clear()
	_action_modifiers.clear()
	_action_triggers.clear()

	for context: GFInputContextBase in _get_sorted_contexts():
		var context_id := context.get_context_id()
		if context_id == &"":
			continue

		for mapping: GFInputMappingBase in context.mappings:
			if mapping == null or mapping.action == null:
				continue

			var action_id := mapping.get_action_id()
			if action_id == &"":
				continue

			var bindings: Array[Dictionary] = []
			for index: int in range(mapping.bindings.size()):
				var base_binding := mapping.bindings[index]
				if base_binding == null:
					continue

				var binding := base_binding.duplicate_binding() as GFInputBindingBase
				if binding == null:
					continue
				if _remap_config != null and _remap_config.has_binding(context_id, action_id, index):
					var override_event := _remap_config.get_bound_event_or_null(context_id, action_id, index)
					if override_event == null:
						continue
					binding.input_event = override_event.duplicate(true) as InputEvent

				bindings.append({
					"binding": binding,
					"key": _make_binding_key(context_id, action_id, index),
				})

			_actions[action_id] = mapping.action
			_action_modifiers[action_id] = _duplicate_modifiers(mapping.modifiers)
			_action_triggers[action_id] = _duplicate_triggers(mapping.triggers)
			_effective_entries.append({
				"context": context,
				"mapping": mapping,
				"action": mapping.action,
				"action_id": action_id,
				"bindings": bindings,
			})

	contexts_changed.emit(get_enabled_contexts())
	mappings_changed.emit()


func _get_sorted_contexts() -> Array[GFInputContextBase]:
	var contexts: Array[GFInputContextBase] = []
	for context_variant: Variant in _active_contexts.keys():
		var context := context_variant as GFInputContextBase
		if context != null:
			contexts.append(context)

	contexts.sort_custom(func(left: GFInputContextBase, right: GFInputContextBase) -> bool:
		var left_meta := _active_contexts[left] as Dictionary
		var right_meta := _active_contexts[right] as Dictionary
		var left_priority := int(left_meta.get("priority", 0))
		var right_priority := int(right_meta.get("priority", 0))
		if left_priority != right_priority:
			return left_priority > right_priority
		return int(left_meta.get("timestamp", 0)) > int(right_meta.get("timestamp", 0))
	)
	return contexts


func _apply_entry_event(entry: Dictionary, event: InputEvent, player_index: int) -> bool:
	var matched := false
	var action := entry["action"] as GFInputActionBase
	var action_id := entry["action_id"] as StringName
	for binding_info: Dictionary in entry["bindings"]:
		var binding := binding_info["binding"] as GFInputBindingBase
		if binding == null or not binding.matches_event(event):
			continue

		var key := _make_source_binding_key(String(binding_info["key"]), event)
		var contribution := binding.get_contribution(event, action.value_type, _get_player_deadzone(player_index))
		_binding_values[key] = contribution
		_binding_to_action[key] = action_id
		if player_index >= 0:
			var player_binding_key := _make_player_binding_key(player_index, String(binding_info["key"]))
			_player_binding_values[player_binding_key] = contribution
			_player_binding_to_action[player_binding_key] = action_id
		matched = true

	if matched:
		_refresh_action_state(action_id, action)
		if player_index >= 0:
			_refresh_player_action_state(player_index, action_id, action)

	return matched


func _refresh_action_state(action_id: StringName, action: GFInputActionBase) -> void:
	var previous_value: Variant = _action_values.get(action_id, _default_value_for_type(action.value_type))
	var previous_active := bool(_action_active.get(action_id, false))
	var next_value: Variant = _calculate_action_value(action_id, action.value_type)
	var raw_active := _is_value_active(next_value, action)
	var next_active := _evaluate_action_triggers(action_id, raw_active, next_value, 0.0)

	_action_values[action_id] = next_value
	_action_active[action_id] = next_active
	_raw_action_active[action_id] = raw_active

	if not _values_equal(previous_value, next_value):
		action_value_changed.emit(action_id, next_value)

	if not previous_active and next_active:
		_just_started[action_id] = true
		_queue_clear_just_started_after_frame()
		action_started.emit(action_id, next_value)
	elif previous_active and not next_active:
		action_completed.emit(action_id, next_value)


func _calculate_action_vector3(action_id: StringName) -> Vector3:
	var total := Vector3.ZERO
	for key: String in _binding_values.keys():
		if _binding_to_action.get(key) == action_id:
			total += _binding_values[key] as Vector3
	if total.length() > 1.0:
		total = total.normalized()
	return _apply_mapping_modifiers(action_id, total)


func _calculate_player_action_vector3(player_index: int, action_id: StringName) -> Vector3:
	var total := Vector3.ZERO
	var prefix := "%d/" % player_index
	for key: String in _player_binding_values.keys():
		if not key.begins_with(prefix):
			continue
		if _player_binding_to_action.get(key) == action_id:
			total += _player_binding_values[key] as Vector3
	if total.length() > 1.0:
		total = total.normalized()
	return _apply_mapping_modifiers(action_id, total)


func _calculate_action_value(action_id: StringName, value_type: GFInputActionBase.ValueType) -> Variant:
	var vector := _calculate_action_vector3(action_id)
	return _calculate_value_from_vector(vector, value_type)


func _calculate_player_action_value(
	player_index: int,
	action_id: StringName,
	value_type: GFInputActionBase.ValueType
) -> Variant:
	var vector := _calculate_player_action_vector3(player_index, action_id)
	return _calculate_value_from_vector(vector, value_type)


func _calculate_value_from_vector(vector: Vector3, value_type: GFInputActionBase.ValueType) -> Variant:
	match value_type:
		GFInputActionBase.ValueType.BOOL:
			return vector.length() > 0.0
		GFInputActionBase.ValueType.AXIS_1D:
			return clampf(vector.x, -1.0, 1.0)
		GFInputActionBase.ValueType.AXIS_2D:
			return Vector2(vector.x, vector.y)
		GFInputActionBase.ValueType.AXIS_3D:
			return vector
		_:
			return null


func _default_value_for_type(value_type: GFInputActionBase.ValueType) -> Variant:
	match value_type:
		GFInputActionBase.ValueType.BOOL:
			return false
		GFInputActionBase.ValueType.AXIS_1D:
			return 0.0
		GFInputActionBase.ValueType.AXIS_2D:
			return Vector2.ZERO
		GFInputActionBase.ValueType.AXIS_3D:
			return Vector3.ZERO
		_:
			return null


func _is_value_active(value: Variant, action: GFInputActionBase) -> bool:
	match action.value_type:
		GFInputActionBase.ValueType.BOOL:
			return bool(value)
		GFInputActionBase.ValueType.AXIS_1D:
			return absf(float(value)) >= action.activation_threshold
		GFInputActionBase.ValueType.AXIS_2D:
			return (value as Vector2).length() >= action.activation_threshold
		GFInputActionBase.ValueType.AXIS_3D:
			return (value as Vector3).length() >= action.activation_threshold
		_:
			return false


func _values_equal(left: Variant, right: Variant) -> bool:
	if left is float or right is float:
		return is_equal_approx(float(left), float(right))
	if left is Vector2 and right is Vector2:
		return (left as Vector2).is_equal_approx(right as Vector2)
	if left is Vector3 and right is Vector3:
		return (left as Vector3).is_equal_approx(right as Vector3)
	return left == right


func _queue_clear_just_started_after_frame() -> void:
	if _clear_just_started_queued:
		return

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return

	_clear_just_started_queued = true
	_clear_just_started_after_frame(_just_started_clear_serial)


func _clear_just_started_after_frame(clear_serial: int) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return

	await tree.process_frame
	if clear_serial != _just_started_clear_serial:
		return
	_just_started.clear()
	_player_just_started.clear()
	_clear_just_started_queued = false


func _clear_runtime_state(emit_completed: bool = false) -> void:
	if emit_completed:
		for action_id: StringName in _action_active.keys():
			if bool(_action_active[action_id]) and _actions.has(action_id):
				var action := _actions[action_id] as GFInputActionBase
				action_completed.emit(action_id, _default_value_for_type(action.value_type))
		for player_action_key: String in _player_action_active.keys():
			if not bool(_player_action_active[player_action_key]):
				continue
			var parts := player_action_key.split("/", false, 1)
			if parts.size() != 2:
				continue
			var player_index := int(parts[0])
			var action_id := StringName(parts[1])
			var action := _actions.get(action_id) as GFInputActionBase
			if action != null:
				player_action_completed.emit(player_index, action_id, _default_value_for_type(action.value_type))

	_binding_values.clear()
	_binding_to_action.clear()
	_player_binding_values.clear()
	_player_binding_to_action.clear()
	_action_values.clear()
	_action_active.clear()
	_raw_action_active.clear()
	_just_started.clear()
	_player_action_values.clear()
	_player_action_active.clear()
	_player_raw_action_active.clear()
	_player_just_started.clear()
	_clear_just_started_queued = false
	_just_started_clear_serial += 1
	_reset_all_trigger_states()


func _clear_player_runtime_state(player_index: int, emit_completed: bool = false) -> void:
	var prefix := "%d/" % player_index
	if emit_completed:
		for player_action_key: String in _player_action_active.keys():
			if not player_action_key.begins_with(prefix):
				continue
			if not bool(_player_action_active[player_action_key]):
				continue
			var action_id := StringName(player_action_key.trim_prefix(prefix))
			var action := _actions.get(action_id) as GFInputActionBase
			if action != null:
				player_action_completed.emit(player_index, action_id, _default_value_for_type(action.value_type))

	for key: String in _player_binding_values.keys():
		if key.begins_with(prefix):
			_player_binding_values.erase(key)
			_player_binding_to_action.erase(key)
	for key: String in _player_action_values.keys():
		if key.begins_with(prefix):
			_player_action_values.erase(key)
			_player_action_active.erase(key)
			_player_raw_action_active.erase(key)
			_player_trigger_states.erase(key)
			_player_just_started.erase(key)


func _get_effective_event(
	context_id: StringName,
	action_id: StringName,
	binding_index: int,
	binding: GFInputBindingBase
) -> InputEvent:
	if _remap_config != null and _remap_config.has_binding(context_id, action_id, binding_index):
		return _remap_config.get_bound_event_or_null(context_id, action_id, binding_index)
	return binding.input_event


func _make_binding_key(context_id: StringName, action_id: StringName, binding_index: int) -> String:
	return "%s/%s/%d" % [String(context_id), String(action_id), binding_index]


func _make_player_binding_key(player_index: int, binding_key: String) -> String:
	return "%d/%s" % [player_index, binding_key]


func _make_source_binding_key(binding_key: String, event: InputEvent) -> String:
	return "%s@%s" % [binding_key, _make_event_source_key(event)]


func _make_player_action_key(player_index: int, action_id: StringName) -> String:
	return "%d/%s" % [player_index, String(action_id)]


func _should_ignore_event(event: InputEvent) -> bool:
	return event is InputEventKey and (event as InputEventKey).echo


func _make_event_source_key(event: InputEvent) -> String:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return "joypad:%d" % event.device
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return "touch:%d" % event.device
	return "keyboard_mouse"


func _refresh_player_action_state(
	player_index: int,
	action_id: StringName,
	action: GFInputActionBase
) -> void:
	var key := _make_player_action_key(player_index, action_id)
	var previous_value: Variant = _player_action_values.get(key, _default_value_for_type(action.value_type))
	var previous_active := bool(_player_action_active.get(key, false))
	var next_value: Variant = _calculate_player_action_value(player_index, action_id, action.value_type)
	var raw_active := _is_value_active(next_value, action)
	var next_active := _evaluate_player_action_triggers(player_index, action_id, raw_active, next_value, 0.0)

	_player_action_values[key] = next_value
	_player_action_active[key] = next_active
	_player_raw_action_active[key] = raw_active

	if not _values_equal(previous_value, next_value):
		player_action_value_changed.emit(player_index, action_id, next_value)

	if not previous_active and next_active:
		_player_just_started[key] = true
		_queue_clear_just_started_after_frame()
		player_action_started.emit(player_index, action_id, next_value)
	elif previous_active and not next_active:
		player_action_completed.emit(player_index, action_id, next_value)


func _resolve_player_index(event: InputEvent) -> int:
	var devices := _get_input_device_utility()
	if devices == null:
		return -1
	return devices.handle_input_event(event)


func _get_player_deadzone(player_index: int) -> float:
	if player_index < 0:
		return -1.0

	var devices := _get_input_device_utility()
	if devices == null:
		return -1.0
	return devices.get_player_deadzone(player_index, -1.0)


func _refresh_triggered_action_states(delta: float) -> void:
	if _action_triggers.is_empty():
		return

	for action_id_variant: Variant in _action_triggers.keys():
		var action_id := action_id_variant as StringName
		var triggers := _action_triggers.get(action_id, []) as Array
		if triggers.is_empty():
			continue
		var action := _actions.get(action_id) as GFInputActionBase
		if action == null:
			continue
		var value: Variant = _action_values.get(action_id, _default_value_for_type(action.value_type))
		var raw_active := bool(_raw_action_active.get(action_id, false))
		_set_action_active_from_triggers(action_id, action, value, raw_active, delta)

	for player_key_variant: Variant in _player_raw_action_active.keys():
		var player_key := String(player_key_variant)
		var parts := player_key.split("/", false, 1)
		if parts.size() != 2:
			continue
		var player_index := int(parts[0])
		var action_id := StringName(parts[1])
		var action := _actions.get(action_id) as GFInputActionBase
		if action == null:
			continue
		var value: Variant = _player_action_values.get(player_key, _default_value_for_type(action.value_type))
		var raw_active := bool(_player_raw_action_active.get(player_key, false))
		_set_player_action_active_from_triggers(player_index, action_id, action, value, raw_active, delta)


func _set_action_active_from_triggers(
	action_id: StringName,
	action: GFInputActionBase,
	value: Variant,
	raw_active: bool,
	delta: float
) -> void:
	var previous_active := bool(_action_active.get(action_id, false))
	var next_active := _evaluate_action_triggers(action_id, raw_active, value, delta)
	_action_active[action_id] = next_active
	if not previous_active and next_active:
		_just_started[action_id] = true
		_queue_clear_just_started_after_frame()
		action_started.emit(action_id, value)
	elif previous_active and not next_active:
		action_completed.emit(action_id, _default_value_for_type(action.value_type))


func _set_player_action_active_from_triggers(
	player_index: int,
	action_id: StringName,
	action: GFInputActionBase,
	value: Variant,
	raw_active: bool,
	delta: float
) -> void:
	var key := _make_player_action_key(player_index, action_id)
	var previous_active := bool(_player_action_active.get(key, false))
	var next_active := _evaluate_player_action_triggers(player_index, action_id, raw_active, value, delta)
	_player_action_active[key] = next_active
	if not previous_active and next_active:
		_player_just_started[key] = true
		_queue_clear_just_started_after_frame()
		player_action_started.emit(player_index, action_id, value)
	elif previous_active and not next_active:
		player_action_completed.emit(player_index, action_id, _default_value_for_type(action.value_type))


func _evaluate_action_triggers(
	action_id: StringName,
	raw_active: bool,
	value: Variant,
	delta: float
) -> bool:
	return _evaluate_triggers(
		action_id,
		-1,
		_action_triggers.get(action_id, []) as Array,
		_get_action_trigger_states(action_id),
		raw_active,
		value,
		delta
	)


func _evaluate_player_action_triggers(
	player_index: int,
	action_id: StringName,
	raw_active: bool,
	value: Variant,
	delta: float
) -> bool:
	var key := _make_player_action_key(player_index, action_id)
	return _evaluate_triggers(
		action_id,
		player_index,
		_action_triggers.get(action_id, []) as Array,
		_get_player_trigger_states(key),
		raw_active,
		value,
		delta
	)


func _evaluate_triggers(
	action_id: StringName,
	player_index: int,
	triggers: Array,
	states: Array[Dictionary],
	raw_active: bool,
	value: Variant,
	delta: float
) -> bool:
	if triggers.is_empty():
		return raw_active

	var any_ongoing := false
	for index: int in range(triggers.size()):
		var trigger := triggers[index] as GFInputTriggerBase
		if trigger == null:
			continue
		while states.size() <= index:
			states.append({})
		var state := states[index]
		trigger.prepare_runtime(action_id, self, player_index, state)
		var trigger_state: int = trigger.update(raw_active, value, delta, state)
		if trigger_state == GFInputTriggerBase.TriggerState.INACTIVE:
			return false
		if trigger_state == GFInputTriggerBase.TriggerState.ONGOING:
			any_ongoing = true

	return not any_ongoing


func _get_action_trigger_states(action_id: StringName) -> Array[Dictionary]:
	if not _action_trigger_states.has(action_id):
		var states: Array[Dictionary] = []
		_action_trigger_states[action_id] = states
	return _action_trigger_states[action_id] as Array[Dictionary]


func _get_player_trigger_states(player_action_key: String) -> Array[Dictionary]:
	if not _player_trigger_states.has(player_action_key):
		var states: Array[Dictionary] = []
		_player_trigger_states[player_action_key] = states
	return _player_trigger_states[player_action_key] as Array[Dictionary]


func _reset_all_trigger_states() -> void:
	_action_trigger_states.clear()
	_player_trigger_states.clear()


func _apply_mapping_modifiers(action_id: StringName, value: Vector3) -> Vector3:
	var modifiers := _action_modifiers.get(action_id, []) as Array
	var action := _actions.get(action_id) as GFInputActionBase
	var result := value
	for modifier: GFInputModifierBase in modifiers:
		if modifier != null:
			if action != null and action.value_type == GFInputActionBase.ValueType.AXIS_3D:
				result = modifier.modify_3d(result, null, action)
			else:
				var modified := modifier.modify(Vector2(result.x, result.y), null, action)
				result = Vector3(modified.x, modified.y, result.z)
	return result


func _duplicate_modifiers(modifiers: Array[GFInputModifierBase]) -> Array[GFInputModifierBase]:
	var result: Array[GFInputModifierBase] = []
	for modifier: GFInputModifierBase in modifiers:
		if modifier == null:
			continue
		var duplicate_modifier := modifier.duplicate_modifier()
		if duplicate_modifier != null:
			result.append(duplicate_modifier)
	return result


func _duplicate_triggers(triggers: Array[GFInputTriggerBase]) -> Array[GFInputTriggerBase]:
	var result: Array[GFInputTriggerBase] = []
	for trigger: GFInputTriggerBase in triggers:
		if trigger == null:
			continue
		var duplicate_trigger := trigger.duplicate_trigger()
		if duplicate_trigger != null:
			result.append(duplicate_trigger)
	return result


func _get_input_device_utility() -> GFInputDeviceUtility:
	var arch := _get_architecture_or_null()
	if arch == null:
		return null
	return arch.get_utility(GFInputDeviceUtility) as GFInputDeviceUtility


class _GFInputRouter extends Node:
	var input_callback: Callable
	var focus_lost_callback: Callable

	func _init() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS


	func _input(event: InputEvent) -> void:
		if input_callback.is_valid():
			input_callback.call(event)


	func _notification(what: int) -> void:
		if what == NOTIFICATION_APPLICATION_FOCUS_OUT and focus_lost_callback.is_valid():
			focus_lost_callback.call()
