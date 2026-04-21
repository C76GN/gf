## GFTimerUtility: 纯代码驱动的全局定时器工具。
##
## 封装了基于 SceneTreeTimer 的延迟回调执行，无需在场景树中
## 挂载任何 Timer 节点。适用于在 GFSystem 或 GFModel 中安排
## 一次性延迟逻辑。
class_name GFTimerUtility
extends GFUtility


# --- 公共方法 ---

## 在指定延迟后执行一次回调函数。
## 内部使用 SceneTree.create_timer()，不依赖场景树中的 Timer 节点。
## @param delay: 延迟时长（秒）。
## @param callback: 延迟结束后执行的无参回调函数。
func execute_after(delay: float, callback: Callable) -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		push_error("[GFTimerUtility] execute_after 失败：无法获取 SceneTree。")
		return
	var timer := scene_tree.create_timer(delay)
	timer.timeout.connect(callback, CONNECT_ONE_SHOT)
