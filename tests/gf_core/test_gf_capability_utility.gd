extends GutTest


# --- 常量 ---

const GF_CAPABILITY_BASE := preload("res://addons/gf/extensions/capability/gf_capability.gd")
const GF_NODE_CAPABILITY_BASE := preload("res://addons/gf/extensions/capability/gf_node_capability.gd")
const GF_CAPABILITY_UTILITY_BASE := preload("res://addons/gf/extensions/capability/gf_capability_utility.gd")
const GF_CAPABILITY_CONTAINER_BASE := preload("res://addons/gf/extensions/capability/gf_capability_container.gd")
const GF_INTERACTION_CONTEXT_BASE := preload("res://addons/gf/extensions/interaction/gf_interaction_context.gd")
const GF_INTERACTIONS_BASE := preload("res://addons/gf/extensions/interaction/gf_interactions.gd")
const GF_PROPERTY_BAG_CAPABILITY_BASE := preload("res://addons/gf/extensions/capability/gf_property_bag_capability.gd")


# --- 辅助类 ---

class HealthCapability extends GF_CAPABILITY_BASE:
	var added_receiver: Object = null
	var removed_receiver: Object = null

	func on_gf_capability_added(target: Object) -> void:
		super.on_gf_capability_added(target)
		added_receiver = target

	func on_gf_capability_removed(target: Object) -> void:
		removed_receiver = target
		super.on_gf_capability_removed(target)


class DamageCapability extends GF_CAPABILITY_BASE:
	func get_required_capabilities() -> Array[Script]:
		return [HealthCapability]


class AutoCleanupDamageCapability extends DamageCapability:
	func get_dependency_removal_policy() -> int:
		return GF_CAPABILITY_UTILITY_BASE.DependencyRemovalPolicy.REMOVE_AUTO_DEPENDENCIES


class RollbackRootCapability extends GF_CAPABILITY_BASE:
	func get_required_capabilities() -> Array[Script]:
		return [HealthCapability, RollbackCycleCapability]


class RollbackCycleCapability extends GF_CAPABILITY_BASE:
	func get_required_capabilities() -> Array[Script]:
		return [RollbackRootCapability]


class InjectedCapability extends GF_CAPABILITY_BASE:
	var injected_architecture: GFArchitecture = null

	func inject_dependencies(architecture: GFArchitecture) -> void:
		super.inject_dependencies(architecture)
		injected_architecture = architecture


class ActiveCapability extends GF_CAPABILITY_BASE:
	var active_events: Array[bool] = []

	func on_gf_capability_active_changed(_target: Object, is_active: bool) -> void:
		active_events.append(is_active)


class ActiveNodeCapability extends GF_NODE_CAPABILITY_BASE:
	var active_events: Array[bool] = []

	func on_gf_capability_active_changed(_target: Object, is_active: bool) -> void:
		active_events.append(is_active)


class InjectedChildNode extends Node:
	var injected_architecture: GFArchitecture = null

	func inject_dependencies(architecture: GFArchitecture) -> void:
		injected_architecture = architecture


class Node2DCapability extends Node2D:
	var added_receiver: Object = null

	func on_gf_capability_added(target: Object) -> void:
		added_receiver = target


class ContextCommand extends GFCommand:
	var interaction_context: GFInteractionContext = null

	func execute() -> Variant:
		return interaction_context


class CapabilityNode extends Node:
	var added_receiver: Object = null
	var removed_receiver: Object = null

	func on_gf_capability_added(target: Object) -> void:
		added_receiver = target

	func on_gf_capability_removed(target: Object) -> void:
		removed_receiver = target


class CountingCapabilityNode extends CapabilityNode:
	static var created_nodes: Array[Node] = []

	func _init() -> void:
		created_nodes.append(self)


class BaseCapability extends GF_CAPABILITY_BASE:
	pass


class ConcreteCapabilityA extends BaseCapability:
	pass


class ConcreteCapabilityB extends BaseCapability:
	pass


# --- 私有变量 ---

var _arch: GFArchitecture
var _utility: Object


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_arch = GFArchitecture.new()
	_utility = GF_CAPABILITY_UTILITY_BASE.new()
	await _arch.register_utility_instance(_utility)
	await Gf.set_architecture(_arch)


func after_each() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
		Gf._architecture = null


# --- 测试用例 ---

