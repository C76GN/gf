## GFCombatHitContext: 一次通用命中交互的上下文。
##
## 只保存 source、target、hit_id、payload、位置和元数据。
## 它不解释伤害、阵营、生命值、命中结果或任何业务语义。
## [br]
## @api public
## [br]
## @category value_object
## [br]
## @since 3.17.0
class_name GFCombatHitContext
extends RefCounted


# --- 公共变量 ---

## 命中发起者。
## [br]
## @api public
var source: Object = null

## 命中目标。
## [br]
## @api public
var target: Object = null

## 命中 ID。
## [br]
## @api public
var hit_id: StringName = &""

## 命中携带的数据。框架不解释该字段。
## [br]
## @api public
## [br]
## @schema payload: Variant，项目自定义命中载荷；框架只复制并透传。
var payload: Variant = null

## 通用强度值。框架不解释该字段。
## [br]
## @api public
var magnitude: float = 0.0

## 命中标签。框架不解释该字段。
## [br]
## @api public
var tags: Array[StringName] = []

## 2D 命中位置。
## [br]
## @api public
var position_2d: Vector2 = Vector2.ZERO

## 2D 命中法线。
## [br]
## @api public
var normal_2d: Vector2 = Vector2.ZERO

## 3D 命中位置。
## [br]
## @api public
var position_3d: Vector3 = Vector3.ZERO

## 3D 命中法线。
## [br]
## @api public
var normal_3d: Vector3 = Vector3.ZERO

## 项目自定义元数据。框架不解释该字段。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，项目自定义命中元数据；框架只复制并透传。
var metadata: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(
	p_source: Object = null,
	p_target: Object = null,
	p_payload: Variant = null,
	p_hit_id: StringName = &""
) -> void:
	source = p_source
	target = p_target
	payload = p_payload
	hit_id = p_hit_id


# --- 公共方法 ---

## 设置 source 并返回自身。
## [br]
## @api public
## [br]
## @param value: source 对象。
## [br]
## @return 当前上下文。
func with_source(value: Object) -> GFCombatHitContext:
	source = value
	return self


## 设置 target 并返回自身。
## [br]
## @api public
## [br]
## @param value: target 对象。
## [br]
## @return 当前上下文。
func with_target(value: Object) -> GFCombatHitContext:
	target = value
	return self


## 设置 hit_id 并返回自身。
## [br]
## @api public
## [br]
## @param value: 命中 ID。
## [br]
## @return 当前上下文。
func with_hit_id(value: StringName) -> GFCombatHitContext:
	hit_id = value
	return self


## 设置 payload 并返回自身。
## [br]
## @api public
## [br]
## @param value: payload 数据。
## [br]
## @return 当前上下文。
## [br]
## @schema value: Variant，项目自定义命中载荷；框架只复制并透传。
func with_payload(value: Variant) -> GFCombatHitContext:
	payload = value
	return self


## 设置通用强度值并返回自身。
## [br]
## @api public
## [br]
## @param value: 通用强度值。
## [br]
## @return 当前上下文。
func with_magnitude(value: float) -> GFCombatHitContext:
	magnitude = value
	return self


## 设置标签并返回自身。
## [br]
## @api public
## [br]
## @param value: 标签数组。
## [br]
## @return 当前上下文。
func with_tags(value: Array[StringName]) -> GFCombatHitContext:
	tags = value.duplicate()
	return self


## 设置元数据并返回自身。
## [br]
## @api public
## [br]
## @param value: 元数据。
## [br]
## @return 当前上下文。
## [br]
## @schema value: Dictionary，项目自定义命中元数据；框架只复制并透传。
func with_metadata(value: Dictionary) -> GFCombatHitContext:
	metadata = value.duplicate(true)
	return self


## 转换为字典快照。
## [br]
## @api public
## [br]
## @return 字典快照。
## [br]
## @schema return: Dictionary，包含 source、target、hit_id、payload、magnitude、tags、position_2d、normal_2d、position_3d、normal_3d 和 metadata。
func to_dict() -> Dictionary:
	return {
		"source": source,
		"target": target,
		"hit_id": hit_id,
		"payload": GFVariantData.duplicate_variant(payload),
		"magnitude": magnitude,
		"tags": tags.duplicate(),
		"position_2d": position_2d,
		"normal_2d": normal_2d,
		"position_3d": position_3d,
		"normal_3d": normal_3d,
		"metadata": metadata.duplicate(true),
	}
