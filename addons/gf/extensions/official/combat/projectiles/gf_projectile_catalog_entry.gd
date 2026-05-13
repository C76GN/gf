## GFProjectileCatalogEntry: 发射体目录中的单个场景映射。
##
## 只把稳定 ID 映射到 PackedScene，不解释该场景的玩法含义。
class_name GFProjectileCatalogEntry
extends Resource


# --- 导出变量 ---

## 发射体 ID。
@export var projectile_id: StringName = &""

## 发射体场景。
@export var scene: PackedScene = null


# --- 公共方法 ---

## 检查条目是否可用于实例化。
## @return ID 和场景都有效时返回 true。
func is_valid_entry() -> bool:
	return projectile_id != &"" and scene != null
