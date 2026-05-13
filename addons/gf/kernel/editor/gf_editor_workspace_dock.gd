@tool

## GFEditorWorkspaceDock: GF 编辑器底部统一入口。
##
## 把核心、标准库和启用扩展贡献的底部面板收束到一个响应式工作区中，
## 避免多个 GF 面板挤占 Godot 底部栏。
extends Control


# --- 常量 ---

const ABOUT_DIALOG_SIZE := Vector2i(620, 360)
const CONTACT_EMAIL: String = "cl7o6dgyn@gmail.com"
const CONTACT_QQ: String = "403150493"
const CONTACT_WECHAT: String = "C76_GN"
const DOCUMENTATION_URL: String = "https://gf-framework.readthedocs.io/"
const EMPTY_MESSAGE: String = "没有可用的 GF 编辑器面板。"
const ABOUT_TEXT_MAX_HEIGHT: float = 236.0
const PAGE_BUTTON_MIN_WIDTH: float = 136.0
const PROJECT_URL: String = "https://github.com/C76GN/gf-framework"
const WORKSPACE_COLLAPSED_MIN_HEIGHT: float = 112.0
const WORKSPACE_TITLE: String = "GF Workspace"


# --- 私有变量 ---

var _about_button: Button = null
var _about_dialog: AcceptDialog = null
var _page_buttons: Array[Button] = []
var _page_selector: HFlowContainer = null
var _tabs: TabContainer = null
var _status_label: Label = null
var _dock_records: Array[Dictionary] = []


# --- Godot 生命周期方法 ---

func _init() -> void:
	name = "GF"
	clip_contents = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(0.0, WORKSPACE_COLLAPSED_MIN_HEIGHT)
	_build_ui()


# --- 公共方法 ---

## 设置工作区页面记录。
## @param dock_records: Dock 记录数组。每条记录至少包含 path，可选 label。
func setup(dock_records: Array[Dictionary]) -> void:
	_dock_records = _copy_records(dock_records)
	_rebuild_pages()


## 获取工作区页面数量。
## @return 页面数量。
func get_page_count() -> int:
	return _tabs.get_child_count() if _tabs != null else 0


## 获取页面标题列表。
## @return 页面标题。
func get_page_titles() -> PackedStringArray:
	var result := PackedStringArray()
	if _tabs == null:
		return result
	for index: int in range(_tabs.get_child_count()):
		result.append(_tabs.get_child(index).name)
	return result


## 获取响应式页面按钮标题列表。
## @return 页面按钮标题。
func get_page_button_titles() -> PackedStringArray:
	var result := PackedStringArray()
	for button: Button in _page_buttons:
		result.append(button.text)
	return result


## 获取框架介绍弹窗文本。
## @return 关于弹窗文本。
func get_about_text() -> String:
	return _make_about_text()


## 激活指定页面。
## @param title: 页面标题。
## @return 找到并激活返回 true。
func select_page(title: String) -> bool:
	if _tabs == null:
		return false
	for index: int in range(_tabs.get_child_count()):
		if _tabs.get_child(index).name == title:
			_tabs.current_tab = index
			_sync_page_buttons()
			_update_status()
			return true
	return false


## 显示 GF Framework 介绍和链接弹窗。
func show_about_dialog() -> void:
	_ensure_about_dialog()
	if is_inside_tree():
		_about_dialog.popup_centered(ABOUT_DIALOG_SIZE)


# --- 私有/辅助方法 ---

