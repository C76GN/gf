@tool

## GFNetworkContractGenerator: 根据 GFNetworkContract 生成强类型消息辅助脚本。
##
## 生成结果保持为 GDScript 轻量封装，围绕 GFNetworkMessage / GFNetworkUtility
## 提供构造、发送、匹配和 payload 读取函数，不绑定任何具体业务协议。
class_name GFNetworkContractGenerator
extends RefCounted


# --- 常量 ---

const DEFAULT_OUTPUT_DIR: String = "res://gf/generated/network"
const GF_SOURCE_BUILDER_BASE := preload("res://addons/gf/kernel/editor/gf_source_builder.gd")
const GFValidationReportDictionaryBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd")


# --- 公共方法 ---

## 生成单个契约访问器脚本。
## @param contract: 网络契约资源。
## @param output_path: 输出脚本路径；为空时按 contract_id 推导。
## @param overwrite_existing: 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。
## @param options: 可选项，支持 class_name。
## @return Godot 错误码。
func generate(
	contract: GFNetworkContract,
	output_path: String = "",
	overwrite_existing: bool = true,
	options: Dictionary = {}
) -> Error:
	if contract == null:
		return ERR_INVALID_PARAMETER
	var validation: Dictionary = contract.validate_contract()
	if not bool(validation.get("ok", false)):
		return ERR_INVALID_DATA

	var resolved_output_path := output_path
	if resolved_output_path.is_empty():
		var class_name_value := _resolve_class_name(contract, options)
		resolved_output_path = DEFAULT_OUTPUT_DIR.path_join("%s.gd" % class_name_value.to_snake_case())
	var source := build_source(contract, options)
	return save_source(resolved_output_path, source, overwrite_existing)


## 批量生成多个契约访问器脚本。
## @param contract_paths: 契约资源路径列表。
## @param output_dir: 输出目录。
## @param overwrite_existing: 为 false 时目标已存在会跳过。
## @param options: 可选项。
## @return 生成报告。
func generate_many(
	contract_paths: PackedStringArray,
	output_dir: String = DEFAULT_OUTPUT_DIR,
	overwrite_existing: bool = true,
	options: Dictionary = {}
) -> Dictionary:
	var generated: Array[Dictionary] = []
	var issues: Array[Dictionary] = []
	var generated_count := 0
	for contract_path: String in contract_paths:
		var contract := load(contract_path) as GFNetworkContract
		if contract == null:
			issues.append({
				"severity": "error",
				"kind": "invalid_contract_resource",
				"path": contract_path,
				"message": "Contract resource could not be loaded as GFNetworkContract.",
			})
			continue

		var class_name_value := _resolve_class_name(contract, options)
		var output_path := output_dir.path_join("%s.gd" % class_name_value.to_snake_case())
		var error := generate(contract, output_path, overwrite_existing, options)
		generated.append({
			"contract_path": contract_path,
			"output_path": output_path,
			"error": error,
			"error_name": error_string(error),
		})
		if error != OK:
			issues.append({
				"severity": "error",
				"kind": "generate_failed",
				"path": contract_path,
				"message": error_string(error),
			})
		else:
			generated_count += 1

	var report := {
		"ok": issues.is_empty(),
		"generated_count": generated_count,
		"attempted_count": generated.size(),
		"generated": generated,
		"issues": issues,
	}
	return GFValidationReportDictionaryBase.finalize_report(report, "Network contract generation", {
		"include_issue_count": true,
		"next_actions": _get_generation_next_actions(),
		"fallback_action": "Review the first network contract generation issue.",
		"no_action": "Network contract generation completed.",
	})


