@tool

## GFAccessGenerator: 生成强类型 GF 访问器脚本。
##
## 生成结果用于减少 `Gf.get_model(Type) as Type` 这类重复样板，
## 并为 Model / System / Utility / Command / Query 提供稳定的 IDE 补全入口。
class_name GFAccessGenerator
extends RefCounted


# --- 枚举 ---

enum TargetKind {
	MODEL,
	SYSTEM,
	UTILITY,
	COMMAND,
	QUERY,
	CAPABILITY,
}


# --- 常量 ---

const DEFAULT_OUTPUT_PATH: String = "res://gf/generated/gf_access.gd"
const _BASE_MODEL_SCRIPT: Script = preload("res://addons/gf/base/gf_model.gd")
const _BASE_SYSTEM_SCRIPT: Script = preload("res://addons/gf/base/gf_system.gd")
const _BASE_UTILITY_SCRIPT: Script = preload("res://addons/gf/base/gf_utility.gd")
const _BASE_COMMAND_SCRIPT: Script = preload("res://addons/gf/base/gf_command.gd")
const _BASE_QUERY_SCRIPT: Script = preload("res://addons/gf/base/gf_query.gd")
const _BASE_CAPABILITY_SCRIPT: Script = preload("res://addons/gf/extensions/capability/gf_capability.gd")
const _BASE_NODE_CAPABILITY_SCRIPT: Script = preload("res://addons/gf/extensions/capability/gf_node_capability.gd")


# --- 公共方法 ---

## 扫描项目 class_name 脚本并生成访问器。
func generate(output_path: String = DEFAULT_OUTPUT_PATH) -> Error:
	var records := collect_records()
	var source := build_source(records)
	return save_source(output_path, source)


## 收集当前项目中可生成访问器的 GF 类型记录。
func collect_records() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for global_class in ProjectSettings.get_global_class_list():
		var class_name_value := String(global_class.get("class", ""))
		var path := String(global_class.get("path", ""))
		if class_name_value.is_empty() or path.is_empty():
			continue

		var script := load(path) as Script
		if script == null:
			continue

		var kind := _resolve_kind(script)
		if kind == -1:
			continue

		records.append({
			"class_name": class_name_value,
			"path": path,
			"kind": kind,
		})

	_sort_records(records)
	return records


## 根据记录生成访问器源码。测试可直接调用该方法验证输出。
func build_source(records: Array) -> String:
	var output := PackedStringArray()
	output.append("## GFAccess: 自动生成的强类型 GF 访问器。")
	output.append("##")
	output.append("## 该文件由 GFAccessGenerator 生成，可以提交到版本库；请不要手动编辑。")
	output.append("class_name GFAccess")
	output.append("extends RefCounted")
	output.append("")
	output.append("")
	output.append("# --- 常量 ---")
	output.append("")
	output.append("const _CAPABILITY_UTILITY_SCRIPT: Script = preload(\"res://addons/gf/extensions/capability/gf_capability_utility.gd\")")
	output.append("")
	output.append("")
	output.append("# --- 公共方法 ---")
	output.append("")
	output.append("## 获取传入架构或当前全局架构。")
	output.append("static func architecture_or_null(architecture: GFArchitecture = null) -> GFArchitecture:")
	output.append("\tif architecture != null:")
	output.append("\t\treturn architecture")
	output.append("\treturn GFAutoload.get_architecture_or_null()")
	output.append("")

	var used_names: Dictionary = {}
	for record in records:
		_append_record_function(output, record, used_names)

	output.append("")
	output.append("# --- 私有/辅助方法 ---")
	output.append("")
	output.append("static func _create_instance(script_cls: Script, architecture: GFArchitecture = null) -> Object:")
	output.append("\tvar resolved_architecture := architecture_or_null(architecture)")
	output.append("\tif resolved_architecture != null and resolved_architecture.has_factory(script_cls):")
	output.append("\t\treturn resolved_architecture.create_instance(script_cls)")
	output.append("")
	output.append("\tif script_cls == null or not script_cls.can_instantiate():")
	output.append("\t\treturn null")
	output.append("")
	output.append("\tvar instance := script_cls.new() as Object")
	output.append("\tif resolved_architecture != null:")
	output.append("\t\t_inject_if_needed(instance, resolved_architecture)")
	output.append("\treturn instance")
	output.append("")
	output.append("")
	output.append("static func _get_capability_utility(architecture: GFArchitecture = null) -> Object:")
	output.append("\tvar resolved_architecture := architecture_or_null(architecture)")
	output.append("\tif resolved_architecture == null:")
	output.append("\t\treturn null")
	output.append("\treturn resolved_architecture.get_utility(_CAPABILITY_UTILITY_SCRIPT)")
	output.append("")
	output.append("")
	output.append("static func _inject_if_needed(instance: Object, architecture: GFArchitecture) -> void:")
	output.append("\tif instance == null or architecture == null:")
	output.append("\t\treturn")
	output.append("\tif instance.has_method(\"inject_dependencies\"):")
	output.append("\t\tinstance.inject_dependencies(architecture)")
	output.append("\tif instance.has_method(\"inject\"):")
	output.append("\t\tinstance.inject(architecture)")

	return "\n".join(output) + "\n"


