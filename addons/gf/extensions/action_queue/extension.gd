# GF Action Queue 扩展安装器。
extends GFInstaller


# --- 常量 ---

const _GF_ACTION_QUEUE_SYSTEM = preload("res://addons/gf/extensions/action_queue/core/gf_action_queue_system.gd")


# --- 框架内部方法 ---

## 注册 Action Queue 扩展的运行时服务。
## [br]
## @api framework_internal
## [br]
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_system(_GF_ACTION_QUEUE_SYSTEM) != null:
		return
	await architecture.register_system_instance(_GF_ACTION_QUEUE_SYSTEM.new())
