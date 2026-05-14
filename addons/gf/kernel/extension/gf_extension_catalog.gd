## GFExtensionCatalog: GF 扩展 manifest 发现与读取辅助。
##
## 扫描 `addons/gf/extensions` 下一层扩展目录中的 `gf_extension.json`，
## 供编辑器工具或项目侧扩展管理界面使用。
class_name GFExtensionCatalog
extends RefCounted


# --- 常量 ---

const GFExtensionManifestBase = preload("res://addons/gf/kernel/extension/gf_extension_manifest.gd")

## GF 内置可选扩展根目录。
const EXTENSIONS_PATH: String = "res://addons/gf/extensions"


# --- 公共方法 ---

## 读取 GF 内置可选扩展 manifest。
## @return 扩展 manifest 列表。
static func load_extension_manifests() -> Array[GFExtensionManifest]:
	return load_manifests_in(EXTENSIONS_PATH)


## 读取所有 GF 内置可选扩展 manifest。
## @return 扩展 manifest 列表。
static func load_all_manifests() -> Array[GFExtensionManifest]:
	return load_extension_manifests()


## 读取指定根目录下一层扩展目录中的 manifest。
## @param root_path: 扩展集合根目录。
## @return 扩展 manifest 列表。
static func load_manifests_in(root_path: String) -> Array[GFExtensionManifest]:
	var manifests: Array[GFExtensionManifest] = []
	for manifest_path: String in get_manifest_paths(root_path):
		var manifest := GFExtensionManifestBase.from_json_file(manifest_path)
		if manifest != null:
			manifests.append(manifest)
	return manifests


## 获取指定根目录下一层扩展目录中的 manifest 路径。
## @param root_path: 扩展集合根目录。
## @return manifest 路径列表。
static func get_manifest_paths(root_path: String) -> Array[String]:
	var paths: Array[String] = []
	if root_path.is_empty():
		return paths

	var dir := DirAccess.open(root_path)
	if dir == null:
		return paths

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		if dir.current_is_dir() and not entry.begins_with("."):
			var manifest_path := root_path.path_join(entry).path_join(GFExtensionManifestBase.FILE_NAME)
			if FileAccess.file_exists(manifest_path):
				paths.append(manifest_path)
		entry = dir.get_next()
	dir.list_dir_end()
	paths.sort()
	return paths
