## GFCombatSystem: 战斗核心系统。
##
## 负责驱动所有注册实体的 Buff 计时、周期触发以及技能 CD 更新。
## 继承自 GFSystem，可通过架构的 tick 自动运行。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFCombatSystem
extends GFSystem


# --- 私有变量 ---

# 存储所有当前受系统管理的战斗实体元数据。
# 格式：{ entity_object: { "buffs": [GFBuff], "skills": [GFSkill] } }
var _entities: Dictionary = {}

# 活跃实体集合。键为实体 ID，值为实体对象。
var _active_entities: Dictionary = {}


# --- GF 生命周期方法 ---

## 推进运行时逻辑。
## [br]
## @api public
## [br]
## @param p_delta: 本帧时间增量（秒）。
func tick(p_delta: float) -> void:
	_cleanup_invalid_entities()
	var ids := _active_entities.keys()
	for id in ids:
		if not _active_entities.has(id):
			continue

		var entity = _active_entities.get(id)
		if not is_instance_valid(entity) or not _entities.has(entity):
			_active_entities.erase(id)
			continue

		_process_entity(entity, p_delta)


## 释放系统持有的实体、Buff 与技能连接。
## [br]
## @api public
func dispose() -> void:
	for entity in _entities.keys():
		_remove_entity_record(entity, true)

	_entities.clear()
	_active_entities.clear()


# --- 公共方法 ---

## 注册战斗实体。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
func register_entity(p_entity: Object) -> void:
	if p_entity == null or _entities.has(p_entity):
		return
		
	_entities[p_entity] = {
		"buffs": [],
		"skills": [],
	}
	_update_active_status(p_entity)


## 注销战斗实体。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
func unregister_entity(p_entity: Object) -> void:
	_remove_entity_record(p_entity, true)


## 给实体添加一个 Buff。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
## [br]
## @param p_buff: Buff 实例。
func add_buff(p_entity: Object, p_buff: GFBuff) -> void:
	if p_buff == null or not _entities.has(p_entity):
		return

	if p_buff.owner == null:
		p_buff.owner = p_entity

	var data: Dictionary = _entities[p_entity]
	var buffs: Array = data["buffs"]
	
	# 检查重叠逻辑 (简单的 ID 排斥/刷新)
	for existing: GFBuff in buffs:
		if _should_refresh_existing_buff(existing, p_buff):
			existing.refresh_from(p_buff)
			_send_combat_event(GFCombatPayloads.GFBuffRefreshedPayload.new(p_entity, existing))
			return
			
	buffs.append(p_buff)
	p_buff.on_apply()
	_send_combat_event(GFCombatPayloads.GFBuffAppliedPayload.new(p_entity, p_buff))
	
	_update_active_status(p_entity)


## 为实体添加技能。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
## [br]
## @param p_skill: 技能实例。
func add_skill(p_entity: Object, p_skill: GFSkill) -> void:
	if p_skill == null or not _entities.has(p_entity):
		return

	if p_skill.owner == null:
		p_skill.owner = p_entity

	var data: Dictionary = _entities[p_entity]
	var skills: Array = data["skills"]
	
	if not skills.has(p_skill):
		skills.append(p_skill)
		if p_skill.has_method("inject_dependencies"):
			p_skill.inject_dependencies(_get_architecture_or_null())
		if not p_skill.is_connected(&"cooldown_started", _on_skill_cooldown_started):
			p_skill.cooldown_started.connect(_on_skill_cooldown_started)
		
	_update_active_status(p_entity)


## 获取实体上的指定 Buff。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
## [br]
## @param p_buff_id: Buff 标识。
## [br]
## @return 找到时返回正在系统中生效的 Buff 实例，否则返回 null。
func get_buff(p_entity: Object, p_buff_id: StringName) -> GFBuff:
	if not _entities.has(p_entity):
		return null

	var data: Dictionary = _entities[p_entity]
	var buffs: Array = data["buffs"]
	for buff: GFBuff in buffs:
		if buff != null and buff.id == p_buff_id:
			return buff
	return null


## 检查实体上是否存在指定 Buff。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
## [br]
## @param p_buff_id: Buff 标识。
## [br]
## @return 存在返回 true。
func has_buff(p_entity: Object, p_buff_id: StringName) -> bool:
	return get_buff(p_entity, p_buff_id) != null


