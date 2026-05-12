## GF Capability 包安装器。
extends GFInstaller


# --- 常量 ---

const GFCapabilityUtilityBase = preload("res://addons/gf/packages/official/capability/core/gf_capability_utility.gd")


# --- 公共方法 ---

## 注册 Capability 包的运行时服务。
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_utility(GFCapabilityUtilityBase) != null:
		return
	await architecture.register_utility_instance(GFCapabilityUtilityBase.new())
