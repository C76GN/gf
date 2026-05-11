## GFUIRoute: UI 路由资源描述。
##
## 只描述路由标识、面板场景、目标层级和默认打开选项，不规定页面业务、
## 动画实现或面板通信方式。
class_name GFUIRoute
extends Resource


# --- 导出变量 ---

## 路由稳定标识。
@export var route_id: StringName = &""

## 面板场景路径。
@export_file("*.tscn") var scene_path: String = ""

## 目标 UI 层级。默认使用 GFUIUtility.POPUP。
@export var layer: int = GFUIUtility.Layer.POPUP

## 默认面板选项，会传给 GFUIUtility。
@export var default_options: Dictionary = {}

## 路由元数据。框架只透传，不解释字段含义。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取稳定路由标识。
## @return 路由标识；未显式设置时尝试使用资源路径。
func get_route_id() -> StringName:
	if route_id != &"":
		return route_id
	if not resource_path.is_empty():
		return StringName(resource_path)
	return &""


## 检查路由是否具备可打开的基本信息。
## @return 路由有效时返回 true。
func is_valid_route() -> bool:
	return get_route_id() != &"" and not scene_path.is_empty() and GFUIUtility.Layer.values().has(layer)


## 合并默认选项、覆盖选项和路由参数。
## @param params: 本次打开路由携带的参数。
## @param option_overrides: 本次打开路由的选项覆盖。
## @return 合并后的 GFUIUtility 选项。
func build_options(params: Dictionary = {}, option_overrides: Dictionary = {}) -> Dictionary:
	var options := default_options.duplicate(true)
	_merge_dictionary(options, option_overrides)

	var merged_metadata := metadata.duplicate(true)
	var option_metadata := options.get("metadata", {}) as Dictionary
	if option_metadata != null:
		_merge_dictionary(merged_metadata, option_metadata)
	merged_metadata["route_id"] = get_route_id()
	if not params.is_empty():
		merged_metadata["route_params"] = params.duplicate(true)
	options["metadata"] = merged_metadata
	return options


# --- 私有/辅助方法 ---

func _merge_dictionary(target: Dictionary, source: Dictionary) -> void:
	for key: Variant in source.keys():
		target[key] = GFVariantData.duplicate_variant(source[key])
