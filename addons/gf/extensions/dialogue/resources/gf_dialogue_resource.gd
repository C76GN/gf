## GFDialogueResource: 通用对话资源。
##
## 资源只保存对话行集合、起始行和自定义元数据。导入格式、剧本 DSL、
## 本地化表和编辑器 UI 均由项目或独立插件决定。
class_name GFDialogueResource
extends Resource


# --- 常量 ---

const GFDialogueLineBase = preload("res://addons/gf/extensions/dialogue/resources/gf_dialogue_line.gd")
const GFValidationReportDictionaryBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd")


# --- 导出变量 ---

## 默认起始行 ID。
@export var start_line_id: StringName = &""

## 对话行集合。
@export var lines: Array[GFDialogueLineBase] = []

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 设置或追加对话行。
## @param line: 对话行。
func set_line(line: GFDialogueLineBase) -> void:
	if line == null or line.line_id == &"":
		return
	for index: int in range(lines.size()):
		if lines[index] != null and lines[index].line_id == line.line_id:
			lines[index] = line
			emit_changed()
			return
	lines.append(line)
	emit_changed()


## 获取对话行。
## @param line_id: 行 ID。
## @return 对话行；不存在时返回 null。
func get_line(line_id: StringName) -> GFDialogueLine:
	for line: GFDialogueLineBase in lines:
		if line != null and line.line_id == line_id:
			return line
	return null


## 获取起始行。
## @param override_line_id: 可选覆盖起点。
## @return 起始行；不存在时返回 null。
func get_start_line(override_line_id: StringName = &"") -> GFDialogueLine:
	var resolved_id := override_line_id if override_line_id != &"" else start_line_id
	if resolved_id != &"":
		return get_line(resolved_id)
	for line: GFDialogueLineBase in lines:
		if line != null:
			return line
	return null


## 获取全部行 ID。
## @return 行 ID 列表。
func get_line_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for line: GFDialogueLineBase in lines:
		if line != null and line.line_id != &"":
			result.append(String(line.line_id))
	return result


## 校验资源结构。
## @return 兼容 GFValidationReportDictionary 的报告字典。
func validate_resource() -> Dictionary:
	var report := {
		"subject": "Dialogue resource",
		"issues": [],
	}
	if start_line_id != &"" and get_line(start_line_id) == null:
		_append_issue(
			report,
			&"missing_start_line",
			String(start_line_id),
			"Dialogue start_line_id does not reference an existing line."
		)

	var seen: Dictionary = {}
	for index: int in range(lines.size()):
		var line := lines[index]
		if line == null:
			_append_issue(report, &"null_line", "lines[%d]" % index, "Dialogue line is null.")
			continue
		if line.line_id == &"":
			_append_issue(report, &"empty_line_id", "lines[%d]" % index, "Dialogue line_id is empty.")
			continue
		if seen.has(line.line_id):
			_append_issue(report, &"duplicate_line_id", String(line.line_id), "Dialogue line_id is duplicated.")
		seen[line.line_id] = true

		var next_ids := PackedStringArray()
		if line.next_line_id != &"":
			next_ids.append(String(line.next_line_id))
		if line.jump_line_id != &"":
			next_ids.append(String(line.jump_line_id))
		if line.fallback_line_id != &"":
			next_ids.append(String(line.fallback_line_id))
		for response: GFDialogueResponse in line.responses:
			if response != null and response.next_line_id != &"":
				next_ids.append(String(response.next_line_id))
		for next_id: String in next_ids:
			if get_line(StringName(next_id)) == null:
				_append_issue(
					report,
					&"missing_next_line",
					"%s -> %s" % [line.line_id, next_id],
					"Dialogue transition references a missing line."
				)

	return GFValidationReportDictionaryBase.finalize_report(report, "Dialogue resource", {
		"include_issue_count": true,
		"next_actions": _get_validation_next_actions(),
	})


## 创建深拷贝。
## @return 对话资源副本。
func duplicate_dialogue() -> GFDialogueResource:
	return duplicate(true) as GFDialogueResource


## 转换为字典。
## @return 资源快照。
func to_dictionary() -> Dictionary:
	var line_data: Array[Dictionary] = []
	for line: GFDialogueLineBase in lines:
		if line != null:
			line_data.append(line.to_dictionary())
	return {
		"start_line_id": start_line_id,
		"lines": line_data,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _append_issue(
	report: Dictionary,
	kind: StringName,
	subject: String,
	message: String
) -> void:
	GFValidationReportDictionaryBase.append_issue(report, "error", kind, message, {
		"subject": subject,
		"path": subject,
	})


func _get_validation_next_actions() -> Dictionary:
	return {
		"missing_start_line": "Create the configured start line or clear start_line_id to use the first available line.",
		"null_line": "Remove empty dialogue line slots or assign a GFDialogueLine resource.",
		"empty_line_id": "Assign every dialogue line a stable line_id.",
		"duplicate_line_id": "Make every dialogue line_id unique.",
		"missing_next_line": "Create the referenced dialogue line or update the transition id.",
	}
