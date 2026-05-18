## GFSaveIdentity: 场景节点的持久化身份描述。
##
## 用于为可恢复实体提供稳定 id、类型键和额外描述信息。它只描述身份，
## 不直接负责保存或实例化。
class_name GFSaveIdentity
extends Node


# --- 导出变量 ---

## 稳定实体 id。留空时由调用方决定是否使用节点路径等回退方案。
@export var persistent_id: StringName = &""

## 可选实体类型键，通常用于恢复时选择工厂。
@export var type_key: StringName = &""

## 可写入存档描述的扩展字段。
@export var descriptor_extra: Dictionary = {}


# --- 公共方法 ---

## 获取稳定实体 id。
## @return 实体 id。
func get_persistent_id() -> StringName:
	return persistent_id


## 获取实体类型键。
## @return 类型键。
func get_type_key() -> StringName:
	return type_key


## 构造身份描述。
## @return 描述字典。
func describe_identity() -> Dictionary:
	var descriptor := descriptor_extra.duplicate(true)
	if persistent_id != &"":
		descriptor["persistent_id"] = persistent_id
	if type_key != &"":
		descriptor["type_key"] = type_key
	return descriptor
