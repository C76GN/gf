## 测试通用对话资源与运行器。
extends GutTest


# --- 测试方法 ---

## 验证对话运行器可处理响应、mutation 和文本行推进。
func test_dialogue_runner_advances_with_response_and_mutation() -> void:
	var resource := GFDialogueResource.new()
	resource.start_line_id = &"start"
	resource.set_line(_make_text_line(&"start", "Start", &""))

	var response := GFDialogueResponse.new()
	response.response_id = &"next"
	response.next_line_id = &"mark"
	response.mutation_id = &"picked"
	resource.get_line(&"start").responses.append(response)

	var mutation_line := GFDialogueLine.new()
	mutation_line.line_id = &"mark"
	mutation_line.kind = GFDialogueLine.LineKind.MUTATION
	mutation_line.mutation_id = &"mark_seen"
	mutation_line.next_line_id = &"done"
	resource.set_line(mutation_line)
	resource.set_line(_make_text_line(&"done", "Done", &"end"))
	resource.set_line(_make_end_line(&"end"))

	var mutations: Array[StringName] = []
	var context := GFDialogueContext.new()
	context.mutation_handler = func(mutation_id: StringName, _payload: Variant, _subject: Variant, _context: GFDialogueContext) -> bool:
		mutations.append(mutation_id)
		return true

	var runner := GFDialogueRunner.new()
	var first_line := runner.start(resource, &"", context)
	var second_line := runner.choose_response(&"next")

	assert_eq(first_line.line_id, &"start", "启动后应到达起始文本行。")
	assert_eq(second_line.line_id, &"done", "选择响应后应推进到下一条文本行。")
	assert_eq(mutations, [&"picked", &"mark_seen"], "响应与 mutation 行都应请求上下文处理。")


## 验证对话运行器在条件失败时可走 fallback。
func test_dialogue_runner_uses_fallback_when_condition_fails() -> void:
	var resource := GFDialogueResource.new()
	resource.start_line_id = &"start"
	resource.set_line(_make_text_line(&"start", "Start", &"locked"))

	var locked := _make_text_line(&"locked", "Locked", &"")
	locked.condition_id = &"can_enter"
	locked.fallback_line_id = &"fallback"
	resource.set_line(locked)
	resource.set_line(_make_text_line(&"fallback", "Fallback", &""))

	var context := GFDialogueContext.new()
	context.condition_handler = func(_condition_id: StringName, _payload: Variant, _subject: Variant, _context: GFDialogueContext) -> bool:
		return false

	var runner := GFDialogueRunner.new()
	runner.start(resource, &"", context)
	var line := runner.advance()

	assert_eq(line.line_id, &"fallback", "条件失败且存在 fallback 时应跳到 fallback 行。")


## 验证对话资源校验会报告缺失后继。
func test_dialogue_resource_validation_reports_missing_next_line() -> void:
	var resource := GFDialogueResource.new()
	resource.set_line(_make_text_line(&"start", "Start", &"missing"))

	var report := resource.validate_resource()

	assert_false(report["ok"], "缺失后继应导致校验失败。")
	assert_eq(report["issues"][0]["issue_id"], &"missing_next_line", "校验报告应标明缺失后继。")


# --- 私有/辅助方法 ---

func _make_text_line(line_id: StringName, text: String, next_line_id: StringName) -> GFDialogueLine:
	var line := GFDialogueLine.new()
	line.line_id = line_id
	line.kind = GFDialogueLine.LineKind.TEXT
	line.text = text
	line.next_line_id = next_line_id
	return line


func _make_end_line(line_id: StringName) -> GFDialogueLine:
	var line := GFDialogueLine.new()
	line.line_id = line_id
	line.kind = GFDialogueLine.LineKind.END
	return line
