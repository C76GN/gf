@tool

## GF 插件 Inspector 与导出插件管理辅助。
extends RefCounted


# --- 常量 ---

const CAPABILITY_INSPECTOR_PLUGIN_SCRIPT_PATH: String = "res://addons/gf/editor/gf_capability_inspector_plugin.gd"
const NODE_STATE_MACHINE_INSPECTOR_PLUGIN_SCRIPT_PATH: String = "res://addons/gf/editor/gf_node_state_machine_inspector_plugin.gd"
const FLOW_GRAPH_INSPECTOR_PLUGIN_SCRIPT_PATH: String = "res://addons/gf/editor/gf_flow_graph_inspector_plugin.gd"
const PATTERN_2D_INSPECTOR_PLUGIN_SCRIPT_PATH: String = "res://addons/gf/editor/gf_pattern_2d_inspector_plugin.gd"
const BUILD_INFO_EXPORT_PLUGIN_SCRIPT_PATH: String = "res://addons/gf/editor/gf_build_info_export_plugin.gd"


# --- 私有变量 ---

var _capability_inspector_plugin: EditorInspectorPlugin
var _node_state_machine_inspector_plugin: EditorInspectorPlugin
var _flow_graph_inspector_plugin: EditorInspectorPlugin
var _pattern_2d_inspector_plugin: EditorInspectorPlugin
var _build_info_export_plugin: EditorExportPlugin


# --- 公共方法 ---

## 安装 GF Inspector 与导出插件。
## @param plugin: 当前 EditorPlugin 实例。
func setup(plugin: EditorPlugin) -> void:
	if plugin == null:
		return
	_setup_inspector_tools(plugin)
	_setup_build_info_export_plugin(plugin)


## 移除 GF Inspector 与导出插件。
## @param plugin: 当前 EditorPlugin 实例。
func cleanup(plugin: EditorPlugin) -> void:
	if plugin == null:
		return
	_cleanup_build_info_export_plugin(plugin)
	_cleanup_inspector_tools(plugin)


# --- 私有/辅助方法 ---

func _setup_inspector_tools(plugin: EditorPlugin) -> void:
	_capability_inspector_plugin = _load_inspector_plugin(CAPABILITY_INSPECTOR_PLUGIN_SCRIPT_PATH, "能力 Inspector")
	if _capability_inspector_plugin != null:
		plugin.add_inspector_plugin(_capability_inspector_plugin)

	_node_state_machine_inspector_plugin = _load_inspector_plugin(
		NODE_STATE_MACHINE_INSPECTOR_PLUGIN_SCRIPT_PATH,
		"节点状态机 Inspector"
	)
	if _node_state_machine_inspector_plugin != null:
		plugin.add_inspector_plugin(_node_state_machine_inspector_plugin)

	_flow_graph_inspector_plugin = _load_inspector_plugin(FLOW_GRAPH_INSPECTOR_PLUGIN_SCRIPT_PATH, "流程图 Inspector")
	if _flow_graph_inspector_plugin != null:
		plugin.add_inspector_plugin(_flow_graph_inspector_plugin)

	_pattern_2d_inspector_plugin = _load_inspector_plugin(PATTERN_2D_INSPECTOR_PLUGIN_SCRIPT_PATH, "Pattern2D Inspector")
	if _pattern_2d_inspector_plugin != null:
		plugin.add_inspector_plugin(_pattern_2d_inspector_plugin)


func _setup_build_info_export_plugin(plugin: EditorPlugin) -> void:
	var export_script := load(BUILD_INFO_EXPORT_PLUGIN_SCRIPT_PATH) as Script
	if export_script == null or not export_script.can_instantiate():
		push_error("[GF Framework] 构建信息导出插件脚本加载失败。")
		return

	_build_info_export_plugin = export_script.new() as EditorExportPlugin
	if _build_info_export_plugin == null:
		push_error("[GF Framework] 构建信息导出插件实例化失败。")
		return

	plugin.add_export_plugin(_build_info_export_plugin)


func _load_inspector_plugin(script_path: String, label: String) -> EditorInspectorPlugin:
	var inspector_script := load(script_path) as Script
	if inspector_script == null or not inspector_script.can_instantiate():
		push_error("[GF Framework] %s 插件脚本加载失败。" % label)
		return null

	var inspector_plugin := inspector_script.new() as EditorInspectorPlugin
	if inspector_plugin == null:
		push_error("[GF Framework] %s 插件实例化失败。" % label)
		return null

	return inspector_plugin


func _cleanup_inspector_tools(plugin: EditorPlugin) -> void:
	if _capability_inspector_plugin != null:
		plugin.remove_inspector_plugin(_capability_inspector_plugin)
		_capability_inspector_plugin = null
	if _node_state_machine_inspector_plugin != null:
		plugin.remove_inspector_plugin(_node_state_machine_inspector_plugin)
		_node_state_machine_inspector_plugin = null
	if _flow_graph_inspector_plugin != null:
		plugin.remove_inspector_plugin(_flow_graph_inspector_plugin)
		_flow_graph_inspector_plugin = null
	if _pattern_2d_inspector_plugin != null:
		plugin.remove_inspector_plugin(_pattern_2d_inspector_plugin)
		_pattern_2d_inspector_plugin = null


func _cleanup_build_info_export_plugin(plugin: EditorPlugin) -> void:
	if _build_info_export_plugin != null:
		plugin.remove_export_plugin(_build_info_export_plugin)
		_build_info_export_plugin = null
