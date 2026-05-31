@tool

# GF Network 扩展编辑器菜单动作。
extends RefCounted


# --- 常量 ---

const _MENU_ACTION_GENERATE_CONTRACTS: StringName = &"generate_network_contracts"
const _SETTING_CONTRACT_PATHS: String = "gf/network/contract_paths"
const _SETTING_CONTRACT_OUTPUT_DIR: String = "gf/network/contract_output_dir"
const _DEFAULT_OUTPUT_DIR: String = "res://gf/generated/network"
const _DIAGNOSTIC_DIALOG_MIN_SIZE: Vector2 = Vector2(720.0, 460.0)
const _GF_NETWORK_CONTRACT_GENERATOR_SCRIPT = preload("res://addons/gf/extensions/network/editor/gf_network_contract_generator.gd")


# --- 私有变量 ---

var _diagnostic_dialog: AcceptDialog = null
var _diagnostic_output: TextEdit = null


# --- 框架内部方法 ---

## 初始化 Network 编辑器动作需要的项目设置默认值。
## [br]
## @api framework_internal
func setup() -> void:
	if not ProjectSettings.has_setting(_SETTING_CONTRACT_PATHS):
		ProjectSettings.set_setting(_SETTING_CONTRACT_PATHS, PackedStringArray())
	if not ProjectSettings.has_setting(_SETTING_CONTRACT_OUTPUT_DIR):
		ProjectSettings.set_setting(_SETTING_CONTRACT_OUTPUT_DIR, _DEFAULT_OUTPUT_DIR)


## 获取 Network 扩展贡献的 GF 工具菜单项。
## [br]
## @api framework_internal
## [br]
## @return 菜单项记录列表。
## [br]
## @schema return: Array[Dictionary]，每个值包含 id、label、section。
func get_menu_entries() -> Array[Dictionary]:
	return [
		{
			"id": _MENU_ACTION_GENERATE_CONTRACTS,
			"label": "生成 Network Contract 访问器",
			"section": "代码生成",
		},
	]


## 执行 Network 扩展菜单动作。
## [br]
## @api framework_internal
## [br]
## @param action_id: 菜单动作 ID。
func handle_menu_action(action_id: StringName) -> void:
	match action_id:
		_MENU_ACTION_GENERATE_CONTRACTS:
			_generate_contract_accessors()


## 清理菜单动作持有的 UI。
## [br]
## @api framework_internal
func cleanup() -> void:
	_cleanup_diagnostic_dialog()


# --- 私有/辅助方法 ---

func _generate_contract_accessors() -> void:
	var contract_paths: PackedStringArray = _read_contract_paths()
	if contract_paths.is_empty():
		_show_diagnostic_dialog(
			"GF Network Contracts",
			"未配置契约资源。请在 ProjectSettings.%s 中填入 GFNetworkContract 资源路径。" % _SETTING_CONTRACT_PATHS
		)
		return

	var output_dir: String = GFVariantData.to_text(ProjectSettings.get_setting(_SETTING_CONTRACT_OUTPUT_DIR, _DEFAULT_OUTPUT_DIR)).strip_edges()
	if output_dir.is_empty():
		output_dir = _DEFAULT_OUTPUT_DIR

	var generator: GFNetworkContractGenerator = _GF_NETWORK_CONTRACT_GENERATOR_SCRIPT.new()
	var report: Dictionary = generator.generate_many(contract_paths, output_dir)
	var lines: PackedStringArray = PackedStringArray()
	var _append_result_88: Variant = lines.append("Output: %s" % output_dir)
	var _append_result_89: Variant = lines.append("Generated: %d" % GFVariantData.get_option_int(report, "generated_count"))
	var _append_result_90: Variant = lines.append("")
	for item_variant: Variant in GFVariantData.get_option_array(report, "generated"):
		if not (item_variant is Dictionary):
			continue
		var item: Dictionary = GFVariantData.as_dictionary(item_variant)
		var _append_result_95: Variant = lines.append("- %s -> %s (%s)" % [
			GFVariantData.get_option_string(item, "contract_path"),
			GFVariantData.get_option_string(item, "output_path"),
			GFVariantData.get_option_string(item, "error_name"),
		])
	for issue_variant: Variant in GFVariantData.get_option_array(report, "issues"):
		if not (issue_variant is Dictionary):
			continue
		var issue: Dictionary = GFVariantData.as_dictionary(issue_variant)
		var _append_result_104: Variant = lines.append("! %s %s: %s" % [
			GFVariantData.get_option_string(issue, "kind"),
			GFVariantData.get_option_string(issue, "path"),
			GFVariantData.get_option_string(issue, "message"),
		])
	_show_diagnostic_dialog("GF Network Contracts", "\n".join(lines))


func _read_contract_paths() -> PackedStringArray:
	var value: Variant = ProjectSettings.get_setting(_SETTING_CONTRACT_PATHS, PackedStringArray())
	var result: PackedStringArray = PackedStringArray()
	if value is PackedStringArray:
		for path: String in value:
			_append_contract_path(result, path)
	elif value is Array:
		for path_variant: Variant in value:
			_append_contract_path(result, GFVariantData.to_text(path_variant))
	elif value is String:
		for path: String in GFVariantData.to_text(value).split(",", false):
			_append_contract_path(result, path)
	return result


func _append_contract_path(result: PackedStringArray, path: String) -> void:
	var normalized_path: String = path.strip_edges()
	if normalized_path.is_empty() or result.has(normalized_path):
		return
	var _append_result_131: Variant = result.append(normalized_path)


func _show_diagnostic_dialog(title: String, text: String) -> void:
	if not is_instance_valid(_diagnostic_dialog):
		_diagnostic_dialog = AcceptDialog.new()
		var dialog_min_size: Vector2i = Vector2i(
			int(_DIAGNOSTIC_DIALOG_MIN_SIZE.x),
			int(_DIAGNOSTIC_DIALOG_MIN_SIZE.y)
		)
		_diagnostic_dialog.min_size = dialog_min_size
		_diagnostic_output = TextEdit.new()
		_diagnostic_output.editable = false
		_diagnostic_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_diagnostic_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_diagnostic_dialog.add_child(_diagnostic_output)
		EditorInterface.get_base_control().add_child(_diagnostic_dialog)

	_diagnostic_dialog.title = title
	if is_instance_valid(_diagnostic_output):
		_diagnostic_output.text = text
	_diagnostic_dialog.popup_centered(Vector2i(
		int(_DIAGNOSTIC_DIALOG_MIN_SIZE.x),
		int(_DIAGNOSTIC_DIALOG_MIN_SIZE.y)
	))


func _cleanup_diagnostic_dialog() -> void:
	if is_instance_valid(_diagnostic_dialog):
		_diagnostic_dialog.queue_free()
	_diagnostic_dialog = null
	_diagnostic_output = null