func _build_ui() -> void:
	if _tabs != null:
		return

	var margin := MarginContainer.new()
	margin.clip_contents = true
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 6)
	margin.add_child(layout)

	var header := HFlowContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("h_separation", 8)
	header.add_theme_constant_override("v_separation", 4)
	layout.add_child(header)

	var title := Label.new()
	title.text = WORKSPACE_TITLE
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	_status_label = Label.new()
	_status_label.modulate = Color(0.72, 0.72, 0.72)
	header.add_child(_status_label)

	_about_button = Button.new()
	_about_button.text = "关于"
	_about_button.tooltip_text = "查看 GF Framework 介绍、项目地址和文档地址。"
	_about_button.pressed.connect(_on_about_button_pressed)
	header.add_child(_about_button)

	_page_selector = HFlowContainer.new()
	_page_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_selector.add_theme_constant_override("h_separation", 6)
	_page_selector.add_theme_constant_override("v_separation", 4)
	layout.add_child(_page_selector)

	_tabs = TabContainer.new()
	_tabs.clip_contents = true
	_tabs.tabs_visible = false
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tabs.tab_changed.connect(_on_tabs_tab_changed)
	layout.add_child(_tabs)


func _rebuild_pages() -> void:
	if _tabs == null:
		return

	for child: Node in _tabs.get_children():
		_tabs.remove_child(child)
		child.queue_free()

	for record: Dictionary in _dock_records:
		var page := _instantiate_page(record)
		if page == null:
			continue
		_tabs.add_child(page)

	if _tabs.get_child_count() <= 0:
		_tabs.add_child(_make_empty_page())
		_set_status(EMPTY_MESSAGE)
	else:
		_tabs.current_tab = clampi(_tabs.current_tab, 0, _tabs.get_child_count() - 1)
		_update_status()
	_rebuild_page_buttons()


func _instantiate_page(record: Dictionary) -> Control:
	var script_path := String(record.get("path", "")).strip_edges()
	if script_path.is_empty():
		return null

	var dock_script := load(script_path) as Script
	if dock_script == null or not dock_script.can_instantiate():
		push_error("[GF Framework] 工作区面板脚本加载失败：%s" % script_path)
		return null

	var dock := dock_script.new() as Control
	if dock == null:
		push_error("[GF Framework] 工作区面板实例化失败：%s" % script_path)
		return null

	var label := _resolve_page_label(dock, String(record.get("label", "")))
	var page := Control.new()
	page.name = label
	page.clip_contents = true
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL

	dock.name = "%s Content" % label
	dock.clip_contents = true
	dock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dock.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(dock)
	dock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return page


func _make_empty_page() -> Control:
	var page := CenterContainer.new()
	page.name = "概览"
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = EMPTY_MESSAGE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	page.add_child(label)
	return page


func _resolve_page_label(dock: Control, fallback_label: String) -> String:
	if not fallback_label.is_empty():
		return fallback_label
	if dock != null and not dock.name.is_empty():
		return dock.name
	return "Panel"


func _copy_records(source: Array[Dictionary]) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for record: Dictionary in source:
		records.append(record.duplicate(true))
	return records


func _set_status(message: String) -> void:
	if is_instance_valid(_status_label):
		_status_label.text = message


func _rebuild_page_buttons() -> void:
	if _page_selector == null or _tabs == null:
		return

	for child: Node in _page_selector.get_children():
		_page_selector.remove_child(child)
		child.queue_free()
	_page_buttons.clear()

	for index: int in range(_tabs.get_child_count()):
		var page := _tabs.get_child(index)
		var button := Button.new()
		button.text = page.name
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = "切换到 %s" % page.name
		button.custom_minimum_size = Vector2(PAGE_BUTTON_MIN_WIDTH, 30.0)
		button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		button.pressed.connect(_on_page_button_pressed.bind(index))
		_page_selector.add_child(button)
		_page_buttons.append(button)
	_sync_page_buttons()


func _sync_page_buttons() -> void:
	if _tabs == null:
		return

	for index: int in range(_page_buttons.size()):
		_page_buttons[index].set_pressed_no_signal(index == _tabs.current_tab)


func _update_status() -> void:
	if _tabs == null or _tabs.get_child_count() <= 0:
		_set_status(EMPTY_MESSAGE)
		return

	var current_title := _tabs.get_child(_tabs.current_tab).name
	_set_status("%d 个页面 · 当前：%s" % [_tabs.get_child_count(), current_title])


