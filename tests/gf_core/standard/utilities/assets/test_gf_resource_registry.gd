## 测试 GFResourceRegistry 的稳定 ID、字段索引和资源加载衔接。
extends GutTest


const GFResourceRegistryBase = preload("res://addons/gf/standard/utilities/assets/gf_resource_registry.gd")
const GFResourceRegistryEntryBase = preload("res://addons/gf/standard/utilities/assets/gf_resource_registry_entry.gd")


class ManualAssetUtility extends GFAssetUtility:
	var requested_path: String = ""
	var requested_type_hint: String = ""
	var requested_handle_path: String = ""
	var requested_handle_type_hint: String = ""
	var requested_group_id: StringName = &""
	var returned_resource: Resource = Resource.new()

	func load_async(path: String, on_loaded: Callable, type_hint: String = "") -> void:
		requested_path = path
		requested_type_hint = type_hint
		on_loaded.call(returned_resource)

	func load_handle_async(
		path: String,
		on_loaded: Callable,
		type_hint: String = "",
		owner: Object = null,
		group_id: StringName = &""
	) -> void:
		requested_handle_path = path
		requested_handle_type_hint = type_hint
		requested_group_id = group_id
		var handle := GFAssetHandle.new()
		var owner_id := owner.get_instance_id() if owner != null else 0
		handle.setup_from_utility(self, path, returned_resource, type_hint, group_id, owner_id)
		on_loaded.call(handle)


func test_entry_configure_duplicates_fields() -> void:
	var fields := {
		&"tags": ["weapon", "rare"],
	}
	var entry: Variant = GFResourceRegistryEntryBase.new().configure(
		&"sword",
		"res://items/sword.tres",
		"Resource",
		fields
	)
	fields[&"tags"].append("mutated")

	assert_true(entry.is_valid_entry(), "ID 和路径有效时条目应可用。")
	assert_eq(entry.id, &"sword")
	assert_eq(entry.path, "res://items/sword.tres")
	assert_eq(entry.type_hint, "Resource")
	assert_eq(entry.fields[&"tags"], ["weapon", "rare"], "配置时应复制字段，避免调用方继续修改。")


func test_registry_replaces_entries_by_stable_id() -> void:
	var registry: Variant = GFResourceRegistryBase.new()
	var first = _make_entry(&"item", "res://old.tres", { &"kind": "old" })
	var second = _make_entry(&"item", "res://new.tres", { &"kind": "new" })

	assert_true(registry.set_entry(first))
	assert_true(registry.set_entry(second))

	assert_eq(registry.get_all_ids(), PackedStringArray(["item"]), "重复 ID 应替换而不是追加。")
	assert_eq(registry.get_entry_path(&"item"), "res://new.tres")
	assert_eq(registry.query(&"kind", "old"), PackedStringArray(), "替换条目后旧字段索引应清理。")
	assert_eq(registry.query(&"kind", "new"), PackedStringArray(["item"]))


func test_query_supports_multi_value_fields_and_many_criteria() -> void:
	var registry: Variant = GFResourceRegistryBase.new()
	registry.set_entry(_make_entry(&"sword", "res://sword.tres", {
		&"kind": "weapon",
		&"tags": ["sharp", "metal"],
		&"rarity": "rare",
	}))
	registry.set_entry(_make_entry(&"shield", "res://shield.tres", {
		&"kind": "armor",
		&"tags": ["metal"],
		&"rarity": "rare",
	}))

	assert_eq(registry.query(&"tags", "metal"), PackedStringArray(["shield", "sword"]))
	assert_eq(registry.query_many({ &"kind": "weapon", &"rarity": "rare" }), PackedStringArray(["sword"]))
	assert_eq(registry.query_many({ &"kind": "weapon", &"kind_alt": "armor" }, false), PackedStringArray(["sword"]))


