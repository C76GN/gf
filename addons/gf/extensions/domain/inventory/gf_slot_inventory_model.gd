## GFSlotInventoryModel: 通用可序列化槽位库存模型。
##
## 管理固定或可增长槽位中的 `GFInventoryStack`，支持堆叠容量、
## 最大堆叠数量、实例数据兼容性、移动、交换和序列化。
class_name GFSlotInventoryModel
extends GFModel


# --- 信号 ---

## 任意槽位变化时发出。
signal slot_changed(slot_index: int)

## 物品加入槽位后发出。
signal item_added(slot_index: int, item_id: StringName, amount: int)

## 物品从槽位移除后发出。
signal item_removed(slot_index: int, item_id: StringName, amount: int)

## 库存整体发生变化时发出。
signal inventory_changed


# --- 公共变量 ---

## 可选物品定义注册表。
var registry: GFInventoryItemRegistry = null

## 是否允许库存在创建新堆叠时自动增长。
## 为 false 时，0 槽位库存不会接收 `add_item()` 的新堆叠。
var allow_growth: bool = false

## 默认初始槽位数量。仅在 GF 生命周期调用 `init()` 时自动应用。
## 手动创建后直接使用时，应调用 `set_slot_count()` 或启用 `allow_growth`。
var default_slot_count: int = 0


# --- 私有变量 ---

var _slots: Array = []
var _item_slot_index: Dictionary = {}
var _index_dirty: bool = true


# --- Godot 生命周期方法 ---

func init() -> void:
	if _slots.is_empty() and default_slot_count > 0:
		set_slot_count(default_slot_count)


# --- 公共方法 ---

## 设置物品注册表。
## @param item_registry: 物品注册表。
func set_registry(item_registry: GFInventoryItemRegistry) -> void:
	registry = item_registry
	_mark_index_dirty()


## 设置槽位数量。
## @param count: 新槽位数量。
## @param preserve_existing: 是否保留已有槽位内容。
func set_slot_count(count: int, preserve_existing: bool = true) -> void:
	var next_count := maxi(count, 0)
	var next_slots: Array = []
	for index: int in range(next_count):
		if preserve_existing and index < _slots.size():
			next_slots.append(_slots[index])
		else:
			next_slots.append(null)
	_slots = next_slots
	_mark_index_dirty()
	inventory_changed.emit()


## 获取槽位数量。
## @return 槽位数量。
func get_slot_count() -> int:
	return _slots.size()