## 构建契约访问器源码。测试或项目工具可直接调用该方法。
## @param contract: 网络契约资源。
## @param options: 可选项，支持 class_name。
## @return GDScript 源码。
func build_source(contract: GFNetworkContract, options: Dictionary = {}) -> String:
	var builder: GFSourceBuilder = GF_SOURCE_BUILDER_BASE.new()
	var class_name_value := _resolve_class_name(contract, options)
	var message_records := _build_message_records(contract)

	builder.doc("%s: 自动生成的 GF Network 契约访问器。" % class_name_value)
	builder.doc()
	builder.doc("该文件由 GFNetworkContractGenerator 生成，可以提交到版本库；请不要手动编辑。")
	builder.line("class_name %s" % class_name_value)
	builder.line("extends RefCounted")
	builder.blank(2)
	_append_constants(builder, message_records)
	builder.section("公共方法")
	for record: Dictionary in message_records:
		_append_message_methods(builder, record)
	_append_private_helpers(builder)
	return builder.build()


## 保存生成源码到指定路径。
## @param output_path: 输出脚本路径。
## @param source: 源码文本。
## @param overwrite_existing: 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。
## @return Godot 错误码。
func save_source(output_path: String, source: String, overwrite_existing: bool = true) -> Error:
	if output_path.is_empty():
		return ERR_INVALID_PARAMETER
	if FileAccess.file_exists(output_path) and not overwrite_existing:
		return ERR_ALREADY_EXISTS

	var dir_path := ProjectSettings.globalize_path(output_path.get_base_dir())
	var dir_error := DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_error != OK:
		return dir_error

	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(source)
	file.close()

	if Engine.is_editor_hint():
		var filesystem := EditorInterface.get_resource_filesystem()
		if filesystem != null:
			filesystem.scan()
	return OK


# --- 私有/辅助方法 ---

func _resolve_class_name(contract: GFNetworkContract, options: Dictionary) -> String:
	var configured := String(options.get("class_name", "")).strip_edges()
	if not configured.is_empty():
		return _to_pascal_identifier(configured, "GFGeneratedNetworkContract")

	var base_name := String(contract.contract_id).strip_edges()
	if base_name.is_empty():
		base_name = contract.resource_path.get_file().get_basename()
	if base_name.is_empty():
		base_name = "generated"
	return _to_pascal_identifier("%s_network_messages" % base_name, "GFGeneratedNetworkContract")


func _build_message_records(contract: GFNetworkContract) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if contract == null:
		return records

	var used_suffixes: Dictionary = {}
	var used_constants: Dictionary = {}
	for message_contract: GFNetworkContractMessage in contract.messages:
		if message_contract == null:
			continue

		var suffix := _make_unique_name(
			_to_snake_identifier(String(message_contract.message_type), "message"),
			used_suffixes
		)
		var message_constant := _make_unique_name(
			"MESSAGE_%s" % _to_constant_name(String(message_contract.message_type), "MESSAGE"),
			used_constants
		)
		var channel_constant := _make_unique_name(
			"CHANNEL_%s" % _to_constant_name(String(message_contract.message_type), "MESSAGE"),
			used_constants
		)
		records.append({
			"message": message_contract,
			"suffix": suffix,
			"message_constant": message_constant,
			"channel_constant": channel_constant,
			"field_records": _build_field_records(message_contract, used_constants),
		})
	return records


func _build_field_records(
	message_contract: GFNetworkContractMessage,
	used_constants: Dictionary
) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var used_parameters: Dictionary = {}
	used_parameters["options"] = true
	used_parameters["network"] = true
	used_parameters["peer_id"] = true

	var message_constant_part := _to_constant_name(String(message_contract.message_type), "MESSAGE")
	for field: GFNetworkContractField in _ordered_fields(message_contract.fields):
		if field == null or field.field_name == &"":
			continue

		var field_constant := _make_unique_name(
			"FIELD_%s_%s" % [
				message_constant_part,
				_to_constant_name(String(field.field_name), "FIELD"),
			],
			used_constants
		)
		records.append({
			"field": field,
			"field_constant": field_constant,
			"parameter_name": _make_unique_name(_to_snake_identifier(String(field.field_name), "field"), used_parameters),
		})
	return records


