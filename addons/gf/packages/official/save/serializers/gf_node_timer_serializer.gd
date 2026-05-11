## GFNodeTimerSerializer: Timer 通用状态序列化器。
##
## 保存 Timer 的等待时间、暂停、一次性和当前剩余时间等通用状态。
class_name GFNodeTimerSerializer
extends GFNodeSerializer


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.timer"
	display_name = "Timer"


# --- 公共方法 ---

## 判断序列化器是否支持指定节点。
## @param node: 目标节点。
func supports_node(node: Node) -> bool:
	return node is Timer


## 采集节点的可保存状态。
## @param node: 目标节点。
## @param _context: 操作上下文字典，默认实现不直接使用。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	var timer := node as Timer
	if timer == null:
		return {}

	return {
		"wait_time": timer.wait_time,
		"one_shot": timer.one_shot,
		"autostart": timer.autostart,
		"paused": timer.paused,
		"time_left": timer.time_left,
		"stopped": timer.is_stopped(),
	}


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var timer := node as Timer
	if timer == null:
		return make_result(false, "Node is not Timer.")

	if payload.has("wait_time"):
		timer.wait_time = maxf(float(payload["wait_time"]), 0.0)
	if payload.has("one_shot"):
		timer.one_shot = bool(payload["one_shot"])
	if payload.has("autostart"):
		timer.autostart = bool(payload["autostart"])
	if payload.has("paused"):
		timer.paused = bool(payload["paused"])

	if payload.has("stopped"):
		if bool(payload["stopped"]):
			timer.stop()
		else:
			var time_left := float(payload.get("time_left", timer.wait_time))
			timer.start(time_left if time_left > 0.0 else timer.wait_time)
	return make_result(true)