## 检查槽位索引是否有效。
## @param slot_index: 槽位索引。
## @return 有效返回 true。
func is_valid_slot(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < _slots.size()


## 获取槽位堆叠副本。
## @param slot_index: 槽位索引。
## @return 堆叠副本；空槽或无效槽位返回 null。
func get_stack(slot_index: int) -> GFInventoryStack:
	var stack := _get_stack_ref(slot_index)
	return stack.duplicate_stack() if stack != null else null


## 获取槽位堆叠字典。
## @param slot_index: 槽位索引。
## @return 堆叠字典；空槽或无效槽位返回空字典。
func get_stack_data(slot_index: int) -> Dictionary:
	var stack := _get_stack_ref(slot_index)
	return stack.to_dict() if stack != null else {}


## 检查槽位是否为空。
## @param slot_index: 槽位索引。
## @return 空槽位返回 true。
func is_slot_empty(slot_index: int) -> bool:
	var stack := _get_stack_ref(slot_index)
	return stack == null or stack.is_empty()


## 设置指定槽位堆叠。
## @param slot_index: 槽位索引。
## @param stack: 堆叠；传 null 表示清空。
## @return 成功返回 true。
func set_stack(slot_index: int, stack: GFInventoryStack) -> bool:
	if not is_valid_slot(slot_index):
		return false
	_slots[slot_index] = stack.duplicate_stack() if stack != null and not stack.is_empty() else null
	_emit_slot_changed(slot_index)
	return true


## 清空指定槽位。
## @param slot_index: 槽位索引。
## @return 成功返回 true。
func clear_slot(slot_index: int) -> bool:
	if not is_valid_slot(slot_index):
		return false
	_slots[slot_index] = null
	_emit_slot_changed(slot_index)
	return true


## 清空全部槽位内容。
func clear() -> void:
	for index: int in range(_slots.size()):
		_slots[index] = null
	_mark_index_dirty()
	inventory_changed.emit()


## 添加物品到库存。
## @param item_id: 物品标识。
## @param amount: 添加数量。
## @param instance_data: 实例数据。
## @param start_slot: 起始槽位；小于 0 时从头开始。
## @param partial_add: 容量不足时是否允许部分加入。
## @return 操作结果。
func add_item(
	item_id: StringName,
	amount: int = 1,
	instance_data: Dictionary = {},
	start_slot: int = -1,
	partial_add: bool = true
) -> GFInventoryOperationResult:
	if item_id == &"" or amount <= 0:
		return GFInventoryOperationResult.partial(item_id, amount, 0, &"invalid_request")
	if not _accepts_item(item_id):
		return GFInventoryOperationResult.partial(item_id, amount, 0, &"item_not_registered")
	if not partial_add and get_remaining_capacity_for_item(item_id, instance_data) < amount:
		return GFInventoryOperationResult.partial(item_id, amount, 0, &"not_enough_space")

	var normalized_data := _normalize_instance_data(item_id, instance_data)
	var remaining := amount
	for slot_index: int in _ordered_slot_indices(start_slot):
		remaining = _try_add_to_existing_stack(slot_index, item_id, remaining, normalized_data)
		if remaining <= 0:
			return GFInventoryOperationResult.success(item_id, amount)

	while remaining > 0 and (_has_empty_slot() or allow_growth):
		if not _can_create_new_stack(item_id):
			break
		var empty_slot := _find_empty_slot()
		if empty_slot == -1 and allow_growth:
			_slots.append(null)
			empty_slot = _slots.size() - 1
		if empty_slot == -1:
			break
		remaining = _try_add_to_empty_slot(empty_slot, item_id, remaining, normalized_data)

	var accepted := amount - remaining
	var reason := &"ok" if remaining <= 0 else &"not_enough_space"
	return GFInventoryOperationResult.partial(item_id, amount, accepted, reason)


## 添加物品到指定槽位。
## @param slot_index: 槽位索引。
## @param item_id: 物品标识。
## @param amount: 添加数量。
## @param instance_data: 实例数据。
## @return 操作结果。
func add_item_to_slot(
	slot_index: int,
	item_id: StringName,
	amount: int = 1,
	instance_data: Dictionary = {}
) -> GFInventoryOperationResult:
	if not is_valid_slot(slot_index):
		return GFInventoryOperationResult.partial(item_id, amount, 0, &"invalid_slot", -1, slot_index)
	if item_id == &"" or amount <= 0 or not _accepts_item(item_id):
		return GFInventoryOperationResult.partial(item_id, amount, 0, &"invalid_request", -1, slot_index)

	var normalized_data := _normalize_instance_data(item_id, instance_data)
	var stack := _get_stack_ref(slot_index)
	var remaining := amount
	if stack == null:
		if not _can_create_new_stack(item_id):
			return GFInventoryOperationResult.partial(item_id, amount, 0, &"stack_count_limit", -1, slot_index)
		remaining = _try_add_to_empty_slot(slot_index, item_id, remaining, normalized_data)
	elif stack.can_merge(item_id, normalized_data, registry):
		remaining = _try_add_to_existing_stack(slot_index, item_id, remaining, normalized_data)
	else:
		return GFInventoryOperationResult.partial(item_id, amount, 0, &"incompatible_stack", -1, slot_index)

	return GFInventoryOperationResult.partial(item_id, amount, amount - remaining, &"ok", -1, slot_index)


## 从库存移除物品。
## @param item_id: 物品标识。
## @param amount: 移除数量。
## @param instance_data: 实例数据。
## @param start_slot: 起始槽位；小于 0 时从头开始。
## @param partial_remove: 数量不足时是否允许部分移除。
## @return 操作结果。
func remove_item(
	item_id: StringName,
	amount: int = 1,
	instance_data: Dictionary = {},
	start_slot: int = -1,
	partial_remove: bool = true
) -> GFInventoryOperationResult:
	if item_id == &"" or amount <= 0:
		return GFInventoryOperationResult.partial(item_id, amount, 0, &"invalid_request")
	var normalized_data := _normalize_instance_data(item_id, instance_data)
	if not partial_remove and get_item_total(item_id, normalized_data) < amount:
		return GFInventoryOperationResult.partial(item_id, amount, 0, &"not_enough_items")

	var remaining := amount
	for slot_index: int in _ordered_slot_indices(start_slot):
		var stack := _get_stack_ref(slot_index)
		if stack == null or not stack.can_merge(item_id, normalized_data, registry):
			continue
		var removed := stack.remove_amount(remaining)
		remaining -= removed
		if removed > 0:
			item_removed.emit(slot_index, item_id, removed)
			if stack.is_empty():
				_slots[slot_index] = null
			_emit_slot_changed(slot_index)
		if remaining <= 0:
			return GFInventoryOperationResult.success(item_id, amount)

	var accepted := amount - remaining
	var reason := &"ok" if remaining <= 0 else &"not_enough_items"
	return GFInventoryOperationResult.partial(item_id, amount, accepted, reason)


## 从指定槽位移除物品。
## @param slot_index: 槽位索引。
## @param amount: 移除数量。
## @return 操作结果。
func remove_item_from_slot(slot_index: int, amount: int = 1) -> GFInventoryOperationResult:
	var stack := _get_stack_ref(slot_index)
	if stack == null or amount <= 0:
		return GFInventoryOperationResult.partial(&"", amount, 0, &"invalid_slot", slot_index)
	var item_id := stack.item_id
	var removed := stack.remove_amount(amount)
	if stack.is_empty():
		_slots[slot_index] = null
	if removed > 0:
		item_removed.emit(slot_index, item_id, removed)
		_emit_slot_changed(slot_index)
	return GFInventoryOperationResult.partial(item_id, amount, removed, &"ok", slot_index)


## 交换两个槽位内容。
## @param first_slot: 第一个槽位。
## @param second_slot: 第二个槽位。
## @return 成功返回 true。
func swap_slots(first_slot: int, second_slot: int) -> bool:
	if not is_valid_slot(first_slot) or not is_valid_slot(second_slot):
		return false
	if first_slot == second_slot:
		return true
	var first_stack: Variant = _slots[first_slot]
	_slots[first_slot] = _slots[second_slot]
	_slots[second_slot] = first_stack
	_emit_slot_changed(first_slot)
	_emit_slot_changed(second_slot)
	return true


## 移动一个槽位的内容到另一个槽位，目标为空时移动，兼容时合并。
## @param source_slot: 源槽位。
## @param target_slot: 目标槽位。
## @param amount: 移动数量；小于等于 0 时移动全部。
## @return 操作结果。
func move_between_slots(source_slot: int, target_slot: int, amount: int = 0) -> GFInventoryOperationResult:
	var source_stack := _get_stack_ref(source_slot)
	if source_stack == null or not is_valid_slot(target_slot):
		return GFInventoryOperationResult.partial(&"", amount, 0, &"invalid_slot", source_slot, target_slot)

	var move_amount := source_stack.amount if amount <= 0 else mini(amount, source_stack.amount)
	var target_stack := _get_stack_ref(target_slot)
	if target_stack == null:
		if source_stack.amount > move_amount and not _can_create_new_stack(source_stack.item_id):
			return GFInventoryOperationResult.partial(source_stack.item_id, move_amount, 0, &"stack_count_limit", source_slot, target_slot)
		var moved_stack := source_stack.duplicate_stack()
		moved_stack.amount = move_amount
		_slots[target_slot] = moved_stack
		source_stack.remove_amount(move_amount)
		if source_stack.is_empty():
			_slots[source_slot] = null
		_emit_slot_changed(source_slot)
		_emit_slot_changed(target_slot)
		return GFInventoryOperationResult.success(moved_stack.item_id, move_amount, source_slot, target_slot)

	if not target_stack.can_merge(source_stack.item_id, source_stack.instance_data, registry):
		return GFInventoryOperationResult.partial(source_stack.item_id, move_amount, 0, &"incompatible_stack", source_slot, target_slot)

	var accepted := mini(move_amount, target_stack.get_available_space(registry))
	if accepted <= 0:
		return GFInventoryOperationResult.partial(source_stack.item_id, move_amount, 0, &"not_enough_space", source_slot, target_slot)
	target_stack.amount += accepted
	source_stack.remove_amount(accepted)
	if source_stack.is_empty():
		_slots[source_slot] = null
	_emit_slot_changed(source_slot)
	_emit_slot_changed(target_slot)
	return GFInventoryOperationResult.partial(target_stack.item_id, move_amount, accepted, &"ok", source_slot, target_slot)


## 获取指定物品总数量。
## @param item_id: 物品标识。
## @param instance_data: 实例数据。为空时统计全部同 ID 物品。
## @return 总数量。
func get_item_total(item_id: StringName, instance_data: Dictionary = {}) -> int:
	var total := 0
	var filter_by_instance := not instance_data.is_empty()
	var normalized_data := _normalize_instance_data(item_id, instance_data)
	for stack_variant: Variant in _slots:
		var stack := stack_variant as GFInventoryStack
		if stack == null or stack.item_id != item_id:
			continue
		if filter_by_instance and not stack.can_merge(item_id, normalized_data, registry):
			continue
		total += stack.amount
	return total


## 检查是否拥有足够数量。
## @param item_id: 物品标识。
## @param amount: 需要数量。
## @param instance_data: 实例数据。
## @return 数量足够返回 true。
func has_item(item_id: StringName, amount: int = 1, instance_data: Dictionary = {}) -> bool:
	return get_item_total(item_id, instance_data) >= amount


## 获取指定物品剩余可加入容量。
## @param item_id: 物品标识。
## @param instance_data: 实例数据。
## @return 剩余容量。
func get_remaining_capacity_for_item(item_id: StringName, instance_data: Dictionary = {}) -> int:
	if not _accepts_item(item_id):
		return 0
	var normalized_data := _normalize_instance_data(item_id, instance_data)
	var capacity := 0
	for stack_variant: Variant in _slots:
		var stack := stack_variant as GFInventoryStack
		if stack == null:
			continue
		if stack.can_merge(item_id, normalized_data, registry):
			capacity += stack.get_available_space(registry)

	var max_stack_count := _get_max_stack_count(item_id)
	var current_stack_count := _get_stack_count_for_item(item_id)
	var free_stack_slots := _get_empty_slot_count()
	if allow_growth and max_stack_count <= 0:
		return capacity + 2147483647
	if max_stack_count > 0:
		var remaining_stack_slots := maxi(max_stack_count - current_stack_count, 0)
		free_stack_slots = remaining_stack_slots if allow_growth else mini(free_stack_slots, remaining_stack_slots)
	capacity += free_stack_slots * _get_max_stack_amount(item_id)
	return capacity


## 获取空槽位索引。
## @return 空槽位索引数组。
func get_empty_slot_indices() -> PackedInt32Array:
	var result := PackedInt32Array()
	for index: int in range(_slots.size()):
		if is_slot_empty(index):
			result.append(index)
	return result


## 获取已占用槽位索引。
## @return 已占用槽位索引数组。
func get_occupied_slot_indices() -> PackedInt32Array:
	var result := PackedInt32Array()
	for index: int in range(_slots.size()):
		if not is_slot_empty(index):
			result.append(index)
	return result


## 获取指定物品所在槽位索引。
## @param item_id: 物品标识。
## @param instance_data: 实例数据。为空时返回全部同 ID 槽位。
## @return 槽位索引列表。
func get_slots_for_item(item_id: StringName, instance_data: Dictionary = {}) -> PackedInt32Array:
	_rebuild_index_if_needed()
	var result := PackedInt32Array()
	var raw_indices := _item_slot_index.get(item_id, PackedInt32Array()) as PackedInt32Array
	if raw_indices == null:
		return result
	var filter_by_instance := not instance_data.is_empty()
	var normalized_data := _normalize_instance_data(item_id, instance_data)
	for slot_index: int in raw_indices:
		var stack := _get_stack_ref(slot_index)
		if stack == null:
			continue
		if filter_by_instance and not stack.can_merge(item_id, normalized_data, registry):
			continue
		result.append(slot_index)
	return result


## 立即重建物品到槽位的索引。
func rebuild_index() -> void:
	_item_slot_index.clear()
	for index: int in range(_slots.size()):
		var stack := _get_stack_ref(index)
		if stack == null or stack.is_empty():
			continue
		if not _item_slot_index.has(stack.item_id):
			_item_slot_index[stack.item_id] = PackedInt32Array()
		var indices := _item_slot_index[stack.item_id] as PackedInt32Array
		indices.append(index)
		_item_slot_index[stack.item_id] = indices
	_index_dirty = false


## 获取索引调试快照。
## @return 索引快照字典。
func get_index_debug_snapshot() -> Dictionary:
	_rebuild_index_if_needed()
	var item_counts: Dictionary = {}
	for item_id: StringName in _item_slot_index.keys():
		item_counts[String(item_id)] = (_item_slot_index[item_id] as PackedInt32Array).size()
	return {
		"dirty": _index_dirty,
		"item_count": _item_slot_index.size(),
		"items": item_counts,
	}


## 校验当前库存内容是否满足注册表约束。
## @return 校验报告字典。
func validate_inventory() -> Dictionary:
	var report := _make_validation_report()
	var stack_counts: Dictionary = {}
	for index: int in range(_slots.size()):
		var stack := _get_stack_ref(index)
		if stack == null:
			continue
		if stack.is_empty():
			_add_validation_issue(report, "warning", "empty_stack", index, stack.item_id, "槽位中存在空堆叠。")
			continue
		if not _accepts_item(stack.item_id):
			_add_validation_issue(report, "error", "unregistered_item", index, stack.item_id, "物品未被注册表接受。")
		var stack_limit := _get_max_stack_amount(stack.item_id)
		if stack.amount > stack_limit:
			_add_validation_issue(report, "error", "stack_amount_exceeds_limit", index, stack.item_id, "堆叠数量超过单堆叠上限。")
		stack_counts[stack.item_id] = int(stack_counts.get(stack.item_id, 0)) + 1

	for item_id: StringName in stack_counts.keys():
		var max_stack_count := _get_max_stack_count(item_id)
		if max_stack_count > 0 and int(stack_counts[item_id]) > max_stack_count:
			_add_validation_issue(report, "error", "stack_count_exceeds_limit", -1, item_id, "物品堆叠数量超过注册表上限。")
	_finalize_validation_report(report)
	return report


## 应用注册表约束并返回报告。
## @param repair: 为 true 时会移除不合法堆叠并裁剪超过上限的数量。
## @return 校验报告字典。
func apply_registry_constraints(repair: bool = false) -> Dictionary:
	var report := validate_inventory()
	if not repair:
		return report

	var stack_counts: Dictionary = {}
	for index: int in range(_slots.size()):
		var stack := _get_stack_ref(index)
		if stack == null:
			continue
		if stack.is_empty() or not _accepts_item(stack.item_id):
			_slots[index] = null
			_emit_slot_changed(index)
			continue
		var stack_limit := _get_max_stack_amount(stack.item_id)
		if stack.amount > stack_limit:
			stack.amount = stack_limit
			_emit_slot_changed(index)
		stack_counts[stack.item_id] = int(stack_counts.get(stack.item_id, 0)) + 1
		var max_stack_count := _get_max_stack_count(stack.item_id)
		if max_stack_count > 0 and int(stack_counts[stack.item_id]) > max_stack_count:
			_slots[index] = null
			_emit_slot_changed(index)
	return report


## 获取库存调试快照。
## @return 调试快照字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"slot_count": _slots.size(),
		"occupied_slot_count": get_occupied_slot_indices().size(),
		"empty_slot_count": get_empty_slot_indices().size(),
		"allow_growth": allow_growth,
		"items": _get_item_totals(),
		"index": get_index_debug_snapshot(),
	}