func _ordered_fields(fields: Array[GFNetworkContractField]) -> Array[GFNetworkContractField]:
	var required_fields: Array[GFNetworkContractField] = []
	var optional_fields: Array[GFNetworkContractField] = []
	for field: GFNetworkContractField in fields:
		if field == null:
			continue
		if field.required:
			required_fields.append(field)
		else:
			optional_fields.append(field)
	required_fields.append_array(optional_fields)
	return required_fields


func _append_constants(builder: GFSourceBuilder, message_records: Array[Dictionary]) -> void:
	builder.section("常量")
	if message_records.is_empty():
		builder.line("const _EMPTY_CONTRACT: bool = true")
		builder.blank(2)
		return

	for record: Dictionary in message_records:
		var message_contract := record.get("message") as GFNetworkContractMessage
		builder.line("const %s: StringName = &\"%s\"" % [
			String(record.get("message_constant", "")),
			String(message_contract.message_type).c_escape(),
		])
		builder.line("const %s: StringName = &\"%s\"" % [
			String(record.get("channel_constant", "")),
			String(message_contract.channel_id).c_escape(),
		])
		for field_record: Dictionary in record.get("field_records", []):
			var field := field_record.get("field") as GFNetworkContractField
			builder.line("const %s: StringName = &\"%s\"" % [
				String(field_record.get("field_constant", "")),
				String(field.field_name).c_escape(),
			])
		builder.blank()
	builder.blank()


func _append_message_methods(builder: GFSourceBuilder, record: Dictionary) -> void:
	var message_contract := record.get("message") as GFNetworkContractMessage
	var suffix := String(record.get("suffix", "message"))
	var field_records := record.get("field_records", []) as Array
	var make_params := _build_function_parameters(field_records, true)
	var send_params := _build_function_parameters(field_records, true)
	send_params.insert(0, "peer_id: int")
	send_params.insert(0, "network: GFNetworkUtility")

	builder.doc("创建 %s 消息。" % String(message_contract.message_type))
	builder.line("static func make_%s(%s) -> GFNetworkMessage:" % [suffix, ", ".join(make_params)])
	builder.indent()
	_append_payload_builder(builder, field_records)
	builder.line("return GFNetworkMessage.new(")
	builder.indent()
	builder.line("%s," % String(record.get("message_constant", "")))
	builder.line("payload,")
	builder.line("int(options.get(\"sequence\", 0)),")
	builder.line("int(options.get(\"tick\", 0)),")
	builder.line("int(options.get(\"sender_id\", -1)),")
	builder.line("StringName(options.get(\"channel_id\", %s))" % String(record.get("channel_constant", "")))
	builder.dedent()
	builder.line(")")
	builder.dedent()
	builder.blank(2)

	builder.doc("发送 %s 消息。" % String(message_contract.message_type))
	builder.line("static func send_%s(%s) -> Error:" % [suffix, ", ".join(send_params)])
	builder.indent()
	builder.line("var message := make_%s(%s)" % [suffix, _build_make_call_arguments(field_records)])
	builder.line("var channel_id := StringName(options.get(\"channel_id\", %s))" % String(record.get("channel_constant", "")))
	builder.line("return _send_contract_message(network, peer_id, message, channel_id, options)")
	builder.dedent()
	builder.blank(2)

	builder.doc("检查消息是否为 %s。" % String(message_contract.message_type))
	builder.line("static func is_%s(message: GFNetworkMessage) -> bool:" % suffix)
	builder.indent()
	builder.line("return message != null and message.message_type == %s" % String(record.get("message_constant", "")))
	builder.dedent()
	builder.blank(2)

	builder.doc("读取 %s 消息 payload 副本。" % String(message_contract.message_type))
	builder.line("static func get_%s_payload(message: GFNetworkMessage) -> Dictionary:" % suffix)
	builder.indent()
	builder.line("return message.payload.duplicate(true) if message != null else {}")
	builder.dedent()
	builder.blank(2)

	for field_record: Dictionary in field_records:
		_append_field_getter(builder, suffix, field_record)


