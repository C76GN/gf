## 测试 GFInteractionContext 链式构造与 GFInteractionFlow 的命令派发。
extends GutTest

class RecordingCommand extends RefCounted:
	var interaction_context: Variant = null

	func set_interaction_context(context: Variant) -> void:
		interaction_context = context

	func execute() -> String:
		return "ok"


class PlainExecuteCommand extends RefCounted:
	func execute() -> int:
		return 99


class SpyArchitecture extends GFArchitecture:
	var sent_command: Object = null

	func send_command(command: Object) -> Variant:
		sent_command = command
		return "arch"


class CapabilityProviderStub:
	var capability: Object = null
	var receivers: Array[Object] = []

	func get_capability(_receiver: Object, _capability_type: Script) -> Object:
		return capability

	func get_receivers_in_group(_group_name: StringName) -> Array[Object]:
		return receivers

	func get_receivers_in_group_with(_group_name: StringName, _capability_type: Script) -> Array[Object]:
		return receivers


func test_interaction_context_chain_sets_fields() -> void:
	var ctx := GFInteractionContext.new()
	var sender := Node.new()
	add_child_autofree(sender)
	var target := Node.new()
	add_child_autofree(target)
	var out := (
		ctx.with_sender(sender).with_target(target).with_payload(42).with_group(&"g")
	)
	assert_same(out, ctx)
	assert_same(ctx.sender, sender)
	assert_same(ctx.target, target)
	assert_eq(ctx.payload, 42)
	assert_eq(ctx.group_name, &"g")


func test_interaction_context_empty_group_receivers() -> void:
	var ctx := GFInteractionContext.new()
	ctx.group_name = &""
	var receivers := ctx.get_group_receivers()
	assert_eq(receivers.size(), 0)


func test_interaction_context_group_receivers_without_capability_utility() -> void:
	var ctx := GFInteractionContext.new()
	ctx.group_name = &"team"
	assert_eq(ctx.get_group_receivers().size(), 0, "未注入架构时无法解析能力工具，应返回空列表。")


func test_interaction_context_uses_explicit_capability_provider() -> void:
	var capability := RefCounted.new()
	var receiver := RefCounted.new()
	var provider := CapabilityProviderStub.new()
	provider.capability = capability
	provider.receivers = [receiver]

	var ctx := GFInteractionContext.new()
	ctx.with_target(receiver).with_group(&"team").with_capability_provider(provider)

	assert_same(ctx.get_target_capability(null), capability, "交互上下文应通过显式 provider 查询能力。")
	assert_eq(ctx.get_group_receivers(), [receiver], "交互上下文应通过显式 provider 查询分组 receiver。")


func test_interaction_flow_chaining_updates_context() -> void:
	var ctx := GFInteractionContext.new()
	var flow := GFInteractionFlow.new(ctx)
	var sender := Node.new()
	add_child_autofree(sender)
	flow.to(sender).with_payload("x").in_group(&"combat")
	assert_same(flow.context.target, sender)
	assert_eq(flow.context.payload, "x")
	assert_eq(flow.context.group_name, &"combat")


func test_interaction_flow_sets_capability_provider() -> void:
	var provider := CapabilityProviderStub.new()
	var flow := GFInteractionFlow.new()

	flow.with_capability_provider(provider)

	assert_same(flow.context.capability_provider, provider)


func test_interaction_flow_execute_null_returns_null() -> void:
	var flow := GFInteractionFlow.new()
	assert_null(flow.execute(null))


func test_interaction_flow_execute_applies_context_and_calls_architecture() -> void:
	var arch := SpyArchitecture.new()
	var ctx := GFInteractionContext.new()
	var flow := GFInteractionFlow.new(ctx)
	flow.inject_dependencies(arch)
	var cmd := RecordingCommand.new()
	var result: Variant = flow.execute(cmd)
	assert_eq(result, "arch")
	assert_same(arch.sent_command, cmd)
	assert_same(cmd.interaction_context, ctx)


func test_interaction_flow_execute_without_architecture_falls_back_to_command() -> void:
	var flow := GFInteractionFlow.new()
	var cmd := PlainExecuteCommand.new()
	assert_eq(flow.execute(cmd), 99)


func test_interaction_flow_send_event_null_is_no_op() -> void:
	var flow := GFInteractionFlow.new()
	flow.send_event(null)
	assert_true(flow.context != null, "send_event(null) 应静默返回且 Flow 仍持有默认上下文。")