## 序列化为字典。
## @return 可序列化字典。
func to_dict() -> Dictionary:
	var stack_data: Array[Dictionary] = []
	for stack_variant: Variant in _slots:
		var stack := stack_variant as GFInventoryStack
		stack_data.append(stack.to_dict() if stack != null else {})
	return {
		"slot_count": _slots.size(),
		"allow_growth": allow_growth,
		"slots": stack_data,
	}


## 从字典恢复。
## @param data: 序列化数据。
func from_dict(data: Dictionary) -> void:
	allow_growth = bool(data.get("allow_growth", allow_growth))
	var slot_count := int(data.get("slot_count", 0))
	var raw_slots := data.get("slots", []) as Array
	_slots.clear()
	var count := maxi(slot_count, raw_slots.size() if raw_slots != null else 0)
	for index: int in range(count):
		var stack_data: Dictionary = {}
		if raw_slots != null and index < raw_slots.size():
			var stack_value := raw_slots[index] as Dictionary
			if stack_value != null:
				stack_data = stack_value
		if stack_data == null or stack_data.is_empty():
			_slots.append(null)
		else:
			var stack := GFInventoryStack.from_dict(stack_data)
			_slots.append(stack if not stack.is_empty() else null)
	_mark_index_dirty()
	inventory_changed.emit()


