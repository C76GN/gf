# addons/gf/extensions/action_queue/gf_action_queue_system.gd

## GFActionQueueSystem: 逻辑与表现解耦的动画队列管理系统。
##
## 继承自 GFSystem，遵守三阶段初始化协议。
## 负责接收 GFVisualAction 并将其排入队列，然后以单消费者模式顺序消费，
## 彻底隔离底层逻辑时序（立即触发）与 UI 表现时序（动画等待）。
##
## 支持两种入队模式：
##   - enqueue(action): 顺序模式，动作完成后才执行下一个。
##   - enqueue_parallel(actions): 并行模式，将一批动作封装为一个同步点，
##     待所有并行动作均完成后，再继续队列中的下一项。
class_name GFActionQueueSystem
extends GFSystem


# --- 信号 ---

## 当队列从有内容变为全部执行完毕时发出。
signal queue_drained


# --- 公共变量 ---

## 是否正在处理队列。
var is_processing: bool = false


# --- 私有变量 ---

## 内部动作队列。元素必须是 GFVisualAction 或其子类。
var _queue: Array[GFVisualAction] = []


# --- Godot 生命周期方法 ---

## 第一阶段初始化：清空队列状态。
func init() -> void:
	_queue.clear()
	is_processing = false


# --- 公共方法 ---

## 将一个动作加入顺序队列，前一个动作完成后才执行。
## @param action: 要入队的 GFVisualAction 实例。
func enqueue(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	_queue.push_back(action)
	_try_start_processing()


## 将一个动作以显式 fire-and-forget 模式加入队列。
## 即使动作 execute() 返回 Signal，队列也会立即继续处理后续动作。
## @param action: 要入队的 GFVisualAction 实例。
func enqueue_fire_and_forget(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return
	action.completion_mode = GFVisualAction.CompletionMode.FIRE_AND_FORGET
	enqueue(action)


## 将一批动作加入队列，这批动作会并行执行，全部完成后才继续队列中的下一项。
## @param actions: 要并行执行的 GFVisualAction 实例数组。
func enqueue_parallel(actions: Array[GFVisualAction]) -> void:
	if actions.is_empty():
		return
		
	var group := GFVisualActionGroup.new(actions, true)
	_queue.push_back(group)
	_try_start_processing()


## 将一个动作插入队列头部（下一个执行）。
## 适用于"后发先至"的堆栈结算逻辑，如卡牌游戏的连锁效果。
## @param action: 要插入的 GFVisualAction 实例。
func push_front(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	_queue.push_front(action)
	_try_start_processing()


## 将一个动作以显式 fire-and-forget 模式插入队列头部。
## @param action: 要插入的 GFVisualAction 实例。
func push_front_fire_and_forget(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return
	action.completion_mode = GFVisualAction.CompletionMode.FIRE_AND_FORGET
	push_front(action)


## 将一批并行动作插入队列头部（下一批执行）。
## @param actions: 要并行执行的 GFVisualAction 实例数组。
func push_front_parallel(actions: Array[GFVisualAction]) -> void:
	if actions.is_empty():
		return
		
	var group := GFVisualActionGroup.new(actions, true)
	_queue.push_front(group)
	_try_start_processing()


## 清空队列中尚未执行的动作（不中断正在执行的动作）。
func clear_queue() -> void:
	_queue.clear()


# --- 私有/辅助方法 ---

## 若当前未在处理队列，则启动处理协程。
func _try_start_processing() -> void:
	if not is_processing:
		_process_queue()


## 核心队列处理协程。以单消费者模式顺序消费队列中的所有动作。
func _process_queue() -> void:
	if _queue.is_empty():
		return

	is_processing = true

	while not _queue.is_empty():
		var action: GFVisualAction = _queue.pop_front()

		if is_instance_valid(action):
			var res: Variant = action.execute()
			if action.should_wait_for_result(res):
				var target_obj: Object = res.get_object()
				
				# 防死锁保护：如果发射源无效，直接跳过
				if not is_instance_valid(target_obj):
					continue
					
				# 如果发射源是 Node，监听其 tree_exited 信号作为安全退出网
				if target_obj is Node:
					var node := target_obj as Node
					if not node.is_inside_tree():
						continue
						
					# 创建一个临时闭包来监听信号或节点销毁
					var completed := [false] # 使用数组存储布尔值以绕过闭包修改限制
					var on_resume := func(_arg1=null, _arg2=null, _arg3=null, _arg4=null): 
						completed[0] = true
					
					res.connect(on_resume, CONNECT_ONE_SHOT)
					if res != node.tree_exited:
						node.tree_exited.connect(on_resume, CONNECT_ONE_SHOT)
					
					# 轮询等待（效率略低但最稳健）或者使用内置机制
					# 在 Godot 4 中，最好的做法是等待直到布尔值变化
					while not completed[0]:
						if not is_instance_valid(node) or not node.is_inside_tree():
							break
						await Engine.get_main_loop().process_frame
				else:
					# 非 Node 对象（如 RefCounted），直接等待信号
					await res

	is_processing = false
	queue_drained.emit()
