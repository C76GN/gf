## GF Domain 扩展安装器。
extends GFInstaller


# --- 常量 ---

const GFLevelUtilityBase = preload("res://addons/gf/extensions/official/domain/level/gf_level_utility.gd")
const GFQuestUtilityBase = preload("res://addons/gf/extensions/official/domain/quest/gf_quest_utility.gd")


# --- 公共方法 ---

## 注册 Domain 扩展的运行时服务。
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_utility(GFLevelUtilityBase) == null:
		await architecture.register_utility_instance(GFLevelUtilityBase.new())
	if architecture.get_local_utility(GFQuestUtilityBase) == null:
		await architecture.register_utility_instance(GFQuestUtilityBase.new())
