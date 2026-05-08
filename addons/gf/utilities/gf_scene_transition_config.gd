## GFSceneTransitionConfig: 场景切换配置资源。
##
## 用资源描述一次场景切换所需的目标场景、loading scene、缓存策略、切换参数和扩展参数。
class_name GFSceneTransitionConfig
extends Resource


# --- 导出变量 ---

## 目标场景路径。
@export_file("*.tscn", "*.scn") var target_scene_path: String = ""

## 可选 loading scene 路径。
@export_file("*.tscn", "*.scn") var loading_scene_path: String = ""

## 切换前是否先发起预加载。
@export var preload_before_change: bool = false

## preload_before_change 为 true 时，是否把预加载结果写入固定缓存。
@export var preload_as_fixed_cache: bool = false

## 本次切换完成后是否允许写入 GFSceneUtility 缓存。
@export var cache_loaded_scene: bool = true

## 本次切换传递给目标场景或项目流程的参数。
@export var params: Dictionary = {}

## loading scene 最短保留秒数；为 0 时不额外等待。
@export_range(0.0, 30.0, 0.01, "or_greater") var minimum_duration_seconds: float = 0.0

## 项目自定义参数。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 转换为 Dictionary。
## @return 配置字典。
func to_dict() -> Dictionary:
	return {
		"target_scene_path": target_scene_path,
		"loading_scene_path": loading_scene_path,
		"preload_before_change": preload_before_change,
		"preload_as_fixed_cache": preload_as_fixed_cache,
		"cache_loaded_scene": cache_loaded_scene,
		"params": params.duplicate(true),
		"minimum_duration_seconds": minimum_duration_seconds,
		"metadata": metadata.duplicate(true),
	}


## 应用字典配置。
## @param data: 配置字典。
func apply_dict(data: Dictionary) -> void:
	target_scene_path = String(data.get("target_scene_path", target_scene_path))
	loading_scene_path = String(data.get("loading_scene_path", loading_scene_path))
	preload_before_change = bool(data.get("preload_before_change", preload_before_change))
	preload_as_fixed_cache = bool(data.get("preload_as_fixed_cache", preload_as_fixed_cache))
	cache_loaded_scene = bool(data.get("cache_loaded_scene", cache_loaded_scene))
	var params_data := data.get("params", {}) as Dictionary
	params = params_data.duplicate(true) if params_data != null else {}
	minimum_duration_seconds = maxf(float(data.get("minimum_duration_seconds", minimum_duration_seconds)), 0.0)
	var metadata_data := data.get("metadata", {}) as Dictionary
	metadata = metadata_data.duplicate(true) if metadata_data != null else {}


## 从 Dictionary 创建配置。
## @param data: 配置字典。
## @return 新配置。
static func from_dict(data: Dictionary) -> GFSceneTransitionConfig:
	var config := GFSceneTransitionConfig.new()
	config.apply_dict(data)
	return config