## 获取实体当前持有的 Buff 列表副本。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
## [br]
## @return Buff 实例数组副本；数组本身可安全修改，但元素仍是运行中的 Buff 引用。
func get_buffs(p_entity: Object) -> Array[GFBuff]:
	var result: Array[GFBuff] = []
	if not _entities.has(p_entity):
		return result

	var data: Dictionary = _entities[p_entity]
	var buffs: Array = data["buffs"]
	for buff: GFBuff in buffs:
		if buff != null:
			result.append(buff)
	return result


## 强制刷新指定 Buff 已挂载修饰器影响到的属性。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
## [br]
## @param p_buff_id: Buff 标识。
## [br]
## @return 至少刷新了一个属性时返回 true。
func refresh_buff_modifiers(p_entity: Object, p_buff_id: StringName) -> bool:
	var buff := get_buff(p_entity, p_buff_id)
	if buff == null:
		return false
	return _refresh_buff_modifier_attributes(buff)


## 移除实体上的指定 Buff。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
## [br]
## @param p_buff_id: Buff 标识。
## [br]
## @return 找到并移除 Buff 时返回 true。
func remove_buff(p_entity: Object, p_buff_id: StringName) -> bool:
	if not _entities.has(p_entity):
		return false

	var data: Dictionary = _entities[p_entity]
	var buffs: Array = data["buffs"]
	for index in range(buffs.size() - 1, -1, -1):
		var buff := buffs[index] as GFBuff
		if buff != null and buff.id == p_buff_id:
			_remove_buff_at(p_entity, buffs, index, true)
			_update_active_status(p_entity)
			return true
	return false


## 清理实体上的 Buff。predicate 为空时清理全部；否则仅清理返回 true 的 Buff。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
## [br]
## @param predicate: 可选过滤回调，签名为 `func(buff: GFBuff) -> bool`。
## [br]
## @return 被清理的 Buff 数量。
func clear_buffs(p_entity: Object, predicate: Callable = Callable()) -> int:
	if not _entities.has(p_entity):
		return 0

	var data: Dictionary = _entities[p_entity]
	var buffs: Array = data["buffs"]
	var removed_count := 0
	for index in range(buffs.size() - 1, -1, -1):
		var buff := buffs[index] as GFBuff
		if buff == null:
			buffs.remove_at(index)
			continue
		if predicate.is_valid() and not bool(predicate.call(buff)):
			continue
		_remove_buff_at(p_entity, buffs, index, true)
		removed_count += 1

	if removed_count > 0:
		_update_active_status(p_entity)
	return removed_count


## 移除实体上的指定技能。
## [br]
## @api public
## [br]
## @param p_entity: 实体对象。
## [br]
## @param p_skill: 技能实例。
## [br]
## @return 找到并移除技能时返回 true。
func remove_skill(p_entity: Object, p_skill: GFSkill) -> bool:
	if p_skill == null or not _entities.has(p_entity):
		return false

	var data: Dictionary = _entities[p_entity]
	var skills: Array = data["skills"]
	if not skills.has(p_skill):
		return false

	if p_skill.is_connected(&"cooldown_started", _on_skill_cooldown_started):
		p_skill.cooldown_started.disconnect(_on_skill_cooldown_started)
	skills.erase(p_skill)
	_update_active_status(p_entity)
	return true


# --- 私有/辅助方法 ---

# 更新实体的活跃状态。
func _update_active_status(p_entity: Object) -> void:
	if not is_instance_valid(p_entity) or not _entities.has(p_entity):
		_erase_active_entity(p_entity)
		return
		
	var data: Dictionary = _entities[p_entity]
	var buffs: Array = data["buffs"]
	var skills: Array = data["skills"]
	
	var is_active: bool = not buffs.is_empty()
	
	if not is_active:
		for skill: GFSkill in skills:
			if skill.cooldown_left > 0.0: # 简化判定：正在 CD 中
				is_active = true
				break
				
	if is_active:
		_active_entities[p_entity.get_instance_id()] = p_entity
	else:
		_active_entities.erase(p_entity.get_instance_id())


func _cleanup_invalid_entities() -> void:
	for entity in _entities.keys():
		if not is_instance_valid(entity):
			_remove_entity_record(entity, false)

	for entity_id in _active_entities.keys():
		var entity = _active_entities[entity_id]
		if not is_instance_valid(entity) or not _entities.has(entity):
			_active_entities.erase(entity_id)


