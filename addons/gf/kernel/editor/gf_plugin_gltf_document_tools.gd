@tool

## GF 插件 glTF 文档扩展管理辅助。
extends RefCounted


# --- 常量 ---

const GFExtensionSettingsBase = preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")


# --- 私有变量 ---

var _document_extensions: Array[GLTFDocumentExtension] = []


# --- 公共方法 ---

## 注册当前启用扩展声明的 GLTFDocumentExtension。
func setup() -> void:
	for extension_path: String in GFExtensionSettingsBase.get_enabled_gltf_document_extension_paths():
		_register_document_extension(extension_path)


## 注销已注册的 GLTFDocumentExtension。
func cleanup() -> void:
	for document_extension: GLTFDocumentExtension in _document_extensions:
		if document_extension != null:
			GLTFDocument.unregister_gltf_document_extension(document_extension)
	_document_extensions.clear()


# --- 私有/辅助方法 ---

func _register_document_extension(script_path: String) -> void:
	var extension_script := load(script_path) as Script
	if extension_script == null or not extension_script.can_instantiate():
		push_error("[GF Framework] glTF 文档扩展脚本加载失败：%s" % script_path)
		return

	var document_extension := extension_script.new() as GLTFDocumentExtension
	if document_extension == null:
		push_error("[GF Framework] glTF 文档扩展实例化失败：%s" % script_path)
		return

	GLTFDocument.register_gltf_document_extension(document_extension)
	_document_extensions.append(document_extension)