## 保存生成源码到指定路径。
func save_source(output_path: String, source: String) -> Error:
	if output_path.is_empty():
		push_error("[GFAccessGenerator] 输出路径为空。")
		return ERR_INVALID_PARAMETER

	DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		var open_error := FileAccess.get_open_error()
		push_error("[GFAccessGenerator] 无法写入访问器脚本：%s (%s)" % [output_path, error_string(open_error)])
		return open_error

	file.store_string(source)
	file.close()

	if Engine.is_editor_hint():
		var filesystem := EditorInterface.get_resource_filesystem()
		if filesystem != null:
			filesystem.scan()

	return OK


# --- 私有/辅助方法 ---

func _resolve_kind(script: Script) -> int:
	if script == _BASE_MODEL_SCRIPT or script == _BASE_SYSTEM_SCRIPT or script == _BASE_UTILITY_SCRIPT:
		return -1
	if script == _BASE_COMMAND_SCRIPT or script == _BASE_QUERY_SCRIPT:
		return -1
	if script == _BASE_CAPABILITY_SCRIPT or script == _BASE_NODE_CAPABILITY_SCRIPT:
		return -1

	if _script_extends_or_equals(script, _BASE_MODEL_SCRIPT):
		return TargetKind.MODEL
	if _script_extends_or_equals(script, _BASE_SYSTEM_SCRIPT):
		return TargetKind.SYSTEM
	if _script_extends_or_equals(script, _BASE_UTILITY_SCRIPT):
		return TargetKind.UTILITY
	if _script_extends_or_equals(script, _BASE_COMMAND_SCRIPT):
		return TargetKind.COMMAND
	if _script_extends_or_equals(script, _BASE_QUERY_SCRIPT):
		return TargetKind.QUERY
	if (
		_script_extends_or_equals(script, _BASE_CAPABILITY_SCRIPT)
		or _script_extends_or_equals(script, _BASE_NODE_CAPABILITY_SCRIPT)
	):
		return TargetKind.CAPABILITY

	return -1


