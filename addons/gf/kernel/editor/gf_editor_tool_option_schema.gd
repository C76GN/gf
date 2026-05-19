@tool

## GFEditorToolOptionSchema: 编辑器工具选项集合声明。
##
## 为工具面板、持久化和调试快照提供稳定的选项描述与值规范化入口。
class_name GFEditorToolOptionSchema
extends Resource


# --- 导出变量 ---

## 工具选项列表。
@export var options: Array[GFEditorToolOption] = []

## 可选元数据，供项目层扩展使用。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 添加或替换选项声明。
## @param option: 选项声明。
## @return 添加成功返回 true。
func add_option(option: GFEditorToolOption) -> bool:
	if option == null or not option.is_valid_definition():
		return false
	for index: int in range(options.size()):
		var current := options[index]
		if current != null and current.option_id == option.option_id:
			options[index] = option
			return true
	options.append(option)
	return true


## 移除选项声明。
## @param option_id: 选项标识。
## @return 移除成功返回 true。
func remove_option(option_id: StringName) -> bool:
	for index: int in range(options.size()):
		var option := options[index]
		if option != null and option.option_id == option_id:
			options.remove_at(index)
			return true
	return false


## 清空选项声明。
func clear_options() -> void:
	options.clear()


## 获取选项声明。
## @param option_id: 选项标识。
## @return 找到时返回选项声明，否则返回 null。
func get_option(option_id: StringName) -> GFEditorToolOption:
	for option: GFEditorToolOption in options:
		if option != null and option.option_id == option_id:
			return option
	return null


## 检查选项声明是否存在。
## @param option_id: 选项标识。
## @return 存在返回 true。
func has_option(option_id: StringName) -> bool:
	return get_option(option_id) != null


## 获取选项 ID 列表。
## @return 排序后的选项 ID。
func get_option_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for option: GFEditorToolOption in options:
		if option != null and option.option_id != &"":
			result.append(String(option.option_id))
	result.sort()
	return result


## 获取默认值字典。
## @return 选项 ID 到默认值的字典。
func get_default_values() -> Dictionary:
	var result: Dictionary = {}
	for option: GFEditorToolOption in options:
		if option != null and option.option_id != &"":
			result[option.option_id] = option.normalize_value(null)
	return result


## 规范化一组选项值。
## @param values: 输入选项值。
## @param include_defaults: 为 true 时补齐缺失默认值。
## @return 规范化后的选项字典。
func normalize_values(values: Dictionary, include_defaults: bool = true) -> Dictionary:
	var result := get_default_values() if include_defaults else {}
	for key: Variant in values.keys():
		var option_id := StringName(key)
		var option := get_option(option_id)
		if option == null:
			continue
		result[option_id] = option.normalize_value(values[key])
	return result


## 校验一组选项值。
## @param values: 输入选项值。
## @return 校验报告字典。
func validate_values(values: Dictionary) -> Dictionary:
	var report := {
		"ok": true,
		"error_count": 0,
		"warning_count": 0,
		"issues": [],
	}
	var issues := report["issues"] as Array
	for key: Variant in values.keys():
		var option_id := StringName(key)
		var option := get_option(option_id)
		if option == null:
			issues.append(_make_issue("warning", "unknown_option", option_id, "未知工具选项：%s。" % String(option_id)))
			report["warning_count"] = int(report["warning_count"]) + 1
			continue
		if not option.is_value_valid(values[key]):
			issues.append(_make_issue("error", "invalid_option_value", option_id, "工具选项值类型不匹配：%s。" % String(option_id)))
			report["error_count"] = int(report["error_count"]) + 1
			report["ok"] = false
	return report


## 创建同内容拷贝。
## @return 新选项集合声明。
func duplicate_schema() -> GFEditorToolOptionSchema:
	var schema := GFEditorToolOptionSchema.new()
	schema.metadata = metadata.duplicate(true)
	for option: GFEditorToolOption in options:
		schema.options.append(option.duplicate_option() if option != null else null)
	return schema


## 导出选项集合摘要。
## @return 选项集合字典。
func describe() -> Dictionary:
	var option_descriptions: Array[Dictionary] = []
	for option: GFEditorToolOption in options:
		if option != null:
			option_descriptions.append(option.describe())
	return {
		"options": option_descriptions,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _make_issue(severity: String, kind: String, option_id: StringName, message: String) -> Dictionary:
	return {
		"severity": severity,
		"kind": kind,
		"option_id": option_id,
		"message": message,
	}
