## GFDialogueLine: 通用对话流程行。
##
## 行可以表示可展示文本、跳转、mutation 请求或结束点。它不规定剧本语法、
## 对话框 UI、角色表或项目状态字段。
class_name GFDialogueLine
extends Resource


# --- 枚举 ---

## 对话行类型。
enum LineKind {
	## 可展示文本行。
	TEXT,
	## 请求执行上下文 mutation 后继续。
	MUTATION,
	## 直接跳转到另一行。
	JUMP,
	## 结束当前对话。
	END,
}


# --- 常量 ---

const GFDialogueResponseBase = preload("res://addons/gf/extensions/dialogue/resources/gf_dialogue_response.gd")


# --- 导出变量 ---

## 行 ID。
@export var line_id: StringName = &""

## 行类型。
@export var kind: LineKind = LineKind.TEXT

## 说话者 ID 或项目自定义主体键。
@export var speaker_id: StringName = &""

## 文本或项目自定义文本键。
@export_multiline var text: String = ""

## 默认后继行 ID。
@export var next_line_id: StringName = &""

## 跳转行 ID。`kind == JUMP` 时优先使用。
@export var jump_line_id: StringName = &""

## 条件 ID。为空表示不需要条件判断。
@export var condition_id: StringName = &""

## 条件载荷。框架只透传给上下文处理器。
@export var condition_payload: Variant = null

## 条件不通过时的后继行 ID。为空时由 Runner 按策略跳过或结束。
@export var fallback_line_id: StringName = &""

## mutation ID。`kind == MUTATION` 时由 Runner 请求上下文处理。
@export var mutation_id: StringName = &""

## mutation 载荷。框架只透传给上下文处理器。
@export var mutation_payload: Variant = null

## 响应选项。
@export var responses: Array[GFDialogueResponseBase] = []

## 语义标签。框架不解释标签含义。
@export var tags: PackedStringArray = PackedStringArray()

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查行是否有响应。
## @return 存在响应时返回 true。
func has_responses() -> bool:
	for response: GFDialogueResponseBase in responses:
		if response != null:
			return true
	return false


## 获取可用响应。
## @param context: 对话上下文。
## @return 可用响应列表。
func get_available_responses(context: GFDialogueContext = null) -> Array[GFDialogueResponse]:
	var result: Array[GFDialogueResponse] = []
	for response: GFDialogueResponseBase in responses:
		if response != null and response.is_available(context):
			result.append(response)
	return result


## 按 ID 获取响应。
## @param response_id: 响应 ID。
## @return 响应；不存在时返回 null。
func get_response(response_id: StringName) -> GFDialogueResponse:
	for response: GFDialogueResponseBase in responses:
		if response != null and response.response_id == response_id:
			return response
	return null


## 检查行是否可进入。
## @param context: 对话上下文。
## @return 可进入时返回 true。
func can_enter(context: GFDialogueContext) -> bool:
	if condition_id == &"":
		return true
	if context == null:
		return false
	return bool(context.check_condition(condition_id, condition_payload, self).get("ok", false))


## 获取默认后继行 ID。
## @return 后继行 ID。
func get_default_next_line_id() -> StringName:
	if kind == LineKind.JUMP and jump_line_id != &"":
		return jump_line_id
	return next_line_id


## 创建深拷贝。
## @return 行副本。
func duplicate_line() -> GFDialogueLine:
	return duplicate(true) as GFDialogueLine


## 转换为字典。
## @return 行快照。
func to_dictionary() -> Dictionary:
	var response_data: Array[Dictionary] = []
	for response: GFDialogueResponseBase in responses:
		if response != null:
			response_data.append(response.to_dictionary())

	return {
		"line_id": line_id,
		"kind": kind,
		"speaker_id": speaker_id,
		"text": text,
		"next_line_id": next_line_id,
		"jump_line_id": jump_line_id,
		"condition_id": condition_id,
		"condition_payload": condition_payload,
		"fallback_line_id": fallback_line_id,
		"mutation_id": mutation_id,
		"mutation_payload": mutation_payload,
		"responses": response_data,
		"tags": tags,
		"metadata": metadata.duplicate(true),
	}
