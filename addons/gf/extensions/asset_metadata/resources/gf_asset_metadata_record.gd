## GFAssetMetadataRecord: 资产元数据记录。
##
## 记录某个导入资产、节点或资源片段上的结构化元数据，不解释字段业务含义。
class_name GFAssetMetadataRecord
extends Resource


# --- 常量 ---

const GFVariantDataBase = preload("res://addons/gf/standard/foundation/variant/gf_variant_data.gd")


# --- 导出变量 ---

## 元数据来源资产路径。
@export var source_path: String = ""

## 元数据所属对象相对路径。节点树中通常是相对根节点的 NodePath。
@export var subject_path: NodePath = NodePath(".")

## 元数据所属对象类别，例如 node、resource 或 asset。
@export var subject_kind: StringName = &""

## 结构化元数据。框架只复制和查询，不解释业务字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 配置记录。
## @param p_source_path: 来源资产路径。
## @param p_subject_path: 所属对象路径。
## @param p_subject_kind: 所属对象类别。
## @param p_metadata: 结构化元数据。
## @return 当前记录。
func configure(
	p_source_path: String = "",
	p_subject_path: NodePath = NodePath("."),
	p_subject_kind: StringName = &"",
	p_metadata: Dictionary = {}
) -> GFAssetMetadataRecord:
	source_path = p_source_path
	subject_path = p_subject_path
	subject_kind = p_subject_kind
	metadata = p_metadata.duplicate(true)
	return self


## 检查记录是否没有元数据。
## @return 没有元数据时返回 true。
func is_empty() -> bool:
	return metadata.is_empty()


## 检查元数据键是否存在。StringName 与 String 形式会被同时识别。
## @param key: 元数据键。
## @return 存在时返回 true。
func has_value(key: StringName) -> bool:
	return metadata.has(key) or metadata.has(String(key))


## 读取元数据值并返回安全副本。
## @param key: 元数据键。
## @param default_value: 缺失时返回的默认值。
## @return 元数据值副本或默认值。
func get_value(key: StringName, default_value: Variant = null) -> Variant:
	if metadata.has(key):
		return GFVariantDataBase.duplicate_variant(metadata[key])

	var key_text := String(key)
	if metadata.has(key_text):
		return GFVariantDataBase.duplicate_variant(metadata[key_text])
	return GFVariantDataBase.duplicate_variant(default_value)


## 转换为字典。
## @return 记录字典副本。
func to_dict() -> Dictionary:
	return {
		"source_path": source_path,
		"subject_path": String(subject_path),
		"subject_kind": subject_kind,
		"metadata": metadata.duplicate(true),
	}


## 从字典应用字段。
## @param data: 输入字典。
func apply_dict(data: Dictionary) -> void:
	source_path = String(data.get("source_path", source_path))
	subject_path = NodePath(String(data.get("subject_path", String(subject_path))))
	subject_kind = StringName(String(data.get("subject_kind", subject_kind)))
	var metadata_value: Variant = data.get("metadata", metadata)
	metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}


## 创建记录深拷贝。
## @return 新记录。
func duplicate_record() -> GFAssetMetadataRecord:
	var record := get_script().new() as GFAssetMetadataRecord
	record.apply_dict(to_dict())
	return record


## 从字典创建记录。
## @param data: 输入字典。
## @return 新记录。
static func from_dict(data: Dictionary) -> GFAssetMetadataRecord:
	var record := (load("res://addons/gf/extensions/asset_metadata/resources/gf_asset_metadata_record.gd") as Script).new() as GFAssetMetadataRecord
	record.apply_dict(data)
	return record
