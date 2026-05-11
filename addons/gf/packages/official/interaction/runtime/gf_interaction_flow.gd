## GFInteractionFlow: 基于 GFInteractionContext 的链式交互辅助对象。
##
## 保持能力查询与命令执行的显式类型边界，适合一次性组织交互流程。
class_name GFInteractionFlow
extends RefCounted


# --- 公共变量 ---

## 当前交互上下文。
var context: GFInteractionContext


# --- 私有变量 ---

var _architecture_ref: WeakRef = null


# --- Godot 生命周期方法 ---

func _init(p_context: GFInteractionContext = null) -> void:
	context = p_context if p_context != null else GFInteractionContext.new()


# --- 公共方法 ---

## 注入当前交互所属架构。
## @param architecture: 用于依赖注入和能力查询的架构实例。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null
	if context != null:
		context.inject_dependencies(architecture)


## 设置交互目标。
## @param target: 交互目标对象。
func to(target: Object) -> GFInteractionFlow:
	context.with_target(target)
	return self


## 设置交互 payload。
## @param payload: 随事件或交互传递的数据。
func with_payload(payload: Variant) -> GFInteractionFlow:
	context.with_payload(payload)
	return self


## 设置交互分组。
## @param group_name: 能力组或状态组名称。
func in_group(group_name: StringName) -> GFInteractionFlow:
	context.with_group(group_name)
	return self


## 获取 sender 上的指定能力。
## @param capability_type: 要查询、添加或移除的能力脚本类型。
func sender_as(capability_type: Script) -> Object:
	return context.get_sender_capability(capability_type)


## 获取 target 上的指定能力。
## @param capability_type: 要查询、添加或移除的能力脚本类型。
func target_as(capability_type: Script) -> Object:
	return context.get_target_capability(capability_type)


## 执行命令。命令可通过 interaction_context 属性或 set_interaction_context(context) 接收上下文。
## @param command: 要执行的命令实例。
func execute(command: Object) -> Variant:
	if command == null:
		return null

	_apply_context(command)
	var architecture := _get_architecture_or_null()
	if architecture != null:
		return architecture.send_command(command)
	if command.has_method("execute"):
		return command.execute()
	return null


## 发送事件。事件可通过 interaction_context 属性或 set_interaction_context(context) 接收上下文。
## @param event_instance: 要派发的事件实例。
func send_event(event_instance: Object) -> void:
	if event_instance == null:
		return

	_apply_context(event_instance)
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.send_event(event_instance)


# --- 私有/辅助方法 ---

func _apply_context(instance: Object) -> void:
	if instance == null or context == null:
		return

	if instance.has_method("set_interaction_context"):
		instance.call("set_interaction_context", context)
	elif "interaction_context" in instance:
		instance.set("interaction_context", context)


func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	return GFAutoload.get_architecture_or_null()