func test_add_and_get_capability() -> void:
	var receiver := RefCounted.new()

	var capability := _utility.add_capability(receiver, HealthCapability) as HealthCapability

	assert_not_null(capability, "应能挂载能力。")
	assert_true(_utility.has_capability(receiver, HealthCapability), "has_capability 应能识别已挂载能力。")
	assert_eq(_utility.get_capability(receiver, HealthCapability), capability, "get_capability 应返回同一能力实例。")
	assert_eq(capability.added_receiver, receiver, "挂载后应调用 added hook。")


func test_required_capabilities_are_created_first() -> void:
	var receiver := RefCounted.new()

	var damage := _utility.add_capability(receiver, DamageCapability) as DamageCapability
	var health := _utility.get_capability(receiver, HealthCapability) as HealthCapability

	assert_not_null(damage, "主能力应挂载成功。")
	assert_not_null(health, "依赖能力应自动补齐。")
	assert_eq(damage.get_capability(HealthCapability), health, "能力基类应能访问同一 receiver 上的依赖能力。")


func test_auto_dependency_cleanup_removes_unused_auto_dependency() -> void:
	var receiver := RefCounted.new()

	_utility.add_capability(receiver, AutoCleanupDamageCapability)
	_utility.remove_capability(receiver, AutoCleanupDamageCapability)

	assert_false(_utility.has_capability(receiver, AutoCleanupDamageCapability), "主能力应被移除。")
	assert_false(_utility.has_capability(receiver, HealthCapability), "仅由主能力自动补齐的依赖应被清理。")


func test_auto_dependency_cleanup_keeps_explicit_dependency() -> void:
	var receiver := RefCounted.new()
	_utility.add_capability(receiver, HealthCapability)

	_utility.add_capability(receiver, AutoCleanupDamageCapability)
	_utility.remove_capability(receiver, AutoCleanupDamageCapability)

	assert_true(_utility.has_capability(receiver, HealthCapability), "用户显式添加的依赖能力不应被级联清理。")


func test_dependency_creation_failure_rolls_back_auto_created_dependencies() -> void:
	var receiver := RefCounted.new()

	var capability: Object = _utility.add_capability(receiver, RollbackRootCapability)

	assert_null(capability, "依赖链创建失败时主能力不应挂载。")
	assert_false(_utility.has_capability(receiver, HealthCapability), "失败前自动补齐的依赖应被回滚。")
	assert_false(_utility.has_capability(receiver, RollbackCycleCapability), "失败的循环依赖能力不应残留。")
	assert_push_error("[GFCapabilityUtility] 检测到循环能力依赖：")


func test_capability_receives_architecture_injection() -> void:
	var receiver := RefCounted.new()

	var capability := _utility.add_capability(receiver, InjectedCapability) as InjectedCapability

	assert_eq(capability.injected_architecture, _arch, "能力应收到当前架构注入。")


func test_node_capability_child_tree_receives_architecture_injection() -> void:
	var receiver := Node.new()
	add_child(receiver)
	var capability := ActiveNodeCapability.new()
	var child := InjectedChildNode.new()
	capability.add_child(child)

	_utility.add_capability_instance(receiver, capability, ActiveNodeCapability)

	assert_eq(child.injected_architecture, _arch, "场景能力子节点也应收到当前架构注入。")

	receiver.queue_free()
	await get_tree().process_frame


func test_remove_capability_calls_hook_and_clears_storage() -> void:
	var receiver := RefCounted.new()
	var capability := _utility.add_capability(receiver, HealthCapability) as HealthCapability

	_utility.remove_capability(receiver, HealthCapability)

	assert_eq(capability.removed_receiver, receiver, "移除前应调用 removed hook。")
	assert_false(_utility.has_capability(receiver, HealthCapability), "移除后不应再查询到能力。")


func test_node_capability_is_attached_to_container() -> void:
	var receiver := Node.new()
	add_child(receiver)

	var capability := _utility.add_capability(receiver, CapabilityNode) as CapabilityNode
	await get_tree().process_frame

	assert_not_null(capability, "Node 能力应创建成功。")
	assert_eq(capability.get_parent().name, "GFCapabilityContainer", "Node 能力应被挂入能力容器。")
	assert_eq(capability.get_parent().get_parent(), receiver, "能力容器应挂在 receiver 下。")
	assert_eq(capability.added_receiver, receiver, "Node 能力也应收到 added hook。")

	receiver.queue_free()
	await get_tree().process_frame


