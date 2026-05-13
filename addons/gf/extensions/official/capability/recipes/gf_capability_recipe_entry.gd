## GFCapabilityRecipeEntry: 能力组合资源中的单个能力条目。
##
## 条目只描述能力提供方式、注册类型和默认启停状态，不解释项目业务含义。
class_name GFCapabilityRecipeEntry
extends Resource


# --- 导出变量 ---

## 能力注册类型。为空且 scene 不为空时，会使用实例脚本类型。
@export var capability_type: Script = null

## 可选场景能力。为空时通过 capability_type.new() 创建纯对象能力。
@export var scene: PackedScene = null

## 应用 Recipe 后是否启用该能力。
@export var active: bool = true

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查条目是否至少提供了一种能力创建方式。
## @return 有效返回 true。
func is_valid_entry() -> bool:
	return capability_type != null or scene != null


## 描述条目。
## @return 条目描述字典。
func describe_entry() -> Dictionary:
	return {
		"capability_type": _get_script_key(capability_type),
		"scene_path": scene.resource_path if scene != null else "",
		"active": active,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _get_script_key(script: Script) -> String:
	if script == null:
		return ""

	var global_name := script.get_global_name()
	if global_name != &"":
		return String(global_name)
	if not script.resource_path.is_empty():
		return script.resource_path
	return str(script.get_instance_id())