func _append_payload_builder(builder: GFSourceBuilder, field_records: Array) -> void:
	builder.line("var payload: Dictionary = {}")
	for field_record: Dictionary in field_records:
		var field := field_record.get("field") as GFNetworkContractField
		var field_constant := String(field_record.get("field_constant", ""))
		var parameter_name := String(field_record.get("parameter_name", ""))
		if _should_omit_null_optional_parameter(field):
			builder.line("if %s != null or bool(options.get(\"include_null_optional_fields\", false)):" % parameter_name)
			builder.indent()
			builder.line("payload[%s] = %s" % [field_constant, parameter_name])
			builder.dedent()
			continue

		builder.line("payload[%s] = %s" % [
			String(field_record.get("field_constant", "")),
			String(field_record.get("parameter_name", "")),
		])


func _append_field_getter(builder: GFSourceBuilder, suffix: String, field_record: Dictionary) -> void:
	var field := field_record.get("field") as GFNetworkContractField
	var field_suffix := _to_snake_identifier(String(field.field_name), "field")
	var return_type := _get_gdscript_type(field)
	var default_literal := _get_default_literal(field)
	builder.doc("读取 %s 字段。" % String(field.field_name))
	builder.line("static func get_%s_%s(message: GFNetworkMessage, default_value: %s = %s) -> %s:" % [
		suffix,
		field_suffix,
		return_type,
		default_literal,
		return_type,
	])
	builder.indent()
	builder.line("var value: Variant = _get_payload_value(message, %s, default_value)" % String(field_record.get("field_constant", "")))
	match field.value_type:
		GFNetworkContractField.ValueType.VARIANT:
			builder.line("return value")
		GFNetworkContractField.ValueType.BOOL:
			builder.line("return bool(value)")
		GFNetworkContractField.ValueType.INT:
			builder.line("return int(value)")
		GFNetworkContractField.ValueType.FLOAT:
			builder.line("return float(value)")
		GFNetworkContractField.ValueType.STRING:
			builder.line("return str(value)")
		GFNetworkContractField.ValueType.STRING_NAME:
			builder.line("return StringName(value)")
		GFNetworkContractField.ValueType.DICTIONARY:
			builder.line("return (value as Dictionary).duplicate(true) if value is Dictionary else default_value")
		GFNetworkContractField.ValueType.ARRAY:
			builder.line("return (value as Array).duplicate(true) if value is Array else default_value")
		GFNetworkContractField.ValueType.OBJECT:
			builder.line("return value as Object if value is Object else default_value")
		_:
			builder.line("return value if value is %s else default_value" % return_type)
	builder.dedent()
	builder.blank(2)


func _append_private_helpers(builder: GFSourceBuilder) -> void:
	builder.section("私有/辅助方法")
	builder.line("static func _get_payload_value(message: GFNetworkMessage, field_name: StringName, default_value: Variant = null) -> Variant:")
	builder.indent()
	builder.line("if message == null:")
	builder.indent()
	builder.line("return default_value")
	builder.dedent()
	builder.line("if message.payload.has(field_name):")
	builder.indent()
	builder.line("return message.payload[field_name]")
	builder.dedent()
	builder.line("return message.payload.get(String(field_name), default_value)")
	builder.dedent()
	builder.blank(2)

	builder.line("static func _send_contract_message(network: GFNetworkUtility, peer_id: int, message: GFNetworkMessage, channel_id: StringName, options: Dictionary = {}) -> Error:")
	builder.indent()
	builder.line("if network == null:")
	builder.indent()
	builder.line("return ERR_UNCONFIGURED")
	builder.dedent()
	builder.line("var send_options := _get_send_options(options)")
	builder.line("if channel_id != &\"\" and network.get_channel(channel_id) != null:")
	builder.indent()
	builder.line("return network.send_message_on_channel(peer_id, message, channel_id, send_options)")
	builder.dedent()
	builder.line("return network.send_message(peer_id, message, send_options)")
	builder.dedent()
	builder.blank(2)

	builder.line("static func _get_send_options(options: Dictionary) -> Dictionary:")
	builder.indent()
	builder.line("var send_options: Variant = options.get(\"send_options\", {})")
	builder.line("return (send_options as Dictionary).duplicate(true) if send_options is Dictionary else {}")
	builder.dedent()


