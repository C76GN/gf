# GF Domain 扩展安装器。
extends GFInstaller


# --- 框架内部方法 ---

## 注册 Domain 扩展的运行时服务。
## [br]
## @api framework_internal
## [br]
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_utility(GFLevelUtility) == null:
		await architecture.register_utility_instance(GFLevelUtility.new())
	if architecture.get_local_utility(GFQuestUtility) == null:
		await architecture.register_utility_instance(GFQuestUtility.new())
