## GFAssetMetadataUtility: 资产元数据收集与查询工具。
##
## 统一管理导入资产元数据在 Object metadata 中的存储键、复制规则和节点树收集流程。
## 它不解释任何项目字段；业务语义应由项目代码或项目扩展消费。
class_name GFAssetMetadataUtility
extends GFUtility


# --- 常量 ---

const GFAssetMetadataRecordBase = preload("res://addons/gf/extensions/asset_metadata/resources/gf_asset_metadata_record.gd")
const GFValidationReportBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")
const GFVariantDataBase = preload("res://addons/gf/standard/foundation/variant/gf_variant_data.gd")

## Object metadata 中保存 GF 资产元数据的默认键。
const META_ASSET_METADATA: StringName = &"gf_asset_metadata"

## Object metadata 中保存元数据来源说明的默认键。
const META_ASSET_METADATA_SOURCE: StringName = &"gf_asset_metadata_source"


# --- 公共方法 ---

## 将任意导入元数据归一为 Dictionary。
## @param value: 输入元数据。Dictionary 会深拷贝；其他非 null 值会保存在 value 字段中。
## @return 归一化后的元数据字典。
static func normalize_metadata(value: Variant) -> Dictionary:
	if value == null:
		return {}
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {
		"value": GFVariantDataBase.duplicate_variant(value),
	}


## 写入对象资产元数据。
## @param target: 目标 Object。
## @param metadata: 结构化元数据。
## @param options: 可选项，支持 metadata_key、source_path、subject_path、subject_kind、metadata_source。
## @return 写入后的记录；目标无效时返回 null。
func write_object_metadata(
	target: Object,
	metadata: Dictionary,
	options: Dictionary = {}
) -> GFAssetMetadataRecord:
	if target == null:
		return null

	var metadata_key := _get_metadata_key(options)
	var normalized_metadata := normalize_metadata(metadata)
	target.set_meta(metadata_key, normalized_metadata)

	var metadata_source := String(options.get("metadata_source", ""))
	if not metadata_source.is_empty():
		target.set_meta(META_ASSET_METADATA_SOURCE, metadata_source)

	return _make_record_for_object(target, normalized_metadata, options)


## 读取对象资产元数据。
## @param target: 目标 Object。
## @param options: 可选项，支持 metadata_key 或 metadata_keys。
## @return 元数据字典副本；不存在时返回空字典。
func read_object_metadata(target: Object, options: Dictionary = {}) -> Dictionary:
	if target == null:
		return {}

	for metadata_key: StringName in _get_metadata_keys(options):
		if not target.has_meta(metadata_key):
			continue

		var value: Variant = target.get_meta(metadata_key)
		return normalize_metadata(value)
	return {}


## 检查对象是否带有资产元数据。
## @param target: 目标 Object。
## @param options: 可选项，支持 metadata_key 或 metadata_keys。
## @return 存在资产元数据时返回 true。
func has_object_metadata(target: Object, options: Dictionary = {}) -> bool:
	if target == null:
		return false
	for metadata_key: StringName in _get_metadata_keys(options):
		if target.has_meta(metadata_key):
			return true
	return false


## 清除对象资产元数据。
## @param target: 目标 Object。
## @param options: 可选项，支持 metadata_key 或 metadata_keys。
func clear_object_metadata(target: Object, options: Dictionary = {}) -> void:
	if target == null:
		return
	for metadata_key: StringName in _get_metadata_keys(options):
		if target.has_meta(metadata_key):
			target.remove_meta(metadata_key)
	if bool(options.get("clear_source", true)) and target.has_meta(META_ASSET_METADATA_SOURCE):
		target.remove_meta(META_ASSET_METADATA_SOURCE)


## 收集节点树中的资产元数据记录。
## @param root: 节点树根节点。
## @param options: 可选项，支持 metadata_key、metadata_keys、source_path、subject_kind、max_depth。
## @return 资产元数据记录列表。
func collect_node_tree(root: Node, options: Dictionary = {}) -> Array[GFAssetMetadataRecord]:
	var records: Array[GFAssetMetadataRecord] = []
	if root == null:
		return records

	var max_depth := int(options.get("max_depth", -1))
	_collect_node_records(root, root, 0, max_depth, options, records)
	return records