func _erase_active_entity(p_entity: Variant) -> void:
	if is_instance_valid(p_entity):
		_active_entities.erase(p_entity.get_instance_id())
		return

	var stale_ids: Array = []
	for entity_id in _active_entities.keys():
		if _active_entities[entity_id] == p_entity:
			stale_ids.append(entity_id)

	for entity_id in stale_ids:
		_active_entities.erase(entity_id)


func _remove_entity_record(p_entity: Variant, remove_effects: bool) -> void:
	if not _entities.has(p_entity):
		_erase_active_entity(p_entity)
		return

	var data: Dictionary = _entities[p_entity]
	_cleanup_entity_data(data, remove_effects)
	_entities.erase(p_entity)
	_erase_active_entity(p_entity)


func _cleanup_entity_data(data: Dictionary, remove_effects: bool) -> void:
	var buffs: Array = data.get("buffs", [])
	for buff: GFBuff in buffs:
		if buff == null:
			continue
		if remove_effects:
			buff.on_remove()

	var skills: Array = data.get("skills", [])
	for skill: GFSkill in skills:
		if skill == null:
			continue
		if skill.is_connected(&"cooldown_started", _on_skill_cooldown_started):
			skill.cooldown_started.disconnect(_on_skill_cooldown_started)


func _on_skill_cooldown_started(p_skill: GFSkill) -> void:
	if is_instance_valid(p_skill) and is_instance_valid(p_skill.owner):
		_update_active_status(p_skill.owner)


func _send_combat_event(event_instance: Object) -> void:
	var arch := _get_architecture_or_null()
	if arch != null and arch.has_method("send_event"):
		arch.send_event(event_instance)


func _remove_buff_at(p_entity: Object, buffs: Array, index: int, remove_effects: bool) -> void:
	var buff := buffs[index] as GFBuff
	buffs.remove_at(index)
	if buff == null:
		return

	var removed_id := buff.id
	if remove_effects:
		buff.on_remove()
	_send_combat_event(GFCombatPayloads.GFBuffRemovedPayload.new(p_entity, removed_id))


func _should_refresh_existing_buff(existing: GFBuff, incoming: GFBuff) -> bool:
	if existing == null or incoming == null:
		return false
	if incoming.id == &"":
		return false
	return existing.id == incoming.id


func _refresh_buff_modifier_attributes(buff: GFBuff) -> bool:
	if buff == null or buff.owner == null or not is_instance_valid(buff.owner):
		return false
	if not buff.owner.has_method("get_attribute"):
		return false

	var refreshed_attribute_ids: Dictionary = {}
	var refreshed := false
	for modifier: GFModifier in buff.modifiers:
		if modifier == null or modifier.attribute_id == &"":
			continue
		if refreshed_attribute_ids.has(modifier.attribute_id):
			continue

		var attr := buff.owner.get_attribute(modifier.attribute_id) as GFModifiedAttribute
		if attr == null:
			continue

		attr.force_recalculate()
		refreshed_attribute_ids[modifier.attribute_id] = true
		refreshed = true
	return refreshed


func _process_entity(p_entity: Object, p_delta: float) -> void:
	if not _entities.has(p_entity):
		return

	var data: Dictionary = _entities[p_entity]
	var buffs: Array = data["buffs"]
	var buff_index := buffs.size() - 1
	while buff_index >= 0:
		if buff_index >= buffs.size():
			buff_index = buffs.size() - 1
			continue

		var buff := buffs[buff_index] as GFBuff
		if buff == null:
			buffs.remove_at(buff_index)
			buff_index -= 1
			continue
		if buff.update(p_delta):
			if buff_index < buffs.size() and buffs[buff_index] == buff:
				_remove_buff_at(p_entity, buffs, buff_index, true)
			else:
				buffs.erase(buff)
				buff.on_remove()
				_send_combat_event(GFCombatPayloads.GFBuffRemovedPayload.new(p_entity, buff.id))
		buff_index -= 1

	if not _entities.has(p_entity):
		return

	var skills: Array = data["skills"]
	var skill_index := skills.size() - 1
	while skill_index >= 0:
		if skill_index >= skills.size():
			skill_index = skills.size() - 1
			continue
		var skill := skills[skill_index] as GFSkill
		if skill == null:
			skills.remove_at(skill_index)
			skill_index -= 1
			continue
		skill.update(p_delta)
		skill_index -= 1

	if _entities.has(p_entity):
		_update_active_status(p_entity)
