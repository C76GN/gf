class_name GFCombatPayloads
extends Node


## GFCombatPayloads: 存放战斗相关的事件载体类。


# --- 内部类 ---

## Buff 已应用事件。
class GFBuffAppliedPayload extends GFPayload:
	## 目标对象。
	var target: Object
	
	## 已应用的 Buff 实例。
	var buff: GFBuff
	
	func _init(p_target: Object, p_buff: GFBuff) -> void:
		target = p_target
		buff = p_buff


## Buff 已变动/刷新事件。
class GFBuffRefreshedPayload extends GFPayload:
	## 目标对象。
	var target: Object
	
	## 已刷新的 Buff 实例。
	var buff: GFBuff
	
	func _init(p_target: Object, p_buff: GFBuff) -> void:
		target = p_target
		buff = p_buff


## Buff 已移除事件。
class GFBuffRemovedPayload extends GFPayload:
	## 目标对象。
	var target: Object
	
	## 被移除的 Buff ID。
	var buff_id: StringName
	
	func _init(p_target: Object, p_buff_id: StringName) -> void:
		target = p_target
		buff_id = p_buff_id
