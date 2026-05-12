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
