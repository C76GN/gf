## GFProjectileCatalog: 发射体场景目录。
##
## 用稳定 ID 管理 PackedScene，供发射器、技能或项目自己的生成流程复用。
## 目录不规定发射体的伤害、阵营、消耗或命中特效。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFProjectileCatalog
extends Resource


# --- 常量 ---

const _GF_PROJECTILE_CATALOG_ENTRY_SCRIPT: Script = preload("res://addons/gf/extensions/combat/projectiles/gf_projectile_catalog_entry.gd")


# --- 导出变量 ---

## 发射体场景条目列表。
## [br]
## @api public
@export var entries: Array[GFProjectileCatalogEntry] = []


# --- 公共方法 ---

## 设置或替换一个发射体场景。
## [br]
## @api public
## [br]
## @param projectile_id: 发射体 ID。
## [br]
## @param scene: 发射体场景；为 null 时移除该 ID。
func set_scene(projectile_id: StringName, scene: PackedScene) -> void:
	if projectile_id == &"":
		return
	if scene == null:
		remove_scene(projectile_id)
		return

	var entry := _get_entry(projectile_id)
	if entry == null:
		entry = GFProjectileCatalogEntry.new()
		entry.projectile_id = projectile_id
		entries.append(entry)
	entry.scene = scene


## 获取指定 ID 的发射体场景。
## [br]
## @api public
## [br]
## @param projectile_id: 发射体 ID。
## [br]
## @return 找到时返回 PackedScene，否则返回 null。
func get_scene(projectile_id: StringName) -> PackedScene:
	var entry := _get_entry(projectile_id)
	if entry == null:
		return null
	return entry.scene


## 移除指定 ID 的发射体场景。
## [br]
## @api public
## [br]
## @param projectile_id: 发射体 ID。
## [br]
## @return 移除成功返回 true。
func remove_scene(projectile_id: StringName) -> bool:
	for index: int in range(entries.size() - 1, -1, -1):
		var entry := entries[index]
		if entry != null and entry.projectile_id == projectile_id:
			entries.remove_at(index)
			return true
	return false


## 检查指定 ID 是否存在有效场景。
## [br]
## @api public
## [br]
## @param projectile_id: 发射体 ID。
## [br]
## @return 存在有效场景时返回 true。
func has_scene(projectile_id: StringName) -> bool:
	return get_scene(projectile_id) != null


## 获取所有有效发射体 ID。
## [br]
## @api public
## [br]
## @return 按字典序排序的 ID 数组。
func get_projectile_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for entry: GFProjectileCatalogEntry in entries:
		if entry != null and entry.is_valid_entry():
			ids.append(String(entry.projectile_id))
	ids.sort()
	return ids


## 清理空条目、空 ID 或空场景。
## [br]
## @api public
## [br]
## @return 被清理的条目数量。
func prune_invalid_entries() -> int:
	var removed_count := 0
	for index: int in range(entries.size() - 1, -1, -1):
		var entry := entries[index]
		if entry == null or not entry.is_valid_entry():
			entries.remove_at(index)
			removed_count += 1
	return removed_count


# --- 私有/辅助方法 ---

func _get_entry(projectile_id: StringName) -> GFProjectileCatalogEntry:
	if projectile_id == &"":
		return null
	for entry: GFProjectileCatalogEntry in entries:
		if entry != null and entry.projectile_id == projectile_id:
			return entry
	return null
