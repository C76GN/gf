@tool

## GFEditorToolContext: 编辑器交互工具上下文。
##
## 用于在工具、动作和命令之间传递 EditorPlugin、UndoRedo、选中节点和额外元数据。
## 该对象只保存通用编辑器上下文，不假设具体工具会编辑哪类资源。
class_name GFEditorToolContext
extends RefCounted


# --- 常量 ---

const GFEditorCommandBase = preload("res://addons/gf/kernel/editor/gf_editor_command.gd")


# --- 公共变量 ---

## 当前 EditorPlugin。
var plugin: EditorPlugin = null

## UndoRedo 管理器或兼容对象。
var undo_manager: Object = null

## 当前编辑场景根节点。
var edited_scene_root: Node = null

## 当前选中节点快照。
var selected_nodes: Array[Node] = []

## 调用方附加元数据。
var metadata: Dictionary = {}


# --- 公共方法 ---

## 从 EditorPlugin 构建上下文。
## @param editor_plugin: 当前编辑器插件。
## @param extra_metadata: 额外元数据。
## @return 新上下文。
static func from_plugin(editor_plugin: EditorPlugin, extra_metadata: Dictionary = {}) -> GFEditorToolContext:
	var context := GFEditorToolContext.new()
	context.plugin = editor_plugin
	context.metadata = extra_metadata.duplicate(true)
	if editor_plugin != null:
		context.undo_manager = editor_plugin.get_undo_redo()
		context.edited_scene_root = EditorInterface.get_edited_scene_root()
		var selection := EditorInterface.get_selection()
		if selection != null:
			for node: Node in selection.get_selected_nodes():
				context.selected_nodes.append(node)
	return context


## 提交一个命令。
## @param command: 需要执行或写入 UndoRedo 的命令。
## @param use_undo: 为 true 且存在 undo_manager 时写入 UndoRedo。
## @return Godot 错误码。
func commit_command(command: GFEditorCommandBase, use_undo: bool = true) -> Error:
	if command == null:
		return ERR_INVALID_PARAMETER
	if use_undo and undo_manager != null:
		return command.add_to_undo_manager(undo_manager)
	return command.execute()


## 获取选中节点副本。
## @return 选中节点数组。
func get_selected_nodes() -> Array[Node]:
	return selected_nodes.duplicate()


## 获取上下文字典。
## @return 普通字典快照。
func to_dictionary() -> Dictionary:
	return {
		"plugin": plugin,
		"undo_manager": undo_manager,
		"edited_scene_root": edited_scene_root,
		"selected_nodes": selected_nodes.duplicate(),
		"metadata": metadata.duplicate(true),
	}
