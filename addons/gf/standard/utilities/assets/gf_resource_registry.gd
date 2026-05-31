## GFResourceRegistry: 通用资源注册表。
##
## 通过稳定 ID 管理资源路径、类型提示和字段索引，便于项目用统一方式查询、
## 预加载或加载资源定义。注册表只描述资源位置和通用字段，不规定物品、技能、
## 关卡、UI 或其他业务规则。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.21.0
class_name GFResourceRegistry
extends Resource


# --- 导出变量 ---

## 注册表条目列表。重复 ID 会以后出现的有效条目为准。
## [br]
## @api public
## [br]
## @schema entries: Array[GFResourceRegistryEntry] resource registry entries.
@export var entries: Array[GFResourceRegistryEntry] = []


# --- 私有变量 ---

var _entry_lookup: Dictionary = {}
var _index: GFValueIndex = GFValueIndex.new()
var _index_dirty: bool = true


# --- 公共方法 ---

## 添加或替换条目。
## [br]
## @api public
## [br]
## @param entry: 要写入的注册表条目。
## [br]
## @return 写入成功返回 true。
func set_entry(entry: Resource) -> bool:
	var source_entry: GFResourceRegistryEntry = _get_registry_entry_value(entry)
	if not _is_valid_registry_entry(source_entry):
		return false

	var stored_entry: GFResourceRegistryEntry = _duplicate_registry_entry(source_entry)
	for index: int in range(entries.size()):
		var existing: GFResourceRegistryEntry = entries[index]
		if _is_valid_registry_entry(existing) and _get_entry_id(existing) == _get_entry_id(stored_entry):
			entries[index] = stored_entry
			mark_index_dirty()
			return true

	entries.append(stored_entry)
	mark_index_dirty()
	return true


## 移除条目。
## [br]
## @api public
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @return 移除成功返回 true。
func remove_entry(entry_id: StringName) -> bool:
	for index: int in range(entries.size() - 1, -1, -1):
		var entry: GFResourceRegistryEntry = entries[index]
		if _is_valid_registry_entry(entry) and _get_entry_id(entry) == entry_id:
			entries.remove_at(index)
			mark_index_dirty()
			return true
	return false


## 清空注册表。
## [br]
## @api public
func clear() -> void:
	entries.clear()
	mark_index_dirty()


## 标记运行时索引需要重建。
## 直接修改 entries 数组或条目字段后，应调用本方法。
## [br]
## @api public
func mark_index_dirty() -> void:
	_index_dirty = true


## 立即重建运行时索引。
## [br]
## @api public
func rebuild_index() -> void:
	_entry_lookup.clear()
	_index.clear()
	for entry: GFResourceRegistryEntry in entries:
		if not _is_valid_registry_entry(entry):
			continue
		var stored_entry: GFResourceRegistryEntry = _duplicate_registry_entry(entry)
		var entry_id: StringName = _get_entry_id(stored_entry)
		_entry_lookup[entry_id] = stored_entry
		var _indexed: bool = _index.set_item(entry_id, _get_entry_path(stored_entry), _get_entry_fields(stored_entry))
	_index_dirty = false


## 检查条目是否存在。
## [br]
## @api public
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @return 条目存在时返回 true。
func has_entry(entry_id: StringName) -> bool:
	_ensure_index()
	return _entry_lookup.has(entry_id)


## 获取条目副本。
## [br]
## @api public
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @return 条目副本；不存在时返回 null。
func get_entry(entry_id: StringName) -> Resource:
	_ensure_index()
	var entry: GFResourceRegistryEntry = _get_registry_entry_value(GFVariantData.get_option_value(_entry_lookup, entry_id))
	if entry == null:
		return null
	return _duplicate_registry_entry(entry)


## 获取条目资源路径。
## [br]
## @api public
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @return 资源路径；不存在时返回空字符串。
func get_entry_path(entry_id: StringName) -> String:
	_ensure_index()
	var entry: GFResourceRegistryEntry = _get_registry_entry_value(GFVariantData.get_option_value(_entry_lookup, entry_id))
	if entry == null:
		return ""
	return _get_entry_path(entry)


## 获取条目类型提示。
## [br]
## @api public
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @return 类型提示；不存在时返回空字符串。
func get_entry_type_hint(entry_id: StringName) -> String:
	_ensure_index()
	var entry: GFResourceRegistryEntry = _get_registry_entry_value(GFVariantData.get_option_value(_entry_lookup, entry_id))
	if entry == null:
		return ""
	return _get_entry_type_hint(entry)


