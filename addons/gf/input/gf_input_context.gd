## GFInputContext: 资源化输入上下文。
##
## 上下文用于表示一组可启停的输入映射，例如 gameplay、menu、dialogue。
class_name GFInputContext
extends Resource


# --- 常量 ---

const GFInputMappingBase = preload("res://addons/gf/input/gf_input_mapping.gd")


# --- 导出变量 ---

## 上下文稳定标识。
@export var context_id: StringName = &""

## 显示名称。
@export var display_name: String = ""

## 该上下文中的动作映射。
@export var mappings: Array[GFInputMappingBase] = []


# --- 公共方法 ---

## 获取稳定上下文标识。
## @return 上下文标识。
func get_context_id() -> StringName:
	if context_id != &"":
		return context_id
	if not resource_path.is_empty():
		return StringName(resource_path)
	return &""


## 获取显示名称。
## @return 显示名称。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if context_id != &"":
		return String(context_id)
	if not resource_path.is_empty():
		return resource_path.get_file().get_basename().capitalize()
	return "Input Context"
