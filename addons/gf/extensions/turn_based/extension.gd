## GF Turn Based 扩展安装器。
extends GFInstaller


# --- 常量 ---

const GFTurnFlowSystemBase = preload("res://addons/gf/extensions/turn_based/runtime/gf_turn_flow_system.gd")


# --- 公共方法 ---

## 注册 Turn Based 扩展的运行时服务。
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_system(GFTurnFlowSystemBase) != null:
		return
	await architecture.register_system_instance(GFTurnFlowSystemBase.new())
