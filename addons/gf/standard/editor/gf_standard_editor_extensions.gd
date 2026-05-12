@tool

## GF 标准库编辑器扩展声明。
extends RefCounted


# --- 公共方法 ---

static func get_inspector_plugin_records() -> Array[Dictionary]:
	return [
		{
			"path": "res://addons/gf/standard/state_machine/node/editor/gf_node_state_machine_inspector_plugin.gd",
			"label": "节点状态机 Inspector",
		},
		{
			"path": "res://addons/gf/standard/foundation/math/editor/gf_pattern_2d_inspector_plugin.gd",
			"label": "Pattern2D Inspector",
		},
	]


static func get_export_plugin_records() -> Array[Dictionary]:
	return [
		{
			"path": "res://addons/gf/standard/utilities/debug/editor/gf_build_info_export_plugin.gd",
			"label": "构建信息导出插件",
		},
	]


static func get_dock_records() -> Array[Dictionary]:
	return [
		{
			"path": "res://addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd",
			"label": "GF Save Viewer",
		},
	]


static func get_template_records() -> Array[Dictionary]:
	return [
		{
			"type": "NodeState",
			"label": "生成 NodeState",
			"section": "扩展模板",
			"base_class": "GFNodeState",
			"template": _get_node_state_template(),
		},
		{
			"type": "NodeStateMachine",
			"label": "生成 NodeStateMachine",
			"section": "扩展模板",
			"base_class": "GFNodeStateMachine",
			"template": _get_node_state_machine_template(),
		},
	]


# --- 私有/辅助方法 ---

static func _get_node_state_template() -> String:
	return """## {ClassName}: TODO。
class_name {ClassName}
extends {BaseClass}


# --- 信号 ---


# --- 枚举 ---


# --- 常量 ---


# --- 导出变量 ---


# --- 公共变量 ---


# --- 私有变量 ---


# --- @onready 变量 (节点引用) ---


# --- 公共方法 ---


# --- 虚方法（由子类重写） ---

func _initialize() -> void:
	pass


func _enter(_previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


func _exit(_next_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


func _pause(_next_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


func _resume(_previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


# --- 私有/辅助方法 ---


# --- 信号处理函数 ---

"""


static func _get_node_state_machine_template() -> String:
	return """## {ClassName}: TODO。
class_name {ClassName}
extends {BaseClass}


# --- 信号 ---


# --- 枚举 ---


# --- 常量 ---


# --- 导出变量 ---


# --- 公共变量 ---


# --- 私有变量 ---


# --- @onready 变量 (节点引用) ---


# --- Godot 生命周期方法 ---

func _ready() -> void:
	super._ready()


# --- 公共方法 ---


# --- 私有/辅助方法 ---


# --- 信号处理函数 ---

"""
