## GFInventoryItemDefinition: 通用库存物品定义。
##
## 只描述库存系统需要理解的堆叠、分类和实例数据匹配规则，
## 不规定品质、装备、货币、掉落等项目业务语义。
class_name GFInventoryItemDefinition
extends Resource


# --- 导出变量 ---

## 物品稳定标识。
@export var item_id: StringName = &""

## 显示名称，供项目 UI 或编辑器工具使用。
@export var display_name: String = ""

## 描述文本，供项目 UI 或编辑器工具使用。
@export_multiline var description: String = ""

## 可选图标资源。
@export var icon: Texture2D = null

## 单个堆叠最多容纳的数量。
@export var max_stack_amount: int:
	get:
		return _max_stack_amount
	set(value):
		_max_stack_amount = maxi(value, 1)

## 同一物品最多占用的堆叠数量。小于等于 0 表示不限制。
@export var max_stack_count: int:
	get:
		return _max_stack_count
	set(value):
		_max_stack_count = maxi(value, 0)

## 分类标签。框架只保存和匹配，不解释具体含义。
@export var categories: Array[StringName] = []

## 默认实例数据。空堆叠或空输入会按这些默认值参与兼容性比较。
@export var default_instance_data: Dictionary = {}

## 用于判断堆叠兼容性的实例数据字段。为空时比较完整实例数据。
@export var stack_key_fields: PackedStringArray = PackedStringArray()

## 项目自定义元数据。
@export var metadata: Dictionary = {}


# --- 公共变量 ---

## 可选堆叠兼容性回调。签名为 Callable(left: Dictionary, right: Dictionary, definition: GFInventoryItemDefinition) -> bool。
var compatibility_checker: Callable = Callable()


# --- 私有变量 ---

var _max_stack_amount: int = 99
var _max_stack_count: int = 0


# --- 公共方法 ---

## 获取稳定物品标识。
## @return 物品标识。
func get_item_id() -> StringName:
	return item_id


## 获取可显示名称。
## @return 显示名称；为空时回退到 item_id 或资源文件名。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if item_id != &"":
		return String(item_id)
	if not resource_path.is_empty():
		return resource_path.get_file().get_basename().capitalize()
	return "Inventory Item"


## 检查是否包含分类标签。
## @param category: 分类标签。
## @return 包含时返回 true。
func has_category(category: StringName) -> bool:
	return categories.has(category)


## 检查是否满足全部分类标签。
## @param required_categories: 需要匹配的分类标签。
## @return 全部满足时返回 true。
func matches_categories(required_categories: Array[StringName]) -> bool:
	for category: StringName in required_categories:
		if not categories.has(category):
			return false
	return true


## 规范化实例数据。与默认实例数据等价时返回空字典。
## @param instance_data: 实例数据。
## @return 规范化后的实例数据副本。
func normalize_instance_data(instance_data: Dictionary = {}) -> Dictionary:
	var data := instance_data.duplicate(true)
	if are_instance_data_compatible(data, default_instance_data):
		return {}
	return data


## 判断两份实例数据是否可以合并到同一堆叠。
## @param left: 左侧实例数据。
## @param right: 右侧实例数据。
## @return 可合并返回 true。
func are_instance_data_compatible(left: Dictionary = {}, right: Dictionary = {}) -> bool:
	var left_data := _with_defaults(left)
	var right_data := _with_defaults(right)
	if compatibility_checker.is_valid():
		return bool(compatibility_checker.call(left_data.duplicate(true), right_data.duplicate(true), self))
	if stack_key_fields.is_empty():
		return left_data == right_data

	for field_name: String in stack_key_fields:
		if left_data.get(field_name) != right_data.get(field_name):
			return false
	return true


## 转换为字典。
## @return 可序列化字典。
func to_dict() -> Dictionary:
	var category_names := PackedStringArray()
	for category: StringName in categories:
		category_names.append(String(category))
	return {
		"item_id": String(item_id),
		"display_name": display_name,
		"description": description,
		"max_stack_amount": max_stack_amount,
		"max_stack_count": max_stack_count,
		"categories": category_names,
		"default_instance_data": default_instance_data.duplicate(true),
		"stack_key_fields": stack_key_fields.duplicate(),
		"metadata": metadata.duplicate(true),
	}


## 应用字典数据。
## @param data: 字典数据。
func apply_dict(data: Dictionary) -> void:
	item_id = StringName(String(data.get("item_id", item_id)))
	display_name = String(data.get("display_name", display_name))
	description = String(data.get("description", description))
	max_stack_amount = int(data.get("max_stack_amount", max_stack_amount))
	max_stack_count = int(data.get("max_stack_count", max_stack_count))
	categories.clear()
	var raw_categories := data.get("categories", PackedStringArray())
	for category: Variant in raw_categories:
		categories.append(StringName(String(category)))
	var default_data := data.get("default_instance_data", {}) as Dictionary
	default_instance_data = default_data.duplicate(true) if default_data != null else {}
	var raw_stack_fields := data.get("stack_key_fields", PackedStringArray())
	stack_key_fields = PackedStringArray()
	for field_name: Variant in raw_stack_fields:
		stack_key_fields.append(String(field_name))
	var metadata_data := data.get("metadata", {}) as Dictionary
	metadata = metadata_data.duplicate(true) if metadata_data != null else {}


## 从字典创建物品定义。
## @param data: 字典数据。
## @return 物品定义。
static func from_dict(data: Dictionary) -> GFInventoryItemDefinition:
	var definition := GFInventoryItemDefinition.new()
	definition.apply_dict(data)
	return definition


# --- 私有/辅助方法 ---

func _with_defaults(instance_data: Dictionary) -> Dictionary:
	var result := default_instance_data.duplicate(true)
	for key: Variant in instance_data.keys():
		result[key] = instance_data[key]
	return result
