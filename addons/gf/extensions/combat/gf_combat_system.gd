# addons/gf/extensions/combat/gf_combat_system.gd
class_name GFCombatSystem
extends GFSystem


## GFCombatSystem: 战斗核心系统。
## 
## 负责驱动所有注册实体的 Buff 计时、周期触发以及技能 CD 更新。
## 继承自 GFSystem，可通过架构的 tick 自动运行。


# --- 私有变量 ---

## 存储所有当前受系统管理的战斗实体元数据。
## 格式：{ entity_object: { "buffs": [GFBuff], "skills": [GFSkill] } }
var _entities: Dictionary = {}

## 活跃实体集合。键为实体 ID，值为实体对象。
var _active_entities: Dictionary = {}


# --- GFSystem 生命周期方法 ---

func tick(p_delta: float) -> void:
	# 仅遍历活跃实体
	var ids := _active_entities.keys()
	for id in ids:
		var entity = _active_entities[id]
		if not is_instance_valid(entity):
			_active_entities.erase(id)
			continue
			
		_process_entity(entity, p_delta)


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
	# 初始状态不一定是活跃的，但在 GFCombatSystem 中注册通常意味着即将开始战斗，
	# 实际的活跃状态由 add_buff 或 add_skill 触发更新。
	_update_active_status(p_entity)


## 注销战斗实体。
## @param p_entity: 实体对象。
func unregister_entity(p_entity: Object) -> void:
	if _entities.has(p_entity):
		var data: Dictionary = _entities[p_entity]
		
		# 移除 Buff 效果并断开信号
		var buffs: Array = data["buffs"]
		for buff: GFBuff in buffs:
			buff.on_remove()
			
		var skills: Array = data["skills"]
		for skill: GFSkill in skills:
			if skill.is_connected(&"cooldown_started", _on_skill_cooldown_started):
				skill.cooldown_started.disconnect(_on_skill_cooldown_started)
		
		_entities.erase(p_entity)
		_active_entities.erase(p_entity)


## 给实体添加一个 Buff。
## @param p_entity: 实体对象。
## @param p_buff: Buff 实例。
func add_buff(p_entity: Object, p_buff: GFBuff) -> void:
	if not _entities.has(p_entity):
		return
		
	var data: Dictionary = _entities[p_entity]
	var buffs: Array = data["buffs"]
	
	# 检查重叠逻辑 (简单的 ID 排斥/刷新)
	for existing: GFBuff in buffs:
		if existing.id == p_buff.id:
			existing.on_refresh(p_buff.duration)
			Gf.get_architecture().send_event(GFCombatPayloads.GFBuffRefreshedPayload.new(p_entity, existing))
			return
			
	buffs.append(p_buff)
	p_buff.on_apply()
	Gf.get_architecture().send_event(GFCombatPayloads.GFBuffAppliedPayload.new(p_entity, p_buff))
	
	_update_active_status(p_entity)


## 为实体添加技能。
## @param p_entity: 实体对象。
## @param p_skill: 技能实例。
func add_skill(p_entity: Object, p_skill: GFSkill) -> void:
	if not _entities.has(p_entity):
		return
		
	var data: Dictionary = _entities[p_entity]
	var skills: Array = data["skills"]
	
	if not skills.has(p_skill):
		skills.append(p_skill)
		if not p_skill.is_connected(&"cooldown_started", _on_skill_cooldown_started):
			p_skill.cooldown_started.connect(_on_skill_cooldown_started)
		
	_update_active_status(p_entity)


# --- 私有方法 ---

## 更新实体的活跃状态。
func _update_active_status(p_entity: Object) -> void:
	if not _entities.has(p_entity):
		_active_entities.erase(p_entity)
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


func _on_skill_cooldown_started(p_skill: GFSkill) -> void:
	if is_instance_valid(p_skill) and is_instance_valid(p_skill.owner):
		_update_active_status(p_skill.owner)




func _process_entity(p_entity: Object, p_delta: float) -> void:
	var data: Dictionary = _entities[p_entity]
	
	# 处理 Buffs
	var buffs: Array = data["buffs"]
	var to_remove: Array[GFBuff] = []
	
	for buff: GFBuff in buffs:
		if buff.update(p_delta):
			to_remove.append(buff)
			
	for buff: GFBuff in to_remove:
		buff.on_remove()
		buffs.erase(buff)
		Gf.get_architecture().send_event(GFCombatPayloads.GFBuffRemovedPayload.new(p_entity, buff.id))
		
	# 处理技能 CD
	var skills: Array = data["skills"]
	for skill: GFSkill in skills:
		skill.update(p_delta)
		
	# 每次处理完后更新活跃状态
	_update_active_status(p_entity)
