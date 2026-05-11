## GFAssetHandle: GFAssetUtility 创建的资源所有权句柄。
##
## 句柄只表达“某个调用方正在持有某个资源路径”，不规定资源业务语义。
## 调用 release() 会把引用归还给 GFAssetUtility；句柄释放前，对应缓存路径不会被 LRU 淘汰。
class_name GFAssetHandle
extends RefCounted


# --- 公共变量 ---

## 资源路径。
var path: String = ""

## 请求时使用的类型提示。
var type_hint: String = ""

## 可选资源分组。
var group_id: StringName = &""

## 资源实例。
var resource: Resource = null


# --- 私有变量 ---

var _utility_ref: WeakRef = null
var _released: bool = false
var _owner_id: int = 0


# --- 公共方法 ---

## 获取资源实例。
## @return 资源实例；句柄已释放时返回 null。
func get_resource() -> Resource:
	return resource if not _released else null


## 获取拥有者实例 ID。
## @return 拥有者实例 ID；未绑定 owner 时为 0。
func get_owner_id() -> int:
	return _owner_id


## 检查句柄是否已释放。
## @return 已释放返回 true。
func is_released() -> bool:
	return _released


## 检查句柄当前是否仍能访问资源。
## @return 可访问资源返回 true。
func is_valid() -> bool:
	return not _released and resource != null


## 释放句柄持有的资源引用。
## @return 成功释放返回 true。
func release() -> bool:
	if _released:
		return false

	var utility := _get_utility()
	if utility == null:
		_release_local()
		return false

	return utility.release_handle(self)


# --- 私有/辅助方法 ---

func _setup(
	utility: GFAssetUtility,
	p_path: String,
	p_resource: Resource,
	p_type_hint: String = "",
	p_group_id: StringName = &"",
	p_owner_id: int = 0
) -> void:
	_utility_ref = weakref(utility) if utility != null else null
	path = p_path
	resource = p_resource
	type_hint = p_type_hint
	group_id = p_group_id
	_owner_id = p_owner_id
	_released = false


func _get_utility() -> GFAssetUtility:
	if _utility_ref == null:
		return null
	return _utility_ref.get_ref() as GFAssetUtility


func _release_local() -> void:
	_released = true
	resource = null
