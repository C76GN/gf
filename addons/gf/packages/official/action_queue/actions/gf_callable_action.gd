## GFCallableAction: 将 Callable 包装为队列动作。
##
## 适合把轻量表现指令、日志、回调或项目自定义命令插入 GFActionQueueSystem。
class_name GFCallableAction
extends GFVisualAction


# --- 公共变量 ---

## 要执行的回调。
var callback: Callable

## 传给回调的参数。
var args: Array = []


# --- Godot 生命周期方法 ---

func _init(p_callback: Callable = Callable(), p_args: Array = []) -> void:
	callback = p_callback
	args = p_args.duplicate()


# --- 公共方法 ---

func execute() -> Variant:
	if not callback.is_valid():
		return null
	return callback.callv(args)
