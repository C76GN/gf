@tool

## GF 包管理器底部面板。
##
## 展示 `gf_package.json` 元数据，并把包启用状态保存到 ProjectSettings。
extends VBoxContainer


# --- 常量 ---

const GFPackageSettingsBase = preload("res://addons/gf/kernel/package/gf_package_settings.gd")
const GFPackageUsageAuditBase = preload("res://addons/gf/kernel/package/gf_package_usage_audit.gd")
const PACKAGE_ROW_MIN_HEIGHT: float = 32.0
const DETAILS_MIN_HEIGHT: float = 160.0
const CHECK_COLUMN_WIDTH: float = 40.0
const KIND_COLUMN_WIDTH: float = 72.0
const VERSION_COLUMN_WIDTH: float = 72.0
const STATUS_COLUMN_WIDTH: float = 72.0
const FILTER_ALL: int = 0
const FILTER_OFFICIAL: int = 1
const FILTER_COMMUNITY: int = 2


# --- 私有变量 ---

var _package_rows: VBoxContainer
var _details_output: RichTextLabel
var _status_label: Label
var _auto_install_check: CheckBox
var _export_exclude_check: CheckBox
var _filter_option: OptionButton
var _search_field: LineEdit
var _package_checks: Dictionary = {}
var _selection_by_id: Dictionary = {}
var _manifests: Array[GFPackageManifest] = []
var _selected_manifest_id: String = ""
var _usage_report: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init() -> void:
	name = "GF Packages"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_ui()
	call_deferred("_refresh_packages")


# --- 私有/辅助方法 ---

func _build_ui() -> void:
	var toolbar := HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(toolbar)

	var title := Label.new()
	title.text = "GF Packages"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(title)

	var reload_button := Button.new()
	reload_button.text = "重新加载"
	reload_button.tooltip_text = "重新读取所有 gf_package.json"
	reload_button.pressed.connect(_refresh_packages)
	toolbar.add_child(reload_button)

	var scan_button := Button.new()
	scan_button.text = "扫描引用"
	scan_button.tooltip_text = "检查当前禁用包是否仍被项目文件直接引用"
	scan_button.pressed.connect(_scan_disabled_package_references)
	toolbar.add_child(scan_button)

	var defaults_button := Button.new()
	defaults_button.text = "恢复默认"
	defaults_button.tooltip_text = "恢复 GF 默认启用包"
	defaults_button.pressed.connect(_restore_default_selection)
	toolbar.add_child(defaults_button)

	var enable_button := Button.new()
	enable_button.text = "启用全部"
	enable_button.tooltip_text = "勾选当前发现的所有包"
	enable_button.pressed.connect(_set_all_enabled.bind(true))
	toolbar.add_child(enable_button)

	var disable_button := Button.new()
	disable_button.text = "禁用全部"
	disable_button.tooltip_text = "取消勾选当前发现的所有包"
	disable_button.pressed.connect(_set_all_enabled.bind(false))
	toolbar.add_child(disable_button)

	var apply_button := Button.new()
	apply_button.text = "保存设置"
	apply_button.tooltip_text = "写入 ProjectSettings 并保存 project.godot"
	apply_button.pressed.connect(_apply_selection)
	toolbar.add_child(apply_button)

	var option_row := HBoxContainer.new()
	option_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(option_row)

	_auto_install_check = CheckBox.new()
	_auto_install_check.text = "自动装配启用包 Installer"
	_auto_install_check.tooltip_text = "初始化 GF 时自动执行启用包 manifest 中声明的 installer_paths"
	option_row.add_child(_auto_install_check)

	_export_exclude_check = CheckBox.new()
	_export_exclude_check.text = "导出时排除禁用包"
	_export_exclude_check.tooltip_text = "项目导出阶段跳过禁用包根目录下的文件"
	option_row.add_child(_export_exclude_check)

	var filter_row := HBoxContainer.new()
	filter_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(filter_row)

	var filter_label := Label.new()
	filter_label.text = "分类"
	filter_row.add_child(filter_label)

	_filter_option = OptionButton.new()
	_filter_option.add_item("全部", FILTER_ALL)
	_filter_option.add_item("官方包", FILTER_OFFICIAL)
	_filter_option.add_item("社区包", FILTER_COMMUNITY)
	_filter_option.item_selected.connect(_on_filter_selected)
	filter_row.add_child(_filter_option)

	_search_field = LineEdit.new()
	_search_field.placeholder_text = "搜索名称、ID、标签"
	_search_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_field.text_changed.connect(_on_search_changed)
	filter_row.add_child(_search_field)

	var split := HSplitContainer.new()
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(split)

	var list_panel := VBoxContainer.new()
	list_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(list_panel)

	list_panel.add_child(_create_header_row())

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_panel.add_child(scroll)

	_package_rows = VBoxContainer.new()
	_package_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_package_rows)

	_details_output = RichTextLabel.new()
	_details_output.custom_minimum_size = Vector2(0.0, DETAILS_MIN_HEIGHT)
	_details_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_details_output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details_output.selection_enabled = true
	_details_output.scroll_active = true
	split.add_child(_details_output)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status_label)


