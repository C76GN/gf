## GFNetworkSnapshotSchema: 网络快照字段编码表。
##
## 用字段级编码器转换快照 state，适合项目在自己的同步、回放或存储流程中
## 统一压缩、量化和恢复状态字段。
class_name GFNetworkSnapshotSchema
extends Resource


# --- 导出变量 ---

## 未注册字段是否原样保留。
@export var include_unregistered_fields: bool = true

## 字段编码器表。Key 推荐使用 StringName 或 String，Value 为 GFNetworkFieldSerializer。
@export var field_serializers: Dictionary = {}


# --- 公共方法 ---

## 设置字段编码器。
## @param field_name: 字段名。
## @param serializer: 字段编码器；为空时移除。
func set_field_serializer(field_name: StringName, serializer: GFNetworkFieldSerializer) -> void:
	if field_name == &"":
		return
	if serializer == null:
		field_serializers.erase(field_name)
		field_serializers.erase(String(field_name))
		return
	field_serializers[field_name] = serializer


## 移除字段编码器。
## @param field_name: 字段名。
func remove_field_serializer(field_name: StringName) -> void:
	field_serializers.erase(field_name)
	field_serializers.erase(String(field_name))


## 获取字段编码器。
## @param field_name: 字段名。
## @return 字段编码器；不存在时返回 null。
func get_field_serializer(field_name: StringName) -> GFNetworkFieldSerializer:
	var value: Variant = null
	if field_serializers.has(field_name):
		value = field_serializers[field_name]
	elif field_serializers.has(String(field_name)):
		value = field_serializers[String(field_name)]
	return value as GFNetworkFieldSerializer


## 检查字段是否注册了编码器。
## @param field_name: 字段名。
## @return 已注册时返回 true。
func has_field_serializer(field_name: StringName) -> bool:
	return get_field_serializer(field_name) != null


## 获取已注册字段名。
## @return 字段名列表。
func get_registered_fields() -> PackedStringArray:
	var result := PackedStringArray()
	var seen: Dictionary = {}
	for key: Variant in field_serializers.keys():
		var serializer := field_serializers[key] as GFNetworkFieldSerializer
		if serializer == null:
			continue
		var field_name := str(key)
		if seen.has(field_name):
			continue
		seen[field_name] = true
		result.append(field_name)
	result.sort()
	return result


## 编码状态字典。
## @param state: 原始状态。
## @return 编码后的状态。
func encode_state(state: Dictionary) -> Dictionary:
	var encoded: Dictionary = {}
	for field_name: String in get_registered_fields():
		var field_key := StringName(field_name)
		if not _state_has_field(state, field_key):
			continue

		var serializer := get_field_serializer(field_key)
		if serializer != null:
			encoded[field_key] = serializer.serialize_value(_state_get_field(state, field_key))

	if include_unregistered_fields:
		for key: Variant in state.keys():
			if has_field_serializer(StringName(str(key))):
				continue
			encoded[key] = GFVariantData.duplicate_variant(state[key])
	return encoded


## 解码状态字典。
## @param encoded_state: 编码后的状态。
## @return 解码后的状态。
func decode_state(encoded_state: Dictionary) -> Dictionary:
	var decoded: Dictionary = {}
	for field_name: String in get_registered_fields():
		var field_key := StringName(field_name)
		if not _state_has_field(encoded_state, field_key):
			continue

		var serializer := get_field_serializer(field_key)
		if serializer != null:
			decoded[field_key] = serializer.deserialize_value(_state_get_field(encoded_state, field_key))

	if include_unregistered_fields:
		for key: Variant in encoded_state.keys():
			if has_field_serializer(StringName(str(key))):
				continue
			decoded[key] = GFVariantData.duplicate_variant(encoded_state[key])
	return decoded


## 编码快照。
## @param snapshot: 原始快照。
## @return 快照字典；snapshot 为空时返回空字典。
func encode_snapshot(snapshot: GFNetworkSnapshot) -> Dictionary:
	if snapshot == null:
		return {}

	var data := snapshot.to_dict()
	data["state"] = encode_state(snapshot.state)
	return data


## 解码快照。
## @param data: encode_snapshot() 或 GFNetworkSnapshot.to_dict() 形式的字典。
## @return 解码后的快照。
func decode_snapshot(data: Dictionary) -> GFNetworkSnapshot:
	var snapshot := GFNetworkSnapshot.new()
	snapshot.from_dict(data)
	snapshot.state = decode_state(snapshot.state)
	return snapshot


## 复制 Schema 配置。
## @return 新 Schema。
func duplicate_schema() -> GFNetworkSnapshotSchema:
	var schema := GFNetworkSnapshotSchema.new()
	schema.include_unregistered_fields = include_unregistered_fields
	for key: Variant in field_serializers.keys():
		var serializer := field_serializers[key] as GFNetworkFieldSerializer
		if serializer != null:
			schema.field_serializers[key] = serializer.duplicate_serializer()
	return schema


# --- 私有/辅助方法 ---

func _state_has_field(state: Dictionary, field_name: StringName) -> bool:
	return state.has(field_name) or state.has(String(field_name))


func _state_get_field(state: Dictionary, field_name: StringName) -> Variant:
	if state.has(field_name):
		return state[field_name]
	return state.get(String(field_name))
