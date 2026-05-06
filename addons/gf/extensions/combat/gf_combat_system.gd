## GFCombatSystem: 战斗核心系统。
##
## 负责驱动所有注册实体的 Buff 计时、周期触发以及技能 CD 更新。
## 继承自 GFSystem，可通过架构的 tick 自动运行。
class_name GFCombatSystem
extends GFSystem


# --- 私有变量 ---

## 存储所有当前受系统管理的战斗实体元数据。
## 格式：{ entity_object: { "buffs": [GFBuff], "skills": [GFSkill] } }
var _entities: Dictionary = {}

## 活跃实体集合。键为实体 ID，值为实体对象。
var _active_entities: Dictionary = {}


# --- GFSystem 生命周期方法 ---

## 推进运行时逻辑。
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


func dispose() -> void:
	for entity in _entities.keys():
		_remove_entity_record(entity, true)

	_entities.clear()
	_active_entities.clear()


# --- 公共方法 ---

## 注册战斗实体。
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
## @param p_entity: 实体对象。
func unregister_entity(p_entity: Object) -> void:
	_remove_entity_record(p_entity, true)


## 给实体添加一个 Buff。
## @param p_entity: 实体对象。
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
		if existing.id == p_buff.id:
			existing.on_refresh(p_buff.duration)
			_send_combat_event(GFCombatPayloads.GFBuffRefreshedPayload.new(p_entity, existing))
			return
			
	buffs.append(p_buff)
	p_buff.on_apply()
	_send_combat_event(GFCombatPayloads.GFBuffAppliedPayload.new(p_entity, p_buff))
	
	_update_active_status(p_entity)


## 为实体添加技能。
## @param p_entity: 实体对象。
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


# --- 私有/辅助方法 ---

## 更新实体的活跃状态。
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
			var removed_id := buff.id
			if buff_index < buffs.size() and buffs[buff_index] == buff:
				buffs.remove_at(buff_index)
			else:
				buffs.erase(buff)
			buff.on_remove()
			_send_combat_event(GFCombatPayloads.GFBuffRemovedPayload.new(p_entity, removed_id))
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