## 收集节点树中的资产元数据记录字典。
## @param root: 节点树根节点。
## @param options: 可选项，支持 metadata_key、metadata_keys、source_path、subject_kind、max_depth。
## @return 资产元数据记录字典列表。
func collect_node_tree_dicts(root: Node, options: Dictionary = {}) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for record: GFAssetMetadataRecord in collect_node_tree(root, options):
		result.append(record.to_dict())
	return result


## 构建节点树资产元数据报告。
## @param root: 节点树根节点。
## @param options: 可选项，支持 collect_node_tree() 的参数。
## @return 报告字典。
func build_node_tree_report(root: Node, options: Dictionary = {}) -> Dictionary:
	var report := GFValidationReportBase.new("Asset metadata") as GFValidationReport
	if root == null:
		report.add_error(&"missing_root", "Root node is null.")
		return report.to_dict({}, _get_report_options())

	var entries := collect_node_tree_dicts(root, options)
	return report.to_dict({
		"source_path": _get_source_path(root, options),
		"entry_count": entries.size(),
		"entries": entries,
	}, _get_report_options())


# --- 私有/辅助方法 ---

func _collect_node_records(
	root: Node,
	node: Node,
	depth: int,
	max_depth: int,
	options: Dictionary,
	records: Array[GFAssetMetadataRecord]
) -> void:
	var metadata := read_object_metadata(node, options)
	if not metadata.is_empty():
		records.append(_make_record_for_node(root, node, metadata, options))

	if max_depth >= 0 and depth >= max_depth:
		return
	for child: Node in node.get_children():
		_collect_node_records(root, child, depth + 1, max_depth, options, records)


func _make_record_for_node(
	root: Node,
	node: Node,
	metadata: Dictionary,
	options: Dictionary
) -> GFAssetMetadataRecord:
	var subject_path := NodePath(".")
	if root != node:
		subject_path = root.get_path_to(node)

	var record := GFAssetMetadataRecordBase.new() as GFAssetMetadataRecord
	record.configure(
		_get_source_path(root, options),
		subject_path,
		StringName(options.get("subject_kind", &"node")),
		metadata
	)
	return record


func _make_record_for_object(
	target: Object,
	metadata: Dictionary,
	options: Dictionary
) -> GFAssetMetadataRecord:
	var record := GFAssetMetadataRecordBase.new() as GFAssetMetadataRecord
	record.configure(
		String(options.get("source_path", "")),
		NodePath(String(options.get("subject_path", "."))),
		StringName(options.get("subject_kind", &"object")),
		metadata
	)
	return record


func _get_source_path(root: Node, options: Dictionary) -> String:
	var explicit_source_path := String(options.get("source_path", ""))
	if not explicit_source_path.is_empty():
		return explicit_source_path
	if root != null and not root.scene_file_path.is_empty():
		return root.scene_file_path
	return ""


func _get_metadata_key(options: Dictionary) -> StringName:
	if options.has("metadata_key"):
		return StringName(String(options.get("metadata_key")))
	return META_ASSET_METADATA


func _get_metadata_keys(options: Dictionary) -> Array[StringName]:
	if options.has("metadata_keys"):
		return _to_string_name_array(options.get("metadata_keys"))
	var result: Array[StringName] = []
	result.append(_get_metadata_key(options))
	return result


func _to_string_name_array(value: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if value is PackedStringArray:
		for item: String in value:
			_append_metadata_key(result, StringName(item))
	elif value is Array:
		for item: Variant in value:
			_append_metadata_key(result, StringName(String(item)))
	elif typeof(value) == TYPE_STRING or value is StringName:
		_append_metadata_key(result, StringName(String(value)))

	if result.is_empty():
		result.append(META_ASSET_METADATA)
	return result


func _append_metadata_key(result: Array[StringName], key: StringName) -> void:
	if key != &"" and not result.has(key):
		result.append(key)


func _get_report_options() -> Dictionary:
	return {
		"next_actions": {
			"missing_root": "Pass a valid Node root before collecting asset metadata.",
		},
		"fallback_action": "Review the first reported asset metadata issue.",
		"no_action": "No action required.",
	}
