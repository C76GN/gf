## GFCombatPayloads: 存放战斗相关的事件载体类。
## [br]
## @api public
## [br]
## @category event_contract
## [br]
## @since 3.17.0
class_name GFCombatPayloads
extends Node


# --- 内部类 ---

## Buff 已应用事件。
## [br]
## @api public
## [br]
## @category event_contract
## [br]
## @since 3.17.0
class GFBuffAppliedPayload extends GFPayload:
	## 目标对象。
	## [br]
	## @api public
	var target: Object
	
	## 已应用的 Buff 实例。
	## [br]
	## @api public
	var buff: GFBuff
	
	func _init(p_target: Object, p_buff: GFBuff) -> void:
		target = p_target
		buff = p_buff


## Buff 已变动/刷新事件。
## [br]
## @api public
## [br]
## @category event_contract
## [br]
## @since 3.17.0
class GFBuffRefreshedPayload extends GFPayload:
	## 目标对象。
	## [br]
	## @api public
	var target: Object
	
	## 已刷新的 Buff 实例。
	## [br]
	## @api public
	var buff: GFBuff
	
	func _init(p_target: Object, p_buff: GFBuff) -> void:
		target = p_target
		buff = p_buff


## Buff 已移除事件。
## [br]
## @api public
## [br]
## @category event_contract
## [br]
## @since 3.17.0
class GFBuffRemovedPayload extends GFPayload:
	## 目标对象。
	## [br]
	## @api public
	var target: Object
	
	## 被移除的 Buff ID。
	## [br]
	## @api public
	var buff_id: StringName
	
	func _init(p_target: Object, p_buff_id: StringName) -> void:
		target = p_target
		buff_id = p_buff_id