func _create_header_row() -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	row.add_child(_create_header_label("启用", CHECK_COLUMN_WIDTH))
	var name_label := _create_header_label("包", 0.0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	row.add_child(_create_header_label("来源", KIND_COLUMN_WIDTH))
	row.add_child(_create_header_label("版本", VERSION_COLUMN_WIDTH))
	row.add_child(_create_header_label("状态", STATUS_COLUMN_WIDTH))
	return row


func _create_header_label(text: String, width: float) -> Label:
	var label := Label.new()
	label.text = text
	label.modulate = Color(0.75, 0.75, 0.75)
	if width > 0.0:
		label.custom_minimum_size = Vector2(width, 0.0)
	return label


func _refresh_packages() -> void:
	_package_checks.clear()
	_selection_by_id.clear()
	_clear_package_rows()

	_manifests = GFPackageSettingsBase.get_all_manifests(true)
	var enabled_ids := GFPackageSettingsBase.resolve_package_dependencies(
		GFPackageSettingsBase.get_enabled_package_ids(),
		_manifests
	)
	for manifest: GFPackageManifest in _manifests:
		_selection_by_id[manifest.id] = enabled_ids.has(manifest.id)

	_auto_install_check.button_pressed = GFPackageSettingsBase.should_auto_install_enabled_installers()
	_export_exclude_check.button_pressed = GFPackageSettingsBase.should_export_exclude_disabled_packages()
	_refresh_usage_report()

	_refresh_visible_package_rows()

	if not _manifests.is_empty():
		_show_manifest_details(_manifests[0])
	else:
		_details_output.text = "没有发现 GF 包。"
	_set_selection_status()


func _refresh_visible_package_rows() -> void:
	_package_checks.clear()
	_clear_package_rows()

	var visible_manifests := _get_visible_manifests()
	var last_kind := ""
	for manifest: GFPackageManifest in visible_manifests:
		if manifest.kind != last_kind:
			_add_group_header(manifest.kind)
			last_kind = manifest.kind
		_add_package_row(manifest, bool(_selection_by_id.get(manifest.id, false)))

	if visible_manifests.is_empty():
		var empty_label := Label.new()
		empty_label.text = "没有匹配的包。"
		empty_label.modulate = Color(0.65, 0.65, 0.65)
		_package_rows.add_child(empty_label)


func _clear_package_rows() -> void:
	for child: Node in _package_rows.get_children():
		child.queue_free()


func _add_group_header(kind: String) -> void:
	var label := Label.new()
	label.text = _format_kind(kind)
	label.modulate = Color(0.85, 0.85, 0.85)
	label.custom_minimum_size = Vector2(0.0, 28.0)
	_package_rows.add_child(label)


func _add_package_row(manifest: GFPackageManifest, enabled: bool) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0.0, PACKAGE_ROW_MIN_HEIGHT)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_package_rows.add_child(row)

	var check := CheckBox.new()
	check.button_pressed = enabled
	check.tooltip_text = manifest.id
	check.custom_minimum_size = Vector2(CHECK_COLUMN_WIDTH, 0.0)
	check.toggled.connect(_on_package_toggled.bind(manifest.id))
	row.add_child(check)
	_package_checks[manifest.id] = check

	var name_button := Button.new()
	name_button.flat = true
	name_button.text = manifest.display_name
	name_button.tooltip_text = "%s\n%s" % [manifest.id, manifest.description]
	name_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_button.pressed.connect(_show_manifest_details.bind(manifest))
	row.add_child(name_button)

	var kind_label := Label.new()
	kind_label.text = _format_kind(manifest.kind)
	kind_label.custom_minimum_size = Vector2(KIND_COLUMN_WIDTH, 0.0)
	row.add_child(kind_label)

	var version_label := Label.new()
	version_label.text = manifest.version
	version_label.custom_minimum_size = Vector2(VERSION_COLUMN_WIDTH, 0.0)
	row.add_child(version_label)

	var status_label := Label.new()
	status_label.text = "有效" if manifest.is_valid() else "无效"
	status_label.tooltip_text = _join_strings(manifest.get_validation_errors())
	status_label.custom_minimum_size = Vector2(STATUS_COLUMN_WIDTH, 0.0)
	row.add_child(status_label)


