## GFSaveEntityFactory: 存档恢复实体工厂基类。
##
## 由 GFSaveGraphUtility 在缺失 Source 且 Scope 允许工厂恢复时调用。
class_name GFSaveEntityFactory
extends Resource


# --- 导出变量 ---

## 工厂可创建的实体类型键。
@export var type_key: StringName = &""

## 可选场景模板。项目也可继承 create_entity 实现自定义创建。
@export var packed_scene: PackedScene


# --- 公共方法 ---

## 获取实体类型键。
## @return 类型键。
func get_type_key() -> StringName:
	return type_key


## 创建实体节点。
## @param _descriptor: 存档中的实体描述。
## @param _context: 调用上下文字典。
## @return 创建出的节点；失败时返回 null。
func create_entity(_descriptor: Dictionary, _context: Dictionary = {}) -> Node:
	if packed_scene == null:
		return null
	return packed_scene.instantiate()


## 实体加入场景树后调用。
## @param _entity: 创建出的实体。
## @param _descriptor: 存档中的实体描述。
## @param _context: 调用上下文字典。
func after_entity_created(_entity: Node, _descriptor: Dictionary, _context: Dictionary = {}) -> void:
	pass
