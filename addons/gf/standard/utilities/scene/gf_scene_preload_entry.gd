## GFScenePreloadEntry: 场景预加载图谱中的单个节点。
##
## 描述一个场景与相邻场景的关系，以及该场景是否应进入固定缓存。
## 它只表达资源关系，不假设关卡、地图、菜单或玩法语义。
class_name GFScenePreloadEntry
extends Resource


# --- 导出变量 ---

## 当前场景资源路径。
@export_file("*.tscn", "*.scn") var scene_path: String = ""

## 与当前场景相邻、可能被提前预热的场景资源路径。
@export var adjacent_scene_paths: PackedStringArray = PackedStringArray()

## 是否建议将该场景放入固定缓存。
@export var fixed: bool = false

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取规范化后的场景路径。
## @return 去除首尾空白后的场景路径。
func get_scene_path() -> String:
	return scene_path.strip_edges()


## 获取去重后的相邻场景路径。
## @return 相邻场景路径列表。
func get_adjacent_scene_paths() -> PackedStringArray:
	var result := PackedStringArray()
	var source_path := get_scene_path()
	for raw_path: String in adjacent_scene_paths:
		var path := raw_path.strip_edges()
		if path.is_empty() or path == source_path or result.has(path):
			continue
		result.append(path)
	return result


## 描述当前条目。
## @return 条目描述字典。
func describe_entry() -> Dictionary:
	return {
		"scene_path": get_scene_path(),
		"adjacent_scene_paths": get_adjacent_scene_paths(),
		"fixed": fixed,
		"metadata": metadata.duplicate(true),
	}