func _apply_selection() -> void:
	GFPackageSettingsBase.set_enabled_package_ids(_get_selected_enabled_ids(), true)
	GFPackageSettingsBase.set_auto_install_enabled_installers(_auto_install_check.button_pressed)
	GFPackageSettingsBase.set_export_exclude_disabled_packages(_export_exclude_check.button_pressed)
	ProjectSettings.save()
	_refresh_usage_report()
	_refresh_packages()
	if int(_usage_report.get("reference_count", 0)) > 0:
		_set_status("包设置已保存，但发现禁用包仍被引用，请检查详情。")
	else:
		_set_status("包设置已保存。")


func _set_all_enabled(enabled: bool) -> void:
	for manifest: GFPackageManifest in _manifests:
		_selection_by_id[manifest.id] = enabled
	_refresh_usage_report()
	_refresh_visible_package_rows()
	_set_status("选择已更新，点击“保存设置”后生效。")


func _restore_default_selection() -> void:
	var default_ids := GFPackageSettingsBase.get_default_enabled_package_ids()
	for manifest: GFPackageManifest in _manifests:
		_selection_by_id[manifest.id] = default_ids.has(manifest.id)
	_refresh_usage_report()
	_refresh_visible_package_rows()
	_set_status("已恢复默认选择，点击“保存设置”后生效。")


func _show_manifest_details(manifest: GFPackageManifest) -> void:
	_selected_manifest_id = manifest.id

	var lines := PackedStringArray()
	lines.append("名称：%s" % manifest.display_name)
	lines.append("ID：%s" % manifest.id)
	lines.append("版本：%s" % manifest.version)
	lines.append("来源：%s" % _format_kind(manifest.kind))
	lines.append("默认启用：%s" % ("是" if manifest.enabled_by_default else "否"))
	lines.append("当前启用：%s" % ("是" if bool(_selection_by_id.get(manifest.id, false)) else "否"))
	lines.append("状态：%s" % ("有效" if manifest.is_valid() else "无效"))
	lines.append("根目录：%s" % manifest.root_path)
	lines.append("")
	lines.append(manifest.description)
	lines.append("")
	lines.append("依赖：%s" % _format_dependencies(manifest.dependencies))
	lines.append("Installer：%s" % _format_string_array(manifest.installer_paths))
	lines.append("菜单动作：%s" % _format_string_array(manifest.editor_action_paths))
	lines.append("底部面板：%s" % _format_string_array(manifest.editor_dock_paths))
	lines.append("Inspector：%s" % _format_string_array(manifest.editor_inspector_paths))
	lines.append("导出插件：%s" % _format_string_array(manifest.export_plugin_paths))
	lines.append("访问器扩展：%s" % _format_string_array(manifest.access_generator_extension_paths))
	lines.append("标签：%s" % _format_string_array(manifest.tags))
	_append_usage_warning_lines(lines, manifest)

	var errors := manifest.get_validation_errors()
	if not errors.is_empty():
		lines.append("")
		lines.append("校验问题：")
		for error: String in errors:
			lines.append("- %s" % error)

	_details_output.text = "\n".join(lines)


func _get_visible_manifests() -> Array[GFPackageManifest]:
	var result: Array[GFPackageManifest] = []
	for manifest: GFPackageManifest in _manifests:
		if not _matches_filter(manifest):
			continue
		if not _matches_search(manifest):
			continue
		result.append(manifest)
	return result


func _matches_filter(manifest: GFPackageManifest) -> bool:
	match _filter_option.get_selected_id():
		FILTER_OFFICIAL:
			return manifest.kind == GFPackageManifest.KIND_OFFICIAL
		FILTER_COMMUNITY:
			return manifest.kind == GFPackageManifest.KIND_COMMUNITY
		_:
			return true


