@tool

## GF 编辑器独立工作区窗口。
##
## 承载由 kernel、standard 和扩展贡献的通用编辑器页面，不绑定具体业务语义。
extends Window


# --- 常量 ---

const DEFAULT_WINDOW_SIZE := Vector2i(1180, 760)
const MIN_WINDOW_SIZE := Vector2i(900, 560)
const WINDOW_TITLE: String = "GF Workspace"
const GFEditorWorkspaceDockBase = preload("res://addons/gf/kernel/editor/gf_editor_workspace_dock.gd")


# --- 私有变量 ---

var _workspace: Control = null
var _dock_records: Array[Dictionary] = []


# --- Godot 生命周期方法 ---

func _init() -> void:
	title = WINDOW_TITLE
	size = DEFAULT_WINDOW_SIZE
	min_size = MIN_WINDOW_SIZE
	wrap_controls = true
	visible = false
	close_requested.connect(_on_close_requested)
	_build_ui()


# --- 公共方法 ---

## 设置工作区页面记录。
## @param dock_records: 页面记录数组。每条记录至少包含 path，可选 label。
func setup(dock_records: Array[Dictionary]) -> void:
	_dock_records = _copy_records(dock_records)
	if _workspace != null and _workspace.has_method("setup"):
		_workspace.call("setup", _dock_records)


## 显示工作区窗口。
func popup_workspace() -> void:
	if size.x <= 0 or size.y <= 0:
		size = DEFAULT_WINDOW_SIZE
	popup_centered(size)


## 隐藏工作区窗口。
func hide_workspace() -> void:
	hide()


## 获取工作区页面数量。
## @return 页面数量。
func get_page_count() -> int:
	if _workspace != null and _workspace.has_method("get_page_count"):
		return int(_workspace.call("get_page_count"))
	return 0


## 获取页面标题列表。
## @return 页面标题。
func get_page_titles() -> PackedStringArray:
	if _workspace != null and _workspace.has_method("get_page_titles"):
		return _workspace.call("get_page_titles") as PackedStringArray
	return PackedStringArray()


## 获取内部工作区控件。
## @return 工作区控件。
func get_workspace() -> Control:
	return _workspace


# --- 私有/辅助方法 ---

func _build_ui() -> void:
	if _workspace != null:
		return

	_workspace = GFEditorWorkspaceDockBase.new()
	_workspace.name = "Workspace"
	_workspace.clip_contents = true
	_workspace.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_workspace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_workspace)
	_workspace.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _copy_records(source: Array[Dictionary]) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for record: Dictionary in source:
		records.append(record.duplicate(true))
	return records


# --- 信号处理函数 ---

func _on_close_requested() -> void:
	hide_workspace()
