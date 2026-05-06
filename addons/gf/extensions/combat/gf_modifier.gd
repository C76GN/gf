class_name GFModifier
extends RefCounted


## GFModifier: 属性修饰器数据类。
##
## 定义了如何修改一个通用属性（如加值、乘值）。
## `attribute_id` 表示目标属性，`source_id` 表示来源，避免把“改谁”和“从哪来”混在一起。
## 通常由 Buff、装备或被动技能产生。


# --- 枚举 ---

## 修饰器计算类型。
enum Type {
	BASE_ADD,    ## 基础加值 (BaseAdd)
	PERCENT_ADD, ## 百分比乘区 (PercentAdd)
	FINAL_ADD,   ## 最终加值 (FinalAdd)
}


# --- 公共变量 ---

## 修饰器类型。
var type: Type = Type.BASE_ADD

## 修饰器的数值。
var value: float = 0.0

## 目标属性标识，例如 &"ATK"、&"HP"。
var attribute_id: StringName = &""

## 来源标识，例如 Buff ID、装备 ID 或被动技能 ID，用于查找和移除。
var source_id: StringName = &""

## 兼容旧字段名。新代码请使用 source_id。
var source_tag: StringName:
	get:
		return source_id
	set(p_source_tag):
		source_id = p_source_tag


# --- Godot 生命周期方法 ---

func _init(
	p_type: Type = Type.BASE_ADD,
	p_value: float = 0.0,
	p_attribute_id: StringName = &"",
	p_source_id: StringName = &""
) -> void:
	type = p_type
	value = p_value
	attribute_id = p_attribute_id
	source_id = p_source_id


# --- 公共方法 ---

## 静态工厂方法：创建基础加值修饰器。
## @param p_value: 修饰器数值。
## @param p_attribute_id: 修饰器作用的属性标识。
## @param p_source_id: 修饰器来源标识。
static func create_base_add(
	p_value: float,
	p_attribute_id: StringName = &"",
	p_source_id: StringName = &""
) -> GFModifier:
	return GFModifier.new(Type.BASE_ADD, p_value, p_attribute_id, p_source_id)


## 静态工厂方法：创建百分比加值修饰器。
## @param p_value: 修饰器数值。
## @param p_attribute_id: 修饰器作用的属性标识。
## @param p_source_id: 修饰器来源标识。
static func create_percent_add(
	p_value: float,
	p_attribute_id: StringName = &"",
	p_source_id: StringName = &""
) -> GFModifier:
	return GFModifier.new(Type.PERCENT_ADD, p_value, p_attribute_id, p_source_id)


## 静态工厂方法：创建最终加值修饰器。
## @param p_value: 修饰器数值。
## @param p_attribute_id: 修饰器作用的属性标识。
## @param p_source_id: 修饰器来源标识。
static func create_final_add(
	p_value: float,
	p_attribute_id: StringName = &"",
	p_source_id: StringName = &""
) -> GFModifier:
	return GFModifier.new(Type.FINAL_ADD, p_value, p_attribute_id, p_source_id)
