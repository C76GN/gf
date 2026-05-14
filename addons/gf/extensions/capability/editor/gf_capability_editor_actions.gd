@tool

## GF Capability 扩展编辑器菜单动作。
extends RefCounted


# --- 公共方法 ---

## 获取 Capability 扩展贡献的脚本模板。
## @return 模板记录列表。
func get_template_records() -> Array[Dictionary]:
	return [
		{
			"type": "Capability",
			"label": "生成 Capability",
			"section": "扩展模板",
			"base_class": "GFCapability",
			"template": _get_capability_template(),
		},
		{
			"type": "NodeCapability",
			"label": "生成 NodeCapability",
			"section": "扩展模板",
			"base_class": "GFNodeCapability",
			"template": _get_capability_template(),
		},
		{
			"type": "Node2DCapability",
			"label": "生成 Node2DCapability",
			"section": "扩展模板",
			"base_class": "GFNode2DCapability",
			"template": _get_capability_template(),
		},
		{
			"type": "Node3DCapability",
			"label": "生成 Node3DCapability",
			"section": "扩展模板",
			"base_class": "GFNode3DCapability",
			"template": _get_capability_template(),
		},
		{
			"type": "ControlCapability",
			"label": "生成 ControlCapability",
			"section": "扩展模板",
			"base_class": "GFControlCapability",
			"template": _get_capability_template(),
		},
	]


# --- 私有/辅助方法 ---

func _get_capability_template() -> String:
	return """## {ClassName}: TODO。
class_name {ClassName}
extends {BaseClass}


# --- 信号 ---


# --- 枚举 ---


# --- 常量 ---


# --- 导出变量 ---


# --- 公共变量 ---


# --- 私有变量 ---


# --- @onready 变量 (节点引用) ---


# --- 公共方法 ---

func get_required_capabilities() -> Array[Script]:
	return [] as Array[Script]


func get_dependency_removal_policy() -> int:
	return super.get_dependency_removal_policy()


## 处理能力添加通知。
## @param target: 交互目标对象。
func on_gf_capability_added(target: Object) -> void:
	super.on_gf_capability_added(target)


## 处理能力移除通知。
## @param target: 交互目标对象。
func on_gf_capability_removed(target: Object) -> void:
	super.on_gf_capability_removed(target)


## 处理能力激活状态变化通知。
## @param _target: 能力目标对象，默认回调不直接使用。
## @param _active: 能力激活状态，默认回调不直接使用。
func on_gf_capability_active_changed(_target: Object, _active: bool) -> void:
	pass


# --- 私有/辅助方法 ---


# --- 信号处理函数 ---

"""
