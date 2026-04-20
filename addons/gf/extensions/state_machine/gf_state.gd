# addons/gf/extensions/state_machine/gf_state.gd

## GFState: 纯代码状态机的状态抽象基类。
##
## 继承自 RefCounted，不依赖 Node 树，可在任何逻辑层使用。
## 通过持有对所属 GFStateMachine 的弱引用，间接访问框架的
## Model、System、Utility 层，实现状态与框架的解耦。
## 子类必须重写 enter()、update()、exit() 以实现具体状态逻辑。
class_name GFState
extends RefCounted


# --- 私有变量 ---

## 持有对所属状态机的弱引用，用于访问框架上下文和切换状态。
var _machine_ref: WeakRef = null


# --- 公共方法 ---

## 由 GFStateMachine 在内部调用，用于注入机器引用。
## @param machine: 拥有此状态的 GFStateMachine 实例。
func setup(machine: GFStateMachine) -> void:
	_machine_ref = weakref(machine) if machine != null else null


## 释放对状态机的引用，避免 RefCounted 环状引用。
func dispose() -> void:
	_machine_ref = null


## 进入此状态时调用。子类可重写以执行进入逻辑（如初始化动画）。
## @param msg: 从上一个状态或调用方传递过来的可选参数字典。
func enter(_msg: Dictionary = {}) -> void:
	pass


## 每帧更新时调用，用于处理持续性逻辑（如计时、轮询）。
## @param delta: 上一帧的时间间隔（秒）。
func update(_delta: float) -> void:
	pass


## 退出此状态时调用。子类可重写以执行清理逻辑（如停止动画）。
func exit() -> void:
	pass


## 获取框架内的 Model 实例（委托给所属状态机）。
## @param model_type: 模型的脚本类型。
## @return 模型实例。
func get_model(model_type: Script) -> Object:
	var machine := _get_machine()
	if machine == null:
		return null
	return machine.get_model(model_type)


## 获取框架内的 System 实例（委托给所属状态机）。
## @param system_type: 系统的脚本类型。
## @return 系统实例。
func get_system(system_type: Script) -> Object:
	var machine := _get_machine()
	if machine == null:
		return null
	return machine.get_system(system_type)


## 获取框架内的 Utility 实例（委托给所属状态机）。
## @param utility_type: 工具的脚本类型。
## @return 工具实例。
func get_utility(utility_type: Script) -> Object:
	var machine := _get_machine()
	if machine == null:
		return null
	return machine.get_utility(utility_type)


## 请求状态机切换到指定状态。
## @param state_name: 目标状态的注册名。
## @param msg: 传递给目标状态 enter() 的可选参数字典。
func change_state(state_name: StringName, msg: Dictionary = {}) -> void:
	var machine := _get_machine()
	if machine != null:
		machine.change_state(state_name, msg)


# --- 私有/辅助方法 ---

func _get_machine() -> GFStateMachine:
	if _machine_ref == null:
		return null
	return _machine_ref.get_ref() as GFStateMachine
