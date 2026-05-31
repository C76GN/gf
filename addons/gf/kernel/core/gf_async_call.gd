# GFAsyncCall: 内核内部的显式分离调用辅助。
# [br]
# @api framework_internal
# [br]
# @layer kernel/core
extends RefCounted

# --- 公共方法 ---

## 启动 Callable，并明确丢弃其返回值。
## [br]
## @api framework_internal
## [br]
## @layer kernel/core
## [br]
## @param callback: 要启动的 Callable，可为同步或异步入口。
## [br]
## @param arguments: 传给 callback 的参数列表。
## [br]
## @schema arguments: Callable 参数数组。
static func run_detached(callback: Callable, arguments: Array = []) -> void:
	if not callback.is_valid():
		return
	var _ignored_call_result: Variant = callback.callv(arguments)
