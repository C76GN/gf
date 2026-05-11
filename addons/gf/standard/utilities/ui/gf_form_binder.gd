## GFFormBinder: 轻量 Control 表单读写绑定器。
##
## 将 StringName 字段映射到 Control 节点，提供批量 read/write 和变化信号。
class_name GFFormBinder
extends RefCounted


# --- 信号 ---

## 字段值变化时发出。
## @param key: 字段键。
## @param value: 当前控件值。
signal field_changed(key: StringName, value: Variant)


# --- 私有变量 ---

var _fields: Dictionary = {}


# --- 公共方法 ---

## 绑定字段到控件。
## @param key: 字段键。
## @param control: 控件节点。
## @param default_value: 控件失效或读取失败时的默认值。
func bind_field(key: StringName, control: Control, default_value: Variant = null) -> void:
	if key == &"":
		push_error("[GFFormBinder] bind_field 失败：字段键为空。")
		return
	if not is_instance_valid(control):
		push_error("[GFFormBinder] bind_field 失败：控件无效。")
		return

	_fields[key] = {
		"control_ref": weakref(control),
		"default_value": default_value,
	}
	GFControlValueAdapter.connect_value_changed(control, func() -> void:
		_on_field_changed(key)
	)
	control.tree_exited.connect(func() -> void:
		unbind_field(key)
	, CONNECT_ONE_SHOT)


## 解绑字段。
## @param key: 字段键。
func unbind_field(key: StringName) -> void:
	_fields.erase(key)


## 清空所有字段绑定。
func clear() -> void:
	_fields.clear()


## 获取绑定字段列表。
## @return 字段键数组。
func get_bound_fields() -> Array[StringName]:
	var result: Array[StringName] = []
	for key: StringName in _fields.keys():
		if _get_control(key) != null:
			result.append(key)
		else:
			_fields.erase(key)
	return result


## 读取单个字段值。
## @param key: 字段键。
## @param fallback: 回退值。
## @return 字段值。
func get_field_value(key: StringName, fallback: Variant = null) -> Variant:
	var control := _get_control(key)
	if control == null:
		return fallback

	var info := _get_field_info(key)
	var default_value: Variant = info.get("default_value", fallback)
	return GFControlValueAdapter.get_value(control, default_value)


## 写入单个字段值。
## @param key: 字段键。
## @param value: 字段值。
## @return 成功写入时返回 true。
func set_field_value(key: StringName, value: Variant) -> bool:
	var control := _get_control(key)
	if control == null:
		return false
	return GFControlValueAdapter.set_value(control, value)


## 读取全部字段值。
## @return 字段值字典。
func read_values() -> Dictionary:
	var data: Dictionary = {}
	for key: StringName in get_bound_fields():
		data[key] = get_field_value(key)
	return data


## 批量写入字段值。
## @param data: 字段值字典。
## @param ignore_missing_fields: true 时忽略未绑定字段，false 时输出 warning。
func write_values(data: Dictionary, ignore_missing_fields: bool = true) -> void:
	for key_variant: Variant in data.keys():
		var key := StringName(key_variant)
		if not _fields.has(key):
			if not ignore_missing_fields:
				push_warning("[GFFormBinder] 未绑定字段：%s" % String(key))
			continue
		set_field_value(key, data[key_variant])


# --- 私有/辅助方法 ---

func _get_control(key: StringName) -> Control:
	var info := _get_field_info(key)
	if info.is_empty():
		return null

	var control_ref_variant: Variant = info.get("control_ref")
	var control_ref := control_ref_variant as WeakRef if control_ref_variant is WeakRef else null
	var control := control_ref.get_ref() as Control if control_ref != null else null
	if not is_instance_valid(control):
		_fields.erase(key)
		return null
	return control


func _on_field_changed(key: StringName) -> void:
	if not _fields.has(key):
		return
	field_changed.emit(key, get_field_value(key))


func _get_field_info(key: StringName) -> Dictionary:
	var info_variant: Variant = _fields.get(key, {})
	if info_variant is Dictionary:
		return info_variant as Dictionary
	return {}