# --- 私有/辅助方法 ---

func _get_stack_ref(slot_index: int) -> GFInventoryStack:
	if not is_valid_slot(slot_index):
		return null
	return _slots[slot_index] as GFInventoryStack


func _accepts_item(item_id: StringName) -> bool:
	if registry == null:
		return item_id != &""
	return registry.accepts_item(item_id)


func _normalize_instance_data(item_id: StringName, instance_data: Dictionary) -> Dictionary:
	if registry == null:
		return instance_data.duplicate(true)
	return registry.normalize_instance_data(item_id, instance_data)


func _get_max_stack_amount(item_id: StringName) -> int:
	if registry == null:
		return 99
	return registry.get_max_stack_amount(item_id)


func _get_max_stack_count(item_id: StringName) -> int:
	if registry == null:
		return 0
	return registry.get_max_stack_count(item_id)


func _get_stack_count_for_item(item_id: StringName) -> int:
	var count := 0
	for stack_variant: Variant in _slots:
		var stack := stack_variant as GFInventoryStack
		if stack != null and stack.item_id == item_id:
			count += 1
	return count


func _can_create_new_stack(item_id: StringName) -> bool:
	var max_stack_count := _get_max_stack_count(item_id)
	return max_stack_count <= 0 or _get_stack_count_for_item(item_id) < max_stack_count


