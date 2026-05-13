## GFInteractionReceiver: 通用交互接收节点。
##
## 用 GFInteractionContext 接收任意交互请求，并提供启用状态、交互 ID 过滤、
## 自定义校验回调和统一结果报告。节点不解释任何业务语义。
class_name GFInteractionReceiver
extends Node


# --- 信号 ---

## 交互进入自定义校验阶段时发出。
## @param context: 交互上下文。
## @param report: 当前结果报告副本。
signal interaction_validating(context: GFInteractionContext, report: Dictionary)

## 交互被接受时发出。
## @param context: 交互上下文。
## @param report: 结果报告。
signal interaction_received(context: GFInteractionContext, report: Dictionary)

## 交互被拒绝时发出。
## @param context: 交互上下文。
## @param report: 结果报告。
signal interaction_rejected(context: GFInteractionContext, report: Dictionary)


# --- 常量 ---

const _MESSAGE_RECEIVER_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_message_receiver_support.gd")


# --- 导出变量 ---

## 是否允许接收交互。
@export var enabled: bool = true

## 非空时，只接受这些交互 ID。
@export var accepted_interaction_ids: Array[StringName] = []

## 始终拒绝的交互 ID。
@export var rejected_interaction_ids: Array[StringName] = []

## 接收器自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共变量 ---

## 自定义校验回调，建议签名为 func(context: GFInteractionContext, report: Dictionary) -> Variant。
## 返回 bool 可直接决定是否接受；返回 Dictionary 可覆盖 ok、reason、metadata 等报告字段。
var validation_callback: Callable = Callable()


# --- 公共方法 ---

## 检查指定交互 ID 是否可被当前接收器接受。
## @param interaction_id: 交互 ID。
## @return 可接受时返回 true。
func can_receive_interaction(interaction_id: StringName = &"") -> bool:
	return bool(_MESSAGE_RECEIVER_SUPPORT._can_receive(
		enabled,
		accepted_interaction_ids,
		rejected_interaction_ids,
		interaction_id
	))


## 接收一次交互。
## @param context: 交互上下文。
## @param interaction_id: 交互 ID。
## @return 统一结果报告。
func receive_interaction(context: GFInteractionContext, interaction_id: StringName = &"") -> Dictionary:
	var report: Dictionary = _MESSAGE_RECEIVER_SUPPORT._receive(
		self,
		context,
		"interaction_id",
		interaction_id,
		enabled,
		accepted_interaction_ids,
		rejected_interaction_ids,
		metadata,
		validation_callback,
		&"interaction_validating",
		&"interaction_received",
		&"interaction_rejected",
		"Interaction context is null.",
		"Interaction receiver is disabled.",
		"Interaction id is rejected.",
		"Interaction id is not accepted."
	) as Dictionary
	return report
