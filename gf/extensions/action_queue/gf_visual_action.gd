# gf/extensions/action_queue/gf_visual_action.gd

## GFVisualAction: 视觉表现动作的抽象基类。
##
## 继承自 RefCounted，代表一个具体的、可 await 的表现动作单元，
## 如移动动画、卡牌翻面、粒子爆炸等。
## 通过将每个视觉动作封装为独立对象，GFActionQueueSystem 可以严格按序
## 或并行地消费它们，从而彻底隔离底层逻辑时序与 UI 表现时序。
##
## 子类必须重写 execute() 以实现具体的视觉逻辑：
##   - 若动作是瞬时的（无需等待），直接执行并返回 null。
##   - 若动作需要等待（如 Tween/动画），返回一个 Signal，
##     外部可 await 此 Signal 以知悉动作结束。
class_name GFVisualAction
extends RefCounted


# --- 公共方法 ---

## 执行此视觉动作。子类必须重写此方法。
## @return 瞬时动作返回 null；需要等待的动作返回一个 Signal 供 await。
func execute() -> Variant:
	return null
