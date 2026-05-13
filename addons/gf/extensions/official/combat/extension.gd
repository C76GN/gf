## GF Combat 扩展安装器。
extends GFInstaller


# --- 常量 ---

const GFCombatSystemBase = preload("res://addons/gf/extensions/official/combat/core/gf_combat_system.gd")
const GFSkillTargetingUtilityBase = preload("res://addons/gf/extensions/official/combat/skills/gf_skill_targeting_utility.gd")


# --- 公共方法 ---

## 注册 Combat 扩展的运行时服务。
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_utility(GFSkillTargetingUtilityBase) == null:
		await architecture.register_utility_instance(GFSkillTargetingUtilityBase.new())
	if architecture.get_local_system(GFCombatSystemBase) == null:
		await architecture.register_system_instance(GFCombatSystemBase.new())
