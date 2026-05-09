## GFCapabilityRecipe: 可复用的能力组合资源。
##
## Recipe 用于把一组通用 Capability 条目批量应用到 receiver。它只描述组合结构，
## 不规定实体类型、玩法规则、UI 或存档字段。
class_name GFCapabilityRecipe
extends Resource


# --- 常量 ---

const GFCapabilityRecipeEntryBase = preload("res://addons/gf/extensions/capability/gf_capability_recipe_entry.gd")
const _GF_VALIDATION_REPORT_SCRIPT = preload("res://addons/gf/foundation/validation/gf_validation_report.gd")


# --- 导出变量 ---

## Recipe 稳定标识。为空时可由项目层按资源路径管理。
@export var recipe_id: StringName = &""

## Recipe 展示名，仅供编辑器和项目工具显示。
@export var display_name: String = ""

## 能力条目列表。
@export var entries: Array[GFCapabilityRecipeEntryBase] = []

## 应用 Recipe 时附加到 receiver 的能力查询分组。
@export var groups: Array[StringName] = []

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取展示名。
## @return 展示名。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if recipe_id != &"":
		return String(recipe_id)
	if not resource_path.is_empty():
		return resource_path.get_file().get_basename().to_pascal_case()
	return "Capability Recipe"


## 描述 Recipe。
## @return Recipe 描述字典。
func describe_recipe() -> Dictionary:
	var entry_descriptions: Array[Dictionary] = []
	for entry: GFCapabilityRecipeEntryBase in entries:
		if entry != null:
			entry_descriptions.append(entry.describe_entry())

	return {
		"recipe_id": recipe_id,
		"display_name": get_display_name(),
		"entry_count": entry_descriptions.size(),
		"entries": entry_descriptions,
		"groups": groups.duplicate(),
		"metadata": metadata.duplicate(true),
	}


## 校验 Recipe 结构。
## @return 校验报告。
func validate_recipe() -> Dictionary:
	var report := _GF_VALIDATION_REPORT_SCRIPT.new("Capability recipe")

	var seen_keys: Dictionary = {}
	for index: int in range(entries.size()):
		var entry := entries[index]
		if entry == null:
			report.add_warning(&"null_entry", "Recipe contains a null entry.", str(index))
			continue
		if not entry.is_valid_entry():
			report.add_error(&"invalid_entry", "Recipe entry requires capability_type or scene.", str(index))
			continue

		var key := _get_entry_key(entry)
		if not key.is_empty() and seen_keys.has(key):
			report.add_warning(&"duplicate_entry", "Recipe contains duplicate capability entries.", key)
		seen_keys[key] = true

	return report.to_dict(
		{ "entry_count": entries.size() },
		{
			"include_subject": false,
			"include_metadata": false,
			"include_info_count": false,
			"include_issue_count": false,
			"next_actions": _get_next_actions(),
			"fallback_action": "Review the first reported capability recipe issue before applying it.",
		}
	)


# --- 私有/辅助方法 ---

func _get_entry_key(entry: GFCapabilityRecipeEntryBase) -> String:
	if entry == null:
		return ""
	if entry.capability_type != null:
		var global_name := entry.capability_type.get_global_name()
		if global_name != &"":
			return String(global_name)
		if not entry.capability_type.resource_path.is_empty():
			return entry.capability_type.resource_path
	if entry.scene != null:
		return entry.scene.resource_path
	return ""


func _get_next_actions() -> Dictionary:
	return {
		"null_entry": "Remove the null Recipe entry or replace it with a valid GFCapabilityRecipeEntry.",
		"invalid_entry": "Set capability_type or scene on every Recipe entry.",
		"duplicate_entry": "Remove duplicate entries unless the duplication is intentional metadata for project tools.",
	}
