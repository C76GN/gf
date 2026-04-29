## GFInteractions: 创建交互上下文与链式交互流程的静态入口。
class_name GFInteractions
extends RefCounted


# --- 常量 ---

const GF_INTERACTION_FLOW_BASE := preload("res://addons/gf/extensions/interaction/gf_interaction_flow.gd")


# --- 公共方法 ---

## 创建以 sender 为发起者的交互流程。
static func with_sender(sender: Object, architecture: GFArchitecture = null) -> Object:
	var context := GFInteractionContext.new(sender)
	var flow := GF_INTERACTION_FLOW_BASE.new(context)
	_inject_if_possible(flow, architecture)
	return flow


## 创建一次 sender 到 target 的交互上下文。
static func between(
	sender: Object,
	target: Object,
	payload: Variant = null,
	group_name: StringName = &"",
	architecture: GFArchitecture = null
) -> GFInteractionContext:
	var context := GFInteractionContext.new(sender, target, payload, group_name)
	_inject_if_possible(context, architecture)
	return context


# --- 私有/辅助方法 ---

static func _inject_if_possible(instance: Object, architecture: GFArchitecture = null) -> void:
	var resolved_architecture := architecture
	if resolved_architecture == null:
		resolved_architecture = GFAutoload.get_architecture_or_null()

	if resolved_architecture != null and instance.has_method("inject_dependencies"):
		instance.inject_dependencies(resolved_architecture)
