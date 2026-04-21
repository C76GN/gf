class_name GFModifier
extends RefCounted


## GFModifier: 属性修饰器数据类。
## 
## 定义了如何修改一个通用属性（如加值、乘值）。
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

## 来源标识（例如 Buff 的 ID 或装备 ID），用于查找和移除。
var source_tag: StringName = &""


# --- Godot 生命周期方法 ---

func _init(p_type: Type = Type.BASE_ADD, p_value: float = 0.0, p_source_tag: StringName = &"") -> void:
	type = p_type
	value = p_value
	source_tag = p_source_tag


# --- 公共方法 ---

## 静态工厂方法：创建基础加值修饰器。
static func create_base_add(p_value: float, p_source_tag: StringName = &"") -> GFModifier:
	return GFModifier.new(Type.BASE_ADD, p_value, p_source_tag)


## 静态工厂方法：创建百分比加值修饰器。
static func create_percent_add(p_value: float, p_source_tag: StringName = &"") -> GFModifier:
	return GFModifier.new(Type.PERCENT_ADD, p_value, p_source_tag)


## 静态工厂方法：创建最终加值修饰器。
static func create_final_add(p_value: float, p_source_tag: StringName = &"") -> GFModifier:
	return GFModifier.new(Type.FINAL_ADD, p_value, p_source_tag)
