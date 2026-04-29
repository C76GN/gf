## GFInputUtility: 输入缓冲与土狼时间管理工具。
##
## 继承自 GFUtility，为动作/平台跳跃游戏提供两项核心输入辅助机制：
##
## 1. 输入缓冲（Input Buffer）：
##    玩家在角色尚未满足执行条件时提前按下的指令（如跳跃），
##    会被缓冲指定时长。一旦条件满足，系统可消费该缓冲指令立即执行动作。
##    用法：
##      - tick(delta) 中每帧递减缓冲计时器。
##      - 玩家按键时调用 buffer_action("jump", 0.15)。
##      - 逻辑层检查 consume_action("jump")，若返回 true 则执行跳跃。
##
## 2. 土狼时间（Coyote Time）：
##    角色离开平台边缘后的短暂宽容窗口，允许玩家在此窗口内仍可执行跳跃。
##    用法：
##      - 角色离开地面时调用 start_coyote("ground", 0.1)。
##      - 跳跃逻辑中检查 is_coyote_active("ground")，若 true 仍允许跳跃。
##
## 注意：宿主需每帧调用 tick(delta) 以驱动计时器递减。
class_name GFInputUtility
extends GFUtility


# --- 私有变量 ---

## 输入缓冲计时器。Key 为 StringName 动作标识，Value 为剩余时间（秒）。
var _buffers: Dictionary = {}

## 土狼时间计时器。Key 为 StringName 标签，Value 为剩余时间（秒）。
var _coyotes: Dictionary = {}


# --- Godot 生命周期方法 ---

## 第一阶段初始化：清空所有计时器。
func init() -> void:
	ignore_time_scale = true
	_buffers.clear()
	_coyotes.clear()


## 销毁阶段：清理所有状态。
func dispose() -> void:
	_buffers.clear()
	_coyotes.clear()


# --- 公共方法 ---

## 每帧驱动计时器递减。所有计时器归零后自动清除。
## @param delta: 帧间隔时间（秒）。
func tick(delta: float) -> void:
	_tick_dict(_buffers, delta)
	_tick_dict(_coyotes, delta)


## 缓冲一个输入指令，在 duration 秒内可被消费。
## 若该动作已有缓冲，则刷新（取最大值）。
## @param action: 动作标识符。
## @param duration: 缓冲持续时间（秒）。
func buffer_action(action: StringName, duration: float) -> void:
	var current: float = _buffers.get(action, 0.0)
	_buffers[action] = maxf(current, duration)


## 尝试消费一个缓冲的输入指令。
## 若缓冲存在且未过期则消费并返回 true，否则返回 false。
## 消费后该缓冲立即清除。
## @param action: 动作标识符。
## @return 是否成功消费。
func consume_action(action: StringName) -> bool:
	if _buffers.has(action) and _buffers[action] > 0.0:
		_buffers.erase(action)
		return true
	return false


## 查询指定动作是否有活跃的缓冲（不消费）。
## @param action: 动作标识符。
## @return 是否有活跃缓冲。
func has_buffered_action(action: StringName) -> bool:
	return _buffers.has(action) and _buffers[action] > 0.0


## 开始一个土狼时间窗口。
## @param tag: 土狼时间标签（如 "ground"、"wall"）。
## @param duration: 宽容窗口持续时间（秒）。
func start_coyote(tag: StringName, duration: float) -> void:
	_coyotes[tag] = duration


## 查询指定标签的土狼时间是否仍在活跃窗口内。
## @param tag: 土狼时间标签。
## @return 是否在窗口内。
func is_coyote_active(tag: StringName) -> bool:
	return _coyotes.has(tag) and _coyotes[tag] > 0.0


## 手动取消指定标签的土狼时间（如实际执行跳跃后应立即取消）。
## @param tag: 土狼时间标签。
func cancel_coyote(tag: StringName) -> void:
	_coyotes.erase(tag)


## 清除所有缓冲和土狼时间状态。
func clear_all() -> void:
	_buffers.clear()
	_coyotes.clear()


# --- 私有/辅助方法 ---

## 对字典中所有计时器进行 delta 递减，归零后移除。
## @param dict: 计时器字典。
## @param delta: 递减量（秒）。
func _tick_dict(dict: Dictionary, delta: float) -> void:
	if dict.is_empty() or delta <= 0.0:
		return

	var expired: Array[StringName] = []

	for key: StringName in dict:
		dict[key] -= delta
		if dict[key] <= 0.0:
			expired.append(key)

	for key: StringName in expired:
		dict.erase(key)
