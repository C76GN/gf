## GFShakeAction: 将反馈播放接入动作队列的表现动作。
class_name GFShakeAction
extends GFVisualAction


# --- 信号 ---

## 等待模式下，目标反馈播放结束时发出。
signal completed


# --- 公共变量 ---

## 反馈 channel。
var channel: StringName = &"default"

## 反馈预设。
var preset: GFShakePreset = null

## 播放强度倍率。
var strength: float = 1.0

## 是否等待本次反馈播放自然结束。
var wait_until_finished: bool = false

## 项目自定义元数据。
var metadata: Dictionary = {}


# --- 私有变量 ---

var _shake_architecture_ref: WeakRef = null
var _shake_id: int = -1


# --- Godot 生命周期方法 ---

func _init(
	action_preset: GFShakePreset = null,
	action_channel: StringName = &"default",
	action_strength: float = 1.0
) -> void:
	preset = action_preset
	channel = action_channel
	strength = action_strength
	completion_mode = CompletionMode.FIRE_AND_FORGET


# --- 公共方法 ---

## 注入当前动作执行所在的架构实例。
## @param architecture: 当前架构。
func inject_dependencies(architecture: GFArchitecture) -> void:
	super.inject_dependencies(architecture)
	_shake_architecture_ref = weakref(architecture) if architecture != null else null


## 执行反馈动作。
## @return 等待模式下返回 completed 信号，否则返回 null。
func execute() -> Variant:
	var utility := _get_shake_utility()
	if utility == null:
		return null
	_shake_id = utility.play_shake(channel, preset, strength, metadata)
	if _shake_id < 0 or not wait_until_finished:
		return null

	completion_mode = CompletionMode.WAIT_FOR_SIGNAL
	if not utility.shake_finished.is_connected(_on_shake_finished):
		utility.shake_finished.connect(_on_shake_finished)
	return completed


## 判断动作是否可执行。
## @return 可以执行返回 true。
func can_execute() -> bool:
	return preset != null and preset.get_duration_seconds() > 0.0


## 请求取消反馈动作。
func cancel() -> void:
	var utility := _get_shake_utility()
	if utility != null and _shake_id >= 0:
		utility.stop_shake(_shake_id)
	_disconnect_completion()
	_shake_id = -1


## 设置等待本次反馈结束，并返回自身以便链式调用。
## @param enabled: 是否等待反馈结束。
## @return 当前动作。
func with_wait_until_finished(enabled: bool = true) -> GFShakeAction:
	wait_until_finished = enabled
	completion_mode = CompletionMode.WAIT_FOR_SIGNAL if enabled else CompletionMode.FIRE_AND_FORGET
	return self


# --- 私有/辅助方法 ---

func _get_shake_utility() -> GFShakeUtility:
	var architecture: GFArchitecture = null
	if _shake_architecture_ref != null:
		architecture = _shake_architecture_ref.get_ref() as GFArchitecture
	if architecture == null:
		architecture = GFAutoload.get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(GFShakeUtility) as GFShakeUtility


func _disconnect_completion() -> void:
	var utility := _get_shake_utility()
	if utility != null and utility.shake_finished.is_connected(_on_shake_finished):
		utility.shake_finished.disconnect(_on_shake_finished)


# --- 信号处理函数 ---

func _on_shake_finished(finished_shake_id: int, _channel: StringName) -> void:
	if finished_shake_id != _shake_id:
		return
	_disconnect_completion()
	_shake_id = -1
	completed.emit()
