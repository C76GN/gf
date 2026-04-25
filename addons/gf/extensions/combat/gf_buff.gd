class_name GFBuff
extends RefCounted


## GFBuff: 状态效果基类。
## 
## 管理 Buff 的生命周期、层数以及对属性/标签的影响。
## 在 GFCombatSystem 的 tick 中驱动 update。


# --- 公共变量 ---

## Buff 的唯一标识名（通常用于排斥逻辑）。
var id: StringName = &""

## Buff 的总持续时间（秒）。如果为 -1 则视为永久 Buff。
var duration: float = 0.0

## 当前剩余剩余时间。
var time_left: float = 0.0

## 当前层数。
var stacks: int = 1

## 最大层数。
var max_stacks: int = 1

## Buff 携带的属性修饰器列表。应用时会自动挂载到宿主的 Attribute 上。
var modifiers: Array[GFModifier] = []

## Buff 携带的标签列表。应用时会自动挂载到宿主的 TagComponent 上。
var tags: Array[StringName] = []

## Buff 的拥有者（通常是一个持有 Combat 数据的 Object）。
var owner: Object = null


# --- 公共方法 ---

## 初始化 Buff，由系统或工厂调用。
func setup(p_id: StringName, p_duration: float, p_owner: Object) -> void:
	id = p_id
	duration = p_duration
	time_left = duration
	owner = p_owner


## 当 Buff 首次应用时触发。
func on_apply() -> void:
	_apply_effects()


## 当 Buff 被移除时触发。
func on_remove() -> void:
	_remove_effects()


## 当 Buff 层数增加时触发（通常用于刷新持续时间）。
func on_refresh(p_new_duration: float) -> void:
	time_left = p_new_duration


## 周期性触发逻辑。
## @param p_delta: 帧间隔。
func on_tick(_p_delta: float) -> void:
	pass


## 内部状态更新流程。
## @param p_delta: 帧间隔。
## @return 如果 Buff 已耗尽生命周期需要被移除，则返回 true。
func update(p_delta: float) -> bool:
	if duration != -1.0:
		time_left -= p_delta
		if time_left <= 0.0:
			return true
	
	on_tick(p_delta)
	return false


# --- 私有方法 ---

## 应用 Buff 携带的所有效果。
func _apply_effects() -> void:
	if owner == null:
		return
		
	# 自动应用标签
	if owner.has_method("get_tag_component"):
		var tc := owner.get_tag_component() as GFTagComponent
		if tc != null:
			for tag in tags:
				tc.add_tag(tag)
				
	# 自动应用修饰器
	if owner.has_method("get_attribute"):
		for mod in modifiers:
			if mod == null:
				continue

			var attr := owner.get_attribute(mod.source_tag) as GFAttribute
			if attr != null:
				attr.add_modifier(mod)


## 移除 Buff 携带的所有效果。
func _remove_effects() -> void:
	if owner == null:
		return
		
	# 移除标签
	if owner.has_method("get_tag_component"):
		var tc := owner.get_tag_component() as GFTagComponent
		if tc != null:
			for tag in tags:
				tc.remove_tag(tag)
				
	# 移除修饰器
	if owner.has_method("get_attribute"):
		for mod in modifiers:
			if mod == null:
				continue

			var attr := owner.get_attribute(mod.source_tag) as GFAttribute
			if attr != null:
				attr.remove_modifier(mod)
