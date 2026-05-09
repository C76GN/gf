## GFHurtBox3D: 3D 通用命中接收区域。
##
## 节点只过滤和接收 GFCombatHitContext，不直接修改生命、属性或 Buff。
class_name GFHurtBox3D
extends Area3D


# --- 信号 ---

## 命中进入自定义校验阶段时发出。
## @param context: 命中上下文。
## @param report: 当前结果报告副本。
signal hit_validating(context: GFCombatHitContext, report: Dictionary)

## 命中被接受时发出。
## @param context: 命中上下文。
## @param report: 结果报告。
signal hit_received(context: GFCombatHitContext, report: Dictionary)

## 命中被拒绝时发出。
## @param context: 命中上下文。
## @param report: 结果报告。
signal hit_rejected(context: GFCombatHitContext, report: Dictionary)


# --- 常量 ---

const _MESSAGE_RECEIVER_SUPPORT: Script = preload("res://addons/gf/extensions/common/gf_message_receiver_support.gd")


# --- 导出变量 ---

## 是否允许接收命中。
@export var enabled: bool = true

## 非空时，只接受这些命中 ID。
@export var accepted_hit_ids: Array[StringName] = []

## 始终拒绝的命中 ID。
@export var rejected_hit_ids: Array[StringName] = []

## 接收器自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共变量 ---

## 自定义校验回调，建议签名为 func(context: GFCombatHitContext, report: Dictionary) -> Variant。
## 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。
var validation_callback: Callable = Callable()


# --- 公共方法 ---

## 检查指定命中 ID 是否可被当前接收器接受。
## @param p_hit_id: 命中 ID。
## @return 可接受时返回 true。
func can_receive_hit(p_hit_id: StringName = &"") -> bool:
	return bool(_MESSAGE_RECEIVER_SUPPORT._can_receive(enabled, accepted_hit_ids, rejected_hit_ids, p_hit_id))


## 接收一次命中。
## @param context: 命中上下文。
## @return 统一结果报告。
func receive_hit(context: GFCombatHitContext) -> Dictionary:
	var hit_id_value := context.hit_id if context != null else &""
	var report: Dictionary = _MESSAGE_RECEIVER_SUPPORT._receive(
		self,
		context,
		"hit_id",
		hit_id_value,
		enabled,
		accepted_hit_ids,
		rejected_hit_ids,
		metadata,
		validation_callback,
		&"hit_validating",
		&"hit_received",
		&"hit_rejected",
		"Hit context is null.",
		"Hurt box is disabled.",
		"Hit id is rejected.",
		"Hit id is not accepted."
	) as Dictionary
	return report