func test_node2d_capability_uses_node2d_container() -> void:
	var receiver := Node2D.new()
	add_child(receiver)

	var capability := _utility.add_capability(receiver, Node2DCapability) as Node2DCapability
	await get_tree().process_frame

	assert_not_null(capability, "Node2D 能力应创建成功。")
	assert_true(capability.get_parent() is Node2D, "Node2D 能力应挂入 Node2D 容器以保留空间继承。")
	assert_eq(capability.get_parent().get_parent(), receiver, "Node2D 能力容器应挂在 receiver 下。")
	assert_eq(capability.added_receiver, receiver, "Node2D 能力应收到 added hook。")

	receiver.queue_free()
	await get_tree().process_frame


func test_scene_container_registers_child_capabilities() -> void:
	var receiver := Node.new()
	var container := Node.new()
	container.set_script(GF_CAPABILITY_CONTAINER_BASE)
	var child_capability := CapabilityNode.new()
	container.add_child(child_capability)
	receiver.add_child(container)
	add_child(receiver)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(_utility.get_capability(receiver, CapabilityNode), child_capability, "场景容器应把子节点注册为父节点能力。")
	assert_eq(child_capability.added_receiver, receiver, "容器注册也应触发 added hook。")

	receiver.queue_free()
	await get_tree().process_frame


func test_add_scene_capability_frees_ignored_duplicate_instance() -> void:
	var receiver := Node.new()
	add_child(receiver)
	var existing := CountingCapabilityNode.new()
	CountingCapabilityNode.created_nodes.clear()
	_utility.add_capability_instance(receiver, existing, CountingCapabilityNode)
	var scene := _make_counting_capability_scene()

	var result: Object = _utility.add_scene_capability(receiver, scene, CountingCapabilityNode)
	var duplicate_node := CountingCapabilityNode.created_nodes.back() as CountingCapabilityNode

	assert_eq(result, existing, "重复挂载场景能力时应返回已有实例。")
	assert_true(duplicate_node.is_queued_for_deletion(), "被忽略的新场景能力实例应被释放。")

	receiver.queue_free()
	await get_tree().process_frame


func test_base_type_lookup_requires_unique_match() -> void:
	var receiver := RefCounted.new()
	var capability_a := _utility.add_capability(receiver, ConcreteCapabilityA) as ConcreteCapabilityA

	assert_eq(_utility.get_capability(receiver, BaseCapability), capability_a, "单个子类能力可通过基类查询。")

	_utility.add_capability(receiver, ConcreteCapabilityB)
	var ambiguous = _utility.get_capability(receiver, BaseCapability)

	assert_push_warning("[GFCapabilityUtility] get_capability(")
	assert_null(ambiguous, "多个子类能力匹配同一基类时应返回 null。")


func test_capability_active_state_updates_property_and_hook() -> void:
	var receiver := RefCounted.new()
	var capability := _utility.add_capability(receiver, ActiveCapability) as ActiveCapability

	_utility.set_capability_active(receiver, ActiveCapability, false)

	assert_false(capability.active, "停用能力后 active 属性应同步。")
	assert_false(_utility.is_capability_active(receiver, ActiveCapability), "Utility 应能查询到停用状态。")
	assert_eq(capability.active_events, [false], "停用能力时应触发 active hook。")

	_utility.set_capability_active(receiver, ActiveCapability, true)

	assert_true(capability.active, "重新启用后 active 属性应恢复。")
	assert_eq(capability.active_events, [false, true], "重新启用时应再次触发 active hook。")


func test_node_capability_active_state_disables_processing() -> void:
	var receiver := Node.new()
	add_child(receiver)

	var capability := _utility.add_capability(receiver, ActiveNodeCapability) as ActiveNodeCapability
	await get_tree().process_frame

	var original_process_mode := capability.process_mode
	_utility.set_capability_active(receiver, ActiveNodeCapability, false)

	assert_false(capability.active, "Node 能力停用后 active 属性应同步。")
	assert_eq(capability.process_mode, Node.PROCESS_MODE_DISABLED, "Node 能力停用后应停止处理。")
	assert_eq(capability.active_events, [false], "Node 能力停用时应触发 active hook。")

	_utility.set_capability_active(receiver, ActiveNodeCapability, true)

	assert_true(capability.active, "Node 能力重新启用后 active 属性应恢复。")
	assert_eq(capability.process_mode, original_process_mode, "Node 能力重新启用后应恢复原 process_mode。")

	receiver.queue_free()
	await get_tree().process_frame


