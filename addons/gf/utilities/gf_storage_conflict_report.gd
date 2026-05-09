## GFStorageConflictReport: 存储同步冲突的通用报告数据。
##
## 该资源只描述冲突，不决定如何解决冲突。项目可以把它用于云同步、
## 多端合并、调试 UI 或自动化测试。
class_name GFStorageConflictReport
extends Resource


# --- 枚举 ---

## 冲突解决策略。
enum Resolution {
	## 尚未决定。
	UNRESOLVED,
	## 使用本地值。
	USE_LOCAL,
	## 使用远端值。
	USE_REMOTE,
	## 使用合并后的值。
	MERGED,
	## 跳过该冲突。
	SKIPPED,
}


# --- 导出变量 ---

## 冲突所属逻辑文件名。
@export var file_name: String = ""

## 冲突字段或业务 key。
@export var key: String = ""

## 本地值。
@export var local_value: Variant = null

## 远端值。
@export var remote_value: Variant = null

## 合并后的值。
@export var resolved_value: Variant = null

## 解决策略。
@export var resolution: Resolution = Resolution.UNRESOLVED

## 扩展元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 从字典应用字段。
## @param data: 输入字典。
func apply_dict(data: Dictionary) -> void:
	file_name = String(data.get("file_name", file_name))
	key = String(data.get("key", key))
	local_value = data.get("local_value", local_value)
	remote_value = data.get("remote_value", remote_value)
	resolved_value = data.get("resolved_value", resolved_value)
	resolution = clampi(int(data.get("resolution", resolution)), Resolution.UNRESOLVED, Resolution.SKIPPED) as Resolution
	var metadata_value: Variant = data.get("metadata", metadata)
	metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}


## 转换为字典。
## @return 字典副本。
func to_dict() -> Dictionary:
	return {
		"file_name": file_name,
		"key": key,
		"local_value": GFVariantUtility.duplicate_variant(local_value),
		"remote_value": GFVariantUtility.duplicate_variant(remote_value),
		"resolved_value": GFVariantUtility.duplicate_variant(resolved_value),
		"resolution": resolution,
		"metadata": metadata.duplicate(true),
	}


## 复制冲突报告。
## @return 新报告实例。
func duplicate_report() -> GFStorageConflictReport:
	var report := GFStorageConflictReport.new()
	report.apply_dict(to_dict())
	return report


## 是否已经解决。
## @return resolution 不是 UNRESOLVED 时返回 true。
func is_resolved() -> bool:
	return resolution != Resolution.UNRESOLVED


## 从字典创建冲突报告。
## @param data: 输入字典。
## @return 新报告实例。
static func from_dict(data: Dictionary) -> GFStorageConflictReport:
	var report := GFStorageConflictReport.new()
	report.apply_dict(data)
	return report
