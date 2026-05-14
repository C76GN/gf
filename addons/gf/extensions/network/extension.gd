## GF Network 扩展安装器。
extends GFInstaller


# --- 常量 ---

const GFNetworkUtilityBase = preload("res://addons/gf/extensions/network/runtime/gf_network_utility.gd")


# --- 公共方法 ---

## 注册 Network 扩展的运行时服务。
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_utility(GFNetworkUtilityBase) != null:
		return
	await architecture.register_utility_instance(GFNetworkUtilityBase.new())