func _build_function_parameters(field_records: Array, include_options: bool) -> PackedStringArray:
	var params := PackedStringArray()
	for field_record: Dictionary in field_records:
		var field := field_record.get("field") as GFNetworkContractField
		var parameter := "%s: %s" % [
			String(field_record.get("parameter_name", "")),
			_get_parameter_type(field),
		]
		if not field.required:
			parameter += " = %s" % _get_parameter_default_literal(field)
		params.append(parameter)
	if include_options:
		params.append("options: Dictionary = {}")
	return params


func _build_make_call_arguments(field_records: Array) -> String:
	var args := PackedStringArray()
	for field_record: Dictionary in field_records:
		args.append(String(field_record.get("parameter_name", "")))
	args.append("options")
	return ", ".join(args)


func _get_gdscript_type(field: GFNetworkContractField) -> String:
	match field.value_type:
		GFNetworkContractField.ValueType.BOOL:
			return "bool"
		GFNetworkContractField.ValueType.INT:
			return "int"
		GFNetworkContractField.ValueType.FLOAT:
			return "float"
		GFNetworkContractField.ValueType.STRING:
			return "String"
		GFNetworkContractField.ValueType.STRING_NAME:
			return "StringName"
		GFNetworkContractField.ValueType.VECTOR2:
			return "Vector2"
		GFNetworkContractField.ValueType.VECTOR3:
			return "Vector3"
		GFNetworkContractField.ValueType.VECTOR2I:
			return "Vector2i"
		GFNetworkContractField.ValueType.VECTOR3I:
			return "Vector3i"
		GFNetworkContractField.ValueType.COLOR:
			return "Color"
		GFNetworkContractField.ValueType.DICTIONARY:
			return "Dictionary"
		GFNetworkContractField.ValueType.ARRAY:
			return "Array"
		GFNetworkContractField.ValueType.NODE_PATH:
			return "NodePath"
		GFNetworkContractField.ValueType.OBJECT:
			return "Object"
		_:
			return "Variant"


func _get_parameter_type(field: GFNetworkContractField) -> String:
	if _should_omit_null_optional_parameter(field):
		return "Variant"
	return _get_gdscript_type(field)


func _get_parameter_default_literal(field: GFNetworkContractField) -> String:
	if _should_omit_null_optional_parameter(field):
		return "null"
	return _get_default_literal(field)


func _should_omit_null_optional_parameter(field: GFNetworkContractField) -> bool:
	return field != null and not field.required and field.default_value == null


func _get_default_literal(field: GFNetworkContractField) -> String:
	if field.default_value != null:
		var literal := _variant_literal(field.default_value)
		if not literal.is_empty():
			return literal

	match field.value_type:
		GFNetworkContractField.ValueType.BOOL:
			return "false"
		GFNetworkContractField.ValueType.INT:
			return "0"
		GFNetworkContractField.ValueType.FLOAT:
			return "0.0"
		GFNetworkContractField.ValueType.STRING:
			return "\"\""
		GFNetworkContractField.ValueType.STRING_NAME:
			return "&\"\""
		GFNetworkContractField.ValueType.VECTOR2:
			return "Vector2.ZERO"
		GFNetworkContractField.ValueType.VECTOR3:
			return "Vector3.ZERO"
		GFNetworkContractField.ValueType.VECTOR2I:
			return "Vector2i.ZERO"
		GFNetworkContractField.ValueType.VECTOR3I:
			return "Vector3i.ZERO"
		GFNetworkContractField.ValueType.COLOR:
			return "Color.WHITE"
		GFNetworkContractField.ValueType.DICTIONARY:
			return "{}"
		GFNetworkContractField.ValueType.ARRAY:
			return "[]"
		GFNetworkContractField.ValueType.NODE_PATH:
			return "NodePath(\"\")"
		GFNetworkContractField.ValueType.OBJECT:
			return "null"
		_:
			return "null"


