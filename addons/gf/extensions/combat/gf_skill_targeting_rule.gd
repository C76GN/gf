# addons/gf/extensions/combat/gf_skill_targeting_rule.gd
class_name GFSkillTargetingRule
extends Resource


## GFSkillTargetingRule: 技能索敌规则资源。
##
## 使用纯数据结构定义索敌逻辑，包括形状、范围、排序规则及标签过滤。


# --- 枚举 ---

## 索敌形状。
enum Shape {
	## 轴对齐矩形 (通常用于简单范围)
	RECTANGLE,
	## 圆形 (最常用)
	CIRCLE,
	## 扇形 (通常用于朝向性技能)
	SECTOR,
	## 单体目标
	SINGLE,
}

## 排序规则。
enum SortRule {
	## 距离最近
	DISTANCE_CLOSEST,
	## 距离最远
	DISTANCE_FURTHEST,
	## 属性值最低 (需要指定 sort_attribute_name)
	ATTRIBUTE_LOWEST,
	## 属性值最高 (需要指定 sort_attribute_name)
	ATTRIBUTE_HIGHEST,
	## 随机选择
	RANDOM,
}


# --- 导出变量 ---

@export_group("空间设置")

## 索敌形状。
@export var shape: Shape = Shape.CIRCLE

## 索敌半径/距离。
@export var radius: float = 100.0

## 最大目标数量。
@export var max_count: int = 1

@export_group("排序规则")

## 排序逻辑。
@export var sort_rule: SortRule = SortRule.DISTANCE_CLOSEST

## 当按属性值排序时，使用的属性名称 (StringName)。
@export var sort_attribute_name: StringName = &"HP"

@export_group("标签过滤")

## 目标必须拥有的标签列表。
@export var require_tags: Array[StringName] = []

## 目标禁止拥有的标签列表。
@export var ignore_tags: Array[StringName] = []
