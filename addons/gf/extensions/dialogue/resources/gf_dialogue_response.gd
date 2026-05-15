## GFDialogueResponse: 通用对话响应选项。
##
## 响应只描述玩家或系统可选择的一条后继路径，不决定 UI 样式、
## 输入方式、角色关系或业务副作用。
class_name GFDialogueResponse
extends Resource


# --- 导出变量 ---

## 响应 ID。
@export var response_id: StringName = &""

## 响应文本或项目自定义文本键。
@export_multiline var text: String = ""

## 选择后跳转到的行 ID。为空时使用当前行的默认后继。
@export var next_line_id: StringName = &""

## 条件 ID。为空表示不需要条件判断。
@export var condition_id: StringName = &""

## 条件载荷。框架只透传给上下文处理器。
@export var condition_payload: Variant = null

## 选择该响应时请求执行的通用 mutation ID。为空表示无副作用请求。
@export var mutation_id: StringName = &""

## mutation 载荷。框架只透传给上下文处理器。
@export var mutation_payload: Variant = null

## 语义标签。框架不解释标签含义。
@export var tags: PackedStringArray = PackedStringArray()

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查响应是否可用。
## @param context: 对话上下文。
## @return 可用时返回 true。
func is_available(context: GFDialogueContext) -> bool:
	if condition_id == &"":
		return true
	if context == null:
		return false
	return bool(context.check_condition(condition_id, condition_payload, self).get("ok", false))


## 创建深拷贝。
## @return 响应副本。
func duplicate_response() -> GFDialogueResponse:
	return duplicate(true) as GFDialogueResponse


## 转换为字典。
## @return 响应快照。
func to_dictionary() -> Dictionary:
	return {
		"response_id": response_id,
		"text": text,
		"next_line_id": next_line_id,
		"condition_id": condition_id,
		"condition_payload": condition_payload,
		"mutation_id": mutation_id,
		"mutation_payload": mutation_payload,
		"tags": tags,
		"metadata": metadata.duplicate(true),
	}
