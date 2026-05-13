## GFRuntimeTunableProperty: 运行时可调属性声明。
##
## 用显式 schema 描述一个目标对象上允许被运行时工具读取或写入的属性。
## 它不自动扫描业务对象，也不决定具体调参界面。
class_name GFRuntimeTunableProperty
extends Resource


# --- 枚举 ---

## 运行时值类型约束。
enum ValueKind {
	## 不转换类型。
	ANY,
	## 布尔值。
	BOOL,
	## 整数。
	INT,
	## 浮点数。
	FLOAT,
	## 字符串。
	STRING,
	## StringName。
	STRING_NAME,
	## Vector2。
	VECTOR2,
	## Vector3。
	VECTOR3,
	## Color。
	COLOR,
}


# --- 导出变量 ---

## 属性 ID，在同一目标内必须唯一。
@export var property_id: StringName = &""

## 展示标签；为空时使用 property_id。
@export var label: String = ""

## 展示分组。
@export var group: String = "Runtime"

## 目标对象上的属性路径。使用 getter/setter 回调时可为空。
@export var property_name: NodePath = NodePath("")

## 值类型约束。
@export var value_kind: ValueKind = ValueKind.ANY

## 是否只读。
@export var read_only: bool = false

## 是否默认出现在快照中。
@export var visible: bool = true

## 是否启用最小值限制，仅对 int/float 生效。
@export var has_min_value: bool = false

## 最小值。
@export var min_value: float = 0.0

## 是否启用最大值限制，仅对 int/float 生效。
@export var has_max_value: bool = false

## 最大值。
@export var max_value: float = 0.0

## 建议步长，仅供 UI 使用。
@export var step: float = 1.0

## 可选值列表。非空时写入值必须归一到列表内。
@export var options: Array = []

## 自定义元数据。
@export var metadata: Dictionary = {}


# --- 公共变量 ---

## 可选读取回调，签名为 `func(target: Object, property: GFRuntimeTunableProperty) -> Variant`。
var getter: Callable

## 可选写入回调，签名为 `func(target: Object, property: GFRuntimeTunableProperty, value: Variant) -> void`。
var setter: Callable

## 可选校验回调，签名为 `func(target: Object, property: GFRuntimeTunableProperty, value: Variant) -> bool`。
var validator: Callable


# --- Godot 生命周期方法 ---

func _init(
	p_property_id: StringName = &"",
	p_property_name: NodePath = NodePath(""),
	p_value_kind: ValueKind = ValueKind.ANY
) -> void:
	property_id = p_property_id
	property_name = p_property_name
	value_kind = p_value_kind


# --- 公共方法 ---

## 设置基础字段并返回自身，便于代码构造 schema。
## @param p_property_id: 属性 ID。
## @param p_property_name: 目标属性路径。
## @param p_value_kind: 值类型约束。
## @return 当前属性声明。
func setup(
	p_property_id: StringName,
	p_property_name: NodePath = NodePath(""),
	p_value_kind: ValueKind = ValueKind.ANY
) -> GFRuntimeTunableProperty:
	property_id = p_property_id
	property_name = p_property_name
	value_kind = p_value_kind
	return self


## 设置数值范围并返回自身。
## @param p_min_value: 最小值。
## @param p_max_value: 最大值。
## @param p_step: 建议步长。
## @return 当前属性声明。
func with_range(p_min_value: float, p_max_value: float, p_step: float = 1.0) -> GFRuntimeTunableProperty:
	has_min_value = true
	has_max_value = true
	min_value = p_min_value
	max_value = p_max_value
	step = maxf(p_step, 0.0)
	return self


## 设置可选值列表并返回自身。
## @param p_options: 可选值列表。
## @return 当前属性声明。
func with_options(p_options: Array) -> GFRuntimeTunableProperty:
	options = p_options.duplicate(true)
	return self


## 读取目标对象当前值。
## @param target: 目标对象。
## @return 当前值；无法读取时返回 null。
func read_value(target: Object) -> Variant:
	if getter.is_valid():
		return getter.call(target, self)
	if not is_instance_valid(target) or property_name.is_empty():
		return null
	return target.get_indexed(property_name)


## 写入目标对象。
## @param target: 目标对象。
## @param value: 请求写入的值。
## @return 写入成功返回 true。
func write_value(target: Object, value: Variant) -> bool:
	if read_only or not is_instance_valid(target):
		return false

	var normalized_value := normalize_value(value)
	if validator.is_valid() and not bool(validator.call(target, self, normalized_value)):
		return false
	if setter.is_valid():
		setter.call(target, self, normalized_value)
		return true
	if property_name.is_empty():
		return false
	target.set_indexed(property_name, normalized_value)
	return true


## 根据 schema 归一化写入值。
## @param value: 输入值。
## @return 归一化后的值。
func normalize_value(value: Variant) -> Variant:
	var normalized: Variant = value
	match value_kind:
		ValueKind.BOOL:
			normalized = bool(value)
		ValueKind.INT:
			normalized = _normalize_int(value)
		ValueKind.FLOAT:
			normalized = _normalize_float(value)
		ValueKind.STRING:
			normalized = String(value)
		ValueKind.STRING_NAME:
			normalized = StringName(String(value))
		ValueKind.VECTOR2:
			normalized = value if value is Vector2 else Vector2.ZERO
		ValueKind.VECTOR3:
			normalized = value if value is Vector3 else Vector3.ZERO
		ValueKind.COLOR:
			normalized = value if value is Color else Color.WHITE
		_:
			pass

	if not options.is_empty() and not options.has(normalized):
		return options[0]
	return normalized


## 生成可序列化 schema 快照。
## @return schema 字典。
func to_schema() -> Dictionary:
	return {
		"property_id": property_id,
		"label": label if not label.is_empty() else String(property_id),
		"group": group,
		"property_name": String(property_name),
		"value_kind": value_kind,
		"read_only": read_only,
		"visible": visible,
		"has_min_value": has_min_value,
		"min_value": min_value,
		"has_max_value": has_max_value,
		"max_value": max_value,
		"step": step,
		"options": options.duplicate(true),
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _normalize_int(value: Variant) -> int:
	var number := int(value)
	if has_min_value:
		number = maxi(number, int(min_value))
	if has_max_value:
		number = mini(number, int(max_value))
	return number


func _normalize_float(value: Variant) -> float:
	var number := float(value)
	if has_min_value:
		number = maxf(number, min_value)
	if has_max_value:
		number = minf(number, max_value)
	return number
