## GFConsoleCommandDefinition: 控制台命令资源定义。
##
## 只保存命令名称、别名、描述和元数据，执行逻辑仍由注册时传入的 Callable 提供。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFConsoleCommandDefinition
extends Resource


# --- 导出变量 ---

## 主命令名。
## [br]
## @api public
@export var command_name: String = ""

## 命令别名。
## [br]
## @api public
@export var aliases: PackedStringArray = PackedStringArray()

## 命令描述。
## [br]
## @api public
@export var description: String = ""

## 项目自定义元数据。框架不解释该字段。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，保存项目自定义命令元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取所有命令名。
## [br]
## @api public
## [br]
## @return: 主命令和别名。
func get_all_names() -> PackedStringArray:
	var result := PackedStringArray()
	if not command_name.is_empty():
		result.append(command_name)
	for alias: String in aliases:
		if alias.is_empty() or result.has(alias):
			continue
		result.append(alias)
	return result
