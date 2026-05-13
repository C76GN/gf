## GF Save 扩展安装器。
extends GFInstaller


# --- 常量 ---

const GFSaveGraphUtilityBase = preload("res://addons/gf/extensions/official/save/graph/gf_save_graph_utility.gd")


# --- 公共方法 ---

## 注册 Save 扩展的运行时服务。
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_utility(GFSaveGraphUtilityBase) != null:
		return
	await architecture.register_utility_instance(GFSaveGraphUtilityBase.new())
