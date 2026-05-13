## GF Action Queue 扩展安装器。
extends GFInstaller


# --- 常量 ---

const GFActionQueueSystemBase = preload("res://addons/gf/extensions/official/action_queue/core/gf_action_queue_system.gd")


# --- 公共方法 ---

## 注册 Action Queue 扩展的运行时服务。
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_system(GFActionQueueSystemBase) != null:
		return
	await architecture.register_system_instance(GFActionQueueSystemBase.new())
