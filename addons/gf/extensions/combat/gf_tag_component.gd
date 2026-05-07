## GFTagComponent: 标签组件。
## 
## 基于 StringName 管理实体的标签及层数（如 &"State.Stun", &"Element.Fire"）。
## 标签系统通常用于技能释放前提检查、伤害加成判定等。
class_name GFTagComponent
extends RefCounted


# --- 信号 ---

## 当标签层数发生变化时发出。
## @param tag_name: 标签名。
## @param count: 变化后的最终层数。
signal tag_changed(tag_name: StringName, count: int)


# --- 私有变量 ---

## 存储标签名及其对应层数。
var _tags: Dictionary = {}


# --- 公共方法 ---

## 添加标签。
## @param p_tag: 标签名。
## @param p_count: 增加的层数。
func add_tag(p_tag: StringName, p_count: int = 1) -> void:
	if p_count <= 0:
		return
		
	var current: int = _tags.get(p_tag, 0)
	_tags[p_tag] = current + p_count
	tag_changed.emit(p_tag, _tags[p_tag])


## 移除标签或减少层数。
## @param p_tag: 标签名。
## @param p_count: 减少的层数，如果为 -1 则直接完全移除。
func remove_tag(p_tag: StringName, p_count: int = 1) -> void:
	if not _tags.has(p_tag):
		return

	if p_count == -1:
		_tags.erase(p_tag)
		tag_changed.emit(p_tag, 0)
		return

	if p_count <= 0:
		push_warning("[GFTagComponent] remove_tag 收到无效层数，请传入正数或 -1。")
		return

	var current: int = _tags[p_tag]
	var updated: int = current - p_count
	
	if updated <= 0:
		_tags.erase(p_tag)
		tag_changed.emit(p_tag, 0)
	else:
		_tags[p_tag] = updated
		tag_changed.emit(p_tag, updated)


## 检查是否拥有指定标签且层数达到要求。
## @param p_tag: 标签名。
## @param p_min_count: 要求的最小层数。
func has_tag(p_tag: StringName, p_min_count: int = 1) -> bool:
	return _tags.get(p_tag, 0) >= p_min_count


## 获取标签的当前层数。
## @param p_tag: 标签名。
func get_tag_count(p_tag: StringName) -> int:
	return _tags.get(p_tag, 0)


## 清空所有标签。
func clear_all() -> void:
	var keys := _tags.keys()
	_tags.clear()
	for p_tag in keys:
		tag_changed.emit(p_tag, 0)
