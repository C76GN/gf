## GF Feedback 包安装器。
extends GFInstaller


# --- 常量 ---

const GFShakeUtilityBase = preload("res://addons/gf/packages/official/feedback/runtime/gf_shake_utility.gd")


# --- 公共方法 ---

## 注册 Feedback 包的运行时服务。
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_utility(GFShakeUtilityBase) != null:
		return
	await architecture.register_utility_instance(GFShakeUtilityBase.new())
