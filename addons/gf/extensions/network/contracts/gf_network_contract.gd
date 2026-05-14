## GFNetworkContract: 网络消息契约集合。
##
## 契约集合用于集中描述一组 GFNetworkMessage 的 message_type、字段和默认通道，
## 方便项目生成强类型辅助代码或在运行前校验消息结构。
class_name GFNetworkContract
extends Resource


# --- 导出变量 ---

## 契约稳定标识。
@export var contract_id: StringName = &""

## 编辑器展示名称。
@export var display_name: String = ""

## 消息契约列表。
@export var messages: Array[GFNetworkContractMessage] = []

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取展示名称。
## @return 展示名称。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if contract_id != &"":
		return String(contract_id)
	return "Network Contract"


## 设置或替换一个消息契约。
## @param message_contract: 消息契约。
func set_message_contract(message_contract: GFNetworkContractMessage) -> void:
	if message_contract == null or message_contract.message_type == &"":
		return

	for index: int in range(messages.size()):
		if messages[index] != null and messages[index].message_type == message_contract.message_type:
			messages[index] = message_contract
			return
	messages.append(message_contract)


## 获取消息契约。
## @param message_type: 消息类型。
## @return 消息契约；不存在时返回 null。
func get_message_contract(message_type: StringName) -> GFNetworkContractMessage:
	for message_contract: GFNetworkContractMessage in messages:
		if message_contract != null and message_contract.message_type == message_type:
			return message_contract
	return null


## 检查消息契约是否存在。
## @param message_type: 消息类型。
## @return 存在返回 true。
func has_message_contract(message_type: StringName) -> bool:
	return get_message_contract(message_type) != null


## 按消息契约创建 GFNetworkMessage。
## @param message_type: 消息类型。
## @param values: 字段值字典。
## @param options: 可选元信息。
## @return 网络消息；契约不存在时返回 null。
func make_message(message_type: StringName, values: Dictionary = {}, options: Dictionary = {}) -> GFNetworkMessage:
	var message_contract := get_message_contract(message_type)
	if message_contract == null:
		return null
	return message_contract.make_message(values, options)


## 校验网络消息是否匹配本契约集合。
## @param message: 网络消息。
## @return 校验报告字典。
func validate_message(message: GFNetworkMessage) -> Dictionary:
	if message == null:
		return _finalize_report([_make_issue("error", "missing_message", "Network message is null.")])

	var message_contract := get_message_contract(message.message_type)
	if message_contract == null:
		return _finalize_report([_make_issue("error", "unknown_message_type", "Network message_type is not declared by this contract.", String(message.message_type))])
	return message_contract.validate_message(message)


## 校验契约定义是否完整。
## @return 校验报告字典。
func validate_contract() -> Dictionary:
	var issues: Array[Dictionary] = []
	if contract_id == &"":
		issues.append(_make_issue("warning", "empty_contract_id", "Network contract_id is empty."))

	var seen_messages: Dictionary = {}
	for index: int in range(messages.size()):
		var message_contract := messages[index]
		if message_contract == null:
			issues.append(_make_issue("warning", "null_message_contract", "Network contract contains a null message.", str(index)))
			continue

		var message_report := message_contract.validate_definition()
		issues.append_array(message_report.get("issues", []) as Array)
		if message_contract.message_type == &"":
			continue
		if seen_messages.has(message_contract.message_type):
			issues.append(_make_issue(
				"error",
				"duplicate_message_type",
				"Network contract message_type is duplicated.",
				String(message_contract.message_type)
			))
		seen_messages[message_contract.message_type] = true
	return _finalize_report(issues)


## 描述契约集合。
## @return 描述字典。
func describe() -> Dictionary:
	var message_descriptions: Array[Dictionary] = []
	for message_contract: GFNetworkContractMessage in messages:
		if message_contract != null:
			message_descriptions.append(message_contract.describe())
	return {
		"contract_id": contract_id,
		"display_name": get_display_name(),
		"message_count": message_descriptions.size(),
		"messages": message_descriptions,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _make_issue(severity: String, kind: String, message: String, key: String = "") -> Dictionary:
	var issue := {
		"severity": severity,
		"kind": kind,
		"contract_id": contract_id,
		"message": message,
	}
	if not key.is_empty():
		issue["key"] = key
	return issue


func _finalize_report(issues: Array[Dictionary]) -> Dictionary:
	var error_count := 0
	var warning_count := 0
	for issue: Dictionary in issues:
		match String(issue.get("severity", "")):
			"error":
				error_count += 1
			"warning":
				warning_count += 1

	return {
		"ok": error_count == 0,
		"healthy": error_count == 0 and warning_count == 0,
		"error_count": error_count,
		"warning_count": warning_count,
		"issues": issues,
	}
