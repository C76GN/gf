# GF Combat 扩展安装器。
extends GFInstaller


# --- 常量 ---

const _GF_COMBAT_SYSTEM_SCRIPT: Script = preload("res://addons/gf/extensions/combat/core/gf_combat_system.gd")
const _GF_SKILL_TARGETING_UTILITY_SCRIPT: Script = preload("res://addons/gf/extensions/combat/skills/gf_skill_targeting_utility.gd")


# --- 框架内部方法 ---

## 注册 Combat 扩展的运行时服务。
## [br]
## @api framework_internal
## [br]
## @param architecture: 要装配的架构实例。
func install(architecture: GFArchitecture) -> void:
	if architecture == null:
		return
	if architecture.get_local_utility(_GF_SKILL_TARGETING_UTILITY_SCRIPT) == null:
		await architecture.register_utility_instance(_GF_SKILL_TARGETING_UTILITY_SCRIPT.new())
	if architecture.get_local_system(_GF_COMBAT_SYSTEM_SCRIPT) == null:
		await architecture.register_system_instance(_GF_COMBAT_SYSTEM_SCRIPT.new())
