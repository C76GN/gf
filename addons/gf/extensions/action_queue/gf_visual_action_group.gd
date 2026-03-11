# addons/gf/extensions/action_queue/gf_visual_action_group.gd

## GFVisualActionGroup: 动作组复合节点 (Composite Pattern)
## 
## 继承自 GFVisualAction。允许将一组子动作打包，按并行（全部一起发出并等待全部完成）
## 或顺序（逐个执行并等待各自完成）两种模式执行。
class_name GFVisualActionGroup
extends GFVisualAction


# --- 信号 ---

## 内部使用：并行执行全部完成时发出。
signal _parallel_completed

## 内部使用：顺序执行全部完成时发出。
signal _sequence_completed


# --- 公共变量 ---

## 包含的子动作列表。
var actions: Array[GFVisualAction] = []

## 是否并行执行。为 true 时，并行触发所有子动作并等待全部完成；
## 为 false 时，按数组顺序依次执行并等待各自完成。
var is_parallel: bool = true


# --- Godot 生命周期方法 ---

func _init(actions_list: Array[GFVisualAction] = [], parallel: bool = true) -> void:
	actions = actions_list
	is_parallel = parallel


# --- 公共方法 ---

## 添加一个子动作。
## @param action: GFVisualAction 实例。
func add(action: GFVisualAction) -> void:
	if is_instance_valid(action):
		actions.append(action)


## 执行动作组逻辑。根据 is_parallel 决定并发还是串行。
## @return 需要等待则返回内部完成信号，否则返回 null。
func execute() -> Variant:
	if actions.is_empty():
		return null
		
	if is_parallel:
		return _run_parallel()
	else:
		return _run_sequence()


# --- 私有方法 ---

func _run_parallel() -> Variant:
	var pending_signals: Array[Signal] = []
	
	for action: GFVisualAction in actions:
		if not is_instance_valid(action):
			continue
			
		var res: Variant = action.execute()
		if res is Signal:
			pending_signals.append(res as Signal)
			
	if pending_signals.is_empty():
		return null
		
	var counter := {"count": pending_signals.size()}
	var on_single_completed := func() -> void:
		counter.count -= 1
		if counter.count <= 0:
			_parallel_completed.emit()
			
	for sig: Signal in pending_signals:
		if sig.get_object() != null and not sig.is_null():
			sig.connect(on_single_completed, CONNECT_ONE_SHOT)
		else:
			on_single_completed.call()
			
	return _parallel_completed


func _run_sequence() -> Variant:
	_do_sequence_async()
	return _sequence_completed


func _do_sequence_async() -> void:
	for action: GFVisualAction in actions:
		if not is_instance_valid(action):
			continue
			
		var res: Variant = action.execute()
		if res is Signal:
			await res
			
	_sequence_completed.emit()