func _variant_literal(value: Variant) -> String:
	if value == null:
		return "null"
	match typeof(value):
		TYPE_BOOL:
			return "true" if bool(value) else "false"
		TYPE_INT:
			return str(int(value))
		TYPE_FLOAT:
			var text := str(float(value))
			return text if text.contains(".") else text + ".0"
		TYPE_STRING:
			return "\"%s\"" % String(value).c_escape()
		TYPE_STRING_NAME:
			return "&\"%s\"" % String(value).c_escape()
		TYPE_VECTOR2:
			var vector2 := value as Vector2
			return "Vector2(%s, %s)" % [_float_literal(vector2.x), _float_literal(vector2.y)]
		TYPE_VECTOR3:
			var vector3 := value as Vector3
			return "Vector3(%s, %s, %s)" % [_float_literal(vector3.x), _float_literal(vector3.y), _float_literal(vector3.z)]
		TYPE_VECTOR2I:
			var vector2i := value as Vector2i
			return "Vector2i(%d, %d)" % [vector2i.x, vector2i.y]
		TYPE_VECTOR3I:
			var vector3i := value as Vector3i
			return "Vector3i(%d, %d, %d)" % [vector3i.x, vector3i.y, vector3i.z]
		TYPE_COLOR:
			var color := value as Color
			return "Color(%s, %s, %s, %s)" % [
				_float_literal(color.r),
				_float_literal(color.g),
				_float_literal(color.b),
				_float_literal(color.a),
			]
		TYPE_NODE_PATH:
			return "NodePath(\"%s\")" % String(value).c_escape()
		_:
			return ""


func _float_literal(value: float) -> String:
	var text := str(value)
	return text if text.contains(".") else text + ".0"


func _to_pascal_identifier(value: String, fallback: String) -> String:
	var base := _to_snake_identifier(value, fallback).to_pascal_case()
	if base.is_empty():
		base = fallback
	if _starts_with_digit(base):
		base = "%s%s" % [fallback, base]
	return base


func _to_snake_identifier(value: String, fallback: String) -> String:
	var snake := value.to_snake_case().to_lower()
	var result := ""
	var previous_was_separator := false
	for index: int in range(snake.length()):
		var code := snake.unicode_at(index)
		var valid := (
			(code >= 97 and code <= 122)
			or (code >= 48 and code <= 57)
			or code == 95
		)
		if valid:
			result += snake.substr(index, 1)
			previous_was_separator = code == 95
		elif not previous_was_separator:
			result += "_"
			previous_was_separator = true

	result = result.strip_edges().trim_prefix("_").trim_suffix("_")
	if result.is_empty():
		result = fallback.to_snake_case().to_lower()
	if _starts_with_digit(result):
		result = "%s_%s" % [fallback.to_snake_case().to_lower(), result]
	return result


func _to_constant_name(value: String, fallback: String) -> String:
	var name := _to_snake_identifier(value, fallback).to_upper()
	return name if not name.is_empty() else fallback


func _make_unique_name(base_name: String, used_names: Dictionary) -> String:
	var candidate := base_name
	var index := 2
	while used_names.has(candidate):
		candidate = "%s_%d" % [base_name, index]
		index += 1
	used_names[candidate] = true
	return candidate


func _get_generation_next_actions() -> Dictionary:
	return {
		"invalid_contract_resource": "Check that the configured path points to a GFNetworkContract resource.",
		"generate_failed": "Review the output path, overwrite setting, and filesystem error.",
	}


func _starts_with_digit(value: String) -> bool:
	return not value.is_empty() and value.unicode_at(0) >= 48 and value.unicode_at(0) <= 57
