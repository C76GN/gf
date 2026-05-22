## GFProjectileCatalogEntry: 发射体目录中的单个场景映射。
##
## 只把稳定 ID 映射到 PackedScene，不解释该场景的玩法含义。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFProjectileCatalogEntry
extends Resource


# --- 导出变量 ---

## 发射体 ID。
## [br]
## @api public
@export var projectile_id: StringName = &""

## 发射体场景。
## [br]
## @api public
@export var scene: PackedScene = null


# --- 公共方法 ---

## 检查条目是否可用于实例化。
## [br]
## @api public
## [br]
## @return ID 和场景都有效时返回 true。
func is_valid_entry() -> bool:
	return projectile_id != &"" and scene != null
