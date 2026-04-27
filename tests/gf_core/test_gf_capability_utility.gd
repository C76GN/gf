extends GutTest


# --- 常量 ---

const GF_CAPABILITY_BASE := preload("res://addons/gf/extensions/capability/gf_capability.gd")
const GF_CAPABILITY_UTILITY_BASE := preload("res://addons/gf/extensions/capability/gf_capability_utility.gd")
const GF_CAPABILITY_CONTAINER_BASE := preload("res://addons/gf/extensions/capability/gf_capability_container.gd")


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


class InjectedCapability extends GF_CAPABILITY_BASE:
	var injected_architecture: GFArchitecture = null

	func inject_dependencies(architecture: GFArchitecture) -> void:
		super.inject_dependencies(architecture)
		injected_architecture = architecture


class CapabilityNode extends Node:
	var added_receiver: Object = null
	var removed_receiver: Object = null

	func on_gf_capability_added(target: Object) -> void:
		added_receiver = target

	func on_gf_capability_removed(target: Object) -> void:
		removed_receiver = target


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


func test_capability_receives_architecture_injection() -> void:
	var receiver := RefCounted.new()

	var capability := _utility.add_capability(receiver, InjectedCapability) as InjectedCapability

	assert_eq(capability.injected_architecture, _arch, "能力应收到当前架构注入。")


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


func test_base_type_lookup_requires_unique_match() -> void:
	var receiver := RefCounted.new()
	var capability_a := _utility.add_capability(receiver, ConcreteCapabilityA) as ConcreteCapabilityA

	assert_eq(_utility.get_capability(receiver, BaseCapability), capability_a, "单个子类能力可通过基类查询。")

	_utility.add_capability(receiver, ConcreteCapabilityB)
	var ambiguous = _utility.get_capability(receiver, BaseCapability)

	assert_push_warning("[GFCapabilityUtility] get_capability(")
	assert_null(ambiguous, "多个子类能力匹配同一基类时应返回 null。")