func _ordered_slot_indices(start_slot: int) -> PackedInt32Array:
	var result := PackedInt32Array()
	if _slots.is_empty():
		return result
	var start := clampi(start_slot, 0, _slots.size() - 1) if start_slot >= 0 else 0
	for offset: int in range(_slots.size()):
		result.append((start + offset) % _slots.size())
	return result


func _try_add_to_existing_stack(
	slot_index: int,
	item_id: StringName,
	remaining: int,
	instance_data: Dictionary
) -> int:
	var stack := _get_stack_ref(slot_index)
	if stack == null or not stack.can_merge(item_id, instance_data, registry):
		return remaining
	var before := stack.amount
	var next_remaining := stack.add_amount(remaining, registry)
	var added := stack.amount - before
	if added > 0:
		item_added.emit(slot_index, item_id, added)
		_emit_slot_changed(slot_index)
	return next_remaining


func _try_add_to_empty_slot(
	slot_index: int,
	item_id: StringName,
	remaining: int,
	instance_data: Dictionary
) -> int:
	var accepted := mini(remaining, _get_max_stack_amount(item_id))
	if accepted <= 0:
		return remaining
	_slots[slot_index] = GFInventoryStack.new(item_id, accepted, instance_data)
	item_added.emit(slot_index, item_id, accepted)
	_emit_slot_changed(slot_index)
	return remaining - accepted


