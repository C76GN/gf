## GFDialogueResource: 通用对话资源。
##
## 资源只保存对话行集合、起始行和自定义元数据。导入格式、剧本 DSL、
## 本地化表和编辑器 UI 均由项目或独立插件决定。
class_name GFDialogueResource
extends Resource


# --- 常量 ---

const GFDialogueLineBase = preload("res://addons/gf/extensions/dialogue/resources/gf_dialogue_line.gd")


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
## @return 包含 ok 与 issues 的报告。
func validate_resource() -> Dictionary:
	var issues: Array[Dictionary] = []
	var seen: Dictionary = {}
	for index: int in range(lines.size()):
		var line := lines[index]
		if line == null:
			issues.append(_make_issue(&"null_line", "lines[%d]" % index))
			continue
		if line.line_id == &"":
			issues.append(_make_issue(&"empty_line_id", "lines[%d]" % index))
			continue
		if seen.has(line.line_id):
			issues.append(_make_issue(&"duplicate_line_id", String(line.line_id)))
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
			if not seen.has(StringName(next_id)) and get_line(StringName(next_id)) == null:
				issues.append(_make_issue(&"missing_next_line", "%s -> %s" % [line.line_id, next_id]))

	return {
		"ok": issues.is_empty(),
		"issues": issues,
	}


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

func _make_issue(issue_id: StringName, subject: String) -> Dictionary:
	return {
		"issue_id": issue_id,
		"subject": subject,
	}
