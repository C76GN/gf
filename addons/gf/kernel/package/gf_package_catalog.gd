## GFPackageCatalog: GF 包 manifest 发现与读取辅助。
##
## 扫描 `addons/gf/packages/official` 与 `addons/gf/packages/community`
## 下的 `gf_package.json`，供编辑器工具或项目侧包管理界面使用。
class_name GFPackageCatalog
extends RefCounted


# --- 常量 ---

const GFPackageManifestBase = preload("res://addons/gf/kernel/package/gf_package_manifest.gd")

## 官方包根目录。
const OFFICIAL_PACKAGES_PATH: String = "res://addons/gf/packages/official"

## 社区包根目录。
const COMMUNITY_PACKAGES_PATH: String = "res://addons/gf/packages/community"


# --- 公共方法 ---

## 读取所有官方包 manifest。
## @return 官方包 manifest 列表。
static func load_official_manifests() -> Array[GFPackageManifest]:
	return load_manifests_in(OFFICIAL_PACKAGES_PATH)


## 读取所有社区包 manifest。
## @return 社区包 manifest 列表。
static func load_community_manifests() -> Array[GFPackageManifest]:
	return load_manifests_in(COMMUNITY_PACKAGES_PATH)


## 读取官方包与社区包 manifest。
## @param include_community: 是否包含社区包目录。
## @return 包 manifest 列表。
static func load_all_manifests(include_community: bool = true) -> Array[GFPackageManifest]:
	var manifests := load_official_manifests()
	if include_community:
		manifests.append_array(load_community_manifests())
	return manifests


## 读取指定根目录下一层包目录中的 manifest。
## @param root_path: 包集合根目录。
## @return 包 manifest 列表。
static func load_manifests_in(root_path: String) -> Array[GFPackageManifest]:
	var manifests: Array[GFPackageManifest] = []
	for manifest_path: String in get_manifest_paths(root_path):
		var manifest := GFPackageManifestBase.from_json_file(manifest_path)
		if manifest != null:
			manifests.append(manifest)
	return manifests


## 获取指定根目录下一层包目录中的 manifest 路径。
## @param root_path: 包集合根目录。
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
			var manifest_path := root_path.path_join(entry).path_join(GFPackageManifestBase.FILE_NAME)
			if FileAccess.file_exists(manifest_path):
				paths.append(manifest_path)
		entry = dir.get_next()
	dir.list_dir_end()
	paths.sort()
	return paths
