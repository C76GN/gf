## GFModalConfig: 通用 modal 配置。
##
## 用 Resource 描述标题、正文、动作和交互策略，使项目自定义 modal 面板
## 可以共享同一套打开与结果协议。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFModalConfig
extends Resource


# --- 导出变量 ---

## 标题文本。
## [br]
## @api public
@export var title: String = ""

## 正文文本。
## [br]
## @api public
@export_multiline var message: String = ""

## 动作列表。为空时默认生成一个确认动作。
## [br]
## @api public
## [br]
## @schema actions: Array[GFModalAction]，modal 可渲染的动作声明列表。
@export var actions: Array[GFModalAction] = []

## 点击背景是否按取消处理。
## [br]
## @api public
@export var dismiss_on_backdrop: bool = false

## 取消请求是否关闭 modal。
## [br]
## @api public
@export var dismiss_on_cancel: bool = true

## 打开时是否自动聚焦动作按钮。
## [br]
## @api public
@export var auto_focus: bool = true

## 关闭后是否恢复打开前焦点。
## [br]
## @api public
@export var restore_focus_on_close: bool = true

## 可选元数据，供项目层或自定义面板解释。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，项目层或自定义 modal 面板解释的配置元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取可用动作列表；配置为空时返回默认确认动作。
## [br]
## @api public
## [br]
## @return 动作列表副本。
func get_actions_or_default() -> Array[GFModalAction]:
	if actions.is_empty():
		return [_make_default_action()]

	var result: Array[GFModalAction] = []
	for action: GFModalAction in actions:
		if action != null:
			result.append(action.duplicate_action())
	if result.is_empty():
		result.append(_make_default_action())
	return result


## 查找指定动作。
## [br]
## @api public
## [br]
## @param action_id: 动作 ID。
## [br]
## @return 找到时返回动作副本，否则返回 null。
func get_action(action_id: StringName) -> GFModalAction:
	for action: GFModalAction in get_actions_or_default():
		if action != null and action.action_id == action_id:
			return action
	return null


## 创建同内容拷贝。
## [br]
## @api public
## [br]
## @return 新配置。
func duplicate_config() -> GFModalConfig:
	var config := GFModalConfig.new()
	config.title = title
	config.message = message
	config.dismiss_on_backdrop = dismiss_on_backdrop
	config.dismiss_on_cancel = dismiss_on_cancel
	config.auto_focus = auto_focus
	config.restore_focus_on_close = restore_focus_on_close
	config.metadata = metadata.duplicate(true)
	for action: GFModalAction in actions:
		config.actions.append(action.duplicate_action() if action != null else null)
	return config


# --- 私有/辅助方法 ---

func _make_default_action() -> GFModalAction:
	var action := GFModalAction.new()
	action.action_id = &"ok"
	action.label = "OK"
	action.result_status = GFModalResult.STATUS_CONFIRMED
	action.grab_focus = true
	return action