func _append_record_function(output: PackedStringArray, record: Dictionary, used_names: Dictionary) -> void:
	var class_name_value := String(record["class_name"])
	var kind := int(record["kind"])
	var function_name := _get_function_name(class_name_value, kind)
	if used_names.has(function_name):
		push_warning("[GFAccessGenerator] 函数名重复，已跳过：%s" % function_name)
		return
	used_names[function_name] = true

	match kind:
		TargetKind.MODEL:
			output.append("## 获取 %s Model。" % class_name_value)
			output.append("static func %s(architecture: GFArchitecture = null) -> %s:" % [function_name, class_name_value])
			output.append("\tvar resolved_architecture := architecture_or_null(architecture)")
			output.append("\tif resolved_architecture == null:")
			output.append("\t\treturn null")
			output.append("\treturn resolved_architecture.get_model(%s) as %s" % [class_name_value, class_name_value])
			output.append("")
			output.append("")

		TargetKind.SYSTEM:
			output.append("## 获取 %s System。" % class_name_value)
			output.append("static func %s(architecture: GFArchitecture = null) -> %s:" % [function_name, class_name_value])
			output.append("\tvar resolved_architecture := architecture_or_null(architecture)")
			output.append("\tif resolved_architecture == null:")
			output.append("\t\treturn null")
			output.append("\treturn resolved_architecture.get_system(%s) as %s" % [class_name_value, class_name_value])
			output.append("")
			output.append("")

		TargetKind.UTILITY:
			output.append("## 获取 %s Utility。" % class_name_value)
			output.append("static func %s(architecture: GFArchitecture = null) -> %s:" % [function_name, class_name_value])
			output.append("\tvar resolved_architecture := architecture_or_null(architecture)")
			output.append("\tif resolved_architecture == null:")
			output.append("\t\treturn null")
			output.append("\treturn resolved_architecture.get_utility(%s) as %s" % [class_name_value, class_name_value])
			output.append("")
			output.append("")

		TargetKind.COMMAND, TargetKind.QUERY:
			output.append("## 创建 %s 实例。" % class_name_value)
			output.append("static func %s(architecture: GFArchitecture = null) -> %s:" % [function_name, class_name_value])
			output.append("\treturn _create_instance(%s, architecture) as %s" % [class_name_value, class_name_value])
			output.append("")
			output.append("")

		TargetKind.CAPABILITY:
			var base_name := _trim_suffix(class_name_value.to_snake_case(), "_capability")
			output.append("## 获取 receiver 上的 %s 能力。" % class_name_value)
			output.append("static func get_%s_capability(receiver: Object, architecture: GFArchitecture = null) -> %s:" % [base_name, class_name_value])
			output.append("\tvar capability_utility := _get_capability_utility(architecture)")
			output.append("\tif capability_utility == null:")
			output.append("\t\treturn null")
			output.append("\treturn capability_utility.get_capability(receiver, %s) as %s" % [class_name_value, class_name_value])
			output.append("")
			output.append("")
			output.append("## 给 receiver 添加 %s 能力。" % class_name_value)
			output.append("static func add_%s_capability(receiver: Object, architecture: GFArchitecture = null) -> %s:" % [base_name, class_name_value])
			output.append("\tvar capability_utility := _get_capability_utility(architecture)")
			output.append("\tif capability_utility == null:")
			output.append("\t\treturn null")
			output.append("\treturn capability_utility.add_capability(receiver, %s) as %s" % [class_name_value, class_name_value])
			output.append("")
			output.append("")
			output.append("## 检查 receiver 是否拥有 %s 能力。" % class_name_value)
			output.append("static func has_%s_capability(receiver: Object, architecture: GFArchitecture = null) -> bool:" % base_name)
			output.append("\tvar capability_utility := _get_capability_utility(architecture)")
			output.append("\tif capability_utility == null:")
			output.append("\t\treturn false")
			output.append("\treturn capability_utility.has_capability(receiver, %s)" % class_name_value)
			output.append("")
			output.append("")
			output.append("## 移除 receiver 上的 %s 能力。" % class_name_value)
			output.append("static func remove_%s_capability(receiver: Object, architecture: GFArchitecture = null) -> void:" % base_name)
			output.append("\tvar capability_utility := _get_capability_utility(architecture)")
			output.append("\tif capability_utility != null:")
			output.append("\t\tcapability_utility.remove_capability(receiver, %s)" % class_name_value)
			output.append("")
			output.append("")
			output.append("## 当 receiver 拥有 %s 能力时执行回调。" % class_name_value)
			output.append("static func if_has_%s_capability(receiver: Object, callback: Callable, architecture: GFArchitecture = null) -> Variant:" % base_name)
			output.append("\tvar capability := get_%s_capability(receiver, architecture)" % base_name)
			output.append("\tif capability == null or not callback.is_valid():")
			output.append("\t\treturn null")
			output.append("\treturn callback.call(capability)")
			output.append("")
			output.append("")


func _get_function_name(class_name_value: String, kind: int) -> String:
	var base_name := class_name_value.to_snake_case()
	match kind:
		TargetKind.MODEL:
			return "get_%s_model" % _trim_suffix(base_name, "_model")
		TargetKind.SYSTEM:
			return "get_%s_system" % _trim_suffix(base_name, "_system")
		TargetKind.UTILITY:
			return "get_%s_utility" % _trim_suffix(base_name, "_utility")
		TargetKind.COMMAND:
			return "create_%s_command" % _trim_suffix(base_name, "_command")
		TargetKind.QUERY:
			return "create_%s_query" % _trim_suffix(base_name, "_query")
		TargetKind.CAPABILITY:
			return "get_%s_capability" % _trim_suffix(base_name, "_capability")
		_:
			return base_name


func _trim_suffix(value: String, suffix: String) -> String:
	if value.ends_with(suffix):
		return value.substr(0, value.length() - suffix.length())
	return value


func _sort_records(records: Array[Dictionary]) -> void:
	records.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_kind := int(left["kind"])
		var right_kind := int(right["kind"])
		if left_kind != right_kind:
			return left_kind < right_kind
		return String(left["class_name"]) < String(right["class_name"])
	)


func _script_extends_or_equals(candidate: Script, expected: Script) -> bool:
	var current := candidate
	while current != null:
		if current == expected:
			return true
		current = current.get_base_script()
	return false
