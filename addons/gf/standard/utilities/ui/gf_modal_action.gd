## GFModalAction: 通用 modal 动作声明。
##
## 描述一个可由 UI 渲染的操作，不绑定具体按钮样式、业务命令或页面类型。
class_name GFModalAction
extends Resource


# --- 导出变量 ---

## 动作 ID。
@export var action_id: StringName = &"ok"

## 显示文本。
@export var label: String = "OK"

## 触发动作后产生的结果状态。
@export var result_status: StringName = GFModalResult.STATUS_CONFIRMED

## 动作携带的通用载荷。
@export var payload: Variant = null

## 是否作为默认聚焦动作。
@export var grab_focus: bool = false

## 触发后是否关闭 modal。
@export var close_on_pressed: bool = true

## 可选元数据，供项目层或自定义 modal 面板解释。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 创建该动作对应的结果。
## @param context: 打开 modal 时传入的调用上下文。
## @return 结果实例。
func make_result(context: Dictionary = {}) -> GFModalResult:
	return GFModalResult.create(
		result_status,
		action_id,
		GFVariantData.duplicate_collection(payload),
		metadata,
		context
	)


## 创建同内容拷贝。
## @return 新动作声明。
func duplicate_action() -> GFModalAction:
	var action := GFModalAction.new()
	action.action_id = action_id
	action.label = label
	action.result_status = result_status
	action.payload = GFVariantData.duplicate_collection(payload)
	action.grab_focus = grab_focus
	action.close_on_pressed = close_on_pressed
	action.metadata = metadata.duplicate(true)
	return action