## 获取条目字段副本。
## [br]
## @api public
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @return 字段字典副本。
## [br]
## @schema return: Dictionary indexed field values.
func get_entry_fields(entry_id: StringName) -> Dictionary:
	_ensure_index()
	var entry: GFResourceRegistryEntry = _get_registry_entry_value(GFVariantData.get_option_value(_entry_lookup, entry_id))
	if entry == null:
		return {}
	return _get_entry_fields(entry)


## 获取全部有效条目 ID。
## [br]
## @api public
## [br]
## @return 排序后的条目 ID 列表。
func get_all_ids() -> PackedStringArray:
	_ensure_index()
	var result: PackedStringArray = PackedStringArray()
	for entry_id_value: Variant in _entry_lookup.keys():
		var entry_id: StringName = GFVariantData.to_string_name(entry_id_value)
		var _appended: bool = result.append(String(entry_id))
	result.sort()
	return result


## 获取全部有效资源路径。
## [br]
## @api public
## [br]
## @return 排序后的资源路径列表。
func get_all_paths() -> PackedStringArray:
	_ensure_index()
	var lookup: Dictionary = {}
	for entry_value: Variant in _entry_lookup.values():
		var entry: GFResourceRegistryEntry = _get_registry_entry_value(entry_value)
		if entry == null:
			continue
		lookup[_get_entry_path(entry)] = true

	var result: PackedStringArray = PackedStringArray()
	for path_value: Variant in lookup.keys():
		var path: String = GFVariantData.to_text(path_value)
		var _appended: bool = result.append(path)
	result.sort()
	return result


## 按单个字段值查询条目 ID。
## [br]
## @api public
## [br]
## @param field_id: 字段标识。
## [br]
## @param field_value: 字段值。
## [br]
## @return 匹配的条目 ID。
## [br]
## @schema field_value: Variant indexed field value.
func query(field_id: StringName, field_value: Variant) -> PackedStringArray:
	_ensure_index()
	return _index.query(field_id, field_value)


## 按多个字段查询条目 ID。
## [br]
## @api public
## [br]
## @param criteria: 字段到值的查询条件。
## [br]
## @param match_all: true 表示交集查询，false 表示并集查询。
## [br]
## @return 匹配的条目 ID。
## [br]
## @schema criteria: Dictionary from field id to query value.
func query_many(criteria: Dictionary, match_all: bool = true) -> PackedStringArray:
	_ensure_index()
	return _index.query_many(criteria, match_all)


## 同步加载条目资源。
## [br]
## @api public
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @param type_hint_override: 可选类型提示覆盖；为空时使用条目自己的 type_hint。
## [br]
## @param cache_mode: ResourceLoader 缓存模式。
## [br]
## @return 加载到的资源；不存在或加载失败时返回 null。
func load_entry(
	entry_id: StringName,
	type_hint_override: String = "",
	cache_mode: int = ResourceLoader.CACHE_MODE_REUSE
) -> Resource:
	var path: String = get_entry_path(entry_id)
	if path.is_empty():
		return null

	var resolved_type_hint: String = _resolve_type_hint(entry_id, type_hint_override)
	if not ResourceLoader.exists(path, resolved_type_hint):
		return null
	return ResourceLoader.load(path, resolved_type_hint, cache_mode)


## 通过 GFAssetUtility 异步加载条目资源。
## [br]
## @api public
## [br]
## @param asset_utility: 资源加载工具。
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @param on_loaded: 加载完成回调，签名为 func(resource: Resource)。
## [br]
## @param type_hint_override: 可选类型提示覆盖；为空时使用条目自己的 type_hint。
func request_entry_async(
	asset_utility: GFAssetUtility,
	entry_id: StringName,
	on_loaded: Callable,
	type_hint_override: String = ""
) -> void:
	if asset_utility == null or not on_loaded.is_valid():
		push_error("[GFResourceRegistry] request_entry_async 失败：asset_utility 或 on_loaded 无效。")
		if on_loaded.is_valid():
			on_loaded.call(null)
		return

	var path: String = get_entry_path(entry_id)
	if path.is_empty():
		on_loaded.call(null)
		return

	asset_utility.load_async(path, on_loaded, _resolve_type_hint(entry_id, type_hint_override))


## 通过 GFAssetUtility 异步加载条目资源并返回所有权句柄。
## [br]
## @api public
## [br]
## @param asset_utility: 资源加载工具。
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @param on_loaded: 加载完成回调，签名为 func(handle: GFAssetHandle)。
## [br]
## @param owner: 可选拥有者。
## [br]
## @param group_id: 可选资源分组。
## [br]
## @param type_hint_override: 可选类型提示覆盖；为空时使用条目自己的 type_hint。
func request_entry_handle_async(
	asset_utility: GFAssetUtility,
	entry_id: StringName,
	on_loaded: Callable,
	owner: Object = null,
	group_id: StringName = &"",
	type_hint_override: String = ""
) -> void:
	if asset_utility == null or not on_loaded.is_valid():
		push_error("[GFResourceRegistry] request_entry_handle_async 失败：asset_utility 或 on_loaded 无效。")
		if on_loaded.is_valid():
			on_loaded.call(null)
		return

	var path: String = get_entry_path(entry_id)
	if path.is_empty():
		on_loaded.call(null)
		return

	asset_utility.load_handle_async(
		path,
		on_loaded,
		_resolve_type_hint(entry_id, type_hint_override),
		owner,
		group_id
	)


