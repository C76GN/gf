## GFSaveScope: 存档图作用域节点。
##
## Scope 定义一次保存/加载的边界。它可嵌套组织子 Scope，但不假设具体业务结构。
class_name GFSaveScope
extends Node


# --- 枚举 ---

## 恢复未知实体时的处理策略。
enum RestorePolicy {
	## 只把数据应用到已存在的 Source。
	APPLY_ONLY_EXISTING,
	## 允许 GFSaveGraphUtility 使用注册的工厂补建实体。
	ALLOW_FACTORIES,
}

## Scope/Source 执行阶段。
enum Phase {
	## 早期执行。
	EARLY,
	## 普通执行。
	NORMAL,
	## 后期执行。
	LATE,
}


# --- 导出变量 ---

## Scope 稳定标识。留空时回退到节点名。
@export var scope_key: StringName = &""

## 可选键命名空间。用于多处复用同名子结构时隔离 source key。
@export var key_namespace: StringName = &""

## 是否启用该 Scope。
@export var enabled: bool = true

## 是否参与保存。
@export var save_enabled: bool = true

## 是否参与加载。
@export var load_enabled: bool = true

## 执行阶段。
@export var phase: Phase = Phase.NORMAL

## 恢复策略。
@export var restore_policy: RestorePolicy = RestorePolicy.APPLY_ONLY_EXISTING


# --- 公共方法 ---

## 获取 Scope 稳定标识。
## @return Scope key。
func get_scope_key() -> StringName:
	if scope_key != &"":
		return scope_key
	return StringName(name)


## 获取 Source key 前缀。
## @return 前缀字符串。
func get_key_prefix() -> String:
	return String(key_namespace)


## 判断是否可保存。
## @param _context: 调用上下文字典。
## @return 可保存时返回 true。
func can_save_scope(_context: Dictionary = {}) -> bool:
	return enabled and save_enabled


## 判断是否可加载。
## @param _context: 调用上下文字典。
## @return 可加载时返回 true。
func can_load_scope(_context: Dictionary = {}) -> bool:
	return enabled and load_enabled


## 保存前 Hook。
## @param _context: 调用上下文字典。
func before_save(_context: Dictionary = {}) -> void:
	pass


## 保存后 Hook。
## @param _payload: 当前 Scope 载荷。
## @param _context: 调用上下文字典。
func after_save(_payload: Dictionary, _context: Dictionary = {}) -> void:
	pass


## 加载前 Hook。
## @param _payload: 当前 Scope 载荷。
## @param _context: 调用上下文字典。
func before_load(_payload: Dictionary, _context: Dictionary = {}) -> void:
	pass


## 加载后 Hook。
## @param _payload: 当前 Scope 载荷。
## @param _context: 调用上下文字典。
func after_load(_payload: Dictionary, _context: Dictionary = {}) -> void:
	pass


## 返回当前 Scope 的通用描述。
## @return 描述字典。
func describe_scope() -> Dictionary:
	return {
		"scope_key": get_scope_key(),
		"key_namespace": key_namespace,
		"phase": phase,
		"restore_policy": restore_policy,
	}
