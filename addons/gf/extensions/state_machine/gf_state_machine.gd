# addons/gf/extensions/state_machine/gf_state_machine.gd

## GFStateMachine: 纯代码分层有限状态机。
##
## 继承自 RefCounted，不依赖 Node 树，可在 GFSystem 或 GFUtility 中直接持有。
## 通过注入的 context（通常是拥有它的 GFSystem 实例）代理访问框架的
## Model、System、Utility 层，使得每个 GFState 都能安全地获取框架依赖。
##
## 使用示例：
##   var _fsm := GFStateMachine.new(self)
##   _fsm.add_state(&"Idle", IdleState.new())
##   _fsm.add_state(&"Run",  RunState.new())
##   _fsm.start(&"Idle")
class_name GFStateMachine
extends RefCounted


# --- 信号 ---

## 当状态成功切换后发出。
## @param from_state: 离开的状态名，初始切换时为空字符串。
## @param to_state: 进入的新状态名。
signal state_changed(from_state: StringName, to_state: StringName)


# --- 公共变量 ---

## 当前激活状态的注册名。
var current_state_name: StringName = &""


# --- 私有变量 ---

## 已注册的所有状态，Key 为 StringName，Value 为 GFState 实例。
var _states: Dictionary = {}

## 当前激活的状态实例。
var _current_state: GFState = null

## 用于访问框架层（Model/System/Utility）的上下文对象。
## 通常是拥有此状态机的 GFSystem 或 GFUtility 实例。
var _context: Object = null


# --- 公共方法 ---

## 创建状态机并注入框架上下文。
## @param context: 上下文对象，用于代理 get_model/get_system/get_utility 调用。
func _init(context: Object = null) -> void:
	_context = context


## 注册一个状态。注册后，状态机会自动注入自身引用。
## @param state_name: 用于标识和切换该状态的唯一名称。
## @param state: GFState 实例。
func add_state(state_name: StringName, state: GFState) -> void:
	state.setup(self )
	_states[state_name] = state


## 启动状态机并进入初始状态。
## @param initial_state_name: 首个要进入的状态名。
## @param msg: 传递给初始状态 enter() 的可选参数字典。
func start(initial_state_name: StringName, msg: Dictionary = {}) -> void:
	if not _states.has(initial_state_name):
		push_warning("[GFStateMachine] 启动失败，未找到状态：%s" % initial_state_name)
		return

	_current_state = _states[initial_state_name]
	current_state_name = initial_state_name
	_current_state.enter(msg)


## 切换到指定状态。会先调用当前状态的 exit()，再调用新状态的 enter()。
## @param state_name: 目标状态的注册名。
## @param msg: 传递给目标状态 enter() 的可选参数字典。
func change_state(state_name: StringName, msg: Dictionary = {}) -> void:
	if not _states.has(state_name):
		push_warning("[GFStateMachine] 切换失败，未找到状态：%s" % state_name)
		return

	var from_name := current_state_name

	if _current_state != null:
		_current_state.exit()

	_current_state = _states[state_name]
	current_state_name = state_name
	_current_state.enter(msg)

	state_changed.emit(from_name, state_name)


## 驱动当前状态的 update() 逻辑，应在宿主的 _process() 中调用。
## @param delta: 上一帧的时间间隔（秒）。
func update(delta: float) -> void:
	if _current_state != null:
		_current_state.update(delta)


## 停止状态机，调用当前状态的 exit() 并清除当前状态。
func stop() -> void:
	if _current_state != null:
		_current_state.exit()
		_current_state = null
		current_state_name = &""


## 代理获取框架内的 Model 实例。
## @param model_type: 模型的脚本类型。
## @return 模型实例，若上下文无效则返回 null。
func get_model(model_type: Script) -> Object:
	if not is_instance_valid(_context):
		push_error("[GFStateMachine] 上下文无效，无法获取 Model。")
		return null
	return Gf.get_architecture().get_model(model_type)


## 代理获取框架内的 System 实例。
## @param system_type: 系统的脚本类型。
## @return 系统实例，若上下文无效则返回 null。
func get_system(system_type: Script) -> Object:
	if not is_instance_valid(_context):
		push_error("[GFStateMachine] 上下文无效，无法获取 System。")
		return null
	return Gf.get_architecture().get_system(system_type)


## 代理获取框架内的 Utility 实例。
## @param utility_type: 工具的脚本类型。
## @return 工具实例，若上下文无效则返回 null。
func get_utility(utility_type: Script) -> Object:
	if not is_instance_valid(_context):
		push_error("[GFStateMachine] 上下文无效，无法获取 Utility。")
		return null
	return Gf.get_architecture().get_utility(utility_type)