## 构建可传给 GFAssetUtility.preload_group_async() 的资源请求列表。
## [br]
## @api public
## [br]
## @param entry_ids: 要导出的条目 ID；为空时导出全部有效条目。
## [br]
## @return 资源请求列表。
## [br]
## @schema entry_ids: PackedStringArray selected entry ids.
## [br]
## @schema return: Array[Dictionary] where each item contains path and type_hint.
func make_asset_group_entries(entry_ids: PackedStringArray = PackedStringArray()) -> Array:
	_ensure_index()
	var include_all: bool = entry_ids.is_empty()
	var result: Array[Dictionary] = []
	for entry_id: String in get_all_ids():
		if not include_all and not entry_ids.has(entry_id):
			continue
		var typed_id: StringName = StringName(entry_id)
		result.append({
			"path": get_entry_path(typed_id),
			"type_hint": get_entry_type_hint(typed_id),
		})
	return result


## 获取调试快照。
## [br]
## @api public
## [br]
## @return 注册表诊断信息。
## [br]
## @schema return: Dictionary with entry_count, indexed_field_count, and ids.
func get_debug_snapshot() -> Dictionary:
	_ensure_index()
	return {
		"entry_count": _entry_lookup.size(),
		"indexed_field_count": _index.get_index_count(),
		"ids": get_all_ids(),
	}


## 转换为可序列化字典。
## [br]
## @api public
## [br]
## @return 注册表字典。
## [br]
## @schema return: Dictionary with entries array.
func to_dict() -> Dictionary:
	var entry_data: Array = []
	for entry: GFResourceRegistryEntry in entries:
		if _is_valid_registry_entry(entry):
			entry_data.append(entry.to_dict())
	return {
		"entries": entry_data,
	}


## 应用字典数据。
## [br]
## @api public
## [br]
## @param data: 注册表字典。
## [br]
## @schema data: Dictionary with entries array.
func apply_dict(data: Dictionary) -> void:
	entries.clear()
	var raw_entries: Array = GFVariantData.get_option_array(data, "entries")
	for raw_entry: Variant in raw_entries:
		if raw_entry is Dictionary:
			var entry: GFResourceRegistryEntry = _get_registry_entry_value(
				GFResourceRegistryEntry.from_dict(GFVariantData.as_dictionary(raw_entry))
			)
			if _is_valid_registry_entry(entry):
				entries.append(entry)
	mark_index_dirty()


## 从字典创建注册表。
## [br]
## @api public
## [br]
## @param data: 注册表字典。
## [br]
## @schema data: Dictionary with entries array.
## [br]
## @return 新注册表。
static func from_dict(data: Dictionary) -> Resource:
	var registry: GFResourceRegistry = GFResourceRegistry.new()
	registry.apply_dict(data)
	return registry


# --- 私有/辅助方法 ---

func _ensure_index() -> void:
	if _index_dirty:
		rebuild_index()


func _resolve_type_hint(entry_id: StringName, type_hint_override: String) -> String:
	if not type_hint_override.is_empty():
		return type_hint_override
	return get_entry_type_hint(entry_id)


func _is_valid_registry_entry(entry: GFResourceRegistryEntry) -> bool:
	return entry != null and entry.is_valid_entry()


func _duplicate_registry_entry(entry: GFResourceRegistryEntry) -> GFResourceRegistryEntry:
	if entry == null:
		return null
	return _get_registry_entry_value(entry.duplicate_entry())


func _get_entry_id(entry: GFResourceRegistryEntry) -> StringName:
	if entry == null:
		return &""
	return entry.id


func _get_entry_path(entry: GFResourceRegistryEntry) -> String:
	if entry == null:
		return ""
	return entry.path


func _get_entry_type_hint(entry: GFResourceRegistryEntry) -> String:
	if entry == null:
		return ""
	return entry.type_hint


func _get_entry_fields(entry: GFResourceRegistryEntry) -> Dictionary:
	if entry == null:
		return {}
	return entry.fields.duplicate(true)


func _get_registry_entry_value(value: Variant) -> GFResourceRegistryEntry:
	if value is GFResourceRegistryEntry:
		var entry: GFResourceRegistryEntry = value
		return entry
	return null
