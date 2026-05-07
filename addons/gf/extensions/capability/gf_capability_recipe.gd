## GFCapabilityRecipe: 可复用的能力组合资源。
##
## Recipe 用于把一组通用 Capability 条目批量应用到 receiver。它只描述组合结构，
## 不规定实体类型、玩法规则、UI 或存档字段。
class_name GFCapabilityRecipe
extends Resource


# --- 常量 ---

const GFCapabilityRecipeEntryBase = preload("res://addons/gf/extensions/capability/gf_capability_recipe_entry.gd")


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
	var report := {
		"ok": true,
		"healthy": true,
		"entry_count": entries.size(),
		"error_count": 0,
		"warning_count": 0,
		"issue_counts_by_kind": {},
		"summary": "",
		"next_action": "",
		"issues": [],
	}

	var seen_keys: Dictionary = {}
	for index: int in range(entries.size()):
		var entry := entries[index]
		if entry == null:
			_append_issue(report, "warning", "null_entry", str(index), "Recipe contains a null entry.")
			continue
		if not entry.is_valid_entry():
			_append_issue(report, "error", "invalid_entry", str(index), "Recipe entry requires capability_type or scene.")
			continue

		var key := _get_entry_key(entry)
		if not key.is_empty() and seen_keys.has(key):
			_append_issue(report, "warning", "duplicate_entry", key, "Recipe contains duplicate capability entries.")
		seen_keys[key] = true

	_finalize_report(report)
	return report


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


func _append_issue(report: Dictionary, severity: String, kind: String, key: String, message: String) -> void:
	(report["issues"] as Array).append({
		"severity": severity,
		"kind": kind,
		"key": key,
		"message": message,
	})


func _finalize_report(report: Dictionary) -> void:
	var error_count := 0
	var warning_count := 0
	var issue_counts_by_kind: Dictionary = {}
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue == null:
			continue

		var severity := String(issue.get("severity", ""))
		var kind := String(issue.get("kind", "unknown"))
		issue_counts_by_kind[kind] = int(issue_counts_by_kind.get(kind, 0)) + 1
		if severity == "error":
			error_count += 1
		elif severity == "warning":
			warning_count += 1

	report["error_count"] = error_count
	report["warning_count"] = warning_count
	report["issue_counts_by_kind"] = issue_counts_by_kind
	report["ok"] = error_count == 0
	report["healthy"] = error_count == 0 and warning_count == 0
	if error_count > 0:
		report["summary"] = "Capability recipe has %d error(s) and %d warning(s)." % [error_count, warning_count]
	elif warning_count > 0:
		report["summary"] = "Capability recipe has %d warning(s)." % warning_count
	else:
		report["summary"] = "Capability recipe is healthy."
	report["next_action"] = _get_next_action(report)


func _get_next_action(report: Dictionary) -> String:
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue != null and String(issue.get("severity", "")) == "error":
			return _get_next_action_for_issue(issue)
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue != null and String(issue.get("severity", "")) == "warning":
			return _get_next_action_for_issue(issue)
	return "No action required."


func _get_next_action_for_issue(issue: Dictionary) -> String:
	match String(issue.get("kind", "")):
		"null_entry":
			return "Remove the null Recipe entry or replace it with a valid GFCapabilityRecipeEntry."
		"invalid_entry":
			return "Set capability_type or scene on every Recipe entry."
		"duplicate_entry":
			return "Remove duplicate entries unless the duplication is intentional metadata for project tools."
		_:
			return "Review the first reported capability recipe issue before applying it."

