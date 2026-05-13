## GFActionInterceptor: 动作队列的通用拦截器基类。
##
## 拦截器可在表现动作执行前后做横切处理，例如跳过、替换、停止后续队列、
## 记录诊断或根据运行时状态调整表现，不绑定任何具体玩法规则。
class_name GFActionInterceptor
extends RefCounted


# --- 公共变量 ---

## 拦截器优先级，数值越大越早执行。
var priority: int = 0

## 是否启用当前拦截器。
var enabled: bool = true


# --- Godot 生命周期方法 ---

func _init(p_priority: int = 0, p_enabled: bool = true) -> void:
	priority = p_priority
	enabled = p_enabled


# --- 可重写钩子 ---

## 动作执行前调用。
## @param _action: 即将执行的动作。
## @param _queue: 当前动作队列。
## @return 拦截结果；返回 null 等价于继续。
func before_execute(
	_action: Object,
	_queue: GFActionQueueSystem
) -> GFActionInterceptionResult:
	return GFActionInterceptionResult.continue_action()


## 动作执行并完成等待后调用。
## @param _action: 已执行的动作。
## @param _queue: 当前动作队列。
## @param _execute_result: 动作 execute() 的原始返回值。
## @return 拦截结果；当前仅 STOP_QUEUE 会影响后续队列。
func after_execute(
	_action: Object,
	_queue: GFActionQueueSystem,
	_execute_result: Variant
) -> GFActionInterceptionResult:
	return GFActionInterceptionResult.continue_action()
