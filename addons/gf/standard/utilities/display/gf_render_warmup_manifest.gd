## GFRenderWarmupManifest: 通用渲染预热清单。
##
## 只描述需要提前触碰的渲染相关资源，不绑定具体关卡、材质命名或项目加载流程。
class_name GFRenderWarmupManifest
extends Resource


# --- 导出变量 ---

## 清单稳定标识，便于诊断和队列统计。
@export var manifest_id: StringName = &""

## 预热条目列表。条目字段为 resource_path、resource、kind、type_hint、metadata。
@export var entries: Array[Dictionary] = []

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 添加资源路径条目。
## @param resource_path: 资源路径。
## @param kind: 资源类别提示。
## @param type_hint: ResourceLoader 类型提示。
## @param entry_metadata: 条目元数据。
## @return 添加后的条目索引；失败返回 -1。
func add_resource_path(
	resource_path: String,
	kind: StringName = &"",
	type_hint: String = "",
	entry_metadata: Dictionary = {}
) -> int:
	if resource_path.is_empty():
		return -1

	entries.append({
		"resource_path": resource_path,
		"resource": null,
		"kind": kind,
		"type_hint": type_hint,
		"metadata": entry_metadata.duplicate(true),
	})
	return entries.size() - 1


## 添加已持有的资源条目。
## @param resource: 资源实例。
## @param kind: 资源类别提示。
## @param entry_metadata: 条目元数据。
## @return 添加后的条目索引；失败返回 -1。
func add_resource(resource: Resource, kind: StringName = &"", entry_metadata: Dictionary = {}) -> int:
	if resource == null:
		return -1

	entries.append({
		"resource_path": resource.resource_path,
		"resource": resource,
		"kind": kind,
		"type_hint": "",
		"metadata": entry_metadata.duplicate(true),
	})
	return entries.size() - 1


## 合并另一个清单的条目。
## @param manifest: 来源清单。
## @return 新增条目数量。
func append_manifest(manifest: GFRenderWarmupManifest) -> int:
	if manifest == null:
		return 0

	var added_count := 0
	for entry: Dictionary in manifest.get_entries():
		entries.append(entry)
		added_count += 1
	return added_count


## 清空清单条目。
func clear() -> void:
	entries.clear()


## 获取条目数量。
## @return 条目数量。
func get_entry_count() -> int:
	return entries.size()


## 检查清单是否为空。
## @return 为空返回 true。
func is_empty() -> bool:
	return entries.is_empty()


## 规范化预热条目字典。
## @param entry: 输入条目。
## @return 包含 resource_path、resource、kind、type_hint、metadata 的规范化副本。
static func normalize_entry(entry: Dictionary) -> Dictionary:
	var metadata_value: Variant = entry.get("metadata", {})
	return {
		"resource_path": _variant_to_string(entry.get("resource_path", "")),
		"resource": entry.get("resource", null),
		"kind": StringName(_variant_to_string(entry.get("kind", &""))),
		"type_hint": _variant_to_string(entry.get("type_hint", "")),
		"metadata": (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {},
	}


## 获取条目副本。
## @return 条目数组副本。
func get_entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in entries:
		result.append(normalize_entry(entry))
	return result


## 描述清单。
## @return 清单描述字典。
func describe() -> Dictionary:
	var described_entries: Array[Dictionary] = []
	for entry: Dictionary in entries:
		var normalized := normalize_entry(entry)
		described_entries.append({
			"resource_path": _variant_to_string(normalized.get("resource_path", "")),
			"kind": StringName(normalized.get("kind", &"")),
			"type_hint": _variant_to_string(normalized.get("type_hint", "")),
			"metadata": (normalized.get("metadata", {}) as Dictionary).duplicate(true),
			"has_resource": normalized.get("resource", null) is Resource,
		})
	return {
		"manifest_id": manifest_id,
		"entry_count": entries.size(),
		"entries": described_entries,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

static func _variant_to_string(value: Variant) -> String:
	if value == null:
		return ""
	if value is String:
		return value as String
	return str(value)
