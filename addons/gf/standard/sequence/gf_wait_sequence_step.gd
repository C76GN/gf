## GFWaitSequenceStep: 通用等待步骤。
##
## 用于在 `GFCommandSequence` 中插入时间间隔。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFWaitSequenceStep
extends GFSequenceStep


# --- 导出变量 ---

## 等待时长，单位秒。
## [br]
## @api public
@export var duration: float = 0.0

## 是否受 Engine.time_scale 影响。
## [br]
## @api public
@export var respect_engine_time_scale: bool = true


# --- 公共方法 ---

## 执行等待步骤。
## [br]
## @api public
## [br]
## @param _context: 序列上下文。
## [br]
## @return 等待用 Signal，时长小于等于 0 时返回 null。
## [br]
## @schema return: Variant, null or Signal.
func execute(_context: GFSequenceContext) -> Variant:
	if duration <= 0.0:
		return null

	var tree: SceneTree = _variant_to_scene_tree(Engine.get_main_loop())
	if tree == null:
		return null

	return tree.create_timer(duration, true, false, not respect_engine_time_scale).timeout


# --- 私有/辅助方法 ---

func _variant_to_scene_tree(value: Variant) -> SceneTree:
	if value is SceneTree:
		var tree: SceneTree = value
		return tree
	return null
