## GFCallableAction: 将 Callable 包装为队列动作。
##
## 适合把轻量表现指令、日志、回调或项目自定义命令插入 GFActionQueueSystem。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFCallableAction
extends GFVisualAction


# --- 公共变量 ---

## 要执行的回调。
## [br]
## @api public
var callback: Callable

## 传给回调的参数。
## [br]
## @api public
## [br]
## @schema args: Array，传给 callback.callv() 的参数列表。
var args: Array = []


# --- Godot 生命周期方法 ---

func _init(p_callback: Callable = Callable(), p_args: Array = []) -> void:
	callback = p_callback
	args = p_args.duplicate()


# --- 公共方法 ---

## 执行回调并返回回调结果。
## [br]
## @api public
## [br]
## @return callback.callv(args) 的返回值；回调无效时返回 null。
## [br]
## @schema return: Variant，由 callback 返回，可能是 Signal、null 或项目自定义值。
func execute() -> Variant:
	if not callback.is_valid():
		return null
	return callback.callv(args)