func _has_empty_slot() -> bool:
	return _find_empty_slot() != -1


func _find_empty_slot() -> int:
	for index: int in range(_slots.size()):
		if is_slot_empty(index):
			return index
	return -1


func _get_empty_slot_count() -> int:
	var count := 0
	for index: int in range(_slots.size()):
		if is_slot_empty(index):
			count += 1
	return count


func _emit_slot_changed(slot_index: int) -> void:
	_mark_index_dirty()
	slot_changed.emit(slot_index)
	inventory_changed.emit()


func _get_item_totals() -> Dictionary:
	var totals: Dictionary = {}
	for stack_variant: Variant in _slots:
		var stack := stack_variant as GFInventoryStack
		if stack == null:
			continue
		var key := String(stack.item_id)
		totals[key] = int(totals.get(key, 0)) + stack.amount
	return totals


func _mark_index_dirty() -> void:
	_index_dirty = true


func _rebuild_index_if_needed() -> void:
	if _index_dirty:
		rebuild_index()


func _make_validation_report() -> Dictionary:
	return {
		"ok": true,
		"error_count": 0,
		"warning_count": 0,
		"issues": [],
	}


func _add_validation_issue(
	report: Dictionary,
	severity: String,
	kind: String,
	slot_index: int,
	item_id: StringName,
	message: String
) -> void:
	var issues := report["issues"] as Array
	issues.append({
		"severity": severity,
		"kind": kind,
		"slot_index": slot_index,
		"item_id": item_id,
		"message": message,
	})
	if severity == "warning":
		report["warning_count"] = int(report["warning_count"]) + 1
	else:
		report["error_count"] = int(report["error_count"]) + 1
		report["ok"] = false


func _finalize_validation_report(report: Dictionary) -> void:
	report["ok"] = int(report.get("error_count", 0)) == 0