func test_capability_reverse_index_and_groups() -> void:
	var receiver_a := RefCounted.new()
	var receiver_b := RefCounted.new()
	var capability_a := _utility.add_capability(receiver_a, ConcreteCapabilityA) as ConcreteCapabilityA
	var capability_b := _utility.add_capability(receiver_b, ConcreteCapabilityB) as ConcreteCapabilityB

	_utility.add_receiver_to_group(receiver_a, &"targets")
	_utility.add_receiver_to_group(receiver_b, &"targets")
	_utility.add_receiver_to_group(receiver_b, &"bosses")

	var receivers: Array[Object] = _utility.get_receivers_with(BaseCapability)
	var capabilities: Array[Object] = _utility.get_capabilities(BaseCapability)
	var target_receivers: Array[Object] = _utility.get_receivers_in_group(&"targets")
	var boss_base_receivers: Array[Object] = _utility.get_receivers_in_group_with(&"bosses", BaseCapability)

	assert_true(receivers.has(receiver_a), "基类反向查询应包含第一个 receiver。")
	assert_true(receivers.has(receiver_b), "基类反向查询应包含第二个 receiver。")
	assert_true(capabilities.has(capability_a), "能力实例查询应包含第一个能力。")
	assert_true(capabilities.has(capability_b), "能力实例查询应包含第二个能力。")
	assert_true(target_receivers.has(receiver_a), "分组查询应包含第一个 receiver。")
	assert_true(target_receivers.has(receiver_b), "分组查询应包含第二个 receiver。")
	assert_eq(boss_base_receivers, [receiver_b], "分组能力交集查询应只返回匹配 receiver。")


func test_interaction_context_queries_capabilities_and_group() -> void:
	var sender := RefCounted.new()
	var target := RefCounted.new()
	var target_capability := _utility.add_capability(target, HealthCapability) as HealthCapability
	_utility.add_receiver_to_group(target, &"targets")

	var context := GF_INTERACTION_CONTEXT_BASE.new(sender, target, { "amount": 10 }, &"targets")
	context.inject_dependencies(_arch)

	assert_eq(context.get_target_capability(HealthCapability), target_capability, "交互上下文应能查询目标能力。")
	assert_eq(context.get_group_receivers(HealthCapability), [target], "交互上下文应能查询当前分组中的能力对象。")


func test_interaction_flow_passes_context_to_command() -> void:
	var sender := RefCounted.new()
	var target := RefCounted.new()
	var command := ContextCommand.new()

	var result := GF_INTERACTIONS_BASE.with_sender(sender, _arch).to(target).with_payload({ "amount": 5 }).execute(command) as GFInteractionContext

	assert_not_null(result, "交互流程应把上下文传递给命令。")
	assert_eq(result.sender, sender, "交互上下文应包含 sender。")
	assert_eq(result.target, target, "交互上下文应包含 target。")
	assert_eq(result.payload["amount"], 5, "交互上下文应包含 payload。")


func test_property_bag_capability_stores_typed_values() -> void:
	var receiver := RefCounted.new()
	var bag: Object = _utility.add_capability(receiver, GF_PROPERTY_BAG_CAPABILITY_BASE)

	bag.set_property_value(&"count", 3)
	bag.set_property_value(&"title", "hello")
	bag.set_property_value(&"offset", Vector2(2.0, 4.0))

	assert_eq(bag.get_int(&"count"), 3, "属性包应能按 int 读取。")
	assert_eq(bag.get_string(&"title"), "hello", "属性包应能按 String 读取。")
	assert_eq(bag.get_vector2(&"offset"), Vector2(2.0, 4.0), "属性包应能按 Vector2 读取。")
	assert_true(bag.remove_property_value(&"title"), "属性包应能移除已有属性。")
	assert_false(bag.has_property_value(&"title"), "移除后属性不应继续存在。")


# --- 私有/辅助方法 ---

func _make_counting_capability_scene() -> PackedScene:
	var node := CountingCapabilityNode.new()
	var scene := PackedScene.new()
	scene.pack(node)
	node.free()
	CountingCapabilityNode.created_nodes.clear()
	return scene