func test_direct_entry_mutation_can_rebuild_index() -> void:
	var registry: Variant = GFResourceRegistryBase.new()
	registry.set_entry(_make_entry(&"item", "res://item.tres", { &"tier": 1 }))
	assert_eq(registry.query(&"tier", 1), PackedStringArray(["item"]))

	registry.entries[0].fields = { &"tier": 2 }
	registry.mark_index_dirty()

	assert_eq(registry.query(&"tier", 1), PackedStringArray())
	assert_eq(registry.query(&"tier", 2), PackedStringArray(["item"]))


func test_make_asset_group_entries_uses_registered_type_hints() -> void:
	var registry: Variant = GFResourceRegistryBase.new()
	registry.set_entry(_make_entry(&"a", "res://a.tres", { &"group": "one" }, "PackedScene"))
	registry.set_entry(_make_entry(&"b", "res://b.tres", { &"group": "two" }, "Resource"))

	var entries: Array = registry.make_asset_group_entries(PackedStringArray(["b"]))

	assert_eq(entries.size(), 1)
	assert_eq(entries[0]["path"], "res://b.tres")
	assert_eq(entries[0]["type_hint"], "Resource")


func test_load_entry_uses_resource_loader_path_and_type_hint() -> void:
	var registry: Variant = GFResourceRegistryBase.new()
	registry.set_entry(_make_entry(
		&"index_script",
		"res://addons/gf/standard/foundation/collections/gf_value_index.gd",
		{},
		"Script"
	))

	var resource: Resource = registry.load_entry(&"index_script")

	assert_not_null(resource, "注册表应能同步加载已登记的资源。")
	assert_true(resource is Script, "type_hint 为 Script 时应返回脚本资源。")


func test_request_entry_async_delegates_to_asset_utility() -> void:
	var registry: Variant = GFResourceRegistryBase.new()
	registry.set_entry(_make_entry(&"item", "res://item.tres", {}, "Resource"))
	var utility := ManualAssetUtility.new()
	var loaded_resources: Array[Resource] = []

	registry.request_entry_async(
		utility,
		&"item",
		func(resource: Resource) -> void:
			loaded_resources.append(resource)
	)

	assert_eq(utility.requested_path, "res://item.tres")
	assert_eq(utility.requested_type_hint, "Resource")
	assert_eq(loaded_resources.size(), 1)
	assert_eq(loaded_resources[0], utility.returned_resource)


func test_request_entry_handle_async_delegates_group_and_owner() -> void:
	var registry: Variant = GFResourceRegistryBase.new()
	registry.set_entry(_make_entry(&"item", "res://item.tres", {}, "Resource"))
	var utility := ManualAssetUtility.new()
	var owner := Node.new()
	var loaded_handles: Array[GFAssetHandle] = []

	registry.request_entry_handle_async(
		utility,
		&"item",
		func(handle: GFAssetHandle) -> void:
			loaded_handles.append(handle),
		owner,
		&"items"
	)

	assert_eq(utility.requested_handle_path, "res://item.tres")
	assert_eq(utility.requested_handle_type_hint, "Resource")
	assert_eq(utility.requested_group_id, &"items")
	assert_eq(loaded_handles.size(), 1)
	assert_eq(loaded_handles[0].path, "res://item.tres")
	assert_eq(loaded_handles[0].get_owner_id(), owner.get_instance_id())

	owner.free()


func test_to_dict_and_from_dict_preserve_entries() -> void:
	var registry: Variant = GFResourceRegistryBase.new()
	registry.set_entry(_make_entry(&"item", "res://item.tres", { &"kind": "test" }, "Resource"))

	var restored: Variant = GFResourceRegistryBase.from_dict(registry.to_dict())

	assert_true(restored.has_entry(&"item"))
	assert_eq(restored.get_entry_path(&"item"), "res://item.tres")
	assert_eq(restored.get_entry_type_hint(&"item"), "Resource")
	assert_eq(restored.query(&"kind", "test"), PackedStringArray(["item"]))


# --- 私有/辅助方法 ---

func _make_entry(
	entry_id: StringName,
	resource_path: String,
	fields: Dictionary = {},
	type_hint: String = ""
) -> Resource:
	return GFResourceRegistryEntryBase.new().configure(entry_id, resource_path, type_hint, fields)
