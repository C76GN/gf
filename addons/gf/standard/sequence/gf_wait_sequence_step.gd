## GFWaitSequenceStep: 通用等待步骤。
##
## 用于在 `GFCommandSequence` 中插入时间间隔。
class_name GFWaitSequenceStep
extends GFSequenceStep


# --- 导出变量 ---

## 等待时长，单位秒。
@export var duration: float = 0.0

## 是否受 Engine.time_scale 影响。
@export var respect_engine_time_scale: bool = true


# --- 公共方法 ---

## 执行等待步骤。
## @param _context: 序列上下文。
## @return 等待用 Signal，时长小于等于 0 时返回 null。
func execute(_context: GFSequenceContext) -> Variant:
	if duration <= 0.0:
		return null

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null

	return tree.create_timer(duration, true, false, not respect_engine_time_scale).timeout
