## GFNetworkContractMessage: 网络契约中的单个消息定义。
##
## 消息定义描述 message_type、默认通道和 payload 字段集合，可用于构造、
## 校验和生成强类型辅助函数。
class_name GFNetworkContractMessage
extends Resource


# --- 导出变量 ---

## 消息类型标识。
@export var message_type: StringName = &""

## 编辑器展示名称。
@export var display_name: String = ""

## 默认逻辑通道。为空时发送时不强制通道。
@export var channel_id: StringName = &""

## payload 字段定义。
@export var fields: Array[GFNetworkContractField] = []

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取消息类型。
## @return 消息类型。
func get_message_type() -> StringName:
	return message_type


## 获取展示名称。
## @return 展示名称。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if message_type != &"":
		return String(message_type)
	return "Network Message"


## 查找字段定义。
## @param target_field_name: 字段名称。
## @return 字段定义；不存在时返回 null。
func get_field(target_field_name: StringName) -> GFNetworkContractField:
	for field: GFNetworkContractField in fields:
		if field != null and field.get_field_name() == target_field_name:
			return field
	return null


## 构建 payload 字典。
## @param values: 字段值字典，可使用 StringName 或 String 作为键。
## @param options: 可选项，支持 include_defaults。
## @return payload 字典。
func build_payload(values: Dictionary = {}, options: Dictionary = {}) -> Dictionary:
	var include_defaults := bool(options.get("include_defaults", true))
	var payload: Dictionary = {}
	for field: GFNetworkContractField in fields:
		if field == null or field.get_field_name() == &"":
			continue

		var field_name := field.get_field_name()
		if _has_payload_key(values, field_name):
			payload[field_name] = field.normalize_value(_get_payload_value(values, field_name, null))
		elif include_defaults and field.default_value != null:
			payload[field_name] = field.get_default_value()
	return payload


## 构建 GFNetworkMessage。
## @param values: 字段值字典。
## @param options: 可选元信息，支持 sequence、tick、sender_id、channel_id。
## @return 网络消息。
func make_message(values: Dictionary = {}, options: Dictionary = {}) -> GFNetworkMessage:
	var resolved_channel_id := channel_id
	if options.has("channel_id"):
		resolved_channel_id = StringName(options.get("channel_id", &""))
	return GFNetworkMessage.new(
		message_type,
		build_payload(values, options),
		int(options.get("sequence", 0)),
		int(options.get("tick", 0)),
		int(options.get("sender_id", -1)),
		resolved_channel_id
	)


## 校验消息定义是否完整。
## @return 校验报告字典。
func validate_definition() -> Dictionary:
	var issues: Array[Dictionary] = []
	if message_type == &"":
		issues.append(_make_issue("error", "empty_message_type", "Network contract message_type is empty."))

	var seen_fields: Dictionary = {}
	for index: int in range(fields.size()):
		var field := fields[index]
		if field == null:
			issues.append(_make_issue("warning", "null_field", "Network contract message contains a null field.", str(index)))
			continue

		var field_report := field.validate_definition()
		issues.append_array(_with_message_context(field_report.get("issues", []) as Array))
		var field_name := field.get_field_name()
		if field_name == &"":
			continue
		if seen_fields.has(field_name):
			issues.append(_make_issue("error", "duplicate_field_name", "Network contract field name is duplicated.", String(field_name)))
		seen_fields[field_name] = true
	return _finalize_report(issues)


## 校验 payload 是否符合字段契约。
## @param payload: payload 字典。
## @return 校验报告字典。
func validate_payload(payload: Dictionary) -> Dictionary:
	var issues: Array[Dictionary] = []
	for field: GFNetworkContractField in fields:
		if field == null or field.get_field_name() == &"":
			continue

		var field_name := field.get_field_name()
		if not _has_payload_key(payload, field_name):
			if field.required:
				issues.append(_make_issue("error", "missing_required_field", "Network payload is missing a required field.", String(field_name)))
			continue

		var value := _get_payload_value(payload, field_name, null)
		var field_report := field.validate_value(value)
		issues.append_array(_with_message_context(field_report.get("issues", []) as Array))
	return _finalize_report(issues)


## 校验 GFNetworkMessage 是否匹配该消息契约。
## @param message: 网络消息。
## @return 校验报告字典。
func validate_message(message: GFNetworkMessage) -> Dictionary:
	if message == null:
		return _finalize_report([_make_issue("error", "missing_message", "Network message is null.")])
	if message.message_type != message_type:
		return _finalize_report([_make_issue("error", "message_type_mismatch", "Network message_type does not match contract.")])
	return validate_payload(message.payload)


## 描述消息契约。
## @return 描述字典。
func describe() -> Dictionary:
	var field_descriptions: Array[Dictionary] = []
	for field: GFNetworkContractField in fields:
		if field != null:
			field_descriptions.append(field.describe())
	return {
		"message_type": message_type,
		"display_name": get_display_name(),
		"channel_id": channel_id,
		"field_count": field_descriptions.size(),
		"fields": field_descriptions,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _has_payload_key(payload: Dictionary, field_name: StringName) -> bool:
	return payload.has(field_name) or payload.has(String(field_name))


func _get_payload_value(payload: Dictionary, field_name: StringName, default_value: Variant) -> Variant:
	if payload.has(field_name):
		return payload[field_name]
	return payload.get(String(field_name), default_value)


func _with_message_context(issues: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for issue_variant: Variant in issues:
		var issue := issue_variant as Dictionary
		if issue == null:
			continue
		var copy := issue.duplicate(true)
		copy["message_type"] = message_type
		result.append(copy)
	return result


func _make_issue(severity: String, kind: String, message: String, field_name: String = "") -> Dictionary:
	var issue := {
		"severity": severity,
		"kind": kind,
		"message_type": message_type,
		"message": message,
	}
	if not field_name.is_empty():
		issue["field_name"] = field_name
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