func _ensure_about_dialog() -> void:
	if is_instance_valid(_about_dialog):
		return

	_about_dialog = AcceptDialog.new()
	_about_dialog.title = "关于 GF Framework"
	_about_dialog.min_size = ABOUT_DIALOG_SIZE
	add_child(_about_dialog)
	_about_dialog.add_child(_make_about_content())
	_about_dialog.get_ok_button().visible = false


func _make_about_text() -> String:
	return "\n".join([
		"GF Framework",
		"",
		"面向 Godot 4 的轻量级游戏架构框架。",
		"它把数据、逻辑、表现、运行时服务和纯算法基础件拆开管理，帮助项目保持可预测的生命周期、清晰的依赖边界和可测试的玩法代码。",
		"",
		"项目地址：%s" % PROJECT_URL,
		"文档地址：%s" % DOCUMENTATION_URL,
		"",
		"联系方式：",
		"E-mail：%s" % CONTACT_EMAIL,
		"WeChat：%s" % CONTACT_WECHAT,
		"QQ：%s" % CONTACT_QQ,
	])


func _make_about_content() -> Control:
	var margin := MarginContainer.new()
	margin.name = "AboutContent"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 18)

	var layout := VBoxContainer.new()
	layout.name = "AboutLayout"
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var scroll := ScrollContainer.new()
	scroll.name = "AboutScroll"
	scroll.custom_minimum_size = Vector2(0.0, ABOUT_TEXT_MAX_HEIGHT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	layout.add_child(scroll)

	var text := RichTextLabel.new()
	text.name = "AboutText"
	text.bbcode_enabled = true
	text.fit_content = false
	text.scroll_active = false
	text.selection_enabled = true
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.text = _make_about_bbcode()
	text.meta_clicked.connect(_on_about_link_clicked)
	scroll.add_child(text)

	var confirm_center := CenterContainer.new()
	confirm_center.name = "AboutConfirmCenter"
	confirm_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(confirm_center)

	var confirm_button := Button.new()
	confirm_button.name = "AboutConfirmButton"
	confirm_button.text = "确定"
	confirm_button.custom_minimum_size = Vector2(96.0, 0.0)
	confirm_button.pressed.connect(_on_about_confirm_pressed)
	confirm_center.add_child(confirm_button)
	return margin


func _make_about_bbcode() -> String:
	return "\n".join([
		"[center][b]GF Framework[/b]",
		"",
		"面向 Godot 4 的轻量级游戏架构框架。",
		"拆开管理数据、逻辑、表现、运行时服务和纯算法基础件。",
		"",
		"项目地址：[url=%s]%s[/url]" % [PROJECT_URL, PROJECT_URL],
		"文档地址：[url=%s]%s[/url]" % [DOCUMENTATION_URL, DOCUMENTATION_URL],
		"",
		"[b]联系方式[/b]",
		"E-mail：[url=mailto:%s]%s[/url]" % [CONTACT_EMAIL, CONTACT_EMAIL],
		"WeChat：%s" % CONTACT_WECHAT,
		"QQ：%s[/center]" % CONTACT_QQ,
	])


# --- 信号处理函数 ---

func _on_about_button_pressed() -> void:
	show_about_dialog()


func _on_page_button_pressed(index: int) -> void:
	if _tabs == null or index < 0 or index >= _tabs.get_child_count():
		return

	_tabs.current_tab = index
	_sync_page_buttons()
	_update_status()


func _on_tabs_tab_changed(_tab: int) -> void:
	_sync_page_buttons()
	_update_status()


func _on_about_link_clicked(meta: Variant) -> void:
	var link := str(meta)
	if not link.is_empty():
		OS.shell_open(link)


func _on_about_confirm_pressed() -> void:
	if is_instance_valid(_about_dialog):
		_about_dialog.hide()