func _matches_search(manifest: GFPackageManifest) -> bool:
	if _search_field == null:
		return true

	var query := _search_field.text.strip_edges().to_lower()
	if query.is_empty():
		return true

	var haystack := "%s %s %s %s %s" % [
		manifest.display_name,
		manifest.id,
		manifest.description,
		manifest.kind,
		_join_strings(manifest.tags),
	]
	return haystack.to_lower().contains(query)


func _get_selected_enabled_ids() -> Array[String]:
	var ids: Array[String] = []
	for manifest: GFPackageManifest in _manifests:
		if bool(_selection_by_id.get(manifest.id, false)):
			ids.append(manifest.id)
	ids.sort()
	return ids


func _get_disabled_manifests_from_selection() -> Array[GFPackageManifest]:
	var manifests: Array[GFPackageManifest] = []
	for manifest: GFPackageManifest in _manifests:
		if not bool(_selection_by_id.get(manifest.id, false)):
			manifests.append(manifest)
	return manifests


func _refresh_usage_report() -> void:
	_usage_report = GFPackageUsageAuditBase.audit_disabled_packages(
		_get_disabled_manifests_from_selection(),
		{
			"max_references_per_package": 20,
		}
	)


func _append_usage_warning_lines(lines: PackedStringArray, manifest: GFPackageManifest) -> void:
	if bool(_selection_by_id.get(manifest.id, false)):
		return

	var packages := _usage_report.get("packages", {}) as Dictionary
	if not packages.has(manifest.id):
		return

	var package_report := packages[manifest.id] as Dictionary
	if package_report == null:
		return

	lines.append("")
	lines.append("引用风险：发现 %d 处项目文件仍直接引用该禁用包。" % int(package_report.get("reference_count", 0)))
	var references := package_report.get("references", []) as Array
	for i: int in range(mini(references.size(), 8)):
		var reference := references[i] as Dictionary
		if reference == null:
			continue
		lines.append("- %s:%d" % [
			String(reference.get("path", "")),
			int(reference.get("line", 0)),
		])
	if references.size() > 8:
		lines.append("- 还有 %d 处未显示。" % (references.size() - 8))


func _format_kind(kind: String) -> String:
	match kind:
		GFPackageManifest.KIND_OFFICIAL:
			return "官方"
		GFPackageManifest.KIND_COMMUNITY:
			return "社区"
		GFPackageManifest.KIND_STANDARD:
			return "标准"
		_:
			return kind


func _format_dependencies(values: Array[String]) -> String:
	if values.is_empty():
		return "无"

	var labels := PackedStringArray()
	for value: String in values:
		match value:
			"gf.kernel":
				labels.append("GF Kernel")
			"gf.standard":
				labels.append("GF Standard")
			_:
				labels.append(value)
	return ", ".join(labels)


func _format_string_array(values: Array[String]) -> String:
	if values.is_empty():
		return "无"
	return _join_strings(values)


func _join_strings(values: Array[String]) -> String:
	var packed := PackedStringArray()
	for value: String in values:
		packed.append(value)
	return ", ".join(packed)


func _set_selection_status() -> void:
	var enabled_count := _get_selected_enabled_ids().size()
	var reference_count := int(_usage_report.get("reference_count", 0))
	if reference_count > 0:
		_set_status("已选择 %d / %d 个包；发现 %d 处禁用包引用。" % [
			enabled_count,
			_manifests.size(),
			reference_count,
		])
	else:
		_set_status("已选择 %d / %d 个包。禁用包可在导出阶段排除。" % [enabled_count, _manifests.size()])


func _set_status(message: String) -> void:
	if is_instance_valid(_status_label):
		_status_label.text = message


func _scan_disabled_package_references() -> void:
	_refresh_usage_report()
	if not _selected_manifest_id.is_empty():
		for manifest: GFPackageManifest in _manifests:
			if manifest.id == _selected_manifest_id:
				_show_manifest_details(manifest)
				break
	_set_selection_status()


# --- 信号处理函数 ---

func _on_filter_selected(_index: int) -> void:
	_refresh_visible_package_rows()
	_set_selection_status()


func _on_search_changed(_new_text: String) -> void:
	_refresh_visible_package_rows()
	_set_selection_status()


func _on_package_toggled(enabled: bool, package_id: String) -> void:
	_selection_by_id[package_id] = enabled
	_refresh_usage_report()
	if package_id == _selected_manifest_id:
		for manifest: GFPackageManifest in _manifests:
			if manifest.id == package_id:
				_show_manifest_details(manifest)
				break
	_set_status("选择已更新，点击“保存设置”后生效。")
